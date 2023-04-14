unit BoardClient;


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Wsockets,Comm,MyoComm;


Type
  TAttribute = Record
       New          : Boolean;
       NoRead       : Boolean;
       Search       : Boolean;
       Marked       : Boolean;
  End;

  TBoardMessage = Record
       BoardTitle   : String;
       No           : Integer;       // = 0 の時は無効とする
       IndexPos     : Integer;
       FilePos      : Integer;
       Size         : Integer;
       FromName     : String[24];
       FromEMail    : String[30];
       DateTime     : TDateTime;
       Title        : String[60];
       Text         : String;
       Attribute    : TAttribute;
  End;

  TMtbbsClientStatus     = (CS_Closed,CS_Login,CS_None,CS_SendTelegram,CS_WriteMessage,CS_WriteMail,Cs_Idle);

  TMtOnReceive             = procedure (Sender: TObject;s : String)           of object;
  TMtOnReceiveLine         = procedure (Sender: TObject;s : String)           of object;
  TMtOnReceiveTelegram     = procedure (Sender: TObject; From,Mes : String)   of object;
  TMtOnReceiveMessage      = procedure (Sender: TObject; Mes : TMtbbsMessage) of object;
  TMtOnGetMessageBoard     = procedure (Sender: TObject; BoardNo : Integer;BoardName,BoardTitle : String) of object;
  TMtOnGetMainPrompt       = procedure (Sender: TObject)                of object;
  TMtOnLogin               = procedure (Sender: TObject; LogInMes : String)   of object;
  TMtOnLogOut              = procedure (Sender: TObject; LogOutMes : String)  of object;
  TMtOnStatusOut           = procedure (Sender: TObject;Status : String)of object;
  TMtOnConnect             = procedure (Sender: TObject)                of object;
  TMtOnDisConnect          = procedure (Sender: TObject)                of object;
  TMtOnError               = procedure (Sender: TObject;ErrMes : String)of object;
  TMtOnReceiveChatLine     = procedure (Sender: TObject;Ch : Integer;HandleName,Mes : String;IsNextChatLine : Boolean) of object;
  TMtOnReceiveLoginUsers   = procedure (Sender: TObject;LoginUsers : String) of object;
  TMtOnExecuteWriteMessage = procedure (Sender: TObject;tag : Integer) of object;
  TMtOnReceiveUsers        = procedure (Sender: TObject;Users : String) of object;

  TMtbbsClient = class(TComponent)
  private

     CommMode       : TCommMode;

     PS1,PS2,PS3,PS4      : String;
     PI1,PI2,PI3,PI4      : Integer;

     TerminateWhenClose : Boolean;

     TCP : TTcpClient;
     LogF : TextFile;

     FMyCh  : Integer;
     FLogFileName : String;
     FMakeLogFile : Boolean;
     FHostKind    : THostKind;

     FCommPort  : Integer;
     FCommRate  : Integer;
     FModemInitCommand : String;
     FModemDialCommand : String;

     IsLogFileOpen : Boolean;

     ReadMode : (RM_None,RM_IAC1,RM_IAC2);

     SendThread  : TObject;
     WorkThread  : TObject;

     Status : TMtbbsClientStatus;

     FUserID   : String;
     FPassword : String;
     FHandleName : String;
     FGetTelegram       : Boolean;
     FGetMessage        : Boolean;
     FGetMail           : Boolean;
     FStealthLogin      : Boolean;
     FAutoReceiveMail   : Boolean;
     FAddress           : String;

     FOnReceive               : TMtOnReceive;
     FOnReceiveLog            : TMtOnReceive;
     FOnReceiveFreePost       : TMtOnReceive;
     FOnReceiveLine           : TMtOnReceiveLine;
     FOnReceiveTelegram       : TMtOnReceiveTelegram;
     FOnReceiveMessage        : TMtOnReceiveMessage;
     FOnGetMessageBoard       : TMtOnGetMessageBoard;
     FOnGetMainPrompt         : TMtOnGetMainPrompt;
     FOnReceiveMail           : TMtOnReceiveMessage;
     FOnReceiveChatLine       : TMtOnReceiveChatLine;
     FOnReceiveLoginUsers     : TMtOnReceiveLoginUsers;
     FOnLogin                 : TMtOnLogin;
     FOnLogOut                : TMtOnLogOut;
     FOnStatusOut             : TMtOnStatusOut;
     FOnConnect               : TMtOnConnect;
     FOnDisConnect            : TMtOnDisConnect;
     FOnExecuteWriteMessage   : TMtOnExecuteWriteMessage;
     FOnReceiveUsers          : TMtOnReceiveUsers;

     procedure TCPError(Sender: TObject; Error: Integer; Msg: String);
     procedure TCPData(Sender: TObject; Socket: Integer);
     procedure TCPClose(Sender: TObject; Socket: Integer);
     procedure CommReceive(Sender: TObject; Size: Word);
     procedure CommEvent(Sender: TObject;EventMask: TCommEventMask);
     procedure ReceiveText(Buf : Pchar;Size: Integer);

  protected

  public

    P1,P2,P3,P4 : Pointer;

     Rp,Wp  : Integer;
     RecvBuf  : Array [0..999] of String;
     Comm : TMyoComm;

    property MyCh   : Integer Read  FMyCh;
    Procedure Login;
    Procedure Logout;
    Procedure Sendln(S : String);
    Procedure Puts(s : String);
    Procedure SendTelegram(ToCh,S : String);

    Procedure WriteMessage(Board,Title,Text : String;tag : Integer);
    Procedure WriteMail(Ids,Title,Text : String;tag : Integer);

    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;

  published

    property HostKind   : THostKind Read  FHostKind
                                  write   FHostKind default hk_mtbbs;
    property ModemInitCommand   : String Read  FModemInitCommand
                                         write  FModemInitCommand;
    property ModemDialCommand   : String Read  FModemDialCommand
                                         write  FModemDialCommand;

    property CommPort   : Integer Read  FCommPort
                                  write FCommPort default 1;
    property CommRate   : Integer Read  FCommRate
                                  write FCommRate default 9600;

    property MakeLogFile   : Boolean Read  FMakeLogFile
                                     write FMakeLogFile default False;

    property LogFileName   : String Read  FLogFileName
                                    write FLogFileName;

    property UserID   : String Read  FUserID
                                   write  FUserID;
    property Password : String Read  FPassword
                                   write  FPassword;
    property HandleName : String Read  FHandleName
                                write  FHandleName;
    property Address : String read FAddress write FAddress;

// メインスレッドと非同期
    property OnReceive : TMtOnReceive read FOnReceive
                                      write FOnReceive;
// メインスレッドと同期
    property OnConnect : TMtOnConnect read  FOnConnect
                                      write FOnConnect;
    property OnDisConnect : TMtOnDisConnect read  FOnDisConnect
                                      write FOnDisConnect;

    property OnLogin : TMtOnLogin read FOnLogin
                                  write FOnLogin;
    property OnLogout : TMtOnLogout read FOnLogOut
                                      write FOnLogOut;
    property OnReceiveLine : TMtOnReceiveLine read FOnReceiveLine
                                      write FOnReceiveLine;

    property OnReceiveFreePost : TMtOnReceive read FOnReceiveFreePost
                                              write FOnReceiveFreePost;
    property OnReceiveLog : TMtOnReceive read FOnReceiveLog
                                              write FOnReceiveLog;

    property OnReceiveTelegram : TMtOnReceiveTelegram read FOnReceiveTelegram
                                                    write FOnReceiveTelegram;
    property OnReceiveMessage : TMtOnReceiveMessage read FOnReceiveMessage
                                                    write FOnReceiveMessage;
    property OnGetMessageBoard : TMtOnGetMessageBoard read FOnGetMessageBoard
                                                    write FOnGetMessageBoard;
    property OnGetMainPrompt : TMtOnGetMainPrompt read FOnGetMainPrompt
                                                    write FOnGetMainPrompt;
    property OnReceiveMail : TMtOnReceiveMessage read FOnReceiveMail
                                                    write FOnReceiveMail;
    property OnReceiveChatLine : TMtOnReceiveChatLine read FOnReceiveChatLine
                                                    write FOnReceiveChatLine;
    property OnReceiveLoginUsers : TMtOnReceiveLoginUsers read FOnReceiveLoginUsers
                                                    write FOnReceiveLoginUsers;

    property OnStatusOut : TMtOnStatusOut read FOnStatusOut
                                         write FOnStatusOut;

    property OnExecuteWriteMessage : TMtOnExecuteWriteMessage read FOnExecuteWriteMessage
                                                             write FOnExecuteWriteMessage;

    property OnReceiveUsers : TMtOnReceiveUsers read FOnReceiveUsers
                                               write FOnReceiveUsers;

    property GetTelegram : Boolean Read  FGetTelegram
                                   write FGetTelegram default True;
    property GetMessage  : Boolean Read  FGetMessage
                                   write FGetMessage default True;
    property GetMail     : Boolean Read  FGetMail
                                   write FGetMail default True;
    property StealthLogin : Boolean Read  FStealthLogin
                                   write FStealthLogin default False;
    property AutoReceiveMail : Boolean Read FAutoReceiveMail
                                      write FAutoReceiveMail default False;


  end;

  TWorkThread = class(TThread)
  private

    _ : TMtbbsClient;

    P1,P2,P3,P4 : Pointer;

//    AutoDeleteMail : Boolean;

    Procedure OnLogin;
    Procedure OnLogout;
    Procedure OnReceive;
    Procedure OnReceiveLine;
    Procedure OnReceiveMessage;
    Procedure OnReceiveMail;
    Procedure OnReceiveTelegram;
    Procedure OnReceiveChatLine;
    Procedure OnReceiveLoginUsers;
    Procedure OnReceiveFreePost;
    Procedure OnReceiveLog;
    Procedure OnStatusOut;
    Procedure OnGetMessageBoard;
    Procedure OnGetMainPrompt;
    Procedure OnExecuteWriteMessage;
    Procedure OnReceiveUsers;

    Function Recvln:String;
    Function Recvln_:String;
    Procedure ReadTelegram;
    Procedure ReadMessage(a : String);
    Procedure ReadMail(a : String;AutoDeleteMail : boolean);
    Procedure ReadChatLine(a : String);
    Procedure ReadWho;
    Procedure ReadUsers;
    Procedure ReadLog;
    procedure Login;
    Procedure Wait(S : String);
    Function WaitStrs(Const StringS : Array of String) : Integer;
    Procedure Sts(s: String);
    Procedure Sendln(S : String);
    Procedure Puts(s : String);
    Function IsReceived : Boolean;
    Procedure SendTelegram;
    Procedure EnterMessage;
    Procedure EnterMail;
    Function ReadBufLines(StartRp,EndRp : Integer):String;
    Function ReadBackToMainPrompt(Start,Max : Integer):String;

  protected

    procedure Execute; override;

  public

    constructor Create(AOwner : TComponent);
    destructor  Destroy; override;

  published
  end;

  TSendThread = class(TThread)
  private
     _ : TMtbbsClient;
  protected
    procedure Execute; override;
  public

    SRp,SWp  : Integer;
    SendBuf  : Array[0..2000] of Char;

    constructor Create(AOwner : TComponent);
    destructor  Destroy; override;

    Procedure Write(Buf : PChar;Size : Integer);


  published
    { Published 宣言 }
  end;


procedure Register;

implementation

uses MVCL;


procedure Register;
begin

  RegisterComponents('MYO', [TMtbbsClient]);

end;


constructor TMtbbsClient.Create(AOwner: TComponent);
Var
  i,j : Integer;
begin

  inherited Create(AOwner);

  Status := CS_Closed;

  TCP  := TTcpClient.Create(Self);
  Comm := TMyoComm.Create(Self);

  With TCP do
   Begin
     OnData  := TCPData;
     OnError := TCPError;
     OnClose := TCPClose;
   End;
  With Comm do
   Begin
     OnCommReceive := CommReceive;
     OnCommEvent   := CommEvent;
     SendNotifySize := 2048;
     EventMask := [evRlsd];
   End;

     FGetTelegram  := True;
     FGetMessage   := True;
     FGetMail      := True;
     FStealthLogin    := False;
     FAutoReceiveMail := False;
     FMakeLogFile := False;
     FHostKind    := hk_mtbbs;
     FModemDialCommand := 'ATD';

     FCommPort  := 1;
     FCommRate  := 9600;

    For i := 1 to 43 do
    Begin
       For j := 0 to 10 do
         RecvBuf[i*20+j] := Copy('                                            ',1,j+1)
             + 'MTBBS MTBBS  MTBBS MTBBS'
             +Copy('                                                                 ',1,20-j*2+1)
             +' MTBBS MTBBS  MTBBS MTBBS';
       For j := 0 to 10 do
         RecvBuf[i*20+j+10] := Copy('                                            ',1,11-j)
             + 'MTBBS MTBBS  MTBBS MTBBS'
             +Copy('                                                                ',1,j*2+1)
             +' MTBBS MTBBS  MTBBS MTBBS';
    End;

end;

destructor TMtbbsClient.Destroy;
begin

  If Assigned(TCP) then TCP.Free;

  inherited Destroy;

end;

Procedure TMtbbsClient.SendTelegram(ToCh,S : String);
Begin

   PS1 := Toch;
   PS2 := s;
   Status := CS_SendTelegram;

End;

Procedure TMtbbsClient.WriteMessage(Board,Title,Text : String;tag : Integer);
Begin

   PS1 := Board;
   PS2 := Title;
   PS3 := Text;
   PI1 := tag;
   Status := CS_WriteMessage;

End;

Procedure TMtbbsClient.WriteMail(Ids,Title,Text : String;tag : Integer);
Begin

   PS1 := Ids;
   PS2 := Title;
   PS3 := Text;
   PI1 := tag;
   Status := CS_WriteMail;

End;



procedure TMtbbsClient.TCPData(Sender: TObject; Socket: Integer);
Var
   Buf  : PChar;
   Size : Integer;
begin

  GetMem(Buf,1024+2);
    Size := TCP.ReadBuffer(Buf,1024);
    ReceiveText(Buf,Size);
  FreeMem(Buf,1024+2);

end;

procedure TMtbbsClient.CommReceive(Sender: TObject; Size: Word);
Var
  Data    : PChar;
begin

  GetMem(Data,Size + 1);
    Comm.Read(Data, Size);
    ReceiveText(Data,Size);
  FreeMem(Data,Size+1);

End;

procedure TMtbbsClient.ReceiveText(Buf : Pchar;Size: Integer);
Var
   i,k  : Integer;
   s    : String;
begin

          S := RecvBuf[Wp];
          For i:=0 to Size-1 Do
          Begin
            Case ReadMode of
              RM_None :
                If ( (buf[i] < #32) or (buf[i] = #255)) then
                   Begin

                     If buf[i]=#255 then
                       ReadMode := RM_IAC1;

                     If buf[i]=#9 then
                      Begin
                        k := Length(S) mod 8;
                        if k = 0 then k := 8;
                         s := s + Copy('        ',1,k);
                      End;

                     If Buf[i]=#8 then
                      Begin
                        k := Length(s);
                        If k > 0 then
                           If  K > 1 then
                             Begin
                              If IsDBCSLeadByte(Byte(S[K-1])) then
                                Begin
                                  S       := Copy(S,1,k-2);
                                End Else
                                Begin     //
                                  S       := Copy(S,1,k-1);
                                End;
                             End Else
                             Begin  //↑同じのが二つ重なって汚いけどまぁいいか^^;
                               S       := Copy(S,1,k-1);
                             End;
                      End;

                     If Buf[i]=#13 then
                      Begin
                       RecvBuf[Wp] := S;
                       Inc(Wp);
                       If Wp > High(RecvBuf) then
                          Wp := 0;
                       RecvBuf[Wp] := '';
                       S := '';
                      End;

                   End
                   Else
                     s       := s       + buf[i];

              RM_IAC1 : ReadMode := RM_IAC2;
              RM_IAC2 : ReadMode := RM_None;

            End;
          End;
          RecvBuf[Wp] := S;

    Buf[Size] := #0;
    FOnReceive(self,Pchar(Buf));


end;

procedure TMtbbsClient.CommEvent(Sender: TObject;EventMask: TCommEventMask);
Begin

  If (evRlsd in EventMask  ) then
   Begin
     If (Not Comm.Rlsd) and TerminateWhenClose then
        Begin
          If Assigned(FOnStatusOut) then FOnStatusOut(self,'切断されました..');
          Logout;
        End;
   End;

End;


procedure TMtbbsClient.TCPError(Sender: TObject; Error: Integer; Msg: String);
begin

   If TerminateWhenClose then
     Begin
       If Assigned(FOnStatusOut) then FOnStatusOut(self,'接続エラーが発生しました..'+TCP.Host);
       Logout;
     End;
end;

procedure TMtbbsClient.TCPClose(Sender: TObject; Socket: Integer);
begin

   If TerminateWhenClose then
       Begin
           If Assigned(FOnStatusOut) then FOnStatusOut(self,'接続が切れました..'+TCP.Host);
           Logout;
       End;

end;

Function MakeLogFileName(Style:String):String;
var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
  j,n:Integer;
  b,c:String;
begin

  c:='';
  n:=0;

  DecodeDate(Now,Year, Month, Day);
  DecodeTime(Now,Hour,Min , Sec  , MSec);

   for j:=1 to length(Style) do
    begin
     b:=Style[j];
     if  n=0 then
      if b='%' then
        n:=1
       else
         c:=c+b
     else
      begin
       if b='Y' then c:=c+Format('%.2d',[Year-1900]);
       if b='y' then c:=c+Format('%.4d',[Year]);
       if b='M' then c:=c+Format('%.2d',[Month]);
       if b='D' then c:=c+Format('%.2d',[Day]);
       if b='H' then c:=c+Format('%.2d',[Hour]);
       if b='I' then c:=c+Format('%.2d',[Min]);
       n:=0;
      end;
    end;

    Result:=C;

end;

Procedure TMtbbsClient.Login;
Begin

   If (WorkThread = nil) and (SendThread = nil)  then
    Begin
      If Assigned(FOnConnect) then FOnConnect(self);
      SendThread  := TSendThread.Create(Self);
      WorkThread  := TWorkThread.Create(self);

      IsLogFileOpen := False;
      If FMakeLogFile then
       Try
         If FLogFileName='' then FLogFileName := MakeLogFileName('%y%M%D_%H%I.LOG');
         If Pos('\',FLogFileName)>0 then
            CreateDir(ExtractFilePath(FLogFileName))
         else
            FLogFileName := ExtractFilePath(Application.ExeName)+FLogFileName;
         AssignFile(LogF,FLogFileName);
         If FileExists(FLogFileName) then Append(LogF)
                           else Rewrite(LogF);

         IsLogFileOpen := True;
       Except
         IsLogFileOpen := False;
         FOnStatusOut(self,'ログファイルを作成できません');
       End;
    End
    Else
      If Assigned(FOnStatusOut) then FOnStatusOut(self,'すでに接続されています');

end;

Procedure TMtbbsClient.Puts(s : String);
Begin

     If SendThread <> nil then TSendThread(SendThread).Write(Pchar(s),Length(s));

End;

Procedure TMtbbsClient.Sendln(S : String);
Begin

  If SendThread <> nil then TSendThread(SendThread).Write(Pchar(s+#13#10),Length(s)+2);

End;

Procedure TMtbbsClient.Logout;
Begin

   If (WorkThread <> nil) and (SendThread <>nil) then
    Begin
      TerminateWhenClose := False;
      TWorkThread(WorkThread).Terminate;
      TSendThread(SendThread).Terminate;
      TCP.Close;
      Comm.Close;
      If Assigned(FOnDisConnect) then FOnDisConnect(Self);
      If IsLogFileOpen  then
      Begin
        CloseFile(LogF);
        IsLogFileOpen := False;
      End;
    End
    Else
      If Assigned(FOnStatusOut) then FOnStatusOut(self,'接続されていません');

end;

(*************************** 実行スレッド *********************************)

constructor TWorkThread.Create(AOwner : TComponent);
Begin

    inherited Create(True);                   // サスペンド状態で作成

    _ := TMtbbsClient(AOwner);
    Resume;

End;

destructor TWorkThread.Destroy;
Begin

    _.WorkThread := Nil;
    _.Status := CS_Closed;

    inherited;

End;

Procedure TWorkThread.OnLogin;
Begin
    _.FOnLogin(_,Pchar(P1^));
End;
Procedure TWorkThread.OnLogout;
Begin
    _.FOnLogout(_,Pchar(P1^));
End;
Procedure TWorkThread.OnReceive;
Begin
    if Assigned(_.FOnReceive) then  _.FOnReceive(_,Pchar(P1^));
End;
Procedure TWorkThread.OnReceiveLine;
Begin
    if Assigned(_.FOnReceiveLine) then  _.FOnReceiveLine(_,Pchar(P1^));
End;
Procedure TWorkThread.OnReceiveMessage;
Begin
    if Assigned(_.FOnReceiveMessage) then _.FOnReceiveMessage(_,TMtbbsMessage(P1^));
End;
Procedure TWorkThread.OnReceiveMail;
Begin
    if Assigned(_.FOnReceiveMail) then _.FOnReceiveMail(_,TMtbbsMessage(P1^));
End;
Procedure TWorkThread.OnReceiveTelegram;
Begin
    if Assigned(_.FOnReceiveTelegram) then _.FOnReceiveTelegram(_,Pchar(P1^),Pchar(P2^));
End;
Procedure TWorkThread.OnStatusOut;
Begin
    if Assigned(_.FOnStatusOut) then _.FOnStatusOut(_,Pchar(P1^));
End;
Procedure TWorkThread.OnReceiveChatLine;
Begin
    if Assigned(_.FOnReceiveChatLine) then _.FOnReceiveChatLine(_,Integer(P1^),Pchar(P2^),Pchar(P3^),Boolean(P4^));
End;
Procedure TWorkThread.OnReceiveLoginUsers;
Begin
    _.FOnReceiveLoginUsers(_,String(P1^));
End;

Procedure TWorkThread.OnGetMessageBoard;
Begin
    _.FOnGetMessageBoard(_,Integer(P1^),String(P2^),String(P3^));
End;

Procedure TWorkThread.OnGetMainPrompt;
Begin
    _.FOnGetMainPrompt(_);
End;

Procedure TWorkThread.OnExecuteWriteMessage;
Begin
    _.FOnExecuteWriteMessage(_,Integer(P1^));
End;

Procedure TWorkThread.OnReceiveUsers;
Begin
    _.FOnReceiveUsers(_,String(P1^));
End;

Procedure TWorkThread.OnReceiveLog;
Begin
    _.FOnReceiveLog(_,String(P1^));
End;
Procedure TWorkThread.OnReceiveFreePost;
Begin
    _.FOnReceiveFreePost(_,String(P1^));
End;

procedure TWorkThread.Execute;
Var
                a,s : string;
  LastReceiveTime   : Integer;
  LastReceiveMainWp : Integer;
              News  : Boolean;

  Procedure GetBoard;
  var
    BoardNo : Integer;
    BoardName : String;
    BoardTitle : String;
  Begin

      BoardNo := -1;
      BoardName := '_________';;
      BoardTitle := '';

      BoardNo    := StrToInt(Copy(a,1,4));
      BoardName  := TrimRight(Copy(a,7,8));
      BoardTitle := Copy(a,16,32);

      P1 := @BoardNo;
      P2 := @BoardName;
      P3 := @BoardTitle;

      if Assigned(_.FOnGetMessageBoard) then Synchronize(OnGetMessageBoard);

  End;

Begin

  Priority := TpHigher;

  FreeOnTerminate :=  True;

   _.Status := CS_Login;
   _.Rp := 0;
   _.Wp := 0;
   News := False;

    While (_.SendThread=nil) and Not Terminated Do
         Sleep(100);

   While Not Terminated do
      Case _.Status of
         CS_Login : Begin
                        Login;
                        If Terminated then Begin
                                            Sts('接続に失敗しました');
                                            Exit;
                                           End;
                    End;
         CS_SendTelegram : SendTelegram;
         CS_WriteMessage : EnterMessage;
         CS_WriteMail    : EnterMail;
        Else
         Begin
          LastReceiveTime := GetTickCount;
          While (_.Rp = _.Wp) and (_.Status=CS_None) and Not Terminated do
           Begin

             Sleep(50);
              With _ do
                if (Copy(RecvBuf[Wp],1,6) = 'MAIN (')
                and (Copy(RecvBuf[Wp],Length(RecvBuf[Wp])-1,2)=')>')
                and (LastReceiveTime + 1000 < GetTickCount)
                and (LastReceiveMainWp <> Wp)
               then
                 Begin
                  Sts('メインメニューを検出しました');
                  LastReceiveMainWp := Wp;
                  if Assigned(_.FOnGetMainPrompt) then Synchronize(Self.OnGetMainPrompt);

                  News := False;
                 End;

           End;

           if _.Status=CS_None then
            Begin
             a := Recvln;

             if (Copy(a,1,6) = '日付が') and (Pos(' 以降のものを読みます。',a)>0) then
               Begin
                 News := True;
                 Sts('News Mode');
               End;
             If News and (Copy(a,5,1)=':') and (Copy(a,1,2)='00') and (StrToIntDef(Copy(a,1,4),0)>0)
                Then GetBoard;

             If Assigned(_.FOnReceiveLog) then
                If (a = '-------- -------------- -- --------- -------- --------   --------  --------')
                or (a = 'USERID    HANDLE        CH  BAUD MNP   D A T E    LOG IN     LOG OUT   CONNECT') then
                  ReadLog;

             If Assigned(_.FOnReceiveLoginUsers) then
                If (a = '-- -------- -------------- -------- -------- -------- -------------------------') then
                   ReadWho;
             If Assigned(_.FOnReceiveUsers) then
                if (a='USERID    H A N D L E')  then
                   ReadUsers;
             If Assigned(_.FOnReceiveFreePost) then
               If (Copy(a,1,15) = 'Free Post     >') then
                Begin
                  Sts('フリーポストを拾得しました');
                  s := ReadBackToMainPrompt(_.Rp-1,199);
                  P1 := @s;
                  If Assigned(_.FOnReceiveFreePost) then Synchronize(OnReceiveFreePost);
                End;

             If _.FGetTelegram and (a = '============================================================') then
               ReadTelegram;
             If _.FGetMessage Then
                 If (Copy(a,1,10) = 'Message  #') then
                    ReadMessage(a);
             If _.FGetMail Then
               If (Copy(a,1,24) = 'Private Message is from:') then
                  ReadMail(a,False);
             ReadChatLine(a);
            End;
         End;
      End;

    Sts('ログアウトしました');

    if Assigned(_.FOnLogout) then
     Begin
       s := ReadBackToMainPrompt(_.Wp,99);
       P1 := @s;
       Synchronize(OnLogOut);
     End;

End;

Function TWorkThread.ReadBackToMainPrompt(Start,Max : Integer):String;
Var
    i   : Integer;
Begin

       i := 0;
       While (Copy(_.RecvBuf[(1000+Start-i) mod 1000],1,3)<>'*CH') and (i<Max) do
           Inc(i);

       Result := '';
       i := (1000+Start-i) mod 1000;
       While Start<>i do
        Begin
           Result := Result +_.RecvBuf[i]+#13#10;
           Inc(i);
           if i > High(_.RecvBuf) then i := 0;
        End;
End;

procedure TWorkThread.Login;
Var
  a,s      : String;
  A1,A2,A3 : String;
  LoginStartWp,i,j,k : Integer;

    procedure OpenTelnet(Host : String);
    Begin

        Sts(Host + 'に接続中');

         With _ do
          Begin
            CommMode := CM_telnet;

            If A3='' then
                TCP.Port := '23'
            else
                TCP.Port := A3;

            TCP.Host := Host;
           TerminateWhenClose := False;
            TCP.close;
           TerminateWhenClose := True;
            TCP.Open;
          End;

    End;

    procedure OpenModem(TelNo : String);
    Var
      n : Integer;
    Begin

         With _ do
          Begin
             TerminateWhenClose := False;
             CommMode := CM_Modem;
             Comm.Port     := CommPort;
             Comm.baudrate := CommRate;
             Comm.Close;
           Try
             Comm.Open;
           Except
             Sts('ポートをオープンできません');
             Terminate;
             Exit;
           End;

          End;


          For n := 1 to 10 do
           Begin
             if _.ModemInitCommand<>'' then
               Begin
                Sts('モデム初期化中...');
                Sendln(_.FModemInitCommand);
                Wait('OK');
               End;
              Sts(TelNo + Format('に電話をかけています....(%d回目)',[n]));
              Sendln(_.FModemDialCommand+Telno);
              if WaitStrs(['CONNECT','BUSY']) = 0 then
                 Break;
              If Terminated then
                 Exit;
           End;

             Sts(TelNo + 'に接続しました');
            _.TerminateWhenClose := true;

    End;

    Function GetIpAddress:String;
    Var
       a : string;
    Begin

      _.CommMode := CM_telnet;
      _.TerminateWhenClose  := False;

         Result := '';

         _.TCP.Host := A1;

         If A3='' then
              _.TCP.Port := '80'
         else
              _.TCP.Port := A3;

         _.TCP.Close;
         _.TCP.Open;

         Sts(A1+' , '+A2+ 'よりIPアドレスを拾得しています.');
         Sendln('GET /'+A2+' HTTP/1.0');
         SendLn('');

         If WaitStrs(['</HTML>','telnet://']) = 0 then
              Sts('IPアドレスを拾得できませんでした.')
          Else
           Begin
             a := RecvLn_;
             a := Copy(a,Pos('://',a)+3,99);
             Result := Copy(a,1,Pos('/',a)-1);
             Sts('IPアドレスを拾得しました...'+Result);
           End;

          While (_.TCP.SocketState <> ssClosed) Do
             If Terminated then Break
                           else Sleep(100);

         _.TCP.Close;

       _.TerminateWhenClose := true;

    End;


Begin

  LoginStartWp := _.Wp;

  // AutoDeleteMail := False;

  s := UpperCase(_.FAddress);

  A1 :=_.FAddress;
  A2 :='';
  A3 :='';

     If Pos('://',s)>0 then
     Begin

      a  := Copy(_.FAddress,Pos('://',_.FAddress)+3,99);

      A1 := Copy(a,1,Pos('/',a)-1);
      A3 := Copy(A1,Pos(':',A1+':')+1,99);
      A1 := Copy(A1,1,Pos(':',A1+':')-1);

      a := Copy(_.FAddress,Pos('://',_.FAddress)+3,200);
      A2 := Copy(a,Pos('/',a)+1,200);

     End
    Else
     Begin

       j := 0;
       For i:=1 to Length(A1) do
        if A1[i]='.' then
          Begin
            Inc(j);
            k := i;
          End
          Else
           if (A1[i] < '0') and ('9' < A1[i]) then
            Begin
              j :=0;
              break;
            End;

       if J=4 then
         Begin
          A3 := Copy(A1,k+1,80);
          A1 := Copy(A1,1,k-1);
         End;
     End;
     
       If Pos('HTTP:',s) > 0 then
         OpenTelnet(GetIPAddress)
        else
          If Pos('TELNET:',s) > 0 then
             OpenTelnet(A1)
           else
             If (Pos('MODEM:',s) > 0) or (Pos('TEL:',s) > 0) then
                OpenModem(A1)
              else
                if pos('.',s) > 0 then
                    OpenTelnet(A1)
                      else
                        OpenModem(A1);


   If Terminated Then exit;

   Wait('ID');
   If (_.FStealthLogin) and (_.HostKind = HK_mtbbs) then
    Begin
     Sts('ログインモード設定中');
     SendLn('$SET_LOGIN_MODE');
       Case WaitStrs(['Pass','Login Mode =']) of
         0 : Sendln('');
         1 : Sendln('STEALTH');
       End;
    End;

   Wait('ID');
   Sts('ID送出待機中');
   SendLn(_.FUserID);

   If Terminated Then exit;
   Case WaitStrs(['Pass','ハンドル']) of
     0 : SendLn(_.FPassword);
     1 : SendLn(_.FHandleName);
   End;
   Sts('パスワード(ハンドル名)送出待機中');
   _.FMyCh := -1;

   While Not Terminated do
     Case WaitStrs(['[RET]:','Private Message is from:','*CH','MAIN (A']) of
       0 : If _.FAutoReceiveMail Then
            Begin
             Sts('メール受信中....(case1)');
//             AutoDeleteMail := True;
             Sendln('');
             If WaitStrs(['Private Message is from:','*CH']) = 0 then
                ReadMail(Recvln,True);
            End
           Else
            Begin
               SendLn('0');
               Recvln;
            End;
       1 : If _.FAutoReceiveMail Then
            Begin
             Sts('メール受信中....(case2)');
             Sendln('');
             ReadMail(RecvLn,True);
            End
           Else
            Begin
               SendLn('0');
               Recvln;
            End;
       2 : Begin
                 _.FMyCh := StrToIntDef(Copy(RecvLn,4,2),-1);
                 Sts('チャンネルを拾得しました..'+IntToStr(_.FMych));
           End;
       3 : Break;
     End;

//   AutoDeleteMail := False;

   _.Status := CS_None;

   If Terminated Then exit;

 if (_.HostKind = HK_mtbbs) then
  Begin
   Sts('モード変更中');
   Sendln('% +M');
  End;

  if not Terminated then
    Begin
     Sts('ログインしました');

     if Assigned(_.FOnLogin) then
      Begin
        i := LoginStartWp+1;
        s := '';
        While _.Wp <> i do
         Begin
          s := s +_.RecvBuf[i]+#13#10;
          i := (i + 1) mod 999;
         End;
        P1 := @s;
        Synchronize(OnLogin);
      End;

    End;

End;

Procedure TWorkThread.Wait(S : String);
Begin
  With _ Do
   While Not Terminated do
    Begin
     If Pos(S,RecvBuf[Rp]) > 0 then Exit;
     If Rp=Wp Then
        Sleep(50)
      Else
        If Pos(S,RecvLn) > 0 then Exit;
    End;

End;

Function TWorkThread.WaitStrs(Const StringS : Array of String) : Integer;
Var
  i : Integer;
  CS :string[120];
Begin

  With _ Do
    While Not(Terminated) Do
     Begin
         CS := _.RecvBuf[Rp];
         For i:=Low(Strings) to High(Strings) do
          Begin
            If Pos(StringS[i],CS)>0 then
              Begin
                 Result := i-Low(Strings);
                 Exit;
              End;
          End;
         If Rp=Wp Then
            Sleep(50)
         Else
            RecvLn;
     End;
   Result := -1;

End;

Procedure TWorkThread.Sts(s: String);
Begin
   P1 := @s;
   Synchronize(OnStatusOut);
end;


Procedure TWorkThread.ReadTelegram;
Var
      a,b : String;
Begin

      a := Recvln;
      b := '';
       if Pos('電報です。発信人は',a)=1 then
         Begin
             b := Recvln; //  01234567
             a := Copy(a,Pos('発信人は',a)+9,99);
             a := Copy(a,1,Pos('さんです。',a)-1);
            P1 := @a;
            P2 := @b;
            Synchronize(OnReceiveTelegram);
            Sts('電報を受信しました');
            Recvln;
         End;


End;

Procedure TWorkThread.ReadWho;
Var
      a,b : String;
Begin

  Sts('ログイン者一覧を拾得中');
      a := Recvln;
      b := '';

       While (Copy(a,1,3)<>'-- ') and Not Terminated do
         Begin
           b := b + a + #13#10;
           a := Recvln;
         End;

        P1 := @b;
        Synchronize(OnReceiveLoginUsers);
  Sts('ログイン者一覧を拾得しました');

End;

Procedure TWorkThread.ReadLog;
Var
      a,b : String;
Begin

  Sts('ログイン記録を拾得中');
      a := Recvln;
      b := '';
                          //123456789
       While (Copy(a,1,9)<>'-------- ') and (a<>'') and Not Terminated do
         Begin
           b := b + a + #13#10;
           a := Recvln;
         End;

        P1 := @b;
        Synchronize(OnReceiveLog);
  Sts('ログイン記録を拾得しました');

End;


Procedure TWorkThread.ReadUsers;
Var
      a,b : String;
Begin

  Sts('ユーザーリスト拾得中');
      a := Recvln;
      b := '';
       While (a<>'') and Not Terminated do
         Begin
           b := b + a + #13#10;
           a := Recvln;
         End;

       P1 := @b;
       Synchronize(OnReceiveUsers);

End;


Procedure TWorkThread.Sendln(s : String);
Begin

     TSendThread(_.SendThread).Write(Pchar(s+#13#10),Length(s)+2);

End;

Procedure TWorkThread.Puts(s : String);
Begin

     TSendThread(_.SendThread).Write(Pchar(s),Length(s));

End;

Function TWorkThread.IsReceived : Boolean;
Begin

   Result := _.Rp <> _.Wp;

End;

Function TWorkThread.Recvln_:String;
Begin

   Result := '';

   With _ Do
    Begin

     While Rp=Wp do
      Begin
         Sleep(50);
         If Terminated then Exit;
      End;

      Result := RecvBuf[Rp];

      Inc(Rp);
      If Rp > High(RecvBuf) then Rp := 0;
    End;

End;


Function TWorkThread.RecvLn  : String;
Begin

  Result := Recvln_;
  P1 := @Result;

  If _.IsLogFileOpen then WriteLn(_.LogF,Result);

  With _ do
   If    ( (Rp<=Wp) and (Wp-Rp < High(RecvBuf)-300))   // 受信バッファの残りが３００行になったらOnReceiveLineを無視する
     or ( (Rp>Wp) and (Rp-Wp >300 ))  then
      Begin
          If Assigned(_.FOnReceiveLine) then Synchronize(Self.OnReceiveLine);
      End;

End;





Procedure TWorkThread.ReadMessage(a : String);
Var
   Mes : TMtbbsMessage;
Begin

  While (Copy(a,1,10) = 'Message  #') do
    Begin

         Mes.Text := '';
         if Pos('is from:',a) = 0 then
          begin
            a := RecvLn;
            Exit;
          End;

           Mes.No     := StrToIntDef(Copy(a,11,4),-1);
           a := Copy(a,25,14+8+1);
           Mes.ID     := Copy(a,1,Pos(' ',a)-1);
           Mes.Handle := Copy(a,Pos(' ',a)+1,14);
         a := RecvLn;
         if Pos('Time:',a) = 0 then Exit;
           Try
             Mes.DateTime := StrToDateTime(Copy(a,7,17));
           Except
             Mes.DateTime := StrToDate('99/99/99');
           End;
           Try
             a := Copy(a,Pos('Section',a)+8,80);
             Mes.BoardNo := StrToInt(Copy(a,1,Pos(':',a)-1));
           Except
             Exit;
           End;
           Mes.BoardTitle   := Copy(a,Pos(':',a)+1,60);
         a := RecvLn;
         if Pos('Subj:',a) = 0 then Exit;
           Mes.Title := Copy(a,7,80);

           While Not Terminated do
            Begin

              If _.FHostKind<>HK_Mtbbs then
               Begin
                 While (_.rp=_.wp) and (Not Terminated) do
                  Sleep(30);
                 a := _.RecvBuf[_.rp];
                 If (Copy(a,5,1)=':') and (Copy(a,1,2)='00') and (StrToIntDef(Copy(a,1,4),0)>0) then
                 Break;
               End;

              a := RecvLn;

              if (Copy(a,1,10) = 'Message  #') or (Copy(a,1,3) = '*CH') or (a='//') then Break;
              Mes.Text := Mes.Text + a +#13#10;
            End;
      P1   := @Mes;
      Synchronize(OnReceiveMessage);
   End;
End;

Procedure TWorkThread.ReadMail(a : String;AutoDeleteMail : Boolean);
Var
   Mes : TMtbbsMessage;
Begin

  While  (Copy(a,1,24) = 'Private Message is from:')  do
   Begin
         Mes.Text := '';
         if Pos('is from:',a) = 0 then
          begin
            a := RecvLn;
            Exit;
          End;

           Mes.No     := -1;
           a := Copy(a,26,99);
           a := Copy(a,1,Pos('to:',a)-2);
           Mes.ID     := Copy(a,1,Pos(' ',a)-1);
           Mes.Handle := Copy(a,Pos(' ',a)+1,14);

         a := RecvLn;
         if Pos('Time:',a) = 0 then Exit;
           Try
             Mes.DateTime := StrToDateTime(Copy(a,7,17));
           Except
             Mes.DateTime := EncodeDate(80,01,01);
           End;

           Mes.BoardNo := 0;
           Mes.Boardtitle := 'メールボックス';

         a := RecvLn;

         if Pos('Subj:',a) = 0 then Exit;
           Mes.Title := Copy(a,7,80);
           Mes.Text := '';

           While Not Terminated do
            Begin
              While AutoDeleteMail and (_.rp=_.wp) do
               Begin
                 if (_.RecvBuf[_.rp]='削除しますか？ (Y/N)>') and AutoDeleteMail then
                  Begin
                    Sendln('y');
                    Break;
                  End;
                 Sleep(50);
               End;
              a := RecvLn;
              if (Copy(a,1,21)='削除しますか？ (Y/N)>')  or (Copy(a,1,3) = '*CH') or (Copy(a,1,24) = 'Private Message is from:')  then Break;
              Mes.Text := Mes.Text + a +#13#10;
            End;

      P1   := @Mes;
      Synchronize(OnReceiveMail);
   End;

End;

Procedure TWorkThread.ReadChatLine(a : String);
Var
  Ch : Integer;
  HandleName : String;
  b  : Boolean;
  s  : String;
Begin

      Ch := StrToIntDef(Copy(a,1,2),-1);

      If (Copy(a,3,1) = ':') and (Pos('>',a)>5) and (ch > -1) then
      Begin
         HandleName := '';//最適化を殺す
         HandleName := TrimRight(Copy(a,4,14));
         P1 := @Ch;
         P2 := @HandleName;
         P3 := @a;
         b := False;
         With _ do
           If Rp<>Wp then
              b := (Copy(RecvBuf[Rp],3,1) = ':') and (Pos('>',RecvBuf[Rp])>5) and (StrToIntDef(Copy(RecvBuf[Rp],1,2),-1) > -1);
         P4 := @b;
         Synchronize(OnReceiveChatLine);
      End;

End;

procedure TWorkThread.SendTelegram;
Begin

  Sendln('T');
  Wait('電報を送るチャンネルは');
  Sendln(_.PS1);
   Case WaitStrs(['メッセージは','ログインされていません','キャンセルしました']) of
     0 : Sendln(_.PS2);
     1,2 : Sts('電報の送信に失敗しました');
   End;

   _.Status := CS_None;

End;


Function TWorkThread.ReadBufLines(StartRp,EndRp : Integer):String;
Var
   i :  Integer;
Begin

 Result := '';
  i:=StartRp;
  Repeat
    Result := Result + _.RecvBuf[i]+#13#10;
    if i=EndRp then Break;
    inc(i);
    If i>High(_.RecvBuf) then i := 0;
  Until Terminated;


End;

Procedure TWorkThread.EnterMessage;
Begin

      sts('メッセージ書込中...'+_.PS2);

      if (_.HostKind = HK_ktbbs) and (Copy(_.PS2,1,3)='Re:')
          and (StrToIntDef(Copy(_.PS2,4,Pos(')',_.PS2)-4),-1)>0)
        then
           SendLn('er'+_.PS1+';'+Copy(_.PS2,4,Pos(')',_.PS2)-4))
        else
           SendLn('ew'+_.PS1+';'+_.PS2);

        repeat

           Case WaitStrs(['存在しません','そのボードには書き込めません。','アクセス権がありません','これでよろしいですか']) of
           0,1,2 : Begin
                    Sendln('0');//Err
                    Wait('*CH');
                   End;
               3 : Begin
                    SendLn('Y');
                    Wait('----+');
                    Puts(_.PS3+#13#10);
                    SendLn('//');
                    If Terminated then Break;
                    Wait('S:送信');
                    SendLn('S');
                     Case WaitStrs(['失敗','*CH','終了']) of
                       0,1 : Sts('失敗しました');
                       2   : If Assigned(_.FOnExecuteWriteMessage) then
                              Begin
                                Sts('書き込みました');
                                P1 := @_.PI1;
                                Synchronize(OnExecuteWriteMessage);
                              End;
                     End;
                   End;
             End;

        until true;

  _.Status := CS_None;

End;

Procedure TWorkThread.EnterMail;
Var
  Mes          : TMtbbsMessage;
  WriteStartRp : Integer;
Begin

      sts('メッセージ書込中...'+_.PS2);
        Repeat
             WriteStartRp := _.Rp;
             SendLn('em'+_.PS1);

             Case WaitStrs(['中止','C:cancel 0:end)>','題名をどうぞ']) of
               0 : Begin
                    Sendln('0');//Err
                    Wait('*CH');
                    Break;
                   End;
               1 : Begin
                    Sendln('0');
                    Wait('題名をどうぞ');
                   End;
              End;

                    SendLn(_.PS2);
                    Wait('これでよろしいですか');
                    SendLn('Y');
                    Wait('----+');
                    Puts(_.PS3+#13#10);
                    SendLn('//');
                    If Terminated then Break;
                    Wait('S:送信');
                    SendLn('S');
                     Case WaitStrs(['失敗','*CH','終了']) of
                       0,1 : Sts('失敗しました');
                       2   : If Assigned(_.FOnExecuteWriteMessage) then
                              Begin
                                Sts('書き込みました');
                                P1 := @_.PI1;
                                Synchronize(OnExecuteWriteMessage);
                              End;
                     End;
                    If Assigned(_.FOnReceiveMail) then
                     Begin
                        Mes.BoardNo  := 0;
                        Mes.No       := -1;
                        Mes.ID       := Copy(_.PS1,1,Pos(';',_.PS1+';')-1);
                        Mes.DateTime := Now;
                        Mes.Title    := '[送信ﾒｰﾙ]'+_.PS2;
                        Mes.Handle   := '？';
                        Mes.Text     := ReadBufLines(WriteStartRp,_.Rp);
                        P1   := @Mes;
                        Synchronize(OnReceiveMail);
                     End;
        Until True;

  _.Status := CS_None;

End;

(*************************** 送信スレッド *********************************)

constructor TSendThread.Create(AOwner : TComponent);
Begin

    inherited Create(True);                   // サスペンド状態で作成
    _ := TMtbbsClient(AOwner);

      SRp := 0;
      SWp := 0;

    Resume;
End;

destructor  TSendThread.Destroy;
Begin

    _.SendThread := Nil;
    inherited;

End;

Procedure TSendThread.Write(Buf : PChar;Size : Integer);
Var

   i,n,j,k : Integer;

     Function FreeSize : Integer;
      Begin
          if Srp<=Swp then
             Result := Srp + (High(SendBuf)-Swp)
           Else
             Result := Srp - Swp;
      End;

Begin

   If Terminated Then Exit;

   For j := 0 to Size div 1024 do
     Begin

         n := j*1024+1023;
         if n>Size - 1 then n := Size - 1;

         While (FreeSize <= (n - j*1024)) and (Not Terminated) do
             Sleep(50);

         For i := j*1024 to n do
          Begin
           SendBuf[Swp] := Buf[i];
           Swp := (Swp + 1) mod High(SendBuf);
          End;

     End;

End;

procedure TSendThread.Execute;
Var
  ss : String;
      Data     : PChar;
      SendSize : Integer;
      i,j,l,k    : Integer;

       dwError : DWord;
       Stat    : TComStat;
       dwBytesWritten: DWord;
       errorcount : Integer;
      Size : Integer;
      Comm : TMyoComm;

Begin
 SRp := 0;
 Swp := 0;

 Data := AllocMem(1025);
 Comm := _.Comm;

 While Not Terminated do
   Case _.CommMode of
    CM_Telnet :
     Begin
       k := SRp;
       If (k<>SWp) then
         Begin
           j := 0;
           While (k <> SWp) Do
            Begin
               Data[j] := SendBuf[k];
               k := (k+1) mod High(SendBuf);
               Inc(j);
               If j > 1023 then Break;
            End;
           SendSize := _.TCP.WriteBuffer(@Data[0],j);
           SRp := (Srp+SendSize) mod High(SendBuf);
         End;
       Sleep(50);
    End;
  CM_Modem :
       Begin
        If Swp = Srp Then
           Sleep(20)
        Else
         Begin
           k := SRp;
           If (k<>SWp) then
           Begin
             Size := 0;
             While (k <> SWp) and (Not Terminated) Do
              Begin
                  Data[Size] := SendBuf[k];
                  Inc(Size);
                  k := (k+1) mod High(SendBuf);
                  If Size > 511 then Break;
              End;
           End;

           repeat                                    // 送信キューが空くのを待つ
             Sleep(5);
             ClearCommError(Comm.Handle, dwError, @Stat);
           until Terminated or ((Comm.OutQueueSize - Stat.cbOutQue) >= Size);

           If Terminated then Break;
           j := 0;
           errorcount := 0;

           if not WriteFile(Comm.Handle, Data^, Size, dwBytesWritten,@Comm.FWriteOs) then
            begin
               if GetLastError = ERROR_IO_PENDING then // オーバーラップ処理時
                 begin
                  while not GetOverlappedResult(Comm.Handle, Comm.FWriteOs,
                    dwBytesWritten, True) do
                     begin
                       if GetLastError = ERROR_IO_INCOMPLETE then  // まだ完了しない
                          Continue
                       else
                        begin
                          ClearCommError(Comm.Handle, dwError, @Stat);
                          Break;
                        end;
                     end;
                 end
                else
                 begin                                   // その他のエラー発生
                  dwError := GetLastError;
                  ClearCommError(Comm.Handle,dwError,@Stat);
                  Inc(errorcount);
                  If errorcount > 29 then
                   Begin
//                     _.Sts('[MODEM]  送信エラー発生(タイムアウト) Last Error No ='+IntToStr(dwError));
                     Terminate;
                   End;
                  Sleep(500);
                 End;
            end;

            SRp := (Srp+dwBytesWritten) mod High(SendBuf);

         End;
       End;
   End;

  While _.WorkThread<>nil do
    Sleep(5);

  FreeMem(Data,1025);
  FreeOnTerminate := True;

End;






end.
