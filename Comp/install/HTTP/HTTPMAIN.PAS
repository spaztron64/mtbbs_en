unit httpmain;
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
  tcpip;
(*@\\\0000000201*)

type
(*@///   TForm1 = class(TForm) *)
TForm1 = class(TForm)
  HTTP: T_HTTP;
  Memo: TMemo;
  edi_url: TEdit;
  lbl_url: TLabel;
  lbl_proxy: TLabel;
  edi_proxy: TEdit;
  chk_proxy: TCheckBox;
  chk_nocache: TCheckBox;
  btn_doit: TButton;
  lbl_user: TLabel;
  edt_user: TEdit;
  lbl_password: TLabel;
  edt_pass: TEdit;
  chk_basic: TCheckBox;
  procedure btn_doitClick(Sender: TObject);
end;
(*@\\\0030000F03000F0C000F03*)

var
  Form1: TForm1;
(*@\\\0000000601*)
(*@/// implementation *)
implementation

{$R *.DFM}

(*@/// procedure TForm1.btn_doitClick(Sender: TObject); *)
procedure TForm1.btn_doitClick(Sender: TObject);
{ var }
{   t:TFileStream; }
begin
  http.url:=edi_url.text;
  if chk_proxy.checked then
    http.proxy:=edi_proxy.text;
  http.nocache:=chk_nocache.checked;
  if chk_basic.checked then
    http.DoBasicAuthorization(edt_user.text,edt_pass.text)
  else
    http.Authorization:='';   (* clean the authorization *)
  http.action;
  memo.lines.loadfromstream(http.stream);
  end;
(*@\\\000E00090600090F000901000901*)
(*@\\\0000000501*)
end.
(*@\\\0000000301*)
