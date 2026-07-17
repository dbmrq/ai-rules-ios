#!/usr/bin/env bash
# Unused-code gate via Periphery. Prefers a recent index store when --skip-build is used.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/_lib.sh"

ROOT="$(repo_root_from_cwd)"
require_quality_installed "$ROOT"
require_tool periphery periphery

cd "$ROOT"

if [[ ! -f "$ROOT/.periphery.yml" ]]; then
  echo "error: missing .periphery.yml in project root." >&2
  echo "Copy the template from .ai-rules/quality/templates/periphery.yml and set scheme/project." >&2
  exit 1
fi

SKIP_BUILD=false
INDEX_STORE=""
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-build)
      SKIP_BUILD=true
      shift
      ;;
    --index-store-path)
      INDEX_STORE="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: deadcode.sh [--skip-build] [--index-store-path PATH] [periphery args...]"
      exit 0
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

ARGS=(scan)
if [[ "$SKIP_BUILD" == true ]]; then
  ARGS+=(--skip-build)
  if [[ -z "$INDEX_STORE" ]]; then
    INDEX_STORE="$(
      find "$HOME/Library/Developer/Xcode/DerivedData" -type d \( -path '*/Index.noindex/DataStore' -o -path '*/Index/DataStore' \) 2>/dev/null \
        | head -n 1 || true
    )"
    if [[ -z "$INDEX_STORE" ]]; then
      echo "error: --skip-build requires --index-store-path (or a DerivedData index store)." >&2
      exit 1
    fi
    echo "Using index store: $INDEX_STORE"
  fi
  ARGS+=(--index-store-path "$INDEX_STORE")
fi

if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  ARGS+=("${EXTRA_ARGS[@]}")
fi

echo "==> periphery ${ARGS[*]}"
set +e
periphery_output="$(periphery "${ARGS[@]}" 2>&1)"
periphery_status=$?
set -e
printf '%s\n' "$periphery_output"
if [[ "$periphery_status" -ne 0 ]] || [[ "$periphery_output" == *"BUILD FAILED"* ]]; then
  echo "error: periphery scan failed" >&2
  exit 1
fi

echo "OK: deadcode.sh passed"
