# Feature Flag Removal

Remove the feature flag **$ARGUMENTS** following the investigation plan.

**Prerequisite:** Must have an investigation file at `docs/feature-flags/issues/$ARGUMENTS.md`. Run `/feature-flag-check $ARGUMENTS` first if it doesn't exist.

## Steps

### 1. Create Jira Task

Create a Jira task in the current sprint using `mcp__claude_ai_Atlassian__createJiraIssue`:
- **Project:** {{TICKET_PREFIX}}
- **Type:** Task
- **Summary:** `Remove feature flag: $ARGUMENTS`
- **Epic Link:** {{TICKET_PREFIX}}-EPIC (Firebase Flags Clean Up)
- **Assignee:** Current user (get from `git config user.email`)

Description template:
```markdown
## Objective

Remove the `$ARGUMENTS` feature flag as part of the Firebase Feature Flags Maintenance initiative.

## Investigation

<Summary from docs/feature-flags/issues/$ARGUMENTS.md>

## Complexity

<Low/Medium/High based on investigation>

## Related

- Epic: {{TICKET_PREFIX}}-EPIC (Firebase Flags Clean Up)
- Notion: {{NOTION_FLAGS_TRACKER_URL}}
```

Save the Jira ticket number (e.g., {{TICKET_PREFIX}}-XXXX) for later use in commit messages and PR title.

### 2. Create Branch

Create a feature branch for this removal:
```bash
git checkout dev
git pull origin dev
git checkout -b feature/remove-flag-$ARGUMENTS
```

### 3. Check for Conflicting PRs

**IMPORTANT:** Before modifying RemoteConfig files, check for open PRs that touch the same files:

```bash
gh pr list --state open --json number,title,files --jq '.[] | select(.files[]?.path | test("{{FLAG_KEY_ENUM}}|{{FLAG_DEFAULTS_FILE}}")) | "PR #\(.number): \(.title)"'
```

**If PRs are found:**
1. ⚠️ **STOP and warn the user** with the list of conflicting PRs
2. Recommend syncing with those developers before proceeding
3. Options:
   - Wait for the other PR to merge, then rebase
   - Coordinate with the other developer to avoid conflicts
   - Proceed only with explicit user confirmation

**Why this matters:** {{FLAG_KEY_FILE}} and {{FLAG_DEFAULTS_FILE}}.swift are shared files. Multiple PRs modifying them simultaneously will cause merge conflicts or overwrites.

### 4. Read the Investigation

Read `docs/feature-flags/issues/$ARGUMENTS.md` and understand:
- Files to delete
- Files to modify
- Tests to update
- The removal plan

**STOP if no investigation exists.** Run `/feature-flag-check` first.

### 5. Remove Flag Definition

Edit `{{APP}}/Helpers/RemoteConfig/{{FLAG_KEY_FILE}}`:
- Remove the case for this flag

Edit `{{APP}}/Helpers/RemoteConfig/{{FLAG_DEFAULTS_FILE}}.swift`:
- Remove the case from the switch statement

### 6. Delete Dead Code Files

For each file marked for deletion in the investigation:
- Delete the file entirely
- These are files that only exist for the feature being removed

### 6.1. V1/V2 Flow Removal (when applicable)

If the flag controls a V1/V2 flow with separate ViewControllers and components, follow this safety protocol:

#### A. Identify Entry Points

**V1 Entry Points (removal candidates):**
- Deep links V1 (e.g., `<deeplink-scheme>`)
- Universal Link Handlers V1
- Coordinators V1 and their navigation methods
- ViewControllers V1

**V2 Entry Points (NEVER remove):**
- Deep links V2 (e.g., `<v2-deeplink-scheme>`)
- Universal Link Handlers V2
- Coordinators V2 (e.g., `<FeatureA>Coordinator`, `<FeatureB>Coordinator`)

#### B. Map Module Dependencies

For each V1 module candidate for removal:

```bash
# Check if it's used by V2 code
grep -r "ModuleName" --include="*.swift" . | grep -v "V1ModulePath"
```

| Result | Action |
|--------|--------|
| References ONLY in V1 code | CAN remove |
| References in V2 code too | DO NOT remove - it's shared |

#### C. Safe Execution Order

1. **FIRST:** Remove references in coordinators/handlers
   - Edit ``<your-universal-link-router>.swift`` - remove V1 case
   - Edit ``<your-app-coordinator>+UniversalLinkContent.swift`` - remove V1 method
   - Remove V1 protocol conformances

2. **SECOND:** Intermediate build
   ```bash
   xcodebuild build -workspace {{APP}}.xcworkspace -scheme {{APP}}
   ```
   **STOP if it doesn't compile.** Fix before deleting files.

3. **THIRD:** Delete Universal Link Handler V1
   ```bash
   rm -rf {{APP}}/Coordinator/UniversalLink/Handlers/<V1Handler>/
   ```

4. **FOURTH:** Delete V1-only modules
   ```bash
   rm -rf {{APP}}/Modules/<V1Module>/
   ```

5. **FIFTH:** Final build + tests

#### D. V2 Verification Checklist

After removal, verify that V2 continues working:

- [ ] V2 deep link opens correctly
- [ ] Navigation from the consumer feature to V2 works
- [ ] Navigation from Explore to V2 works
- [ ] No V2 coordinator was impacted
- [ ] Build passes without errors
- [ ] Tests pass

#### E. Common Modules to Preserve

These modules are frequently shared between V1 and V2:
- `<design-system-module>/` - used by <FeatureA>, <FeatureB>
- Domain models (`GuideModel`, etc.)
- Repositories with GraphQL queries

**NEVER delete shared modules without explicit verification.**

### 7. Verify Code Usage Before Removal

**IMPORTANT:** Before deleting any file, class, or component, verify it's not used elsewhere:

```bash
# For each file/class/component to be removed, search for references
grep -r "ClassName" --include="*.swift" .
grep -r "import ModuleName" --include="*.swift" .
```

**If references are found outside the flag context:**
1. List all usages found
2. **PROMPT the user:** "The following code is used in other contexts. Confirm removal?"
   - Show each usage location
   - Wait for explicit confirmation before proceeding
3. If user declines, skip that specific removal and note it in the report

**Examples of what to check:**
- Classes/structs being removed → search for instantiations
- Protocols being removed → search for conformances
- Extensions being removed → search for method calls
- View components → search for usages in other Views
- Repository methods → search for calls from ViewModels

**Never remove code that is actively used without explicit user confirmation.**

### 8. Modify Affected Files

For each file marked for modification:
- Remove flag checks/conditionals
- Simplify code to always use the "permanent" path
- Remove unused imports
- Remove unused methods/properties

Common patterns:
```swift
// BEFORE
if remoteConfig.bool(for: .flagName) {
    doFeature()
}

// AFTER (if feature was always ON)
doFeature()

// AFTER (if feature was always OFF)
// Delete the entire block
```

### 9. Update/Delete Tests

For tests in the investigation:
- Delete test files for deleted features
- Update tests that mocked the flag
- Remove flag-related test cases

### 10. Build the Project

Run `xcodebuild build` and verify:
- Exit code 0
- No compilation errors
- No warnings related to the removed flag

Fix any issues before proceeding.

### 11. Run Tests

Run `xcodebuild test` and verify:
- All tests pass
- No test failures related to the removal

### 12. Generate Review Report

Create `docs/feature-flags/reports/$ARGUMENTS.md`:

```markdown
# Cleanup Review: $ARGUMENTS

> Generated: <date>
> Status: **PASSED/FAILED**

## Checklist

| Check | Status | Notes |
|-------|--------|-------|
| Flag removed from {{FLAG_KEY_ENUM}} | PASS/FAIL | |
| Flag removed from DefaultValueFactory | PASS/FAIL | |
| All code usages removed | PASS/FAIL | X usages removed |
| Dead code files deleted | PASS/FAIL | X files deleted |
| Conditionals simplified | PASS/FAIL | List files |
| Tests updated | PASS/FAIL | X test files |
| No orphan references | PASS/FAIL | |
| Build passes | PASS/FAIL | |
| Tests pass | PASS/FAIL | |

## Summary

### Files Deleted (<count>)
| File | Purpose |
|------|---------|
| ... | ... |

### Files Modified (<count>)
| File | Change |
|------|--------|
| ... | ... |

### Tests Changed
| Test File | Change |
|-----------|--------|
| ... | ... |

## Metrics

| Metric | Value |
|--------|-------|
| Files deleted | X |
| Files modified | X |
| Lines removed | ~X |
| Tests removed | X files |
| Tests modified | X files |

## Issues Found

<List any issues or None>

## V1/V2 Flow Analysis (if applicable)

| Check | Status |
|-------|--------|
| V1 entry points removed | PASS/FAIL |
| V2 entry points preserved | PASS/FAIL |
| V2 deep link tested | PASS/FAIL |
| Shared modules intact | PASS/FAIL |

### V1 Removed
- Deep link: `<path>`
- Handler: `<HandlerName>`
- Modules: `<list>`

### V2 Preserved
- Deep link: `<path>`
- Handler: `<HandlerName>`
- Coordinators: `<list>`

## Recommendation

**APPROVED/NEEDS FIXES** - <reason>
```

### 13. Update Status File

Update `docs/feature-flags/status.md`:
- Move flag from "In-Progress" to "Removed" (if not there)
- Add to "Recently Removed" table with PR link placeholder
- Update counts

### 14. Commit, Push, and Create PR

Stage all changes and create a commit:
```
[REFACTOR][{{TICKET_PREFIX}}-XXXX] Remove feature flag: $ARGUMENTS

- Remove flag from RemoteConfig
- Delete dead code (<X> files)
- Simplify conditionals in <X> files
- Update/remove tests

Lines removed: ~X
```

Push the branch:
```bash
git push -u origin feature/remove-flag-$ARGUMENTS
```

**Create the PR by invoking the `/create-pr` skill — DO NOT call `gh pr create` directly.**

The `/create-pr` skill enforces the {{APP}} PR template (`.github/pull_request_template.md`); calling `gh pr create` directly produces PRs out of team standards.

Inputs to pass into `/create-pr`:

- **Title:** `[REFACTOR][{{TICKET_PREFIX}}-XXXX] Remove feature flag: <name>`
  - TYPE must be `[REFACTOR]` (code removal / tech debt). Never use `[CHORE]` — it is not in the allowed TYPE list.
- **Label:** `report-tech-improvement`
- **Base:** `dev`
- **Body:** {{APP}} PR template, filled in from the investigation and review report:

  | Template section | Content to populate |
  |---|---|
  | Pull Request Checklist | Tick `I tested my code`, `The build was run locally`, and `Feature tested for accessibility` when applicable |
  | What is the current behavior? | Short paragraph describing the flag and the gated behavior (paraphrase from `docs/feature-flags/issues/$ARGUMENTS.md`) |
  | What is the new behavior? | The post-removal behavior — always-on, always-off, or dead-code-deleted |
  | Have any third-party libraries been added or changed? | `No` |
  | Does this change involve any AB testing? | `No — feature flag was already rolled out / dead` (or equivalent) |
  | Evidence | Screenshots/videos confirming the removed flow still works (request from user if not provided) |
  | Other information | Paste the Flag Details table; the Files Modified / Lines Removed metrics from the review report; and a link to `docs/feature-flags/reports/$ARGUMENTS.md` |

The review report at `docs/feature-flags/reports/$ARGUMENTS.md` remains a useful internal artifact (and is referenced by `/feature-flag-completed`), but **is not the PR body**.

## Notes

- Always build and test before committing
- If build fails, fix issues before proceeding
- **PR title TYPE must be `[REFACTOR]`** for flag removal — `[CHORE]` is not an allowed TYPE per team standards (allowed: BUILD, CI, DOCS, FEATURE, FIX, PERF, REFACTOR, STYLE, TEST)
- **PR creation goes through `/create-pr`**, never `gh pr create` directly — preserves the {{APP}} PR template
- Part of Firebase Feature Flags Maintenance initiative
- **Epic:** {{TICKET_PREFIX}}-EPIC (Firebase Flags Clean Up)
- **Notion:** {{NOTION_FLAGS_TRACKER_URL}}
