unit AutoEd;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls, Dialogs,WSockets_, Rascomp32;

type
  TAuto = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    GroupBox1: TGroupBox;
    StartTinou_: TCheckBox;
    WriteOpenMessage_: TCheckBox;
    GroupBox2: TGroupBox;
    WriteCloseMessage_: TCheckBox;
    OpenBtn: TButton;
    CloseBtn: TButton;
    GroupBox3: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    IpWriterFileName_: TEdit;
    TinouFileName_: TEdit;
    Label12: TLabel;
    Label13: TLabel;
    OpenDialog1: TOpenDialog;
    GroupBox4: TGroupBox;
    Entry_: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    UserName_: TEdit;
    Password_: TEdit;
    Label3: TLabel;
    ConnectDialUpNetWork_: TCheckBox;
    DisConnectDialUpNetWork_: TCheckBox;
    AutoOpenTime_: TDateTimePicker;
    AutoOpenEnabled_: TCheckBox;
    AutoCloseEnabled_: TCheckBox;
    AutoCloseTime_: TDateTimePicker;
    RAS: TRAS;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure OpenBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure RASPasswordExpired(Sender: TObject);
    procedure RASInteractiveStarted(Sender: TObject);
    procedure RASDisconnect(Sender: TObject; Error: Integer;
      ErrorString: String);
    procedure RASConnect(Sender: TObject);
    procedure RASPortOpened(Sender: TObject);
    procedure RASAboutToOpenPort(Sender: TObject);
    procedure RASAboutToConnDev(Sender: TObject);
    procedure RASWaitForModemReset(Sender: TObject);
    procedure RASDevConnected(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private

     UserName : String;
     Password : String;
     Entry    : Integer;

     ConnectDialUpNetWork    : Boolean;
     DisConnectDialUpNetWork : Boolean;

     Procedure Sts(S : String);


  public

     OpenDone : Boolean;
     CloseDone : Boolean;

     AutoOpenEnabled   : Boolean;
     AutoCloseEnabled  : Boolean;
     AutoOpenTime     : TTime;
     AutoCloseTime     : TTime;
     StartTinou        : Boolean;
     WriteOpenMessage  : Boolean;
     WriteCloseMessage : Boolean;
     IpWriterFileName  : String;
     TinouFileName     : String;

    procedure Open_;
     procedure Open2;
    procedure Close_;

  end;

var
  Auto: TAuto;


implementation

{$R *.DFM}
uses
  IniFiles,Main,ShellApi, MtBbs, RasF;


procedure TAuto.Open2;
Var
  s : String;
Begin

  s := '-o';

      If StartTinou then
       ShellExecute(Application.Handle,nil,pchar(TinouFileName),Pchar(s),nil,SW_SHOWNORMAL);
      If WriteOpenMessage then
       ShellExecute(Application.Handle,nil,pchar(IpWriterFileName),Pchar(s),nil,SW_SHOWNORMAL);

End;

procedure TAuto.Open_;
Begin

  If MainForm.TCPServer1.SocketState <> Wsockets_.ssListening then
     MainForm.SpeedButton1Click(Auto);


  If ConnectDialUpNetwork then
   Begin
     Application.CreateForm(TRasForm,RasForm);
     With RasForm Do
      Begin
       RAS.EntryName := Entry_.Items[Entry];
       RAS.UserName  := UserName;
       RAS.PassWord  := Password;
       RAS.Connect;
      End;
   End
      Else
       Open2;

End;

procedure TAuto.Close_;
var
    SI :TStartupInfo;
    PI :TProcessInformation;
    dwExitCode: DWORD;
    s : String;
begin

  If WriteCloseMessage then
   Begin

      GetStartupInfo(SI);
      s := IpWriterFileName+' -c';
      CreateProcess(PChar(IpWriterFileName),Pchar(s), nil, nil,
          False,  CREATE_DEFAULT_ERROR_MODE,nil, nil, SI, PI);
      repeat
         Application.ProcessMessages;
         GetExitCodeProcess(PI.hProcess, dwExitCode);
      until dwExitCode <> STILL_ACTIVE;

  end;

{  If WriteCloseMessage then
      ShellExecute(Application.Handle,nil,pchar(IpWriterFileName),Pchar(s),nil, SW_SHOWNORMAL);
 }
  If DisConnectDialUpNetwork then
     RAS.DisConnect;

//  If MainForm.TCPServer1.SocketState = ssListening then
//     MainForm.SpeedButton1Click(Auto);


End;


procedure TAuto.Button1Click(Sender: TObject);
begin

  OpenDialog1.FileName := IpWriterFileName_.Text;

  If OpenDialog1.Execute then
    IpWriterFileName_.Text := OpenDialog1.FileName;

end;

procedure TAuto.Button2Click(Sender: TObject);
begin

  OpenDialog1.FileName := TinouFileName_.Text;
  If OpenDialog1.Execute then
    TinouFileName_.Text := OpenDialog1.FileName;

end;

procedure TAuto.FormCreate(Sender: TObject);
Var
  Ini : TiniFile;
begin

   Ini := TIniFile.Create(AppPath+'AutoSys.INI');

     AutoOpenEnabled   := Boolean(Ini.ReadInteger('Auto','OpenEnabled',Integer(False)));
     AutoCloseEnabled  := Boolean(Ini.ReadInteger('Auto','CloseEnabled',Integer(False)));
     AutoOpenTime      := StrToTime(Ini.ReadString('Auto','OpenTime','23:00:00'));
     AutoCloseTime     := StrToTime(Ini.ReadString('Auto','CloseTime','00:30:00'));
     StartTinou        := Boolean(Ini.ReadInteger('Open','Tinou',Integer(False)));
     WriteOpenMessage  := Boolean(Ini.ReadInteger('Open' ,'WriteMessage',Integer(False)));
     WriteCloseMessage := Boolean(Ini.ReadInteger('Close','WriteMessage',Integer(False)));
     IpWriterFileName  := Ini.ReadString('FileName','IpWriter',AppPath+'IpWriter.exe');
     TinouFileName     := Ini.ReadString('FileName','Tinou',AppPath+'痴脳.exe');;

     UserName          := Ini.ReadString ('Network','UserName','myo');
     Password          := Ini.ReadString ('Network','Password','myo7777');
     Entry             := Ini.ReadInteger('Network','Entry',-1);
   ConnectDialUpNetWork:= Boolean(Ini.ReadInteger('Open','DialUpNetWork',Integer(False)));
DisConnectDialUpNetWork:= Boolean(Ini.ReadInteger('Close','DialUpNetWork',Integer(False)));


   Ini.Free;

  OpenDone := False;
  CloseDone := False;


  case RAS.fRASAPI of
    0 : begin
      RAS.GetPhoneBookEntries;
      Entry_.Items.Assign (RAS.PhoneBookEntries);
    end;
    1 : ShowMessage('RASAPI32.DLL が見つかりません');
    2 : ShowMessage('RASAPI32.DLL が正常でありません');
  end;

  RasForm := Nil;

end;

procedure TAuto.FormShow(Sender: TObject);
begin

     AutoOpenEnabled_   .Checked :=      AutoOpenEnabled  ;
     AutoCloseEnabled_  .Checked :=      AutoCloseEnabled ;
     AutoOpenTime_      .Time    :=      AutoOpenTime     ;
     AutoCloseTime_     .Time    :=      AutoCloseTime    ;
     StartTinou_        .Checked :=      StartTinou       ;
     WriteOpenMessage_  .Checked :=      WriteOpenMessage ;
     WriteCloseMessage_ .Checked :=      WriteCloseMessage;
     IpWriterFileName_  .Text    :=      IpWriterFileName ;
     TinouFileName_     .Text    :=      TinouFileName    ;
     UserName_          .Text    :=      UserName         ;
     Password_          .Text    :=      Password         ;
     If Entry_.Items.Count > Entry then
       Entry_         .ItemIndex :=      Entry
     else
       Entry_         .ItemIndex :=      -1               ;
   ConnectDialUpNetWork_.Checked :=   ConnectDialUpNetWork;
DisConnectDialUpNetWork_.Checked :=DisConnectDialUpNetWork;

end;

procedure TAuto.OKBtnClick(Sender: TObject);
Var
  Ini : TiniFile;
begin

     AutoOpenEnabled   :=      AutoOpenEnabled_  .Checked;
     AutoCloseEnabled  :=      AutoCloseEnabled_ .Checked;
     AutoOpenTime      :=      AutoOpenTime_     .Time;
     AutoCloseTime     :=      AutoCloseTime_    .Time;
     StartTinou        :=      StartTinou_       .Checked;
     WriteOpenMessage  :=      WriteOpenMessage_ .Checked;
     WriteCloseMessage :=      WriteCloseMessage_.Checked;
     IpWriterFileName  :=      IpWriterFileName_ .Text;
     TinouFileName     :=      TinouFileName_    .Text;

     UserName          :=      UserName_         .Text;
     Password          :=      Password_         .Text;
     Entry             :=      Entry_.ItemIndex;


   ConnectDialUpNetWork:=   ConnectDialUpNetWork_.Checked;
DisConnectDialUpNetWork:=DisConnectDialUpNetWork_.Checked;

   Ini := TIniFile.Create(AppPath+'AutoSys.INI');

     Ini.WriteInteger('Auto','OpenEnabled',Integer(AutoOpenEnabled));
     Ini.WriteInteger('Auto','CloseEnabled',Integer(AutoCloseEnabled));
     Ini.WriteString ('Auto','OpenTime',TimeToStr(AutoOpenTime));
     Ini.WriteString ('Auto','CloseTime',TimeToStr(AutoCloseTime));
     Ini.WriteInteger('Open','Tinou',Integer(StartTinou));
     Ini.WriteInteger('Open','WriteMessage',Integer(WriteOpenMessage));
     Ini.WriteInteger('Close','WriteMessage',Integer(WriteCloseMessage));
     Ini.WriteString ('FileName','IpWriter',IpWriterFileName);
     Ini.WriteString ('FileName','Tinou',TinouFileName);

     Ini.WriteString ('Network','UserName',UserName);
     Ini.WriteString ('Network','Password',Password);
     Ini.WriteInteger('Network','Entry',Entry);

     Ini.WriteInteger('Open','DialUpNetWork',Integer(ConnectDialUpNetWork));
     Ini.WriteInteger('Close','DialUpNetWork',Integer(DisConnectDialUpNetWork));



   Ini.Free;

end;

procedure TAuto.OpenBtnClick(Sender: TObject);
begin

     OKBtnClick(Sender);
     Open_;

end;

procedure TAuto.CloseBtnClick(Sender: TObject);
begin

     OKBtnClick(Sender);
     Close_;

end;




procedure TAuto.RASPasswordExpired(Sender: TObject);
begin

       Sts('パスワードを送信しました');

end;


procedure TAuto.RASInteractiveStarted(Sender: TObject);
begin
       Sts('認証中');

end;

procedure TAuto.RASDisconnect(Sender: TObject; Error: Integer;
  ErrorString: String);
begin

  Sts('切断されました');

end;

procedure TAuto.RASConnect(Sender: TObject);
begin

  Sts('接続しました');
  Auto.Open2;
  If RasForm <> nil then
     RasForm.Close;

end;

procedure TAuto.RASPortOpened(Sender: TObject);
begin

  Sts('ポートをオープンしました');


end;

procedure TAuto.RASAboutToOpenPort(Sender: TObject);
begin
  Sts('ポートをオープン中');

end;

procedure TAuto.RASAboutToConnDev(Sender: TObject);
begin

  Sts('接続中');

end;

procedure TAuto.RASWaitForModemReset(Sender: TObject);
begin

  Sts('モデムからの応答を待機中です');

end;

procedure TAuto.RASDevConnected(Sender: TObject);
begin

  Sts('接続しました');

end;

Procedure TAuto.Sts(S : String);
Begin

   if RasForm<>nil then
      RasForm.Status.Caption := s;

End;

procedure TAuto.Button3Click(Sender: TObject);
Var
  s : String;
begin
   s :='';

       ShellExecute(Application.Handle,nil,pchar(IpWriterFileName),Pchar(s),nil,SW_SHOWNORMAL);

end;

end.
