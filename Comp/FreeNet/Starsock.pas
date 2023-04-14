unit starsock;
{
Copyright (©) 1997  Tony BenBrahim
This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Library General Public License as published by the Free
Software Foundation
This library is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Library General Public License for more details.
You should have received a copy of the GNU Library General Public License along
with this library; if not, write to the:

Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA  02111-1307, USA.
}

interface

uses Classes,WinTypes,WinProcs,Messages,SysUtils;

{$I WINSOCK.INC}

{$IFDEF WIN32}
Taccept=function(s : TSock; addr : PSockaddr; addrlen : PInteger) : TSock;stdcall;
Tbind=function(s : TSock; addr : Psockaddr; namelen : integer) : integer;stdcall;
Tclosesocket=function(s : TSock) : integer;stdcall;
TConnect=function(s : TSock; name : Psockaddr; namelen : integer) : integer;stdcall;
Tioctlsocket=function(s : TSock; cmd : longint; argp : u_long) : integer;stdcall;
Tgetpeername=function(s : TSock; name : Psockaddr; namelen : Pinteger) : integer;stdcall;
Tgetsockname=function(s : TSock; name : Psockaddr; namelen : Pinteger) : integer;stdcall;
Tgetsockopt=function(s : TSock; level, optname : integer; optval : PChar; optlen : integer) : integer;stdcall;
Thtonl=function(hostlong : u_long) : u_long;stdcall;
Thtons=function(hostshort : u_short) : u_short;stdcall;
Tinet_addr=function(cp : PChar) : u_long; stdcall;{PIn_Addr;}  { in_addr }
Tinet_ntoa=function(inaddr : in_addr) : PChar;stdcall;
TlistenProc=function(s : TSock; backlog : integer) : integer;stdcall;
Tntohl=function(netlong : u_long) : u_long;stdcall;
Tntohs=function(netshort : u_short) : u_short;stdcall;
Trecv=function(s : TSock; buf : PChar; len, flags : integer) : integer;stdcall;
Trecvfrom=function(s : TSock; buf : PChar; len, flags : integer; from : sockaddr; fromlen : integer) : integer;stdcall;
Tselect=function(nfds : integer; readfds, writefds, exceptfds : fd_set; timeout : timeval) : longint;stdcall;
Tsend=function(s : TSock; buf : PChar; len, flags : integer) : integer;stdcall;
Tsendto=function(s : TSock; buf : PChar; len, flags : integer; addrto : sockaddr; tolen : integer) : integer;stdcall;
Tsetsockopt=function(s : TSock; level, optname : integer; optval : PChar; optlen : integer) : integer;stdcall;
Tshutdown=function(s : TSock; how : integer) : integer;stdcall;
Tsocket=function(af, struct, protocol : integer) : TSock;stdcall;
Tgethostbyaddr=function(addr : PChar; len, struct : integer) : PHostEnt; stdcall;{ hostent }
Tgethostbyname=function(name : PChar) : PHostEnt;stdcall; { hostent }
Tgethostname=function(name : PChar; len : integer) : integer;stdcall;
Tgetservbyport=function(port : integer; proto : PChar) : PServEnt;stdcall; { servent }
Tgetservbyname=function(name, proto : PChar) : PServEnt;stdcall; { servent }
Tgetprotobynumber=function(proto : integer) : PProtoEnt;stdcall; { protoent }
Tgetprotobyname=function(name : PChar) : PProtoEnt;stdcall; { protoent }
TWSAStartup=function(wVersionRequired : word; lpWSData : LPWSADATA) : integer;stdcall;
TWSACleanup=function  : integer;stdcall;
TWSASetLastError=procedure(iError : integer);stdcall;
TWSAGetLastError=function  : integer;stdcall;
TWSAIsBlocking=function  : BOOL;stdcall;
TWSAUnhookBlockingHook=function  : integer;stdcall;
TWSASetBlockingHook=function  (lpBlockFunc : TFarProc) : TFarProc;stdcall;
TWSACancelBlockingCall=function  : integer;stdcall;
TWSAAsyncGetServByName=function  (HWindow : HWND; wMsg : u_int; name, proto, buf : PChar; buflen : integer) : THandle;stdcall;
TWSAAsyncGetServByPort=function  ( HWindow : HWND; wMsg, port : u_int; proto, buf : PChar; buflen : integer) : THandle;stdcall;
TWSAAsyncGetProtoByName=function  (HWindow : HWND; wMsg : u_int; name, buf : PChar; buflen : integer) : THandle;stdcall;
TWSAAsyncGetProtoByNumber=function  (HWindow : HWND; wMsg : u_int; number : integer;
                                      buf : PChar; buflen : integer) : THandle;stdcall;
TWSAAsyncGetHostByName=function  (HWindow : HWND; wMsg : u_int; name, buf : PChar; buflen : integer) : THandle;stdcall;
TWSAAsyncGetHostByAddr=function  (HWindow : HWND; wMsg : u_int; addr : PChar; len, struct : integer;
                                  buf : PChar; buflen : integer) : THandle;stdcall;
TWSACancelAsyncRequest=function  (hAsyncTaskHandle : THandle) : integer;stdcall;
TWSAAsyncSelect=function  (s : TSock; HWindow : HWND; wMsg : u_int; lEvent : longint) : integer;stdcall;
{$ENDIF}
function WSAMakeSyncReply (Buflen, Error : Word) : LongInt;
function WSAMakeSelectReply (Event, Error : Word) : LongInt;
function WSAGetAsyncBuflen (Param : LongInt) : Word;
function WSAGetAsyncError (Param : LongInt) : Word;
function WSAGetSelectEvent (Param : LongInt) : Word;
function WSAGetSelectError (Param : LongInt) : Word;

const
        WM_ARPDONE=WM_USER;
        WM_SOCKMSG=WM_USER+1;

        WM_STARSOCKLAST=WM_SOCKMSG;

type TSSWndMethod=procedure(var Message: TMessage) of object;

type TStarSocket=class(TComponent)
private
        FHandle: HWND;
        FSocket: TSock;
	FAddr: sockaddr_in;
	FConnected: boolean;
	FBytesSent: integer;
        WinsockLib: THandle;
        FWinsockLoaded,FWinsockInitialized: Boolean;
        FDescription: string;
        FSystemStatus: string;
        FMaxSockets: integer;
        FCustomMessage: TSSWndMethod;
        MyWsaData: WsaData;
        FLookupNameDone,FOnConnected,FOnDisconnected,FTimeoutEvt: TNotifyEvent;
        FOnReadReady,FOnWriteReady,FOnAccept: TNotifyEvent;
        HostEntryBuf: array[1..MAXGETHOSTSTRUCT] of byte;
        sa: in_addr;
        ArpHandle: THandle;
        FConnTO,FArpTO,FTransTO: LongInt;
        Timer: LongInt;
        TimerID: LongInt;
        dnsbuf: array[1..64] of char;
        procedure SockWndProc(var Message : TMessage);
protected
        FVersion: string;
        procedure LookupNameDone;virtual;
        procedure Connected;
        procedure Disconnected;
        procedure ReadReady;
        procedure WriteReady;
        procedure AcceptReady;
public
        Address,Host,Server: string;
        Port: u_short;
        LastError: word;
        constructor Create(AOwner: TComponent);override;
        destructor Destroy;override;
        property Version: string read FVersion;
        function LoadWinsock(wsPath: string): Boolean;
        function InitializeWinsock: Boolean;
        procedure UnloadWinsock;
        procedure ShutdownWinsock;
        procedure CreateTCPSocket;
        procedure CreateICMPSocket;
        procedure LookupName(host: string);
        procedure FillName;
        procedure FillAddress(address: string);
        procedure FillPort(port: word);
        procedure Connect;
        procedure Disconnect;
        procedure Listen;
        procedure Accept(ListeningSocket: TStarSocket);
        function GetAddressString: string;
        function GetLocalHost: string;
        function GetLocalAddress : string;
        function GetLocalPort: u_short;
        function SendBuf(buf: PChar; cnt : integer) : integer;
        function SendBufOOB(buf: PChar; cnt : integer) : integer;
        function RecvBuf(buf: PChar; cnt : integer) : integer;
        procedure SetServer(s: string);
        procedure SetTimeout(seconds: LongInt);
        property WinsockLoaded: Boolean read FWinsockLoaded;
        property WinsockInitialized: Boolean read FWinsockInitialized;
        property Description: string read FDescription;
        property SystemStatus: string read FSystemStatus;
        property MaxSockets: integer read FMaxSockets;
        property Handle: HWND read FHandle;
        property CustomMessage: TSSWndMethod read FCustomMessage write FCustomMessage;
        property IsConnected: Boolean read FConnected;
        property Socket: TSock read FSocket;
        property OnLookupNameDone: TNotifyEvent read FLookupNameDone write FLookupNameDone;
        property OnConnected: TNotifyEvent read FOnConnected write FOnConnected;
        property OnDisconnected: TNotifyEvent read FOnDisconnected write FOnDisconnected;
        property OnReadReady: TNotifyEvent read FOnReadReady write FOnReadReady;
        property OnWriteReady: TNotifyEvent read FOnWriteReady write FOnWriteReady;
        property OnTimeOut: TNotifyEvent read FTimeOutEvt write FTimeOutEvt;
        property OnAccept: TNotifyEvent read FOnAccept write FOnAccept;
        property TimeOutConnect: LongInt read FConnTO write FConnTO;
        property TimeOutArp: LongInt read FArpTO write FArpTo;
        property TimeOutTransaction: LongInt read FTransTO write FTransTO;
end;

function WsErrorToStr(e : integer) : String;

implementation

uses Forms;

var
        accept:                 Taccept;
        bind:                   Tbind;
        closesocket:            Tclosesocket;
        connect:                TConnect;
        ioctlsocket:            Tioctlsocket;
        getpeername:            Tgetpeername;
        getsockname:            Tgetsockname;
        getsockopt:             Tgetsockopt;
        htonl:                  Thtonl;
        htons:                  Thtons;
        inet_addr:              Tinet_addr;
        inet_ntoa:              Tinet_ntoa;
        listen:                 TlistenProc;
        ntohl:                  Tntohl;
        ntohs:                  Tntohs;
        recv:                   Trecv;
        recvfrom:               Trecvfrom;
        select:                 Tselect;
        send:                   Tsend;
        sendto:                 Tsendto;
        setsockopt:             Tsetsockopt;
        shutdown:               Tshutdown;
        socket:                 Tsocket;
        gethostbyaddr:          Tgethostbyaddr;
        gethostbyname:          Tgethostbyname;
        gethostname:            Tgethostname;
        getservbyport:          Tgetservbyport;
        getservbyname:          Tgetservbyname;
        getprotobynumber:       Tgetprotobynumber;
        getprotobyname:         Tgetprotobyname;
        WSAStartup:             TWSAStartup;
        WSACleanup:             TWSACleanup;
        WSASetLastError:        TWSASetLastError;
        WSAGetLastError:        TWSAGetLastError;
        WSAIsBlocking:          TWSAIsBlocking;
        WSAUnhookBlockingHook:  TWSAUnhookBlockingHook;
        WSASetBlockingHook:     TWSASetBlockingHook;
        WSACancelBlockingCall:  TWSACancelBlockingCall;
        WSAAsyncGetServByName:  TWSAAsyncGetServByName;
        WSAAsyncGetServByPort:  TWSAAsyncGetServByPort;
        WSAAsyncGetProtoByName: TWSAAsyncGetProtoByName;
        WSAAsyncGetProtoByNumber:TWSAAsyncGetProtoByNumber;
        WSAAsyncGetHostByName:  TWSAAsyncGetHostByName;
        WSAAsyncGetHostByAddr:  TWSAAsyncGetHostByAddr;
        WSACancelAsyncRequest:  TWSACancelAsyncRequest;
        WSAAsyncSelect:         TWSAAsyncSelect;

constructor TStarSocket.Create(AOwner: TComponent);
begin
        inherited Create(AOwner);
        FAddr.sin_family := PF_INET;
	FAddr.sin_addr.s_addr := INADDR_ANY;
        FAddr.sin_port := 0;
        FHandle := AllocateHWND(SockWndProc);
        FSocket := INVALID_SOCKET;
	FConnected := false;
	FBytesSent := 0;
        FConnTO:=0;
        FArpTO:=0;
end;

destructor TStarSocket.Destroy;
begin
        DeallocateHwnd(FHandle);
        if WinsockInitialized then ShutdownWinsock;
        if WinsockLoaded then UnloadWinsock;
        inherited Destroy;
end;

procedure TStarSocket.SockWndProc(var Message: TMessage);
var
        phe: PHostEnt;
        evt: word;
begin
        if (Message.Msg>WM_STARSOCKLAST) and Assigned(FCustomMessage) then
        begin
                FCustomMessage(Message);
                Exit;
        end;
        case Message.Msg of
        {custom messages}
        WM_ARPDONE: {received after WsaAsyncGetHostByName}
                begin
                        if TimerID<>0 then
                        begin
                                KillTimer(FHandle,TimerID);
                                TimerID:=0;
                        end;
                        LastError:=WsaGetAsyncError(Message.lParam);
                        if LastError=0 then
                        begin
                                phe:=PHostEnt(@HostEntryBuf);
	                        phe^.h_addr := phe^.h_addr_list^;
                                sa.S_un_b.s_b1:=phe^.h_addr[0];
                                sa.S_un_b.s_b2:=phe^.h_addr[1];
	                        sa.S_un_b.s_b3:=phe^.h_addr[2];
                                sa.S_un_b.s_b4:=phe^.h_addr[3];
                        end;
                        ArpHandle:=0;
                        LookupNameDone;
                end;
        WM_SOCKMSG:  {received after connect,read,write,disconnect notification}
                begin
                        if TimerID<>0 then
                        begin
                                KillTimer(FHandle,TimerID);
                                TimerID:=0;
                        end;
                        evt := WSAGetSelectEvent(Message.lParam);
                        LastError:=WSAGetSelectError(Message.lParam);
                        case evt of
                        FD_CONNECT:
                                begin
                                        FConnected := true;
                                        Connected;
                                end;
                        FD_CLOSE:
                                begin
                                        Disconnected;
                                        if FConnected then closesocket(FSocket);
                                        FConnected := false;
                                        FSocket:=INVALID_SOCKET;
                                end;
                        FD_READ: ReadReady;
                        FD_WRITE: WriteReady;
                        FD_ACCEPT: AcceptReady;

                        end;
                end;
        {end custom messages}
        WM_TIMER:
                begin
                        Dec(Timer);
                        if Timer=0 then
                        begin
                                Disconnect;
                                if Assigned(FTimeoutEvt) then FTimeoutEvt(self);
                        end;
                end;
        WM_QUERYENDSESSION: Message.Result:=1; {end session bug}
	else DefWindowProc(FHandle, Message.Msg, Message.wParam, Message.lParam);
        end;
end;

procedure TStarSocket.SetTimeout(seconds: LongInt);
begin
        if TimerID<>0 then KillTimer(FHandle,TimerID);
        if seconds=0 then TimerId:=0
        else
        begin
                Timer:=seconds;
                TimerID:=SetTimer(FHandle,1,1000,nil);
        end;
end;

function TStarSocket.InitializeWinsock: Boolean;
begin
        if not FWinsockInitialized then
        begin
                FWinsockInitialized:=False;
                if not WinsockLoaded then LoadWinsock('');
                if FWinsockLoaded then
                begin
                	if WSAStartup($0101,@myWSAData)=0 then
                        begin
                                FWinsockInitialized:=True;
                                FDescription:=StrPas(myWsaData.szDescription);
                                FSystemStatus:=StrPas(myWsaData.szSystemStatus);
                                FMaxSockets:=myWsaData.iMaxSockets;
                        end;
                end;
        end;
        Result:=FWinsockInitialized;
end;

procedure TStarSocket.ShutdownWinsock;
begin
        if FWinsockInitialized then
        begin
                FWinsockInitialized:=False;
                WSACleanup;
        end;
end;

procedure TStarSocket.UnloadWinsock;
begin
        if FWinsockInitialized then ShutdownWinsock;
        if FWinsockLoaded then
        begin
                FreeLibrary(WinsockLib);
                FWinsockLoaded:=False;
        end;
end;

procedure TStarSocket.CreateTCPSocket;
begin
        If FSocket<>INVALID_SOCKET then Exit;
        FSocket:=starsock.socket(PF_INET, SOCK_STREAM, IPPROTO_IP);
        if FSocket = INVALID_SOCKET then LastError:=WsaGetLastError
        else LastError:=0;
end;

procedure TStarSocket.CreateICMPSocket;
begin
        If FSocket<>INVALID_SOCKET then Exit;
        FSocket:=starsock.socket(PF_INET, SOCK_RAW,IPPROTO_ICMP);
        if FSocket = INVALID_SOCKET then LastError:=WsaGetLastError
        else LastError:=0;
end;

function TStarSocket.GetAddressString: string;
begin
        Result := StrPas(inet_ntoa(FAddr.sin_addr));
end;

procedure TStarSocket.LookupName(host: string);
begin
        if ArpHandle<>0 then Exit;
        StrPCopy(@dnsbuf,host);
        ArpHandle:=WSAAsyncGetHostByName(FHandle,WM_ARPDONE,@dnsbuf,@HostEntryBuf,MAXGETHOSTSTRUCT);
        if ArpHandle=0 then LastError:=WsaGetLastError
        else LastError:=0;
        if LastError<>0 then Exit;
        SetTimeout(FArpTo);
end;

procedure TStarSocket.FillName;
begin
        FAddr.sin_addr:=sa;
end;

procedure TStarSocket.FillAddress(address: string);
var
	s	: array [1..32] of char;
begin
        StrPCopy(@s, address);
        FAddr.sin_addr.s_addr := inet_addr(@s);
end;

procedure TStarSocket.FillPort(port: word);
begin
        FAddr.sin_port := htons(port);
end;

procedure TStarSocket.LookupNameDone;
begin
        if Assigned(FLookupNameDone) then FLookupNameDone(self);
end;

procedure TStarSocket.Connected;
begin
        if Assigned(FOnConnected) then FOnConnected(self);
end;

procedure TStarSocket.Disconnected;
begin
        if Assigned(FOnDisconnected) then FOnDisconnected(self);
end;

procedure TStarSocket.ReadReady;
begin
        if Assigned(FOnReadReady) then FOnReadReady(self);
end;

procedure TStarSocket.WriteReady;
begin
        if Assigned(FOnWriteReady) then FOnWriteReady(self);
end;

procedure TStarSocket.AcceptReady;
begin
        if Assigned(FOnAccept) then FOnAccept(self);
end;

procedure TStarSocket.Connect;
begin
        WSAAsyncSelect(FSocket, FHandle, WM_SOCKMSG, FD_CONNECT or FD_CLOSE or FD_READ or FD_WRITE);
	if starsock.connect(FSocket, Psockaddr(@FAddr), SizeOf(FAddr)) <> 0 then
        begin
                LastError:=WSAGetLastError;
        	if LastError=WSAEWOULDBLOCK then LastError:=0;
        end;
        if LastError<>0 then Exit;
        SetTimeout(FConnTO);
end;

procedure TStarSocket.Listen;
begin
        if bind(FSocket, Psockaddr(@FAddr), SizeOf(FAddr)) <> 0 then
	begin
                LastError:=WSAGetLastError;
                Exit;
        end;
        WSAAsyncSelect(FSocket, FHandle, WM_SOCKMSG,FD_ACCEPT);
	if StarSock.listen(FSocket, 2) <> 0 then
	begin
	        LastError:=WSAGetLastError;
                Exit;
	end;
end;

procedure TStarSocket.Accept(ListeningSocket: TStarSocket);
var
        nl: integer;
begin
	nl := sizeof(sockaddr_in);
	FSocket :=starsock.accept(ListeningSocket.Socket,PSockaddr(@FAddr), @nl);
	if FSocket=INVALID_SOCKET then
        begin
                LastError:=WSAGetLastError;
                Exit;
        end
        else LastError:=0;
        FConnected:=True;
        WSAAsyncSelect(FSocket,FHandle,WM_SOCKMSG,FD_CLOSE or FD_READ or FD_WRITE);
end;

procedure TStarSocket.Disconnect;
begin
        if ArpHandle<>0 then WSACancelAsyncRequest(ArpHandle);
        if TimerID<>0 then
        begin
                KillTimer(FHandle,TimerID);
                TimerID:=0;
        end;
        if FSocket<>INVALID_SOCKET then
        begin
                closesocket(FSocket);
                LastError:=WsaGetLastError;
                FSocket:=INVALID_SOCKET;
                FConnected:=False;
        end;
end;

function TStarSocket.SendBuf(buf: PChar; cnt : integer) : integer;
var
	n : integer;
begin
	Result := 0;
	n := send(FSocket, buf, cnt, 0);
	if n > 0 then
        begin
                Result := n;
                LastError:=0;
        end
	else if (n = SOCKET_ERROR) then
        begin
                LastError:=WSAGetLastError;
                if LastError=WSAEWOULDBLOCK then LastError:=0;
        end;
end;

function TStarSocket.SendBufOOB(buf: PChar; cnt : integer) : integer;
var
	n : integer;
begin
	Result := 0;
	n := send(FSocket, buf, cnt, MSG_OOB);
	if n > 0 then
        begin
                Result := n;
                LastError:=0;
        end
	else if (n = SOCKET_ERROR) then
        begin
                LastError:=WSAGetLastError;
                if LastError=WSAEWOULDBLOCK then LastError:=0;
        end;
end;

function TStarSocket.RecvBuf(buf: PChar; cnt : integer) : integer;
var
	n : integer;
begin
	Result := 0;
        n := recv(FSocket, buf, cnt, 0);
	if n > 0 then
        begin
                Result := n;
                LastError:=0;
        end
        else if (n = SOCKET_ERROR) then
        begin
                LastError:=WSAGetLastError;
                if LastError=WSAEWOULDBLOCK then LastError:=0;
        end;
end;

function TStarSocket.GetLocalHost: string;
var
	sh : array [0..255] of char;
begin
	if gethostname(sh, 255)=0 then Result := StrPas(sh)
	else Result := '';
        LastError:=WsaGetLastError;
end;

function TStarSocket.GetLocalAddress : string;
var
	sa : sockaddr_in;
	nl : integer;
begin
	Result := '';
        nl:=SizeOf(sa);
	if FSocket = INVALID_SOCKET then exit;
	if getsockname(FSocket, PSockaddr(@sa), @nl)=0 then Result := StrPas(inet_ntoa(sa.sin_addr));
        LastError:=WsaGetLastError;
end;

function TStarSocket.GetLocalPort : u_short;
var
	sa : sockaddr_in;
	nl : integer;
begin
	Result := 0;
        nl:=Sizeof(sa);
	if FSocket = INVALID_SOCKET then exit;
	if getsockname(FSocket, PSockaddr(@sa), @nl) = 0 then Result := ntohs(sa.sin_port);
        LastError:=WsaGetLastError;
end;

function TStarSocket.LoadWinsock(wsPath: string): Boolean;
var
        oldMode: Word;
        buf: array[1..256] of char;
        P: Pointer;
begin
        FWinsockLoaded:=False;
        Result:=False;
        oldMode:=SetErrorMode(0);
        SetErrorMode(SEM_NOOPENFILEERRORBOX);
        if wsPath='' then
                {$IFDEF WIN32}
                 WinsockLib:=LoadLibrary('WSOCK32.DLL')
                {$ENDIF}
        else
        begin
                StrPCopy(@buf,Copy(wsPath,1,255));
                WinSockLib:=LoadLibrary(@buf);
        end;
        SetErrorMode(oldMode);
        if WinsockLib<HINSTANCE_ERROR then Exit;
        P:=GetProcAddress(WinsockLib,PChar(1));
        if P=nil then Exit;
        starsock.accept:=Taccept(P);
        P:=GetProcAddress(WinsockLib,PChar(2));
        if P=nil then Exit;
        bind:=Tbind(P);
        P:=GetProcAddress(WinsockLib,PChar(3));
        if P=nil then Exit;
        closesocket:=Tclosesocket(P);
        P:=GetProcAddress(WinsockLib,PChar(4));
        if P=nil then Exit;
        starsock.connect:=Tconnect(P);
        P:=GetProcAddress(WinsockLib,PChar(5));
        if P=nil then Exit;
        getpeername:=Tgetpeername(P);
        P:=GetProcAddress(WinsockLib,PChar(6));
        if P=nil then Exit;
        getsockname:=Tgetsockname(P);
        P:=GetProcAddress(WinsockLib,PChar(7));
        if P=nil then Exit;
        getsockopt:=Tgetsockopt(P);
        P:=GetProcAddress(WinsockLib,PChar(8));
        if P=nil then Exit;
        htonl:=Thtonl(P);
        P:=GetProcAddress(WinsockLib,PChar(9));
        if P=nil then Exit;
        htons:=Thtons(P);
        P:=GetProcAddress(WinsockLib,PChar(10));
        if P=nil then Exit;
        inet_addr:=Tinet_addr(P);
        P:=GetProcAddress(WinsockLib,PChar(11));
        if P=nil then Exit;
        inet_ntoa:=Tinet_ntoa(P);
        P:=GetProcAddress(WinsockLib,PChar(12));
        if P=nil then Exit;
        ioctlsocket:=Tioctlsocket(P);
        P:=GetProcAddress(WinsockLib,PChar(13));
        if P=nil then Exit;
        starsock.listen:=TlistenProc(P);
        P:=GetProcAddress(WinsockLib,PChar(14));
        if P=nil then Exit;
        ntohl:=Tntohl(P);
        P:=GetProcAddress(WinsockLib,PChar(15));
        if P=nil then Exit;
        ntohs:=Tntohs(P);
        P:=GetProcAddress(WinsockLib,PChar(16));
        if P=nil then Exit;
        recv:=TRecv(P);
        P:=GetProcAddress(WinsockLib,PChar(17));
        if P=nil then Exit;
        recvfrom:=Trecvfrom(P);
        P:=GetProcAddress(WinsockLib,PChar(18));
        if P=nil then Exit;
        select:=Tselect(P);
        P:=GetProcAddress(WinsockLib,PChar(19));
        if P=nil then Exit;
        send:=Tsend(P);
        P:=GetProcAddress(WinsockLib,PChar(20));
        if P=nil then Exit;
        sendto:=Tsendto(P);
        P:=GetProcAddress(WinsockLib,PChar(21));
        if P=nil then Exit;
        setsockopt:=Tsetsockopt(P);
        P:=GetProcAddress(WinsockLib,PChar(22));
        if P=nil then Exit;
        shutdown:=Tshutdown(P);
        P:=GetProcAddress(WinsockLib,PChar(23));
        if P=nil then Exit;
        starsock.socket:=Tsocket(P);
        P:=GetProcAddress(WinsockLib,PChar(51));
        if P=nil then Exit;
        gethostbyaddr:=Tgethostbyaddr(P);
        P:=GetProcAddress(WinsockLib,PChar(52));
        if P=nil then Exit;
        gethostbyname:=Tgethostbyname(P);
        P:=GetProcAddress(WinsockLib,PChar(53));
        if P=nil then Exit;
        getprotobyname:=Tgetprotobyname(P);
        P:=GetProcAddress(WinsockLib,PChar(54));
        if P=nil then Exit;
        getprotobynumber:=Tgetprotobynumber(P);
        P:=GetProcAddress(WinsockLib,PChar(55));
        if P=nil then Exit;
        getservbyname:=Tgetservbyname(P);
        P:=GetProcAddress(WinsockLib,PChar(56));
        if P=nil then Exit;
        getservbyport:=Tgetservbyport(P);
        P:=GetProcAddress(WinsockLib,PChar(57));
        if P=nil then Exit;
        gethostname:=Tgethostname(P);
        P:=GetProcAddress(WinsockLib,PChar(101));
        if P=nil then Exit;
        WSAAsyncSelect:=TWSAAsyncSelect(P);
        P:=GetProcAddress(WinsockLib,PChar(102));
        if P=nil then Exit;
        WSAAsyncGetHostByAddr:=TWSAAsyncGetHostByAddr(P);
        P:=GetProcAddress(WinsockLib,PChar(103));
        if P=nil then Exit;
        WSAAsyncGetHostByName:=TWSAAsyncGetHostByName(P);
        P:=GetProcAddress(WinsockLib,PChar(104));
        if P=nil then Exit;
        WSAAsyncGetProtoByNumber:=TWSAAsyncGetProtoByNumber(P);
        P:=GetProcAddress(WinsockLib,PChar(105));
        if P=nil then Exit;
        WSAAsyncGetprotoByName:=TWSAAsyncGetprotoByName(P);
        P:=GetProcAddress(WinsockLib,PChar(106));
        if P=nil then Exit;
        WSAAsyncGetServByPort:=TWSAAsyncGetServByPort(P);
        P:=GetProcAddress(WinsockLib,PChar(107));
        if P=nil then Exit;
        WSAAsyncGetServByName:=TWSAAsyncGetServByName(P);
        P:=GetProcAddress(WinsockLib,PChar(108));
        if P=nil then Exit;
        WSACancelAsyncRequest:=TWSACancelAsyncRequest(P);
        P:=GetProcAddress(WinsockLib,PChar(109));
        if P=nil then Exit;
        WSASetBlockingHook:=TWSASetBlockingHook(P);
        P:=GetProcAddress(WinsockLib,PChar(110));
        if P=nil then Exit;
        WSAUnhookBlockingHook:=TWSAUnhookBlockingHook(P);
        P:=GetProcAddress(WinsockLib,PChar(111));
        if P=nil then Exit;
        WSAGetLastError:=TWSAGetLastError(P);
        P:=GetProcAddress(WinsockLib,PChar(112));
        if P=nil then Exit;
        WSASetLastError:=TWSASetLastError(P);
        P:=GetProcAddress(WinsockLib,PChar(113));
        if P=nil then Exit;
        WSACancelBlockingCall:=TWSACancelBlockingCall(P);
        P:=GetProcAddress(WinsockLib,PChar(114));
        if P=nil then Exit;
        WSAIsBlocking:=TWSAIsBlocking(P);
        P:=GetProcAddress(WinsockLib,PChar(115));
        if P=nil then Exit;
        WSAStartup:=TWSAStartup(P);
        P:=GetProcAddress(WinsockLib,PChar(116));
        if P=nil then Exit;
        WSACleanup:=TWSACleanup(P);
        FWinsockLoaded:=True;
        Result:=True;
end;

procedure TStarSocket.SetServer(s: string);
begin
        Server:=s;
        if server<>'' then
        begin
                if (server[1]>='0') and (server[1]<='9') then
                begin
                        Address:=server;
                        Host:='';
                end
                else
                begin
                        Host:=server;
                        Address:='';
                end;
        end;
end;


{Miscellaneous Winsock functions}
function WSAMakeSyncReply (Buflen, Error : Word) : LongInt;
begin
        WSAMakeSyncReply := MakeLong (Buflen, Error);
end;

function WSAMakeSelectReply (Event, Error : Word) : LongInt;
begin
        WSAMakeSelectReply := MakeLong (Event, Error);
end;

function WSAGetAsyncBuflen (Param : LongInt) : Word;
begin
        WSAGetAsyncBuflen := LOWORD(Param);
end;

function WSAGetAsyncError (Param : LongInt) : Word;
begin
        WSAGetAsyncError := HIWORD(Param);
end;

function WSAGetSelectEvent (Param : LongInt) : Word;
begin
        WSAGetSelectEvent := LOWORD(Param);
end;

function WSAGetSelectError (Param : LongInt) : Word;
begin
        WSAGetSelectError := HIWORD(Param);
end;

function WsErrorToStr(e : integer) : String;
begin
     Case e of
     WSAEINTR           : Result := 'WSAEINTR';
     WSAEBADF           : Result := 'WSAEINTR';
     WSAEFAULT          : Result := 'WSAEFAULT';
     WSAEINVAL          : Result := 'WSAEINVAL';
     WSAEMFILE          : Result := 'WSAEMFILE';
     WSAEWOULDBLOCK     : Result := 'WSAEWOULDBLOCK';
     WSAEINPROGRESS     : Result := 'WSAEINPROGRESS';
     WSAEALREADY        : Result := 'WSAEALREADY';
     WSAENOTSOCK        : Result := 'WSAENOTSOCK';
     WSAEDESTADDRREQ    : Result := 'WSAEDESTADDRREQ';
     WSAEMSGSIZE        : Result := 'WSAEMSGSIZE';
     WSAEPROTOTYPE      : Result := 'WSAEPROTOTYPE';
     WSAENOPROTOOPT     : Result := 'WSAENOPROTOOPT';
     WSAEPROTONOSUPPORT : Result := 'WSAEPROTONOSUPPORT';
     WSAESOCKTNOSUPPORT : Result := 'WSAESOCKTNOSUPPORT';
     WSAEOPNOTSUPP      : Result := 'WSAEOPNOTSUPP';
     WSAEPFNOSUPPORT    : Result := 'WSAEPFNOSUPPORT';
     WSAEAFNOSUPPORT    : Result := 'WSAEAFNOSUPPORT';
     WSAEADDRINUSE      : Result := 'WSAEADDRINUSE';
     WSAEADDRNOTAVAIL   : Result := 'WSAEADDRNOTAVAIL';
     WSAENETDOWN        : Result := 'WSAENETDOWN';
     WSAENETUNREACH     : Result := 'WSAENETUNREACH';
     WSAENETRESET       : Result := 'WSAENETRESET';
     WSAECONNABORTED    : Result := 'WSAECONNABORTED';
     WSAECONNRESET      : Result := 'WSAECONNRESET';
     WSAENOBUFS         : Result := 'WSAENOBUFS';
     WSAEISCONN         : Result := 'WSAEISCONN';
     WSAENOTCONN        : Result := 'WSAENOTCONN';
     WSAESHUTDOWN       : Result := 'WSAESHUTDOWN';
     WSAETOOMANYREFS    : Result := 'WSAETOOMANYREFS';
     WSAETIMEDOUT       : Result := 'WSAETIMEDOUT';
     WSAECONNREFUSED    : Result := 'WSAECONNREFUSED';
     WSAELOOP           : Result := 'WSAELOOP';
     WSAENAMETOOLONG    : Result := 'WSAENAMETOOLONG';
     WSAEHOSTDOWN       : Result := 'WSAEHOSTDOWN';
     WSAEHOSTUNREACH    : Result := 'WSAEHOSTUNREACH';
     WSAENOTEMPTY       : Result := 'WSAENOTEMPTY';
     WSAEPROCLIM        : Result := 'WSAEPROCLIM';
     WSAEUSERS          : Result := 'WSAEUSERS';
     WSAEDQUOT          : Result := 'WSAEDQUOT';
     WSAESTALE          : Result := 'WSAESTALE';
     WSAEREMOTE         : Result := 'WSAEREMOTE';
     WSASYSNOTREADY     : Result := 'WSASYSNOTREADY';
     WSAVERNOTSUPPORTED : Result := 'WSAVERNOTSUPPORTED';
     WSANOTINITIALISED  : Result := 'WSANOTINITIALISED';
     WSAHOST_NOT_FOUND  : Result := 'WSAHOST_NOT_FOUND';
     WSATRY_AGAIN       : Result := 'WSATRY_AGAIN';
     WSANO_RECOVERY     : Result := 'WSANO_RECOVERY';
     WSANO_DATA         : Result := 'WSANO_DATA';
     end;
end;

end.
