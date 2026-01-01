# -*- coding: utf-8 -*-

import json
import os
from datetime import datetime
import shutil
from tkinter import filedialog, messagebox
import config

class FileManager:
    """Менеджер работы с файлами настроек"""
    
    def __init__(self):
        self.settings_file = config.DEFAULT_SETTINGS_FILE
        self.template_file = config.TEMPLATE_FILE
        self.settings = {}
        
    def load_settings(self):
        """Загрузка настроек из файла"""
        try:
            # Проверяем существование файла настроек
            if os.path.exists(self.settings_file):
                with open(self.settings_file, 'r', encoding='utf-8') as f:
                    self.settings = json.load(f)
                return True, f"Настройки загружены из {self.settings_file}"
            else:
                # Если файла нет, проверяем шаблон
                if os.path.exists(self.template_file):
                    with open(self.template_file, 'r', encoding='utf-8') as f:
                        self.settings = json.load(f)
                    return True, f"Создан {self.settings_file} из шаблона"
                else:
                    # Создаем настройки по умолчанию
                    from templates.default import get_default_template
                    self.settings = get_default_template()
                    return True, "Созданы настройки по умолчанию"
                    
        except Exception as e:
            return False, f"Ошибка загрузки: {str(e)}"
            
    def save_settings(self, settings=None):
        """Сохранение настроек в файл"""
        try:
            if settings:
                self.settings = settings
                
            with open(self.settings_file, 'w', encoding='utf-8') as f:
                json.dump(self.settings, f, ensure_ascii=False, indent=2)
            return True, f"Настройки сохранены в {self.settings_file}"
            
        except Exception as e:
            return False, f"Ошибка сохранения: {str(e)}"
            
    def create_template(self, template_data=None):
        """Создание файла шаблона"""
        try:
            if not template_data:
                from templates.default import get_default_template
                template_data = get_default_template()
                
            with open(self.template_file, 'w', encoding='utf-8') as f:
                json.dump(template_data, f, ensure_ascii=False, indent=2)
            return True, f"Шаблон создан: {self.template_file}"
            
        except Exception as e:
            return False, f"Ошибка создания шаблона: {str(e)}"
            
    def export_settings(self, settings, parent_window=None):
        """Экспорт настроек в выбранный файл"""
        try:
            filename = filedialog.asksaveasfilename(
                parent=parent_window,
                defaultextension=".json",
                filetypes=[("JSON files", "*.json"), ("All files", "*.*")],
                initialfile=f"{config.EXPORT_PREFIX}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            )
            
            if filename:
                with open(filename, 'w', encoding='utf-8') as f:
                    json.dump(settings, f, ensure_ascii=False, indent=2)
                return True, f"Настройки экспортированы в {filename}"
            return False, "Экспорт отменен"
            
        except Exception as e:
            return False, f"Ошибка экспорта: {str(e)}"
            
    def import_settings(self, parent_window=None):
        """Импорт настроек из файла"""
        try:
            filename = filedialog.askopenfilename(
                parent=parent_window,
                filetypes=[("JSON files", "*.json"), ("All files", "*.*")]
            )
            
            if filename:
                with open(filename, 'r', encoding='utf-8') as f:
                    imported = json.load(f)
                return True, "Настройки импортированы", imported
            return False, "Импорт отменен", None
            
        except Exception as e:
            return False, f"Ошибка импорта: {str(e)}", None
            
    def get_file_status(self):
        """Получение статуса файлов"""
        return {
            'settings': {
                'exists': os.path.exists(self.settings_file),
                'path': os.path.abspath(self.settings_file)
            },
            'template': {
                'exists': os.path.exists(self.template_file),
                'path': os.path.abspath(self.template_file)
            }
        }
        
    def backup_settings(self):
        """Создание резервной копии настроек"""
        try:
            if os.path.exists(self.settings_file):
                backup_file = f"settings_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
                shutil.copy2(self.settings_file, backup_file)
                return True, f"Резервная копия создана: {backup_file}"
            return False, "Файл настроек не найден для резервного копирования"
        except Exception as e:
            return False, f"Ошибка создания резервной копии: {str(e)}"