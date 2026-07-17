#!/usr/bin/env bash
# Fragment for ci_post_xcodebuild.sh — run after xcodebuild so the index store exists.
set -euo pipefail

if ! command -v periphery >/dev/null 2>&1; then brew install peripheryapp/periphery/periphery; fi

cd "$CI_PRIMARY_REPOSITORY_PATH"

INDEX_STORE="$(
  find "$HOME/Library/Developer/Xcode/DerivedData" -type d -path '*/Index.noindex/DataStore' 2>/dev/null \
    | head -n 1 || true
)"

if [[ -z "$INDEX_STORE" ]]; then
  echo "warning: no Index.noindex/DataStore found; running periphery with build" >&2
  ./scripts/deadcode.sh
else
  ./scripts/deadcode.sh --skip-build --index-store-path "$INDEX_STORE"
fi
