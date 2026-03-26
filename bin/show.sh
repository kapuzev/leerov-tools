#!/bin/bash

# Функция с поддержкой исключения файлов
show() {
    if [ $# -eq 0 ]; then
        echo "Usage: show <pattern1> [pattern2 ...]"
        echo "Example: show \"*.py\" \"*.txt\""
        return 1
    fi
    
    for pattern in "$@"; do
        find . -name "$pattern" -type f -exec sh -c '
            echo "=== {} ==="
            nl -ba {}
        ' \;
    done
}
