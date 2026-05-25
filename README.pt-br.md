# ios-workflow-claude

[English](README.md) · **Português brasileiro**

Slash-commands, skills e workflows reutilizáveis do Claude Code, extraídos de projetos iOS / backend reais. Solta na pasta `.claude/` de qualquer repo, ou conecta no `~/.claude/` global.

![demo](docs/assets/demo.gif)

Os arquivos `.md` em `commands/` e `skills/` são **templates** - eles referenciam seu projeto via `{{PLACEHOLDERS}}` (ver abaixo) que você substitui uma vez por projeto.

> O GIF acima é reproduzível - veja [`docs/assets/demo.tape`](docs/assets/demo.tape). Instale o [VHS](https://github.com/charmbracelet/vhs) (`brew install vhs`) e rode `vhs docs/assets/demo.tape`.

---

## Por que isso existe

Existem bons kits de Claude Code para iOS, e bons kits para automação de workflow. Não existe nenhum que faça as duas coisas.

| Kit | O que cobre | O que não cobre |
|---|---|---|
| [keskinonur/claude-code-ios-dev-guide](https://github.com/keskinonur/claude-code-ios-dev-guide) (705⭐) | Agent de arquitetura iOS, specialist SwiftUI, reviewer Swift | Jira, PRs via `gh`, stacked PRs, Apollo→native, cleanup de feature-flag, playbook de perf, fixer SwiftLint |
| [schovi/claude-schovi](https://github.com/schovi/claude-schovi) (MIT) | Auto-detect de Jira, `/review`, `/publish` | Qualquer coisa de iOS |
| [kylehughes/apple-platform-build-tools](https://github.com/kylehughes/apple-platform-build-tools-claude-code-plugin) (57⭐) | Wrapper de `xcodebuild` / simctl / devicectl, subagent builder | Automação de workflow |
| **`ios-workflow-claude`** (este repo) | **A interseção.** Pipeline de migração Swift 6, remoção do Apollo SDK→native, stacked PRs ≤600 linhas, abertura de PR via Jira, orchestrator de build Xcode, playbook de perf com pattern matching concreto, fixer SwiftLint | - |

Duas coisas aqui que não achei em nenhum outro lugar público:

- Um **pipeline completo de migração Swift 6** (`/swift6-check` → `/swift6-fix` uma categoria por vez → `/swift6-status`). A maioria dos kits te dá um reviewer Swift que sinaliza issues; este aqui roda o loop até acabar.
- Um **padrão generalizável de remoção de SDK** (`/apollo-*`). Cinco comandos construídos pra remover Apollo iOS, mas o padrão - investigar um repo → migrar para uma substituição baseada em protocolo com testes obrigatórios → self-review → stacked PRs - mapeia pra qualquer troca de SDK: Realm → SwiftData, Combine → async/await, networking custom → URLSession.

O sistema de templates `{{PLACEHOLDER}}` + `bootstrap.sh --interactive` também é raro - a maioria dos kits ou hardcoda paths ou espera que você faça fork e edite na mão.

**Não é pra você se:** você não trabalha com iOS, não usa Jira, ou seu time não despacha código via PRs do GitHub revisadas via `gh`. O plugin `xcode-build-suite` é a parte mais agnóstica de stack - instala só ele se otimização de build do Xcode é tudo que você quer.

---

## O que tem aqui

### `commands/` - slash commands

| Comando | O que faz | Aciona em |
|---|---|---|
| `swift6-check` / `swift6-fix` / `swift6-status` | Migração de concorrência Swift 6: scan → fix uma categoria por vez → tracking de progresso. | Codebases Swift indo de 5 → 6 |
| `apollo-check` / `apollo-migrate` / `apollo-review` / `apollo-status` / `apollo-tasks` | Pipeline de remoção do Apollo iOS SDK: investigar um repo → migrar pra `GraphQLClientProtocol` nativo com testes obrigatórios → self-review → PR. O padrão generaliza pra **qualquer remoção de SDK** (Realm → SwiftData, Combine → async/await, etc.). | Projetos iOS no Apollo |
| `feature-flag-check` / `feature-flag-remove` / `feature-flag-completed` / `feature-flag-status` | Cleanup de feature-flag: tracear a cadeia de dependências → remover código morto → testes → post no Slack/Notion. | Qualquer codebase com flags |
| `code-review` | Aplica padrões de DRY / SOLID / naming / formatação nos arquivos modificados. | Depois da implementação, antes do PR |
| `stacked-prs` | Divide uma branch em commits semânticos e PRs upstream stacked de ≤600 linhas cada. | Branches grandes com múltiplas preocupações |
| `verified-pr` | Gate: full build local + testes passando **antes** de abrir um PR. Use quando o CI não roda testes em PRs. | Projetos iOS |
| `create-pr-from-staged-changes` | Abre um PR direto a partir das mudanças staged (pula os gates de build/test). | PRs rápidos |
| `request-review` | Re-request review em um PR existente. | PRs existentes |
| `update-jira` | Atualiza uma task do Jira com link/status do PR. | Workflows orientados a Jira |
| `perf-investigate` | Playbook de investigação de performance / leak (Time Profiler + memgraph). | "App tá lento", "suspeita de leak" |
| `bump` | Bump da versão do app / build number em todos os targets do Xcode. | Pré-release iOS |
| `open-pr` | PR opener opinionated: detecta ticket do Jira a partir da branch, anexa screenshots de evidência, transiciona o status no Jira. | Workflows orientados a Jira |
| `review-pr` | Code review amigável em uma branch ou número de PR - posta comentários inline via `gh`. | Revisando PR de colegas |

### `skills/` - skills invocadas pelo modelo

| Skill | O que faz |
|---|---|
| `create-tasks` | Transforma notas de reunião / specs / descrições de feature em tasks do Jira com sequenciamento, dependências e critérios de aceitação. |
| `xcode-build-orchestrator` + `xcode-build-benchmark` + `xcode-compilation-analyzer` + `xcode-project-analyzer` + `xcode-build-fixer` | Otimização ponta-a-ponta de tempo de build do Xcode: benchmark → analyze (compile / project / SPM) → recommend → apply com aprovação → re-benchmark. |
| `spm-build-analysis` | Auditoria de dependências SwiftPM, plugins, variantes de módulo, overhead de CI. |
| `content` | Vira trabalho técnico recente (bug fix / release / case study) em rascunhos de LinkedIn / Twitter / Instagram. Salva em `/content/drafts/`. Atua tanto reativamente (`/content linkedin <tópico>`) quanto proativamente (sugere ao final de sessões content-worthy). |
| `knowledge` | Busca federada + lifecycle para docs `.md` em `~/Desktop/knowledge/`, no repo atual, e no diretório de memory do Claude. Subcomandos: `stale`, `drafts`, `related`, `suggest`, `new`, `index`. |
| `local-fast` / `local-smart` | Delega tarefas de baixo risco / reasoning pesado a um LLM local via ollama. **Requer:** `bin/qwen-task.sh` + `bin/dots-task.sh` colocados em `.claude/bin/` do projeto, mais ollama com os modelos referenciados puxados. Veja [`bin/`](bin/) para os scripts wrapper. |

### `agents/` - subagents especializados

Solta em `.claude/agents/` (ou `~/.claude/agents/`) e eles ficam disponíveis via a tool Agent.

| Agent | Use pra |
|---|---|
| `ios-code-reviewer` | Code review de Swift / iOS - proativamente depois de features, refactors, ou antes de PRs. Retorna findings priorizados com rationale. |
| `ios-test-writer` | Geração de suite de XCTest com mocking apropriado. Aciona em "write tests", "add coverage", ou após novas features. |
| `swiftlint-fixer` | Checa + corrige violações do SwiftLint contra o `.swiftlint.yml` do projeto. |

### Plugins de terceiros (recomendados - instalar via marketplace)

Esses são entregues como plugins do Claude Code. Não copie eles aqui - instale via marketplace pra receber atualizações upstream. Veja [`docs/PLUGINS.md`](docs/PLUGINS.md) para os passos de instalação em um comando.

- `ios-swift-skills` (Patrick Serrano, MIT) - SwiftUI performance audit, profiling de app nativo via `xctrace`, expert em Swift concurrency, refactor de SwiftUI view, padrões SwiftUI, Liquid Glass (iOS 26+), agent debugger iOS, changelog de release na App Store, empacotamento SPM macOS
- `memorydetective` (Apache 2.0) - Playbooks disciplinados de investigação de perf + leak iOS via MCP
- `codex` (OpenAI, Apache 2.0) - Delega tasks travadas / second-opinion ao Codex CLI (`/codex:setup`, `/codex:rescue`)
- `code-review` (oficial) - Comando genérico de code review
- `security-guidance` (oficial) - `/security-review` pra mudanças pendentes
- `pr-review-toolkit` (oficial) - `/review` de PR + subagents (simplifier, comment-analyzer, type-design)

### Built into Claude Code (sem instalação)

Disponível out of the box - só invocar. Veja [`docs/BUILTINS.md`](docs/BUILTINS.md) pra descrições curtas.

- `/init` - bootstrap do `CLAUDE.md` a partir do codebase atual
- `/loop` - roda um prompt / slash command em intervalos ou auto-pacing
- `/schedule` - agents remotos agendados estilo cron
- `claude-api` - build/debug de apps com o SDK Anthropic (caching, migração de modelo)
- Skills: `update-config` (hooks/permissões/env), `keybindings-help`, `fewer-permission-prompts`, `simplify`, `init`

---

## Quickstart

```bash
# Uma vez por máquina: clone o repo em um lugar estável
git clone git@github.com:carloshpdoc/ios-workflow-claude.git ~/Development/ios-workflow-claude

# Por projeto: rode o bootstrap com os identificadores do projeto
cd /path/to/new-project
~/Development/ios-workflow-claude/bootstrap.sh \
  --app MyApp \
  --ticket PROJ \
  --owner mycorp \
  --handle myhandle \
  --jira mycorp.atlassian.net \
  --bundle-id com.mycorp.myapp
```

Isso copia commands + skills + agents em `./.claude/` e substitui cada `{{PLACEHOLDER}}` pelos valores que você passou. Os novos slash commands aparecem no tab-completion do Claude Code imediatamente.

## Instalação

### Opção A - `bootstrap.sh` (recomendada)

O repo tem um `bootstrap.sh` auto-localizável que faz copy + substituição de placeholder. Escolha a variante que cabe na sua situação:

| # | Cenário | Comando |
|---|---|---|
| a | **Instalação padrão no projeto** - copia todos os commands/skills/agents e substitui placeholders | `bootstrap.sh --app MyApp --ticket PROJ --owner mycorp --handle myhandle --jira mycorp.atlassian.net --bundle-id com.mycorp.myapp` |
| b | **Interativa** - pergunta cada placeholder faltante, aceita defaults do `git config` | `bootstrap.sh --interactive` |
| c | **Só workflow de PR** - sem skills/agents, só os comandos de PR | `bootstrap.sh --app MyApp --ticket PROJ --owner o --handle h --commands "verified-pr,code-review,stacked-prs,create-pr-*,request-review,update-jira" --no-skills --no-agents` |
| d | **Instalação global** - symlinks tudo em `~/.claude/` (placeholders ficam literais, atualizações propagam do repo) | `bootstrap.sh --global` |
| e | **Dry-run preview** - imprime cada ação sem escrever | `bootstrap.sh --interactive --dry-run` |

Adiciona `--bin` em qualquer uma pra também instalar os scripts wrapper em `bin/` (necessário pra `local-fast` / `local-smart`).

Adiciona `--force` pra sobrescrever arquivos existentes no target.

Rode `bootstrap.sh --help` pra ver a lista completa de flags.

#### O que o script faz

- **Auto-localiza o repo** via `BASH_SOURCE` - sem paths hardcoded, funciona através de symlinks (`ln -sf ~/Development/ios-workflow-claude/bootstrap.sh ~/bin/ios-workflow-claude` e você pode rodar `ios-workflow-claude` de qualquer lugar).
- **Pega defaults do `git config`** - `--git-user` / `--git-email` vêm de `git config user.name` / `user.email` a menos que você sobrescreva.
- **Substitui só os placeholders que você fornece** - valores vazios ficam como `{{PLACEHOLDER}}` pra você poder rodar o script de novo depois pra preencher. Mesma lógica se aplica ao `--interactive`: pula um campo e ele fica literal.
- **Detecta o flavor do `sed`** - sed BSD do macOS e GNU sed ambos funcionam na substituição in-place.
- **Idempotente** - arquivos existentes são pulados com warning a menos que `--force` seja passado; symlinks são atualizados com segurança no modo `--global`.
- **Filtra por glob** - `--commands "verified-pr,swift6-*"` e `--skills "xcode-build-*"` aceitam globs separados por vírgula pra cherry-pick.
- **Opt-out granular** - `--no-commands`, `--no-skills`, `--no-agents` pulam categorias inteiras. `--bin` opta in aos scripts wrapper de ollama (off por default já que a maioria dos projetos não usa).

### Opção B - Cópia manual

Se preferir controlar os arquivos na mão:

```bash
# Escolhe e pega
mkdir -p .claude/commands .claude/skills
cp ~/Development/ios-workflow-claude/commands/verified-pr.md .claude/commands/
cp -R ~/Development/ios-workflow-claude/skills/xcode-build-orchestrator .claude/skills/
```

Depois ou faz o pass do `sed` (veja "Quick replace" abaixo) ou aceita os `{{PLACEHOLDERS}}` no output.

### Opção C - Globalmente para todos os projetos (symlink manual)

```bash
# Symlink (pra que atualizações aqui propaguem em todo lugar)
ln -sf ~/Development/ios-workflow-claude/commands/verified-pr.md ~/.claude/commands/verified-pr.md
ln -sf ~/Development/ios-workflow-claude/skills/xcode-build-orchestrator ~/.claude/skills/xcode-build-orchestrator
```

(Mesmo que `bootstrap.sh --global`, só que sem o script.)

### Opção D - Como plugin do Claude Code

Esse repo tem um `.claude-plugin/marketplace.json` com três plugins. Usuários instalam via:

```bash
/plugin marketplace add carloshpdoc/ios-workflow-claude
/plugin install xcode-build-suite@carloshpdoc-plugins      # otimizador standalone do Xcode (sem placeholders)
/plugin install ios-workflow@carloshpdoc-plugins           # comandos iOS + agents (cheio de placeholders - bootstrap.sh recomendado pra adoção)
/plugin install claude-utilities@carloshpdoc-plugins       # cross-stack: content, knowledge, create-tasks
```

O caminho de instalação via marketplace é melhor pra preview / teste rápido. Para substituição de placeholder por projeto, use `bootstrap.sh` (Opção A acima).

---

## Placeholders pra substituir por projeto

Esses templates usam placeholders `{{...}}`. Depois de copiar pra um projeto, faça um replace global uma vez:

| Placeholder | Significa | Valor exemplo |
|---|---|---|
| `{{APP}}` | Nome do app / scheme | `MyApp` |
| `{{APP_TESTS}}` | Nome do target de unit-test | `MyAppTests` |
| `{{PROJECT_DIR}}` | Nome do diretório do repo | `myapp-ios` |
| `{{TICKET_PREFIX}}` | Chave do projeto no Jira | `PROJ` |
| `{{JIRA_HOST}}` | Hostname do Jira | `mycompany.atlassian.net` |
| `{{GITHUB_OWNER}}` | Org/user do GitHub | `mycompany` |
| `{{GITHUB_HANDLE}}` | Seu handle no GitHub | `myhandle` |
| `{{BUNDLE_ID}}` | Bundle ID do iOS | `com.mycompany.myapp` |
| `{{BUNDLE_ID_PREFIX}}` | Prefixo do Bundle ID | `com.mycompany` |
| `{{GIT_USER}}` | Username git local | `myname` |
| `{{GIT_EMAIL}}` | Email do commit git | `me@example.com` |
| `{{GIT_NAME}}` | Nome de display nos commits | `My Name` |
| `{{FONT_SCALE_TYPE}}` | Tipo de font scale do design-system | `MyAppFontScale` |
| `{{FONT_SIZE_TYPE}}` | Tipo de font size do design-system | `MyAppFontSize` |
| `{{JIRA_BOARD_ID}}` | ID do board do Jira (usado pela skill `create-tasks`) | `42` |
| `{{FLAG_KEY_ENUM}}` | Nome do enum de feature-flag key | `FeatureFlagKey` |
| `{{FLAG_KEY_FILE}}` | Arquivo do feature-flag key (com `.swift`) | `FeatureFlagKey.swift` |
| `{{FLAG_DEFAULTS_FILE}}` | Arquivo/classe de defaults de feature-flag | `FeatureFlagDefaults` |

### Quick replace (macOS/Linux)

```bash
# Dentro da pasta .claude/ do seu projeto alvo
APP=MyApp
TESTS=MyAppTests
TICKET=PROJ
JIRA=mycompany.atlassian.net
OWNER=mycompany
HANDLE=myhandle
BOARD=42
FLAG_ENUM=FeatureFlagKey
FLAG_FILE=FeatureFlagKey.swift
FLAG_DEFAULTS=FeatureFlagDefaults

find .claude -name "*.md" -type f -exec sed -i '' \
  -e "s|{{APP}}|$APP|g" \
  -e "s|{{APP_TESTS}}|$TESTS|g" \
  -e "s|{{TICKET_PREFIX}}|$TICKET|g" \
  -e "s|{{JIRA_HOST}}|$JIRA|g" \
  -e "s|{{JIRA_BOARD_ID}}|$BOARD|g" \
  -e "s|{{GITHUB_OWNER}}|$OWNER|g" \
  -e "s|{{GITHUB_HANDLE}}|$HANDLE|g" \
  -e "s|{{FLAG_KEY_ENUM}}|$FLAG_ENUM|g" \
  -e "s|{{FLAG_KEY_FILE}}|$FLAG_FILE|g" \
  -e "s|{{FLAG_DEFAULTS_FILE}}|$FLAG_DEFAULTS|g" \
  {} +
```

---

## Layout

```
ios-workflow-claude/
├── commands/                # slash commands (.md por comando)
├── skills/                  # skills invocadas pelo modelo (uma pasta cada, com SKILL.md)
│   └── <skill>/
│       ├── SKILL.md
│       └── references/      # docs de apoio que a skill lê quando precisa
├── agents/                  # subagents especializados (.md, invocados via a tool Agent)
├── bin/                     # scripts helper referenciados por algumas skills (ex: local-fast/smart)
├── docs/
│   ├── PLUGINS.md           # passos de instalação dos plugins de terceiros
│   └── BUILTINS.md          # cheat sheet dos comandos built-in do Claude Code
└── README.md
```

## Setup para local-fast / local-smart (opcional)

Essas duas skills delegam pra LLMs locais via [ollama](https://ollama.com). Se você não usar, pula essa seção.

```bash
# 1. Instala ollama e puxa os modelos referenciados pelos wrappers
brew install ollama
ollama pull qwen3.5:35b-a3b-coding-nvfp4   # usado pelo local-fast
ollama pull dots.llm1                       # usado pelo local-smart

# 2. Solta os scripts wrapper em .claude/bin/ do seu projeto
mkdir -p .claude/bin
cp ~/Development/ios-workflow-claude/bin/*.sh .claude/bin/
chmod +x .claude/bin/*.sh
```

Se preferir modelos locais diferentes, edita os scripts em `bin/` - são wrappers de 3 linhas em volta de `ollama run <modelo>`.

## Licença

Os templates em `commands/` e `skills/` são liberados sob Apache 2.0 - veja [LICENSE](LICENSE).

Plugins de terceiros documentados em `docs/PLUGINS.md` mantêm suas próprias licenças (MIT para `ios-swift-skills`, Apache 2.0 para `codex` e `memorydetective`, licença Anthropic para o set oficial `claude-plugins-official`).
