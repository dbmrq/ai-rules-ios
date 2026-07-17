#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/_lib.sh"

PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(repo_root_from_cwd)"
require_quality_installed "$ROOT"
require_tool swiftformat swiftformat

CONFIG="$ROOT/.swiftformat"
if [[ ! -f "$CONFIG" ]]; then
  CONFIG="$PLUGIN_ROOT/.swiftformat"
fi

FIX=false
for arg in "$@"; do
  case "$arg" in
    --fix) FIX=true ;;
    --lint) FIX=false ;;
    --help|-h)
      echo "Usage: format.sh [--fix|--lint]"
      exit 0
      ;;
  esac
done

cd "$ROOT"
if [[ "$FIX" == true ]]; then
  swiftformat --config "$CONFIG" .
else
  swiftformat --lint --config "$CONFIG" .
fi
