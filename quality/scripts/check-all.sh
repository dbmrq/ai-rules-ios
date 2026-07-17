#!/usr/bin/env bash
# Full gate: lint/format + unused code.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/check.sh"
"$SCRIPT_DIR/deadcode.sh" "$@"
