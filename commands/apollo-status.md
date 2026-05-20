# Apollo Migration Status

Show the current Apollo removal migration progress.

## Steps

### 1. Read the Tracking File

Read `docs/apollo-migration-status.md` and parse the migration table.

### 2. Calculate Summary Statistics

Count repositories by status:
- **Done:** Fully migrated to GraphQLClientProtocol
- **Deleted:** Removed (no longer needed)
- **In-Progress:** Currently being worked on
- **Todo:** Not yet started
- **Not-Needed:** Already uses non-Apollo pattern or not a repository

### 3. Show Progress

Display:

```
## Apollo Migration Progress

| Status      | Count | Percentage |
|-------------|-------|------------|
| Done        | X     | X%         |
| Deleted     | X     | X%         |
| In-Progress | X     | X%         |
| Todo        | X     | X%         |
| Not-Needed  | X     | X%         |
| **Total**   | **X** | **100%**   |

Progress bar: [=========>..........] X%
```

### 4. Show In-Progress Repos

If any repos are in-progress, list them with their owner:

```
### Currently In-Progress
| Repository | Owner | Tier |
|------------|-------|------|
| ...        | ...   | ...  |
```

### 5. Recommend Next Repos

Suggest the next 5 repositories to tackle, prioritizing:
1. **Tier 1** (simplest) first
2. Fewer consumers = easier migration
3. Repos in `{{APP}}/Repositories/` before `{{APP}}/Modules/` (more standardized)

```
### Recommended Next
| Repository | Tier | Consumers | Location |
|------------|------|-----------|----------|
| ...        | ...  | ...       | ...      |
```

### 6. Show Recently Completed

List the last 5 completed migrations with their PR links (if available).
