# Agent operating notes (tool-neutral)

This project uses the [ai-rules-ios](https://github.com/dbmrq/ai-rules-ios) plug-in (`.ai-rules/`) for shared iOS guidance and quality gates.

New greenfield apps: follow the **ios-bootstrap** skill (XcodeGen + this plug-in + warnings-as-errors). Finishing work: **ios-quality-gate**.

## Before finishing work

1. Run `./scripts/check.sh` (SwiftFormat lint + SwiftLint — all curated rules are errors).
2. After structural edits or removing features, run `./scripts/check-all.sh` (also Periphery `--strict`; needs a build/index store).
3. Fix failures before considering the task done. Do not leave unused store/domain APIs behind.
4. **No Periphery baselines** and **no force unwraps** (`!` / `as!`).
5. Keep `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES` on Swift targets.
6. Optional: `./.ai-rules/quality/scripts/debt-report.sh` for remaining counts.

## Project conventions

- Prefer native SwiftUI (`List`, `Form`, `ContentUnavailableView`, system buttons) over custom chrome.
- Prefer `@Observable` over `ObservableObject` / `@Published`.
- After adding files under `Sources/`, run `xcodegen generate` when the app uses XcodeGen.
- Shared rules live in `.ai-rules/rules/always.md` — edit upstream, not tool-specific copies.

## Install / update the plug-in

```bash
curl -fsSL https://raw.githubusercontent.com/dbmrq/ai-rules-ios/main/install.sh | bash -s -- --non-interactive --no-commit
```
