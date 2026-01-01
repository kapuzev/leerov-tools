# -*- coding: utf-8 -*-

from tkinter import ttk
import config

def setup_styles():
    """Настройка стилей Tkinter"""
    style = ttk.Style()
    style.theme_use('clam')
    
    # Настройка цветов темы
    style.configure('.', 
                   background=config.COLORS['light_bg'],
                   foreground='black')
    
    # Кастомные стили
    style.configure('Title.TLabel', 
                   font=config.FONTS['title'])
    
    style.configure('Subtitle.TLabel', 
                   font=config.FONTS['subtitle'],
                   foreground='#666')
    
    style.configure('Section.TLabel',
                   font=config.FONTS['section'])
    
    # Кнопки вкладок
    style.configure('Tab.TButton',
                   font=config.FONTS['normal'],
                   padding=10)
    
    # Фреймы настроек
    style.configure('Setting.TLabelframe',
                   padding=10,
                   relief=tk.RAISED,
                   borderwidth=1)
    
    style.configure('Setting.TLabelframe.Label',
                   font=('Segoe UI', 10, 'bold'),
                   foreground=config.COLORS['primary'])
    
    # Статусы
    style.configure('Success.TLabel',
                   foreground=config.COLORS['success'])
    
    style.configure('Error.TLabel',
                   foreground=config.COLORS['error'])
    
    style.configure('Warning.TLabel',
                   foreground=config.COLORS['warning'])
    
    # Кнопки действий
    style.configure('Primary.TButton',
                   background=config.COLORS['primary'],
                   foreground='white',
                   borderwidth=0)
    
    style.map('Primary.TButton',
             background=[('active', '#2c5282')])
    
    # Заголовки настроек
    style.configure('SettingTitle.TLabel',
                   font=('Segoe UI', 11, 'bold'),
                   foreground='#2d3748')
    
    return style