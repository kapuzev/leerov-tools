property Lib : load script alias ((path to library folder as text) & "Scripts:apple_script_lib.scpt")

-- Использование через tell:
tell Lib to openSystemPreferences("com.apple.preference.keyboard", "")