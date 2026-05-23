# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] — 2026-05-23

### Added

- **`bootstrap.sh --ide <claude|cursor|kiro>`** — install the same content as Cursor `.mdc` rules or Kiro `.md` steering files. Frontmatter is rewritten per IDE; `{{PLACEHOLDER}}` substitution still applies.
- **Four new placeholders** wired through `bootstrap.sh` (CLI flag + env var + sed substitution): `{{JIRA_BOARD_ID}}`, `{{FLAG_KEY_ENUM}}`, `{{FLAG_KEY_FILE}}`, `{{FLAG_DEFAULTS_FILE}}`.
- **`.github/ISSUE_TEMPLATE/`** — bug report + feature request forms (blank issues disabled, Discussions linked).
- **`.github/PULL_REQUEST_TEMPLATE.md`** — change-type checklist with a placeholder-hygiene gate.
- **`.github/workflows/bootstrap-smoke-test.yml`** — matrix CI (`claude` × `cursor` × `kiro`) that runs `bootstrap.sh` against each target, verifies expected layout + substitution, and fails the build if any previously-leaked fingerprint reappears.

### Changed

- Generalized agent + command examples that referenced real production class/file names. Replacements use clearly synthetic names (`Profile`, `ProfileViewModel`, `FeatureFlagKey`, etc.) or `<descriptive-tag>` markers.

## [0.1.0] — 2026-05-19

Initial public release. The repo was previously a personal collection under `skills-claude`; renamed and reorganized for community distribution.

### Added

- **Plugin marketplace** at `.claude-plugin/marketplace.json` with three plugins users can install via `/plugin marketplace add carloshpdoc/ios-workflow-claude`:
  - `xcode-build-suite` — 6 standalone skills for Xcode build optimization (orchestrator, benchmark, compilation analyzer, project analyzer, fixer, SPM analysis). No placeholders required.
  - `ios-workflow` — 22 commands + 3 agents for Swift 6 migration, Apollo→native SDK removal, stacked PRs, Jira automation, perf playbook, SwiftLint fixer. Placeholder-heavy — `bootstrap.sh` recommended for adoption.
  - `claude-utilities` — 3 cross-stack skills (`content`, `knowledge`, `create-tasks`).
- **"Why this exists" section** in README with a comparative table against the 3 nearest competitors (`keskinonur/claude-code-ios-dev-guide`, `schovi/claude-schovi`, `kylehughes/apple-platform-build-tools`).
- **`examples/claude-settings.json`** — drop-in `.claude/settings.json` template using `extraKnownMarketplaces` + `enabledPlugins` for teams adopting the marketplace per project.

### Changed

- **Project renamed** `skills-claude` → `ios-workflow-claude`. GitHub URL, README references, `bootstrap.sh` self-description, and all clone paths updated.
- **`bootstrap.sh` env var** `SKILLS_CLAUDE_REPO` → `IOS_WORKFLOW_CLAUDE_REPO` with backwards-compat alias (`${IOS_WORKFLOW_CLAUDE_REPO:-${SKILLS_CLAUDE_REPO:-$SCRIPT_DIR}}`).
- **GitHub topics** added: `claude-code`, `claude-plugin`, `claude-code-plugin`, `ios`, `swift`, `xcode`, `swift6`, `jira`, `github-cli`, `automation`, `pr-workflow`, `apollo-ios`, `swiftlint`, `slash-commands`.

[Unreleased]: https://github.com/carloshpdoc/ios-workflow-claude/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/carloshpdoc/ios-workflow-claude/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/carloshpdoc/ios-workflow-claude/releases/tag/v0.1.0
