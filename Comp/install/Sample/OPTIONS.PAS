unit Options;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons;

type
  TOptionsForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    GroupBox1: TGroupBox;
    AutoCheckStart: TCheckBox;
    AutoCheckMail: TCheckBox;
    MinutesEdt: TEdit;
    Label1: TLabel;
    AutoAddAddress: TCheckBox;
    GroupBox2: TGroupBox;
    SaveSent: TCheckBox;
    GroupBox3: TGroupBox;
    FullHeaders: TCheckBox;
    Label2: TLabel;
    BrowserEdt: TEdit;
    BrowseBtn: TButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure BrowseBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TOptionsForm.BitBtn1Click(Sender: TObject);
var
        i: integer;
begin
        if AutoCheckMail.Checked then
        begin
                try
                        i:=StrToInt(MinutesEdt.Text);
                        ModalResult:=mrOk;
                except
                        ShowMessage('You must specify the number of minutes.');
                        ActiveControl:=MinutesEdt;
                end;
        end
        else ModalResult:=mrOk;
end;

procedure TOptionsForm.BrowseBtnClick(Sender: TObject);
var
        d: TOpenDialog;
begin
        try
                d:=TOpenDialog.Create(self);
                d.Title:='Web Browser';
                d.Filter:='Programs|*.exe;*.com;*.bat;*.pif';
                if d.Execute then BrowserEdt.Text:=d.Filename;
        finally
                d.Free;
        end;
end;

end.
