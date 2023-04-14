unit Mimeedit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls;

type TMimeEditor = class(TForm)
    Panel3: TPanel;
    Label1: TLabel;
    ListBox: TListBox;
    Header: THeader;
    Label3: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    BrowseBtn: TButton;
    NewBtn: TButton;
    EditBtn: TButton;
    DeleteBtn: TButton;
    Button5: TButton;
    MIMEType: TLabel;
    Description: TLabel;
    Extension: TLabel;
    Application: TLabel;
    procedure FormShow(Sender: TObject);
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Button5Click(Sender: TObject);
    procedure ListBoxClick(Sender: TObject);
    procedure NewBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure BrowseBtnClick(Sender: TObject);
private
        function GetHighlightedEntry: integer;
end;

implementation

{$R *.DFM}

uses Main,MimeMgr,NMimeTyp;

procedure TMimeEditor.FormShow(Sender: TObject);
var
        D: TMimeDefinition;
        i: integer;
        s: string;
begin
        Header.SectionWidth[0]:=200;
        Header.SectionWidth[1]:=70;
        ListBox.Clear;
        for i:=1 to MimeManager.GetNumDefinitions do
        begin
                D:=MimeManager.GetDefinition(i);
                s:=Lowercase(D.MimeType+'|'+D.Extension+'|'+D.Application+'|'+IntToStr(i));
                ListBox.Items.Add(s);
        end;
        if ListBox.ItemIndex=-1 then ListBox.ItemIndex:=0;
        ListBoxClick(self);
end;

procedure TMimeEditor.ListBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
        s: string;
        i: integer;
        Bitmap: TBitmap;
begin
        s:=Listbox.Items[Index];
        with Listbox.Canvas do
        begin
                FillRect(Rect);
                case s[1] of
                'a':
                        begin
                                if s[2]='u' then Bitmap:=MimeAudioBM
                                else Bitmap:=MimeApplicationBM;
                        end;
                'i': Bitmap:=MimeImageBM;
                'm': Bitmap:=MimeMessageBM;
                't': Bitmap:=MimeTextBM;
                'v': Bitmap:=MimeVideoBM;
                end;
                i:=Pos('|',s);
                Draw(Rect.Left+2,Rect.Top,Bitmap);
                TextOut(Rect.Left+21,Rect.Top,Copy(s,1,i-1));
                Delete(s,1,i);
                i:=Pos('|',s);
                TextOut(Rect.Left+205,Rect.Top,Copy(s,1,i-1));
                Delete(s,1,i);
                i:=Pos('|',s);
                TextOut(Rect.Left+275,Rect.Top,Copy(s,1,i-1));
                MoveTo(200,0);
                LineTo(200,Listbox.Height);
                MoveTo(270,0);
                LineTo(270,Listbox.Height);
        end;
end;

procedure TMimeEditor.Button5Click(Sender: TObject);
begin
        Close;
end;

function TMimeEditor.GetHighlightedEntry: integer;
var
        s: string;
        i: integer;
begin
        If ListBox.ItemIndex=-1 then Exit;
        s:=ListBox.Items[ListBox.ItemIndex];
        i:=Pos('|',s);
        Delete(s,1,i);
        i:=Pos('|',s);
        Delete(s,1,i);
        i:=Pos('|',s);
        Delete(s,1,i);
        try
                i:=StrToInt(s);
        except
                Result:=0;
                Exit;
        end;
        Result:=i;
end;

procedure TMimeEditor.ListBoxClick(Sender: TObject);
var
        i: Integer;
        D: TMimeDefinition;
begin
        i:=GetHighlightedEntry;
        if i=0 then Exit;
        d:=MimeManager.GetDefinition(i);
        Description.Caption:=D.Description;
        MIMEType.Caption:=D.MIMEType;
        Application.Caption:=Lowercase(D.Application);
        Extension.Caption:=D.Extension;
end;

procedure TMimeEditor.NewBtnClick(Sender: TObject);
var
        d: TNewMimeTypeForm;
        s: string;
        t: TMimeDefinition;
begin
        try
                d:=TNewMimeTypeForm.Create(self);
                d.MajorLB.ItemIndex:=0;
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
                        FormShow(self);{reload ListBox}
                end;
        finally
                d.Free;
        end;
end;

procedure TMimeEditor.EditBtnClick(Sender: TObject);
var
        d: TNewMimeTypeForm;
        s: string;
        t: TMimeDefinition;
        i: integer;
begin
        if ListBox.ItemIndex=-1 then Exit;
        i:=GetHighlightedEntry;
        if i=0 then Exit;
        t:=MimeManager.GetDefinition(i);
        try
                d:=TNewMimeTypeForm.Create(self);
                s:=t.MimeType;
                i:=Pos('/',s);
                d.MajorLB.ItemIndex:=d.MajorLB.Items.IndexOf(Copy(s,1,i-1));
                d.MinorEdt.Text:=Copy(s,i+1,999);
                d.ExtensionEdt.Text:=t.Extension;
                d.DescriptionEdt.Text:=t.Description;
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
                        MimeManager.AddMimeType(t);
                        FormShow(self);{reload ListBox}
                end;
        finally
                d.Free;
        end;
end;

procedure TMimeEditor.DeleteBtnClick(Sender: TObject);
var
        i: integer;
begin
        if ListBox.ItemIndex=-1 then Exit;
        i:=GetHighlightedEntry;
        if i=0 then Exit;
        MimeManager.DeleteDefinition(i);
        FormShow(self);{reload ListBox}
end;

procedure TMimeEditor.BrowseBtnClick(Sender: TObject);
var
        d: TOpenDialog;
        t: TMimeDefinition;
begin
        if ListBox.ItemIndex=-1 then Exit;
        try
                d:=TOpenDialog.Create(self);
                d.Title:='Select a viewer application';
                d.Filter:='Programs|*.exe;*.com;*.bat;*.pif';
                d.Options:=[ofFileMustExist];
                if d.Execute then
                begin
                        Application.Caption:=d.Filename;
                        t.MimeType:=MimeType.Caption;
                        t.Extension:=Extension.Caption;
                        t.Description:=Description.Caption;
                        t.MimeAction:=maLaunch;
                        t.Application:=Application.Caption;
                        MimeManager.AddMimeType(t);
                        FormShow(self);{reload ListBox}

                end;
        finally
                d.Free;
        end;
end;

end.
