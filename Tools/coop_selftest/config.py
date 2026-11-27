"""Paths for the co-op self-test and build tools.

Automatically locates the local Steam library containing Deus Ex: Revision / TNM2
(and Steam Workshop 1774011024) across standard Windows drives and Steam's
libraryfolders.vdf, so co-developers can clone the Git repo anywhere and run
builder.py without editing paths manually.

Override any path with environment variables (TNM_GAME_DIR, TNM_WORKSHOP_DIR,
TNM_BUNDLE_DIR) or an optional gitignored selftest_config.json next to this file:

    {"game_dir": "D:/games/steam/steamapps/common/Deus Ex/Revision/TNM2"}
"""
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
BUNDLE_ROOT = os.path.normpath(os.path.join(HERE, '..', '..'))
_ENV = {'game_dir': 'TNM_GAME_DIR', 'workshop_dir': 'TNM_WORKSHOP_DIR', 'bundle_dir': 'TNM_BUNDLE_DIR'}


def _candidate_steamapps():
    seen = []

    def add(p):
        if p:
            np = os.path.normpath(p)
            if np not in seen and os.path.isdir(np):
                seen.append(np)

    # 1. If bundle_dir itself is inside ...\steamapps\common\Deus Ex\Revision\TNM2
    add(os.path.join(BUNDLE_ROOT, '..', '..', '..', '..'))

    # 2. Windows Registry SteamPath
    try:
        import winreg
        for root_key, sub in (
            (winreg.HKEY_CURRENT_USER, r'Software\Valve\Steam'),
            (winreg.HKEY_LOCAL_MACHINE, r'SOFTWARE\WOW6432Node\Valve\Steam'),
        ):
            try:
                with winreg.OpenKey(root_key, sub) as k:
                    sp, _ = winreg.QueryValueEx(k, 'SteamPath')
                    steam_root = os.path.normpath(sp)
                    add(os.path.join(steam_root, 'steamapps'))
                    vdf = os.path.join(steam_root, 'steamapps', 'libraryfolders.vdf')
                    if os.path.isfile(vdf):
                        with open(vdf, encoding='utf-8', errors='replace') as vf:
                            for m in re.finditer(r'"path"\s+"([^"]+)"', vf.read()):
                                lib = m.group(1).replace('\\\\', '\\')
                                add(os.path.join(lib, 'steamapps'))
            except OSError:
                pass
    except ImportError:
        pass

    # 3. Common Steam library locations across drives
    for drv in ('C', 'D', 'E', 'F', 'G'):
        for rel in (r'Program Files (x86)\Steam\steamapps', r'Steam\steamapps',
                    r'SteamLibrary\steamapps', r'games\steam\steamapps', r'Games\Steam\steamapps'):
            add('%s:\\%s' % (drv, rel))

    return seen


def _autodetect_defaults():
    game_dir = r'C:\Program Files (x86)\Steam\steamapps\common\Deus Ex\Revision\TNM2'
    workshop_dir = r'C:\Program Files (x86)\Steam\steamapps\workshop\content\397550\1774011024'

    steamapps_list = _candidate_steamapps()
    for sa in steamapps_list:
        cand_game = os.path.join(sa, 'common', 'Deus Ex', 'Revision', 'TNM2')
        if os.path.isfile(os.path.join(cand_game, 'TNM.exe')) or os.path.isdir(cand_game):
            game_dir = cand_game
            break

    for sa in steamapps_list:
        cand_ws = os.path.join(sa, 'workshop', 'content', '397550', '1774011024')
        if os.path.isdir(cand_ws):
            workshop_dir = cand_ws
            break

    return {
        'game_dir': game_dir,
        'workshop_dir': workshop_dir,
        'bundle_dir': BUNDLE_ROOT,
        'cache_dir': os.path.join(HERE, '.cache'),
    }


def load():
    cfg = _autodetect_defaults()
    path = os.path.join(HERE, 'selftest_config.json')
    if os.path.exists(path):
        with open(path, encoding='utf-8') as f:
            cfg.update(json.load(f))
    for key, env in _ENV.items():
        if os.environ.get(env):
            cfg[key] = os.environ[env]
    cfg['source_dir'] = os.path.join(cfg['bundle_dir'], 'Source', 'Classes')
    cfg['installed_tnm'] = os.path.join(cfg['game_dir'], 'CoopMod', 'System', 'TNM.u')
    return cfg
