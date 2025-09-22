#!/bin/bash

git_push() {
    nohup git pull --strategy=merge > /dev/null 2>&1
    
    DATE=$(date +"%Y-%m-%d")
    TIME=$(date +"%H:%M:%S")
    
    # Получаем список изменённых файлов
    FILES_LIST=$(git status --porcelain | awk '{print "- "$2}')
    
    # Формируем сообщение коммита
    MESSAGE="$DATE $TIME: $*

$FILES_LIST"

    
    nohup git add * > /dev/null 2>&1
    nohup git commit -m "$MESSAGE" > /dev/null 2>&1
    nohup git push > /dev/null 2>&1
}
