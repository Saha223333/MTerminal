Option Explicit

dim path, WshShell, fs,wn,ap,login,pass

' ������ ���� � ��������� �����
path = "Y:\ASKUE\MTerminal\"

' ������� ������ �� ������ WscriptShell
set WshShell = WScript.CreateObject("Wscript.Shell")

' ��������� ��������� (Wshshell Run)
WshShell.Run path & "MTerminal.exe", ,true
MsgBox "��������� ��������� ������!!!" & vbCrLf & "��������� ����"

