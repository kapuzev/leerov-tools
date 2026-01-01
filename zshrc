#!/bin/bash
CURRENT_DIR=$(pwd)
SCRIPT_DIR="$HOME/leerov-tools"
cd "$SCRIPT_DIR"
source env.sh
source pushRepo.sh
source poolReview.sh

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

settings(){
(
    python3 -c 'python3 leerov-tools/settings.py' >/dev/null 2>&1
) &
disown
}


qr() {
    if [ $# -eq 0 ]; then
        # Если нет аргументов, читаем из stdin
        if [ -t 0 ]; then
            echo "Usage: qr <text>"
            return 1
        else
            local text=$(cat)
            local encoded_text=$(echo "$text" | sed 's/ /%20/g')
            local url="qrenco.de/$encoded_text"
            
            echo "$url"
            echo "$text" | curl -s -F-=\<- qrenco.de
        fi
    else
        # Если есть аргументы, используем их
        local text="$*"
        local encoded_text=$(echo "$text" | sed 's/ /%20/g')
        local url="qrenco.de/$encoded_text"
        
        echo "$url"
        echo "$text" | curl -s -F-=\<- qrenco.de
    fi
}

# Модификация PATH
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"

# Автозагрузка при входе 
chmod +x pushRepo.sh
(
    bash -c 'source pushRepo.sh; git_push "${1:-Autocommit}"' >/dev/null 2>&1
) &
disown

# Загружаем общий конфиг
[ -f commonrc ] && source commonrc

if [ "$OS_TYPE" = "Darwin" ]; then
    [ -f macrc ] && source macrc
elif [ "$OS_TYPE" = "Linux" ]; then
    [ -f linuxrc ] && source linuxrc
fi



# Space in goinfre
echo "📁 Вес вашей папки Goinfre: $(du -sh /opt/goinfre/$(whoami) | cut -f1)"
echo "💾 Диск: Использовано/Свободно/Всего (Заполнено): $(df -h /opt/goinfre/$(whoami) 2>/dev/null | tail -1 | awk '{print $3 " / " $4 " / " $2 " (" $5 ")"}' || echo "N/A")"
echo ""


cd "$CURRENT_DIR"
