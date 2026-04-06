#!/bin/bash
# lib/ap.zsh - AP (AI-friendly Patch) функции

# Создание ap-патча из выделенного текста или буфера
ap() {
    local selected_text=""
    if [[ -n $REGION_ACTIVE && $REGION_ACTIVE -ge 0 ]]; then
        selected_text=$(echo "$CUTBUFFER" 2>/dev/null)
    fi
    
    if [[ -z "$selected_text" ]]; then
        selected_text="$BUFFER"
    fi
    
    if [[ -z "$selected_text" ]]; then
        echo "No text to process"
        return 1
    fi
    
    local patch_id=$(openssl rand -hex 4 2>/dev/null || cat /dev/urandom | LC_ALL=C tr -dc 'a-f0-9' | head -c 8)
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local patch_file="patch_${timestamp}_${patch_id}.ap"
    
    cat > "$patch_file" << EOF
# Summary: AI-generated patch
# Generated: $(date)
# Source: $(pwd)

${patch_id} AP 3.1

${patch_id} FILE
[FILE_PATH]

${patch_id} REPLACE
${patch_id} snippet
$(echo "$selected_text" | sed 's/^/'"${patch_id} "'/')
${patch_id} content
[REPLACEMENT_CONTENT]

EOF
    
    echo "Patch file created: $patch_file"
    echo "Edit the file to specify FILE_PATH and REPLACEMENT_CONTENT"
}

# Быстрый патч из буфера обмена
apclip() {
    local clipboard_content=""
    
    if command -v pbpaste >/dev/null 2>&1; then
        clipboard_content=$(pbpaste)
    elif command -v xclip >/dev/null 2>&1; then
        clipboard_content=$(xclip -selection clipboard -o)
    else
        echo "No clipboard command found"
        return 1
    fi
    
    if [[ -z "$clipboard_content" ]]; then
        echo "Clipboard is empty"
        return 1
    fi
    
    local patch_id=$(openssl rand -hex 4 2>/dev/null || cat /dev/urandom | LC_ALL=C tr -dc 'a-f0-9' | head -c 8)
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local patch_file="patch_${timestamp}_${patch_id}.ap"
    
    cat > "$patch_file" << EOF
# Summary: AI-generated patch from clipboard
# Generated: $(date)

${patch_id} AP 3.1

${patch_id} FILE
[FILE_PATH]

${patch_id} REPLACE
${patch_id} snippet
$(echo "$clipboard_content" | sed 's/^/'"${patch_id} "'/')
${patch_id} content
[REPLACEMENT_CONTENT]

EOF
    
    echo "Patch file created from clipboard: $patch_file"
}

# Бинды для zsh
function _ap_create_patch() {
    ap
    zle reset-prompt
}
zle -N _ap_create_patch
bindkey '^[fj' _ap_create_patch  # Alt+f j
bindkey '^[jf' _ap_create_patch  # Alt+j f

# Алиасы для простоты
alias jf='ap'
alias fj='ap'