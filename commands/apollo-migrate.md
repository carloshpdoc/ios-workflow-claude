# Apollo Repository Migration

Migrate the Apollo repository **$ARGUMENTS** to the new `GraphQLClientProtocol` pattern.

## Pre-Migration: Read the Investigation

**MANDATORY:** Before writing any code, read the investigation file:

```
docs/apollo-removal/issues/$ARGUMENTS.md
```

If the investigation file does NOT exist, tell the user to run `/apollo-check $ARGUMENTS` first and stop. Do not proceed without an investigation.

If the investigation file exists, read it completely. It contains:
- The design decisions already made (pattern, fragment handling, PR splitting)
- The exact files to create, modify, and delete
- The consumers to update
- The tests to write
- Any risks or special considerations

**Follow the investigation.** The migration steps are always the same (see CLAUDE.md). What changes per repo is the target files and consumers identified in the investigation. If you need to deviate from it, note the deviation and the reason — you will need to explain this in the report.

## Reference

Read `docs/apollo-migration-guide.md` for the full migration guide.

**Gold standard reference files (read before writing code):**
- `{{APP}}/Repositories/<ReferenceRepo>/Queries/<ReferenceRepo>Query.swift`
- `{{APP}}/Repositories/<ReferenceRepo>/<ReferenceRepo>GraphQLDataSource.swift`
- `{{APP}}/Repositories/<ReferenceRepo>/Models/<ReferenceRepo>GraphQLResponse.swift`
- `{{APP}}/Repositories/<ReferenceRepo>/<ReferenceRepo>ResponseMapper.swift`
- `{{APP}}/Repositories/<ReferenceRepo>/<ReferenceRepo>Repository.swift`
- `{{APP}}/Repositories/<ReferenceRepo>/<ReferenceRepo>RepositoryFactory.swift`

## Migration Steps

The steps are always the same (defined in CLAUDE.md). Use the investigation file for repo-specific details:

### Step 1: Gather Information

Read the source files listed in the investigation. Verify the investigation is still accurate (no files changed since it was written).

### Step 2: Create Query File

Create `Queries/<Name>Query.swift` in the repository directory:

```swift
enum <Name>Query {
    static let query = """
        <paste the exact query from the .graphql file>
    """

    static let operationName = "<OperationName>"
}
```

- Copy the query **exactly** from the `.graphql` file
- The operation name is the name after `query` or `mutation` keyword

### Step 3: Create GraphQL Response Models

Create `Models/<Name>GraphQLResponse.swift`:

- Define `Codable` structs matching the GraphQL response JSON structure
- Use `__typename` mapped via CodingKeys where needed
- Match the field names from the `.graphql` query
- Study the `.graphql.swift` generated types to understand the shape and nullability

### Step 4: Create GraphQL DataSource

Create `<Name>GraphQLDataSource.swift`:

- Define protocol `<Name>GraphQLDataSourceProtocol` with async throws methods
- Implement using `GraphQLClientProtocol` from `import Services`
- Use `InputEncodable` for query parameters
- Use `withCheckedThrowingContinuation` to bridge the callback-based client to async/await
- Include mock loading support (following <ReferenceRepo> pattern)

### Step 5: Create Response Mapper

Create `<Name>ResponseMapper.swift`:

- Define protocol `<Name>ResponseMapperProtocol`
- Map from `*GraphQLResponse` types to domain models
- Handle optional fields and type discriminators (`__typename`)
- Reuse existing domain models from `SharedModels` when they exist

### Step 6: Create/Update Repository

Create or update `<Name>Repository.swift`:

- Keep the existing protocol if consumers already depend on it
- If the protocol signature needs to change, update all consumers
- Implementation delegates to DataSource + Mapper
- Constructor takes `dataSource` and `mapper` parameters
- **MANDATORY: All completion handlers MUST dispatch to `DispatchQueue.main.async`**

```swift
// ✅ CORRECT pattern for repository methods
func fetchData(completion: @escaping (Model?) -> Void) {
    Task {
        do {
            let response = try await dataSource.fetch()
            let model = mapper.map(response)
            DispatchQueue.main.async { completion(model) }
        } catch {
            Log.error(message: error.localizedDescription)
            DispatchQueue.main.async { completion(nil) }
        }
    }
}
```

### Step 7: Create Factory

Create `<Name>RepositoryFactory.swift` following the standard pattern from `docs/apollo-migration-guide.md`.

### Step 8: Update Consumers

For each consumer listed in the investigation:

1. Replace `import Apollo` with `import Services` (if needed)
2. Replace `Network<Name>Repository()` with `<Name>RepositoryFactory.makeRepository()`
3. Remove any direct Apollo type usage (`<Query>.Data`, fragments, etc.)
4. Update method calls if the protocol signature changed
5. Verify the consumer still compiles

### Step 9: Delete Old Files

Remove the files listed in the investigation's "Files to Delete" section:
1. The `.graphql` file (unless it has shared fragments — check the plan)
2. The `.graphql.swift` file from `{{APP}}/Services/Apollo/API/`
3. The old `Network*Repository.swift` (only if fully replaced)
4. Any Apollo-specific extensions or helpers only used by this repo

### Step 10: Regenerate Project

**MANDATORY after adding or deleting files.** Run:
```bash
tuist generate --no-open
```

This regenerates `{{APP}}.xcodeproj/project.pbxproj` and removes orphaned references to deleted files. Skipping this step causes build failures ("file not found" errors for deleted files that are still referenced in the project).

### Step 11: Build and Verify

Build the project to verify compilation:

```bash
xcodebuild -workspace {{APP}}.xcworkspace -scheme {{APP}} -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' -quiet build 2>&1 | head -100
```

The build MUST succeed (exit code 0). Fix any errors before proceeding.

### Step 12: Write Unit Tests

**MANDATORY — NOT NEGOTIABLE.** Every migration MUST include unit tests. Do not skip this step.

Create the tests listed in the investigation's "Tests to Write" section. At minimum:

1. **Mock the repository protocol** (`Mock<Name>Repository.swift` in `Mocks/`)
2. **Repository implementation tests** (`<Name>RepositoryImplTests.swift`)
3. **ViewModel tests** (`<Name>ViewModelTests.swift`)
4. **ResponseMapper tests** (if DataSource/Mapper pattern is used)

Reference: `{{APP_TESTS}}/<ReferenceRepo>/Repositories/` and `{{APP_TESTS}}/Settings/DeleteAccount/`.

### Step 13: Run Tests

Regenerate the project if needed, then run tests:

```bash
xcodebuild test -workspace {{APP}}.xcworkspace -scheme {{APP}} -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' -only-testing:{{APP_TESTS}}/<TestClassName> 2>&1 | tail -50
```

Tests MUST pass with 0 failures. Fix any failures before proceeding.

### Step 14: Update Tracking

Update `docs/apollo-migration-status.md`:
- Set status to `done`
- Update consumer count
- Add notes about the migration

### Step 15: Update Investigation File Status

Update the investigation file `docs/apollo-removal/issues/$ARGUMENTS.md`:
- Change `Status: planned` to `Status: completed`

### Step 16: Self-Review

**Automatically run the self-review.** Follow the full process defined in `.claude/commands/apollo-review.md`:

1. Read the investigation file and compare it against what was actually done
2. Use `git diff` and `git status` to identify every changed file
3. Verify: no `import Apollo`, no `Network.shared`, no dead code, all consumers updated, all tests passing
4. Write the report to `docs/apollo-removal/reports/$ARGUMENTS.md`

If the review finds issues, fix them before proceeding. If everything passes, continue to Step 17.

### Step 17: Commit, Push, and Open PR

After the review passes, open a PR automatically:

1. **Commit** all changes (migration files + report) on the current branch
2. **Push** to remote with `-u` flag
3. **Open PR** using `gh pr create` with the report's "PR Description" section as the PR body

**PR title format:** `[FEATURE][{{TICKET_PREFIX}}-<number>]` where `<number>` is extracted from the current branch name (e.g., `feature/{{TICKET_PREFIX}}-XXXX` → `[FEATURE][{{TICKET_PREFIX}}-2854]`). Run `git branch --show-current` to get the branch name and extract the ticket number. Never use `[APOLLO]` or other prefixes.

Use this format:
```bash
gh pr create --title "[FEATURE][{{TICKET_PREFIX}}-<number>] Migrate $ARGUMENTS to GraphQLClientProtocol" --body "$(cat <<'EOF'
<Insert the "PR Description (copy-paste ready)" section from the report>

---

Full migration report: `docs/apollo-removal/reports/$ARGUMENTS.md`
Investigation: `docs/apollo-removal/issues/$ARGUMENTS.md`
EOF
)"
```

Tests MUST pass with 0 failures. Fix any failures before proceeding.

### Step 14: Update Tracking

Update `docs/apollo-migration-status.md`:
- Set status to `done`
- Update consumer count
- Add notes about the migration

### Step 15: Update Investigation File Status

Update the investigation file `docs/apollo-removal/issues/$ARGUMENTS.md`:
- Change `Status: planned` to `Status: completed`

### Step 16: Self-Review

**Automatically run the self-review.** Follow the full process defined in `.claude/commands/apollo-review.md`:

1. Read the investigation file and compare it against what was actually done
2. Use `git diff` and `git status` to identify every changed file
3. Verify: no `import Apollo`, no `Network.shared`, no dead code, all consumers updated, all tests passing
4. Write the report to `docs/apollo-removal/reports/$ARGUMENTS.md`

If the review finds issues, fix them before proceeding. If everything passes, continue to Step 17.

### Step 17: Commit, Push, and Open PR

After the review passes, open a PR automatically:

1. **Commit** all changes (migration files + report) on the current branch
2. **Push** to remote with `-u` flag
3. **Open PR** using `gh pr create` with the report's "PR Description" section as the PR body

**PR title format:** `[FEATURE][{{TICKET_PREFIX}}-<number>]` where `<number>` is extracted from the current branch name (e.g., `feature/{{TICKET_PREFIX}}-XXXX` → `[FEATURE][{{TICKET_PREFIX}}-2854]`). Run `git branch --show-current` to get the branch name and extract the ticket number. Never use `[APOLLO]` or other prefixes.

Use this format:
```bash
gh pr create --title "[FEATURE][{{TICKET_PREFIX}}-<number>] Migrate $ARGUMENTS to GraphQLClientProtocol" --body "$(cat <<'EOF'
<Insert the "PR Description (copy-paste ready)" section from the report>

---

Full migration report: `docs/apollo-removal/reports/$ARGUMENTS.md`
Investigation: `docs/apollo-removal/issues/$ARGUMENTS.md`
EOF
)"
```

The PR description should give reviewers a clear picture of:
- What was migrated and the pattern applied
- Files created, modified, and deleted
- Consumer updates (before → after)
- Test results
- Any deviations from the investigation and why

## Post-Migration Verification

Display the PR URL to the user when done.
- [ ] No `import Apollo` in any new files
- [ ] No `Network.shared` references in new files
- [ ] Old `.graphql` file deleted
- [ ] Old `.graphql.swift` file deleted
- [ ] Old Apollo implementation deleted
- [ ] All consumers updated to use factory
- [ ] Build succeeds
- [ ] Unit tests written and passing
- [ ] Tracking file updated

## Self-Correction

If during migration you discover that any instruction in `docs/apollo-migration-guide.md`, this file, or `.claude/CLAUDE.md` is missing, incorrect, or could cause a mistake in future migrations, **update those files immediately**. Every lesson learned must be captured in the reference docs so the same mistake is never repeated.
