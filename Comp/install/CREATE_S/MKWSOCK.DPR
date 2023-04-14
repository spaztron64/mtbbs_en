program Mkwsock;

uses
  Forms,
  Mainform in 'MAINFORM.PAS' {Form1};

{$R *.RES}

begin
  Application.Title := 'Creating Windows'' sockets';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
