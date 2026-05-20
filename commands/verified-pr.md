---
description: >
  Open a PR only after a full local build + test pass. When the project's PR CI does not run unit tests,
  so this skill enforces the gate locally before handing off to /create-pr. Use whenever the user
  asks to open, create, push, or ship a PR — including phrases like "open a PR", "make a PR",
  "ship it", "create the pull request", or after a feature/fix is implemented and ready to send out.
  Prefer this skill over calling /create-pr directly.
---

# Verified PR

Wraps `/create-pr` with a mandatory local build + test gate. PR CI currently runs lint and build only — unit test failures slip into `dev` if we do not catch them locally. This skill closes that gap by refusing to open a PR until both gates pass.

## When to Use

Invoke this skill any time the user is ready to open a PR:

- "open a PR", "create a PR", "make a PR", "send the PR"
- "ship it", "let's ship this", "ready to ship"
- After implementing a feature/fix when the natural next step is a PR

Do **not** invoke this for drafts that explicitly skip CI/tests — defer to `/create-pr` directly if the user passes `--skip-tests` or says "skip tests, just open the PR".

## Gates (in order)

The PR is **only** created when every gate below passes. Stop immediately on the first failure — do not proceed, do not "try anyway", do not open a draft.

### Gate 1 — Build

Run the build command with a 5-minute timeout:

```bash
timeout 300 xcodebuild -workspace {{APP}}.xcworkspace -scheme {{APP}} -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' build 2>&1 | grep -E "^/.* error:|BUILD SUCCEEDED|BUILD FAILED" | tail -30
```

Pass criterion: the output ends with `** BUILD SUCCEEDED **` and no `error:` lines from the project's source paths.

On failure:
1. Surface the exact compiler errors (file paths + messages) from the output.
2. STOP. Do not run Gate 2. Do not create the PR.
3. Tell the user the build failed and wait for them to either fix it or hand it back.

**Simulator issues:** If the build fails due to simulator unavailability or timeout, retry once with a fresh simulator boot:
```bash
xcrun simctl shutdown all && xcrun simctl boot "iPhone 11"
```

### Gate 2 — Tests

Run tests with parallel testing enabled for faster feedback (8-minute timeout):

```bash
timeout 480 xcodebuild test -workspace {{APP}}.xcworkspace -scheme {{APP}} -destination 'platform=iOS Simulator,name=iPhone 11,OS=latest' -parallel-testing-enabled YES -only-testing:{{APP_TESTS}} 2>&1 | grep -E "^/.* error:|Test Case.*passed|Test Case.*failed|Executed|TEST SUCCEEDED|TEST FAILED" | tail -100
```

Pass criterion: `** TEST SUCCEEDED **` and `Executed N tests, with 0 failures` in the output.

On failure:
1. List the failing test names exactly as they appear (`-[SuiteName testMethodName]`).
2. Report total executed / failed counts.
3. STOP. Do not create the PR.
4. Per the global "Maximum 3 attempts" rule: do not retry the same failure more than twice. After the second retry, hand back to the user.

**Flaky test handling:** Treat **flaky/intermittent failures** as failures. The gate exists precisely because PR CI is not catching these — opening the PR anyway defeats the purpose. If a test fails intermittently:
1. First retry: run the specific failing test class only
2. Second retry: if same test fails, report as genuine failure
3. Do NOT proceed to PR creation

### Gate 3 — Working tree

Before delegating to `/create-pr`, confirm:

- `git status` shows the intended changes staged or already committed (no unrelated WIP about to ride along).
- The current branch follows the `feature/{{TICKET_PREFIX}}-XXXX` / `fix/{{TICKET_PREFIX}}-XXXX` / `chore/<topic>` convention from `/commit-and-pr`. If it does not, ask the user before proceeding — the PR title and labels depend on the ticket number in the branch name.

## Hand-off

Once all three gates pass, invoke `/create-pr` and let it do its job unchanged. Do **not** reimplement PR-template, label-selection, base-branch (`--base dev`), or footer logic here — `/create-pr` owns that.

After `/create-pr` returns the PR URL, report:

- Gate 1: build SUCCEEDED
- Gate 2: tests passed (`Executed N, failures 0`)
- PR: `<url>`

Keep the summary to those three lines — no extra prose.

## What this skill does NOT do

- It does not commit code. If there are unstaged changes, hand off to `/create-pr-from-staged-changes` or `/branch-and-pr` first — those skills own commit + push.
- It does not bypass a failing gate under any circumstance. The whole point of the skill is that PR CI does not run tests, so a green gate here is the only thing standing between a broken `main`/`dev` and the team.
- It does not change branch, base, label, or template behavior. That is `/create-pr`'s job.
- It does not run `swiftformat` or `/code-review` — those are separate review concerns, not a CI substitute.

## Composition

| Step | Command | Purpose |
|------|---------|---------|
| Gate 1 | Build with timeout | Verify compilation (5 min timeout) |
| Gate 2 | Test with parallel | Verify all unit tests pass (8 min timeout) |
| Gate 3 | Working tree check | Ensure clean state and proper branch |
| Create | `/create-pr` | Open PR with team template, label, base `dev`, footer |

## Arguments

- `$ARGUMENTS` — Optional flags:
  - `--quick` — Run only tests for files changed in this branch (faster for focused PRs)
  - `--skip-tests` — Bypass Gate 2 and defer to `/create-pr` directly (use sparingly)

### Quick Mode (--quick)

When `--quick` is passed, Gate 2 runs only tests related to changed files:

1. Get changed Swift files: `git diff dev --name-only | grep '\.swift$'`
2. Extract test class names from test files (files containing `Tests.swift`)
3. Run only those test classes: `-only-testing:{{APP_TESTS}}/<TestClassName>`

This provides faster feedback for focused changes while still catching regressions in touched code.

## Reporting Format

After a successful run:

```
Build:  SUCCEEDED (Xm Ys)
Tests:  Executed <N>, failures 0 (Xm Ys)
PR:     <github-url>
```

After a failed run:

```
Build:  <SUCCEEDED|FAILED> (Xm Ys)
Tests:  <not-run|Executed N, failures M — <test names>>
PR:     not created — <Build|Tests> gate failed
```

## Error Categories

When reporting failures, categorize the error type to help the user:

| Category | Example | Suggested Action |
|----------|---------|------------------|
| **Compile Error** | `error: cannot find 'X' in scope` | Fix the code |
| **Type Error** | `error: cannot convert value` | Check types |
| **Missing Import** | `error: no such module` | Add import or check module |
| **Test Assertion** | `XCTAssertEqual failed` | Fix test or implementation |
| **Test Timeout** | `Test exceeded execution time` | Check for infinite loops |
| **Simulator Issue** | `Unable to boot simulator` | Retry with simulator reset |
