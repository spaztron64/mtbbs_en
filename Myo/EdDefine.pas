unit EdDefine;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, checklst, ComCtrls, Dialogs;

type
  TEditDefine = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Page: TPageControl;
    TabSheet1: TTabSheet;
    AutoRegist: TCheckBox;
    UserFreeID: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    IDNumLength: TEdit;
    IDHead: TEdit;
    TabSheet2: TTabSheet;
    StartLevel: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Label5: TLabel;
    GuestID: TEdit;
    Label7: TLabel;
    Label6: TLabel;
    Kinous: TListBox;
    Levels: TCheckListBox;
    Label9: TLabel;
    SysopCall: TCheckBox;
    TabSheet5: TTabSheet;
    RadioGroup1: TRadioGroup;
    Address: TCheckBox;
    Tel: TCheckBox;
    Hobby: TCheckBox;
    SignOn: TCheckBox;
    BirthDay: TCheckBox;
    Comment: TCheckBox;
    Name: TCheckBox;
    GroupBox1: TGroupBox;
    Label11: TLabel;
    Chat_BackLogLines: TEdit;
    Chat_LogFileName: TEdit;
    Label8: TLabel;
    Chat_SaveLogFile: TCheckBox;
    GroupBox2: TGroupBox;
    Log_MaxSize: TEdit;
    Label10: TLabel;
    Email: TCheckBox;
    TabSheet6: TTabSheet;
    Label15: TLabel;
    FreePost_MaxSize: TEdit;
    Label16: TLabel;
    GoodbyeMessage_MaxSize: TEdit;
    ReadPromptBeforeMessage: TCheckBox;
    GoodbyeMessage: TCheckBox;
    TabSheet7: TTabSheet;
    StartUpMinimize: TCheckBox;
    StartUpTinou: TCheckBox;
    StartUpModem: TCheckBox;
    StartUpTelnet: TCheckBox;
    TabSheet8: TTabSheet;
    PlayLogin: TCheckBox;
    LoginFileName: TEdit;
    Label17: TLabel;
    Button1: TButton;
    Label18: TLabel;
    LogoutFileName: TEdit;
    Button2: TButton;
    PlayLogout: TCheckBox;
    OpenDialog1: TOpenDialog;
    PlaySysopCall: TCheckBox;
    Label19: TLabel;
    SysopCallFileName: TEdit;
    Button3: TButton;
    GuestLastReadDate: TEdit;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    StartLastReadDate: TEdit;
    Label23: TLabel;
    GroupBox3: TGroupBox;
    Label25: TLabel;
    Label24: TLabel;
    Label14: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    port: TEdit;
    MaxClientsLimit: TEdit;
    MaxSameIp: TEdit;
    IdleTimeLimit: TEdit;
    GroupBox4: TGroupBox;
    Label26: TLabel;
    Label27: TLabel;
    wwwport: TEdit;
    wwwidletimelimit: TEdit;
    StartUpWWW: TCheckBox;
    WWWroot: TEdit;
    Label28: TLabel;
    Label29: TLabel;
    SysopLevel: TEdit;
    Label30: TLabel;
    AccessCountReset: TEdit;
    TabSheet9: TTabSheet;
    Label31: TLabel;
    MtidsHostName: TEdit;
    HostList: TLabel;
    MTIDSHostList: TMemo;
    StartupMTIDS: TCheckBox;
    Label32: TLabel;
    mtidsport: TEdit;
    LoginTelegram: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure IDHeadChange(Sender: TObject);
    procedure IDNumLengthChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure KinousClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure LevelsExit(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);



  private

    Procedure SaveCanUseLevels;


  public

    Procedure LoadCanUseLevels;
    procedure LoadGeneralDefine;

  end;

var
  EditDefine: TEditDefine;

implementation

uses UEdit,IniFiles, Main, Define;

{$R *.DFM}


procedure TEditDefine.FormCreate(Sender: TObject);
Begin

  LoadGeneralDefine;

End;

procedure TEditDefine.LoadGeneralDefine;
Var
  FN : String;
  Ini : TiniFile;
Begin

   Ini := TIniFile.Create(AppPath+'MyoHost.INI');

     With GeneralDefine Do
      Begin
        With Apply Do
         Begin
          AutoRegist        := Boolean(Ini.ReadInteger('Apply','AutoRegist',Integer(True)));
          UseFreeID         := Boolean(Ini.ReadInteger('Apply','UseFreeID',Integer(True)));
          IDHead            := Ini.ReadString('Apply','IDHead','MYO');
          IDNumLength       := Ini.ReadInteger('Apply','IDNumLength',4);
          StartLevel        := Ini.ReadInteger('Apply','StartLevel',1);
          StartLastReadDate := Ini.ReadInteger('Apply','StartLastReadDate',30);
         End;
        With Telegram Do
         Begin
          GuestUse     := Boolean(Ini.ReadInteger('Telegram','GuestUse',Integer(True)));
          RecvMax      := Ini.ReadInteger('Telegram','RecvMax',99);
          LoginTelegram:= Boolean(Ini.ReadInteger('Telegram','LoginTelegram',Integer(True)));
         End;
        With User Do
         Begin
          SysopCall         := Boolean(Ini.ReadInteger('User','SysopCall',Integer(True)));
          GuestID           := Ini.ReadString('User','GuestID','GUEST');
          GoodbyeMessage    := Boolean(Ini.ReadInteger('User','GoodbyeMessage',Integer(True)));
          GuestLastReadDate := Ini.ReadInteger('User','GuestLastReadDate',30);
          SysopLevel        := Ini.ReadInteger('User','SysopLevel',5);
         End;
        With Profile Do
         Begin
          Tel     := Boolean(Ini.ReadInteger('Profile','Tel',Integer(False)));
          Address := Boolean(Ini.ReadInteger('Profile','Address',Integer(False)));
          Name    := Boolean(Ini.ReadInteger('Profile','Name',Integer(False)));
          Hobby   := Boolean(Ini.ReadInteger('Profile','Hobby',Integer(True)));
          Comment := Boolean(Ini.ReadInteger('Profile','Comment',Integer(True)));
          SignOn  := Boolean(Ini.ReadInteger('Profile','SignOn',Integer(True)));
          BirthDay:= Boolean(Ini.ReadInteger('Profile','BirthDay',Integer(True)));
          EMail   := Boolean(Ini.ReadInteger('Profile','Email',Integer(True)));
         End;
        With Other Do
         Begin
          Log_MaxSize             := Ini.ReadInteger('Other','Log_MaxSize',20);
          AccessCountReset        := Ini.ReadInteger('Other','AccessCountReset',0);
          FreePost_MaxSize        := Ini.ReadInteger('Other','FreePost_MaxSize',30);
          GoodbyeMessage_MaxSize  := Ini.ReadInteger('Other','GoodbyeMessage_MaxSize',30);
          ReadPromptBeforeMessage := Boolean(Ini.ReadInteger ('Other','ReadPromptBeforeMessage',Integer(False)));
         End;
        With Chat Do
         Begin
          SaveLog       := Boolean(Ini.ReadInteger ('Chat','SaveLogFile',Integer(False)));
          LogFileName   := Ini.ReadString  ('Chat','LogFileName','Chat.LOG');
          BackLogLines  := Ini.ReadInteger ('Chat','BackLogLines',10);
         End;
        With TcpIp Do
         Begin
          Port            := Ini.ReadString  ('TcpIp','Port','23');
          MaxClientsLimit := Ini.ReadInteger ('TcpIp','MaxClientsLimit',99);
          wwwPort         := Ini.ReadString  ('TcpIp','wwwPort','80');
          MaxSameIp       := Ini.ReadInteger ('TcpIp','MaxSameIp',5);
          IdleTimeLimit   := Ini.ReadInteger ('TcpIp','IdleTimeLimit',1200);
          wwwIdleTimeLimit:= Ini.ReadInteger ('TcpIp','wwwIdleTimeLimit',360);
          wwwroot         := Ini.ReadString  ('TcpIp','wwwroot',ExtractFilepath(application.ExeName)+'wwwroot\');
          MainForm.PortNo.Text  := Port;
          MainForm.wwwPortNo.Text  := wwwPort;
          MainForm.MaxUser.Text := IntToStr(MaxClientsLimit);
         End;

        With Mail Do
         Begin
          SaveDayLimit        := Ini.ReadInteger('Mail','SaveDayLimit',100);
          UseGuestMailToSysop := Boolean(Ini.ReadInteger('Mail','UseGuestMailToSysop',Integer(True)));
          BoxSize             := Ini.ReadInteger('Mail','BoxSize',50);
          OneSendMax          := Ini.ReadInteger('Mail','OneSendMax',20);
         End;

        With StartUp Do
         Begin
          OpenTelnet         := Boolean(Ini.ReadInteger ('StartUp','OpenTelnet',Integer(False)));
          OpenModem          := Boolean(Ini.ReadInteger ('StartUp','OpenModem',Integer(False)));
          OpenWWW            := Boolean(Ini.ReadInteger ('StartUp','OpenWWW',Integer(False)));
          OpenMTIDS          := Boolean(Ini.ReadInteger ('StartUp','OpenMTIDS',Integer(False)));
          StartTinou         := Boolean(Ini.ReadInteger ('StartUp','StartTinou',Integer(False)));
          Minimize           := Boolean(Ini.ReadInteger ('StartUp','Minimize',Integer(False)));
         End;

        With Sound Do
         Begin
          PlayLogin     := Boolean(Ini.ReadInteger('Sound','PlayLogin',Integer(False)));
          PlayLogout    := Boolean(Ini.ReadInteger('Sound','PlayLogout',Integer(False)));
          PlaySysopCall := Boolean(Ini.ReadInteger('Sound','PlaySysopCall',Integer(False)));
          LoginFileName     := Ini.ReadString  ('Sound','LoginFileName','');
          LogoutFileName    := Ini.ReadString  ('Sound','LogoutFileName','');
          SysopCallFileName := Ini.ReadString  ('Sound','SysopCallFileName','');
         End;

        With MTIDS Do
         Begin
           HostName := Ini.ReadString  ('MTIDS','HostName','');
           Port     := Ini.ReadString  ('MTIDS','Port','12345');

           MainForm.mtidsPortNo.Text  := Port;
         End;
      End;

  Ini.Free;
  LoadCanUseLevels;



end;

procedure TEditDefine.OKBtnClick(Sender: TObject);
Var
  FN : String;
  Ini : TiniFile;
  i   : Integer;

Begin

   Ini := TIniFile.Create(AppPath+'MyoHost.INI');

     With GeneralDefine Do
      Begin

        Telegram.LoginTelegram  := LoginTelegram.Checked;

        Apply.AutoRegist        := AutoRegist.Checked;
        Apply.UseFreeID         := UserFreeID.Checked;
        Apply.IDHead            := IDHead.Text;
        Apply.IDNumLength       := StrToIntDef(IDNumLength.Text,3);
        Apply.StartLevel        := StrToIntDef(StartLevel.Text,1);
        Apply.StartLastReadDate := StrToIntDef(StartLastReadDate.Text,30);

        User.GuestID           := UpperCase(GuestID.Text);
        User.GuestLastReadDate := StrToIntDef(GuestLastReadDate.Text,30);
        User.SysopCall         := SysopCall.Checked;
        User.GoodbyeMessage    := GoodbyeMessage.Checked;
        User.SysopLevel        := StrToIntDef(SysopLevel.text,5);

        Other.Log_MaxSize            := StrToIntDef(Log_MaxSize.Text,20);
        Other.AccessCountReset       := StrToIntDef(AccessCountReset.Text,0);
        Other.FreePost_MaxSize       := StrToIntDef(FreePost_MaxSize.Text,30);
        Other.GoodbyeMessage_MaxSize := StrToIntDef(GoodbyeMessage_MaxSize.Text,30);
        Other.ReadPromptBeforeMessage:= ReadPromptBeforeMessage.Checked;

        Chat.BackLogLines := StrToIntDef(Chat_BackLogLines.Text,10);
        Chat.SaveLog      := Chat_SaveLogFile.Checked;
        Chat.LogFileName  := Chat_LogFileName.Text;

        Profile.Tel      := Tel.Checked;
        Profile.Name     := Name.Checked;
        Profile.Address  := Address.Checked;
        Profile.Hobby    := Hobby.Checked;
        Profile.Comment  := Comment.Checked;
        Profile.SignOn   := SignOn.Checked;
        Profile.BirthDay := BirthDay.Checked;
        Profile.Email    := EMail.Checked;

        TcpIp.Port            := Port.Text;
        TcpIp.wwwPort         := wwwPort.Text;
        TcpIp.MaxClientsLimit := StrToIntDef(MaxClientsLimit.Text,99);
        TcpIp.MaxSameIp       := StrToIntDef(MaxSameIp      .Text,5);
        TcpIp.IdleTimeLimit   := StrToIntDef(IdleTimeLimit  .Text,1200);
        TcpIp.wwwIdleTimeLimit:= StrToIntDef(wwwIdleTimeLimit.Text,360);
        TcpIp.wwwroot         := wwwroot.Text;

        StartUp.OpenTelnet         := StartUpTelnet.Checked;
        StartUp.OpenModem          := StartUpModem.Checked;
        StartUp.OpenWWW            := StartUpWWW.Checked;
        StartUp.OpenMTIDS          := StartUpMTIDS.Checked;
        StartUp.StartTinou         := StartUpTinou.Checked;
        StartUp.Minimize           := StartUpMinimize.Checked;

        Sound.PlayLogin         := PlayLogin    .Checked;
        Sound.PlayLogout        := PlayLogout   .Checked;
        Sound.PlaySysopCall     := PlaySysopCall.Checked;
        Sound.LoginFileName     := LoginFileName    .Text;
        Sound.LogoutFileName    := LogoutFileName   .Text;
        Sound.SysopCallFileName := SysopCallFileName.Text;

        MTIDS.HostName          := MtidsHostName.Text;
        MTIDS.Port              := MtidsPort.Text;

        With Apply Do
         Begin
          Ini.WriteInteger('Apply','AutoRegist',Integer(AutoRegist));
          Ini.WriteInteger('Apply','UseFreeID',Integer(UseFreeID));
          Ini.WriteString ('Apply','IDHead',IDHead);
          Ini.WriteInteger('Apply','IDNumLength',IDNumLength);
          Ini.WriteInteger('Apply','StartLevel',StartLevel);
          Ini.WriteInteger('Apply','StartLastReadDate',StartLastReadDate);
         End;
        With Telegram Do
         Begin
          Ini.WriteInteger('Telegram','GuestUse',Integer(GuestUse));
          Ini.WriteInteger('Telegram','RecvMax',RecvMax);
          Ini.WriteInteger('Telegram','LoginTelegram',Integer(LoginTelegram));
         End;
        With User Do
         Begin
          Ini.WriteInteger('User','SysopCall',Integer(SysopCall));
          Ini.WriteString ('User','GuestID',GuestID);
          Ini.WriteInteger('User','GoodbyeMessage',Integer(GoodbyeMessage));
          Ini.WriteInteger('User','GuestLastReadDate',GuestLastReadDate);
          Ini.WriteInteger('User','SysopLevel',SysopLevel);
         End;
        With Profile Do
         Begin
          Ini.WriteInteger('Profile','Name',Integer(Name));
          Ini.WriteInteger('Profile','Address',Integer(Address));
          Ini.WriteInteger('Profile','Tel',Integer(Tel));
          Ini.WriteInteger('Profile','Hobby',Integer(Hobby));
          Ini.WriteInteger('Profile','BirthDay',Integer(BirthDay));
          Ini.WriteInteger('Profile','SignOn',Integer(SignOn));
          Ini.WriteInteger('Profile','Comment',Integer(Comment));
          Ini.WriteInteger('Profile','EMail',Integer(EMail));
         End;

        With Chat Do
         Begin
          Ini.WriteInteger ('Chat','SaveLogFile',Integer(SaveLog));
          Ini.WriteString ('Chat','LogFileName',LogFileName);
          Ini.WriteInteger ('Chat','BackLogLines',BackLogLines);
         End;

        With Other Do
         Begin
          Ini.WriteInteger ('Other','Log_MaxSize',Log_MaxSize);
          Ini.WriteInteger ('Other','AccessCountReset',AccessCountReset);
          Ini.WriteInteger ('Other','FreePost_MaxSize',FreePost_MaxSize);
          Ini.WriteInteger ('Other','GoodbyeMessage_MaxSize',GoodbyeMessage_MaxSize);
          Ini.WriteInteger ('Other','ReadPromptBeforeMessage',Integer(ReadPromptBeforeMessage));
         End;

        With TcpIp Do
         Begin
          Ini.WriteString  ('TcpIp','Port',Port);
          Ini.WriteString  ('TcpIp','wwwPort',wwwPort);
          Ini.WriteInteger ('TcpIp','MaxClientsLimit',MaxClientsLimit);
          Ini.WriteInteger ('TcpIp','MaxSameIp',MaxSameIp);
          Ini.WriteInteger ('TcpIp','IdleTimeLimit',IdleTimeLimit);
          Ini.WriteInteger ('TcpIp','wwwIdleTimeLimit',wwwIdleTimeLimit);
          Ini.WriteString  ('TcpIp','wwwroot',wwwroot);

           MainForm.PortNo         .Text := TcpIp.Port;
           MainForm.wwwPortNo      .Text := TcpIp.wwwPort;
           MainForm.MaxUser        .Text := IntToStr(TcpIp.MaxClientsLimit);
         End;

        With Mail Do
         Begin
          Ini.WriteInteger('SaveDayLimit','Mail',SaveDayLimit);
          Ini.WriteInteger('UseGuestMailToSysop','Mail',Integer(UseGuestMailToSysop));
          Ini.WriteInteger('BoxSize','Mail',BoxSize);
          Ini.WriteInteger('OneSendMax','Mail',OneSendMax);
         End;

        With StartUp Do
         Begin
          Ini.WriteInteger ('StartUp','OpenTelnet',Integer(OpenTelnet));
          Ini.WriteInteger ('StartUp','OpenModem',Integer(OpenModem));
          Ini.WriteInteger ('StartUp','OpenWWW',Integer(OpenWWW));
          Ini.WriteInteger ('StartUp','OpenMTIDS',Integer(OpenMTIDS));
          Ini.WriteInteger ('StartUp','StartTinou',Integer(StartTinou));
          Ini.WriteInteger ('StartUp','Minimize',Integer(Minimize));
         End;

        With Sound Do
         Begin
          Ini.WriteInteger ('Sound','PlayLogin',Integer(PlayLogin));
          Ini.WriteInteger ('Sound','PlayLogout',Integer(PlayLogout));
          Ini.WriteInteger ('Sound','PlaySysopCall',Integer(PlaySysopCall));
          Ini.WriteString  ('Sound','LoginFileName',LoginFileName);
          Ini.WriteString  ('Sound','LogoutFileName',LogoutFileName);
          Ini.WriteString  ('Sound','SysopCallFileName',SysopCallFileName);
         End;

        With MTIDS Do
         Begin
          Ini.WriteString  ('MTIDS','HostName',HostName);
          Ini.WriteString  ('MTIDS','Port',Port);
         End;
      End;

   Ini.Free;
   SaveCanUseLevels;


end;


procedure TEditDefine.IDHeadChange(Sender: TObject);
begin

     If Length(IDHead.Text)+StrToIntDef(IDNumLength.Text,3)>8 then
           IDNumLength.Text := IntToStr(8-Length(IDHead.Text));

end;

procedure TEditDefine.IDNumLengthChange(Sender: TObject);
begin

    If Length(IDHead.Text)+StrToIntDef(IDNumLength.Text,3)>8 then
        IDNumLength.Text := IntToStr(8-Length(IDHead.Text));


end;

procedure TEditDefine.FormShow(Sender: TObject);
begin

     With GeneralDefine Do
      Begin
       //Apply
        AutoRegist.Checked := Apply.AutoRegist;
        UserFreeID.Checked := Apply.UseFreeID;
        IDHead.Text        := Apply.IDHead;
        IDNumLength.Text   := IntToStr(Apply.IDNumLength);
        StartLevel.Text    := IntToStr(Apply.StartLevel);
        StartLastReadDate.Text  := IntToStr(Apply.StartLastReadDate);

       //User
        GuestID.Text            := User.GuestID;
        SysopCall.Checked       := User.SysopCall;
        GoodbyeMessage.Checked  := User.GoodbyeMessage;
        GuestLastReadDate.Text  := IntToStr(User.GuestLastReadDate);
        SysopLevel.Text         := IntToStr(User.SysopLevel);

       //Chat and Telegram
        LoginTelegram.Checked   := Telegram.LoginTelegram;

       //Levels
       //Profile
        Name.Checked     := Profile.Name     ;
        Tel.Checked      := Profile.Tel      ;
        Address.Checked  := Profile.Address  ;
        Hobby.Checked    := Profile.Hobby    ;
        Comment.Checked  := Profile.Comment  ;
        SignOn.Checked   := Profile.SignOn   ;
        BirthDay.Checked := Profile.BirthDay ;
        EMail.Checked    := Profile.EMail    ;

        Port           .Text := TcpIp.Port;
        wwwPort        .Text := TcpIp.wwwPort;
        MaxClientsLimit.Text := IntToStr(TcpIp.MaxClientsLimit);
        MaxSameIp      .Text := IntToStr(TcpIp.MaxSameIp);
        IdleTimeLimit  .Text := IntToStr(TcpIp.IdleTimeLimit);
        wwwIdleTimeLimit.Text:= IntToStr(TcpIp.wwwIdleTimeLimit);
        wwwRoot        .Text := TcpIp.wwwroot;

        Chat_BackLogLines.Text   := IntToStr(Chat.BackLogLines);
        Chat_SaveLogFile.Checked := Chat.SaveLog;
        Chat_LogFileName.Text    := Chat.LogFileName;

        Log_MaxSize.Text                := IntToStr(Other.Log_MaxSize);
        AccessCountReset.Text           := IntToStr(Other.AccessCountReset);
        FreePost_MaxSize.Text           := IntToStr(Other.FreePost_MaxSize);
        GoodbyeMessage_MaxSize.Text     := IntToStr(Other.GoodbyeMessage_MaxSize);
        ReadPromptBeforeMessage.Checked := Other.ReadPromptBeforeMessage;


        StartUpTelnet.Checked      := StartUp.OpenTelnet;
        StartUpModem.Checked       := StartUp.OpenModem;
        StartUpWWW.Checked         := StartUp.OpenWWW;
        StartUpMTIDS.Checked       := StartUp.OpenMTIDS;
        StartUpTinou.Checked       := StartUp.StartTinou;
        StartUpMinimize.Checked    := StartUp.Minimize;

        PlayLogin    .Checked      := Sound.PlayLogin;
        PlayLogout   .Checked      := Sound.PlayLogout;
        PlaySysopCall.Checked      := Sound.PlaySysopCall;
        LoginFileName    .Text := Sound.LoginFileName;
        LogoutFileName   .Text := Sound.LogoutFileName;
        SysopCallFileName.Text := Sound.SysopCallFileName;

        MtidsHostName.Text := MTIDS.HostName;
        MtidsPort    .Text := MTIDS.Port;

      End;

   Kinous.ItemIndex := 0;
   KinousClick(Sender);

end;






procedure TEditDefine.KinousClick(Sender: TObject);
Var
   i : integer;
begin


          For i := 0 to Levels.items.Count-1 Do
             Levels.Checked[i] := GeneralDefine.CanUseLevels[TKinou(Kinous.ItemIndex)][i-1] ;


end;

procedure TEditDefine.CancelBtnClick(Sender: TObject);
begin

    LoadCanUseLevels;

end;

Procedure TEditDefine.LoadCanUseLevels;
Var
  i   : TKinou;
  j   : Integer;
  F   : File of TLevels;
Begin

  If FileExists(AppPath+'Levels.DAT') then
    Begin
      AssignFile(F,AppPath+'Levels.DAT');
      Reset(F);
       BlockRead(F,GeneralDefine.CanUseLevels,Ord(High(TKinou)));
      CloseFile(F);
    End
    Else
     Begin
        For i := Low(TKinou) to High(TKinou) Do
          For j := Low(TLevels) to High(TLevels) Do
             GeneralDefine.CanUseLevels[i][j] := True;
     End;
End;

Procedure TEditDefine.SaveCanUseLevels;
Var
  F   : File of TLevels;
Begin

      AssignFile(F,AppPath+'Levels.DAT');
      Rewrite(F);
       BlockWrite(F,GeneralDefine.CanUseLevels,Ord(High(TKinou)));
      CloseFile(F);

End;


procedure TEditDefine.LevelsExit(Sender: TObject);
Var
   i : Integer;
begin

          For i := 0 to Levels.items.Count-1 Do
              GeneralDefine.CanUseLevels[TKinou(Kinous.ItemIndex)][i-1] := Levels.Checked[i];

end;

procedure TEditDefine.Button1Click(Sender: TObject);
begin

  OpenDialog1.FileName := LoginFileName.Text;

  If OpenDialog1.Execute then
    LoginFileName.Text := OpenDialog1.FileName;

end;

procedure TEditDefine.Button2Click(Sender: TObject);
begin

  OpenDialog1.FileName := LogoutFileName.Text;

  If OpenDialog1.Execute then
    LogoutFileName.Text := OpenDialog1.FileName;

end;

procedure TEditDefine.Button3Click(Sender: TObject);
begin

  OpenDialog1.FileName := SysopCallFileName.Text;

  If OpenDialog1.Execute then
    SysopCallFileName.Text := OpenDialog1.FileName;

end;

end.
