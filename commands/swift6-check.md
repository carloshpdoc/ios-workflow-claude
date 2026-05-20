# Swift 6 Concurrency Check

Analyze the current Swift 6 strict concurrency readiness. This is a dry-run — no code is modified.

If `$ARGUMENTS` is provided, scope the check to that category only (e.g., `mainactor`, `singletons`, `dispatch-queue`, `completion-handlers`, `sendable`, `delegates`).
If no argument, run a full scan.

## Steps

### 1. Read Current Status

Read `docs/swift6-migration-status.md` to understand what has already been migrated.

### 2. Run Category Scans

For each category (or the specified one), run targeted searches:

#### @MainActor on ViewModels
```bash
# ViewModels WITHOUT @MainActor
grep -rl "class.*ViewModel.*ObservableObject" {{APP}}/ --include="*.swift" | while read f; do
  grep -L "@MainActor" "$f"
done
```
Report: total ViewModels, annotated count, remaining count, list of unannotated files.

#### DispatchQueue.main.async
```bash
grep -rn "DispatchQueue\.main\.async" {{APP}}/ --include="*.swift"
```
Report: total occurrences, files affected, top 10 files by count.

#### Completion Handlers
```bash
grep -rn "completion:.*@escaping" {{APP}}/ --include="*.swift"
```
Report: total occurrences, files affected, top 10 files by count.

#### Mutable Singletons
```bash
grep -rn "static var shared\|static let shared" {{APP}}/ --include="*.swift"
```
For each singleton, check if it has `@MainActor`, actor isolation, or lock synchronization.
Report: total singletons, protected count, unprotected count, list with file paths.

#### @Sendable Coverage
```bash
# Classes without @Sendable or Sendable conformance
grep -rn "^class \|^final class \|^public class \|^public final class " {{APP}}/ --include="*.swift" | grep -v "@Sendable\|: Sendable"
```
Report: total classes, Sendable count, remaining count.

#### Delegate Patterns
```bash
grep -rn "weak var.*delegate" {{APP}}/ --include="*.swift"
```
Report: total delegates, files affected.

### 3. Build with Strict Concurrency (Optional)

If the user requests it or if config checklist shows `targeted` is enabled:
```bash
xcodebuild -scheme {{APP}} -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' \
  OTHER_SWIFT_FLAGS='-strict-concurrency=complete' \
  -quiet build 2>&1 | grep -c "warning:"
```
Report total warnings count.

### 4. Generate Report

Output a summary table:

```
## Swift 6 Readiness Report

| Category | Total | Done | Remaining | Priority |
|----------|-------|------|-----------|----------|
| @MainActor ViewModels | X | X | X | HIGH |
| DispatchQueue.main.async | X | X | X | HIGH |
| Completion handlers | X | X | X | HIGH |
| Mutable singletons | X | X | X | CRITICAL |
| @Sendable classes | X | X | X | MEDIUM |
| Delegate patterns | X | X | X | LOW |

Recommended next: /swift6-fix <type>
```

### 5. Update Status File If Counts Changed

If live counts differ from `docs/swift6-migration-status.md`, update the file with accurate numbers.

## Notes

- This is a READ-ONLY operation — no source code is modified
- Run this before starting any `/swift6-fix` session to get current state
- Run this after a `/swift6-fix` session to verify progress
- Large modules (your app target) may take longer to scan
