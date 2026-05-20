#!/usr/bin/env bash
#
# bootstrap.sh — install ios-workflow-claude into a project (.claude/) or globally (~/.claude/)
#
# Usage:
#   ./bootstrap.sh [options]
#
# Run inside the target project (cwd becomes the install target) or pass --target.

set -euo pipefail

# ----- repo self-location ----------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${IOS_WORKFLOW_CLAUDE_REPO:-${SKILLS_CLAUDE_REPO:-$SCRIPT_DIR}}"

# ----- defaults --------------------------------------------------------------
TARGET_DIR=""
MODE="project"          # project | global
SYMLINK=false
SKIP_SUBSTITUTION=false
DRY_RUN=false
FORCE=false
INTERACTIVE=false

INCLUDE_COMMANDS=true
INCLUDE_SKILLS=true
INCLUDE_AGENTS=true
INCLUDE_BIN=false       # off by default — many projects don't use local-fast/smart

COMMANDS_FILTER=""      # comma-separated globs; empty = all
SKILLS_FILTER=""

# Placeholder values (read from CLI or git config or env)
APP="${APP:-}"
APP_TESTS="${APP_TESTS:-}"
TICKET_PREFIX="${TICKET_PREFIX:-}"
JIRA_HOST="${JIRA_HOST:-}"
GITHUB_OWNER="${GITHUB_OWNER:-}"
GITHUB_HANDLE="${GITHUB_HANDLE:-}"
BUNDLE_ID="${BUNDLE_ID:-}"
BUNDLE_ID_PREFIX="${BUNDLE_ID_PREFIX:-}"
PROJECT_DIR="${PROJECT_DIR:-}"
FONT_SCALE_TYPE="${FONT_SCALE_TYPE:-}"
FONT_SIZE_TYPE="${FONT_SIZE_TYPE:-}"
COMPANY_HANDLE="${COMPANY_HANDLE:-}"
GIT_USER="${GIT_USER:-$(git config user.name 2>/dev/null || echo "")}"
GIT_NAME="${GIT_NAME:-$GIT_USER}"
GIT_EMAIL="${GIT_EMAIL:-$(git config user.email 2>/dev/null || echo "")}"

# ----- helpers ---------------------------------------------------------------
say()  { printf "\033[1;34m▶\033[0m %s\n" "$*"; }
ok()   { printf "\033[1;32m✓\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!\033[0m %s\n" "$*" >&2; }
die()  { printf "\033[1;31m✗\033[0m %s\n" "$*" >&2; exit 1; }
run()  { if $DRY_RUN; then echo "  (dry-run) $*"; else eval "$*"; fi; }

usage() {
  cat <<'EOF'
bootstrap.sh — install ios-workflow-claude commands, skills, agents

USAGE
  ./bootstrap.sh [options]

INSTALL MODES
  (default)              Install to ./.claude/ — copies files, substitutes placeholders
  --global               Install to ~/.claude/ — symlinks files, skips substitution
  --target <path>        Custom install root (overrides project / global)

PLACEHOLDER VALUES (required for project install; ignored for --global)
  --app <name>           App / scheme name                 → {{APP}}
  --tests <name>         Test target (default: <app>Tests) → {{APP_TESTS}}
  --ticket <prefix>      Jira project key (e.g. PROJ)      → {{TICKET_PREFIX}}
  --jira <host>          Jira hostname                     → {{JIRA_HOST}}
  --owner <name>         GitHub org or user                → {{GITHUB_OWNER}}
  --handle <name>        Your GitHub handle                → {{GITHUB_HANDLE}}
  --bundle-id <id>       iOS bundle id                     → {{BUNDLE_ID}}
  --bundle-prefix <p>    iOS bundle id prefix              → {{BUNDLE_ID_PREFIX}}
  --project-dir <name>   Repo dir name (default: basename) → {{PROJECT_DIR}}
  --font-scale <type>    DS font scale type                → {{FONT_SCALE_TYPE}}
  --font-size <type>     DS font size type                 → {{FONT_SIZE_TYPE}}
  --company <name>       Company handle / domain           → {{COMPANY_HANDLE}}
  --git-user <name>      (auto from `git config user.name`)
  --git-email <addr>     (auto from `git config user.email`)

WHAT TO INSTALL
  --no-commands          Skip commands/
  --no-skills            Skip skills/
  --no-agents            Skip agents/
  --bin                  Install bin/ wrapper scripts (off by default — for local-fast/smart)
  --commands <pattern>   Comma-separated globs, e.g. "verified-pr,code-review,swift6-*"
  --skills <pattern>     Same, applied to skills/ folder names

BEHAVIOR
  --symlink              Use symlinks even for project install (implies --skip-substitution)
  --skip-substitution    Don't run sed (leave {{PLACEHOLDERS}} as-is)
  --force                Overwrite existing files in target
  --interactive          Prompt for any missing placeholder
  --dry-run              Print what would happen, don't write
  -h, --help             This help

EXAMPLES
  # Per-project install with all placeholders set
  ./bootstrap.sh --app MyApp --ticket PROJ --owner mycorp --handle myhandle \
                 --jira mycorp.atlassian.net --bundle-id com.mycorp.myapp

  # Just the PR workflow + code review, nothing else
  ./bootstrap.sh --app MyApp --ticket PROJ --owner mycorp --handle myhandle \
                 --commands "verified-pr,code-review,stacked-prs,create-pr-*,request-review,update-jira" \
                 --no-skills --no-agents

  # Globally symlink everything to ~/.claude/ (skip placeholders)
  ./bootstrap.sh --global

  # Global install but include bin/ scripts too (for ollama-backed skills)
  ./bootstrap.sh --global --bin

  # Interactive mode — asks for any missing field
  ./bootstrap.sh --interactive
EOF
}

# ----- arg parsing -----------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --app)              APP="$2"; shift 2 ;;
    --tests)            APP_TESTS="$2"; shift 2 ;;
    --ticket)           TICKET_PREFIX="$2"; shift 2 ;;
    --jira)             JIRA_HOST="$2"; shift 2 ;;
    --owner)            GITHUB_OWNER="$2"; shift 2 ;;
    --handle)           GITHUB_HANDLE="$2"; shift 2 ;;
    --bundle-id)        BUNDLE_ID="$2"; shift 2 ;;
    --bundle-prefix)    BUNDLE_ID_PREFIX="$2"; shift 2 ;;
    --project-dir)      PROJECT_DIR="$2"; shift 2 ;;
    --font-scale)       FONT_SCALE_TYPE="$2"; shift 2 ;;
    --font-size)        FONT_SIZE_TYPE="$2"; shift 2 ;;
    --company)          COMPANY_HANDLE="$2"; shift 2 ;;
    --git-user)         GIT_USER="$2"; GIT_NAME="$2"; shift 2 ;;
    --git-email)        GIT_EMAIL="$2"; shift 2 ;;
    --target)           TARGET_DIR="$2"; shift 2 ;;
    --global)           MODE="global"; shift ;;
    --commands)         COMMANDS_FILTER="$2"; shift 2 ;;
    --skills)           SKILLS_FILTER="$2"; shift 2 ;;
    --no-commands)      INCLUDE_COMMANDS=false; shift ;;
    --no-skills)        INCLUDE_SKILLS=false; shift ;;
    --no-agents)        INCLUDE_AGENTS=false; shift ;;
    --bin)              INCLUDE_BIN=true; shift ;;
    --symlink)          SYMLINK=true; SKIP_SUBSTITUTION=true; shift ;;
    --skip-substitution) SKIP_SUBSTITUTION=true; shift ;;
    --dry-run)          DRY_RUN=true; shift ;;
    --force)            FORCE=true; shift ;;
    --interactive)      INTERACTIVE=true; shift ;;
    -h|--help)          usage; exit 0 ;;
    *)                  die "Unknown argument: $1 (try --help)" ;;
  esac
done

# ----- resolve target --------------------------------------------------------
if [[ -z "$TARGET_DIR" ]]; then
  if [[ "$MODE" == "global" ]]; then
    TARGET_DIR="$HOME/.claude"
    SYMLINK=true
    SKIP_SUBSTITUTION=true
  else
    TARGET_DIR="$(pwd)/.claude"
  fi
fi

# ----- interactive prompts (project install only) ---------------------------
prompt() {
  local var_name="$1" label="$2" default="${3:-}"
  local current="${!var_name}"
  [[ -n "$current" ]] && return
  if $INTERACTIVE; then
    if [[ -n "$default" ]]; then
      read -r -p "$label [$default]: " input
      printf -v "$var_name" "%s" "${input:-$default}"
    else
      read -r -p "$label: " input
      printf -v "$var_name" "%s" "$input"
    fi
  fi
}

if $INTERACTIVE && [[ "$MODE" != "global" ]]; then
  say "Interactive setup — press Enter to accept defaults shown in [brackets]"
  prompt APP             "App / scheme name (replaces {{APP}})"
  prompt APP_TESTS       "Test target (replaces {{APP_TESTS}})" "${APP}Tests"
  prompt TICKET_PREFIX   "Jira project key (e.g. PROJ)"
  prompt JIRA_HOST       "Jira host (e.g. mycorp.atlassian.net)"
  prompt GITHUB_OWNER    "GitHub org/user"
  prompt GITHUB_HANDLE   "Your GitHub handle"
  prompt BUNDLE_ID       "iOS bundle id (or leave empty)"
fi

# Apply derived defaults
[[ -z "$APP_TESTS"   && -n "$APP" ]] && APP_TESTS="${APP}Tests"
[[ -z "$PROJECT_DIR"            ]] && PROJECT_DIR="$(basename "$(pwd)")"
[[ -z "$GIT_NAME"               ]] && GIT_NAME="$GIT_USER"

# ----- validate --------------------------------------------------------------
if [[ ! -d "$REPO_DIR/commands" || ! -d "$REPO_DIR/skills" ]]; then
  die "Cannot find ios-workflow-claude repo at: $REPO_DIR (set IOS_WORKFLOW_CLAUDE_REPO env var to override)"
fi

if [[ "$MODE" != "global" && ! $SKIP_SUBSTITUTION ]]; then
  [[ -z "$APP" ]]            && warn "{{APP}} placeholder will be left literal (pass --app)"
  [[ -z "$TICKET_PREFIX" ]]  && warn "{{TICKET_PREFIX}} placeholder will be left literal (pass --ticket)"
fi

# ----- summary ---------------------------------------------------------------
say "ios-workflow-claude bootstrap"
echo "  source:        $REPO_DIR"
echo "  target:        $TARGET_DIR"
echo "  mode:          $MODE ($([[ "$SYMLINK" == "true" ]] && echo "symlink" || echo "copy"))"
echo "  substitution:  $([[ "$SKIP_SUBSTITUTION" == "true" ]] && echo "off" || echo "on")"
echo "  include:       $($INCLUDE_COMMANDS && echo -n "commands ")$($INCLUDE_SKILLS && echo -n "skills ")$($INCLUDE_AGENTS && echo -n "agents ")$($INCLUDE_BIN && echo -n "bin ")"
if [[ "$MODE" != "global" && "$SKIP_SUBSTITUTION" == "false" ]]; then
  echo "  placeholders:"
  for v in APP APP_TESTS TICKET_PREFIX JIRA_HOST GITHUB_OWNER GITHUB_HANDLE BUNDLE_ID BUNDLE_ID_PREFIX PROJECT_DIR FONT_SCALE_TYPE FONT_SIZE_TYPE COMPANY_HANDLE GIT_USER GIT_NAME GIT_EMAIL; do
    val="${!v}"
    [[ -n "$val" ]] && printf "    %-20s = %s\n" "$v" "$val"
  done
fi
echo

# ----- install ---------------------------------------------------------------
install_one() {
  # $1 = src path, $2 = dst path
  local src="$1" dst="$2"
  if [[ -e "$dst" || -L "$dst" ]]; then
    if $FORCE; then
      run "rm -rf '$dst'"
    elif $SYMLINK && [[ -L "$dst" ]]; then
      run "rm '$dst'"
    else
      warn "skip (already exists): $dst — use --force to overwrite"
      return
    fi
  fi
  if $SYMLINK; then
    run "ln -s '$src' '$dst'"
  else
    run "cp -R '$src' '$dst'"
  fi
}

matches_filter() {
  # $1 = name, $2 = comma-separated globs (empty = match all)
  local name="$1" filter="$2"
  [[ -z "$filter" ]] && return 0
  IFS=',' read -ra patterns <<< "$filter"
  for pat in "${patterns[@]}"; do
    # shellcheck disable=SC2053
    [[ "$name" == $pat ]] && return 0
  done
  return 1
}

run "mkdir -p '$TARGET_DIR'"

if $INCLUDE_COMMANDS; then
  say "Installing commands → $TARGET_DIR/commands/"
  run "mkdir -p '$TARGET_DIR/commands'"
  for f in "$REPO_DIR"/commands/*.md; do
    name="$(basename "$f" .md)"
    matches_filter "$name" "$COMMANDS_FILTER" || continue
    install_one "$f" "$TARGET_DIR/commands/$(basename "$f")"
  done
fi

if $INCLUDE_SKILLS; then
  say "Installing skills → $TARGET_DIR/skills/"
  run "mkdir -p '$TARGET_DIR/skills'"
  for d in "$REPO_DIR"/skills/*/; do
    name="$(basename "$d")"
    matches_filter "$name" "$SKILLS_FILTER" || continue
    install_one "${d%/}" "$TARGET_DIR/skills/$name"
  done
fi

if $INCLUDE_AGENTS; then
  say "Installing agents → $TARGET_DIR/agents/"
  run "mkdir -p '$TARGET_DIR/agents'"
  for f in "$REPO_DIR"/agents/*.md; do
    install_one "$f" "$TARGET_DIR/agents/$(basename "$f")"
  done
fi

if $INCLUDE_BIN; then
  say "Installing bin/ → $TARGET_DIR/bin/"
  run "mkdir -p '$TARGET_DIR/bin'"
  for f in "$REPO_DIR"/bin/*.sh; do
    install_one "$f" "$TARGET_DIR/bin/$(basename "$f")"
    $SYMLINK || run "chmod +x '$TARGET_DIR/bin/$(basename "$f")'"
  done
fi

# ----- substitution ----------------------------------------------------------
substitute() {
  if $SKIP_SUBSTITUTION || $SYMLINK; then
    return
  fi
  say "Substituting placeholders in $TARGET_DIR/"
  local -a seds=()
  add_sed() {
    local placeholder="$1" value="$2"
    [[ -z "$value" ]] && return
    # Escape | and & for sed
    value="${value//&/\\&}"
    seds+=("-e" "s|{{$placeholder}}|$value|g")
  }
  add_sed APP              "$APP"
  add_sed APP_TESTS        "$APP_TESTS"
  add_sed TICKET_PREFIX    "$TICKET_PREFIX"
  add_sed JIRA_HOST        "$JIRA_HOST"
  add_sed GITHUB_OWNER     "$GITHUB_OWNER"
  add_sed GITHUB_HANDLE    "$GITHUB_HANDLE"
  add_sed BUNDLE_ID        "$BUNDLE_ID"
  add_sed BUNDLE_ID_PREFIX "$BUNDLE_ID_PREFIX"
  add_sed PROJECT_DIR      "$PROJECT_DIR"
  add_sed FONT_SCALE_TYPE  "$FONT_SCALE_TYPE"
  add_sed FONT_SIZE_TYPE   "$FONT_SIZE_TYPE"
  add_sed COMPANY_HANDLE   "$COMPANY_HANDLE"
  add_sed GIT_USER         "$GIT_USER"
  add_sed GIT_NAME         "$GIT_NAME"
  add_sed GIT_EMAIL        "$GIT_EMAIL"

  if [[ ${#seds[@]} -eq 0 ]]; then
    warn "no placeholder values supplied — nothing to substitute"
    return
  fi

  # macOS sed needs '' after -i; GNU sed doesn't. Detect.
  local sed_inplace=()
  if sed --version >/dev/null 2>&1; then
    sed_inplace=(-i)
  else
    sed_inplace=(-i '')
  fi

  while IFS= read -r -d '' f; do
    if $DRY_RUN; then
      echo "  (dry-run) sed ... '$f'"
    else
      sed "${sed_inplace[@]}" "${seds[@]}" "$f"
    fi
  done < <(find "$TARGET_DIR" -type f -name "*.md" -print0)
}

substitute

echo
ok "Done."
echo
echo "Next steps:"
echo "  • Open Claude Code in this project — new slash commands appear in tab-completion."
[[ "$INCLUDE_BIN" == "true" && "$MODE" != "global" ]] && echo "  • For local-fast / local-smart: install ollama + pull models (see README)."
[[ "$MODE" == "global" ]] && echo "  • Commands installed globally are NOT substituted — set placeholders per-project via CLAUDE.md or shadow them in .claude/commands/."
