import tkinter as tk
from tkinter import ttk, messagebox, filedialog, scrolledtext
import json
import os
import sys
from datetime import datetime

class SettingsEditor:
    def __init__(self, root):
        self.root = root
        self.root.title("Редактор настроек JSON")
        self.root.geometry("1200x700")
        self.root.minsize(900, 600)
        
        # Настройка стилей
        self.setup_styles()
        
        # Переменные
        self.settings = {}
        self.current_file = "settings.json"
        self.template_file = "settings_template.json"
        
        # Создание интерфейса
        self.create_widgets()
        
        # Загрузка настроек
        self.load_settings()
        
        # Центрирование окна
        self.center_window()
        
    def setup_styles(self):
        """Настройка стилей для Tkinter"""
        style = ttk.Style()
        style.theme_use('clam')
        
        # Кастомные стили
        style.configure('Title.TLabel', font=('Segoe UI', 16, 'bold'))
        style.configure('Subtitle.TLabel', font=('Segoe UI', 10))
        style.configure('Tab.TButton', font=('Segoe UI', 10), padding=10)
        style.configure('Success.TLabel', foreground='#2e7d32')
        style.configure('Error.TLabel', foreground='#c62828')
        style.configure('Setting.TLabelframe', padding=10)
        style.configure('Setting.TLabelframe.Label', font=('Segoe UI', 10, 'bold'))
        
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
        title_frame = ttk.Frame(main_container)
        title_frame.grid(row=0, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        ttk.Label(title_frame, text="⚙️ Редактор настроек JSON", 
                 style='Title.TLabel').pack(side=tk.LEFT)
        
        ttk.Label(title_frame, 
                 text="Редактируйте настройки локально. Все изменения сохраняются в файлы рядом с программой.",
                 style='Subtitle.TLabel').pack(side=tk.LEFT, padx=10)
        
        # Панель вкладок слева
        self.tab_frame = ttk.Frame(main_container, width=200)
        self.tab_frame.grid(row=1, column=0, sticky=(tk.W, tk.N, tk.S), padx=(0, 10))
        self.tab_frame.grid_propagate(False)
        
        ttk.Label(self.tab_frame, text="Разделы настроек:", 
                 font=('Segoe UI', 11, 'bold')).pack(anchor=tk.W, pady=(0, 10))
        
        # Контейнер для кнопок вкладок
        self.tabs_container = ttk.Frame(self.tab_frame)
        self.tabs_container.pack(fill=tk.BOTH, expand=True)
        
        # Информация о файлах
        self.file_info_frame = ttk.LabelFrame(self.tab_frame, text="Файлы", padding=10)
        self.file_info_frame.pack(fill=tk.X, pady=(10, 0))
        
        self.file_info_label = ttk.Label(self.file_info_frame, text="Проверка файлов...")
        self.file_info_label.pack(anchor=tk.W)
        
        # Основная область настроек справа
        self.settings_frame = ttk.Frame(main_container)
        self.settings_frame.grid(row=1, column=1, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Заголовок раздела
        self.section_header = ttk.Frame(self.settings_frame)
        self.section_header.pack(fill=tk.X, pady=(0, 20))
        
        self.section_title = ttk.Label(self.section_header, text="Выберите раздел настроек", 
                                      font=('Segoe UI', 14, 'bold'))
        self.section_title.pack(anchor=tk.W)
        
        self.section_desc = ttk.Label(self.section_header, text="Настройки сгруппированы по разделам",
                                     font=('Segoe UI', 10))
        self.section_desc.pack(anchor=tk.W)
        
        # Контейнер для настроек с прокруткой
        self.canvas = tk.Canvas(self.settings_frame, highlightthickness=0)
        self.scrollbar = ttk.Scrollbar(self.settings_frame, orient="vertical", 
                                      command=self.canvas.yview)
        self.settings_container = ttk.Frame(self.canvas)
        
        self.canvas.configure(yscrollcommand=self.scrollbar.set)
        self.canvas_window = self.canvas.create_window((0, 0), window=self.settings_container, 
                                                      anchor="nw", tags="self.settings_container")
        
        self.canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Привязка событий прокрутки
        self.settings_container.bind("<Configure>", self.on_frame_configure)
        self.canvas.bind("<Configure>", self.on_canvas_configure)
        self.canvas.bind_all("<MouseWheel>", self.on_mousewheel)
        
        # Панель действий внизу
        action_frame = ttk.Frame(main_container)
        action_frame.grid(row=2, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(10, 0))
        
        # Кнопки действий
        ttk.Button(action_frame, text="💾 Сохранить", 
                  command=self.save_settings).pack(side=tk.LEFT, padx=2)
        ttk.Button(action_frame, text="🔄 Загрузить", 
                  command=self.load_settings).pack(side=tk.LEFT, padx=2)
        ttk.Button(action_frame, text="📄 Создать шаблон", 
                  command=self.create_template).pack(side=tk.LEFT, padx=2)
        ttk.Button(action_frame, text="↩️ Сбросить к шаблону", 
                  command=self.reset_to_template).pack(side=tk.LEFT, padx=2)
        ttk.Button(action_frame, text="📋 Показать JSON", 
                  command=self.show_json).pack(side=tk.LEFT, padx=2)
        ttk.Button(action_frame, text="📤 Экспорт", 
                  command=self.export_settings).pack(side=tk.LEFT, padx=2)
        
        # Статус бар
        self.status_var = tk.StringVar(value="Готов")
        status_bar = ttk.Label(main_container, textvariable=self.status_var, 
                              relief=tk.SUNKEN, anchor=tk.W)
        status_bar.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(10, 0))
        
    def on_frame_configure(self, event=None):
        """Обновление scrollregion при изменении размера frame"""
        self.canvas.configure(scrollregion=self.canvas.bbox("all"))
        
    def on_canvas_configure(self, event):
        """Изменение ширины внутреннего frame при изменении canvas"""
        canvas_width = event.width
        self.canvas.itemconfig(self.canvas_window, width=canvas_width)
        
    def on_mousewheel(self, event):
        """Прокрутка колесиком мыши"""
        self.canvas.yview_scroll(int(-1*(event.delta/120)), "units")
        
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
        settings_exists = os.path.exists(self.current_file)
        template_exists = os.path.exists(self.template_file)
        
        info_text = ""
        if template_exists:
            info_text += "✓ settings_template.json\n"
        else:
            info_text += "✗ settings_template.json\n"
            
        if settings_exists:
            info_text += "✓ settings.json"
        else:
            info_text += "✗ settings.json (будет создан)"
            
        self.file_info_label.config(text=info_text)
        
    def load_settings(self):
        """Загрузка настроек из файла"""
        try:
            # Проверяем существование файла настроек
            if os.path.exists(self.current_file):
                with open(self.current_file, 'r', encoding='utf-8') as f:
                    self.settings = json.load(f)
                self.status_var.set(f"Настройки загружены из {self.current_file}")
            else:
                # Если файла нет, проверяем шаблон
                if os.path.exists(self.template_file):
                    with open(self.template_file, 'r', encoding='utf-8') as f:
                        self.settings = json.load(f)
                    self.status_var.set(f"Создан {self.current_file} из шаблона")
                else:
                    # Создаем пустые настройки
                    self.settings = self.get_default_template()
                    self.status_var.set("Созданы настройки по умолчанию")
                    
            # Обновляем интерфейс
            self.update_tabs()
            self.update_file_info()
            
            # Выбираем первую вкладку
            if self.settings:
                first_tab = list(self.settings.keys())[0]
                self.select_tab(first_tab)
                
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось загрузить настройки:\n{str(e)}")
            self.status_var.set("Ошибка загрузки")
            
    def save_settings(self):
        """Сохранение настроек в файл"""
        try:
            with open(self.current_file, 'w', encoding='utf-8') as f:
                json.dump(self.settings, f, ensure_ascii=False, indent=2)
            
            self.status_var.set(f"Настройки сохранены в {self.current_file}")
            self.update_file_info()
            messagebox.showinfo("Сохранено", f"Настройки успешно сохранены в файл:\n{self.current_file}")
            
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось сохранить настройки:\n{str(e)}")
            
    def create_template(self):
        """Создание файла шаблона"""
        try:
            template = self.get_default_template()
            with open(self.template_file, 'w', encoding='utf-8') as f:
                json.dump(template, f, ensure_ascii=False, indent=2)
            
            self.status_var.set(f"Шаблон создан: {self.template_file}")
            self.update_file_info()
            messagebox.showinfo("Шаблон создан", 
                              f"Файл шаблона создан:\n{self.template_file}")
                              
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось создать шаблон:\n{str(e)}")
            
    def reset_to_template(self):
        """Сброс настроек к шаблону"""
        if not messagebox.askyesno("Подтверждение", 
                                  "Сбросить все настройки к значениям шаблона?\nТекущие изменения будут потеряны."):
            return
            
        try:
            if os.path.exists(self.template_file):
                with open(self.template_file, 'r', encoding='utf-8') as f:
                    self.settings = json.load(f)
                self.status_var.set("Настройки сброшены к шаблону")
                self.update_tabs()
                if self.settings:
                    first_tab = list(self.settings.keys())[0]
                    self.select_tab(first_tab)
            else:
                messagebox.showwarning("Шаблон не найден", 
                                      "Файл шаблона не найден. Создайте его сначала.")
                                      
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось сбросить настройки:\n{str(e)}")
            
    def export_settings(self):
        """Экспорт настроек в выбранный файл"""
        filename = filedialog.asksaveasfilename(
            defaultextension=".json",
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")],
            initialfile="settings_export.json"
        )
        
        if filename:
            try:
                with open(filename, 'w', encoding='utf-8') as f:
                    json.dump(self.settings, f, ensure_ascii=False, indent=2)
                self.status_var.set(f"Настройки экспортированы в {filename}")
                messagebox.showinfo("Экспорт", f"Настройки успешно экспортированы в:\n{filename}")
            except Exception as e:
                messagebox.showerror("Ошибка", f"Не удалось экспортировать настройки:\n{str(e)}")
                
    def show_json(self):
        """Показать/редактировать JSON в отдельном окне"""
        json_window = tk.Toplevel(self.root)
        json_window.title("Редактор JSON")
        json_window.geometry("800x600")
        
        # Текстовое поле с JSON
        text_frame = ttk.Frame(json_window, padding="10")
        text_frame.pack(fill=tk.BOTH, expand=True)
        
        text_widget = scrolledtext.ScrolledText(text_frame, wrap=tk.NONE, 
                                               font=('Consolas', 10))
        text_widget.pack(fill=tk.BOTH, expand=True)
        
        # Вставка текущих настроек
        try:
            json_text = json.dumps(self.settings, ensure_ascii=False, indent=2)
            text_widget.insert(1.0, json_text)
        except Exception as e:
            text_widget.insert(1.0, f"Ошибка: {str(e)}")
            
        # Кнопки действий
        button_frame = ttk.Frame(json_window, padding="10")
        button_frame.pack(fill=tk.X)
        
        def apply_json():
            """Применить изменения из JSON"""
            try:
                new_settings = json.loads(text_widget.get(1.0, tk.END))
                self.settings = new_settings
                self.update_tabs()
                if self.settings:
                    first_tab = list(self.settings.keys())[0]
                    self.select_tab(first_tab)
                json_window.destroy()
                self.status_var.set("Настройки обновлены из JSON")
                messagebox.showinfo("Успешно", "Настройки обновлены из JSON")
            except Exception as e:
                messagebox.showerror("Ошибка JSON", f"Некорректный JSON:\n{str(e)}")
                
        ttk.Button(button_frame, text="Применить", command=apply_json).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Отмена", command=json_window.destroy).pack(side=tk.LEFT, padx=5)
        
    def get_default_template(self):
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
                    "description": "Максимальное количество элементов для отображения"
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
                    "description": "Таймаут для HTTP запросов в секундах"
                },
                "Использовать кэширование": {
                    "value": True,
                    "type": "boolean",
                    "description": "Включить кэширование API запросов"
                }
            },
            "Внешний вид": {
                "Темная тема": {
                    "value": False,
                    "type": "boolean",
                    "description": "Включение темной темы оформления"
                },
                "Основной цвет": {
                    "value": "#3b82f6",
                    "type": "string",
                    "description": "Основной цвет приложения в HEX формате"
                },
                "Размер шрифта": {
                    "value": 16,
                    "type": "number",
                    "description": "Базовый размер шрифта в пикселях"
                },
                "Тема оформления": {
                    "value": "light",
                    "type": "string",
                    "description": "Тема интерфейса",
                    "options": ["light", "dark", "auto"]
                }
            },
            "Уведомления": {
                "Email уведомления": {
                    "value": True,
                    "type": "boolean",
                    "description": "Включение email уведомлений"
                },
                "Push уведомления": {
                    "value": False,
                    "type": "boolean",
                    "description": "Включение push уведомлений"
                },
                "Звуковые уведомления": {
                    "value": True,
                    "type": "boolean",
                    "description": "Воспроизведение звука при уведомлениях"
                },
                "Email для уведомлений": {
                    "value": "admin@example.com",
                    "type": "string",
                    "description": "Email адрес для отправки уведомлений"
                }
            }
        }
        
    def update_tabs(self):
        """Обновление списка вкладок"""
        # Очищаем контейнер
        for widget in self.tabs_container.winfo_children():
            widget.destroy()
            
        # Создаем кнопки для каждой вкладки
        self.tab_buttons = {}
        for tab_name in self.settings.keys():
            btn = ttk.Button(self.tabs_container, text=tab_name, 
                           style='Tab.TButton', command=lambda t=tab_name: self.select_tab(t))
            btn.pack(fill=tk.X, pady=2)
            self.tab_buttons[tab_name] = btn
            
    def select_tab(self, tab_name):
        """Выбор вкладки для отображения"""
        # Сбрасываем выделение всех кнопок
        for btn in self.tab_buttons.values():
            btn.state(['!pressed'])
            
        # Устанавливаем новую активную вкладку
        self.active_tab = tab_name
        if tab_name in self.tab_buttons:
            self.tab_buttons[tab_name].state(['pressed'])
            
        # Обновляем заголовок
        self.section_title.config(text=tab_name)
        self.section_desc.config(text=f"Редактирование настроек раздела")
        
        # Отображаем настройки выбранной вкладки
        self.display_settings(tab_name)
        
    def display_settings(self, tab_name):
        """Отображение настроек выбранной вкладки"""
        # Очищаем контейнер
        for widget in self.settings_container.winfo_children():
            widget.destroy()
            
        if tab_name not in self.settings:
            ttk.Label(self.settings_container, text="Раздел не найден",
                     font=('Segoe UI', 12)).pack(pady=20)
            return
            
        tab_settings = self.settings[tab_name]
        
        # Создаем виджеты для каждой настройки
        self.setting_widgets = {}
        row = 0
        
        for setting_name, setting_data in tab_settings.items():
            frame = ttk.LabelFrame(self.settings_container, text=setting_name,
                                 style='Setting.TLabelframe')
            frame.grid(row=row, column=0, sticky=(tk.W, tk.E), padx=5, pady=5)
            frame.columnconfigure(1, weight=1)
            row += 1
            
            # Описание
            desc_label = ttk.Label(frame, text=setting_data.get('description', 'Без описания'),
                                  font=('Segoe UI', 9))
            desc_label.grid(row=0, column=0, columnspan=2, sticky=tk.W, pady=(0, 10))
            
            # Контрол в зависимости от типа
            value_frame = ttk.Frame(frame)
            value_frame.grid(row=1, column=0, columnspan=2, sticky=(tk.W, tk.E))
            
            widget = self.create_setting_widget(value_frame, tab_name, setting_name, setting_data)
            self.setting_widgets[(tab_name, setting_name)] = widget
            
    def create_setting_widget(self, parent, tab_name, setting_name, setting_data):
        """Создание виджета для настройки в зависимости от типа"""
        value = setting_data['value']
        setting_type = setting_data.get('type', 'string')
        var = None
        
        if setting_type == 'boolean':
            var = tk.BooleanVar(value=value)
            widget = ttk.Checkbutton(parent, text="Включено", variable=var,
                                   command=lambda: self.update_setting(tab_name, setting_name, var.get()))
            widget.pack(anchor=tk.W)
            
        elif setting_type == 'number':
            var = tk.StringVar(value=str(value))
            widget = ttk.Spinbox(parent, from_=0, to=999999, textvariable=var,
                               width=20, command=lambda: self.update_setting(tab_name, setting_name, float(var.get())))
            widget.pack(anchor=tk.W)
            widget.bind('<FocusOut>', 
                       lambda e: self.update_setting(tab_name, setting_name, float(var.get())))
            
        elif setting_type == 'string' and 'options' in setting_data:
            var = tk.StringVar(value=value)
            widget = ttk.Combobox(parent, textvariable=var, 
                                values=setting_data['options'], state='readonly', width=20)
            widget.pack(anchor=tk.W)
            widget.bind('<<ComboboxSelected>>', 
                       lambda e: self.update_setting(tab_name, setting_name, var.get()))
            
        else:  # string или другой тип
            var = tk.StringVar(value=str(value))
            widget = ttk.Entry(parent, textvariable=var, width=30)
            widget.pack(fill=tk.X)
            widget.bind('<FocusOut>', 
                       lambda e: self.update_setting(tab_name, setting_name, var.get()))
            
        return {'widget': widget, 'var': var, 'type': setting_type}
        
    def update_setting(self, tab_name, setting_name, value):
        """Обновление значения настройки"""
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

def main():
    """Запуск приложения"""
    root = tk.Tk()
    app = SettingsEditor(root)
    
    # Обработка закрытия окна
    def on_closing():
        if messagebox.askyesno("Выход", "Сохранить настройки перед выходом?"):
            app.save_settings()
        root.destroy()
        
    root.protocol("WM_DELETE_WINDOW", on_closing)
    root.mainloop()

if __name__ == "__main__":
    main()