"""Dump ScriptText (TextBuffer) of every class in a UE1 package to <out>/<Class>.uc

usage: python -I uexport.py <package.u> <out dir>
ScriptText has no defaultproperties; use HTK OBJ EXPORT when you need those.
"""
import struct, sys, os

def rd_ci(b, p):
    v = b[p]; p += 1
    neg = v & 0x80; r = v & 0x3f
    if v & 0x40:
        sh = 6
        while True:
            x = b[p]; p += 1
            r |= (x & 0x7f) << sh; sh += 7
            if not (x & 0x80): break
    return (-r if neg else r), p

def export_scripts(path, out):
    """Write every class's ScriptText to out; returns the number of classes."""
    b = open(path, 'rb').read()
    tag, ver, lic, flags, nc, no, ec, eo, ic, io = struct.unpack_from('<IHHIIIIIII', b, 0)
    names = []; p = no
    for _ in range(nc):
        if ver >= 64:
            l, p = rd_ci(b, p); s = b[p:p+l-1].decode('latin1'); p += l
        else:
            e = b.index(0, p); s = b[p:e].decode('latin1'); p = e + 1
        p += 4; names.append(s)
    imports = []; p = io
    for _ in range(ic):
        cp, p = rd_ci(b, p); cn, p = rd_ci(b, p); pk = struct.unpack_from('<i', b, p)[0]; p += 4
        on, p = rd_ci(b, p); imports.append((names[cn], names[on]))
    exports = []; p = eo
    for _ in range(ec):
        cl, p = rd_ci(b, p); su, p = rd_ci(b, p); pk = struct.unpack_from('<i', b, p)[0]; p += 4
        on, p = rd_ci(b, p); fl = struct.unpack_from('<I', b, p)[0]; p += 4
        sz, p = rd_ci(b, p); off = 0
        if sz > 0: off, p = rd_ci(b, p)
        exports.append((cl, pk, names[on], sz, off))
    def clsname(ref):
        if ref < 0: return imports[-ref-1][1]
        if ref > 0: return exports[ref-1][2]
        return 'Class'
    os.makedirs(out, exist_ok=True); n = 0
    for cl, pk, name, sz, off in exports:
        if clsname(cl) != 'TextBuffer' or name != 'ScriptText' or pk <= 0: continue
        owner = exports[pk-1]
        if clsname(owner[0]) != 'Class': continue
        q = off
        _, q = rd_ci(b, q)  # 'None' property terminator
        q += 8              # Pos, Top
        l, q = rd_ci(b, q)
        txt = b[q:q+abs(l)-1].decode('latin1') if l else ''
        open(os.path.join(out, owner[2] + '.uc'), 'w', encoding='latin1', newline='').write(txt); n += 1
    return n


if __name__ == '__main__':
    print(sys.argv[1], 'classes', export_scripts(sys.argv[1], sys.argv[2]))
