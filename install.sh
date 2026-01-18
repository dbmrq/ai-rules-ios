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

# Function to sync rules to all destinations
sync_rules() {
    local source="$RULES_PATH"

    # Create directories
    mkdir -p .cursor/rules .augment/rules .github .claude/rules

    # Make destination files writable if they exist (so we can overwrite)
    for dest in .clinerules .windsurfrules .cursor/rules/always.mdc \
                .augment/rules/always.md .github/copilot-instructions.md \
                .claude/rules/always.md; do
        [ -f "$dest" ] && chmod 644 "$dest" 2>/dev/null || true
    done

    # Copy to all destinations
    cp "$source" .clinerules
    cp "$source" .windsurfrules
    cp "$source" .cursor/rules/always.mdc
    cp "$source" .augment/rules/always.md
    cp "$source" .github/copilot-instructions.md
    cp "$source" .claude/rules/always.md

    # Make copies read-only to prevent accidental edits
    chmod 444 .clinerules .windsurfrules .cursor/rules/always.mdc \
              .augment/rules/always.md .github/copilot-instructions.md \
              .claude/rules/always.md
}

# Function to install pre-commit hook
install_hook() {
    local hook_dir=".git/hooks"
    local hook_file="$hook_dir/pre-commit"
    local hook_marker="# ai-rules-ios sync"

    # Check if hook already has our marker
    if [ -f "$hook_file" ] && grep -q "$hook_marker" "$hook_file"; then
        return 0
    fi

    # Create hooks directory if it doesn't exist
    mkdir -p "$hook_dir"

    # If hook exists and is executable, append to it; otherwise create new
    if [ -x "$hook_file" ]; then
        echo "" >> "$hook_file"
        echo "$hook_marker" >> "$hook_file"
    else
        echo "#!/bin/bash" > "$hook_file"
        echo "$hook_marker" >> "$hook_file"
    fi

    # Add the sync logic
    cat >> "$hook_file" << 'HOOK_SCRIPT'
# Sync AI rules before commit
if [ -f ".ai-rules/rules/always.md" ]; then
    RULES_SOURCE=".ai-rules/rules/always.md"
    DESTINATIONS=(".clinerules" ".windsurfrules" ".cursor/rules/always.mdc" \
                  ".augment/rules/always.md" ".github/copilot-instructions.md" \
                  ".claude/rules/always.md")

    for dest in "${DESTINATIONS[@]}"; do
        if [ -f "$dest" ]; then
            # Make writable, update, make read-only
            chmod 644 "$dest" 2>/dev/null || true
            cp "$RULES_SOURCE" "$dest"
            chmod 444 "$dest"
            git add "$dest"
        fi
    done
fi
HOOK_SCRIPT

    chmod +x "$hook_file"
}

# Check if already installed - if so, update
if [ -d "$SUBTREE_DIR" ]; then
    echo "ai-rules-ios already installed. Pulling updates..."
    if [ "$DRY_RUN" = true ]; then
        echo "  Would run: git subtree pull --prefix=$SUBTREE_DIR $REPO_URL main --squash"
        echo "  Would sync rules to all destinations"
        echo ""
        echo -e "${GREEN}DRY RUN complete. No changes made.${NC}"
        exit 0
    fi
    git subtree pull --prefix="$SUBTREE_DIR" "$REPO_URL" main --squash -m "Update AI rules from upstream"
    sync_rules
    echo ""
    echo -e "${GREEN}Done! AI rules have been updated and synced.${NC}"
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
    echo "  2. Copy rules to (read-only):"
    echo "     .clinerules"
    echo "     .windsurfrules"
    echo "     .cursor/rules/always.mdc"
    echo "     .augment/rules/always.md"
    echo "     .github/copilot-instructions.md"
    echo "     .claude/rules/always.md"
    echo ""
    echo "  3. Install pre-commit hook to auto-sync on commit"
    echo ""
    echo "  4. Stage and commit changes"
    echo ""
    echo -e "${GREEN}DRY RUN complete. No changes made.${NC}"
    exit 0
fi

# Add subtree
echo "Adding ai-rules-ios as subtree at $SUBTREE_DIR..."
git subtree add --prefix="$SUBTREE_DIR" "$REPO_URL" main --squash

# Sync rules to all destinations
echo "Syncing rules to all destinations..."
sync_rules

# Install pre-commit hook
echo "Installing pre-commit hook..."
install_hook

# Stage files
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
echo "Notes:"
echo "  - Rule copies are read-only; edit only .ai-rules/rules/always.md"
echo "  - Run .ai-rules/sync.command to manually sync after editing"
echo "  - Pre-commit hook auto-syncs on commit"
echo ""
echo "Commands for future reference:"
echo ""
echo "  Pull updates from upstream:"
echo "    git subtree pull --prefix=$SUBTREE_DIR $REPO_URL main --squash"
echo ""
echo "  Push local changes upstream:"
echo "    git subtree push --prefix=$SUBTREE_DIR $REPO_URL main"

