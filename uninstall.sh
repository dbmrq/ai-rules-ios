#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SUBTREE_DIR=".ai-rules"

# Parse arguments
DRY_RUN=false
NO_COMMIT=false

for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --no-commit)
            NO_COMMIT=true
            ;;
        --help|-h)
            echo "Usage: uninstall.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run    Preview changes without making them"
            echo "  --no-commit  Uninstall without auto-committing"
            echo "  --help, -h   Show this help message"
            exit 0
            ;;
    esac
done

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN: No changes will be made${NC}"
    echo ""
fi

echo -e "${YELLOW}Uninstalling ai-rules-ios...${NC}"

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Navigate to repo root
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Check if installed
if [ ! -d "$SUBTREE_DIR" ]; then
    echo -e "${RED}Error: ai-rules-ios is not installed (no $SUBTREE_DIR directory found)${NC}"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}Warning: You have uncommitted changes.${NC}"
    if [ "$DRY_RUN" = false ]; then
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

if [ "$DRY_RUN" = true ]; then
    echo "Would perform the following actions:"
    echo ""
    echo "  1. Remove symlinks:"
    [ -L ".clinerules" ] && echo "     .clinerules"
    [ -L ".windsurfrules" ] && echo "     .windsurfrules"
    [ -L ".cursor/rules/always.mdc" ] && echo "     .cursor/rules/always.mdc"
    [ -L ".augment/rules/always.md" ] && echo "     .augment/rules/always.md"
    [ -L ".github/copilot-instructions.md" ] && echo "     .github/copilot-instructions.md"
    [ -L ".claude/rules/always.md" ] && echo "     .claude/rules/always.md"
    echo ""
    echo "  2. Remove subtree directory: $SUBTREE_DIR"
    echo ""
    echo "  3. Stage and commit changes"
    echo ""
    echo -e "${GREEN}DRY RUN complete. No changes made.${NC}"
    exit 0
fi

echo "Removing symlinks..."

# Remove symlinks (check if they exist and are symlinks before removing)
[ -L ".clinerules" ] && rm ".clinerules"
[ -L ".windsurfrules" ] && rm ".windsurfrules"
[ -L ".cursor/rules/always.mdc" ] && rm ".cursor/rules/always.mdc"
[ -L ".augment/rules/always.md" ] && rm ".augment/rules/always.md"
[ -L ".github/copilot-instructions.md" ] && rm ".github/copilot-instructions.md"
[ -L ".claude/rules/always.md" ] && rm ".claude/rules/always.md"

# Remove empty directories (only if empty)
rmdir ".cursor/rules" 2>/dev/null || true
rmdir ".cursor" 2>/dev/null || true
rmdir ".augment/rules" 2>/dev/null || true
rmdir ".augment" 2>/dev/null || true
rmdir ".claude/rules" 2>/dev/null || true
rmdir ".claude" 2>/dev/null || true
# Don't remove .github as it likely contains other files

echo "Removing subtree directory..."
rm -rf "$SUBTREE_DIR"

echo "Staging changes..."
git add -A

if [ "$NO_COMMIT" = true ]; then
    echo ""
    echo -e "${GREEN}Done! ai-rules-ios has been removed and changes staged.${NC}"
    echo -e "${YELLOW}Changes are staged but not committed. Review and commit when ready.${NC}"
else
    echo "Committing..."
    git commit -m "Remove ai-rules-ios

Uninstalled via: curl -fsSL https://raw.githubusercontent.com/dbmrq/ai-rules-ios/main/uninstall.sh | bash"

    echo ""
    echo -e "${GREEN}Done! ai-rules-ios has been uninstalled.${NC}"
fi

