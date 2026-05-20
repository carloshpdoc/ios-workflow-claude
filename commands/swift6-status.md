# Swift 6 Migration Status

Show the current Swift 6 migration progress across all blocker categories.

## Steps

### 1. Read the Tracking File

Read `docs/swift6-migration-status.md` and parse the progress table and config checklist.

### 2. Live Scan (Optional Verification)

Run a quick grep to verify counts against the actual codebase:

```bash
# Current @MainActor coverage on ViewModels
grep -r "@MainActor" {{APP}}/Modules --include="*ViewModel*.swift" -l | wc -l

# Remaining DispatchQueue.main.async calls
grep -r "DispatchQueue.main.async" {{APP}}/ --include="*.swift" -l | wc -l

# Remaining completion handlers
grep -r "completion:" {{APP}}/ --include="*.swift" -l | wc -l

# Singletons
grep -r "static let shared\|static var shared" {{APP}}/ --include="*.swift" | wc -l
```

Compare live counts against the tracking file. Flag discrepancies if any.

### 3. Show Config Status

Display the config checklist items with their current status (done/pending).

### 4. Show Progress Table

Display the progress table with a visual progress bar:

```
## Swift 6 Migration Progress

| Category | Total | Done | Remaining | Status |
|----------|-------|------|-----------|--------|
| ...      | ...   | ...  | ...       | ...    |

Overall Progress: [=========>..........] X%
```

### 5. Show Recent Activity

List the last 5 entries from the Execution Log:

```
### Recent Activity
| Date | Category | Files Changed | Dev | PR |
|------|----------|---------------|-----|----|
| ...  | ...      | ...           | ... | ...|
```

### 6. Recommend Next Fix

Based on the analysis priority order, recommend the next `/swift6-fix` to run:

Priority order:
1. Config changes (if not done)
2. `@MainActor` on ViewModels (highest impact, enables other fixes)
3. Mutable singletons (small count, high risk)
4. `DispatchQueue.main.async` (mechanical, large count)
5. Completion handlers (mechanical, largest count)
6. `@Sendable` annotations (can be done last)
7. Delegate patterns (often resolved by @MainActor)

```
### Recommended Next
Run: `/swift6-fix <type>` — <reason>
Estimated files: <count>
```

### 7. Show Known Blockers

Display the external dependency blockers table from the status file.

## Notes

- Status file: `docs/swift6-migration-status.md`
- Analysis doc: [Notion — Swift 6 Migration]({{NOTION_SWIFT6_PAGE_URL}})
- Always verify live counts against tracked counts
- When counts diverge significantly, update the status file
