unit Ftpmain;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Starsock, FileCtrl, Buttons, ExtCtrls,
  ShellApi, Ftp;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    FileListBox1: TFileListBox;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Log: TMemo;
    ConnectBtn: TButton;
    Button2: TButton;
    Button3: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    MkDirFTPBtn: TButton;
    RmDirFTPBtn: TButton;
    Button12: TButton;
    Button13: TButton;
    Button10: TButton;
    Ftp1: TStarFtp;
    Button11: TButton;
    ByteCounter: TLabel;
    Button14: TButton;
    Button15: TButton;
    Button4: TButton;
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ConnectBtnClick(Sender: TObject);
    procedure Ftp1FtpInfo(Sender: TObject; info: FtpInfo; addinfo: String);
    procedure Button11Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure MkDirFTPBtnClick(Sender: TObject);
    procedure RmDirFTPBtnClick(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Ftp1ListingDone(Sender: TObject);
    procedure Ftp1FtpQuit(Sender: TObject);
    procedure Ftp1FileStored(Sender: TObject);
    procedure NeedNewFTPListing(Sender: TObject);
    procedure Ftp1FtpNeedInfo(Sender: TObject; need: TFtpInfoNeeded;
      var value: string);
    procedure Ftp1FileReceived(Sender: TObject);
    procedure Ftp1FtpError(Sender: TObject; error: FtpError;
      addinfo: string);
    procedure Button4Click(Sender: TObject);
  private
        Closing: Boolean;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses FtpInput;

procedure TForm1.Button6Click(Sender: TObject);
var
        command:   string;
begin
        if FileListBox1.ItemIndex=-1 then Exit;
        command:='notepad '+FileListBox1.Filename+#0;
        {$IFDEF VER90}
        WinExec(PChar(command),SW_SHOW);
        {$ELSE}
        WinExec(PChar(@command[1]),SW_SHOW);
        {$ENDIF}
end;

procedure TForm1.Button7Click(Sender: TObject);
var
        command:   string;
begin
        if FileListBox1.ItemIndex=-1 then Exit;
        command:=FileListBox1.Filename+#0;
        {$IFDEF VER90}
        ShellExecute(Application.Handle,nil,PChar(command),nil,nil,SW_SHOW);
        {$ELSE}
        ShellExecute(Application.Handle,nil,PChar(@command[1]),nil,nil,SW_SHOW);
        {$ENDIF}
end;

procedure TForm1.Button8Click(Sender: TObject);
var
        f:      file;
begin
        if FileListBox1.ItemIndex=-1 then Exit;
        InputForm.Caption:='Rename';
        InputForm.Prompt.Caption:='Enter new name:';
        InputForm.Input.Text:='';
        if InputForm.ShowModal=mrOk then
        begin
                AssignFile(f,FileListBox1.Filename);
                Rename(f,ExtractFilePath(FileListBox1.Filename)+ExtractFileName(InputForm.Input.Text));
                FileListBox1.Mask:='';
                FileListBox1.Mask:='*.*';
        end;
end;

procedure TForm1.Button9Click(Sender: TObject);
var
        f:      file;
        q:      string;
begin
        if FileListBox1.ItemIndex=-1 then Exit;
        q:='Are you sure you want to delete '+ExtractFileName(FileListBox1.FileName)+' ?'+#0;
        if MessageDlg(q,mtConfirmation,[mbYes,mbNo],0)=mrYes then
        begin
                AssignFile(f,FileListBox1.Filename);
                Erase(f);
                FileListBox1.Mask:='';
                FileListBox1.Mask:='*.*';
        end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
        if DirectoryListBox1.ItemIndex=-1 then Exit;
        InputForm.Caption:='Create Directory';
        InputForm.Prompt.Caption:='Enter new directory name:';
        InputForm.Input.Text:='';
        if InputForm.ShowModal=mrOk then
        begin
                MkDir(DirectoryListbox1.Directory+'/'+InputForm.Input.Text);
                DirectoryListBox1.Directory:=DirectoryListbox1.Directory+'/'+InputForm.Input.Text;
        end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
        q:      string;
        d:      char;
begin
        if DirectoryListBox1.ItemIndex=-1 then Exit;
        q:='Are you sure you want to remove '+DirectoryListBox1.Directory+' ?'+#0;
        if MessageDlg(q,mtConfirmation,[mbYes,mbNo],0)=mrYes then
        begin
                d:=DirectoryListbox1.Drive;
                q:=DirectoryListbox1.Directory;
                DirectoryListBox1.Directory:=ExtractFilePath(q);
                RmDir(q);
                DirectoryListBox1.Clear;
                DirectoryListBox1.Drive:=d;
                DirectoryListBox1.Directory:=ExtractFilePath(q);
        end;
end;


procedure TForm1.ConnectBtnClick(Sender: TObject);
var
        h:      string;
begin
        If (Ftp1.Connected) or (Screen.Cursor=crHourglass) then Exit;
        Ftp1.FtpServer:='';
        Ftp1.UserName:='';
        Ftp1.UserPassword:='';
        Ftp1.UserAccount:='';
        Screen.Cursor:=crHourglass;
        Ftp1.Login;
end;


procedure TForm1.Ftp1FtpInfo(Sender: TObject; info: FtpInfo;
  addinfo: String);
begin
        case info of
        ftpTraceIn,ftpTraceOut:
                begin
                        try
                                Log.Lines.Add(addinfo);
                        except
                                Log.Lines.Clear;
                                Log.Lines.Add(addinfo);
                        end;
                end;
        ftpDataTrace: ByteCounter.Caption:=IntToStr(FTP1.BytesTransferred);
        end;
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
        if not Ftp1.Connected or (Screen.cursor=crHourglass) then Exit;
        Screen.cursor:=crHourglass;
        Ftp1.Quit;
end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
begin
        if not Ftp1.Connected or (ListBox1.ItemIndex=-1) or (Screen.cursor=crHourglass) then Exit;
        Screen.cursor:=crHourglass;
        Ftp1.ChangeDirectory(ListBox1.Items[ListBox1.ItemIndex]);
end;

procedure TForm1.MkDirFTPBtnClick(Sender: TObject);
begin
        if not Ftp1.Connected  or (Screen.cursor=crHourglass) then Exit;
        InputForm.Caption:='Create Directory';
        InputForm.Prompt.Caption:='Enter new directory name:';
        InputForm.Input.Text:='';
        if InputForm.ShowModal=mrOk then
        begin
                Screen.cursor:=crHourglass;
                Ftp1.CreateDirectory(InputForm.Input.Text);
        end;
end;

procedure TForm1.RmDirFTPBtnClick(Sender: TObject);
var
        q:      string;
begin
        if not Ftp1.Connected or (ListBox1.ItemIndex=-1) or (Screen.cursor=crHourglass) then Exit;
        q:='Are you sure you want to remove '+ListBox1.Items[ListBox1.ItemIndex]+' ?'+#0;
        if MessageDlg(q,mtConfirmation,[mbYes,mbNo],0)=mrYes then
        begin
                Screen.cursor:=crHourglass;
                Ftp1.DeleteDirectory(ListBox1.Items[ListBox1.ItemIndex]);
        end;
end;

procedure TForm1.Button12Click(Sender: TObject);
begin
        if not Ftp1.Connected or (ListBox2.ItemIndex=-1) or (Screen.cursor=crHourglass) then Exit;
        InputForm.Caption:='Rename File';
        InputForm.Prompt.Caption:='Enter new File name:';
        InputForm.Input.Text:='';
        if InputForm.ShowModal=mrOk then
        begin
                Screen.cursor:=crHourglass;
                Ftp1.RenameFile(ListBox2.Items[ListBox2.ItemIndex],InputForm.Input.Text);
        end;
end;

procedure TForm1.Button13Click(Sender: TObject);
var
        q:      string;
begin
        if not Ftp1.Connected or (ListBox2.ItemIndex=-1) or (Screen.cursor=crHourglass) then Exit;
        q:='Are you sure you want to remove '+ListBox2.Items[ListBox2.ItemIndex]+' ?'+#0;
        if MessageDlg(q,mtConfirmation,[mbYes,mbNo],0)=mrYes then
        begin
                screen.cursor:=crHourglass;
                Ftp1.DeleteFile(ListBox2.Items[ListBox2.ItemIndex]);
        end;
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
        Close;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
        if Ftp1.Connected then
        begin
                Ftp1.Quit;
                CanClose:=False;
                Closing:=True;
        end
        else CanClose:=True;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
var
        sv:             TSaveDialog;
begin
        if not Ftp1.Connected or (ListBox2.ItemIndex=-1) or (Screen.cursor=crHourglass) then Exit;
        Ftp1.RemoteFile:=ListBox2.Items[ListBox2.ItemIndex];
        sv:=TSaveDialog.Create(self);
        sv.Filename:=ListBox2.Items[ListBox2.ItemIndex];
        if sv.Execute then Ftp1.LocalFile:=sv.Filename;
        sv.Destroy;
        screen.cursor:=crHourglass;
        Ftp1.GetFile;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
        if not Ftp1.Connected or (Screen.cursor=crHourglass) or (FileListBox1.ItemIndex=-1) then Exit;
        Ftp1.LocalFile:=FilelistBox1.Filename;
        Ftp1.RemoteFile:=ExtractFilename(FileListBox1.Filename);
        screen.cursor:=crHourglass;
        Ftp1.PutFile;
end;

procedure TForm1.Button14Click(Sender: TObject);
begin
        FileListBox1.Mask:='';
        FileListBox1.Mask:='*.*';
end;

procedure TForm1.Button15Click(Sender: TObject);
begin
        if not Ftp1.Connected or (Screen.cursor=crHourglass) then Exit;
        Ftp1.FTPRefresh;
end;

procedure TForm1.Ftp1ListingDone(Sender: TObject);
begin
        ListBox1.Clear;
        ListBox1.Items.Assign(FTP1.Directories);
        If ListBox1.Items.IndexOf('..')=-1 then ListBox1.Items.Insert(0,'..');
        ListBox2.Clear;
        ListBox2.Items.Assign(FTP1.Files);
        screen.cursor:=crDefault;
end;

procedure TForm1.Ftp1FtpQuit(Sender: TObject);
begin
        Screen.Cursor:=crDefault;
        if Closing then PostQuitMessage(0);
end;

procedure TForm1.Ftp1FileStored(Sender: TObject);
begin
        begin
                if FTP1.TransferTime<>0 then
                Log.Lines.Add(IntToStr(FTP1.BytesTransferred)+
                 ' bytes transferred in '+IntToStr(FTP1.TransferTime div 1000)+'.'+
                 IntToStr(FTP1.TransferTime mod 1000)+' seconds ('+
                 IntToStr(FTP1.BytesTransferred div FTP1.TransferTime)+'K per second)');
                 ByteCounter.Caption:='';
                 FileListBox1.Mask:='';
                 FileListBox1.Mask:='*.*';
        end;
        NeedNewFTPListing(self);
end;

procedure TForm1.NeedNewFTPListing(Sender: TObject);
begin
        FTP1.FTPRefresh;
end;

procedure TForm1.Ftp1FtpNeedInfo(Sender: TObject; need: TFtpInfoNeeded;
  var value: string);
var
        title:           string;
begin
        case need of
        niHost: title:='Hostname';
        niUser: title:='User ID';
        niPassword: title:='Password';
        niAccount: title:='Account';
        end;
        InputForm.Caption:=title;
        InputForm.Prompt.Caption:='Enter the '+lowercase(title)+'.';
        InputForm.Input.Text:='';
        InputForm.ShowModal;
        value:=InputForm.Input.Text;
end;

procedure TForm1.Ftp1FileReceived(Sender: TObject);
begin
        FileListBox1.Mask:='';
        FileListBox1.Mask:='*.*';
        Screen.Cursor:=crDefault;
end;

procedure TForm1.Ftp1FtpError(Sender: TObject; error: FtpError;
  addinfo: string);
begin
        case error of
        ftpNoServer: ShowMessage('No server specified');
        ftpFileNotFound,ftpFileOpen: ShowMessage('Error opening '+addinfo);
        ftpFileRead: ShowMessage('Error reading from '+addinfo);
        ftpFileWrite: ShowMessage('Error writing to '+addinfo);
        ftpWInsockNotInitialized: ShowMessage('The winsock interface could not be '+
                'initialized. Make sure that winsock is installed on your system.');
        ftpNetworkUnreachable,ftpAddressNotAvailable,ftpHostUnreachable,ftpNetworkDown: ShowMessage('The network is '+
                'down. Make sure that you have established a connection to the network.');
        ftpInvalidAddress,ftpAddressResolutionError: ShowMessage('StarMail could not find your FTP mail server. '+
                'Check that you are connected to your service provider and '+
                'that your setup information is correct.');
        ftpInternalError,ftpGeneralWinsockError,ftpUnknown: ShowMessage('An unexpected error occured');
        ftpPrematureDisconnect,ftpConnAborted,ftpConnReset: ShowMessage('The connection was unexpectedly closed by the '+
                'remote server');
        ftpConnectTimeOut: ShowMessage('The connection attempt to the server timed out.');
        ftpOutofSockets: ShowMessage('The winsock is out of sockets. Close a winsock application before trying '+
                'again.');
        ftpConnectionRefused: ShowMessage('The mail server refused the connection. Make sure that you have '+
                'entered the correct value in setup for your FTP server.');
        ftpProtocolError: ShowMessage('An unexpected response was received from the mail server. Make sure that you '+
                'have entered the correct value in setup for your FTP port.');
        ftpCanceled: ShowMessage('The transaction was canceled.');
        ftpAccessDenied: ShowMessage('Access denied. Check your user ID and password.');
        ftpServerDown: ShowMessage('The FTP server is down.');
        ftpDataError: ShowMessage('An error occured while transferring data.');
        end;
        Screen.Cursor:=crDefault;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
        Ftp1.StopTransfer;
end;

end.
