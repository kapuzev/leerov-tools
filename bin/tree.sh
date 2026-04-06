tree() {
    local dir="${1:-.}"
    
    if [ ! -d "$dir" ]; then
        echo "Error: Directory '$dir' does not exist" >&2
        return 1
    fi
    
    (
        cd "$dir" || return
        find . -not -path '*/\.*' \
               \( -name '__pycache__' -prune \) -o \
               -not -name '*.pyc' \
               -print | sed -e 's;[^/]*/;│   ;g;s;│   \([^/]*$\);└── \1;'
    )
}