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

## JSON Schema

See `schemas/build-benchmark.schema.json` for the full schema. Key fields:

- `schema_version`: `"1.0.0"`, `"1.1.0"`, or `"1.2.0"` (1.2.0 includes cached_clean)
- `build`: project/workspace, scheme, configuration, destination, command
- `environment`: host, Xcode version, macOS version
- `runs`: arrays of individual build results per type
- `summary`: statistical summaries (count, min, max, median, average) per type

Each run includes:
- `duration_seconds`: wall-clock time
- `timing_summary_categories`: parsed Build Timing Summary categories with seconds and task counts
- `raw_log_path`: path to the full build log

## Variance Mitigation

- First clean builds often run 20-40% slower due to cold OS caches. Include a warmup build.
- Use medians rather than means when variance is high.
- If the spread (max - min) exceeds 20% of the median, flag as high variance.
- Document any environmental factors that could affect reproducibility.

## Compilation Caching

When `COMPILATION_CACHING = YES` is detected:

- The benchmark automatically runs cached clean builds.
- The cache warmup builds once, then deletes DerivedData (not the cache) before each measured run.
- This reflects realistic workflows like branch switching where the cache persists.
