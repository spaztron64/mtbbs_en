unit Viewmail;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Strngvwr, Buttons,NMailbox;

type TViewMailForm = class(TForm)
        Panel2: TPanel;
        Label1: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        From: TLabel;
        Date: TLabel;
        Subject: TLabel;
        Memo: TStringsViewer;
        AttachmentPanel: TPanel;
        Panel1: TPanel;
        AttachList: TListBox;
        Panel3: TPanel;
        ViewBtn: TBitBtn;
        SaveBtn: TBitBtn;
        procedure FormClose(Sender: TObject; var Action: TCloseAction);
        procedure FormActivate(Sender: TObject);
        procedure AttachListDrawItem(Control: TWinControl; Index: Integer;
          R: TRect; State: TOwnerDrawState);
        procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y: Integer);
        procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
          Shift: TShiftState; X, Y: Integer);
        procedure ViewBtnClick(Sender: TObject);
        procedure MemoLink(Sender: TObject; link: String);
    procedure FormShow(Sender: TObject);
public
        procedure NextMessage;
        procedure PreviousMessage;
        procedure Reply;
        procedure DeleteMessage;
        procedure TransferMessage;
private
        StartY: integer;
        Resizing: Boolean;
        MailboxNumber,MessageNumber: integer;
        ParentViewer: NMailboxViewer;
        procedure MBVSetMessage(var Msg: TMessage); message MBV_SETMESSAGE;
        procedure MBVParent(var Msg: TMessage); message MBV_PARENT;
        procedure MBVClose(var Msg: TMessage);message MBV_CLOSE;
        procedure MBVUpdateInfo(var Msg: TMessage);message MBV_UPDATEINFO;
end;

implementation

{$R *.DFM}

uses Main,AttDef,MimeMgr,MimeExec,Global,NewMail,Transfer;

procedure TViewMailForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
        Action:=caFree;
end;

procedure TViewMailForm.FormActivate(Sender: TObject);
begin
        Mainform.FormActivate(self);
end;

procedure TViewMailForm.AttachListDrawItem(Control: TWinControl;
  Index: Integer; R: TRect; State: TOwnerDrawState);
var
        A: TMIMEAttachment;
        s,t: string;
        i: integer;
begin
        i:=StrToInt((Control as TListBox).Items[Index]);
        try
                A:=MainForm.AttachmentManager.Retrieve(i);
                s:='';
                if A.Size<1024 then s:=IntToStr(A.Size);
                if (A.Size>1023) and (A.Size<1048576) then s:=IntToStr(A.Size div 1024)+'K';
                if A.Size>= 1048576 then s:=IntToStr(A.Size div 1048576)+'M';
                with AttachList.Canvas do
                begin
                        FillRect(R);
                        t:=A.MimeType;
                        t:=Copy(t,1,Pos('/',t)-1);
                        if t='image' then  Draw(R.Left+2,R.Top+8,MimeImageBM);
                        if t='application' then  Draw(R.Left+2,R.Top+8,MimeApplicationBM);
                        if t='audio' then  Draw(R.Left+2,R.Top+8,MimeAudioBM);
                        if t='video' then  Draw(R.Left+2,R.Top+8,MimeVideoBM);
                        if t='text' then  Draw(R.Left+2,R.Top+8,MimeTextBM);
                        if t='message' then  Draw(R.Left+2,R.Top+8,MimeMessageBM);
                        if A.Name<>'' then TextRect(Rect(R.Left+25,R.Top,R.Left+240,R.Top+15),R.Left+25,R.Top,'Name: '+A.Name)
                        else TextRect(Rect(R.Left+25,R.Top,R.Left+240,R.Top+15),R.Left+25,R.Top,'Name: <none>');
                        TextRect(Rect(R.Left+250,R.Top,R.Left+310,R.Top+15),R.Left+250,R.Top,'Size: '+s);
                        if A.MimeType<>'' then TextRect(Rect(R.Left+325,R.Top,R.Right,R.Top+15),R.Left+325,R.Top,'Type: '+
                           A.MimeType)
                        else TextRect(Rect(R.Left+325,R.Top,R.Right,R.Top+15),R.Left+325,R.Top,'Type: <none>');
                        if A.Description<>'' then TextRect(Rect(R.Left+25,R.Top+16,R.Right,R.Top+31),R.Left+25,R.Top+16,
                           'Description: '+A.Description)
                        else TextRect(Rect(R.Left+25,R.Top+16,R.Right,R.Top+31),R.Left+25,R.Top+16,'Description: <none>');
                        MoveTo(R.Left,R.Top+32);
                        LineTo(R.Right,R.Top+32);
                end;
        except
                ;
        end;
end;

procedure TViewMailForm.Panel1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
        StartY:=Y;
end;

procedure TViewMailForm.Panel1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
        AttachmentPanel.Height:=AttachmentPanel.Height+StartY-Y;
        if AttachmentPanel.Height<Panel1.Height then
           AttachmentPanel.Height:=Panel1.Height;
end;

procedure TViewMailForm.ViewBtnClick(Sender: TObject);
var
        Att: TMimeAttachment;
        i: LongInt;
        tmpfile: string;
        s,t: string;
        d: TMimeLaunchForm;
begin
        if AttachList.ItemIndex=-1 then Exit;
        i:=StrToInt(AttachList.Items[AttachList.ItemIndex]);
        if i=0 then Exit;
        Att:=MainForm.AttachmentManager.Retrieve(i);
        case MimeManager.GetAction(Att.MimeType) of
        maPrompt:
                begin
                        s:=MimeManager.SuggestApplication(Att.Name);
                        try
                                d:=TMimeLaunchForm.Create(self);
                                d.ApplicationEdt.Text:=s;
                                t:='No application has been defined for MIME type '+Att.MimeType+'.';
                                if s<>'' then t:=t+' It is suggested that you use the application below to view '+
                                  'this document. You may change this by pressing the Change button.'
                                else t:=t+' Please press the Change button to select a viewer application for '+
                                   'this MIME type';
                                d.Prompt.Caption:=t;
                                if d.ShowModal=mrOk then
                                begin
                                        MimeManager.RegisterApplication(Att.MimeType,d.ApplicationEdt.Text);
                                        tmpfile:=MainForm.AttachmentManager.GetTempFile(i,
                                           MimeManager.GetDefaultExtension(Att.MimeType));
                                        if not MimeManager.Launch(tmpfile,Att.MimeType) then
                                           ShowMessage('An error occured while launching the viewer application.');
                                end;
                        finally
                                d.Free;
                        end;
                end;
        maLaunch:
                begin
                        tmpfile:=MainForm.AttachmentManager.GetTempFile(i,MimeManager.GetDefaultExtension(Att.MimeType));
                        if not MimeManager.Launch(tmpfile,Att.MimeType) then
                           ShowMessage('An error occured while launching the viewer application.');
                end;
        maInternal: ;{not used in this program}
        end;
end;

procedure TViewMailForm.MemoLink(Sender: TObject; link: String);
var
        s: string;
begin
        if IniOptions.Browser<>'' then
        begin
                s:=IniOptions.Browser+' '+link+#0;
                WinExec(@s[1],SW_SHOW);
        end
        else ShowMessage('You have not configured a web browser. Use '+
           'the Setup|Options menu choice to configure one.');
end;

procedure TViewMailForm.MBVParent(var Msg: TMessage);
begin
        ParentViewer:=NMailboxViewer(Msg.lParam);
end;

procedure TViewMailForm.MBVClose(var Msg: TMessage);
begin
        Close;
end;

procedure TViewMailForm.MBVSetMessage(var Msg: TMessage);
var
        Text: TStrings;
        i: integer;
begin
        MailboxNumber:=Msg.wParam;
        MessageNumber:=Msg.lParam;
        with ParentViewer.Mailbox do
        begin
                CurrentMailBoxNumber:=MailboxNumber;
                Msg_Number:=MessageNumber;
                LoadMail;
                Subject.Caption:=Msg_Subject;
                Date.Caption:=Msg_Date;
                From.Caption:=Msg_From;
                if Msg_Flag='U' then UpdateFlag('V');
                Text:=TStringList.Create;
                Text.Assign(Msg_Text);
                {remove headers}
                if not IniOptions.FullHeaders then
                begin
                        while Text[0]<>'' do Text.Delete(0);
                        Text.Delete(0);
                end;
                Memo.Lines.Clear;
                Memo.Lines.Assign(Text);
                Text.Destroy;
                Caption:=Msg_Subject;
                if Msg_AttachStart=0 then AttachmentPanel.Visible:=False
                else
                begin
                        AttachmentPanel.Visible:=True;
                        AttachList.Clear;
                        for i:=Msg_AttachStart to Msg_AttachEnd do AttachList.Items.Add(IntToStr(i));
                end;
        end;
end;

procedure TViewMailForm.NextMessage;
begin
        ParentViewer.NextMessage(self.Handle);
end;

procedure TViewMailForm.PreviousMessage;
begin
        ParentViewer.PreviousMessage(self.Handle);
end;

procedure TViewMailForm.Reply;
var
        d: TNewMessageForm;
        i: integer;
        s,address,name,FromLine: string;
begin
        with ParentViewer.Mailbox do
        begin
                CurrentMailboxNumber:=MailboxNumber;
                Msg_Number:=MessageNumber;
                UpdateFlag('R');
        end;
        try
                d:=TNewMessageForm.Create(MainForm);
                {make subject}
                s:=Lowercase(Subject.Caption);
                if Copy(s,1,3)<>'re:' then s:='Re: '+Subject.Caption
                else s:=Subject.Caption;
                d.SubjectEdt.Text:=s;
                {make reply address}
                address:='';
                name:='';
                FromLine:=From.Caption;
                ExtractAddress(FromLine,address,name);
                if name<>'' then
                begin
                        d.ToList.Add(address+'|'+name);
                        d.ToEdt.Text:=name;
                end
                else
                begin
                        d.ToList.Add(address);
                        d.ToEdt.Text:=address;
                end;
                {finally quote the text}
                i:=0;
                while (i<100) and (i<Memo.Lines.Count) do
                begin
                        d.Memo1.Lines.BeginUpdate;
                        d.Memo1.Lines.Add('>'+Memo.Lines[i]);
                        d.Memo1.Lines.EndUpdate;
                        Inc(i);
                end;
        finally
                ;
        end;
end;

procedure TViewMailForm.DeleteMessage;
begin
        with ParentViewer.Mailbox do
        begin
                CurrentMailBoxNumber:=MailboxNumber;
                Msg_Number:=MessageNumber;
                TransferTo(MailboxFile(TRASH_MAILBOX));
        end;
end;

procedure TViewMailForm.TransferMessage;
var
        d: TTransferForm;
        i: integer;
begin
        try
                d:=TTransferForm.Create(self);
                for i:=1 to MainForm.Mailbox.Mailboxes.Count do
                begin
                        d.MailBoxes.Items.Add(MainForm.Mailbox.MailboxName(i));
                end;
                if d.ShowModal=mrOk then
                begin
                        with ParentViewer.Mailbox do
                        begin
                                CurrentMailBoxNumber:=MailboxNumber;
                                Msg_Number:=MessageNumber;
                                TransferTo(MailboxFile(d.Mailboxes.ItemIndex+1));
                        end;
                end;
        finally
                d.Free;
        end;
end;

procedure TViewMailForm.MBVUpdateInfo(var Msg: TMessage);
begin
        MailboxNumber:=Msg.wParam;
        MessageNumber:=Msg.lParam;
end;

procedure TViewMailForm.FormShow(Sender: TObject);
begin
        MainForm.FormActivate(self);
end;

end.
