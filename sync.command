#!/bin/bash
# Double-click in Finder (from a host app) or run: .ai-rules/sync.command
set -e

cd "$(dirname "$0")/.."

if [ -f ".ai-rules/sync.sh" ]; then
  bash .ai-rules/sync.sh
elif [ -f "sync.sh" ]; then
  # Running from inside the ai-rules-ios source repo checkout via Finder
  bash sync.sh
else
  echo "error: sync.sh not found"
  exit 1
fi

echo ""
echo "Press any key to close..."
read -n 1
