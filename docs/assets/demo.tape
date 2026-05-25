# VHS tape - ios-workflow-claude demo
# Run from the repo root:
#   vhs docs/assets/demo.tape
# Output: docs/assets/demo.gif (~45s)

Output docs/assets/demo.gif

# Overwrite PS1 inherited from the user's shell (oh-my-zsh / starship / etc. break VHS rendering)
Env PS1 "$ "
Env PROMPT_COMMAND ""

# Force placeholder identity so bootstrap.sh's summary does not capture the real git config
Env GIT_USER "My Name"
Env GIT_NAME "My Name"
Env GIT_EMAIL "me@example.com"

Set FontSize 16
Set FontFamily "JetBrains Mono"
Set Width 960
Set Height 620
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 40ms
Set PlaybackSpeed 1.0

# Silent setup: clean temp install target. Assumes you ran vhs from the repo root.
Hide
Type "rm -rf /tmp/demo-ios-app && mkdir -p /tmp/demo-ios-app"
Enter
Type "clear"
Enter
Show

# Beat 1 (0-18s): run the interactive bootstrap and answer the prompts
Type "./bootstrap.sh --interactive --target /tmp/demo-ios-app/.claude --commands 'verified-pr,swift6-*,apollo-*,stacked-prs,open-pr'"
Enter
Sleep 1500ms

# Prompt order from bootstrap.sh: App / App_Tests (default offered) / Ticket / Jira / Owner / Handle / Bundle
Type "MyApp"
Enter
Sleep 500ms
Enter
Sleep 500ms
Type "PROJ"
Enter
Sleep 500ms
Type "mycorp.atlassian.net"
Enter
Sleep 500ms
Type "mycorp"
Enter
Sleep 500ms
Type "carlosh"
Enter
Sleep 500ms
Type "com.mycorp.myapp"
Enter
Sleep 4s

# Beat 2 (18-26s): show the freshly installed commands
Type "ls /tmp/demo-ios-app/.claude/commands/"
Enter
Sleep 4s

# Beat 3 (26-38s): show one command with the placeholders substituted to real values
Type "head -18 /tmp/demo-ios-app/.claude/commands/verified-pr.md"
Enter
Sleep 6s

# Beat 4 (38-46s): CTA on two lines to avoid mid-URL wrapping
Type "echo '22 commands + 9 skills + 3 agents.'"
Enter
Type "echo 'github.com/carloshpdoc/ios-workflow-claude'"
Enter
Sleep 4s
