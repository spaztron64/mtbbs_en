unit pop_main;
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
  Menus,
  StdCtrls,
  tcpip;
(*@\\\*)

type
(*@///   Tmainform = class(TForm) *)
Tmainform = class(TForm)
  Pop: T_Pop3;
  edt_hostname: TEdit;
  edt_username: TEdit;
  edt_password: TEdit;
  lbl_host: TLabel;
  Label2: TLabel;
  Label3: TLabel;
  lbx_messages: TListBox;
  mem_text: TMemo;
  lbl_messages: TLabel;
  btn_connect: TButton;
  mnu_messages: TPopupMenu;
  mnu_get: TMenuItem;
  mnu_delete: TMenuItem;
  btn_close: TButton;
  mnu_mail: TPopupMenu;
  mnu_save: TMenuItem;
  dlg_save: TSaveDialog;
  procedure btn_connectClick(Sender: TObject);
  procedure lbx_messagesDrawItem(Control:TWinControl; Index:Integer; Rect:TRect; State:TOwnerDrawState);
  procedure lbx_messagesDblClick(Sender: TObject);
  procedure mnu_deleteClick(Sender: TObject);
  procedure btn_closeClick(Sender: TObject);
  procedure mnu_saveClick(Sender: TObject);
private
  active: boolean;
public
end;
(*@\\\0000001501*)

var
  mainform: Tmainform;
(*@\\\0000000601*)
(*@/// implementation *)
implementation

{$R *.DFM}

(*@/// procedure Tmainform.btn_connectClick(Sender: TObject); *)
procedure Tmainform.btn_connectClick(Sender: TObject);
begin
  pop.hostname:=edt_hostname.text;
  pop.username:=edt_username.text;
  pop.password:=edt_password.text;
  pop.login;
  active:=true;
  pop.getheaders;
  lbx_messages.items.assign(pop.mail);
  end;
(*@\\\0000000A03*)
(*@/// procedure Tmainform.lbx_messagesDrawItem(Control: TWinControl; Index: Integer; *)
procedure Tmainform.lbx_messagesDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  h: integer;
  s: string;
begin
  s:=lbx_messages.items[index];
  WITH lbx_messages.canvas do begin
    brush.style:=bsSolid;
    brush.color:=lbx_messages.color;
    if odSelected in state then
      brush.color:=clHighlight;
    fillrect(rect);
    h:=pos(#7,s);
    if h=0 then
      textout(rect.top,rect.left,s)
    else begin
      textout(rect.left,rect.top,copy(s,1,h-1));
      textout(rect.left+(rect.right-rect.left)div 2,rect.top,
        copy(s,h+1,length(s)));
      end;
    if odFocused in state then
      drawfocusrect(rect);
    end;
  end;
(*@\\\0000000305*)
(*@/// procedure Tmainform.lbx_messagesDblClick(Sender: TObject); *)
procedure Tmainform.lbx_messagesDblClick(Sender: TObject);
begin
  if active then begin
    pop.getmail(lbx_messages.itemindex+1);
    mem_text.lines.assign(pop.mail);
    end;
  end;
(*@\\\0000000703*)
(*@/// procedure Tmainform.mnu_deleteClick(Sender: TObject); *)
procedure Tmainform.mnu_deleteClick(Sender: TObject);
begin
  if active then
    pop.deletemail(lbx_messages.itemindex+1);
  end;
(*@\\\0000000503*)
(*@/// procedure Tmainform.btn_closeClick(Sender: TObject); *)
procedure Tmainform.btn_closeClick(Sender: TObject);
begin
  pop.logout;
  active:=false;
  lbx_messages.items.clear;
  end;
(*@\\\0000000603*)
(*@/// procedure Tmainform.mnu_saveClick(Sender: TObject); *)
procedure Tmainform.mnu_saveClick(Sender: TObject);
begin
  if dlg_save.execute then
    mem_text.lines.savetofile(dlg_save.filename);
  end;
(*@\\\0000000503*)
(*@\\\0000000A01*)
end.
(*@\\\0000000201*)
