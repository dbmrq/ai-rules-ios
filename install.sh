#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_URL="https://github.com/dbmrq/ai-rules-ios.git"
SUBTREE_DIR=".ai-rules"
RULES_PATH="$SUBTREE_DIR/rules/always.md"

DRY_RUN=false
NO_COMMIT=false
NON_INTERACTIVE=false

for arg in "$@"; do
    case $arg in
        --dry-run) DRY_RUN=true ;;
        --no-commit) NO_COMMIT=true ;;
        --non-interactive) NON_INTERACTIVE=true ;;
        --help|-h)
            echo "Usage: install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run           Preview changes without making them"
            echo "  --no-commit         Install without auto-committing"
            echo "  --non-interactive   Skip confirmation prompts (for agents/CI)"
            echo "  --help, -h          Show this help message"
            exit 0
            ;;
    esac
done

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN: No changes will be made${NC}"
    echo ""
fi

echo -e "${GREEN}Installing ai-rules-ios (rules + quality plug-in)...${NC}"

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

run_sync() {
    if [ -f "$SUBTREE_DIR/sync.sh" ]; then
        bash "$SUBTREE_DIR/sync.sh"
    else
        echo -e "${RED}error: $SUBTREE_DIR/sync.sh missing${NC}"
        exit 1
    fi
}

install_hook() {
    local hook_dir=".git/hooks"
    local hook_file="$hook_dir/pre-commit"
    local hook_marker="# ai-rules-ios sync"

    if [ -f "$hook_file" ] && grep -q "$hook_marker" "$hook_file"; then
        return 0
    fi

    mkdir -p "$hook_dir"

    if [ -x "$hook_file" ]; then
        echo "" >> "$hook_file"
        echo "$hook_marker" >> "$hook_file"
    else
        echo "#!/bin/bash" > "$hook_file"
        echo "$hook_marker" >> "$hook_file"
    fi

    cat >> "$hook_file" << 'HOOK_SCRIPT'
# Sync AI rules + quality wrappers before commit
if [ -f ".ai-rules/sync.sh" ]; then
    bash .ai-rules/sync.sh
    git add .clinerules .windsurfrules .cursor .augment .github .claude \
      scripts AGENTS.md .swiftlint.yml .swiftformat .periphery.yml 2>/dev/null || true
fi
HOOK_SCRIPT

    chmod +x "$hook_file"
}

if [ -d "$SUBTREE_DIR" ]; then
    echo "ai-rules-ios already installed. Pulling updates..."
    if [ "$DRY_RUN" = true ]; then
        echo "  Would run: git subtree pull --prefix=$SUBTREE_DIR $REPO_URL main --squash"
        echo "  Would run: $SUBTREE_DIR/sync.sh"
        exit 0
    fi
    git subtree pull --prefix="$SUBTREE_DIR" "$REPO_URL" main --squash -m "Update AI rules and quality plug-in from upstream"
    run_sync
    echo -e "${GREEN}Done! Updated and synced.${NC}"
    exit 0
fi

if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}Warning: You have uncommitted changes.${NC}"
    if [ "$DRY_RUN" = false ] && [ "$NON_INTERACTIVE" = false ]; then
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    elif [ "$NON_INTERACTIVE" = true ]; then
        echo "Continuing because --non-interactive was set."
    fi
fi

if [ "$DRY_RUN" = true ]; then
    echo "Would add subtree, sync rules+quality wrappers, install pre-commit hook, and stage."
    exit 0
fi

echo "Adding ai-rules-ios as subtree at $SUBTREE_DIR..."
git subtree add --prefix="$SUBTREE_DIR" "$REPO_URL" main --squash

echo "Syncing rules and quality plug-in..."
run_sync

echo "Installing pre-commit hook..."
install_hook

echo "Staging changes..."
git add .clinerules .windsurfrules .cursor .augment .github .claude \
  scripts AGENTS.md .swiftlint.yml .swiftformat .periphery.yml 2>/dev/null || true
git add -A "$SUBTREE_DIR" 2>/dev/null || true

if [ "$NO_COMMIT" = true ]; then
    echo -e "${GREEN}Done! Plug-in installed and staged.${NC}"
    echo -e "${YELLOW}Edit .periphery.yml (scheme/targets), then commit when ready.${NC}"
else
    git commit -m "$(cat <<'EOF'
Add ai-rules-ios (rules + quality plug-in)

Shared SwiftLint/SwiftFormat/Periphery scripts and multi-tool agent rules.
EOF
)"
    echo -e "${GREEN}Done! Plug-in installed and committed.${NC}"
fi

echo ""
echo "Next: edit .periphery.yml, then ./scripts/format.sh --fix && ./scripts/check.sh"
