# Create Pull Request

You are helping to create a pull request following the {{APP}} iOS team's standard template.

## Task

When the user asks to create a PR or open a pull request:

1. **Commit staged changes** (if not already committed)
2. **Push to remote** with `-u origin [branch-name]`
3. **Create PR using gh** with the template below

## PR Template

Use this exact template when creating the PR with `gh pr create`:

```markdown
## Pull Request Checklist

- [ ] I tested my code (for bug/feature)
- [ ] Documents have been revised and added/updated if necessary (for bug/feature fixes)
- [ ] The build was run locally, and all changes were pushed
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

[Any other important information to this PR]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## PR Title Format

Follow this pattern for the title:
```
[TYPE][{{TICKET_PREFIX}}-XXXX] Description
```

Where TYPE is one of: BUILD, CI, DOCS, FEATURE, FIX, PERF, REFACTOR, STYLE, TEST

## PR Label

Every PR must have exactly one report label. Select based on the nature of the change:

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

If the label is ambiguous (e.g., a FIX that is actually analytics), ask the user.

## Skip CI for Docs-Only PRs

When a PR **only** changes documentation files (`.claude/**`, `docs/**`, `*.md`, `.github/**`), add `[skip ci]` to the commit message to avoid wasting CI resources.

**How:** Include `[skip ci]` at the end of the first line or in the commit body:
```
[DOCS][{{TICKET_PREFIX}}-3271] Update create-tasks skill [skip ci]
```

**When NOT to skip:** If the PR touches ANY Swift, config, or build file — even alongside docs — do NOT add `[skip ci]`.

## Notes

- Always set `--base dev` when creating the PR
- Always add `--label "<label>"` to the `gh pr create` command using the selected report label
- Fill in all sections appropriately based on the changes
- Include evidence (screenshots/videos) when applicable
- Add the Claude Code footer at the end of the PR body
