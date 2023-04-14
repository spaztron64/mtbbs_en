unit Mainform;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Controls,
  Forms, StdCtrls, Buttons, ExtCtrls, Dialogs,
  Winsock, SockLib, Packet;

type
  TForm1 = class(TForm)
    Destination: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Source: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Edit4: TEdit;
    Server: TGroupBox;
    Client: TGroupBox;
    btnSsock: TButton;
    btnSlisten: TButton;
    btnSsend: TButton;
    btnSclose: TButton;
    btnCsock: TButton;
    btnCconnect: TButton;
    btnCsend: TButton;
    btnCclose: TButton;
    GroupBox4: TGroupBox;
    Status: TLabel;
    BtnExit: TBitBtn;
    Label7: TLabel;
    OpenDialog1: TOpenDialog;
    Open: TBitBtn;
    Bevel1: TBevel;
    Filename: TLabel;
    Loopback: TCheckBox;
    localhost: TCheckBox;
    SaveDialog1: TSaveDialog;
    procedure BtnExitClick(Sender: TObject);
    procedure btnSsockClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Edit4Change(Sender: TObject);
    procedure btnSlistenClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure btnCsockClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure btnCconnectClick(Sender: TObject);
    procedure LoopbackClick(Sender: TObject);
    procedure localhostClick(Sender: TObject);
    procedure OpenClick(Sender: TObject);
  private
    { Private êÈåæ }
    procedure WSAConnect(var Msg: TMSG); message CM_WSAConnect;
    procedure WSARead(var Msg: TMSG); message CM_WSARead;
    procedure WSAClose(var Msg: TMSG); message CM_WSAClose;
  public
    { Public êÈåæ }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

{ ----------------------- Global variable ----------------------------------- }

const
  cszTitle = 'Socket Tester 32bit edition Rev.1.0';
  
var
  sock,
  ssock     : TSOCKET;
  MyAddr,
  FromAddr,
  ToAddr    : TSockAddrIn;
  buf       : Tpacket;

  Files     : Textfile;
  sbuf      : Tpacket;
  filebuf   : array[1..512] of byte;
  Logging   : boolean;

{ ----------------------- Process Main -------------------------------------- }

procedure TForm1.FormCreate(Sender: TObject);
begin
  if ws_init <> 0 then begin
    ShowMessage('Winsock is not installed.');
    close;
  end;

  Caption          := cszTitle;
  btnSsock.Enabled := True;
  btnCsock.Enabled := True;
  Logging          := False;
end;

procedure TForm1.BtnExitClick(Sender: TObject);
begin
  closesocket(ssock);
  closesocket(sock);
  ws_term;
  close;
end;

procedure TForm1.btnCloseClick(Sender: TObject);
begin
  PostMessage(handle, CM_WSAClose, sock, sock);
end;

procedure TForm1.btnSendClick(Sender: TObject);
var
  userData: string;
  slen    : integer;

begin
  Status.Caption := 'Sending';
  slen := 0;

  if Eof(Files) then begin
    ShowMessage('No more send data in file');
    CloseFile(Files);
    if Server.Enabled then
      btnSsend.Enabled := False
    else
      btnCsend.Enabled := False;
    Exit
  end;

  with sbuf.header do begin
    FillChar(sbuf, SizeOf(sbuf), $00);
    System.Readln(Files, Task_ID,
                         Req_ID,
                         GUI_ID,
                         SYS_ID,
                         Len,
                         Results,
                         UserData);

    { sbuf.header.Len is dummy, it will set program itself correctly }
    if Len <> 0 then begin
      StrPCopy(sbuf.data, UserData);
      slen := Length(UserData);
      Len := htonl(slen);
    end;
  end;
  slen := slen + Header_Size;

  send(sock, sbuf, slen, 0);

  if Logging then sendLog('Tester', sbuf);
end;

procedure TForm1.OpenClick(Sender: TObject);
begin
  if not OpenDialog1.Execute then Exit;

  FileName.Caption := ExtractFileName(OpenDialog1.FileName);

  { Correct Filename is selected }
  System.AssignFile(Files, OpenDialog1.FileName);
  FileMode := 0;                       {File is readonly mode}
  System.SetTextBuf(Files, FileBuf);
  System.Reset(Files);

  { select send botton }
  if Server.Enabled then
    btnSsend.Enabled := True
  else
    btnCsend.Enabled := True;

  Open.Enabled := False;
  Status.Caption := 'File Opened';
end;

{ ----------------------- Shared Process ------------------------------------ }

procedure TForm1.WSAClose(var Msg: TMSG);
begin
  Status.Caption := 'Close';
  WSAAsyncSelect(Msg.wParam, handle, 0, 0);
  closesocket(Msg.wParam);

  Self.FileName.Caption := 'FileName';
  Open.Enabled          := False;
  closeLog(Logging);

  btnSsend.Enabled  := False;
  btnSClose.Enabled := False;
  btnCsend.Enabled  := False;
  btnCClose.Enabled := False;

  btnSsock.Enabled  := True;
  btnCsock.Enabled  := True;
  Client.Enabled    := True;
  Server.Enabled    := True;
end;

procedure TForm1.WSARead(var Msg: TMSG);
var
  packlen: longint;
  rlen   : longint;

begin
  Status.Caption := 'Receiving';

  { read Common packet header }
  FillChar(buf, SizeOf(buf), $00);
  rlen := recv(sock, buf.header, HEADER_SIZE, 0);

  { Check close request }
  if rlen <= 0 then begin
    Status.Caption := 'Close Req';
    PostMessage(handle, CM_WSAClose, sock, sock);
    exit;
  end;

  { read USER-data }
  packlen := ntohl(buf.header.Len);
  if packlen > 0 then recv(sock, buf.Data, packLen, 0);

  {Ignore illeagal request if it's received. }
  if buf.Header.Task_ID = $00 then exit;

  { Logging receieve data }
  if Logging then recvLog('Tester', buf);

  { Check response packet }
  if (buf.header.Req_ID and $80) <> 0 then Exit;

  { send response }
  buf.header.Req_ID := buf.header.Req_ID or $80; { make response}
  send(sock, buf, (packlen + HEADER_SIZE), 0);
  if Logging then sendLog('Tester', buf);

end;

{ ----------------------- Server Process ------------------------------------ }

procedure TForm1.btnSsockClick(Sender: TObject);
begin
  { Display executing mode }
  Form1.Caption := cszTitle + ' in [ SERVER ]';
  { make socket for server facility }
  ssock := socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  if ssock = INVALID_SOCKET then begin
    ShowMessage('Socket can not create.');
    Exit;
  end;

  Status.Caption := 'Socket';

  { Open record log file }
  Logging := False;
  SaveDialog1.FileName := getLogFileName('SV');
  if SaveDialog1.Execute then begin
    openLog(SaveDialog1.FileName);
    Logging := True;
  end;

  { Window and cursor control }
  btnSsock.Enabled    := False;
  btnCsock.Enabled    := False;
  Client.Enabled      := False;
  Destination.Enabled := False;
  Source.Enabled      := True;
  Edit1.Text          := 'No need to set';
  Edit2.Text          := 'No need to set';
  Edit4.Enabled       := True;
  Edit4.Text          := '';
  localhost.Checked   := True;
  loopback.Checked    := False;
  localhost.SetFocus;
end;

procedure TForm1.LoopbackClick(Sender: TObject);
begin
  if Loopback.Checked then
    Localhost.Checked := False
  else
    Localhost.Checked := True;
  Edit4.SetFocus;
end;

procedure TForm1.localhostClick(Sender: TObject);
begin
  if Localhost.Checked then
    Loopback.Checked  := False
  else
    Loopback.Checked  := True;
  Edit4.SetFocus;
end;

procedure TForm1.Edit4Change(Sender: TObject);
begin
  if Server.Enabled then btnSlisten.Enabled  := True;
end;

procedure TForm1.btnSlistenClick(Sender: TObject);
var
  port : integer;
begin
  Edit4.Enabled := False;
  try
    port := StrToInt(Edit4.Text);
  except
    on EConvertError do begin
      ShowMessage('Port must be number.');
      btnSlisten.Enabled := False;
      Edit4.Enabled := True;
      Edit4.SetFocus;
      Exit;
    end;
  end;

  { bind }
  Status.Caption := 'Binding';
  Source.Enabled := False;

  FillChar(MyAddr, SizeOf(MyAddr), $00);
  MyAddr.sin_family := AF_INET;
  MyAddr.sin_port := htons(port);
  if localhost.Checked then MyAddr.sin_addr.s_addr := htonl(INADDR_ANY);
  if loopback.Checked then MyAddr.sin_addr.s_addr := htonl(INADDR_LOOPBACK);
  if bind(ssock, TSOCKADDR(MyAddr), SizeOf(MyAddr)) <> 0 then begin
    ShowMessage('It does not Bind.');
    btnSlisten.Enabled := True;
    Source.Enabled := True;
    Edit4.Enabled := True;
    Edit4.SetFocus;
    Exit;
  end;

  { Listen }
  Status.Caption     := 'Listening';
  btnSlisten.Enabled := False;

  if (listen(ssock, SOMAXCONN) < 0) then begin
    ShowMessage('It can not listen.');
    PostMessage(handle, CM_WSAClose, ssock, ssock);
    Exit;
  end;

  {Select wait for connecting request}
  WSAAsyncSelect(ssock, handle, CM_WSAConnect, (FD_ACCEPT));

end;

{receiving a connect request and accepting }
procedure TForm1.WSAConnect(var Msg: TMSG);
var
  AddrLen: integer;

begin
  Status.Caption := 'Accept';

  FillChar(FromAddr, SizeOf(FromAddr), $00);
  AddrLen := SizeOf(FromAddr);
  sock := accept(ssock, TSOCKADDR(FromAddr), AddrLen);
  {The above sock is new socket which is already connected to peer.
   It will use following procceses. The ssock, hence, is not need.}

  {close old socket}
  closesocket(ssock);

  if sock = INVALID_SOCKET then begin
    ShowMessage('It does not accept connection request.');
    Exit;
  end;

  { --- Show connected hostname ---}
{
  FillChar(ip, SizeOf(ip), $00);
  ip := inet_ntoa(FromAddr.sin_addr);
  ptr := gethostbyaddr(@FromAddr.sin_addr.s_addr, SizeOf(FromAddr.sin_addr.s_addr), PF_INET);
  if ptr <> nil then begin
      Edit1.Text := StrPas(ptr^.h_name);
    end
  else
    begin
      Edit1.Text := 'Unknown';
  end;
}

  Edit2.Text := IntToStr(ntohs(FromAddr.sin_port));
  Status.Caption := 'Connecting';

  {Wait receiving or close request}
  WSAAsyncSelect(sock, handle, CM_WSARead, (FD_READ or FD_CLOSE));
  Open.Enabled       := True;
  btnSclose.Enabled  := True;
end;

{ ----------------------- Client Process ------------------------------------ }

procedure TForm1.btnCsockClick(Sender: TObject);
begin
  { Display executing mode }
  Form1.Caption := cszTiTle + ' in [ CLIENT ]';

  { make socket for client facility }
  sock := socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  if sock <= 0 then begin
    ShowMessage('Socket can not create.');
    Exit;
  end;

  { Open record log file }
  Logging := False;
  SaveDialog1.FileName := getLogFileName('CL');
  if SaveDialog1.Execute then begin
    openLog(SaveDialog1.FileName);
    Logging := True;
  end;

  Status.Caption := 'Socket';

  { Window and cursor control }
  btnSsock.Enabled    := False;
  Server.Enabled      := False;
  btnCsock.Enabled    := False;
  Destination.Enabled := True;
  Source.Enabled      := False;
  Edit1.Text          := '';
  Edit2.Text          := '';
  Edit4.Text          := 'No need to set';

  Edit1.SetFocus;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  if (Edit1.Text <> '') and (Edit2.Text <> '') then begin
    if Client.Enabled then btnCconnect.Enabled := True;
  end;
end;

procedure TForm1.Edit2Change(Sender: TObject);
begin
  if (Edit1.Text <> '') and (Edit2.Text <> '') then begin
    if Client.Enabled then btnCconnect.Enabled := True;
  end;
end;

procedure TForm1.btnCconnectClick(Sender: TObject);
var
  ip     : u_long;
  port   : integer;
  pip    : array[0..20] of char;

begin
  { bind }
  Status.Caption := 'Binding';
  Destination.Enabled := False;

  { Retreave ip address }
  FillChar(pip, SizeOf(pip), $00);
  StrPLCopy(pip, Edit1.Text, SizeOf(pip));
  ip := inet_addr(pip);
  if ip = 0 then begin
      ShowMessage('IP must be "xxx.xxx.xxx.xxx" form.');
      Destination.Enabled := True;
      btnCconnect.Enabled := False;
      Edit1.Enabled := True;
      Edit1.SetFocus;
      Exit;
  end;

  { Retreave port number }
  try
    port := StrToInt(Edit2.Text);
  except
    on EConvertError do begin
      ShowMessage('Port must be number.');
      btnCconnect.Enabled := False;
      Destination.Enabled := True;
      Edit2.Enabled := True;
      Edit2.SetFocus;
      Exit;
    end;
  end;

  { Connecting }
  Status.Caption := 'Connecting';
  FillChar(ToAddr, SizeOf(ToAddr), $00);
  ToAddr.sin_family := AF_INET;
  ToAddr.sin_port := htons(port);
  ToAddr.sin_addr.s_addr := ip;
  if connect(sock, TSOCKADDR(ToAddr), Sizeof(ToAddr)) <> 0 then begin
    ShowMessage('Server does not response to connect request.');
    PostMessage(handle, CM_WSAClose, sock, sock);
    exit;
  end;

  { Connecting }
  Status.Caption := 'Connected';

  {Wait receiving or sending}
  WSAAsyncSelect(sock, handle, CM_WSARead, (FD_READ or FD_CLOSE));
  btnCconnect.Enabled := False;
  Open.Enabled        := True;
  btnCclose.Enabled   := True;
end;

end.
