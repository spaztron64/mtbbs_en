program Radftp;

uses
  Forms,
  Ftpinput in 'FTPINPUT.PAS' {InputForm},
  Ftpmain in 'FTPMAIN.PAS' {Form1};

{$R *.RES}

begin
  Application.Title := 'RadFTP';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TInputForm, InputForm);
  Application.Run;
end.
