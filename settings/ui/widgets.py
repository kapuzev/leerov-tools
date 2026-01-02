# -*- coding: utf-8 -*-

import tkinter as tk
from tkinter import ttk
from tkinter import scrolledtext
import config

class ScrollableFrame(ttk.Frame):
    """Прокручиваемый Frame"""
    
    def __init__(self, parent, **kwargs):
        super().__init__(parent, **kwargs)
        
        # Создаем Canvas и Scrollbar
        self.canvas = tk.Canvas(self, highlightthickness=0, bg=config.COLORS['bg_primary'])
        self.scrollbar = ttk.Scrollbar(self, orient="vertical", 
                                      command=self.canvas.yview)
        self.scrollable_frame = ttk.Frame(self.canvas)
        
        self.canvas.configure(yscrollcommand=self.scrollbar.set)
        self.canvas_window = self.canvas.create_window(
            (0, 0), window=self.scrollable_frame, anchor="nw"
        )
        
        # Упаковка
        self.canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Привязка событий
        self.scrollable_frame.bind("<Configure>", self.on_frame_configure)
        self.canvas.bind("<Configure>", self.on_canvas_configure)
        self.canvas.bind_all("<MouseWheel>", self.on_mousewheel)
        
    def on_frame_configure(self, event=None):
        """Обновление scrollregion"""
        self.canvas.configure(scrollregion=self.canvas.bbox("all"))
        
    def on_canvas_configure(self, event):
        """Изменение ширины внутреннего frame"""
        canvas_width = event.width
        self.canvas.itemconfig(self.canvas_window, width=canvas_width)
        
    def on_mousewheel(self, event):
        """Прокрутка колесиком мыши"""
        self.canvas.yview_scroll(int(-1*(event.delta/120)), "units")

class SettingWidget(ttk.Frame):
    """Виджет для настройки"""
    
    def __init__(self, parent, setting_name, setting_data, 
                 on_change_callback=None, **kwargs):
        super().__init__(parent, **kwargs)
        
        self.setting_name = setting_name
        self.setting_data = setting_data
        
        # Обернем колбэк для правильной передачи аргументов
        if on_change_callback:
            # Создаем замыкание для сохранения текущих значений
            self.on_change = lambda value=None: on_change_callback(value)
        else:
            self.on_change = None
        
        self.create_widgets()
        
    def create_widgets(self):
        """Создание виджетов настройки"""
        # Основной фрейм с рамкой
        self.configure(relief='solid', borderwidth=1)
        
        # Заголовок и тип
        header_frame = ttk.Frame(self)
        header_frame.pack(fill=tk.X, padx=10, pady=(10, 5))
        
        ttk.Label(header_frame, text=self.setting_name,
                 font=config.FONTS['normal']).pack(side=tk.LEFT)
        
        setting_type = self.setting_data.get('type', 'string')
        ttk.Label(header_frame, text=f"({setting_type})",
                 font=('Segoe UI', 8),
                 foreground=config.COLORS['text_muted']).pack(side=tk.LEFT, padx=(5, 0))
        
        # Описание
        description = self.setting_data.get('description', '')
        if description:
            ttk.Label(self, text=description,
                     font=('Segoe UI', 9),
                     foreground=config.COLORS['text_muted'],
                     wraplength=400,
                     justify=tk.LEFT).pack(fill=tk.X, padx=10, pady=(0, 10))
        
        # Контрол в зависимости от типа
        self.create_control()
        
    def create_control(self):
        """Создание контрола в зависимости от типа"""
        value = self.setting_data['value']
        setting_type = self.setting_data.get('type', 'string')
        
        control_frame = ttk.Frame(self)
        control_frame.pack(fill=tk.X, padx=10, pady=(0, 10))
        
        if setting_type == 'boolean':
            self.var = tk.BooleanVar(value=value)
            self.control = ttk.Checkbutton(
                control_frame, text="Включено", 
                variable=self.var,
                command=lambda: self._handle_change()
            )
            self.control.pack(anchor=tk.W)
            
        elif setting_type == 'number':
            self.var = tk.StringVar(value=str(value))
            min_val = self.setting_data.get('min', 0)
            max_val = self.setting_data.get('max', 999999)
            
            self.control = ttk.Spinbox(
                control_frame, 
                from_=min_val, to=max_val,
                textvariable=self.var,
                width=15,
                command=self._handle_change
            )
            self.control.pack(anchor=tk.W)
            self.control.bind('<FocusOut>', lambda e: self._handle_change())
            
        elif setting_type == 'string' and 'options' in self.setting_data:
            self.var = tk.StringVar(value=value)
            self.control = ttk.Combobox(
                control_frame,
                textvariable=self.var,
                values=self.setting_data['options'],
                state='readonly',
                width=20
            )
            self.control.pack(anchor=tk.W)
            self.control.bind('<<ComboboxSelected>>', lambda e: self._handle_change())
            
        else:  # string или другой тип
            self.var = tk.StringVar(value=str(value))
            self.control = ttk.Entry(
                control_frame,
                textvariable=self.var,
                width=30
            )
            self.control.pack(fill=tk.X)
            self.control.bind('<KeyRelease>', lambda e: self._handle_change())
            
    def _handle_change(self):
        """Обработчик изменения значения"""
        if self.on_change:
            self.on_change(self.get_value())
            
    def get_value(self):
        """Получение значения с правильным типом"""
        setting_type = self.setting_data.get('type', 'string')
        
        if setting_type == 'boolean':
            return self.var.get()
        elif setting_type == 'number':
            try:
                return float(self.var.get())
            except ValueError:
                return 0
        else:
            return str(self.var.get())

class JsonEditorDialog:
    """Диалоговое окно редактора JSON"""
    
    def __init__(self, parent, json_text, title="Редактор JSON"):
        self.parent = parent
        self.json_text = json_text
        self.title = title
        
        self.create_dialog()
        
    def create_dialog(self):
        """Создание диалогового окна"""
        self.dialog = tk.Toplevel(self.parent)
        self.dialog.title(self.title)
        self.dialog.geometry("800x600")
        self.dialog.configure(bg=config.COLORS['bg_primary'])
        self.dialog.transient(self.parent)
        self.dialog.grab_set()
        
        # Основной контейнер
        main_frame = ttk.Frame(self.dialog, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Текстовое поле
        text_frame = ttk.Frame(main_frame)
        text_frame.pack(fill=tk.BOTH, expand=True)
        
        self.text_widget = scrolledtext.ScrolledText(
            text_frame, 
            wrap=tk.NONE,
            font=config.FONTS['monospace'],
            bg=config.COLORS['input_bg'],
            fg=config.COLORS['input_text'],
            insertbackground=config.COLORS['text_primary']
        )
        self.text_widget.pack(fill=tk.BOTH, expand=True)
        self.text_widget.insert(1.0, self.json_text)
        
        # Кнопки действий
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill=tk.X, pady=(10, 0))
        
        ttk.Button(button_frame, text="Применить", 
                  command=self.on_apply).pack(side=tk.LEFT, padx=5)
        ttk.Button(button_frame, text="Отмена", 
                  command=self.dialog.destroy).pack(side=tk.LEFT, padx=5)
                  
    def on_apply(self):
        """Применить изменения"""
        self.result = self.text_widget.get(1.0, tk.END)
        self.dialog.destroy()
        
    def show(self):
        """Показать диалог и вернуть результат"""
        self.parent.wait_window(self.dialog)
        return getattr(self, 'result', None)