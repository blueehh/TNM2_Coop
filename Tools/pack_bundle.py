"""Pack a clean, self-contained TNM2_Coop_Playtest_Bundle archive (.zip).

Excludes .git, .cache, machine-local selftest_config.json, logs, save slots,
and backup binaries so the resulting archive is ready to share with playtesters.
"""
import os
import sys
import time
import zipfile

SKIP_DIRS = {'.git', '.cache', '__pycache__', 'HTKWork', 'Save', 'Updates'}
SKIP_FILES = {
    'selftest_config.json', 'Running.ini', 'htk_build.log',
    'selftest_host.log', 'selftest_client.log', 'TNM_Host.log', 'TNM_Client.log',
    'TNMCoopSave.ini', 'TNMCoopPrefs.ini',
    'CoopSlot1.ini', 'CoopSlot2.ini', 'CoopSlot3.ini', 'CoopSlot4.ini',
}


def pack(bundle_root, out_zip=None):
    bundle_root = os.path.abspath(bundle_root)
    if out_zip is None:
        stamp = time.strftime('%Y-%m-%d')
        out_zip = os.path.abspath(os.path.join(bundle_root, '..', 'TNM2_Coop_Playtest_Bundle_%s.zip' % stamp))

    cnt = 0
    with zipfile.ZipFile(out_zip, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for dp, dns, fns in os.walk(bundle_root):
            dns[:] = sorted(d for d in dns if d not in SKIP_DIRS)
            for fn in sorted(fns):
                if fn in SKIP_FILES or '.bak_' in fn or fn.endswith('.pyc'):
                    continue
                fp = os.path.join(dp, fn)
                rel = os.path.relpath(fp, bundle_root)
                z.write(fp, os.path.join('TNM2_Coop_Playtest_Bundle', rel))
                cnt += 1

    mb = os.path.getsize(out_zip) / (1024.0 * 1024.0)
    print('Packed %d files -> %s (%.2f MB)' % (cnt, out_zip, mb))
    return out_zip


if __name__ == '__main__':
    root = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
    target = sys.argv[1] if len(sys.argv) > 1 else None
    pack(root, target)
