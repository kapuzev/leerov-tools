#!/bin/bash
CURRENT_DIR=$(pwd)
SCRIPT_DIR="$HOME/leerov-tools"
cd "$SCRIPT_DIR"
source env.sh
source pushRepo

# Определяем ОС
OS_TYPE=$(uname)

# Создать папку с правами 755 (чтение для всех)
mkdir -p /opt/goinfre/$(whoami)
chmod -R 755 /opt/goinfre/$(whoami)

push() {
    git_push "$@"
}

# Алиасы
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
chmod +x pushRepo
(
    bash -c 'source pushRepo; git_push "${1:-Autocommit}"' >/dev/null 2>&1
) &
disown

# Загружаем общий конфиг
[ -f commonrc ] && source commonrc

if [ "$OS_TYPE" = "Darwin" ]; then
    [ -f macrc ] && source macrc
elif [ "$OS_TYPE" = "Linux" ]; then
    [ -f linuxrc ] && source linuxrc
fi

# Fastfetch and clear
if ! command -v fastfetch &> /dev/null; then
    command -v brew &> /dev/null || brewSetup
    brew install fastfetch
fi
clear
fastfetch

# Space in goinfre
echo "💾 Goinfre: $(df -h /opt/goinfre/$(whoami) 2>/dev/null | tail -1 | awk '{print $3 "/" $2 " (" $5 ")"}' || echo "N/A")"
echo ""


cd "$CURRENT_DIR"
