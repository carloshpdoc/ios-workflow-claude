# Feature Flag Cleanup Status

Show the current feature flag cleanup progress.

## Steps

### 1. Read the Tracking File

Read `docs/feature-flags/status.md` and parse the progress table.

### 2. Calculate Summary Statistics

Count flags by status:
- **Removed:** Successfully cleaned up
- **In-Progress:** Currently being worked on
- **Pending:** Not yet started

### 3. Show Progress

Display:

```
## Feature Flag Cleanup Progress

| Status      | Count | Percentage |
|-------------|-------|------------|
| Removed     | X     | X%         |
| In-Progress | X     | X%         |
| Pending     | X     | X%         |
| **Total**   | **X** | **100%**   |

Progress: [=========>..........] X%
```

### 4. Show In-Progress Flags

If any flags are in-progress, list them:

```
### Currently In-Progress
| Flag | Owner | Started |
|------|-------|---------|
| ...  | ...   | ...     |
```

### 5. Show Recently Removed

List the last 5 removed flags with their PR links:

```
### Recently Removed
| Flag | Date | PR | Lines Removed |
|------|------|----|---------------|
| ...  | ...  | ...| ...           |
```

### 6. Recommend Next Flags

Show the recommended next flags to remove from the status file:

```
### Recommended Next
| Flag | Recommendation | Complexity |
|------|----------------|------------|
| ...  | ...            | ...        |
```

## Notes

- Total flags are counted from `{{FLAG_KEY_FILE}}`
- Part of Firebase Feature Flags Maintenance initiative
- See investigation files in `docs/feature-flags/issues/`
- See review reports in `docs/feature-flags/reports/`
