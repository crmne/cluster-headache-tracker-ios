#!/bin/bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: DEMO_PASSWORD=... Scripts/store-screenshots.sh BASE_URL SIMULATOR_UDID...

Takes the App Store screenshots on each simulator (an iPhone 6.9" and an iPad
13" cover every size App Store Connect requires) from a local server holding the
synthetic `screenshots` account, never real data. In the Rails app:

  DEMO_USERNAME=screenshots DEMO_ONGOING_ATTACK=1 DEMO_TIME_ZONE=Europe/Berlin \
    DEMO_PASSWORD=... bin/rails demo:reset
  bin/rails server -p 3078

Images land in fastlane/screenshots/en-US, named after the device.
EOF
}

if [[ $# -lt 2 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 1
fi

base_url="$1"
shift
: "${DEMO_PASSWORD:?Set DEMO_PASSWORD to the screenshots account password}"

root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/fastlane/screenshots/en-US"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$out"

for udid in "$@"; do
  name="$(xcrun simctl list devices -j | python3 -c "import json,sys; print(next(d['name'] for r in json.load(sys.stdin)['devices'].values() for d in r if d['udid'] == sys.argv[1]))" "$udid")"
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b >/dev/null
  # Reduce Motion stills the attack timer's rolling digits, which a screenshot
  # would otherwise catch halfway.
  xcrun simctl spawn "$udid" defaults write com.apple.Accessibility ReduceMotionEnabled -bool true
  xcrun simctl status_bar "$udid" override --batteryState charged --batteryLevel 100 \
    --wifiBars 3 --cellularMode notSupported --dataNetwork wifi

  for appearance in light dark; do
    xcrun simctl boot "$udid" 2>/dev/null || true
    xcrun simctl bootstatus "$udid" -b >/dev/null
    xcrun simctl ui "$udid" appearance "$appearance"
    test_name=$([[ "$appearance" == light ]] && echo testStoreScreenshots || echo testDarkModeScreenshot)
    bundle="$work/$udid-$appearance.xcresult"

    TEST_RUNNER_CHT_PREVIEW_URL="$base_url" \
    TEST_RUNNER_CHT_DEMO_USERNAME="${DEMO_USERNAME:-screenshots}" \
    TEST_RUNNER_CHT_DEMO_PASSWORD="$DEMO_PASSWORD" \
      xcodebuild test -project "$root/Cluster Headache Tracker.xcodeproj" -scheme "Cluster Headache Tracker" \
        -destination "platform=iOS Simulator,id=$udid" \
        -only-testing:"Cluster Headache TrackerUITests/StoreScreenshotsUITests/$test_name" \
        -parallel-testing-enabled NO -resultBundlePath "$bundle" -quiet

    xcrun xcresulttool export attachments --path "$bundle" --output-path "$work/$udid-$appearance" >/dev/null
    python3 - "$work/$udid-$appearance" "$out" "$name" <<'PY'
import json, os, shutil, sys
source, out, device = sys.argv[1:]
for test in json.load(open(os.path.join(source, "manifest.json"))):
    for attachment in test["attachments"]:
        label = attachment["suggestedHumanReadableName"].split("_0_")[0]
        target = os.path.join(out, f"{device} - {label}.png")
        shutil.copy(os.path.join(source, attachment["exportedFileName"]), target)
        print(target)
PY
  done

  xcrun simctl ui "$udid" appearance light
  xcrun simctl status_bar "$udid" clear
  xcrun simctl spawn "$udid" defaults write com.apple.Accessibility ReduceMotionEnabled -bool false
done
