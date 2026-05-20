# Create Pull Request

Create a pull request for the current branch following the the team's standard PR template.

**$ARGUMENTS** (optional): space-separated options. All are optional and can be combined in any order.

| Argument | Description | Default |
|----------|-------------|---------|
| `--base <branch>` | Base branch for the PR | `dev` |
| `--draft` | Create as draft PR | off |
| `--reviewer <user>` | Add reviewer(s). Can repeat: `--reviewer user1 --reviewer user2` | none |
| `--label <name>` | Add label(s). Can repeat: `--label bug --label urgent` | none |

For convenience, a bare value (no `--` prefix) is treated as `--base <value>`.

**Examples:**
- `/open-pr` - PR to `dev`
- `/open-pr main` - PR to `main` (shorthand for `--base main`)
- `/open-pr --base feature/{{TICKET_PREFIX}}-XXXX-some-feature` - PR to another feature branch
- `/open-pr --draft` - Draft PR to `dev`
- `/open-pr --base feature/{{TICKET_PREFIX}}-XXXX --draft --reviewer jvlcapi` - Draft PR to a feature branch with reviewer
- `/open-pr --label bug --reviewer jvlcapi --reviewer other-dev` - PR to `dev` with label and two reviewers

## Steps

### 1. Parse Arguments

Parse `$ARGUMENTS` to extract:
- **--base <branch>**: the target base branch, or `dev` if not provided. A bare value (no `--` prefix) is also treated as the base branch for convenience (e.g., `main` is equivalent to `--base main`)
- **--draft**: if present, add `--draft` flag to `gh pr create`
- **--reviewer <user>**: collect all `--reviewer` values, add each as `--reviewer <user>` to `gh pr create`
- **--label <name>**: collect all `--label` values, add each as `--label <name>` to `gh pr create`

### 2. Gather Branch Context

Run these in parallel:

```bash
# Current branch name
git rev-parse --abbrev-ref HEAD

# Check if branch has a remote tracking branch
git status -sb

# Untracked and staged files
git status

# Staged + unstaged diff
git diff HEAD
```

### 3. Determine Base Branch

Use the parsed base branch from $ARGUMENTS, or default to `dev`.

### 4. Analyze All Changes

Run these in parallel:

```bash
# Full diff between base and HEAD
git diff <base>...HEAD

# Commit log since diverging from base
git log <base>..HEAD --oneline --no-decorate

# Files changed
git diff <base>...HEAD --stat
```

### 5. Extract Jira Ticket from Branch Name

Parse the branch name to find the Jira ticket. Expected patterns:
- `feature/{{TICKET_PREFIX}}-XXXX-description` -> `{{TICKET_PREFIX}}-XXXX`
- `fix/{{TICKET_PREFIX}}-XXXX-description` -> `{{TICKET_PREFIX}}-XXXX`
- `refactor/{{TICKET_PREFIX}}-XXXX-description` -> `{{TICKET_PREFIX}}-XXXX`

If no ticket is found, ask the user.

### 6. Determine PR Type

Infer the PR type from the branch prefix and the nature of changes:

| Branch prefix | Default type |
|---------------|-------------|
| `feature/`    | FEATURE     |
| `fix/`        | FIX         |
| `refactor/`   | REFACTOR    |
| `test/`       | TEST        |
| `docs/`       | DOCS        |
| `ci/`         | CI          |
| `build/`      | BUILD       |
| `perf/`       | PERF        |
| `style/`      | STYLE       |

If the prefix is ambiguous, infer from the diff content.

### 7. Generate PR Title

Format: `[TYPE][{{TICKET_PREFIX}}-XXXX] Short description`

Generate a concise description (under 60 chars) summarizing the changes from the diff and commit messages.

### 8. Generate PR Body

Analyze the diff and commits to fill in each section of the template. Be specific and accurate.

- **Pull Request Checklist**: Leave unchecked (the author will check manually)
- **What is the current behavior?**: Describe what the code did before these changes
- **What is the new behavior?**: Describe what the changes introduce, referencing specific files/modules
- **Have any third-party libraries been added or changed?**: Check if `Package.swift`, `Podfile`, `Tuist/Dependencies`, or dependency files were modified. If none, write "No"
- **Does this change involve any AB testing?**: Check if any feature flag / experiment files were touched. If none, write "No"
- **Evidence**: see step 9 (auto-embed if screenshots exist) — only fall back to "N/A - To be added by the author" if no folder exists AND the user declines to capture them.
- **Other information**: Include any extra context worth mentioning (migration notes, follow-up tasks, etc.)

### 9. Embed Evidence Screenshots

Before pushing, attach evidence automatically — do not leave the user to drag-drop in the browser.

1. Look for screenshots in this order:
   - `~/Desktop/{{TICKET_PREFIX}}-XXXX-evidence/` (the smoke-test convention) — if present, use every `.jpg`/`.png` inside.
   - If absent, ask the user to point at the screenshots OR offer to capture them via the simulator (`xcodebuildmcp` / `ios-debugger-agent`).
2. Copy them into the repo and commit on a separate commit so the code commit stays focused:
   ```bash
   mkdir -p .github/screenshots/{{TICKET_PREFIX}}-XXXX
   cp ~/Desktop/{{TICKET_PREFIX}}-XXXX-evidence/*.{jpg,png} .github/screenshots/{{TICKET_PREFIX}}-XXXX/ 2>/dev/null
   git add .github/screenshots/{{TICKET_PREFIX}}-XXXX/
   git commit -m "[<TYPE>][{{TICKET_PREFIX}}-XXXX] Add PR evidence screenshots"
   ```
3. Reference each image in the PR body with a one-line caption above and an `<img>` tag pointing at the GitHub raw URL on the same branch (works in private repos for authenticated reviewers):
   ```html
   <img src="https://github.com/{{GITHUB_OWNER}}/{{PROJECT_DIR}}/raw/<branch>/.github/screenshots/{{TICKET_PREFIX}}-XXXX/01-foo.jpg" width="320" alt="short description" />
   ```
4. In the "Other information" section add: *"Screenshots committed under `.github/screenshots/{{TICKET_PREFIX}}-XXXX/` — happy to remove after merge if the team prefers."*

### 10. Push and Create PR

```bash
# Push the branch to remote (if not already pushed or behind)
git push -u origin <branch-name>

# Create the PR — always pass --assignee @me, the report label and one or more type labels
gh pr create --base <base-branch> \
  --title "<title>" \
  --body "$(cat <<'EOF'
<generated body>
EOF
)" \
  --assignee @me \
  --label "<report-label>" \
  --label "<type-label>" \
  [--draft] \
  [--reviewer <user1> --reviewer <user2>] \
  [--label <extra-label>]
```

- `--assignee @me` is gh CLI shorthand for the authenticated user — always include it.
- The mandatory **report label** is selected from change type:
  | Label | Use when |
  |-------|----------|
  | `report-feature` | New feature or functionality |
  | `report-improvement-fix` | Bug fix or UX improvement (not a new feature) |
  | `report-tech-improvement` | Tech debt, CI/CD, refactoring, code removal |
  | `report-analytics-fix` | Analytics-related changes |

  Auto-inference from TYPE: FEATURE→`report-feature`, FIX→`report-improvement-fix`, REFACTOR/BUILD/CI/PERF/STYLE/DOCS/TEST→`report-tech-improvement`. If a `[FEATURE]` is purely UX with no new functionality, prefer `report-improvement-fix`.
- Add at least one **type label** matching the title prefix and the actual nature of the change (`feature`, `fix`, `refactor`, `perf`, `build`, `ci`, `docs`, `style`, `test`). Combine when multiple fit (a refactor that also improves UX gets `refactor` + `feature`/`fix`).
- Include any extra `--reviewer` / `--label` / `--draft` flags from `$ARGUMENTS`.

### 11. Move Jira card to "In Review"

After the PR opens, transition the Jira card automatically.

1. Pick the Jira MCP available in the session:
   - `mcp__claude_ai_Atlassian__*` (OAuth via Claude.ai connector — preferred when the local jira MCP is authenticated as a different user).
   - `mcp__jira__*` (basic auth) — only use if `jira_auth_status` returns the same email as `gh api user --jq .email`.
2. Look up transitions: `getTransitionsForJiraIssue` (claude.ai) or `jira_get_transitions` (local) with `issueIdOrKey: "{{TICKET_PREFIX}}-XXXX"`.
3. Match by name (case-insensitive) in this priority order: `In Review`, `Em Revisão`, `Em análise`, `Code Review`, `Review`. (For the {{APP}} project the actual transition name is `IN REVIEW` → status `Em análise`.) If none match, surface the available transitions and ask the user.
4. Apply with `transitionJiraIssue` (claude.ai) or `jira_transition_issue` (local).
5. Verify by re-fetching the issue and report the new status.

If no Jira MCP is available, surface that and give the user the issue URL with a one-line "please move manually" note.

### 12. Output Final Summary

Print:
- PR URL.
- Labels applied.
- Screenshots attached (count) — or "none" if the user declined.
- Jira card status after transition (or "not transitioned: <reason>").

## PR Body Template

Use this exact structure for the body:

```markdown
## Pull Request Checklist

- [ ] I tested my code (for bug/feature)
- [ ] Documents have been revised and added/updated if necessary (for bug/feature fixes)
- [ ] The build was run locally, and all changes were pushed
- [ ] Feature tested for accessibility

## What is the current behavior?

<describe based on diff analysis>

## What is the new behavior?

<describe based on diff analysis>

## Have any third-party libraries been added or changed?

<No, or describe>

## Does this change involve any AB testing?

<No, or describe>

## Evidence

N/A - To be added by the author

## Other information

<any extra context, or "None">
```

## Important Rules

- Always use `--base dev` unless the user specifies a different base via $ARGUMENTS
- Never fabricate changes that are not in the diff
- Keep descriptions factual and based on the actual code changes
- Do NOT ask the user to fill in sections you can infer from the diff
- Do NOT push to the remote without first checking if there are uncommitted changes. If there are, ask the user whether to commit them first
