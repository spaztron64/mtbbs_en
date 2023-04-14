program Tnsrv;

uses
  Forms,
  Tnsrv1 in 'tnsrv1.pas' {ServerForm},
  Tnsrv2 in 'tnsrv2.pas' {ClientForm};

{$R *.RES}

begin
  Application.CreateForm(TServerForm, ServerForm);
  Application.Run;
end.
