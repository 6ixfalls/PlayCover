#!/bin/bash
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/nikke-tests.XXXXXX")"
trap 'rm -rf "$test_dir"' EXIT
swiftc -module-cache-path "$repo_dir/.build/SwiftModuleCache" \
    "$repo_dir/PlayCover/Model/NikkeMiniGamePatch.swift" "$repo_dir/Tests/NikkeMiniGamePatchTests.swift" \
    -o "$test_dir/patch-tests"
"$test_dir/patch-tests" "$@"
app="$test_dir/SettingsTests.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources/AppSettingsOverrides"
cp "$repo_dir/PlayCover/AppSettingsOverrides/com.proximabeta.nikke.json" \
    "$app/Contents/Resources/AppSettingsOverrides/"
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0"><dict><key>CFBundleExecutable</key><string>Tests</string>
<key>CFBundleIdentifier</key><string>dev.6ixfalls.NikkeSettingsTests</string></dict></plist>
PLIST
swiftc -module-cache-path "$repo_dir/.build/SwiftModuleCache" \
    -import-objc-header "$repo_dir/Tests/SettingsTestSupport.h" \
    "$repo_dir/PlayCover/Model/AppSettings.swift" "$repo_dir/Tests/AppSettingsTests.swift" \
    -o "$app/Contents/MacOS/Tests"
"$app/Contents/MacOS/Tests"
