unit Mimeexec;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, StdCtrls;

type
  TMimeLaunchForm = class(TForm)
    Prompt: TLabel;
    Label1: TLabel;
    ApplicationEdt: TEdit;
    ChangeBtn: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure ChangeBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TMimeLaunchForm.BitBtn1Click(Sender: TObject);
begin
        if not FileExists(ApplicationEdt.Text) then
           ShowMessage('An invalid or no application was selected.')
        else ModalResult:=mrOk;
end;

procedure TMimeLaunchForm.ChangeBtnClick(Sender: TObject);
var
        d: TOpenDialog;
begin
        try
                d:=TOpenDialog.Create(self);
                d.Title:='Select a viewer application';
                d.Filter:='Programs|*.exe;*.com;*.bat;*.pif';
                d.Options:=[ofFileMustExist];
                if d.Execute then ApplicationEdt.Text:=d.Filename;
        finally
                d.Free;
        end;
end;

end.
