Const OverwriteExisting = True
Set objFSO = CreateObject("Scripting.FileSystemObject")
objFSO.CopyFile "C:\MTerminal\Db\*.*" , "S:\", OverwriteExisting
MsgBox "Файлы скопированы!!!"