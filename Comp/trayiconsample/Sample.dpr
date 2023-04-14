program Sample;

uses
  Forms,
  Main in 'Main.pas' {FormMain},
  About in 'About.pas' {FormAbout};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'サンプルアプリケーション';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
