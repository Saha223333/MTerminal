Option Explicit

dim path, WshShell, fs,wn,ap,login,pass

' задаем путь к системной папке
path = "Y:\ASKUE\MTerminal\"

' Создаем ссылку на объект WscriptShell
set WshShell = WScript.CreateObject("Wscript.Shell")

' Открываем программу (Wshshell Run)
WshShell.Run path & "MTerminal.exe", ,true
MsgBox "Программа завершила работу!!!" & vbCrLf & "Закрываем окно"

