program MTerminal;

uses
  Forms,
  u_main in 'u_main.pas' {MainForm},
  QStrings in '..\Documents and Settings\protasov\Рабочий стол\Работа\BQuarkConsole\QSTRINGS.PAS';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

