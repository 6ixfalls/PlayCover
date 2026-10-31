#!/bin/bash
set -euo pipefail
repo_dir="${SRCROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
expected_revision="$(tr -d '[:space:]' < "$repo_dir/PlayTools.revision")"
stamp="$repo_dir/Carthage/Build/PlayTools.revision"
if [ ! -f "$stamp" ] || [ "$(tr -d '[:space:]' < "$stamp")" != "$expected_revision" ]; then
    echo "error: Build the pinned PlayTools source first: bash scripts/build-local.sh" >&2
    exit 1
fi
