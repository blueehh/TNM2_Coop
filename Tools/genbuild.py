"""Write the HTK exec script that rebuilds TNM.u from <src dir>.

usage: python -I genbuild.py <src dir relative to game dir> <out exec file> <out package path>

Every .uc in <src dir> is CLASS LOADed. Files must be OBJ EXPORTs (they carry
defaultproperties); stored ScriptText does not, see AGENTS.md section 2.
"""
import os
import sys

src, out, pkg = sys.argv[1], sys.argv[2], sys.argv[3]
classes = sorted(f[:-3] for f in os.listdir(src) if f.lower().endswith('.uc'))
lines = []
if os.path.exists(r'Source\CoopPingSound.wav'):
    lines.append(r'AUDIO IMPORT FILE=Source\CoopPingSound.wav NAME=CoopPingSound PACKAGE=TNM')
if os.path.exists(r'Source\CoopChatSound.wav'):
    lines.append(r'AUDIO IMPORT FILE=Source\CoopChatSound.wav NAME=CoopChatSound PACKAGE=TNM')
lines += [r'CLASS LOAD FILE=%s\%s.uc PACKAGE=TNM NAME=%s' % (src, c, c) for c in classes]
lines += ['SCRIPT MAKE', 'OBJ SAVEPACKAGE PACKAGE=TNM FILE=%s' % pkg, 'EXIT']
with open(out, 'w') as f:
    f.write('\n'.join(lines) + '\n')
print('%d classes' % len(classes))
