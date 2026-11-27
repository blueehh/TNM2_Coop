"""Static scanner for co-op hazards in TNM / Deus Ex UnrealScript.

Every rule encodes a bug that was actually hit in the co-op port (see AGENTS.md):
code that only looks at the host, deathmatch-only branches, replication
mistakes, and client-side calls that silently do nothing.

usage:
    python -I scanner.py                      # installed CoopMod TNM.u + bundle Source overrides
    python -I scanner.py --dir <folder of .uc> [--min warning] [--class Trestkon] [--json out.json]
"""
import argparse
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))

import config  # noqa: E402

SEVERITY = {'info': 0, 'warning': 1, 'error': 2}

FUNC_RE = re.compile(
    r'^\s*(?:(?:simulated|static|final|native|exec|singular|latent|iterator|private|protected|reliable|unreliable)\s+)*'
    r'(?:function|event)\s+(?:[\w<>.]+\s+)?(\w+)\s*\(', re.I)
STATE_RE = re.compile(r'^\s*(?:auto\s+|simulated\s+)*state\s+(\w+)', re.I)
CLASS_RE = re.compile(r'^\s*class\s+(\w+)\s+(?:extends|expands)\s+([\w.]+)', re.I | re.M)
VAR_RE = re.compile(r'^\s*var(?:\s*\([^)]*\))?\s+(?:[\w<>]+\s+)*?([\w<>.]+)\s+([^;]+);', re.I)

# What a GetPlayerPawn() line is doing decides how bad "host only" is.
HOST_BENIGN = re.compile(r'SetAchievement|autosave|SaveConfig|Unlocked|PostIntro|\bbUnlock|Achievement', re.I)
HOST_FLAGS = re.compile(r'flagbase', re.I)
HOST_GAMEPLAY = re.compile(
    r'TakeDamage|VSize|Location|Health|bBreakAndEnter|GiveTo|Trigger\(|inHand|Inventory|Touch|halongas|'
    r'IsInState|StartConversation|SetPhysics|SetLocation|bInsane|ClientMessage', re.I)

PLAYER_CLASSES = r"(?:PlayerPawn|DeusExPlayer|Trestkon|Human)"
FIRST_PLAYER_LOOP = re.compile(r"foreach\s+(?:\w+\.)?AllActors\s*\(\s*class\s*'" + PLAYER_CLASSES + r"'", re.I)
MISSION_PLAYER = re.compile(r'VSize\s*\(\s*Player\b|\bPlayer\.(?:Location|Health|inHand|bHidden|IsInState|FindInventoryType|CarriedDecoration)\b', re.I)
NETMODE = re.compile(r'NetMode\s*(?:!=|==)\s*NM_Standalone', re.I)
OGG_NATIVE = re.compile(r'(?<!CoopNative)\b(?:SetCurrentOgg|GetCurrentSongPosition|StopPlayback|GetNextOggFileLoop|GetNextOggFileIntro)\s*\(')
SELECTED_AMMO = re.compile(r'GetSelectedAmmo\s*\(')


def strip_comments(lines):
    out, in_block = [], False
    for line in lines:
        s = line
        if in_block:
            end = s.find('*/')
            if end < 0:
                out.append('')
                continue
            s = s[end + 2:]
            in_block = False
        while '/*' in s:
            start = s.find('/*')
            end = s.find('*/', start + 2)
            if end < 0:
                s = s[:start]
                in_block = True
                break
            s = s[:start] + s[end + 2:]
        cut = s.find('//')
        if cut >= 0:
            s = s[:cut]
        out.append(s)
    return out


def load_sources(directory):
    srcs = {}
    for f in os.listdir(directory):
        if f.lower().endswith('.uc'):
            with open(os.path.join(directory, f), encoding='latin1') as fh:
                srcs[f[:-3]] = fh.read()
    return srcs


def class_graph(srcs):
    parent = {}
    for name, text in srcs.items():
        m = CLASS_RE.search(text)
        if m:
            parent[name.lower()] = m.group(2).split('.')[-1].lower()
    return parent


def descends_from(cls, ancestor, parent):
    cls, ancestor = cls.lower(), ancestor.lower()
    seen = set()
    while cls in parent and cls not in seen:
        if cls == ancestor:
            return True
        seen.add(cls)
        cls = parent[cls]
    return cls == ancestor


def parse_replication(lines):
    """[(condition, [names], line_no)] from the replication block."""
    blocks, i = [], 0
    text_lines = [l for l in lines]
    while i < len(text_lines):
        if re.match(r'^\s*replication\b', text_lines[i], re.I):
            depth, j, body = 0, i, []
            while j < len(text_lines):
                depth += text_lines[j].count('{') - text_lines[j].count('}')
                body.append((j, text_lines[j]))
                if depth <= 0 and '}' in text_lines[j] and j > i:
                    break
                j += 1
            joined = ' '.join(l for _, l in body)
            for m in re.finditer(r'(un)?reliable\s+if\s*\((.*?)\)\s*([\w\s,]+?);', joined, re.I | re.S):
                cond = m.group(2)
                # balance parens: the lazy match can stop early on nested parens
                names = [n.strip() for n in m.group(3).split(',') if n.strip()]
                ln = next((k for k, l in body if names and names[0] in l), i)
                blocks.append((cond, names, ln + 1))
            i = j
        i += 1
    return blocks


def scan_class(name, text, parent):
    raw = text.replace('\r\n', '\n').split('\n')
    lines = strip_comments(raw)
    findings = []

    def add(rule, sev, ln, msg, advice):
        findings.append({'class': name, 'line': ln, 'rule': rule, 'severity': sev,
                         'function': func_at.get(ln, ''), 'code': raw[ln - 1].strip()[:200],
                         'message': msg, 'advice': advice})

    # which function / state each line belongs to
    func_at, simulated_at, cur, cur_sim, state = {}, {}, '', False, ''
    depth, state_open = 0, False
    for idx, line in enumerate(lines, 1):
        sm = STATE_RE.match(line)
        if sm and depth == 0:
            state, state_open = sm.group(1), False
        fm = FUNC_RE.match(line)
        if fm:
            cur = (state + '.' if state else '') + fm.group(1)
            cur_sim = bool(re.match(r'^\s*(?:\w+\s+)*simulated\b', line, re.I))
        func_at[idx] = cur
        simulated_at[idx] = cur_sim
        depth += line.count('{') - line.count('}')
        if state and depth > 0:
            state_open = True
        if state and state_open and depth == 0:
            state, state_open = '', False

    declared_funcs = {FUNC_RE.match(l).group(1).lower() for l in lines if FUNC_RE.match(l)}
    declared_vars = set()
    for l in lines:
        vm = VAR_RE.match(l)
        if vm:
            for v in vm.group(2).split(','):
                declared_vars.add(re.sub(r'\[.*', '', v).strip().lower())

    is_mission = descends_from(name, 'MissionScript', parent)

    for idx, line in enumerate(lines, 1):
        if not line.strip():
            continue

        if re.search(r'\bGetPlayerPawn\s*\(', line, re.I):
            if HOST_BENIGN.search(line):
                add('HOST_ONLY', 'info', idx, 'GetPlayerPawn() is the host; this looks like host-side persistence or cosmetics.',
                    'Usually fine. If the client should get it too, loop Level.PawnList for Trestkon.')
            elif HOST_FLAGS.search(line):
                add('HOST_ONLY_FLAGS', 'info', idx, 'Reads/writes the host flagBase.',
                    'Fine while tnmGameInfo.CoopMergeFlags runs (host<->client merge every second).')
            elif HOST_GAMEPLAY.search(line) or 'Tick' in func_at.get(idx, '') or 'Touch' in func_at.get(idx, ''):
                add('HOST_ONLY', 'warning', idx, 'Gameplay check or effect against the host only (GetPlayerPawn()).',
                    'Use the instigator/toucher, the closest Trestkon, or every Trestkon in Level.PawnList.')
            else:
                add('HOST_ONLY', 'info', idx, 'GetPlayerPawn() returns the host on a listen server.',
                    'Check whether the client should be considered here.')

        if FIRST_PLAYER_LOOP.search(line):
            window = ' '.join(lines[idx - 1:idx + 7])
            if re.search(r'\bbreak\s*;', window) or re.search(r'\breturn\b', window):
                add('FIRST_PLAYER_ONLY', 'warning', idx, 'Loop over players stops at the first one (the host in practice).',
                    'Handle every player, or pick the relevant one explicitly.')

        if is_mission and MISSION_PLAYER.search(line):
            add('MISSION_HOST_PLAYER', 'warning', idx, "MissionScript.Player is the host; this distance/state check ignores the client.",
                'Check every Trestkon (see TNMMissionScript proximity helpers).')

        if NETMODE.search(line):
            add('NETMODE_BRANCH', 'info', idx, 'Standalone vs netgame branch. Co-op runs the netgame side, which is usually deathmatch logic.',
                'Gate deathmatch rules on a real DeusExMPGame (see TNMWeapon.IsDeathmatchStats).')

        if OGG_NATIVE.search(line) and simulated_at.get(idx) and not func_at.get(idx, '').lower().startswith('coopnative'):
            add('OGG_NATIVE_ON_CLIENT', 'warning', idx, 'DXOgg natives do nothing unless Role == ROLE_Authority; a simulated call on a client is a no-op.',
                'Call through TNMOggMusicManager.CoopNative* helpers.')

        if SELECTED_AMMO.search(line):
            add('DANGLING_AMMO_BUTTON', 'error' if 'Tick' in func_at.get(idx, '') or 'Refresh' in func_at.get(idx, '') else 'warning', idx,
                'PersonaInventoryInfoWindow.GetSelectedAmmo() can read a destroyed button after Clear().',
                'Walk winInfo.winTileAmmo children instead (Trestkon.CoopGetLoadedAmmoButton).')

    for cond, names, ln in parse_replication(lines):
        funcs = [n for n in names if n.lower() in declared_funcs]
        vars_ = [n for n in names if n.lower() in declared_vars]
        if funcs and re.search(r'bNetOwner', cond, re.I):
            findings.append({'class': name, 'line': ln, 'rule': 'REP_FUNC_NETOWNER', 'severity': 'error', 'function': '',
                             'code': 'reliable if (' + cond.strip() + ') ' + ', '.join(funcs),
                             'message': 'Replicated functions gated on bNetOwner: it is stale at call time, so calls can run on the server instead of being sent.',
                             'advice': 'Use reliable if (Role == ROLE_Authority) for client functions; keep bNetOwner for variables.'})
        if vars_ and re.search(r'Role\s*<\s*ROLE_Authority', cond, re.I):
            findings.append({'class': name, 'line': ln, 'rule': 'VAR_CLIENT_TO_SERVER', 'severity': 'warning', 'function': '',
                             'code': ', '.join(vars_),
                             'message': 'UE1 never replicates variables client->server; these never reach the server.',
                             'advice': 'Send them with a server RPC (see Trestkon.ServerSetMovementPrefs).'})
    return findings


def resolve_sources(source='installed', directory=None):
    """Return a directory of .uc files to scan.

    installed: ScriptText of the installed CoopMod TNM.u (all classes), with the
               bundle's Source/Classes copies laid over it.
    bundle:    only Source/Classes.
    """
    cfg = config.load()
    if directory:
        return directory
    if source == 'bundle':
        return cfg['source_dir']
    import uexport
    out = os.path.join(cfg['cache_dir'], 'installed_tnm')
    os.makedirs(out, exist_ok=True)
    uexport.export_scripts(cfg['installed_tnm'], out)
    if os.path.isdir(cfg['source_dir']):
        for f in os.listdir(cfg['source_dir']):
            if f.lower().endswith('.uc'):
                with open(os.path.join(cfg['source_dir'], f), encoding='latin1') as src:
                    text = src.read()
                with open(os.path.join(out, f), 'w', encoding='latin1', newline='') as dst:
                    dst.write(text)
    return out


def scan(directory, min_severity='info', class_filter=None, rules=None):
    srcs = load_sources(directory)
    parent = class_graph(srcs)
    found = []
    for name in sorted(srcs, key=str.lower):
        if class_filter and not re.search(class_filter, name, re.I):
            continue
        for f in scan_class(name, srcs[name], parent):
            if SEVERITY[f['severity']] >= SEVERITY[min_severity] and (not rules or f['rule'] in rules):
                found.append(f)
    return found


def to_markdown(findings, title='Co-op script scan'):
    by_rule, by_class = {}, {}
    for f in findings:
        by_rule.setdefault((f['rule'], f['severity']), 0)
        by_rule[(f['rule'], f['severity'])] += 1
        by_class.setdefault(f['class'], []).append(f)
    out = ['# ' + title, '', '| Rule | Severity | Count |', '|---|---|---|']
    for (rule, sev), n in sorted(by_rule.items(), key=lambda x: (-SEVERITY[x[0][1]], x[0][0])):
        out.append('| %s | %s | %d |' % (rule, sev, n))
    for cls in sorted(by_class, key=lambda c: (-max(SEVERITY[f['severity']] for f in by_class[c]), c.lower())):
        out += ['', '## ' + cls]
        for f in sorted(by_class[cls], key=lambda f: f['line']):
            fn = (' `%s`' % f['function']) if f['function'] else ''
            out.append('- **%s** %s line %d%s: `%s`  \n  %s %s' % (
                f['severity'].upper(), f['rule'], f['line'], fn, f['code'].replace('`', "'"), f['message'], f['advice']))
    return '\n'.join(out) + '\n'


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--source', choices=['installed', 'bundle'], default='installed')
    ap.add_argument('--dir', help='scan this folder of .uc files instead')
    ap.add_argument('--min', default='info', choices=list(SEVERITY))
    ap.add_argument('--class', dest='cls', help='regex on class name')
    ap.add_argument('--rule', action='append', help='only these rules (repeatable)')
    ap.add_argument('--json', help='also write findings as JSON here')
    ap.add_argument('--out', help='write the markdown report here instead of stdout')
    a = ap.parse_args()
    d = resolve_sources(a.source, a.dir)
    findings = scan(d, a.min, a.cls, a.rule)
    md = to_markdown(findings)
    if a.out:
        with open(a.out, 'w', encoding='utf-8') as f:
            f.write(md)
        print('%d findings -> %s' % (len(findings), a.out))
    else:
        sys.stdout.write(md)
    if a.json:
        with open(a.json, 'w', encoding='utf-8') as f:
            json.dump(findings, f, indent=1)


if __name__ == '__main__':
    main()
