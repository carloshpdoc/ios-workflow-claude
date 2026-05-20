# Build Optimization Sources

This file stores the external sources that the skill docs should cite consistently.

## Apple: Improving the speed of incremental builds

Source: <https://developer.apple.com/documentation/xcode/improving-the-speed-of-incremental-builds>

Key takeaways:
- Measure first with `Build With Timing Summary` or `xcodebuild -showBuildTimingSummary`.
- Accurate target dependencies improve correctness and parallelism.
- Run scripts should declare inputs and outputs so Xcode can skip unnecessary work.
- `.xcfilelist` files are appropriate when scripts have many inputs or outputs.
- Custom frameworks and libraries benefit from module maps, typically by enabling `DEFINES_MODULE`.
- Module reuse is strongest when related sources compile with consistent options.
- Breaking monolithic targets into better-scoped modules can reduce unnecessary rebuilds.

## Apple: Improving build efficiency with good coding practices

Source: <https://developer.apple.com/documentation/xcode/improving-build-efficiency-with-good-coding-practices>

Key takeaways:
- Use framework-qualified imports when module maps are available.
- Keep Objective-C bridging surfaces narrow.
- Prefer explicit type information when inference becomes expensive.
- Use explicit delegate protocols instead of overly generic delegate types.
- Simplify complex expressions that are hard for the compiler to type-check.

## Apple: Building your project with explicit module dependencies

Source: <https://developer.apple.com/documentation/xcode/building-your-project-with-explicit-module-dependencies>

Key takeaways:
- Explicit module builds make module work visible in the build log and improve scheduling.
- Repeated builds of the same module often point to avoidable module variants.
- Inconsistent build options across targets can force duplicate module builds.
- Timing summaries can reveal option drift that prevents module reuse.

## Apple: Demystify explicitly built modules (WWDC24)

Source: <https://developer.apple.com/videos/play/wwdc2024/10171/>

Key takeaways:
- Explains how explicitly built modules divide compilation into scan, module build, and source compile stages.
- Unrelated modules build in parallel, improving CPU utilization.
- Module variant duplication is a key bottleneck -- uniform compiler options across targets prevent it.

## Swift Compile-Time Best Practices

- Mark classes `final` when they are not intended for subclassing.
- Restrict access control to the narrowest useful scope (`private`, `fileprivate`).
- Prefer value types (`struct`, `enum`) over `class` when reference semantics are not needed.
- Break long method chains into intermediate `let` bindings with explicit type annotations.
- Provide explicit return types on closures passed to generic functions.
- Decompose large SwiftUI `body` properties into smaller extracted subviews.

## Swift Forums: Slow incremental builds because of planning swift module

Source: <https://forums.swift.org/t/slow-incremental-builds-because-of-planning-swift-module/84803>

Key takeaways:
- "Planning Swift module" can dominate incremental builds (up to 30s per module).
- Heavy Swift macro usage can cause trivial changes to cascade into near-full rebuilds.
- `swift-syntax` builds universally when no prebuilt binary is available.
- `SwiftEmitModule` can take 60s+ after a single-line change in large modules.
- Asset catalog compilation is single-threaded per target.
