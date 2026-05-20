# VHS tape — ios-workflow-claude demo
# Run: vhs .local/demo.tape
# Output: .local/demo.gif (~60s)

Output .local/demo.gif

# Sobrescreve PS1 herdado da shell do user (que tem `$(notifyme)` que não existe no bash do VHS)
Env PS1 "$ "
Env PROMPT_COMMAND ""

Set FontSize 18
Set FontFamily "JetBrains Mono"
Set Width 800
Set Height 500
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 50ms
Set PlaybackSpeed 1.0

# Beat 1 (0-6s): clean prompt, contexto
Type "cd ~/Desktop/demo-ios-app"
Enter
Sleep 1s
Type "ls"
Enter
Sleep 2s

# Beat 2 (6-18s): adicionar marketplace via CLI não-interativo
Type "claude plugin marketplace add carloshpdoc/ios-workflow-claude"
Enter
Sleep 4s

# Beat 3 (18-30s): instalar o plugin standalone (xcode-build-suite, sem placeholders)
Type "claude plugin install xcode-build-suite@carloshpdoc-plugins"
Enter
Sleep 4s

# Beat 4 (30-45s): listar pra mostrar o plugin instalado
Type "claude plugin list"
Enter
Sleep 4s

# Beat 5 (45-55s): frame final com link
Type "# full kit: github.com/carloshpdoc/ios-workflow-claude"
Sleep 4s
