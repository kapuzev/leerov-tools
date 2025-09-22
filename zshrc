#!/bin/bash
SCRIPT_DIR="$HOME/leerov-tools"

# Алиасы
alias push="bash push"
alias la="ls -la"
alias p="bash peer-review.sh"
alias f="bash clang-format-and-cppcheck.sh"
alias c="bash clean.sh"
alias r="bash crun.sh"
alias s="bash save.sh"

alias tree="find . -not -path '*/\.*' -print | sed -e 's;[^/]*/;│   ;g;s;│   \([^/]*$\);└── \1;'"

code() {
  target="$1"
  if [ -z "$target" ]; then
    wsfile=$(find . -maxdepth 1 -name "*.code-workspace" | head -n 1)
    if [ -n "$wsfile" ]; then
      open -a "Visual Studio Code" "$wsfile" --args --profile "21"
    else
      open -a "Visual Studio Code" . --args --profile "21"
    fi
  else
    open -a "Visual Studio Code" "$target" --args --profile "21"
  fi
}

# Автозагрузка при входе

chmod +x "$SCRIPT_DIR/pullRepo"
"$SCRIPT_DIR/pullRepo"
chmod +x "$SCRIPT_DIR/pushRepo"
"$SCRIPT_DIR/pushRepo"