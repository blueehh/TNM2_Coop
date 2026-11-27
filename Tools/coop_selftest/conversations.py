"""List Conversation objects (owner, invoke methods, radius, flags) from TNM/DX conversation packages.

Conversations are serialized as tagged properties, so this reads them straight
from the .u file. Used to find which conversations start by proximity
(bInvokeRadius), which stock ScriptedPawn/DeusExDecoration code only checks
against the host.

usage: python -I conversations.py [--owner regex] [--radius-only]
"""
import argparse
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import config  # noqa: E402

PACKAGES = ('TNMConvos1Text', 'TNMConvos2Text')
_SIZES = {0: 1, 1: 2, 2: 4, 3: 12, 4: 16}


def _ci(b, p):
    v = b[p]
    p += 1
    neg, r = v & 0x80, v & 0x3f
    if v & 0x40:
        sh = 6
        while True:
            x = b[p]
            p += 1
            r |= (x & 0x7f) << sh
            sh += 7
            if not x & 0x80:
                break
    return (-r if neg else r), p


def _load(path):
    b = open(path, 'rb').read()
    _, ver, _, _, nc, no, ec, eo, ic, io = struct.unpack_from('<IHHIIIIIII', b, 0)
    names, p = [], no
    for _ in range(nc):
        n, p = _ci(b, p)
        names.append(b[p:p + n - 1].decode('latin1'))
        p += n + 4
    imports, p = [], io
    for _ in range(ic):
        _, p = _ci(b, p)
        _, p = _ci(b, p)
        p += 4
        on, p = _ci(b, p)
        imports.append(names[on])
    exports, p = [], eo
    for _ in range(ec):
        cl, p = _ci(b, p)
        _, p = _ci(b, p)
        p += 4
        on, p = _ci(b, p)
        p += 4
        sz, p = _ci(b, p)
        off = 0
        if sz > 0:
            off, p = _ci(b, p)
        exports.append((cl, names[on], sz, off))
    return b, names, imports, exports


def _props(b, p, end, names):
    out = {}
    while p < end:
        n, p = _ci(b, p)
        if names[n] == 'None':
            break
        info = b[p]
        p += 1
        t, sc = info & 15, (info >> 4) & 7
        if t == 10:
            _, p = _ci(b, p)
        size = _SIZES.get(sc)
        if size is None:
            if sc == 5:
                size = b[p]
                p += 1
            elif sc == 6:
                size = struct.unpack_from('<H', b, p)[0]
                p += 2
            else:
                size = struct.unpack_from('<I', b, p)[0]
                p += 4
        if (info & 0x80) and t != 3:
            p += 1
        val = b[p:p + size]
        p += size
        key = names[n]
        if t == 3:
            out[key] = bool(info & 0x80)
        elif t == 2:
            out[key] = struct.unpack('<i', val)[0]
        elif t == 6:
            out[key] = names[_ci(val, 0)[0]]
        elif t == 13:
            ln, q = _ci(val, 0)
            out[key] = val[q:q + abs(ln) - 1].decode('latin1') if ln else ''
    return out


def list_conversations():
    cfg = config.load()
    convs = []
    for pkg in PACKAGES:
        path = os.path.join(cfg['workshop_dir'], 'System', pkg + '.u')
        if not os.path.exists(path):
            path = os.path.join(cfg['workshop_dir'], 'TNM2', 'System', pkg + '.u')
        if not os.path.exists(path):
            continue
        b, names, imports, exports = _load(path)
        for cl, name, sz, off in exports:
            if cl < 0 and imports[-cl - 1] == 'Conversation' and sz > 0:
                try:
                    pr = _props(b, off, off + sz, names)
                except (IndexError, struct.error):
                    continue
                pr['_object'] = name
                pr['_package'] = pkg
                convs.append(pr)
    return convs


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--owner', help='regex on conOwnerName')
    ap.add_argument('--radius-only', action='store_true')
    a = ap.parse_args()
    rx = re.compile(a.owner, re.I) if a.owner else None
    for c in list_conversations():
        if a.radius_only and not c.get('bInvokeRadius'):
            continue
        if rx and not rx.search(c.get('conOwnerName', '')):
            continue
        print('%-32s owner=%-22s radius=%s(%s) frob=%s bump=%s sight=%s 1st=%s once=%s' % (
            c.get('conName', c['_object']), c.get('conOwnerName', ''), c.get('bInvokeRadius', False), c.get('radiusDistance', ''),
            c.get('bInvokeFrob', False), c.get('bInvokeBump', False), c.get('bInvokeSight', False),
            c.get('bFirstPerson', False), c.get('bDisplayOnce', False)))
