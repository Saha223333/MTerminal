Option Explicit

dim path, WshShell, fs,wn,ap,login,pass

Set fs = WScript.CreateObject("Scripting.FileSystemObject")
Set wn = WScript.CreateObject("WScript.Network")
Set ap = CreateObject("Shell.Application")
if fs.DriveExists("S:") then wn.RemoveNetworkDrive "S:", true, true
wn.MapNetworkDrive "S:", "\\pc_913\Db",false, login, pass
MsgBox "���� ���������!!!"

' ������ ���� � ��������� �����
path = "Y:\ASKUE\MTerminal\"

' ������� ������ �� ������ WscriptShell
set WshShell = WScript.CreateObject("Wscript.Shell")

' ��������� ��������� (Wshshell Run)
WshShell.Run path & "MTerminal.exe", ,true
MsgBox "��������� ��������� ������!!!" & vbCrLf & "��������� ����"

