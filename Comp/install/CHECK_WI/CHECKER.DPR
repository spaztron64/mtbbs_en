program Checker;

uses
  Forms,
  Chkmain in 'CHKMAIN.PAS' {Form1};

{$R *.RES}

begin
  Application.Title := 'Winsock Checker';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
