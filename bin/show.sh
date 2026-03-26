#!/bin/bash

# Функция с поддержкой исключения файлов
show() {
    if [ $# -eq 0 ]; then
        echo "Usage: show <pattern>"
        echo "  show \"*.py\"     - search only in current directory"
        echo "  show \"**/*.py\"  - search recursively"
        return 1
    fi
    
    for pattern in "$@"; do
        # Проверяем, есть ли ** в паттерне
        if [[ "$pattern" == *"**"* ]]; then
            # Рекурсивный поиск
            local filename=$(basename "$pattern")
            find . -name "$filename" -type f -exec sh -c '
                echo "=== {} ==="
                nl -ba {}
            ' \;
        else
            # Поиск только в текущей директории
            for file in $pattern; do
                if [ -f "$file" ]; then
                    echo "=== $file ==="
                    nl -ba "$file"
                fi
            done
        fi
    done
}