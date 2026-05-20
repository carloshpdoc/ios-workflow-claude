# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/carloshpdoc/ios-workflow-claude/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/carloshpdoc/ios-workflow-claude/releases/tag/v0.1.0
