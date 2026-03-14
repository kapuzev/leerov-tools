#!/bin/bash

function install_app() {
    local package_name=$1
    
    # Проверяем, установлен ли Homebrew
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew не установлен"
        return 1
    fi
    
    echo "📦 Устанавливаем $package_name..."
    
    # Сначала пробуем установить как formula (консольная утилита)
    if brew install "$package_name"; then
        echo "✅ $package_name успешно установлен как formula"
        return 0
    fi
    
    # Если formula не найдена, пробуем как cask (графическое приложение)
    echo "🔄 Пробуем установить как cask..."
    if brew install --cask "$package_name" --appdir="$HOME/Applications"; then
        echo "✅ $package_name успешно установлен как cask"
        return 0
    fi
    
    echo "❌ Не удалось установить $package_name"
    echo "🔍 Проверьте существование пакета: brew search $package_name"
    return 1
}

# Создаем директорию Applications если её нет
mkdir -p "$HOME/Applications"
