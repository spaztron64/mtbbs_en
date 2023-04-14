unit Mainform;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls,
  WinSock;

type
  TForm1 = class(TForm)
    Exit: TButton;
    Label1: TLabel;
    Image1: TImage;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    TCPs: TLabel;
    UDPs: TLabel;
    procedure ExitClick(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.ExitClick(Sender: TObject);
const
  iMaxSocket = 512;

var
  WsaData: TWSADATA;
  cnt, i, iMax: integer;
  Sockets: array[1..iMaxSocket] of TSOCKET;

begin
  if Exit.Default = True then close;

  Exit.Default := True;
  Exit.Caption := 'OK';

{ Creating SOCKETs as many as possible, if it is smaller than iMaxSocket}

  if (WSAStartUp($0101, WsaData) = 0) then begin

  FillChar(Sockets, SizeOf(Sockets), $00);

  { Set loop-count }
  iMax := iMaxSocket;
  if WsaData.iMaxSockets < iMaxSocket then iMax := WsaData.iMaxSockets;

  { Create TCP SOCKETs }
    cnt := 0;
    repeat
      inc(cnt);
      Sockets[cnt] := socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    until ((Sockets[cnt] <= 0) or (cnt = iMax));
    if not ((cnt = iMax) and (Sockets[cnt] > 0)) then dec(cnt);
    TCPs.Caption := IntToStr(cnt);
    for i := 1 to cnt do closesocket(Sockets[i]);

  { Create UDP SOCKETs }
    cnt := 0;
    repeat
      inc(cnt);
      Sockets[cnt] := socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
    until ((Sockets[cnt] <= 0) or (cnt = iMax));
    if not ((cnt = iMax) and (Sockets[cnt] > 0)) then dec(cnt);
    UDPs.Caption := IntToStr(cnt);
    for i := 1 to cnt do closesocket(Sockets[i]);

  end;
  WSACleanUP;
end;

end.
