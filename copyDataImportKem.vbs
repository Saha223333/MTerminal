Const OverwriteExisting = True
Set objFSO = CreateObject("Scripting.FileSystemObject")
objFSO.DeleteFile "C:\MTerminal\Db\*.*"
If objFSO.FileExists("S:\Account.X09") and objFSO.FileExists("S:\Account.X07") Then 
objFSO.DeleteFile "S:\*.*07"
objFSO.MoveFile "S:\Account.X09", "S:\Account.X07"
objFSO.MoveFile "S:\Account.Y09", "S:\Account.Y07"
End If 
objFSO.CopyFile "S:\*.*" , "C:\MTerminal\Db", OverwriteExisting
MsgBox "Файлы скопированы!!!"