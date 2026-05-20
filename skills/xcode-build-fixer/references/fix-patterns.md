# Fix Patterns

Common implementation patterns for the `xcode-build-fixer` skill.

## Build Settings Changes

### Modifying project.pbxproj

Build settings live in `project.pbxproj` under `XCBuildConfiguration` sections. Each configuration (Debug/Release) has its own `buildSettings` block.

```
/* Debug */ = {
    isa = XCBuildConfiguration;
    buildSettings = {
        DEBUG_INFORMATION_FORMAT = dwarf;
        ...
    };
};
```

### Adding a new setting

Add the key-value pair to the appropriate configuration's `buildSettings` block.

### Changing an existing setting

Replace the value in-place. Always verify the change compiles.

## Script Phase Guards

### Debug-only guard

```bash
if [ "$CONFIGURATION" = "Release" ]; then
    echo "Skipping in Release"
    exit 0
fi
```

### Simulator-only guard

```bash
if [ "$PLATFORM_NAME" = "iphonesimulator" ]; then
    echo "Skipping for simulator"
    exit 0
fi
```

### Adding input/output declarations

In the pbxproj, find the `PBXShellScriptBuildPhase` and add:

```
inputPaths = (
    "$(SRCROOT)/path/to/input",
);
outputPaths = (
    "$(DERIVED_FILE_DIR)/output",
);
```

## Source-Level Fixes

### Adding explicit types

```swift
// Before (slow type-check)
let result = items.map { $0.value }.filter { $0 > 0 }.reduce(0, +)

// After (faster type-check)
let mapped: [Int] = items.map { $0.value }
let filtered: [Int] = mapped.filter { $0 > 0 }
let result: Int = filtered.reduce(0, +)
```

### Marking classes final

```swift
// Before
class MyService { ... }

// After
final class MyService { ... }
```

### Decomposing SwiftUI views

```swift
// Before: monolithic body
var body: some View {
    VStack {
        // 100+ lines
    }
}

// After: extracted subviews
var body: some View {
    VStack {
        HeaderView()
        ContentView()
        FooterView()
    }
}
```

## Verification

After each change:
1. `xcodebuild build` must succeed
2. If it fails, revert immediately
3. After all changes, re-benchmark with same parameters
