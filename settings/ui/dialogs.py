# -*- coding: utf-8 -*-

import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
import config

class Dialogs:
    """Класс для работы с диалоговыми окнами"""
    
    @staticmethod
    def show_info(title, message):
        """Показать информационное сообщение"""
        return messagebox.showinfo(title, message)
    
    @staticmethod
    def show_warning(title, message):
        """Показать предупреждение"""
        return messagebox.showwarning(title, message)
    
    @staticmethod
    def show_error(title, message):
        """Показать сообщение об ошибке"""
        return messagebox.showerror(title, message)
    
    @staticmethod
    def ask_yesno(title, message):
        """Задать вопрос Да/Нет"""
        return messagebox.askyesno(title, message)
    
    @staticmethod
    def ask_okcancel(title, message):
        """Задать вопрос ОК/Отмена"""
        return messagebox.askokcancel(title, message)
    
    @staticmethod
    def input_dialog(parent, title, prompt, initial_value=""):
        """Диалог ввода текста"""
        return simpledialog.askstring(title, prompt, 
                                     parent=parent,
                                     initialvalue=initial_value)
    
    @staticmethod
    def create_section_dialog(parent):
        """Диалог создания нового раздела"""
        dialog = tk.Toplevel(parent)
        dialog.title("Новый раздел")
        dialog.geometry("400x200")
        dialog.transient(parent)
        dialog.grab_set()
        
        result = {"name": "", "description": ""}
        
        def on_ok():
            result["name"] = name_entry.get()
            result["description"] = desc_entry.get()
            dialog.destroy()
        
        def on_cancel():
            dialog.destroy()
        
        # Основной контейнер
        main_frame = ttk.Frame(dialog, padding="20")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Название раздела
        ttk.Label(main_frame, text="Название раздела:").pack(anchor=tk.W, pady=(0, 5))
        name_entry = ttk.Entry(main_frame, width=40)
        name_entry.pack(fill=tk.X, pady=(0, 15))
        name_entry.focus_set()
        
        # Описание
        ttk.Label(main_frame, text="Описание (опционально):").pack(anchor=tk.W, pady=(0, 5))
        desc_entry = ttk.Entry(main_frame, width=40)
        desc_entry.pack(fill=tk.X, pady=(0, 20))
        
        # Кнопки
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill=tk.X)
        
        ttk.Button(button_frame, text="Создать", 
                  command=on_ok).pack(side=tk.RIGHT, padx=5)
        ttk.Button(button_frame, text="Отмена", 
                  command=on_cancel).pack(side=tk.RIGHT)
        
        parent.wait_window(dialog)
        return result if result["name"] else None
    
    @staticmethod
    def create_setting_dialog(parent):
        """Диалог создания новой настройки"""
        dialog = tk.Toplevel(parent)
        dialog.title("Новая настройка")
        dialog.geometry("500x350")
        dialog.transient(parent)
        dialog.grab_set()
        
        result = {
            "name": "",
            "type": "string",
            "value": "",
            "description": ""
        }
        
        def on_ok():
            result["name"] = name_entry.get()
            result["type"] = type_var.get()
            result["value"] = value_entry.get()
            result["description"] = desc_entry.get()
            dialog.destroy()
        
        def on_cancel():
            dialog.destroy()
        
        # Основной контейнер
        main_frame = ttk.Frame(dialog, padding="20")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Название настройки
        ttk.Label(main_frame, text="Название настройки:").pack(anchor=tk.W, pady=(0, 5))
        name_entry = ttk.Entry(main_frame, width=40)
        name_entry.pack(fill=tk.X, pady=(0, 10))
        name_entry.focus_set()
        
        # Тип настройки
        ttk.Label(main_frame, text="Тип данных:").pack(anchor=tk.W, pady=(0, 5))
        type_var = tk.StringVar(value="string")
        type_frame = ttk.Frame(main_frame)
        type_frame.pack(fill=tk.X, pady=(0, 10))
        
        types = ["string", "boolean", "number"]
        for t in types:
            ttk.Radiobutton(type_frame, text=t, 
                          variable=type_var, 
                          value=t).pack(side=tk.LEFT, padx=5)
        
        # Значение по умолчанию
        ttk.Label(main_frame, text="Значение по умолчанию:").pack(anchor=tk.W, pady=(0, 5))
        value_entry = ttk.Entry(main_frame, width=40)
        value_entry.pack(fill=tk.X, pady=(0, 10))
        
        # Описание
        ttk.Label(main_frame, text="Описание:").pack(anchor=tk.W, pady=(0, 5))
        desc_entry = ttk.Entry(main_frame, width=40)
        desc_entry.pack(fill=tk.X, pady=(0, 20))
        
        # Кнопки
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill=tk.X)
        
        ttk.Button(button_frame, text="Создать", 
                  command=on_ok).pack(side=tk.RIGHT, padx=5)
        ttk.Button(button_frame, text="Отмена", 
                  command=on_cancel).pack(side=tk.RIGHT)
        
        parent.wait_window(dialog)
        return result if result["name"] else None