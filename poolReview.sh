#!/bin/bash
p2p () {
    git clone $1 review -b develop
    code review
    check
}

check() {
    if [ $# -eq 0 ]; then
        # Используем путь по умолчанию - review в текущей папке
        local PROJECT_PATH="review"
        echo "Используется путь по умолчанию: $PROJECT_PATH"
    else
        local PROJECT_PATH="$1"
    fi
    
    local ORIGINAL_DIR="$PWD"
    
    # Проверяем существование папки проекта
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "Ошибка: Папка $PROJECT_PATH не существует"
        return 1
    fi
    
    # Переходим в папку проекта
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
    
    # 2. Статический анализ cppcheck
    echo -e "\n2. СТАТИЧЕСКИЙ АНАЛИЗ (cppcheck):"
    cppcheck --enable=all --suppress=missingIncludeSystem --std=c11 *.c
    
    # 3. Компиляция всех .c файлов
    echo -e "\n3. КОМПИЛЯЦИЯ:"
    local compiled_files=()
    for file in *.c; do
        if [ -f "$file" ]; then
            output_name="${file%.c}.out"
            echo "Компиляция $file..."
            if gcc -Wall -Werror -Wextra -std=c11 -o "$output_name" "$file"; then
                compiled_files+=("$output_name")
                echo "✓ Успешно: $output_name"
            else
                echo "✗ Ошибка компиляции: $file"
            fi
        fi
    done
    
    # 4. Меню для запуска с проверкой утечек
    if [ ${#compiled_files[@]} -gt 0 ]; then
        echo -e "\n4. ЗАПУСК И ПРОВЕРКА УТЕЧЕК:"
        while true; do
            echo "0. Выход"
            for i in "${!compiled_files[@]}"; do
                echo "$((i+1)). Запустить ${compiled_files[$i]} с проверкой утечек"
            done
            
            read -p "Выбор: " choice
            echo
            
            case $choice in
                0)
                    break
                    ;;
                *)
                    if [[ $choice -gt 0 && $choice -le ${#compiled_files[@]} ]]; then
                        index=$((choice-1))
                        file_to_run="${compiled_files[$index]}"
                        echo "Запуск $file_to_run с проверкой утечек..."
                        leaks -atExit -- ./"$file_to_run"
                    else
                        echo "Неверный выбор. Попробуйте снова."
                    fi
                    ;;
            esac
        done
    else
        echo -e "\nНет скомпилированных файлов для запуска"
    fi
    
    # Очистка скомпилированных файлов
    echo -e "\nОчистка..."
    rm -f *.out
    
    # Возврат в исходную директорию
    cd "$ORIGINAL_DIR" || return 1
    echo -e "\n=== ПРОВЕРКА ЗАВЕРШЕНА ==="
}