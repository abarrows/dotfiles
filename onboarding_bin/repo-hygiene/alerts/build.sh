#!/usr/bin/env bash
# Builds ~/Applications/Repo Hygiene Alerts.app from RepoHygieneAlerts.applescript.
# Re-run after editing the script. Re-signing resets the app's notification permission, so macOS
# asks once more the first time it posts.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
APP="$HOME/Applications/Repo Hygiene Alerts.app"
mkdir -p "$HOME/Applications"
rm -rf "$APP"
osacompile -o "$APP" "$HERE/RepoHygieneAlerts.applescript"
# background app: no Dock icon, no menu bar
/usr/libexec/PlistBuddy -c 'Add :LSUIElement bool true' "$APP/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c 'Set :CFBundleName "Repo Hygiene"' "$APP/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c 'Add :CFBundleIdentifier string com.retailsuccess.repo-hygiene-alerts' "$APP/Contents/Info.plist" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier com.retailsuccess.repo-hygiene-alerts' "$APP/Contents/Info.plist"
codesign --force -s - "$APP" >/dev/null 2>&1
echo "built $APP"
