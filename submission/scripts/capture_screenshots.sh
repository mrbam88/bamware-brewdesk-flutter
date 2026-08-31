#!/usr/bin/env bash
# Bamware house rail: marketing screenshots via a scripted adb walk.
# Requires: a booted emulator/device matching screenshots.json's reference
# resolution, and the app installed (debug build is fine for screenshots).
# Usage (repo root):  bash submission/scripts/capture_screenshots.sh <package>
set -euo pipefail

PACKAGE="${1:?usage: capture_screenshots.sh <package> [activity]}"
ACTIVITY="${2:-.MainActivity}"
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
OUT="submission/metadata/android/en-US/images/phoneScreenshots"
WALK="submission/assets-src/screenshots.json"
mkdir -p "$OUT"

adb shell "cmd uimode night no" >/dev/null
adb shell am force-stop "$PACKAGE"
adb shell am start -n "$PACKAGE/$ACTIVITY" >/dev/null
sleep "$(python3 -c "import json;print(json.load(open('$WALK'))['launch_wait_s'])")"

python3 - "$WALK" <<'PYEOF' | while read -r line; do
import json, sys
walk = json.load(open(sys.argv[1]))
for shot in walk["shots"]:
    print(json.dumps(shot))
PYEOF
  name=$(echo "$line" | python3 -c "import json,sys;print(json.load(sys.stdin)['name'])")
  night=$(echo "$line" | python3 -c "import json,sys;print(json.load(sys.stdin).get('night',False))")
  relaunch=$(echo "$line" | python3 -c "import json,sys;print(json.load(sys.stdin).get('relaunch',False))")
  wait_s=$(echo "$line" | python3 -c "import json,sys;print(json.load(sys.stdin)['wait_s'])")
  if [ "$night" = "True" ]; then adb shell "cmd uimode night yes" >/dev/null; fi
  if [ "$relaunch" = "True" ]; then
    adb shell am force-stop "$PACKAGE"; adb shell am start -n "$PACKAGE/$ACTIVITY" >/dev/null
  fi
  echo "$line" | python3 -c "
import json, subprocess, sys, time
for tap in json.load(sys.stdin)['taps']:
    if tap[1] == 'BACK':
        subprocess.run(['adb', 'shell', 'input', 'keyevent', '4'], check=True)
    else:
        subprocess.run(['adb', 'shell', 'input', 'tap', str(tap[0]), str(tap[1])], check=True)
    time.sleep(1.5)
"
  sleep "$wait_s"
  adb exec-out screencap -p > "$OUT/$name.png"
  echo "captured $name"
done
adb shell "cmd uimode night no" >/dev/null
echo "screenshots in $OUT"
