program Sample;

uses
  Forms,
  Main in 'Main.pas' {FormMain},
  About in 'About.pas' {FormAbout};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := '�T���v���A�v���P�[�V����';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
