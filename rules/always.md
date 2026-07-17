---
description: Swift and iOS development guidelines
globs:
alwaysApply: true
---

# Swift and iOS Development Guidelines

## General Principles

- Be aware of the project's minimum iOS deployment target
- Use the newest available APIs and features supported by the minimum version
- Prefer modern alternatives (e.g., SwiftData over Core Data, Swift Testing over XCTest, Observation over Combine)
- After making changes, remove any stale code that no longer applies
- Pay attention to consistency across the codebase
  - When changing something in one place, check for similar patterns elsewhere

## Code Style

- Follow Apple's Swift code formatting standards
- Do not add trailing whitespace
- Do not use emojis in code or comments
- A single class/struct/enum per file
- Organize the workspace semantically, not by file type (e.g., group related views and view models together)
- Use extensions to organize protocol conformance
- Use MARK comments to organize code sections:

```swift
// MARK: - Properties
// MARK: - Lifecycle
// MARK: - Public Methods
// MARK: - Private Methods
```

## Swift Best Practices

- Never use forced unwrapping (`!`); use `#require` in tests
- Favor protocol composition over inheritance
- Use protocol extensions to provide default implementations
- Design for protocol conformance rather than concrete types
- Prefer `Logger()` over `print()` for debugging
- Use typed throws to specify error types when appropriate
- Prefer `guard let` with early return over deeply nested optional chaining
- Let the compiler synthesize `Equatable`, `Hashable` and other conformances when possible

## Concurrency

- Use `async/await` for asynchronous code
- Use strict concurrency; never use `nonisolated(unsafe)` or `@unchecked Sendable`
- Use actors for shared mutable state
- Avoid running code on the main actor unless it's UI-related
- Mark classes with `@MainActor` when they drive UI updates
- Mark closures as `@Sendable` when passed across actor boundaries
- Remember that `@MainActor` is inherited by subclasses

## SwiftUI

- Use SwiftUI for new UI development
- Always add Previews to views
- Use `@Observable` instead of `ObservableObject`
- Keep views small and modular
- Prefer native SwiftUI controls over custom implementations:
  - Use button modifiers like `.bordered`, `.borderedProminent`
  - Use `GroupBox` for cards
  - Prefer default system colors
- Use SF Symbols instead of custom icons
- Implement size classes to adapt layouts between iPhone and iPad
- Use Dynamic Type to support different text sizes
- Avoid `AnyView`; use `@ViewBuilder` or generics instead
- Use `@Environment` for dependency injection
- Use `.task` modifier instead of `onAppear` with `Task { }` for automatic cancellation

## Data and Networking

- Use appropriate storage solutions:
  - UserDefaults for simple key-value pairs
  - Keychain for sensitive data
  - SwiftData for complex object relationships
  - CloudKit for syncing across devices
- Handle poor network conditions gracefully

## Testing

- Write meaningful tests for business logic; avoid superficial tests
- Prefer Swift Testing framework over XCTest
- Structure tests using Arrange-Act-Assert pattern
- Use project-specific build/test scripts when available

## Quality gates

- Prefer the shared [ai-rules-ios](https://github.com/dbmrq/ai-rules-ios) plug-in (`.ai-rules/`) for SwiftLint, SwiftFormat, and Periphery — do not invent a second lint stack
- Treat compiler warnings as errors (`SWIFT_TREAT_WARNINGS_AS_ERRORS`)
- Never force-unwrap (`!` / `as!`); never commit Periphery baselines — fix unused code instead
- Before finishing work: `./scripts/format.sh --fix`, `./scripts/check.sh`, and after structural edits `./scripts/deadcode.sh`
- New apps: follow the **ios-bootstrap** agent skill; ongoing work: **ios-quality-gate**

## Accessibility

- Make apps fully accessible from the start
- Support Dark Mode
- Set accessibility labels and hints for all UI elements

## Documentation

- Be parsimonious: don't document what's obvious from the code
- Use `///` comments only for non-obvious public interfaces
- Don't create new documentation files unless explicitly requested

## App Store and Platform

- Follow Human Interface Guidelines
- Ensure compliance with App Store Review Guidelines
- Include required privacy labels and descriptions
- Add App Tracking Transparency prompt if needed
- Support Handoff and Continuity features
- Use rich notifications with appropriate actions

## Memory Management

- Use `[weak self]` in escaping closures to avoid retain cycles
- Store and cancel Combine subscriptions to prevent memory leaks

## Performance

- Use Instruments to identify performance bottlenecks
- Implement pagination for large data sets
