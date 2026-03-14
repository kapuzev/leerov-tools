#!/bin/bash
SCRIPT_DIR="$HOME/leerov-tools"

# Устанавливаем vim-plug
curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Настраиваем .zshrc
if [ ! -f "$HOME/.zshrc" ]; then
    touch "$HOME/.zshrc"
fi

if ! grep -q "source $SCRIPT_DIR/config/zshrc" "$HOME/.zshrc"; then
    echo "source $SCRIPT_DIR/config/zshrc" >> "$HOME/.zshrc"
fi

# Настраиваем .vimrc
if [ ! -f "$HOME/.vimrc" ]; then
    touch "$HOME/.vimrc"
fi

if ! grep -q "source $SCRIPT_DIR/config/vimrc.vim" "$HOME/.vimrc"; then
    echo "source $SCRIPT_DIR/config/vimrc.vim" >> "$HOME/.vimrc"
fi

# Добавляем bin в PATH
if ! grep -q "export PATH=\"\$HOME/leerov-tools/bin:\$PATH\"" "$HOME/.zshrc"; then
    echo 'export PATH="$HOME/leerov-tools/bin:$PATH"' >> "$HOME/.zshrc"
fi

echo "✅ Установка завершена! Перезапустите терминал или выполните: source ~/.zshrc"