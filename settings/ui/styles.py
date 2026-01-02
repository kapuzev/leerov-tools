# -*- coding: utf-8 -*-

from tkinter import ttk
import config

def setup_styles():
    """Настройка стилей Tkinter для темной темы"""
    style = ttk.Style()
    
    # Используем тему 'alt' которая лучше подходит для темного режима
    style.theme_use('alt')
    
    # Получаем цвета из конфига
    colors = config.COLORS
    
    # ========== БАЗОВЫЕ СТИЛИ ==========
    
    # Основные настройки
    style.configure('.',
        background=colors['bg_primary'],
        foreground=colors['text_primary'],
        fieldbackground=colors['input_bg'],
        selectbackground=colors['selection_bg'],
        selectforeground=colors['selection_text'],
        insertcolor=colors['text_primary'],
        troughcolor=colors['bg_secondary']
    )
    
    # ========== КОМПОНЕНТЫ ==========
    
    # Frame
    style.configure('TFrame',
        background=colors['bg_primary']
    )
    
    # Label
    style.configure('TLabel',
        background=colors['bg_primary'],
        foreground=colors['text_primary'],
        font=config.FONTS['normal']
    )
    
    # LabelFrame
    style.configure('TLabelframe',
        background=colors['bg_primary'],
        foreground=colors['text_primary'],
        relief='solid',
        borderwidth=1
    )
    style.configure('TLabelframe.Label',
        background=colors['bg_primary'],
        foreground=colors['text_primary'],
        font=('Segoe UI', 10, 'bold')
    )
    
    # ========== КНОПКИ ==========
    
    # Обычные кнопки
    style.configure('TButton',
        background=colors['button_bg'],
        foreground=colors['button_text'],
        borderwidth=1,
        relief='raised',
        font=config.FONTS['normal'],
        padding=(12, 6)
    )
    
    # Состояния кнопок
    style.map('TButton',
        background=[
            ('active', colors['button_bg_hover']),
            ('pressed', colors['button_bg_active'])
        ],
        foreground=[
            ('active', colors['button_text']),
            ('pressed', colors['button_text_active'])
        ],
        relief=[
            ('pressed', 'sunken'),
            ('active', 'raised')
        ]
    )
    
    # Кнопки вкладок
    style.configure('Tab.TButton',
        background=colors['tab_bg'],
        foreground=colors['tab_text'],
        borderwidth=1,
        relief='flat',
        font=config.FONTS['normal'],
        padding=10
    )
    style.map('Tab.TButton',
        background=[
            ('active', colors['tab_bg_hover']),
            ('pressed', colors['tab_bg_active'])
        ],
        foreground=[
            ('active', colors['tab_text']),
            ('pressed', colors['tab_text_active'])
        ]
    )
    
    # ========== ПОЛЯ ВВОДА ==========
    
    # Поля ввода
    style.configure('TEntry',
        fieldbackground=colors['input_bg'],
        foreground=colors['input_text'],
        borderwidth=1,
        relief='solid',
        padding=6
    )
    style.map('TEntry',
        fieldbackground=[
            ('focus', colors['input_bg']),
            ('disabled', colors['bg_secondary'])
        ],
        foreground=[
            ('focus', colors['input_text']),
            ('disabled', colors['text_muted'])
        ]
    )
    
    # ComboBox
    style.configure('TCombobox',
        fieldbackground=colors['input_bg'],
        foreground=colors['input_text'],
        background=colors['bg_secondary'],
        borderwidth=1,
        relief='solid',
        arrowsize=12
    )
    style.map('TCombobox',
        fieldbackground=[
            ('focus', colors['input_bg']),
            ('readonly', colors['input_bg'])
        ],
        foreground=[
            ('focus', colors['input_text']),
            ('disabled', colors['text_muted'])
        ]
    )
    
    # Spinbox
    style.configure('TSpinbox',
        fieldbackground=colors['input_bg'],
        foreground=colors['input_text'],
        background=colors['bg_secondary'],
        borderwidth=1,
        relief='solid',
        arrowsize=12
    )
    style.map('TSpinbox',
        fieldbackground=[
            ('focus', colors['input_bg']),
            ('disabled', colors['bg_secondary'])
        ],
        foreground=[
            ('focus', colors['input_text']),
            ('disabled', colors['text_muted'])
        ]
    )
    
    # ========== ПРОКРУТКА ==========
    
    # Вертикальный скроллбар
    style.configure('Vertical.TScrollbar',
        background=colors['scrollbar_bg'],
        troughcolor=colors['scrollbar_bg'],
        width=10
    )
    style.map('Vertical.TScrollbar',
        background=[
            ('active', colors['scrollbar_thumb_hover']),
            ('pressed', colors['scrollbar_thumb'])
        ]
    )
    
    return style