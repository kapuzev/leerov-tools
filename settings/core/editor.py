# -*- coding: utf-8 -*-

import tkinter as tk
from tkinter import ttk, messagebox
import json

from file_manager import FileManager
from ui.styles import setup_styles
from ui.widgets import ScrollableFrame, SettingWidget, JsonEditorDialog
import config

class SettingsEditor:
    """Основной класс редактора настроек"""
    
    def __init__(self, root):
        self.root = root
        self.root.title(config.APP_NAME)
        self.root.geometry(f"{config.WINDOW_WIDTH}x{config.WINDOW_HEIGHT}")
        self.root.minsize(config.MIN_WIDTH, config.MIN_HEIGHT)
        
        # Настройка темной темы для корневого окна
        self.root.configure(bg=config.COLORS['bg_primary'])
        
        # Настройка стилей
        self.style = setup_styles()
        
        # Менеджер файлов
        self.file_manager = FileManager()
        self.settings = {}
        self.active_tab = None
        
        # Создание интерфейса
        self.create_widgets()
        
        # Загрузка настроек
        self.load_settings()
        
        # Центрирование окна
        self.center_window()
        
    def create_widgets(self):
        """Создание всех виджетов интерфейса"""
        # Главный контейнер
        main_container = ttk.Frame(self.root, padding="10")
        main_container.pack(fill=tk.BOTH, expand=True)
        
        # Заголовок
        self.create_header(main_container)
        
        # Основное содержимое
        content_frame = ttk.Frame(main_container)
        content_frame.pack(fill=tk.BOTH, expand=True, pady=(10, 0))
        
        # Левая панель с вкладками
        self.create_tabs_panel(content_frame)
        
        # Правая панель с настройками
        self.create_settings_panel(content_frame)
        
        # Панель действий
        self.create_actions_panel(main_container)
        
        # Статус бар
        self.create_status_bar(main_container)
        
    def create_header(self, parent):
        """Создание заголовка"""
        header_frame = ttk.Frame(parent)
        header_frame.pack(fill=tk.X)
        
        ttk.Label(header_frame, text="⚙️ Редактор настроек JSON", 
                 style='TLabel', font=config.FONTS['title']).pack(side=tk.LEFT)
        
        ttk.Label(header_frame, 
                 text="Редактируйте настройки локально",
                 style='TLabel', font=config.FONTS['subtitle']).pack(side=tk.LEFT, padx=10)
                 
    def create_tabs_panel(self, parent):
        """Создание панели с вкладками"""
        left_frame = ttk.Frame(parent, width=200)
        left_frame.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 10))
        left_frame.pack_propagate(False)
        
        ttk.Label(left_frame, text="Разделы настроек:", 
                 font=('Segoe UI', 11, 'bold')).pack(anchor=tk.W, pady=(0, 10))
        
        # Контейнер для кнопок вкладок
        self.tabs_container = ttk.Frame(left_frame)
        self.tabs_container.pack(fill=tk.BOTH, expand=True)
        
        # Информация о файлах
        self.create_file_info_panel(left_frame)
        
    def create_file_info_panel(self, parent):
        """Создание панели информации о файлах"""
        file_frame = ttk.LabelFrame(parent, text="Файлы", padding=10)
        file_frame.pack(fill=tk.X, pady=(10, 0))
        
        self.file_info_label = ttk.Label(file_frame, text="Проверка файлов...")
        self.file_info_label.pack(anchor=tk.W)
        
    def create_settings_panel(self, parent):
        """Создание основной панели настроек"""
        right_frame = ttk.Frame(parent)
        right_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        # Заголовок раздела
        self.section_header = ttk.Frame(right_frame)
        self.section_header.pack(fill=tk.X, pady=(0, 15))
        
        self.section_title = ttk.Label(self.section_header, 
                                      text="Выберите раздел настроек",
                                      font=config.FONTS['section'])
        self.section_title.pack(anchor=tk.W)
        
        # Область настроек с прокруткой
        self.scrollable_settings = ScrollableFrame(right_frame)
        self.scrollable_settings.pack(fill=tk.BOTH, expand=True)
        
    def create_actions_panel(self, parent):
        """Создание панели действий"""
        action_frame = ttk.Frame(parent)
        action_frame.pack(fill=tk.X, pady=(10, 0))
        
        # Кнопки действий
        actions = [
            ("💾 Сохранить", self.save_settings),
            ("🔄 Загрузить", self.load_settings),
            ("📄 Создать шаблон", self.create_template),
            ("↩️ Сбросить к шаблону", self.reset_to_template),
            ("📋 Показать JSON", self.show_json),
            ("📤 Экспорт", self.export_settings),
        ]
        
        for text, command in actions:
            ttk.Button(action_frame, text=text, 
                      command=command).pack(side=tk.LEFT, padx=2)
                      
    def create_status_bar(self, parent):
        """Создание статус бара"""
        self.status_var = tk.StringVar(value="Готов")
        status_bar = ttk.Label(parent, textvariable=self.status_var, 
                              relief=tk.SUNKEN, anchor=tk.W)
        status_bar.pack(fill=tk.X, pady=(10, 0))
        
    def center_window(self):
        """Центрирование окна на экране"""
        self.root.update_idletasks()
        width = self.root.winfo_width()
        height = self.root.winfo_height()
        x = (self.root.winfo_screenwidth() // 2) - (width // 2)
        y = (self.root.winfo_screenheight() // 2) - (height // 2)
        self.root.geometry(f'{width}x{height}+{x}+{y}')
        
    def update_file_info(self):
        """Обновление информации о файлах"""
        file_status = self.file_manager.get_file_status()
        
        info_text = ""
        if file_status['template']['exists']:
            info_text += "✓ settings_template.json\n"
        else:
            info_text += "✗ settings_template.json\n"
            
        if file_status['settings']['exists']:
            info_text += "✓ settings.json"
        else:
            info_text += "✗ settings.json (будет создан)"
            
        self.file_info_label.config(text=info_text)
        
    def load_settings(self):
        """Загрузка настроек из файла"""
        success, message = self.file_manager.load_settings()
        
        if success:
            self.settings = self.file_manager.settings
            self.status_var.set(message)
            self.update_tabs()
            self.update_file_info()
            
            # Выбираем первую вкладку
            if self.settings:
                first_tab = list(self.settings.keys())[0]
                self.select_tab(first_tab)
        else:
            messagebox.showerror("Ошибка", message)
            self.status_var.set("Ошибка загрузки")
            
    def save_settings(self):
        """Сохранение настроек в файл"""
        success, message = self.file_manager.save_settings(self.settings)
        
        if success:
            self.status_var.set(message)
            self.update_file_info()
            messagebox.showinfo("Сохранено", message)
        else:
            messagebox.showerror("Ошибка", message)
            
    def create_template(self):
        """Создание файла шаблона"""
        success, message = self.file_manager.create_template()
        
        if success:
            self.status_var.set(message)
            self.update_file_info()
            messagebox.showinfo("Шаблон создан", message)
        else:
            messagebox.showerror("Ошибка", message)
            
    def reset_to_template(self):
        """Сброс настроек к шаблону"""
        if not messagebox.askyesno("Подтверждение", 
                                 "Сбросить все настройки к значениям шаблона?\nТекущие изменения будут потеряны."):
            return
            
        success, message = self.file_manager.load_settings()
        
        if success:
            self.settings = self.file_manager.settings
            self.status_var.set("Настройки сброшены к шаблону")
            self.update_tabs()
            
            if self.settings:
                first_tab = list(self.settings.keys())[0]
                self.select_tab(first_tab)
        else:
            messagebox.showwarning("Шаблон не найден", 
                                 "Файл шаблона не найден. Создайте его сначала.")
                               
    def export_settings(self):
        """Экспорт настроек в выбранный файл"""
        success, message = self.file_manager.export_settings(self.settings, self.root)
        
        if success:
            self.status_var.set(message)
            messagebox.showinfo("Экспорт", message)
        elif message != "Экспорт отменен":
            messagebox.showerror("Ошибка", message)
            
    def show_json(self):
        """Показать/редактировать JSON в отдельном окне"""
        try:
            json_text = json.dumps(self.settings, ensure_ascii=False, indent=2)
            
            editor = JsonEditorDialog(self.root, json_text)
            result = editor.show()
            
            if result:
                try:
                    new_settings = json.loads(result)
                    self.settings = new_settings
                    self.update_tabs()
                    
                    if self.settings:
                        first_tab = list(self.settings.keys())[0]
                        self.select_tab(first_tab)
                        
                    self.status_var.set("Настройки обновлены из JSON")
                    messagebox.showinfo("Успешно", "Настройки обновлены из JSON")
                except Exception as e:
                    messagebox.showerror("Ошибка JSON", f"Некорректный JSON:\n{str(e)}")
                    
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось создать редактор JSON:\n{str(e)}")
            
    def update_tabs(self):
        """Обновление списка вкладок"""
        # Очищаем контейнер
        for widget in self.tabs_container.winfo_children():
            widget.destroy()
            
        # Создаем кнопки для каждой вкладки
        self.tab_buttons = {}
        for tab_name in self.settings.keys():
            btn = ttk.Button(self.tabs_container, text=tab_name,
                           style='Tab.TButton', 
                           command=lambda t=tab_name: self.select_tab(t))
            btn.pack(fill=tk.X, pady=2)
            self.tab_buttons[tab_name] = btn
            
    def select_tab(self, tab_name):
        """Выбор вкладки для отображения"""
        # Сбрасываем активную вкладку
        self.active_tab = tab_name
        
        # Обновляем заголовок
        self.section_title.config(text=tab_name)
        
        # Отображаем настройки выбранной вкладки
        self.display_settings(tab_name)
        
    def display_settings(self, tab_name):
        """Отображение настроек выбранной вкладки"""
        # Очищаем контейнер
        for widget in self.scrollable_settings.scrollable_frame.winfo_children():
            widget.destroy()
            
        if tab_name not in self.settings:
            ttk.Label(self.scrollable_settings.scrollable_frame, 
                     text="Раздел не найден",
                     font=('Segoe UI', 12)).pack(pady=20)
            return
            
        tab_settings = self.settings[tab_name]
        
        # Создаем виджеты для каждой настройки
        for setting_name, setting_data in tab_settings.items():
            # Создаем обработчик с замыканием для сохранения значений
            def make_handler(tab=tab_name, name=setting_name):
                def handler(value):
                    self.on_setting_change(tab, name, value)
                return handler
            
            widget = SettingWidget(
                self.scrollable_settings.scrollable_frame,
                setting_name,
                setting_data,
                on_change_callback=make_handler()
            )
            widget.pack(fill=tk.X, padx=5, pady=5)
            
    def on_setting_change(self, tab_name, setting_name, value):
        """Обработчик изменения настройки"""
        try:
            if tab_name in self.settings and setting_name in self.settings[tab_name]:
                # Преобразуем значение в правильный тип
                setting_type = self.settings[tab_name][setting_name].get('type', 'string')
                
                if setting_type == 'boolean':
                    self.settings[tab_name][setting_name]['value'] = bool(value)
                elif setting_type == 'number':
                    try:
                        self.settings[tab_name][setting_name]['value'] = float(value)
                    except ValueError:
                        self.settings[tab_name][setting_name]['value'] = 0
                else:
                    self.settings[tab_name][setting_name]['value'] = str(value)
                    
                self.status_var.set(f"Настройка обновлена: {setting_name}")
                
        except Exception as e:
            print(f"Ошибка обновления настройки: {e}")