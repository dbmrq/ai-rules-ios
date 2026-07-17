#!/usr/bin/env bash
# Fast quality gate: SwiftFormat (lint) + SwiftLint (strict).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/_lib.sh"

PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(repo_root_from_cwd)"
require_quality_installed "$ROOT"
require_tool swiftformat swiftformat
require_tool swiftlint swiftlint

cd "$ROOT"

FORMAT_CONFIG="$ROOT/.swiftformat"
if [[ ! -f "$FORMAT_CONFIG" ]]; then
  FORMAT_CONFIG="$PLUGIN_ROOT/.swiftformat"
fi

LINT_CONFIG="$ROOT/.swiftlint.yml"
if [[ ! -f "$LINT_CONFIG" ]]; then
  LINT_CONFIG="$PLUGIN_ROOT/.swiftlint.yml"
fi

echo "==> swiftformat --lint"
swiftformat --lint --config "$FORMAT_CONFIG" .

echo "==> swiftlint lint"
# Warnings are reported but do not fail; rule severities of `error` still fail the build.
swiftlint lint --config "$LINT_CONFIG" --quiet

echo "OK: check.sh passed"
