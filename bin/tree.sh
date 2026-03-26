tree() {
    local dir="${1:-.}"
    
    # Проверяем, существует ли директория
    if [ ! -d "$dir" ]; then
        echo "Error: Directory '$dir' does not exist" >&2
        return 1
    fi
    
    # Переходим в директорию и выводим структуру
    (
        cd "$dir" || return
        find . -not -path '*/\.*' -print | sed -e 's;[^/]*/;│   ;g;s;│   \([^/]*$\);└── \1;'
    )
}