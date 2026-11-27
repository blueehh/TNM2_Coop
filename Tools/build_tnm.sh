#!/bin/sh
# Rebuild CoopMod/System/TNM.u from Source/Classes with HTK (see AGENTS.md section 2).
# Run from Git Bash:  sh Tools/build_tnm.sh            (build + deploy)
#                     sh Tools/build_tnm.sh --no-deploy (build only, leaves <game>/HTKWork/TNM.u)
#
# The work is done by Tools/coop_selftest/builder.py. Game/Workshop paths come
# from Tools/coop_selftest/selftest_config.json or TNM_GAME_DIR / TNM_WORKSHOP_DIR
# (defaults: C:\Program Files (x86)\Steam\...).
BUNDLE="$(cd "$(dirname "$0")/.." && pwd)"
if [ "$1" = "--no-deploy" ]; then
	python -I "$BUNDLE/Tools/coop_selftest/builder.py"
else
	python -I "$BUNDLE/Tools/coop_selftest/builder.py" --deploy
fi
