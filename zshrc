#!/bin/bash

# Скрипт для обновления пути в .zshrc с leerov-tools/zshrc на leerov-tools/config/zshrc

SCRIPT_DIR="$HOME/leerov-tools"
ZSHRC="$HOME/.zshrc"

# Проверяем существует ли .zshrc
[ ! -f "$ZSHRC" ] && exit 0

# Удаляем старую ссылку если она есть
if grep -q "source $SCRIPT_DIR/zshrc" "$ZSHRC"; then
    grep -v "source $SCRIPT_DIR/zshrc" "$ZSHRC" > "$ZSHRC.tmp"
    mv "$ZSHRC.tmp" "$ZSHRC"
fi

# Добавляем новую ссылку если её ещё нет
if ! grep -q "source $SCRIPT_DIR/config/zshrc" "$ZSHRC"; then
    echo "source $SCRIPT_DIR/config/zshrc" >> "$ZSHRC"
fi

# Проверяем есть ли bin в PATH
if ! grep -q "export PATH=\"\$HOME/leerov-tools/bin:\$PATH\"" "$ZSHRC"; then
    echo 'export PATH="$HOME/leerov-tools/bin:$PATH"' >> "$ZSHRC"
fi

help() {
    cat "$SCRIPT_DIR/docs/help.txt"
}
echo "💡 Введите 'help' для просмотра доступных команд"

source $SCRIPT_DIR/vimrc.vim