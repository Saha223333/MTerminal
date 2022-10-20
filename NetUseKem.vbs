Option Explicit

dim path, WshShell, fs,wn,ap,login,pass

Set fs = WScript.CreateObject("Scripting.FileSystemObject")
Set wn = WScript.CreateObject("WScript.Network")
Set ap = CreateObject("Shell.Application")
if fs.DriveExists("S:") then wn.RemoveNetworkDrive "S:", true, true
wn.MapNetworkDrive "S:", "\\pc_913\Db",false, login, pass
MsgBox "Диск подключен!!!"

' задаем путь к системной папке
path = "Y:\ASKUE\MTerminal\"

' Создаем ссылку на объект WscriptShell
set WshShell = WScript.CreateObject("Wscript.Shell")

' Открываем программу (Wshshell Run)
WshShell.Run path & "MTerminal.exe", ,true
MsgBox "Программа завершила работу!!!" & vbCrLf & "Закрываем окно"

