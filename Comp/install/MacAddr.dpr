program Macaddr;

uses
  Forms,
  Main in 'MAIN.PAS' {Form1},
  Nb in 'NB.PAS';

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
