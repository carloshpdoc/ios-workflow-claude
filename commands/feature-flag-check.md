# Feature Flag Investigation

Investigate the feature flag **$ARGUMENTS** and produce a detailed investigation for removal.

**Output:** Creates an investigation file at `docs/feature-flags/issues/$ARGUMENTS.md` that serves as the "issue" for this cleanup. The `/feature-flag-remove` command will read this investigation before executing the removal.

## Steps

### 1. Find the Flag Definition

Search for the flag in RemoteConfig files:

```
Grep: "$ARGUMENTS" in {{FLAG_KEY_FILE}}
Grep: "$ARGUMENTS" in {{FLAG_DEFAULTS_FILE}}.swift
```

Document:
- The exact case name in `{{FLAG_KEY_ENUM}}`
- The default value from `{{FLAG_DEFAULTS_FILE}}`
- The value type (Bool, String, Int, etc.)

### 2. Find All Flag Usages

Search for all code using this flag:

```
Grep: "{{FLAG_KEY_ENUM}}.$ARGUMENTS" in *.swift
Grep: ".$ARGUMENTS" in *.swift (for shorthand usage)
Grep: the flag's string key in all files
```

For each usage, note:
- File path
- How the flag is read (remoteConfig.bool(), remoteConfig.string(), etc.)
- What code path is gated (true vs false branch)
- Whether it's the only flag check or combined with others

### 3. Trace Code Paths

For each flag usage, trace what code is affected:

**If flag guards a feature:**
- Find all ViewControllers/Views involved
- Find all ViewModels involved
- Find all Repositories/DataSources involved
- Find all Models specific to the feature
- Find navigation/coordinator logic
- Find any managers or helpers

**If flag guards a UI element:**
- Find the specific view/component
- Check if it has dedicated logic or is inline

**If flag guards a string/config value:**
- Find where the value is used
- Check if removal requires a replacement value

### 4. Check Firebase Remote Config

Ask user to verify in Firebase Console:
- Current production value
- Current staging value
- Last time the flag was changed
- Whether it's safe to assume the flag is permanently ON or OFF

### 5. Identify Dead Code

Based on the flag's permanent value, identify:
- Code that will NEVER run (dead code to delete)
- Code that will ALWAYS run (keep, remove conditional)
- Code that needs the conditional simplified

### 6. Find Related Tests

Search for tests that reference this flag:

```
Grep: "$ARGUMENTS" in {{APP_TESTS}}/
Grep: MockRemoteConfig with flag setup
```

Note which tests need updating vs deletion.

### 7. Assess Complexity

Rate the cleanup complexity:

| Complexity | Criteria |
|------------|----------|
| **Low** | String config, simple bool, <5 usages, no UI |
| **Medium** | Feature toggle, 5-15 usages, some UI, some tests |
| **High** | Major feature, >15 usages, full module, many tests |

### 8. Write the Investigation File

Create `docs/feature-flags/issues/$ARGUMENTS.md`:

```markdown
# Investigation: $ARGUMENTS

> Generated: <date>
> Complexity: <Low/Medium/High>

## Flag Definition

| Property | Value |
|----------|-------|
| {{FLAG_KEY_ENUM}} | `$ARGUMENTS` |
| Type | <Bool/String/Int> |
| Default Value | <value> |
| Production Value | <value> (verify in Firebase) |

## Current Usages (<count>)

| File | Line | Usage |
|------|------|-------|
| ... | ... | ... |

## Affected Code

### Files to Delete
| File | Purpose | Lines |
|------|---------|-------|
| ... | ... | ... |

### Files to Modify
| File | Change Required |
|------|-----------------|
| ... | ... |

### Tests to Update
| Test File | Change |
|-----------|--------|
| ... | ... |

## Removal Plan

1. <step 1>
2. <step 2>
...

## Risks

- <any risks or dependencies to watch>

## Recommendation

<SAFE TO REMOVE / NEEDS DISCUSSION / BLOCKED BY X>
```

### 9. Update Status File

Add the flag to "In-Progress" section of `docs/feature-flags/status.md` if user wants to proceed.

## Notes

- Always verify production flag value in Firebase before proceeding
- Some flags may be A/B tests still running - do not remove
- Check the team's pre-approved flags list (Notion or equivalent tracker)
