# ai-rules-ios

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey.svg)

**Plug-in for Leio iOS apps:** shared AI coding guidelines **and** a reusable quality gate (SwiftLint, SwiftFormat, Periphery).

See the rules in [`rules/always.md`](rules/always.md). Quality scripts live under [`quality/`](quality/).

**New apps:** use the [ios-bootstrap](https://github.com/dbmrq/agent-skills/tree/main/skills/ios-bootstrap) agent skill (XcodeGen starter + this plug-in + warnings-as-errors). Ongoing work: [ios-quality-gate](https://github.com/dbmrq/agent-skills/tree/main/skills/ios-quality-gate).

## Supported AI tools

| Tool | Config Location |
| --- | --- |
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

Then:

1. Edit `.periphery.yml` for your scheme/project (**no** `baseline:`)
2. Set `SWIFT_TREAT_WARNINGS_AS_ERRORS: YES` on every Swift target (see `quality/xcodegen/settings-strict.yml`)
3. Wire Quality Check `preBuildScripts` + `ENABLE_USER_SCRIPT_SANDBOXING: NO` on the app target
4. Run:

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

## Quality policy

- **Warnings as errors** — compiler (`SWIFT_TREAT_WARNINGS_AS_ERRORS`) and SwiftLint (all curated rules are `error` severity).
- **No Periphery baselines** — `./scripts/deadcode.sh` runs with `--strict`; delete unused code instead of suppressing.
- **No force unwraps** — `force_unwrapping`, `force_try`, `force_cast`, `implicitly_unwrapped_optional` are errors.
- **One shared config** — [`quality/.swiftlint.yml`](quality/.swiftlint.yml); apps only set `parent_config` + paths.

### Curated SwiftLint rules

| Family | Rules |
| --- | --- |
| Foot-guns | `force_cast`, `force_try`, `force_unwrapping`, `implicitly_unwrapped_optional` |
| Size | `file_length` (400), `type_body_length` (250), `function_body_length` (50), `function_parameter_count` (7), `cyclomatic_complexity` (15), `nesting` |
| Empty / redundancy | `empty_count`, `empty_string`, `redundant_nil_coalescing`, `unused_optional_binding`, `contains_over_filter_count`, `first_where` |
| Idioms | `unavailable_condition`, `optional_data_string_conversion` |
| Custom | `no_observable_object` |

## Quality plug-in layout

| Path | Role |
| --- | --- |
| `quality/.swiftlint.yml` | Shared lint rules (apps use `parent_config`; all errors) |
| `quality/.swiftformat` | Shared formatting |
| `quality/scripts/*` | Canonical check / format / deadcode / debt-report scripts |
| `quality/debt/RATCHET.md` | Zero-suppression checklist (historical debt only) |
| `quality/templates/*` | `.periphery.yml` + `AGENTS.md` seeds |
| `quality/xcodegen/*` | preBuild, strict settings snippets |
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
