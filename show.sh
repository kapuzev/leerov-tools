#!/bin/bash

# Функция с поддержкой исключения файлов
show() {
    local search_dir="."
    local include_patterns=()
    local exclude_patterns=()
    local recursive=false
    
    # Парсинг аргументов
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dir|--directory)
                search_dir="${2:-.}"
                shift 2
                ;;
            -r|--recursive)
                recursive=true
                shift
                ;;
            -x|--exclude)
                if [[ -n "$2" ]]; then
                    exclude_patterns+=("$2")
                    shift 2
                else
                    echo "Ошибка: Не указана маска для исключения" >&2
                    return 1
                fi
                ;;
            -h|--help)
                cat << EOF
show - показывает содержимое файлов

Использование: show [ОПЦИИ] [МАСКИ...]

Опции:
  -d, --dir ДИРЕКТОРИЯ  Поиск в указанной директории (по умолчанию: .)
  -r, --recursive       Рекурсивный поиск
  -x, --exclude МАСКА   Исключить файлы по маске (можно несколько раз)
  -h, --help            Показать справку

Маски:
  Можно указать несколько масок для включения:
    show *.txt *.sh              # Только .txt и .sh файлы
    show -x "*.bak" "*.tmp"      # Все файлы кроме .bak и .tmp
    show "*.py" -x "test_*.py"   # .py файлы кроме начинающихся на test_

Примеры:
  show                              # Все файлы в текущей папке
  show -d ~/docs *.pdf *.doc       # PDF и DOC в ~/docs
  show -r "*.conf" -x "*.old"      # Рекурсивно .conf файлы кроме .old
  show *.sh *.bash -x "*test*"     # .sh и .bash файлы кроме содержащих test
EOF
                return 0
                ;;
            -*)
                echo "Неизвестная опция: $1" >&2
                return 1
                ;;
            *)
                include_patterns+=("$1")
                shift
                ;;
        esac
    done
    
    # Если нет масок для включения, берем все
    [[ ${#include_patterns[@]} -eq 0 ]] && include_patterns=("*")
    
    local counter=1
    echo "=== Показываю файлы ==="
    echo "Директория: $(realpath "$search_dir")"
    echo "Включая: ${include_patterns[*]}"
    [[ ${#exclude_patterns[@]} -gt 0 ]] && echo "Исключая: ${exclude_patterns[*]}"
    [[ $recursive == true ]] && echo "Режим: рекурсивный"
    echo ""
    
    # Обработка файлов
    local files_found=0
    local first_file=true
    
    # Используем find для поиска файлов с учетом паттернов
    for pattern in "${include_patterns[@]}"; do
        while IFS= read -r -d '' file; do
            # Проверка на исключение
            local exclude=false
            for exclude_pattern in "${exclude_patterns[@]}"; do
                if [[ "$(basename "$file")" == $exclude_pattern ]]; then
                    exclude=true
                    break
                fi
            done
            
            if [[ $exclude == true ]]; then
                continue
            fi
            
            if [[ $first_file == true ]]; then
                first_file=false
            else
                echo ""
            fi
            
            echo "### Файл $counter: $file ###"
            
            if [[ -r "$file" ]]; then
                if file "$file" | grep -q "text"; then
                    echo "--- Содержимое ($(wc -l < "$file") строк) ---"
                    cat -n "$file"
                    echo "--- Конец ---"
                else
                    echo "[Бинарный файл]"
                    echo "Тип: $(file -b "$file")"
                    echo "Размер: $(du -h "$file" | cut -f1)"
                fi
            else
                echo "[Нет доступа]"
            fi
            
            ((counter++))
            ((files_found++))
            
        done < <(
            # Генерируем команду find с учетом рекурсивности
            if [[ $recursive == true ]]; then
                find "$search_dir" -type f -name "$pattern" -print0 2>/dev/null
            else
                find "$search_dir" -maxdepth 1 -type f -name "$pattern" -print0 2>/dev/null
            fi
        )
    done
    
    if [[ $files_found -eq 0 ]]; then
        echo "Файлы не найдены"
    fi
    echo "=== Всего: $files_found файлов ==="
}