#!/bin/bash

curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if [ ! -f "$HOME/.zshrc" ]; then
    touch "$HOME/.zshrc"
fi
if ! grep -q "source $SCRIPT_DIR/zshrc" "$HOME/.zshrc"; then
    echo "source $SCRIPT_DIR/zshrc" >> "$HOME/.zshrc"
fi

if [ ! -f "$HOME/.vimrc" ]; then
    touch "$HOME/.vimrc"
fi
if ! grep -q "source $SCRIPT_DIR/vimrc" "$HOME/.vimrc"; then
    echo "source $SCRIPT_DIR/vimrc" >> "$HOME/.vimrc"
fi