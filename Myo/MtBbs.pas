unit MtBbs;
{

*********************************************************

  MTBBS チャンネルスレッドユニット

　Copyright (C) 1997.10.9,1999.8 By Yoshihiro Myokan.

*********************************************************


}
interface

uses
  Classes,SysUtils,Forms,MesBrd,FileBrd,Windows,Define
  ,UserSys,ExMtBBS,MailSys,MyoComm,FileTranSys,mtbbsapi,eddefine
  ;

Const

  NormalThreadPriority = tpNormal;

Type

   TUser = Record
       ID                  : string[8];
       HandleName          : String[14];
       Memo                : String[25];
       Level               : TUserLevel;
       Where               : String[8];
       LoginTime           : TDateTime;
       LastRead            : TDateTime;
       LastFileNews        : TDateTime;
       UseLoginReport      : Boolean;
       NewsEnableBoards    : TNewsEnableBoards;
       ReceiveTelegramBell : Boolean;
       Options    : Record
                     AddMessageEof : Boolean;
                    End;
   End;

   TStringArray = Array [0..9] of String;

   TBoardAccessKind = (AK_Read,AK_Write);

   TProfileItem     = (_Address,_Name,_Tel,_Comment,_BirthDay,_Hobby,_Handle,_Email);

   TReceive = Procedure(Data : PChar;Size : Integer) of object;

   TMtBbs = class(TThread)
     private

       MTAPI_     : TObject;
       FWakeupMtbbs : THandle;

       FMtbbsSts  : String;
       FAddLoginErr : Record
            Way   : String[40];
            Id    : String[8];
            Pass  : String[8];
       End;

       EchoStrs  : String;

       MessageBoard     : TMessageBoard;
       MailSystem       : TMailSystem;
       FileTran         : TFileTran;
       CommWriteThread  : TObject;
       CommandLine : String[255];

       Procedure AddLoginError_;
       Procedure AddLoginError(Way,Id,Pass : String);

       Function InputTitle : String;
       Function InputCommand2(Prompt : String): String;

       Function MakePassword : String;
       Function  ChatInput : String;   //チャット／電報受信に対応
       Procedure Apply;
       Procedure Version;
       Function ZenToHan (s : String):String;

       Procedure ReadBoard(BoardNo,StartNo,direction : Integer);
       Procedure ReadMail(MailsIndex : Array of Integer;MailsCount : Integer);
       Procedure WriteMail(IsBMail : Boolean);
       Procedure WriteResMail(ResMail : TMail);

       Function  WriteRes(BoardNo,ResNo : Integer) : Boolean;

       Function InputUserID : Integer;
       Procedure InputProfile(Var UI : TUserInit;P : TProfileItem);
       Function CheckUseLevel(kinou : TKinou):Boolean;   // True = 使用禁止

 //
       Procedure SendUserInfo;
       Procedure Users;
       Procedure SysopCall;
       Procedure MessageList(BoardNo : Integer;IDs : Array of String);
       Procedure Boards;
       Procedure FBoards;
       Procedure RecvTelegram;
       Procedure Goodbye(b : Boolean);
       Function InputText : String;
       Function InputBoardNo(AK : TBoardAccessKind) : Integer;
       Function InputFileBoardNo(AK : TBoardAccessKind) : Integer;

       Procedure PutProfile(I : Integer);
       Procedure ChatRoomList;
       Procedure ChatRoomWho(MyChatRoom : Integer);
       Procedure Login;
       Procedure Main;
       Procedure Chat;
       Procedure Profile;
       Procedure Enter;
       Procedure ReadMessage;
       Procedure WriteMessage;
       Procedure WriteResponse;
       Procedure News;
       Procedure FileNews;
       Procedure Kill;
       Procedure Install;
       Procedure Log;
       Procedure Sysop;
       Procedure Ip;
       Procedure ChangeMode;
       Procedure FreePost;

       Function UploadFile(ReceiveFileName : String;P : String):Boolean;
       Function DownloadFile(FileName,SendFileName : String;P : String):Boolean;

       Procedure Wait(t : Integer);
       Procedure Mail;
       Procedure FileMain;

//
       Function ChToHandle(Ch : Integer) : String;
       Function IsUsedWWWch(c : integer) : Boolean;

       Function MakeMessageHead(Mes : TMessage) : String;
       Function MakeMailHead   (Mail : TMail;idx : Integer)   : String;
       Function MakeText(S : String) : String;
       Procedure FileList(BoardNo : Integer;IDs : Array of String);

       Procedure MtbbsSts(s : String);
       Procedure MtbbsStsOut;
       Procedure PlayLoginSound;
       Procedure PlayLogoutSound;
       Procedure PlaySysopCallSound;
       Procedure PluginCreate(PlugIndex : Integer);

       Procedure DownLoadBMail(MailIndex : Integer;Mail : TMail);
       Function UpLoadBMail(MailIndex : Integer;Mail : TMail):String;

     protected

       procedure Execute; override;

     public

       SendBuf : Array[0..2000] of Char;

       ReadMode  : (RM_None,RM_IAC1,RM_IAC2);

       SRp        : Integer;
       SWp        : Integer;
       Comm       : TMyoComm;

       Wp    : Integer;
       Rp    : Integer;

       RecvStrbuf : Array[0..2000] of String;
       Receive    : TReceive;

       Crp        : Integer; // チャットのリードポインタ
       MyChatRoom : Integer;


       Telegrams : TStringList;//電報用

       Echo      : Boolean;

       User : TUser;

       MainInChat : Boolean; // チャットルームからメインをよびだし中

       FOwner : TComponent;
       FCh    : Integer;

       Function CheckPluginCommand(s : String) : Boolean;
       Procedure PutEchoStrs;
       Procedure Who;
       Procedure Telegram;
       Procedure SendTelegram(ch : Integer;Mes : String);

       Procedure Puts(S : String);
       Function  RecvLn : String;
       Procedure SendLn(S : String);
       Function YesNoInput(Prompt : String): Boolean;   //電報受信に対応
       Function  Input(Prompt : String): String;   //電報受信に対応
          Function InputCommand(Prompt : String;CharInp : Boolean): String;   //電報受信に対応
       Procedure RecordReadMail(Mail : TMail);

       Procedure Write(Buf : PChar;Size : Integer);
       Procedure TextReceive(Data : PChar;Size : Integer);

       constructor Create(AOwner : TComponent;Ch : Integer;Comm_ : TMyoComm);
       destructor  Destroy;override;
//
   end;

   TCommWriteThread = class(TThread)  //モデム接続送信用スレッド
   private
      Mtbbs  : TMtbbs;
      Fs     : String;
      Procedure AddMonitorWindow;
   protected
       procedure Execute; override;            // スレッドのメイン処理
   public
       constructor Create(Mt: TMtbbs);
   end;

   TMtAPI = class(TObject)
     private
          StrBuf   : String;
     protected
     public

       API          : TMtAPIRecord;
       MTBBS        : TMtbbs;
       _Terminated  : ^Boolean;

          Function Version : Pchar;stdcall;
          Function Terminated : Boolean;stdcall;
          Procedure ChangeWhere(s : Pchar);stdcall;
          Procedure Sendln(s : PChar);stdcall;
          Function Recvln : PChar;stdcall;
          Procedure Puts(s : PChar);stdcall;
          Function YesNoInput(Prompt:Pchar):Boolean;stdcall;
          Function Input(Prompt:Pchar):Pchar;stdcall;
          Function InputCommand(Prompt:Pchar;CharInp:Boolean):Pchar;stdcall;
          Procedure Who;stdcall;
          Procedure Telegram;stdcall;
          Function IsUsedChannel(Ch : LongInt):boolean;stdcall;
          Function GetLoginUserData(Ch : LongInt):TUserData;stdcall;
          Function IsReceived:boolean;stdcall;
          Procedure PutEchoStrs;stdcall;
          Function InputText : Pchar;stdcall;
          Procedure RecvTelegram;stdcall;
          Procedure SendTelegram(ToCh : Integer;From : PChar;Mes : Pchar);stdcall;
          Function UsersCount:Integer;stdcall;
          Function SearchUser(ID : PChar):Integer;stdcall;
          Function  ReadUserInfo(Index : Integer):TUserInfo;stdcall;
          Procedure WriteUserInfo(Index : Integer;UserInfo : TUserInfo);stdcall;
          Function GetLastReceiveLine:Pchar;stdcall;
          Function IsReceivedTelegram:boolean;stdcall;


       constructor Create(AOwner :TObject);
   end;

  Function SeparateString(s : String):TStringArray;
Var
  SystemStartDateTime : TDateTime;
  ChatRooms : array [1..20] of
   Record

     ID : string[8];
     Handle : String[14];
     Password : String[8];
     RoomTitle : String[40];
     RoomComment : string;
     Lock : boolean;
     ChatLogFile_Assigned : boolean;
     ChatLogFile          : TextFile;
     ChatBuffer : Array [0..1000] of String; // チャット用
     Cwp        : Integer;
     ChatLines  : Integer;
   End;

implementation
uses
  Main,LogSys,game,plugsetup,MVCL;

Const
   Spc = '                       ';
Var

  AddChat_Busy : Boolean;

//---

Procedure TMTbbs.PutEchoStrs;
Var
  s : String;
Begin

  If Length(EchoStrs)=0 then Exit;

    s := EchoStrs;
    EchoStrs := '';
    Puts(s);

End;

Procedure TMtbbs.MtbbsStsOut;
Begin
     MainForm.MTBBSSTSAdd(Format('CH%.2d:',[Fch])+FMtbbsSts);
End;

Procedure TMtbbs.MtbbsSts(s : String);
Begin

   FMtbbsSts := s;
   Synchronize(MtbbsStsOut);


End;

// -------------------------　送信処理　----------------------------------------

Procedure TcommWriteThread.AddMonitorWindow;
Begin

      MainForm.Chs[TMtbbs(Mtbbs).Fch].MonitorWindow.AddStr(Fs);

End;

constructor TCommWriteThread.Create(Mt: TMtbbs);
begin
  inherited Create(True);                   // サスペンド状態で作成
  Mtbbs := Mt;
  Resume;                                   // スレッドの実行開始
end;

procedure TCommWriteThread.Execute;
Var

      dwError : DWord;
      Stat    : TComStat;
      dwBytesWritten: DWord;
      errorcount : Integer;
      Data       : PChar;
      i,j,l,k    : Integer;

      Size : Integer;
      Comm : TMyoComm;

Begin

    Priority := tpHigher;
    Data := AllocMem(1025);

    Comm := Mtbbs.Comm;

    With Mtbbs do
      While Not Terminated do
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
                     MTBBSSts('[MODEM]  Transmission error! Last Error No ='+IntToStr(dwError));
                     Terminate;
                   End;
                  Sleep(500);
                 End;
            end;

            If dwBytesWritten > 0 then
                   MainForm.Chs[fch].IdleStartTime := GetTickCount;

            SRp := (Srp+dwBytesWritten) mod High(SendBuf);
            Data[dwBytesWritten] := #0;

           If MainForm.Chs[Fch].MonitorWindow <> nil then
               Begin
                Fs := PChar(Data);
                Synchronize(AddMonitorWindow);
               End;
         End;
       End;

    FreeMem(Data,1025);
    FreeOnTerminate := True;

End;




Procedure TMtBBS.Write(Buf : PChar;Size : Integer);
Var

   i,j,k : Integer;

     Function FreeSize : Integer;
      Begin
          if Srp<=Swp then
             Result := Srp + (2000-Swp)
           Else
             Result := Srp - Swp;
      End;

Begin

         While FreeSize <= Size do
          Begin
             Sleep(50);
             If Terminated then Exit;
          End;

         For i := 0 to Size - 1 do
          Begin
           SendBuf[Swp] := Buf[i];
           Swp := (Swp + 1) mod High(SendBuf);
          End;


End;


Procedure TMtBBS.TextReceive(Data : PChar;Size : Integer);
Var
  SendStr : String;
  i,j,k   : Integer;
  S       : String;
Begin

          SendStr := '';
          S := RecvStrBuf[Wp];
          For i:=0 to Size-1 Do
          Begin
            Case ReadMode of
              RM_None :
                If ( (Data[i] < #32) or (Data[i] = #255)) then
                   Begin
                     If Data[i]=#255 then
                       ReadMode := RM_IAC1;
                     If Data[i]=#9 then
                      Begin
                        k := Length(S) mod 8;
                        if k = 0 then k := 8;
                         s := s + Copy('        ',1,k);
                         SendStr := SendStr + Copy('        ',1,k);
                      End;
                     If Data[i]=#8 then
                      Begin
                        k := Length(s);
                        If k > 0 then
                           If  K > 1 then
                             Begin
                              If IsDBCSLeadByte(Byte(S[K-1])) then
                                Begin
                                  SendStr := SendStr + #8#8'  '#8#8;
                                  S       := Copy(S,1,k-2);
                                End Else
                                Begin     //
                                  SendStr := SendStr + #8' '#8;
                                  S       := Copy(S,1,k-1);
                                End;
                             End Else
                             Begin  //↑同じのが二つ重なって汚いけどまぁいいか^^;
                               SendStr := SendStr + #8' '#8;
                               S       := Copy(S,1,k-1);
                             End;
                      End;
                     If Data[i]=#13 then
                      Begin
                       SendStr := SendStr + #13#10;
                       RecvStrBuf[Wp] := S;
                       Inc(Wp);
                       If Wp > 1999 then Wp := 0;
                       RecvStrBuf[Wp] := '';
                       S := '';
                      End;
                   End
                   Else
                    Begin
                     SendStr := SendStr + Data[i];
                     s       := s       + Data[i];
                    End;
              RM_IAC1 : ReadMode := RM_IAC2;
              RM_IAC2 : ReadMode := RM_None;
            End;
          End;
          RecvStrBuf[Wp] := S;
          If Echo Then EchoStrs := EchoStrs + SendStr;

End;





Procedure TMtBBS.Puts(S : String);
Var
 i,n : Integer;
  p : PChar;
Begin

  For i := 0 to Length(s) Div (High(SendBuf)-2) do
   Begin
     n := Length(s) - (High(SendBuf)-2)*i;
     if n > (High(SendBuf)-2) then
       n := (High(SendBuf)-2);
     p := PChar(s);
     Inc(p,(High(SendBuf)-2)*i);
     Write(p,n);
   End;

End;

Procedure TMtBBS.SendLn(S : String);
Begin

    S := S + #13#10;
    Write(Pchar(S),Length(s));

End;


// ---------------------------------------------------------------------

Function GetFileSize(Fn : String) : integer;
Var
    Fs: File of Byte;
begin

    if Fileexists(Fn) then Begin
       AssignFile(Fs,Fn);
       Reset(Fs);
       Result := FileSize(Fs);
       CloseFile(Fs);
       Sleep(100);
     end
     Else Result:=0;

End;

Function TMtBBS.MakeText(S : String) : String;
Var
  i : Integer;

    Function Conv(c : Char) : String;
    Var
      Hour,Dummy : Word;
    Begin
        Case c of
          'H' :  Result := User.HandleName;
          'I' :  Result := User.ID;
          'T' :  Result := TimeToStr(Now);
          'D' :  Result := DateToStr(Now);
          'W' :  Case DayOfWeek(Now) of
                  1: Result :='日';
                  2: Result :='月';
                  3: Result :='火';
                  4: Result :='水';
                  5: Result :='木';
                  6: Result :='金';
                  7: Result :='土';
                 End;
          'C' :  Result := TimeToStr(Now - User.LoginTime);
          'N' :  Result := IntToStr(AccessCount+GeneralDefine.Other.AccessCountReset);
          'A' :  Begin
                   DecodeTime(Now, Hour, dummy,dummy,dummy);
                   Case Hour of
                      0..4,18..23    : Result :='こんばんは';
                      5..10          : Result :='おはようございます';
                      11..17         : Result :='こんにちは';
                   End;
                 End;
          'V' :  Result := MTBBSVERSION;
          'L' :  Result := IntToStr(User.Level);
          'X' :  Result := OkotobaStrs[Random(OkotobaStrs.Count)];
           Else
            Result := '%';
        End;

     End;

begin

  Result := '';

  i := 1;
  While i <= Length(S) Do
   Begin

    If (S[i]='%') and  (i+1 < Length(S)) then
     Begin
       Inc(i);
       Result := Result + Conv(S[i]);
     End
     Else
       Result := Result + S[i];

     Inc(i);

   End;


End;


Procedure TMtBBS.AddLoginError_;
Var
   f : TextFile;
Begin

  AssignFile(F,AppPath+'LoginErr.Log');
  If FileExists(AppPath+'LoginErr.Log') then Append(F)
   Else
    Begin
      Rewrite(f);
      Writeln(F,' Date     Time      ID  ');
      Writeln(F,'-------- -------- -------- -----------------------------');
    End;

  Writeln(F,Format('%.17s %.8s  %s',[DateTimeToStr(Now)+'               ',FAddLoginErr.Id+'               ',FAddLoginErr.Way]));
  CloseFile(f);

End;



Procedure TMtBBS.AddLoginError(Way,Id,Pass : String);
Begin

  FAddLoginErr.Way  :=Way ;
  FAddLoginErr.Id   :=Id  ;
  FAddLoginErr.Pass :=Pass;

  Synchronize(AddLoginError_);

End;


Procedure AddChatMessage(MyChatRoom : integer;Mes : String);
Var
  Fn : String;
Begin


  Mutex.Wait;

 Try
 with ChatRooms[MyChatRoom] do
  Begin
   ChatBuffer[Cwp] := Mes;
   Inc(Cwp);
   Inc(ChatLines);
   If Cwp > 999 then Cwp := 0;

   if GeneralDefine.Chat.SaveLog then
    Begin
      If Not ChatLogFile_Assigned then
        Begin
         Fn := GeneralDefine.Chat.LogFileName+IntToStr(MyChatRoom);
         If Pos('\',Fn)=0 then Fn := AppPath + Fn;
         Try
          AssignFile(ChatLogFile,Fn);
           If FileExists(Fn) then
              Append(ChatLogFile)
           Else
              Rewrite(ChatLogFile);
         Except
           GeneralDefine.Chat.SaveLog := False;
           MainForm.MTBBSSTSAdd('Internal error...　Failed to open chat file.');
           AddChat_Busy := False;
           Exit;
         End;
         ChatLogFile_Assigned := True;
        End;
      WriteLn(ChatLogFile,Mes);
    End
     Else
       If ChatLogFile_Assigned then
         Begin
           CloseFile(ChatLogFile);
           ChatLogFile_Assigned := False;
         End;
 End;

 Finally

   Mutex.Release;
 End;


End;


Function SeparateString(s : String):TStringArray;
Var
   i,p : Integer;
   f   : Boolean;
Begin

     i := 0;
     F := False;
     Result[i] := '';

     For p:=1 to Length(s) do
      If (s[p]=' ') and F then
         Begin
            inc(i);
            if i>9 then Exit;
            Result[i] := '';
            F := False;
         End Else
         Begin
            Result[i] := Result[i] + S[p];
            F := True;
         End;
End;


constructor TMtBBS.Create(AOwner : TComponent;Ch : Integer;Comm_ : TMyoComm);
Var
  s : String;
  i   : Integer;
Begin

     inherited Create(True);

     FOwner := AOwner;
     FCh    := Ch;
     MyChatRoom := -1;

     Rp      := 0;
     Wp      := 0;

     SRp     := 0;
     SWp     := 0;
     Echo   :=  False;
     EchoStrs := '';

     Telegrams        := TStringList.Create;
     MessageBoard     := TMessageBoard.Create;
     MailSystem       := TMailSystem.Create;
     FileTran         := TFileTran.Create(Self);
     FileTran.Terminated := @Terminated;
     MTAPI_            := TMTAPI.Create(Self);
     TMTAPI(MTAPI_)._Terminated    := @Terminated;

     CommWriteThread  := nil;

     Priority := NormalThreadPriority;

     CommandLine :=  '';

     Comm  := Comm_;
     Receive  := TextReceive;

     ReadMode := Rm_None;

     If MainForm.Chs[Fch].Mode = Cm_Modem then
         CommWriteThread := TCommWriteThread.Create(Self);   //送信用スレッドの生成

     For i := 0 to PluginsCount - 1 do
        Plugins[i].Created[fch] := False;

     Resume;

     Case MainForm.Chs[Ch].Mode of
       CM_Telnet : s := 'TCP/IP Telnet';
       CM_Modem  : s := 'Modem link';
      End;
      MTBBSSTS(s+'connection established.');     // チャンネルの初期化

      If MainForm.Chs[Fch].Disconnect then
          Terminate;

End;


destructor TMtBBS.Destroy;
Var
  Log : TAccessLog;
  i   : Integer;
Begin

   Log.Ch     := Fch;
   Log.Handle := User.HandleName;
   Log.Id     := User.Id;
   Log.Way    := MainForm.Chs[fch].Way;
   Log.InTime := User.LoginTime;
   Log.OutTime:= Now;

   If Pos('MYO',Commandline)=0 then
      AddAccessLog(Log);

   Case MainForm.Chs[fch].Mode of
      cm_Telnet :   If Not MainForm.Chs[Fch].Disconnect then
                       MainForm.TCPServer1.Disconnect(TMainForm(FOwner).Chs[fch].Socket);
      cm_Modem  : TMainForm(FOwner).DisConnectLine(TMainForm(FOwner).Chs[fch].Socket);
   End;

     MtbbsSts('Connection severed.');

     Telegrams        .Free;
     MessageBoard     .Free;
     MailSystem       .Free;
     FileTran         .Free;

     For i := 0 to PluginsCount - 1 do
       if Plugins[i].Created[fch] then
           Plugins[i].Free(fch);

     MainForm.Chs[Fch].Mode   := cm_None;
     MainForm.Chs[Fch].Thread := Nil;

     inherited Destroy;



End;




Function TMtBBS.RecvLn  : String;
Begin


 Result := '';

 While Rp=Wp do
  Begin
   PutEchoStrs;
   Sleep(50);
   If Terminated then Exit;
  End;
  PutEchoStrs;

  Result := RecvStrBuf[Rp];

 Inc(Rp);
 If Rp>1999 then Rp := 0;

End;



Procedure TMtBBS.Execute;
Var
   UI : TUserInit;
    i : Integer;
    b : Boolean;
Begin

 FreeOnTerminate := True;

 Sleep(500);

 If MainForm.Chs[Fch].Mode = Cm_Modem then
     Begin
        i := GetTickCount;
        While( GetTickCount < i + 1500) do
         Begin
           Sleep(200);
           If Terminated then Exit;
         End;
     End;

  SendLn(Format('*** Connected to channel [%.2d] ***',[Fch]));

  puts(MakeText(OpeningMessage));

     Rp     := 0;
     Wp     := 0;
     RecvStrBuf[Rp] := '';
     Echo   := True;

  Try
    Login;
  Except
    MTBBSSTS('CH:'+IntToStr(FCh)+'  Internal error!');
    UsingFile := False;   // 念のため
    Mail_UsingFile := False;
  End;

  If User.Level > 0 then
     Begin
           UI := GetUserInit(User.ID);
             UI.LastLogin := User.LoginTime;
             Inc(UI.AccessCount);
            OutUserInit(UI.ID,UI);
     End;

  FreeOnTerminate := True;
  Terminate;

  If CommWriteThread <> nil then
     TCommWriteThread(CommWriteThread).WaitFor;


End;

Procedure TMtBBS.PluginCreate(PlugIndex : Integer);
Begin

          if not Plugins[PlugIndex].Created[fch] then
           Begin
             Plugins[PlugIndex].Create(fch,TMTAPI(mtapi_).API);
             Plugins[PlugIndex].Created[fch] := True;
           End;

End;

Function TMtBBS.ZenToHan (s : String):String;     // 全角->半角
Var
  i : Integer;
  c : Char;
Begin

    i := 1;

    While i<=Length(s) do
     Case s[i] of
       #$81     : Begin
                   If i < Length(s) then
                     Begin
                       Inc(i);
                       c := s[i];
                       Case c of
                         #$40       : Result := Result + ' ';
                         #$46       : Result := Result + ':';
                         #$47       : if i>1 then Break
                                             else Inc(i);
                         #$48       : Result := Result + '?';
                         #$7B       : Result := Result + '+';
                         #$7C       : Result := Result + '-';
                       else
                         Result := s[i-1]+c;
                       End;
                     End;
                    inc(i);
                 End;

       #$82     : Begin
                   If i < Length(s) then
                     Begin
                       Inc(i);
                       c := s[i];
                       Case c of
                         #$4f..Char($6f+$a) : Result := Result + Char($30-$4f+Byte(c));
                         #$81..Char($90+$a) : Result := Result + Char($61-$81+Byte(c));
                       else
                         Result := s[i-1]+c;
                       End;
                     End;
                    inc(i);
                 End;
      else
       Begin
        Result := Result + s[i];
        Inc(i);
       End;

    End;

End;


Function TMtBBS.CheckPluginCommand(s : String) : Boolean;
Var
   a   : String;
   i,x : Integer;
   GetMtbbsAPIAddress : TProcedure;
Begin

    s := UpperCase(s + ZenToHan(CommandLine));

    Result := False;
     x := -1;

     If Copy(User.Where,1,4) = 'Main' then
        For i := 0 to PluginsCount-1 do
          If Plugins[i].MainCommand = Copy(s,1,Pos(';',s+';')-1) then
             x := i;
     If Copy(User.Where,1,4) = 'Chat' then
        For i := 0 to PluginsCount-1 do
          If Plugins[i].ChatCommand = Copy(s,1,Pos(';',s+';')-1) then
             x := i;

     If (x>-1) and Assigned(Plugins[x].Call) then
       Begin

          Result := True;

          If User.Level < Plugins[x].CanUseLevel then
           Begin
              Sendln('*** Unauthorized use. ***');
              Exit;
           End;
          CommandLine := Copy(s,Pos(';',s+';')+1,255);


          PluginCreate(x);

          Try
            Plugins[x].Call(fch);
          Except
            Sendln(#13#10'*** A plugin error has occured. ***');
          End;
          CommandLine := '';
       End;

End;


Procedure TMtBBS.Version;
Var
   i : Integer;
   Hour,Min,Sec,MSec : Word;
Begin

 Puts(HostVersionMessage+#13#10);
 DecodeTime(Now - SystemStartDateTime,Hour,Min,Sec,MSec);
 Sendln(Format('<<　Uptime [ %.4dd %.2dh %.2dm%.2ds (Start:'+DateTimeToStr(SystemStartDateTime)+') ] >>',[Trunc(Now - SystemStartDateTime),Hour,Min,Sec]));

  If PluginsCount= 0 then
     SendLn('<< No plugins installed. >>')
   else
    Begin
      SendLn(Format('<< %.d plugins installed. >>',[PluginsCount]));
      Sendln('-----------------------------------------------------------');
       For i := 0 to PluginsCount - 1 do
        Begin
          Sendln(Plugins[i].Information);
          Sendln('-----------------------------------------------------------');
        End;
    End;

End;


Procedure TMtBBS.Main;
Var
    Cl : String;
    MtbbsGame : TMtbbsGame;
Begin

 While True Do
  Begin

     CommandLine := '';
     If MainInChat then
        Begin
           User.Where  := 'Main[Chat]';
           SendLn('*** Type C to return to the chat room. ***');
        End
     else User.Where  := 'Main';

     SendLn(Format('*CH%.2d*',[FCh]));

     Cl := UpperCase(InputCommand('MAIN (A,C,E,F,H,I,K,L,M,N,O,R,T,U,W,X,Y,#,?,G)>',True));

      If Not CheckPluginCommand(cl) Then

       Case (
       cl+'*')[1] of
          'W' : Who;
          'M' : Mail;
          'Y' : Puts(#13#10+SysInfoMessage+#13#10);
          '_' : Version;
          '#' : SendUserInfo;
          'C' : If MainInChat then
                 Begin
                  SendLn('*** メインから復帰しました ***');
                  MainInChat := False;
                  Exit;
                 End
                 else Chat;
          'T' : Telegram;
          'A' : Apply;
          'U' : Users;
          'N' : News;
          'K' : Kill;
          'I' : Install;
          'L' : Log;
          'H' : Puts(#13#10+MakeText(HelpMessage)+#13#10);
          'O' : Profile;
          'S' : SysopCall;
          'G' :  If MainInChat then SendLn('*** You have entered a chatroom. ***')
                               else Goodbye(False);
          'Q' :  If MainInChat then SendLn('*** You have entered a chatroom. ***')
                               else GoodBye(True);
          'R' : ReadMessage;
          'E' : Enter;
          'X' : Ip;
          'P' : FreePost;
          '@' : Sysop;
          'F' : FileMain;
          '%' : ChangeMode;
          '!' : Begin
                  MtbbsGame := TMtbbsGame.Create(Self);
                  MtbbsGame.Terminated := @Terminated;
                  Try
                    MtbbsGame.Main;
                  Finally
                    MtbbsGame.Free;
                  End;
                End;

          '*','?' : Puts(#13#10+MakeText(MainMenuMessage)+#13#10);
        else
          Puts('*** Invalid command. ***'#13#10);
        Puts(#13#10+MakeText(MainMenuMessage)+#13#10);
       End;

     If Terminated then Exit;

  End;

End;

Function TMtBBS.CheckUseLevel(kinou : TKinou):Boolean;   //注)(Result = True).. 使用禁止
Begin

    If GeneralDefine.CanUseLevels[Kinou][User.Level] then
       Result := False
    Else Begin
       SendLn('*** Unauthorized use. ***');
       If  (GeneralDefine.Apply.AutoRegist)
        and GeneralDefine.CanUseLevels[Kinou][GeneralDefine.Apply.StartLevel]
        and (User.Level = 0)
       then
         SendLn('Type in "A" to register an account.');

       Result := True;
    End;

End;






Procedure TMtBBS.RecvTelegram;
Var
   i : Integer;
Begin

  For i := 0 to Telegrams.Count -1 Do
   Begin
     Sendln('============================================================');
     SendLn('Private message from: '
          +Copy(Telegrams[i],1,Pos(#1,Telegrams[i])-1)
          +' .');
     SendLn(Copy(Telegrams[i],Pos(#1,Telegrams[i])+1,256));
     SendLn('============================================================');
     If User.ReceiveTelegramBell then Puts(#7);
   End;

   Telegrams.Clear;

End;

Function TMtBBS.IsUsedWWWch(c : integer) : Boolean;
Begin
           Result := False;
           If (c>89) and (c<100) then
              Result := wwwusers[99-c].Enabled;
end;


Procedure TMtBBS.SendTelegram(ch : Integer;Mes : String);
Var
  i,j : Integer;

Begin

   If CheckUseLevel(_Telegram) then Exit;

   Sendln('');

  Case Ch of
   100 : Begin
          j := 0;
           For i := 0 to 99 do
            Begin
              if (Fch<>i) and (MainForm.Chs[i].Thread <> nil) then
               Begin
                 MainForm.Chs[i].Thread.Telegrams.Add(Format('CH%.2d %.14s',[Fch,User.HandleName])+#1+Mes);
                 Inc(j);
               End;
            End;
         Sendln(Format('All %d logged in users should read this PM.',[j]));
         Sendln('');
        End;
   101 : MtbbsSts('Private message from: '+Format('CH%.2d %.14s',[Fch,User.HandleName])
          +'.'#13#10+Copy(Mes,1,256));
   Else
        Begin

         if (TMainForm(FOwner).Chs[ch].mode = Cm_None) and not(IsUsedWWWch(ch)) then
          Begin
           Sendln('** Not logged in. **'#13#10);
           Sendln('The private message has failed to arrive...');
           Exit;
          End;


           if IsUsedWWWch(ch) then
            Begin
              wwwusers[99-ch].Telegrams.Add(
                 Format('CH%.2d %.14s',[Fch,User.HandleName])+#1+Mes);
              Sendln(WWWUsers[99-ch].User.HandleName+' has received the PM.');
            End
            Else
             Begin
              MainForm.Chs[ch].Thread.Telegrams.Add(
                 Format('CH%.2d %.14s',[Fch,User.HandleName])+#1+Mes);
              Sendln(TMainForm(FOwner).Chs[ch].Thread.User.HandleName+' should have read the PM');
             End;

         Sendln('');
        End;
   End;

End;

Function TMtBBS.MakeMailHead(Mail : TMail;idx : Integer) : String;
var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
  a,b,fn : String;
begin

  DecodeDate(Mail.DateTime,Year,Month, Day);
  Year := Year - 1900;
  If Year > 99 then Year := Year - 100;
  DecodeTime(Mail.DateTime,Hour,Min, Sec, MSec);

   Case Mail.Status of
       MS_Read : a := ' (Seen)';
     MS_NoRead : a := '';
   End;


   If Mail.IsBMail then
    Begin
      fn := FMailFilePath+Format('%.2d\%.2d.BIN',[idx div 100,idx mod 100]);
      b := ' (Binary)';

      If FileExists(fn) then
         b:=b +'   '+IntToStr(GetFileSize(Fn))+ ' bytes';
    End
    Else
      a:='';

     Result :=
       Format('Private messages from: %s to: %s',[Mail.FromID+' '+Mail.MailFrom,Mail.ToID+' '+Mail.MailTo])+a+#13#10
      +Format('Time: %.2d/%.2d/%.2d %.2d:%.2d:%.2d',[Year,Month,Day,Hour,Min,Sec])+#13#10
      +'Subj: '+Mail.Title+b+#13#10;



end;



Procedure TMtbbs.RecordReadMail(Mail : TMail);
Var
  Mail_ : TMail;
Begin

   If (Mail.ToID = User.ID) and (Mail.Status = ms_NoRead) then
      If Pos('Delivery record',Mail.Title)>0 then
        Begin
          Mail_.Status    := Ms_NoRead;
          Mail_.IsBmail   := False;
          Mail_.FromId    := 'SYSTEM';
          Mail_.MailFrom  := 'Mail system';
          Mail_.DateTime  := Now;
          Mail_.Title     := 'E-Mail delivery notification';
          Mail_.ToID      := Mail.FromID;
          Mail_.MailTo    := Mail.MailFrom;
          MailSystem.Write(Mail_,
            '本日下記のとおり電子郵便(配達記録)を配達しましたからご通知いたします。'#13#10
           +#13#10
           +'==============================================='#13#10
           +'宛先  ID     : '+Mail.ToID+#13#10
           +'      HANDLE : '+Mail.MailTo+' 様'#13#10
           +'配達日時     :'+DateTimeToStr(Now)+#13#10
           +'題名         :'+Mail.Title+#13#10
           +'==============================================='#13#10);
        End;

End;

Procedure TMtbbs.Mail;
Var

      Mail       : TMail;
      MailsIndex : Array [0..99] of Integer;
      c          : String;
      MailsCount : Integer;

      IncludeRecvMail,IncludeSendMail : Boolean;

   Procedure List;
   Var
     a : string;
     i : Integer;
   Begin

       MailsCount := MailSystem.Sort(@MailsIndex,99,User.ID,IncludeRecvMail,IncludeSendMail);

       If IncludeRecvMail then a := '[Received mail]';
       If IncludeSendMail then a := a+'[Sent mail]';
       Sendln(#13#10'List : '+a);

       Sendln('No  Sender  Recvr    Date　   Status  Title　');
       Sendln('-- -------- -------- -------- ---- ----------------------------------------');
       if MailsCount = 0 then
          Sendln('<< No messages. >>')
       Else
        For i :=0 to MailsCount-1 Do
          Begin
            Mail := MailSystem.ReadHead(MailsIndex[i],False);
            Case Mail.Status of
               MS_NoRead : A := 'Unread';
               MS_Read   : A := 'Read';
            End;
            Sendln(Format('%.2d %.8s %.8s %.8s %.4s %.40s',[i+1,mail.FromID+'         ',Mail.ToID+'         ',DateToStr(Mail.DateTime)+'         ',a+'         ',Mail.Title]));
          End;
       Sendln('-- -------- -------- -------- ---- ----------------------------------------');

   End;

   Procedure InputKind;
   Begin

      c := UpperCase(InputCommand(#13#10'MAILLIST ([RET]:All  S:Outbox  R:Inbox  0:end)>',True)+'*');
      Case c[1] of
        '*' : Begin
                IncludeRecvMail := True;
                IncludeSendMail := True;
                List;
              End;
        'S' : Begin
                IncludeRecvMail := False;
                IncludeSendMail := True;
                List;
              End;
        'R' : Begin
                IncludeRecvMail := True;
                IncludeSendMail := False;
                List;
              End;
        '0' : Sendln('*** Re-reading as per selected parameters. ***');
      End;

   End;

   Procedure NumberRead;
   Var
      n : Integer;
   Begin

       While Not Terminated do
       Begin

         c := InputCommand(#13#10'Read which number? (?:list 0:end)>',False);
         If c = '?' then
            List
         Else
          Begin
           n := StrToIntDef(c,-1)-1;
           if n = -1 then Exit;

           If (-1 < n) and (n < MailsCount) then
            Begin
              if Mails[MailsIndex[n]].ToID = User.ID then
                  Mail := MailSystem.ReadHead(MailsIndex[n],True)
              else
                  Mail := MailSystem.ReadHead(MailsIndex[n],False);

              If (Mail.Status <> MS_Deleted) and ((Mail.ToID = User.ID) or (Mail.FromID = User.ID)) then
               Begin
                 Puts(#13#10+MakeMailHead(Mail,MailsIndex[n]));
                 Puts(#13#10+MailSystem.ReadText(MailsIndex[n])+#13#10);
                 If Mail.IsBMail then
                   DownloadBMail(MailsIndex[n],Mail);
                 If YesNoInput('Confirm deletion? (Y/N)>') then
                    MailSystem.Kill(MailsIndex[n]);
                 RecordReadMail(Mail);
               End
               Else
                 Sendln('Deleted.');

            End
            Else
              Sendln('*** Type in a valid number. ***');
          End;
       End;
   End;
Begin

  If User.Level = 0 then
    Begin
       Sendln('*** Feature unavailable to guests. ***');
       Exit;
    End;

   If CheckUseLevel(_Mail) then Exit;

    IncludeRecvMail := True;
    IncludeSendMail := False;
    List;

             While Not Terminated do
              Begin
               c := InputCommand(#13#10'MAIL ([RET]:Read  L:Set parameters  #:Read by number  0:end)>',True)+'*';
               Case c[1] of
                 '*' : ReadMail(MailsIndex,MailsCount);
                 'L' : InputKind;
                 '#' : NumberRead;
                 '0' : Break;
               End;
              End;


End;

Procedure TMtBBS.DownLoadBMail(MailIndex : Integer;Mail : TMail);
Var
 Fn : String;
 s  : String;
Begin

       Fn := FMailFilePath+Format('%.2d',[mailindex div 100]);
       Fn := Fn +  Format('\%.2d.BIN',[mailindex mod 100]);

        While Not Terminated do
         Case UpperCase(InputCommand(#13#10'BMAIL (X:XMODEM  Y:YMODEM  G:YMODEM-g  Z:ZMODEM  M:M-LINK  0:end)>',true)+'*')[1] of
            '0'     : Break;
            'X'     : Begin
                         DownloadFile(Fn,Mail.Title,'XMODEM');
                         Break;
                      End;
            'Y'     : Begin
                         DownloadFile(Fn,Mail.Title,'YMODEM');
                         Break;
                      End;
            'Z'     : Begin
                         DownloadFile(Fn,Mail.Title,'ZMODEM');
                         Break;
                      End;
            'M'     : Begin
                         DownloadFile(Fn,Mail.Title,'MLINK');
                         Break;
                      End;
         End;

End;

Function TMtBBS.UpLoadBMail(MailIndex : Integer;Mail : TMail):String;
Var
 Fn : String;
 s  : String;
Begin

       Fn := FMailFilePath+Format('%.2d',[mailindex div 100]);
       Fn := Fn +  Format('\%.2d.BIN',[mailindex mod 100]);

       Result := Fn;

        While Not Terminated do
         Case UpperCase(InputCommand(#13#10'BMAIL (X:XMODEM  Y:YMODEM  G:YMODEM-g  Z:ZMODEM  M:M-LINK  0:end)>',true)+'*')[1] of
            '0'     : Break;
            'F'     : Begin
                         UploadFile(Fn,'FTP');
                         Break;
                      End;
            'X'     : Begin
                         UploadFile(Fn,'XMODEM');
                         Break;
                      End;
            'Y'     : Begin
                         UploadFile(Fn,'YMODEM');
                         Break;
                      End;
            'Z'     : Begin
                         UploadFile(Fn,'ZMODEM');
                         Break;
                      End;
            'M'     : Begin
                         UploadFile(Fn,'MLINK');
                         Break;
                      End;
         End;

End;

Procedure TMtBBS.ReadMail(MailsIndex : Array of Integer;MailsCount : Integer);
Var
  i,Dir      : Integer;
  Mail       : TMail;
  c          : String;
Begin

   if MailsCount = 0 then
    Begin
      Sendln('*** No mail. ***');
      Exit;
    End;

   i := 0;
   dir := +1;

   While (-1<i) and (i < MailsCount) and (Not Terminated) Do
    Begin

      if Mails[MailsIndex[i]].ToID = User.ID then
          Mail := MailSystem.ReadHead(MailsIndex[i],True)
      else
          Mail := MailSystem.ReadHead(MailsIndex[i],False);

       If (Mail.Status <> MS_Deleted) and ((Mail.ToID = User.ID) or (Mail.FromID = User.ID)) then
         Begin

           Puts(#13#10+MakeMailHead(Mail,MailsIndex[i]));
           Puts(#13#10+MailSystem.ReadText(MailsIndex[i])+#13#10);

           If Mail.IsBMail then
              DownLoadBMail(MailsIndex[i],Mail);

           If YesNoInput('Confirm deletion? (Y/N)>') then
              MailSystem.Kill(MailsIndex[i]);
           RecordReadMail(Mail);

           If  Not( (-1<i) and (i < MailsCount) ) then Break;

             While Not Terminated do
              Begin
               c := InputCommand(#13#10'[RET]:next  P:prev  R:reply  +:frwd  -:back  0:end >',True)+'*';
               Case c[1] of
                 '*' : Begin
                         I := i + Dir;
                         Break;
                       End;
                 'P' : Begin
                         Dec(i);
                         Break;
                       End;
                 'R' : WriteResMail(Mail);
                 '+' : Begin
                        Dir := +1;
                        Puts('  < Sort by date. >'#13#10);
                       End;
                 '-' : Begin
                        Dir := -1;
                        Puts('  < Sort in reverse order. >'#13#10);
                       End;
                 '0' : Begin
                        i := -1;
                        Break;
                       End;
               End;
              End;
         End
          Else
           I := i + Dir;
    End;

    Sendln('');

End;

Procedure TMtBBS.WriteResMail(ResMail : TMail);
Var
  Mail : TMail;
  MailText : String;
  i  : Integer;
Begin

  If  SearchUser(ResMail.FromID) = -1 then
    Begin
       Sendln('*** '+ResMail.FromID+' is a non-existent ID. ***');
       Exit;
    End;

   Mail.Status    := Ms_NoRead;
   Mail.FromId    := User.ID;
   Mail.MailFrom  := User.HandleName;
   Mail.MailTo    := ResMail.MailFrom;
   Mail.ToID      := ResMail.FromID;
   Mail.DateTime  := Now;
   Mail.Title := 'Re:'+ResMail.Title;
   Sendln('');

   Puts(#13#10+MakeMailHead(Mail,-1)+#13#10);

   if Not YesNoInput('Confirm your submission? (Y/N/Quit)>') Then
     Begin
        Puts('** Writing has been cancelled. **'#13#10);
       Exit;
     End;

   if Terminated then Exit;

   MailText := InputText;
  If MailText = '' then
    Begin
     Puts('** Writing has been cancelled. **'#13#10);
     Exit;
    End;

   Puts('Currently writing　...');

   If (MailSystem.Write(Mail,MailText))=-1 then
          Sendln( 'Failed to write. '
                 +Mail.ToID+' '+Mail.MailTo
                 +' Cause:'+MailSystem.LastErr)
   else
     Begin
        For i := 0 to 99 do
            if (MainForm.Chs[i].Thread <> nil)
               and (MainForm.Chs[i].Thread.User.ID = Mail.ToID)  then
                  MainForm.Chs[i].Thread.Telegrams.Add('<< MTBBS SYSTEM >>'+#1
                  +Format('CH%.2d %s %s has sent you an e-mail.',[Fch,User.ID,User.HandleName]));
       Sendln('Finished.'#13#10)
     End;

End;

Function TMtBbs.InputTitle : String;
Begin

  If CommandLine = '' then
    Begin
      Sendln('              ____________________________________________________________');
      Result := InputCommand2('Subject >');
    End
    Else
      Result := InputCommand2('');

End;


Procedure TMtBBS.WriteMail(IsBMail : Boolean);
Var
  s : String;
  i,j,idx : Integer;

  Mail : TMail;
  MailText : String;

  Ids      : Array[0..99] of Integer;
  IdsCount : Integer;

  RecvFileName : String;

  Procedure InputSendIDs;
  Var
     c   : string;
     n,i : Integer;
  Begin

      While Not Terminated Do
       Begin
         c := UpperCase(InputCommand(#13#10'Enter the recipient'
                        +' ID(s). Max: '
						+IntToStr(GeneralDefine.Mail.OneSendMax)
						+'(?:List members C:cancel 0:end)>',False));

         If Terminated then Exit;
          If c='' then Break;
          If Length(c)=1 then
            Case c[1] of
              '?'     : Users;
              'C'     : Begin
                        IdsCount := 0;
                        Exit;
                      End;
              '0'     : Break;
            End
            Else
              Begin
                 if GeneralDefine.Mail.OneSendMax <= IdsCount then
                    Sendln('*** No more IDs can be added. ***')
                 Else
                  Begin
                    n := SearchUser(c);
                    If  n = -1 then
                       Sendln('*** '+C+' is a non-existent ID. ***')
                    Else
                     Begin
                       For i:=0 to IdsCount - 1 do
                          If Ids[i] = n then
                           Begin
                            Sendln('*** '+C+' has already been added. ***');
                            n := -1;
                            Break;
                           End;
                       If n > -1 then
                        Begin
                          Ids[IdsCount] := n;
                          Inc(IdsCount);
                          Sendln('Mail No. '+IntToStr(IdsCount)+':'+UserInits[n].Id+' '+UserInits[n].Handle);
                        End;
                     End;
                  End;
              End;
       End;
  End;


Begin


  Puts('-- Writing an e-mail --'#13#10);

  If CheckUseLevel(_EnterMail) then Exit;

  IdsCount := 0;

  InputSendIDs;

  If IdsCount = 0 then
    Begin
       Sendln('*** E-Mail sending has been cancelled. ***');
       Exit;
    End;

   Mail.Status    := Ms_NoRead;
   Mail.FromId    := User.ID;
   Mail.MailFrom  := User.HandleName;
   Mail.MailTo    := UserInits[Ids[0]].Handle;
   Mail.ToID      := UserInits[Ids[0]].Id;
   Mail.MailFrom  := User.HandleName;
   Mail.DateTime  := Now;
   Mail.IsBMail   := IsBMail;

   Sendln('');

   For i := 0 to IdsCount - 1 Do
      Sendln('Mail to: '+UserInits[Ids[i]].Id+' '+UserInits[Ids[i]].Handle);

  If IsBMail then  Begin
                       Mail.Title := InputCommand2('Enter filename (RET:end)>');
                       If (Mail.Title='') then Exit;
                   End
             else  Begin
                       Sendln('※配達通知を希望する場合は、題名の頭に[配達通知]と書いてください.');
                       Mail.Title := InputTitle;
                   End;

  if Terminated then Exit;

   Puts(#13#10+MakeMailHead(Mail,-1));

   If IdsCount > 1 then
      Sendln('Broadcast (to '+IntToStr(IdsCount)+' people)');
   Sendln('');

  if Not YesNoInput('Confirm your action? (Y/N/Quit)>') Then
    Begin
     Puts('** Writing has been cancelled. **'#13#10);
     Exit;
    End;

  if IsBMail then
   Begin
     MailText := '';
     if YesNoInput('Would you like to put a comment? (Y/N) >') then
        Begin
          MailText := InputText;
          Puts('Writing comment　...');
        End;
   End
  else
   Begin
    MailText := InputText;
    If MailText = '' then
      Begin
        Puts('** Writing has been cancelled. **'#13#10);
        Exit;
      End;
    Puts('Currently writing　...');
   End;

   RecvFileName := '';


   For i := 0 to IdsCount - 1 Do
    Begin
       Mail.ToID   := UserInits[Ids[i]].Id;
       Mail.MailTo := UserInits[Ids[i]].Handle;
       idx := (MailSystem.Write(Mail,MailText));
       If idx>-1 then
        Begin
           if IsBMail then
              Begin
               if RecvFileName = '' then
                  RecvFileName := UpLoadBMail(idx,Mail)
               else
                 Begin
                    if not CopyFile(
                     Pchar(RecvFileName)
                    ,pchar(FMailFilePath+Format('%.2d\%.2d.BIN',[idx div 100,idx mod 100]))
                    ,False) then
                       sendln('Error: Cannot copy files.');
                 End;

              End;

           For j := 0 to 99 do
            if (MainForm.Chs[j].Thread <> nil)
               and (MainForm.Chs[j].Thread.User.ID = Mail.ToID)  then
                  MainForm.Chs[j].Thread.Telegrams.Add('<< MTBBS SYSTEM >>'+#1
                  +Format('CH%.2d %s %s has sent you an e-mail.',[Fch,User.ID,User.HandleName]));
        End
        Else
          Sendln( 'Failure. '
                 +Mail.ToID+' '+Mail.MailTo
                 +' Cause:'+MailSystem.LastErr);


    End;
  Sendln('Completed.'#13#10)

End;



Function TMtBBS.MakeMessageHead(Mes : TMessage) : String;
var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin

  DecodeDate(Mes.DateTime,Year,Month, Day);
  Year := Year - 1900;
  If Year > 99 then Year := Year - 100;
  DecodeTime(Mes.DateTime,Hour,Min, Sec, MSec);

     Result :=
       Format('Message  #%.4d is from: %s',[Mes.No,Mes.ID +' '+Mes.Handle])+#13#10
      +Format('Time: %.2d/%.2d/%.2d %.2d:%.2d:%.2d Section %d: %s',[Year,Month,Day,Hour,Min,Sec,Mes.BoardNo,MessageBoards[Mes.BoardNo].Title])+#13#10
      +'Subj: '+Mes.Title+#13#10;

End;

Function TMtBBS.InputUserID : Integer;
Var
  j : Integer;
  s : String;
Begin
    Result := -1;
   j := -1;
     Repeat
        s := UpperCase(InputCommand('Enter the user''s ID. (?:List users [RET]:end)>',false));
        if Terminated or (s='')then Exit;
        If s ='?' then Puts(#13#10+GetUserList+#13#10)
         Else
           j := SearchUser(s);
     Until (j > -1);
   Result := j;

End;

Procedure TMtBBS.InputProfile(Var UI : TUserInit;P : TProfileItem);
Const
  SS = '          ';
  BS = #8#8#8#8#8#8#8#8#8#8;
Var
   s :  String;

Begin

   Case P of
      _Address  :  s  := Input('Address (max 60) :');
      _Name     :  s  := Input('Name (max 30) :');
      _Tel      :  s  := Input('Phone (max 20) :');
      _Hobby    :  s  := Input('Hobbies (max 60) :');
      _BirthDay :  s  := Input('Birthdate (max 6) Example: 630620 :[      ]'#8#8#8#8#8#8#8);
      _Handle   :  s  := Input('Handle (max 14): ');
      _Comment  :  s  := Input('Biography (max 160)'#13#10+':>');
      _EMail    :  s  := Input('E-Mail  (max 45) :');
   End;

   Case P of
      _Address  :  UI.Address  := s;
      _Name     :  UI.Name     := s;
      _Tel      :  UI.TelNo    := s;
      _Hobby    :  UI.Hobby    := s;
      _BirthDay :  UI.BirthDay := s;
      _Handle   :  UI.Handle   := s;
      _Comment  :  UI.Comment  := s;
      _Email    :  UI.Email    := s;
   End;


End;


Function TMtBBS.InputFileBoardNo(AK : TBoardAccessKind) : Integer;
Const
  spc = '                                ';
Var
  s : String;
  b : Boolean;
Begin

  Result := 0;

  While True do
   Begin
     s := InputCommand(#13#10'Enter file board number. (?:List boards  0:end)>',False);
     Result := 0;
     if Terminated then Exit;
     if StrToIntDef(s,-1)=0 then Exit;
     if (StrToIntDef(s,1)<0) or (99 < StrToIntDef(s,1)) then
        Puts('Board 1 to 99'#13#10)
     Else
      Begin
        if s='?' then FBoards
          else
            If S<>'' then
               Begin
                 Result := FileBoardNameToIndex(s);
                  if FileBoards[Result].Enabled Then
                   Begin
                      Case AK of
                        AK_Read  : b := FileBoards[Result].ReadLevel  <= User.Level;
                        AK_Write : b := FileBoards[Result].WriteLevel <= User.Level;
                      End;
                      if b then
                       Begin
                        If Result > 0 then
                         Begin
                          With FileBoards[Result] do
                            Puts(#13#10+Format('%.4d: %.8s %.32s',[Result,Name+Spc,Title+Spc+Spc])+#13#10#13#10);
                          Exit;
                         End;
                       End Else
                         Puts(#13#10'*** Access denied. ***'#13#10);
                   End Else
                         Puts(#13#10'*** Board does not exist. ***'#13#10);
               End;
      End;
     CommandLine := '';
   End;

End;



Function TMtBBS.InputBoardNo(AK : TBoardAccessKind) : Integer;
Const
  spc = '                                ';
Var
  s : String;
  b : Boolean;
Begin

  Result := 0;

  While True do
   Begin
     s := InputCommand(#13#10'Enter message board number. (?:List boards　0:end)>',False);
     Result := 0;

     if Terminated then Exit;
     if StrToIntDef(s,-1)=0 then Exit;
     if (StrToIntDef(s,1)<0) or (99 < StrToIntDef(s,1)) then
        Puts('Boards from 1 to 99.'#13#10)
     Else
      Begin
        if s='?' then Boards
          else
            If S<>'' then
               Begin
                 Result := BoardNameToIndex(s);
                  if MessageBoards[Result].Enabled Then
                   Begin
                      Case AK of
                        AK_Read  : b := MessageBoards[Result].ReadLevel  <= User.Level;
                        AK_Write : b := MessageBoards[Result].WriteLevel <= User.Level;
                      End;
                      if b then
                       Begin
                        If Result > 0 then
                         Begin
                          With MessageBoards[Result] do
                            Puts(#13#10+Format('%.4d: %.8s %.32s',[Result,Name+Spc,Title+Spc+Spc])+#13#10#13#10);
                          Exit;
                         End;
                       End Else
                         Puts(#13#10'*** Access denied. ***'#13#10);
                   End Else
                         Puts(#13#10'*** Board does not exist. ***'#13#10);
               End;
      End;
     CommandLine := '';
   End;

End;

Function TMtBBS.InputText : String;
Var

    S : String;
    i : Integer;

   Function GetText : String;
   Begin
      Result := '';
      Puts(#13#10);
      Puts('Enter your message. Max 1024 bytes and 2000 lines.'#13#10);
      Puts('To finish, enter "//" and hit Return.'#13#10);
      Puts('----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+---'#13#10);

      While True Do
        Begin
         if i >= 2000 then
          Begin
           Sendln('*** No more can be written. ***');
           Break;
          End;
         s := Copy(RecvLn,1,1024);
         if Terminated then Exit;
         if (s = '.') or (s = '..') or (s = '//') or (s = '／／') then Break;
         Result := Result + s + #13#10;
         Inc(i);
        End;
   End;


Begin

   CommandLine := 'N';
      i := 0;

     While Not Terminated Do
       Begin
         s := UpperCase(InputCommand('EDIT (S:Send  L:Re-read  C:Add  0:Abort)>',True))
           +'*';
         Case s[1] of
            'S' : Exit;
            'L' : Puts(#13#10+Result+#13#10);
            'C' : Result := Result + GetText;
            'N' : Begin
                     i := 0;
                     Result := GetText;
                  End;
            '0' : Break;
         End;
       End;

    Result := '';

End;


Procedure TMtBBS.ReadBoard( BoardNo,StartNo,direction : Integer);
Var
      i   : Integer;
      c   : String;
      Mes : TMessage;
      dir : Integer;
Begin

  If StartNo > MessageBoards[BoardNo].MaxMessageNo then
          i := MessageBoards[BoardNo].MaxMessageNo
   Else
          i := StartNo;

  Dir := direction;

      While (0 < i) and (Not Terminated) do
        Begin

            Mes := MessageBoard.Read(BoardNo,i);

            Case Mes.No of
                 0 : Puts('         #'+Format('%.4d',[i])+'      *** Deleted. ***'#13#10);
                -1 : Break;
               else
                 Begin
                    Puts(#13#10+MakeMessageHead(Mes)+#13#10);
                 End;
            End;

           If GeneralDefine.Other.ReadPromptBeforeMessage Then
            While Not Terminated do
             Begin
               c := UpperCase(InputCommand('[RET]:read  N:next  P:prev  R:reply  +:frwd  -:back  0:end >',True))+'*';
               Case c[1] of
                 '*' : Begin
                         if Mes.No > 0 then
                          Begin
                            Puts(Mes.Text);
                            If User.Options.AddMessageEof then
                                 SendLn('//');
                          End;
                         I := i + Dir;
                         Break;
                       End;
                 'N' : Begin
                         Inc(i);
                         Break;
                       End;
                 'P' : Begin
                         Dec(i);
                         Break;
                       End;
                 'R' : WriteRes(BoardNo,i);
                 '+' : Begin
                        Dir := +1;
                        Puts('  < Sort by date. >'#13#10);
                       End;
                 '-' : Begin
                        Dir := -1;
                        Puts('  < Sort inverse. >'#13#10);
                       End;
                 '0' : Begin
                        i := -1;
                        Break;
                       End;
               End;
            End
           else
            Begin
            if Mes.No > 0 then
              Begin
                Puts(Mes.Text+#13#10);
                If User.Options.AddMessageEof then
                      SendLn('//');
              End;
             While Not Terminated do
              Begin
               c := UpperCase(InputCommand('[RET]:next  P:prev  R:reply  +:frwd  -:back  0:end >',True))+'*';
               Case c[1] of
                 '*' : Begin
                         I := i + Dir;
                         Break;
                       End;
                 'P' : Begin
                         Dec(i);
                         Break;
                       End;
                 'R' : WriteRes(BoardNo,i);
                 '+' : Begin
                        Dir := +1;
                        Puts('  < Sort by date. >'#13#10);
                       End;
                 '-' : Begin
                        Dir := -1;
                        Puts('  < Sort inverse. >'#13#10);
                       End;
                 '0' : Begin
                        i := -1;
                        Break;
                       End;
               End;
              End;
            End;


        End;
End;


Procedure TMtBBS.News;
Var
   s        : String;
   UI       : TUserInit;
   NewsDate : TDateTime;
   EP,MP,i   : Integer;
   AutoRead : Boolean;
   ReadStartTime : TDateTime;

      Procedure Readm(BoardNo,SN,EN : Integer);
      Var
         Messages : Array [0..30] of TMessage;
         l,m      : Integer;
      Begin
        For l := 0 to (EN - SN) Div 30 Do
          Begin
             For m := 0 to MessageBoard.Readm(BoardNo,Sn + l*30,SN + l*30+29,Messages)-1 Do
               Begin
                 Puts(#13#10+MakeMessageHead(Messages[m])+Messages[m].Text);
                 If User.Options.AddMessageEof then
                    Sendln('//');
               End;
          End;
        Sendln('');
      End;

Begin

    User.Where := 'News';

    ReadStartTime := Now;


    If User.Level <1 then
      UI.LastRead := User.LastRead //ゲスト
    else
      UI := GetUserInit(User.ID);

     AutoRead := False;
     NewsDate := User.LastRead;

         While True Do
          Begin
            if Terminated then Exit;

             If CommandLine<>'' then S := CommandLine+'*'
                                Else S := Input(#13#10'NEWS: ..+[@]Consecutive +[Unread date]([RET]: "'+DateTimeToStr(UI.LastRead)+'" )>')+'*';
             If s='' then Break;

             If  Pos('@',CommandLine+s) > 0  then
                     AutoRead := True;

              For i:= 1 to Length(s) do
                Case S[i] of
                 '0','1','2','3','4','5','6','7','8','9' :
                   Begin
                     s := Copy(s,1,Length(s)-1);
                     if Pos('@',s) > i then s := Copy(s,i,Pos('@',s)-i)
                                       else s := Copy(s,Pos('@',s)+1,99);
                     NewsDate := StrToDateTimeDef(s,EncodeDate(1,1,1));
                     If EncodeDate(1,1,1) = NewsDate then
                      Begin
                        S := '';CommandLine := '';
                        NewsDate := UI.LastRead;
                        Puts('*** Date and time format incorrect. *** Ex: 97/01/01'#13#10);
                        Break;
                      End
                      else
                        Break;
                   End;
                End;
              If s <>'' then Break;
          End;

    CommandLine := '';
    Puts('Read starting from '+DateTimeToStr(NewsDate)+'.'#13#10);
    Puts(#13#10);

     For i:=1 to 99 do
       With MessageBoards[i] do
          if Enabled and (ReadLevel <= User.Level) then
            Begin
              MessageBoard.GetMidokuPoint(i,NewsDate,EP,MP);
              Puts(Format('%.4d: %.8s %.32s･ 総数: %.4d ',[i,Name+Spc,Title+' ････････････････････････････････････････････････････････････････',EP]));

              If User.NewsEnableBoards[i] then
               Begin
                If Ep >= Mp then
                 Begin
                  Puts(#13#10);
                  Puts(#13#10'You have '+IntToStr(Ep-Mp + 1)+' new messages.'#13#10);
                  if AutoRead then
                        Readm(i,Mp,Ep)     //　連続読み
                  else
                   While True Do
                    Begin
                     s := UpperCase(InputCommand(#13#10'[RET]:read  S:skip  0:end >',True))+'*';
                     If Terminated then Exit;
                      Case S[1] of
                       '*' : Begin
                             ReadBoard(i,Mp,1);
                             Puts(#13#10);
                             Break;
                            End;
                       'S' : Begin
                             Puts(' *** Skipped. ***'#13#10#13#10);
                             Break;
                            End;
                       '0' : Begin
                             Puts(#13#10);
                             Exit;
                            End;
                      End;
                    End;
                 End
                 Else
                   Sendln('... Unread.');
               End
               Else
                 Sendln('... Skipped.');
            End;
   Puts(#13#10);
   UI.LastRead := ReadStartTime;
   User.LastRead := ReadStartTime;

    if User.Level > 0 then
        OutUserInit(User.ID,UI);

End;




Procedure TMtBBS.FileNews;
Var
   s        : String;
   UI       : TUserInit;
   NewsDate : TDateTime;
   EP,MP,i  : Integer;
   ReadStartTime : TDateTime;
   AddText : Boolean;

      Function MakeFileHead(FileInfo : TFileInfo): String;
      Var
         FSize : String;
      Begin

              If FileInfo.FileSize < 10000 then FSize := Format('%.4d',[FileInfo.FileSize])
                    else
                      If FileInfo.FileSize < 1000*1000 then FSize := Format('%.3dK',[FileInfo.FileSize Div 1000])
                        else
                          FSize := Format('%.3dM',[FileInfo.FileSize Div (1000*1000)]);
              Result := Format('%.3d:%.12s %.4s %.3d %.8s %.8s %.35s'
                  ,[FileInfo.no,FileInfo.FileName+'             ',FSize,FileInfo.Download,DateToStr(FileInfo.DateTime)+'             ',FileInfo.ID+'        ',FileInfo.Title]);

      End;

      Procedure Readm(BoardNo,SN,EN : Integer);
      Var
         Files : Array [0..30] of TFileInfo;
         l,m      : Integer;
      Begin
        For l := 0 to (EN - SN) Div 30 Do
          Begin
             For m := 0 to FileBoardReadm(BoardNo,Sn + l*30,SN + l*30+29,Files)-1 Do
               Begin
                 Sendln(MakeFileHead(files[m]));
                 If AddText and (Length(Files[m].Text)>0) then
                    Puts(#13#10+Files[m].Text+#13#10);

               End;
          End;
        Sendln('');
      End;

Begin

    AddText := False;

    User.Where := 'FileNews';
    ReadStartTime := Now;

    If User.Level <1 then
      UI.LastFileNews := User.LastFileNews //ゲスト
    else
      UI := GetUserInit(User.ID);

     NewsDate := User.LastFileNews;

         While True Do
          Begin
            if Terminated then Exit;

             If CommandLine<>'' then S := CommandLine+'*'
                                Else S := Input(#13#10'FILE NEWS: +[@]Read with descrption +[Search by date]([RET]:'+DateTimeToStr(UI.LastFileNews)+')>')+'*';
             If s='' then Break;

              If  Pos('@',CommandLine+s) > 0  then
                     AddText := True;
              For i:= 1 to Length(s) do
                Case S[i] of
                 '0','1','2','3','4','5','6','7','8','9' :
                   Begin
                     s := Copy(s,1,Length(s)-1);

                     if Pos('@',s) > i then s := Copy(s,i,Pos('@',s)-i)
                                       else s := Copy(s,Pos('@',s)+1,99);
                     NewsDate := StrToDateTimeDef(s,EncodeDate(1,1,1));
                     If EncodeDate(1,1,1) = NewsDate then
                      Begin
                        S := '';CommandLine := '';
                        NewsDate := UI.LastFileNews;
                        Puts('*** Date and time format incorrect. *** Ex:97/01/01'#13#10);
                        Break;
                      End
                      else
                        Break;
                   End;
                End;
              If s <>'' then Break;
          End;

    CommandLine := '';
    Puts('Search by date: '+DateTimeToStr(NewsDate)+'.'#13#10);
    Puts(#13#10);

     For i:=1 to 99 do
       With FileBoards[i] do
          if Enabled and (ReadLevel <= User.Level) then
            Begin
              FileBoardGetMidokuPoint(i,NewsDate,EP,MP);
              Puts(Format('%.4d: %.8s %.32s･ 総数: %.4d ',[i,Name+Spc,Title+' ････････････････････････････････････････････････････････････････',EP]));
               If Ep >= Mp then
                 Begin
                  Sendln(#13#10'There are '+IntToStr(Ep-Mp + 1)+' new files.'#13#10);
                  Readm(i,Mp,Ep);     //　連続読み
                 End
                 Else
                   Sendln('････ No new arrivals');
            End;

     Puts(#13#10);
     UI.LastFileNews   := ReadStartTime;
     User.LastFileNews := ReadStartTime;

    if User.Level > 0 then
        OutUserInit(User.ID,UI);

End;


Procedure TMtBBS.ChangeMode;
Var
  s : String;
  i : Integer;
Begin

   s := UpperCase(CommandLine);

   If Pos('+M',s)>0     then User.Options.AddMessageEof := True;
   If Pos('-M',s)>0     then User.Options.AddMessageEof := False;

   If Pos('DOMO',s)>0 then
     For i := 0 to 99 do
        if (MainForm.Chs[i].Thread <> nil) then
           MainForm.Chs[i].Thread.Telegrams.Add('<< MTBBS SYSTEM >>'+#1+'Hello everyone!');
   If Pos('AHA',s)>0 then
     For i := 0 to 99 do
        if (MainForm.Chs[i].Thread <> nil) then
           MainForm.Chs[i].Thread.Telegrams.Add('<< MTBBS SYSTEM >>'+#1+'hahaha..(^^;');



End;


Procedure TMtBBS.Sysop;
Var
  c       : String;
  i,j     : Integer;
Begin

  If User.Level < GeneralDefine.User.SysopLevel then Exit;

//  User.Where := 'Sysop';

   Puts(#13#10+SysopMenuMessage+#13#10);

     While True do
      Begin
         c := UpperCase(InputCommand(#13#10'SYSOP (A,B,C,D,E,F,K,L,M,#,?,0)>',True)+'*');
         If Terminated then Exit;
          Case c[1] of
            '0'     : Break;
            '?','*' : Puts(#13#10+SysopMenuMessage+#13#10);
            'A'     : Begin
                        i := User.Level;
                        User.Level := 0;
                         Apply;
                        User.Level := i;
                      End;
            'Q'     : Begin
                        CommandLine := 'MYO';
                        Goodbye(true);
                        CommandLine := '';
                      End;

            'R'     : Begin
                          Puts(' * ');
                          EditDefine.LoadGeneralDefine;
                          Sendln('再ロードしました.... MyoHost.INI (総合設定)');
                          Puts(' * ');
                          EditDefine.LoadCanUseLevels;
                          Sendln('再ロードしました.... LEVELS.DAT  (機能別使用可能レベル)');
                          Puts(' * ');
                          MessageBoardsLoad;
                          Sendln('再ロードしました.... Boards.Dat  (メッセージボード)');
                          Puts(' * ');
                          FileBoardsLoad;
                          Sendln('再ロードしました.... FBoards.Dat (ファイルボード)');
                      End;
            'L'     : Begin
                        i := InputUserID;
                        If i > -1 then
                         Begin
                           PutProfile(i);
                           Sendln('Current user levels are '+IntToStr(UserInits[i].Level)+'です');
                           j := StrToIntDef(InputCommand(#13#10'Set a new user level? (-1～9 0:Deleted no.)>',true),-99);
                           If (-1<=j) and (j<=9) then
                             Begin
                              UserInits[i].Level := j;
                              Sendln('Level changed: '+IntToStr(j)+'.');
                              SaveUserInit(i);
                             End
                             Else
                              Sendln('No changes have been made.');
                         End;
                      End;
            'K'     : While Not Terminated do
                       Begin
                           c := InputCommand(#13#10'Which channel to open? (0-99 ?:Who RET:Abort)>',true);
                           If c='?' then Who
                           Else
                            Begin
                              i := StrToIntDef(c,-1);
                              If (i>-1) and (i<100) then
                                if MainForm.Chs[i].Mode <> cm_None then
                                 Begin
                                   MainForm.Kill(i);
                                   SendLn('Channel opened: '+IntToStr(i)+'.');
                                 End else
                                      SendLn('*** Not in use. ***');
                              Break;
                            End;
                       End;
          End;
      End;


End;

Procedure TMtBBS.Install;

Var
  c       : String;
  UI      : TUserInit;

     Procedure Entry;
     Var
        c : String;
        i : Integer;
     Begin

        While Not Terminated do
         begin
            c := InputCommand(#13#10'ENTRY (A:Register  D:Cancel  S:Register all  R:Cancel all ?:List boards 0:end)>',True)+'*';
            If Terminated then Exit;
            Case c[1] of
              '0' : Break;
              '?' : Boards;
              'A' :
                Begin
                  i := InputBoardNo(AK_Read);
                  if i>0 then
                   Begin
                     User.NewsEnableBoards[i] := True ;
                     Sendln('Board registered: '+IntToStr(i)+'.');
                   End;
                End;
              'D' :
                Begin
                  i := InputBoardNo(AK_Read);
                  if MessageBoards[i].EnforcedNews then
                    Sendln('*** Unskippable boards. ***')
                  Else
                   if i>0 then
                    Begin
                     User.NewsEnableBoards[i] := False;
                     Sendln('Skipping boards: '+IntToStr(i)+'.');
                    End;
                End;
              'S' :
                Begin
                  For i := 0 to 99 Do
                     User.NewsEnableBoards[i] := True ;
                  Sendln('All board have been registered.');
                End;
              'R' :
                Begin
                  For i := 0 to 99 Do
                    if MessageBoards[i].EnforcedNews then
                       User.NewsEnableBoards[i] := True
                    else
                       User.NewsEnableBoards[i] := False;
                  Sendln('All boards except unskippable ones have been ditched.');
                End;
               Else
                  Sendln('*** Invalid command. ***');
            End;
         End;

        UI.NewsEnableBoards := User.NewsEnableBoards;

     End;


Begin


  User.Where := 'Install';

  UI := GetUserInit(User.ID);

   Puts(#13#10+InstallMenuMessage+#13#10);

     While True do
      Begin
         c := UpperCase(InputCommand(#13#10'INSTALL (B,D,E,H,J,L,M,N,P,S,Y,?,0)>',True)+'*');
         If Terminated then Exit;
          Case c[1] of
            '0'     : Break;
            'N'     : Entry;
            '?','*' : Puts(#13#10+InstallMenuMessage+#13#10);
            'P'     : if User.Level<1 then Puts('*** Guest users cannot be configured. ***')
                      else UI.Password    := MakePassword;
            'R'     :
               While True Do
                Begin
                  UI.LastRead := StrToDateTimeDef(Input(#13#10'Unread date/time (YY/MM/DD HH:MM:SS) :'),EncodeDate(1,1,1));
                  If Terminated Then Exit;
                  User.LastRead := UI.LastRead;
                  If EncodeDate(1,1,1) = UI.LastRead then
                     Puts('*** Date/Time format is incorrect *** Ex: 97/01/01 10:10:10'#13#10)
                  else Break;
                End;
            'H'     :
                Begin
                  UI.Handle       := Input(#13#10'Handle (max 14) :[              ]'#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8);
                  User.HandleName := UI.Handle;
                End;
            'M'     :
                Begin
                  UI.Memo         := Input(#13#10'Comment (max 25) :[                        ]'#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8);
                  User.Memo := UI.Memo;
                End;
            'A'     :
                Begin
                  Case (Input(#13#10'Incoming user notifications [1]:On [2]:Off [0]:Cancel :>')+'*')[1] of
                      '1' : UI.UseLoginReport := True;
                      '2' : UI.UseLoginReport := False;
                      Else
                          Puts('No changes made.');
                     End;
                   User.UseLoginReport := UI.UseLoginReport;
                End;
            'B'     :
                Begin
                  Case (Input(#13#10'Enable private message notif. [1]:On [2]:Off [0]:Cancel :>')+'*')[1] of
                      '1' : UI.ReceiveTelegramBell := True;
                      '2' : UI.ReceiveTelegramBell := False;
                      Else
                          Puts('No changes done.');
                     End;
                   User.ReceiveTelegramBell := UI.ReceiveTelegramBell;
                End;


            else
                Puts('*** Invalid command. ***'#13#10);
          End;
      End;

 If User.Level > 0 then
   OutUserInit(User.ID,UI);

End;


Procedure TMtBBS.MessageList(BoardNo : Integer;IDs : Array of String);
Var
   s : String;
   i : Integer;
Begin

      Repeat
         s := InputCommand(#13#10'Start reading from...? ([RET]:from top 0:Cancel)>',False);
         if s = '' then s := '1';
         i := StrToIntDef(s,-1);
         if (i = 0) or Terminated then Exit;
      Until i>0;

      Puts('  No. FROM      D A T E   T I T L E                                           '#13#10);
      Puts('------------------------------------------------------------------------------'#13#10);
      Puts(MessageBoard.GetMessageList(BoardNo,i,Ids)+#13#10);

End;


Procedure TMtBBS.ReadMessage;
Var
  s,c       : String;
  BoardNo,i : Integer;


    Procedure IndividualRead;
    Var
      i   : Integer;
      Mes : TMessage;
    Begin
       While True Do
        Begin
            Repeat
                i := StrToIntDef(InputCommand(#13#10'Enter number of post to read. (0:end)>',false),-1);
                if Terminated then Exit;
                if i = 0 then Exit;
            Until i > -1;

            Mes := MessageBoard.Read(BoardNo,i);

            Case Mes.No of
               -1 : Puts('*** Post does not exist. ***'#13#10);
                0 : Puts('*** Post has been deleted. ***'#13#10);
             Else
              Begin
               Puts(#13#10+MakeMessageHead(Mes)+Mes.Text);
               If User.Options.AddMessageEof then
                  SendLn('//');
              End;
            End;
        End;
    End;


Begin

  User.Where := 'Read';
  Puts('-- Loading posts... --'#13#10);

  While True do
   Begin
      BoardNo :=  InputBoardNo(Ak_Read);

      If (BoardNo = 0) or Terminated then Exit;

      Puts(ReadMenuMessage);
      While Not Terminated do
       Begin
         s := UpperCase(InputCommand(#13#10'READ (R,I,S,L,F,#,?,0)>',true)+'*');
         Case s[1] of
            '0'     : Break;
            '?','*' : Puts(#13#10+ReadMenuMessage+#13#10);
            'L'     : MessageList(BoardNo,['ALL']);
            'R'     : Begin
                       While True do
                        Begin
                         c := InputCommand(#13#10'Read from where? ([RET]:From end 0:From beginning)>',False);
                         if c = '0' then c := '1';
                         if c = '' then
                          Begin              // = MAX // 逆向きに読む
                            ReadBoard(BoardNo,999999,-1);
                            Break;
                          End;
                         i := StrToIntDef(c,-1);
                         if Terminated then Exit;
                         if i = 0 then Exit;
                         if i > -1 then
                           Begin
                             ReadBoard(BoardNo,i,1);
                             Break;
                           End;
                        End;
                      End;
            'I'     : IndividualRead;
            'S'     : Puts('*** Sorry, not supported yet...^^;; ***'#13#10);
            else
                      Puts('*** Invalid command. ***'#13#10);
         End;
       End;
   End;

End;

Function TMtBBS.UploadFile(ReceiveFileName : String;P : String):Boolean;
Begin

   Result := False;
   If P = 'FTP' then
   Begin
       While True Do
        Begin
         Sendln('"'+ExtractFileName(ReceiveFileName)+'" will be uploaded to the FTP.'#13#10);
         Case (InputCommand('FTP (F : Confirm transfer 0 : Cancel)>',True)+'*')[1] of
            'F' : If Fileexists(ReceiveFileName) then
                   Begin
                     Result := True;
                     Exit;
                   End
                   Else
                     Sendln('*** '+ExtractFileName(ReceiveFileName)+' does not exist.***');
            '0' :  begin
                    Result := False;
                    Exit;
                   End;
         End;
        End;
   End;

   If P = 'XMODEM' then
      Case (InputCommand(#13#10'Protocol (1:SUM(128)  2:CRC(128)  3:CRC(1024)  0:end)>',True)+'*')[1] of
         '1' : FileTran.Protocol := pr_XMODEM_SUM_128;
         '2' : FileTran.Protocol := pr_XMODEM_CRC_128;
         '3' : FileTran.Protocol := pr_XMODEM_CRC_1024;
         '0' : Exit;
        else
          Begin
            uploadFile(ReceiveFileName,p);
            Exit;
          End;
      End;

   If P = 'YMODEM' then
     FileTran.Protocol := pr_YMODEM;
   If P = 'YMODEM-G' then
     FileTran.Protocol := pr_YMODEM_g;
   If P = 'ZMODEM' then
     FileTran.Protocol := pr_ZMODEM;
   If P = 'MLINK' then
     FileTran.Protocol := pr_MLINK;
   Sendln(P+' Uploaded.'#13#10);
   Result := FileTran.DownLoad(ReceiveFileName);
   Sendln('');

End;


Function TMtBBS.DownloadFile(FileName,SendFileName : String;P : String):Boolean;
Begin

   Result := False;

   If P = 'XMODEM' then
      Case (InputCommand(#13#10'Protocol (1:SUM(128)  2:CRC(128)  3:CRC(1024)  0:end)>',True)+'*')[1] of
         '1' : FileTran.Protocol := pr_XMODEM_SUM_128;
         '2' : FileTran.Protocol := pr_XMODEM_CRC_128;
         '3' : FileTran.Protocol := pr_XMODEM_CRC_1024;
         '0' : Exit;
        else
          Begin
            DownloadFile(FileName,SendFileName,P);
            Exit;
          End;
      End;

   If P = 'YMODEM' then
     FileTran.Protocol := pr_YMODEM;
   If P = 'YMODEM-G' then
     FileTran.Protocol := pr_YMODEM_g;
   If P = 'ZMODEM' then
     FileTran.Protocol := pr_ZMODEM;
   If P = 'MLINK' then
     FileTran.Protocol := pr_MLINK;

   Sendln(P+' Downloaded.'#13#10);
   Result := FileTran.UpLoad(FileName,SendFileName);
   Sendln('');


End;




Procedure TMtBBS.FileList(BoardNo : Integer;IDs : Array of String);
Var
   s : String;
   i : Integer;
Begin

      Repeat
         s := InputCommand(#13#10'Enter starting number. ([RET]:from top 0:Cancel)>',False);
         if s = '' then s := '1';
         i := StrToIntDef(s,-1);
         if (i = 0) or Terminated then Exit;
      Until i>0;

      Puts(#13#10'No. Filename     SIZE DL  YY/MM/DD Uploader　Comment'#13#10);
            Puts('--- ------------ ---- --- -------- -------- -----------------------------------'#13#10);
      Puts(FileBoardGetFileList(BoardNo,i,Ids)+#13#10);

End;

Procedure TMtBBS.FileMain;
Var
   FileInfo : TFileInfo;
  s,c       : String;
  BoardNo,i : Integer;
  Protocol  : String;


       Procedure SendFileInfo;
       Begin
               if FileInfo.Text<> '' then
                  Puts(#13#10+FileInfo.Text+#13#10);
               Sendln(#13#10'-------------------------------------------------------');
               Sendln('Uploader ID : '+FileInfo.ID);
               Sendln('Upload Date　 : '+DateTimeToStr(FileInfo.DateTime));
               Sendln('Filename : '+FileInfo.FileName);
               Sendln('Size　　 : '+IntToStr(FileInfo.FileSize)+' Bytes');
               Sendln('Comment   : '+FileInfo.Title);
               Sendln('-------------------------------------------------------'#13#10);
       End;


       Function WantFileNo : Boolean;
       Var
         a : String;
       Begin

          Result := False;
          While Not Terminated do
           Begin
            While Not Terminated do
              Begin
               a := InputCommand(#13#10+'Kill: Enter file number. (?:list  0:end)>',True);
               If StrToIntDef(a,-1)>0 then Break;
                Case (a+'*')[1] of
                   '?' : FileList(BoardNo,[User.ID]);
                   '0' : Exit;
                End;
              End;

            FileInfo := FileBoardRead(BoardNo,StrToIntDef(a,-1),False);
              Case FileInfo.No of
               -1 : Puts('*** File not found. ***'#13#10);
                0 : Puts('*** File deleted. ***'#13#10);
                Else
                  Begin
                    SendFileInfo;
                    If YesNoInput('Are you sure? (Y/N)>') then
                      Begin
                        Result := True;
                        Exit;
                      End;
                  End;
              End;
           End;
       End;


       Procedure ReadFileInfo;
       Var
          i   : Integer;
          a   : String;
       Begin

           While True Do
           Begin
              a := InputCommand(#13#10+'Enter file number. (?:list  0:end)>',True);
                 If StrToIntDef(a,-1)>0 then
                  Begin
                     FileInfo := FileBoardRead(BoardNo,StrToIntDef(a,-1),false);
                     Case FileInfo.No of
                       -1 : Puts('*** File not found. ***'#13#10);
                        0 : Puts('*** File deleted. ***'#13#10);
                     Else
                        SendFileInfo;
                     End;
                  End
                  Else
                   Case (a+'*')[1] of
                    '?' : FileList(BoardNo,['ALL']);
                    '0' : Exit;
                   End;
           End;
       End;


    Procedure UpLoad;
    Var
       a,b : String;
    Begin

         FileInfo.FileName := InputCommand(#13#10+Protocol+'Upload: Enter filename. (RET:end)>',False);
         If FileInfo.FileName = '' then Exit;

         Sendln('                  ___________________________________');
           Puts('Enter a comment: >');
         If Commandline= '' then FileInfo.Title := Recvln
                            else FileInfo.Title := Commandline;
         If YesNoInput(#13#10'Do you want to describe the file in detail? (Y/N)>') then
             Begin
               Sendln(#13#10'Write the description.'#13#10);
               FileInfo.Text := InputText;
               If FileInfo.Text<>'' then
                  Sendln('Writing completed.');
             End
             Else
               FileInfo.Text := '';

         If UpLoadFile(FFileBoardPath+'upload\'+FileInfo.FileName,Protocol) then
          Begin

            Puts('--');
            FileInfo.ID       := User.ID;
            FileInfo.DateTime := Now;
            FileInfo.FileSize := GetFileSize(FFileBoardPath+'upload\'+FileInfo.FileName);
            FileInfo.No       := FileBoardWrite (BoardNo,FileInfo);
            Puts('--');
            If FileInfo.No > 0 then
             Begin
               a := FFileBoardPath+'upload\'+FileInfo.FileName;
               b := FFileBoardPath + FileBoards[BoardNo].Name + '\'+Format('%.3d',[FileInfo.No])+'.'+FileInfo.FileName;

               Sendln('--');

               If FileExists(pchar(b)) then
                Begin
                  DeleteFile(pchar(b));
                  Sleep(300);
                End;  
               If MoveFile(pchar(a),pchar(b)) then
                   Sendln('Transfer completed.')
               else
                  Begin
                     Sendln('Transfer failed. Cause: File could not be sent. ErrNo='+IntToStr(GetLastError));
                     FileBoardKill(BoardNo,FileInfo.no);
                  End;

             End
             Else
               Sendln('Transfer failed.');
          End
          Else
            Sendln('Upload failed.');


    End;

    Procedure DownLoad;
    Var
       a,b : String;
       n : Integer;
    Begin

       While Not Terminated do
        Begin
          a := InputCommand(#13#10+Protocol+'Download: Enter file number. (?:list  0:end)>',True);
          If StrToIntDef(a,-1)>0 then Break;
          Case (a+'*')[1] of
            '?' : FileList(BoardNo,['ALL']);
            '0' : Exit;
          End;
        End;

          FileInfo := FileBoardRead(BoardNo,StrToIntDef(a,-1),True);

            Case FileInfo.No of
               -1 : Puts('*** File not found. ***'#13#10);
                0 : Puts('*** File is deleted. ***'#13#10);
             Else
              Begin

              SendFileInfo;

               If YesNoInput('Are you sure? (Y/N)') Then
                  If DownLoadFile(
                     FFileBoardPath + FileBoards[BoardNo].Name + '\'+Format('%.3d',[FileInfo.No])+'.'+FileInfo.FileName
                     ,FileInfo.FileName
                     ,Protocol)
                   then Sendln('Transfer complete.')
                   Else Sendln('Download failed.');

               If User.Options.AddMessageEof then
                  SendLn('//');
              End;
            End;
    End;


    Procedure UpOrDown;
    Var
      c : String;
    Begin

      While Not Terminated Do
       Begin
        c := InputCommand(#13#10+Protocol+' (U:upload  D:download  0:end)>',true)+'*';
         Case c[1] of
            '0'     : Break;
            'U'     : Begin
                        UpLoad;
                        Break;
                      End;
            'D'     : Begin
                        If Protocol = 'FTP' then
                          SendLn('*** Please connect your FTP client. ***')
                        else
                          DownLoad;
                        Break;
                      End;
         End;
       End;

    End;

    Procedure Kill;
    Var
      a : String;
    Begin

          If WantFileNo then
            Begin

              If (User.Level > 0) and (User.ID = FileInfo.ID) or (User.ID = FileBoards[BoardNo].BoardOpID)
                or (User.Level > 4)  then
                Begin
                    FileBoardKill(BoardNo,FileInfo.No);
                    SendLn('Deleted.');
                End Else
                Puts('*** Deletion forbidden. ***'#13#10);
            End;
    End;


Begin

  If Uppercase((CommandLine+'*')[1]) = 'N' then
   Begin
      InputCommand('',True);
      FileNews;
      Exit;
   End;

  User.Where := 'File';

  Puts(#13#10+MakeText(FileBoardInfoMessage)+#13#10);

  While Not Terminated do
   Begin
      BoardNo :=  InputFileBoardNo(Ak_Read);

      If (BoardNo = 0) or Terminated then Exit;
      Puts(MakeText(FileMenuMessage));
      While Not Terminated do
       Begin
         s := UpperCase(InputCommand(#13#10'FILE (L,B,X,Y,Z,M,U,D,S,E,F,K,H,?,0)>',true)+'*');
         Case s[1] of
            '0'     : Break;
            '?','*' : Puts(#13#10+MakeText(FileMenuMessage)+#13#10);
            'L'     : FileList(BoardNo,['ALL']);
            'I'     : Puts(#13#10+MakeText(FileBoardInfoMessage)+#13#10);

            'F'    : Begin
                        Protocol := 'FTP';
                        UpOrDown;
                      End;
            'X'    : Begin
                        Protocol := 'XMODEM';
                        UpOrDown;
                      End;
            'Y'    : Begin
                        Protocol := 'YMODEM';
                        UpOrDown;
                      End;
            'Z'    : Begin
                        Protocol := 'ZMODEM';
                        UpOrDown;
                      End;
            'D'    :    ReadFileInfo;
            'M'    : Begin
                        Protocol := 'MLINK';
                        UpOrDown;
                      End;

            'K'     : Kill;
            'N'     : FileNews;

            else
             Begin
                 Puts('*** Invalid command. ***'#13#10);
                 Puts(#13#10+MakeText(FileMenuMessage)+#13#10);
             End;
         End;
       End;
   End;

End;



Procedure TMtBBS.Kill;
Var
  BoardNo  : Integer;
   KillNo  : Integer;
        s  : String;
      Mes  : TMessage;
Begin

  User.Where := 'Kill';
  Puts('-- Delete post --'#13#10);

    BoardNo :=  InputBoardNo(AK_Write);
    If (BoardNo = 0) or Terminated then Exit;

    While True Do
     Begin
       Repeat
         s := InputCommand('Enter number to delete. ( ?:list 0:Cancel)>',false);
         if (s = '0') or Terminated then Exit;
         if s = '?' then
           Begin
              If (User.ID = 'SYSOP') or (User.ID = MessageBoards[BoardNo].SigOpID) then
                 MessageList(BoardNo,['ALL'])
              else
                 MessageList(BoardNo,[User.ID]);
           End;
         KillNo := StrToIntDef(s,0);
       Until KillNo > 0;

       Mes := MessageBoard.Read(BoardNo,KillNo);

       if Mes.No > 0 then
        Begin
          If (User.Level > 0) and (User.ID = Mes.ID) or (User.ID = MessageBoards[BoardNo].SigOpID)
            or (User.Level > 4)  then
              Begin
                 Puts(#13#10+MakeMessageHead(Mes)+Mes.Text);
                 Break;
              End Else
                Puts('*** Deletion forbidden. ***'#13#10);
        End Else
          Puts('*** Post not found. ***'#13#10);

     End;

    If YesNoInput('Confirm deletion? (Y/N)>') then
      Begin
          MessageBoard.Kill(BoardNo,KillNo);
          Puts('Post deleted.'#13#10);
      End
      Else
          Puts('*** Deletion cancelled. ***'#13#10);

End;






Procedure TMtBBS.WriteMessage;
Var
  s : String;
  i : Integer;
  Mes : TMessage;
Begin

  Puts('-- Make post --'#13#10);

  i :=  InputBoardNo(AK_Write);
  If i = 0 then Exit;
  if Terminated then Exit;

   Mes.No        := MessageBoards[i].MaxMessageNo+1;
   Mes.Id        := User.ID;
   Mes.Handle    := User.HandleName;
   Mes.MesTo     := 'ALL';
   Mes.DateTime  := Now;
   Mes.BoardNo   := i;

  Mes.Title := InputTitle;

   Puts(#13#10+MakeMessageHead(Mes)+#13#10);

  if Not YesNoInput('Are you sure? (Y/N/Quit)>') Then
    Begin
     Puts('** Writing cancelled. **'#13#10);
     Exit;
    End;
  Mes.Text := InputText;
  If Mes.Text='' then
    Begin
     Puts('** Writing cancelled. **'#13#10);
     Exit;
    End;

  Puts('Writing...');
  If MessageBoard.Write(i,Mes) then
    Puts('Completed. '#13#10)
  else
    Puts('Failed.'#13#10);


End;

Procedure TMtBBS.WriteResponse;
Var
  s : String;
  i : Integer;
  ResNo : Integer;
Begin

  User.Where := 'Enter';

  Puts('-- Write a reply --'#13#10);

  i :=  InputBoardNo(AK_Write);
  If i = 0 then Exit;
  if Terminated then Exit;


    While True Do
     Begin
         s := InputCommand('Enter number to reply to. (?:list 0:Cancel)>',false);
         if (s = '0') or Terminated then Exit;
         if s = '?' then
                 MessageList(i,['ALL']);
         ResNo := StrToIntDef(s,0);
         If ResNo > 0 then
           if WriteRes(i,ResNo) then Break;
         CommandLine := '';
     End;


End;


Function TMtBBS.WriteRes(BoardNo,ResNo :Integer):Boolean;
Var
  Mes : TMessage;
Begin

  Result := False;
  if MessageBoards[BoardNo].WriteLevel > User.Level then
    Begin
     Sendln('*** Access denied. ***');
     Exit;
    End;

     Mes := MessageBoard.Read(BoardNo,ResNo);


     if Mes.No < 1 then
      Begin
        Puts('*** No posts to reply to. ***'#13#10);
        Exit;
      End;

     If Copy(Mes.Title,1,3) = 'Re:' then
         Mes.Title := Copy(Mes.Title,Pos(')',Mes.Title)+1,80);
     Mes.Title     := Format('Re:%d)',[ResNo])+Mes.Title;
     Mes.No        := MessageBoards[BoardNo].MaxMessageNo+1;
     Mes.ID        := User.ID;
     Mes.Handle    := User.HandleName;
     Mes.MesTo     := 'ALL';
     Mes.DateTime  := Now;
     Mes.BoardNo   := BoardNo;

     Puts(#13#10+MakeMessageHead(Mes)+#13#10);

     if Not YesNoInput('Are you sure? (Y/N/Quit)>') Then
      Begin
        Puts('*** Writing cancelled. ***'#13#10);
        Exit;
      End;
      Mes.Text := InputText;
     If Mes.Text='' then
       Begin
        Puts('*** Writing cancelled. ***'#13#10);
        Exit;
       End;

     Puts('Writing　...');
     If MessageBoard.Write(BoardNo,Mes) then
      Begin
         Puts('Completed.'#13#10);
         Result := True;
      End
     else
         Puts('Failed.'#13#10);

End;


Procedure TMtBBS.Enter;
Var
  s : String[1];
Begin

   User.Where := 'Enter';

  s := UpperCase(InputCommand(#13#10'ENTER (M:Mail  B:Binarymail  W:Post  R:Reply  0:end)>',true)
       +'*');

 if Terminated then Exit;

  Case s[1] of
       'M'  :   WriteMail(False);
       'B'  :   WriteMail(True);
       'W'  :   WriteMessage;
       'R'  :   WriteResponse;
  End;

End;


Procedure TMtBBS.Boards;
Var
   s : String;
   i,j : Integer;

   MidokuSum    : Integer;
   CountSum     : Integer;
   Midoku       : Integer;
   Count        : Integer;


   Year, Month, Day : Word;

Begin

  Puts(#13#10);

     // 1234  12345678 12345678901234567890123456789012
  Puts('No.   Label    Title                            Total/Unr Newest Admin ID News'#13#10);
  Puts('----  -------- -------------------------------- ---- ----  ----- -------- ----'#13#10);
  MidokuSum := 0;
  CountSum := 0;

     For i:=1 to 99 do
       With MessageBoards[i] do
          if Enabled and ((ReadLevel <= User.Level) or (WriteLevel <= User.Level)) then
            Begin
              DecodeDate(MessageBoards[i].LastModified,Year, Month, Day);
              MessageBoard.GetMidokuPoint(i,User.LastRead,Count,Midoku);
              If User.NewsEnableBoards[i] then s := 'Avail'
                                          else s := 'Unavl';
              if MessageBoards[i].EnforcedNews then
                Begin
                   User.NewsEnableBoards[i] := True;
                   s := 'Must read';
                End;

              Puts(Format('%.4d: %.8s %.32s %.4d(%.4d) %.2d/%.2d %.8s %.4s'
              ,[i,Name+Spc,Title+Spc+Spc,Count,Count-Midoku+1,Month,Day,SigopID+'         ',s])+#13#10);
              MidokuSum := MidokuSum + Count-Midoku+1;
              CountSum  := CountSum  + COUNT;
            End;
  Puts(Format('----  -------- -------------------------/ Total %.4d(%.4d)/----- -------- ----',[CountSum,MidokuSum])+#13#10);

End;



Procedure TMtBBS.FBoards;
Var
   s : String;
   i,j : Integer;

   MidokuSum    : Integer;
   CountSum     : Integer;
   Midoku       : Integer;
   Count        : Integer;
   Year, Month, Day : Word;

Begin

  Puts(#13#10);

     // 1234  12345678 12345678901234567890123456789012
  Puts('No.   Label    Title                            Total/Unr Newest Admin ID'#13#10);
  Puts('----  -------- -------------------------------- ---- ----  ----- --------'#13#10);
  MidokuSum := 0;
  CountSum := 0;

     For i:=1 to 99 do
       With FileBoards[i] do
          if Enabled and ((ReadLevel <= User.Level) or (WriteLevel <= User.Level)) then
            Begin
              DecodeDate(FileBoards[i].LastModified,Year, Month, Day);
              FileBoardGetMidokuPoint(i,User.LastFileNews,Count,Midoku);
              Puts(Format('%.4d: %.8s %.32s %.4d(%.4d) %.2d/%.2d %.8s'
              ,[i,Name+Spc,Title+Spc+Spc,Count,Count-Midoku+1,Month,Day,BoardopID+'         '])+#13#10);
              MidokuSum := MidokuSum + Count-Midoku+1;
              CountSum  := CountSum  + COUNT;
            End;
  Puts(Format('----  -------- -------------------------/ Total %.4d(%.4d)/----- --------',[CountSum,MidokuSum])+#13#10);

End;



Procedure TMtBBS.Users;
Var
   s : String;
   i,j : Integer;
Begin


     User.Where := 'Users';
     Puts(#13#10'--- User list： Registered users: '+IntToStr(UserInitsCount)+' ---'#13#10);
     Puts(#13#10);
     If CheckUseLevel(_Users) then Exit;

     Repeat
        s := UpperCase(InputCommand('Enter ID to check. ([RET]:all)>',false));
        if Terminated then Exit;
        j := SearchUser(s);
        if s='' then j := 0;
     Until (j > -1);


     Puts(#13#10);
     Puts('USERID    H A N D L E'#13#10);
     Puts('-------------------------'#13#10);

    For i := j to UserInitsCount - 1 Do
        Puts(Format('%.8s  %.14s  %.25s',[UserInits[i].ID+'                   ',UserInits[i].Handle+'                   '
                    ,UserInits[i].Memo])
        + #13#10);

     Puts(#13#10);


End;


Procedure TMtBBS.PutProfile(I : Integer);
Var
   UI : TUserInit;
Begin

 UI := UserInits[i];

 With GeneralDefine.Profile do
  Begin
                      Puts(Format('- #%.4d ----------------------------------------------------',[i])+#13#10);
                      Puts(#13#10);
                      Puts('ID/HANDLE : '+Format('%.8s %.14s',[UI.ID+'             ',UI.Handle])+#13#10);
     if Address  then Puts('Address      : '+UI.Address+#13#10);
     if Name     then Puts('Name      : '+UI.Name+#13#10);
     if Tel      then Puts('Phone  : '+UI.TelNo+#13#10);
     if Hobby    then Puts('Hobbies      : '+UI.Hobby+#13#10);
     if BirthDay then Puts('Birthday  : '+UI.BirthDay+#13#10);
     if Signon   then Puts('Regist. date  : '+DateTimeToStr(UI.SignOn)+#13#10);
     if Comment  then Puts('Comment  : '+UI.Comment+#13#10);
     if Email    then Puts('E-Mail    : '+UI.EMail+#13#10);

                      Puts(#13#10);
  End;

End;

//Procedure TMtBBS.ReadPofile(I : Integer);


Procedure TMtBBS.Profile;

Var
  c : String;
  k : Integer;

    Procedure List;
    Var
       i,j : Integer;
       s   : String;
    Begin
      Repeat
         s := UpperCase(InputCommand('Enter ID to check. ([RET]:all)>',false));
         if Terminated then Exit;
         j := SearchUser(s);
         if s='' then j := 0;
      Until (j > -1);
      For i:= j to UserInitsCount - 1 do
          PutProfile(i);

    End;

    Procedure Edit(ID : String);
    Var
       UI : TUserInit;
       c  : String;

        Procedure PutPro;

           Function m(i : Integer) : String;
           Begin
              Result := ' ';
              With GeneralDefine.Profile do
                Case i of
                 1: if Address  then Result := '*';
                 2: if Name     then Result := '*';
                 3: if Tel      then Result := '*';
                 4: if Hobby    then Result := '*';
                 5: if BirthDay then Result := '*';
                 6: if Comment  then Result := '*';
                 7: if Email    then Result := '*';
                End;
           End;

        Begin
           SendLn('');
           SendLn(' ID/HANDLE  : '+Format('%.8s %.14s',[UI.ID+'             ',UI.Handle]));
           SendLn(m(1)+' 1: Address     : '+UI.Address);
           SendLn(m(2)+' 2: Name     : '+UI.Name);
           SendLn(m(3)+' 3: Phone : '+UI.TelNo);
           SendLn(m(4)+' 4: Hobbies     : '+UI.Hobby);
           SendLn(m(5)+' 5: Birthday : '+UI.BirthDay);
           SendLn(m(6)+' 6: Comment : '+UI.Comment);
           SendLn(m(7)+' 7: E-Mail   : '+UI.EMail);
           SendLn(#13#10'※ "*"Other users can see this data.');
           SendLn('');
        End;
    Begin

       UI := GetUserInit(ID);
       PutPro;

           While True do
            Begin
               c := UpperCase(InputCommand('Edit which user? (0:end ?:List)>',True)+'*');
               If Terminated then Exit;
                Case c[1] of
                  '0'     : Begin
                              OutUserInit(ID,UI);
                              Exit;
                            End;
                  '?'     : PutPro;
                  '1'     : InputProfile(UI,_Address);
                  '2'     : InputProfile(UI,_Name);
                  '3'     : InputProfile(UI,_Tel);
                  '4'     : InputProfile(UI,_Hobby);
                  '5'     : InputProfile(UI,_BirthDay);
                  '6'     : InputProfile(UI,_Comment);
                  '7'     : InputProfile(UI,_Email);
                End;
            End;
    End;

Begin

  User.Where := 'Profile';
  If CheckUseLevel(_Profile) then Exit;

     While True do
      Begin
         c := UpperCase(InputCommand(#13#10'PROFILE (L:List  I:Individual  E:Edit 0:end)>',True)+'*');
         If Terminated then Exit;
          Case c[1] of
            '0'     : Exit;
            'L'     : List;
            'I'     : Begin
                       k :=InputUserID;
                       If k>-1 then PutProfile(k);
                      End;
            'E'     : If User.Level > 0 then
                        Edit(User.ID)
                      Else
                        Puts('*** Not available to guests. ***'#13#10);
          End;
      End;


End;





Procedure TMtBBS.Telegram;
Var
   ch,ms : String;
Begin

 If CheckUseLevel(_Telegram) then Exit;

  User.Where := 'Telegram';
  Puts(#13#10);

  ch := UpperCase(InputCommand('Send a PM to? (?:WHO A:Everyone S:MTBBS system [RET]:Quit)>',False));

  if ch = '' then
   Begin
     Puts('*** Private messaging cancelled. ***'#13#10);
     Exit;
   End;

  if terminated then Exit;

  If ch = 'A' then
     ch := '100'
  Else If ch = 'S' then
          ch := '101'
      Else
       Begin
         if (StrToIntDef(ch,100)>99) or (StrToIntDef(ch,100)<0) then
          Begin
            if ch = '?' then who;
            Telegram;
            Exit;
          End;

          if (TMainForm(FOwner).Chs[StrToInt(ch)].Mode = Cm_None) and not(IsUsedWWWCh(StrToInt(ch))) then
           Begin
            Puts('** Not logged in. **'#13#10);
            Exit;
           End;
       End;

     Puts(#13#10);
     ms := Input('What is the message? >');

     if ms='' then
       Begin
         Puts('*** Private messaging cancelled. ***'#13#10);
         Exit;
       End;


  SendTelegram(StrToInt(ch),ms);

End;

Function TMtBBS.MakePassword : String;
Begin

   If YesNoInput('Automatically generate password? (Y/N)>') Then
    Begin
      Randomize;
      Result := IntToHex(Random($FFFFFFFF),8);
    End
    Else
     Repeat
       Result := Input('Enter password (3 to 8 chars) :[        ]'#8#8#8#8#8#8#8#8#8);
       if Terminated then Exit;
     Until (Length(Result)>2) and (9>Length(Result));

   Puts(#13#10);

    Repeat
      if Terminated then Exit;
      Puts('Password is ' + Result + '. Re-enter to confirm.'#13#10);
    Until (Result = Input('Password:'));

    Puts(#13#10);

End;


Procedure TMtBBS.Apply;
Const

  SS = '          ';
  BS = #8#8#8#8#8#8#8#8#8#8;

  CancelMes = '*** Registration cancelled. ***'#13#10;
Var
   UI : TUserInit;

    Function CheckStr(s : String) : Boolean;
     Var
        i  : Integer;
        a  : String;
     Begin
      Result := True;
      for i := 1 to Length(a) do
        if (a[i]<#33) or (#122<a[i]) then
           Result := False;
     End;

    Function InputNewID : String;
    Var
        a : String;
    Begin
      Result := '';
       If GeneralDefine.Apply.UseFreeID then
        If Not YesNoInput('Automatically generate ID? (Y/N)>') Then
          Begin
           a := '';
           While True do
            Begin
             a := UpperCase(Input('Enter ID (up to 8 half-width alphanumerics) : [        ]'#8#8#8#8#8#8#8#8#8));
             if terminated then Exit;
             if (Pos(' ',a)=0) and (0<Length(a)) and (Length(a)<9)  then
               if SearchUser(a)=-1 then
                Begin
                  if CheckStr(a) then
                     Begin
                        If (StrToIntDef(Copy(a,Length(GeneralDefine.Apply.IdHead)+1,99),-1)>-1) and (GeneralDefine.Apply.IdHead=Copy(a,1,Length(GeneralDefine.Apply.IdHead))) then
                            Sendln('*** Cannot use this ID. ***')
                        else
                            Break
                     End
                   else
                     Sendln('*** Half-width alphanumerics only! ***');
                End
               Else // SearchUser(a)<>-1
                   Sendln('*** "'+a+'" ID is already taken. ***');
            End;
           Result := a;
           Exit;
          End;
      Result := MakeUserID
    End;


Begin

  User.Where := 'Apply';

  If User.Level <> 0 then
   Begin
       Puts(#13#10'*** You have already registered. ***'#13#10#13#10);
       Exit;
   End;

   Puts(#13#10+MakeText(ApplyInfoMessage)+#13#10#13#10);

   If (Not GeneralDefine.Apply.AutoRegist) then Exit;

   Puts(#13#10#13#10);
   Puts('Registration begins now. Please provide the details'#13#10);
   Puts('we ask of you.'#13#10#13#10);

   If Not YesNoInput('Ready to register? (Y/N)>') then
     Begin
       Puts(CancelMes);
       Exit;
     End;

   Puts('Provide your details carefully.'#13#10#13#10);

   UI := DefaultUserInit;

   UI.Id := InputNewID;

   Puts(#13#10'ＩＤ : '+UI.ID+#13#10#13#10);

   //Puts('注) 括弧内の最大文字数は"半角"で数えた場合となっています.'#13#10);
   //Puts('-------------------------------------------------------------'#13#10);
    InputProfile(UI,_Name);
    InputProfile(UI,_Address);
     If (UI.Name = '') or (UI.Address = '')  then
      Begin
        Puts('** Registration cancelled. Required info not provided. **'#13#10);
        Exit;
      End;
    InputProfile(UI,_Tel);
    InputProfile(UI,_Hobby);
    InputProfile(UI,_BirthDay);
    InputProfile(UI,_Handle);
    InputProfile(UI,_Comment);
    InputProfile(UI,_Email);
   Puts('-------------------------------------------------------------'#13#10);
   Puts(#13#10);

   UI.Password := MakePassword;
   UI.Level    := GeneralDefine.Apply.StartLevel;

  While True Do
  Begin
    If YesNoInput('Confirm registration? (Y/N)>') then
     Begin
       If Terminated then Exit;
        if SearchUser(UI.Id) > -1 then  //　念のため^^;;;  たぶんこーゆー事は絶対に無いと思う
         Begin
            Puts('"'+UI.ID+'"is already registered. Provide another ID.'#13#10);
            UI.Id:= InputNewID;
         End
         Else
          Begin
            UI.SignOn := Now;
            OutUserInit(UI.ID,UI);
            Puts(#13#10'ID :'+UI.ID+' PASSWORD :'+UI.Password+' has registered.'#13#10#13#10);

              SendMailFromSystemToSysop('A member has registered:[TELNET]'
                 ,  'ＩＤ      : '+UI.ID+#13#10
                   +'Password: '+UI.Password+#13#10
                   +'Address      : '+UI.Address+#13#10
                   +'Name      : '+UI.Name+#13#10
                   +'Phone  : '+UI.TelNo+#13#10
                   +'Hobbies      : '+UI.Hobby+#13#10
                   +'Birthday  : '+UI.BirthDay+#13#10
                   +'Regist. date  : '+DateTimeToStr(UI.SignOn)+#13#10
                   +'Comment  : '+UI.Comment+#13#10
                   +'E-Mail    : '+UI.EMail+#13#10
               );

            Puts('Thank you. You may now log in.'#13#10);
	    Puts('DO NOT FORGET YOUR ID AND PASSWORD!'#13#10);
            User.Level := -1;
            If YesNoInput(#13#10'Would you like to log in? (Y/N)>') then
             Begin
              Login;
              Terminate;
              Exit;
             End;
            Puts(#13#10);
            Break;
          End;
     End
     Else
      Begin
       Puts(CancelMes);
       Break;
      End;
     If Terminated then Exit;
  End;

End;




Function TMtBBS.ChToHandle(Ch : Integer) : String;
Begin

  With TMainForm(FOwner).Chs[ch].Thread Do
    Result := Format('%.2d:%.14s',[Fch,User.HandleName+'                '])

End;

Function TMtBBS.ChatInput : String;   //チャット／電報受信に対応
var i : integer;
    s : string;
Const
   Prompt = '?';
Begin

 Result := '';
 If Echo then Puts(Prompt);
with chatRooms[myChatRoom] do
 While Rp=Wp do
  Begin
   PutEchoStrs;
   Sleep(50);
   If Terminated then Exit;
   if CWp <> CRp then
    Begin
      if RecvStrBuf[Rp]='' then
         Puts(#8+ChatBuffer[CRp]+#13#10)
      Else
         Puts(#13#10+ChatBuffer[CRp]+#13#10);
      Inc(CRp);
      If CRp > 999 then CRp := 0;

      If Echo then Puts(Prompt+RecvStrBuf[Rp]);
    End;
   if Telegrams.Count>0 then
    Begin
      Puts(#13#10);
      RecvTelegram;
      If Echo then Puts(Prompt+RecvStrBuf[Rp]);
    End;
//   Application.ProcessMessages;
  End;
  PutEchoStrs;
  Result := RecvStrBuf[Rp];

 Inc(Rp);
 If Rp>1999 then Rp := 0;

End;

Procedure TMtBBS.SysopCall;
Var
    T : Integer;
    i : Integer;
Begin

  If CheckUseLevel(_SysopCall) then Exit;

  User.Where := 'SysopCall';
  MtbbsSts('ユーザーがSysop呼び出しをしました.');

  If GeneralDefine.User.SysopCall then
   Begin

      If GeneralDefine.Sound.PlaySysopCall then
       Begin
        Sendln('Calling the sysop...');
        Synchronize(PlaySysopCallSound);
        Sleep(2000);
       End
      Else
       Begin
        Puts('Calling the sysop...([RET]:Quit)');

         For i := 0 to 9 Do
         Begin
          If Wp <> Rp then
            Begin
              Recvln;
              Break;
           End;
          Puts('..');
          T := GetTickCount;
          While Not(Terminated) and (GetTickCount < T+800) do
             Sleep(100);
          SysUtils.Beep;
        End;
       End;
   End Else
       Puts('*** SysOp calling is currently disabled. ***');

   Puts(#13#10);

End;

Procedure TMtBBS.ChatRoomList;
var
     i,j,n : integer;
Begin
    Sendln('<< List of chatrooms >>');
    Sendln('No. CreatorID Creator handle Chatroom name                  Users');
    Sendln('---- -------- -------------- ------------------------------ -- ');

    For i:=1 to 20 do
     Begin
       n := 0;
       for j:= 0 to 99 do
         if MainForm.Chs[j].Mode <> Cm_None then
           if TMtbbs(MainForm.Chs[j].Thread).MyChatRoom = i then
              inc(n);

       With ChatRooms[i] do
         Begin
          if id<>'' then
           Sendln(Format('%.4d %.8s %.14s %.30s(%.2d)'
           ,[i,ID+'        ',Handle+'                '
           ,RoomTitle+'                            ',n]));
         End;
     End;

    Sendln('---- -------- -------------- ------------------------------ -- ');
End;

Procedure TMtBBS.ChatRoomWho(MyChatRoom : Integer);
var
  j : integer;
  s : string;
Begin
       Sendln(format('%.4d 「'+ChatRooms[MyChatRoom].RoomTitle+'」 List of members',[MyChatRoom]));
       Puts('CH User ID  Handle         Protocol Location Prot.st  Memo'#13#10);
       Puts('-- -------- -------------- -------- -------- -------- -------------------------'#13#10);
       S :='';
       for j:= 0 to 99 do
         if MainForm.Chs[j].Mode <> Cm_None then
           if TMtbbs(MainForm.Chs[j].Thread).MyChatRoom = MyChatRoom then
            Begin

             With MainForm.Chs[j].Thread Do
              S := S+(Format('%.2d %.8s %.14s %.8s %.8s %.8s %.25s'#13#10
                     ,[j,User.ID+'        ',User.HandleName+'              ',MainForm.Chs[j].Way+'               '
                     ,User.Where+'        ',TimeToStr(User.LoginTime)+'        ',User.Memo]) );
            End;
       if s='' then s := '<No users>'#13#10;
       Puts(s+'-- -------- -------------- -------- -------- -------- -------------------------'#13#10);
End;

Procedure TMtBBS.Chat;
Var
   s,c : String;
   C_Echo : Boolean;
   i,j,n : integer;




     Procedure RotenFuro;
     Var
        cl : String;
     Begin

        Sendln('*** 露天風呂に入りました ***');
      While True do
       Begin
         User.Where := '露天風呂';
         Cl := UpperCase(InputCommand(#13#10'露天風呂 (G:風呂の外に出る J:じゃんけん T:電報 W:ﾛｸﾞｲﾝ状況 ?:help 0:戻る)>',True))
                +'*';
          Case cl[1] of
           'J' : Begin
                   Puts('じゃん');
                   Sleep(300);
                   Puts('けん');
                   Sleep(300);
                   Puts('ぽん');
                   Sleep(300);
                   Sendln('');
                  End;
            '0' : Break;
            'T' : Telegram;
            'W' : Who;
            'G' : If YesNoInput(#13#10'あなたは裸のままです。それでも外に出ますか？(Y/N)') then
                      Sendln('<< ごめんなさい準備中です >>');
//                      OutFuro;
            '?' : Sendln('<< ごめんなさい準備中です >>');
          End;
       End;
     End;

   Procedure Yasyoku;
   var n,i : integer;
   Begin
       AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == 夜食 in ==');
        Repeat
                User.Where := '夜食';
                Sendln(#13#10'** 夜食 **'#13#10);
                Sendln('何を食べ(飲み)ますか?');
                Sendln(' 1 .. ホットコーヒー');
                Sendln(' 2 .. カップ麺');
                Sendln(' 3 .. 水');
                Sendln(' 4 .. 毒キノコ');
                Sendln(' 0 .. 戻る');
                n := StrToIntDef(InputCommand(#13#10'何にしますか？(番号)>',True),-1);

                Case n of
                   1 : Begin
                         AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == ホットコーヒー in ==');
                         if YesNoInput('お砂糖は入れますか？') then
                            Sendln('*** 砂糖投入完了 ***');
                         Sendln('今作ってるからちょっと待ってね・・');
                         for i:=0 to 20 do
                          Begin
                            sleep(1000);
                            puts('あと、'+IntToStr(20-i)+'秒  ');
                            if terminated then break;
                          End;
                          Sendln(#13#10'さぁ召し上がれ・・');
                          While Not terminated do
                            if YesNoInput(#13#10'おいしいですか？(Y:「うん、凄くおいしいよ」,N:「まずいよ」)') then break
                               else Sendln('なんだと！！');
                          Sendln('ありがとう・・');
                          AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == ホットコーヒー out ==');
                       End;
                   2 : Begin
                         AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == カップ麺 in ==');
                         Sendln('３分間待つのじゃぞ・・');
                         for i:=0 to 180 do
                          Begin

                            sleep(1000);
                            puts('あと、'+IntToStr(180-i)+'秒  ');
                            if terminated then break;
                          End;

                          Sendln(#13#10'さぁ召し上がれ・・'#7#7#7#7#7);
                          While Not terminated do
                            if YesNoInput(#13#10'おいしいですか？(Y/N)') then break
                               else Sendln('なんだと！！');
                          AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == カップ麺 out ==');

                       End;
                   3 : Begin
                         If YesNoInput(#13#10'ここの水は水質汚染がひどいです、それでもあなたは飲むのですか？(Y/N)') then
                            If YesNoInput(#13#10'ホントに飲むのですか？(Y/N)') then
                              Begin
                                AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == 腹痛 in ==');
                                 Sendln('*** あなたはお腹をこわしました ***');
                                 Sleep(1000);
                                 Sendln('これから苦しみを味わうことになります・・・');
                                 Sleep(2000);
                                 for i:=0 to 999 do Puts('<腹痛>');
                                 Sleep(2000);
                                 Sendln(#13#10'なんとか、傷みはおさまりました。めでたしめでたし。(^^;');
                                 AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == 腹痛 out ==');
                              End;
                       End;
                   4 : Begin
                         AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == 幻覚の世界 in ==');
                         While Not Terminated do
                         Begin
                             Sendln('*********************************');
                             Sendln('* 幻覚の世界へようこそ！！      *');
                             Sendln('* Welcome to fantastic world !! *');
                             Sendln('*********************************');
                             Sendln('あなたはもう逃げられない');
                             Sendln('');
                             Puts(#13#10+MakeText(MainMenuMessage)+#13#10);
                             SendLn(Format('*CH%.2d*',[FCh]));
                             InputCommand('MAIN (A,C,E,F,H,I,K,L,M,N,O,R,T,U,W,X,Y,#,?,G)>',True);
                         End;
                       End;
                End;
        Until (n=0) or Terminated;

        AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == 夜食 out ==');
   End;


   Procedure Furo;
   Var
      cl : String;
{
           Procedure outFuro;

               Procedure UpRiver;
               Begin

               End;
               Procedure DownRiver;
               Begin

                  Sendln('*** 臣に ***');
                  Sendln('<<< ここは、露天風呂の外を流れている豊平川・・(注:札幌市を流れている川)>>>');
                  User.Where := '豊平川';

               End;

           Begin

              Sendln('*** 風呂の外へ出ました ***');

              Sendln('<<< ここは、露天風呂の外を流れている豊平川・・(注:札幌市を流れている川)>>>');
               User.Where := '豊平川';
               Cl := UpperCase(InputCommand(#13#10'豊平川 (U:川の上流へ泳ぐ D:川の下流へ泳ぐ T:電報 W:Who ?:help)>',True))+'*';
                Case cl[1] of
                  'U' : UpRiver;
                  'D' : DownRiver;
                  'T' : Telegram;
                  'W' : Who;
                  '?' : Sendln('<< ごめんなさい準備中です >>');
                End;
              Sendln('*** 露天風呂を出ました ***');

           End;

 }


   Begin
      AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == Furo in ==');
      Sendln('*** 風呂に入りました ***');
       While Not Terminated do
        Begin
         User.Where := '風呂';
         Cl := UpperCase(InputCommand(#13#10'FURO (S:歌う R:露天風呂 D:溺れる T:電報 W:ﾛｸﾞｲﾝ状況 ?:help 0:end)>',True))+'*';
          Case cl[1] of
            'S' : Sendln(#13#10'勝手に歌ってください(笑)');
            '0' : Break;
            'T' : Telegram;
            'R' : RotenFuro;
            'W' : Who;
            'D' : If YesNoInput(#13#10'溺れてよろしいですか？(Y/N)') then
                    If YesNoInput('本当に溺れてよろしいですか？(Y/N)') then
                      Begin
                         AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == The other world in ==');
                         Sendln(#13#10'*** あなたは死にました ***');
                         Sleep(2500);
                         Goodbye(True);
                         Terminate;
                         Exit;
                      End;
            '?' : Sendln('<< ごめんなさい準備中です >>');
          End;
        End;

      AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == Furo out ==');
      Sendln('*** 風呂から出ました ***');

   End;

Begin


  MyChatRoom := -1;
  sendln(#13#10);
    For i:= 0 to 19 do
      if ChatRooms[i].ID<>'' then
         ChatRoomWho(i);
  repeat

    sendln('');
    ChatRoomList;
    s := InputCommand(#13#10'Room number？(M:Create room [RET]:Stanard room 0:Quit)>',false);
    if terminated then exit;
    if s='' then MyChatRoom := 1
            else MyChatRoom := StrToIntDef(s,-1);
    if MyChatRoom=0 then exit;
    if (s='M') or (s='m') then
     Begin
        If User.Level = 0 then
           Sendln('*** Restricted for guests. ***')
        else
         For i:=1 to 20 do
          Begin
             if ChatRooms[i].ID = '' then
              With ChatRooms[i] do
               Begin
                 sendln(#13#10'<< Creating chatroom >>');
                 puts(#13#10'Enter the room name.>');
                 RoomTitle := Recvln;
                 Sendln(#13#10'Describe the room.・・・');
                 RoomComment := InputText;
                 ID        := User.ID;
                 Handle    := User.HandleName;
                 MyChatRoom := i;
                 Lock := False;
                 Sendln('** Chatroom created. **');
                 Sendln('Edit or delete it with the C command when you enter it.');
                 break;
               End;
             if i=20 then
                Sendln('*** Creation failed. ***');
          end;
     End;
     if (MyChatRoom>0) and (MyChatRoom<21) then
      if ChatRooms[MyChatRoom].lock then
       Begin
          If (GeneralDefine.User.SysopLevel<=User.level)
          or (ChatRooms[MyChatRoom].ID=User.ID) then
             ChatRooms[MyChatRoom].Lock := Not YesNoInput(#13#10'Want to unlock the room? (Y/N)');
          if ChatRooms[MyChatRoom].lock then
           Begin
             sendln('Room locked, cannot enter.');
             Exit;
           End
             else break;
       End
     else
      break;
  Until false;


  With ChatRooms[MyChatRoom] do
   Begin
       C_Echo := True;
       Echo := C_Echo;

       If CheckUseLevel(_Chat) then Exit;

      If ChatLines < GeneralDefine.Chat.BackLogLines Then
          Crp := (CWp - ChatLines)
         Else
          Crp := (CWp - GeneralDefine.Chat.BackLogLines);
      Crp := (Crp+999) mod 999;


           // 123456789012345678901234567890123456789


      Puts(#13#10'Enter chat mode.(?:Help)'#13#10);
      Puts(MakeText(RoomComment)+#13#10+ChatMenuMessage);
      Puts(#13#10'Current time　　 : '+DateTimeToStr(Now)+#13#10);
      ChatRoomWho(MyChatRoom);

      AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == Chat in ==');

      While True do
       Begin
         User.Where := 'Chat:'+IntToStr(MyChatRoom);
         s := ChatInput;
         if Terminated then Break;
         if s<>'' then
          Begin
            if (s='//') or (s='／／') then Break;

            If (Copy(TrimLeft(s),1,3) = '== ') and (Pos(' ==',TrimLeft(s))>3) then
                s := '＞＞'+s;

            Echo := True;

            If Not CheckPluginCommand(s) then
             Begin
               c := UpperCase(s);
                if Length(c)=1 then
                 Begin
                   Case C[1] of
                     'T' : Telegram;
                     'W' : Who;
                     'C' : if (GeneralDefine.User.SysopLevel<=User.level)
                            or (ChatRooms[MyChatRoom].ID = User.ID) then
                             Begin
                              Sendln('<< Editing chatroom >>');
                              while not terminated do
                               Begin
                                s := UpperCase(InputCommand(#13#10'Chatroom editing (N:Rename C:Describe D:Delete L:Lock 0:end)>',True))+'*';
                                Case s[1] of
                                     'N': Begin
                                           puts(#13#10'Room name?>');RoomTitle := Recvln;
                                          end;
                                     'C': RoomComment := InputText;
                                     'D': If YesNoInput(#13#10'Confirm deletion? (Y/N)') then
                                             ID := '';
                                     'L': Lock := YesNoInput(#13#10'Confirm locking? (Y/N)');
                                     '0':break;
                                End;
                               End;
                             End
                            else
                             Sendln('** Unauthorized. **'); 
                     'L' : ChatRoomWho(MyChatRoom);
                     '?' : Puts(MakeText(RoomComment)+#13#10+ChatMenuMessage);
                     'K' : AddChatMessage(MyChatRoom,ChToHandle(Fch)+'> '+'こんばんは～');
                     'D' : AddChatMessage(MyChatRoom,ChToHandle(Fch)+'> '+'どもども(^^)');
                     'H' : Begin
                              AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == 歯磨き in ==');
                              User.Where := '歯磨き';
                              Input('歯磨き ([RET]:復帰)>');
                              AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == 歯磨き out ==');
                           End;
                     'R' : Begin
                              AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == 来客 in ==');
                              User.Where := '来客';
                              Input('来客 ([RET]:復帰)>');
                              AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == 来客 out ==');
                           End;
                     'Y' : Yasyoku;
                     'P' : Begin
                              AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == 電話 in ==');
                              User.Where := '電話';
                              Input('電話 ([RET]:復帰)>');
                              AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == 電話 out ==');
                           End;
                     'B' : Begin
                              AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == トイレ in ==');
                              User.Where := '便所';
                              Input('便所 ([RET]:復帰)>');
                              AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == トイレ out ==');
                           End;
                     'F' : Furo;
                     'S' : SysopCall;
      //               'L' : Puts('*** 未対応の機能 ***'#13#10);
                     'O' : Profile;
                     'M' : Begin
                             MainInChat := True;
                             Main;
                           End;
                     'E' : Begin
                             C_Echo := Not(C_Echo);
                             Echo := C_Echo;
                             If Echo Then Puts('*** ECHO ON  に設定しました ***'#13#10)
                                     Else Puts('*** ECHO OFF に設定しました ***'#13#10);
                           End;
                     'N' : Puts('現在時刻　　 : '+DateTimeToStr(Now)+#13#10);
                     Else
                           AddChatMessage(MyChatRoom,ChToHandle(Fch)+'> '+s);
                   End;
                 End
                 Else
                   AddChatMessage(MyChatRoom,ChToHandle(Fch)+'> '+s);
             End;
           Echo := C_Echo;

          End;
       End;

      AddChatMessage(MyChatRoom,ChToHandle(FCh)+'> == Chat out ==');
      Echo := True;
      Puts(#13#10'*** Leaving the chatroom. ***'#13#10);
   End;
   MyChatRoom := 0;
End;

Function TMtBBS.InputCommand2(Prompt : String): String;
Var
  i : Integer;
Begin

  If CommandLine = '' then
     CommandLine := Input(Prompt);

  i := Pos(';',CommandLine+';');

  Result := Copy(CommandLine,1,i-1);
  CommandLine := Copy(CommandLine,i+1,256);

End;


Function TMtBBS.InputCommand(Prompt : String;CharInp : Boolean): String;   //電報受信に対応

   Function ReadCommand : String;
   Var
         i : Integer;
         c : Char;
   Begin

    Result := '';

    i := 1;

    While i<=Length(CommandLine) do
     Case CommandLine[i] of
       #$81     : Begin
                   If i < Length(CommandLine) then
                     Begin
                       Inc(i);
                       c := CommandLine[i];
                       Case c of
                         #$40       : Result := Result + ' ';
                         #$46       : Result := Result + ':';
                         #$47       : if i>2 then Break
                                             else ;
                         #$48       : Result := Result + '?';
                         #$7B       : Result := Result + '+';
                         #$7C       : Result := Result + '-';
                       else
                         Result := CommandLine[i-1]+c;
                       End;
                       If CharInp and (c<>#$47) then Break;
                       inc(i);
                     End;
                 End;

       #$82     : Begin
                   If i < Length(CommandLine) then
                     Begin
                       Inc(i);
                       c := CommandLine[i];
                       Case c of
                         #$4f..Char($6f+$a) : Result := Result + Char($30-$4f+Byte(c));
                         #$81..Char($90+$a) : Result := Result + Char($61-$81+Byte(c));
                       else
                         Result := CommandLine[i-1]+c;
                       End;
                       If CharInp then Break;
                       inc(i);
                     End;
                 End;

       ';'     : if i>1 then Break
                        else Inc(i);
       '0','1','2','3','4','5','6','7','8','9',' '
               : Begin
                    Result := Result + CommandLine[i];
                    Inc(i);
                 End;
      else
       Begin
        Result := Result + CommandLine[i];
        If CharInp then Break;
        Inc(i);
       End;
     End;

    If CharInp and (CommandLine = '00') then
      CommandLine :='0'
    else
      CommandLine := Copy(CommandLine,i+1,255);


   End;


Begin

  If CommandLine = '' then
     CommandLine := Input(Prompt);
  Result := Trim(UpperCase(ReadCommand));

End;



Function TMtBBS.Input(Prompt : String): String;   //電報受信に対応
Begin


 Result := '';
 CommandLine :=  '';

 Puts(Prompt);

 While (Rp=Wp) and Not(Terminated)do
  Begin
   PutEchoStrs;
   Sleep(50);
   if Telegrams.Count>0 then
    Begin
      Puts(#13#10);
      RecvTelegram;
      Puts(Prompt+RecvStrBuf[Rp]);
    End;
  End;
  If Terminated then Exit;
  PutEchoStrs;

  Result := RecvStrBuf[Rp];

 Inc(Rp);
 If Rp>1999 then Rp := 0;

End;


Function TMtBBS.YesNoInput(Prompt : String): Boolean;   //電報受信に対応
Var
  a : String;
Begin

   Result := False;
   a := '*';

   While  Not Terminated do
     Begin
       a := UpperCase(InputCommand(Prompt,False))+'*';
       Case a[1] of
        '*','Y' : Begin
                    Result := True;
                    Break;
                  End;
        'N' : Break;
        'Q' : Break;
       End;
     End;

End;

Procedure TMtBBS.FreePost;
Var
    a : String;
Begin

  If CheckUseLevel(_FreePost) then Exit;

  User.Where := 'FreePost';

      SendLn('');
      SendLn('《 Casual/Freeposting board 》 ');
      SendLn('');
      SendLn('-------------------------------------------------------------------------------');
       Puts(ExMtBBS.ReadFreePost);
      SendLn('-------------------------------------------------------------------------------');
      SendLn('Free Post     :Write a message (max 64 characters) ([RET] : Quit)');
      SendLn('               1---+---10----+---20----+---30----+---40----+---50----+---60--64');

      While Not Terminated do
       Begin
         Puts('Free Post     >');
         a := RecvLn;
         if a='' then Break;
            ExMtBBS.WriteFreePost(User.HandleName,a);
       End;
      SendLn('');

End;

Procedure TMtBBS.Goodbye(b : Boolean);
Var
    i : Integer;
    a : String;
Begin

   For i := 0 to PluginsCount - 1 do
    If Assigned(Plugins[i].OnGoodbye) then
     Begin
          PluginCreate(i);
          Plugins[i].OnGoodbye(Fch);
     End;
  User.Where := 'Goodbye';
  If GeneralDefine.User.GoodbyeMessage and b Then
    Begin
      SendLn('');
      SendLn(' Please say something on your way out! ');
      SendLn('');
      SendLn('-------------------------------------------------------------------------------');
       Puts(ExMtBBS.ReadGoodByeMessage);
      SendLn('-------------------------------------------------------------------------------');
      SendLn('        Write a goodbye message (max 46 chars)  (@@:Back to Main)');
      SendLn('        1---+---10----+---20----+---30----+---40----46');
      Puts('------->');
       a := RecvLn;
      if a='@@' then Exit;
      If a<>'' then
           ExMtBBS.WriteGoodByeMessage(User.HandleName,a);
    End;

        For i := 0 to PluginsCount - 1 do
        If Assigned(Plugins[i].OnLogout) then
         Begin
            PluginCreate(i);
            Plugins[i].OnLogout(Fch);
         End;

         Sendln(MakeText(LogOutMessage));
         Sendln('---------------------------------');
         Sendln(' Thank you for using the PC-9800 Central Bulletin Board!');
         Sendln(' Connection time: '+TimeToStr(Now-User.LoginTime));
         Sendln('---------------------------------');

         Sleep(100);

         Sendln(#13#10'*** Dropping connection now. ***');
         Sleep(2000);

         Terminate;

End;


Procedure TMtBBS.Who;
Var
   i : Integer;
   S,ConnectMode : String;
Begin

   If CheckUseLevel(_Whos) then Exit;

  User.Where := 'Who';
  Puts('CH User ID   Handle        Protocol Location Prot.st. Memo'#13#10);
  Puts('-- -------- -------------- -------- -------- -------- -------------------------'#13#10);
  S :='';
  For i:=0 to 99 Do
    if MainForm.Chs[i].Mode <> Cm_None then
     Begin
       With MainForm.Chs[i].Thread Do
        S := S+(Format('%.2d %.8s %.14s %.8s %.8s %.8s %.25s'#13#10
        ,[i,User.ID+'        ',User.HandleName+'              ',MainForm.Chs[i].Way+'               '
        ,User.Where+'        ',TimeToStr(User.LoginTime)+'        ',User.Memo]) );
     End;
         For i:=0 to 9 Do
  if WWWUsers[i].Enabled then
        Begin
         With WWWUsers[i] Do
           S := S+(Format('%.2d %.8s %.14s %.8s %.8s %.8s %.25s'#13#10
            ,[99-i,User.ID+'        ',User.HandleName+'              ','WWW'+'               '
            ,User.Where+'        ',TimeToStr(User.LoginTime)+'        ',User.Memo]) );
         End;

  Puts(S);
  Puts('-- -------- -------------- -------- -------- -------- -------------------------'#13#10);

End;


Procedure TMtBBS.Ip;
Var
   i : Integer;
   S : String;
Begin

   If CheckUseLevel(_Ip) then Exit;

  User.Where := 'Ip';
  Puts('CH User ID  Handle         Protocol / IP Address'#13#10);
  Puts('-- -------- -------------- --------------------------------------------------'#13#10);
  S := '@@ MYOHOST  MTBBSシステム  '+'LOCALHOST / '+MainForm.TCPServer1.LocalHostAddress+#13#10;
  For i:=0 to 99 Do
    if TMainForm(FOwner).Chs[i].Mode <> Cm_None then
     Begin
       With MainForm.Chs[i].Thread Do
        S := S + Format('%.2d %.8s %.14s %.50s'#13#10
        ,[i,User.ID+'        ',User.HandleName+'              ',MainForm.Chs[i].Way+'               ']);
     End;
  Puts(S);
  Puts('-- -------- -------------- --------------------------------------------------'#13#10);

End;



Procedure TMtBBS.Log;
Var
   i,j : Integer;
   Log : ^TAccessLog;
Begin

  If CheckUseLevel(_Log) then Exit;
  User.Where := 'Log';

  Puts(#13#10);
  Puts('User ID  Handle         CH Protocol   Date     Login     Logout    Con.time'#13#10);
  Puts('-------- -------------- -- --------- -------- --------   --------  --------'#13#10);

  Log := AllocMem(SizeOf(TAccessLog)*(GeneralDefine.Other.Log_MaxSize+1));

  j := GetAccessLog(Log^,GeneralDefine.Other.Log_MaxSize);

   For i := 0 to j-1 do
    With Log^ do
     Begin
      Puts(Format('%.8s %.14s %.2d %.9s %.8s %.8s-->%.8s (%.8s)'#13#10,
      [Id+'         ',Handle+'               ',Ch,Way+'         '
       ,DateToStr(InTime)+'         ',TimeToStr(InTime)+'         '
       ,TimeToStr(OutTime)+'         ',TimeToStr(OutTime - InTime)+'         ']));
      Inc(Log);
     End;
   Dec(Log,j);

  FreeMem(Log,SizeOf(TAccessLog)*(GeneralDefine.Other.Log_MaxSize+1));

  Puts('-------- -------------- -- --------- -------- --------   --------  --------'#13#10);
  Puts(#13#10);


End;

Procedure TMtBBS.Wait(t : Integer);
Var
  i : Integer;
Begin

  i := GetTickCount;

  While (GetTickCount < i+t) and (Not Terminated) do
    Sleep(50);

End;

Procedure TMtbbs.PlayLoginSound;
Begin
 If GeneralDefine.Sound.PlayLogin then
 Try
  With MainForm Do
   Begin
     MediaPlayer1.FileName := GeneralDefine.Sound.LoginFileName;
     MediaPlayer1.Open;
     MediaPlayer1.Play;
   End;
 Except
   MtbbsSts('Cannot play sound.');
 End;

End;

Procedure TMtbbs.PlayLogoutSound;
Begin

 If GeneralDefine.Sound.PlayLogout then
 Try
  With MainForm Do
   Begin
     MediaPlayer1.FileName := GeneralDefine.Sound.LogoutFileName;
     MediaPlayer1.Open;
     MediaPlayer1.Play;
   End;
 Except
   MtbbsSts('Cannot play sound.');
 End;
End;

Procedure TMtbbs.PlaySysopCallSound;
Begin

 Try
  With MainForm Do
   Begin
     MediaPlayer1.FileName := GeneralDefine.Sound.SysopCallFileName;
     MediaPlayer1.Open;
     MediaPlayer1.Play;
   End;
 Except
   MtbbsSts('Cannot play sound.');
 End;

End;


Procedure TMtBBS.Login;
Var
   ID,S    : String;
   UI      : TUserInit;
   T,i     : Integer;
   Attack  : Integer;
   StealthLogin : Boolean;

      MailsIndex : Array [0..99] of Integer;
      MailsCount : Integer;

Begin



  With User do
   Begin
     Level      := 0;
     Where      := 'Login';
     ID         := '?????';
     HandleName := '?????';
     Memo       := '';
     LastRead     := Now - GeneralDefine.User.GuestLastReadDate;
     LastFileNews := Now - GeneralDefine.User.GuestLastReadDate;
     LoginTime  := Now;
     UseLoginReport := True;
     For i := 0 to 99 do
        NewsEnableBoards[i] := True;

     With Options do
       Begin
         AddMessageEof := False;
       End;

   End;

  Attack := 0;

 While True Do
  Begin
    If Terminated then Exit;

     Case Attack of
       0 : ;
       1 : Wait(3000);
       2 : Wait(5000);
       3 : Wait(6000);
     End;

     StealthLogin := False;

     While Not Terminated Do
       Begin
          Puts('User ID  = ');
          ID := UpperCase(RecvLn);
           User.ID := ID;
          If ID = '$SET_LOGIN_MODE' then
          Begin
             Puts('Login Mode = ');
             s := UpperCase(Recvln);
             If Pos('STEALTH',s)>0 then
               StealthLogin := True;
          End
          else
           Break;
       End;

     if ID = GeneralDefine.User.GuestID then
      Begin
        Puts('* Guest Login *'#13#10);
        Puts('What is your handle? >');
        User.HandleName := RecvLn;
        If Terminated then Exit;
        Break;
      End Else
      Begin
         Puts('Password = ');
         UI := GetUserInit(User.ID);
         Echo := False;
         s := RecvLn;
         Puts(#13#10);
         Echo := True;
         If UI.Password = S then
          Begin
           If UI.Level = 0 then
            Begin
              Puts(#13#10#13#10'*** Your ID has been banned. ***'#13#10#13#10);
              Goodbye(False);
              Exit;
            End;
           User.HandleName := UI.Handle;
           User.Memo       := UI.Memo;
           User.Level      := UI.Level;
           User.LastRead   := UI.LastRead;
           User.LastFileNews := UI.LastFileNews;
           User.UseLoginReport := UI.UseLoginReport;
           User.NewsEnableBoards := UI.NewsEnableBoards;
           User.ReceiveTelegramBell := UI.ReceiveTelegramBell;
           Break;
          End Else
            Begin
              AddLoginError(MainForm.chs[Fch].Way,Id,s);
              SendLn('*** ID or Password is incorrect ***');
            End;
      End;
    Inc(Attack);
    If Attack>2 then
      Begin
        SendLn('*** Check your ID and password. ***');
        Wait(1000);
        SendLn('*** Connection dropped. ***');
        Exit;
      End;
  End;

   User.LoginTime := Now;
   Puts(#13#10#13#10);
   SendUserInfo;
   Boards;

   Synchronize(PlayLoginSound); //
   MtbbsSts('A user has logged in: '+User.ID+' / '+User.HandleName);

   If not StealthLogin then
    Begin
     For i := 0 to 99 do
      Begin
       if (Fch<>i) and (MainForm.Chs[i].Thread <> nil) and MainForm.Chs[i].Thread.User.UseLoginReport and GeneralDefine.Telegram.LoginTelegram then
           MainForm.Chs[i].Thread.Telegrams.Add('<< MTBBS SYSTEM >>'+#1+Format('On channel: [%.2d]に %.8s %.14s has logged in.',[Fch,User.ID,User.HandleName]));
      End;
     For i := 0 to 9 do
      Begin
       if WWWUsers[i].Enabled and WWWUsers[i].User.UseLoginReport and GeneralDefine.Telegram.LoginTelegram then
           WWWUsers[i].Telegrams.Add('<< MTBBS SYSTEM >>'+#1+Format('On channel: [%.2d]に %.8s %.14s has logged in.',[Fch,User.ID,User.HandleName]));
      End;
    End;

   Puts(#13#10);
   Puts(MakeText(LoginMessage)+#13#10);

   If MailSystem.Search(0,User.ID,True,False) > -1 then
       Begin
         Sendln('You have mail!'#13#10);
          While True do
           Case (InputCommand('[RET]:read  0:end >',False)+'*')[1] of
              '*' : Begin
                      MailsCount := MailSystem.Sort(@MailsIndex,99,User.ID,True,False);
                      ReadMail(MailsIndex,MailsCount);
                      Break;
                    End;
              '0' : Break;
           End;

       End;

   For i := 0 to PluginsCount - 1 do
     If Assigned(Plugins[i].OnLogin) then
       Begin
         PluginCreate(i);
         Plugins[i].OnLogin(fch);
       End;

   Puts(MakeText(MainMenuMessage)+#13#10);

   MainInChat := False;
   Main;

   Synchronize(PlayLogOutSound);

End;


Procedure TMtBBS.SendUserInfo;
Var
   UI : TUserInit;
Begin

     UI := GetUserInit(User.ID);

      Puts(' ID / Handle : '+User.ID+' / '+User.HandleName+#13#10);
      Puts(' Level        : '+IntToStr(User.Level)+#13#10);
      Puts(' Time left      : @@:@@:@@'#13#10);
      Puts(' Last login  : '+DateTimeToStr(UI.LastLogin)+#13#10);
      Puts(' Unread date　　  : '+DateTimeToStr(User.LastRead )+#13#10);
      Puts(' No. of accesses  : '+IntToStr(UI.AccessCount) +#13#10);

End;

(*<<<<<<<<<<<<<<<<<<<<<<<<<<<  MTBBS API >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*)

constructor TMtAPI.Create(AOwner :TObject);
Begin
   Mtbbs := TMtbbs(AOwner);
       API.Version         := Version;
       API.Terminated      := Terminated;
       API.ChangeWhere     := ChangeWhere;
       API.Sendln          := Sendln;
       API.Recvln          := Recvln;
       API.Puts            := Puts;
       API.YesNoInput      := YesNoInput;
       API.Input           := Input;
       API.InputCommand    := InputCommand;
       API.Who             := Who;
       API.Telegram        := Telegram;
       API.IsReceived      := IsReceived;
       API.IsUsedChannel   := IsUsedChannel;
       API.GetLoginUserData:= GetLoginUserData;
       API.PutEchoStrs     := PutEchoStrs;
       API.InputText       := InputText;
       API.RecvTelegram    := RecvTelegram;
       API.SendTelegram    := SendTelegram;
       API.UsersCount      := UsersCount;
       API.SearchUser      := SearchUser;
       API.ReadUserInfo    := ReadUserInfo;
       API.WriteUserInfo   := WriteUserInfo;
       API.GetLastReceiveLine := GetLastReceiveLine;//22
       API.IsReceivedTelegram := IsReceivedTelegram;//23


End;

Function TMtAPI.Version : Pchar;stdcall;
Begin
    Result := MTBBSVERSION;
End;

Function TMtAPI.Terminated : Boolean;stdcall;
Begin
  Result := _Terminated^;
End;

Procedure TMtAPI.ChangeWhere(s : Pchar);stdcall;
Begin
   Mtbbs.User.Where := s;
End;


Function TMtAPI.Recvln : PChar;stdcall;
Begin
  StrBuf := Mtbbs.Recvln;
  Result := Pchar(StrBuf);
End;

Procedure TMtAPI.Sendln(s : PChar);stdcall;
Var
   ss : String;
Begin
   ss := s;
   Mtbbs.Sendln(ss);
End;

Procedure TMTAPI.Puts(s : PChar);stdcall;
Var
   ss : String;
Begin

  ss := s;
  MTBBS.Puts(ss);

End;

Function TMTAPI.YesNoInput(Prompt:Pchar):Boolean;stdcall;
Begin
  Result := MTBBS.YesNoInput(Prompt);
End;

Function TMTAPI.Input(Prompt:Pchar):Pchar;stdcall;
Begin
  StrBuf := Mtbbs.Input(Prompt);
  Result := Pchar(StrBuf);
End;

Function TMTAPI.InputCommand(Prompt:Pchar;CharInp:Boolean):Pchar;stdcall;
Begin
  StrBuf := Mtbbs.InputCommand(Prompt,CharInp);
  Result := Pchar(StrBuf);
End;

Procedure TMTAPI.Who;stdcall;
Begin
   Mtbbs.Who;
End;

Procedure TMTAPI.Telegram;stdcall;
Begin
   Mtbbs.Telegram;
End;

Function TMTAPI.IsUsedChannel(Ch : LongInt):boolean;stdcall;
Begin
  Result := (MainForm.Chs[ch].Thread <> nil);
End;

Function TMTAPI.IsReceived:boolean;stdcall;
Begin
  Result := (Mtbbs.Wp<>Mtbbs.Rp);
End;

Function TMTAPI.InputText : Pchar;stdcall;
Begin

  StrBuf := Pchar(Mtbbs.InputText);
  Result := Pchar(StrBuf);

End;

Function TMTAPI.GetLoginUserData(Ch : LongInt):TUserData;stdcall;

   Procedure Clear;
    Begin
     With Result do
      Begin
        Result.ID         := '';
        Result.HandleName := '';
        Result.Memo       := '';
        Result.Level      := 0;
        result.Where      := '';
      End;
    End;

Begin

  if (Ch<0) or (99<ch) then
    Begin
      Clear;
      Exit;
    End;

   if MainForm.Chs[ch].Thread = nil then
       Clear
    Else
     With MainForm.Chs[ch].Thread.User do
      Begin
        Result.ID         := ID;
        Result.HandleName := HandleName;
        Result.Memo       := Memo;
        Result.Level      := Level;
        result.Where      := Where;
      End;
End;

Procedure TMTAPI.PutEchoStrs;stdcall;
Begin
   Mtbbs.PutEchoStrs;
End;

Procedure TMtAPI.RecvTelegram;
Begin

   Mtbbs.RecvTelegram;

End;

Procedure TMtAPI.SendTelegram(ToCh : Integer;From : PChar;Mes : Pchar);
Begin
   MainForm.Chs[ToCh].Thread.Telegrams.Add(From+#1+Mes);
End;

Function TMtAPI.UsersCount:Integer;stdcall;
Begin
   Result := UserInitsCount;
End;

Function TMtAPI.SearchUser(ID : PChar):Integer;stdcall;
Begin
   Result := UserSys.SearchUser(ID);
End;

Function  TMtAPI.ReadUserInfo(Index : Integer):TUserInfo;stdcall;
Begin
   Result := TUserInfo(UserInits[Index]);
End;

Procedure TMtAPI.WriteUserInfo(Index : Integer;UserInfo : TUserInfo);stdcall;
Begin
   UserInits[Index] := TUserInit(UserInfo);
End;

Function TMtAPI.GetLastReceiveLine:Pchar;stdcall;
Begin

     StrBuf := Mtbbs.RecvStrBuf[Mtbbs.Wp];
     Result := Pchar(StrBuf);

End;

Function TMtAPI.IsReceivedTelegram:boolean;stdcall;
Begin

    Result := Mtbbs.Telegrams.Count>0;

End;


(*<<<<<<<<<<<<<<<<<<<<<<<<<<<  MTBBS API END >>>>>>>>>>>>>>>>>>>>>>>>>>>>*)

var
  i : integer;
initialization

    for i:=1 to 20 do
     With ChatRooms[i] do
       Begin
        Cwp := 0;
        ChatLogFile_Assigned := False;
        AddChat_Busy         := False;
        ChatLines := 0;
       End;

     With ChatRooms[1] do
       Begin
          RoomTitle := 'Standard room';
          ID := '!SYSTEM';
          Handle := 'MTBBSｼｽﾃﾑ';
          RoomComment := ChatRoomOpeningMessage;
       End;

     SystemStartDateTime := Now;

Finalization

  for i:=1 to 20 do
   With ChatRooms[i] do
    If ChatLogFile_Assigned then
       Begin
          CloseFile(ChatLogFile);
          ChatLogFile_Assigned := False;
       End;

end.


