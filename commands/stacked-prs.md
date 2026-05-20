---
name: stacked-prs
description: Create semantic commits split into stacked upstream PRs under 600 lines each
usage: /stacked-prs
---

# Stacked PRs Workflow

You are creating semantic commits and splitting them into stacked upstream PRs, each under 600 added lines.

## Task

Split uncommitted changes into multiple branches with semantic commits, where each branch is based on the previous one, creating a chain of PRs.

## Workflow

### Step 1: Analyze Changes

1. Run `git status` and `git diff --stat` to identify all changed/new files
2. Ask the user which files should be **excluded** from commits (e.g., unrelated docs, settings changes, storekit files)
3. Count lines per file: `wc -l <file>` for new files, `git diff --stat <file>` for modified files

### Step 2: Plan the Split

Group files into logical commits, each under 600 added lines:

**Suggested grouping order** (adapt to the actual changes):
1. **Models/DTOs** — domain models, response types, shared models
2. **Data layer** — repositories, data sources, mappers, queries, mock data
3. **Presentation** — view models, coordinators, factories, use cases, views
4. **Tests** — test mocks, unit tests (split further if over 600 lines)

Present the plan to the user with line counts per group before proceeding.

### Step 2.5: Select PR Label

Every PR must have exactly one report label. Select **once** for the entire chain (all PRs get the same label):

| Label | Use when |
|-------|----------|
| `report-feature` | New feature or functionality |
| `report-improvement-fix` | Bug fix or UX improvement (not a new feature) |
| `report-tech-improvement` | Tech debt, CI/CD, refactoring, code removal |
| `report-analytics-fix` | Analytics-related changes |

**Auto-inference from TYPE:**
- FEATURE → `report-feature`
- FIX → `report-improvement-fix`
- REFACTOR, BUILD, CI, PERF, STYLE, DOCS, TEST → `report-tech-improvement`

If ambiguous, ask the user.

### Step 3: Determine Branch Naming

- Use the current branch name as the base (e.g., `feature/{{TICKET_PREFIX}}-XXXX`)
- Subsequent branches append `-pt2`, `-pt3`, etc.
- Example: `feature/{{TICKET_PREFIX}}-XXXX`, `feature/{{TICKET_PREFIX}}-XXXX-pt2`, `feature/{{TICKET_PREFIX}}-XXXX-pt3`

### Step 4: Create Commits and PRs

For each group, sequentially:

1. **Create branch** (except for pt1 which uses the current branch):
   ```bash
   git checkout -b feature/{{TICKET_PREFIX}}-XXXX-ptN
   ```

2. **Stage specific files**:
   ```bash
   git add <file1> <file2> ...
   ```

3. **Commit with semantic message**:
   ```bash
   git commit -m "$(cat <<'EOF'
   <type>(<scope>): <description>

   <body explaining what and why>

   Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
   EOF
   )"
   ```
   Types: `feat`, `fix`, `test`, `refactor`, `docs`, `style`, `perf`, `ci`

4. **Push branch**:
   ```bash
   git push -u origin <branch-name>
   ```

5. **Create PR** using the {{APP}} template with `gh pr create`:
   - pt1 targets `dev` (or the main branch)
   - pt2+ targets the previous branch in the chain
   - Title format: `[TYPE][{{TICKET_PREFIX}}-XXXX] Description (ptN)`
   - Body includes the full PR template from `/create-pr`
   - Add `--label "<selected-label>"` using the label chosen in Step 2.5
   - Add "Stacked PR chain" section in "Other information" listing all parts

### Step 5: Summary

Print a table with all created PRs:

```
| PR | Branch | Base | Title | Lines |
|---|---|---|---|---|
| #XXXX | feature/{{TICKET_PREFIX}}-XXXX | dev | Description (pt1) | +NNN |
| #XXXX | feature/{{TICKET_PREFIX}}-XXXX-pt2 | feature/{{TICKET_PREFIX}}-XXXX | Description (pt2) | +NNN |
```

## PR Template

Use the same template as `/create-pr`:

```markdown
## Pull Request Checklist

- [x] I tested my code (for bug/feature)
- [ ] Documents have been revised and added/updated if necessary (for bug/feature fixes)
- [x] The build was run locally, and all changes were pushed
- [ ] Feature tested for accessibility

## What is the current behavior?

[Describe the current behavior or link to a relevant issue]

## What is the new behavior?

[Describe the behavior or changes being added by this PR]

## Have any third-party libraries been added or changed?

[Describe what the libraries are, or write "No"]

## Does this change involve any AB testing?

[If so, what is the experiment's name and the link to it in the console? If not, what is the justification for the absence?]

## Evidence

[Screenshots/videos of how the components/functionalities are changed or created]

## Other information

Stacked PR chain:
- **ptN (this PR)**: [description]
- ptN+1: [description]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Important Notes

- Each PR must be under 600 added lines
- Never include files the user asked to exclude
- Always use `--base` flag pointing to the previous branch in the chain (except pt1 which targets `dev`)
- Run `swiftformat` on all Swift files before committing
- Verify staged file counts with `git diff --cached --stat` before each commit
