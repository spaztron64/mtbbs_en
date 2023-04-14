unit Attform;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons, FileCtrl,MimeMgr,
  InetMail;

type
  TAttachmentForm = class(TForm)
    DriveComboBox1: TDriveComboBox;
    DirectoryListBox1: TDirectoryListBox;
    FileListBox1: TFileListBox;
    AttList: TListBox;
    RemoveAttachmentBtn: TButton;
    AddAttachmentBtn: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    Label1: TLabel;
    Label5: TLabel;
    Label2: TLabel;
    LocationEdt: TEdit;
    NameEdt: TEdit;
    MimeTypeLB: TComboBox;
    DescriptionEdt: TEdit;
    ViewAttachmentBtn: TButton;
    NewTypeBtn: TButton;
    procedure FileListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AttListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure AttListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure MimeTypeLBDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure AttListClick(Sender: TObject);
    procedure AttListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure MimeTypeLBChange(Sender: TObject);
    procedure AddAttachmentBtnClick(Sender: TObject);
    procedure RemoveAttachmentBtnClick(Sender: TObject);
    procedure ViewAttachmentBtnClick(Sender: TObject);
    procedure NewTypeBtnClick(Sender: TObject);
  private
        procedure AddAttachment(location: string);
  public
        Attachments: array[1..50] of TSendMailAttachment;
        NumAttachments: integer;
  end;

implementation

{$R *.DFM}

uses Main,MimeExec,NMimeTyp;

procedure TAttachmentForm.FormShow(Sender: TObject);
var
        d: TMimeDefinition;
        i: integer;
begin
        MimeTypeLB.Clear;
        for i:=1 to MimeManager.GetNumDefinitions do
        begin
                d:=MimeManager.GetDefinition(i);
                MimeTypeLB.Items.Add(d.MimeType);
        end;
end;

procedure TAttachmentForm.FileListBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
        if (Button=mbLeft) and (FileListBox1.ItemIndex<>-1) then FileListBox1.BeginDrag(False);
end;

procedure TAttachmentForm.AttListDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
        if Sender is TFileListBox then Accept:=True;
end;

procedure TAttachmentForm.AttListDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
        AddAttachment(FileListBox1.FileName);
end;

procedure TAttachmentForm.AddAttachment(location: string);
begin
        if AttList.Items.IndexOf(location)<>-1 then Exit;
        Inc(NumAttachments);
        Attachments[NumAttachments].Location:=location;
        Attachments[NumAttachments].MimeType:=MimeManager.GetMimeType(location);
        Attachments[NumAttachments].Name:=ExtractFileName(location);
        Attachments[NumAttachments].MimeDescription:='';
        AttList.Items.Add(location);
        AttList.ItemIndex:=NumAttachments-1;
        AttListClick(self);
end;

procedure TAttachmentForm.MimeTypeLBDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
        s: string;
        BM: TBitmap;
begin
        s:=(Control as TComboBox).Items[Index];
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
                TextOut(Rect.Left+18,Rect.Top,(Control as TComboBox).Items[Index]);
        end;
end;

procedure TAttachmentForm.AttListClick(Sender: TObject);
var
        i,j: integer;
begin
        i:=AttList.ItemIndex+1;
        if i=0 then
        begin
                LocationEdt.Text:='';
                NameEdt.Text:='';
                NameEdt.Enabled:=False;
                MimeTypeLB.ItemIndex:=-1;
                MimeTypeLB.Enabled:=False;
                DescriptionEdt.Text:='';
                DescriptionEdt.Enabled:=False;
                NewTypeBtn.Enabled:=False;
        end
        else
        begin
                LocationEdt.Text:=Attachments[i].Location;
                NameEdt.Text:=Attachments[i].Name;
                NameEdt.Enabled:=True;
                MimeTypeLB.ItemIndex:=MimeTypeLB.Items.IndexOf(Attachments[i].MimeType);
                MimeTypeLB.Enabled:=True;
                DescriptionEdt.Text:=Attachments[i].MimeDescription;
                DescriptionEdt.Enabled:=True;
                NewTypeBtn.Enabled:=True;
        end;
end;

procedure TAttachmentForm.AttListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
        BM: TBitmap;
        s: string;
begin
        s:=Attachments[Index+1].MimeType;
        s:=Lowercase(Copy(s,1,Pos('/',s)-1));
        with (Control as TListBox).Canvas do
        begin
                FillRect(Rect);
                if s='image' then BM:=MimeImageBM;
                if s='audio' then BM:=MimeAudioBM;
                if s='video' then BM:=MimeVideoBM;
                if s='message' then BM:=MimeMessageBM;
                if s='text' then BM:=MimeTextBM;
                if s='application' then BM:=MimeApplicationBM;
                Draw(Rect.Left,Rect.Top,BM);
                TextOut(Rect.Left+18,Rect.Top,Attachments[Index+1].Name);
        end;
end;

procedure TAttachmentForm.MimeTypeLBChange(Sender: TObject);
var
        i: integer;
begin
        i:=AttList.ItemIndex+1;
        if i=0 then Exit;
        Attachments[i].MimeType:=MimeTypeLB.Items[MimeTypeLB.ItemIndex];
        Attachments[i].MIMEDescription:=DescriptionEdt.Text;
        Attachments[i].Name:=NameEdt.Text;
end;

procedure TAttachmentForm.AddAttachmentBtnClick(Sender: TObject);
begin
        if FileListBox1.ItemIndex<>-1 then AddAttachment(FileListBox1.Filename);
end;

procedure TAttachmentForm.RemoveAttachmentBtnClick(Sender: TObject);
var
        i,j: integer;
begin
        i:=AttList.ItemIndex+1;
        if i=0 then Exit;
        for j:=i to NumAttachments-1 do
        begin
                Attachments[j]:=Attachments[j+1];
        end;
        Dec(NumAttachments);
        AttList.Items.Delete(AttList.ItemIndex);
        AttListClick(self);
end;

procedure TAttachmentForm.ViewAttachmentBtnClick(Sender: TObject);
var
        i: integer;
        s,t: string;
        d: TMimeLaunchForm;
begin
        i:=AttList.ItemIndex+1;
        if i=0 then Exit;
        case MimeManager.GetAction(Attachments[i].MimeType) of
        maPrompt:
                begin
                        s:=MimeManager.SuggestApplication(Attachments[i].Location);
                        try
                                d:=TMimeLaunchForm.Create(self);
                                d.ApplicationEdt.Text:=s;
                                t:='No application has been defined for MIME type '+Attachments[i].MimeType+'.';
                                if s<>'' then t:=t+' It is suggested that you use the application below to view '+
                                  'this document. You may change this by pressing the Change button.'
                                else t:=t+' Please press the Change button to select a viewer application for '+
                                   'this MIME type';
                                d.Prompt.Caption:=t;
                                if d.ShowModal=mrOk then
                                begin
                                        MimeManager.RegisterApplication(Attachments[i].MimeType,d.ApplicationEdt.Text);
                                        if not MimeManager.Launch(Attachments[i].Location,Attachments[i].MimeType) then
                                           ShowMessage('An error occured while launching the viewer application.');
                                end;
                        finally
                                d.Free;
                        end;
                end;
        maLaunch: if not MimeManager.Launch(Attachments[i].Location,Attachments[i].MimeType) then
                     ShowMessage('An error occured while launching the viewer application.');
        maInternal: ;{not used in this program}
        end;
end;

procedure TAttachmentForm.NewTypeBtnClick(Sender: TObject);
var
        d: TNewMimeTypeForm;
        t: TMimeDefinition;
        s: string;
begin
        try
                d:=TNewMimeTypeForm.Create(self);
                s:=ExtractFileExt(LocationEdt.Text);
                Delete(s,1,1);
                d.ExtensionEdt.Text:=s;
                d.MajorLB.ItemIndex:=0;
                if s<>'' then d.MinorEdt.Text:='x-'+s;
                if d.ShowModal=mrOk then
                begin
                        case d.MajorLB.ItemIndex of
                        0: s:='application';
                        1: s:='audio';
                        2: s:='image';
                        3: s:='message';
                        4: s:='text';
                        5: s:='video';
                        end;
                        s:=s+'/'+d.MinorEdt.Text;
                        t.MimeType:=s;
                        t.Extension:=d.ExtensionEdt.Text;
                        t.Description:=d.DescriptionEdt.Text;
                        t.MimeAction:=maPrompt;
                        t.Application:='';
                        MimeManager.AddMimeType(t);
                        FormShow(self);{reload MimeTypeLB}
                        MimeTypeLB.ItemIndex:=MimeTypeLB.Items.IndexOf(s);
                end;
        finally
                d.Free;
        end;
end;

end.
