#!/bin/bash
# Build the pinned sibling PlayTools source and an ad-hoc signed PlayCover app.
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
tools_dir="${PLAYTOOLS_SOURCE:-$repo_dir/../PlayTools}"
expected_revision="$(tr -d '[:space:]' < "$repo_dir/PlayTools.revision")"
if [ ! -d "$tools_dir/.git" ]; then
    echo "Clone https://github.com/6ixfalls/PlayTools beside PlayCover and check out $expected_revision." >&2
    exit 1
fi
if [ "$(git -C "$tools_dir" rev-parse HEAD)" != "$expected_revision" ]; then
    echo "PlayTools must be at the revision in PlayTools.revision: $expected_revision" >&2
    exit 1
fi
if ! git -C "$tools_dir" diff --quiet HEAD --; then
    echo "Commit or discard tracked PlayTools changes before building the pinned source." >&2
    exit 1
fi
mkdir -p "$repo_dir/.build" "$repo_dir/Carthage/Build"
export FASTLANE=1 # Dependencies are prepared here; do not run the upstream update phase.
xcodebuild -project "$tools_dir/PlayTools.xcodeproj" -scheme PlayTools -configuration Release \
    -derivedDataPath "$tools_dir/.build/DerivedData" \
    -clonedSourcePackagesDirPath "$tools_dir/.build/SourcePackages" \
    -onlyUsePackageVersionsFromResolvedFile \
    CODE_SIGNING_ALLOWED=NO ARCHS=arm64 build

framework="$tools_dir/.build/DerivedData/Build/Products/Release-iphoneos/PlayTools.framework"
plugin="$tools_dir/.build/DerivedData/Build/Products/Release/AKInterface.bundle"
if [ ! -f "$framework/PlayTools" ] || [ ! -f "$plugin/Contents/MacOS/AKInterface" ]; then
    echo "PlayTools or its native macOS input bundle did not build." >&2
    exit 1
fi
mkdir -p "$framework/PlugIns"
ditto "$plugin" "$framework/PlugIns/AKInterface.bundle"
# This directory layout is the existing Xcode copy phase's input. No Carthage
# download or prebuilt PlayTools release is used.
destination="$repo_dir/Carthage/Build/PlayTools.xcframework/ios-arm64/PlayTools.framework"
mkdir -p "$(dirname "$destination")"
ditto "$framework" "$destination"
printf '%s\n' "$expected_revision" > "$repo_dir/Carthage/Build/PlayTools.revision"

xcodebuild -project "$repo_dir/PlayCover.xcodeproj" -scheme PlayCover -configuration Nightly \
    -derivedDataPath "$repo_dir/.build/DerivedData" \
    -clonedSourcePackagesDirPath "$repo_dir/.build/SourcePackages" \
    -onlyUsePackageVersionsFromResolvedFile \
    CODE_SIGNING_ALLOWED=NO ARCHS=arm64 build

app="$repo_dir/.build/DerivedData/Build/Products/Nightly/PlayCover.app"
codesign --force --deep --sign - "$app"
codesign --verify --deep --strict "$app"
echo "Built $app"
