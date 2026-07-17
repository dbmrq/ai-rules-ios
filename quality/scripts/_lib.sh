#!/usr/bin/env bash
# Shared helpers for ai-rules-ios quality plug-in scripts.
set -euo pipefail

require_tool() {
  local name="$1"
  local brew_pkg="${2:-$1}"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "error: '$name' is required. Install with: brew install $brew_pkg" >&2
    exit 1
  fi
}

repo_root_from_cwd() {
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    git rev-parse --show-toplevel
    return
  fi
  pwd
}

require_quality_installed() {
  local root="$1"
  if [[ ! -d "$root/.ai-rules/quality" ]]; then
    echo "error: .ai-rules/quality is missing." >&2
    echo "Install the plug-in:" >&2
    echo "  curl -fsSL https://raw.githubusercontent.com/dbmrq/ai-rules-ios/main/install.sh | bash -s -- --non-interactive --no-commit" >&2
    exit 1
  fi
}
