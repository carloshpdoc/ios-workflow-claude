# Benchmarking Workflow

This reference describes the standard benchmarking workflow used by the `xcode-build-benchmark` skill.

## Workflow Steps

1. **Collect inputs**: workspace/project, scheme, configuration, destination
2. **Warmup**: Run one full build to validate the command succeeds and warm OS caches
3. **Clean builds** (3x): Delete DerivedData, then build and measure wall-clock time
4. **Cached clean builds** (3x, if COMPILATION_CACHING=YES): Warm the cache once, then delete DerivedData (not the cache) before each measured build
5. **Zero-change builds** (3x): Build immediately after a successful build with no edits
6. **Incremental builds** (3x, optional): Touch a source file before each build
7. **Save artifact**: Write timestamped JSON to `.build-benchmark/`
8. **Report**: Present medians with min/max spread

## Consistency Rules

- Same command, destination, configuration, and scheme across all runs
- Same machine state (close heavy apps, same power mode)
- Same Xcode version
- Do not change project files during benchmarking

## Interpreting Results

- **Clean build median**: Baseline for full compilation
- **Cached clean median**: Realistic developer experience (branch switching, clean build folder)
- **Zero-change median**: Fixed overhead floor (should be < 5s on Apple Silicon)
- **Incremental median**: Edit-rebuild loop cost

## When Results Are Noisy

If min-to-max spread exceeds 20% of the median:
- Recommend running 5+ repetitions
- Close background apps
- Ensure consistent power state
- Note the variance in the report
