# Agent operating notes (tool-neutral)

This project uses the [ai-rules-ios](https://github.com/dbmrq/ai-rules-ios) plug-in (`.ai-rules/`) for shared iOS guidance and quality gates.

## Before finishing work

1. Run `./scripts/check.sh` (SwiftFormat lint + SwiftLint).
2. After structural edits or removing features, run `./scripts/check-all.sh` (also Periphery unused-code scan; needs a build/index store).
3. Fix failures before considering the task done. Do not leave unused store/domain APIs behind.

## Project conventions

- Prefer native SwiftUI (`List`, `Form`, `ContentUnavailableView`, system buttons) over custom chrome.
- Prefer `@Observable` over `ObservableObject` / `@Published`.
- After adding files under `Sources/`, run `xcodegen generate` when the app uses XcodeGen.
- Shared rules live in `.ai-rules/rules/always.md` — edit upstream, not tool-specific copies.

## Install / update the plug-in

```bash
curl -fsSL https://raw.githubusercontent.com/dbmrq/ai-rules-ios/main/install.sh | bash -s -- --non-interactive --no-commit
```
