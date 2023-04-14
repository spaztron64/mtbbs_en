program Shutsock;

uses
  Forms,
  Mainform in 'MAINFORM.PAS' {Form2},
  WinSock in 'C:\Program Files\Borland\Delphi 2.0\SOURCE\RTL\WIN\Winsock.pas';

{$R *.RES}

begin
  Application.Title := 'Shutdown All sockets even acting';
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
