program timedemo;

uses
  Forms,
  timemain in 'timemain.pas' {Form1};

{$R *.RES}

begin
(*$ifndef ver80 *)
  Application.Initialize;
(*$endif *)
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
(*@\\\0000000A01*)
