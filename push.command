#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_URL="https://github.com/dbmrq/ai-rules-ios.git"
SUBTREE_DIR=".ai-rules"

# Navigate to script directory (where .ai-rules is)
cd "$(dirname "$0")/.."

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Navigate to repo root
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Check if subtree exists
if [ ! -d "$SUBTREE_DIR" ]; then
    echo -e "${RED}Error: $SUBTREE_DIR not found. Run install.sh first.${NC}"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}You have uncommitted changes.${NC}"
    echo ""
    read -p "Enter commit message (or press Enter to cancel): " COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        exit 1
    fi
    git add -A
    git commit -m "$COMMIT_MSG"
    echo -e "${GREEN}Changes committed.${NC}"
    echo ""
fi

# Push to upstream
echo "Pushing local changes to upstream..."
git subtree push --prefix="$SUBTREE_DIR" "$REPO_URL" main

echo ""
echo -e "${GREEN}Done! Changes have been pushed upstream.${NC}"

