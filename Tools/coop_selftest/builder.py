"""Rebuild TNM.u from the bundle's Source/Classes with HTK (Python port of Tools/build_tnm.sh).

usage: python -I builder.py [--deploy]

Without --deploy the package is left at <game>/HTKWork/TNM.u. With --deploy it
replaces CoopMod/System/TNM.u (previous one kept as TNM.u.bak_<timestamp>) and
the bundle copy. Refuses to deploy if the compile log has any error: HTK still
writes a broken, script-less package when a class fails to compile.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import config  # noqa: E402

# Asset sources the classes import with #ForceExec / AUDIO IMPORT, relative to
# the game folder (HTK's working directory). Copied in for the build and removed
# afterwards unless the bundle *is* the game folder.
ASSET_DIRS = ('Models', os.path.join('Textures', 'Skins'))
COOP_SOUNDS = (
    (os.path.join('Source', 'CoopPingSound.wav'), 'CoopPingSound'),
    (os.path.join('Source', 'CoopChatSound.wav'), 'CoopChatSound'),
)

DROP_EDIT_PACKAGES = {'EditPackages=TNMItems', 'EditPackages=TNMCharacters', 'EditPackages=TNMDeco', 'EditPackages=TNMGUI'}


def build(deploy=False, timeout=600):
    cfg = config.load()
    game, ws = cfg['game_dir'], cfg['workshop_dir']
    result = {'ok': False, 'deployed': False, 'errors': [], 'log': os.path.join(game, 'htk_build.log')}

    live = cfg['installed_tnm']
    os.makedirs(os.path.dirname(live), exist_ok=True)
    prev_backup = None
    if os.path.exists(live):
        prev_backup = live + '.bak_' + time.strftime('%Y%m%d_%H%M%S')
        shutil.copy2(live, prev_backup)

    # Always seed CoopMod/System/TNM.u from CleanBase_TNM.u (or Workshop TNM.u) before HTK runs
    clean_candidates = [
        os.path.join(cfg['bundle_dir'], 'Tools', 'CleanBase_TNM.u'),
        os.path.join(os.path.dirname(cfg['bundle_dir']), 'CleanBase_TNM.u'),
        os.path.join(ws, 'TNM2', 'System', 'TNM.u'),
    ]
    for cand in clean_candidates:
        if os.path.exists(cand):
            shutil.copy2(cand, live)
            break

    staged = []
    for src, name in ((os.path.join(ws, 'TNM2', 'System', 'HTK.exe'), 'HTK.exe'),
                      (os.path.join(ws, 'System', 'HTK.dll'), 'HTK.dll'),
                      (os.path.join(ws, 'System', 'lib3ds.dll'), 'lib3ds.dll')):
        dst = os.path.join(game, name)
        if not os.path.exists(dst):
            shutil.copy2(src, dst)
            staged.append(dst)

    with open(os.path.join(game, 'TNM_Host.ini'), encoding='latin1') as f:
        ini = f.read()
    ini = ini.replace('EditorEngine=Editor.EditorEngine', 'EditorEngine=HTK.HTKEditorEngine')
    ini = ini.replace('[Editor.EditorEngine]', '[HTK.HTKEditorEngine]')
    ini = '\n'.join(l for l in ini.split('\n') if l.strip() not in DROP_EDIT_PACKAGES)
    with open(os.path.join(game, 'HTK_Build.ini'), 'w', encoding='latin1', newline='') as f:
        f.write(ini)

    staged_dirs = []
    same_dir = os.path.normcase(os.path.abspath(cfg['bundle_dir'])) == os.path.normcase(os.path.abspath(game))
    if not same_dir:
        sound_basenames = {os.path.basename(rel_p).lower() for rel_p, _ in COOP_SOUNDS}
        for rel in ASSET_DIRS + ('Source',):
            src_dir = os.path.join(cfg['bundle_dir'], rel)
            if not os.path.isdir(src_dir):
                continue
            top = os.path.join(game, rel.split(os.sep)[0])
            if not os.path.exists(top):
                staged_dirs.append(top)
            os.makedirs(os.path.join(game, rel), exist_ok=True)
            for f in os.listdir(src_dir):
                if rel == 'Source' and f.lower() not in sound_basenames:
                    continue
                if os.path.isfile(os.path.join(src_dir, f)):
                    shutil.copy2(os.path.join(src_dir, f), os.path.join(game, rel, f))

    work = os.path.join(game, 'HTKWork')
    shutil.rmtree(work, ignore_errors=True)
    os.makedirs(os.path.join(work, 'src'))
    classes = []
    for f in sorted(os.listdir(cfg['source_dir'])):
        if f.lower().endswith('.uc'):
            shutil.copy2(os.path.join(cfg['source_dir'], f), os.path.join(work, 'src', f))
            classes.append(f[:-3])
    lines = []
    for rel_sound, snd_name in COOP_SOUNDS:
        if os.path.exists(os.path.join(game, rel_sound)):
            lines.append('AUDIO IMPORT FILE=%s NAME=%s PACKAGE=TNM' % (rel_sound, snd_name))
    lines += [r'CLASS LOAD FILE=HTKWork\src\%s.uc PACKAGE=TNM NAME=%s' % (c, c) for c in classes]
    lines += ['SCRIPT MAKE', r'OBJ SAVEPACKAGE PACKAGE=TNM FILE=HTKWork\TNM.u', 'EXIT']
    with open(os.path.join(game, 'build_tnm.txt'), 'w') as f:
        f.write('\n'.join(lines) + '\n')

    try:
        subprocess.run([os.path.join(game, 'HTK.exe'), 'EXEC=build_tnm.txt', 'INI=HTK_Build.ini',
                        'USERINI=TNMUser_Host.ini', 'LOG=htk_build.log', '-FORCELOGFLUSH'],
                       cwd=game, timeout=timeout)
    except subprocess.TimeoutExpired:
        result['errors'].append('HTK timed out after %ds' % timeout)

    with open(result['log'], encoding='latin1', errors='replace') as f:
        log = f.read()
    result['errors'] += re.findall(r'^.*(?:Error in |: Error).*$', log, re.M)
    m = re.search(r'Success: Compiled .*', log)
    result['compiled'] = m.group(0) if m else None
    result['classes'] = len(classes)
    result['ok'] = bool(m) and not result['errors'] and os.path.exists(os.path.join(work, 'TNM.u'))
    result['package'] = os.path.join(work, 'TNM.u')

    if result['ok'] and deploy:
        shutil.copy2(result['package'], live)
        bundle_tnm = os.path.join(cfg['bundle_dir'], 'CoopMod', 'System', 'TNM.u')
        os.makedirs(os.path.dirname(bundle_tnm), exist_ok=True)
        if os.path.abspath(bundle_tnm) != os.path.abspath(live):
            shutil.copy2(result['package'], bundle_tnm)
        shutil.rmtree(work, ignore_errors=True)
        result['deployed'] = True
        result['package'] = live
    elif prev_backup and os.path.exists(prev_backup):
        shutil.copy2(prev_backup, live)

    for d in staged_dirs:
        shutil.rmtree(d, ignore_errors=True)
    for p in staged + [os.path.join(game, 'HTK_Build.ini'), os.path.join(game, 'build_tnm.txt')]:
        try:
            os.remove(p)
        except OSError:
            pass
    return result


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--deploy', action='store_true')
    r = build(ap.parse_args().deploy)
    print(r)
    sys.exit(0 if r['ok'] else 1)
