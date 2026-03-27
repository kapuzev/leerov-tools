#!/bin/bash

# Скрипт для синхронизации приложений между goinfre и home
# Проверяет наличие ссылок на приложения в goinfre и обновляет home

SCRIPT_NAME="sync_apps.sh"
LOG_DIR="$HOME"
LAST_HOST_FILE="$LOG_DIR/last_hostname"
CURRENT_HOST=$(hostname)

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Функция для проверки, нужно ли выполнять синхронизацию
need_sync() {
    local last_host=""
    
    # Проверяем существование файла с последним hostname
    if [ -f "$LAST_HOST_FILE" ]; then
        last_host=$(cat "$LAST_HOST_FILE" 2>/dev/null | head -1)
        
        # Проверяем дату изменения файла
        if [ -f "$LAST_HOST_FILE" ]; then
            local file_age
            local current_time
            local one_day_seconds=86400
            
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                file_age=$(($(date +%s) - $(stat -f %m "$LAST_HOST_FILE" 2>/dev/null)))
            else
                # Linux
                file_age=$(($(date +%s) - $(stat -c %Y "$LAST_HOST_FILE" 2>/dev/null)))
            fi
            
            # Если файл старше дня
            if [ "$file_age" -gt "$one_day_seconds" ]; then
                log_info "Файл $LAST_HOST_FILE старше 1 дня (возраст: $((file_age / 3600)) часов)"
                return 0
            fi
        fi
    fi
    
    # Проверяем, изменился ли hostname
    if [ "$CURRENT_HOST" != "$last_host" ]; then
        log_info "Hostname изменился: было '$last_host', стало '$CURRENT_HOST'"
        return 0
    fi
    
    log_info "Синхронизация не требуется (hostname не изменился, файл обновлен менее дня назад)"
    return 1
}

# Функция для синхронизации приложений
sync_applications() {
    local goinfre_path="/opt/goinfre/$(whoami)"
    local home_path="$HOME"
    local apps_dir="Applications"
    
    # Проверяем существование goinfre директории
    if [ ! -d "$goinfre_path" ]; then
        log_error "Директория goinfre не найдена: $goinfre_path"
        return 1
    fi
    
    log_info "Проверка приложений в $goinfre_path/$apps_dir"
    
    # Переменные для подсчета операций
    local added_count=0
    local removed_count=0
    local skipped_count=0
    
    # Получаем список приложений в goinfre
    if [ -d "$goinfre_path/$apps_dir" ]; then
        for app in "$goinfre_path/$apps_dir"/*; do
            if [ -e "$app" ]; then
                local app_name=$(basename "$app")
                local home_link="$home_path/$apps_dir/$app_name"
                
                # Проверяем, существует ли ссылка в home
                if [ -L "$home_link" ]; then
                    # Ссылка существует, проверяем куда она ведет
                    local target=$(readlink "$home_link")
                    if [ "$target" != "$app" ]; then
                        log_warning "Ссылка $app_name ведет не туда, обновляем..."
                        rm -f "$home_link"
                        ln -s "$app" "$home_link"
                        log_success "Обновлена ссылка: $app_name -> $app"
                        ((added_count++))
                    else
                        log_info "Ссылка существует: $app_name"
                        ((skipped_count++))
                    fi
                else
                    # Ссылки нет, создаем
                    log_info "Добавление ссылки для: $app_name"
                    ln -s "$app" "$home_link" 2>/dev/null
                    if [ $? -eq 0 ]; then
                        log_success "Добавлена ссылка: $app_name -> $app"
                        ((added_count++))
                    else
                        log_error "Не удалось создать ссылку для: $app_name"
                    fi
                fi
            fi
        done
    else
        log_info "Директория $goinfre_path/$apps_dir не существует"
    fi
    
    # Проверяем ссылки в home, которые ведут в goinfre
    if [ -d "$home_path/$apps_dir" ]; then
        for link in "$home_path/$apps_dir"/*; do
            if [ -L "$link" ]; then
                local link_name=$(basename "$link")
                local target=$(readlink "$link")
                
                # Проверяем, ведет ли ссылка в goinfre
                if [[ "$target" == "$goinfre_path/$apps_dir"* ]]; then
                    # Проверяем, существует ли целевое приложение
                    if [ ! -e "$target" ]; then
                        log_warning "Приложение не существует: $link_name -> $target"
                        rm -f "$link"
                        log_success "Удалена неработающая ссылка: $link_name"
                        ((removed_count++))
                    fi
                fi
            fi
        done
    fi
    
    log_info "Статистика: добавлено $added_count, удалено $removed_count, пропущено $skipped_count"
    
    return 0
}

# Функция для записи текущего hostname
write_last_hostname() {
    echo "$CURRENT_HOST" > "$LAST_HOST_FILE" 2>/dev/null
    if [ $? -eq 0 ]; then
        log_success "Сохранен hostname '$CURRENT_HOST' в $LAST_HOST_FILE"
    else
        log_error "Не удалось сохранить hostname в $LAST_HOST_FILE"
    fi
}

# Главная функция
main() {

    
    # Проверяем, нужно ли выполнять синхронизацию
    if need_sync; then

        
        # Выполняем синхронизацию
        sync_applications
        local sync_result=$?
        
        # Записываем текущий hostname
        write_last_hostname
        
        if [ $sync_result -eq 0 ]; then

        else
            log_error "Синхронизация завершена с ошибками"
            return 1
        fi
    else

    fi
    

    
    return 0
}

# Запуск основной функции
main "$@"