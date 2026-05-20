# SPM Analysis Checks

Detailed checklist for the `spm-build-analysis` skill.

## Dependency Graph

- [ ] No circular dependencies between modules
- [ ] Dependency direction flows inward (Common/Core -> Services -> Features/UI)
- [ ] No umbrella modules using `@_exported import`
- [ ] Interface/implementation separation where it benefits build parallelism
- [ ] Test targets depend on the module under test, not the entire app target

## Package Pinning

- [ ] No branch-pinned dependencies when tags are available
- [ ] Branch-pinned packages without tags use revision hash pins
- [ ] `Package.resolved` is committed

## Module Size

- [ ] No oversized modules (200+ files) that widen incremental rebuild scope
- [ ] Large modules evaluated for splitting opportunities

## Build Plugins

- [ ] No build-tool plugins running during incremental builds unnecessarily
- [ ] Plugin overhead measured in timing summaries

## Swift Macros

- [ ] Macro-heavy libraries (TCA, swift-syntax) isolated into stable modules
- [ ] Macro expansion cascading assessed for incremental build impact
- [ ] `swift-syntax` not building universally when prebuilt binary available

## Multi-Platform

- [ ] Secondary platform targets assessed for build multiplication
- [ ] Shared SPM packages not building redundantly per platform/architecture

## Package Verification

- [ ] Local packages in recommendations verified as actually linked in `project.pbxproj`
- [ ] Vendor directories checked for unlinked packages
