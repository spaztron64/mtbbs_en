program autoconv;

uses
  Forms,
  convsamp in 'convsamp.pas' {Form1},
  sjisconv in 'sjisconv.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
