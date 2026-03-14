#!/bin/bash
# lib/brew-functions.sh - Функции для управления Homebrew

# Функция активации Homebrew
function brewActivate {
    local user=$(whoami)
    local goinfre_path="/opt/goinfre/$user"
    local brew_path="$goinfre_path/homebrew"
    
    if [ -d "$brew_path" ]; then
        # 1. Активируем Homebrew
        eval "$($brew_path/bin/brew shellenv)"
        
        # 2. Настраиваем пути для Cask
        export HOMEBREW_CASK_OPTS="--appdir=$goinfre_path/Applications --fontdir=$goinfre_path/Library/Fonts"
        
        # 3. Настраиваем кеш в goinfre
        export HOMEBREW_CACHE="$brew_path/cache"
        
        # 4. Оптимизации для 42
        export HOMEBREW_NO_ANALYTICS=1
        export HOMEBREW_NO_AUTO_UPDATE=1
        
        # 5. Создаем необходимые директории
        mkdir -p "$goinfre_path/Applications" 2>/dev/null
        mkdir -p "$goinfre_path/Library/Fonts" 2>/dev/null
        mkdir -p "$HOMEBREW_CACHE" 2>/dev/null
        
        # 6. Создаем симлинки для совместимости
        if [ ! -L ~/Applications ] && [ ! -d ~/Applications ]; then
            ln -sf "$goinfre_path/Applications" ~/Applications 2>/dev/null
        fi
        
        if [ ! -L ~/Library/Fonts ] && [ ! -d ~/Library/Fonts ]; then
            ln -sf "$goinfre_path/Library/Fonts" ~/Library/Fonts 2>/dev/null
        fi
        
        # 7. Исправляем права для zsh автодополнения
        chmod -R go-w "$(brew --prefix)/share/zsh" 2>/dev/null || true
        
        echo "✅ Homebrew активирован"
        echo "📦 Cask приложения: $goinfre_path/Applications"
        echo "🗄️  Кеш brew: $HOMEBREW_CACHE"
        return 0
    else
        echo "❌ Homebrew не найден по пути: $brew_path"
        echo "💡 Используйте команду: brew-setup"
        return 1
    fi
}

# Функция установки Homebrew
function brewInstall {
    if [ -d /opt/goinfre/$(whoami)/homebrew ]; then
        echo "Homebrew уже установлен"
        brewActivate
        return 0
    fi
    
    echo "Установка Homebrew..."
    cd /opt/goinfre/$(whoami)
    git clone https://github.com/Homebrew/brew homebrew
    eval "$(/opt/goinfre/$(whoami)/homebrew/bin/brew shellenv)"
    brew update --force --quiet
    chmod -R go-w "$(brew --prefix)/share/zsh"
    brew install lcov
    echo "Homebrew успешно установлен"
}

# Функция удаления Homebrew
function brewUninstall {
    if [ -d /opt/goinfre/$(whoami)/homebrew ]; then
        echo "Удаление Homebrew..."
        rm -rf /opt/goinfre/$(whoami)/homebrew
        echo "Homebrew удален"
    else
        echo "Homebrew не установлен в /opt/goinfre/$(whoami)/homebrew"
    fi
}

# Основная функция установки/активации
function brewSetup {
    local brew_path="/opt/goinfre/$(whoami)/homebrew"
    
    if [ -d "$brew_path" ]; then
        eval "$($brew_path/bin/brew shellenv)"
        chmod -R go-w "$(brew --prefix)/share/zsh"
        echo "✓ Homebrew активирован"
        return 0
    fi
    
    echo "Быстрая установка Homebrew..."
    cd /opt/goinfre/$(whoami)
    
    # Оптимальный вариант: неглубокое клонирование
    git clone --depth=1 https://github.com/Homebrew/brew homebrew
    
    eval "$($brew_path/bin/brew shellenv)"
    brew update --force --quiet
    chmod -R go-w "$(brew --prefix)/share/zsh"
    
    # Тестируем функциональность
    if brew --version > /dev/null 2>&1; then
        echo "✓ Homebrew успешно установлен и готов к работе"
        echo "✓ Доступны: brew install, brew search, brew update и другие команды"
    else
        echo "❌ Что-то пошло не так"
        return 1
    fi
}

# Функция переустановки
function brewReinstall {
    brewUninstall
    brewInstall
}

# Добавляем brew в PATH если он есть
brew_path="/opt/goinfre/$(whoami)/homebrew/bin"
if [[ ":$PATH:" != *":$brew_path:"* ]] && [ -d "$brew_path" ]; then
    export PATH="$brew_path:$PATH"
fi