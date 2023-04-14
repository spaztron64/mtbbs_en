unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Menus, NMailBox, Attmgr, Starsock, Gnetmail,
  Buttons, Addrbook,MimeMgr;

const
        WM_APPINIT      =       WM_USER+1;

type TMainForm = class(TForm)
        MainMenu1: TMainMenu;
        File1: TMenuItem;
        Edit1: TMenuItem;
        Mailbox1: TMenuItem;
        Message1: TMenuItem;
        Transfer1: TMenuItem;
        Window1: TMenuItem;
        Help1: TMenuItem;
        Panel1: TPanel;
        Close1: TMenuItem;
        N1: TMenuItem;
        Save1: TMenuItem;
        SaveAs1: TMenuItem;
        N3: TMenuItem;
        Print1: TMenuItem;
        PrintSetup1: TMenuItem;
        N4: TMenuItem;
        Exit1: TMenuItem;
        AttachmentManager: TAttachmentManager;
        Mailbox: TNMailBox;
        New1: TMenuItem;
        N6: TMenuItem;
        Mail1: TMenuItem;
        CheckMail2: TMenuItem;
        NewMessage1: TMenuItem;
        Setup1: TMenuItem;
        GeneralSetup1: TMenuItem;
        Options1: TMenuItem;
        MIMESetup1: TMenuItem;
        Signature1: TMenuItem;
        AddressBook1: TMenuItem;
        About1: TMenuItem;
        DeleteBtn: TSpeedButton;
        SaveBtn: TSpeedButton;
        PrintBtn: TSpeedButton;
        PreviousBtn: TSpeedButton;
        NextBtn: TSpeedButton;
        FileBtn: TSpeedButton;
        NewBtn: TSpeedButton;
    Tile1: TMenuItem;
    Cascade1: TMenuItem;
    CloseAll1: TMenuItem;
    ArrangeIcons1: TMenuItem;
    Next1: TMenuItem;
    Previous1: TMenuItem;
    SystemTimer: TTimer;
    CheckMailBtn: TSpeedButton;
    SendQueuedBtn: TSpeedButton;
    ReplyBtn: TSpeedButton;
    ForwardBtn: TSpeedButton;
    RedirectBtn: TSpeedButton;
    Next2: TMenuItem;
    Previous2: TMenuItem;
    N2: TMenuItem;
    Reply1: TMenuItem;
    Forward1: TMenuItem;
    Redirect1: TMenuItem;
    AddressBook: TAddressBook;
        procedure Close1Click(Sender: TObject);
        procedure Setup1Click(Sender: TObject);
        procedure FormShow(Sender: TObject);
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure About1Click(Sender: TObject);
        procedure CheckMail2Click(Sender: TObject);
        procedure DeleteBtnClick(Sender: TObject);
        procedure SaveBtnClick(Sender: TObject);
        procedure PrintBtnClick(Sender: TObject);
        procedure PreviousBtnClick(Sender: TObject);
        procedure NextBtnClick(Sender: TObject);
        procedure FileBtnClick(Sender: TObject);
        procedure NewBtnClick(Sender: TObject);
        procedure Options1Click(Sender: TObject);
        procedure Signature1Click(Sender: TObject);
    procedure AddressBook1Click(Sender: TObject);
    procedure MIMESetup1Click(Sender: TObject);
    procedure Tile1Click(Sender: TObject);
    procedure Cascade1Click(Sender: TObject);
    procedure CloseAll1Click(Sender: TObject);
    procedure ArrangeIcons1Click(Sender: TObject);
    procedure Next1Click(Sender: TObject);
    procedure Previous1Click(Sender: TObject);
    procedure SystemTimerTimer(Sender: TObject);
    procedure ReplyBtnClick(Sender: TObject);
    procedure SendQueuedBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure DoFormActivate(Sender: TObject);
private
        TimeToCheckMail: LongInt;
        procedure WMAppInit(var Msg: TMsg);message WM_APPINIT;
        procedure MailboxMenuClick(Sender: TObject);
        procedure OpenMailbox(number: integer);
public
end;

var
        MainForm: TMainForm;
        UnreadBM,ReadBM,SentBM,AttachBM,QueuedBM: TBitmap;
        MimeAudioBM,MimeTextBM,MimeVideoBM,MimeApplicationBM: TBitmap;
        MimeMessageBM,MimeImageBM: TBitmap;
        MimeManager: TMimeManager;

implementation

{$R *.DFM}

{$IFDEF WIN32}
{$R XTRA32.RES}
{$ELSE}
{$R XTRA.RES}
{$ENDIF}

uses    SetupFrm {for TSetupForm},
        Global {global routines and variables},
        FlashFrm {for Flash},
        ChkMail {for TGetMailForm},
        MbxForm {for TMailboxForm},
        Viewmail {for TViewMailForm},
        NewMail {for TNewMessageForm},
        Print {for TPrintProgress},
        Options {for TOptionsForm},
        Signatur {for TSignatureForm},
        ABook {for TAddressBook},
        MimeEdit {for TMimeEditor},
        SndMail {for TSendMailForm},
        attdef,inetmail;

procedure TMainForm.FormShow(Sender: TObject);
begin
        {$IFDEF VER90}
        Caption:='StarMail-32 Light';
        {$ELSE}
        Caption:='StarMail Light';
        {$ENDIF}
        {Show form then initialize}
        PostMessage(Handle,WM_APPINIT,0,0);
end;

procedure TMainForm.WMAppInit(var Msg: TMsg);
var
        AppDirectory,s: string;
        i: integer;
        mt: TMenuItem;
        d: TFlash;
begin
        d:=TFlash.Create(self);
        d.ShowModal;
        MailboxList:=TStringList.Create;
        AppDirectory:=ExtractFilePath(Application.ExeName);
        LoadIniFile;
        Mailbox.Mailboxes.Assign(MailboxList);
        Mailbox.MailboxDirectory:=AppDirectory+'mailboxe';
        AddressBook.Directory:=AppDirectory;
        {set up Mailbox and Transfer Menus}
        for i:=0 to MailboxList.Count-1 do
        begin
                s:=MailboxList[i];
                mt:=TMenuItem.Create(self);
                mt.Caption:=Copy(s,Pos('=',s)+1,999);
                mt.Tag:=i+1;
                mt.OnClick:=MailboxMenuClick;
                Mailbox1.Add(mt);
                mt:=TMenuItem.Create(self);
                mt.Caption:=Copy(s,Pos('=',s)+1,999);
                mt.Tag:=i+1;
                Transfer1.Add(mt);
        end;
        {Load bitmaps from resource file}
        ReadBM:=TBitmap.Create;
        ReadBM.Handle:=LoadBitmap(HInstance,'MAIL_READ');
        UnreadBM:=TBitmap.Create;
        UnreadBM.Handle:=LoadBitmap(HInstance,'MAIL_UNREAD');
        SentBM:=TBitmap.Create;
        SentBM.Handle:=LoadBitmap(HInstance,'MAIL_SENT');
        AttachBM:=TBitmap.Create;
        AttachBM.Handle:=LoadBitmap(HInstance,'MAIL_ATTACHMENT');
        QueuedBM:=TBitmap.Create;
        QueuedBM.Handle:=LoadBitmap(HInstance,'MAIL_QUEUED');

        MimeAudioBM:=TBitmap.Create;
        MimeAudioBM.Handle:=LoadBitmap(HInstance,'MIME_AUDIO');
        MimeApplicationBM:=TBitmap.Create;
        MimeApplicationBM.Handle:=LoadBitmap(HInstance,'MIME_APPLICATION');
        MimeImageBM:=TBitmap.Create;
        MimeImageBM.Handle:=LoadBitmap(HInstance,'MIME_IMAGE');
        MimeMessageBM:=TBitmap.Create;
        MimeMessageBM.Handle:=LoadBitmap(HInstance,'MIME_MESSAGE');
        MimeTextBM:=TBitmap.Create;
        MimeTextBM.Handle:=LoadBitmap(HInstance,'MIME_TEXT');
        MimeVideoBM:=TBitmap.Create;
        MimeVideoBM.Handle:=LoadBitmap(HInstance,'MIME_VIDEO');
        {Initialize MimeManger}
        MimeManager:=TMimeManager.Create(AppDirectory+'mime.def');
        {Auto check Mail}
        TimeToCheckMail:=IniOptions.AutoCheckMinutes;
        if IniOptions.AutoCheckStart then CheckMail2Click(self);
end;

{shutdown}
procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
        i: integer;
begin
        Screen.Cursor:=crHourglass;
        {Empty Trash}
        MailBox.EmptyMailbox(TRASH_MAILBOX);
        {Compact Mailboxes}
        for i:=1 to Mailbox.Mailboxes.Count do
        begin
                Mailbox.CurrentMailboxNumber:=i;
                if Mailbox.CurrentNMailboxTrash>100000 then Mailbox.Compress;
        end;
        Screen.Cursor:=crDefault;
        SaveIniFile;
        MailboxList.Destroy;

        ReadBM.Destroy;
        UnreadBM.Destroy;
        SentBM.Destroy;
        AttachBM.Destroy;
        QueuedBM.Destroy;

        MimeAudioBM.Destroy;
        MimeApplicationBM.Destroy;
        MimeTextBM.Destroy;
        MimeVideoBM.Destroy;
        MimeMessageBM.Destroy;
        MimeImageBM.Destroy;

        MimeManager.Destroy;
end;

{Close active window}
procedure TMainForm.Close1Click(Sender: TObject);
begin
        if ActiveMDIChild<>nil then ActiveMDIChild.Close;
end;

{Bring up setup window}
procedure TMainForm.Setup1Click(Sender: TObject);
var
        d: TSetupForm;
begin
        try
                d:=TSetupForm.Create(self);
                d.NameEdt.Text:=IniInfo.UserName;
                d.UserEdt.Text:=IniInfo.UserID;
                d.SMTPServerEdt.Text:=IniInfo.SMTPServer;
                d.SMTPPortEdt.Text:=IntToStr(IniInfo.SMTPPort);
                d.POP3Server.Text:=IniInfo.POPServer;
                d.POP3Port.Text:=IntToStr(IniInfo.POPPort);
                d.POP3PasswordEdt.Text:=IniInfo.Password;
                if d.ShowModal=mrOk then
                begin
                        IniInfo.UserName:=d.NameEdt.Text;
                        IniInfo.UserID:=d.UserEdt.Text;
                        IniInfo.SMTPServer:=d.SMTPServerEdt.Text;
                        IniInfo.SMTPPort:=StrToInt(d.SMTPPortEdt.Text);
                        IniInfo.POPServer:=d.POP3Server.Text;
                        IniInfo.POPPort:=StrToInt(d.POP3Port.Text);
                        IniInfo.Password:=d.POP3PasswordEdt.Text;
                        SaveIniFile;
                end;
        finally
                d.Free;
        end;
end;

procedure TMainForm.About1Click(Sender: TObject);
var
        d: TFlash;
begin
        d:=TFlash.Create(self);
        d.ShowModal;
end;

procedure TMainForm.CheckMail2Click(Sender: TObject);
var
        d: TGetMailForm;
        i: integer;
begin
        try
                d:=TGetMailForm.Create(self);
                d.ShowModal;
                if d.NewMail then
                begin
                        OpenMailbox(IN_MAILBOX);
                        MessageBeep(Word(-1));
                        ShowMessage('You have new mail waiting.');
                end
                else
                begin
                        if (Sender is TMenuItem) or (Sender is TSpeedButton) then
                        begin
                                MessageBeep(Word(-1));
                                ShowMessage('Sorry, you have no new mail waiting.');
                        end;
                end;
        finally
                d.Free;
        end;
        TimeToCheckMail:=IniOptions.AutoCheckMinutes;
end;

procedure TMainForm.MailboxMenuClick(Sender: TObject);
var
        mbxNum: integer;
begin
        mbxNum:=(Sender as TMenuItem).Tag;
        OpenMailbox(mbxNum);
end;

procedure TMainForm.OpenMailbox(number: integer);
var
        i: integer;
        d: TMailboxForm;
begin
        {check for mailbox form already open}
        for i:=0 to MDIChildCount-1 do
        begin
                if MDIChildren[i] is TMailboxForm then
                begin
                        if (MDIChildren[i] as TMailboxForm).Viewer.MailboxNumber=number then
                        begin
                                (MDIChildren[i] as TMailboxForm).Show;
                                Exit;{found form, exit}
                        end;
                end;
        end;
        {still here, so did not find form}
        d:=TMailboxForm.Create(self);
        if (number=OUT_MAILBOX) or (number=PENDING_MAILBOX) then
        begin
                d.Viewer.SectionNames.Clear;
                d.Viewer.SectionNames.Add('Status');
                d.Viewer.SectionNames.Add('To');
                d.Viewer.SectionNames.Add('Date');
                d.Viewer.SectionNames.Add('Size');
                d.Viewer.SectionNames.Add('Subject');
                d.Viewer.DropEnabled:=False;
        end;
        d.Viewer.SetHeaderSize(2,150);
        d.Viewer.SetHeaderSize(3,150);
        d.Viewer.AttachmentBitmap:=AttachBM;
        case number of
        OUT_MAILBOX:
                begin
                        d.Viewer.ReadBitmap:=SentBM;
                        d.Viewer.UnreadBitmap:=SentBM;
                        d.Viewer.RepliedBitmap:=SentBM;
                end;
        PENDING_MAILBOX:
                begin
                        d.Viewer.ReadBitmap:=QueuedBM;
                        d.Viewer.UnreadBitmap:=QueuedBM;
                        d.Viewer.RepliedBitmap:=QueuedBM;
                end;
        else
                begin
                        d.Viewer.ReadBitmap:=ReadBM;
                        d.Viewer.UnreadBitmap:=UnreadBM;
                        d.Viewer.RepliedBitmap:=SentBM;
                end;
        end;
        d.Viewer.MailboxNumber:=number;
        d.Viewer.Mailbox:=Mailbox;
        d.Caption:=Mailbox.MailboxName(number);
end;

procedure TMainForm.DeleteBtnClick(Sender: TObject);
begin
        if ActiveMDIChild=nil then Exit;{just in case}
        if ActiveMDIChild is TMailboxForm then
                (ActiveMDIChild as TMailboxForm).DeleteItems;
        if ActiveMDIChild is TViewMailForm then
                (ActiveMDIChild as TViewMailForm).DeleteMessage;
end;

procedure TMainForm.SaveBtnClick(Sender: TObject);
var
        d: TSaveDialog;
begin
        if ActiveMDIChild=nil then Exit;
        if ActiveMDIChild is TViewMailForm then
        begin
                try
                        d:=TSaveDialog.Create(self);
                        d.Title:='Save Message Text';
                        d.Filter:='Text|*.txt';
                        if d.Execute then
                           (ActiveMDIChild as TViewMailForm).Memo.Lines.SaveToFile(d.Filename);
                finally
                        d.Free;
                end;
        end;
end;

procedure TMainForm.PrintBtnClick(Sender: TObject);
var
        d: TPrintDialog;
        p: TPrintProgress;
        DoPrint: Boolean;
begin
        if ActiveMDIChild=nil then Exit;
        if ActiveMDIChild is TViewMailForm then
        begin
                try
                        d:=TPrintDialog.Create(self);
                        DoPrint:=(d.Execute=True);
                finally
                        d.Free;
                end;
        end;
        if DoPrint then
        begin
                try
                        p:=TPrintProgress.Create(self);
                        p.Lines:=(ActiveMDIChild as TViewMailForm).Memo.Lines;
                        p.PrinterFont:=(ActiveMDIChild as TViewMailForm).Memo.Font;
                        p.ShowModal;
                finally
                        p.Free;
                end;
        end;
end;

procedure TMainForm.PreviousBtnClick(Sender: TObject);
var
        i,MessageNumber,MailboxNumber,index: integer;
        MBForm: TMailboxForm;
        MailViewer: TViewMailForm;
        Text: TStrings;
begin
        if ActiveMDIChild=nil then Exit;
        if not (ActiveMDIChild is TViewMailForm) then Exit;
        (ActiveMDIChild as TViewMailForm).PreviousMessage;
end;

procedure TMainForm.NextBtnClick(Sender: TObject);
var
        i,MessageNumber,MailboxNumber,index: integer;
        MBForm: TMailboxForm;
        MailViewer: TViewMailForm;
        Text: TStrings;
begin
        if ActiveMDIChild=nil then Exit;
        if not (ActiveMDIChild is TViewMailForm) then Exit;
        (ActiveMDIChild as TViewMailForm).NextMessage;
end;

procedure TMainForm.FileBtnClick(Sender: TObject);
begin
        if ActiveMDIChild=nil then Exit;{just in case}
        if ActiveMDIChild is TMailboxForm then
                (ActiveMDIChild as TMailboxForm).TransferItems;
        if ActiveMDIChild is TViewMailForm then
                (ActiveMDIChild as TViewMailForm).TransferMessage;
end;

procedure TMainForm.NewBtnClick(Sender: TObject);
var
        d: TNewMessageForm;
begin
        try
                d:=TNewMessageForm.Create(self);
        except
                {}
        end;
end;

procedure TMainForm.Options1Click(Sender: TObject);
var
        d: TOptionsForm;
begin
        try
                d:=TOptionsForm.Create(self);
                d.AutoAddAddress.Checked:=IniOptions.AutoAddAddress;
                d.FullHeaders.Checked:=IniOptions.FullHeaders;
                d.SaveSent.Checked:=IniOptions.SaveSent;
                d.AutoCheckStart.Checked:=IniOptions.AutoCheckStart;
                d.AutoCheckMail.Checked:=IniOptions.AutoCheckMail;
                d.MinutesEdt.Text:=IntToStr(IniOptions.AutoCheckMinutes);
                d.BrowserEdt.Text:=IniOptions.Browser;
                if d.ShowModal=mrOk then
                begin
                        IniOptions.AutoAddAddress:=d.AutoAddAddress.Checked;
                        IniOptions.FullHeaders:=d.FullHeaders.Checked;
                        IniOptions.SaveSent:=d.SaveSent.Checked;
                        IniOptions.AutoCheckMail:=d.AutoCheckMail.Checked;
                        IniOptions.AutoCheckStart:=d.AutoCheckStart.Checked;
                        IniOptions.AutoCheckMinutes:=StrToInt(d.MinutesEdt.Text);
                        IniOptions.Browser:=d.BrowserEdt.Text;
                end;
        finally
                d.Free;
        end;
end;

procedure TMainForm.Signature1Click(Sender: TObject);
var
        d: TSignatureForm;
        s: TStrings;
        AppDirectory: string;
begin
        try
                s:=TStringList.Create;
        except
                Exit;
        end;
        AppDirectory:=ExtractFilePath(Application.ExeName);
        try
                s.LoadFromFile(AppDirectory+'signatur.def');
        except
                {}
        end;
        try
                d:=TSignatureForm.Create(self);
                d.UseSignature.Checked:=IniOptions.UseSignature;
                if s.Count=0 then d.UseSignature.Checked:=False
                else d.Memo1.Lines.Assign(s);
                if d.ShowModal=mrOk then
                begin
                        if d.Memo1.Lines.Count=0 then IniOptions.UseSignature:=False
                        else IniOptions.UseSignature:=d.UseSignature.Checked;
                        d.Memo1.Lines.SaveToFile(AppDirectory+'signatur.def');
                end;
        finally
                d.Free;
        end;
        s.Destroy;
end;

procedure TMainForm.AddressBook1Click(Sender: TObject);
var
        d: TAddressBook;
        i: integer;
begin
        for i:=0 to MDiChildCount-1 do
        if MDIChildren[i] is TAddressBook then
        begin
                (MDIChildren[i] as TAddressBook).Show;
                Exit;
        end;
        try
                d:=TAddressBook.Create(self);
        except
                {}
        end;
end;

procedure TMainForm.MIMESetup1Click(Sender: TObject);
var
        d: TMimeEditor;
begin
        try
                d:=TMimeEditor.Create(self);
                d.ShowModal;
        finally
                d.Free;
        end;
end;

procedure TMainForm.Tile1Click(Sender: TObject);
begin
        Tile;
end;

procedure TMainForm.Cascade1Click(Sender: TObject);
begin
        Cascade;
end;

procedure TMainForm.CloseAll1Click(Sender: TObject);
var
        i: integer;
begin
        for i:=0 to MDIChildCount-1 do MDIChildren[i].Close;
end;

procedure TMainForm.ArrangeIcons1Click(Sender: TObject);
begin
        ArrangeIcons;
end;

procedure TMainForm.Next1Click(Sender: TObject);
begin
        Next;
end;

procedure TMainForm.Previous1Click(Sender: TObject);
begin
        Previous;
end;

procedure TMainForm.SystemTimerTimer(Sender: TObject);
begin
        Dec(TimeToCheckMail);
        if TimeToCheckMail<=0 then
        begin
                TimeToCheckMail:=999999;
                CheckMail2Click(self);
        end;
end;

procedure TMainForm.ReplyBtnClick(Sender: TObject);
begin
        if not (ActiveMDIChild is TViewMailForm) then Exit;
        (ActiveMDIChild as TViewMailForm).Reply;
end;

procedure TMainForm.SendQueuedBtnClick(Sender: TObject);
var
        i: integer;
        d: TSendMailForm;
        Headers: TStrings;
        Address,PName,s: string;
        mAtt: TMimeAttachment;
        sAtt: TSendMailAttachment;
begin
        Mailbox.CurrentMailboxNumber:=PENDING_MAILBOX;
        while Mailbox.CurrentMailboxMessages>0 do
        begin
                try
                        Mailbox.Msg_Number:=1;
                        Mailbox.LoadMail;
                        d:=TSendMailForm.Create(self);
                        d.SendMail1.FROM_Address:=IniInfo.UserID+'@'+IniInfo.POPServer;
                        d.SendMail1.FROM_Name:=IniInfo.UserName;
                        d.SendMail1.Headers.Add('X-Mailer: StarMail Light Version 0.1');
                        Headers:=TStringList.Create;
                        while (Mailbox.Msg_Text.Count>0) and (Mailbox.Msg_Text[0]<>'') do
                        begin
                                Headers.Add(Mailbox.Msg_Text[0]);
                                Mailbox.Msg_Text.Delete(0);
                        end;
                        Mailbox.Msg_Text.Delete(0);
                        d.SendMail1.MailText.Assign(Mailbox.Msg_Text);
                        d.SendMail1.Subject:=Mailbox.Msg_Subject;
                        for i:=0 to Headers.Count-1 do
                        begin
                                s:=Headers[i];
                                if Copy(s,1,4)='To: ' then
                                begin
                                        Delete(s,1,4);
                                        ExtractAddress(s,Address,PName);
                                        d.SendMail1.ListTo.Add(Address+'|'+PName);
                                end;
                                if Copy(s,1,4)='cc: ' then
                                begin
                                        Delete(s,1,4);
                                        ExtractAddress(s,Address,PName);
                                        d.SendMail1.Listcc.Add(Address+'|'+PName);
                                end;
                                if Copy(s,1,5)='Bcc: ' then
                                begin
                                        Delete(s,1,5);
                                        ExtractAddress(s,Address,PName);
                                        d.SendMail1.ListBcc.Add(Address+'|'+PName);
                                end;
                        end;
                        Headers.Destroy;
                        d.SendMail1.ClearAttachments;
                        for i:=Mailbox.Msg_AttachStart to Mailbox.Msg_AttachEnd do
                        begin
                                try
                                        mAtt:=AttachmentManager.Retrieve(i);
                                        sAtt.Location:=mAtt.Location;
                                        sAtt.MimeType:=mAtt.MimeType;
                                        sAtt.MimeDescription:=mAtt.Description;
                                        sAtt.Name:=mAtt.Name;
                                        sAtt.MimeDisposition:='attachment';
                                        d.SendMail1.AddAttachment(sAtt);
                                except
                                        ;
                                end;
                        end;
                        if d.ShowModal=mrOK then
                        begin
                                {move message to sent mailbox}
                                Mailbox.TransferTo(Mailbox.MailboxFile(OUT_MAILBOX));
                        end
                        else Exit;
                except
                        Exit;
                end;
                Mailbox.CurrentMailboxNumber:=PENDING_MAILBOX;
        end;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
        DeleteBtn.Enabled:=(Sender is TMailboxForm) or (Sender is TViewMailForm);
        SaveBtn.Enabled:=(Sender is TViewMailForm);
        PrintBtn.Enabled:=(Sender is TViewMailForm);
        PreviousBtn.Enabled:=(Sender is TViewMailForm);
        NextBtn.Enabled:=(Sender is TViewMailForm);
        FileBtn.Enabled:=(Sender is TMailboxForm) or (Sender is TViewMailForm);
        ReplyBtn.Enabled:=(Sender is TViewMailForm);
        ForwardBtn.Enabled:=(Sender is TViewMailForm);
        RedirectBtn.Enabled:=(Sender is TViewMailForm);
end;

procedure TMainForm.DoFormActivate(Sender: TObject);
begin
        DeleteBtn.Enabled:=(ActiveMDIChild is TMailboxForm) or (ActiveMDIChild is TViewMailForm);
        SaveBtn.Enabled:=(ActiveMDIChild is TViewMailForm);
        PrintBtn.Enabled:=(ActiveMDIChild is TViewMailForm);
        PreviousBtn.Enabled:=(ActiveMDIChild is TViewMailForm);
        NextBtn.Enabled:=(ActiveMDIChild is TViewMailForm);
        FileBtn.Enabled:=(ActiveMDIChild is TMailboxForm)or (ActiveMDIChild is TViewMailForm);
        ReplyBtn.Enabled:=(ActiveMDIChild is TViewMailForm);
        ForwardBtn.Enabled:=(ActiveMDIChild is TViewMailForm);
        RedirectBtn.Enabled:=(ActiveMDIChild is TViewMailForm);
end;

end.
