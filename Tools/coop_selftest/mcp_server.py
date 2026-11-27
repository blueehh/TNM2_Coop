"""TNM 2.0 co-op self-test MCP server (stdio, no dependencies).

Gives an agent tools to walk the UnrealScript, flag co-op hazards (especially
code that only looks at the host), rebuild TNM.u, and run a local host+client
session and read the results.

Register it with an MCP client, e.g. Antigravity's mcp_config.json:

    {"mcpServers": {"tnm-coop-selftest": {
        "command": "python",
        "args": ["-I", "<bundle>/Tools/coop_selftest/mcp_server.py"]}}}
"""
import json
import os
import re
import sys
import traceback

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))

import builder  # noqa: E402
import conversations  # noqa: E402
import map_analysis  # noqa: E402
import config  # noqa: E402
import runner  # noqa: E402
import scanner  # noqa: E402

PROTOCOL_VERSION = '2024-11-05'
MAX_TEXT = 60000
_scan_dir = {}


def _sources(source):
    if source not in _scan_dir or not os.path.isdir(_scan_dir[source]):
        _scan_dir[source] = scanner.resolve_sources(source)
    return _scan_dir[source]


def _clip(text):
    if len(text) <= MAX_TEXT:
        return text
    return text[:MAX_TEXT] + '\n\n[truncated: %d more characters; narrow with class_filter/rules/min_severity]' % (len(text) - MAX_TEXT)


# ---------------------------------------------------------------------------
# tools

def t_scan_scripts(a):
    d = _sources(a.get('source', 'installed'))
    f = scanner.scan(d, a.get('min_severity', 'warning'), a.get('class_filter'), a.get('rules'))
    if a.get('format') == 'json':
        return json.dumps(f, indent=1)
    return scanner.to_markdown(f)


def t_list_host_only_sites(a):
    d = _sources(a.get('source', 'installed'))
    rules = ['HOST_ONLY', 'HOST_ONLY_FLAGS', 'FIRST_PLAYER_ONLY', 'MISSION_HOST_PLAYER']
    f = scanner.scan(d, a.get('min_severity', 'warning'), a.get('class_filter'), rules)
    return scanner.to_markdown(f, 'Scripts that rely on the host instead of any player')


def t_list_classes(a):
    d = _sources(a.get('source', 'installed'))
    srcs = scanner.load_sources(d)
    parent = scanner.class_graph(srcs)
    rx = re.compile(a['filter'], re.I) if a.get('filter') else None
    rows = []
    for name in sorted(srcs, key=str.lower):
        if rx and not rx.search(name):
            continue
        rows.append('%s extends %s (%d lines)' % (name, parent.get(name.lower(), '?'), srcs[name].count('\n') + 1))
    return '\n'.join(rows)


def t_get_class_source(a):
    d = _sources(a.get('source', 'installed'))
    name = a['class_name']
    match = [f for f in os.listdir(d) if f.lower() == name.lower() + '.uc']
    if not match:
        return 'No class %s in %s' % (name, d)
    with open(os.path.join(d, match[0]), encoding='latin1') as f:
        lines = f.read().replace('\r\n', '\n').split('\n')
    start = max(1, int(a.get('start_line', 1)))
    end = min(len(lines), int(a.get('end_line', start + 399)))
    return '\n'.join('%6d  %s' % (i, lines[i - 1]) for i in range(start, end + 1)) + \
        '\n[%s: lines %d-%d of %d]' % (match[0], start, end, len(lines))


def t_find_references(a):
    d = _sources(a.get('source', 'installed'))
    rx = re.compile(a['pattern'], re.I)
    out, limit = [], int(a.get('max_results', 200))
    for f in sorted(os.listdir(d), key=str.lower):
        if not f.lower().endswith('.uc'):
            continue
        with open(os.path.join(d, f), encoding='latin1') as fh:
            for i, line in enumerate(fh, 1):
                if rx.search(line):
                    out.append('%s:%d: %s' % (f[:-3], i, line.strip()[:200]))
                    if len(out) >= limit:
                        return '\n'.join(out) + '\n[limit reached]'
    return '\n'.join(out) or 'no matches'


def t_export_package(a):
    import uexport
    cfg = config.load()
    path = a['package_path']
    out = os.path.join(cfg['cache_dir'], os.path.splitext(os.path.basename(path))[0] + '_' + str(abs(hash(path)) % 10000))
    n = uexport.export_scripts(path, out)
    _scan_dir['custom:' + path] = out
    return 'Exported %d classes (ScriptText, no defaultproperties) to %s. Pass source="%s" to other tools.' % (n, out, out)


def t_build_tnm(a):
    return json.dumps(builder.build(bool(a.get('deploy', False))), indent=1)


def t_run_coop_session(a):
    r = runner.run(a.get('map', '20_PhasApartment'), int(a.get('soak_seconds', 30)), bool(a.get('keep_running', False)))
    return json.dumps(r, indent=1)


def t_stop_coop_session(a):
    return 'stopped: %s' % (runner.stop() or 'nothing running')


def t_read_log(a):
    return runner.tail(a.get('which', 'host'), int(a.get('lines', 80)), a.get('grep'))


def t_analyze_map(a):
    res = map_analysis.analyze(a['map'])
    return map_analysis.to_markdown(res, int(a.get('max_instances', 8)))


def t_list_conversations(a):
    rx = re.compile(a['owner'], re.I) if a.get('owner') else None
    rows = []
    for c in conversations.list_conversations():
        if a.get('radius_only') and not c.get('bInvokeRadius'):
            continue
        if rx and not rx.search(c.get('conOwnerName', '')):
            continue
        rows.append('%s owner=%s radius=%s(%s) firstperson=%s once=%s' % (
            c.get('conName', c['_object']), c.get('conOwnerName', ''), c.get('bInvokeRadius', False),
            c.get('radiusDistance', ''), c.get('bFirstPerson', False), c.get('bDisplayOnce', False)))
    return '\n'.join(rows[:int(a.get('max_results', 300))]) or 'no matches'


def _src_prop():
    return {'type': 'string', 'description': 'installed (default: installed CoopMod TNM.u with bundle Source/Classes on top), '
                                              'bundle (only Source/Classes), or a folder path from export_package'}


TOOLS = [
    ('scan_scripts', t_scan_scripts,
     'Static scan for co-op hazards: host-only logic (GetPlayerPawn, first-player loops, MissionScript.Player), '
     'deathmatch NetMode branches, replicated functions gated on bNetOwner, client->server variables, DXOgg natives '
     'called on clients, dangling inventory ammo buttons. Returns markdown grouped by class.',
     {'source': _src_prop(),
      'min_severity': {'type': 'string', 'enum': ['info', 'warning', 'error'], 'description': 'default warning'},
      'class_filter': {'type': 'string', 'description': 'regex on class name'},
      'rules': {'type': 'array', 'items': {'type': 'string'}, 'description': 'limit to these rule ids'},
      'format': {'type': 'string', 'enum': ['markdown', 'json']}}),
    ('list_host_only_sites', t_list_host_only_sites,
     'Only the findings where scripts rely on the host instead of any player.',
     {'source': _src_prop(), 'class_filter': {'type': 'string'},
      'min_severity': {'type': 'string', 'enum': ['info', 'warning', 'error'], 'description': 'default warning; info also lists achievements/autosave/flags'}}),
    ('list_classes', t_list_classes, 'List classes with their parent and size.',
     {'source': _src_prop(), 'filter': {'type': 'string', 'description': 'regex on class name'}}),
    ('get_class_source', t_get_class_source, 'Read a class source with line numbers (400 lines per call).',
     {'class_name': {'type': 'string'}, 'start_line': {'type': 'integer'}, 'end_line': {'type': 'integer'}, 'source': _src_prop()}),
    ('find_references', t_find_references, 'Regex search across all classes (file:line: text).',
     {'pattern': {'type': 'string'}, 'max_results': {'type': 'integer'}, 'source': _src_prop()}),
    ('export_package', t_export_package,
     'Extract ScriptText from any UE1 package (e.g. the Workshop TNM.u, TNMItems.u, stock DeusEx.u) for reading/scanning.',
     {'package_path': {'type': 'string'}}),
    ('build_tnm', t_build_tnm,
     'Compile Source/Classes into TNM.u with HTK. deploy=true installs it (backs up the old one). Fails on any compile error.',
     {'deploy': {'type': 'boolean'}}),
    ('run_coop_session', t_run_coop_session,
     'Launch a local listen-server host and a client on 127.0.0.1, wait for the join, let it run soak_seconds, and '
     'report crashes, script warnings, runaway loops and CoopMod log lines. Opens two game windows.',
     {'map': {'type': 'string'}, 'soak_seconds': {'type': 'integer'}, 'keep_running': {'type': 'boolean'}}),
    ('analyze_map', t_analyze_map,
     'Export a map (e.g. 20_FCDowntown) to T3D with HTK and report co-op risks for what is actually placed: '
     'radius conversations that only start for the host, skill awards only the toucher gets, triggers wired to '
     'toggle/control movers, and inherited host-only code per placed class. First run per map takes ~30s.',
     {'map': {'type': 'string'}, 'max_instances': {'type': 'integer'}}),
    ('list_conversations', t_list_conversations,
     'List TNM conversations (owner BindName, radius/frob invocation, first-person, once).',
     {'owner': {'type': 'string', 'description': 'regex on conOwnerName (BindName)'},
      'radius_only': {'type': 'boolean'}, 'max_results': {'type': 'integer'}}),
    ('stop_coop_session', t_stop_coop_session, 'Stop game instances started by run_coop_session.', {}),
    ('read_log', t_read_log, 'Tail a log, optionally filtered by regex.',
     {'which': {'type': 'string', 'enum': ['host', 'client', 'build', 'player_host', 'player_client']},
      'lines': {'type': 'integer'}, 'grep': {'type': 'string'}}),
]
REQUIRED = {'analyze_map': ['map'], 'get_class_source': ['class_name'], 'find_references': ['pattern'], 'export_package': ['package_path']}


# ---------------------------------------------------------------------------
# JSON-RPC over stdio

def _send(msg):
    sys.stdout.write(json.dumps(msg) + '\n')
    sys.stdout.flush()


def handle(req):
    method, rid = req.get('method'), req.get('id')
    if method == 'initialize':
        return {'protocolVersion': PROTOCOL_VERSION, 'capabilities': {'tools': {}},
                'serverInfo': {'name': 'tnm-coop-selftest', 'version': '0.1.0'}}
    if method == 'tools/list':
        return {'tools': [{'name': n, 'description': d,
                           'inputSchema': {'type': 'object', 'properties': p, 'required': REQUIRED.get(n, [])}}
                          for n, _, d, p in TOOLS]}
    if method == 'tools/call':
        name = req['params']['name']
        args = req['params'].get('arguments') or {}
        fn = next((f for n, f, _, _ in TOOLS if n == name), None)
        if fn is None:
            raise ValueError('unknown tool ' + name)
        try:
            text, err = fn(args), False
        except Exception:
            text, err = traceback.format_exc(), True
        return {'content': [{'type': 'text', 'text': _clip(text)}], 'isError': err}
    if method == 'ping':
        return {}
    if rid is None:
        return None  # notification
    raise LookupError(method)


def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            req = json.loads(line)
        except ValueError:
            continue
        try:
            res = handle(req)
            if req.get('id') is not None:
                _send({'jsonrpc': '2.0', 'id': req['id'], 'result': res})
        except LookupError as e:
            _send({'jsonrpc': '2.0', 'id': req.get('id'), 'error': {'code': -32601, 'message': 'method not found: %s' % e}})
        except Exception as e:
            _send({'jsonrpc': '2.0', 'id': req.get('id'), 'error': {'code': -32603, 'message': str(e)}})
    runner.stop()


if __name__ == '__main__':
    main()
