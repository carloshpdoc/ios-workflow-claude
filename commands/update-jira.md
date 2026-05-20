# Update Jira Task

Update a Jira task with a summary of the fix implementation.

## Usage

```
/update-jira <task_id>
```

**Arguments:**
- `task_id` - The Jira task ID (e.g., PROD-4070, {{TICKET_PREFIX}}-XXXX)

**Examples:**
```
/update-jira PROD-4070
/update-jira {{TICKET_PREFIX}}-XXXX
```

## Instructions

When this skill is invoked:

1. **Parse the task ID** from `$ARGUMENTS`

2. **Gather context from the current session**:
   - Check git log for recent commits on current branch
   - Check for any open PRs from current branch using `gh pr view`
   - Identify changed files from commits

3. **Build the update comment** with:
   - **PR link** (if available)
   - **Problem summary** - What was the issue
   - **Solution summary** - How it was fixed
   - **Files changed** - List of modified files
   - **Result** - What the fix accomplishes

4. **Post comment to Jira**:
   - Use `mcp__claude_ai_Atlassian__addCommentToJiraIssue`
   - cloudId: `{{JIRA_HOST}}`
   - issueIdOrKey: the task ID
   - contentFormat: `markdown`

5. **Confirm success** with link to Jira task

## Comment Template

```markdown
## Fix Implemented

**PR:** <pr_url>

### Problem
<brief description of the issue>

### Solution
<what was changed and why>

### Files Changed
- <file1>
- <file2>

### Result
<what the fix accomplishes>
```

## Notes

- Extracts information from git history and PR details automatically
- Uses the current branch context to determine what was done
- Keep descriptions concise but informative
