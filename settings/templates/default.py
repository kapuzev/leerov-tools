# -*- coding: utf-8 -*-

def get_default_template():
    """Возвращает шаблон настроек по умолчанию"""
    return {
        "Основные настройки": {
            "Название приложения": {
                "value": "Мое приложение",
                "type": "string",
                "description": "Отображаемое название приложения"
            },
            "Версия": {
                "value": "1.0.0",
                "type": "string",
                "description": "Версия приложения"
            },
            "Режим отладки": {
                "value": False,
                "type": "boolean",
                "description": "Включение режима отладки с дополнительными логами"
            },
            "Максимальное количество элементов": {
                "value": 100,
                "type": "number",
                "description": "Максимальное количество элементов для отображения",
                "min": 1,
                "max": 1000
            }
        },
        "Настройки API": {
            "Базовый URL API": {
                "value": "https://api.example.com/v1",
                "type": "string",
                "description": "Базовый URL для API запросов"
            },
            "Ключ API": {
                "value": "",
                "type": "string",
                "description": "Секретный ключ для доступа к API"
            },
            "Таймаут запросов": {
                "value": 30,
                "type": "number",
                "description": "Таймаут для HTTP запросов в секундах",
                "min": 1,
                "max": 300
            },
            "Использовать кэширование": {
                "value": True,
                "type": "boolean",
                "description": "Включить кэширование API запросов"
            }
        },
        "Внешний вид": {
            "Темная тема": {
                "value": True,
                "type": "boolean",
                "description": "Включение темной темы оформления"
            },
            "Основной цвет": {
                "value": "#60a5fa",
                "type": "string",
                "description": "Основной цвет приложения в HEX формате"
            },
            "Размер шрифта": {
                "value": 16,
                "type": "number",
                "description": "Базовый размер шрифта в пикселях",
                "min": 8,
                "max": 32
            }
        }
    }