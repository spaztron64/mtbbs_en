program smtpdemo;

uses
  Forms,
  smtpmain in 'smtpmain.pas' {Form1},
  attach in 'attach.pas' {frm_attach};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(Tfrm_attach, frm_attach);
  Application.Run;
end.
