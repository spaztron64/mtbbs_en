unit MComm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,WSockets;

type

  TCommMode = (CM_Comm,CM_Telnet);

  TMComm = class(TThread)
  private

     TerminateWhenClose : Boolean;
     Tcp : TTCPClient;

     ReadMode : (RM_None,RM_IAC1,RM_IAC2);

     SRp,SWp,Rp,Wp  : Integer;

     procedure TCPError(Sender: TObject; Error: Integer; Msg: String);
     procedure TCPData(Sender: TObject; Socket: Integer);
     procedure TCPClose(Sender: TObject; Socket: Integer);

     Procedure Write(Buf : PChar;Size : Integer);
     procedure WaitSendLoop;

  protected

    procedure Execute; override;

  public

    CommMode : TCommMode;


    RecvBuf  : Array [0..199] of String;
    SendBuf  : Array[0..2000] of Char;

    FAddress : String;

    constructor Create(AOwner : TComponent;Address : String);
    destructor  Destroy; override;

//    procedure Close;
//    procedure OpenTelnet(Host : String);

//    procedure Read(Buffer: PChar; Size: Integer);
    Procedure Sendln(s : String);
    Procedure Puts(s : String);
    Function IsReceived : Boolean;
    Function Recvln:String;
    Function WaitStrs(Const StringS : Array of String) : Integer;


  published
    { Published 宣言 }
  end;

implementation
Uses
   MVCL;

{
   http://～/
   127.0.0.1
   110-898-7670
}

constructor TMcomm.Create(AOwner : TComponent;Address : String);
Begin

     inherited Create(True);                   // サスペンド状態で作成

    TCP := TTcpClient.Create(AOwner);

     TCP.OnData  := TCPData;
     TCP.OnError := TCPError;
     TCP.OnClose := TCPClose;

    FAddress := Address;

    TerminateWhenClose := true;

    Resume;

End;

destructor  TMComm.Destroy;
Begin

    TCP    .Free;
    inherited;

End;


Procedure TMComm.Sendln(s : String);
Begin

   Mutex.Wait;
     Write(Pchar(s+#13#10),Length(s)+2);
   Mutex.Release;

End;

Procedure TMComm.Puts(s : String);
Begin

   Mutex.Wait;
     Write(Pchar(s),Length(s));
   Mutex.Release;

End;

Function TMComm.IsReceived : Boolean;
Begin

   Result := Rp <> Wp;

End;



Function TMComm.Recvln:String;
Begin

   Mutex.Wait;

   Result := '';

     While Rp=Wp do
      Begin
         Sleep(50);
         If Terminated then Exit;
      End;

      Result := RecvBuf[Rp];

      Inc(Rp);
      If Rp > SizeOf(RecvBuf) then Rp := 0;

   Mutex.Release;

End;

Function TMComm.WaitStrs(Const StringS : Array of String) : Integer;
Var
  T,i : Integer;
  CS :string[120];
Begin

 Mutex.Wait;

   While Not(Terminated) Do
    Begin
         CS := RecvBuf[Rp];
         For i:=Low(Strings) to High(Strings) do
          Begin
            If Pos(StringS[i],CS)>0 then
              Begin
                 Result := i-Low(Strings);
                 Mutex.Release;
                 Exit;
              End;
          End;
         If Rp=Wp Then
            Sleep(50)
         Else
            RecvLn;
    End;
    Result := -1;

 Mutex.Release;

End;



Procedure TMComm.Write(Buf : PChar;Size : Integer);
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


   If Terminated Then Exit;

     Mutex.Wait;

         While FreeSize <= Size do
          Begin
             Sleep(50);
             If Terminated then
               Begin
                  Mutex.Release;
                  Exit;
               End;
          End;

         For i := 0 to Size - 1 do
          Begin
           SendBuf[Swp] := Buf[i];
           Swp := (Swp + 1) mod High(SendBuf);
          End;

     Mutex.Release;

End;


Procedure Sts(s: String);
Begin
end;

procedure TMcomm.Execute;
Var
  a,s   : String;
  P1,P2 : String;

    procedure OpenTelnet(Host : String);
    Begin
       CommMode := CM_telnet;
       Tcp.close;
    End;

    Function GetIpAddress:String;
    Var
       a : string;
    Begin

      TerminateWhenClose  := False;

         Result := '';

         Tcp.Host := P1;

         Tcp.Close;
         Tcp.Open;

         Sts(P1 + 'よりIPアドレスを拾得しています.');

         Sendln('GET /'+P2+' HTTP/1.0');
         SendLn('');

         If WaitStrs(['</HTML>','telnet://']) = 0 then
              Sts('IPアドレスを拾得できませんでした.')
          Else
           Begin
             a := RecvLn;
             a := Copy(a,Pos('://',a)+3,99);
             Result := Copy(a,1,Pos('/',a)-1);
           End;

          While (Tcp.SocketState <> ssClosed) Do
             If Terminated then Break
                           else Sleep(100);

         Tcp.Close;

       TerminateWhenClose := true;

    End;

Begin

  s := UpperCase(FAddress);

     If Pos('://',s)>0 then
     Begin

      a  := Copy(FAddress,Pos('://',FAddress)+3,99);
      P1 := Copy(a,1,Pos('/',a)-1);

      a := Copy(FAddress,Pos('://',FAddress)+3,200);
      P2 := Copy(a,Pos('/',a)+1,200);

     End;

   If Pos('HTTP',s) > 0 then
         OpenTelnet(GetIPAddress)
       else
          If Pos('TELNET',s) > 0 then
             OpenTelnet(P1)
          else
             If Pos('MODEM',s) > 0 then
        //        OpenModem(P1)
             else
                OpenTelnet(P1);

     WaitSendLoop;

End;

procedure TMComm.WaitSendLoop;
Var
  ss : String;
      Data     : PChar;
      SendSize : Integer;
      i,j,l,k    : Integer;
Begin

 Data := AllocMem(1025);
   While Not Terminated do
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
           SendSize := TCP.WriteBuffer(@Data[0],j);
//           Data[SendSize] := #0;
           SRp := (Srp+SendSize) mod High(SendBuf);
         End;
    End;
 FreeMem(Data,1025);
End;


procedure TMComm.TCPData(Sender: TObject; Socket: Integer);
Var
   Buf  : PChar;
   Size : Integer;
   i,k  : Integer;
   s    : String;
begin

  GetMem(Buf,1024+1);
    Size := TCP.ReadBuffer(Buf,1024);

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
                       If Wp > SizeOf(RecvBuf) then
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

  FreeMem(Buf,1024+1);

end;

procedure TMComm.TCPError(Sender: TObject; Error: Integer; Msg: String);
begin

     Sts('接続エラーが発生しました..'+TCP.Host);
     Terminate;

end;

procedure TMComm.TCPClose(Sender: TObject; Socket: Integer);
begin

   If TerminateWhenClose then
           Sts('接続が切れました..'+TCP.Host);


end;


end.
