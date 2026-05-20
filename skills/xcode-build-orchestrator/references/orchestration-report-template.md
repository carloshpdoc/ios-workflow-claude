# Orchestration Report Template

Use this template when generating the final optimization report at `.build-benchmark/optimization-plan.md`.

## Template

```markdown
# Xcode Build Optimization Plan

## Project Context

- **Project:** `<path>`
- **Scheme:** `<scheme>`
- **Configuration:** `<configuration>`
- **Destination:** `<destination>`
- **Xcode:** <version>
- **macOS:** <version>
- **Date:** <ISO date>
- **Benchmark artifact:** `<path>`

## Baseline Benchmarks

| Metric | Clean | Cached Clean | Incremental |
|--------|-------|-------------|-------------|
| Median | Xs | Xs | Xs |
| Min | Xs | Xs | Xs |
| Max | Xs | Xs | Xs |
| Runs | N | N | N |

### Clean Build Timing Summary

> **Note:** These are aggregated task times across all CPU cores. Because Xcode runs many tasks in parallel, these totals typically exceed the actual build wait time shown above.

| Category | Tasks | Seconds |
|----------|------:|--------:|
| ... | ... | ... |

## Build Settings Audit

### Debug Configuration
- [x] `SETTING`: `value` (recommended: `value`)
- [ ] `SETTING`: `value` (recommended: `value`)

### General (All Configurations)
...

### Release Configuration
...

### Cross-Target Consistency
...

## Compilation Diagnostics

Threshold: Xms | Total warnings: N | Function bodies: N | Expressions: N

| Duration | Kind | File | Line | Name |
|---------:|------|------|-----:|------|
| ... | ... | ... | ... | ... |

## Prioritized Recommendations

### 1. <Title>

**Wait-Time Impact:** <impact statement>
**Actionability:** <repo-local|package-manager|xcode-behavior|upstream>
**Evidence:** <what was observed>
**Impact:** <High/Medium/Low>
**Confidence:** <High/Medium/Low>
**Risk:** <Low/Medium/High>

## Approval Checklist

- [ ] **1. <Title>** -- Impact: <statement> | Actionability: <value> | Risk: <level>
- [ ] **2. <Title>** -- Impact: <statement> | Actionability: <value> | Risk: <level>

## Next Steps

After implementing approved changes, re-benchmark with the same inputs:

\```bash
python3 .claude/skills/scripts/benchmark_builds.py \
  --project <path> \
  --scheme <scheme> \
  --configuration <config> \
  --destination "<destination>" \
  --output-dir .build-benchmark
\```

Compare the new wall-clock medians against the baseline. Report results as:
"Your [clean/incremental] build now takes X.Xs (was Y.Ys) -- Z.Zs faster/slower."
```
