# Функция для транслитерации в реальном времени
function transliterate-inline() {
    local mapping=(
        "й q" "ц w" "у e" "к r" "е t" "н y" "г u" "ш i" "щ o" "з p" "х [" "ъ ]"
        "ф a" "ы s" "в d" "а f" "п g" "р h" "о j" "л k" "д l" "ж ;" "э '"
        "я z" "ч x" "с c" "м v" "и b" "т n" "ь m" "б ," "ю ." "ё \`"
        "Й Q" "Ц W" "У E" "К R" "Е T" "Н Y" "Г U" "Ш I" "Щ O" "З P" "Х {" "Ъ }"
        "Ф A" "Ы S" "В D" "А F" "П G" "Р H" "О J" "Л K" "Д L" "Ж :" "Э \""
        "Я Z" "Ч X" "С C" "М V" "И B" "Т N" "Ь M" "Б <" "Ю >" "Ё ~"
    )
    
    local current_buffer="$BUFFER"
    local cursor_pos=$CURSOR
    
    # Если строка пустая, выходим
    if [[ -z "$current_buffer" ]] || [[ $cursor_pos -eq 0 ]]; then
        return
    }
    
    # Получаем последний введенный символ
    local last_char="${current_buffer:$((cursor_pos-1)):1}"
    
    # Проверяем, находится ли позиция курсора внутри кавычек
    local cursor_in_quotes=0
    local quote_count_single=0
    local quote_count_double=0
    
    # Считаем кавычки до позиции курсора
    for (( i=0; i<$cursor_pos; i++ )); do
        local char="${current_buffer:$i:1}"
        
        if [[ "$char" == "'" ]]; then
            quote_count_single=$((quote_count_single + 1))
        elif [[ "$char" == "\"" ]]; then
            quote_count_double=$((quote_count_double + 1))
        fi
    done
    
    # Если количество кавычек нечетное, значит мы внутри кавычек
    if [[ $((quote_count_single % 2)) -eq 1 ]] || [[ $((quote_count_double % 2)) -eq 1 ]]; then
        cursor_in_quotes=1
    fi
    
    # Если курсор внутри кавычек, не транслитерируем
    if [[ $cursor_in_quotes -eq 1 ]]; then
        return
    fi
    
    # Транслитерируем только последний символ, если он русский
    for pair in "${mapping[@]}"; do
        local ru="${pair%% *}"
        local en="${pair##* }"
        if [[ "$last_char" == "$ru" ]]; then
            # Заменяем последний символ
            BUFFER="${current_buffer:0:$((cursor_pos-1))}${en}${current_buffer:$cursor_pos}"
            CURSOR=$cursor_pos
            return
        fi
    done
}

# Основная функция для ввода символов с транслитерацией
function self-insert-with-translit() {
    # Сначала вставляем символ обычным способом
    zle .self-insert
    # Затем проверяем, нужно ли его транслитерировать
    transliterate-inline
}

# Создаем виджеты ZLE
zle -N self-insert-with-translit

# Привязываем ВСЕ печатные символы к нашей функции
# Это можно сделать через ranges или отдельно
bindkey -M emacs '!' self-insert-with-translit
bindkey -M emacs '"' self-insert-with-translit
bindkey -M emacs '#' self-insert-with-translit
bindkey -M emacs '$' self-insert-with-translit
bindkey -M emacs '%' self-insert-with-translit
bindkey -M emacs '&' self-insert-with-translit
bindkey -M emacs "'" self-insert-with-translit
bindkey -M emacs '(' self-insert-with-translit
bindkey -M emacs ')' self-insert-with-translit
bindkey -M emacs '*' self-insert-with-translit
bindkey -M emacs '+' self-insert-with-translit
bindkey -M emacs ',' self-insert-with-translit
bindkey -M emacs '-' self-insert-with-translit
bindkey -M emacs '.' self-insert-with-translit
bindkey -M emacs '/' self-insert-with-translit

# Цифры
for i in {0..9}; do
    bindkey -M emacs $i self-insert-with-translit
done

# Буквы и специальные символы
bindkey -M emacs ':' self-insert-with-translit
bindkey -M emacs ';' self-insert-with-translit
bindkey -M emacs '<' self-insert-with-translit
bindkey -M emacs '=' self-insert-with-translit
bindkey -M emacs '>' self-insert-with-translit
bindkey -M emacs '?' self-insert-with-translit
bindkey -M emacs '@' self-insert-with-translit

# Буквы A-Z, a-z (английские)
for char in {a..z} {A..Z}; do
    bindkey -M emacs $char self-insert-with-translit
done

# Русские буквы (символы)
# Привязываем русские буквы как символы
bindkey -M emacs 'а' self-insert-with-translit
bindkey -M emacs 'б' self-insert-with-translit
bindkey -M emacs 'в' self-insert-with-translit
bindkey -M emacs 'г' self-insert-with-translit
bindkey -M emacs 'д' self-insert-with-translit
bindkey -M emacs 'е' self-insert-with-translit
bindkey -M emacs 'ё' self-insert-with-translit
bindkey -M emacs 'ж' self-insert-with-translit
bindkey -M emacs 'з' self-insert-with-translit
bindkey -M emacs 'и' self-insert-with-translit
bindkey -M emacs 'й' self-insert-with-translit
bindkey -M emacs 'к' self-insert-with-translit
bindkey -M emacs 'л' self-insert-with-translit
bindkey -M emacs 'м' self-insert-with-translit
bindkey -M emacs 'н' self-insert-with-translit
bindkey -M emacs 'о' self-insert-with-translit
bindkey -M emacs 'п' self-insert-with-translit
bindkey -M emacs 'р' self-insert-with-translit
bindkey -M emacs 'с' self-insert-with-translit
bindkey -M emacs 'т' self-insert-with-translit
bindkey -M emacs 'у' self-insert-with-translit
bindkey -M emacs 'ф' self-insert-with-translit
bindkey -M emacs 'х' self-insert-with-translit
bindkey -M emacs 'ц' self-insert-with-translit
bindkey -M emacs 'ч' self-insert-with-translit
bindkey -M emacs 'ш' self-insert-with-translit
bindkey -M emacs 'щ' self-insert-with-translit
bindkey -M emacs 'ъ' self-insert-with-translit
bindkey -M emacs 'ы' self-insert-with-translit
bindkey -M emacs 'ь' self-insert-with-translit
bindkey -M emacs 'э' self-insert-with-translit
bindkey -M emacs 'ю' self-insert-with-translit
bindkey -M emacs 'я' self-insert-with-translit

# Заглавные русские буквы
bindkey -M emacs 'А' self-insert-with-translit
bindkey -M emacs 'Б' self-insert-with-translit
bindkey -M emacs 'В' self-insert-with-translit
bindkey -M emacs 'Г' self-insert-with-translit
bindkey -M emacs 'Д' self-insert-with-translit
bindkey -M emacs 'Е' self-insert-with-translit
bindkey -M emacs 'Ё' self-insert-with-translit
bindkey -M emacs 'Ж' self-insert-with-translit
bindkey -M emacs 'З' self-insert-with-translit
bindkey -M emacs 'И' self-insert-with-translit
bindkey -M emacs 'Й' self-insert-with-translit
bindkey -M emacs 'К' self-insert-with-translit
bindkey -M emacs 'Л' self-insert-with-translit
bindkey -M emacs 'М' self-insert-with-translit
bindkey -M emacs 'Н' self-insert-with-translit
bindkey -M emacs 'О' self-insert-with-translit
bindkey -M emacs 'П' self-insert-with-translit
bindkey -M emacs 'Р' self-insert-with-translit
bindkey -M emacs 'С' self-insert-with-translit
bindkey -M emacs 'Т' self-insert-with-translit
bindkey -M emacs 'У' self-insert-with-translit
bindkey -M emacs 'Ф' self-insert-with-translit
bindkey -M emacs 'Х' self-insert-with-translit
bindkey -M emacs 'Ц' self-insert-with-translit
bindkey -M emacs 'Ч' self-insert-with-translit
bindkey -M emacs 'Ш' self-insert-with-translit
bindkey -M emacs 'Щ' self-insert-with-translit
bindkey -M emacs 'Ъ' self-insert-with-translit
bindkey -M emacs 'Ы' self-insert-with-translit
bindkey -M emacs 'Ь' self-insert-with-translit
bindkey -M emacs 'Э' self-insert-with-translit
bindkey -M emacs 'Ю' self-insert-with-translit
bindkey -M emacs 'Я' self-insert-with-translit

# Специальные символы для русской раскладки
bindkey -M emacs '[' self-insert-with-translit
bindkey -M emacs ']' self-insert-with-translit
bindkey -M emacs '{' self-insert-with-translit
bindkey -M emacs '}' self-insert-with-translit
bindkey -M emacs ':' self-insert-with-translit
bindkey -M emacs ';' self-insert-with-translit
bindkey -M emacs '"' self-insert-with-translit
bindkey -M emacs "'" self-insert-with-translit
bindkey -M emacs '~' self-insert-with-translit
bindkey -M emacs '`' self-insert-with-translit
bindkey -M emacs '<' self-insert-with-translit
bindkey -M emacs '>' self-insert-with-translit
bindkey -M emacs ',' self-insert-with-translit
bindkey -M emacs '.' self-insert-with-translit

# Пробел
bindkey -M emacs ' ' self-insert-with-translit

# Упрощенный вариант привязки всех символов (если предыдущий способ не работает)
# Можно использовать хук для preexec вместо привязки каждого символа:
function zle-line-init() {
    # Устанавливаем флаг, что мы в начале строки
    zle autosuggest-clear
}

function zle-line-finish() {
    # Дополнительная обработка при завершении редактирования строки
    :
}

# Добавляем хуки
zle -N zle-line-init
zle -N zle-line-finish

# Привязываем стандартные клавиши управления
bindkey -M emacs "^H" backward-delete-char
bindkey -M emacs "^?" backward-delete-char
bindkey -M emacs "^W" backward-kill-word
bindkey -M emacs "^U" kill-whole-line
bindkey -M emacs "^K" kill-line

# Enter работает как обычно
bindkey -M emacs "^M" accept-line
bindkey -M emacs "^J" accept-line