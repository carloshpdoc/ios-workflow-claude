# Claude Code built-ins

These ship with Claude Code itself — no install needed. Invoke as slash commands or let Claude pick them up automatically when relevant.

## Slash commands

| Command | What it does | When to use |
|---|---|---|
| `/init` | Scans the current repo and bootstraps a `CLAUDE.md` with codebase context, conventions, common commands. | First-time setup of a new repo. |
| `/loop` | Run a prompt or another slash command on an interval (e.g. `/loop 5m /babysit-prs`) or self-paced. | Polling, recurring checks, monitoring CI. |
| `/schedule` | Create, list, or run scheduled remote agents (cron). One-time runs work too: `/schedule run this once at 3pm`. | Cron-style automation, daily/weekly tasks. |

## Skills (model-invoked)

These trigger automatically when relevant — you don't need to type the name:

| Skill | Triggers on |
|---|---|
| `update-config` | "allow X", "add permission", "set env var", "when claude stops do X", hooks, settings.json. |
| `keybindings-help` | "rebind ctrl+s", "add a chord shortcut", "customize keybindings". |
| `fewer-permission-prompts` | "reduce permission prompts" — scans transcripts and proposes an allowlist for `.claude/settings.json`. |
| `simplify` | "simplify this code", "review for reuse / quality / efficiency". |
| `claude-api` | When working with `anthropic` / `@anthropic-ai/sdk`, prompt caching, Anthropic SDK migrations. |

## Quick references

- `/help` — what commands are available right now
- `/config` — open Claude Code settings UI
- `/mcp` — list and manage MCP servers
- `/plugin` — list installed plugins, install/uninstall, switch marketplaces
