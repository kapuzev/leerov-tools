#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import tkinter as tk
from tkinter import messagebox
from core.editor import SettingsEditor

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