unit Nmimetyp;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons;

type
  TNewMimeTypeForm = class(TForm)
    Label1: TLabel;
    MajorLB: TComboBox;
    Label2: TLabel;
    MinorEdt: TEdit;
    Label3: TLabel;
    DescriptionEdt: TEdit;
    Label4: TLabel;
    ExtensionEdt: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TNewMimeTypeForm.BitBtn1Click(Sender: TObject);
begin
        if MinorEdt.Text='' then
        begin
                ActiveControl:=MinorEdt;
                ShowMessage('You must specify a MIME minor type');
                Exit;
        end;
        ModalResult:=mrOk;
end;

end.
