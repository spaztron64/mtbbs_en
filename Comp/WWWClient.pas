unit WWWClient;


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Wsockets_;

Type

  TWWWClientAction         = (WA_GET,WA_POST,WA_IDLE);
  TWCOnReceive             = procedure (Sender: TObject;s : String)     of object;
  TWCOnGetHTML             = procedure  (Sender: TObject; HTML : String) of object;
  TWCOnStatusOut           = procedure (Sender: TObject;Status : String)of object;
  TWCOnConnect             = procedure (Sender: TObject)                of object;
  TWCOnDisConnect          = procedure (Sender: TObject)                of object;
  TWCOnError               = procedure (Sender: TObject;ErrMes : String)of object;


  TWWWClient = class(TComponent)
  private

     TCP : TTcpClient;
     Action : TWWWClientAction;
     ReadMode : (RM_None,RM_IAC1,RM_IAC2);
     ReceiveMode  : (RM_RECEIVE_HEAD,RM_RECEIVE_CONTENT,RM_RECEIVE_TEXT);
     ContentLength : integer;
     PostData : string;

     SendThread  : TObject;
     WorkThread  : TObject;

     FUserID     : String;
     FPassword   : String;
     FHandleName : String;
     FURL        : String;

     FOnReceive               : TWCOnReceive;
     FOnGetHTML               : TWCOnGetHTML;
     FOnStatusOut             : TWCOnStatusOut;
     FOnConnect               : TWCOnConnect;
     FOnDisConnect            : TWCOnDisConnect;

     procedure TCPError(Sender: TObject; Error: Integer; Msg: String);
     procedure TCPData(Sender: TObject; Socket: Integer);
     procedure TCPClose(Sender: TObject; Socket: Integer);
     procedure ReceiveText(Buf : Pchar;Size: Integer);

     Procedure Sendln(S : String);
     Procedure Puts(s : String);


  protected

  public

     Rp,Wp  : Integer;
     RecvBuf  : Array [0..999] of String;
     ReceiveDataBuf : Pchar;
     ReceiveDataBufSize : Integer;
     ReceiveDataBufWP : Integer;
     ReceiveDataBufContentStart : Integer;

     Busy : boolean;

    Procedure Logout;
    Procedure Get;
    Procedure Post(Data : String);
//    Procedure Post(Data : String);
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;

  published

    property UserID   : String Read  FUserID
                                   write  FUserID;
    property Password : String Read  FPassword
                                   write  FPassword;
    property HandleName : String Read  FHandleName
                                write  FHandleName;
    property URL : String read FURL write FURL;


// メインスレッドと同期
    property OnConnect : TWCOnConnect read  FOnConnect
                                      write FOnConnect;
    property OnDisConnect : TWCOnDisConnect read  FOnDisConnect
                                      write FOnDisConnect;
    property OnGetHTML : TWCOnGetHTML read FOnGetHTML
                                                    write FOnGetHTML;
    property OnStatusOut : TWCOnStatusOut read FOnStatusOut
                                         write FOnStatusOut;


  end;

  TWorkThread = class(TThread)
  private

    _ : TWWWClient;
        P1,P2,P3,P4 : Pointer;

    Procedure OnReceive;
    Procedure OnGetHTML;
    Procedure OnStatusOut;
    Procedure OnConnect;
    Procedure OnDisConnect;
    Procedure Login;

    Function Recvln:String;
    Procedure Wait(S : String);
    Function WaitStrs(Const StringS : Array of String) : Integer;
    Procedure Sts(s: String);
    Procedure Sendln(S : String);
    Procedure Puts(s : String);
    Function IsReceived : Boolean;
    Function ReadBufLines(StartRp,EndRp : Integer):String;

  protected

    procedure Execute; override;

  public

    constructor Create(AOwner : TComponent);
    destructor  Destroy; override;

  published
  end;

  TSendThread = class(TThread)
  private
     _ : TWWWClient;
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
  RegisterComponents('MYO', [TWWWClient]);
end;

constructor TWWWClient.Create(AOwner: TComponent);
Var
  i,j : Integer;
begin

  inherited Create(AOwner);

  Action := WA_IDLE;
  TCP   := TTcpClient.Create(Self);

  ReceiveDataBufSize := 100000;
  GetMem(ReceiveDataBuf,ReceiveDataBufSize);

  With TCP do
   Begin
     OnData  := TCPData;
     OnError := TCPError;
     OnClose := TCPClose;
   End;

    For i := 1 to 43 do
    Begin
       For j := 0 to 10 do
         RecvBuf[i*20+j] := Copy('                                            ',1,j+1)
             + 'WWW MESSAGE READER'
             +Copy('                                                                 ',1,20-j*2+1)
             +' COPYRIGHT (C) 1999.10 BY YOSHIHIRO MYOKAN';
       For j := 0 to 10 do
         RecvBuf[i*20+j+10] := Copy('                                            ',1,11-j)
             + '------'
             +Copy('                                                                ',1,j*2+1)
             + '-----';
    End;

end;

destructor TWWWClient.Destroy;
begin

   TCP.Close;
   FreeMem(ReceiveDataBuf,ReceiveDataBufSize);

  If Assigned(TCP) then TCP.Free;
  inherited Destroy;

end;


Procedure TWWWClient.Get;
Begin

    If Action<>WA_IDLE then
      Begin
        If Assigned(FOnStatusOut) then FOnStatusOut(self,'すでに接続されています');
        Exit;
      End;
   FOnConnect(Self);
   SendThread  := TSendThread.Create(Self);
   WorkThread  := TWorkThread.Create(self);
   Action := WA_GET;

End;

Procedure TWWWClient.Post(Data : string);
Begin

    If Action<>WA_IDLE then
      Begin
        If Assigned(FOnStatusOut) then FOnStatusOut(self,'すでに接続されています');
        Exit;
      End;
   FOnConnect(Self);
   PostData := Data;
   Action := WA_Post;
   SendThread  := TSendThread.Create(Self);
   WorkThread  := TWorkThread.Create(self);

End;

procedure TWWWClient.TCPData(Sender: TObject; Socket: Integer);
Var
   Size : Integer;
begin

     Size := TCP.ReadBuffer(@ReceiveDataBuf[ReceiveDataBufWP],ReceiveDataBufSize-ReceiveDataBufWP);
    case ReceiveMode of
       RM_RECEIVE_HEAD,RM_RECEIVE_TEXT   :
                     ReceiveText(@ReceiveDataBuf[ReceiveDataBufWP],Size);
    End;

     ReceiveDataBufWP := ReceiveDataBufWP + Size;
     if ReceiveDataBufSize-ReceiveDataBufWP<4096 then
      Begin
        ReceiveDataBufSize := ReceiveDataBufSize + 100000;
        ReallocMem(ReceiveDataBuf,ReceiveDataBufSize);
      End;

end;


procedure TWWWClient.ReceiveText(Buf : Pchar;Size: Integer);
Var
   i,j,k  : Integer;
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

                       if (ReceiveMode = RM_RECEIVE_HEAD) and (s = '') then
                        Begin
                           ReceiveMode := RM_RECEIVE_CONTENT;
                           ReceiveDataBufContentStart := i+ReceiveDataBufWp+2;
                           Break;
                        End;
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
    if assigned(FOnReceive) then
     FOnReceive(self,Pchar(Buf));


end;

procedure TWWWClient.TCPError(Sender: TObject; Error: Integer; Msg: String);
begin

      If Assigned(FOnStatusOut) then FOnStatusOut(self,'エラーが発生しました..'+TCP.Host+#13#10+msg);
      if WorkThread<>nil then
        TThread(WorkThread).Terminate;

end;

procedure TWWWClient.TCPClose(Sender: TObject; Socket: Integer);
begin

   sleep(1000);
   if WorkThread<>nil then TThread(WorkThread).Terminate;

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


Procedure TWWWClient.Puts(s : String);
Begin

     If SendThread <> nil then TSendThread(SendThread).Write(Pchar(s),Length(s));

End;

Procedure TWWWClient.Sendln(S : String);
Begin

  If SendThread <> nil then TSendThread(SendThread).Write(Pchar(s+#13#10),Length(s)+2);

End;

Procedure TWWWClient.Logout;
Begin

   if Tcp.SocketState = ssClosed then
      TCP.Close;

   If (WorkThread <> nil) and (SendThread <>nil) then
      Begin
        TThread(WorkThread).Terminate;
      End
    Else
      If Assigned(FOnStatusOut) then FOnStatusOut(self,'接続されていません');

end;

(*************************** 実行スレッド *********************************)

constructor TWorkThread.Create(AOwner : TComponent);
Begin

    inherited Create(True);                   // サスペンド状態で作成
    _ := TWWWClient(AOwner);
    Resume;

End;

destructor TWorkThread.Destroy;
Begin

    _.WorkThread := Nil;
    inherited;

End;


Procedure TWorkThread.OnReceive;
Begin
    if Assigned(_.FOnReceive) then  _.FOnReceive(_,Pchar(P1));
End;

Procedure TWorkThread.OnGetHTML;
Begin
    if Assigned(_.FOnGetHTML) then _.FOnGetHTML(_,Pchar(P1));
End;

Procedure TWorkThread.OnStatusOut;
Begin
    if Assigned(_.FOnStatusOut) then _.FOnStatusOut(_,Pchar(P1^));
End;
Procedure TWorkThread.OnConnect;
Begin
    if Assigned(_.FOnConnect) then _.FOnConnect(_);
End;
Procedure TWorkThread.OnDisConnect;
Begin
    if Assigned(_.FOnDisConnect) then _.FOnDisConnect(_);
End;


procedure TWorkThread.Execute;
Var
                a,s : string;

Begin
 _.Busy := true;
  Priority        := TpHigher;
   _.Rp := 0;
   _.Wp := 0;
   _.ReceiveMode := RM_RECEIVE_HEAD;
   _.ContentLength := 0;
   _.ReceiveDataBufContentStart := 0;
   _.ReceiveDataBufWp := 0;

     Login;
     Terminate;
     Synchronize(_.Logout);

   If _.SendThread <> nil then
     TSendThread(_.SendThread).Terminate;
   _.WorkThread := nil;

   While _.SendThread<>nil do
       Sleep(5);
   Synchronize(OnDisConnect);
  _.Busy := false;
  FreeOnTerminate :=  True;
  _.Action := WA_IDLE;
End;


procedure TWorkThread.Login;
Var
  a,s      : String;
  A1,A2,A3 : String;
  i,j,k : Integer;

    Procedure Get;
    Var
       a : string;
       ContentLength :  integer;
    Begin
         Sts(A1+' , '+A2+ 'よりＨＴＭＬ文章を拾得しています....');

         if _.action = WA_Get then
            Sendln('GET /'+A2+' HTTP/1.0')
        else
         if _.action = WA_Post then
           Begin
            Sendln('POST /'+A2+' HTTP/1.0');
            Sendln('Content-Length: '+IntToStr(Length(_.PostData)));
           End;

         SendLn('USER_AGENT:MyoWWWBoardReader 1.0');
         Sendln('REFERER:http://member.nifty.ne.jp/myo/');
         Sendln('');

         if _.action = WA_Post then
            Puts(_.PostData);

         a := '';
         a := Recvln;

         ContentLength := 0;
         if (pos('HTTP/',a)>0) and (Pos(' 200 ',a)>0) then
          Begin
             While true do
              begin
               a := Recvln;
               if Pos('Content-Length: ',a)=1 then
                   ContentLength := StrToIntDef(Copy(a,17,99),0);
               if (_.Rp=_.Wp) and (Terminated or (_.TCP.SocketState = ssClosed)) then break;
               if a= '' then break;
              End;
          End;

         If Terminated then exit;

              _.ContentLength := ContentLength;
            if ContentLength>0 then
             Begin
                While (_.ReceiveDataBufWP-_.ReceiveDataBufContentStart<ContentLength) and not(Terminated) do
                 Begin
                   Sts(A1+' , '+A2+ 'からデータ受信中です...'+IntToStr(_.ReceiveDataBufWP-_.ReceiveDataBufContentStart)+'/'+IntToStr(ContentLength));
                   sleep(500);
                  End;
             End
            else
             Begin
               While Not Terminated do
                 Begin
                  Sts(A1+' , '+A2+ 'からデータ受信中です...'+IntToStr(_.ReceiveDataBufWP-_.ReceiveDataBufContentStart)+'バイト');
                  sleep(500);
                 End;
             End;

            Sts('ＨＴＭＬ文章を拾得しました...');

            _.ReceiveDataBuf[_.ReceiveDataBufWP]:=#0;
            P1 := @_.ReceiveDataBuf[_.ReceiveDataBufContentStart];
            Synchronize(OnGetHTML);
    End;


Begin

  s := UpperCase(_.FURL);
  A1 :=_.FURL;
  A2 :='';
  A3 :='';

     If Pos('://',s)>0 then
     Begin

      a  := Copy(_.FURL,Pos('://',_.FURL)+3,99);

      A1 := Copy(a,1,Pos('/',a)-1);
      A3 := Copy(A1,Pos(':',A1+':')+1,99);
      A1 := Copy(A1,1,Pos(':',A1+':')-1);

      a := Copy(_.FURL,Pos('://',_.FURL)+3,200);
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

      Sts(A1 + 'に接続中');

      With _ do
        Begin
          If A3='' then
              TCP.Port := '80'
          else
              TCP.Port := A3;
         TCP.Host := A1;
         if (_.TCP.SocketState <> ssClosed) then
            TCP.close;
         TCP.Open;
        End;

   while (_.TCP.SocketState <> ssConnected) do
    Begin
       sleep(50);
      If Terminated then exit;
    End;

   Get;

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


Function TWorkThread.RecvLn  : String;
Begin

     While (_.Rp=_.Wp) do
      Begin
         If Terminated or (_.TCP.SocketState = ssClosed) then
         exit;
         Sleep(50);
      End;

      Result := _.RecvBuf[_.Rp];
      Inc(_.Rp);
      If _.Rp > High(_.RecvBuf) then _.Rp := 0;

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

(*************************** 送信スレッド *********************************)
constructor TSendThread.Create(AOwner : TComponent);
Begin

    inherited Create(True);                   // サスペンド状態で作成
    _ := TWWWClient(AOwner);

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

Begin
 SRp := 0;
 Swp := 0;

 Data := AllocMem(1025);

 While Not Terminated do
   Begin
       k := SRp;
       If (k<>SWp) then
         Begin
           j := 0;
           While (k <> SWp) and Not Terminated Do
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
  FreeMem(Data,1025);
  FreeOnTerminate := True;
  _.SendThread := nil;
  While _.WorkThread<>nil do
    sleep(5);

End;



end.
