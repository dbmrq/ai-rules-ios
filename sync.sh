#!/usr/bin/env bash
# Sync rule copies + quality wrappers into the host project.
# When installed as a subtree, this file lives at .ai-rules/sync.sh
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Resolve project root: if we're inside .ai-rules, go up one; else use git root.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$(basename "$SCRIPT_DIR")" == ".ai-rules" ]] || [[ -d "$SCRIPT_DIR/rules" && -d "$SCRIPT_DIR/quality" ]]; then
  # Running from .ai-rules/ or from the ai-rules-ios repo itself during development
  if [[ -d "$SCRIPT_DIR/../.git" ]] || git -C "$SCRIPT_DIR/.." rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    SUBTREE_DIR_NAME="$(basename "$SCRIPT_DIR")"
  else
    REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
    SUBTREE_DIR_NAME=".ai-rules"
  fi
else
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  SUBTREE_DIR_NAME=".ai-rules"
fi

cd "$REPO_ROOT"

# When developing inside ai-rules-ios itself, SUBTREE is the repo; don't sync into itself.
if [[ -f "$REPO_ROOT/rules/always.md" && -d "$REPO_ROOT/quality" && ! -d "$REPO_ROOT/.ai-rules" ]]; then
  echo "Running inside ai-rules-ios source repo — nothing to sync into a host app."
  exit 0
fi

SUBTREE_DIR=".ai-rules"
RULES_PATH="$SUBTREE_DIR/rules/always.md"
QUALITY_DIR="$SUBTREE_DIR/quality"

if [[ ! -f "$RULES_PATH" ]]; then
  echo "error: missing $RULES_PATH" >&2
  exit 1
fi

echo -e "${GREEN}Syncing AI rule copies...${NC}"

mkdir -p .cursor/rules .augment/rules .github .claude/rules

for dest in .clinerules .windsurfrules .cursor/rules/always.mdc \
            .augment/rules/always.md .github/copilot-instructions.md \
            .claude/rules/always.md; do
  if [[ -f "$dest" ]]; then
    chmod 644 "$dest" 2>/dev/null || true
  fi
done

cp "$RULES_PATH" .clinerules
cp "$RULES_PATH" .windsurfrules
cp "$RULES_PATH" .cursor/rules/always.mdc
cp "$RULES_PATH" .augment/rules/always.md
cp "$RULES_PATH" .github/copilot-instructions.md
cp "$RULES_PATH" .claude/rules/always.md

chmod 444 .clinerules .windsurfrules .cursor/rules/always.mdc \
          .augment/rules/always.md .github/copilot-instructions.md \
          .claude/rules/always.md

if [[ -d "$QUALITY_DIR" ]]; then
  echo -e "${GREEN}Syncing quality plug-in wrappers...${NC}"
  mkdir -p scripts
  for name in check.sh format.sh deadcode.sh check-all.sh; do
    cat > "scripts/$name" <<EOF
#!/usr/bin/env bash
set -euo pipefail
ROOT="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"
exec "\$ROOT/$QUALITY_DIR/scripts/$name" "\$@"
EOF
    chmod +x "scripts/$name"
  done

  if [[ ! -f .swiftlint.yml ]]; then
    cat > .swiftlint.yml <<EOF
parent_config: $QUALITY_DIR/.swiftlint.yml

included:
  - Sources
  - Packages
  - Tests

excluded:
  - .ai-rules
  - .build
  - build
  - DerivedData
  - Packages/**/.build
EOF
    echo "Created .swiftlint.yml"
  fi

  if [[ ! -f .swiftformat ]]; then
    cp "$QUALITY_DIR/.swiftformat" .swiftformat
    echo "Created .swiftformat"
  fi

  if [[ ! -f .periphery.yml ]]; then
    cp "$QUALITY_DIR/templates/periphery.yml" .periphery.yml
    echo -e "${YELLOW}Created .periphery.yml — edit scheme/project/targets.${NC}"
  fi

  if [[ ! -f AGENTS.md ]]; then
    cp "$QUALITY_DIR/templates/AGENTS.md" AGENTS.md
    echo "Created AGENTS.md"
  fi
else
  echo -e "${YELLOW}No quality/ directory in plug-in.${NC}"
fi

echo -e "${GREEN}Sync complete.${NC}"
