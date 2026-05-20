# Bump Version

Bump the app version or build number across all targets in the current project.

**$ARGUMENTS**: the bump type. If empty, defaults to `build`.

| Argument | Description | Example |
|----------|-------------|---------|
| `build` | Increment build number only | `1` -> `2` |
| `patch` | Bump patch version, increment build | `1.0.0` -> `1.0.1` |
| `minor` | Bump minor version, increment build | `1.0.0` -> `1.1.0` |
| `major` | Bump major version, increment build | `1.0.0` -> `2.0.0` |

**Examples:**
- `/bump` - Increment build number (default)
- `/bump build` - Increment build number
- `/bump patch` - Bump patch version
- `/bump minor` - Bump minor version
- `/bump major` - Bump major version

## Steps

### 1. Parse Arguments

Read `$ARGUMENTS` and determine the bump type:
- If empty or `build` -> bump build number only
- If `patch` -> bump patch, increment build
- If `minor` -> bump minor, increment build
- If `major` -> bump major, increment build
- If anything else -> tell the user the valid options and stop

### 2. Detect Project Type

Check what version source exists in the current working directory:

**Option A — XcodeGen (`project.yml`):**
Look for `project.yml` in the project root. If found, this is the source of truth. Extract the current `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` values from it.

**Option B — Native Xcode (`.pbxproj`):**
If no `project.yml` exists, find the `.pbxproj` file (typically at `*.xcodeproj/project.pbxproj`). Extract the current `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` values from it.

If neither exists, tell the user no version source was found and stop.

### 3. Read Current Versions

Extract the current values:
- **MARKETING_VERSION** (e.g., `1.0.0`) — the user-facing version
- **CURRENT_PROJECT_VERSION** (e.g., `3`) — the build number

If multiple different values exist across targets (e.g., some targets at build 3, others at build 1), warn the user and show the discrepancies. Use the **highest** value as the baseline for bumping, and the bump will unify all targets to the same new value.

### 4. Calculate New Values

Based on the bump type, calculate the new version and build number:

| Bump type | New MARKETING_VERSION | New CURRENT_PROJECT_VERSION |
|-----------|----------------------|---------------------------|
| `build` | unchanged | current + 1 |
| `patch` | X.Y.Z+1 | current + 1 |
| `minor` | X.Y+1.0 | current + 1 |
| `major` | X+1.0.0 | current + 1 |

**Why always increment instead of reset:** App Store Connect only requires that `CURRENT_PROJECT_VERSION` is monotonically increasing within the same `MARKETING_VERSION`. Always incrementing is safe across pre-release iteration (multiple TestFlights at the same marketing version) and post-release iteration alike, with no edge case where you'd resubmit a build number that was already used.

### 5. Update Version Source

**For `project.yml` (XcodeGen):**
Use `sed` to replace ALL occurrences:
- `MARKETING_VERSION: "old"` -> `MARKETING_VERSION: "new"` (when version changed)
- `CURRENT_PROJECT_VERSION: "old"` -> `CURRENT_PROJECT_VERSION: "new"`

If targets had different values (detected in step 3), replace each distinct old value so all targets converge to the new unified value.

**For `.pbxproj` (native Xcode):**
Use `sed` to replace ALL occurrences:
- `MARKETING_VERSION = old;` -> `MARKETING_VERSION = new;` (when version changed)
- `CURRENT_PROJECT_VERSION = old;` -> `CURRENT_PROJECT_VERSION = new;`

If targets had different build numbers, replace each distinct old value so all converge to the new value.

### 6. Show Summary

Display a clear summary:

```
Version bump: <type>
  MARKETING_VERSION:        <old> -> <new>  (or "unchanged" for build bump)
  CURRENT_PROJECT_VERSION:  <old> -> <new>
  Updated in: <project.yml | *.pbxproj>
  Targets affected: <count>
```

Then show `git diff` of the changed file so the user can verify.

### 7. Offer to Commit

Ask the user if they want to commit the change. If yes:

For version bumps (patch/minor/major):
```
Bump version to <new_version> (build <new_build>)
```

For build bumps:
```
Bump build number to <new_build>
```

### 5b. Regenerate Project (XcodeGen only)

If the version source is `project.yml`, run `xcodegen generate --no-env` to regenerate the `.pbxproj` so Xcode picks up the new version values. This is required because Xcode reads build settings from `.pbxproj`, not from `project.yml` directly.

## Important Rules

- NEVER modify `Info.plist` files — they reference `$(MARKETING_VERSION)` and `$(CURRENT_PROJECT_VERSION)` which resolve from build settings automatically
- Always update ALL targets/occurrences in a single operation to keep them in sync
- If the project has BOTH `project.yml` and `.pbxproj`, prefer `project.yml` as the source of truth (XcodeGen regenerates the `.pbxproj`)
- For XcodeGen projects: ALWAYS run `xcodegen generate --no-env` after updating `project.yml` — otherwise the `.pbxproj` stays stale and Xcode shows old version numbers
