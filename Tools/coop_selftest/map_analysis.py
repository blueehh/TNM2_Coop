"""Per-map co-op risk analysis.

Exports a map to T3D with HTK, resolves every placed actor's class chain across
the script packages the game loads, and reports which placed logic actors
(triggers, conversation/flag/skill triggers, NPCs, movers, devices) inherit code
that only looks at the host, plus timing-sensitive setups.

usage:
    python -I map_analysis.py 20_FCDowntown [--out report.md] [--t3d existing.t3d]
"""
import argparse
import os
import re
import shutil
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))

import config  # noqa: E402
import scanner  # noqa: E402

# Packages whose classes appear in TNM maps, in load order (later wins on name clashes).
PACKAGES = [
    ('Engine', 'System'), ('DeusEx', 'System'), ('MoreTriggers', 'ws_tnm'), ('CaroneElevatorSet', 'ws_tnm'),
    ('precipitation', 'ws_tnm'), ('TNM', 'coop'), ('TNMItems', 'ws_tnm'), ('TNMCharacters', 'ws_tnm'),
    ('TNMDeco', 'ws_tnm'),
]

LOGIC_ROOTS = {'triggers', 'keypoint', 'scriptedpawn', 'mover', 'electronicdevices', 'hackabledevices',
               'missionscript', 'info', 'teleporter', 'navigationpoint'}
SKIP_ROOTS = {'light', 'brush', 'zoneinfo', 'decal', 'pathnode', 'ambientsound'}
EVENT_FUNCS = re.compile(r'(?:^|\.)(Touch|UnTouch|Trigger|UnTrigger|Tick|Timer|Frob|Bump|HitWall|BeginPlay|PostBeginPlay|'
                         r'BeginState|EndState|Activate|TakeDamage|ZoneChange|SeePlayer|HearNoise|EnemyAcquired)$', re.I)
KEYPROPS = ('Tag', 'Event', 'TriggerType', 'bTriggerOnceOnly', 'ReTriggerDelay', 'bInitiallyActive', 'ClassProximityType',
            'BindName', 'conversationTag', 'datalinkTag', 'FlagName', 'flagValue', 'flagExpiration', 'checkFlag',
            'skillPointsAdded', 'goalName', 'Alliance', 'Orders', 'OrderTag', 'bInvincible', 'CollisionRadius',
            'DestMap', 'URL', 'bIsSecretGoal', 'awardMessage', 'newAlliance', 'Alliances', 'Message')


def export_t3d(map_name):
    cfg = config.load()
    game, ws = cfg['game_dir'], cfg['workshop_dir']
    out_dir = os.path.join(cfg['cache_dir'], 'maps')
    os.makedirs(out_dir, exist_ok=True)
    out = os.path.join(out_dir, map_name + '.t3d')
    if os.path.exists(out):
        return out
    src = None
    for d in (os.path.join(ws, 'TNM2', 'Maps'), os.path.join(game, '..', 'OldMaps'), os.path.join(game, '..', '..', 'Maps')):
        p = os.path.join(d, map_name + '.dx')
        if os.path.exists(p):
            src = p
            break
    if not src:
        raise FileNotFoundError(map_name + '.dx')
    staged = []
    for s, name in ((os.path.join(ws, 'TNM2', 'System', 'HTK.exe'), 'HTK.exe'), (os.path.join(ws, 'System', 'HTK.dll'), 'HTK.dll')):
        dst = os.path.join(game, name)
        if not os.path.exists(dst):
            shutil.copy2(s, dst)
            staged.append(dst)
    work = os.path.join(game, 'HTKMapWork')
    os.makedirs(work, exist_ok=True)
    shutil.copy2(src, os.path.join(work, map_name + '.dx'))
    with open(os.path.join(game, 'TNM_Host.ini'), encoding='latin1') as f:
        ini = f.read().replace('EditorEngine=Editor.EditorEngine', 'EditorEngine=HTK.HTKEditorEngine')
    ini = ini.replace('[Editor.EditorEngine]', '[HTK.HTKEditorEngine]')
    with open(os.path.join(game, 'HTK_Map.ini'), 'w', encoding='latin1', newline='') as f:
        f.write(ini)
    with open(os.path.join(game, 'htk_map.txt'), 'w') as f:
        f.write('MAP LOAD FILE=HTKMapWork\\%s.dx\nMAP EXPORT FILE=HTKMapWork\\%s.t3d\nEXIT\n' % (map_name, map_name))
    try:
        subprocess.run([os.path.join(game, 'HTK.exe'), 'EXEC=htk_map.txt', 'INI=HTK_Map.ini', 'USERINI=TNMUser_Host.ini',
                        'LOG=htk_map.log', '-FORCELOGFLUSH'], cwd=game, timeout=600)
        shutil.copy2(os.path.join(work, map_name + '.t3d'), out)
    finally:
        shutil.rmtree(work, ignore_errors=True)
        for p in staged + [os.path.join(game, n) for n in ('HTK_Map.ini', 'htk_map.txt', 'htk_map.log')]:
            try:
                os.remove(p)
            except OSError:
                pass
    return out


def parse_t3d(path):
    actors, cur, depth = [], None, 0
    with open(path, encoding='latin1') as f:
        for line in f:
            s = line.strip()
            m = re.match(r'Begin Actor Class=(\w+) Name=(\w+)', s)
            if m and cur is None:
                cur, depth = {'class': m.group(1), 'name': m.group(2), 'props': {}}, 0
                continue
            if cur is None:
                continue
            if s.startswith('Begin '):
                depth += 1
                continue
            if s.startswith('End '):
                if depth == 0:
                    actors.append(cur)
                    cur = None
                else:
                    depth -= 1
                continue
            if depth == 0 and '=' in s:
                k, v = s.split('=', 1)
                cur['props'][k] = v
    return actors


def load_packages():
    """{lower class name: (package, ClassName, source text)}"""
    cfg = config.load()
    import uexport
    classes = {}
    roots = {'System': os.path.join(cfg['game_dir'], '..', '..', 'System'),
             'ws_tnm': os.path.join(cfg['workshop_dir'], 'TNM2', 'System'),
             'coop': os.path.dirname(cfg['installed_tnm'])}
    for pkg, where in PACKAGES:
        path = os.path.join(roots[where], pkg + '.u')
        if not os.path.exists(path):
            continue
        out = os.path.join(cfg['cache_dir'], 'pkg_' + pkg)
        if not os.path.isdir(out) or not os.listdir(out):
            uexport.export_scripts(path, out)
        for f in os.listdir(out):
            if f.lower().endswith('.uc'):
                with open(os.path.join(out, f), encoding='latin1') as fh:
                    classes[f[:-3].lower()] = (pkg, f[:-3], fh.read())
    if os.path.isdir(cfg['source_dir']):  # current edits win
        for f in os.listdir(cfg['source_dir']):
            if f.lower().endswith('.uc'):
                with open(os.path.join(cfg['source_dir'], f), encoding='latin1') as fh:
                    classes[f[:-3].lower()] = ('TNM', f[:-3], fh.read())
    return classes


def chain_of(cls, parent):
    out, c = [], cls.lower()
    while c and c not in out:
        out.append(c)
        c = parent.get(c)
    return out


def analyze(map_name, t3d=None):
    t3d = t3d or export_t3d(map_name)
    actors = parse_t3d(t3d)
    classes = load_packages()
    parent = scanner.class_graph({k: v[2] for k, v in classes.items()})
    findings_cache = {}

    def class_findings(c):
        if c not in findings_cache:
            if c in classes:
                fs = scanner.scan_class(classes[c][1], classes[c][2], parent)
                findings_cache[c] = [f for f in fs if f['severity'] != 'info' or f['rule'].startswith('HOST')]
            else:
                findings_cache[c] = []
        return findings_cache[c]

    placed = {}
    for a in actors:
        placed.setdefault(a['class'].lower(), []).append(a)

    rows = []
    for c, insts in placed.items():
        chain = chain_of(c, parent)
        if any(x in SKIP_ROOTS for x in chain) or not any(x in LOGIC_ROOTS for x in chain):
            continue
        risks = []
        for anc in chain:
            for f in class_findings(anc):
                fn = f['function'].split('.')[-1] if f['function'] else ''
                if f['rule'].startswith('HOST') or f['rule'] in ('FIRST_PLAYER_ONLY', 'MISSION_HOST_PLAYER'):
                    if not EVENT_FUNCS.search(fn) and f['severity'] != 'warning':
                        continue
                risks.append(f)
        rows.append({'class': classes.get(c, ('?', c))[1], 'package': classes.get(c, ('?',))[0], 'count': len(insts),
                     'chain': ' < '.join(classes.get(x, ('?', x))[1] for x in chain[:6]), 'risks': risks, 'instances': insts})
    rows.sort(key=lambda r: (-sum(1 for f in r['risks'] if f['severity'] == 'warning'), -r['count'], r['class']))

    # Radius-invoked conversations: stock ScriptedPawn/DeusExDecoration.Tick only
    # call StartConversation(Self, IM_Radius) on GetPlayerPawn() (the host).
    radius = []
    try:
        import conversations
        owners = {}
        for c in conversations.list_conversations():
            if c.get('bInvokeRadius'):
                owners.setdefault(c.get('conOwnerName', '').lower(), []).append(c)
        for a in actors:
            ch = chain_of(a['class'], parent)
            if 'scriptedpawn' not in ch and 'deusexdecoration' not in ch:
                continue  # e.g. ConversationTrigger.BindName names the NPC it targets
            bn = a['props'].get('BindName', '').strip('"').lower()
            for c in owners.get(bn, []):
                radius.append((a, c))
    except Exception as e:  # conversation packages missing or unreadable
        radius = [('error', str(e))]

    # Triggers: stock SkillAwardTrigger/FlagTrigger/ConversationTrigger default to
    # bTriggerOnceOnly=True (T3D omits defaults), and Trigger.Touch/UnTouch keep
    # no occupancy count, so two players re-fire / release triggers.
    by_tag = {}
    for a in actors:
        by_tag.setdefault(a['props'].get('Tag', '').lower(), []).append(a)
    awards, mover_links = [], []
    for a in actors:
        ch = chain_of(a['class'], parent)
        if 'trigger' not in ch:
            continue
        p = a['props']
        once = p.get('bTriggerOnceOnly', 'True' if a['class'].lower() in ONCE_BY_DEFAULT else 'False') == 'True'
        if 'skillawardtrigger' in ch:
            awards.append((a, once))
        for t in by_tag.get(p.get('Event', '').lower(), []) if p.get('Event') else []:
            if 'mover' in chain_of(t['class'], parent):
                mover_links.append((a, once, t, t['props'].get('InitialState', 'BumpOpenTimed')))
    return {'map': map_name, 'actor_count': len(actors), 'rows': rows, 'placed': placed,
            'radius': radius, 'awards': awards, 'mover_links': mover_links}


ONCE_BY_DEFAULT = {'skillawardtrigger', 'flagtrigger', 'conversationtrigger', 'datalinktrigger', 'goalcompletetrigger',
                   'conversationforcetrigger'}
RISKY_MOVER_STATES = {'triggertoggle', 'triggercontrol', 'triggerpound'}


def to_markdown(res, max_instances=12):
    out = ['# Co-op map analysis: %s' % res['map'], '', '%d actors placed.' % res['actor_count'], '']

    out += ['## Proximity (radius) conversations', '',
            'Stock `ScriptedPawn.Tick` / `DeusExDecoration.Tick` start these only for `GetPlayerPawn()` (the host). '
            'A client walking up alone does not trigger them.', '']
    if res['radius'] and res['radius'][0][0] == 'error':
        out.append('- (could not read conversations: %s)' % res['radius'][0][1])
    elif not res['radius']:
        out.append('- none')
    for a, c in res['radius']:
        out.append('- `%s` (%s) — **%s** radius %s, first-person=%s, once=%s' % (
            a['props'].get('BindName', '').strip('"'), a['class'], c.get('conName'), c.get('radiusDistance', '?'),
            c.get('bFirstPerson', False), c.get('bDisplayOnce', False)))

    total = sum(int(a['props'].get('skillPointsAdded', '10') or 10) for a, once in res['awards'] if once)
    out += ['', '## Skill award triggers', '',
            'Stock `SkillAwardTrigger` gives points only to the toucher/instigator. Once-only ones then switch off, '
            'so the other player never gets them (%d points across once-only awards here).' % total, '']
    for a, once in res['awards']:
        out.append('- `%s` %s pts, once=%s, radius=%s' % (a['name'], a['props'].get('skillPointsAdded', '10'), once,
                                                          a['props'].get('CollisionRadius', 'default')))
    if not res['awards']:
        out.append('- none')

    out += ['', '## Triggers wired to movers', '',
            '`Trigger.Touch` has no occupancy count and `UnTouch` fires when either player leaves. Risky for '
            'non-once triggers driving TriggerToggle (opens then closes when both players enter) or '
            'TriggerControl (closes on the partner when one leaves).', '']
    for a, once, t, st in res['mover_links']:
        risky = (not once) and st.lower() in RISKY_MOVER_STATES
        out.append('- %s`%s` (%s, once=%s) -> `%s` %s' % ('**RISK** ' if risky else '', a['name'], a['class'], once, t['name'], st))
    if not res['mover_links']:
        out.append('- none')

    out += ['', '## Logic actors and inherited co-op hazards', '',
            '| Class | Placed | Warnings | Chain |', '|---|---|---|---|']
    for r in res['rows']:
        w = sum(1 for f in r['risks'] if f['severity'] == 'warning')
        out.append('| %s | %d | %d | %s |' % (r['class'], r['count'], w, r['chain']))
    for r in res['rows']:
        if not r['risks']:
            continue
        out += ['', '## %s (%d placed, %s)' % (r['class'], r['count'], r['package'])]
        seen = set()
        for f in r['risks']:
            key = (f['class'], f['line'])
            if key in seen:
                continue
            seen.add(key)
            out.append('- **%s** %s `%s.%s` line %d: `%s`' % (f['severity'].upper(), f['rule'], f['class'], f['function'] or '?',
                                                               f['line'], f['code'].replace('`', "'")))
        out.append('')
        out.append('Placed instances:')
        for a in r['instances'][:max_instances]:
            props = ', '.join('%s=%s' % (k, a['props'][k]) for k in KEYPROPS if k in a['props'])
            out.append('- `%s` %s' % (a['name'], props[:300]))
        if len(r['instances']) > max_instances:
            out.append('- ... %d more' % (len(r['instances']) - max_instances))
    return '\n'.join(out) + '\n'


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('map')
    ap.add_argument('--t3d')
    ap.add_argument('--out')
    a = ap.parse_args()
    md = to_markdown(analyze(a.map, a.t3d))
    if a.out:
        with open(a.out, 'w', encoding='utf-8') as f:
            f.write(md)
        print('->', a.out)
    else:
        sys.stdout.write(md)
