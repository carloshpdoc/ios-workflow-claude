# Plugin install guide

Third-party Claude Code plugins referenced by this repo. Don't copy these files into your project — install them via the marketplace so you get upstream updates and licensing is respected.

> The commands below use `/plugin marketplace add` and `/plugin install` inside Claude Code. The marketplace `claude-plugins-official` ships with Claude Code; the others need adding once.

---

## 1. iOS / Swift skills (Patrick Serrano, MIT)

Adds: `ios-swift-skills:swiftui-performance-audit`, `ios-swift-skills:native-app-profiling`, `ios-swift-skills:swift-concurrency-expert`, `ios-swift-skills:swiftui-view-refactor`, `ios-swift-skills:swiftui-ui-patterns`, `ios-swift-skills:swiftui-liquid-glass`, `ios-swift-skills:ios-debugger-agent`, `ios-swift-skills:release-app-store-changelog`, `ios-swift-skills:release-macos-spm-packaging`, `ios-swift-skills:github-issue-fix-flow`.

Patrick's repo isn't in a public marketplace, so register it via a personal marketplace once:

```text
# Inside Claude Code
/plugin marketplace add <your-marketplace-url-or-local-path>
/plugin install ios-swift-skills
```

If you don't already have a personal marketplace, the simplest approach is to clone Patrick's repo and point a local marketplace at it. Reference: https://github.com/patrickserrano/skills

---

## 2. memorydetective (Apache 2.0)

Adds: `memorydetective:perf-investigate` — disciplined iOS perf + memory-leak investigation playbooks via MCP (memgraph leak hunting, time profiler, hangs, jank, slow launch).

```text
/plugin marketplace add memorydetective-plugin <repo-url>
/plugin install memorydetective@memorydetective-plugin
```

---

## 3. codex (OpenAI, Apache 2.0)

Adds: `codex:setup`, `codex:rescue`, `codex:codex-cli-runtime`, `codex:codex-result-handling`, `codex:gpt-5-4-prompting`. Lets you hand off investigation, second-opinion, or stuck implementations to Codex CLI through a shared runtime.

```text
/plugin marketplace add openai-codex <repo-url>
/plugin install codex@openai-codex
```

---

## 4. Official plugins (Anthropic)

The `claude-plugins-official` marketplace ships with Claude Code. Install just what you need:

```text
/plugin install code-review@claude-plugins-official       # generic /code-review
/plugin install security-guidance@claude-plugins-official # /security-review
/plugin install pr-review-toolkit@claude-plugins-official # /review + subagents (simplifier, comment analyzer, etc.)
/plugin install frontend-design@claude-plugins-official   # /frontend-design — polished web UI generator
/plugin install claude-md-management@claude-plugins-official  # CLAUDE.md health checks
/plugin install plugin-dev@claude-plugins-official        # tooling for building your own plugins
```

LSPs (one per language as needed):

```text
/plugin install swift-lsp@claude-plugins-official
/plugin install typescript-lsp@claude-plugins-official
/plugin install pyright-lsp@claude-plugins-official
# ...etc
```

---

## Verifying

After installing:

```text
/plugin
```

Lists installed plugins. Restart Claude Code if the new commands don't show up in tab-completion.
