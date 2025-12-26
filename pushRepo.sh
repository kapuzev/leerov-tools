#!/bin/bash

# Функция для определения протокола клонирования
get_clone_protocol() {
    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null)
    
    if [ -z "$remote_url" ]; then
        echo "unknown"
        return 1
    fi
    
    # Определяем протокол
    if [[ "$remote_url" == https://github.com/* ]]; then
        echo "https"
    elif [[ "$remote_url" == git@github.com:* ]]; then
        echo "ssh"
    elif [[ "$remote_url" == git://github.com/* ]]; then
        echo "git"
    else
        # Проверяем другие возможные форматы
        if [[ "$remote_url" == http*://* ]]; then
            echo "http"
        elif [[ "$remote_url" == ssh://* ]]; then
            echo "ssh"
        elif [[ "$remote_url" == git://* ]]; then
            echo "git"
        else
            echo "unknown"
        fi
    fi
}

# Функция git_push только для SSH
git_push_ssh_only() {
    echo "=== Проверка SSH протокола ==="
    
    # Проверяем, находимся ли в git репозитории
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Ошибка: Это не git репозиторий"
        return 1
    fi
    
    # Проверяем наличие remote origin
    if ! git remote get-url origin > /dev/null 2>&1; then
        echo "Ошибка: Remote 'origin' не настроен"
        return 1
    fi
    
    # Получаем протокол клонирования
    local protocol
    protocol=$(get_clone_protocol)
    
    # Проверяем, что репозиторий склонирован по SSH
    if [ "$protocol" != "ssh" ]; then
        echo "Отмена: Репозиторий склонирован по протоколу '$protocol', а требуется 'ssh'"
        echo "URL: $(git remote get-url origin)"
        echo ""
        echo "Чтобы изменить протокол на SSH выполните:"
        echo "git remote set-url origin git@github.com:username/repository.git"
        return 1
    fi
    
    echo "✓ Репозиторий склонирован по SSH"
    
    # Проверяем SSH доступ
    echo "Проверяем SSH подключение..."
    if ! ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo "Ошибка: SSH подключение к GitHub не работает"
        echo "Проверьте:"
        echo "1. Наличие SSH ключей: ls -la ~/.ssh/"
        echo "2. Ключ добавлен в ssh-agent: ssh-add -l"
        echo "3. Ключ добавлен в GitHub: https://github.com/settings/keys"
        return 1
    fi
    
    echo "✓ SSH подключение работает"
    
    # Вызываем основную функцию git_push
    git_push "$@"
}

# Основная функция git_push (без проверки протокола)
git_push() {
    local commit_message="${1:-Autocommit}"
    
    echo "=== Начинаем push операцию ==="
    
    # Выполняем pull
    echo "Выполняем pull..."
    if ! git pull --strategy=merge; then
        echo "Ошибка при выполнении pull. Разрешите конфликты и попробуйте снова."
        return 1
    fi
    
    DATE=$(date +"%Y-%m-%d")
    TIME=$(date +"%H:%M:%S")
    
    # Получаем список изменённых файлов
    echo "Анализируем изменения..."
    FILES_LIST=$(git status --porcelain | awk '{print "- "$2}')
    
    if [ -z "$FILES_LIST" ]; then
        echo "Нет изменений для коммита."
        return 0
    fi
    
    echo "Изменённые файлы:"
    echo "$FILES_LIST"
    
    # Формируем сообщение коммита
    MESSAGE="$DATE $TIME: $commit_message

$FILES_LIST"
    
    echo ""
    echo "Добавляем файлы..."
    if ! git add .; then
        echo "Ошибка при добавлении файлов."
        return 1
    fi
    
    echo "Создаём коммит..."
    if ! git commit -m "$MESSAGE"; then
        echo "Ошибка при создании коммита."
        return 1
    fi
    
    echo "Отправляем изменения..."
    if ! git push; then
        echo "Ошибка при отправке изменений."
        return 1
    fi
    
    echo ""
    echo "✅ Успешно! Изменения отправлены в репозиторий."
}

# Альтернативная версия с тихим выполнением (для фоновых задач)
git_push_ssh_only_silent() {
    # Быстрая проверка SSH протокола
    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null)
    
    if [ -z "$remote_url" ]; then
        return 1
    fi
    
    # Проверяем, что это SSH протокол GitHub
    if [[ ! "$remote_url" == git@github.com:* ]] && [[ ! "$remote_url" == ssh://git@github.com/* ]]; then
        return 1  # Не SSH протокол
    fi
    
    # Быстрая проверка SSH подключения
    if ! ssh -o BatchMode=yes -o ConnectTimeout=3 -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        return 1  # SSH не работает
    fi
    
    # Тихий pull
    git pull --strategy=merge --quiet 2>/dev/null
    
    # Проверяем есть ли изменения
    if [ -z "$(git status --porcelain)" ]; then
        return 0  # Нет изменений
    fi
    
    DATE=$(date +"%Y-%m-%d")
    TIME=$(date +"%H:%M:%S")
    COMMIT_MSG="${1:-Autocommit}"
    
    FILES_LIST=$(git status --porcelain | awk '{print "- "$2}')
    MESSAGE="$DATE $TIME: $COMMIT_MSG

$FILES_LIST"
    
    # Тихие операции
    git add . --quiet 2>/dev/null
    git commit -m "$MESSAGE" --quiet 2>/dev/null
    git push --quiet 2>/dev/null
    
    return 0
}