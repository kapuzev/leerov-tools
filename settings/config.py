# -*- coding: utf-8 -*-

# Константы приложения
APP_NAME = "Редактор настроек JSON"
APP_VERSION = "1.0.0"
APP_AUTHOR = "Your Name"

# Файлы
DEFAULT_SETTINGS_FILE = "settings.json"
TEMPLATE_FILE = "settings_template.json"
EXPORT_PREFIX = "settings_export"

# Размеры окна
WINDOW_WIDTH = 1200
WINDOW_HEIGHT = 700
MIN_WIDTH = 900
MIN_HEIGHT = 600

# ========== ТЕМНАЯ ТЕМА ==========
COLORS = {
    # Основные цвета фона
    'bg_primary': '#0f172a',           # Основной фон окна
    'bg_secondary': '#1e293b',         # Вторичный фон (панели, карточки)
    'bg_tertiary': '#334155',          # Третичный фон
    
    # Цвета текста
    'text_primary': '#f1f5f9',         # Основной текст
    'text_secondary': '#cbd5e1',       # Вторичный текст
    'text_muted': '#94a3b8',           # Приглушенный текст
    
    # Акцентные цвета
    'primary': '#60a5fa',              # Основной акцент
    'primary_hover': '#93c5fd',        # Акцент при наведении
    'primary_active': '#3b82f6',       # Акцент в активном состоянии
    
    # Статусные цвета
    'success': '#34d399',              # Успех
    'success_hover': '#6ee7b7',        # Успех при наведении
    'error': '#f87171',                # Ошибка
    'error_hover': '#fca5a5',          # Ошибка при наведении
    'warning': '#fbbf24',              # Предупреждение
    'warning_hover': '#fcd34d',        # Предупреждение при наведении
    'info': '#60a5fa',                 # Информация
    
    # Границы
    'border': '#475569',               # Границы элементов
    'border_hover': '#64748b',         # Границы при наведении
    'border_active': '#60a5fa',        # Активные границы
    
    # Поля ввода
    'input_bg': '#1e293b',             # Фон полей ввода
    'input_bg_hover': '#334155',       # Фон при наведении
    'input_border': '#475569',         # Граница полей
    'input_border_focus': '#60a5fa',   # Граница при фокусе
    'input_text': '#f1f5f9',           # Текст в полях
    
    # Кнопки
    'button_bg': '#334155',            # Фон кнопок
    'button_bg_hover': '#475569',      # Фон при наведении
    'button_bg_active': '#60a5fa',     # Фон активных кнопок
    'button_text': '#f1f5f9',          # Текст кнопок
    'button_text_active': '#ffffff',   # Текст активных кнопок
    
    # Вкладки
    'tab_bg': '#1e293b',               # Фон вкладок
    'tab_bg_active': '#60a5fa',        # Фон активной вкладки
    'tab_bg_hover': '#334155',         # Фон при наведении
    'tab_text': '#cbd5e1',             # Текст вкладок
    'tab_text_active': '#ffffff',      # Текст активной вкладки
    
    # Прокрутка
    'scrollbar_bg': '#1e293b',         # Фон скроллбара
    'scrollbar_thumb': '#475569',      # Ползунок
    'scrollbar_thumb_hover': '#64748b',# Ползунок при наведении
    
    # Выделение
    'selection_bg': '#3b82f6',         # Фон выделения
    'selection_text': '#ffffff',       # Текст выделения
    
    # Для обратной совместимости
    'light_bg': '#0f172a',
    'dark_bg': '#0f172a'
}

# Шрифты
FONTS = {
    'title': ('Segoe UI', 16, 'bold'),
    'subtitle': ('Segoe UI', 10),
    'section': ('Segoe UI', 14, 'bold'),
    'normal': ('Segoe UI', 10),
    'monospace': ('Consolas', 10)
}