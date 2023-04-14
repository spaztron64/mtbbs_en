unit Mbxform;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Buttons, NMailBox;

type
  TMailboxForm = class(TForm)
    Viewer: NMailboxViewer;
    MessageCount: TPanel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ViewerChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
        procedure DeleteItems;
        procedure TransferItems;
end;

implementation

{$R *.DFM}

uses    ViewMail {for TViewMailForm},
        Transfer {for TTransferForm},
        Main,Global,NewMail;

procedure TMailboxForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
        MailboxNumber,i: integer;
begin
        Action:=caFree;
end;

procedure TMailboxForm.TransferItems;
var
        d: TTransferForm;
        i: integer;
        Move: Boolean;
begin
        if Viewer.ItemIndex=-1 then Exit;
        try
                d:=TTransferForm.Create(self);
                for i:=1 to MainForm.Mailbox.Mailboxes.Count do
                begin
                        d.MailBoxes.Items.Add(MainForm.Mailbox.MailboxName(i));
                end;
                if d.ShowModal=mrOk then Viewer.TransferSelectedMessages(d.Mailboxes.ItemIndex+1);
        finally
                d.Free;
        end;
end;

procedure TMailboxForm.DeleteItems;
begin
        if Viewer.ItemIndex=-1 then Exit;
        Viewer.TransferSelectedMessages(TRASH_MAILBOX);
end;

procedure TMailboxForm.ViewerChange(Sender: TObject);
begin
        MessageCount.Caption:=' '+IntToStr(Viewer.NumMessages)+' messages';
end;

procedure TMailboxForm.FormActivate(Sender: TObject);
begin
        MainForm.FormActivate(self);
end;

procedure TMailboxForm.FormShow(Sender: TObject);
begin
        Viewer.EnableMessageViewerManager(TViewMailForm);
        MainForm.FormActivate(self);
end;

end.
