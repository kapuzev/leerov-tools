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
WINDOW_SIZE = "800x600"
BG_COLOR = "#2d2d2d"
FG_COLOR = "#ffffff"
ENTRY_BG = "#3c3c3c"
BUTTON_BG = "#4a4a4a"


class JsonEditor:
    """Простой редактор JSON настроек"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("Редактор настроек JSON")
        self.root.geometry(WINDOW_SIZE)
        self.root.configure(bg=BG_COLOR)
        
        self.settings = {}
        self.widgets = {}  # {path: widget_var}
        
        self.create_widgets()
        self.load_settings()
        
    def create_widgets(self):
        """Создание интерфейса"""
        # Верхняя панель
        top_frame = tk.Frame(self.root, bg=BG_COLOR)
        top_frame.pack(fill=tk.X, padx=10, pady=5)
        
        tk.Button(top_frame, text="Загрузить", command=self.load_settings,
                 bg=BUTTON_BG, fg=FG_COLOR).pack(side=tk.LEFT, padx=2)
        tk.Button(top_frame, text="Сохранить", command=self.save_settings,
                 bg=BUTTON_BG, fg=FG_COLOR).pack(side=tk.LEFT, padx=2)
        tk.Button(top_frame, text="Обновить", command=self.refresh_display,
                 bg=BUTTON_BG, fg=FG_COLOR).pack(side=tk.LEFT, padx=2)
        
        # Область с прокруткой
        self.canvas = tk.Canvas(self.root, bg=BG_COLOR, highlightthickness=0)
        scrollbar = ttk.Scrollbar(self.root, orient="vertical", command=self.canvas.yview)
        self.scrollable_frame = tk.Frame(self.canvas, bg=BG_COLOR)
        
        self.scrollable_frame.bind(
            "<Configure>",
            lambda e: self.canvas.configure(scrollregion=self.canvas.bbox("all"))
        )
        
        self.canvas.create_window((0, 0), window=self.scrollable_frame, anchor="nw")
        self.canvas.configure(yscrollcommand=scrollbar.set)
        
        self.canvas.pack(side="left", fill="both", expand=True, padx=10, pady=10)
        scrollbar.pack(side="right", fill="y")
        
        # Привязка колесика мыши
        self.canvas.bind_all("<MouseWheel>", self._on_mousewheel)
        
    def _on_mousewheel(self, event):
        self.canvas.yview_scroll(int(-1*(event.delta/120)), "units")
        
    def load_settings(self):
        """Загрузка настроек из файла"""
        try:
            if os.path.exists(SETTINGS_FILE):
                with open(SETTINGS_FILE, 'r', encoding='utf-8') as f:
                    self.settings = json.load(f)
                self.status("Загружено", success=True)
            else:
                self.settings = {}
                self.status("Файл не найден, создан пустой", success=False)
            
            self.refresh_display()
            
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось загрузить: {e}")
            self.status(f"Ошибка: {e}", success=False)
            
    def save_settings(self):
        """Сохранение настроек"""
        # Собираем значения из виджетов
        self._collect_values()
        
        try:
            with open(SETTINGS_FILE, 'w', encoding='utf-8') as f:
                json.dump(self.settings, f, ensure_ascii=False, indent=2)
            self.status("Сохранено", success=True)
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось сохранить: {e}")
            self.status(f"Ошибка: {e}", success=False)
            
    def refresh_display(self):
        """Обновление отображения"""
        # Очищаем старые виджеты
        for widget in self.scrollable_frame.winfo_children():
            widget.destroy()
        self.widgets.clear()
        
        if not self.settings:
            tk.Label(self.scrollable_frame, text="Нет настроек", 
                    bg=BG_COLOR, fg=FG_COLOR).pack(pady=20)
            return
            
        # Создаем виджеты для каждой настройки
        for section_name, section_data in self.settings.items():
            self._create_section(section_name, section_data)
            
    def _create_section(self, name, data):
        """Создание секции настроек"""
        # Рамка секции
        section_frame = tk.LabelFrame(self.scrollable_frame, text=name, 
                                      bg=BG_COLOR, fg=FG_COLOR,
                                      font=('Arial', 10, 'bold'))
        section_frame.pack(fill=tk.X, pady=10, padx=5)
        
        # Проходим по настройкам в секции
        for setting_name, setting_data in data.items():
            self._create_setting_row(section_frame, f"{name}.{setting_name}", 
                                     setting_name, setting_data)
            
    def _create_setting_row(self, parent, full_path, name, data):
        """Создание строки настройки"""
        frame = tk.Frame(parent, bg=BG_COLOR)
        frame.pack(fill=tk.X, padx=5, pady=5)
        
        # Название
        label = tk.Label(frame, text=name, bg=BG_COLOR, fg=FG_COLOR, width=25, anchor='w')
        label.pack(side=tk.LEFT, padx=5)
        
        # Значение (в зависимости от типа)
        setting_type = data.get('type', 'string')
        value = data.get('value', '')
        
        if setting_type == 'boolean':
            var = tk.BooleanVar(value=value)
            widget = tk.Checkbutton(frame, variable=var, bg=BG_COLOR, fg=FG_COLOR,
                                   selectcolor=BG_COLOR)
            widget.pack(side=tk.LEFT)
            self.widgets[full_path] = (var, setting_type)
            
        elif setting_type == 'number':
            var = tk.StringVar(value=str(value))
            widget = tk.Spinbox(frame, from_=0, to=999999, width=15,
                               textvariable=var, bg=ENTRY_BG, fg=FG_COLOR)
            widget.pack(side=tk.LEFT)
            self.widgets[full_path] = (var, setting_type)
            
        else:  # string
            var = tk.StringVar(value=str(value))
            widget = tk.Entry(frame, textvariable=var, width=40,
                             bg=ENTRY_BG, fg=FG_COLOR)
            widget.pack(side=tk.LEFT, fill=tk.X, expand=True)
            self.widgets[full_path] = (var, setting_type)
            
        # Описание (если есть)
        desc = data.get('description', '')
        if desc:
            tk.Label(frame, text=desc, bg=BG_COLOR, fg='#888888',
                    font=('Arial', 8)).pack(side=tk.LEFT, padx=10)
            
    def _collect_values(self):
        """Сбор значений из виджетов в self.settings"""
        for path, (var, setting_type) in self.widgets.items():
            # Разбираем путь: "section.setting"
            parts = path.split('.')
            if len(parts) != 2:
                continue
                
            section, setting = parts
            if section not in self.settings:
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
            
    def status(self, message, success=True):
        """Показать сообщение в статус-баре"""
        # Создаем статус-бар если его нет
        if not hasattr(self, 'status_bar'):
            self.status_bar = tk.Label(self.root, text="", bg=BG_COLOR, fg=FG_COLOR,
                                       relief=tk.SUNKEN, anchor=tk.W)
            self.status_bar.pack(side=tk.BOTTOM, fill=tk.X)
        
        color = "#4caf50" if success else "#f44336"
        self.status_bar.config(text=f"  {message}", fg=color)
        self.root.after(3000, lambda: self.status_bar.config(text="", fg=FG_COLOR))


def main():
    root = tk.Tk()
    app = JsonEditor(root)
    
    def on_closing():
        if messagebox.askyesno("Выход", "Сохранить изменения?"):
            app.save_settings()
        root.destroy()
        
    root.protocol("WM_DELETE_WINDOW", on_closing)
    root.mainloop()


if __name__ == "__main__":
    main()