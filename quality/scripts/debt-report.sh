#!/usr/bin/env bash
# Print SwiftLint + Periphery debt counts for the current app repo.
# Used by quality ratchet agents to pick the next chip-away item.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/_lib.sh"

PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(repo_root_from_cwd)"
require_quality_installed "$ROOT"
require_tool swiftlint swiftlint

cd "$ROOT"

LINT_CONFIG="$ROOT/.swiftlint.yml"
if [[ ! -f "$LINT_CONFIG" ]]; then
  LINT_CONFIG="$PLUGIN_ROOT/.swiftlint.yml"
fi

echo "==> SwiftLint debt ($ROOT)"
lint_out="$(swiftlint lint --config "$LINT_CONFIG" --quiet 2>&1 || true)"
if [[ -z "$lint_out" ]]; then
  echo "SwiftLint: 0 violations"
else
  echo "$lint_out" | sed -n 's/.*warning: //p; s/.*error: //p' \
    | sed 's/ Violation:.*//' \
    | sort | uniq -c | sort -rn
  echo "SwiftLint total: $(echo "$lint_out" | grep -cE 'warning:|error:' || true)"
fi

if ! command -v periphery >/dev/null 2>&1; then
  echo "Periphery: not installed (skip)"
  exit 0
fi

if [[ ! -f "$ROOT/.periphery.yml" ]]; then
  echo "Periphery: no .periphery.yml (skip)"
  exit 0
fi

EMPTY_BASE="$(mktemp)"
python3 -c 'import json,sys; json.dump({"v1":{"usrs":[]}}, open(sys.argv[1],"w"))' "$EMPTY_BASE"

PERI_ARGS=(scan --baseline "$EMPTY_BASE" --disable-update-check --strict)
INDEX_STORE="$(
  find "$HOME/Library/Developer/Xcode/DerivedData" /tmp -type d \( -path '*/Index.noindex/DataStore' -o -path '*/Index/DataStore' \) 2>/dev/null \
    | head -n 1 || true
)"
if [[ -n "$INDEX_STORE" ]]; then
  PERI_ARGS+=(--skip-build --index-store-path "$INDEX_STORE")
  echo "Using index store: $INDEX_STORE"
fi

echo "==> Periphery debt (empty baseline override)"
set +e
peri_out="$(periphery "${PERI_ARGS[@]}" 2>&1)"
peri_status=$?
set -e
rm -f "$EMPTY_BASE"

if [[ "$peri_out" == *"BUILD FAILED"* ]]; then
  echo "Periphery: build failed — try after an app build, or pass index via deadcode.sh --skip-build"
  echo "(raw exit $peri_status)"
  exit 0
fi

if echo "$peri_out" | grep -q "No unused code detected"; then
  echo "Periphery: 0 findings"
else
  echo "$peri_out" | grep 'warning:' | sed 's/.*warning: //' | sed 's/ for .*//' | sed "s/ '.*'//" \
    | sort | uniq -c | sort -rn || true
  echo "Periphery total: $(echo "$peri_out" | grep -c 'warning:' || true)"
fi

if [[ -f "$ROOT/.periphery.baseline.json" ]]; then
  count="$(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["v1"]["usrs"]))' "$ROOT/.periphery.baseline.json")"
  echo "Baseline USRs still suppressed: $count"
else
  echo "Baseline file: none"
fi
