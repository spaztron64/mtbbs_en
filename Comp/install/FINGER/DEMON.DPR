program demon;

uses
  Forms,
  d_main in 'd_main.pas' {frm_main},
  d_user in 'd_user.pas' {frm_user};

{$R *.RES}

begin
(*$ifndef ver80 *)
  Application.Initialize;
(*$endif *)
  Application.CreateForm(Tfrm_main, frm_main);
  Application.CreateForm(Tfrm_user, frm_user);
  Application.Run;
end.
(*@\\\0000000B01*)
