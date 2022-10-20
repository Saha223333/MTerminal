unit u_main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, DBTables, Grids, DBGrids, ExtCtrls, DBCtrls,
  Oracle, OracleData, ComCtrls, RzLabel, RzPrgres, RzDBProg, Buttons,
  RzButton, RzEdit, GridsEh, DBGridEh, RzLaunch,Bde, DBLists;

type
  TMainForm = class(TForm)
    Button1: TButton;
    DB: TTable;
    DataSource1: TDataSource;
	 ODSLS: TOracleDataSet;
    OS: TOracleSession;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
	 Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
	 Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    ODSLSLS: TIntegerField;
    ODSLSHOUSE: TStringField;
    ODSLSFLAT: TStringField;
    ODSLSFAM: TStringField;
    ODSLSIM: TStringField;
    ODSLSOTCH: TStringField;
    ODSLSZAV_NOM: TStringField;
    ODSLSTYPE_SCH: TIntegerField;
    ODSLSSTREET: TStringField;
    ODSLSNAME: TStringField;
    ODSLSNAME_TP: TStringField;
    DBQ: TQuery;
	 DataSource2: TDataSource;
    OS2: TOracleSession;
    OQ: TOracleQuery;
    OP: TOraclePackage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button19: TRzBitBtn;
    Button18: TRzBitBtn;
    BitBtn1: TRzBitBtn;
    PB: TRzProgressBar;
    Memo1: TRzMemo;
    Grid: TDBGridEh;
    Label4: TLabel;
    ODSLSUCHASTOK: TStringField;
    ODSDatch_m: TOracleDataSet;
    DataSource3: TDataSource;
    DataSource4: TDataSource;
    DB2: TTable;
    Launcher: TRzLauncher;
    Label5: TLabel;
    Button20: TButton;
    RzL: TRzLabel;
    RzBitBtn1: TRzBitBtn;
    Resttemp: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button17Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
	 procedure Button20Click(Sender: TObject);
	 procedure ShM;
    procedure RzBitBtn1Click(Sender: TObject);
    procedure ResttempClick(Sender: TObject);
  private
	 { Private declarations }
  public
	 { Public declarations }
  end;

  TExportThread = class(TThread)
	 private
  protected
	 procedure Execute; override;
  end;

  TImportThread = class(TThread)
	 private
  protected
	 procedure Execute; override;
  end;

var
  MainForm: TMainForm;
  ExportThread: TExportThread;
  ImportThread: TImportThread;

const
//PathToDB:string='C:\Program Files\Slander\Db';
PathToDB:string='C:\MTerminal\Db'; 
//PathToDB:string='s:\'; 

implementation

uses QSTRINGS;
{$R *.dfm}

procedure TImportThread.Execute;
var
 ls,account_id,unit_id,type_id:integer;
 date_m,number,w_str,time_m:string;
 w_:real;
 accounts_mass:array [0..40000] of integer;

Begin 
  //поток слива показаний с терминала
  //первым делом  подключается сетевой диск 
  //на ноутбуке и через батник сливаются файлы
  
  //льем из показаний
  //заголовок метки
  MainForm.RzL.Caption:='Импортируем показания...';
  //моргание метки для пользователя
  MainForm.RzL.Blinking:=true; 
  //открывааем таблицу показаний
  Synchronize(MainForm.DB.Close);
  MainForm.DB.TableType := ttParadox;
  MainForm.DB.DatabaseName := PathToDB;
  MainForm.DB.TableName := 'Metering';
  Synchronize(MainForm.DB.Open);
  Synchronize(MainForm.DB.First);
  //прогресс бар
  MainForm.PB.PartsComplete:=0;
  MainForm.PB.TotalParts:=MainForm.DB.RecordCount;
  //цикл по загруженной в компонент таблице
  While not MainForm.DB.Eof do
	Begin
	 Try
	  //запоминаем данные записи в переменные
	  account_id:=MainForm.DB.FieldByName('Account_id').AsInteger;
	  unit_id:=MainForm.DB.FieldByName('Unit_id').AsInteger;
	  date_m:=MainForm.DB.FieldByName('Date_m').AsString;
	  time_m:=MainForm.DB.FieldByName('Time_m').AsString;
	  //меняем в показаниях запятую на точку чтобы записать в базу
	  w_str:=MainForm.DB.FieldByName('W_').AsString; 
	  //w_:= MainForm.DB.FieldByName('W_').AsFloat; 
	  w_str:=Q_ReplaceText(w_str,',','.');

	  if time_m='0:00:00' then
		 time_m:='0'+time_m;
	  
		//открываем таблицу лицевых  
	  Synchronize(MainForm.DB2.Close);
	  MainForm.DB2.TableType := ttParadox;
	  MainForm.DB2.DatabaseName := PathToDB;
	  MainForm.DB2.TableName := 'Account';
		//получаем лицевой счет
	  MainForm.DB2.Filter:='Account_id='+IntToStr(account_id);
	  Synchronize(MainForm.DB2.Open);
	  MainForm.DB2.Filtered:=true;
		//массив лицевых
	  accounts_mass[Unit_id]:=MainForm.DB2.FieldByName('Account').AsInteger;

	  Synchronize(MainForm.OQ.Close);  
	  //вставка во временную таблицу для записи в биллинг
	  MainForm.OQ.SQL.Text:='insert into askue.metering_m values '+
						'('+IntToStr(account_id)+','+IntToStr(unit_id)+',to_date('''+date_m+' '
							+time_m+''','+'''DD:MM:YYYY HH24:MI:SS'''+'),'+
							 w_str+','+MainForm.DB2.FieldByName('Account').AsString+')'; 

	  Synchronize(MainForm.OQ.Execute); 
	except on E:Exception do
	 begin
	  MainForm.Memo1.Lines.Add('Ошибка при импорте. Account_id='+IntToStr(account_id)
							+ ' Лицевой=' + MainForm.DB2.FieldByName('Account').AsString + ' Unit_id='+IntToStr(unit_id) +
							' Показания='+w_str+' '+' Дата\время='+date_m + ', ' + E.Message + ' ' + MainForm.OQ.SQL.Text);
	  //MainForm.Memo1.Lines.Add(MainForm.OQ.SQL.Text);
	  Synchronize(MainForm.DB.Next);
	  Synchronize(MainForm.PB.IncPartsByOne); 
	  Continue;
	 end; 
	end;
	Synchronize(MainForm.DB.Next);
	Synchronize(MainForm.PB.IncPartsByOne); 
	End;

  //льем из счетчиков
  MainForm.RzL.Caption:='Импортируем точки учета...';
  //открываем таблицу счетчиков
  Synchronize(MainForm.DB.Close);
  MainForm.DB.TableType := ttParadox;
  MainForm.DB.DatabaseName := PathToDB;
  MainForm.DB.TableName := 'Unit';
  Synchronize(MainForm.DB.Open);
  Synchronize(MainForm.DB.First);
  //прогресс бар
  MainForm.PB.PartsComplete:=0;
  MainForm.PB.TotalParts:=MainForm.DB.RecordCount;
	//цикл по загруженной в компонент таблице
  While not MainForm.DB.Eof do	
	Begin
	  unit_id:=MainForm.DB.FieldByName('Unit_id').AsInteger;
	  number:=MainForm.DB.FieldByName('Number_').AsString;
	  type_id:=MainForm.DB.FieldByName('Type_id').AsInteger;
															
	  ls:=accounts_mass[Unit_id];

	  Synchronize(MainForm.OQ.Close);
	   //вставка во временную таблицу для записи в биллинг
	  MainForm.OQ.SQL.Text:='insert into askue.unit_m values ('+IntToStr(unit_id)+','''+number+''','
						+IntToStr(type_id)+','+IntToStr(ls)+')';
	  Synchronize(MainForm.OQ.Execute); 
	  Synchronize(MainForm.DB.Next);

	Synchronize(MainForm.PB.IncPartsByOne);
	End;
	//вызываем пакетные процедуры
	MainForm.RzL.Caption:='Вызываем пакетные процедуры...';
	Sleep(3000);
	MainForm.OP.CallProcedure('Update_RIMs',[]);
	MainForm.OP.CallProcedure('Get_MTerminal',[]);
	Synchronize(MainForm.OS2.Commit);

MainForm.Caption:='Импорт завершен';

MainForm.RzL.Caption:='Импорт завершен';
MainForm.RzL.Blinking:=false;

MainForm.BitBtn1.Enabled:=true; 
MainForm.Button17.Enabled:=true;
MainForm.Button18.Enabled:=true;
MainForm.Button19.Enabled:=false;
MainForm.RzBitBtn1.Enabled:=true;

MainForm.DB.EnableControls;
End;

procedure TExportThread.Execute;
var
point_id,account_id,unit_id,type_id,possibility:integer;
l_group,l_address,point_name,street,house,flat,tenant,account,number,name_tp:string;
aName: String;
i: Byte;
aExclusive, aActive: Boolean;

begin
point_id:=0; account_id:=0; unit_id:=0; type_id:=0; possibility:=0;
point_name:=''; street:='';  house:=''; flat:=''; tenant:=''; account:='';
number:=''; l_group:=''; l_address:='';

 While not MainForm.ODSLS.Eof do
 begin
  //наращиваем идентификатор точки (point_id)
  inc(point_id);
  //запоминаем адрес из датасета биллинга
  street:=MainForm.ODSLS.FieldByName('STREET').AsString;
  house:=MainForm.ODSLS.FieldByName('HOUSE').AsString;
  flat:=MainForm.ODSLS.FieldByName('FLAT').AsString;
  //формируем имя точки из её адреса
  point_name:=street+' '+house+'-'+flat;
  //открываем таблицу Point
  Synchronize(MainForm.DB.Close);
  MainForm.DB.TableType:= ttParadox;
  MainForm.DB.DatabaseName:= PathToDB;
  MainForm.DB.TableName:= 'Point';

  Synchronize(MainForm.DB.Open);
  //заносим запись в таблицу Point с соответствующими параметрами
  Synchronize(MainForm.DB.Insert);
  MainForm.DB.FieldByName('Point_id').AsInteger:=point_id;
  MainForm.DB.FieldByName('Name').AsString:=point_name;
  Synchronize(MainForm.DB.Post);
  //наращиваем идентификатор лицевого счёта
  inc(account_id);
  //запоминаем  лицевой счёт из датасета биллинга
  account:=IntToStr(MainForm.ODSLS.FieldByName('LS').AsInteger);
  //запоминаем абонента (ФИО) из датасета биллинга
  tenant:=MainForm.ODSLS.FieldByName('FAM').AsString+' '
			  +MainForm.ODSLS.FieldByName('IM').AsString+' '
			  +MainForm.ODSLS.FieldByName('OTCH').AsString;
  //запоминаем подстанцию из датасета биллинга
  name_tp:=MainForm.ODSLS.FieldByName('NAME_TP').AsString;
  //открываем таблицу Account
  Synchronize(MainForm.DB.Close);
  MainForm.DB.TableType:= ttParadox;
  MainForm.DB.DatabaseName:= PathToDB;
  MainForm.DB.TableName:= 'Account';
  Synchronize(MainForm.DB.Open);
  //заносим запись в таблицу Account
  Synchronize(MainForm.DB.Insert);
  MainForm.DB.FieldByName('Account_id').AsInteger:=account_id;
  MainForm.DB.FieldByName('Street').AsString:=street;
  MainForm.DB.FieldByName('House').AsString:=house;
  MainForm.DB.FieldByName('Flat').AsString:=flat;
  MainForm.DB.FieldByName('Account').AsString:=account;
  MainForm.DB.FieldByName('Tenant').AsString:=tenant;
  MainForm.DB.FieldByName('Point_id').AsInteger:=point_id;
  //если счётчик РИМ-109 то к имени подстанции добавляем "РИМ" 
	If (MainForm.ODSLS.FieldByName('TYPE_SCH').AsInteger=118) then
		MainForm.DB.FieldByName('Trans_Station').AsString:='РИМ '
		+' '+MainForm.ODSLS.FieldByName('UCHASTOK').AsString
	else
		MainForm.DB.FieldByName('Trans_Station').AsString:=name_tp;

  Synchronize(MainForm.DB.Post);
 //запоминаем номер счётчика мз датасета биллинга
 number:=MainForm.ODSLS.FieldByName('ZAV_NOM').AsString;
 //определяем какой тип счетчика в биллинге и ставим соответствующий ему в терминале
 //и устанавливаем соответствующие параметры и наращиваем идентификатор сч-ка
 case MainForm.ODSLS.FieldByName('TYPE_SCH').AsInteger of
  46:begin//соэб 2 пдр
		type_id:=32; possibility:=580; inc(unit_id);
	  end;
 114:begin//стэб др
		type_id:=34; possibility:=836; inc(unit_id);
	  end;
 113:begin//стэб
		type_id:=33; possibility:=836; inc(unit_id);
	  end;
 115:begin//стэб 3 др
		type_id:=35; possibility:=836; inc(unit_id);
	  end;
 end; 

 If (MainForm.ODSLS.FieldByName('TYPE_SCH').AsInteger=118) then
 begin

 case  MainForm.ODSLS.FieldByName('TYPE_SCH').AsInteger of
  118:begin//рим 109	
		 type_id:=8; possibility:=16385; inc(unit_id);
		end;
  end;
 //если счётчик типа РИМ-109 
 //то создаем для лицевого счета несколько счетчиков
 //и присваимваем им номера ДДМ-ов
 //фильтруем таблицу ДДМ-ов по текущему лицевому
  If MainForm.ODSDatch_m.Active=true then 
	Begin
	 Synchronize(MainForm.ODSDatch_m.Close); 
	 MainForm.ODSDatch_m.SetVariable('ls',account);
	 Synchronize(MainForm.ODSDatch_m.Open); 
	End;

  Synchronize(MainForm.ODSDatch_m.First);
 //цикл по ДДМ-ам (датчики мощности в отдельной таблице)
 While not MainForm.ODSDatch_m.EOF do
  Begin
	 //наращиваем идентификатор сч-ка
	 inc(unit_id);
    //запоминаем номер счётчика из таблицы ДДМ-ов
	 number:=MainForm.ODSDatch_m.FieldByName('ZAV_NOM').AsString;
	 //блок заливки для счетчиков типа РИМ-109
	 //открываем таблицу Unit
	 Synchronize(MainForm.DB.Close);
	 MainForm.DB.TableType:= ttParadox;
	 MainForm.DB.DatabaseName:= PathToDB;
	 MainForm.DB.TableName:= 'Unit';
	 Synchronize(MainForm.DB.Open);
	 //заносим счётчик
	 Synchronize(MainForm.DB.Insert);
	 MainForm.DB.FieldByName('Unit_id').AsInteger:=unit_id;
	 MainForm.DB.FieldByName('Number_').AsString:=number;
	 MainForm.DB.FieldByName('Type_id').AsInteger:=type_id;
	 MainForm.DB.FieldByName('Possibility').AsInteger:=Possibility;
	
		try
		// if number = '3299608' then
		  //	begin
			 //Synchronize(MainForm.ShM);
		  //	end;
		 Synchronize(MainForm.DB.Post)
		except
		 MainForm.Memo1.Lines.Add('Ошибка экспорта. Возможно дублирование. Номер ДДМ '+number);
		 Synchronize(MainForm.ODSDatch_m.Next); 
		 Continue;  
		end;
	//если длина номера сч-ка >= 4 то можно выделить группу и адрес
	If length(number)>=4 then
	 begin
	  l_address:=Copy(number,length(number)-1,2);
	  if l_address = '00' then l_address:= '100';
	  l_group:=Copy(number,length(number)-3,2);
	  if l_group = '00' then l_group:= '100';
	  //открываем таблицу Plm_net
		Synchronize(MainForm.DB.Close);
		MainForm.DB.TableType:= ttParadox;
		MainForm.DB.DatabaseName:= PathToDB;
		MainForm.DB.TableName:= 'Plm_net';
		Synchronize(MainForm.DB.Open);
		//заполняем таблицу Plm_net
		Synchronize(MainForm.DB.Insert);
		MainForm.DB.FieldByName('Unit_id').AsInteger:=unit_id;
		MainForm.DB.FieldByName('Number_').AsString:=number;
		MainForm.DB.FieldByName('L_group').AsInteger:=StrToInt(l_group);
		MainForm.DB.FieldByName('L_address').AsInteger:=StrToInt(l_address); 
		Synchronize(MainForm.DB.Post);
	 end;
	 //открываем таблицу Account_electro
	 Synchronize(MainForm.DB.Close);
	 MainForm.DB.TableType:= ttParadox;
	 MainForm.DB.DatabaseName:= PathToDB;
	 MainForm.DB.TableName:= 'Account_electro';
	 Synchronize(MainForm.DB.Open);
	 //заполняем таблицу Account_electro
	 Synchronize(MainForm.DB.Insert);
	 MainForm.DB.FieldByName('Unit_id').AsInteger:=unit_id;
	 MainForm.DB.FieldByName('Account_id').AsInteger:=account_id;
	 Synchronize(MainForm.DB.Post);
	 //следующая запись в таблицы ДДМ-ов
	 Synchronize(MainForm.ODSDatch_m.Next);
	end;//конце цикла по ДДМ-ам While not ODSDatch_m.EOF
  //следующая запись в датасете биллинга
  Synchronize(MainForm.ODSLS.Next);
  Synchronize(MainForm.PB.IncPartsByOne);
  Continue;
  end; //конец условия по типам

  //дублируем блок заливки для всех других типов счетчиков
  //открываем таблицу Unit
  Synchronize(MainForm.DB.Close);
  MainForm.DB.TableType:= ttParadox;
  MainForm.DB.DatabaseName:= PathToDB;
  MainForm.DB.TableName:= 'Unit';
  Synchronize(MainForm.DB.Open);
  //заносим счётчик
  Synchronize(MainForm.DB.Insert);
  MainForm.DB.FieldByName('Unit_id').AsInteger:=unit_id;
  MainForm.DB.FieldByName('Number_').AsString:=number;
  MainForm.DB.FieldByName('Type_id').AsInteger:=type_id;
  MainForm.DB.FieldByName('Possibility').AsInteger:=Possibility;
	
	try
	 Synchronize(MainForm.DB.Post);
	except
	 MainForm.Memo1.Lines.Add('Ошибка экспорта. Возможно дублирование. Номер счетчика '+number);
	 Synchronize(MainForm.ODSLS.Next); 
	 Continue;  
	end;

  //открываем таблицу Account_electro 
  Synchronize(MainForm.DB.Close);
  MainForm.DB.TableType:= ttParadox;
  MainForm.DB.DatabaseName:= PathToDB;
  MainForm.DB.TableName:= 'Account_electro';
  Synchronize(MainForm.DB.Open);

  //заполняем таблицу Account_electro
  Synchronize(MainForm.DB.Insert);
  MainForm.DB.FieldByName('Unit_id').AsInteger:=unit_id;
  MainForm.DB.FieldByName('Account_id').AsInteger:=account_id;
  Synchronize(MainForm.DB.Post);

  //следующая запись в датасете биллинга
  Synchronize(MainForm.ODSLS.Next);
  Synchronize(MainForm.PB.IncPartsByOne);
 end;  //конец верхнего цикла While not ODSLS.Eof do
  //последним действием нужно пересоздать индекс по полю Point_id в таблице Account
  Synchronize(MainForm.DB.Close);
  MainForm.DB.TableType:= ttParadox;
  MainForm.DB.DatabaseName:= PathToDB;
  MainForm.DB.TableName:= 'Account';
  MainForm.DB.Exclusive := True;
  //Synchronize(MainForm.DB.Open);

	 aActive := MainForm.DB.Active;
	 Synchronize(MainForm.DB.Close);
	 aExclusive := MainForm.DB.Exclusive;
	 MainForm.DB.Exclusive := True;
	 Synchronize(MainForm.DB.IndexDefs.Update);
	 i := MainForm.DB.IndexDefs.Count;
  while i > 0 do
	 begin
		aName := MainForm.DB.IndexDefs.Items[i - 1].Name;
		MainForm.DB.DeleteIndex(aName);
      Dec(i);
	 end;
	 MainForm.DB.AddIndex('', 'Account_id', [ixPrimary]);
	 MainForm.DB.AddIndex('Point_id', 'Point_id', []);
	 Synchronize(MainForm.DB.IndexDefs.Update);
	 MainForm.DB.Exclusive := aExclusive;
	 MainForm.DB.Active := aActive;
	 //Check(DbiSaveChanges(DB.Handle));

	
MainForm.RzBitBtn1.Enabled:=true;
MainForm.BitBtn1.Enabled:=true;
Synchronize(MainForm.ODSLS.EnableControls);   
Synchronize(MainForm.DB.EnableControls);

MainForm.Button18.Enabled:=true; 
MainForm.Button19.Enabled:=true;

//копируем файлы на мобильный терминал
MainForm.Launcher.FileName:='C:\MTerminal_Kedr\CopyDataExport.vbs';
Synchronize(MainForm.Launcher.Launch);

MainForm.Caption:='Экспорт завершен';
ShowMessage('Экспорт завершен');

MainForm.RzL.Caption:='Экспорт завершен';
MainForm.RzL.Blinking:=false;
end;

procedure TMainForm.ShM;
begin
  ShowMessage('123');
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
 aName: String;
 i: Byte;
 aExclusive, aActive: Boolean;
begin
	
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Account';
 // aActive := MainForm.DB.Active;
  DB.Close;
{
  aExclusive := DB.Exclusive;
  MainForm.DB.Exclusive := True;
  DB.AddIndex('', 'Account_id', [ixPrimary]);
  DB.AddIndex('Point_id', 'Point_id', []);
  DB.IndexDefs.Update;
  DB.Exclusive := aExclusive;
  DB.Active := aActive;
 }
  DB.Active := True;	
 
	 //Check(DbiSaveChanges(DB.Handle));		
//label5.caption:=IntToStr(DB.RecordCount);
  
 Grid.Columns.Items[0].Width:=10;
 Grid.Columns.Items[1].Width:=100;
 Grid.Columns.Items[2].Width:=50;
 Grid.Columns.Items[3].Width:=50;
 Grid.Columns.Items[4].Width:=50;
 Grid.Columns.Items[5].Width:=50;
 Grid.Columns.Items[6].Width:=50;
 Grid.Columns.Items[7].Width:=50;
 Grid.Columns.Items[8].Width:=50;
 Grid.Columns.Items[9].Width:=50;
 Grid.Columns.Items[10].Width:=50;
  	
  {	 
 
  }	  
end;
 {
procedure TForm1.Button4Click(Sender: TObject);
var
  aExclusive, aActive: Boolean;
begin
  with DB do
  begin
	 aActive := Active;
    Close;
    aExclusive := Exclusive;
    Exclusive := True;
    Open;
	 Check(DbiRegenIndexes(Table1.Handle));
    Close;
    Exclusive := aExclusive;
    Active := aActive;
    Check(DbiSaveChanges(Table1.Handle));
  end;
end;
 }

procedure TMainForm.Button2Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Account_electro';
  DB.Active := true;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Additional_account';
  DB.Active := true;
end;

procedure TMainForm.Button4Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Additional_info';
  DB.Active := true;
end;

procedure TMainForm.Button5Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Balance';
  DB.Active := true;
end;

procedure TMainForm.Button6Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Balance_account';
  DB.Active := true;
end;

procedure TMainForm.Button7Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Clasure';
  DB.Active := true;
end;

procedure TMainForm.Button8Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Last_614';
  DB.Active := true;
end;

procedure TMainForm.Button9Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Map';
  DB.Active := true;
end;

procedure TMainForm.Button10Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName :=PathToDB;
  DB.TableName := 'Metering';
  DB.Active := true;

label5.caption:=IntToStr(DB.RecordCount);
end;

procedure TMainForm.Button11Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Plm_net';
  DB.Active := true;
end;

procedure TMainForm.Button12Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Point';
  DB.Active := true;
end;

procedure TMainForm.Button13Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Task';
  DB.Active := true;
end;

procedure TMainForm.Button14Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Type_unit';
  DB.Active := true;
end;

procedure TMainForm.Button15Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Unit';
  DB.Active := true;
end;

procedure TMainForm.Button16Click(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Unit_power';
  DB.Active := true;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin

If OS2.Connected=false then
 OS2.Connected:=true;

If OS.Connected=false then
 OS.Connected:=true;

If ODSLS.Active=false then
 ODSLS.Active:=true;

If ODSDatch_m.Active=false then
 ODSDatch_m.Active:=true;

 Label1.Caption:=OS.LogonDatabase;
 Label4.Caption:=PathToDb;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
If OS.Connected=true then
 ODSLS.Active:=false;

If ODSLS.Active=true then
 OS.Connected:=false;
end;

procedure TMainForm.Button17Click(Sender: TObject);
begin

//очищаем базу
//порядок удаления имеет значение
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Account_electro';

  DB.EmptyTable;
	
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Map';
  
  DB.EmptyTable;
  
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Clasure';
  
  DB.EmptyTable;

  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Metering';
  
  DB.EmptyTable;
	
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Plm_net';
  
  DB.EmptyTable;

  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Task';

  DB.EmptyTable;


  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Unit_power';

  DB.EmptyTable;

  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName :=PathToDB;
  DB.TableName := 'Additional_account';

  DB.EmptyTable;
  
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Additional_info';

  DB.EmptyTable;

  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Account';

  DB.EmptyTable;

  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Last_614';

  DB.EmptyTable;

	DB.Active := False;
	DB.TableType := ttParadox;
	DB.DatabaseName := PathToDB;
	DB.TableName := 'resttemp';
  try	
	DB.EmptyTable;
  except
	//ShowMessage('123');
  end;

	DB.Active := False;
	DB.TableType := ttParadox;
	DB.DatabaseName := PathToDB;
	DB.TableName := 'Point';

  try	
	DB.EmptyTable;
  except
	//ShowMessage('1232');
  end;

	DB.Active := False;
	DB.TableType := ttParadox;
	DB.DatabaseName := PathToDB;
	DB.TableName := 'Unit';
  
	DB.EmptyTable;
end;

procedure TMainForm.Button18Click(Sender: TObject);
var
point_id,account_id,unit_id,type_id,possibility:integer;
l_group,l_address,point_name,street,house,flat,tenant,account,number,name_tp:string;
begin
point_id:=0; account_id:=0; unit_id:=0; type_id:=0; possibility:=0;
point_name:=''; street:='';  house:=''; flat:=''; tenant:=''; account:='';
number:=''; l_group:=''; l_address:='';

If MessageDlg('В терминале будут удалены все данные. Продолжить?',
 mtConfirmation, [mbYes, mbNo], 0) = mrNo then Exit;

RzL.Caption:='Экспортируем';
RzL.Blinking:=true;
BitBtn1.Enabled:=false;
Button18.Enabled:=false; 
Button19.Enabled:=false;
RzBitBtn1.Enabled:=false;

Button17.Click;
//перенос данных из биллинга в МТерминал
//циклимся по биллинговому датасету 
MainForm.Caption:='Экспортируем точки учета...'; 
ODSLS.DisableControls;
DB.DisableControls;

ODSLS.First;
PB.PartsComplete:=0;
PB.TotalParts:=ODSLS.RecordCount;

ExportThread:=TExportThread.Create(true);
ExportThread.FreeOnTerminate:=true;
ExportThread.Priority:=tpNormal;
ExportThread.Resume;
end;

procedure TMainForm.Button19Click(Sender: TObject);
var
ls,account_id,unit_id,type_id,i:integer;
date_m,number,w_str,time_m:string;
w_:real;
accounts_mass:array [0..40000] of integer;

begin

Launcher.FileName:='C:\MTerminal_Kedr\CopyDataImportKedr.vbs';
Launcher.Launch;

DB.DisableControls;

BitBtn1.Enabled:=false; 
Button17.Enabled:=false;
Button18.Enabled:=false;
Button19.Enabled:=false;
RzBitBtn1.Enabled:=false;

ImportThread:=TImportThread.Create(true);
ImportThread.FreeOnTerminate:=true;
ImportThread.Priority:=tpNormal;
ImportThread.Resume;
end;

procedure TMainForm.BitBtn1Click(Sender: TObject);
begin
 Application.Terminate;
end;

procedure TMainForm.Button20Click(Sender: TObject);
begin
  DB.Active:= False;
  DB.TableType:= ttParadox;
  DB.DatabaseName:= PathToDB;
  DB.TableName:= 'Account';
  DB.Exclusive:= True;
  DB.Active:=True;
 Check(dbiRegenIndexes(DB.Handle));
end;

procedure TMainForm.RzBitBtn1Click(Sender: TObject);
begin
If MessageDlg('В терминале будут удалены все данные. Продолжить?',
 mtConfirmation, [mbYes, mbNo], 0) = mrNo then Exit;
//Button17.Click;

BitBtn1.Enabled:=false;
Button18.Enabled:=false; 
Button19.Enabled:=false;
RzBitBtn1.Enabled:=false;

//копируем файлы на мобильный терминал
Launcher.FileName:='C:\MTerminal_Kedr\CopyDataExportKedr.vbs';
Launcher.Launch;

MainForm.Caption:='Экспорт завершен';
ShowMessage('Экспорт завершен');

MainForm.RzL.Caption:='Экспорт завершен';

RzBitBtn1.Enabled:=true;
Button18.Enabled:=true;; 
Button19.Enabled:=true;;
RzBitBtn1.Enabled:=true;;
end;

procedure TMainForm.ResttempClick(Sender: TObject);
begin
  DB.Active := False;
  DB.TableType := ttParadox;
  DB.DatabaseName := PathToDB;
  DB.TableName := 'Resttemp';
  DB.Active := true;
end;

end.

