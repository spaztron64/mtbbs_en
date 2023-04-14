unit Main;

interface

uses
  Windows,Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, WSockets, ComCtrls, ExtCtrls,MTBBS,Winsock, Menus,
  Comm,MyoComm,ShellAPI, Grids,Monitor, Define, TrayIcon, MPlayer,MailSys,MesBrd,mtids,
  FtpSrv, WSockets_,clipbrd;

Const

  MyoHostVer = ' MyoHostSystem Ver '+MTBBSVERSION+' Copyright (C) 1997.10,1999.11 By MYO'+#13#10
  /////////////
               +'               Updated and translated 2023.04     Spaztron64';

type
  TChMode = (CM_None,CM_TelNet,CM_Modem);// ���g�p,Telnet�Ŏg�p,���f���Ŏg�@ /  /  //

Type

  TMainForm = class(TForm)
    TCPServer1: TTCPServer;
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    GroupBox5: TGroupBox;
    Button6: TButton;
    GroupBox6: TGroupBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    line1: TLabel;
    L1Status: TPanel;
    Label3: TLabel;
    L2Status: TPanel;
    N2: TMenuItem;
    MYOCOMM1: TMYOCOMM;
    E1: TMenuItem;
    N3: TMenuItem;
    PortNo: TEdit;
    Label4: TLabel;
    MYOCOMM2: TMYOCOMM;
    Help1: TMenuItem;
    V1: TMenuItem;
    Button8: TButton;
    Label5: TLabel;
    TcpIpClients: TPanel;
    N4: TMenuItem;
    L1: TMenuItem;
    MTBBS1: TMenuItem;
    N5: TMenuItem;
    L2: TMenuItem;
    M1: TMenuItem;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    OpenClose_TELNET: TMenuItem;
    OpenClose_Modem: TMenuItem;
    N7: TMenuItem;
    Exit1: TMenuItem;
    ImageList1: TImageList;
    File1: TMenuItem;
    Exit2: TMenuItem;
    N6: TMenuItem;
    N8: TMenuItem;
    IP1: TMenuItem;
    PluginMenu: TMenuItem;
    P2: TMenuItem;
    mFreePlugin: TMenuItem;
    mLoadPlugin: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    MYOCOMM3: TMYOCOMM;
    L3Status: TPanel;
    Label7: TLabel;
    MYOCOMM4: TMYOCOMM;
    Button9: TButton;
    WWWServer: TTCPServer;
    GroupBox7: TGroupBox;
    Label1: TLabel;
    WWWPortNo: TEdit;
    SpeedButton3: TSpeedButton;
    MaxUser: TEdit;
    Label6: TLabel;
    GroupBox8: TGroupBox;
    Label8: TLabel;
    SpeedButton4: TSpeedButton;
    MTIDSPortNo: TEdit;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    GroupBox1: TGroupBox;
    Bevel1: TBevel;
    LoginUsers: TStringGrid;
    MediaPlayer1: TMediaPlayer;
    GroupBox4: TGroupBox;
    WWWStatus: TMemo;
    GroupBox3: TGroupBox;
    MtBBSStatus: TMemo;
    GroupBox2: TGroupBox;
    TcpStatus: TMemo;
    GroupBox9: TGroupBox;
    ListBox1: TListBox;
    GroupBox10: TGroupBox;
    ListBox2: TListBox;
    GroupBox11: TGroupBox;
    MTIDSStatus: TMemo;
    Button7: TButton;
    Button1: TButton;
    Button3: TButton;
    Button2: TButton;
    Button4: TButton;
    Button12: TButton;
    Button13: TButton;
    Button11: TButton;
    Button10: TButton;
    MTIDSServer: TTCPServer;
    FTP: TTabSheet;
    Label2: TLabel;
    MyIpAddress: TListBox;
    Button5: TButton;
    GroupBox12: TGroupBox;
    SpeedButton5: TSpeedButton;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    FtpPort: TEdit;
    Button14: TButton;
    Panel1: TPanel;
    FtpMaxClients: TEdit;
    Button15: TButton;
    FtpServer1: TFtpServer;
    procedure SpeedButton1Click(Sender: TObject);
    procedure TCPServer1Accept(Sender: TObject; Socket: Integer);
    procedure TCPServer1Data(Sender: TObject; Socket: Integer);
    procedure TCPServer1Close(Sender: TObject; Socket: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ReLoadUsers(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure N2Click(Sender: TObject);

    procedure MyoComm1CommEvent(Sender: TObject;EventMask: TCommEventMask);
    procedure MYOCOMM2CommEvent(Sender: TObject;
      EventMask: TCommEventMask);
    procedure MYOCOMM1CommReceive(Sender: TObject; Size: Word);
    procedure SpeedButton2Click(Sender: TObject);
    procedure X1Click(Sender: TObject);
    procedure E1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure MYOCOMM2CommReceive(Sender: TObject; Size: Word);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure V1Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    Procedure ReadCommandLine;
    procedure N5Click(Sender: TObject);
    procedure L1Click(Sender: TObject);
    procedure L2Click(Sender: TObject);
    procedure M1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure OpenClose_TELNETClick(Sender: TObject);
    procedure OpenClose_ModemClick(Sender: TObject);
    procedure TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N8Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure P1Click(Sender: TObject);
    procedure P2Click(Sender: TObject);
    procedure mFreePluginClick(Sender: TObject);
    procedure mLoadPluginClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure MYOCOMM3CommReceive(Sender: TObject; Size: Word);
    procedure Button9Click(Sender: TObject);
    procedure WWWServerData(Sender: TObject; Socket: Integer);
    procedure SpeedButton3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MTIDSServerData(Sender: TObject; Socket: Integer);
    procedure SpeedButton4Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure MTIDSServerClose(Sender: TObject; Socket: Integer);
    procedure Button11Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure FtpServer1Start(Sender: TObject);
    procedure FtpServer1Stop(Sender: TObject);
    procedure Button15Click(Sender: TObject);

  private
//    Connecting   : Boolean;
    Timer_Reload : Integer;
    Started : Boolean;
    Procedure AppMinimize(Sender: TObject);


  public

    Chs : Array[0..99] of Record
        IdleStartTime : Integer;
        Mode       : TChMode;
        Socket     : Integer;
        Thread     : TMtBBS;
        Way        : String[50];
        IP         : String[20];
        DisConnect : Boolean;
        MonitorWindow : TMonitorWindow;
    End;


// ->Tel
    Comms    : Array[0..3] of TMyoComm;
    ComLines : Array[0..3] of TMyoComm;

    CommRecvStr : Array[0..3] of String;
    CommStatus  : Array[0..3] of (Cs_WaitRing,Cs_WaitConnect,Cs_OpenDirect,Cs_Direct,Cs_Modem);

    procedure Kill(Ch : Integer);
    procedure TCPSTSAdd(S: String);
    procedure MTBbsSTSAdd(S: String);
    procedure WWWSTSAdd(S: String);
    procedure MTIDSSTSAdd(S: String);


    Procedure AssignCh(ChMode : TChMode;Socket : Integer;Way : String;Comm : TMyoComm);
    procedure ReLoadLoginUsers;
    procedure ReLoadAssignUsers;
    procedure CommLineStatusOut(Line : Integer;Text : String);
    procedure DisConnectLine(Line : Integer);

//****************************** MTIDS ****************************************//
    procedure DecodeReceiveData(Buf: Pointer;Socket_ : Integer;size : integer);
    procedure SendData(SendPacket: Pointer);
    procedure SendSystemMessage(buf : Pointer;ToHost,ToID : String;mes : String);
    Procedure SendMyStatusToContactUsersAndGetUsersStatus(Index : Integer;OnLine : Boolean);
    Procedure SendContactUsersStatus(ToHost : String;IDList : Pointer;IdListCount : Integer
    ;ID : String;Host : String;OnLine : Boolean;UserInfo : TMTQUserInfo);
//****************************** MTIDS ****************************************//
  end;

  Procedure Wait(Wt : Integer);
  Procedure SendMailFromSystemToSysop(Title,Mes : String);
  Function IsUsedWWWch(c : integer) : Boolean;

var
  MainForm : TMainForm;
  AppPath  : String;

  WWWUsers : Array[-1..9] of
              Record
                Enabled : Boolean;
                User : TUser;
                IP   : String;
                IdleStartTime  : Integer;
                Telegrams      : TStringList;
                URI            : String[32];
                Status         : Integer;
                Buf            : String;
                ContentLength  : Integer;
              End;

  WWWSendFiles : Array[0..99] of
                 Record
                   F : File of Char;
                   Rp : Integer;
                   Socket : Integer;
                 End;

  MTIDSSendDataBuf : Array[0..99] of
                Record
                   Data   : Pchar;
                   Socket : Integer;
                   Size   : Integer;
                   Rp     : Integer;
                End;



  MailSystem  : TMailSystem;
  MessageBoard : TMessageBoard;



implementation

uses UList, Modem, UEdit, UserSys,FileBrd, MBrdEdit, SysMesEd, EdDefine,
  MhostVer, AutoEd, LogSys, Memo, MailMan, FbrdEdit, plugsetup,MVCL,wwwmtbbs;



{$R *.DFM}


Procedure TMainForm.Kill(Ch : Integer);
Begin

     Chs[ch].Thread.SWp := 0;
     Chs[ch].Thread.SRp := 0;
{     Puts(Chs[ch].Thread,#13#10'**********************'#13#10
                             +'** �����ؒf���܂��� **'#13#10
                             +'**********************'#13#10);
}     Chs[ch].Thread.Terminate;

End;

Function IsUsedWWWch(c : integer) : Boolean;
Begin
           Result := False;
           If (c>89) and (c<100) then
              Result := wwwusers[99-c].Enabled;
end;

Function SendSystemTelegram(Mes : String):integer;
Var
   i : integer;
Begin
    Result := 0;
     For i := 0 to 99 do
       if (MainForm.Chs[i].Thread <> nil) then
         Begin
           MainForm.Chs[i].Thread.Telegrams.Add('<< MTBBS SYSTEM >>'+#1+Mes);
           Inc(Result);
         End;

End;

Procedure SendMailFromSystemToSysop(Title,Mes : String);
Var
   SysopIds : String;
   i : integer;
   MailText : String;
   Mail     : Tmail;
Begin


   Mail.Status    := Ms_NoRead;
   Mail.IsBmail   := False;
   Mail.FromId    := 'SYSTEM';
   Mail.MailFrom  := 'MTBBS�V�X�e��';
   Mail.DateTime  := Now;
   Mail.Title := Title;
   MailText   := Mes;

     For i:=0 to UserInitsCount-1 do
        If UserInits[i].Level >= GeneralDefine.User.SysopLevel then
            Begin
              Mail.ToID      := UserInits[i].ID;
              Mail.MailTo    := UserInits[i].Handle;
              (MailSystem.Write(Mail,MailText));
            End;

End;

procedure TMainForm.DisConnectLine(Line : Integer);
Var
   Comm : TMyoComm;
   Sts  : TPanel;
   CurrentTime : Integer;
Begin

  Case Line of
      0 : Begin
            Comm := MyoComm1;
            Sts  := L1Status;
          End;
      1 : Begin
            Comm := MyoComm2;
            Sts  := L2Status;
          End;
      2 : Begin
            Comm := MyoComm3;
            Sts  := L3Status;
          End;
   End;

      If  (Comm.Handle > -1) and Comm.Rlsd then
        Begin
         Comm.Abort := True;
         Application.ProcessMessages;
         Sts.Caption := '����ؒf���ł�.';
         CurrentTime := GetTickCount;
         EscapeCommFunction(Comm.Handle,CLRDTR);
         while GetTickCount < CurrentTime + 5000 do
          Begin
            Application.ProcessMessages;
            If Not Comm.Rlsd then
              Begin
                  EscapeCommFunction(Comm.Handle,SETDTR);
                  CommLineStatusOut(Line,'���M�ҋ@��');
                  CommStatus[Line]  := Cs_WaitRing;
                  Exit;
              End;
            Sleep(300);
          End;
         EscapeCommFunction(Comm.Handle,SETDTR);
         Sts.Caption := '����ؒf�Ɏ��s���܂���.';
         CommStatus[Line] := Cs_WaitRing;
        End;

End;



procedure TMainForm.TCPSTSAdd(S: String);
Begin

  with TCPStatus.Lines do
    begin
      if Count > 20 then
        Delete(0);
      Add('['+TimeToStr(Now)+'] '+S);
      TCPStatus.Update;
    end;

End;

procedure TMainForm.MTBbsSTSAdd(S: String);
Begin
  with MTBBSStatus.Lines do
    begin
      if Count > 20 then
        Delete(0);
      Add('['+TimeToStr(Now)+'] '+S);
      MTBBSStatus.Update;
    end;
End;

procedure TMainForm.WWWSTSAdd(S: String);
Begin
  with WWWStatus.Lines do
    begin
      if Count > 20 then
        Delete(0);
      Add('['+TimeToStr(Now)+'] '+S);
      WWWStatus.Update;
    end;
End;

procedure TMainForm.MTIDSSTSAdd(S: String);
Begin
  with MTIDSStatus.Lines do
    begin
      if Count > 20 then
        Delete(0);
      Add('['+TimeToStr(Now)+'] '+S);
      Update;
    end;
End;


procedure TMainForm.AssignCh(ChMode : TChMode;Socket : Integer;Way : String;Comm : TMyoComm);
Var
   AssignCh : Integer;
   i        : Integer;
   Cms      : String;
Begin

 Mutex.Wait;

  AssignCh := 0;
  For i := 0 to 99 Do  //�@�g���Ă��Ȃ��`�����l���̌���
    if (Chs[i].Mode = Cm_None) and (Chs[i].Thread=nil) then
     Begin
       AssignCh := i;
       Break;
     End;
  Chs[AssignCh].Socket        := Socket;
  Chs[AssignCh].Way           := Way;
  Chs[AssignCh].Disconnect    := False;

  Case ChMode of
       CM_Telnet :
         Begin
            Cms := 'TCP/IP Telnet';
            Chs[AssignCh].Ip     := TcpServer1.PeerToAddress(Socket);
         End;
       CM_Modem  :
         Begin
            Cms := '���f���ڑ�';
            Chs[AssignCh].Ip     := '';
         End;
  End;

  Chs[AssignCh].IdleStartTime := GetTickCount;
  Chs[AssignCh].Mode          := ChMode;
  Chs[AssignCh].Thread        := TMtbbs.Create(MainForm,AssignCh,Comm);   // �X���b�h�̐���

 Mutex.Release;


End;

procedure TMainForm.SpeedButton1Click(Sender: TObject);
Var
   i : Integer;
begin

  with TCPServer1 do
    begin

     Port := PortNo.Text;

     If SocketState = ssListening then
      Begin

        For i := 0 to 99 do
         if Chs[i].Mode = Cm_Telnet then
             Kill(i);

       Wait(1500);
       Close;
      End
      Else Open;

      SpeedButton1.Down := (SocketState = ssListening);
      SpeedButton1.Refresh;
      if SocketState = ssListening then
        begin
          TCPStatus.Lines.Clear;
          TCPSTSAdd(LocalHostAddress+' �ڑ���ҋ@���܂��B �|�[�g: '+Port);
        end;
    end;

  if SpeedButton1.Down or SpeedButton2.Down then
     TrayIcon1.AnimatePlay(amAutomatic)
  else
     TrayIcon1.AnimateStop;


end;

Procedure Wait(Wt : Integer);
Var
  i : Integer;
Begin

  i := GetTickCount;
  While (i+Wt)>GetTickCount do
     Application.ProcessMessages;


End;




procedure TMainForm.TCPServer1Accept(Sender: TObject; Socket: Integer);
Var
 s : String;

  Function CountIP(IP : String) : Integer;
  Var
     i : Integer;
  Begin
    Result :=0;
    For i := 0 to 99 do
       if (IP = chs[i].Ip) and (chs[i].Thread <> nil) then
            Inc(Result);
  End;

begin

 Mutex.Wait;

  Try
//    Connecting := True;

  with TCPServer1 do
    begin

      if Clients.Count > StrToIntDef(MaxUser.Text,9) then
        begin
          Write(Socket,#$FF#$FB#$01#$FF#$FB#$03//�iIAC WILL ECHO,IAC WILL SUPPRESS-GO-AHEAD�j
          +#13#10#13#10+MyoHostVer+#13#10+'Sorry !! MyoHost reached max client limit('+MaxUser.Text+')...'#13#10'Please try again later.'#13#10);
          TcpSTSAdd('�ő�ڑ������z�����אV�����ڑ������ۂ��܂����B '+PeerToAddress(Socket)+' �|�[�g:'+PeerToPort(Socket));
          Wait(1000);
          Disconnect(Socket);
        end
      else
        begin
          If CountIP(PeerToAddress(Socket)) >= GeneralDefine.TcpIp.MaxSameIp then
            Begin
              Write(Socket,#$FF#$FB#$01#$FF#$FB#$03//�iIAC WILL ECHO,IAC WILL SUPPRESS-GO-AHEAD�j
              +#13#10#13#10+MyoHostVer+#13#10#13#10+'*** ����IP�A�h���X�ɂ��ڑ��́A�ő�'+IntToStr(GeneralDefine.TcpIp.MaxSameIp)+'�ɐ�������Ă��܂� ***'#13#10#13#10);
              TcpSTSAdd('����h�o�A�h���X�̍ő�ڑ������z�����אV�����ڑ������ۂ��܂����B'+PeerToAddress(Socket)+' �|�[�g:'+PeerToPort(Socket));
              Wait(1000);
              Disconnect(Socket);
            End Else
            Begin
              TcpSTSAdd('�V�����ڑ����󂯕t���܂����B'+PeerToAddress(Socket)+' �|�[�g:'+PeerToPort(Socket));
              TcpIpClients.Caption := IntToStr(Clients.Count);
              Write(Socket,#$FF#$FB#$01#$FF#$FB#$03///�iIAC WILL ECHO,IAC WILL SUPPRESS-GO-AHEAD, IAC WILL BINARY-TRANSFER
              +#13#10#13#10#13#10+MyoHostVer+#13#10#13#10);
              if PeerToAddress(Socket)='127.0.0.1' then s := 'LOCALHOST'
                                                   else s := PeerToAddress(Socket);
              AssignCh(Cm_Telnet,Socket,'TELNET   '+s,nil);
            End;
        end;
    end;
 Finally
//   Connecting := False;
  Mutex.Release;
 End;

end;


procedure TMainForm.TCPServer1Data(Sender: TObject; Socket: Integer);
Var
   Buf  : PChar;
   Size : Integer;
   i    : Integer;
begin

  GetMem(Buf,1024+1);
    Size := TCPServer1.ReadBuffer(Socket,Buf,1024);

    For i := 0 to 99 do
    if  ( chs[i].Mode = cm_Telnet) and (chs[i].socket = Socket) and (chs[i].Thread <> nil)
      Then  Chs[i].Thread.Receive(Buf,Size);

  FreeMem(Buf,1024+1);

end;

procedure TMainForm.TCPServer1Close(Sender: TObject; Socket: Integer);
Var
   i,t : Integer;
begin

  Mutex.Wait;


    With TCPServer1 do
      Begin
          TcpSTSAdd('�ؒf����܂��� ...'+PeerToAddress(Socket)+' �|�[�g:'+PeerToPort(Socket));
          TcpIpClients.Caption := IntToStr(Clients.Count);
      End;

      Sleep(50);

      For i:=0 to 99 Do
          if (chs[i].Mode = cm_Telnet) and (chs[i].Socket = Socket) then
             Begin
               Chs[i].Disconnect := True;
               If Chs[i].Thread <> nil then
                   Chs[i].Thread.Terminate;
          End;

  Mutex.Release;

end;

Procedure TMainForm.ReadCommandLine;
  Var
     OpenTelnet : Boolean;
     OpenModem  : Boolean;
     OpenWWW    : Boolean;

     a          : String;
     i          : Integer;
   Begin

      OpenTelnet := False;
      OpenModem  := False;
      OpenWWW    := False;

      for i := 1 to ParamCount do
       begin
         a := UpperCase(ParamStr(I));

         If Pos('OT',a)>0 then
            OpenTelnet := True;
         If Pos('OM',a)>0 then
            OpenModem  := True;
         If Pos('OW',a)>0 then
            OpenWWW    := True;
       End;

       If GeneralDefine.StartUp.minimize then
          Application.Minimize;

       If OpenTelnet or GeneralDefine.StartUp.OpenTelnet then
          SpeedButton1Click(MainForm);
       If OpenWWW or GeneralDefine.StartUp.OpenWWW then
          SpeedButton3Click(MainForm);
       If GeneralDefine.StartUp.OpenMTIDS then
          SpeedButton4Click(MainForm);
       If OpenModem or GeneralDefine.StartUp.OpenModem then
         Begin
          SpeedButton2.Down := True;
          SpeedButton2Click(MainForm);
         End;

       a := '-o';

       If GeneralDefine.StartUp.StartTinou then
           ShellExecute(Application.Handle,nil,pchar(Auto.TinouFileName),Pchar(a),nil,SW_SHOWNORMAL);


end;


   Procedure TMainForm.AppMinimize(Sender: TObject);
   Var
     ExStyle : LongInt;
   Begin

        ShowWindow(Application.handle,SW_HIDE);
        ExStyle := WS_EX_TOOLWINDOW;
        SetWindowLong(Application.Handle, GWL_EXSTYLE, ExStyle);

   End;

procedure TMainForm.FormCreate(Sender: TObject);
Var
   i        : Integer;


Begin




 Started := False;

  Application.OnMinimize := AppMinimize;

  For i := 0 to 99 Do  //�@�`�����l���̏�����
   Begin
    Chs[i].Mode   := cm_None;
    Chs[i].Thread := nil;
    Chs[i].MonitorWindow := nil;
   End;

  AppPath := ExtractFilePath(Application.ExeName);  // Main.Pas

  Timer_Reload := GetTickCount;

   With LoginUsers Do
     Begin
          Cells[0,0] := 'Channel';
          Cells[1,0] := 'ID';
          Cells[2,0] := 'Handle';
          Cells[3,0] := 'Protocol / IP';//User.From;
          Cells[4,0] := 'Location';
         For i:=0 to 99 Do
            Cells[0,i+1] := Format('CH%.2d',[i]);
     End;

 MtBBSStatus.Text := HostVersionMessage;//'�z�X�g�v���O���� MTBBS Version '+MTBBSVERSION+'  Copyright(C) 1997.10-98.2 By MYO';

// Connecting := False;


end;



procedure TMainForm.Timer1Timer(Sender: TObject);
Var

   MTBBS : TMTBBS;
   i,j,k,l : Integer;
   SS    : String;
   b     : Boolean;

   tm    : TDateTime;

   Hour1,Min1,Dummy : Word;
   Hour2,Min2       : Word;

   Procedure ShowMyIP;
   Type
     TPCArr = array[0..9999] of PChar;   // PChar �̔z��^
     PPCarr = ^TPCArr;                   // �ւ̎Q�ƌ^
   var
     HostName: array [1..50] of char;          // �����̃z�X�g��
     hostent: PHostEnt;                        // ������IP�A�h���X�擾�p
     InAddr: TInAddr;                          // IP�A�h���X�\����
     FLastError : Integer;
     Selfname : String;
     wVersionRequired: WORD;                   // WinSock�̃o�[�W����
     FWsaData: TWSAData;                     // WinSock�\����

     S: string;
     i : Integer;

   begin
     MyIpAddress.Clear;

     wVersionRequired := MAKEWORD(1,1);
     if WSAStartup(wVersionRequired, FWsaData) <> 0 then
     begin
       FLastError := WSAGetLastError;          // �G���[�R�[�h�̎擾
       Exit;
     end;

     { �����̃z�X�g���̎擾 : �v���p�e�B�ɕ\�������邽�߂��� }
     if gethostname(@HostName, SizeOf(HostName)-1) = SOCKET_ERROR then
     begin
       FLastError := WSAGetLastError;          // �G���[�R�[�h�̎擾
       Exit;                                   // ���\�b�h���甲���o��
     end;
     Selfname := StrPas(@HostName);           // �����̃z�X�g��

     { ������IP�A�h���X�̎擾 : �v���p�e�B�ɕ\�������邽�߂���}
     hostent := gethostbyname(PChar(Selfname));   // �z�X�g������IP�A�h���X
     if hostent <> nil then                    // �z�X�g��񂪎擾�ł�����
     begin
     i := 0;
     while PPCarr( hostent.h_addr_list )[i] <> nil do
      begin
         CopyMemory(@InAddr,(PPCarr(hostent.h_addr_list)[i]), SizeOf(InAddr));  // IP�A�h���X�����̃R�s�[
         MyIpAddress.Items.add(StrPas(inet_ntoa(InAddr)));     // ������IP�A�h���X
         inc(i);
     end;
     end;
     WSACleanup;

  //   If DefIPNo<ListBox1.Items.Count then
    //    ListBox1.ItemIndex := DefIPNo;

   end;
  Procedure CheckConnect(CP: Integer);
  Var
    Comm : TMyoComm;
  Begin
     Case Cp Of
       0 :  Comm := MyoComm1;
       1 :  Comm := MyoComm2;
       2 :  Comm := MyoComm3;
     End;
     If (CommStatus[CP] = Cs_OpenDirect)   or ((Comm.rlsd and (CommStatus[CP] <> Cs_Modem)))   then
      Begin

           Comm.SendString(#13#10#13#10+MyoHostVer+#13#10#13#10);

        If CommStatus[CP] = Cs_OpenDirect then
         Begin
           CommStatus[CP] := Cs_Direct;
           AssignCh(cm_Modem,Cp,Format('DIRECT L%d',[Cp+1]),Comm);
         End
        else
         Begin
           AssignCh(cm_Modem,Cp,Format('MODEM L%d',[Cp+1]),Comm);
           CommStatus[CP] := Cs_Modem;
         End;

          CommLineStatusOut(Cp,'�ڑ����܂���.');
      End
      Else
        If not(CommStatus[CP] = Cs_Direct) and  (CommStatus[Cp] <> Cs_WaitRing)  and Not(Comm.Rlsd) then
         Begin
            CommLineStatusOut(Cp,'���M�ҋ@��');
            CommStatus[Cp] := Cs_WaitRing;
         End;
  End;

   Procedure TcpSend;
   Var
      Data     : PChar;
      SendSize : Integer;
      i,j,l    : Integer;
   Begin

     Data := AllocMem(1025);

       For i:=0 to 99 do
        if Not (chs[i].Thread = nil) then
         Begin

            MTBBS := Chs[i].Thread;

            If Chs[i].Mode = Cm_Telnet Then
               For l := 0 To TCPServer1.Clients.Count - 1 Do
                 If Chs[i].Socket = TCPServer1.Clients[l] then
                  Begin
                   With MTBBS do
                    Begin
                      k := SRp;
                      If (k<>SWp) then
                       Begin
                         j := 0;
                         While (k <> SWp) Do
                          Begin
                            Data[j] := SendBuf[k];
                            Inc(j);
                            k := (k+1) mod High(SendBuf);
                            If j > 1023 then Break;
                          End;
                          SendSize := TCPServer1.WriteBuffer(Chs[i].Socket,@Data[0],j);
                          If SendSize>0 then
                             Chs[i].IdleStartTime := GetTickCount;
                          Data[SendSize] := #0;
                          SRp := (Srp+SendSize) mod High(SendBuf);
                          If Chs[i].MonitorWindow <> nil then
                             Chs[i].MonitorWindow.AddStr(PChar(Data));
                       End;
                    End;
                    Break;
                  End;
            If (GeneralDefine.TcpIP.IdleTimeLimit > 0) and (GetTickCount - Chs[i].IdleStartTime > GeneralDefine.TcpIP.IdleTimeLimit*1000) and (Chs[i].Ip<>'127.0.0.1') then
               Begin
                 MTBbsSTSAdd(Format('CH%.2d:���ʐM�^�C���A�E�g�����������׃`�����l�����J�����܂�.',[i]));
                 Mtbbs.Terminate;
                 Chs[i].IdleStartTime := GetTickCount;
               End;
         End;

        For i:=0 to 99 do
          if (WWWSendFiles[i].Socket > 0) then
               Begin
                   If Eof(WWWSendFiles[i].F) or (TcpServer1.PeerToAddress(WWWSendFiles[i].Socket) = '')  then
                     Begin
                        CloseFile(WWWSendFiles[i].F);
                        WWWSendFiles[i].Socket  := 0;
                     End
                     Else
                     Begin
                        Seek(WWWSendFiles[i].F,WWWSendFiles[i].Rp);
                        BlockRead(WWWSendFiles[i].F,Data^,1024,j);
                        WWWSendFiles[i].Rp := WWWSendFiles[i].Rp
                                            + WWWServer.WriteBuffer(WWWSendFiles[i].Socket,Data,j);
                     End;
               End;

        For i:=0 to 99 do
          if (MTIDSSendDataBuf[i].Socket > 0) then
           Begin
              If (MTIDSServer.PeerToAddress(MTIDSSendDataBuf[i].Socket) = '')  then
               Begin
                MTIDSSendDataBuf[i].Socket := 0;
                FreeMem(MTIDSSendDataBuf[i].Data,MTIDSSendDataBuf[i].Size);
               End
              else
               Begin
                  MTIDSSendDataBuf[i].Rp := MTIDSSendDataBuf[i].Rp
                    + MTIDSServer.WriteBuffer(MTIDSSendDataBuf[i].Socket,@MTIDSSendDataBuf[i].Data[MTIDSSendDataBuf[i].Rp],MTIDSSendDataBuf[i].Size-MTIDSSendDataBuf[i].Rp);
                  if MTIDSSendDataBuf[i].Size=MTIDSSendDataBuf[i].Rp then
                    Begin
                      MTIDSSendDataBuf[i].Socket := 0;
                      FreeMem(MTIDSSendDataBuf[i].Data,MTIDSSendDataBuf[i].Size);
                    End;
               End;
           End;

     FreeMem(Data,1025);

   End;



begin


   if Timer_Reload + 5000 < GetTickCount then
    Begin

      ReLoadLoginUsers;
      ReLoadAssignUsers;

      TcpIpClients.Caption := IntToStr(TCPServer1.Clients.Count);
      Timer_Reload := GetTickCount;
      ShowMyIP;

      For i := 0 to 99 do
       If Chs[i].Thread<>nil Then
        Begin
         If (Chs[i].Mode = Cm_Modem) Then
              If not(CommStatus[Chs[i].socket] = Cs_Direct) and Not Chs[i].Thread.Comm.RLSD then
                  Chs[i].Thread.Terminate;

         If (chs[i].Mode = cm_Telnet) then
            If (TcpServer1.PeerToAddress(Chs[i].Socket) = '') then
               Chs[i].Thread.Terminate;
        End;

    End;

   DecodeTime(Now,Hour1,Min1,Dummy,Dummy);

   DecodeTime(Auto.AutoOpenTime,Hour2,Min2,Dummy,Dummy);

   If Auto.AutoOpenEnabled then
      If (Hour1 = Hour2) and  (Min1 = Min2) then
        Begin
           If Not Auto.OpenDone then
            Begin
             Auto.OpenDone := True;
             Auto.Open_;
            End;
        End
        else
           Auto.OpenDone := False;

   DecodeTime(Auto.AutoCloseTime,Hour2,Min2,Dummy,Dummy);

   If Auto.AutoCloseEnabled and not(Auto.OpenDone) then
      If (Hour1 = Hour2) and  (Min1 = Min2) then
        Begin
           If Not Auto.CloseDone then
            Begin
             Auto.CloseDone := True;  //�ċN��h��
             Auto.Close_;
            End;
        End
        else
           Auto.CloseDone := False;


   CheckConnect(0);
   CheckConnect(1);
   CheckConnect(2);

   If MessageBoardsChange then
     Begin
       MessageBoardsSave;
       MessageBoardsChange := False;
     End;

   TcpSend;

   For i:=0 to 9 do
    if WWWUsers[i].Enabled and  (GetTickCount - WWWUsers[i].IdleStartTime > GeneralDefine.TcpIp.WWWIdleTimeLimit*1000) then
           Begin
                 WWWSTSAdd(Format('WWWCH%.2d:���ʐM�^�C���A�E�g�����������׃`�����l�����J�����܂�.',[i]));
                 FreeWWWCh(i);
           End;


end;


procedure TMainForm.ReLoadLoginUsers;
Var
   i,j : Integer;
   ItemIndex  : Integer;
   User       : Mtbbs.TUser;
Begin

//  ItemIndex := LoginUsers.ItemIndex;

 GroupBox1.Caption := '�`�����l���g�p�� ['+TimeToStr(Now)+']';

  j := 1;
  With LoginUsers Do
   Begin
    For i:=0 to 99 Do
     if Chs[i].Mode <> cm_None then
      Begin
          User := Chs[i].Thread.User;
          Cells[0,j] := Format('CH%.2d',[i]);
          Cells[1,j] := User.ID;
          Cells[2,j] := User.HandleName;
          Cells[3,j] := Chs[i].Way;
          Cells[4,j] := User.Where;
          Inc(j);
      End;
    For i:=0 to 9 Do
     if WWWUsers[i].Enabled then
      Begin
          User := WWWUsers[i].User;
          Cells[0,j] := Format('CH%.2d',[99-i]);
          Cells[1,j] := User.ID;
          Cells[2,j] := User.HandleName;
          Cells[3,j] := 'WWW / '+WWWUsers[i].Ip;
          Cells[4,j] := User.Where;
          Inc(j);
      End;
     For i:=j to 100 do
      If  Cells[0,i]<>'' then
       Begin
          Cells[0,i] := '';
          Cells[1,i] := '';
          Cells[2,i] := '';
          Cells[3,i] := 'Empty';
          Cells[4,i] := '';
       End;
   End;


{  If LoginUsers.Items.Count > ItemIndex then
     LoginUsers.ItemIndex := ItemIndex;
 }
end;

procedure TMainForm.ReLoadAssignUsers;
Var
   i : Integer;
Begin


 GroupBox10.Caption := 'IP�f�[�^�x�[�X(ID / IP / �o�^����) ['+TimeToStr(Now)+']';
 ListBox2.items.clear;

  For i:=0 to 99 Do
    With MTIDSClientDataBase[i] Do
     if ID <> '' then
       ListBox2.items.add(ID+' / '+inet_ntoa(info.InAddr)+' / '+DateTimeToStr(LoginTime));

end;


procedure TMainForm.Button5Click(Sender: TObject);
begin
   if MyIpAddress.itemindex=-1 then
     begin
         if MyIpAddress.items.count >0 then
            MyIpAddress.itemindex:=0
         else
           exit;
     end;
     Clipboard.SetTextBuf(pchar(MyIpAddress.items[MyIpAddress.itemindex]));

end;

procedure TMainForm.N1Click(Sender: TObject);
begin
     UserList.ShowModal;
end;

procedure TMainForm.Button6Click(Sender: TObject);
begin

     ModemSettingDialog.ShowModal;

end;

procedure TMainForm.ReLoadUsers(Sender: TObject);
begin

   ReLoadLoginUsers;

end;

procedure TMainForm.Button2Click(Sender: TObject);
Var
   Ch : Integer;
begin

     Ch := StrToIntDef(Copy(LoginUsers.Cells[0,LoginUsers.Selection.Top],3,2),-1);
     if ch<0 then exit;

     if Chs[Ch].Mode <> cm_None then
       If SearchUser(Chs[Ch].Thread.User.ID) > -1 then
         Begin
            User.UserInit := GetUserInit(Chs[Ch].Thread.User.ID);
            User.ShowModal;
         End;

end;

procedure TMainForm.N2Click(Sender: TObject);
begin
     MessageBoardEdit.ShowModal;
end;

////------------   �d�b����@�@----------------------

procedure TMainForm.CommLineStatusOut(Line : Integer;Text : String);
Begin
    Mutex.Wait;
        Case Line of
           0 : L1Status.Caption:=Text;
           1 : L2Status.Caption:=Text;
           2 : L3Status.Caption:=Text;
        End;
    Mutex.Release;
End;


procedure TMainForm.MyoComm1CommEvent(Sender: TObject;EventMask: TCommEventMask);
Var
   T : Integer;
begin

  If (evRlsd in EventMask  ) then
   Begin
     If Not MyoComm1.Rlsd then
        Begin
         CommLineStatusOut(0,'���M�ҋ@��');
         CommStatus[0] := Cs_WaitRing;
        End;
   End;

end;


procedure TMainForm.MYOCOMM2CommEvent(Sender: TObject;
  EventMask: TCommEventMask);
Var
   T : Integer;
begin

  If (evRlsd in EventMask  ) then
   Begin
     If Not MyoComm2.Rlsd then
        Begin
         CommLineStatusOut(1,'���M�ҋ@��');
         CommStatus[1] := Cs_WaitRing;
        End;
   End;

end;

procedure TMainForm.MYOCOMM1CommReceive(Sender: TObject; Size: Word);
Const
   CP   = 0;
Var
  SendStr : String;
  i,j     : Integer;
  MTBBS   : TMTBBS;
  S       : String;
  Data    : PChar;
  Comm    : TMyoComm;
begin

  Comm := MyoComm1;

  GetMem(Data,Size + 1);
    Comm.Read(Data, Size);

  If Comm.rlsd or (CommStatus[CP] = Cs_Direct)  then
  Begin
      For i:=0 to 99 do
         if (chs[i].Mode = Cm_Modem) and (chs[i].Thread <> nil) and (chs[i].Thread.Comm = Comm) then
             chs[i].Thread.Receive(Data,Size);
  End Else
      Begin
            For i:=0 to Size - 1 Do
              Case Data[i] of
               #13 :
                Begin
                   Case CommStatus[CP] of
                      Cs_WaitRing :
                        if Pos('RING',CommRecvStr[CP])>0 then
                         Begin
                           Comm.SendString('ATA'#13#10);
                           CommStatus[CP] := Cs_WaitConnect;
                         End;
                      Cs_WaitConnect :
                         Begin
                            if (Pos('OK',CommRecvStr[CP])>0) or (Pos('NO CARRIER',CommRecvStr[CP])>0) then
                                CommStatus[CP] := Cs_WaitRing;
                         End;
                   End;
                   CommRecvStr[Cp] := '';
                End;
                Else
                 CommRecvStr[Cp] := CommRecvStr[Cp] + Data[i];
              End;
      End;

  FreeMem(Data,Size+1);

end;

procedure TMainForm.SpeedButton2Click(Sender: TObject);
Var
  i : Integer;
    Function OpenComm(Comm : TMyoComm;ModemSetting : TModemSetting):Boolean;
    Begin
     Try
       Result := False;
        With ModemSetting do
         if Enabled then
          Begin
            Comm.Port     := Port;
            Comm.BaudRate := BaudRate;
            Comm.Open;
            Comm.SendString(ClearCommand+#13#10);
            Result := True;
          End;
     Except
       Result := False;
     End;
    End;

begin

  If SpeedButton2.Down then
     Begin
       CommStatus[0] := Cs_WaitRing;
       CommStatus[1] := Cs_WaitRing;
       CommStatus[2] := Cs_WaitRing;
{
       For i:= 0 to 2 do
        Begin
          If ModemSetting[i].Direct then CommStatus[i] := Cs_Direct
        End;
 }
       CommRecvStr[0] := '';
       CommRecvStr[1] := '';
       CommRecvStr[2] := '';

       If OpenComm(MyoComm1,ModemSetting[0]) then
         Begin
          CommLineStatusOut(0,'���M�ҋ@��');
          Button9.Enabled := True;
         End;
       If OpenComm(MyoComm2,ModemSetting[1]) then
          CommLineStatusOut(1,'���M�ҋ@��');
       If OpenComm(MyoComm3,ModemSetting[2]) then
          CommLineStatusOut(2,'���M�ҋ@��');
     End
    Else
    Begin

      DisConnectLine(0);
      DisConnectLine(1);
      DisConnectLine(2);
      Button9.Enabled := False;
      MyoComm1.Close;
       CommLineStatusOut(0,'���ғ�');
      MyoComm2.Close;
       CommLineStatusOut(1,'���ғ�');
      MyoComm3.Close;
       CommLineStatusOut(2,'���ғ�');
    End;

  if SpeedButton1.Down or SpeedButton2.Down then
     TrayIcon1.AnimatePlay(amAutomatic)
  else
     TrayIcon1.AnimateStop;


end;

procedure TMainForm.X1Click(Sender: TObject);
begin
     Close;
end;

procedure TMainForm.E1Click(Sender: TObject);
begin
    SystemMessageEdit.ShowModal;
end;

procedure TMainForm.N3Click(Sender: TObject);
begin
    EditDefine.ShowModal;
end;


procedure TMainForm.MYOCOMM2CommReceive(Sender: TObject; Size: Word);
Const
   CP   = 1;
Var
  SendStr : String;
  i,j     : Integer;
  MTBBS   : TMTBBS;
  S       : String;
  Data    : PChar;
  Comm    : TMyoComm;
begin

  Comm := MyoComm2;

  GetMem(Data,Size + 1);
    Comm.Read(Data, Size);

  If Comm.rlsd or (CommStatus[CP] = Cs_Direct) then
  Begin
      For i:=0 to 99 do
         if (chs[i].Mode = Cm_Modem) and (chs[i].Thread <> nil) and (chs[i].Thread.Comm = Comm) then
             chs[i].Thread.Receive(Data,Size);
  End Else
      Begin
            For i:=0 to Size - 1 Do
              Case Data[i] of
               #13 :
                Begin
                   Case CommStatus[CP] of
                      Cs_WaitRing :
                        if Pos('RING',CommRecvStr[CP])>0 then
                         Begin
                           Comm.SendString('ATA'#13#10);
                           CommStatus[CP] := Cs_WaitConnect;
                         End;
                      Cs_WaitConnect :
                         Begin
                            if (Pos('OK',CommRecvStr[CP])>0) or (Pos('NO CARRIER',CommRecvStr[CP])>0) then
                                CommStatus[CP] := Cs_WaitRing;
                         End;
                   End;
                   CommRecvStr[Cp] := '';
                End;
                Else
                 CommRecvStr[Cp] := CommRecvStr[Cp] + Data[i];
              End;
      End;

  FreeMem(Data,Size+1);


end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin

 if SendSystemTelegram('�I���̎��Ԃł����')>0 then
     Timer1Timer(Sender);

  If SpeedButton1.Down then
     SpeedButton1Click(Sender);
  If SpeedButton2.Down then
   Begin
     SpeedButton2.Down := False;
     SpeedButton2Click(Sender);
   End;


end;


procedure TMainForm.V1Click(Sender: TObject);
begin
    MyoHostVersion.ShowModal;
end;


procedure TMainForm.Button8Click(Sender: TObject);
begin

    ShellExecute(Handle,nil,'Telnet.exe','127.0.0.1',PChar(AppPath),SW_SHOWNORMAL)

end;

procedure TMainForm.Button1Click(Sender: TObject);
Var
   Ch : Integer;
begin


     Ch := StrToIntDef(Copy(LoginUsers.Cells[0,LoginUsers.Selection.Top],3,2),-1);
     if ch<0 then exit;

  if IsUsedWWWch(ch) then
    WWWUsers[99-ch].Enabled := False
  else
    if Chs[Ch].Mode <> cm_None then
         Kill(ch);



end;

procedure TMainForm.Button7Click(Sender: TObject);
begin
     ReLoadLoginUsers;

end;

procedure TMainForm.Button3Click(Sender: TObject);
Var
   Ch : Integer;
begin

     Ch := StrToIntDef(Copy(LoginUsers.Cells[0,LoginUsers.Selection.Top],3,2),-1);
     if ch<0 then exit;

     if Chs[Ch].MonitorWindow = nil then
      Begin
        Application.CreateForm(TMonitorWindow,Chs[Ch].MonitorWindow);
        Chs[Ch].MonitorWindow.Fch  := Ch;
        Chs[Ch].MonitorWindow.Caption := Format('���j�^�[ .... �`�����l��[%.2d]',[Ch]);
      End
      Else
        Chs[Ch].MonitorWindow.Show;

end;

procedure TMainForm.N5Click(Sender: TObject);
begin
   Auto.ShowModal;
end;

procedure TMainForm.L1Click(Sender: TObject);
Var
   i,j : Integer;
   Log : ^TAccessLog;
    MF : TMemoForm;
     s : String;
Begin

  Application.CreateForm(TMemoForm,MF);
  MF.Caption := '�ǂݍ��ݒ�....';

  Log := AllocMem(SizeOf(TAccessLog)*(500+1));
  j := GetAccessLog(Log^,500);
  S := '';

  S := '���[�UID  �n �� �h ��   CH  �� �t   ���O�C��  ���O�A�E�g �ڑ�����  �ڑ��`��  '#13#10
      +'-------- -------------- -- -------- --------   --------  -------- ---------->'#13#10;

  Inc(Log,j);
   For i := 0 to j-1 do
    Begin
     Dec(Log);
     With Log^ do
      Begin
       S := S + (Format('%.8s %.14s %.2d %.8s %.8s-->%.8s (%.8s) %s'#13#10,
       [Id+'         ',Handle+'               ',Ch,DateToStr(InTime)+'         ',TimeToStr(InTime)+'         '
        ,TimeToStr(OutTime)+'         ',TimeToStr(OutTime - InTime)+'         ',Way]));
      End;
     End;

  MF.Memo1.Text := s;
  MF.Caption := '�A�N�Z�X�L�^';

  FreeMem(Log,SizeOf(TAccessLog)*(600+1));


end;

procedure TMainForm.L2Click(Sender: TObject);
Var
    MF : TMemoForm;
Begin

  Application.CreateForm(TMemoForm,MF);
  MF.Caption := '���O�C�����s�L�^ .... '+AppPath+'LoginErr.Log';
  MF.Memo1.Lines.LoadFromfile(AppPath+'LoginErr.Log');

End;

procedure TMainForm.M1Click(Sender: TObject);
begin

  MailManager.ShowModal;

end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
   close;
end;

procedure TMainForm.PopupMenu1Popup(Sender: TObject);
begin

  If Speedbutton1.Down then
    Openclose_telnet.Caption := 'Telnet�ڑ����N���[�Y'
  else
    Openclose_telnet.Caption := 'Telnet�ڑ����I�[�v��';
  If Speedbutton2.Down then
    Openclose_modem.Caption := '���f���ڑ����N���[�Y'
  else
    Openclose_modem.Caption := '���f���ڑ����I�[�v��';



end;

procedure TMainForm.OpenClose_TELNETClick(Sender: TObject);
begin

    SpeedButton1Click(Sender);

end;

procedure TMainForm.OpenClose_ModemClick(Sender: TObject);
begin

    SpeedButton2.Down := Not(SpeedButton2.Down);
    SpeedButton2Click(Sender);

end;


procedure TMainForm.TrayIcon1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
  ExStyle : LongInt;

begin

     ExStyle := WS_EX_APPWINDOW;
     SetWindowLong(Application.Handle, GWL_EXSTYLE, ExStyle);
     ShowWindow(Application.handle,SW_SHOWNORMAL);
     SetForegroundWindow(Application.handle);  //���̕����Ȃ��ƕ\�����x���
     BringWindowToTop(Application.Handle);
    // ShowWindow(Application.Handle, SW_SHOWNORMAL)

end;

procedure TMainForm.N8Click(Sender: TObject);
begin
 //  ApplicationWindowState := wsMinimized;
end;

procedure TMainForm.N6Click(Sender: TObject);
begin

   FileBoardEdit.ShowModal;

end;

procedure TMainForm.Button4Click(Sender: TObject);
Var
   Ch : Integer;
   a  : String;
begin

     Ch := StrToIntDef(Copy(LoginUsers.Cells[0,LoginUsers.Selection.Top],3,2),-1);
     if ch<0 then exit;

     if Chs[Ch].Mode <> cm_None then
         Begin
            a := InputBox('�V�X�e���d��̑��M', '���b�Z�[�W����͂��Ă�������', '');
            If a<>'' then
               if Chs[Ch].Mode <> cm_None then
                   Chs[Ch].Thread.Telegrams.Add('<< MTBBS SYSTEM >>'+#1+a)
               Else
                 Begin
                      Beep;
                      ShowMessage('���O�C������Ă��܂���');
                 End;
         End;
end;

procedure TMainForm.P1Click(Sender: TObject);
begin
    PlugSetupDialog.ShowModal;
end;

procedure TMainForm.P2Click(Sender: TObject);
begin

    PlugSetupDialog.ShowModal;

end;

procedure TMainForm.mFreePluginClick(Sender: TObject);
begin
   FreePlugin;
end;

procedure TMainForm.mLoadPluginClick(Sender: TObject);
begin
  LoadPlugin;
end;


procedure TMainForm.FormActivate(Sender: TObject);
begin

  LoadUserInits;

 if Started then Exit;

  MainForm.ReadCommandLine;

 Started := True;

end;




procedure TMainForm.MYOCOMM3CommReceive(Sender: TObject; Size: Word);
Const
   CP   = 2;
Var
  SendStr : String;
  i,j     : Integer;
  MTBBS   : TMTBBS;
  S       : String;
  Data    : PChar;
  Comm    : TMyoComm;
begin

  Comm := MyoComm3;

  GetMem(Data,Size + 1);
    Comm.Read(Data, Size);

  If Comm.rlsd or (CommStatus[CP] = Cs_Direct) then
  Begin
      For i:=0 to 99 do
         if (chs[i].Mode = Cm_Modem) and (chs[i].Thread <> nil) and (chs[i].Thread.Comm = Comm) then
             chs[i].Thread.Receive(Data,Size);
  End Else
      Begin
            For i:=0 to Size - 1 Do
              Case Data[i] of
               #13 :
                Begin
                   Case CommStatus[CP] of
                      Cs_WaitRing :
                        if Pos('RING',CommRecvStr[CP])>0 then
                         Begin
                           Comm.SendString('ATA'#13#10);
                           CommStatus[CP] := Cs_WaitConnect;
                         End;
                      Cs_WaitConnect :
                         Begin
                            if (Pos('OK',CommRecvStr[CP])>0) or (Pos('NO CARRIER',CommRecvStr[CP])>0) then
                                CommStatus[CP] := Cs_WaitRing;
                         End;
                   End;
                   CommRecvStr[Cp] := '';
                End;
                Else
                 CommRecvStr[Cp] := CommRecvStr[Cp] + Data[i];
              End;
      End;

  FreeMem(Data,Size+1);


end;


procedure TMainForm.Button9Click(Sender: TObject);
begin

 If  CommStatus[0] = Cs_WaitRing then
   CommStatus[0] := Cs_OpenDirect;

end;



procedure TMainForm.WWWServerData(Sender: TObject; Socket: Integer);
Begin
   WWWReceive(Sender,Socket);
end;

procedure TMainForm.SpeedButton3Click(Sender: TObject);
begin

  with WWWServer do
    begin

     Port := WWWPortNo.Text;

     If SocketState = ssListening then
      Begin
         Close;
      End
      Else
       Open;

      SpeedButton3.Down := (SocketState = ssListening);
      SpeedButton3.Refresh;
      if SocketState = ssListening then
        begin
          WWWStatus.Lines.Clear;
          WWWSTSAdd(LocalHostAddress+' �ڑ���ҋ@���܂��B �|�[�g: '+Port);
        end;
    end;

end;
var i : integer;

procedure TMainForm.FormShow(Sender: TObject);
begin

  // WWWServer.OnData :=WWWReceive;

end;

(*****************************************************************************)
(****************************** MTIDS ****************************************)
(*****************************************************************************)

Type
  TIDList = Array [0..99] of string[8];


Procedure MTIDSSendData(Socket : Integer;Data : Pchar;Size : Integer);
var
    i,j : integer;
Begin
   For i := 0 to 99 do
    if MTIDSSendDataBuf[i].Socket = 0 then
      Begin
        MTIDSSendDataBuf[i].Socket := Socket;
        GetMem(MTIDSSendDataBuf[i].Data,Size);
        For j := 0 to Size do MTIDSSendDataBuf[i].Data[j] := Data[j];
        MTIDSSendDataBuf[i].Size   := Size;
        MTIDSSendDataBuf[i].Rp     := 0;
        Break;
      End;
End;


procedure TMainForm.SendData(SendPacket: Pointer);
var
      i : integer;
      Mes : TMTIDSMessage;
Begin

     if TPacketRecord(SendPacket^).ToHost = '' then
        TPacketRecord(SendPacket^).ToHost := GeneralDefine.MTIDS.HostName;

     if TPacketRecord(SendPacket^).ToHost = GeneralDefine.MTIDS.HostName then
      Begin
         i := MTIDS_IdToIndex(TPacketRecord(Sendpacket^).ToID);
          if i>-1 then
          Begin
           MTIDSServer.WriteBuffer(
                                   MTIDSClientDataBase[i].Socket
                                  ,SendPacket
                                  ,TPacketRecord(Sendpacket^).PacketSize
                                  );
          End
          else
           Begin
            if TPacketRecord(SendPacket^).buf[2] = '2' then
             With TUserPacketRecord(SendPacket^) do
               If (DataType = 0) or (DataType = 1) then      //DataType 0 -> 1
                  Begin
                       if SearchUser(ToID)>-1 then
                        Begin
                           Mes.ToID       := ToID;
                           Mes.DateTime   := Now;
                           Mes.From       := From;
                           Mes.Info       := Info;
                           Mes.DataType   := DataType;
                           Mes.Mes        := String(Data);
                         if MTIDS_AddSleepMessage(Mes)<0 then
                            SendSystemMessage(SendPacket,From.Host,From.ID,ToHost+':'+ToID+':���b�Z�[�W��ۑ��ł��܂���(['+ToHost+']�Ǘ��҂ɖ₢���킹��������)')
                         else
                            SendSystemMessage(SendPacket,From.Host,From.ID,ToHost+':'+ToID+'���̃��b�Z�[�W��ۑ����܂���')
                        End
                       else
                        Begin
                         if ToID = '!SYSTEM' then
                             SendSystemMessage(SendPacket,From.Host,From.ID,OkotobaStrs[Random(OkotobaStrs.Count)])
                         Else
                             SendSystemMessage(SendPacket,From.Host,From.ID,'*** �f�[�^�]���G���[ ***'#13#10+ToHost+':'+ToID+'�͑��݂��Ȃ����[�U�[�ł���.');
                        End;
                  End
                  Else
                     MTIDSStsAdd('err...send system data From:'+From.Host);
           End;
      End
     Else
      Begin
       If TPacketRecord(SendPacket^).buf[2]='2' then   //UserToUserPacket
          SendSystemMessage(SendPacket,TUserPacketRecord(SendPacket^).From.Host
                                      ,TUserPacketRecord(SendPacket^).From.ID
                                ,'*** �f�[�^�]���G���[ ***'#13#10'Unknown host :'+TUserPacketRecord(SendPacket^).ToHost);
         //�]�������E�E�E�E
      End;


End;

procedure TMainForm.SendSystemMessage(buf : Pointer;ToHost,ToID : String;mes : String);
Begin
            TUserPacketRecord(buf^).Buf[0]     := 'M';
            TUserPacketRecord(buf^).buf[1]     := 'T';
            TUserPacketRecord(buf^).buf[2]     := '2';
            TUserPacketRecord(buf^).From.ID     := '!SYSTEM';
            TUserPacketRecord(buf^).From.Host   := GeneralDefine.MTIDS.HostName;
            TUserPacketRecord(buf^).From.Handle := '<<MTQ SYSTEM>>';
            TUserPacketRecord(buf^).From.EMail  := '';
            TUserPacketRecord(buf^).ToID       := ToID;
            TUserPacketRecord(buf^).ToHost     := ToHost;
            TUserPacketRecord(buf^).DataType   := 0;
            TUserPacketRecord(buf^).DateTime   := Now;
            StrCopy(TUserPacketRecord(buf^).Data,pchar(mes));
            TUserPacketRecord(buf^).Data[Length(mes)] := #0;
            TUserPacketRecord(buf^).PacketSize := SizeOf(TUserPacketRecord)
            - UserPacketRecordDataMaxSize + Length(mes) + 1;
            SendData(Buf);
End;

Procedure TMainForm.SendContactUsersStatus(ToHost : String;IDList : Pointer;IdListCount : Integer;ID : String
   ;Host : String;OnLine : Boolean;UserInfo : TMTQUserInfo);
var
   i,j,k           : integer;
   SystemPacket    : TSystemPacketRecord;
   UsersStatusData : ^TMTQUsersDataRecord;
Begin

   UsersStatusData := @SystemPacket.data;

   If GeneralDefine.MTIDS.HostName <> ToHost then exit; //�]��


         SystemPacket.Buf[0] := 'M';
         SystemPacket.Buf[1] := 'T';
         SystemPacket.buf[2] := '3';
         SystemPacket.FromHost := GeneralDefine.MTIDS.HostName;

         if OnLine then
              Begin
                (*�R���^�N�g���X�g�ɓ��ꂽ�l�����̏���Host:ID�ɂ�����*)
                  SystemPacket.ToHost := Host;
                  SystemPacket.ToID   := ID;

                  UsersStatusData.Count  := IDListCount;
                     for i:=0 to IDListCount-1 do
                      Begin
                        UsersStatusData^.Data[i].ID      := TIDList(IDList^)[i];
                        UsersStatusData^.Data[i].Status  := [];
                          for j:=0 to 99 do
                            if MTIDSClientDatabase[j].ID = TIDList(IDList^)[i] then
                             Begin
                                UsersStatusData^.Data[i].Status     := [US_ONLINE];
                                UsersStatusData^.Data[i].Info       := MTIDSClientDatabase[j].info;
                      //        UsersStatusData^.Data[i].Info.InAddr:= ;  InAddr������
                                for k:=0 to MTIDSClientDatabase[j].ContactListCount-1 do
                                   if (MTIDSClientDatabase[j].ContactList[k].Host = Host) and (MTIDSClientDatabase[j].ContactList[k].ID = ID) then
                                    Begin
                                       UsersStatusData^.Data[i].Status  := [US_ONLINE,US_CONTACT];
                                       Break;
                                    End;
                                 if (    (US_CONTACT in UsersStatusData^.Data[i].Status)    //�����ؽĂɓ����Ă���
                                       or(UI_OPEN_IP in UsersStatusData^.Data[i].info.LoginMode)
                                    ) and(UI_SERVER  in UsersStatusData^.Data[i].info.LoginMode)
                                  then
                                     UsersStatusData^.Data[i].info.InAddr  := MTIDSClientDatabase[j].info.InAddr;
                                break;
                            End;

                      End;
                  SystemPacket.PacketSize := SizeOf(TSystemPacketRecord) - 1024 +4+SizeOf(TMTQUserData)*IDListCount;
                  MainForm.SendData(@SystemPacket);
              End;

         (*�����̂h�c���R���^�N�g���X�g�ɓ���Ă���l����ToHost:@@@@�Ɏ����̏�Ԃ𑗂�*)

             SystemPacket.ToHost              := ToHost;
             UsersStatusData^.Count           := 1;
             UsersStatusData^.Data[0].ID      := ID;

             if Online then
               Begin
                UsersStatusData^.Data[0].Status   := [US_CONTACT,US_ONLINE];
                UsersStatusData^.Data[0].info     := UserInfo;
               // if not(UI_SERVER in UserInfo.LoginMode) then
                //  UsersStatusData^.Data[0].InAddr   := 0;
               End
             else
                UsersStatusData^.Data[0].Status  := [];

             SystemPacket.PacketSize := SizeOf(TSystemPacketRecord) - 1024 +SizeOf(TMTQUserData)*1;

             for i:=0 to IDListCount-1 do
              for j:=0 to 99 do
                 if MTIDSClientDatabase[j].ID = TIDList(IDList^)[i] then
                    for k:=0 to MTIDSClientDatabase[j].ContactListCount-1 do
                       if (MTIDSClientDatabase[j].ContactList[k].Host = Host) and (MTIDSClientDatabase[j].ContactList[k].ID = ID) then
                          Begin
                             SystemPacket.ToID   := TIDList(IDList^)[i];
                             MainForm.SendData(@SystemPacket);
                          End;

End;


Procedure TMainForm.SendMyStatusToContactUsersAndGetUsersStatus(Index : Integer;OnLine : Boolean);
Var
   IDList : TIDList;
   IDListCount : Integer;
   i : integer;
Begin

   IDListCount := 0;
   With MTIDSClientDataBase[Index] do
     If  ContactListCount = 0 then
                           SendContactUsersStatus(GeneralDefine.MTIDS.HostName
                                           ,nil
                                           ,0
                                           ,ID
                                           ,GeneralDefine.MTIDS.HostName
                                           ,Online
                                           ,Info)
    else
     Begin
       For i:=0 to ContactListCount-1 do
           Begin
               IDList[IDListCount] := ContactList[i].ID;
               Inc(IDListCount);
               If (i = ContactListCount-1) or (ContactList[i+1].Host <> ContactList[i].Host) then
                 Begin
                     SendContactUsersStatus(ContactList[i].Host
                                           ,@IDList
                                           ,IdListCount
                                           ,ID
                                           ,GeneralDefine.MTIDS.HostName
                                           ,Online
                                           ,info);
                     IDListCount := 0;
                   End;
           End;
     End;



End;


procedure TMainForm.MTIDSServerData(Sender: TObject; Socket: Integer);
var
   Buf             : Pchar;
   Size            : Integer;
   rp : integer;
Begin

     GetMem(Buf,1024+1);
      Rp := 0;
      Size := MTIDSServer.ReadBuffer(Socket,Buf,1024);
        While Rp<Size do
          if (buf[Rp+00]='M') and  (buf[Rp+01]='T') then
            Begin
              if (buf[Rp+02]='0')  then
               Begin
                DecodeReceiveData(@Buf[Rp],Socket,size); //���O�C���f�[�^�[
                break;
               end
              else
               Begin
                 if TPacketRecord((@buf[rp])^).PacketSize < 10 then Break;     //�s���p�P�b�g�Ւf
                 if TPacketRecord((@buf[rp])^).PacketSize+rp > 1024 then Break;//�s���p�P�b�g�Ւf
                 DecodeReceiveData(@Buf[Rp],Socket,TPacketRecord((@buf[rp])^).PacketSize);
                 Rp := Rp + TPacketRecord((@buf[rp])^).PacketSize;
               End;
            End
           else
            break;

     FreeMem(Buf,1024+1);

End;


procedure TMainForm.DecodeReceiveData(Buf: Pointer;Socket_ : Integer;size : integer);
Var

   i,j,k,l    : Integer;
   UI         : TUserInit;
   MCD        : TMTIDSClientData;

   UserID : String[8];

   s      : string;
   HostListCount,rp : integer;
   IDListCount : Integer;
   IDList : TIDList;

   Function getbuf(m,n : integer):string;
   var  i : integer;
   begin
        Result := '';
        if m+n > Size then exit;
        for i:=m to m+n-1 do
          if (pchar(buf)[i]=#0) or (pchar(buf)[i]=' ') then break
                       else result := result + pchar(buf)[i];
   end;

   procedure putbuf(s : string;m,n : integer);
   var  i : integer;
   begin
        for i:=1 to Length(s) do
          if i>n then break
                 else pchar(buf)[m+i-1] := s[i];
        if length(s)<n then
           pchar(buf)[m+n] := #0;
   end;


   Procedure SendSystemMessageLocal(mes : String);
   var
      i : Integer;

   Begin
       With TUserPacketRecord(buf^) do
          Begin
            Buf[0]     := 'M';
            buf[1]     := 'T';
            buf[2]     := '2';
            From.ID     := '!SYSTEM';
            From.Host   := GeneralDefine.MTIDS.HostName;
            From.Handle := '<<MTQ SYSTEM>>';
            From.EMail  := '';
            ToID       := UserID;
            ToHost     := GeneralDefine.MTIDS.HostName;
            DataType   := 0;
            DateTime   := Now;
            StrCopy(Data,pchar(mes));
            Data[Length(mes)] := #0;
            PacketSize := SizeOf(TUserPacketRecord)-UserPacketRecordDataMaxSize  + Length(mes) + 1;
            MTIDSServer.WriteBuffer(
                                   Socket_
                                  ,@Buf[0]
                                  ,PacketSize
                                  );
          End;
   End;

   Procedure SendSleepMessages;
   Var
       i : Integer;
   Begin
       i := -1;
       while true do
        Begin
           i := MTIDS_SearchSleepMessage(UserID,i+1);
           if i<0 then break;

           With TUserPacketRecord((Pointer(buf))^) do
            Begin
                  Buf[0]     :='M';
                  Buf[1]     :='T';
                  Buf[2]     :='2';
                  ToHost     := GeneralDefine.MTIDS.HostName;
                  ToID       := SleepMessages[i].ToID;
                  From       := SleepMessages[i].From;
                  info       := SleepMessages[i].info;
                  DataType   := SleepMessages[i].DataType;
                  DateTime   := SleepMessages[i].DateTIme;
                  StrCopy(Data,Pchar(SleepMessages[i].mes));
                  Data[Length(SleepMessages[i].mes)] := #0;
                  PacketSize := SizeOf(TUserPacketRecord) - UserPacketRecordDataMaxSize
                   + Length(SleepMessages[i].mes) + 1;
                  MTIDSSendData(
                         Socket_
                        ,@Buf[0]
                        ,PacketSize
                        );
                  SleepMessages[i].ToID := '';
            End;
        end;
   End;

begin//procedure TMainForm.MTIDSServerData(Sender: TObject; Socket_: Integer);


        case pchar(buf)[2] of
             '0' : With TLoginPacketRecord(buf^) do // add data base
                    Begin

                       MCD.ID :=  ID;
                       UserID := ID;
                        UI := GetUserInit(ID);

                       if UI.Password = Password then
                       begin
                          if Handle = '' then
                              MCD.Handle := UI.Handle
                          else
                              MCD.Handle := Handle;

                           MCD.Info    := Info;
                           //21-29 dummy
                           MCD.ContactListCount := ConatctUsersCount;

                           if (ConatctUsersCount > 39)  then
                            Begin
                              SendSystemMessageLocal('*** LOGIN ERROR *** err01'#13#10);
                              exit;
                            End;

                           For i:=0 to ConatctUsersCount-1 do
                             MCD.ContactList[i] := ContactUsers[i];

                            MCD.Socket      := Socket_;
                            MCD.info.InAddr := MTIDSServer.PeerToInAddr(Socket_);
                            MCD.LoginTime   := Now;

                           i:=MTIDS_Add(MCD);
                           if i>-1 then
                            Begin
                             SendMyStatusToContactUsersAndGetUsersStatus(i,true);
                             MTIDSStsAdd('�f�[�^�x�[�X�o�^ :'+UserID+' '
                             +inet_ntoa(MCD.info.InAddr)+' / '+IntToStr(Socket_));
                             SendSleepMessages;
                            End;
                        End
                       Else
                        Begin
                          SendSystemMessageLocal(MyoHostVer+#13#10+GeneralDefine.MTIDS.HostName+'>***LOGIN ERROR ***'#13#10'ID�܂��̓p�X���[�h���������Ȃ�');
                          MTIDSServer.Disconnect(Socket_);
                        End;
                    End;
             '1' : Begin
                        i := MTIDS_IdToIndex(getbuf(3,8));
                        If i>-1 then
                         if Socket_ = MTIDSClientDataBase[i].Socket then
                            MTIDSClientDataBase[i].ID := '';   //del
                   End;
          //--- �]��---
             '2' : Begin    // 3->11:FromID 12->19:Fromhost(WriteByHost) 20->27:ToID 27->34:ToHost 35:MessageType 36:
                        i      := MTIDS_IdToIndex(TUserPacketRecord(buf^).From.ID);
                        UserID := TUserPacketRecord(buf^).From.ID;
                        If (i>-1) then
                           Begin
                               if Socket_ = MTIDSClientDataBase[i].Socket then
                                 Begin
                                   TUserPacketRecord(buf^).From.Host  := GeneralDefine.MTIDS.HostName;
                                   TUserPacketRecord(buf^).From.ID    := MTIDSClientDataBase[i].ID;
                                   TUserPacketRecord(buf^).info       := MTIDSClientDataBase[i].info;
                                   TUserPacketRecord(buf^).DateTime   := Now;
                                   SendData(buf);
                                 End;
                             End;
                   End;
             '3' : Begin //System -> System
                   End;
        End;

end;


procedure TMainForm.SpeedButton4Click(Sender: TObject);
begin
  with MTIDSServer do
    begin

     Port := MTIDSPortNo.Text;

     If SocketState = ssListening then
      Begin
         Close;
      End
      Else
       Open;

      SpeedButton4.Down := (SocketState = ssListening);
      SpeedButton4.Refresh;
      if SocketState = ssListening then
        begin
          MTIDSStatus.Lines.Clear;
          MTIDSSTSAdd(LocalHostAddress+' �ڑ���ҋ@���܂��B �|�[�g: '+Port);
        end;
    end;
end;

procedure TMainForm.Button12Click(Sender: TObject);
begin
     ReLoadAssignUsers;
end;

procedure TMainForm.MTIDSServerClose(Sender: TObject; Socket: Integer);
var
   Idx,i,j : Integer;
   delid : String[8];
begin


    for idx := 0 to 99 do
      if MTIDSClientDataBase[idx].Socket = Socket then
       if (MTIDSClientDataBase[idx].Id <> '') then
        With MTIDSClientDataBase[idx] do
          Begin
             delid := id;
             SendMyStatusToContactUsersAndGetUsersStatus(idx,false);
             MTIDSStsAdd('�f�[�^�x�[�X�폜 :'+ID);
             Id := '';
             Break;
          End;

end;

procedure TMainForm.Button11Click(Sender: TObject);
var
  a : String[9];
begin

     if ListBox2.ItemIndex>-1 then
      Begin
        a := Copy(ListBox2.Items[ListBox2.ItemIndex],1,9);
        a := Copy(a,1,Pos(' ',a)-1);
       If SearchUser(a) > -1 then
         Begin
            User.UserInit := GetUserInit(a);
            User.ShowModal;
         End;
      End;
end;

procedure TMainForm.Button10Click(Sender: TObject);
var
   a  : String[9];
   mes : string;
   i : integer;
   Buf : Pointer;
begin

     if ListBox2.ItemIndex>-1 then
      Begin
        a := Copy(ListBox2.Items[ListBox2.ItemIndex],1,9);
        a := Copy(a,1,Pos(' ',a)-1);
        i := MTIDS_IDtoIndex(a);
        If i > -1 then
         Begin
            mes := InputBox('�V�X�e�����b�Z�[�W�̑��M', '���b�Z�[�W����͂��Ă�������', '');
            If mes <>'' then
            Begin
             GetMem(Buf,1024);
              SendSystemMessage(buf,'',a,mes);
             FreeMem(Buf,1024);
            End;
        End;
      End;

end;

procedure TMainForm.SpeedButton5Click(Sender: TObject);
begin

   If SpeedButton5.down then
    Begin
     SpeedButton5.Down := false;
     FtpServer1.MaxClients := StrToIntDef(FtpMaxClients.text,0);
     FtpServer1.Start;
    End
   else
     FtpServer1.Stop;


end;

procedure TMainForm.Button14Click(Sender: TObject);
begin

     ShellExecute(Application.Handle,'open',Pchar('ftp://127.0.0.1:'+FtpPort.text+'/'),nil,'.',SW_SHOWNORMAL);
end;

procedure TMainForm.FtpServer1Start(Sender: TObject);
begin
   SpeedButton5.Down := true;

end;

procedure TMainForm.FtpServer1Stop(Sender: TObject);
begin
   SpeedButton5.Down := false;

end;

procedure TMainForm.Button15Click(Sender: TObject);
begin
     ShellExecute(Application.Handle,'open',Pchar('http://127.0.0.1:'+WWWPortNo.text+'/'),nil,'.',SW_SHOWNORMAL);

end;

Initialization;
Begin
   for i:=0 to 9 do
     Begin
      WWWUsers[i].Enabled := false;
      WWWUsers[i].Telegrams := TStringList.Create;
     End;

   MailSystem   := TMailSystem.Create;
   MessageBoard := TMessageboard.Create;

End;
Finalization
Begin
   for i:=0 to 9 do
     Begin
      WWWUsers[i].Telegrams.Free;
     End;
   MailSystem.Free;
   MessageBoard.Free;

End;

end.                                                                1