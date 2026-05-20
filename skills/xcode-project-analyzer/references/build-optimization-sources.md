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

## Apple: Demystify explicitly built modules (WWDC24)

Source: <https://developer.apple.com/videos/play/wwdc2024/10171/>

## SwiftLee: Build performance analysis for speeding up Xcode builds

Source: <https://www.avanderlee.com/optimization/analysing-build-performance-xcode/>

## Swift Forums: Slow incremental builds because of planning swift module

Source: <https://forums.swift.org/t/slow-incremental-builds-because-of-planning-swift-module/84803>
