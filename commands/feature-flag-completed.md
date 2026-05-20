# Feature Flag Completion

Post-removal documentation for feature flag cleanup **$ARGUMENTS**.

This skill updates status.md, posts to Slack, and optionally updates Notion after a feature flag removal PR is merged.

**Note:** Run this skill AFTER updating `docs/feature-flags/status.md` with the removed flags.

## Usage

```
/feature-flag-completed [pr_number]
```

- `pr_number` - Optional PR number (defaults to current branch's PR)

## Steps

### 1. Gather Information

Get PR details using `gh pr view`:
- If PR number provided: `gh pr view <pr_number> --json number,title,url,body`
- If no PR number: `gh pr view --json number,title,url,body`

Extract the list of removed flags from the PR body (look for "Flags removed" table or list).

### 2. Read Current Status

Read `docs/feature-flags/status.md` and extract:
- Total removed count
- Total flags count
- Percentage
- In-Progress count
- Pending count

### 3. Post to Slack

Use `mcp__slack__conversations_add_message` to post to #flags-removal (ID: C0AST27EWTA):

```
:triangular_flag_on_post: Feature Flag Cleanup — Status Update
Progress: <removed> / <total> removed (<percentage>%)
In-Progress: <in_progress>
Pending: <pending>

Recently Removed:
- <flag_name_1> — #<pr_number> — <date>
- <flag_name_2> — #<pr_number> — <date>
...

:page_facing_up: Tracking: {{NOTION_FLAGS_TRACKER_URL}}
```

### 4. Update Notion (Optional)

If Notion MCP is available, for each removed flag:
- Search for the flag in the Notion database
- Update the page with:
  - `Code removal date` = today's date (YYYY-MM-DD)
  - `Owner` = git user name

### 5. Confirm to User

Output summary:
```
## Feature Flag Cleanup Complete

| Metric | Value |
|--------|-------|
| Flags removed | <count> |
| PR | #<pr_number> |
| Progress | <removed>/<total> (<percentage>%) |

### Flags Removed
- <flag_1>
- <flag_2>
...

### Actions
| Action | Status |
|--------|--------|
| status.md | Already updated |
| Slack posted | Message sent to #flags-removal |
| Notion | Updated / Not available |
```

## Error Handling

- **No PR found:** Prompt user to provide PR number explicitly
- **No flags found in PR body:** Ask user to list the flags manually
- **Slack error:** Show message for manual posting

## Notes

- This skill is meant to be run AFTER a flag removal PR is ready/merged
- The status.md should be updated as part of the removal PR itself
- Slack channel #flags-removal ID: C0AST27EWTA
- Part of Firebase Feature Flags Maintenance initiative
