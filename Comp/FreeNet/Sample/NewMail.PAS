unit Newmail;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls,InetMail;

type TNewMessageForm = class(TForm)
    Panel1: TPanel;
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ToEdt: TEdit;
    ccEdt: TEdit;
    BccEdt: TEdit;
    AddBookBtn: TBitBtn;
    AttachBtn: TBitBtn;
    SubjectEdt: TEdit;
    Label4: TLabel;
    MailNowBtn: TBitBtn;
    MailLaterBtn: TBitBtn;
    BitBtn4: TBitBtn;
    Label5: TLabel;
    AttachmentsLB: TComboBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AddBookBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MailNowBtnClick(Sender: TObject);
    procedure AttachBtnClick(Sender: TObject);
    procedure AttachmentsLBDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormActivate(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure MailLaterBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
private
        Attachments: array[1..50] of TSendMailAttachment;
        NumAttachments: integer;
        procedure GenerateMessage(m: TStrings);
public
        ToList,ccList,BccList: TStrings;
end;

implementation

{$R *.DFM}

uses    Address {for TAddressForm},
        SndMail {for TSendMailForm},
        AttForm {for TAttachmentForm},
        MbxForm {for TMailboxForm},
        Global,Main,AttDef;

procedure TNewMessageForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
        Action:=caFree;
end;

procedure TNewMessageForm.AddBookBtnClick(Sender: TObject);
var
        d: TAddressForm;
        i: integer;
begin
        try
                d:=TAddressForm.Create(self);
                d.ToList.Items.Assign(ToList);
                d.ccList.Items.Assign(ccList);
                d.BccList.Items.Assign(BccList);
                if (d.ShowModal=mrOk) then
                begin
                        ToList.Assign(d.ToList.Items);
                        ccList.Assign(d.ccList.Items);
                        BccList.Assign(d.BccList.Items);
                        ToEdt.Text:='';
                        for i:=0 to ToList.Count-1 do
                        begin
                                ToEdt.Text:=ToEdt.Text+Copy(ToList[i],Pos('|',ToList[i])+1,999);
                                if i<>ToList.Count-1 then ToEdt.Text:=ToEdt.Text+', ';
                        end;
                        ccEdt.Text:='';
                        for i:=0 to ccList.Count-1 do
                        begin
                                ccEdt.Text:=ccEdt.Text+Copy(ccList[i],Pos('|',ccList[i])+1,999);
                                if i<>ccList.Count-1 then ccEdt.Text:=ccEdt.Text+', ';
                        end;
                        BccEdt.Text:='';
                        for i:=0 to BccList.Count-1 do
                        begin
                                BccEdt.Text:=BccEdt.Text+Copy(BccList[i],Pos('|',BccList[i])+1,999);
                                if i<>BccList.Count-1 then BccEdt.Text:=BccEdt.Text+', ';
                        end;
                end;
        finally
                d.Free;
        end;
end;

procedure TNewMessageForm.FormCreate(Sender: TObject);
begin
        ToList:=TStringList.Create;
        ccList:=TStringList.Create;
        BccList:=TstringList.Create;
end;

procedure TNewMessageForm.FormDestroy(Sender: TObject);
begin
        ToList.Destroy;
        ccList.Destroy;
        BccList.Destroy;
end;

procedure TNewMessageForm.MailNowBtnClick(Sender: TObject);
var
        d: TSendMailForm;
        msg,sig: TStrings;
        AppDirectory,s: string;
        i: integer;
        Att: TMimeAttachment;
        f: File;
        natt: LongInt;
begin
        AppDirectory:=ExtractFilePath(Application.ExeName);
        sig:=TStringList.Create;
        if IniOptions.UseSignature then
        begin
                try
                        AppDirectory:=ExtractFilePath(Application.ExeName);
                        sig.LoadFromFile(AppDirectory+'signatur.def');
                        if sig.Count=0 then IniOptions.UseSignature:=False
                        else sig.Insert(0,' ');
                except
                        IniOptions.UseSignature:=False;
                end;
        end;
        if ToList.Count+ccList.Count+BccList.Count>0 then
        begin
                try
                        d:=TSendMailForm.Create(self);
                        d.SendMail1.FROM_Address:=IniInfo.UserID+'@'+IniInfo.POPServer;
                        d.SendMail1.FROM_Name:=IniInfo.UserName;
                        d.SendMail1.Headers.Add('X-Mailer: StarMail Light Version 0.1');
                        d.SendMail1.ListTo.Assign(ToList);
                        d.SendMail1.Listcc.Assign(ccList);
                        d.SendMail1.ListBcc.Assign(BccList);
                        d.SendMail1.Subject:=SubjectEdt.Text;
                        d.SendMail1.MailText.Assign(Memo1.Lines);
                        if NumAttachments>0 then
                        begin
                                d.SendMail1.ClearAttachments;
                                for i:=1 to NumAttachments do d.SendMail1.AddAttachment(Attachments[i]);
                        end;
                        if IniOptions.UseSignature then d.SendMail1.MailText.AddStrings(sig);
                        if d.ShowModal=mrOK then
                        begin
                                {store message in sent mailbox}
                                with MainForm.Mailbox do
                                begin
                                        CurrentMailBoxNumber:=OUT_MAILBOX;
                                        msg:=TStringList.Create;
                                        GenerateMessage(msg);
                                        if IniOptions.UseSignature then msg.AddStrings(sig);
                                        Msg_Text.Assign(msg);
                                        msg.Destroy;
                                        Msg_Subject:=SubjectEdt.Text;
                                        s:=ToList[0];
                                        Msg_From:=Copy(s,Pos('|',s)+1,999)+' <'+Copy(s,1,Pos('|',s)-1)+'>';
                                        Msg_Flag:='U';
                                        Msg_Date:=FormatDateTime('ddd, d mmm yyyy hh:nn:ss',Now);
                                        Msg_AttachStart:=0;
                                        Msg_AttachEnd:=0;
                                        for i:=1 to NumAttachments do
                                        begin
                                                Att.Name:=Attachments[i].Name;
                                                Att.MimeType:=Attachments[i].MimeType;
                                                Att.Disposition:='attachment';
                                                Att.Location:=Attachments[i].Location;
                                                Att.Description:=Attachments[i].MIMEDescription;
                                                Att.Stored:=False;
                                                try
                                                        AssignFile(f,Att.Location);
                                                        Reset(f,1);
                                                        Att.Size:=FileSize(f);
                                                        CloseFile(f);
                                                except
                                                        Att.Size:=0;
                                                end;
                                                natt:=MainForm.AttachmentManager.NewAttachment(Att);
                                                if Msg_AttachStart=0 then Msg_AttachStart:=natt;
                                                Msg_AttachEnd:=natt;
                                        end;
                                        AddMail;
                                end;
                        end;
                finally
                        d.Free;
                end;
                Close;
        end
        else ShowMessage('You have not specified any recipients');
        sig.Destroy;
end;

procedure TNewMessageForm.GenerateMessage(m: TStrings);
var
        i: integer;
        s: string;
begin
        m.Add('From: '+IniInfo.UserName+' <'+IniInfo.UserId+'@'+IniInfo.POPServer+'>');
        for i:=0 to ToList.Count-1 do
        begin
                s:=ToList[i];
                m.Add('To: '+Copy(s,Pos('|',s)+1,999)+' <'+Copy(s,1,Pos('|',s)-1)+'>');
        end;
        for i:=0 to ccList.Count-1 do
        begin
                s:=ccList[i];
                m.Add('cc: '+Copy(s,Pos('|',s)+1,999)+' <'+Copy(s,1,Pos('|',s)-1)+'>');
        end;
        for i:=0 to BccList.Count-1 do
        begin
                s:=BccList[i];
                m.Add('Bcc: '+Copy(s,Pos('|',s)+1,999)+' <'+Copy(s,1,Pos('|',s)-1)+'>');
        end;
        m.Add('Date: '+FormatDateTime('ddd, d mmm yyyy hh:nn:ss',Now));
        if SubjectEdt.Text<>'' then m.Add('Subject: '+SubjectEdt.Text);
        m.Add('X-Mailer: StarMail Light Version 0.1');
        m.Add('');
        m.AddStrings(Memo1.Lines);
end;


procedure TNewMessageForm.AttachBtnClick(Sender: TObject);
var
        d: TAttachmentForm;
        i: integer;
begin
        try
                d:=TAttachmentForm.Create(self);
                for i:=1 to NumAttachments do
                begin
                        d.Attachments[i]:=Attachments[i];
                        d.AttList.Items.Add(Attachments[i].Location);
                end;
                d.NumAttachments:=NumAttachments;
                if d.ShowModal=mrOk then
                begin
                        AttachmentsLB.Clear;
                        for i:=1 to d.NumAttachments do
                        begin
                                Attachments[i]:=d.Attachments[i];
                                AttachmentsLB.Items.Add(Attachments[i].Location);
                        end;
                        NumAttachments:=d.NumAttachments;
                        if NumAttachments>0 then AttachmentsLB.ItemIndex:=0;
                end;
        finally
                d.Free;
        end;
end;

procedure TNewMessageForm.AttachmentsLBDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
        BM: TBitmap;
        s: string;
begin
        s:=Attachments[Index+1].MimeType;
        s:=Lowercase(Copy(s,1,Pos('/',s)-1));
        with (Control as TComboBox).Canvas do
        begin
                FillRect(Rect);
                if s='image' then BM:=MimeImageBM;
                if s='audio' then BM:=MimeAudioBM;
                if s='video' then BM:=MimeVideoBM;
                if s='message' then BM:=MimeMessageBM;
                if s='text' then BM:=MimeTextBM;
                if s='application' then BM:=MimeApplicationBM;
                Draw(Rect.Left,Rect.Top,BM);
                s:=Attachments[Index+1].Name;
                if Attachments[Index+1].MimeDescription<>'' then
                   s:=s+' ('+Attachments[Index+1].MimeDescription+')';
                TextOut(Rect.Left+18,Rect.Top,s);
        end;
end;

procedure TNewMessageForm.FormActivate(Sender: TObject);
begin
        MainForm.FormActivate(self);
end;

procedure TNewMessageForm.BitBtn4Click(Sender: TObject);
begin
        Close;
end;

procedure TNewMessageForm.MailLaterBtnClick(Sender: TObject);
var
        sig,msg: TStrings;
        natt: LongInt;
        i: integer;
        AppDirectory,s: string;
        Att: TMimeAttachment;
        f: file;
begin
        AppDirectory:=ExtractFilePath(Application.ExeName);
        sig:=TStringList.Create;
        if IniOptions.UseSignature then
        begin
                try
                        AppDirectory:=ExtractFilePath(Application.ExeName);
                        sig.LoadFromFile(AppDirectory+'signatur.def');
                        if sig.Count=0 then IniOptions.UseSignature:=False
                        else sig.Insert(0,' ');
                except
                        IniOptions.UseSignature:=False;
                end;
        end;
        if ToList.Count+ccList.Count+BccList.Count>0 then
        begin
                {store message in pending mailbox}
                with MainForm.Mailbox do
                begin
                        CurrentMailBoxNumber:=PENDING_MAILBOX;
                        msg:=TStringList.Create;
                        GenerateMessage(msg);
                        if IniOptions.UseSignature then msg.AddStrings(sig);
                        Msg_Text.Assign(msg);
                        msg.Destroy;
                        Msg_Subject:=SubjectEdt.Text;
                        s:=ToList[0];
                        Msg_From:=Copy(s,Pos('|',s)+1,999)+' <'+Copy(s,1,Pos('|',s)-1)+'>';
                        Msg_Flag:='U';
                        Msg_Date:=FormatDateTime('ddd, d mmm yyyy hh:nn:ss',Now);
                        Msg_AttachStart:=0;
                        Msg_AttachEnd:=0;
                        for i:=1 to NumAttachments do
                        begin
                                Att.Name:=Attachments[i].Name;
                                Att.MimeType:=Attachments[i].MimeType;
                                Att.Disposition:='attachment';
                                Att.Location:=Attachments[i].Location;
                                Att.Description:=Attachments[i].MIMEDescription;
                                Att.Stored:=False;
                                try
                                        AssignFile(f,Att.Location);
                                        Reset(f,1);
                                        Att.Size:=FileSize(f);
                                        CloseFile(f);
                                except
                                        Att.Size:=0;
                                end;
                                natt:=MainForm.AttachmentManager.NewAttachment(Att);
                                if Msg_AttachStart=0 then Msg_AttachStart:=natt;
                                Msg_AttachEnd:=natt;
                        end;
                        AddMail;
                end;
                Close;
        end
        else ShowMessage('You have not specified any recipients');
        sig.Destroy;
end;

procedure TNewMessageForm.FormShow(Sender: TObject);
begin
        MainForm.FormActivate(self);
end;

end.
