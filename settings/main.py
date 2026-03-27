#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Минимальный редактор настроек JSON
"""

import json
import os
import tkinter as tk
from tkinter import ttk, messagebox

# ========== КОНФИГУРАЦИЯ ==========
SETTINGS_FILE = os.path.join(os.path.dirname(__file__), "settings.json")
WINDOW_SIZE = "900x700"

# Цветовая схема (тёмная, но контрастная)
COLORS = {
    'bg': '#1e1e2e',           # Основной фон
    'bg_secondary': '#2d2d3a',  # Вторичный фон (секции)
    'fg': '#cdd6f4',            # Основной текст
    'fg_muted': '#a6adc8',      # Приглушённый текст
    'accent': '#89b4fa',        # Акцентный цвет
    'accent_hover': '#b4befe',  # Акцент при наведении
    'success': '#a6e3a1',       # Зелёный для успеха
    'error': '#f38ba8',         # Красный для ошибок
    'entry_bg': '#313244',      # Фон полей ввода
    'entry_fg': '#cdd6f4',      # Текст в полях
    'button_bg': '#45475a',     # Фон кнопок
    'button_fg': '#cdd6f4',     # Текст кнопок
    'border': '#45475a',        # Цвет границ
    'check_bg': '#313244',      # Фон чекбокса
    'select_bg': '#45475a',     # Фон выделения
}


class JsonEditor:
    """Простой редактор JSON настроек"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("Редактор настроек JSON")
        self.root.geometry(WINDOW_SIZE)
        self.root.configure(bg=COLORS['bg'])
        
        self.settings = {}
        self.widgets = {}  # {path: (var, type, widget)}
        
        self.create_widgets()
        self.load_settings()
        
    def create_widgets(self):
        """Создание интерфейса"""
        # Стили для ttk
        self.setup_styles()
        
        # Верхняя панель
        top_frame = tk.Frame(self.root, bg=COLORS['bg'])
        top_frame.pack(fill=tk.X, padx=10, pady=10)
        
        # Кнопки
        btn_style = {'bg': COLORS['button_bg'], 'fg': COLORS['button_fg'],
                    'activebackground': COLORS['accent'], 'activeforeground': 'white',
                    'font': ('Segoe UI', 10), 'padx': 15, 'pady': 5,
                    'relief': tk.FLAT, 'bd': 0}
        
        tk.Button(top_frame, text="📂 Загрузить", command=self.load_settings, **btn_style).pack(side=tk.LEFT, padx=2)
        tk.Button(top_frame, text="💾 Сохранить", command=self.save_settings, **btn_style).pack(side=tk.LEFT, padx=2)
        tk.Button(top_frame, text="🔄 Обновить", command=self.refresh_display, **btn_style).pack(side=tk.LEFT, padx=2)
        
        # Информация о файле
        self.file_label = tk.Label(top_frame, text="", bg=COLORS['bg'], fg=COLORS['fg_muted'],
                                   font=('Segoe UI', 9))
        self.file_label.pack(side=tk.RIGHT, padx=10)
        
        # Область с прокруткой
        self.create_scrollable_area()
        
        # Статус бар
        self.status_bar = tk.Label(self.root, text=" Готов", bg=COLORS['bg_secondary'], 
                                   fg=COLORS['fg_muted'], anchor=tk.W,
                                   font=('Segoe UI', 9), relief=tk.FLAT, padx=5)
        self.status_bar.pack(side=tk.BOTTOM, fill=tk.X)
        
    def setup_styles(self):
        """Настройка стилей ttk"""
        style = ttk.Style()
        style.theme_use('clam')
        
        # Стиль для LabelFrame
        style.configure('TLabelframe', background=COLORS['bg'], foreground=COLORS['fg'],
                       borderwidth=1, relief='solid')
        style.configure('TLabelframe.Label', background=COLORS['bg'], 
                       foreground=COLORS['accent'], font=('Segoe UI', 11, 'bold'))
        
        # Стиль для кнопок ttk (если понадобятся)
        style.configure('TButton', background=COLORS['button_bg'], foreground=COLORS['button_fg'],
                       borderwidth=0, focuscolor='none')
        style.map('TButton', background=[('active', COLORS['accent'])])
        
    def create_scrollable_area(self):
        """Создание области с прокруткой"""
        # Контейнер
        self.main_container = tk.Frame(self.root, bg=COLORS['bg'])
        self.main_container.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        # Canvas и Scrollbar
        self.canvas = tk.Canvas(self.main_container, bg=COLORS['bg'], 
                                highlightthickness=0, bd=0)
        scrollbar = ttk.Scrollbar(self.main_container, orient="vertical", 
                                  command=self.canvas.yview)
        
        # Внутренний фрейм
        self.scrollable_frame = tk.Frame(self.canvas, bg=COLORS['bg'])
        
        self.canvas.configure(yscrollcommand=scrollbar.set)
        self.canvas_window = self.canvas.create_window((0, 0), window=self.scrollable_frame, 
                                                       anchor="nw", width=self.canvas.winfo_width())
        
        self.canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")
        
        # Обновление размера
        self.scrollable_frame.bind("<Configure>", self._on_frame_configure)
        self.canvas.bind("<Configure>", self._on_canvas_configure)
        
        # Колесико мыши
        self.canvas.bind_all("<MouseWheel>", self._on_mousewheel)
        
    def _on_frame_configure(self, event=None):
        self.canvas.configure(scrollregion=self.canvas.bbox("all"))
        
    def _on_canvas_configure(self, event):
        self.canvas.itemconfig(self.canvas_window, width=event.width)
        
    def _on_mousewheel(self, event):
        self.canvas.yview_scroll(int(-1*(event.delta/120)), "units")
        
    def load_settings(self):
        """Загрузка настроек из файла"""
        try:
            if os.path.exists(SETTINGS_FILE):
                with open(SETTINGS_FILE, 'r', encoding='utf-8') as f:
                    self.settings = json.load(f)
                self._set_status(f"✓ Загружено: {os.path.basename(SETTINGS_FILE)}", success=True)
                self.file_label.config(text=f"📄 {os.path.basename(SETTINGS_FILE)}")
            else:
                self.settings = {}
                self._set_status("✗ Файл не найден, создан пустой", success=False)
                self.file_label.config(text="📄 (нет файла)")
            
            self.refresh_display()
            
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось загрузить:\n{e}")
            self._set_status(f"✗ Ошибка: {e}", success=False)
            
    def save_settings(self):
        """Сохранение настроек"""
        # Собираем значения из виджетов
        self._collect_values()
        
        try:
            with open(SETTINGS_FILE, 'w', encoding='utf-8') as f:
                json.dump(self.settings, f, ensure_ascii=False, indent=2)
            self._set_status(f"✓ Сохранено: {os.path.basename(SETTINGS_FILE)}", success=True)
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось сохранить:\n{e}")
            self._set_status(f"✗ Ошибка: {e}", success=False)
            
    def refresh_display(self):
        """Обновление отображения"""
        # Очищаем старые виджеты
        for widget in self.scrollable_frame.winfo_children():
            widget.destroy()
        self.widgets.clear()
        
        if not self.settings:
            tk.Label(self.scrollable_frame, text="📭 Нет настроек\n\nСоздайте файл settings.json", 
                    bg=COLORS['bg'], fg=COLORS['fg_muted'], font=('Segoe UI', 12),
                    justify=tk.CENTER).pack(pady=50)
            return
            
        # Создаём виджеты для каждой секции
        for section_name, section_data in self.settings.items():
            self._create_section(section_name, section_data)
            
    def _create_section(self, name, data):
        """Создание секции настроек"""
        # Рамка секции
        section_frame = ttk.LabelFrame(self.scrollable_frame, text=f" ⚙️ {name} ", 
                                       padding="10")
        section_frame.pack(fill=tk.X, pady=10, padx=5)
        
        # Внутренний фрейм для настроек
        inner_frame = tk.Frame(section_frame, bg=COLORS['bg'])
        inner_frame.pack(fill=tk.X, expand=True)
        
        # Проходим по настройкам в секции
        for setting_name, setting_data in data.items():
            self._create_setting_row(inner_frame, f"{name}.{setting_name}", 
                                     setting_name, setting_data)
            
    def _create_setting_row(self, parent, full_path, name, data):
        """Создание строки настройки"""
        frame = tk.Frame(parent, bg=COLORS['bg'])
        frame.pack(fill=tk.X, pady=8, padx=5)
        
        # Название настройки
        label = tk.Label(frame, text=name, bg=COLORS['bg'], fg=COLORS['fg'],
                        font=('Segoe UI', 10, 'bold'), width=28, anchor='w')
        label.pack(side=tk.LEFT, padx=5)
        
        # Тип настройки (иконка)
        setting_type = data.get('type', 'string')
        type_icons = {'string': '📝', 'boolean': '☑️', 'number': '🔢'}
        type_icon = type_icons.get(setting_type, '📄')
        tk.Label(frame, text=type_icon, bg=COLORS['bg'], fg=COLORS['fg_muted'],
                font=('Segoe UI', 9)).pack(side=tk.LEFT, padx=2)
        
        # Значение (в зависимости от типа)
        value = data.get('value', '')
        
        # Фрейм для контрола
        control_frame = tk.Frame(frame, bg=COLORS['bg'])
        control_frame.pack(side=tk.LEFT, padx=10, fill=tk.X, expand=True)
        
        if setting_type == 'boolean':
            var = tk.BooleanVar(value=value)
            widget = tk.Checkbutton(control_frame, text=" Включено", variable=var,
                                    bg=COLORS['bg'], fg=COLORS['fg'],
                                    activebackground=COLORS['bg'],
                                    selectcolor=COLORS['entry_bg'],
                                    font=('Segoe UI', 10))
            widget.pack(anchor=tk.W)
            self.widgets[full_path] = (var, setting_type, widget)
            
        elif setting_type == 'number':
            var = tk.StringVar(value=str(value))
            widget = tk.Spinbox(control_frame, from_=-999999, to=999999, 
                               width=15, textvariable=var,
                               bg=COLORS['entry_bg'], fg=COLORS['entry_fg'],
                               font=('Segoe UI', 10), bd=1, relief=tk.FLAT,
                               highlightthickness=0)
            widget.pack(anchor=tk.W)
            self.widgets[full_path] = (var, setting_type, widget)
            
        else:  # string
            var = tk.StringVar(value=str(value))
            widget = tk.Entry(control_frame, textvariable=var, width=45,
                             bg=COLORS['entry_bg'], fg=COLORS['entry_fg'],
                             font=('Segoe UI', 10), bd=1, relief=tk.FLAT,
                             highlightthickness=0)
            widget.pack(anchor=tk.W, fill=tk.X)
            self.widgets[full_path] = (var, setting_type, widget)
            
        # Описание (если есть)
        desc = data.get('description', '')
        if desc:
            desc_frame = tk.Frame(frame, bg=COLORS['bg'])
            desc_frame.pack(side=tk.RIGHT, padx=5)
            tk.Label(desc_frame, text=desc, bg=COLORS['bg'], fg=COLORS['fg_muted'],
                    font=('Segoe UI', 8), wraplength=250, justify=tk.LEFT).pack()
            
    def _collect_values(self):
        """Сбор значений из виджетов в self.settings"""
        for path, (var, setting_type, widget) in self.widgets.items():
            # Разбираем путь: "section.setting"
            parts = path.split('.')
            if len(parts) != 2:
                continue
                
            section, setting = parts
            if section not in self.settings:
                continue
                
            if setting not in self.settings[section]:
                continue
                
            value = var.get()
            
            # Преобразуем тип
            if setting_type == 'boolean':
                value = bool(value)
            elif setting_type == 'number':
                try:
                    value = float(value) if '.' in str(value) else int(value)
                except ValueError:
                    value = 0
                    
            self.settings[section][setting]['value'] = value
            
    def _set_status(self, message, success=True):
        """Показать сообщение в статус-баре"""
        color = COLORS['success'] if success else COLORS['error']
        self.status_bar.config(text=f" {message}", fg=color)
        self.root.after(3000, lambda: self.status_bar.config(text=" Готов", fg=COLORS['fg_muted']))


def main():
    root = tk.Tk()
    app = JsonEditor(root)
    
    def on_closing():
        if messagebox.askyesno("Выход", "Сохранить изменения перед выходом?"):
            app.save_settings()
        root.destroy()
        
    root.protocol("WM_DELETE_WINDOW", on_closing)
    root.mainloop()


if __name__ == "__main__":
    main()