# Swift 6 Fix: $ARGUMENTS

Apply Swift 6 strict concurrency fixes for the specified category.

**Valid categories:** `config`, `mainactor`, `singletons`, `dispatch-queue`, `completion-handlers`, `sendable`, `delegates`

If `$ARGUMENTS` is empty, show usage and recommend next category based on `docs/swift6-migration-status.md`.

## Prerequisites

1. Read `docs/swift6-migration-status.md` to understand current progress
2. Run `/swift6-check $ARGUMENTS` mentally — verify that the category has remaining items
3. If the category shows 0 remaining, inform the user and suggest the next category

## Category: `config`

Foundation changes — run this FIRST before any other category.

### Steps
1. Update `Project.swift`: change `"SWIFT_VERSION": "5.3"` → `"SWIFT_VERSION": "6.0"` (all occurrences)
2. Update all `Modules/*/Package.swift`: change `swiftLanguageMode(.v5)` → `swiftLanguageMode(.v6)`
3. Add `SWIFT_STRICT_CONCURRENCY` build setting:
   - If first time: set to `targeted`
   - If `targeted` already done: set to `complete`
4. Lock any dependency versions still pinned to `master` / a moving branch (Swift 6 will break on unexpected upstream changes)
5. Run `tuist generate --no-open`
6. Build: `xcodebuild -scheme {{APP}} -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' -quiet build`
7. If build fails, fix errors iteratively (max 10 iterations)
8. Update `docs/swift6-migration-status.md` config checklist
9. Commit with message: `[CHORE] Swift 6 migration: update Swift version and concurrency settings`

## Category: `mainactor`

Add `@MainActor` to ViewModels that are `ObservableObject` subclasses.

### Rules
- Add `@MainActor` annotation to the class declaration
- Do NOT change any method signatures or property types
- If a method is explicitly `nonisolated`, leave it as-is
- If a class already has `@MainActor`, skip it
- Work in batches of 20-30 files per session to keep PRs reviewable

### Steps
1. Find all unannotated ViewModels:
   ```bash
   grep -rl "class.*ViewModel.*ObservableObject" {{APP}}/ --include="*.swift" | while read f; do
     grep -L "@MainActor" "$f"
   done
   ```
2. For each file, add `@MainActor` before the class declaration:
   ```swift
   // BEFORE
   final class SomeViewModel: ObservableObject {

   // AFTER
   @MainActor
   final class SomeViewModel: ObservableObject {
   ```
3. Build after every 10 files. If errors appear:
   - `@MainActor`-isolated property accessed from non-isolated context → add `@MainActor` to the caller or mark the access as `MainActor.assumeIsolated`
   - Protocol conformance issues → add `@MainActor` to the protocol if it's internal
   - Test files referencing the ViewModel → add `@MainActor` to the test class or use `await`
4. Run tests for affected modules
5. Update `docs/swift6-migration-status.md`:
   - Increment "Done" count
   - Decrement "Remaining" count
   - Add entry to Execution Log
6. Format changed files with `swiftformat`
7. Commit with message: `[CHORE] Swift 6 migration: add @MainActor to ViewModels (batch N)`

## Category: `singletons`

Protect mutable singletons with actor isolation or `@MainActor`.

### Rules
- `static let shared` with mutable properties → add `@MainActor` to the class
- `static var shared` (mutable reference) → change to `static let shared` + add `@MainActor`
- If the singleton is accessed from background threads intentionally, wrap in an actor instead
- The session/user singleton typically gets special treatment — it's usually the most critical one

### Critical Singletons (priority order)
1. Session/user managers — many mutable properties, accessed everywhere
2. Any `static var shared` (mutable reference!) — convert first
3. Analytics/tracking singletons with mutable internal state
4. Shared ViewModels exposed as `static var`
5. All remaining `static let shared` with mutable internal state

### Steps
1. List all singletons:
   ```bash
   grep -rn "static let shared\|static var shared" {{APP}}/ --include="*.swift"
   ```
2. For each singleton:
   a. Read the file to understand thread access patterns
   b. If mainly UI-bound: add `@MainActor` to the class
   c. If accessed from background threads: convert to actor or use `nonisolated(unsafe)` as escape hatch
   d. Change `static var shared` → `static let shared` where possible
3. Build after every 5 changes
4. Fix cascading errors (callers may need `await` or `@MainActor`)
5. Run tests
6. Update `docs/swift6-migration-status.md`
7. Commit with message: `[CHORE] Swift 6 migration: protect singletons with actor isolation`

## Category: `dispatch-queue`

Replace `DispatchQueue.main.async` with structured concurrency.

### Rules
- `DispatchQueue.main.async { ... }` in a `@MainActor` context → remove the dispatch, code already runs on main
- `DispatchQueue.main.async { ... }` in a non-MainActor context → use `Task { @MainActor in ... }` or `await MainActor.run { ... }`
- `DispatchQueue.main.sync` → evaluate carefully, may indicate a design issue
- `DispatchQueue.global().async` → use `Task.detached` or `Task { ... }` with appropriate priority
- Work in batches of 30-50 replacements per session

### Steps
1. Find all occurrences:
   ```bash
   grep -rn "DispatchQueue\.main\.async" {{APP}}/ --include="*.swift"
   ```
2. Group by file and context:
   - In ViewModels (already `@MainActor` after mainactor phase) → remove dispatch wrapper
   - In Services/Repositories → use `Task { @MainActor in ... }`
   - In UIKit delegates/callbacks → use `Task { @MainActor in ... }`
3. Apply changes per file
4. Build after every 15 files
5. Run tests
6. Update `docs/swift6-migration-status.md`
7. Commit with message: `[CHORE] Swift 6 migration: replace DispatchQueue.main.async (batch N)`

## Category: `completion-handlers`

Convert completion handler APIs to async/await.

### Rules
- Start with internal APIs (repositories, data sources, managers)
- Do NOT convert third-party SDK callbacks — use `withCheckedContinuation` wrappers
- If a method has both completion and async versions, remove the completion version
- Update callers to use async/await
- Work in batches by module/feature area

### Steps
1. Find all completion handlers:
   ```bash
   grep -rn "completion:.*@escaping" {{APP}}/ --include="*.swift"
   ```
2. For each function:
   a. Create async version:
   ```swift
   // BEFORE
   func fetchData(id: String, completion: @escaping (Result<Data, Error>) -> Void)

   // AFTER
   func fetchData(id: String) async throws -> Data
   ```
   b. Update all callers to use `await`
   c. If the function is in a protocol, update protocol + all conformers
3. Build after every 10 conversions
4. Run tests
5. Update `docs/swift6-migration-status.md`
6. Commit with message: `[CHORE] Swift 6 migration: convert completion handlers to async/await (batch N)`

## Category: `sendable`

Add `Sendable` conformance to types that cross concurrency boundaries.

### Rules
- Structs with only value-type properties → add `: Sendable`
- `final class` with only `let` properties of Sendable types → add `: Sendable`
- `final class` with mutable state → add `@MainActor` or convert to actor
- Enums without associated values or with Sendable associated values → add `: Sendable`
- Do NOT add `@unchecked Sendable` unless absolutely necessary (document why)
- Protocol types used in closures → add `: Sendable` to protocol

### Steps
1. Build with strict concurrency and collect "non-Sendable" warnings:
   ```bash
   xcodebuild -scheme {{APP}} -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' \
     OTHER_SWIFT_FLAGS='-strict-concurrency=complete' build 2>&1 | grep "non-Sendable"
   ```
2. Categorize each warning by the type that needs Sendable
3. Apply conformance in dependency order (models first, then protocols, then classes)
4. Build iteratively
5. Run tests
6. Update `docs/swift6-migration-status.md`
7. Commit with message: `[CHORE] Swift 6 migration: add Sendable conformance (batch N)`

## Category: `delegates`

Add actor isolation to delegate patterns.

### Rules
- Delegate protocols used for UI callbacks → add `@MainActor` to protocol
- Delegate protocols used for data callbacks → evaluate case by case
- `weak var delegate` already implies reference semantics — adding `@MainActor` to the protocol is usually sufficient
- If the delegate is set from a different thread than it's called from → requires redesign

### Steps
1. Find all delegate patterns:
   ```bash
   grep -rn "weak var.*delegate" {{APP}}/ --include="*.swift"
   ```
2. For each delegate protocol:
   a. Find the protocol definition
   b. Add `@MainActor` if it's a UI-bound delegate
   c. Update conformers if needed
3. Build after every 10 changes
4. Run tests
5. Update `docs/swift6-migration-status.md`
6. Commit with message: `[CHORE] Swift 6 migration: add actor isolation to delegate patterns (batch N)`

## Post-Fix Steps (ALL categories)

After completing fixes for any category:

1. **Build verification:**
   ```bash
   xcodebuild -scheme {{APP}} -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' -quiet build
   ```
   Must pass with 0 errors.

2. **Test verification:**
   ```bash
   xcodebuild test -scheme {{APP}} -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' 2>&1 | tail -20
   ```
   Must pass with 0 failures.

3. **Format:**
   ```bash
   swiftformat <changed-files>
   ```

4. **Update tracking:**
   - Update counts in `docs/swift6-migration-status.md`
   - Add entry to Execution Log with: date, category, files changed, dev name, PR link

5. **Update Notion:**
   - Update the progress table in the [Swift 6 Migration Notion page]({{NOTION_SWIFT6_PAGE_URL}})

6. **Commit and PR:**
   - Branch: `chore/swift6-<category>-batch-<N>`
   - Commit: `[CHORE] Swift 6 migration: <description>`
   - PR base: `dev`
   - PR description: include before/after counts and files changed

## Execution Order

Run categories in this order for best results:

```
1. /swift6-fix config          ← Foundation (do this ONCE)
2. /swift6-fix mainactor       ← Highest impact, enables other fixes
3. /swift6-fix singletons      ← Small count, high risk
4. /swift6-fix dispatch-queue   ← Mechanical, large count (easier after mainactor)
5. /swift6-fix completion-handlers ← Mechanical, largest count
6. /swift6-fix sendable        ← Can be done last
7. /swift6-fix delegates       ← Often resolved by mainactor phase
```

## Notes

- Status file: `docs/swift6-migration-status.md`
- Analysis doc: [Notion — Swift 6 Migration]({{NOTION_SWIFT6_PAGE_URL}})
- Keep PRs under 600 lines when possible — use batches
- If a fix introduces too many cascading errors, revert and try a smaller batch
- Swift 6.2 `defaultIsolation: MainActor` may obsolete the mainactor phase — check before starting
