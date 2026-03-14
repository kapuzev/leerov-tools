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
    
    # Включаем поддержку globstar для рекурсивного поиска
    shopt -s globstar nullglob
    
    # Собираем все .c и .h файлы рекурсивно
    local C_FILES=(**/*.c)
    local H_FILES=(**/*.h)
    
    # 1. Проверка clang-format
    echo -e "\n1. ПРОВЕРКА СТИЛЯ КОДА (clang-format):"
    local CLANG_FORMAT_CONFIG=""
    if [ -f "../../materials/linters/.clang-format" ]; then
        CLANG_FORMAT_CONFIG="--style=file"
        echo "Используется конфиг: ../../materials/linters/.clang-format"
        # Копируем конфиг в текущую директорию для правильной работы
        cp "../../materials/linters/.clang-format" . 2>/dev/null
    else
        CLANG_FORMAT_CONFIG="--style='{BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 110}'"
        echo "Используется стандартный стиль Google"
    fi
    
    # Проверяем все .c и .h файлы
    if [ ${#C_FILES[@]} -gt 0 ] || [ ${#H_FILES[@]} -gt 0 ]; then
        clang-format $CLANG_FORMAT_CONFIG -n "${C_FILES[@]}" "${H_FILES[@]}" 2>&1 | grep -v "Is a directory" || true
    else
        echo "Нет .c или .h файлов для проверки стиля"
    fi
    
    # 2. Статический анализ cppcheck
    echo -e "\n2. СТАТИЧЕСКИЙ АНАЛИЗ (cppcheck):"
    if [ ${#C_FILES[@]} -gt 0 ]; then
        cppcheck --enable=all --suppress=missingIncludeSystem --suppress=unusedFunction --std=c11 "${C_FILES[@]}"
    else
        echo "Нет .c файлов для статического анализа"
    fi
    
    # 3. Компиляция всех .c файлов в один исполняемый файл
    echo -e "\n3. КОМПИЛЯЦИЯ ВСЕХ ФАЙЛОВ:"
    if [ ${#C_FILES[@]} -gt 0 ]; then
        echo "Найдены файлы для компиляции:"
        printf '%s\n' "${C_FILES[@]}"
        
        echo -e "\nКомпиляция всех .c файлов в program.out..."
        
        # Компилируем с поддержкой всех стандартных библиотек
        if clang -Wall -Werror -Wextra -std=c11 -I. -o program.out "${C_FILES[@]}" -lm; then
            echo "✓ Успешно: program.out"
            
            # Проверяем, является ли файл исполняемым
            if [ -x "./program.out" ]; then
                # 4. Запуск с проверкой утечек
                echo -e "\n4. ЗАПУСК И ПРОВЕРКА УТЕЧЕК:"
                echo "Запуск program.out с проверкой утечек..."
                
                # Проверяем наличие аргументов для program.out
                if [ -f "./program.out" ]; then
                    leaks -atExit -- ./program.out
                else
                    echo "Исполняемый файл не найден"
                fi
            else
                echo "✗ Исполняемый файл не создан или недоступен"
            fi
        else
            echo "✗ Ошибка компиляции"
        fi
    else
        echo "Нет .c файлов для компиляции"
    fi
    
    # Очистка
    echo -e "\nОчистка..."
    rm -f program.out .clang-format 2>/dev/null
    
    # Возврат в исходную директорию
    cd "$ORIGINAL_DIR" || return 1
    echo -e "\n=== ПРОВЕРКА ЗАВЕРШЕНА ==="
}