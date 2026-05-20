# Benchmark Artifacts

This document defines the contract for benchmark artifacts stored in `.build-benchmark/`.

## Principles

- **Wall-clock time** is the primary metric -- how long the developer actually waits.
- **Cumulative task time** is diagnostic evidence, not a direct measure of build speed. A large cumulative `SwiftCompile` value is diagnostic evidence of compiler workload, not proof that compilation is blocking the build.
- Artifacts must be self-contained: anyone with the JSON file should be able to understand what was measured, how, and when.

## Artifact Organization

The `.build-benchmark/` directory contains:

- Timestamped JSON artifacts (one per benchmark run)
- Raw build log files (one per individual build)
- Diagnostics artifacts (from `diagnose_compilation.py`)
- The optimization plan (`optimization-plan.md`)

## Build Scenarios

Each benchmark captures up to three scenarios:

1. **Clean builds** -- Full compilation from scratch (DerivedData deleted)
2. **Cached clean builds** -- Clean build with a warm compilation cache. The compilation cache lives outside DerivedData and survives product deletion. This captures the realistic developer experience: branch switching, pulling changes, and Clean Build Folder.
3. **Incremental / zero-change builds** -- Build immediately after a successful build, measuring fixed overhead or edit-rebuild cost.

## Variance Mitigation

- First clean builds often run 20-40% slower due to cold OS caches. Include a warmup build.
- Use medians rather than means when variance is high.
- If the spread (max - min) exceeds 20% of the median, flag as high variance.
- Document any environmental factors that could affect reproducibility.
