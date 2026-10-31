#!/bin/bash
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
app="$repo_dir/.build/DerivedData/Build/Products/Nightly/PlayCover.app"
output="$repo_dir/output"
codesign --verify --deep --strict "$app"
mkdir -p "$output"
stage="$(mktemp -d "${TMPDIR:-/tmp}/playcover-dmg.XXXXXX")"
trap 'rm -rf "$stage"' EXIT
ditto "$app" "$stage/PlayCover.app"
ln -s /Applications "$stage/Applications"
ditto -c -k --sequesterRsrc --keepParent "$app" "$output/PlayCover-NIKKE.zip"
hdiutil create -ov -fs HFS+ -volname "PlayCover NIKKE" -srcfolder "$stage" \
    -format UDZO "$output/PlayCover-NIKKE.dmg"
export PLAYCOVER_REVISION="$(git -C "$repo_dir" rev-parse HEAD)"
export PLAYTOOLS_REVISION="${PLAYTOOLS_REVISION:-$(tr -d '[:space:]' < "$repo_dir/PlayTools.revision")}"
python3 - "$output/build-info.json" <<'PY'
import datetime, json, os, sys
data = {
    "playcover": os.environ["PLAYCOVER_REVISION"],
    "playtools": os.environ["PLAYTOOLS_REVISION"],
    "built_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "signing": "ad-hoc; not notarized",
}
if os.environ.get("GITHUB_RUN_ID"):
    data["run_url"] = "https://github.com/{}/actions/runs/{}".format(
        os.environ["GITHUB_REPOSITORY"], os.environ["GITHUB_RUN_ID"])
with open(sys.argv[1], "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY
cd "$output"
shasum -a 256 PlayCover-NIKKE.zip PlayCover-NIKKE.dmg build-info.json > SHA256SUMS
