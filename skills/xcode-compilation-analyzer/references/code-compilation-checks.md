# Code Compilation Checks

Detailed checklist of source-level compilation patterns that the `xcode-compilation-analyzer` should inspect.

## Type-Checking Hotspots

- [ ] Complex chained or nested expressions without intermediate type annotations
- [ ] Nested ternaries or overloaded generic chains
- [ ] Long method chains (`.map().flatMap().filter().reduce()`) without typed intermediates
- [ ] Closures passed to generic functions without explicit return types
- [ ] SwiftUI result-builder expressions that are too large for the type-checker

## SwiftUI Specific

- [ ] Monolithic `body` properties (50+ lines) that should be decomposed into subviews
- [ ] `@ViewBuilder` helper properties instead of separate `struct View` types
- [ ] Deeply nested `Group`/`VStack`/`HStack` hierarchies within a single body

## Access Control

- [ ] Classes missing `final` that are never subclassed
- [ ] Properties/methods using default `internal` that could be `private`/`fileprivate`
- [ ] `public`/`open` access on symbols only used internally

## Type System

- [ ] Delegate properties typed as `AnyObject` instead of a concrete protocol
- [ ] Missing explicit type information in expensive expressions
- [ ] Value types (`struct`/`enum`) preferred over `class` when reference semantics not needed

## Mixed-Language

- [ ] Oversized Objective-C bridging headers
- [ ] Header imports that skip framework qualification
- [ ] Swift members unnecessarily exposed to Objective-C

## Diagnostic Flags

Use these for investigation:

| Flag | Purpose |
|------|---------|
| `-Xfrontend -warn-long-function-bodies=<ms>` | Surface slow function bodies |
| `-Xfrontend -warn-long-expression-type-checking=<ms>` | Surface slow expressions |
| `-Xfrontend -debug-time-compilation` | Per-file compile times |
| `-Xfrontend -debug-time-function-bodies` | Per-function compile times |
| `-Xswiftc -driver-time-compilation` | Driver-level timing |
| `-Xfrontend -stats-output-dir <path>` | Detailed compiler statistics (JSON) |
