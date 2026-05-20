---
name: code-review
description: Review code quality applying DRY, SOLID, naming, and formatting standards
usage: /code-review
---

# Code Quality Review

You are performing a code quality review on new or modified files in the current branch.

## Task

Review all new and modified Swift files (excluding test files) in the current branch, applying the principles below. Then apply the fixes.

## Scope

1. **Identify changed files**: Run `git diff --name-only HEAD~1` or `git status` to find new/modified Swift source files
2. **Read each file** fully before suggesting changes
3. **Apply fixes** incrementally, confirming each category of change

## Principles to Apply

### DRY (Don't Repeat Yourself)
- Look for duplicated code blocks, repeated patterns, or copy-pasted logic
- Extract shared behavior into helper methods or computed properties
- If 3+ lines are repeated across switch cases or conditionals, extract them

### SOLID
- **Single Responsibility**: Each method/class should have one reason to change — one job, one concern
- **Open/Closed**: Classes should be open for extension but closed for modification — prefer adding computed properties to enums over external switch statements, use protocol extensions to add behavior
- **Liskov Substitution**: Subclasses/implementations must be substitutable for their base types without breaking behavior — don't restrict capabilities or violate contracts of the parent type
- **Interface Segregation**: Don't force classes to depend on interfaces they don't use — split large protocols into smaller, focused ones aligned with client needs
- **Dependency Inversion**: High-level modules should depend on abstractions, not concrete types — use protocols for dependencies, inject them rather than hardcoding

### Naming
- Variable and method names must be descriptive of their purpose
- Avoid abbreviations unless universally understood (e.g., `url`, `id`)
- Boolean variables should read as questions: `isLoading`, `hasError`, `shouldRetry`

### No Comments
- Remove TODO comments, inline explanations, and redundant documentation
- MARK comments (e.g., `// MARK: - Section Name`) are acceptable and should be kept
- Code should be self-documenting through clear naming

### Brief Methods
- Methods longer than ~20 lines should be refactored into smaller, focused methods
- Each method should have a single level of abstraction
- Extract complex conditions into descriptively-named computed properties or methods

### Remove Dead Code
- Remove unused variables, parameters, and methods
- Remove redundant assignments (e.g., setting a value twice before it's read)

### Use Font Tokens
- Never use hardcoded `Font.custom("GTUltra-...", size: N)` — use DS font modifiers instead
- **How to find the right modifier:**
  1. Check `Modules/DS/Sources/DS/Font/Modifiers/FontScaleModifier.swift` for available ``<scale>Font()` (your design-system font scale modifiers)` View modifiers
  2. Each modifier maps to a scale in `Modules/DS/Sources/DS/Font/Scale/{{FONT_SCALE_TYPE}}.swift` which defines the font family (via `CustomFont`) and size (via `{{FONT_SIZE_TYPE}}`)
  3. Font families are defined in `Modules/DS/Sources/DS/Typography/FontProvider/CustomFont.swift`
  4. Font sizes are defined in `Modules/DS/Sources/DS/Font/Size/{{FONT_SIZE_TYPE}}.swift`
- To match a hardcoded font: find the `CustomFont` case matching the font name, then find the `{{FONT_SCALE_TYPE}}` case that combines that font with the target size
- Flag any `Font.custom("GTUltra..."` usage and suggest the matching modifier

### Reuse UIComponents
- Check `Modules/UIComponents/Sources/UIComponents/` for existing components (buttons, cards, etc.) that can be reused instead of building custom UI inline
- If an existing component is close but not an exact match, suggest extending it with a new style/variant rather than duplicating code
- Pay special attention to `ButtonComponent` and its styles — prefer using or adding a `ButtonComponentStyle` case over custom `Button` implementations

### Localize Strings
- All user-facing text must be in `{{APP}}/Resources/Localizable.strings`, not hardcoded in views
- **How to localize a string:**
  1. Add the key-value pair to `{{APP}}/Resources/Localizable.strings` using dot-notation matching the feature area:
     ```
     "FeatureName.elementName" = "The visible text";
     ```
  2. R.swift auto-generates accessors on build. The key `FeatureName.elementName` becomes `R.string.localizable.featureNameElementName()`
  3. Reference in Swift code: `R.string.localizable.featureNameElementName()` — this returns a `String`
  4. For SwiftUI `Text`, use: `Text(R.string.localizable.featureNameElementName())`
  5. For `ButtonComponent` or any `String` parameter, pass the R.swift call directly
- Flag any hardcoded strings found in views, view models, or coordinators

## After Applying Fixes

Run `swiftformat` on all changed and added files (including untracked):

```bash
# Get all modified and new Swift files
git diff --name-only HEAD | grep '\.swift$' | xargs swiftformat
git ls-files --others --exclude-standard | grep '\.swift$' | xargs swiftformat
```

## Output

After completing the review and fixes, provide a summary:
- Number of files reviewed
- List of changes made, grouped by principle (DRY, naming, brevity, etc.)
- Confirmation that swiftformat ran successfully
