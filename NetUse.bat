echo off
net use /delete S:
net use S: \\pc_913\Db /user:user_bd user_bd
if exist s:\ call Y:\ASKUE\MTerminal\MTerminal.exe 
if not exist s:\ echo ��� ᮥ������� � �ନ����� 
if not exist s:\ pause
