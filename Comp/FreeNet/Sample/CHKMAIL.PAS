unit Chkmail;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Starsock, Gnetmail;

const
        WM_GETMAIL      =       WM_USER+1;

type
  TGetMailForm = class(TForm)
    Status: TLabel;
    StatusBk: TPanel;
    StatusBar: TPanel;
    Stop: TButton;
    MessagesLeft: TLabel;
    GetMail1: GetMail;
    Subject: TLabel;
    procedure FormShow(Sender: TObject);
    procedure GetMail1MailInfo(Sender: TObject; info: GetMailInfo;
      addinfo: String);
    procedure GetMail1MessageLoaded(Sender: TObject);
    procedure GetMail1AttachmentGetLocation(Sender: TObject;
      Attachment: TMIMEAttachmentPtr);
    procedure GetMail1HeadersLoaded(Sender: TObject);
    procedure GetMail1AttachmentStored(Sender: TObject;
      Attachment: TMIMEAttachmentPtr);
    procedure StopClick(Sender: TObject);
    procedure GetMail1Done(Sender: TObject);
    procedure GetMail1MailError(Sender: TObject; error: GetMailError;
      addinfo: string);
  private
        UIDLSupported: Boolean;
        UIDLManager: TUIDLManager;
        NumMessages: Integer;
        todo,done: LongInt;
        StartAtt,EndAtt,CurrentAttachment: LongInt;
        procedure WMGetMail(var Msg:TMsg);message WM_GETMAIL;
        procedure AddToAddressBook(FromLine: string);
  public
        NewMail: Boolean;
  end;

implementation

{$R *.DFM}
uses Main,Global,AttDef,AddrBook;

procedure TGetMailForm.FormShow(Sender: TObject);
begin
        AppDirectory:=ExtractFilePath(Application.ExeName);
        try
                GetMail1.UIDLList.LoadFromFile(AppDirectory+'uidl.lst');
        except
                ;
        end;
        Status.Caption:='Connecting to '+IniInfo.POPServer;
        {Show Form before starting to get mail}
        PostMessage(Handle,WM_GETMAIL,0,0);
end;

procedure TGetMailForm.WMGetMail(var Msg: TMsg);
begin
        NewMail:=False;
        UIDLSupported:=True;
        with GetMail1 do
        begin
                Mail_Server:=IniInfo.POPServer;
                Mail_Port:=IniInfo.POPPort;
                User_ID:=IniInfo.UserID;
                User_Password:=IniInfo.Password;
                Opt_Preview:=True;{change depends on leave mail on server option}
                Mail_Action:=Get_Mail;
        end;
end;

procedure TGetMailForm.GetMail1MailInfo(Sender: TObject; info: GetMailInfo;
  addinfo: String);
var
        bw: LongInt;
begin
        case info of
        gmResolvingAddress: Status.Caption:='Resolving '+addinfo;
        gmAddressResolved: Status.Caption:='Connected to '+addinfo;
        gmUIDLSupport:
                begin
                        GetMail1.Opt_Preview:=(addinfo='0');{if UIDL not supported then need to preview messages}
                        UIDLSupported:=(addinfo='1');
                        if not UIDLSupported then UIDLManager:=TUIDLManager.Create(AppDirectory+'uidl.lst');
                end;
        gmServerConnected: Status.Caption:='Connected to '+addinfo;
        gmServerDisconnected: Status.Caption:='Disconnected';
        gmAccessGranted: Status.Caption:='Logged in to server.';
        gmUIDLList: Status.Caption:='Getting message list';
        gmNumberMessage:
                begin
                        try
                                NumMessages:=StrToInt(addinfo);
                        except
                                NumMessages:=-1;
                        end;
                        if NumMessages>0 then
                          MessagesLeft.Caption:='Messages left: '+addinfo;
                end;
        gmLogin: Status.Caption:='Logging in';
        gmMessageSize:
                begin
                        StartAtt:=0;
                        EndAtt:=0;
                        if not GetMail1.Opt_Preview then Status.Caption:='Getting Message';
                        StatusBar.Width:=0;
                        try
                                todo:=StrToInt(addinfo);
                        except
                                todo:=0;
                        end;
                end;
        gmGettingMessage:
                begin
                        Subject.Caption:=GetMail1.Msg_Subject;
                        try
                                done:=StrToInt(addinfo);
                                if todo>0 then
                                begin
                                        bw:=(done*StatusBk.Width) div todo;
                                        StatusBar.Width:=bw;
                                end;
                        except
                                ;
                        end;
                end;
        end;
end;

procedure TGetMailForm.GetMail1MessageLoaded(Sender: TObject);
begin
        NewMail:=True;
        StatusBar.Width:=StatusBk.Width;
        with MainForm.Mailbox do
        begin
                CurrentMailboxNumber:=IN_MAILBOX;
                Msg_Flag:='U';
                Msg_Subject:=GetMail1.Msg_Subject;
                Msg_From:=GetMail1.Msg_From;
                Msg_To:=GetMail1.Msg_To;
                Msg_Date:=GetMail1.Msg_Date;
                Msg_Size:=GetMail1.Msg_Size;
                Msg_Text.Assign(GetMail1.Mail_Text);
                Msg_AttachStart:=StartAtt;
                Msg_AttachEnd:=EndAtt;
                AddMail;
        end;
        GetMail1.Opt_Delete:=False;
        {Auto Add address to address book}
        if IniOptions.AutoAddAddress then AddToAddressBook(GetMail1.Msg_From);
        {Post message cleanup}
        Dec(NumMessages);
        if NumMessages>0 then MessagesLeft.Caption:='Messages left: '+IntToStr(NumMessages)
        else MessagesLeft.Caption:='';
        Subject.Caption:='';
end;

procedure TGetMailForm.AddToAddressBook(FromLine: string);
var
        name,fname,lname,address: string;
        a: TAddressBookEntry;
        i: integer;
begin
        address:='';
        fname:='';
        lname:='';
        ExtractAddress(FromLine,Address,Name);
        fname:=Copy(name,1,Pos(' ',name)-1);
        lname:=Copy(name,Pos(' ',name)+1,999);
        if (fname<>'') and (lname<>'') and (address<>'') then
        begin
                {Handle Middle Name}
                if Pos(' ',lname)<>0 then
                begin
                        i:=Pos(' ',lname);
                        if (i=3) and (lname[2]='.') then
                        begin
                                fname:=fname+' '+Copy(lname,1,2);
                                Delete(lname,1,3);
                        end;
                        if (i=2) then
                        begin
                                fname:=fname+' '+lname[1];
                                Delete(lname,1,2);
                        end;
                end;
                if MainForm.AddressBook.FindEntry (fname,lname,address)=0 then
                begin
                        a.FirstName:=fname;
                        a.LastName:=lname;
                        a.HomeMail:=address;
                        a.WorkMail:='';
                        a.Organization:='';
                        a.NickName:='';
                        MainForm.AddressBook.AddEntry(a);
                end;
        end;
end;

procedure TGetMailForm.GetMail1AttachmentGetLocation(Sender: TObject;
  Attachment: TMIMEAttachmentPtr);
begin
        CurrentAttachment:=MainForm.AttachmentManager.NewAttachment(Attachment^);
        if StartAtt=0 then StartAtt:=CurrentAttachment;
        EndAtt:=CurrentAttachment;
end;

procedure TGetMailForm.GetMail1HeadersLoaded(Sender: TObject);
begin
        GetMail1.Opt_Skip:=not UIDLManager.ProcessMessageID(GetMail1.Msg_UIDL);
        if GetMail1.Opt_Skip then
        begin
                Dec(NumMessages);
                if NumMessages>0 then MessagesLeft.Caption:='Messages left: '+IntToStr(NumMessages)
                else MessagesLeft.Caption:='';
                Subject.Caption:='';
                Status.Caption:='Skipping previously retrieved messages';
        end
        else Status.Caption:='Getting Message';
end;

procedure TGetMailForm.GetMail1AttachmentStored(Sender: TObject;
  Attachment: TMIMEAttachmentPtr);
begin
        MainForm.AttachmentManager.Update(CurrentAttachment,Attachment^);
end;

procedure TGetMailForm.StopClick(Sender: TObject);
begin
        GetMail1.QuitAsap;
        if not UIDLSupported then UIDLManager.Error;
end;

procedure TGetMailForm.GetMail1Done(Sender: TObject);
begin
        if not UIDLSupported then UIDLManager.Destroy
        else GetMail1.UIDLList.SaveToFile(AppDirectory+'uidl.lst');
        if GetMail1.Success then ModalResult:=mrOK
        else ModalResult:=mrCancel;
end;

procedure TGetMailForm.GetMail1MailError(Sender: TObject;
  error: GetMailError; addinfo: string);
begin
       case error of
       gmWInsockNotInitialized: Application.MessageBox('The winsock interface could not be '+
                'initialized. Make sure that winsock is installed on your system.',
                'Winsock Error',MB_OK+MB_ICONSTOP);
       gmNetworkUnreachable,gmAddressNotAvailable,gmHostUnreachable,gmNetworkDown: Application.MessageBox('The network is '+
                'down. Make sure that you have established a connection to the network.',
                'Network Down Error',MB_OK+MB_ICONSTOP);
       gmInvalidAddress,gmAddressResolutionError: Application.MessageBox('StarMail could not find your POP3 mail server. '+
                'Check that you are connected to your service provider and '+
                'that your setup information is correct.','Name Resolution Error',MB_OK+MB_ICONSTOP);
       gmInternalError,gmGeneralWinsockError,gmUnknown: Application.MessageBox('An unexpected error occured',
                'Unexpected Error',MB_OK+MB_ICONSTOP);
       gmPrematureDisconnect,gmConnAborted,gmConnReset: Application.MessageBox('The connection was unexpectedly closed by the'+
                ' remote server','Premature Disconnect Error',MB_OK+MB_ICONSTOP);
       gmConnectTimeOut: Application.MessageBox('The connection attempt to the server timed out.','Connect Timeout Error',
                MB_OK+MB_ICONSTOP);
       gmOutofSockets: Application.MessageBox('The winsock is out of sockets. Close a winsock application before trying '+
                'again.','Out of Sockets Error',MB_OK+MB_ICONSTOP);
       gmConnectionRefused: Application.MessageBox('The mail server refused the connection. Make sure that you have '+
                'entered the correct value in setup for your POP3 server.','Connection Rejected Error',MB_OK+MB_ICONSTOP);
       gmProtocolError: Application.MessageBox('An unexpected response was received from the mail server. Make sure that you '+
                'have entered the correct value in setup for your POP3 port.','Unexpected Response Error',MB_OK+MB_ICONSTOP);
       gmCanceled:Application.MessageBox('The sending of mail was canceled.','Transaction Canceled',MB_OK+MB_ICONSTOP);
       gmAccessDenied: Application.MessageBox('The server rejected the login either because the user ID or password you '+
                'specified is incorrect, or your account is being accessed by another program.','Access Denied Error',
                MB_OK+MB_ICONSTOP);
       end;
end;

end.
