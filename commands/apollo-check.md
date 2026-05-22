# Apollo Repository Investigation

Investigate the Apollo repository **$ARGUMENTS** and produce a detailed investigation for migration.

**Output:** This command creates an investigation file at `docs/apollo-removal/issues/$ARGUMENTS.md` that serves as the "issue" for this migration. The `/apollo-migrate` command will read this investigation before executing the fixed migration steps.

## Steps

### 1. Find All Related Files

Search for all files related to this repository:

```
Glob: **/$ARGUMENTS*
Glob: **/Network$ARGUMENTS*
Grep: "$ARGUMENTS" in *.swift files
```

Look specifically for:
- `.graphql` file (query definition) - usually in `{{APP}}/Repositories/<Name>/` or `{{APP}}/Modules/<Feature>/Repository/`
- `.graphql.swift` file (Apollo-generated types) - usually in `{{APP}}/Services/Apollo/API/`
- `Network*Repository.swift` (old implementation using Apollo)
- Any existing new-pattern files (`*GraphQLDataSource.swift`, `*Query.swift`, etc.)
- Fragment extension files (`*+Fragments.swift`)

### 2. Read the Implementation

Read the old `Network*Repository.swift` file to understand:
- What queries/mutations does it perform?
- What Apollo types does it use?
- What protocol does it conform to?
- What domain models does it return?
- What cache policies does it use?

Read the `.graphql` file to get the query string.

Read the `.graphql.swift` file to understand nullability of fields (`.nonNull` vs optional).

### 3. Find All Consumers

Search for all files that import or use this repository:

```
Grep: protocol name (e.g., "<Name>RepositoryProtocol" or "<Name>Repository")
Grep: class instantiation (e.g., "Network<Name>Repository(")
Grep: factory usage if exists
```

Check in:
- ViewModels (`*ViewModel.swift`)
- Managers (`*Manager.swift`)
- Coordinators (`*Coordinator.swift`)
- Factories (`*Factory.swift`)
- Other repositories that might depend on it

**For each consumer**, note:
- The file path
- How it instantiates the repository (inline GraphQLClient? Network.shared? factory?)
- Which methods it calls
- Whether it uses Apollo types directly (fragments, query data types)

### 4. Check for Feature Flags

Check if the repository's consumers are gated behind Firebase Remote Config flags or feature toggles that may indicate dead code:

```
Grep: RemoteConfig / remoteConfig / FeatureToggle in each consumer file
Grep: the consumer's class name in coordinator/factory files to trace the full call chain
```

For each consumer, trace the full instantiation chain back to the entry point (Coordinator → Factory → ViewModel → Repository). At any point in that chain, check if a feature flag controls whether the code path is reached.

**For each feature flag found**, document:
- The flag key (e.g., `is_<feature>_available`)
- Which `{{FLAG_KEY_ENUM}}` case it maps to
- What the default value is (check `{{FLAG_DEFAULTS_FILE}}`)
- Which code branch uses the repository (the `true` or `false` path)

> **Why this matters:** If a repository is only used behind a feature flag that has been permanently disabled, the entire repository + consumer chain may be dead code. The user can validate this in Firebase Remote Config before deciding to **delete** instead of **migrate**, saving the full migration effort.

### 5. Check for Shared Fragments

Search if this repository's `.graphql` file defines fragments used by other repositories:
```
Grep: fragment names from the .graphql file across all other .graphql files
```

If fragments are shared, note which repos depend on them — the `.graphql` file may need to be kept.

**IMPORTANT:** Also check the reverse: do OTHER `.graphql` files have queries that reference fragments defined in THIS repo's `.graphql` file? If so, deleting this `.graphql` will cause Apollo codegen to fail with "Unknown fragment". In the investigation, note whether the referencing query is dead after migration (can be removed from the other `.graphql` file) or still live (fragment must be kept or inlined).

### 6. Check if Already Partially Migrated

Look for signs of existing migration:
- `*GraphQLDataSource.swift` files
- `*Query.swift` files in Queries/ subfolder
- Usage of `GraphQLClientProtocol` instead of `Network.shared`
- Existing `MigrationModel` structs in SharedModels

### 7. Write the Plan File

Create the file `docs/apollo-removal/issues/$ARGUMENTS.md` using the Write tool with this structure:

```markdown
# Migration Plan: $ARGUMENTS

> Generated: <date>
> Status: planned

## Summary

- **Repository:** <full class name>
- **Location:** <path>
- **Tier:** <1-5>
- **Consumers:** <count>
- **Operation type:** query / mutation / mixed
- **Recommendation:** migrate / delete / already-done

## Current State

### Files
| File | Path | Purpose |
|------|------|---------|
| .graphql | <path> | Query definition |
| .graphql.swift | <path> | Apollo-generated types |
| Network impl | <path> | Old Apollo implementation |
| Fragment extensions | <path or N/A> | Apollo fragment helpers |

### Queries/Mutations
| Operation | Name | Variables | Cache Policy |
|-----------|------|-----------|--------------|
| query/mutation | <OperationName> | <list or none> | <policy> |

### Response Shape
<Describe the response structure based on .graphql.swift analysis, including nullability>

### Shared Fragments
| Fragment | Defined in | Used by |
|----------|-----------|---------|
| <name> | <this repo's .graphql> | <list of other repos> |

(or "None — .graphql can be safely deleted")

### Consumers
| # | File | Instantiation | Methods Used | Uses Apollo Types? |
|---|------|---------------|--------------|-------------------|
| 1 | <path> | <how> | <which methods> | yes/no |

### Feature Flags
| Flag Key | {{FLAG_KEY_ENUM}} | Default Value | Branch Using Repo | Status |
|----------|-----------------|---------------|-------------------|--------|
| <key or "None"> | <case name> | <true/false> | <true/false branch> | <active/disabled — check Firebase> |

> If any consumer is only reachable behind a permanently disabled feature flag, the recommendation should be **delete** instead of **migrate**. Flag the user to validate the flag state in Firebase Remote Config before proceeding.

## Migration Specifics

> The generic migration steps (create files → update consumers → delete → build → test → tracking) are defined in `CLAUDE.md` and `docs/apollo-migration-guide.md`. This section only covers what is SPECIFIC to this repository.

### Design Decisions
- **Domain models:** <Create new in repo / Reuse existing from SharedModels / etc.>
- **Response models:** <Where to create GraphQL response Codable structs>
- **Pattern:** <Full DataSource/Mapper/Factory or simplified (like DeleteAccount)>
- **Fragment handling:** <Keep .graphql for shared fragments / Delete / Inline>
- **PR splitting:** <Single PR / Multiple PRs (if >3 consumers)>

### Files to Create
- `<path>/Queries/<Name>Query.swift`
- `<path>/Models/<Name>GraphQLResponse.swift`
- `<path>/<Name>GraphQLDataSource.swift`
- `<path>/<Name>ResponseMapper.swift`
- `<path>/<Name>Repository.swift` (update or create)
- `<path>/<Name>RepositoryFactory.swift`

### Files to Modify (consumers)
- `<consumer1 path>` — Replace Network*Repository with factory
- `<consumer2 path>` — Replace Network*Repository with factory

### Files to Delete
- `<path to .graphql>` (or "KEEP — shared fragment")
- `<path to .graphql.swift>`
- `<path to old Network*Repository.swift>`
- `<path to *+Fragments.swift>` (if dead code)

### Tests to Write
- `{{APP_TESTS}}/.../Mocks/Mock<Name>Repository.swift`
- `{{APP_TESTS}}/.../<Name>RepositoryImplTests.swift`
- `{{APP_TESTS}}/.../<Name>ViewModelTests.swift` (for each consumer ViewModel)
- `{{APP_TESTS}}/.../<Name>ResponseMapperTests.swift` (if DataSource/Mapper pattern)

### Risks & Notes
- <Any special considerations, edge cases, or things to watch out for>
```

### 8. Show Summary to User

After writing the investigation file, display a concise summary in the terminal:
- Repository name, tier, consumer count
- Recommendation (migrate/delete)
- Key risks or special considerations
- Path to the investigation file
- Ask the user to review it before running `/apollo-migrate`

### 9. Update Tracking

Update `docs/apollo-migration-status.md` with consumer count and tier if not already set.

### 10. Self-Correction

If during investigation you discover that any instruction in `docs/apollo-migration-guide.md`, `.claude/commands/apollo-migrate.md`, or `.claude/CLAUDE.md` is missing, incorrect, or could cause a mistake, **update those files immediately**. Every lesson learned must be captured in the reference docs.
