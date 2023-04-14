unit Addedtfm;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TAddEdit = class(TForm)
    lAS: TLabel;
    LastEdt: TEdit;
    FirstEdt: TEdit;
    OrgEdt: TEdit;
    Label3: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    HomeEdt: TEdit;
    WorkEdt: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    NickEdt: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure OkBtnClick(Sender: TObject);
  private
        OrigX, OrigY: integer;
  public
    { Public declarations }
  end;

var
  AddEdit: TAddEdit;

implementation

{$R *.DFM}

procedure TAddEdit.OkBtnClick(Sender: TObject);
var
        s: string;
        c: char;
begin
        if LastEdt.Text='' then
        begin
                Application.MessageBox('You must specify a Last Name.',
                   'Input Error',MB_OK+MB_ICONINFORMATION);
                ActiveControl:=LastEdt;
                Exit;
        end;
        s:=UpperCase(LastEdt.Text);
        if (s[1]<'A') or (s[1]>'Z') then
        begin
                Application.MessageBox('The Last Name must start with a letter.',
                   'Input Error',MB_OK+MB_ICONINFORMATION);
                ActiveControl:=LastEdt;
                Exit;
        end;
        c:=s[1];
        s:=LastEdt.Text;
        s[1]:=c;
        LastEdt.Text:=s;
        if FirstEdt.Text='' then
        begin
                Application.MessageBox('You must specify a First Name.',
                   'Input Error',MB_OK+MB_ICONINFORMATION);
                ActiveControl:=FirstEdt;
                Exit;
        end;
        s:=UpperCase(FirstEdt.Text);
        if (s[1]<'A') or (s[1]>'Z') then
        begin
                Application.MessageBox('The First Name must start with a letter.',
                   'Input Error',MB_OK+MB_ICONINFORMATION);
                ActiveControl:=FirstEdt;
                Exit;
        end;
        c:=s[1];
        s:=FirstEdt.Text;
        s[1]:=c;
        FirstEdt.Text:=s;
        if (HomeEdt.Text='') and (WorkEdt.Text='') then
        begin
                Application.MessageBox('You must specify either a home or work e-mail address.',
                   'Input Error',MB_OK+MB_ICONINFORMATION);
                ActiveControl:=HomeEdt;
                Exit;
        end;
        ModalResult:=mrOk;
end;

end.
