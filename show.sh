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

Использование: show [ОПЦИИ] [МАСКИ/ПУТИ...]

Опции:
  -d, --dir ДИРЕКТОРИЯ  Поиск в указанной директории (по умолчанию: .)
  -r, --recursive       Рекурсивный поиск
  -x, --exclude МАСКА   Исключить файлы по маске (можно несколько раз)
  -h, --help            Показать справку

Маски:
  Можно указать несколько масок или путей:
    show *.txt *.sh              # Только .txt и .sh файлы
    show "**/*.sql"              # Все .sql файлы рекурсивно
    show "*/src/*/*.sql"         # .sql файлы в поддиректориях src
    show -x "*.bak" "*.tmp"      # Все файлы кроме .bak и .tmp

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
                # Проверяем, является ли аргумент существующим файлом
                if [[ -f "$1" ]]; then
                    include_patterns+=("$(basename "$1")")
                    search_dir="$(dirname "$1")"
                else
                    include_patterns+=("$1")
                fi
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
    
    # Определяем, нужно ли использовать рекурсивный поиск
    local find_opts=""
    [[ $recursive != true ]] && find_opts="-maxdepth 1"
    
    for pattern in "${include_patterns[@]}"; do
        # Проверяем, содержит ли паттерн путь
        if [[ "$pattern" == */* ]]; then
            # Паттерн с путем - разделяем на директорию и маску
            local dir_part="${pattern%/*}"
            local mask_part="${pattern##*/}"
            
            if [[ "$dir_part" == "**" ]]; then
                # Специальный случай: рекурсивный поиск с **
                while IFS= read -r -d '' file; do
                    process_file "$file"
                done < <(find "$search_dir" -type f -name "$mask_part" -print0 2>/dev/null | sort -z)
            else
                # Поиск в определенной директории с маской
                local search_path="$search_dir/$dir_part"
                while IFS= read -r -d '' file; do
                    process_file "$file"
                done < <(find "$search_path" $find_opts -type f -name "$mask_part" -print0 2>/dev/null | sort -z)
            fi
        else
            # Простой паттерн без пути
            while IFS= read -r -d '' file; do
                process_file "$file"
            done < <(find "$search_dir" $find_opts -type f -name "$pattern" -print0 2>/dev/null | sort -z)
        fi
    done
    
    if [[ $files_found -eq 0 ]]; then
        echo "Файлы не найдены"
    fi
    echo "=== Всего: $files_found файлов ==="
}

# Вспомогательная функция для обработки одного файла
process_file() {
    local file="$1"
    
    # Проверка на исключение
    local exclude=false
    local filename="$(basename "$file")"
    for exclude_pattern in "${exclude_patterns[@]}"; do
        if [[ "$filename" == $exclude_pattern ]]; then
            exclude=true
            break
        fi
    done
    
    [[ $exclude == true ]] && return
    
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
}