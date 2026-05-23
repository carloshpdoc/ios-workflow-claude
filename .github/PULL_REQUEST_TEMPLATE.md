<!--
Thanks for the PR! A few quick checks before you submit:

- For new commands / skills / agents: use {{PLACEHOLDER}} where company/project-specific
  values would otherwise be hardcoded. Add the placeholder to bootstrap.sh and README.
- For changes to bootstrap.sh: run a dry-run against each --ide (claude / cursor / kiro)
  before submitting — the smoke-test workflow runs this automatically on PR.
- Don't include real Jira IDs, Notion URLs, internal class names, or company-specific
  filenames in examples. Use generic placeholders or <descriptive-tags>.
-->

## What changed

<!-- One or two sentences. The "why" matters more than the "what". -->

## Type of change

- [ ] New command / skill / agent
- [ ] Bug fix in existing command / skill / agent
- [ ] bootstrap.sh change (CLI flag, substitution, --ide target)
- [ ] Documentation only
- [ ] Refactor / cleanup (no behavior change)

## Verification

How did you test this?

- [ ] `bootstrap.sh --dry-run --ide claude` works
- [ ] `bootstrap.sh --dry-run --ide cursor` works (if relevant)
- [ ] `bootstrap.sh --dry-run --ide kiro` works (if relevant)
- [ ] Invoked the changed command/skill in a real project
- [ ] N/A — docs / refactor only

## Placeholder hygiene (for new content)

- [ ] No real Jira IDs, Notion URLs, person names, internal class/module names
- [ ] New placeholders (if any) added to `bootstrap.sh` + `README.md` placeholder table
- [ ] Examples use `MyApp`, `PROJ`, `mycompany.atlassian.net`, etc.

## Related issues

<!-- Closes #N -->
