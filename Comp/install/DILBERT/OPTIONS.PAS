unit options;
(*@/// interface *)
interface

(*@/// uses *)
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
  StdCtrls,
  FileCtrl,
  comctrls,
  tcpip,
  ExtCtrls;
(*@\\\*)

type
(*@///   Tfrm_options = class(TForm) *)
Tfrm_options = class(TForm)
  page: TPageControl;
  pg_modus: TTabSheet;
  pg_target: TTabSheet;
  box_dir: TDirectoryListBox;
  box_drive: TDriveComboBox;
  lbl_dir: TLabel;
  lbl_target: TLabel;
  pg_internet: TTabSheet;
  lbl_proxy: TLabel;
  edt_proxy: TEdit;
  chk_proxy: TCheckBox;
  chk_status: TCheckBox;
  btn_ok: TButton;
  btn_cancel: TButton;
  HTTP: T_HTTP;
  grp_mode: TRadioGroup;
  procedure btn_okClick(Sender: TObject);
  procedure formcreate(Sender: TObject);
end;
(*@\\\000000100B*)

var
  frm_options: Tfrm_options;
(*@\\\0000000601*)
(*@/// implementation *)
implementation

uses status, doit;

{$R *.DFM}

(*@/// procedure Tfrm_options.btn_okClick(Sender: TObject); *)
procedure Tfrm_options.btn_okClick(Sender: TObject);
begin
  http.proxy:=edt_proxy.text;
  http.nocache:=chk_proxy.checked;
  if chk_status.checked then begin
    frm_status.visible:=true;
    http.ontrace:=frm_status.DoTrace;
    end;
  btn_ok.enabled:=false;
  action(grp_mode.itemindex,lbl_dir.caption+'\',http);
  btn_ok.enabled:=true;
  end;
(*@\\\0000000901*)
(*@/// procedure Tfrm_options.formcreate(Sender: TObject); *)
procedure Tfrm_options.formcreate(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to nr_of_comics-1 do
    grp_mode.items.add(comics[i,3]);
  grp_mode.itemindex:=0;
  end;
(*@\\\0000000701*)
(*@\\\0000000801*)
end.
(*@\\\0000000405*)
