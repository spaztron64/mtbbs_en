{$LONGSTRINGS ON}
unit Rascomp32;

{-------------------------------------------------
DELPHI 2.0 RAS COMPONENT
(C) 1996 Daniel Polistchuck
(C) 1997 rayesper (rewritten)
}

{
This is a Delphi 2.0 wrapper for the RAS & W95 Dial-Up Connection
client services. It was tested and re-tested. But, anyway, there is
always something that can be missing or wrong. Please, feel free to
contact me at

danpol@br.homeshopping.com.br

This component is a rewrite of the excelent Mike Armstrong's
(compuserve 72740,1145) TRAS component. Parts of it were
rewritten in order to conform to the 32 bits RAS Api, whose
prototypes are included in the RAS_API32 unit source code.

Daniel Polistchuck
with collaborations from Ronaldo Smith Jr.
}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, RAS_API32;


const
  MaxConnections = 4;

type
  TConnectionList = class(TList)
    function AddConnection(Connection: TRASConn): Word;
    function RASConn(Index: Integer): HRASConn;
    function EntryName(Index: Integer): String;
    procedure Delete(Index: Integer);
  end;

  TRasStateEvent = Procedure( Sender: TObject; Error: Longint; ErrorString: String) of Object;

  TRAS = class(TComponent)
  private
    { Private declarations }
    FEntryName,
    FPhoneNumber,
    FPhoneBookPath,
    FCallbackNumber,
    FUserName,
    FPassword,
    FDomain,
    FDeviceType,
    FDeviceName: String;
    FRedialAttempts: Integer;
    fOnCallback,
    fOnConnect,
    fAboutToOpenPort,
    fPortOpened,
    fAboutToConnDev,
    fDevConnected,
    fAllDevsConnected,
    fAuthenticate,
    fAuthNotify,
    fAuthRetry,
    fAuthCallBack,
    fAuthChangePassword,
    fAuthProject,
    fAuthLinkSpeed,
    fAuthAck,
    fReAuthenticate,
    fAuthenticated,
    fPrepareforCallback,
    fWaitForModemReset,
    fInteractiveStarted,
    fRetryAuth,
    fPasswordExpired : TNotifyEvent;
    fOnDisconnect : TRasStateEvent;
    fWindowHandle: HWND;
    RASEvent: Word;

    procedure SetPhoneBookPath(Value: String);
    procedure Connected;
    procedure DisConnected;
    procedure WaitingForCallBack;
    procedure AboutToOpenPort;
    procedure PortOpened;
    procedure AboutToConnDev;
    procedure DevConnected;
    procedure AllDevsConnected;
    procedure Authenticate;
    procedure AuthNotify;
    procedure AuthRetry;
    procedure AuthCallBack;
    procedure AuthChangePassword;
    procedure AuthProject;
    procedure AuthLinkSpeed;
    procedure AuthAck;
    procedure ReAuthenticate;
    procedure Authenticated;
    procedure PrepareforCallback;
    procedure WaitForModemReset;
    procedure InteractiveStarted;
    procedure RetryAuth;
    procedure PasswordExpired;
    Procedure SetRedialAttempts( Value: Integer );

    procedure WndProc(var Msg: TMessage);
    function IntDisConnect: LongInt; { Used internally to bypass fOnDisconnect }
  protected
    { Protected declarations }
  public
    { Public declarations }
    PhoneBookEntries: TStringList;
    Connections: TConnectionList;
    LastError: LongInt;
    RASConn: HRASConn;   { Connection handle}
    ConnectState: Word;
    fRASAPI : Word;            //Added 97.8.30 by rayesper 
    CONSTRUCTOR Create(AOwner: TComponent); OVERRIDE;
    DESTRUCTOR Destroy; override;
    FUNCTION GetConnectStatus: LongInt;
    FUNCTION DisConnect: LongInt;
    FUNCTION GetErrorString(ErrorCode: LongInt): String;
    FUNCTION Connect: LongInt;
    FUNCTION CurrentStatus: String;
    FUNCTION GetConnections: LongInt;
    FUNCTION GetPhoneBookEntries: LongInt;

  PUBLISHED
    { Published declarations }
    PROPERTY EntryName:   String          read fEntryName write fEntryName;
    PROPERTY PhoneNumber: String          read fPhoneNumber write fPhoneNumber;
    PROPERTY PhoneBookPath:  String       read fPhoneBookPath write SetPhoneBookPath;
    PROPERTY CallbackNumber: String       read fCallbackNumber write fCallbackNumber;
    PROPERTY UserName:    String          read fUserName write fUserName;
    PROPERTY Password:    String          read fPassword write fPassword;
    PROPERTY RedialAttempts: Integer      read FRedialAttempts write SetRedialAttempts default 1;
    PROPERTY Domain:      String          read fDomain write fDomain;
    PROPERTY DeviceType:  String          read fDeviceType write fDeviceType;
    PROPERTY DeviceName:  String          read fDeviceName write fDeviceName;
    PROPERTY OnConnect:    TNotifyEvent   read fOnconnect write fOnConnect;
    PROPERTY OnDisconnect: TRasStateEvent read fOnDisconnect write fOnDisconnect;
    PROPERTY OnCallBack:   TNotifyEvent   read fOnCallBack write fOnCallBack;
    PROPERTY OnAboutToOpenPort:TNotifyEvent read fAboutToOpenPort write fAboutToOpenPort;
    PROPERTY OnPortOpened:     TNotifyEvent read fPortOpened write fPortOpened;
    PROPERTY OnAboutToConnDev: TNotifyEvent read fAboutToConnDev write fAboutToConnDev;
    PROPERTY OnDevConnected:   TNotifyEvent read fAllDevsConnected write fAllDevsConnected;
    PROPERTY OnAllDevsConnected: TNotifyEvent read fAllDevsConnected write fAllDevsConnected;
    PROPERTY OnAuthenticate:   TNotifyEvent read fAuthenticate write fAuthenticate;
    PROPERTY OnAuthNotify:     TNotifyEvent read fAuthNotify write fAuthNotify;
    property OnAuthRetry:      TNotifyEvent read fAuthRetry write fAuthRetry;
    property OnAuthCallBack:   TNotifyEvent read fAuthCallBack write fAuthCallBack;
    property OnAuthChangePassword: TNotifyEvent read fAuthChangePassword write fAuthChangePassword;
    property OnAuthProject:    TNotifyEvent read fAuthProject write fAuthProject;
    property OnAuthLinkSpeed:  TNotifyEvent read fAuthLinkSpeed write fAuthLinkSpeed;
    property OnAuthAck:        TNotifyEvent read fAuthAck write fAuthAck;
    property OnReAuthenticate: TNotifyEvent read fReAuthenticate write fReAuthenticate;
    property OnAuthenticated:  TNotifyEvent read fAuthenticated write fAuthenticated;
    property OnPrepareforCallback: TNotifyEvent read fPrepareforCallback write fPrepareforCallback;
    property OnWaitForModemReset:  TNotifyEvent read fWaitForModemReset write fWaitForModemReset;
    property OnInteractiveStarted: TNotifyEvent read fInteractiveStarted write fInteractiveStarted;
    property OnRetryAuth:       TNotifyEvent read fRetryAuth write fRetryAuth;
    property OnPasswordExpired: TNotifyEvent read fPasswordExpired write fPasswordExpired;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RAS', [TRAS]);
end;

{ ********************************************************************* }
{                           TConnectionList                             }
{ ********************************************************************* }
function TConnectionList.AddConnection(Connection: TRASConn): Word;
var
  Conn: PRASConn;
begin
  Conn := New(PRASConn);
  Conn^ := Connection;
  Add(Conn);
end;

function TConnectionList.RASConn(Index: Integer): HRASConn;
begin
  Result := PRASConn(Items[Index])^.RASConn;
end;

function TConnectionList.EntryName(Index: Integer): String;
begin
  If PRASConn(Items[Index])^.szEntryName[0] <> #0 THEN
     Result := StrPas(PRASConn(Items[Index])^.szEntryName)
  ELSE
     Result := '';
end;

procedure TConnectionList.Delete(Index: Integer);
begin
  Dispose( PRASConn( Items[ Index ] ) );
  Items[ Index ] := Nil;

  Inherited Delete( Index );
end;

{ ********************************************************************* }
{                            TRASConnection                             }
{ ********************************************************************* }
CONSTRUCTOR TRAS.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RASEvent := RegisterWindowMessage(RASDialEvent);
  If RASEvent = 0 THEN
     RASEvent := WM_RASDialEvent;
  fRASAPI :=RASAPIFlag;                 // Added 97.8.30 by rayesper 
  RASConn := 0;
  ConnectState := 0;
  fWindowHandle := 0;

  FRedialAttempts := 1;

  PhoneBookEntries := TStringList.Create;
  Connections := TConnectionList.Create;
end;

destructor TRAS.Destroy;
begin
//  IntDisconnect;         //Not disconnect when destroy.  97.8.30 by rayesper 
  PhoneBookEntries.Free;
  Connections.Free;
  inherited Destroy;
end;

function TRAS.Connect: LongInt;
var
  RASDialParams: TRASDialParams;{ points to calling parameters }
  R: LongInt;
begin
  If RASConn <> 0 THEN { Allow only one connection }
     IntDisConnect;
  If fWindowHandle = 0 THEN
     fWindowHandle := AllocateHWnd(WndProc);
  FillChar(RASDialParams, SizeOf(RASDialParams), #0);
  RasConn := 0;
  With RASDialParams DO
  Begin
    dwSize := SizeOf(TRASDialParams);
    UniqueString(fEntryName);
    StrLCopy(szEntryName, PChar((fEntryName)), RAS_MaxEntryName);
    UniqueString(fPhoneNumber);
    StrLCopy(szPhoneNumber, PChar(fPhoneNumber), RAS_MaxPhoneNumber);
    UniqueString(fCallBackNumber);
    StrLCopy(szCallbackNumber, PChar((fCallBackNumber)), RAS_MaxCallbackNumber);
    UniqueString(fUserName);
    StrLCopy(szUserName,PChar((fUserName)) , UNLEN);
    UniqueString(fPassWord);
    StrLCopy(szPassword, PChar((fPassWord)), PWLEN);
    UniqueString(fDomain);
    StrLCopy(szDomain, Pchar(fDomain), DNLEN);
  End;
  If fPhoneBookPath <> '' THEN
  Begin
    LastError := RasDial(Nil, PChar(fPhoneBookPath), @RASDialParams, $FFFFFFFF, fWindowHandle, RASConn);
  End
  ELSE
    LastError := RasDial(Nil, Nil, @RASDialParams,$FFFFFFFF,  fWindowHandle, RASConn);
  Result := LastError;
end;

function TRAS.GetErrorString(ErrorCode: LongInt): String;
var
  szErrorString: Array[0..256] of Char;
begin
  Result := '';
  If (RASConn = 0) THEN
     Exit;
  FillChar(szErrorString, SizeOf(szErrorString), #0);
  RasGetErrorString(ErrorCode, szErrorString, 256);
  If szErrorString[0] <> #0 THEN
     Result := StrPas(szErrorString)
  Else
     Result := 'Status Unknown';
end;

function TRAS.Disconnect: LongInt;
begin
  Result := 0;
  If RASConn <> 0 THEN
     Result := RASHangUp(RASConn);
  RASConn := 0;
  If fWindowHandle <> 0 THEN { Stop message flow }
  Begin
    DeallocateHWnd(fWindowHandle);
    fWindowHandle := 0;
  End;
  LastError := Result;
  Disconnected;
end;

function TRAS.IntDisconnect: LongInt;
begin
  Result := 0;
  If RASConn <> 0 THEN
     Result := RASHangUp(RASConn);
  RASConn := 0;
  If fWindowHandle <> 0 THEN { Stop message flow }
  Begin
    DeallocateHWnd(fWindowHandle);
    fWindowHandle := 0;
  End;
  LastError := Result;
end;

function TRAS.GetConnectStatus: LongInt;
var
  RASConnStatus: TRASConnStatus;
begin
  If (RASConn = 0) THEN
     Exit;
  FillChar(RASConnStatus, SizeOf(RASConnStatus), #0);
  RASConnStatus.dwSize := SizeOf (RasConnStatus);
  LastError := RasGetConnectStatus(RASConn, @RASConnStatus);
  If LastError = 0 THEN
  begin
    fDeviceName := StrPas(RASConnStatus.szDeviceName);
    fDeviceType := StrPas(RASConnStatus.szDeviceType);
    ConnectState := RASConnStatus.rasconnstate;
  end;
  LastError := RASConnStatus.dwError;
  Result := LastError;
end;

function TRAS.GetConnections: LongInt;
var
  RASConnect: Array[1..MaxConnections] OF TRASConn;
  I,
  BufSize,
  NumConnections: DWord;
begin
  for i:=0 to Connections.Count - 1 do begin  //Added 97.8.30 by rayesper 
//    dispose(Connections[i]);                //Added 97.8.30 by rayesper
    Connections.delete(i);                    //Added 97.8.30 by rayesper
  end;
  Connections.Clear;
  RASConnect[1].dwSize := Sizeof (RASConnect[1]);
  BufSize := SizeOf(RASConnect);
  Result := RasEnumConnections(@RASConnect, BufSize, NumConnections);
  LastError := Result;
  If (Result = 0) OR (Result = ERROR_BUFFER_TOO_SMALL) THEN
     For I := 1 TO NumConnections DO
         If (I <= MaxConnections) THEN
            Connections.AddConnection(RASConnect[I]);
end;

function TRAS.GetPhoneBookEntries;
var
  RASEntryName: Array[1..20] Of TRASENTRYNAME;
  I,
  BufSize,
  Entries: DWord;
  szPhoneBookPath: PChar;
begin
  PhoneBookEntries.Clear;
  RASEntryName[1].dwSize := SizeOf(RASEntryName[1]);
  BufSize := SizeOf(RASEntryName);
  If fPhoneBookPath <> '' THEN
  Begin
    GetMem(szPhoneBookPath, Length(fPhoneBookPath) + 1);
    StrPCopy(szPhoneBookPath, fPhoneBookPath);
    Result := RasEnumEntries(Nil, szPhonebookPath, @RASEntryName,
                             BufSize, Entries);
    FreeMem(szPhoneBookPath, Length(fPhoneBookPath) + 1);
  End
  ELSE
    Result := RasEnumEntries(Nil, Nil, @RASEntryName, BufSize, Entries);
  LastError := Result;
  If (Result = 0) OR (Result = ERROR_BUFFER_TOO_SMALL) THEN
     For I := 1 TO Entries DO
         If ( I < 21) AND (RASEntryName[I].szEntryName[0] <> #0) THEN
            PhoneBookEntries.Add(StrPas(RASEntryName[I].szEntryName));
end;

procedure TRAS.WndProc(var Msg: TMessage);
begin
  If (Msg.Msg = RASEvent) AND (RASConn <> 0) THEN
  Begin
    If Msg.lParam <> 0 THEN
       LastError := Msg.lParam
    ELSE
    Begin
      ConnectState := Msg.wParam;
      Case ConnectState OF
{           RASCS_DeviceConnected: DeviceConnected;}
           {Daniel's Addition}
           RASCS_OpenPort : AboutToOpenPort;
           RASCS_PortOpened : PortOpened;
           RASCS_ConnectDevice : AboutToConnDev;
           RASCS_DeviceConnected : DevConnected;
           RASCS_AllDevicesConnected : AllDevsConnected;
           RASCS_Authenticate : Authenticate;
           RASCS_AuthNotify : AuthNotify;
           RASCS_AuthRetry : AuthRetry;
           RASCS_AuthCallback : AuthCallBack;
           RASCS_AuthChangePassword : AuthChangePassword;
           RASCS_AuthProject : AuthProject;
           RASCS_AuthLinkSpeed : AuthLinkSpeed;
           RASCS_AuthAck : AuthAck;
           RASCS_ReAuthenticate : ReAuthenticate;
           RASCS_Authenticated : Authenticated;
           RASCS_PrepareForCallback : PrepareforCallback;
           RASCS_WaitForModemReset : WaitForModemReset;
           RASCS_Interactive : InteractiveStarted;
           RASCS_RetryAuthentication : RetryAuth;
           RASCS_PasswordExpired : PasswordExpired;
           RASCS_Connected    : Connected;
           RASCS_DisConnected : Disconnected;
           RASCS_WaitForCallBack: WaitingForCallBack;
      End;
    End;
    CurrentStatus;
  End
  ELSE
     DefWindowProc(fWindowHandle, Msg.Msg, Msg.wParam, Msg.lParam);
end;

Procedure TRAS.SetRedialAttempts( Value: Integer );
Begin
  IF ( FRedialAttempts <> Value ) THEN
  BEGIN
    FRedialAttempts := Value;
  END;
End;

FUNCTION TRAS.CurrentStatus: String;
BEGIN
  Result := '';
  If (RASConn = 0) THEN
  Begin
    Result := 'Not Active';
    Exit;
  End;
  If RASConn <> 0 THEN
  Begin
    GetConnectStatus;
    If LastError <> 0 THEN
    Begin
      If LastError >= 600 THEN
         Result := GetErrorString(LastError)
      ELSE
      Case LastError OF
        6: Result := 'Invalid Handle';
        8: Result := 'Not enough memory';
      End;
    End
    ELSE
    Case ConnectState OF
     RASCS_OpenPort:
            Result := 'Opening Port';
     RASCS_PortOpened:
            Result := 'Port Opened';
     RASCS_ConnectDevice:
            Result := 'Using Device: ' + fDeviceName + ' - ' + fDeviceType;
     RASCS_DeviceConnected:
            Result := 'Device is connected';
     RASCS_AllDevicesConnected:
            Result := 'All Required Devices Connected';
     RASCS_Authenticate:
            Result := 'Validating User/Password/Domain';
     RASCS_AuthNotify:
            Result := 'Authentication Notification';
     RASCS_AuthCallBack:
            Result := 'Authentication Call Back';
     RASCS_AuthProject:
            Result := 'Project';
     RASCS_AuthLinkSpeed:
            Result := 'Calculating Link speed';
     RASCS_AuthAck:
            Result := 'Authentication acknowledged';
     RASCS_ReAuthenticate:
            Result := 'Reauthenticating';
     RASCS_Authenticated:
            Result := 'Login Authenticated';
     RASCS_PrepareforCallBack:
            Result := 'Preparing for Callback';
     RASCS_WaitForModemReset:
            Result := 'Waiting for Modem Reset';
     RASCS_WaitForCallBack:
            Result := 'Waiting for Callback';
    End; { Case }
  End
  ELSE
    Result := 'Not Connected';
end;

PROCEDURE TRAS.SetPhoneBookPath( Value: String );
BEGIN
  fPhoneBookPath := Value;
  GetPhoneBookEntries;
END;

PROCEDURE TRAS.Connected;
BEGIN
  If ( RASConn = 0 ) THEN
    Exit;
  If Assigned( fOnConnect ) THEN
    fOnConnect( Self );
END;

PROCEDURE TRAS.AboutToOpenPort;
BEGIN
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fAboutToOpenPort) THEN
     fAboutToOpenPort (Self);
end;

procedure TRAS.PortOpened;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fPortOpened) THEN
     fPortOpened(Self);
end;

procedure TRAS.AboutToConnDev;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fAboutToConnDev) THEN
     fAboutToConnDev (Self);
end;

procedure TRAS.DevConnected;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fDevConnected) THEN
     fDevConnected(Self);
end;

procedure TRAS.AllDevsConnected;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fAllDevsConnected) THEN
     fAllDevsConnected(Self);
end;

procedure TRAS.Authenticate;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fAuthenticate) THEN
     fAuthenticate(Self);
end;

procedure TRAS.AuthNotify;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fAuthNotify) THEN
     fAuthNotify(Self);
end;

procedure TRAS.AuthRetry;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fAuthRetry) THEN
     fAuthRetry(Self);
end;

procedure TRAS.AuthCallBack;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fAuthCallBack) THEN
     fAuthCallBack(Self);
end;

procedure TRAS.AuthChangePassword;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fAuthChangePassword) THEN
     fAuthChangePassword(Self);
end;

procedure TRAS.AuthProject;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fAuthProject) THEN
     fAuthProject(Self);
end;

procedure TRAS.AuthLinkSpeed;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fAuthLinkSpeed) THEN
     fAuthLinkSpeed(Self);
end;

procedure TRAS.AuthAck;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fAuthAck) THEN
     fAuthAck(Self);
end;

procedure TRAS.ReAuthenticate;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fReAuthenticate) THEN
     fReAuthenticate(Self);
end;

procedure TRas.Authenticated;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fAuthenticated) THEN
     fAuthenticated(Self);
end;

procedure TRAS.PrepareforCallback;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fPrepareforCallback) THEN
     fPrepareforCallback(Self);
end;

procedure TRAS.WaitForModemReset;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fWaitForModemReset) THEN
     fWaitForModemReset(Self);
end;

procedure TRAS.InteractiveStarted;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fInteractiveStarted) THEN
     fInteractiveStarted(Self);
end;

procedure TRAS.RetryAuth;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fRetryAuth) THEN
     fRetryAuth(Self);
end;

procedure TRAS.PasswordExpired;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fPasswordExpired) THEN
     fPasswordExpired(Self);
end;

procedure TRAS.DisConnected;
var
  RasConnStatus : TRasConnStatus;
  LastError : Longint;
  ErrorStr : String;
begin
  If Assigned(fOnDisConnect) THEN
  begin
    FillChar(RASConnStatus, SizeOf(RASConnStatus), #0);
    RASConnStatus.dwSize := Sizeof (RasConnStatus);
    LastError := RasGetConnectStatus(RASConn, @RASConnStatus);
    ErrorStr := GetErrorString (LastError);
    fOnDisConnect(Self,LastError,ErrorStr);
  end;
end;

procedure TRAS.WaitingForCallBack;
begin
  If (RASConn = 0) THEN
     Exit;
  If Assigned(fOnCallBack) THEN
     fOnCallBack(Self);
end;

end.
