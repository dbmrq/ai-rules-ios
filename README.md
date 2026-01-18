# ai-rules-ios

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey.svg)]()

**Single source of truth for AI coding assistants in iOS projects.**

This project provides a shared set of iOS development guidelines that are symlinked for major AI coding assistants.

See the rules in [`rules/always.md`](rules/always.md).

## Supported Tools

| Tool | Config Location |
|------|-----------------|
| [Augment](https://www.augmentcode.com/) | `.augment/rules/always.md` |
| [Cursor](https://cursor.sh/) | `.cursor/rules/always.mdc` |
| [Windsurf](https://codeium.com/windsurf) | `.windsurfrules` |
| [Cline](https://github.com/cline/cline) | `.clinerules` |
| [GitHub Copilot](https://github.com/features/copilot) | `.github/copilot-instructions.md` |
| [Claude Code](https://claude.ai/) | `.claude/rules/always.md` |

## Installation

Run this command in your project's root directory:

```bash
curl -fsSL https://raw.githubusercontent.com/dbmrq/ai-rules-ios/main/install.sh | bash
```

This will:
1. Add ai-rules-ios as a git subtree at `.ai-rules/`
2. Create symlinks for all supported tools
3. Commit the changes

### Installation Options

```bash
# Preview changes without making them
curl -fsSL https://raw.githubusercontent.com/dbmrq/ai-rules-ios/main/install.sh | bash -s -- --dry-run

# Install without committing
curl -fsSL https://raw.githubusercontent.com/dbmrq/ai-rules-ios/main/install.sh | bash -s -- --no-commit
```

## Updating

Re-run the install command to pull the latest rules:

```bash
curl -fsSL https://raw.githubusercontent.com/dbmrq/ai-rules-ios/main/install.sh | bash
```

Or manually:

```bash
git subtree pull --prefix=.ai-rules https://github.com/dbmrq/ai-rules-ios.git main --squash
```

## Uninstalling

```bash
curl -fsSL https://raw.githubusercontent.com/dbmrq/ai-rules-ios/main/uninstall.sh | bash
```

## Contributing

Contributions are welcome! Please open an issue or pull request.

## License

[MIT](LICENSE)

