unit attach;
(*@/// interface *)
interface

(*@/// uses *)
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, shellapi;
(*@\\\0002000310000310*)

type
(*@///   Tfrm_attach = class(TForm) *)
Tfrm_attach = class(TForm)
  lbx_attach: TListBox;
  btn_del: TButton;
  btn_add: TButton;
  btn_ok: TButton;
  OpenDialog: TOpenDialog;
  procedure lbx_attachDrawItem(Control: TWinControl; Index: Integer;
    Rect: TRect; State: TOwnerDrawState);
  procedure btn_addClick(Sender: TObject);
  procedure btn_delClick(Sender: TObject);
private
public
end;
(*@\\\0000000801*)

var
  frm_attach: Tfrm_attach;
(*@\\\0000000301*)
(*@/// implementation *)
implementation

{$R *.DFM}

type
  TIconKind=(ShellSmall, ShellLarge);

(*@/// function GetIcon(const filename:string; kind:TIconKind):HIcon; *)
function GetIcon(const filename:string; kind:TIconKind):HIcon;
var
  sh: TSHFileInfo;
  s:string;
begin
  s:=filename+#0;
  case Kind of
    ShellSmall:
      result:=shgetfileinfo(@s[1],0,sh,sizeof(TSHFileInfo),
                shgfi_icon or shgfi_smallicon or shgfi_shelliconsize);
    ShellLarge:
      result:=shgetfileinfo(@s[1],0,sh,sizeof(TSHFileInfo),
                shgfi_icon or shgfi_shelliconsize);
    end;
    result:=sh.hicon;
  end;
(*@\\\0000000805*)

(*@/// procedure Tfrm_attach.lbx_attachDrawItem(Control: TWinControl; Index: Integer; *)
procedure Tfrm_attach.lbx_attachDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  h: HIcon;
begin
  with (control as TListbox) do begin
    canvas.brush.style:=bssolid;
    canvas.brush.color:=color;
    if odselected in state then begin
      canvas.brush.color:=clActiveCaption;
      end;
    canvas.fillrect(rect);
    canvas.Textout( Rect.left+20,rect.top,items[index]);
    h:=GetIcon(items[index],ShellSmall);
    if h<>0 then
      drawiconex(canvas.handle,rect.left+1,rect.top+1,h,16,16,0,0,di_normal);
    if odFocused in state then
      canvas.DrawFocusRect(rect);
    end;
  end;
(*@\\\0030001012001012001101*)
(*@/// procedure Tfrm_attach.btn_addClick(Sender: TObject); *)
procedure Tfrm_attach.btn_addClick(Sender: TObject);
begin
  if opendialog.execute then
    lbx_attach.items.add(opendialog.filename);
  end;
(*@\\\0000000503*)
(*@/// procedure Tfrm_attach.btn_delClick(Sender: TObject); *)
procedure Tfrm_attach.btn_delClick(Sender: TObject);
var
  i: integer;
begin
  for i:=lbx_attach.items.count-1 downto 0 do
    if lbx_attach.selected[i] then
      lbx_attach.items.delete(i);
  end;
(*@\\\0000000803*)
(*@\\\0000000A01*)
end.


(*@\\\000D000601000601000011000201*)
