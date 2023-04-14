unit RasF;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Rascomp32, StdCtrls;

type
  TRasForm = class(TForm)
    Button1: TButton;
    Status: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  public
    { Public êÈåæ }
  end;

var
  RasForm: TRasForm;

implementation

uses AutoEd;

{$R *.DFM}



procedure TRasForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := CaFree;
end;

procedure TRasForm.Button1Click(Sender: TObject);
begin
     Auto.Ras.DisConnect;
     Close;
end;

procedure TRasForm.FormDestroy(Sender: TObject);
begin
   RasForm := Nil;
end;

end.
