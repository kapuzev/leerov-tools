-- Открытие системных настроек
on openSystemPreferences(paneID, anchorName)
    try
        if anchorName is not "" then
            do shell script "open 'x-apple.systempreferences:" & paneID & "?" & anchorName & "'"
        else
            do shell script "open 'x-apple.systempreferences:" & paneID & "'"
        end if
    on error
        tell application "System Preferences"
            activate
            if anchorName is not "" then
                reveal anchor anchorName of pane id paneID
            else
                set current pane to pane id paneID
            end if
        end tell
    end try
    delay 1 -- Даем время для открытия
end openSystemPreferences

-- Ожидание элемента
on waitForElement(elementDescription, timeout)
    set startTime to current date
    repeat
        try
            tell application "System Events"
                tell process "System Settings"
                    return elementDescription
                end tell
            end tell
        on error
            if (current date) - startTime > timeout then
                error "Timeout waiting for element"
            end if
            delay 0.5
        end try
    end repeat
end waitForElement

-- Клик по элементу
on clickElement(elementDescription)
    tell application "System Events"
        tell process "System Settings"
            click elementDescription
        end tell
    end tell
end clickElement

-- Установить состояние чекбокса
on setCheckboxState(checkboxDescription, state)
    tell application "System Events"
        tell process "System Settings"
            set checkbox to checkboxDescription
            set currentState to (value of checkbox as boolean)
            
            if currentState is not state then
                click checkbox
            end if
        end tell
    end tell
end setCheckboxState

-- Получить состояние чекбокса
on getCheckboxState(checkboxDescription)
    tell application "System Events"
        tell process "System Settings"
            set checkbox to checkboxDescription
            return (value of checkbox as boolean)
        end tell
    end tell
end getCheckboxState

-- Переключить чекбокс
on toggleCheckbox(checkboxDescription)
    tell application "System Events"
        tell process "System Settings"
            set checkbox to checkboxDescription
            click checkbox
        end tell
    end tell
end toggleCheckbox

-- Выбрать значение из выпадающего списка
on selectPopupValue(popupDescription, valueToSelect)
    tell application "System Events"
        tell process "System Settings"
            set popup to popupDescription
            click popup
            
            -- Ждем появления меню
            delay 0.5
            
            -- Выбираем значение
            click (menu item valueToSelect of menu 1 of popup)
        end tell
    end tell
end selectPopupValue

-- Получить текущее значение выпадающего списка
on getPopupValue(popupDescription)
    tell application "System Events"
        tell process "System Settings"
            set popup to popupDescription
            return value of popup
        end tell
    end tell
end getPopupValue

-- Получить список всех значений выпадающего списка
on getPopupValues(popupDescription)
    tell application "System Events"
        tell process "System Settings"
            set popup to popupDescription
            click popup
            delay 0.5
            
            set menuItems to name of menu items of menu 1 of popup
            click popup -- закрываем меню
            
            return menuItems
        end tell
    end tell
end getPopupValues

-- Выбрать радиокнопку
on selectRadioButton(radioGroupDescription, buttonValue)
    tell application "System Events"
        tell process "System Settings"
            set radioButtons to radio buttons of radioGroupDescription
            
            repeat with radioButton in radioButtons
                if value of radioButton is buttonValue then
                    click radioButton
                    exit repeat
                end if
            end repeat
        end tell
    end tell
end selectRadioButton

-- Получить выбранную радиокнопку
on getSelectedRadioButton(radioGroupDescription)
    tell application "System Events"
        tell process "System Settings"
            set radioButtons to radio buttons of radioGroupDescription
            
            repeat with radioButton in radioButtons
                if value of radioButton is 1 then
                    return name of radioButton
                end if
            end repeat
        end tell
    end tell
end getSelectedRadioButton

-- Установить значение ползунка
on setSliderValue(sliderDescription, newValue)
    tell application "System Events"
        tell process "System Settings"
            set slider to sliderDescription
            set value of slider to newValue
        end tell
    end tell
end setSliderValue

-- Получить значение ползунка
on getSliderValue(sliderDescription)
    tell application "System Events"
        tell process "System Settings"
            set slider to sliderDescription
            return value of slider
        end tell
    end tell
end getSliderValue

-- Найти и кликнуть по кнопке по заголовку
on clickButtonByTitle(buttonTitle)
    tell application "System Events"
        tell process "System Settings"
            click (first button whose title is buttonTitle)
        end tell
    end tell
end clickButtonByTitle

-- Найти и кликнуть по кнопке по ID
on clickButtonById(buttonId)
    tell application "System Events"
        tell process "System Settings"
            click (first button whose value of attribute "AXIdentifier" is buttonId)
        end tell
    end tell
end clickButtonById

-- Прокрутить к элементу
on scrollToElement(elementDescription)
    tell application "System Events"
        tell process "System Settings"
            set elementToScroll to elementDescription
            set value of attribute "AXSelected" of elementToScroll to true
        end tell
    end tell
end scrollToElement