#!/bin/bash
if grep -q "source ~/leerov-tools/zshrc" ~/.zshrc; then
    sed -i '/source ~\/leerov-tools\/zshrc/d' ~/.zshrc
fi
if grep -q "source ~/leerov-tools/vimrc.vim" ~/.vimrc.vim; then
    sed -i '/source ~\/leerov-tools\/vimrc.vim/d' ~/.vimrc.vim
fi
if [ -d ~/leerov-tools ]; then
    rm -rf ~/leerov-tools
    echo "Папка ~/leerov-tools удалена."
else
    echo "Папка ~/leerov-tools не существует."
fi
if [ -f ~/.vim/autoload/plug.vim ]; then
    rm -f ~/.vim/autoload/plug.vim
    echo "Файл ~/.vim/autoload/plug.vim удален."
else
    echo "Файл ~/.vim/autoload/plug.vim не существует."
fi
echo "Все изменения отменены."
