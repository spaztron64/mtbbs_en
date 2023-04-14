unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Starsock, Ftp, ComCtrls, ExtCtrls, Menus,ShellApi, Buttons,
  FileCtrl,splash;

type TFTPServerInfo=record
        Name: string[50];
        Server: string[40];
        Port: integer;
        password: string[40];
        user: string[40];
        account: string[40];
        Description: string[200];
        InitialDir: string[255];
        Anonymous: Boolean;
        SavePassword: Boolean;
        ModifiedDate: string[80];
        EMail: string[60];
end;

type
  TMain = class(TForm)
    Panel1: TPanel;
    Ftp1: TStarFtp;
    Panel3: TPanel;
    Panel4: TPanel;
    FTPPanel: TPanel;
    Panel2: TPanel;
    FTPLabel: TLabel;
    LeftPanel: TPanel;
    LocalLabel: TLabel;
    BottomPanel: TPanel;
    StatusPanel: TPanel;
    RichEdit1: TRichEdit;
    LocalView: TListView;
    FTPView: TListView;
    Panel6: TPanel;
    DriveComboBox1: TDriveComboBox;
    FTPPathPanel: TPanel;
    LocalPath: TComboBox;
    FTPPath: TComboBox;
    FTPOneLevelUp: TSpeedButton;
    LocalUpOneLevel: TSpeedButton;
    LargeImage: TImageList;
    SmallImage: TImageList;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    SelectAll1: TMenuItem;
    N5: TMenuItem;
    Delete2: TMenuItem;
    SpeedButton1: TSpeedButton;
    QuitBtn: TSpeedButton;
    PopupMenu1: TPopupMenu;
    View1: TMenuItem;
    LargeIcons1: TMenuItem;
    SmallIcons1: TMenuItem;
    List1: TMenuItem;
    Details1: TMenuItem;
    New1: TMenuItem;
    Folder1: TMenuItem;
    Server1: TMenuItem;
    N1: TMenuItem;
    ArrangeIcons1: TMenuItem;
    byName1: TMenuItem;
    N2: TMenuItem;
    Lineupicons1: TMenuItem;
    Delete1: TMenuItem;
    N3: TMenuItem;
    Properties1: TMenuItem;
    N4: TMenuItem;
    procedure Ftp1FtpInfo(Sender: TObject; info: FtpInfo; addinfo: string);
    procedure Ftp1LoggedIn(Sender: TObject);
    procedure Ftp1DirectoryChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Ftp1DirectoryCreated(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Panel2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Ftp1FileReceived(Sender: TObject);
    procedure Ftp1FileDeleted(Sender: TObject);
    procedure Ftp1FtpReady(Sender: TObject);
    procedure Ftp1ListingDone(Sender: TObject);
    procedure Panel3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Ftp1FileStored(Sender: TObject);
    procedure FTPPathDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure LocalPathDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FTPOneLevelUpClick(Sender: TObject);
    procedure LocalUpOneLevelClick(Sender: TObject);
    procedure DriveComboBox1Change(Sender: TObject);
    procedure FTPViewDblClick(Sender: TObject);
    procedure LocalViewDblClick(Sender: TObject);
    procedure FTPPathChange(Sender: TObject);
    procedure LocalPathChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure LargeIcons1Click(Sender: TObject);
    procedure SmallIcons1Click(Sender: TObject);
    procedure List1Click(Sender: TObject);
    procedure Details1Click(Sender: TObject);
    procedure LineUpIcons1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure Ftp1DirectoryDeleted(Sender: TObject);
    procedure FTPViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LocalViewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure LocalViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure LocalViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FTPViewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FTPViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Properties1Click(Sender: TObject);
    procedure Server1Click(Sender: TObject);
    procedure NewFolder1Click(Sender: TObject);
    procedure QuitBtnClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FTPViewEdited(Sender: TObject; Item: TListItem;
      var S: string);
    procedure LocalViewEdited(Sender: TObject; Item: TListItem;
      var S: string);
    procedure Ftp1FileRenamed(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Ftp1FtpNeedInfo(Sender: TObject; need: TFtpInfoNeeded;
      var value: string);
    procedure FormResize(Sender: TObject);
    procedure Ftp1FtpQuit(Sender: TObject);
    procedure FTPViewCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure LocalViewCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure Ftp1FtpError(Sender: TObject; error: FtpError;
      addinfo: string);
private
    SourceDirList,DestDirList,SourceList,DestList: TStrings;
    RecursingHomeLocal,RecursingHomeFTP,HomeLocal,HomeFTP: string;
    X0,Y0: integer;
    todo: LongInt;
    Sending: Boolean;
    ProgName: string;
    RecursingGet,RecursingPut,BusyFTP,InServersView: Boolean;
    destdir,recdir: string;
    OldClientWidth,OldClientHeight,OldWidth,oldHeight: integer;
    procedure ProcessRemoteDirectory(source,dest: string);
    procedure ProcessRemoteListing;
    procedure ProcessLocalListing;
    procedure UpdateLocalListing;
    procedure EnableFTPCOntrols;
    procedure DisableFTPCOntrols;
    procedure LoadServersView;
    procedure Cancel;
end;

var
  Main: TMain;
  NewDir: string;
  function ValidUnixName(s: string): string;

implementation

{$R *.DFM}

{$R XTRA32.RES}

uses IniFiles,ServerProperty, progressfrm;

{
        Initialization
}
procedure TMain.FormCreate(Sender: TObject);
begin
        SourceList:=TStringList.Create;
        DestList:=TStringList.Create;
        SourceDirList:=TStringList.Create;
        DestDirList:=TStringList.Create;
        OldClientHeight:=0;
        OldClientWidth:=0;
end;

procedure TMain.FormDestroy(Sender: TObject);
begin
        SourceList.Destroy;
        DestList.Destroy;
        SourceDirList.Destroy;
        DestDirList.Destroy;
end;

procedure TMain.FormShow(Sender: TObject);
begin
        {add resource bitmaps to SmallImage image list}
        with SmallImage do
        begin
                GetResource(rtBitmap,'DISK',16,[],clPurple);{index=3}
                GetResource(rtBitmap,'SERVER',16,[],clPurple);{index=4}
                GetResource(rtBitmap,'FOLDEROPEN',16,[],clPurple);{index=5}
        end;
        LoadServersView;
        InServersView:=True;
        SplashScreen.Free;
end;

{
        Ftp Information notification
}
procedure TMain.Ftp1FtpInfo(Sender: TObject; info: FtpInfo;
  addinfo: string);
begin
        case info of
        ftpResolvingAddress: StatusPanel.Caption:=' Resolving '+addinfo;
        ftpAddressResolved: StatusPanel.Caption:=' Connected to '+addinfo;
        ftpTraceIn,ftpTraceOut: RichEdit1.Lines.Add(addinfo);
        ftpServerConnected: StatusPanel.Caption:='  Connected to '+addinfo;
        ftpServerDisconnected:
                begin
                        StatusPanel.Caption:='  Disconnected';
                end;
        ftpLoggedIn: StatusPanel.Caption:='Logged in';
        ftpFileSize:
                begin
                        todo:=StrToInt(addinfo);
                        if Assigned(Progress) then Progress.StartNewTransfer(FTP1.LocalFile,todo,Sending);
                end;
        ftpDataTrace:
                begin
                        if Assigned(Progress) and not FTP1.DoingListing then Progress.Progress(FTP1.BytesTransferred,FTP1.TransferTime);
                        if FTP1.DoingListing then StatusPanel.Caption:='  Receiving listing: '+IntToStr(Ftp1.BytesTransferred)+' bytes';
                end;
        end;
end;

procedure TMain.Ftp1FtpError(Sender: TObject; error: FtpError;
  addinfo: string);
begin
        case error of
        ftpFileNotFound,ftpFileOpen: StatusPanel.Caption:='  Error opening '+addinfo;
        ftpFileRead: StatusPanel.Caption:='  Error reading from '+addinfo;
        ftpFileWrite: StatusPanel.Caption:='  Error writing to '+addinfo;
        ftpWInsockNotInitialized: Application.MessageBox('The winsock interface could not be '+
                'initialized. Make sure that winsock is installed on your system.',
                'Winsock Error',MB_OK+MB_ICONSTOP);
        ftpNetworkUnreachable,ftpAddressNotAvailable,ftpHostUnreachable,ftpNetworkDown: Application.MessageBox('The network is '+
                'down. Make sure that you have established a connection to the network.',
                'Network Down Error',MB_OK+MB_ICONSTOP);
        ftpInvalidAddress,ftpAddressResolutionError: Application.MessageBox('StarMail could not find your FTP mail server. '+
                'Check that you are connected to your service provider and '+
                'that your setup information is correct.','Name Resolution Error',MB_OK+MB_ICONSTOP);
        ftpInternalError,ftpGeneralWinsockError,ftpUnknown: Application.MessageBox('An unexpected error occured',
                'Unexpected Error',MB_OK+MB_ICONSTOP);
        ftpPrematureDisconnect,ftpConnAborted,ftpConnReset: Application.MessageBox('The connection was unexpectedly closed by the '+
                'remote server','Premature Disconnect Error',MB_OK+MB_ICONSTOP);
        ftpConnectTimeOut: Application.MessageBox('The connection attempt to the server timed out.','Connect Timeout Error',
                MB_OK+MB_ICONSTOP);
        ftpOutofSockets: Application.MessageBox('The winsock is out of sockets. Close a winsock application before trying '+
                'again.','Out of Sockets Error',MB_OK+MB_ICONSTOP);
        ftpConnectionRefused: Application.MessageBox('The mail server refused the connection. Make sure that you have '+
                'entered the correct value in setup for your FTP server.','Connection Rejected Error',MB_OK+MB_ICONSTOP);
        ftpProtocolError: Application.MessageBox('An unexpected response was received from the mail server. Make sure that you '+
                'have entered the correct value in setup for your FTP port.','Unexpected Response Error',MB_OK+MB_ICONSTOP);
        ftpCanceled: Application.MessageBox('The transaction was canceled.','Transaction Canceled',MB_OK+MB_ICONSTOP);
        ftpAccessDenied: Application.MessageBox('Access denied. Check your user ID and password.','Access Denied',
                MB_OK+MB_ICONSTOP);
        ftpServerDown: Application.MessageBox('The FTP server is down.','Server Down Error',
                MB_OK+MB_ICONSTOP);
        ftpDataError: Application.MessageBox('An error occured while transferring data.','Data Transfer Error',
                MB_OK+MB_ICONSTOP);
        end;
end;

{
        Panel Resizing
}
procedure TMain.Panel2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
        X0:=X;
end;

procedure TMain.Panel2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
        n: integer;
begin
        n:=LeftPanel.Width+X-X0;
        if n<0 then n:=0;
        LeftPanel.Width:=n;
        OldWidth:=LeftPanel.Width;
end;

procedure TMain.Panel3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
        Y0:=Y;
end;

procedure TMain.Panel3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
        n: integer;
begin
        n:=BottomPanel.Height+Y0-Y;
        if n<0 then n:=0;
        BottomPanel.Height:=n;
        OldHeight:=BottomPanel.Height;
end;

{
        ValidUnixName: changes spaces to underscore in files destined for server
}
function ValidUnixName(s: string): string;
var
        i: integer;
begin
        for i:=1 to Length(s) do if s[i]=' ' then s[i]:='_';
        Result:=s;
end;

{
        Completion Notifications from FTP Server
}

procedure TMain.Ftp1LoggedIn(Sender: TObject);
begin
        FTPPathPanel.Visible:=True;
        FTPLabel.Caption:=FTP1.FTPServer;
        FTPView.Items.CLear;
        FTPView.ViewStyle:=vsReport;
        InServersView:=False;
        StatusPanel.Caption:='  Waiting for directory listing';
        FTP1.FTPRefresh;
end;

procedure TMain.Ftp1DirectoryCreated(Sender: TObject);
begin
        if RecursingPut then FTP1.ChangeDirectory(ValidUnixName(destdir))
        else
        begin
                FTP1.FTPRefresh;
                StatusPanel.Caption:='  Waiting for directory listing';
        end;
end;

procedure TMain.Ftp1DirectoryChanged(Sender: TObject);
begin
        StatusPanel.Caption:='  Waiting for directory listing';
        if RecursingPut then ProcessLocalListing
        else FTP1.FTPRefresh;
end;

procedure TMain.Ftp1FileReceived(Sender: TObject);
begin
        if Assigned(Progress) then Progress.EndTransfer;
        UpdateLocalListing;
        {check for more files to download}
        if SourceList.Count>0 then
        begin
                Ftp1.RemoteFile:=SourceList[0];
                SourceList.Delete(0);
                Ftp1.LocalFile:=DestList[0];
                DestList.Delete(0);
                StatusPanel.Caption:='  Starting transfer of '+ExtractFileName(Ftp1.LocalFile);
                Sending:=False;
                Ftp1.GetFile;
        end
        else {no more files, check for more directories}
        begin
                if SourceDirList.Count>0 then
                begin
                        ProcessRemoteDirectory(SourceDirList[0],DestDirList[0]);
                        SourceDirList.Delete(0);
                        DestDirList.Delete(0);
                end
                else
                begin
                        EnableFTPControls;{we are all done}
                        if Assigned(Progress) then Progress.Free;
                        Progress:=nil;
                end;
        end;
end;

procedure TMain.Ftp1FileStored(Sender: TObject);
var
        s: string;
begin
        if Assigned(Progress) then Progress.EndTransfer;
        s:=ExtractFileName(FTP1.LocalFile);
        {check for more files to download}
        if SourceList.Count>0 then
        begin
                Ftp1.LocalFile:=SourceList[0];
                SourceList.Delete(0);
                Ftp1.RemoteFile:=ValidUnixName(DestList[0]);
                DestList.Delete(0);
                DisableFTPControls;
                Sending:=True;
                Ftp1.PutFile;
        end
        else {no more files, check for more directories}
        begin
                if SourceDirList.Count>0 then
                begin
                        recdir:=SourceDirList[0];
                        destdir:=DestDirList[0];
                        SourceDirList.Delete(0);
                        DestDirList.Delete(0);
                        SetCurrentDir(recdir);
                        UpdateLocalListing;
                        RecursingPut:=True;
                        Ftp1.CreateDirectory(ValidUnixName(destdir));
                end
                else
                begin
                        FTp1.FTPRefresh;{all done}
                        If Assigned(Progress) then Progress.Free;
                        Progress:=nil;
                end;
        end;
end;

procedure TMain.Ftp1FileDeleted(Sender: TObject);
begin
        {check for more files to delete}
        if SourceList.Count>0 then
        begin
                StatusPanel.Caption:='Deleting file '+SourceList[0];
                Ftp1.DeleteFile(SourceList[0]);
                SourceList.Delete(0);
                Exit;
        end;
        {done with files, now check directories}
        if SourceDirList.Count>0 then
        begin
                StatusPanel.Caption:='Deleting directory '+SourceDirList[0];
                Ftp1.DeleteFile(SourceDirList[0]);
                SourceDirList.Delete(0);
                Exit;
        end;
        {still here so we are finished}
        begin
                Ftp1.FTPRefresh;
                StatusPanel.Caption:='  Waiting for directory listing';
        end;
end;

procedure TMain.Ftp1DirectoryDeleted(Sender: TObject);
begin
        {check for more directories to delete}
        if SourceDirList.Count>0 then
        begin
                FTP1.DeleteDirectory(SourceDirList[0]);
                SourceDirList.Delete(0);
        end
        else {we are done}
        begin
                StatusPanel.Caption:='  Waiting for directory listing';
                Ftp1.FTPRefresh;
        end;
end;

procedure TMain.Ftp1FileRenamed(Sender: TObject);
begin
        StatusPanel.Caption:='  Waiting for directory listing';
        Ftp1.FTPRefresh;
end;

procedure TMain.Ftp1FtpQuit(Sender: TObject);
begin
        InServersView:=True;
        FTPLabel.Caption:='FTP Servers';
        LoadServersView;
        EnableFTPControls;
        FTPPathPanel.Visible:=False;
        FTPView.ViewStyle:=vsIcon;
end;

procedure TMain.Ftp1FtpReady(Sender: TObject);
begin
        RichEdit1.Lines.Add('-------------------------');
end;

procedure TMain.Ftp1ListingDone(Sender: TObject); {received when file listing has been updated}
var
        i: integer;
        s,fname,fdate,fsize: string;
        item: TListItem;
        IsDir: Boolean;
begin
        {performance enhancements!}
        FTPView.Items.BeginUpdate;
        if FTPView.Items.Count>0 then FTPView.Items.Clear;
        FTPView.SortType:=stNone;
        {first add directories and files}
        for i:=0 to FTP1.Listing.Count-1 do
        begin
                s:=FTP1.Listing[i];
                if ParseListingLine(Ftp1.ServerType,s,fname,fsize,fdate,IsDir) then
                begin
                        try
                                item:=FTPView.Items.Add;
                                item.Caption:=fname;
                                if IsDir then item.SubItems.Add('')
                                else item.SubItems.Add(fsize);
                                item.SubItems.Add(fdate);
                                if IsDir then item.ImageIndex:=0
                                else item.ImageIndex:=1;
                        except
                                ;
                        end;
                end;
        end;
        {then update path combo box}
        FTPPath.Clear;
        FTPPath.Items.Add(FTP1.FTPServer);
        s:=FTP1.InitialDirectory;
        if FTP1.ServerType=ftpstUnix then
        begin
                if s[1]='/' then Delete(s,1,1);
                while s<>'' do
                begin
                        i:=Pos('/',s);
                        if i=0 then i:=Length(s)+1;
                        FTPPath.Items.Add(Copy(s,1,i-1));
                        Delete(s,1,i);
                end;
        end;
        ftpPath.ItemIndex:=ftpPath.Items.Count-1;
        if RecursingGet then ProcessRemoteListing{nothing happens here unless we are recursing directories}
        else EnableFTPCOntrols;
        FTPView.SortType:=stBoth;
        FTPView.Items.EndUpdate;
end;

{
        Owner draw routines for FtpPath and LocalPath combo boxes
}
procedure TMain.FTPPathDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
        bmi: integer;{bitmap index into SmallImage Image List}
begin
        with FTPPath.Canvas do
        begin
                FillRect(Rect);
                if Index=0 then bmi:=4
                else bmi:=5;
                SmallImage.DrawingStyle:=dsTransparent;
                SmallImage.Draw(FTPPath.Canvas,Rect.Left+Index*5,Rect.Top,bmi);
                TextOut(Rect.Left+Index*5+18,Rect.Top,FTPPath.Items[Index]);
        end;
end;

procedure TMain.LocalPathDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
        bmi: integer;{bitmap index into SmallImage Image List}
begin
        with LocalPath.Canvas do
        begin
                FillRect(Rect);
                if Index=0 then bmi:=3
                else bmi:=5;
                SmallImage.DrawingStyle:=dsTransparent;
                SmallImage.Draw(LocalPath.Canvas,Rect.Left+Index*5,Rect.Top,bmi);
                TextOut(Rect.Left+Index*5+18,Rect.Top,LocalPath.Items[Index]);
        end;
end;

{
        Get Listing of current directory into LocalView ListView
}
procedure TMain.UpdateLocalListing;
var
        curdir,s: string;
        i,r: integer;
        f: TSearchRec;
        item: TListItem;
begin
        Screen.Cursor:=crHourglass;
        LocalView.Items.BeginUpdate;
        LocalView.Items.Clear;
        curdir:=GetCurrentDir;
        DriveComboBox1.Drive:=curdir[1];
        LocalView.SortType:=stNone;
        {get listing of local directory}
        r:=FindFirst('*',faAnyFile,f);
        while r=0 do
        begin
                if(f.Attr and faDirectory)<>0 then
                begin
                        if (f.Name[1]<>'.') then
                        begin
                                item:=LocalView.Items.Add;
                                item.Caption:=f.Name;
                                item.SubItems.Add('');
                                DateTimeToString(s,'ddddd t',FileDateToDateTime(f.Time));
                                item.SubItems.Add(s);
                                item.ImageIndex:=0;
                        end;
                end
                else
                begin
                        item:=LocalView.Items.Add;
                        item.Caption:=f.Name;
                        item.SubItems.Add(IntToStr(f.Size));
                        DateTimeToString(s,'ddddd t',FileDateToDateTime(f.Time));
                        item.SubItems.Add(s);
                        item.ImageIndex:=1;
                end;
                r:=FindNext(f);
        end;
        FindClose(f);
        {Populate LocalPath combo box}
        LocalPath.Clear;
        while curdir<>'' do
        begin
                i:=Pos('\',curdir);
                if i=0 then i:=Length(curdir)+1;
                LocalPath.Items.Add(Copy(curdir,1,i-1));
                Delete(curdir,1,i);
        end;
        LocalPath.ItemIndex:=LocalPath.Items.Count-1;
        LocalView.SortType:=stBoth;
        LocalView.Items.EndUpdate;
        Screen.Cursor:=crDefault;
end;

{
        Other Directory functions
}
procedure TMain.FTPOneLevelUpClick(Sender: TObject);
begin
        if FTP1.Busy then Exit;
        DisableFTPCOntrols;
        StatusPanel.Caption:='  Changing directory';
        FTP1.ChangeDirectory('..');
end;

procedure TMain.LocalUpOneLevelClick(Sender: TObject);
begin
        SetCurrentDir('..');
        UpdateLocalListing;
end;

procedure TMain.FTPViewDblClick(Sender: TObject);
var
        i: TIniFile;
        r: TFTPServerInfo;
        s: string;
begin
        if InServersView then
        begin
                if FTPView.Selected=nil then Exit;
                s:=ExtractFilePath(Application.ExeName)+'\'+FTPView.Selected.Caption+'.ftp';
                i:=TIniFile.Create(s);
                r.server:=i.ReadString('Server','server','');
                r.port:=i.ReadInteger('Server','port',21);
                r.Anonymous:=i.ReadBool('User','anonymous',True);
                r.user:=i.readstring('User','user','anonymous');
                r.password:=i.readstring('User','password','');
                r.account:=i.readstring('User','account','');
                r.InitialDir:=i.readstring('Directories','remote','');
                r.EMail:=i.readstring('User','email','joe@acme.com');
                r.SavePassword:=True;
                Ftp1.FTPServer:=r.server;
                FTP1.FTPPort:=r.port;
                if r.Anonymous then
                begin
                        FTP1.UserName:='anonymous';
                        FTP1.UserAccount:='';
                        FTP1.UserPassword:=r.Email;
                end
                else
                begin
                        FTP1.UserName:=r.user;
                        FTP1.UserAccount:=r.account;
                        if r.SavePassword then FTP1.UserPassword:=r.password
                        else
                        begin
                                if not(InputQuery('Enter password','Password:',s)) then Exit;
                                FTP1.UserPassword:=s;
                        end;
                end;
                FTP1.InitialDirectory:=r.InitialDir;
                RecursingGet:=False;
                RecursingPut:=False;
                DisableFTPControls;
                FtpPathPanel.Visible:=True;
                Application.ProcessMessages;
                ftp1.Login;
        end
        else
        begin
                if BusyFTP or (FTPView.Selected=nil) then Exit;
                if FTPView.Selected.ImageIndex=0 then {it is a directory}
                begin
                        DisableFTPCOntrols;
                        StatusPanel.Caption:='  Changing directory';
                        FTP1.ChangeDirectory(FTPView.Selected.Caption);
                end;
        end;
end;

procedure TMain.LocalViewDblClick(Sender: TObject);
begin
        if LocalView.Selected=nil then Exit;
        if LocalView.Selected.ImageIndex=0 then {it is a directory}
        begin
                SetCurrentDir(LocalView.Selected.Caption);
                UpdateLocalListing;
        end;
end;

procedure TMain.DriveComboBox1Change(Sender: TObject);
var
        s: string;
        b: byte;
begin
        b:=DriveComboBox1.ItemIndex+1;
        GetDir(b,s);
        SetCurrentDir(s);
        UpdateLocalListing;
end;

procedure TMain.FTPPathChange(Sender: TObject);
var
        newpath: string;
        i: integer;
begin
        if BusyFTP then Exit;
        newpath:='';
        for i:=1 to FTPPath.ItemIndex do newpath:=newpath+'/'+FTPPath.Items[i];
        if newpath='' then newpath:='/';
        DisableFTPCOntrols;
        StatusPanel.Caption:='  Changing directory';
        FTP1.ChangeDirectory(newpath);
end;

procedure TMain.LocalPathChange(Sender: TObject);
var
        newpath: string;
        i: integer;
begin
        newpath:=LocalPath.Items[0]+'\';
        for i:=1 to LocalPath.ItemIndex do newpath:=newpath+LocalPath.Items[i]+'\';
        SetCurrentDir(newpath);
        UpdatelocalListing;
end;

{
        Routines to Enable and Disable FTP Controls when an action is occuring
        for programming ease, all controls which are related to FTP have a Tag of 16
}
procedure TMain.EnableFTPControls;
var
        i: integer;
begin
        BusyFTP:=False;
        for i:=0 to ComponentCount-1 do
        begin
                if Components[i].tag=16 then (Components[i] as TControl).Cursor:=crDefault;
        end;
        StatusPanel.Caption:='  Ready';
        FTPPath.Enabled:=True;
end;

procedure TMain.DisableFTPCOntrols;
var
        i: integer;
begin
        BusyFTP:=True;
        for i:=0 to ComponentCount-1 do
        begin
                if Components[i].tag=16 then (Components[i] as TControl).Cursor:=crHourglass;
        end;
        FTPPath.Enabled:=false;
end;

procedure TMain.Button2Click(Sender: TObject);
var
        r: TFTPServerInfo;
        f: file;
begin
        AssignFile(f,ExtractFilePath(Application.ExeName)+'\servers.dat');
        Rewrite(f,Sizeof(TFTPServerInfo));
        r.name:='StarTech Computer Services';
        r.server:='www.neosoft.com';
        r.port:=21;
        r.user:='startech';
        r.password:='at93lo';
        r.Description:='files from StarTech Web Site (http://www.neosoft.com/~startech';
        r.InitialDir:='';
        r.Account:='';
        r.SavePassword:=True;
        r.Anonymous:=False;
        BlockWrite(f,r,1);
        CloseFile(f);
end;

procedure TMain.PopupMenu1Popup(Sender: TObject);
begin
        if ActiveControl=FTPView then
        begin
                if InServersView then
                begin
                        Details1.Enabled:=False;
                        Folder1.Enabled:=False;
                        Server1.Enabled:=True;
                end
                else
                begin
                        Details1.Enabled:=True;
                        Folder1.Enabled:=True;
                        Server1.Enabled:=False;
                        if BusyFTP then
                        begin
                                Delete1.Enabled:=False;
                        end
                        else
                        begin
                                Delete1.Enabled:=True;
                        end;
                end;
        end;
        if ActiveControl=LocalView then
        begin
                Details1.Enabled:=True;
                Folder1.Enabled:=True;
                Server1.Enabled:=False;
                Delete1.Enabled:=True;
        end;
end;

{
        View Menu
}
procedure TMain.LargeIcons1Click(Sender: TObject);
begin
        if ActiveControl=FTPView then FTPView.ViewStyle:=vsIcon;
        if ActiveControl=LocalView then LocalView.ViewStyle:=vsIcon;
end;

procedure TMain.SmallIcons1Click(Sender: TObject);
begin
        if ActiveControl=FTPView then FTPView.ViewStyle:=vsSmallIcon;
        if ActiveControl=LocalView then LocalView.ViewStyle:=vsSmallIcon;
end;

procedure TMain.List1Click(Sender: TObject);
begin
        if ActiveControl=FTPView then FTPView.ViewStyle:=vsList;
        if ActiveControl=LocalView then LocalView.ViewStyle:=vsList;
end;

procedure TMain.Details1Click(Sender: TObject);
begin
        if ActiveControl=FTPView then FTPView.ViewStyle:=vsReport;
        if ActiveControl=LocalView then LocalView.ViewStyle:=vsReport;
end;

{
        LineUpIcons
}
procedure TMain.LineUpIcons1Click(Sender: TObject);
begin
        if ActiveControl=FTPView then FTPView.Arrange(arSnapToGrid);
        if ActiveControl=LocalView then LocalView.Arrange(arSnapToGrid);
end;

{
        Delete menu
}

procedure TMain.Delete1Click(Sender: TObject);
var
        i: integer;
        PathRemote,PathLocal: string;
begin
        if ActiveControl=FTPView then
        begin
                if InServersView then
                begin
                        for i:=0 to FTPView.Items.COunt-1 do
                        begin
                                if FTPView.Items[i].Selected then
                                begin
                                        DeleteFile(ExtractFilePath(Application.ExeName)+'\'+FTPView.Items[i].Caption+'.ftp');
                                end;
                        end;
                        LoadServersView;
                end
                else
                begin
                        {remove files and directories from server}
                        {we will store files to delete in SourceList, directories to delete
                         in SourceDirLis}
                        if BusyFTP then Exit;
                        if SourceDirList.Count>0 then SourceDirList.Clear;
                        if DestDirList.Count>0 then DestDirList.Clear;
                        if SourceList.Count>0 then SourceList.Clear;
                        if DestList.Count>0 then DestList.Clear;
                        PathRemote:=FTP1.InitialDirectory;
                        if PathRemote[Length(PathRemote)]<>'/' then PathRemote:=PathRemote+'/';
                        for i:=0 to FTPView.Items.Count-1 do
                        begin
                                if FTPView.Items[i].Selected then
                                begin
                                        if FTPView.Items[i].ImageIndex=0 then SourceDirList.Add(PathRemote+FTPView.Items[i].Caption)
                                        else SourceList.Add(PathRemote+FTPView.Items[i].Caption);
                                end;
                        end;
                        {delete first file or directory}

                        if SourceList.Count>0 then
                        begin
                                DisableFTPCOntrols;
                                StatusPanel.Caption:='Deleting file '+SourceList[0];
                                Ftp1.DeleteFile(SourceList[0]);
                                SourceList.Delete(0);
                                Exit;
                        end;
                        if SourceDirList.Count>0 then
                        begin
                                DisableFTPCOntrols;
                                StatusPanel.Caption:='Deleting directory '+SourceDirList[0];
                                Ftp1.DeleteDirectory(SourceDirList[0]);
                                SourceDirList.Delete(0);
                                Exit;
                        end;
                end;
        end;
        if ActiveControl=LocalView then
        begin
                if LocalView.Selected=nil then Exit;
                PathLocal:=GetCurrentDir;
                if PathLocal[Length(PathLocal)]<>'\' then PathLocal:=PathLocal+'\';
                {iterate through all files and directories selected}
                for i:=0 to LocalView.Items.Count-1 do
                begin
                        if LocalView.Items[i].Selected then
                        begin
                                if LocalView.Items[i].ImageIndex=0 then RemoveDir(PathLocal+LocalView.Items[i].Caption) {this is a directory}
                                else DeleteFile(PathLocal+LocalView.Items[i].Caption); {this is a file}
                        end;
                end;
                UpdateLocalListing;
        end;
end;

procedure TMain.SelectAll1Click(Sender: TObject);
var
        L: TListView;
        i: integer;
begin
        if (ActiveControl=LocalView) or (ActiveControl=FTPView) then
        begin
                L:=ActiveControl as TListView;
                for i:=0 to L.Items.Count-1 do
                begin
                        L.Items[i].Selected:=True;
                end;
        end;
end;

{
        Drag drop FTP to local view
}
procedure TMain.FTPViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
        if (Button=mbLeft) and not BusyFTP  then
        begin
                FTPView.BeginDrag(False);
        end;
end;


procedure TMain.LocalViewDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
        if ((Source as TComponent).Tag=16) and (not BusyFTP) then Accept:=True
        else Accept:=False;
end;

procedure TMain.LocalViewDragDrop(Sender, Source: TObject; X, Y: Integer);
var
        PathLocal,PathRemote: string;
        i: integer;
begin
        try
                Progress:=TProgress.Create(self);
                Progress.CancelProc:=Cancel;
                Progress.Show;
        except
                ;
        end;
        {build list of files and directories to transfer}
        if SourceDirList.Count>0 then SourceDirList.Clear;
        if DestDirList.Count>0 then DestDirList.Clear;
        if SourceList.Count>0 then SourceList.Clear;
        if DestList.Count>0 then DestList.Clear;
        PathRemote:=FTP1.InitialDirectory;
        if PathRemote[Length(PathRemote)]<>'/' then PathRemote:=PathRemote+'/';
        PathLocal:=GetCurrentDir;
        if PathLocal[Length(PathLocal)]<>'\' then PathLocal:=PathLocal+'\';
        for i:=0 to FTPView.Items.Count-1 do
        begin
                if FTPView.Items[i].Selected then
                begin
                        if FTPView.Items[i].ImageIndex=0 then {directory}
                        begin
                                SourceDirList.Add(PathRemote+FTPView.Items[i].Caption);
                                DestDirList.Add(PathLocal+FTPView.Items[i].Caption);
                        end
                        else
                        begin
                                SourceList.Add(PathRemote+FTPView.Items[i].Caption);
                                DestList.Add(PathLocal+FTPView.Items[i].Caption);
                        end;
                end;
        end;
        {transfer first file or Directory}
        if SourceList.Count>0 then
        begin
                DisableFTPControls;
                Ftp1.RemoteFile:=SourceList[0];
                SourceList.Delete(0);
                Ftp1.LocalFile:=DestList[0];
                DestList.Delete(0);
                StatusPanel.Caption:='  Starting transfer of '+ExtractFileName(Ftp1.LocalFile);
                Sending:=False;
                Ftp1.GetFile;
                Exit;
        end;
        {still here so transfer first directory}
        if SourceDirList.Count>0 then
        begin
                DisableFTPControls;
                ProcessRemoteDirectory(SourceDirList[0],DestDirList[0]);
                SourceDirList.Delete(0);
                DestDirList.Delete(0);
                Exit;
        end;
        {still here noting to do}
end;

{
        ProcessRemoteDirectory: changes to directory in parameter 1, create directory in parameter 2,
        gets listing
}
procedure TMain.ProcessRemoteDirectory(source,dest: string);
begin
        RecursingGet:=True;
        ForceDirectories(dest);
        SetCurrentDir(dest);
        UpdateLocalListing;
        Ftp1.ChangeDirectory(source);
end;

{
        ProcessRemoteListing:  adds directories to DirList and sets up files to transfers in SourceList,
        DestList and start transfer of first file for transfers from FTP to local
}
procedure TMain.ProcessRemoteListing;
var
        i: integer;
        PathLocal,PathRemote: string;
begin
        RecursingGet:=False;
        {Add files to get now and subdirectories to process later}
        PathRemote:=FTP1.InitialDirectory;
        if PathRemote[Length(PathRemote)]<>'/' then PathRemote:=PathRemote+'/';
        PathLocal:=GetCurrentDir;
        if PathLocal[Length(PathLocal)]<>'\' then PathLocal:=PathLocal+'\';
        for i:=0 to FTPView.Items.Count-1 do
        begin
                if FTPView.Items[i].ImageIndex=0 then {directory}
                begin
                        SourceDirList.Add(PathRemote+FTPView.Items[i].Caption);
                        DestDirList.Add(PathLocal+FTPView.Items[i].Caption);
                end
                else
                begin
                        SourceList.Add(PathRemote+FTPView.Items[i].Caption);
                        DestList.Add(PathLocal+FTPView.Items[i].Caption);
                end;
        end;
        {get first file}
        if SourceList.Count>0 then
        begin
                Ftp1.RemoteFile:=SourceList[0];
                SourceList.Delete(0);
                Ftp1.LocalFile:=DestList[0];
                DestList.Delete(0);
                StatusPanel.Caption:='  Starting transfer of '+ExtractFileName(Ftp1.LocalFile);
                Sending:=False;
                Ftp1.GetFile;
        end
        else Ftp1FileReceived(self); {a cheap way to process next directory}
end;

{
        Drag Drop routines- from local view to ftp view
}
procedure TMain.LocalViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
        if (Button=mbLeft) and (not BusyFTP) then
        begin
                LocalView.BeginDrag(False);
        end;
end;

procedure TMain.FTPViewDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
        if ((Source as TComponent).Tag=2) and (not InServersView) and not BusyFTP then Accept:=True
        else Accept:=False;
end;

procedure TMain.FTPViewDragDrop(Sender, Source: TObject; X, Y: Integer);
var
        i: integer;
        PathRemote,PathLocal: string;
begin
        if not Assigned(Progress) then
        begin
                try
                        Progress:=TProgress.Create(self);
                        Progress.CancelProc:=Cancel;
                        Progress.Show;
                except
                        Exit;
                end;
        end;
        {build list of files and directories to transfer}
        if SourceDirList.Count>0 then SourceDirList.Clear;
        if DestDirList.Count>0 then DestDirList.Clear;
        if SourceList.Count>0 then SourceList.Clear;
        if DestList.Count>0 then DestList.Clear;
        PathRemote:=FTP1.InitialDirectory;
        if PathRemote[Length(PathRemote)]<>'/' then PathRemote:=PathRemote+'/';
        PathLocal:=GetCurrentDir;
        if PathLocal[Length(PathLocal)]<>'\' then PathLocal:=PathLocal+'\';
        for i:=0 to LocalView.Items.Count-1 do
        begin
                if LocalView.Items[i].Selected then
                begin
                        if (LocalView.Items[i].ImageIndex=0) then {this is a directory}
                        begin
                                DestDirList.Add(PathRemote+LocalView.Items[i].Caption);
                                SourceDirList.Add(PathLocal+LocalView.Items[i].Caption);
                        end
                        else {this is a file}
                        begin
                                DestList.Add(PathRemote+LocalView.Items[i].Caption);
                                SourceList.Add(PathLocal+LocalView.Items[i].Caption);
                        end;
                end;
        end;
        {transfer first file}
        if SourceList.Count>0 then
        begin
                Ftp1.RemoteFile:=ValidUnixName(DestList[0]);
                DestList.Delete(0);
                Ftp1.LocalFile:=SourceList[0];
                SourceList.Delete(0);
                StatusPanel.Caption:='  Starting transfer of '+ExtractFileName(Ftp1.LocalFile);
                DisableFTPControls;
                Sending:=True;
                Ftp1.PutFile;
                Exit;
        end;
        {still here so transfer first directory}
        if SourceDirList.Count>0 then
        begin
                recdir:=SourceDirList[0];
                destdir:=DestDirList[0];
                SourceDirList.Delete(0);
                DestDirList.Delete(0);
                SetCurrentDir(recdir);
                UpdateLocalListing;
                RecursingPut:=True;
                StatusPanel.Caption:='  Creating directory';
                DisableFTPControls;
                Ftp1.CreateDirectory(ValidUnixName(destdir));
        end;
end;

procedure TMain.ProcessLocalListing;
var
        r: integer;
        f: TSearchRec;
        PathRemote,PathLocal: string;
begin
        RecursingPut:=False;
        PathRemote:=FTP1.InitialDirectory;
        if PathRemote[Length(PathRemote)]<>'/' then PathRemote:=PathRemote+'/';
        PathLocal:=GetCurrentDir;
        if PathLocal[Length(PathLocal)]<>'\' then PathLocal:=PathLocal+'\';
        {get listing of local directory}
        r:=FindFirst(recdir+'\*.*',faAnyFile,f);
        while r=0 do
        begin
                if ((f.Attr and faDirectory)<>0) then {subdirectories to get later}
                begin
                        if (f.Name[1]<>'.') then
                        begin
                                SourceDirList.Add(PathLocal+ExtractFileName(f.Name));
                                DestDirList.Add(PathRemote+ExtractFileName(f.Name));
                        end;
                end
                else
                begin {files to get now}
                        SourceList.Add(PathLocal+ExtractFileName(f.Name));
                        DestList.Add(PathRemote+ExtractFileName(f.Name));
                end;
                r:=FindNext(f);
        end;
        FindClose(f);
        if SourceList.Count>0 then
        begin
                Ftp1.LocalFile:=SourceList[0];
                SourceList.Delete(0);
                Ftp1.RemoteFile:=ValidUnixName(DestList[0]);
                DestList.Delete(0);
                StatusPanel.Caption:='  Starting transfer of '+ExtractFileName(Ftp1.LocalFile);
                Sending:=True;
                Ftp1.PutFile;
        end
        else {no more files, check for more directories}
        begin
                if SourceDirList.Count>0 then
                begin
                        recdir:=SourceDirList[0];
                        destdir:=DestDirList[0];
                        SourceDirList.Delete(0);
                        DestDirList.Delete(0);
                        SetCurrentDir(recdir);
                        UpdateLocalListing;
                        RecursingPut:=True;
                        Ftp1.CreateDirectory(ValidUnixName(destdir));
                end
                else FTp1.FTPRefresh;{all done}
        end;
end;

procedure TMain.Properties1Click(Sender: TObject);
var
        d: TServerPropertyForm;
        s: string;
        i: TIniFile;
begin
        if ActiveControl=FTPView then
        begin
                if InServersView then
                begin
                        if FTPView.Selected=nil then Exit;
                        try
                                d:=TServerPropertyForm.Create(self);
                                d.Update:=True;
                                s:=ExtractFilePath(Application.ExeName)+'\'+FTPView.Selected.Caption+'.ftp';
                                i:=TIniFile.Create(s);
                                d.NameEdt.Text:=FTPView.Selected.Caption;
                                d.NameEdt.ReadOnly:=True;
                                d.ServerEdt.Text:=i.ReadString('Server','server','');
                                d.PortEdt.Text:=IntToStr(i.ReadInteger('Server','port',21));
                                d.AnonymousCB.Checked:=i.ReadBool('User','anonymous',True);
                                d.UserEdt.Text:=i.readstring('User','user','anonymous');
                                d.PasswordEdt.Text:=i.readstring('User','password','');
                                d.AccountEdt.Text:=i.readstring('User','account','');
                                d.RemoteDirEdt.Text:=i.readstring('Directories','remote','');
                                d.LocalDirEdt.Text:=i.readstring('Directories','local','');
                                d.EMailEdt.Text:=i.readstring('User','email','joe@acme.com');
                                d.SavePasswordCB.Checked:=i.ReadBool('User','SavePassword',True);
                                i.Destroy;
                                if d.ShowModal=mrOk then LoadServersView;
                        finally
                                d.Free;
                        end;
                end
                else
                begin
                        {###ADD CODE FOR PROPERTY FTP}
                end;
        end;
        If ActiveCOntrol=LocalView then
        begin
                        {###ADD CODE FOR PROPERTY LOCAL}
        end;
end;

procedure TMain.Server1Click(Sender: TObject);
var
        d: TServerPropertyForm;
begin
        if not InServersView then Exit;
        try
                d:=TServerPropertyForm.Create(self);
                d.Update:=False;
                if d.ShowModal=mrOk then LoadServersView;
        finally
                d.Free;
        end;
end;

procedure TMain.LoadServersView;
var
        f: TSearchRec;
        r: integer;
        item: TListItem;
        s: string;
begin
        FTPView.Items.BeginUpdate;
        FTPView.Items.Clear;
        FTPView.SortType:=stNone;
        r:=FindFirst(ExtractFilePath(Application.ExeName)+'\*.ftp',faAnyFile,f);
        while r=0 do
        begin
                item:=FTPView.Items.Add;
                s:=ExtractFileName(f.Name);
                Delete(s,Pos('.ftp',s),999);
                item.Caption:=s;
                item.ImageIndex:=2;
                r:=FindNext(f);
        end;
        FindClose(f);
        FTPView.SortType:=stBoth;
        FTPView.Items.EndUpdate;
end;

procedure TMain.NewFolder1Click(Sender: TObject);
var
        NewDir: string;
        Path: string;
begin
        if (ActiveControl=FTPView) then
        begin
                if InputQuery('New Folder','Please enter the new folder name:',NewDir) then
                begin
                        StatusPanel.Caption:='  Creating directory '+NewDir;
                        DisableFTPControls;
                        Ftp1.CreateDirectory(ValidUnixName(NewDir));
                end;
        end;
        if (ActiveControl=LocalView) then
        begin
                begin
                        if InputQuery('New Folder','Please enter the new folder name:',NewDir) then
                        Path:=GetCurrentDir;
                        if Path[Length(Path)]<>'\' then Path:=Path+'\';
                        NewDir:=Path+NewDir;
                        CreateDirectory(PChar(NewDir),nil);
                        UpdateLocalListing;
                end;
        end;
end;


procedure TMain.QuitBtnClick(Sender: TObject);
begin
        if BusyFTP then Exit;
        DisableFTPCOntrols;
        FTP1.Quit;
end;

procedure TMain.SpeedButton1Click(Sender: TObject);
begin
        FTP1.StopTransfer;
end;

procedure TMain.FTPViewEdited(Sender: TObject; Item: TListItem;
  var S: string);
var
        dir: string;
begin
        If InServersView then
        begin
                dir:=ExtractFilePath(Application.ExeName);
                if dir[Length(dir)]<>'\' then dir:=dir+'\';
                RenameFile(dir+Item.Caption+'.ftp',dir+S+'.ftp');
                LoadServersView;
        end
        else
        begin
                StatusPanel.Caption:='  Renaming file';
                DisableFTPControls;
                FTP1.RenameFile(Item.Caption,S);
        end;
end;

procedure TMain.LocalViewEdited(Sender: TObject; Item: TListItem;
  var S: string);
var
        dir: string;
begin
        if Item=nil then Exit;
        if Item.Caption=S then Exit;
        dir:=GetCurrentDir;
        if dir[Length(dir)]<>'\' then dir:=dir+'\';
        RenameFile(dir+Item.Caption,dir+s);
        UpdateLocalListing;
end;


procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
        CanClose:=not BusyFTP;
        if BusyFTP then
        begin
                ShowMessage('Interrupt current transfer or wait for transfer to complete.');
        end;
end;

procedure TMain.Ftp1FtpNeedInfo(Sender: TObject; need: TFtpInfoNeeded;
  var value: string);
begin
        ;{add code for password}
end;

procedure TMain.FormResize(Sender: TObject);
begin
        if OldClientWidth>0 then
        begin
                LeftPanel.Width:=(OldWidth*ClientWidth) div OldCLientWidth;
        end;
        OldCLientWidth:=ClientWidth;
        OldWidth:=LeftPanel.Width;
        if OldClientHeight>0 then
        begin
                BottomPanel.Height:=(OldHeight*ClientHeight) div OldCLientHeight;
        end;
        OldCLientHeight:=ClientHeight;
        OldHeight:=BottomPanel.Height;
        FTPView.Arrange(arDefault);
        LocalView.Arrange(arDefault);
end;


procedure TMain.FTPViewCompare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
begin
        Compare:=Item1.ImageIndex-Item2.ImageIndex;
        if Compare<>0 then Exit;
        if Uppercase(Item1.Caption)<Uppercase(Item2.Caption) then
        begin
                Compare:=-1;
                Exit;
        end;
        if Uppercase(Item1.Caption)>Uppercase(Item2.Caption) then
        begin
                Compare:=1;
                Exit;
        end;
        Compare:=0;
end;

procedure TMain.LocalViewCompare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
begin
        Compare:=Item1.ImageIndex-Item2.ImageIndex;
        if Compare<>0 then Exit;
        if Uppercase(Item1.Caption)<Uppercase(Item2.Caption) then
        begin
                Compare:=-1;
                Exit;
        end;
        if Uppercase(Item1.Caption)>Uppercase(Item2.Caption) then
        begin
                Compare:=1;
                Exit;
        end;
        Compare:=0;
end;

procedure TMain.Cancel;
begin
        FTP1.StopTransfer;
end;



end.
