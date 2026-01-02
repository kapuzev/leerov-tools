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
alias r="source ~/.zshrc"
alias s="bash $SCRIPT_DIR/save.sh"

alias tree="find . -not -path '*/\.*' -print | sed -e 's;[^/]*/;│   ;g;s;│   \([^/]*$\);└── \1;'"

# Функции
settings(){
(
    bash -c 'cd leerov-tools/settings; open "LT Settings.app"' >/dev/null 2>&1
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

function transliterate-command-line() {
    local mapping=(
        "й q" "ц w" "у e" "к r" "е t" "н y" "г u" "ш i" "щ o" "з p" "х [" "ъ ]"
        "ф a" "ы s" "в d" "а f" "п g" "р h" "о j" "л k" "д l" "ж ;" "э '"
        "я z" "ч x" "с c" "м v" "и b" "т n" "ь m" "б ," "ю ." "ё \`"
        "Й Q" "Ц W" "У E" "К R" "Е T" "Н Y" "Г U" "Ш I" "Щ O" "З P" "Х {" "Ъ }"
        "Ф A" "Ы S" "В D" "А F" "П G" "Р H" "О J" "Л K" "Д L" "Ж :" "Э \""
        "Я Z" "Ч X" "С C" "М V" "И B" "Т N" "Ь M" "Б <" "Ю >" "Ё ~"
    )
    
    local result="$BUFFER"
    for pair in "${mapping[@]}"; do
        local ru="${pair%% *}"
        local en="${pair##* }"
        result="${result//$ru/$en}"
    done
    
    BUFFER="$result"
    CURSOR=${#BUFFER}
}

# Привязываем к нажатию Enter
function accept-line-with-translit() {
    transliterate-command-line
    zle .accept-line
}

zle -N accept-line-with-translit
bindkey '^M' accept-line-with-translit
bindkey '^J' accept-line-with-translit