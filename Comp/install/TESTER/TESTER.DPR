program Tester;

uses
  Forms,
  Mainform in 'MAINFORM.PAS' {Form1},
  Packet in 'Packet.pas';

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
