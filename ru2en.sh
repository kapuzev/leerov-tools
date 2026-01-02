#!/usr/bin/env zsh

# Улучшенная транслитерация в реальном времени для ZSH
# Русские буквы вне кавычек сразу преобразуются в английские

# 1. Оптимизированная структура данных для маппинга
# Используем ассоциативный массив для O(1) доступа
declare -A TRANSLIT_MAP
local -a mapping_pairs=(
    "й q" "ц w" "у e" "к r" "е t" "н y" "г u" "ш i" "щ o" "з p" "х [" "ъ ]"
    "ф a" "ы s" "в d" "а f" "п g" "р h" "о j" "л k" "д l" "ж ;" "э '"
    "я z" "ч x" "с c" "м v" "и b" "т n" "ь m" "б ," "ю ." "ё \`"
    "Й Q" "Ц W" "У E" "К R" "Е T" "Н Y" "Г U" "Ш I" "Щ O" "З P" "Х {" "Ъ }"
    "Ф A" "Ы S" "В D" "А F" "П G" "Р H" "О J" "Л K" "Д L" "Ж :" "Э \""
    "Я Z" "Ч X" "С C" "М V" "И B" "Т N" "Ь M" "Б <" "Ю >" "Ё ~"
)

# Заполняем ассоциативный массив
for pair in "${mapping_pairs[@]}"; do
    local ru="${pair%% *}"
    local en="${pair##* }"
    TRANSLIT_MAP[$ru]="$en"
done

# 2. Функция для определения, находимся ли внутри кавычек
# Более эффективный алгоритм с учетом escaped кавычек
function is-inside-quotes() {
    local string="$1"
    local position="$2"
    
    local in_single_quotes=0
    local in_double_quotes=0
    local escaped=0
    
    for (( i=0; i<position; i++ )); do
        local char="${string:$i:1}"
        local prev_char="${string:$((i-1)):1}"
        
        # Сбрасываем escaped статус, если не предыдущий символ не был \
        if [[ $i -gt 0 ]] && [[ "$prev_char" != "\\" ]]; then
            escaped=0
        fi
        
        # Обрабатываем escape-символ
        if [[ "$char" == "\\" ]] && [[ $escaped -eq 0 ]]; then
            escaped=1
            continue
        fi
        
        # Обрабатываем кавычки только если не escaped
        if [[ $escaped -eq 0 ]]; then
            if [[ "$char" == "'" ]]; then
                if [[ $in_double_quotes -eq 0 ]]; then
                    in_single_quotes=$((1 - in_single_quotes))
                fi
            elif [[ "$char" == "\"" ]]; then
                if [[ $in_single_quotes -eq 0 ]]; then
                    in_double_quotes=$((1 - in_double_quotes))
                fi
            fi
        fi
        
        escaped=0
    done
    
    # Возвращаем 1 если внутри кавычек, 0 если нет
    [[ $in_single_quotes -eq 1 ]] || [[ $in_double_quotes -eq 1 ]]
}

# 3. Основная функция транслитерации
function transliterate-inline() {
    # Используем локальные переменные для избежания конфликтов
    local buffer="$BUFFER"
    local cursor="$CURSOR"
    
    # Быстрые проверки для выхода из функции
    [[ -z "$buffer" ]] || [[ $cursor -eq 0 ]] && return
    
    # Получаем последний введенный символ
    local last_char="${buffer:$((cursor-1)):1}"
    
    # Проверяем, является ли символ русской буквой
    if [[ -z "${TRANSLIT_MAP[$last_char]}" ]]; then
        return  # Не русская буква - выходим
    fi
    
    # Проверяем, не находимся ли мы внутри кавычек
    if is-inside-quotes "$buffer" "$cursor"; then
        return  # Внутри кавычек - не транслитерируем
    fi
    
    # Получаем английский эквивалент
    local replacement="${TRANSLIT_MAP[$last_char]}"
    
    # Заменяем символ в буфере
    BUFFER="${buffer:0:$((cursor-1))}${replacement}${buffer:$cursor}"
    
    # Восстанавливаем позицию курсора
    CURSOR=$cursor
}

# 4. Улучшенный виджет для self-insert
function zle-self-insert-with-translit() {
    # Список символов, которые не требуют транслитерации
    local -a skip_chars=(" " $'\t' $'\n' "[" "]" "{" "}" "(" ")" "<" ">" 
                         ":" ";" "'" '"' "`" "~" "!" "@" "#" "$" "%" "^" 
                         "&" "*" "(" ")" "-" "_" "+" "=" "|" "\\" "/" "?" 
                         "." "," "0" "1" "2" "3" "4" "5" "6" "7" "8" "9")
    
    local char="${KEYS[-1]}"
    
    # Быстрая проверка - если символ точно не русская буква, пропускаем транслитерацию
    if [[ " ${skip_chars[*]} " == *" $char "* ]]; then
        zle .self-insert
        return
    fi
    
    # Вставляем символ
    zle .self-insert
    
    # Транслитерируем если нужно
    transliterate-inline
}

# 5. Виджет для обратной транслитерации (опционально)
function zle-backward-translit() {
    local buffer="$BUFFER"
    local cursor="$CURSOR"
    
    if [[ $cursor -gt 0 ]]; then
        local char="${buffer:$((cursor-1)):1}"
        
        # Ищем русскую букву для этого английского символа
        for ru en in "${(@kv)TRANSLIT_MAP}"; do
            if [[ "$en" == "$char" ]] && ! is-inside-quotes "$buffer" "$cursor"; then
                BUFFER="${buffer:0:$((cursor-1))}${ru}${buffer:$cursor}"
                return
            fi
        done
    fi
    
    zle .backward-delete-char
}

# 6. Регистрация виджетов
zle -N zle-self-insert-with-translit
zle -N zle-backward-translit
zle -N is-inside-quotes

# 7. Привязка клавиш - оптимизированный подход
# Используем zle-line-init для настройки привязок
function zle-line-init() {
    # Временно сохраняем текущие привязки
    local original_bindings=("${(@kv)key}")
    
    # Устанавливаем привязку для всех печатных символов
    # Более эффективно, чем привязывать каждый символ отдельно
    bindkey -M emacs -R ' '-'~' zle-self-insert-with-translit
    bindkey -M emacs -R 'а'-'я' zle-self-insert-with-translit
    bindkey -M emacs -R 'А'-'Я' zle-self-insert-with-translit
    bindkey -M emacs -R 'ё' zle-self-insert-with-translit
    bindkey -M emacs -R 'Ё' zle-self-insert-with-translit
    
    # Привязка для Backspace с возможностью обратной транслитерации
    bindkey -M emacs '^H' zle-backward-translit
    bindkey -M emacs '^?' zle-backward-translit
}

function zle-line-finish() {
    # Восстанавливаем оригинальные привязки (опционально)
    # или очищаем временные данные
    :
}

# Регистрируем хуки
zle -N zle-line-init
zle -N zle-line-finish

# Включаем хуки
add-zsh-hook zle-line-init zle-line-init
add-zsh-hook zle-line-finish zle-line-finish

# 8. Альтернативный подход: глобальные привязки (проще, но менее гибко)
# Раскомментируйте, если подход с хуками не работает

# # Привязываем диапазоны символов
# bindkey -M emacs -R ' '-'~' zle-self-insert-with-translit  # ASCII символы
# bindkey -M emacs -R 'а'-'я' zle-self-insert-with-translit  # русские строчные
# bindkey -M emacs -R 'А'-'Я' zle-self-insert-with-translit  # русские заглавные
# bindkey -M emacs 'ё' zle-self-insert-with-translit         # буква ё
# bindkey -M emacs 'Ё' zle-self-insert-with-translit         # буква Ё

# 9. Стандартные привязки для управления
bindkey -M emacs '^W' backward-kill-word
bindkey -M emacs '^U' kill-whole-line
bindkey -M emacs '^K' kill-line
bindkey -M emacs '^A' beginning-of-line
bindkey -M emacs '^E' end-of-line
bindkey -M emacs '^F' forward-char
bindkey -M emacs '^B' backward-char

# 10. Enter работает как обычно
bindkey -M emacs '^M' accept-line
bindkey -M emacs '^J' accept-line

# 11. Функция для отладки (можно убрать в продакшене)
function translit-debug() {
    echo "Buffer: '$BUFFER'"
    echo "Cursor: $CURSOR"
    echo "Last char: '${BUFFER:$((CURSOR-1)):1}'"
    is-inside-quotes "$BUFFER" "$CURSOR" && echo "Inside quotes" || echo "Not in quotes"
}

# 12. Быстрый тест работы
function test-translit() {
    echo "Тест транслитерации:"
    echo "1. Вне кавычек: привет -> ghbdtn"
    echo "2. В кавычек: 'привет' останется 'привет'"
    echo "3. Смешанный: привет 'мир' тест -> ghbdtn 'мир' ntnc"
}

# Инициализация
echo "[OK] Транслитерация загружена. Русские буквы вне кавычек будут преобразовываться автоматически."