#!/bin/bash
SCRIPT_DIR="$HOME/leerov-tools"
source $SCRIPT_DIR/pushRepo

# Алиасы
alias push="git_push"
alias la="ls -la"
alias p="bash $SCRIPT_DIR/peer-review.sh"
alias f="bash $SCRIPT_DIR/clang-format-and-cppcheck.sh"
alias c="bash $SCRIPT_DIR/clean.sh"
alias r="bash $SCRIPT_DIR/crun.sh"
alias s="bash $SCRIPT_DIR/save.sh"

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
cd "$SCRIPT_DIR"
chmod +x "$SCRIPT_DIR/pushRepo"
git_push "$@" &
cd