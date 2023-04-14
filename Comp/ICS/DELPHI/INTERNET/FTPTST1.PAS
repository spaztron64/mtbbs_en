{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Creation:     Aug 1997
Version:      2.21
Object:       Demo for TFtpClient object (RFC 959 implementation)
              It is a graphical FTP client program
              Compatible with Delphi 1, 2, 3 and 4
EMail:        francois.piette@pophost.eunet.be
              francois.piette@rtfm.be             http://www.rtfm.be/fpiette
Support:      Use the mailing list twsocket@rtfm.be See website for details.
Legal issues: Copyright (C) 1997, 1998 by François PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium. Fax: +32-4-365.74.56
              <francois.piette@pophost.eunet.be>

              This software is provided 'as-is', without any express or
  	      implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software for any
              purpose, including commercial applications, and to alter it
              and redistribute it freely, subject to the following
              restrictions:

              1. The origin of this software must not be misrepresented,
                 you must not claim that you wrote the original software.
                 If you use this software in a product, an acknowledgment
                 in the product documentation would be appreciated but is
                 not required.

              2. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

              4. You must register this software by sending a picture postcard
                 to the author. Use a nice stamp and mention your name, street
                 address, EMail address and any comment you like to say.

Updates:
Sep 13, 97    Added directory functions. Added button to show how to makes
              several transferts in one session
Sep 27, 97    Change identifiers names to be more standard with other sources
Jan 10, 98    Saved edit boxes content to an IniFile, added FileSize, Quote
              and RestartGet commands
Jan 25, 1998  Completely rewritten for new component version (Asynchronous)
Feb 02, 1998  V2.17 Added a checkbox to run the synchronous or asynchronous
              version of the component methods.
Feb 15, 1998  V2.18 Removed useless wait unit from the use clause.
              Added display of winsock information at startup.
Feb 22, 1998  V2.19 Added Append and AppendFile commands
Aug 21, 1998  V2.20 Added a comment in OnProgress event handler to warn user
              about CPU usage.
Dec 22,1998   V2.21 Replaced DisplayFlag by DysplayFileFlag.


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit Ftptst1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, FtpCli, StdCtrls, IniFiles, ExtCtrls, WinSock, WSocket;

const
  FTPTstVersion = 221;

type
  TSyncCmd  = function : Boolean  of object;
  TAsyncCmd = procedure of object;

  TFtpReceiveForm = class(TForm)
    DisplayMemo: TMemo;
    FtpClient1: TFtpClient;
    Panel1: TPanel;
    ExitButton: TButton;
    OpenAsyncButton: TButton;
    QuitAsyncButton: TButton;
    CwdAsyncButton: TButton;
    UserAsyncButton: TButton;
    PassAsyncButton: TButton;
    ConnectAsyncButton: TButton;
    GetAsyncButton: TButton;
    ReceiveAsyncButton: TButton;
    AbortAsyncButton: TButton;
    DirAsyncButton: TButton;
    DirectoryAsyncButton: TButton;
    LsAsyncButton: TButton;
    ListAsyncButton: TButton;
    SystAsyncButton: TButton;
    SystemAsyncButton: TButton;
    FileSizeAsyncButton: TButton;
    SizeAsyncButton: TButton;
    MkdAsyncButton: TButton;
    MkdirAsyncButton: TButton;
    RmdAsyncButton: TButton;
    RmdirAsyncButton: TButton;
    RenAsyncButton: TButton;
    RenameAsyncButton: TButton;
    DeleAsyncButton: TButton;
    DeleteAsyncButton: TButton;
    PwdAsyncButton: TButton;
    QuoteAsyncButton: TButton;
    DoQuoteAsyncButton: TButton;
    PutAsyncButton: TButton;
    TransmitAsyncButton: TButton;
    TypeSetAsyncButton: TButton;
    RestGetAsyncButton: TButton;
    RestartGetAsyncButton: TButton;
    CDupAsyncButton: TButton;
    Panel2: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    HostNameEdit: TEdit;
    HostFileEdit: TEdit;
    UserNameEdit: TEdit;
    PassWordEdit: TEdit;
    cbDisplay: TCheckBox;
    LocalFileEdit: TEdit;
    cbBinary: TCheckBox;
    HostDirEdit: TEdit;
    PortEdit: TEdit;
    InfoLabel: TLabel;
    StateLabel: TLabel;
    ClearButton: TButton;
    SyncCheckBox: TCheckBox;
    AppendFileAsyncButton: TButton;
    AppendAsyncButton: TButton;
    PassiveCheckBox: TCheckBox;
    Button1: TButton;
    procedure ExitButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Display(Sender: TObject; var Msg : String);
    procedure FtpClient1Progress(Sender: TObject; Count: Longint;
      var Abort: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OpenAsyncButtonClick(Sender: TObject);
    procedure FtpClient1RequestDone(Sender: TObject; RqType: TFtpRequest;
      Error: Word);
    procedure FtpClient1SessionConnected(Sender: TObject; Error: Word);
    procedure FtpClient1SessionClosed(Sender: TObject; Error: Word);
    procedure QuitAsyncButtonClick(Sender: TObject);
    procedure CwdAsyncButtonClick(Sender: TObject);
    procedure UserAsyncButtonClick(Sender: TObject);
    procedure PassAsyncButtonClick(Sender: TObject);
    procedure ConnectAsyncButtonClick(Sender: TObject);
    procedure FtpClient1StateChange(Sender: TObject);
    procedure GetAsyncButtonClick(Sender: TObject);
    procedure ReceiveAsyncButtonClick(Sender: TObject);
    procedure AbortAsyncButtonClick(Sender: TObject);
    procedure DirAsyncButtonClick(Sender: TObject);
    procedure DirectoryAsyncButtonClick(Sender: TObject);
    procedure LsAsyncButtonClick(Sender: TObject);
    procedure ListAsyncButtonClick(Sender: TObject);
    procedure SystAsyncButtonClick(Sender: TObject);
    procedure SystemAsyncButtonClick(Sender: TObject);
    procedure FileSizeAsyncButtonClick(Sender: TObject);
    procedure SizeAsyncButtonClick(Sender: TObject);
    procedure MkdAsyncButtonClick(Sender: TObject);
    procedure MkdirAsyncButtonClick(Sender: TObject);
    procedure RmdAsyncButtonClick(Sender: TObject);
    procedure RmdirAsyncButtonClick(Sender: TObject);
    procedure RenAsyncButtonClick(Sender: TObject);
    procedure RenameAsyncButtonClick(Sender: TObject);
    procedure DeleAsyncButtonClick(Sender: TObject);
    procedure DeleteAsyncButtonClick(Sender: TObject);
    procedure PwdAsyncButtonClick(Sender: TObject);
    procedure QuoteAsyncButtonClick(Sender: TObject);
    procedure DoQuoteAsyncButtonClick(Sender: TObject);
    procedure PutAsyncButtonClick(Sender: TObject);
    procedure TransmitAsyncButtonClick(Sender: TObject);
    procedure TypeSetAsyncButtonClick(Sender: TObject);
    procedure RestGetAsyncButtonClick(Sender: TObject);
    procedure RestartGetAsyncButtonClick(Sender: TObject);
    procedure CDupAsyncButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure AppendAsyncButtonClick(Sender: TObject);
    procedure AppendFileAsyncButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FIniFileName : String;
    FInitialized : Boolean;
    procedure DisplayFile(FileName : String);
    procedure ExecuteCmd(SyncCmd : TSyncCmd; ASyncCmd : TAsyncCmd);
  public
  end;

const
  TEMP_FILE_NAME = 'FTPDIR.TXT';

var
  FtpReceiveForm: TFtpReceiveForm;

implementation

uses
  FtpTst2;

{$R *.DFM}
const
    SectionData   = 'Data';
    KeyHostName   = 'HostName';
    KeyUserName   = 'UserName';
    KeyPassWord   = 'PassWord';
    KeyHostDir    = 'HostDir';
    KeyPort       = 'Port';
    KeyHostFile   = 'HostFile';
    KeyLocalFile  = 'LocalFile';
    SectionWindow = 'Window';
    KeyTop        = 'Top';
    KeyLeft       = 'Left';
    KeyWidth      = 'Width';
    KeyHeight     = 'Height';


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFNDEF VER80 }
{ To debug event driven programs, it is often handy to just use writeln to  }
{ write debug messages to the console. To get a console, just ask the       }
{ linker to build a console mode application. Then you'll get the default   }
{ console. The function below will make it the size you like...             }
procedure BigConsole(nCols, nLines : Integer);
var
    sc : TCoord;
    N  : DWord;
begin
    if not IsConsole then
        Exit;
    sc.x := nCols;
    sc.y := nLines;
    SetConsoleScreenBufferSize(GetStdHandle(STD_OUTPUT_HANDLE), sc);
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),
                            BACKGROUND_BLUE or BACKGROUND_GREEN or
                            BACKGROUND_RED or BACKGROUND_INTENSITY);
    sc.x := 0;
    sc.y := 0;
    FillConsoleOutputAttribute(GetStdHandle(STD_OUTPUT_HANDLE),
                               BACKGROUND_BLUE or BACKGROUND_GREEN or
                               BACKGROUND_RED or BACKGROUND_INTENSITY,
                               nCols * nLines, sc, N);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.FormCreate(Sender: TObject);
begin
{$IFNDEF VER80}
    BigConsole(80, 100);
{$ENDIF}
    DisplayMemo.Clear;
    InfoLabel.Caption  := '';
    StateLabel.Caption := '';
    FIniFileName := LowerCase(ExtractFileName(Application.ExeName));
    FIniFileName := Copy(FIniFileName, 1, Length(FIniFileName) - 3) + 'ini';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.FormShow(Sender: TObject);
var
    IniFile : TIniFile;
    Data    : TWSAData;
begin
    if not FInitialized then begin
        FInitialized := TRUE;
        IniFile := TIniFile.Create(FIniFileName);
        HostNameEdit.Text  := IniFile.ReadString(SectionData, KeyHostName,
                                                 'ftp.simtel.net');
        PortEdit.Text      := IniFile.ReadString(SectionData, KeyPort,
                                                 'ftp');
        UserNameEdit.Text  := IniFile.ReadString(SectionData, KeyUserName,
                                                 'anonymous');
        PassWordEdit.Text  := IniFile.ReadString(SectionData, KeyPassWord,
                                                 'your.name@your.company.com');
        HostDirEdit.Text   := IniFile.ReadString(SectionData, KeyHostDir,
                                                 '/pub/simtelnet');
        HostFileEdit.Text  := IniFile.ReadString(SectionData, KeyHostFile,
                                                 'index.html');
        LocalFileEdit.Text := IniFile.ReadString(SectionData, KeyLocalFile,
                                                 'c:\temp\index.htm');

        Width  := IniFile.ReadInteger(SectionWindow, KeyWidth,  Width);
        Height := IniFile.ReadInteger(SectionWindow, KeyHeight, Height);
        Top    := IniFile.ReadInteger(SectionWindow, KeyTop,    (Screen.Height - Height) div 2);
        Left   := IniFile.ReadInteger(SectionWindow, KeyLeft,   (Screen.Width - Width) div 2);

        IniFile.Free;

        { Display winsock info } 
        Data := WinsockInfo;
        DisplayMemo.Lines.Add('Winsock verion ' +
                              IntToStr(LOBYTE(Data.wVersion)) + '.' +
                              IntToStr(HIBYTE(Data.wVersion)));
        DisplayMemo.Lines.Add(StrPas(Data.szDescription));
        DisplayMemo.Lines.Add(StrPas(Data.szSystemStatus));
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
    IniFile : TIniFile;
begin
    IniFile := TIniFile.Create(FIniFileName);
    IniFile.WriteString(SectionData, KeyHostName,  HostNameEdit.Text);
    IniFile.WriteString(SectionData, KeyPort,      PortEdit.Text);
    IniFile.WriteString(SectionData, KeyUserName,  UserNameEdit.Text);
    IniFile.WriteString(SectionData, KeyPassWord,  PassWordEdit.Text);
    IniFile.WriteString(SectionData, KeyHostDir,   HostDirEdit.Text);
    IniFile.WriteString(SectionData, KeyHostFile,  HostFileEdit.Text);
    IniFile.WriteString(SectionData, KeyLocalFile, LocalFileEdit.Text);
    IniFile.WriteInteger(SectionWindow, KeyTop,    Top);
    IniFile.WriteInteger(SectionWindow, KeyLeft,   Left);
    IniFile.WriteInteger(SectionWindow, KeyWidth,  Width);
    IniFile.WriteInteger(SectionWindow, KeyHeight, Height);
    IniFile.Free;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF VER80}
function DeleteFile(const FileName: string): Boolean;
var
   F : File of char;
begin
    Result := TRUE;
    try
        AssignFile(F, FileName);
        Erase(F);
    except
        Result := FALSE;
    end;
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.Display(Sender : TObject; var Msg : String);
begin
    DisplayMemo.Lines.Add(Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.ExitButtonClick(Sender: TObject);
begin
    Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.FtpClient1Progress(Sender: TObject;
  Count: Longint; var Abort: Boolean);
begin
    InfoLabel.Caption := IntToStr(Count);
    InfoLabel.Repaint;
    { Uncomment the next line to let other application use more CPU }
    { (this will of course make file transfert slower }
    { Application.ProcessMessages; }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.DisplayFile(FileName : String);
begin
    try
        DirectoryForm.DirListBox.Items.LoadFromFile(FileName);
    except
        DirectoryForm.DirListBox.Clear;
    end;
    DirectoryForm.ShowModal;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.FtpClient1RequestDone(Sender: TObject;
  RqType: TFtpRequest; Error: Word);
begin
    DisplayMemo.Lines.Add('Request ' + IntToStr(Ord(RqType)) + ' Done.');
    DisplayMemo.Lines.Add('StatusCode = ' + IntToStr(FtpClient1.StatusCode));
    DisplayMemo.Lines.Add('LastResponse was : ''' +
                          FtpClient1.LastResponse + '''');
    if Error = 0 then
        DisplayMemo.Lines.Add('No error')
    else
        DisplayMemo.Lines.Add('Error = ' + IntToStr(Error) +
                              ' (' + FtpClient1.ErrorMessage + ')');

    if Error = 0 then begin
        case RqType of
        ftpDirAsync, ftpDirectoryAsync,
        ftpLsAsync,  ftpListAsync       : DisplayFile(TEMP_FILE_NAME);
        ftpSizeAsync                    : DisplayMemo.Lines.Add(
                                             'File size is ' +
                                             IntToStr(FtpClient1.SizeResult) +
                                             ' bytes' );
        ftpPwdAsync, ftpMkdAsync,
        ftpCDupAsync, ftpCwdAsync       : DisplayMemo.Lines.Add(
                                             'Directory is "' +
                                             FtpClient1.DirResult + '"');
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.FtpClient1SessionConnected(Sender: TObject;
  Error: Word);
begin
    DisplayMemo.Lines.Add('Session Connected, error = ' + IntToStr(Error));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.FtpClient1SessionClosed(Sender: TObject;
  Error: Word);
begin
    DisplayMemo.Lines.Add('Session Closed, error = ' + IntToStr(Error));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.FtpClient1StateChange(Sender: TObject);
begin
{   DisplayMemo.Lines.Add('State = ' + IntToStr(Ord(FtpClient1.State))); }
    StateLabel.Caption := IntToStr(Ord(FtpClient1.State));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.ExecuteCmd(SyncCmd : TSyncCmd; ASyncCmd : TAsyncCmd);
begin
    DisplayMemo.Lines.Add('Executing Requested Command');
    if SyncCheckBox.Checked then begin
        if SyncCmd then
            DisplayMemo.Lines.Add('Command Success')
        else
            DisplayMemo.Lines.Add('Command Failure');
    end
    else
        ASyncCmd;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.OpenAsyncButtonClick(Sender: TObject);
begin
    DisplayMemo.Clear;
    DisplayMemo.Lines.Add('Connect Async');
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Open, FtpClient1.OpenAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.QuitAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Quit, FtpClient1.QuitAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.CwdAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Cwd, FtpClient1.CwdAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.UserAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.User, FtpClient1.UserAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.PassAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.Password        := PasswordEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Pass, FtpClient1.PassAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.ConnectAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.Password        := PasswordEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Connect, FtpClient1.ConnectAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.GetAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.Passive         := PassiveCheckBox.Checked;
    ExecuteCmd(FtpClient1.Get, FtpClient1.GetAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.ReceiveAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.Binary          := cbBinary.Checked;
    FtpClient1.Passive         := PassiveCheckBox.Checked;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Receive, FtpClient1.ReceiveAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.AbortAsyncButtonClick(Sender: TObject);
begin
    ExecuteCmd(FtpClient1.Abort, FtpClient1.AbortAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.DirAsyncButtonClick(Sender: TObject);
begin
    DeleteFile(TEMP_FILE_NAME);
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := TEMP_FILE_NAME;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.Passive         := PassiveCheckBox.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Dir, FtpClient1.DirAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.DirectoryAsyncButtonClick(Sender: TObject);
begin
    DeleteFile(TEMP_FILE_NAME);
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := TEMP_FILE_NAME;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.Passive         := PassiveCheckBox.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Directory, FtpClient1.DirectoryAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.LsAsyncButtonClick(Sender: TObject);
begin
    DeleteFile(TEMP_FILE_NAME);
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := TEMP_FILE_NAME;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.Passive         := PassiveCheckBox.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Ls, FtpClient1.LsAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.ListAsyncButtonClick(Sender: TObject);
begin
    DeleteFile(TEMP_FILE_NAME);
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := TEMP_FILE_NAME;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.Passive         := PassiveCheckBox.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.List, FtpClient1.ListAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.SystAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Syst, FtpClient1.SystAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.SystemAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.System, FtpClient1.SystemAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.FileSizeAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.FileSize, FtpClient1.FileSizeAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.SizeAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Size, FtpClient1.SizeAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.MkdAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Mkd, FtpClient1.MkdAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.MkdirAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.MkDir, FtpClient1.MkdirAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.RmdAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Rmd, FtpClient1.RmdAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.RmdirAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.RmDir, FtpClient1.RmDirAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.RenAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Ren, FtpClient1.RenAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.RenameAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Rename, FtpClient1.RenameAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.DeleAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Dele, FtpClient1.DeleAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.DeleteAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Delete, FtpClient1.DeleteAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.PwdAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Pwd, FtpClient1.PwdAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.QuoteAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Quote, FtpClient1.QuoteAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.DoQuoteAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.DoQuote, FtpClient1.DoQuoteAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.PutAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.Binary          := cbBinary.Checked;
    FtpClient1.Passive         := PassiveCheckBox.Checked;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Put, FtpClient1.PutAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.TransmitAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.Binary          := cbBinary.Checked;
    FtpClient1.Passive         := PassiveCheckBox.Checked;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Transmit, FtpClient1.TransmitAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.TypeSetAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.Binary          := cbBinary.Checked;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.TypeSet, FtpClient1.TypeSetAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.RestGetAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    ExecuteCmd(FtpClient1.RestGet, FtpClient1.RestGetAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.RestartGetAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.Binary          := cbBinary.Checked;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.RestartGet, FtpClient1.RestartGetAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.CDupAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.CDup, FtpClient1.CDupAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.ClearButtonClick(Sender: TObject);
begin
    DisplayMemo.Clear;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.AppendAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.Binary          := cbBinary.Checked;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.Append, FtpClient1.AppendAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.AppendFileAsyncButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.Port            := PortEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.Binary          := cbBinary.Checked;
    FtpClient1.DisplayFileFlag := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    ExecuteCmd(FtpClient1.AppendFile, FtpClient1.AppendFileAsync);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

procedure TFtpReceiveForm.Button1Click(Sender: TObject);
var
    Count : Integer;
begin
    SyncCheckBox.Checked := TRUE;
    if not FtpClient1.Connected then begin
        FtpClient1.HostName        := HostNameEdit.Text;
        FtpClient1.Port            := PortEdit.Text;
        FtpClient1.UserName        := UserNameEdit.Text;
        FtpClient1.Password        := PasswordEdit.Text;
        FtpClient1.DisplayFileFlag := cbDisplay.Checked;
        FtpClient1.OnDisplay       := Display;
        ExecuteCmd(FtpClient1.Connect, FtpClient1.ConnectAsync);
        if Copy(FtpClient1.LastResponse, 1, 3) <> '230' then
            Exit;
    end;
    Count := 0;
    repeat
        DisplayMemo.Clear;
        Inc(Count);
        DisplayMemo.Lines.Add('Count=' + IntToStr(Count));
        FtpClient1.HostDirName     := HostDirEdit.Text;
        FtpClient1.HostFileName    := HostFileEdit.Text;
        FtpClient1.LocalFileName   := LocalFileEdit.Text;
        FtpClient1.Binary          := cbBinary.Checked;
        FtpClient1.Passive         := PassiveCheckBox.Checked;
        FtpClient1.DisplayFileFlag := cbDisplay.Checked;
        FtpClient1.OnDisplay       := Display;
        ExecuteCmd(FtpClient1.Put, FtpClient1.PutAsync);
    until Copy(FtpClient1.LastResponse, 1, 3) <> '226';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

