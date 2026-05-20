# Apollo Migration Self-Review

Review the completed migration for **$ARGUMENTS** against the original investigation and produce a detailed report.

**This command can be used in two ways:**
1. **Automatic** — `/apollo-migrate` calls it at the end of every migration (Step 16)
2. **Manual** — Run `/apollo-review <RepoName>` independently to review a migration at any time

**Output:** This command creates a report file at `docs/apollo-removal/reports/$ARGUMENTS.md`. When called by `/apollo-migrate`, the report's PR description section is used as the body of the automatically opened PR.

## Steps

### 1. Read the Investigation

Read the investigation file:
```
docs/apollo-removal/issues/$ARGUMENTS.md
```

If the investigation file does not exist, inform the user and stop.

### 2. Read All Changed Files

Use `git diff` and `git status` to identify every file that was changed, created, or deleted as part of this migration.

For each file, read its current content to understand what was done.

### 3. Compare Investigation vs. Execution

Go through every item in the investigation and verify:

- [ ] Was each "File to Create" actually created?
- [ ] Was each "File to Modify" actually modified?
- [ ] Was each "File to Delete" actually deleted?
- [ ] Were all consumers updated?
- [ ] Were all tests written?
- [ ] Does the build succeed?
- [ ] Do all tests pass?

### 4. Check for Regressions

Verify:
- No `import Apollo` in any new or modified files
- No `Network.shared` references in new files
- No Apollo types leaked into consumers (fragments, query data types)
- No dead code left behind
- Factory pattern used correctly
- Cache policies preserved from original implementation
- **Threading**: All completion handlers dispatch to `DispatchQueue.main.async`

### 5. Run Full Test Suite (if not recently run)

If tests haven't been run since the last change:
```bash
xcodebuild test -workspace {{APP}}.xcworkspace -scheme {{APP}} -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' -only-testing:{{APP_TESTS}}/<RelevantTestClasses> 2>&1 | tail -50
```

### 6. Write the Report

Create the file `docs/apollo-removal/reports/$ARGUMENTS.md` using the Write tool:

```markdown
# Migration Report: $ARGUMENTS

> Generated: <date>
> Investigation: docs/apollo-removal/issues/$ARGUMENTS.md
> Status: completed

## Summary

| Item | Value |
|------|-------|
| Repository | <full class name> |
| Tier | <1-5> |
| Consumers updated | <count> |
| Files created | <count> |
| Files modified | <count> |
| Files deleted | <count> |
| Tests written | <count> |
| Tests passing | <count>/<count> |
| Build status | pass/fail |

## What Was Done

### Files Created
| File | Purpose |
|------|---------|
| `<path>` | <brief description of what this file does> |

### Files Modified
| File | What Changed | Why |
|------|-------------|-----|
| `<path>` | <description of changes> | <reason> |

### Files Deleted
| File | Why |
|------|-----|
| `<path>` | <reason - e.g., "Old Apollo implementation, fully replaced"> |

### Consumer Updates
| Consumer | Before | After |
|----------|--------|-------|
| `<path>` | `NetworkXxxRepository(provider: Network.shared.client)` | `XxxRepositoryFactory.makeRepository()` |

## Design Decisions

<List any non-obvious decisions made during migration and why>

- **Decision:** <what>
  - **Reason:** <why>
  - **Alternative considered:** <what else was considered>

## Deviations from Investigation

<List any deviations from the original investigation in docs/apollo-removal/issues/$ARGUMENTS.md>

| Planned | Actual | Reason |
|---------|--------|--------|
| <what the plan said> | <what was actually done> | <why> |

(or "None — investigation was followed exactly")

## Issues Encountered

<List any problems found during migration and how they were resolved>

| Issue | Resolution |
|-------|-----------|
| <description> | <how it was fixed> |

(or "None")

## Tests

### Test Files Created
| File | Tests | Status |
|------|-------|--------|
| `<path>` | <count> | all passing |

### Test Coverage Summary
- Repository impl: <what's covered>
- ViewModel: <what's covered>
- Mapper: <what's covered>

## Verification Checklist

- [ ] No `import Apollo` in new files
- [ ] No `Network.shared` references in new files
- [ ] Old `.graphql` file handled (deleted or kept with reason)
- [ ] Old `.graphql.swift` file deleted
- [ ] Old Apollo implementation deleted
- [ ] All consumers updated to use factory
- [ ] **Threading**: All completion handlers dispatch to `DispatchQueue.main.async`
- [ ] Build succeeds (exit code 0)
- [ ] All unit tests written and passing
- [ ] `docs/apollo-migration-status.md` updated
- [ ] Investigation file status updated to completed

## PR Description (copy-paste ready)

<A concise summary suitable for a PR description, including:>
- What was migrated
- Pattern applied
- Key decisions
- Files affected count
- Test results
```

### 7. Show Summary to User

After writing the report, display:
- Path to the report file
- Any issues or deviations found
- Whether the migration is ready for PR
- Suggest: "You can use the report content for the PR description, or link to it from the PR"

### 8. Self-Correction

If during review you discover any issue that should have been caught by the investigation or the migration process, **update the relevant instruction files** (`docs/apollo-migration-guide.md`, `.claude/commands/apollo-check.md`, `.claude/commands/apollo-migrate.md`, `.claude/CLAUDE.md`) so the same issue is prevented in future migrations.
