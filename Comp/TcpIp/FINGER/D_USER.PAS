unit d_user;
(*@/// interface *)
interface

uses
(*$ifdef ver80 *)
  winprocs,
  wintypes,
(*$else *)
  Windows,
(*$endif *)
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls;

type
(*@///   Tfrm_user = class(TForm) *)
Tfrm_user = class(TForm)
  edt_user: TEdit;
  lbl_user: TLabel;
  btn_ok: TButton;
  btn_cancel: TButton;
end;
(*@\\\0000000601*)

var
  frm_user: Tfrm_user;
(*@\\\0000001403*)
(*@/// implementation *)
implementation

{$R *.DFM}
(*@\\\*)
end.
(*@\\\0000000301*)
