# Code Review PR

Review the pull request **$ARGUMENTS** and post inline comments using the authenticated GitHub user.

**$ARGUMENTS** can be a branch name (e.g., `feature/{{TICKET_PREFIX}}-XXXX`) or a PR number (e.g., `4012`).

## Tone & Style

- **Informal and friendly.** Use casual greetings like "Hey, dev!", "Yo dev,", "Nice one, dev!", etc.
- Always address the PR author as **"dev"** (since they are the one who opened the PR).
- Keep it light — you're a teammate, not an auditor.
- Examples of good tone:
  - "Hey dev, this looks solid! Just a small thing here..."
  - "Yo dev, heads up — this might bite us later because..."
  - "Nice work, dev! One suggestion though..."
  - "Hey dev, nothing blocking here, just a thought..."

## Steps

### 1. Find the PR

If `$ARGUMENTS` is a number, use it directly. If it's a branch name, find the PR:

```bash
gh pr list --head $ARGUMENTS --json number,title,url --jq '.[0]'
```

If no PR is found, inform the user and stop.

### 2. Gather PR Context

Run these in parallel:

```bash
# PR metadata
gh pr view <number> --json title,body,state,reviewDecision,reviews,additions,deletions,changedFiles,baseRefName,headRefName

# Full diff
gh pr diff <number>

# Existing inline comments (avoid duplicating)
gh api repos/{owner}/{repo}/pulls/<number>/comments --jq '.[] | {path, line, body, user: .user.login}'

# Existing reviews
gh api repos/{owner}/{repo}/pulls/<number>/reviews --jq '.[] | {state, body, user: .user.login}'
```

### 3. Analyze the Diff

Review the diff looking for these categories of issues:

**Blocking (must fix before merge):**
- Security vulnerabilities (OWASP top 10)
- Crashes or force unwraps without safety
- Data loss or race conditions
- Broken functionality

**Non-blocking (suggestions, nice-to-haves):**
- Template & process (pre-checked boxes, missing description sections)
- Hardcoded values that could be constants
- DRY violations
- Missing `weak self` in closures
- Inconsistent patterns vs. the rest of the codebase
- Missing accessibility modifiers
- Minor code quality improvements

### 4. Prepare Review Comments

For each issue found, prepare an inline comment with:
- **path**: the file path relative to the repo root
- **line**: the line number in the diff (new file side)
- **body**: casual, friendly description addressing "dev". Use suggestion blocks when proposing fixes.

Use GitHub suggestion blocks when proposing concrete fixes:
````
```suggestion
corrected code here
```
````

### 5. Post the Review

Post all comments as a single review using the GitHub API:

```bash
gh api repos/{owner}/{repo}/pulls/<number>/reviews \
  -X POST \
  --input - <<'EOF'
{
  "event": "<EVENT>",
  "body": "<BODY>",
  "comments": [
    {
      "path": "file.swift",
      "line": 42,
      "body": "Hey dev, ..."
    }
  ]
}
EOF
```

**Important:** Use `--input -` with a heredoc for the JSON body. Do NOT use `--field` for the comments array.

### 6. Decide: Approve or Request Changes

**Auto-approve** the PR if there are **no blocking issues**, even if inline comments were posted. Non-blocking suggestions are not a reason to hold the PR.

- **No issues at all:** Approve with a friendly message like "Hey dev, LGTM! Clean and ready to ship."
- **Only non-blocking comments:** Approve with something like "Hey dev, looks good! Left a few suggestions but nothing blocking. Ship it!"
- **Blocking issues found:** Request changes with a message like "Hey dev, almost there! Just a couple of things we need to fix before merging."

Use:
```bash
# Approve
gh pr review <number> --approve --body "message"

# Request changes (only for blocking issues)
gh pr review <number> --request-changes --body "message"
```

Do NOT ask the user what action to take. Decide automatically based on the severity of findings.

## Guidelines

- Be constructive, not nitpicky. Focus on issues that matter.
- Don't comment on style preferences unless they violate project conventions.
- If the diff is clean, say so — don't invent problems.
- If there are existing inline comments from others, read them to avoid duplicating feedback.
- Group related issues into a single comment when they affect the same line.
- Keep comment bodies concise. One issue per comment unless tightly related.
