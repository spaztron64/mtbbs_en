unit Transfer;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons;

type
  TTransferForm = class(TForm)
    Mailboxes: TListBox;
    OkBtn: TBitBtn;
    BitBtn2: TBitBtn;
    procedure OkBtnClick(Sender: TObject);
    procedure MailboxesDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TransferForm: TTransferForm;

implementation

{$R *.DFM}

procedure TTransferForm.OkBtnClick(Sender: TObject);
begin
        if Mailboxes.ItemIndex<>-1 then ModalResult:=mrOk;
end;

procedure TTransferForm.MailboxesDblClick(Sender: TObject);
begin
        ModalResult:=mrOk;
end;

end.
