#!/bin/bash

# Скрипт для обновления пути в .vimrc с leerov-tools/vimrc.vim на leerov-tools/config/vimrc.vim

SCRIPT_DIR="$HOME/leerov-tools"
VIMRC="$HOME/.vimrc"

# Проверяем существует ли .vimrc
[ ! -f "$VIMRC" ] && exit 0

# Удаляем старую ссылку если она есть
if grep -q "source $SCRIPT_DIR/vimrc.vim" "$VIMRC"; then
    grep -v "source $SCRIPT_DIR/vimrc.vim" "$VIMRC" > "$VIMRC.tmp"
    mv "$VIMRC.tmp" "$VIMRC"
fi

# Добавляем новую ссылку если её ещё нет
if ! grep -q "source $SCRIPT_DIR/config/vimrc.vim" "$VIMRC"; then
    echo "source $SCRIPT_DIR/config/vimrc.vim" >> "$VIMRC"
fi