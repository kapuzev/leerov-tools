# -*- coding: utf-8 -*-

import tkinter as tk
from tkinter import ttk
from tkinter import messagebox

import config
from file_manager import FileManager
from ui.styles import setup_styles
from ui.widgets import ScrollableFrame, SettingWidget, TabButton, JsonEditorDialog
from ui.dialogs import Dialogs

class SettingsEditor:
    """Основной класс редактора настроек"""
    
    def __init__(self, root):
        self.root = root
        self.root.title(config.APP_NAME)
        self.root.geometry(f"{config.WINDOW_WIDTH}x{config.WINDOW_HEIGHT}")
        self.root.minsize(config.MIN_WIDTH, config.MIN_HEIGHT)
        
        # Настройка стилей
        self.style = setup_styles()
        
        # Менеджер файлов
        self.file_manager = FileManager()
        self.settings = {}
        
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
        main_container.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Настройка веса строк и колонок
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_container.columnconfigure(1, weight=1)
        main_container.rowconfigure(1, weight=1)
        
        # Заголовок
        self.create_header(main_container)
        
        # Панель вкладок слева
        self.create_tabs_panel(main_container)
        
        # Основная область настроек справа
        self.create_settings_panel(main_container)
        
        # Панель действий
        self.create_actions_panel(main_container)
        
        # Статус бар
        self.create_status_bar(main_container)
        
    def create_header(self, parent):
        """Создание заголовка"""
        title_frame = ttk.Frame(parent)
        title_frame.grid(row=0, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        ttk.Label(title_frame, text="⚙️ Редактор настроек JSON", 
                 style='Title.TLabel').pack(side=tk.LEFT)
        
        ttk.Label(title_frame, 
                 text="Редактируйте настройки локально. Все изменения сохраняются в файлы рядом с программой.",
                 style='Subtitle.TLabel').pack(side=tk.LEFT, padx=10)
                 
    def create_tabs_panel(self, parent):
        """Создание панели с вкладками"""
        self.tab_frame = ttk.Frame(parent, width=200)
        self.tab_frame.grid(row=1, column=0, sticky=(tk.W, tk.N, tk.S), padx=(0, 10))
        self.tab_frame.grid_propagate(False)
        
        ttk.Label(self.tab_frame, text="Разделы настроек:", 
                 font=('Segoe UI', 11, 'bold')).pack(anchor=tk.W, pady=(0, 10))
        
        # Контейнер для кнопок вкладок
        self.tabs_container = ttk.Frame(self.tab_frame)
        self.tabs_container.pack(fill=tk.BOTH, expand=True)
        
        # Информация о файлах
        self.create_file_info_panel()
        
    def create_file_info_panel(self):
        """Создание панели информации о файлах"""
        self.file_info_frame = ttk.LabelFrame(self.tab_frame, text="Файлы", padding=10)
        self.file_info_frame.pack(fill=tk.X, pady=(10, 0))
        
        self.file_info_label = ttk.Label(self.file_info_frame, text="Проверка файлов...")
        self.file_info_label.pack(anchor=tk.W)
        
    def create_settings_panel(self, parent):
        """Создание основной панели настроек"""
        self.settings_frame = ttk.Frame(parent)
        self.settings_frame.grid(row=1, column=1, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Заголовок раздела
        self.section_header = ttk.Frame(self.settings_frame)
        self.section_header.pack(fill=tk.X, pady=(0, 20))
        
        self.section_title = ttk.Label(self.section_header, 
                                      text="Выберите раздел настроек", 
                                      style='Section.TLabel')
        self.section_title.pack(anchor=tk.W)
        
        self.section_desc = ttk.Label(self.section_header, 
                                     text="Настройки сгруппированы по разделам",
                                     style='Subtitle.TLabel')
        self.section_desc.pack(anchor=tk.W)
        
        # Контейнер для настроек с прокруткой
        self.scrollable_settings = ScrollableFrame(self.settings_frame)
        self.scrollable_settings.pack(fill=tk.BOTH, expand=True)
        
    def create_actions_panel(self, parent):
        """Создание панели действий"""
        action_frame = ttk.Frame(parent)
        action_frame.grid(row=2, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(10, 0))
        
        # Кнопки действий
        actions = [
            ("💾 Сохранить", self.save_settings),
            ("🔄 Загрузить", self.load_settings),
            ("📄 Создать шаблон", self.create_template),
            ("↩️ Сбросить к шаблону", self.reset_to_template),
            ("📋 Показать JSON", self.show_json),
            ("📤 Экспорт", self.export_settings),
            ("➕ Новый раздел", self.add_section),
            ("🔧 Новая настройка", self.add_setting)
        ]
        
        for text, command in actions:
            ttk.Button(action_frame, text=text, 
                      command=command).pack(side=tk.LEFT, padx=2)
                      
    def create_status_bar(self, parent):
        """Создание статус бара"""
        self.status_var = tk.StringVar(value="Готов")
        status_bar = ttk.Label(parent, textvariable=self.status_var, 
                              relief=tk.SUNKEN, anchor=tk.W)
        status_bar.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(10, 0))
        
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
            Dialogs.show_info("Сохранено", message)
        else:
            Dialogs.show_error("Ошибка", message)
            
    def create_template(self):
        """Создание файла шаблона"""
        success, message = self.file_manager.create_template()
        
        if success:
            self.status_var.set(message)
            self.update_file_info()
            Dialogs.show_info("Шаблон создан", message)
        else:
            Dialogs.show_error("Ошибка", message)
            
    def reset_to_template(self):
        """Сброс настроек к шаблону"""
        if not Dialogs.ask_yesno("Подтверждение", 
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
            Dialogs.show_warning("Шаблон не найден", 
                               "Файл шаблона не найден. Создайте его сначала.")
                               
    def export_settings(self):
        """Экспорт настроек в выбранный файл"""
        success, message = self.file_manager.export_settings(self.settings, self.root)
        
        if success:
            self.status_var.set(message)
            Dialogs.show_info("Экспорт", message)
        elif message != "Экспорт отменен":
            Dialogs.show_error("Ошибка", message)
            
    def show_json(self):
        """Показать/редактировать JSON в отдельном окне"""
        try:
            import json
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
                    Dialogs.show_info("Успешно", "Настройки обновлены из JSON")
                except Exception as e:
                    Dialogs.show_error("Ошибка JSON", f"Некорректный JSON:\n{str(e)}")
                    
        except Exception as e:
            Dialogs.show_error("Ошибка", f"Не удалось создать редактор JSON:\n{str(e)}")
            
    def add_section(self):
        """Добавить новый раздел"""
        result = Dialogs.create_section_dialog(self.root)
        
        if result:
            section_name = result["name"]
            if section_name not in self.settings:
                self.settings[section_name] = {}
                self.update_tabs()
                self.select_tab(section_name)
                self.status_var.set(f"Добавлен раздел: {section_name}")
            else:
                Dialogs.show_warning("Ошибка", "Раздел с таким именем уже существует")
                
    def add_setting(self):
        """Добавить новую настройку"""
        if not self.settings:
            Dialogs.show_warning("Ошибка", "Сначала создайте или выберите раздел")
            return
            
        if not hasattr(self, 'active_tab') or not self.active_tab:
            Dialogs.show_warning("Ошибка", "Сначала выберите раздел для добавления настройки")
            return
            
        result = Dialogs.create_setting_dialog(self.root)
        
        if result:
            setting_name = result["name"]
            if setting_name not in self.settings[self.active_tab]:
                self.settings[self.active_tab][setting_name] = {
                    "value": result["value"],
                    "type": result["type"],
                    "description": result["description"]
                }
                self.display_settings(self.active_tab)
                self.status_var.set(f"Добавлена настройка: {setting_name}")
            else:
                Dialogs.show_warning("Ошибка", "Настройка с таким именем уже существует")
                
    def update_tabs(self):
        """Обновление списка вкладок"""
        # Очищаем контейнер
        for widget in self.tabs_container.winfo_children():
            widget.destroy()
            
        # Создаем кнопки для каждой вкладки
        self.tab_buttons = {}
        for tab_name in self.settings.keys():
            btn = TabButton(self.tabs_container, text=tab_name, 
                          style='Tab.TButton', 
                          command=lambda t=tab_name: self.select_tab(t))
            btn.pack(fill=tk.X, pady=2)
            self.tab_buttons[tab_name] = btn
            
    def select_tab(self, tab_name):
        """Выбор вкладки для отображения"""
        # Сбрасываем выделение всех кнопок
        for btn in self.tab_buttons.values():
            btn.deactivate()
            
        # Устанавливаем новую активную вкладку
        self.active_tab = tab_name
        if tab_name in self.tab_buttons:
            self.tab_buttons[tab_name].activate()
            
        # Обновляем заголовок
        self.section_title.config(text=tab_name)
        self.section_desc.config(text=f"Редактирование настроек раздела")
        
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
        self.setting_widgets = {}
        row = 0
        
        for setting_name, setting_data in tab_settings.items():
            def create_change_handler(setting_name, tab_name):
                return lambda value=None: self.on_setting_change(tab_name, setting_name, value)
            
            widget = SettingWidget(
                self.scrollable_settings.scrollable_frame,
                setting_name,
                setting_data,
                on_change_callback=create_change_handler(setting_name)
            )
            widget.grid(row=row, column=0, sticky=(tk.W, tk.E), padx=5, pady=5)
            self.setting_widgets[(tab_name, setting_name)] = widget
            row += 1
            
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