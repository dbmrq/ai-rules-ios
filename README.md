# ai-rules-ios

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey.svg)

**Plug-in for Leio iOS apps:** shared AI coding guidelines **and** a reusable quality gate (SwiftLint, SwiftFormat, Periphery).

See the rules in [`rules/always.md`](rules/always.md). Quality scripts live under [`quality/`](quality/).

## Supported AI tools

| Tool | Config Location |
|------|-----------------|
| [Augment](https://www.augmentcode.com/) | `.augment/rules/always.md` |
| [Cursor](https://cursor.sh/) | `.cursor/rules/always.mdc` |
| [Windsurf](https://codeium.com/windsurf) | `.windsurfrules` |
| [Cline](https://github.com/cline/cline) | `.clinerules` |
| [GitHub Copilot](https://github.com/features/copilot) | `.github/copilot-instructions.md` |
| [Claude Code](https://claude.ai/) | `.claude/rules/always.md` |
| Any agent | `AGENTS.md` (tool-neutral) |

## Installation

From your app repo root:

```bash
curl -fsSL https://raw.githubusercontent.com/dbmrq/ai-rules-ios/main/install.sh | bash -s -- --non-interactive --no-commit
```

This will:

1. Add ai-rules-ios as a git subtree at `.ai-rules/`
2. Copy rules into all supported tool locations (read-only copies)
3. Create thin `scripts/check.sh`, `format.sh`, `deadcode.sh`, `check-all.sh` wrappers
4. Seed `.swiftlint.yml` (parent config), `.swiftformat`, `.periphery.yml` template, and `AGENTS.md`
5. Install a pre-commit hook that re-syncs on commit

Then edit `.periphery.yml` for your scheme/project/targets and run:

```bash
./scripts/format.sh --fix
./scripts/check.sh
# after an Xcode build:
./scripts/deadcode.sh
```

### Options

```bash
curl -fsSL …/install.sh | bash -s -- --dry-run
curl -fsSL …/install.sh | bash -s -- --non-interactive --no-commit
```

## Quality plug-in layout

| Path | Role |
|------|------|
| `quality/.swiftlint.yml` | Shared lint rules (apps use `parent_config`) |
| `quality/.swiftformat` | Shared formatting |
| `quality/scripts/*` | Canonical check / format / deadcode scripts |
| `quality/templates/*` | `.periphery.yml` + `AGENTS.md` seeds |
| `quality/xcodegen/*` | Snippets for preBuild / Quality aggregate |
| `quality/ci/*` | Xcode Cloud pre/post fragments |

Apps keep **thin overlays** only (scheme-specific Periphery config, optional lint path tweaks).

## Updating

```bash
curl -fsSL https://raw.githubusercontent.com/dbmrq/ai-rules-ios/main/install.sh | bash -s -- --non-interactive --no-commit
```

Or:

```bash
git subtree pull --prefix=.ai-rules https://github.com/dbmrq/ai-rules-ios.git main --squash
.ai-rules/sync.sh
```

## Editing rules

Edit only `.ai-rules/rules/always.md` (or this upstream repo). Tool-specific files are read-only copies — run `.ai-rules/sync.command` or `sync.sh` after edits.

## Uninstalling

```bash
curl -fsSL https://raw.githubusercontent.com/dbmrq/ai-rules-ios/main/uninstall.sh | bash
```

## License

[MIT](LICENSE)
