#!/bin/bash
CURRENT_DIR=$(pwd)
SCRIPT_DIR="$HOME/leerov-tools"
source $SCRIPT_DIR/pushRepo

push() {
    git_push "$@"
}

# Алиасы
alias k="osascript $SCRIPT_DIR/caps-to-esc.scpt"
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
(
    bash -c 'source "'"$SCRIPT_DIR"'/pushRepo"; git_push "${1:-Autocommit}"' "$SCRIPT_DIR" >/dev/null 2>&1
) &
disown

# Загружаем общий конфиг
[ -f "$SCRIPT_DIR/commonrc" ] && source "$SCRIPT_DIR/commonrc"

# Определяем ОС
OS_TYPE=$(uname)

if [ "$OS_TYPE" = "Darwin" ]; then
    [ -f "$SCRIPT_DIR/macrc" ] && source "$SCRIPT_DIR/macrc"
elif [ "$OS_TYPE" = "Linux" ]; then
    [ -f "$SCRIPT_DIR/linuxrc" ] && source "$SCRIPT_DIR/linuxrc"
fi

cd "$CURRENT_DIR"