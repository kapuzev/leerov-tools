# Копировать все текстовые файлы в буфер обмена с нумерацией строк
showcopy() {
    local dir="${1:-.}"
    local temp_file=$(mktemp)
    local stdout_only=0
    if [[ "$1" == "--stdout" ]]; then
        stdout_only=1
        dir="${2:-.}"
    fi
    # Расширения текстовых файлов
    local text_exts=(
        # Исходный код (языки программирования)
        "*.c" "*.h" "*.cpp" "*.hpp" "*.cc" "*.cxx" "*.hh" "*.hxx"
        "*.py" "*.pyx" "*.pyi"
        "*.sh" "*.bash" "*.zsh" "*.fish" "*.ksh" "*.dash"
        "*.js" "*.ts" "*.jsx" "*.tsx" "*.mjs" "*.cjs"
        "*.html" "*.htm" "*.xhtml" "*.xml" "*.svg" "*.rss" "*.atom"
        "*.css" "*.scss" "*.sass" "*.less" "*.styl"
        "*.json" "*.json5" "*.jsonc" "*.yaml" "*.yml" "*.toml" "*.ini"
        "*.md" "*.markdown" "*.rst" "*.tex" "*.latex" "*.ltx"
        "*.lua" "*.rb" "*.go" "*.rs" "*.swift" "*.kt" "*.kts" "*.java"
        "*.sql" "*.psql" "*.r" "*.m" "*.mm" "*.pl" "*.pm" "*.t" "*.pod"
        "*.php" "*.phtml" "*.phps" "*.asp" "*.aspx" "*.jsp"
        "*.scala" "*.sc" "*.clj" "*.cljs" "*.edn" "*.erl" "*.hrl"
        "*.ex" "*.exs" "*.el" "*.lisp" "*.cl" "*.rkt" "*.ss"
        "*.dart" "*.nim" "*.cr" "*.zig" "*.v" "*.vsh" "*.fs" "*.fsx"
        "*.f" "*.f90" "*.f95" "*.f03" "*.for" "*.ada" "*.adb" "*.ads"
        "*.d" "*.di" "*.mli" "*.ml" "*.hs" "*.lhs"
        "*.asm" "*.s" "*.S" "*.nasm"
        
        # Конфигурационные файлы
        "*.cfg" "*.conf" "*.config" "*.cnf"
        "*.vim" "*.vimrc" "*.gvimrc" "*.nvimrc"
        "*.zshrc" "*.bashrc" "*.bash_profile" "*.profile" "*.bash_logout"
        "*.gitignore" "*.gitattributes" "*.gitconfig" "*.gitmodules"
        "*.dockerfile" "Dockerfile*" "*.containerfile"
        "Makefile" "makefile" "*.mk" "*.mak" "*.cmake" "CMakeLists.txt"
        "*.gradle" "*.gradle.kts" "*.sbt"
        "*.pom.xml" "*.ivy" "*.ant"
        
        # Web и фронтенд
        "*.vue" "*.svelte" "*.astro"
        "*.graphql" "*.gql"
        "*.ejs" "*.hbs" "*.mustache"
        "*.twig" "*.jinja" "*.jinja2"
        
        # Data science и научные
        "*.ipynb" "*.julia" "*.jl"
        "*.qmd" "*.rmd" "*.Rnw"
        "*.stan" "*.bugs" "*.jags"
        
        # DevOps и инфраструктура
        "*.tf" "*.tfvars" "*.hcl"
        "*.yml" "*.yaml"  # (уже есть, но для ansible важно)
        "*.sls"  # SaltStack
        "*.pp"  # Puppet
        "*.erb"
        "*.ps1" "*.psm1" "*.psd1"  # PowerShell
        "*.j2"  # Jinja2 templates
        
        # Документация и текстовые форматы
        "*.txt" "*.text" "*.log" "*.out" "*.err"
        "*.nfo" "*.readme" "README*" "CHANGELOG*" "LICENSE*" "CONTRIBUTING*"
        "*.tex" "*.ltx" "*.bib" "*.bst"
        "*.adoc" "*.asciidoc"
        "*.org"  # Emacs org-mode
        "*.wiki"
        "*.rtf"
        "*.csv" "*.tsv" "*.psv"
        "*.ics"  # iCalendar
        
        # Специализированные форматы
        "*.desktop"  # .desktop entries
        "*.service"  # systemd
        "*.timer"    # systemd timers
        "*.socket"   # systemd sockets
        "*.target"   # systemd targets
        "*.cron" "*.tab" "crontab"
        "*.sed" "*.awk"
        "*.regex"
        "*.lisp" "*.cl" "*.el"
        "*.prolog" "*.pl" "*.p"
        
        # Без расширения (специальные имена)
        "Makefile" "makefile" "CMakeLists.txt" "Dockerfile" "dockerfile"
        ".env" ".env.*" "env" "environment"
        "Procfile"
        "Gemfile" "Gemfile.lock"
        "Rakefile"
        "Cargo.toml" "Cargo.lock"
        "go.mod" "go.sum"
        "package.json" "package-lock.json" "yarn.lock" "pnpm-lock.yaml"
        "composer.json" "composer.lock"
        "requirements.txt" "Pipfile" "Pipfile.lock" "pyproject.toml" "setup.py" "setup.cfg"
        ".pre-commit-config.yaml"
        ".eslintrc*" ".prettierrc*" ".babelrc*"
        
        # Прочие
        "*.patch" "*.diff"
        "*.sig" "*.asc"  # PGP signatures (текстовые)
        "*.gcode"  # 3D printing
        "*.scad"   # OpenSCAD
        "*.led"    # LED patterns
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
    
    # Собираем содержимое всех файлов с нумерацией строк
    while IFS= read -r file; do
        echo "=== $file ===" >> "$temp_file"
        # Добавляем нумерацию строк с помощью nl или cat -n
        # Вариант 1: используем nl (более гибкий)
        nl -ba "$file" 2>/dev/null >> "$temp_file"
        # Вариант 2: используем cat -n (проще)
        # cat -n "$file" 2>/dev/null >> "$temp_file"
        echo "" >> "$temp_file"
        echo "" >> "$temp_file"
    done < "$temp_file.list"
    
    if [[ $stdout_only -eq 1 ]]; then
        cat "$temp_file"
    else
        # Копируем в буфер обмена
        if command -v pbcopy &> /dev/null; then
            cat "$temp_file" | pbcopy
            echo "Скопировано $file_count файлов с нумерацией строк"
        elif command -v xclip &> /dev/null; then
            cat "$temp_file" | xclip -selection clipboard
            echo "Скопировано $file_count файлов с нумерацией строк"
        elif command -v clip.exe &> /dev/null; then
            cat "$temp_file" | clip.exe
            echo "Скопировано $file_count файлов с нумерацией строк"
        else
            echo "Не найдена команда для копирования в буфер обмена"
            cat "$temp_file"
        fi
    fi
    
    # Очистка
    rm -f "$temp_file" "$temp_file.list"
}


# Алиас для быстрого вызова
alias sc="showcopy"