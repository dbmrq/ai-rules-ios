#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_URL="https://github.com/dbmrq/ai-rules-ios.git"
SUBTREE_DIR=".ai-rules"
RULES_PATH="$SUBTREE_DIR/rules/always.md"

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
            echo "Usage: install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run    Preview changes without making them"
            echo "  --no-commit  Install without auto-committing"
            echo "  --help, -h   Show this help message"
            exit 0
            ;;
    esac
done

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN: No changes will be made${NC}"
    echo ""
fi

echo -e "${GREEN}Installing ai-rules-ios...${NC}"

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Navigate to repo root
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Check if already installed - if so, update
if [ -d "$SUBTREE_DIR" ]; then
    echo "ai-rules-ios already installed. Pulling updates..."
    if [ "$DRY_RUN" = true ]; then
        echo "  Would run: git subtree pull --prefix=$SUBTREE_DIR $REPO_URL main --squash"
        echo ""
        echo -e "${GREEN}DRY RUN complete. No changes made.${NC}"
        exit 0
    fi
    git subtree pull --prefix="$SUBTREE_DIR" "$REPO_URL" main --squash -m "Update AI rules from upstream"
    echo ""
    echo -e "${GREEN}Done! AI rules have been updated.${NC}"
    exit 0
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
    echo "  1. Add ai-rules-ios as subtree at $SUBTREE_DIR"
    echo "     git subtree add --prefix=$SUBTREE_DIR $REPO_URL main --squash"
    echo ""
    echo "  2. Create symlinks:"
    echo "     .clinerules -> $RULES_PATH"
    echo "     .windsurfrules -> $RULES_PATH"
    echo "     .cursor/rules/always.mdc -> ../../$RULES_PATH"
    echo "     .augment/rules/always.md -> ../../$RULES_PATH"
    echo "     .github/copilot-instructions.md -> ../$RULES_PATH"
    echo "     .claude/rules/always.md -> ../../$RULES_PATH"
    echo ""
    echo "  3. Stage and commit changes"
    echo ""
    echo -e "${GREEN}DRY RUN complete. No changes made.${NC}"
    exit 0
fi

# Add subtree
echo "Adding ai-rules-ios as subtree at $SUBTREE_DIR..."
git subtree add --prefix="$SUBTREE_DIR" "$REPO_URL" main --squash

# Create symlinks
echo "Creating symlinks..."

# Root level
ln -sf "$RULES_PATH" .clinerules
ln -sf "$RULES_PATH" .windsurfrules

# .cursor/rules/
mkdir -p .cursor/rules
ln -sf "../../$RULES_PATH" .cursor/rules/always.mdc

# .augment/rules/
mkdir -p .augment/rules
ln -sf "../../$RULES_PATH" .augment/rules/always.md

# .github/
mkdir -p .github
ln -sf "../$RULES_PATH" .github/copilot-instructions.md

# .claude/rules/
mkdir -p .claude/rules
ln -sf "../../$RULES_PATH" .claude/rules/always.md

# Stage symlinks
echo "Staging changes..."
git add .clinerules .windsurfrules .cursor .augment .github .claude

if [ "$NO_COMMIT" = true ]; then
    echo ""
    echo -e "${GREEN}Done! AI rules have been installed and staged.${NC}"
    echo -e "${YELLOW}Changes are staged but not committed. Review and commit when ready.${NC}"
else
    # Commit
    echo "Committing..."
    git commit -m "Add AI rules for iOS development

Installed via: curl -fsSL https://raw.githubusercontent.com/dbmrq/ai-rules-ios/main/install.sh | bash"

    echo ""
    echo -e "${GREEN}Done! AI rules have been installed and committed.${NC}"
fi

echo ""
echo "Commands for future reference:"
echo ""
echo "  Pull updates from upstream:"
echo "    git subtree pull --prefix=$SUBTREE_DIR $REPO_URL main --squash"
echo ""
echo "  Push local changes upstream:"
echo "    git subtree push --prefix=$SUBTREE_DIR $REPO_URL main"

