# Project Audit Checks

Detailed checklist for the `xcode-project-analyzer` skill.

## Build Settings Audit

- [ ] Debug: `SWIFT_COMPILATION_MODE` = `singlefile`
- [ ] Debug: `SWIFT_OPTIMIZATION_LEVEL` = `-Onone`
- [ ] Debug: `GCC_OPTIMIZATION_LEVEL` = `0`
- [ ] Debug: `ONLY_ACTIVE_ARCH` = `YES`
- [ ] Debug: `DEBUG_INFORMATION_FORMAT` = `dwarf`
- [ ] Debug: `ENABLE_TESTABILITY` = `YES`
- [ ] Debug: `EAGER_LINKING` = `YES`
- [ ] Release: `SWIFT_COMPILATION_MODE` = `wholemodule`
- [ ] Release: `SWIFT_OPTIMIZATION_LEVEL` = `-O` or `-Osize`
- [ ] Release: `ONLY_ACTIVE_ARCH` = `NO`
- [ ] Release: `DEBUG_INFORMATION_FORMAT` = `dwarf-with-dsym`
- [ ] General: `COMPILATION_CACHING` = `YES`
- [ ] General: `SWIFT_USE_INTEGRATED_DRIVER` = `YES`
- [ ] General: `CLANG_ENABLE_MODULES` = `YES`

## Script Phase Checks

- [ ] All run scripts declare input and output files
- [ ] No scripts with `alwaysOutOfDate = 1` without justification
- [ ] Debug/simulator guards on release-only scripts
- [ ] No linters/formatters touching file timestamps without changing content
- [ ] `.xcfilelist` used when scripts have many inputs/outputs

## Target Dependencies

- [ ] Target dependencies are explicit and accurate
- [ ] No stale/removed dependencies
- [ ] Scheme builds in `Dependency Order`
- [ ] `DEFINES_MODULE` enabled for custom frameworks
- [ ] Public headers are self-contained for module-map use

## Cross-Target Consistency

- [ ] `SWIFT_COMPILATION_MODE` consistent across targets
- [ ] `SWIFT_OPTIMIZATION_LEVEL` consistent across targets
- [ ] `ONLY_ACTIVE_ARCH` consistent across targets
- [ ] `DEBUG_INFORMATION_FORMAT` consistent across targets
- [ ] No unnecessary per-target overrides

## CocoaPods

- [ ] If `Podfile` exists, recommend migrating to SPM
- [ ] Do not audit `Pods.xcodeproj` or attempt CocoaPods-specific optimizations

## Zero-Change Build Overhead

- [ ] Zero-change build < 5s on Apple Silicon
- [ ] Investigate fixed-cost phases if exceeded
