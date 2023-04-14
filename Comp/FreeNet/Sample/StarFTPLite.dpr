program StarFTPLite;

uses
  Forms,
  mainform in 'mainform.pas' {Main},
  ServerProperty in 'ServerProperty.pas' {ServerPropertyForm},
  splash in 'splash.pas' {SplashScreen},
  progressfrm in 'progressfrm.pas' {Progress};


{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'StarFTP Light 0.1';
  SplashScreen := TSplashScreen.Create(Application);
  SplashScreen.Show;
  SplashScreen.Refresh;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
