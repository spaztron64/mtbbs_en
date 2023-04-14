program dilbert;

uses
  Forms,
  options in 'options.pas' {frm_options},
  status in 'status.pas' {frm_status};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm_options, frm_options);
  Application.CreateForm(Tfrm_status, frm_status);
  Application.Run;
end.
