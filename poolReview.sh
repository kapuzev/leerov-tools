#!/bin/bash

p2p () {
    git clone $1 review -b develop
    code review
    check
}

check() {
    if [ $# -eq 0 ]; then
        local PROJECT_PATH="review"
        echo "Используется путь по умолчанию: $PROJECT_PATH"
    else
        local PROJECT_PATH="$1"
    fi
    
    local ORIGINAL_DIR="$PWD"
    
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "Ошибка: Папка $PROJECT_PATH не существует"
        return 1
    fi
    
    if [ ! -d "$PROJECT_PATH/src" ]; then
        echo "Ошибка: Папка $PROJECT_PATH не содержит директорию src"
        return 1
    fi
    
    cd "$PROJECT_PATH/src" || return 1
    
    echo "=== ПРОВЕРКА ПРОЕКТА: $(basename "$PROJECT_PATH") ==="
    
    # 1. Проверка clang-format
    echo -e "\n1. ПРОВЕРКА СТИЛЯ КОДА (clang-format):"
    local CLANG_FORMAT_CONFIG=""
    if [ -f "../../materials/linters/.clang-format" ]; then
        CLANG_FORMAT_CONFIG="--style=file"
        echo "Используется конфиг: ../../materials/linters/.clang-format"
    else
        CLANG_FORMAT_CONFIG="--style='{BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 110}'"
        echo "Используется стандартный стиль Google"
    fi
    
    clang-format $CLANG_FORMAT_CONFIG -n *.c *.h 2>/dev/null
    
    # 2. Статический анализ cppcheck - ИСПРАВЛЕНО
    echo -e "\n2. СТАТИЧЕСКИЙ АНАЛИЗ (cppcheck):"
    cppcheck --enable=all --suppress=missingIncludeSystem --suppress=unusedFunction --std=c11 .
    
    # 3. Компиляция всех .c файлов в один исполняемый файл
    echo -e "\n3. КОМПИЛЯЦИЯ ВСЕХ ФАЙЛОВ:"
    if ls *.c >/dev/null 2>&1; then
        echo "Компиляция всех .c файлов в program.out..."
        if gcc -Wall -Werror -Wextra -std=c11 -o program.out *.c; then
            echo "✓ Успешно: program.out"
            
            # 4. Запуск с проверкой утечек
            echo -e "\n4. ЗАПУСК И ПРОВЕРКА УТЕЧЕК:"
            echo "Запуск program.out с проверкой утечек..."
            leaks -atExit -- ./program.out
        else
            echo "✗ Ошибка компиляции"
        fi
    else
        echo "Нет .c файлов для компиляции"
    fi
    
    # Очистка
    echo -e "\nОчистка..."
    rm -f program.out
    
    # Возврат в исходную директорию
    cd "$ORIGINAL_DIR" || return 1
    echo -e "\n=== ПРОВЕРКА ЗАВЕРШЕНА ==="
}