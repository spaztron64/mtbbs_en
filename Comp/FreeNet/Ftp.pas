{
TStarFtp- Internet FTP Component for Delphi

Copyright (�) 1997  Tony BenBrahim
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
{
                1.3     first stable release of FTP
9/13/95         1.3.1   lets server disconnect on Access Denied
                        non fatal if SYST is not supported
2/13/96         1.3.2   removed extraneous ftpReady on Quit
                        fixed InitialDirectory
3/6/96          1.3.3   Delphi 2.0 version!
3/16/96         1.3.4   increased efficiency of data routines
                        eliminated race condition for small files and Ready by adding ReadySynch;
3/24/96         1.4.0   added FTPURLDialog in same file
4/14/96         1.4.1   made TransferTime property correct throughout transfer, not just at end.
5/11/96         1.4.2   added timeout properties to TFtp
                        error on RETR is no longer fatal (as per documentation)
                        fixed premature disconnect (again :-(
                        StopTransfer function now works.
                        Error handling reaaranged.
}

unit Ftp;

interface


uses StarSock,Classes,Forms,WinTypes,SysUtils,Controls,Messages,
        Graphics,Dsgnintf,StdCtrls,ExtCtrls,TabNotBk,Dialogs;

const
        FTP_AVAILABLE   =       WM_USER+2;
        FTP_ERROR       =       WM_USER+3;
        FTP_READY       =       WM_USER+4;

type TFtpURLAction=(fd_GetURL,fd_PutURL,fd_ListURL);

type TFTPServerType=(ftpstDefault,ftpstAutoDetect,ftpstUNIX,ftpstULTRIX,ftpstU5000,ftpstSINTFTPD,
                     ftpstVmsMultinet,ftpstVmsUcx,ftpstMVS,ftpstMacFtpd,ftpstClix,ftpstQVT,
                     ftpstNCSA,ftpstChameleon,ftpstVM,ftpstVMVPS);

type FtpInfo=  (ftpServerConnected,ftpServerDisconnected,ftpResolvingAddress,ftpAddressResolved,
                ftpTraceIn,ftpTraceOut,ftpAlreadyBusy,
                ftpDataTrace,ftpReady,ftpTransferDone,ftpDirectoryRefresh,
                ftpLoggedIn,ftpFileSize,ftpPermissionDenied,ftpListing,ftpStartListing,
                ftpStoringFile,ftpGettingFile,ftpDeleting);

type FtpError=(ftpNone,ftpWInsockNotInitialized,ftpNetworkDown,ftpInvalidAddress,ftpInternalError,
                    ftpGeneralWinsockError,ftpConnAborted,ftpConnReset,ftpConnectTimeOut,
                    ftpOutofSockets,ftpNetworkUnreachable,ftpAddressNotAvailable,
                    ftpConnectionRefused,ftpProtocolError,ftpCanceled,ftpUnknown,
                    ftpAddressResolutionError,ftpPrematureDisconnect,
                    ftpHostUnreachable,ftpNoServer,ftpBadURL,
                    ftpFileOpen,ftpFileWrite,ftpFileRead,ftpFileNotFound,
                    ftpTimeOut,ftpServerDown,ftpAccessDenied,ftpDataError);

type TFtpInfoNeeded=(niHost,niUser,niPassword,niAccount);
type TTransferType=(BinaryTransfer,AsciiTransfer);
type TFtpLastAction=(ftplaNONE,ftplaLOGIN,ftplaCWD,ftplaMKD,ftplaRMD,
                     ftplaRM,ftplaGET,ftplaPUT,ftplaLIST,ftplaREN,
                     ftplaGETS,ftplaPUTS,ftplaRMS);

TFtpInfoEvent = procedure (Sender : TObject; info: FtpInfo; addinfo: string) of object;
TFtpErrorEvent = procedure (Sender : TObject; error: FtpError; addinfo: string) of object;
TFtpInfoNeededEvent = procedure (Sender :TObject;need: TFtpInfoNeeded;var value: string) of object;
TURLProc=procedure of object;

TNewLineProc=procedure(line:string) of object;

type TStarFtp = class(TStarSocket)
        private
                FUSer,FPass,FAcct:      string;

                FList:                  TStrings;
                FFiles:                 TStrings;
                FDirectories:           TStrings;

                FFile:                  string;
                FURL,urlfile:           string;
                FSelection:             string;
                FDirectory:             string;
                FType:                  TFTPServerType;

                FMode:                  TTransferType;
                Bytes,TrTime,StartTime: Longint;

                FtpInfoEvt:             TFtpInfoEvent;
                FOnError:               TFtpErrorEvent;
                FOnReady:               TNotifyEvent;
                NeedInfo:               TFtpInfoNeededEvent;

                FtpProc:                TNewLineProc;
                Intermediate:           Boolean;
                Response:               string;

                datafile:               file;

                FDoingListing:          Boolean;
                fReady,Pending:         Boolean;
                FtpInfoEvent:           TFtpInfoEvent;
                LoggedIn:               Boolean;
                FSuccess,FDataSuccess:  Boolean;
                DataClient:             integer;
                ControlConnected:       Boolean;
                DataConnected:          Boolean;
                DataID:                 integer;
                FileOpened:             Boolean;
                rnto:                   string;
                URLMode,SaveList:       Boolean;
                URLProc:                TURLProc;
                OnHold,TransferAborted: Boolean;
                FVersion,DummyS:        string;

                FLoggedIn,FDirectoryChanged,FDirectoryCreated: TNotifyEvent;
                FDirectoryDeleted,FFileDeleted,FFileReceived: TNotifyEvent;
                FFileStored, FListingDone,FFileRenamed: TNotifyEvent;
                FFTPQuit: TNotifyEvent;

                FtpLastAction: TFtpLastAction;
                ReadyPort,ReadyMain: Boolean;

                buffer: array[0..2048] of Char;
                step: integer;
                Aborted: Boolean;
                PartialLine,DataPartialLine: string;
                ListeningSocket,DataSocket: TStarSocket;
                FError:  FtpError;
                procedure CloseProc;
                function RecvText : string;
                function CheckError: Boolean;
                procedure SetWinsockStarted(b: Boolean);
                function GetWinsockStarted: Boolean;
                procedure DataDoListing(sender: TObject);
                procedure DataListConnected(sender: TObject);
                procedure DataListDisconnected(sender: TObject);

                procedure DataRetrFile(sender: TObject);
                procedure DataFileDisconnected(sender: TObject);

                procedure DataStorConnected(sender: TObject);

                procedure Proceed(s: string;n: integer);
                procedure FtpLogin(line:string);

                procedure SetList(s: TStrings);
                procedure SetFiles(s: TStrings);
                procedure SetDirectories(s: TStrings);

                procedure UserMessageHandler(var Message: TMessage);

                procedure DoFtpInfo(info: FtpInfo; add: string);
                procedure DoFtpError(e: FtpError);
                procedure Ready;

                function SetupDataPort: string;

                function ExtractLast(line: string): string;
                procedure Write(line: string);
                procedure DidConnect(Sender: TObject);
                procedure DoDisconnect(Sender: TObject);
                procedure DoRead(Sender: TObject);

                procedure LoadURL;
                procedure StoreURL;
                procedure DirURL;
                procedure QuitURL;
                procedure QuitListURL;
                procedure TimedOut(Sender: TObject);
        protected
                constructor Create(AOwner: TComponent);override;
                destructor Destroy;override;
                procedure LookupNameDone;override;
        public
                Busy: Boolean;
                procedure FatalError(e: FtpError);
                procedure DeleteDirectory(dir: string);
                procedure CreateDirectory(dir: string);
                procedure RenameFile(oldname,newname: string);
                procedure DeleteFile(filename: string);
                procedure IssueCommand(command: string);
                procedure ChangeDirectory(name: string);
                procedure FTPRefresh;
                procedure Quit;

                procedure Login;
                procedure GetFile;
                procedure PutFile;
                procedure ListFile;

                procedure GetURL;
                procedure PutURL;
                procedure ListURL;
                procedure StopTransfer;

                property DoingListing: Boolean read FDoingListing;
                property Listing: TStrings read FList write SetList;
                property Files: TStrings read FFiles write SetFiles;
                property Directories: TStrings read FDirectories write SetDirectories;
                property BytesTransferred: LongInt read Bytes write Bytes;
                property TransferTime: LongInt read TrTime;
                property Connected: Boolean read ControlConnected;
                property Error: FtpError read FError;
        published
                property FtpServer: string read Server write SetServer;
                property FtpPort: u_short read Port write Port;
                property UserName: string read FUser write FUser;
                property UserPassword: string read FPass write FPass;
                property UserAccount: string read FAcct write FAcct;

                property LocalFile: string read FFile write FFile;
                property RemoteFile: string read FSelection write FSelection;
                property Ftp_URL: string read FURL write FURL;
                property TransferMode: TTransferType read FMode write FMode;

                property InitialDirectory: string read FDirectory write FDirectory;

                property OnFtpInfo: TFtpInfoEvent read FtpInfoEvt write FtpInfoEvt;
                property OnFtpNeedInfo: TFtpInfoNeededEvent read NeedInfo write NeedInfo;
                property OnFtpReady: TNotifyEvent read FOnReady write FOnReady;
                property OnFtpError: TFtpErrorEvent read FOnError write FOnError;

                property WinsockStarted: Boolean read GetWinsockStarted write SetWinsockStarted;
                property Version: string read FVersion write DummyS;
                property Success: Boolean read FSuccess;

                property OnLoggedIn: TNotifyEvent read FLoggedIn write FLoggedIn;
                property OnDirectoryChanged: TNotifyEvent read FDirectoryChanged write FDirectoryChanged;
                property OnDirectoryCreated: TNotifyEvent read FDirectoryCreated write FDirectoryCreated;
                property OnDirectoryDeleted: TNotifyEvent read FDirectoryDeleted write FDirectoryDeleted;
                property OnFileDeleted: TNotifyEvent read FFileDeleted write FFileDeleted;
                property OnFileReceived: TNotifyEvent read FFileReceived write FFileReceived;
                property OnFileStored: TNotifyEvent read FFileStored write FFileStored;
                property OnListingDone: TNotifyEvent read FListingDone write FListingDone;
                property OnFileRenamed: TNotifyEvent read FFileRenamed write FFIleRenamed;
                property OnFtpQuit: TNotifyEvent read FFTPQuit write FFTPQuit;
                property ServerType:TFTPServerType read FType write FType;

                property TimeOutConnect;
                property TimeOutArp;
end;

type FtpURLDialogObjects=(StatusText,StatusBar,ByteCounter,CancelButton);
TFtpURLDialogOptions=set of FtpURLDialogObjects;

type TFtpURLDialogPos=(ScreenCenter,Custom);

const
        WM_Proceed=WM_USER+1;

type
  TFtpudlg = class(TForm)
    Status: TLabel;
    Timer: TTimer;
    Ftp1: TStarFtp;
    PaintBox1: TPaintBox;
    counter: TLabel;
    cancel: TButton;
    procedure TimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Ftp1FtpInfo(Sender: TObject; info: FtpInfo; addinfo: String);
    procedure PaintBox1Paint(Sender: TObject);
    procedure Ftp1FtpError(Sender: TObject; error: FtpError; addinfo: String);
    procedure Ftp1FtpNeedInfo(Sender: TObject; need: TFtpInfoNeeded;
      var value: OpenString);
    procedure cancelClick(Sender: TObject);
  private
        todo,done: Longint;
        procedure PaintBox1Update;
        procedure FtpProceed(var Msg: TMsg); message WM_Proceed;
  public
        URLError:       FtpError;
        act:            TFtpURLAction;
        tconn1,tconn2,ttrans,tlogin: string;
        Fdemo:          Boolean;
        c1,c2:          TColor;
  end;

type FtpURLDialog = class(TComponent)
        private
                FCaption:                               string;
                FURL,FID,FPass,FAcct,FLocal:            string;
                FAct:                                   TFtpURLAction;
                d:                                      TFtpudlg;
                FTimeOut:                               word;
                FS:                                     FtpInfo;
                TT:                                     TTransferType;
                bs:                                     TFormBorderStyle;
                ftop,fleft:                             integer;
                FFont:                                  TFont;
                FStatusColor:                           TColor;
                FStatusBk:                              TColor;
                FColor:                                 TColor;
                FOptions:                               TFtpURLDialogOptions;
                FWidth,FHeight:                         integer;
                FInit:                                  Boolean;
                FPos:                                   TFtpUrlDialogPos;
                FLang:                                  TStrings;
                FVersion,DummyS:                               string;
                FDemo:                                  Boolean;
                procedure SetFFont(f: TFont);
                procedure SetFLang(s: TStrings);
                procedure MeasureText(s: string;var x: integer;var y: integer);
        protected
                property Initialized: Boolean read FInit write FInit;
        public
                function Execute: Boolean;
                procedure Demo;
                constructor Create(owner: TComponent);override;
                destructor Destroy;override;
                property Error: FtpInfo read FS write FS;
        published
                property Caption: string read FCaption write FCaption;
                property URL: string read FURL write FURL;
                property UserID: string read FID write FID;
                property UserPass: string read FPass write FPass;
                property LocalFile: string read FLocal write FLocal;
                property Action: TFtpURLAction read FAct write FAct;
                property Timeout: word read FTimeOut write FTimeOut;
                property TransferType: TTransferType read TT write TT;
                property Border: TFormBorderStyle read bs write bs;
                property WindowTop: integer read ftop write ftop;
                property WindowLeft: integer read fleft write fleft;
                property Color: TColor read FColor write FColor;
                property Font: TFont read FFont write SetFFont;
                property StatusBarColor: TColor read FStatusColor write FStatusColor;
                property StatusBarBackground: TColor read FStatusBk write FStatusBk;
                property Options: TFtpURLDialogOptions read FOptions write FOptions;
                property StatusBarHeight: integer read FHeight write FHeight;
                property StatusBarWidth: integer read FWidth write FWidth;
                property Position: TFtpUrlDialogPos read FPos write FPos;
                property LanguageStrings: TStrings read FLang write SetFLang;
                property Version: string read Fversion write DummyS;
end;

type FtpURLDialogEditor=class(TComponentEditor)
        public
                procedure Edit;override;
                function GetVerb(Index: integer): string; override;
                function GetVerbCount: integer; override;
                procedure ExecuteVerb(Index: integer);override;
end;

type
  TFtpURLDialogCE = class(TForm)
    TabbedNotebook1: TTabbedNotebook;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    poscenter: TRadioButton;
    poscustom: TRadioButton;
    Label3: TLabel;
    Label4: TLabel;
    etop: TEdit;
    eleft: TEdit;
    GroupBox3: TGroupBox;
    rbdialog: TRadioButton;
    rbsingle: TRadioButton;
    rbnone: TRadioButton;
    Color: TGroupBox;
    bkcol: TShape;
    txtcol: TShape;
    Label5: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    FontSample: TPaintBox;
    GroupBox4: TGroupBox;
    sttext: TCheckBox;
    stcounter: TCheckBox;
    stcancel: TCheckBox;
    stbar: TCheckBox;
    GroupBox5: TGroupBox;
    eheight: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    ewidth: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Button7: TButton;
    Button8: TButton;
    stcol: TShape;
    stbk: TShape;
    Label8: TLabel;
    Label9: TLabel;
    tconnecting: TEdit;
    tconnected: TEdit;
    Label10: TLabel;
    tloggedin: TEdit;
    Label11: TLabel;
    ttransferring: TEdit;
    Label12: TLabel;
    tcancel: TEdit;
    Label13: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    procedure Button6Click(Sender: TObject);
    procedure FontSamplePaint(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure stbarClick(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  public
        FDemo: Boolean;
  end;


function ParseListingLine(ServerType: TFTPServerType;line: string;var name,size,date: string; var IsDir: Boolean): Boolean;
function FTPExtractLast(line: string): string;


implementation


{$R FTPURLFM.DFM}
{$R URLDGEDT.DFM}

constructor TStarFtp.Create(AOwner: TComponent);
begin
        inherited Create(AOwner);
        FList:=TStringList.Create;
        FFiles:=TStringList.Create;
        FDirectories:=TStringList.Create;
        FVersion:='TFtp 1.4.2';
        Busy:=False;
        Port:=21;
        FError:=ftpNone;
        CustomMessage:=UserMessageHandler;
        ListeningSocket:=TStarSocket.Create(self);
        ListeningSocket.InitializeWinsock;
        DataSocket:=TStarSocket.Create(self);
        DataSocket.InitializeWinsock;
end;

destructor TStarFtp.Destroy;
begin
        DataSocket.Destroy;
        ListeningSocket.Destroy;
        Disconnect;
        FList.Free;
        FFiles.Free;
        FDirectories.Free;
        inherited Destroy;
end;

procedure TStarFtp.UserMessageHandler(var Message: TMessage);
begin
        case Message.Msg of
        FTP_AVAILABLE:
                begin
                        Busy:=False;
                        if Assigned(FFtpQuit) then FFtpQuit(self);
                end;
        FTP_ERROR: if Assigned(FOnError) then FOnError(self,FtpError(Message.WParam),'Error');
        FTP_READY:
                begin
                        Busy:=False;
                        if URLMode then URLProc
                        else if Assigned(FOnReady) then FOnReady(self);
                        if TransferAborted then
                        begin
                                DataSocket.Disconnect;
                                ListeningSocket.Disconnect;
                                TransferAborted:=False;
                        end;
                        case FtpLastAction of
                        ftplaLOGIN:
                                begin
                                        FtpLastAction:=ftplaNONE;
                                        if Assigned(FLoggedIn) then FloggedIn(self);
                                end;
                        ftplaCWD:
                                begin
                                        FtpLastAction:=ftplaNONE;
                                        if Assigned(FDirectoryChanged) then FDirectoryChanged(self);
                                end;
                        ftplaMKD:
                                begin
                                        FtpLastAction:=ftplaNONE;
                                        if Assigned(FDirectoryCreated) then FDirectoryCreated(self);
                                end;
                        ftplaRMD:
                                begin
                                        FtpLastAction:=ftplaNONE;
                                        if Assigned(FDirectoryDeleted) then FDirectoryDeleted(self);
                                end;
                        ftplaRM:
                                begin
                                        FtpLastAction:=ftplaNONE;
                                        if Assigned(FFileDeleted) then FFileDeleted(self);
                                end;
                        ftplaGET:
                                begin
                                        FtpLastAction:=ftplaNONE;
                                        if Assigned(FFileReceived) then FFileReceived(self);
                                end;
                        ftplaPUT:
                                begin
                                        FtpLastAction:=ftplaNONE;
                                        if Assigned(FFileStored) then FFileStored(self);
                                end;
                        ftplaLIST:
                                begin
                                        FtpLastAction:=ftplaNONE;
                                        if Assigned(FListingDone) then FListingDone(self);
                                end;
                        ftplaREN:
                                begin
                                        FtpLastAction:=ftplaNONE;
                                        if Assigned(FFileRenamed) then FFileRenamed(self);
                                end;
                        end;
                end;
        end;
end;

procedure TStarFtp.DoFtpInfo(info: FtpInfo; add: string);
begin
        if Assigned(FtpInfoEvt) then FtpInfoEvt(self,info,add);
end;

procedure TStarFtp.DoFtpError(e: FtpError);
begin
        if URLMode then
        begin
                URLMode:=False;
                FatalError(e);
                Exit;
        end;
        FSuccess:=False;
        FError:=e;
        {PostMessage(Handle,FTP_ERROR,Ord(e),0);}
        if Assigned(FOnError) then FOnError(self,e,'Error');
end;

procedure TStarFtp.Ready;
begin
        PostMessage(Handle,FTP_READY,0,0);
end;

procedure TStarFtp.Login;
var
        s: string;
begin
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        OnTimeOut:=TimedOut;
        FError:=FtpNone;
        FSuccess:=True;
        URLMode:=False;
        InitializeWinsock;
        if not WinsockInitialized then
        begin
                DoFtpError(ftpWinsockNotInitialized);
                Exit;
        end;
        if FtpServer='' then
        begin
                if Assigned(NeedInfo) then NeedInfo(self,niHost,s);
                if s='' then
                begin
                        DoFtpError(ftpNoServer);
                        Exit;
                end;
                SetServer(s);
        end;
        if Port=0 then Port:=21;
        FtpProc:=FtpLogin;
        Intermediate:=False;
        Response:='';
        step:=0;
        OnConnected:=DidConnect;
        OnReadReady:=DoRead;
        OnDisconnected:=DoDisconnect;
        CreateTCPSocket;
        if CheckError then Exit;
        if Address<>'' then FillAddress(Address)
        else
        begin
                DoFtpInfo(ftpResolvingAddress,Host);
                LookupName(Host);
                CheckError;
                Exit;
        end;
        FillPort(Port);
        Connect;
        if CheckError then Exit;
end;

procedure TStarFtp.LookupNameDone;
begin
        if CheckError then Exit;
        FillName;
        FillPort(Port);
        Address:=GetAddressString;
        DoFtpInfo(ftpAddressResolved,Address);
        Connect;
        if CheckError then Exit;
end;

procedure TStarFtp.TimedOut(Sender: TObject);
begin
        FatalError(ftpConnectTimeOut);
end;

procedure TStarFtp.GetURL;
var
        i,j,k: integer;
        f: string;
begin
        FError:=FtpNone;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        WinsockStarted:=True;
        if not WinsockStarted then
        begin
                DoFtpError(ftpWinsockNotInitialized);
                Exit;
        end;
        f:=FURL;
        if Pos('ftp://',f)=0 then
        begin
                DoFtpError(ftpBadURL);
                Exit;
        end;
        f:=Copy(f,7,Length(f)-6);
        i:=Pos('/',f);
        if i=0 then
        begin
                DoFtpError(ftpBadURL);
                Exit;
        end;
        SetServer(Copy(f,1,i-1));
        RemoteFile:=Copy(f,i,Length(f));
        URLMode:=True;
        URLProc:=LoadURL;
        if Port=0 then Port:=21;
        FtpProc:=FtpLogin;
        Intermediate:=False;
        Response:='';
        step:=0;
        OnConnected:=DidConnect;
        OnReadReady:=DoRead;
        OnDisconnected:=DoDisconnect;
        CreateTCPSocket;
        if CheckError then Exit;
        if Address<>'' then FillAddress(Address)
        else
        begin
                DoFtpInfo(ftpResolvingAddress,Host);
                LookupName(Host);
                CheckError;
                Exit;
        end;
        FillPort(Port);
        Connect;
        if CheckError then Exit;
end;

procedure TStarFtp.ListURL;
var
        i,j,k: integer;
        f: string;
begin
        FError:=FtpNone;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        WinsockStarted:=True;
        if not WinsockStarted then
        begin
                DoFtpError(ftpWinsockNotInitialized);
                Exit;
        end;
        f:=FURL;
        if Pos('ftp://',f)=0 then
        begin
                DoFtpError(ftpBadURL);
                Exit;
        end;
        f:=Copy(f,7,Length(f)-6);
        i:=Pos('/',f);
        if i=0 then
        begin
                DoFtpError(ftpBadURL);
                Exit;
        end;
        SetServer(Copy(f,1,i-1));
        RemoteFile:=Copy(f,i,Length(f));
        URLMode:=True;
        URLProc:=DirURL;
        if Port=0 then Port:=21;
        FtpProc:=FtpLogin;
        Intermediate:=False;
        Response:='';
        step:=0;
        OnConnected:=DidConnect;
        OnReadReady:=DoRead;
        OnDisconnected:=DoDisconnect;
        CreateTCPSocket;
        if CheckError then Exit;
        if Address<>'' then FillAddress(Address)
        else
        begin
                DoFtpInfo(ftpResolvingAddress,Host);
                LookupName(Host);
                CheckError;
                Exit;
        end;
        FillPort(Port);
        Connect;
        if CheckError then Exit;
end;


procedure TStarFtp.PutURL;
var
        i,j,k: integer;
        f: string;
begin
        FError:=FtpNone;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        WinsockStarted:=True;
        if not WinsockStarted then
        begin
                DoFtpError(ftpWinsockNotInitialized);
                Exit;
        end;
        f:=FURL;
        if Pos('ftp://',f)=0 then
        begin
                DoFtpError(ftpBadURL);
                Exit;
        end;
        f:=Copy(f,7,Length(f)-6);
        i:=Pos('/',f);
        if i=0 then
        begin
                DoFtpError(ftpBadURL);
                Exit;
        end;
        SetServer(Copy(f,1,i-1));
        RemoteFile:=Copy(f,i,Length(f));
        URLMode:=True;
        URLProc:=StoreURL;
        if Port=0 then Port:=21;
        FtpProc:=FtpLogin;
        Intermediate:=False;
        Response:='';
        step:=0;
        OnConnected:=DidConnect;
        OnReadReady:=DoRead;
        OnDisconnected:=DoDisconnect;
        CreateTCPSocket;
        if CheckError then Exit;
        if Address<>'' then FillAddress(Address)
        else
        begin
                DoFtpInfo(ftpResolvingAddress,Host);
                LookupName(Host);
                CheckError;
                Exit;
        end;
        FillPort(Port);
        Connect;
        if CheckError then Exit;
end;

procedure TStarFtp.LoadURL;
begin
        URLProc:=QuitURL;
        GetFile;
end;

procedure TStarFtp.StoreURL;
begin
        URLProc:=QuitURL;
        PutFile;
end;

procedure TStarFtp.DirURL;
begin
        URLProc:=QuitListURL;
        ListFile;
end;

procedure TStarFtp.QuitURL;
begin
        URLMode:=False;
        Quit;
end;

procedure TStarFtp.QuitListURL;
begin
        URLMode:=False;
        Quit;
end;

procedure TStarFtp.GetFile;
begin
        FSuccess:=True;
        if not ControlConnected then
        begin
                DoFtpInfo(ftpServerDisconnected,'');
                Exit;
        end;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        FTPLastAction:=ftplaGET;
        FError:=FtpNone;
        Busy:=True;
        if FSelection='' then
        begin
                DoFtpError(ftpFileNotFound);
                Exit;
        end;
        if FFile<>'' then
        begin
                try
                        AssignFile(datafile,FFile);
                        Rewrite(datafile,1);
                        FileOpened:=True;
                except
                        DoFtpError(ftpFileOpen);
                        Ready;
                        Exit;
                end;
        end
        else
        begin
                DoFtpError(ftpFileOpen);
                Ready;
                Exit;
        end;
        ReadyPort:=False;
        ReadyMain:=False;
        if FMode=BinaryTransfer then Proceed('TYPE I',20)
        else Proceed('TYPE A',20);
end;

procedure TStarFtp.PutFile;
begin
        FSuccess:=True;
        FTPLastAction:=ftplaPUT;
        FError:=FtpNone;
        if not ControlConnected then
        begin
                DoFtpInfo(ftpServerDisconnected,'');
                Ready;
                Exit;
        end;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        Busy:=True;
        if FSelection='' then
        begin
                DoFtpError(ftpFileNotFound);
                Ready;
                Exit;
        end;
        if FFile<>'' then
        begin
                try
                        AssignFile(datafile,FFile);
                        Reset(datafile,1);
                        FileOpened:=True;
                except
                        DoFtpError(ftpFileOpen);
                        Ready;
                        Exit;
                end;
        end
        else
        begin
                DoFtpError(ftpFileOpen);
                Ready;
                Exit;
        end;
        if FMode=BinaryTransfer then Proceed('TYPE I',30)
        else Proceed('TYPE A',30);
end;

procedure TStarFtp.ListFile;
begin
        FSuccess:=True;
        FError:=FtpNone;
        if not ControlConnected then
        begin
                DoFtpInfo(ftpServerDisconnected,'');
                Exit;
        end;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        Busy:=True;
        if FSelection='' then
        begin
                DoFtpError(ftpFileNotFound);
                Exit;
        end;
        if FFile<>'' then
        begin
                try
                        AssignFile(datafile,FFile);
                        Rewrite(datafile,1);
                        CloseFile(datafile);
                except
                        DoFtpError(ftpFileOpen);
                        Exit;
                end;
        end
        else
        begin
                DoFtpError(ftpFileOpen);
                Exit;
        end;
        Proceed('TYPE A',70);
end;

procedure TStarFtp.RenameFile(oldname,newname: string);
begin
        FSuccess:=True;
        if not ControlConnected then
        begin
                DoFtpInfo(ftpServerDisconnected,'');
                Exit;
        end;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        Busy:=True;
        FError:=ftpNone;
        FTPLastAction:=ftplaREN;
        rnto:=newname;
        Proceed('RNFR '+oldname,40);
end;

procedure TStarFtp.DeleteDirectory(dir: string);
begin
        FSuccess:=True;
        FTPLastAction:=ftplaRMD;
        if not ControlConnected then
        begin
                DoFtpInfo(ftpServerDisconnected,'');
                Exit;
        end;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        FError:=FtpNone;
        Busy:=True;
        Proceed('RMD '+dir,50);
end;

procedure TStarFtp.CreateDirectory(dir: string);
begin
        FSuccess:=True;
        FTPLastAction:=ftplaMKD;
        if not ControlConnected then
        begin
                DoFtpInfo(ftpServerDisconnected,'');
                Exit;
        end;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        FError:=FtpNone;
        Busy:=True;
        Proceed('MKD '+dir,50);
end;


procedure TStarFtp.DeleteFile(filename: string);
begin
        FSuccess:=True;
        FTPLastAction:=ftplaRM;
        if not ControlConnected then
        begin
                DoFtpInfo(ftpServerDisconnected,'');
                Exit;
        end;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        FError:=FtpNone;
        Busy:=True;
        Proceed('DELE '+filename,50);
end;

procedure TStarFtp.ChangeDirectory(name: string);
begin
        FSuccess:=True;
        FtpLastAction:=ftplaCWD;
        if not ControlConnected then
        begin
                DoFtpInfo(ftpServerDisconnected,'');
                Exit;
        end;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        FError:=FtpNone;
        Busy:=True;
        FDirectory:=name;
        Proceed('CWD '+name,50);
end;

procedure TStarFtp.IssueCommand(command: string);
begin
        if not ControlConnected then
        begin
                DoFtpInfo(ftpServerDisconnected,'');
                Exit;
        end;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        FError:=FtpNone;
        Busy:=True;
        Proceed(command,50);
end;

procedure TStarFtp.FTPRefresh;
begin
        FTPLastAction:=ftplaLIST;
        if not ControlConnected then
        begin
                DoFtpInfo(ftpServerDisconnected,'');
                Exit;
        end;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        FError:=FtpNone;
        Busy:=True;
        Proceed('PWD',7);
end;

procedure TStarFtp.Quit;
begin
        if not ControlConnected then
        begin
                DoFtpInfo(ftpServerDisconnected,'');
                Exit;
        end;
        if Busy then
        begin
                DoFtpInfo(ftpAlreadyBusy,'');
                Exit;
        end;
        FError:=FtpNone;
        Busy:=True;
        Proceed('QUIT',60);
end;

procedure TStarFtp.SetList(s: TStrings);
begin
        FList.Assign(s);
end;

procedure TStarFtp.SetFiles(s: TStrings);
begin
        FFiles.Assign(s);
end;

procedure TStarFtp.SetDirectories(s: TStrings);
begin
        FDirectories.Assign(s);
end;

procedure TStarFtp.Write(line: string);
var
        data:              string;
begin
        data:=line+chr(13)+chr(10);
        if Aborted then Exit;
        DoFtpInfo(ftpTraceOut,data);
        while data<>'' do
        begin
                Application.ProcessMessages;
                if Aborted then Exit;
                Delete(data,1,SendBuf(PChar(@data[1]), Length(data)));
                if CheckError then Exit;
        end;
end;

procedure TStarFtp.DidConnect(Sender: TObject);
begin
        step:=0;
        DoFtpInfo(ftpServerConnected,Address);
        ControlConnected:=True;
        PartialLine:='';
        OnHold:=False;
end;

procedure TStarFtp.DoDisconnect(Sender:TObject);
begin
{        if Assigned(FOnRead) then FOnRead(Sender);}
        DoFTPInfo(ftpServerDisconnected,'Disconnected');
        Ready;
        URLMode:=False;
        PostMessage(Handle,FTP_AVAILABLE,0,0);
        ControlConnected:=False;
end;

procedure TStarFtp.DoRead(Sender: TObject);
var
        linein,newline:         string;
        {$IFDEF WIN32}
        el:                     integer;
        {$ENDIF}
begin
        if OnHold then Exit;
        if Aborted then Exit;
        while True do
        begin
                if Aborted then Exit;
                linein:=RecvText;
                if CheckError then Exit;
                DoFtpInfo(ftpTraceIn,linein);
                {$IFDEF WIN32}
                if Length(linein)=0 then Exit;
                linein:=PartialLine+linein;
                repeat
                        el:=Pos(#13+#10,linein);
                        if el<>0 then
                        begin
                                newline:=Copy(linein,1,el-1);
                                Delete(linein,1,el+1);
                                OnHold:=True;
                                FtpProc(newline);
                                OnHold:=False;
                                if Aborted then Exit;
                        end;
                until el=0;
                PartialLine:=linein;
                {$ENDIF}
        end;
end;

procedure TStarFtp.FatalError(e: FtpError);
begin
        if Aborted then Exit;
        URLMode:=False;
        DataSocket.Disconnect;
        ListeningSocket.Disconnect;
        Disconnect;
        ControlConnected:=False;
        FSuccess:=False;
        FError:=e;
        if Assigned(FOnError) then FOnError(self,e,'Error');
        PostMessage(Handle,FTP_AVAILABLE,0,0);
end;

procedure TStarFtp.Proceed(s: string;n: integer);
begin
        Write(s);
        step:=n;
end;

function TStarFtp.ExtractLast(line: string): string;
var
        i: integer;
begin
        i:=Pos('->',line);
        if i<>0 then Delete(line,i-1,999);
        i:=Length(line);
        while line[i]=' ' do Dec(i);
        Delete(line,i,999);
        while Pos(' ',line)=0 do Dec(i);
        Result:=Copy(line,i+1,999);
end;

procedure TStarFtp.FtpLogin(line: string);
var
        i,j: integer;
        fsyst: string;
begin
        if line='' then Exit;
        if Intermediate and (Copy(line,1,4)<>Response+' ') then Exit;
        if Line[4]='-' then
        begin
                Intermediate:=True;
                Response:=Copy(line,1,3);
                Exit;
        end;
        Intermediate:=False;
        case step of
        0: {banner}
                begin
                        if line[1]<>'2' then FatalError(ftpServerDown)
                        else
                        begin
                                if (FUser='') and Assigned(NeedInfo) then NeedInfo(self,niUser,FUser);
                                Proceed('USER '+FUser,1);
                        end;
                end;
        1: {USER}
                begin
                        if line[1]='2' then Proceed('SYST',5)
                        else
                        if line[1]<>'3' then
                        begin
                                DoFtpError(ftpAccessDenied);
                                Write('QUIT');
                                step:=60;
                        end
                        else
                        begin
                                if (FPass='') and Assigned(NeedInfo) then NeedInfo(self,niPassword,FPass);
                                Proceed('PASS '+FPass,2);
                        end;
                end;
        2: {PASS}
                begin
                        if line[1]='2' then Proceed('SYST',5)
                        else
                        if line[1]<>'3' then
                        begin
                                DoFtpError(ftpAccessDenied);
                                Write('QUIT');
                                step:=60;
                        end
                        else
                        begin
                                if (FAcct='') and Assigned(NeedInfo) then NeedInfo(self,niAccount,FAcct);
                                Proceed('ACCT '+FAcct,3);
                        end;
                end;
        3: {ACCT}
                begin
                        if line[1]='2' then Proceed('SYST',5)
                        else
                        begin
                                DoFtpError(ftpAccessDenied);
                                Write('QUIT');
                                step:=60;
                        end
                end;
        5: {following a SYST}
                begin
                        FtpLastAction:=ftplaLOGIN;
                        if line[1]<>'5' then
                        begin
                                FSyst:=Uppercase(Copy(line,5,99));
                                FType:=ftpstDefault;
                                if Pos('UNIX',FSyst)<>0 then FType:=ftpstUnix;
                                if Pos('CLIX',FSyst)<>0 then FType:=ftpstClix;
                                if Pos('ULTRIX',FSyst)<>0 then FType:=ftpstUltrix;
                                if Pos('MVS',FSyst)<>0 then FType:=ftpstMVS;
                                if Pos('QVT',FSyst)<>0 then FType:=ftpstQVT;
                                if Pos('NCSA',FSyst)<>0 then FType:=ftpstNCSA;
                                if Pos('CHAMELEON',FSyst)<>0 then FType:=ftpstChameleon;
                                if Pos('VMS',FSyst)<>0 then
                                begin
                                        if Pos('MULTINET',FSyst)<>0 then FType:=ftpstVmsMultinet
                                        else FType:=ftpstVmsUcx;
                                end
                                else
                                begin
                                        if Pos('VM',Fsyst)<>0 then
                                        begin
                                                if Pos('VPS',FSyst)=0 then FType:=ftpstVM
                                                else FType:=ftpstVMVPS;
                                        end;
                                end;
                        end
                        else FType:=ftpstDefault;
                        if FDirectory='' then
                        begin
                                DoFtpInfo(ftpLoggedIn,'Logged in');
                                step:=100;
                                Ready;
                        end
                        else Proceed('CWD '+FDirectory,6);
                end;
        6: {following a CWD to InitialDirectory}
                begin
                        if line[1]<>'2' then DoFTPInfo(ftpPermissionDenied,'');
                        DoFtpInfo(ftpLoggedIn,'Logged in');
                        step:=100;
                        Ready;
                end;
        7: {following a PWD start of Resfresh}
                begin
                        if line[1]='2' then
                        begin
                                FDirectory:=Copy(line,Pos('"',line)+1,999);
                                FDirectory:=Copy(FDirectory,1,Pos('"',FDirectory)-1);
                                Proceed('TYPE A',8);
                        end
                        else FatalError(ftpProtocolError);
                end;
        8: {TYPE A, in preparation for listing}
               begin
                        ReadyMain:=False;
                        ReadyPort:=False;
                        if line[1]='2' then Proceed('PORT '+SetupDataPort,10)
                        else FatalError(ftpProtocolError);
                end;
        10: {following a PORT}
                begin
                        if line[1]<>'2' then FatalError(ftpProtocolError)
                        else
                        begin
                                DataSocket.OnReadReady:=DataDoListing;
                                DataSocket.OnDisconnected:=DataListDisconnected;
                                DataSocket.onWriteReady:=nil;
                                ListeningSocket.OnAccept:=DataListConnected;
                                FList.Clear;
                                FFiles.Clear;
                                FDirectories.Clear;
                                Proceed('LIST',12);
                        end;
                end;
        12: {following a LIST}
               begin
                        if line[1]='1' then Exit;
                        if line[1]='2' then
                        begin
                                ReadyMain:=True;
                                if ReadyPort then Ready;
                        end
                        else
                        begin
                                DataSocket.Disconnect; {close data connection}
                                ListeningSocket.Disconnect;
                                FatalError(ftpProtocolError);
                                FSuccess:=false;
                        end;
                end;
       20: {Start of RETR filename, following TYPE}
                begin
                        if line[1]='2' then Proceed('PORT '+SetupDataPort,21)
                        else FatalError(ftpProtocolError);
                end;
        21: {following a PORT}
                begin
                        if line[1]<>'2' then FatalError(ftpProtocolError)
                        else
                        begin
                                DataSocket.OnReadReady:=DataRetrFile;
                                DataSocket.OnDisconnected:=DataFileDisconnected;
                                DataSocket.OnWriteReady:=nil;
                                ListeningSocket.OnAccept:=DataListConnected;
                                Proceed('RETR '+FSelection,22);
                        end;
                end;
        22: {following a RETR}
                begin
                        if line[1]='1' then
                        begin
                                i:=Pos('(',line);
                                for j:=i to Length(line) do
                                begin
                                        if line[j]=' ' then
                                        begin
                                                DoFtpInfo(ftpFileSize,Copy(line,i+1,j-i-1));
                                                Exit;
                                        end;
                                end;
                                Exit;
                        end;
                        if line[1]='2' then
                        begin
                                ReadyMain:=True;
                                if ReadyPort then Ready;
                                step:=100;
                        end
                        else
                        begin
                                if Copy(Line,1,3)='426' then Exit;{ABOR command sometimes 1st response}
                                DataSocket.Disconnect; {close data connection}
                                ListeningSocket.Disconnect;
                                DoFtpInfo(ftpPermissionDenied,'');
                                FSuccess:=False;
                                Ready;
                        end;
                end;
        30: {start of STOR filename, after TYPE}
                begin
                        ReadyPort:=False;
                        ReadyMain:=False;
                        if line[1]='2' then Proceed('PORT '+SetupDataPort,31)
                        else FatalError(ftpProtocolError);
                end;
        31: {following a PORT}
                begin
                        if line[1]<>'2' then
                        begin
                                FatalError(ftpProtocolError);
                                FSuccess:=False;
                        end
                        else
                        begin
                                DataSocket.OnReadReady:=nil;
                                DataSocket.OnDisconnected:=DataFileDisconnected;
                                DataSocket.onWriteReady:=nil;
                                ListeningSocket.OnAccept:=DataStorConnected;
                                Proceed('STOR '+FSelection,32);
                        end;
                end;
        32: {following a STOR}
                begin
                        if line[1]='1' then Exit;
                        if line[1]='2' then
                        begin
                                ReadyMain:=True;
                                if ReadyPort then Ready;
                        end
                        else
                        begin
                                if Copy(Line,1,3)='426' then Exit;{ABOR command sometimes 1st response}
                                DataSocket.Disconnect; {close data connection}
                                ListeningSocket.Disconnect;
                                DoFtpInfo(ftpPermissionDenied,'');
                                FSuccess:=False;
                                Ready;
                        end;
                end;
        40: {following a RNFR}
                begin
                        if line[1]='3' then Proceed('RNTO '+rnto,41)
                        else
                        begin
                                DoFtpInfo(ftpPermissionDenied,'');
                                FSuccess:=False;
                                step:=100;
                                Ready;
                        end;
                end;
        41: {following a RNTO}
                begin
                        if line[1]<>'2' then
                        begin
                                DoFtpInfo(ftpPermissionDenied,'');
                                FSuccess:=False;
                        end;
                        step:=100;
                        Ready;
                end;
        50: {following a MKD,RMD,CWD,DELE,CWD and login}
                begin
                        if line[1]<>'2' then
                        begin
                                DoFtpInfo(ftpPermissionDenied,'');
                                FSuccess:=False;
                        end;
                        step:=100;
                        Ready;
                end;
        60: {following a QUIT}
                begin
                        if line[1]<>'2' then FatalError(ftpNone);
                        step:=100;
                end;
        70: {TYPE A, in preparation for listing of URL}
               begin
                        if line[1]='2' then Proceed('PORT '+SetupDataPort,71)
                        else
                        begin
                                FatalError(ftpProtocolError);
                                FSuccess:=False;
                        end;
                end;
        71: {following a PORT}
                begin
                        if line[1]<>'2' then
                        begin
                                FatalError(ftpProtocolError);
                                FSuccess:=False;
                        end
                        else
                        begin
                                DataSocket.OnReadReady:=DataDoListing;
                                DataSocket.OnDisconnected:=DataListDisconnected;
                                DataSocket.OnWriteReady:=nil;
                                ListeningSocket.OnAccept:=DataListConnected;
                                FList.Clear;
                                FFiles.Clear;
                                FDirectories.Clear;
                                Proceed('LIST '+FSelection,72);
                        end;
                end;
        72: {following a LIST}
               begin
                        if line[1]='1' then Exit;
                        if line[1]='2' then step:=100
                        else
                        begin
                                DataSocket.Disconnect; {close data connection}
                                ListeningSocket.Disconnect;
                                FSuccess:=False;
                                FatalError(ftpProtocolError);
                        end;
                end;
        end;
end;

{============================== data connection routines=================}
procedure TStarFtp.DataListConnected(sender :TObject);
begin
        DataSocket.Accept(ListeningSocket);
        if DataSocket.LastError<>0 then
        begin
                if not TransferAborted then FatalError(ftpDataError);
                Exit;
        end;
        Bytes:=0;
        FSuccess:=True;
        StartTime:=GetTickCount;
        TrTime:=0;
        DataPartialLine:='';
        SaveList:=URLMode;
        DataConnected:=True;
        TransferAborted:=False;
end;

procedure TStarFtp.DataListDisconnected(Sender:TObject);
var
        e: TNotifyEvent;
begin
        e:=DataSocket.OnReadReady;
        if Assigned(e) then DataSocket.OnReadReady(Sender);
        TrTime:=GetTickCount-StartTime;
        DataSocket.Disconnect;
        ListeningSocket.Disconnect;
        DoFtpInfo(ftpDirectoryRefresh,'Listing ready');
        if SaveList then FList.SaveToFile(FFile);
        DoFtpInfo(ftpTransferDone,'Transfer done');
        DataConnected:=False;
        FDoingListing:=False;
        ReadyPort:=True;
        if ReadyMain then Ready;
end;

procedure TStarFtp.DataFileDisconnected(Sender:TObject);
var
        e: TNotifyEvent;
begin
        e:=DataSocket.OnReadReady;
        if Assigned(e) then DataSocket.OnReadReady(Sender);
        TrTime:=GetTickCount-StartTime;
        DataSocket.Disconnect;
        ListeningSocket.Disconnect;
        if FileOpened then CloseFile(datafile);
        DoFtpInfo(ftpTransferDone,'Transfer done');
        DataConnected:=False;
        FDoingListing:=False;
        ReadyPort:=True;
        if ReadyMain then Ready
end;

procedure TStarFtp.DataRetrFile(Sender:TObject);
var
        n,Transferred:          integer;
begin
        FDoingListing:=False;
        n:=DataSocket.RecvBuf(@buffer,2048);
        if DataSocket.LastError<>0 then
        begin
                if not TransferAborted then FatalError(ftpDataError);
                Exit;
        end;
        if n=0 then Exit;
        Inc(Bytes,n);
        TrTime:=GetTickCount-StartTime;
        DoFtpInfo(ftpDataTrace,'');
        if FileOpened then
        begin
                BlockWrite(datafile,buffer,n,Transferred);
                if n<>Transferred then
                begin
                        DoFtpError(ftpFileWrite);
                        CloseFile(datafile);
                        FileOpened:=False;
                end;
        end;
end;

procedure TStarFtp.DataDoListing(Sender:TObject);
var
        i:                      integer;
        c:                      char;
        linein,newline:         string;
        fname,j1,j2:            string;
        d:                      Boolean;
        {$IFDEF WIN32}
        el:                     integer;
        {$ENDIF}
begin
        FDoingListing:=True;
        {$IFDEF WIN32}
        i:=DataSocket.RecvBuf(@buffer,2048);
        if DataSocket.LastError<>0 then
        begin
                if not TransferAborted then FatalError(ftpDataError);
                Exit;
        end;
        buffer[i]:=#0;
        linein:=StrPas(@buffer);
        {$ENDIF}
        if linein='' then Exit;
        Inc(Bytes,Length(linein));
        {$IFDEF WIN32}
        linein:=DataPartialLine+linein;
        repeat
                el:=Pos(#13+#10,linein);
                if el<>0 then
                begin
                        newline:=Copy(linein,1,el-1);
                        Delete(linein,1,el+1);
                        TrTime:=GetTickCount-StartTime;
                        DoFtpInfo(ftpDataTrace,newline);
                        try
                                FList.Add(newline);
                                DoFtpInfo(ftpListing,newline);
                                if ParseListingLine(Ftype,newline,fname,j1,j2,d) then
                                begin
                                        if d then FDirectories.Add(fname)
                                        else FFiles.Add(fname);
                                end;
                        except
                                ;
                        end;
                end;
        until el=0;
        DataPartialLine:=linein;
        {$ENDIF}
end;

procedure TStarFtp.DataStorConnected(sender :TObject);
var
        i,j:                    LongInt;
        k:                      integer;
        totsent,nb:             LongInt;
begin
        TransferAborted:=False;
        DataSocket.Accept(ListeningSocket);
        FDoingListing:=False;
        Bytes:=0;
        StartTime:=GetTickCount;
        TrTime:=0;
        DoFtpInfo(ftpFileSize,IntToStr(FileSize(datafile)));
        j:=FileSize(datafile) div 2048;
        k:=FileSize(datafile) mod 2048;
        if k<>0 then Inc(j);
        nb:=2048;
        for i:=1 to j do
        begin
                if TransferAborted then
                begin
                        FSuccess:=False;
                        Break;
                end;
                try
                        if (i=j) and (k<>0) then
                        begin
                                BlockRead(datafile,buffer,k);
                                Inc(Bytes,k);
                                nb:=k;
                        end
                        else
                        begin
                                BlockRead(datafile,buffer,2048);
                                Inc(Bytes,2048);
                        end;
                except
                        DoFtpError(ftpFileRead);
                        if FileOpened then CloseFile(datafile);
                        FileOpened:=False;
                        DataSocket.Disconnect;
                        ListeningSocket.Disconnect;
                        FSuccess:=False;
                        Exit;
                end;
                totsent:=0;
                while totsent<nb do
                begin
                        Application.ProcessMessages;
                        if Aborted then Exit;
                        Inc(totsent,DataSocket.SendBuf(@Buffer[totsent],nb-totsent));
                        if DataSocket.LastError<>0 then
                        begin
                                if not TransferAborted then FatalError(ftpDataError);
                                Exit;
                        end;
                end;
                DoFtpInfo(ftpDataTrace,'');
                TrTime:=GetTickCount-StartTime;
        end;
        DataSocket.Disconnect;
        ListeningSocket.Disconnect;
        if FileOpened then CloseFile(datafile);
        FileOpened:=False;
        TrTime:=GetTickCount-TrTime;
        DoFtpInfo(ftpTransferDone,'Transfer done');
        ReadyPort:=True;
        if ReadyMain then Ready;
end;

procedure TStarFtp.StopTransfer;
var
        data: string;
        n: integer;
begin
        if TransferAborted then Exit;
        TransferAborted:=True;
        data:=#255+#244;
        while data<>'' do
        begin
                if Aborted then Exit;
                Delete(data,1,SendBuf(PChar(@data[1]), Length(data)));
                if CheckError then Exit;
        end;
        data:=#255+#242;
        while data<>'' do
        begin
                if Aborted then Exit;
                Delete(data,1,SendBufOOB(PChar(@data[1]), Length(data)));
                if CheckError then Exit;
        end;
        Write('ABOR');
        data:=#255+#242;
        while data<>'' do
        begin
                if Aborted then Exit;
                Delete(data,1,SendBuf(PChar(@data[1]), Length(data)));
                if CheckError then Exit;
        end;
end;


function TStarFtp.SetupDataPort: string;
var
        line:                   string;
        dataaddr:               string;
        dataport,p1,p2:         word;
        i:                      word;
begin
        ListeningSocket.Address:=GetLocalAddress;
        ListeningSocket.Port:=0;
        DataPartialLine:='';
        ListeningSocket.FillAddress(ListeningSocket.Address);
        ListeningSocket.FillPort(ListeningSocket.Port);
        ListeningSocket.CreateTCPSocket;
        ListeningSocket.Listen;
        dataaddr:=ListeningSocket.GetLocalAddress;
        dataport:=ListeningSocket.GetLocalPort;
        i:=1;
        while i<>0 do
        begin
                i:=Pos('.',dataaddr);
                if i<>0 then dataaddr[i]:=',';
        end;
        line:=dataaddr+','+IntToStr(dataport div 256)+','+IntToStr(dataport mod 256);
        Result:=line;
end;

function TStarFtp.GetWinsockStarted: Boolean;
begin
        Result:=WinsockInitialized;
end;

procedure TStarFtp.SetWinsockStarted(b: Boolean);
begin
        if b then InitializeWinsock
        else UnloadWinsock;
end;

function TStarFtp.CheckError: Boolean;
var
        errs: string;
begin
        if Aborted then Exit;
        if LastError=0 then
        begin
                FError:=ftpNone;
                Result:=False;
        end
        else
        begin
                case LastError of
                WSANOTINITIALISED:
                        begin
                                FError:=ftpWinsockNotInitialized;
                                errs:='Winsock not initialized';
                        end;
                WSAENETDOWN:
                        begin
                                FError:=ftpNetworkDown;
                                errs:='Network down';
                        end;
                WSAEACCES:
                        begin
                                FError:=ftpInvalidAddress;
                                errs:='Invalid address specified';
                        end;
                WSAEFAULT,WSAENOTSOCK,WSAEOPNOTSUPP,WSAESHUTDOWN,WSAEMSGSIZE,WSAENOTCONN,
                WSAEADDRINUSE,WSAEINPROGRESS,WSAEINTR,WSAEAFNOSUPPORT,WSAEINVAL,WSAEISCONN:
                        begin
                                FError:=ftpInternalError;
                                errs:='Unexpected internal error in component';
                        end;
                WSAETIMEDOUT:
                        begin
                                FError:=ftpConnectTimeout;
                                errs:='timeout';
                        end;
                WSAEMFILE:
                        begin
                                FError:=ftpOutofSockets;
                                errs:='Out of sockets';
                        end;
                WSAENETUNREACH:
                        begin
                                FError:=ftpNetworkUnreachable;
                                errs:='Network unreachable';
                        end;
                WSAEADDRNOTAVAIL:
                        begin
                                FError:=ftpAddressNotAvailable;
                                errs:='Address not available';
                        end;
                WSAECONNREFUSED:
                        begin
                                FError:=ftpConnectionRefused;
                                errs:='Connection Refused';
                        end;
                WSAENETRESET,WSAENOBUFS:
                        begin
                                FError:=ftpGeneralWinsockError;
                                errs:='General Winsock Error';
                        end;
                WSAECONNABORTED:
                        begin
                                Ferror:=ftpConnAborted;
                                errs:='Connection aborted due to timeout or other failure';
                        end;
                WSAECONNRESET:
                        begin
                                Ferror:=ftpConnReset;
                                errs:='Connection reset by remote side';
                        end;
                WSAHOST_NOT_FOUND,WSATRY_AGAIN,WSANO_RECOVERY,WSANO_DATA:
                        begin
                                FError:=ftpAddressResolutionError;
                                errs:='Address resolution error';
                        end;
                WSAEHOSTUNREACH:
                        begin
                                FError:=ftpHostUnreachable;
                                errs:='Host Unreachable';
                        end;
                else
                        begin
                                FError:=ftpUnknown;
                                errs:='Unknown Error';
                        end;
                end;
                FatalError(FError);
                Result:=True;
                CloseProc;
        end;
end;

function TStarFtp.RecvText : string;
var
        n		: integer;
        {$IFDEF WIN32}
        buf:            array[0..2048] of char;
        {$ENDIF}
begin
        {$IFDEF WIN32}
        n:=RecvBuf(buf,2048);
        buf[n]:=#0;
        Result:=buf;
        {$ENDIF}
end;

procedure TStarFtp.CloseProc;
begin
        if Aborted then Exit;
        Aborted:=True;
        DataSocket.Disconnect;
        ListeningSocket.Disconnect;
        Disconnect;
        PostMessage(Handle,FTP_AVAILABLE,0,0);
end;

{========================== Editor Code =============================}

function FtpURLDialogEditor.GetVerb(Index: integer): string;
begin
        case Index of
        0: Result:='Edit Component';
        1: Result:='View Dialog Box';
        2: Result:='-';
        end;
end;

function FtpURLDialogEditor.GetVerbCount: integer;
begin
        Result:=3;
end;

procedure FtpURLDialogEditor.ExecuteVerb(Index: integer);
begin
        case Index of
        0: Edit;
        1: (Component as FtpUrlDialog).Demo;
        end;
end;

procedure FtpURLDialogEditor.Edit;
var
       d:       TFtpURLDialogCE;
       c:       FtpURLDialog;
begin
        try
                d:=TFtpURLDialogCE.Create(Application.MainForm);
                c:=Component as FtpURLDialog;
                case c.Border of
                bsDialog: d.rbdialog.Checked:=True;
                bsNone: d.rbnone.Checked:=True;
                bsSingle: d.rbsingle.Checked:=True;
                end;
                d.eheight.Text:=IntToStr(c.StatusBarHeight);
                d.ewidth.Text:=IntToStr(c.StatusBarWidth);
                d.sttext.Checked:=StatusText in c.Options;
                d.stbar.Checked:=StatusBar in c.Options;
                d.stcancel.Checked:=CancelButton in c.Options;
                d.stcounter.Checked:=ByteCounter in c.Options;
                d.GroupBox5.Visible:=StatusBar in c.Options;
                d.etop.Text:=IntToStr(c.WindowTop);
                d.eleft.Text:=IntToStr(c.WindowLeft);
                d.bkcol.Brush.Color:=c.Color;
                d.txtcol.Brush.Color:=c.Font.Color;
                d.FontSample.Font.Assign(c.Font);
                d.stcol.Brush.Color:=c.StatusBarColor;
                d.stbk.Brush.Color:=c.StatusBarBackground;
                d.tconnecting.Text:=c.LanguageStrings[0];
                d.tconnected.Text:=c.LanguageStrings[1];
                d.tLoggedin.Text:=c.LanguageStrings[2];
                d.ttransferring.Text:=c.LanguageStrings[3];
                d.tcancel.Text:=c.LanguageStrings[4];
                case c.Position of
                ScreenCenter: d.poscenter.Checked:=True;
                Custom: d.poscustom.Checked:=True;
                end;
                if d.ShowModal=mrOk then
                begin
                        c.LanguageStrings.Clear;
                        c.LanguageStrings.Add(d.tconnecting.Text);
                        c.LanguageStrings.Add(d.tconnected.Text);
                        c.LanguageStrings.Add(d.tloggedin.Text);
                        c.LanguageStrings.Add(d.ttransferring.Text);
                        c.LanguageStrings.Add(d.tcancel.Text);
                        c.Options:=[];
                        if d.sttext.Checked then c.options:=c.options+[StatusText];
                        if d.stbar.Checked then c.options:=c.options+[StatusBar];
                        if d.stcounter.Checked then c.options:=c.options+[ByteCounter];
                        if d.stcancel.Checked then c.options:=c.options+[CancelButton];
                        if d.poscenter.Checked then c.Position:=screencenter;
                        if d.poscustom.Checked then c.Position:=custom;
                        c.Color:=d.bkcol.Brush.Color;
                        c.StatusBarColor:=d.stcol.Brush.Color;
                        c.StatusBarBackground:=d.stbk.Brush.Color;
                        c.Font.Assign(d.FontSample.Font);
                        if d.rbdialog.Checked then c.Border:=bsDialog;
                        if d.rbnone.Checked then c.Border:=bsNone;
                        if d.rbsingle.Checked then c.Border:=bsSingle;
                        try
                                c.WindowTop:=StrToInt(d.etop.Text);
                        except
                                ShowMessage('Invalid property value for Top');
                        end;
                        try
                                c.WindowLeft:=StrToInt(d.eleft.Text);
                        except
                                ShowMessage('Invalid property value for Left');
                        end;
                        try
                                c.StatusBarHeight:=StrToInt(d.eheight.Text);
                        except
                                ShowMessage('Invalid property value for StatusBarHeight');
                        end;
                        try
                                c.StatusBarWidth:=StrToInt(d.ewidth.Text);
                        except
                                ShowMessage('Invalid property value for StatusBarWidth');
                        end;
                        Designer.Modified;
                        if d.FDemo then
                        begin
                                d.Fdemo:=False;
                                c.Demo;
                        end;
                end;
        finally
                d.Destroy;
        end;
end;

{=========================== Component Code =========================}

constructor FtpURLDialog.Create(owner: TComponent);
begin
        inherited Create(owner);
        FFont:=TFont.Create;
        FLang:=TStringList.Create;
        FVersion:='FtpUrlDialog version 1.4';
        if not Initialized then
        begin
                Color:=clSilver;
                StatusBarColor:=clBlue;
                StatusBarBackground:=clWhite;
                StatusBarHeight:=18;
                StatusBarWidth:=200;
                Font.Color:=clBlack;
                Options:=[StatusText,StatusBar,ByteCounter,CancelButton];
                Border:=bsDialog;
                FInit:=True;
                Position:=ScreenCenter;
                FLang.Clear;
        end;
        if FLang.Count=0 then FLang.Add('Connecting...');
        if FLang.Count=1 then FLang.Add('Connected to');
        if FLang.Count=2 then FLang.Add('Logged in to server');
        if FLang.Count=3 then FLang.Add('Transferring file');
        if FLang.Count=4 then FLang.Add('Cancel');
end;

destructor FtpURLDialog.Destroy;
begin
        FFont.Free;
        FLang.Free;
        inherited Destroy;
end;

procedure FtpURLDialog.SetFFont(f: TFont);
begin
        FFont.Assign(f);
end;

procedure FtpURLDialog.SetFLang(s: TStrings);
begin
        FLang.Assign(s);
end;

procedure FtpURLDialog.Demo;
begin
        FDemo:=True;
        Execute;
        FDemo:=False;
end;

procedure FtpURLDialog.MeasureText(s: string;var x: integer;var y: integer);
begin
        with d.Canvas do
        begin
                x:=TextWidth(s);
                y:=TextHeight(s);
        end;
end;

function FtpURLDialog.Execute: Boolean;
var
        i,x,y,maxx: integer;
begin
        try
                d:=Tftpudlg.Create(Application);
                d.FDemo:=FDemo;
                d.caption:=FCaption;
                if Position=ScreenCenter then d.Position:=poScreenCenter
                else
                begin
                        d.Position:=poDesigned;
                        d.Left:=WindowLeft;
                        d.Top:=WindowTop;
                end;
                d.BorderStyle:=Border;
                d.Color:=Color;
                d.Font.Assign(Font);
                d.PaintBox1.Width:=StatusBarWidth;
                d.PaintBox1.Height:=StatusBarHeight;
                d.ClientHeight:=3;
                d.ClientWidth:=3;
                if StatusText in Options then
                begin
                        maxx:=0;
                        for i:=0 to 3 do
                        begin
                                if i<>1 then MeasureText(LanguageStrings[i]+' ',x,y)
                                else MeasureText(LanguageStrings[i]+' 199.199.199.199 ',x,y);
                                if x>maxx then maxx:=x;
                        end;
                        d.Status.Height:=y+6;
                        d.Status.Width:=maxx+6;
                        d.Status.Top:=d.ClientHeight;
                        d.Status.Left:=0;
                        d.ClientHeight:=d.ClientHeight+d.Status.Height;
                        d.ClientWidth:=d.Status.Width+6;
                        d.Status.Visible:=True;
                end
                else d.Status.Visible:=False;
                if StatusBar in Options then
                begin
                        d.PaintBox1.Top:=d.ClientHeight;
                        d.PaintBox1.Width:=StatusBarWidth;
                        d.PaintBox1.height:=StatusBarHeight;
                        d.ClientHeight:=d.ClientHeight+StatusBarHeight+3;
                        d.PaintBox1.Visible:=True;
                        if d.PaintBox1.Width+6>d.ClientWidth then d.ClientWidth:=d.PaintBox1.Width+6;
                end
                else d.PaintBox1.Visible:=False;
                if ByteCounter in Options then
                begin
                        d.Counter.Visible:=True;
                        MeasureText('99999999',x,y);
                        d.Counter.Left:=3;
                        d.Counter.Width:=x+6;
                        d.Counter.Height:=y;
                        d.Counter.Top:=d.ClientHeight+3;
                        if not (CancelButton in Options) then d.ClientHeight:=d.ClientHeight+y+6;
                end
                else d.Counter.Visible:=False;
                if CancelButton in Options then
                begin
                        d.Cancel.Visible:=True;
                        MeasureText(LanguageStrings[4],x,y);
                        d.Cancel.Caption:=LanguageStrings[4];
                        d.Cancel.Width:=x+16;
                        d.Cancel.Height:=y+10;
                        if not (ByteCounter in Options) then d.cancel.top:=d.ClientHeight+3
                        else d.cancel.top:=d.counter.top;
                        d.ClientHeight:=d.ClientHeight+d.Cancel.Height+3;
                end
                else d.Cancel.Visible:=False;
                if (ByteCounter in Options) and (CancelButton in Options) then
                begin
                        if d.Cancel.Width+d.Counter.Width+12>d.ClientWidth then
                                d.ClientWidth:=d.Cancel.Width+d.Counter.Width+12;
                        d.Cancel.Left:=d.ClientWidth-d.Cancel.Width-3;
                end;
                if (ByteCounter in Options) and not (CancelButton in Options) then
                begin
                        if d.Counter.Width+6>d.ClientWidth then
                                d.ClientWidth:=d.Counter.Width+6;
                        d.Counter.Left:=(d.ClientWidth-d.Counter.Width)div 2;
                end;
                if not (ByteCounter in Options) and (CancelButton in Options) then
                begin
                        if d.Cancel.Width+6>d.ClientWidth then
                                d.ClientWidth:=d.Cancel.Width+6;
                        d.Cancel.Left:=(d.ClientWidth-d.Cancel.Width) div 2;
                end;
                d.Status.Width:=d.ClientWidth;
                d.PaintBox1.Left:=(d.ClientWidth-d.PaintBox1.Width)div 2;
                d.ClientHeight:=d.ClientHeight+3;
                d.Ftp1.Ftp_URL:=FURL;
                d.Ftp1.LocalFile:=FLocal;
                if FID='' then FID:='anonymous';
                d.Ftp1.UserName:=FID;
                if FPass='' then FPass:='jdoe@acme.com';
                d.Ftp1.UserPassword:=FPass;
                d.Ftp1.UserAccount:=FAcct;
                d.Timer.Interval:=FTimeOut;
                d.Ftp1.TransferMode:=TT;
                d.tconn1:=LanguageStrings[0];
                d.tconn2:=LanguageStrings[1];
                d.tlogin:=LanguageStrings[2];
                d.ttrans:=LanguageStrings[3];
                d.act:=Action;
                d.c1:=StatusBarColor;
                d.c2:=StatusBarBackground;
                d.ShowModal;
                if d.Ftp1.Error=ftpNone then Result:=True
                else Result:=False;
        finally
                d.Free;
        end;
end;

{=======================================================================}
procedure TFtpURLDialogCE.Button6Click(Sender: TObject);
var
        fed: TFontDialog;
begin
        try
                fed:=TFontDialog.Create(self);
                fed.Font:=FontSample.Font;
                if fed.execute then
                begin
                        FontSample.Font:=fed.Font;
                        txtcol.Brush.Color:=fed.Font.Color;
                        FontSample.Invalidate;
                end;
        finally
                fed.Destroy;
        end;
end;

procedure TFtpURLDialogCE.FontSamplePaint(Sender: TObject);
begin
        with FontSample.Canvas do
        begin
                Brush.Color:=bkcol.Brush.Color;
                Pen.Color:=clBlack;
                Rectangle(0,0,FontSample.Width-1,FontSample.Height-1);
                Font.Color:=txtcol.Brush.Color;
                TextOut(5,5,'AaBbCcDd');
                Moveto(0,0);
                LineTo(FontSample.Width,0);
                LineTo(FontSample.Width,FontSample.Height);
                LineTo(0,FontSample.Height);
                LineTo(0,0);
        end;
end;

procedure TFtpURLDialogCE.Button2Click(Sender: TObject);
var
        ced: TColorDialog;
begin
        try
                ced:=TColorDialog.Create(self);
                ced.Color:=txtcol.Brush.Color;
                if ced.Execute then
                begin
                        txtcol.Brush.Color:=ced.Color;
                        FontSample.Invalidate;

                end;
        finally
                ced.Destroy;
        end;
end;

procedure TFtpURLDialogCE.Button1Click(Sender: TObject);
var
        ced: TColorDialog;
begin
        try
                ced:=TColorDialog.Create(self);
                ced.Color:=bkcol.Brush.Color;
                if ced.Execute then
                begin
                        bkcol.Brush.Color:=ced.Color;
                        FontSample.Invalidate;

                end;
        finally
                ced.Destroy;
        end;
end;

procedure TFtpURLDialogCE.stbarClick(Sender: TObject);
begin
        if stbar.Checked then GroupBox5.Visible:=True
        else GroupBox5.Visible:=false;
end;

procedure TFtpURLDialogCE.Button7Click(Sender: TObject);
var
        ced: TColorDialog;
begin
        try
                ced:=TColorDialog.Create(self);
                ced.Color:=stcol.Brush.Color;
                if ced.Execute then stcol.Brush.Color:=ced.Color;
        finally
                ced.Destroy;
        end;
end;

procedure TFtpURLDialogCE.Button8Click(Sender: TObject);
var
        ced: TColorDialog;
begin
        try
                ced:=TColorDialog.Create(self);
                ced.Color:=stbk.Brush.Color;
                if ced.Execute then stbk.Brush.Color:=ced.Color;
        finally
                ced.Destroy;
        end;
end;

procedure TFtpURLDialogCE.Button5Click(Sender: TObject);
begin
        FDemo:=True;
        ModalResult:=mrOk;
end;
{====================================================================================}
procedure TFtpudlg.TimerTimer(Sender: TObject);
begin
        Ftp1.FatalError(FtpTimeout);
        ModalResult:=1;
end;

procedure TFtpudlg.FtpProceed(var Msg: TMsg);
begin
        case act of
        fd_GetURL: Ftp1.GetURL;
        fd_PutURL: Ftp1.PutURL;
        fd_ListURL: Ftp1.ListURL;
        end;
end;

procedure TFtpudlg.FormShow(Sender: TObject);
begin
        if FDemo then
        begin
                done:=100;
                todo:=300;
                PaintBox1.Invalidate;
                Timer.Interval:=5000;
                Timer.Enabled:=True;
                Status.Caption:=ttrans;
                Counter.Caption:='34580';
                Exit;
        end;
        done:=0;
        todo:=9999;
        URLError:=ftpNone;
        PaintBox1.Invalidate;
        Timer.Enabled:=True;
        Status.Caption:=tconn1;
        PostMessage(Handle,WM_Proceed,0,0);
end;

procedure TFtpudlg.Ftp1FtpInfo(Sender: TObject; info: FtpInfo;
  addinfo: String);
begin
        Timer.Enabled:=False;
        Timer.Enabled:=True;
        case info of
        ftpTransferDone: ModalResult:=1;
        ftpServerConnected:Status.Caption:=tconn2+' '+addinfo;
        ftpDataTrace:
                begin
                        done:=Ftp1.BytesTransferred;
                        Status.Caption:=ttrans;
                        Counter.Caption:=IntToStr(done);
                        PaintBox1Update;
                end;
        ftpFileSize: todo:=StrToInt(addinfo);
        ftpLoggedIn: Status.Caption:=tlogin;
        end;
end;

procedure TFtpudlg.PaintBox1Update;
var
        sub: longint;
begin
        if not PaintBox1.Visible then Exit;
        if (done>todo) or (todo=0) then
        begin
                PaintBox1.Invalidate;
                Exit;
        end;
        with PaintBox1 do
        begin
                with Canvas do
                begin
                        sub:=Width*done;
                        sub:=sub div todo;
                        Brush.Color:=c1;
                        Rectangle(0,0,sub-1,Height-1);
                end;
        end;
end;

procedure TFtpudlg.PaintBox1Paint(Sender: TObject);
begin
        if done>todo then Exit;
        with PaintBox1.Canvas do
        begin
                Brush.Color:=c2;
                Pen.Color:=clBlack;
                Rectangle(0,0,PaintBox1.Width-1,PaintBox1.Height-1);
        end;
        PaintBox1Update;
end;

procedure TFtpudlg.Ftp1FtpError(Sender: TObject; error: FtpError;addinfo: String);
begin
        todo:=0;
        URLError:=error;
end;

procedure TFtpudlg.Ftp1FtpNeedInfo(Sender: TObject; need: TFtpInfoNeeded;
  var value: OpenString);
begin
        case need of
        niUser: value:='anonymous';
        niPassword: value:='acme@acme.com';
        niAccount: value:='0';
        niHost: value:='none';
        end;
end;

procedure TFtpudlg.cancelClick(Sender: TObject);
begin
        URLError:=ftpCanceled;
        Ftp1.StopTransfer;
        ModalResult:=mrCancel;
end;

function FTPExtractLast(line: string): string;
var
        i: integer;
begin
        if Pos('->',line)<>0 then Delete(line,Pos('->',line),999);
        while line[Length(line)]=' ' do Delete(line,Length(line),1);
        i:=Length(line);
        while line[i]<>' ' do Dec(i);
        Result:=Copy(line,i+1,999);
end;

function ExtractField(line: string;n: integer): string;{n is 0 based}
var
        i,j: integer;
begin
        i:=Pos('  ',line);
        while i<>0 do
        begin
                Delete(line,i,1);
                i:=Pos('  ',line);
        end;
        for i:=n downto 1 do
        begin
                j:=Pos(' ',line);
                if j=0 then
                begin
                        Result:='';
                        Exit;
                end;
                Delete(line,1,j);
        end;
        j:=Pos(' ',line);
        if j=0 then Result:=''
        else Result:=Copy(line,1,j-1);
end;

var
        tmpvmsname: string;

function ParseListingLine(ServerType: TFTPServerType;line: string;var name,size,date: string; var IsDir: Boolean): Boolean;
begin
        case ServerType of
        ftpstUNIX,ftpstULTRIX,ftpstU5000,ftpstSINTFTPD,ftpstDefault:
                begin
                        name:=FtpExtractLast(line);
                        case line[1] of
                        'd','l': IsDir:=True;
                        '-','f': IsDir:=False;
                        else
                                begin
                                        Result:=False;
                                        Exit;
                                end;
                        end;
                        if ExtractField(line,1)[1]='[' then
                        begin
                                date:=ExtractField(line,4)+' '+ExtractField(line,5)+' '+ExtractField(line,6);
                                size:=ExtractField(line,3);
                        end
                        else
                        begin
                                date:=ExtractField(line,5)+' '+ExtractField(line,6)+' '+ExtractField(line,7);
                                size:=ExtractField(line,4);
                        end;
                        Result:=True;
                end;
        ftpstVM:
                begin
                        name:=ExtractField(line,0)+'.'+ExtractField(line,1);
                        size:=ExtractField(line,3);
                        date:=ExtractField(line,6)+' '+ExtractField(line,7);
                        IsDir:=False;
                        Result:=True;
                end;
        ftpstVMVPS:
                begin
                        if (Pos('=',line)<>0) or (Pos('totals:', line)<>0) or
                           (Pos(' rf trks',line)<>0) or (Pos('track limit',line)<>0) then
                        begin
                                Result:=False;
                                Exit;
                        end;
                        name:='.'+ExtractField(line,1);
                        size:=ExtractField(line,2);
                        date:=ExtractField(line,7)+' '+ExtractField(line,6);
                        IsDIr:=False;
                        Result:=True;
                end;
        ftpstVMSMultinet,ftpstVMSUcx:
                begin
                        if tmpvmsname<>'' then
                        begin
                                line:=tmpvmsname+line;
                                tmpvmsname:='';
                        end;
                        if Pos(';',line)=0 then
                        begin
                                tmpvmsname:='';
                                Result:=False;
                                Exit;
                        end;
                        name:=ExtractField(line,0);
                        if name='' then
                        begin
                                tmpvmsname:=line;
                                Result:=False;
                        end
                        else
                        begin
                                name:=Copy(name,1,Pos(';',name)-1);
                                IsDIr:=Pos('.DIR',name)<>0;
                                if IsDIr then Name:=Copy(name,1,Pos('.DIR',name)-1);
                                size:=ExtractField(line,1);
                                date:=ExtractField(line,2)+' '+ExtractField(line,3);
                                Result:=True;
                        end;
                end;
        end;
end;

end.
