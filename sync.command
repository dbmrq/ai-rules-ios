#!/bin/bash
# Double-click this file in Finder to sync AI rules after editing .ai-rules/rules/always.md

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Navigate to repo root
cd "$(dirname "$0")/.."

RULES_SOURCE=".ai-rules/rules/always.md"

if [ ! -f "$RULES_SOURCE" ]; then
    echo -e "${RED}Error: Source file not found: $RULES_SOURCE${NC}"
    echo "Press any key to close..."
    read -n 1
    exit 1
fi

echo -e "${GREEN}Syncing AI rules...${NC}"
echo ""

# Destinations
DESTINATIONS=(
    ".clinerules"
    ".windsurfrules"
    ".cursor/rules/always.mdc"
    ".augment/rules/always.md"
    ".github/copilot-instructions.md"
    ".claude/rules/always.md"
)

# Create directories if needed
mkdir -p .cursor/rules .augment/rules .github .claude/rules

# Sync each destination
for dest in "${DESTINATIONS[@]}"; do
    # Make writable if exists
    [ -f "$dest" ] && chmod 644 "$dest" 2>/dev/null || true
    # Copy
    cp "$RULES_SOURCE" "$dest"
    # Make read-only
    chmod 444 "$dest"
    echo "  ✓ $dest"
done

echo ""
echo -e "${GREEN}Done! All rule files have been synced.${NC}"
echo ""
echo -e "${YELLOW}Note: These changes are not staged. Commit when ready.${NC}"
echo ""
echo "Press any key to close..."
read -n 1

