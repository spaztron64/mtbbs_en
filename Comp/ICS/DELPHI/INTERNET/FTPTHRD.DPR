program ftpthrd;

uses
  Forms,
  FtpThrd1 in 'FtpThrd1.pas' {ThrdFtpForm},
  Ftpcli in 'C:\Temp\Ftpcli.pas',
  WSocket in 'C:\Temp\Wsocket.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TThrdFtpForm, ThrdFtpForm);
  Application.Run;
end.
