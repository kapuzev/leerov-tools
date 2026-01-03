#!/bin/bash
SCRIPT_DIR="$HOME/leerov-tools"
curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if [ ! -f "$HOME/.zshrc" ]; then
    touch "$HOME/.zshrc"
fi
if ! grep -q "source $SCRIPT_DIR/zshrc" "$HOME/.zshrc"; then
    echo "source $SCRIPT_DIR/zshrc" >> "$HOME/.zshrc"
fi

if [ ! -f "$HOME/.vimrc.vim" ]; then
    touch "$HOME/.vimrc.vim"
fi
if ! grep -q "source $SCRIPT_DIR/vimrc.vim" "$HOME/.vimrc.vim"; then
    echo "source $SCRIPT_DIR/vimrc.vim" >> "$HOME/.vimrc.vim"
fi