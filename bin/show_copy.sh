# Копировать все текстовые файлы в буфер обмена
showcopy() {
    local dir="${1:-.}"
    local temp_file=$(mktemp)
    
    # Расширения текстовых файлов
    local text_exts=(
        "*.c" "*.h" "*.cpp" "*.hpp" "*.py" "*.sh" "*.bash" "*.zsh"
        "*.js" "*.ts" "*.jsx" "*.tsx" "*.html" "*.css" "*.scss"
        "*.json" "*.xml" "*.yaml" "*.yml" "*.md" "*.txt" "*.cfg"
        "*.conf" "*.ini" "*.vim" "*.vimrc" "*.zshrc" "*.bashrc"
        "*.gitignore" "*.dockerfile" "Makefile" "*.mk" "*.cmake"
        "*.lua" "*.rb" "*.go" "*.rs" "*.swift" "*.kt" "*.java"
        "*.sql" "*.r" "*.m" "*.mm" "*.pl" "*.pm" "*.t" "*.pod"
    )
    
    # Собираем все текстовые файлы
    local files=()
    for ext in "${text_exts[@]}"; do
        while IFS= read -r file; do
            files+=("$file")
        done < <(find "$dir" -type f -name "$ext" 2>/dev/null | grep -v -E "(\.git|node_modules|__pycache__|\.venv|venv|build|dist|.idea|.vscode)")
    done
    
    # Убираем дубликаты и сортируем
    printf "%s\n" "${files[@]}" | sort -u > "$temp_file.list"
    
    local file_count=$(wc -l < "$temp_file.list" | tr -d ' ')
    
    if [ "$file_count" -eq 0 ]; then
        rm -f "$temp_file" "$temp_file.list"
        return 1
    fi
    
    # Собираем содержимое всех файлов
    while IFS= read -r file; do
        echo "=== $file ===" >> "$temp_file"
        cat "$file" 2>/dev/null >> "$temp_file"
        echo "" >> "$temp_file"
        echo "" >> "$temp_file"
    done < "$temp_file.list"
    
    # Копируем в буфер обмена
    if command -v pbcopy &> /dev/null; then
        cat "$temp_file" | pbcopy
    fi
    
    # Очистка
    rm -f "$temp_file" "$temp_file.list"
}

# Алиас для быстрого вызова
alias sc="showcopy"