# Request PR Review

Send a message to the #{{PROJECT_DIR}} Slack channel requesting a PR review.

## Usage

```
/request-review <pr_number> [description]
```

**Arguments:**
- `pr_number` - The PR number to request review for
- `description` (optional) - Brief description of the changes

**Examples:**
```
/request-review 4315
/request-review 4315 "Fix white button color in Edit Photos screen"
```

## Instructions

When this skill is invoked:

1. **Parse arguments** from `$ARGUMENTS`:
   - Extract the PR number (required)
   - Extract optional description

2. **Get PR details** if no description provided:
   - Run `gh pr view <pr_number> --json title,url` to get PR info
   - Use the PR title as the description

3. **Detect the PR type** by reading the prefix in the title (`[FIX]`, `[FEATURE]`, `[REFACTOR]`, `[PERF]`, `[BUILD]`, `[CI]`, `[DOCS]`, `[STYLE]`, `[TEST]`):
   - This drives which playful opener to use (see "Tone & Templates" below)
   - If the prefix is missing, fall back to the generic opener

4. **Compose the message** using the templates below. Rules that always apply:
   - Tom descontraído, em português, curto e direto — sem `cc @...`
   - O time é marcado **inline** dentro da frase, usando `<!subteam^S058UQVG6MA|frontend>` (nunca como `cc`, nunca como footer)
   - Uma linha de chamada + título do PR em negrito + linha do link
   - **Nunca** acrescentar nenhuma assinatura, footer, ou texto do tipo "enviado por", "via Claude", "generated with...". A mensagem termina no link.

5. **Send the message** to #{{PROJECT_DIR}} channel:
   - Use `mcp__claude_ai_Slack__slack_send_message`
   - Channel: #{{PROJECT_DIR}} (ID: C04EL113PTK)

6. **Confirm success** to the user with the message link returned by the tool.

## Tone & Templates

Pick the template that matches the PR prefix. The team mention is woven into the sentence — not appended as `cc`.

### `[FIX]` — bug fix
```
:bug: cacei mais um bug, <!subteam^S058UQVG6MA|frontend> — alguém topa revisar?
*<PR title>*
:link: <PR URL>
```

### `[FEATURE]` — new feature
```
:sparkles: feature nova saindo do forno, <!subteam^S058UQVG6MA|frontend>! aceita revisar?
*<PR title>*
:link: <PR URL>
```

### `[REFACTOR]` — refactor / cleanup
```
:broom: refactor caprichado pra <!subteam^S058UQVG6MA|frontend> dar aquele olhar crítico:
*<PR title>*
:link: <PR URL>
```

### `[PERF]` — performance
```
:rocket: deixei o app um tiquinho mais rápido — <!subteam^S058UQVG6MA|frontend>, segura essa revisão?
*<PR title>*
:link: <PR URL>
```

### `[BUILD]` / `[CI]` — pipeline / build
```
:wrench: mexi no encanamento da build, <!subteam^S058UQVG6MA|frontend> — passa o olho aí?
*<PR title>*
:link: <PR URL>
```

### `[DOCS]` — documentation
```
:books: documentei aquela parte que ninguém entendia, <!subteam^S058UQVG6MA|frontend> — fica de olho?
*<PR title>*
:link: <PR URL>
```

### `[STYLE]` / `[TEST]` — formatting / tests
```
:test_tube: PR sem mistério, <!subteam^S058UQVG6MA|frontend> — revisão rapidinha?
*<PR title>*
:link: <PR URL>
```

### Generic fallback (prefix desconhecido / ausente)
```
:eyes: PR fresquinho pra <!subteam^S058UQVG6MA|frontend> dar uma olhada:
*<PR title>*
:link: <PR URL>
```

## Notes

- **Sem footer "via Claude":** o Slack adiciona automaticamente uma atribuição quando o app Claude posta em nome do usuário — isso é controlado pelo Slack, não pelo conteúdo da mensagem. Mesmo que essa linha apareça abaixo do post, **nunca a duplique no corpo da mensagem**, nem com variações (ex.: "enviado por", "generated with", "🤖 Claude Code").
- A mensagem termina no `:link:`. Nada de PS, nada de assinatura, nada de "cc".
- Mantenha o tom leve mas sem exagerar — o objetivo é ser convidativo, não comediante.
- O grupo `<!subteam^S058UQVG6MA|frontend>` deve aparecer **uma única vez** e dentro da primeira linha.
