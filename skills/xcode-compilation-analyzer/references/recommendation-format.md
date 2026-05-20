# Recommendation Format

All optimization skills should report recommendations in a shared structure so the orchestrator can merge and prioritize them cleanly.

## Required Fields

Each recommendation should include:

- `title`
- `wait_time_impact` -- plain-language statement of expected wall-clock impact
- `actionability` -- classifies how fixable the issue is from the project
- `category`
- `observed_evidence`
- `estimated_impact`
- `confidence`
- `approval_required`
- `benchmark_verification_status`

### Actionability Values

- `repo-local` -- Fix lives entirely in project files, source code, or local configuration.
- `package-manager` -- Requires CocoaPods or SPM configuration changes.
- `xcode-behavior` -- Observed cost is driven by Xcode internals.
- `upstream` -- Requires changes in a third-party dependency.

## Verification Status Values

- `Not yet verified`
- `Queued for verification`
- `Verified improvement`
- `No measurable improvement`
- `Inconclusive due to benchmark noise`
