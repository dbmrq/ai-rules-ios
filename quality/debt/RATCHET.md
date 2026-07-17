# Quality debt ratchet (zero suppressions)

**Architecture spec:** shared plug-in under `quality/`; apps Melvil + Gregor consume via `.ai-rules`.

## Goal

Eliminate every quality suppression until Melvil and Gregor are 100% green: no Periphery baselines, SwiftLint expanded and all-errors (including `force_unwrapping`), gates fail on any finding.

## How this plan is used (Ralph loop)

This file is the **source of truth** for chip-away agent runs. Each run, a fresh agent:

1. Reads this plan
2. Implements the **next unchecked** checklist item only
3. Runs that item's verification
4. Marks the item `[x]` when verified
5. Adds **Notes for later items** when it learns something future agents need

Shared changes land in **ai-rules-ios first**, then sync Melvil/Gregor `.ai-rules`. Never reintroduce force unwraps or grow baselines.

## Contracts / invariants

- Prefer delete unused API over `@_spi` / `// periphery:ignore` / baseline growth.
- Never reintroduce force unwraps (`!`, `as!`) to silence a lint.
- One ratchet step per run; do not combine unrelated families.
- Legitimate path filters stay: `exclude_tests`, LeioMarkdown excludes, `retain_*`.

## Implementation Checklist

- [x] **1. Scaffold debt tooling.**  
  Ensure `quality/scripts/debt-report.sh` exists and `deadcode.sh` always passes `--strict`. Templates must not teach baselines.  
  Verification: `bash -n quality/scripts/debt-report.sh quality/scripts/deadcode.sh` and `rg -n 'write-baseline|baseline:' quality/templates` shows none (except historical notes if any — prefer none).

- [x] **2. Force unwrap as error + clear Melvil.**  
  Add `force_unwrapping` to shared `only_rules` at severity error. Fix any Melvil violations.  
  Verification: Melvil `./scripts/check.sh` exits 0 with force_unwrapping error enabled.

- [x] **3. Clear Gregor force unwraps (calendar/day).**  
  Remove all `!` / `as!` in Gregor calendar, vault day helpers, and tests. Prefer `guard let` / `if let` / `??`.  
  Verification: Gregor `./scripts/check.sh` exits 0; `debt-report.sh` shows 0 `force_unwrapping`.

- [x] **4. Promote curated foot-guns to error.**  
  Set `force_try`, `empty_count`, `redundant_nil_coalescing`, `contains_over_filter_count`, `no_observable_object` to error. Fix both apps.  
  Verification: both apps `./scripts/check.sh` green.

- [x] **5. Periphery — unused imports + obvious dead APIs (Melvil).**  
  Fix unused imports and clearly unused functions/properties in Melvil; rewrite smaller baseline or remove entries.  
  Verification: Melvil deadcode with empty baseline override shows fewer findings; `./scripts/deadcode.sh` green.

- [x] **6. Periphery — unused imports + obvious dead APIs (Gregor).**  
  Same for Gregor (e.g. unused `GregorSpotlight` import, `renameNote`, share helpers).  
  Verification: Gregor `./scripts/deadcode.sh` green; findings count down.

- [x] **7. Periphery — assign-only + demo/screenshot symbols.**  
  Wire reads, remove, or give real call sites Periphery can see. Both apps.  
  Verification: assign-only / demo findings gone from empty-baseline scan.

- [x] **8. Periphery — demote redundant public (Melvil).**  
  Demote same-module `public` to `internal` where redundant.  
  Verification: Melvil empty-baseline scan has 0 redundant-public findings.

- [x] **9. Periphery — demote redundant public (Gregor).**  
  Especially `NoteStore` and package-internal APIs.  
  Verification: Gregor empty-baseline scan has 0 redundant-public findings.

- [x] **10. Delete Periphery baselines.**  
  Remove `.periphery.baseline.json` and `baseline:` from Melvil and Gregor `.periphery.yml`.  
  Verification: both apps `./scripts/deadcode.sh` green with `--strict` and no baseline file.

- [x] **11. Tighten length ceilings (step 1).**  
  Shared: function 70, type 400, file 500. Fix hotspots that exceed. Still warning or error only if already clean.  
  Verification: both apps `./scripts/check.sh` green at new ceilings.

- [x] **12. Tighten length ceilings (final) + error severity.**  
  Shared finals: function 50, type 250, file 400. Promote length/complexity/nesting/parameter rules to error. Split remaining hot types/files.  
  Verification: both apps `./scripts/check.sh` green; length rules are errors.

- [x] **13. Expand family — optional safety.**  
  Enable `implicitly_unwrapped_optional` (and related) as warning, fix both apps, promote to error.  
  Verification: both apps clean for this family at error.

- [x] **14. Expand family — unused/redundancy.**  
  Enable `unused_optional_binding`, `redundant_optional_initialization`, `unreachable_code` (warn → fix → error).  
  Verification: both apps clean for this family at error.

- [x] **15. Expand family — collection idioms.**  
  Enable `first_where`, `empty_string`, and related (warn → fix → error).  
  Verification: both apps clean for this family at error.

- [x] **16. Lock end state.**  
  Update shared philosophy comments; confirm CI snippets; `debt-report.sh` zeros; no baseline files.  
  Verification: Melvil and Gregor `./scripts/check-all.sh` green; debt report all zeros.

## Notes for later items

- Cross-file extensions require `internal` (not `private`/`private(set)`) for members mutated outside the defining file.
- `unreachable_code` / `redundant_optional_initialization` were not available as named rules in the installed SwiftLint; used `unused_optional_binding`, `unavailable_condition`, `optional_data_string_conversion` instead.
- Gregor Periphery prefers app `build` + `--skip-build` when test targets fail under Periphery’s default `build-for-testing`.

## Manual Validation After The Checklist

- Smoke Melvil editor + Gregor calendar month/week paging after force-unwrap removals.
- Confirm Xcode Cloud still runs quality scripts on both apps.
- Spot-check that demoted `internal` APIs didn’t break a future package split you care about.
