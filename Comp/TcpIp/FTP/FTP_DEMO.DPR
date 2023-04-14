program ftp_demo;

uses
  Forms,
  ftp_main in 'ftp_main.pas' {mainform};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(Tmainform, mainform);
  Application.Run;
end.
