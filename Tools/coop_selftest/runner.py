"""Launch a local co-op session (listen-server host + client), let it run, and report.

usage: python -I runner.py [--map 20_PhasApartment] [--soak 30] [--keep-running]

Uses its own log files (selftest_host.log / selftest_client.log) with
-FORCELOGFLUSH so the player's normal TNM_Host.log / TNM_Client.log are left
alone. Only processes this script started are stopped. Two game windows open
on screen while it runs.

The report covers what can be checked from logs without input: both sides
reach the map, the client joins, script warnings / Accessed None, crashes
(Critical: stacks), and the CoopMod log lines (music sync, UI init).
"""
import argparse
import os
import re
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import config  # noqa: E402

HOST_LOG, CLIENT_LOG = 'selftest_host.log', 'selftest_client.log'
_session = {'host': None, 'client': None}


def _read(path):
    try:
        with open(path, encoding='latin1', errors='replace') as f:
            return f.read()
    except OSError:
        return ''


def _wait_for(path, pattern, timeout, proc=None):
    end = time.time() + timeout
    rx = re.compile(pattern)
    while time.time() < end:
        if rx.search(_read(path)):
            return True
        if proc is not None and proc.poll() is not None:
            return False
        time.sleep(1)
    return False


def _launch(game, url, ini, userini, log):
    try:
        os.remove(os.path.join(game, 'Running.ini'))
    except OSError:
        pass
    try:
        os.remove(os.path.join(game, log))
    except OSError:
        pass
    return subprocess.Popen([os.path.join(game, 'TNM.exe'), url, 'INI=' + ini, 'USERINI=' + userini,
                             'LOG=' + log, '-FORCELOGFLUSH', '-hax0r'], cwd=game)


def summarize_log(text):
    warnings = {}
    for m in re.finditer(r'^ScriptWarning: (.*)$', text, re.M):
        key = re.sub(r'\d+', '#', m.group(1))[:220]
        warnings[key] = warnings.get(key, 0) + 1
    crash = re.findall(r'^Critical: .*$', text, re.M)
    return {
        'reached_map': bool(re.search(r'Bringing Level (?!Entry\.|dx\.)\w+\.MyLevel', text)),
        'script_warnings': sorted(warnings.items(), key=lambda x: -x[1])[:40],
        'script_warning_total': sum(warnings.values()),
        'runaway': re.findall(r'^.*(?:Runaway loop|Infinite script recursion).*$', text, re.M)[:10],
        'crash': crash[:40],
        'coopmod_lines': re.findall(r'^ScriptLog: CoopMod.*$', text, re.M)[-15:],
    }


def stop():
    stopped = []
    for key in ('client', 'host'):
        p = _session.get(key)
        if p is not None and p.poll() is None:
            p.terminate()
            try:
                p.wait(10)
            except subprocess.TimeoutExpired:
                p.kill()
            stopped.append(key)
        _session[key] = None
    return stopped


def run(map_name='20_PhasApartment', soak=30, keep_running=False, join_timeout=120):
    cfg = config.load()
    game = cfg['game_dir']
    stop()
    report = {'map': map_name, 'host_log': os.path.join(game, HOST_LOG), 'client_log': os.path.join(game, CLIENT_LOG)}

    _session['host'] = _launch(game, '%s?Name=Trestkon?Class=TNM.Trestkon?Game=TNM.TNMGameInfo?Listen' % map_name,
                               'TNM_Host.ini', 'TNMUser_Host.ini', HOST_LOG)
    report['host_up'] = _wait_for(report['host_log'], r'CoopMod UI Initialized for (?!Entry|dx\.)', join_timeout, _session['host'])
    # the client's "UI Initialized" line isn't reliable; use the engine's join messages
    if report['host_up']:
        time.sleep(3)
        _session['client'] = _launch(game, '127.0.0.1?Name=Partner?Class=TNM.Trestkon',
                                     'TNM_Client.ini', 'TNMUser_Client.ini', CLIENT_LOG)
        report['client_joined'] = (_wait_for(report['host_log'], r'Join succeeded: Partner', join_timeout, _session['client'])
                                   and _wait_for(report['client_log'], r'Bringing Level %s\.MyLevel' % re.escape(map_name),
                                                 join_timeout, _session['client']))
        if report['client_joined']:
            end = time.time() + soak
            while time.time() < end and all(p.poll() is None for p in _session.values() if p):
                time.sleep(1)
    else:
        report['client_joined'] = False

    report['host_alive'] = _session['host'] is not None and _session['host'].poll() is None
    report['client_alive'] = _session['client'] is not None and _session['client'].poll() is None
    report['host'] = summarize_log(_read(report['host_log']))
    report['client'] = summarize_log(_read(report['client_log']))
    # music reaches the client (TNMOggMusicManager / Trestkon.ClientPlayOgg log these)
    report['client_music_started'] = bool(re.search(r'CoopMod (?:ClientPlayOgg|TNMOggMusicManager\.Tick Client Sync)',
                                                    _read(report['client_log'])))
    report['ok'] = (report['host_up'] and report['client_joined'] and report['host_alive'] and report['client_alive']
                    and not report['host']['crash'] and not report['client']['crash']
                    and not report['host']['runaway'] and not report['client']['runaway'])
    if not keep_running:
        report['stopped'] = stop()
    return report


def tail(which='host', lines=80, grep=None):
    cfg = config.load()
    name = {'host': HOST_LOG, 'client': CLIENT_LOG, 'build': 'htk_build.log',
            'player_host': 'TNM_Host.log', 'player_client': 'TNM_Client.log'}[which]
    text = _read(os.path.join(cfg['game_dir'], name)).splitlines()
    if grep:
        rx = re.compile(grep, re.I)
        text = [l for l in text if rx.search(l)]
    return '\n'.join(text[-lines:])


if __name__ == '__main__':
    import json
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--map', default='20_PhasApartment')
    ap.add_argument('--soak', type=int, default=30, help='seconds to let both sides run after the client joins')
    ap.add_argument('--keep-running', action='store_true')
    a = ap.parse_args()
    r = run(a.map, a.soak, a.keep_running)
    print(json.dumps(r, indent=1))
    sys.exit(0 if r['ok'] else 1)
