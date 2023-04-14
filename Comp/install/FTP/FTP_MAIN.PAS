unit ftp_main;
(*@/// interface *)
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, tcpip, ip_misc, Buttons, shellapi, Menus, CommCtrl,
  ExtCtrls;

type
(*@///   Tmainform = class(TForm) *)
Tmainform = class(TForm)
  ftp: T_FTP;
  edt_hostname: TEdit;
  lbl_hostname: TLabel;
  btn_connect: TButton;
  grp_main: TPanel;
    lbl_path: TLabel;
    cbx_path: TComboBox;
    btn_up: TSpeedButton;
    btn_newdir: TSpeedButton;
    btn_details: TSpeedButton;
    btn_list: TSpeedButton;
    dirview: TListView;
(*@///   mnu_style: TPopupMenu; *)
mnu_style: TPopupMenu;
mnu_view: TMenuItem;
  mnu_view_big: TMenuItem;
  mnu_view_small: TMenuItem;
  mnu_view_list: TMenuItem;
  mnu_view_details: TMenuItem;
mnu_line1: TMenuItem;
mnu_sort: TMenuItem;
  mnu_sort_name: TMenuItem;
  mnu_sort_type: TMenuItem;
  mnu_sort_size: TMenuItem;
  mnu_sort_date: TMenuItem;
(*@\\\*)
  dlg_save: TSaveDialog;
  icons_large: TImageList;
  icons_small: TImageList;
    Status: TStatusBar;
    chk_async: TCheckBox;
  procedure btn_connectClick(Sender: TObject);
  procedure btn_detailsClick(Sender: TObject);
  procedure btn_listClick(Sender: TObject);
  procedure dirviewDblClick(Sender: TObject);
  procedure FormCreate(Sender: TObject);
  procedure FormClose(Sender: TObject; var Action: TCloseAction);
  procedure btn_upClick(Sender: TObject);
  procedure mnu_viewClick(Sender: TObject);
  procedure mnu_sortClick(Sender: TObject);
  procedure dirviewColumnClick(Sender: TObject; Column: TListColumn);
  procedure cbx_pathDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  procedure cbx_pathDblClick(Sender: TObject);
  procedure ftp_complete(Sender:TObject; mode: t_ftp_mode);
  procedure ftp_data(Sender:TObject; mode: t_ftp_mode; data:integer);
  procedure ftp_trace(const s: string; level: TTraceLevel);
  procedure chk_asyncClick(Sender: TObject);
public
  icon_host: TIcon;
  icon_dir: TIcon;
  ext_known: TStringList;
  size: integer;
  procedure getdir(const s:string);
end;
(*@\\\0000002401*)

var
  mainform: Tmainform;
(*@\\\0000000901*)
(*@/// implementation *)
implementation

{$R *.DFM}

type
  TIconKind=(ShellSmall, ShellLarge);
(*@/// function GetIconFromType(const typename:string; kind:TIconKind):HIcon; *)
function GetIconFromType(const typename:string; kind:TIconKind):HIcon;
var
  s,t:string;
  h:THandle;
  x,y,i:integer;
begin
  result:=0;
  s:=typename+'\DefaultIcon'+#0;
  if RegOpenKeyEx(HKEY_CLASSES_ROOT,@s[1],0,key_read,h)=error_success then begin
    s:=#0;
    x:=255;
    setlength(t,x);
    if RegQueryValueEx(h,@s[1],NIL,@y,@t[1],@x)=error_success then begin
      try
        s:=copy(t,1,x);
        t:=copy(s,1,pos(',',s)-1)+#0;
        s:=copy(s,pos(',',s)+1,length(s));
        i:=0;
        try
          i:=strtoint(s);
        except
          end;
        case kind of
          ShellSmall: y:=ExtractIconEx(@t[1],i,h,x,1);
          ShellLarge: y:=ExtractIconEx(@t[1],i,x,h,1);
          end;
        result:=x;
      except
        end;
      end;
    end;
  end;
(*@\\\0002001D01001D01*)
(*@/// function GetIconIndirect(const filename:string; kind:TIconKind):HIcon; *)
function GetIconIndirect(const filename:string; kind:TIconKind):HIcon;

(* crawl through the registry to find the icon attached to a given
   file extension *)

var
  s,t:string;
  h:THandle;
  x,y:integer;
begin
  result:=0;
  s:=filename+#0;
  y:=reg_sz;
  if RegOpenKeyEx(HKEY_CLASSES_ROOT,@s[1],0,key_read,h)=error_success then begin
    s:=#0;
    x:=255;
    setlength(t,255);
    if RegQueryValueEx(h,@s[1],NIL,@y,@t[1],@x)=error_success then begin
      result:=GetIconFromType(copy(t,1,x-1),kind);
(*@///       s:=copy(t,1,x-1)+'\DefaultIcon'+#0; *)
(*$ifdef zero*)
s:=copy(t,1,x-1)+'\DefaultIcon'+#0;
if RegOpenKeyEx(HKEY_CLASSES_ROOT,@s[1],0,key_read,h)=error_success then begin
  s:=#0;
  x:=255;
  if RegQueryValueEx(h,@s[1],NIL,@y,@t[1],@x)=error_success then begin
    try
      s:=copy(t,1,x);
      t:=copy(s,1,pos(',',s)-1)+#0;
      s:=copy(s,pos(',',s)+1,length(s));
      i:=strtoint(s);
      case kind of
        ShellSmall: y:=ExtractIconEx(@t[1],i,h,x,1);
        ShellLarge: y:=ExtractIconEx(@t[1],i,x,h,1);
        end;
      result:=x;
    except
      result:=0;
      end;
    end;
  end;
(*$endif*)
(*@\\\0000001601*)
      end;
    end;
  end;
(*@\\\0000000906*)

(*@/// function SortList(item1,item2, Paramsort:integer):integer stdcall; *)
function SortList(item1,item2, Paramsort:integer):integer stdcall;
var
  i1,i2: TListItem;
  s1,s2: string;
  a1,a2: integer;
  d1,d2: TDateTime;
begin
  i1:=TListItem(item1);
  i2:=TListItem(item2);
  case abs(paramsort) of
(*@///     0: sort by caption *)
0: begin
  s1:=i1.caption;
  s2:=i2.caption;
  if s1>s2 then
    result:=+1
  else if s1<s2 then
    result:=-1
  else
    result:=0;
  end;
(*@\\\*)
(*@///     1: sort by type *)
1: begin
  s1:=i1.subitems[1];
  s2:=i2.subitems[2];
  if s1>s2 then
    result:=+1
  else if s1<s2 then
    result:=-1
  else
    result:=0;
  end;
(*@\\\0000000301*)
(*@///     2: sort by size *)
2: begin
  a1:=strtoint('0'+i1.subitems[0]);
  a2:=strtoint('0'+i2.subitems[0]);
  if a1>a2 then
    result:=+1
  else if a1<a2 then
    result:=-1
  else
    result:=0;
  end;
(*@\\\0000000201*)
(*@///     3: sort by date *)
3: begin
  d1:=strtodatetime(i1.subitems[2]);
  d2:=strtodatetime(i2.subitems[2]);
  if d1<d2 then
    result:=+1
  else if d1>d2 then
    result:=-1
  else
    result:=0;
  end;
(*@\\\*)
    else result:=0;
    end;
  if paramsort<0 then result:=-result;
  end;
(*@\\\0000000F01*)

(*@/// procedure Tmainform.FormCreate(Sender: TObject); *)
procedure Tmainform.FormCreate(Sender: TObject);
var
  s: string;
  icon: TIcon;
  h,x: THandle;
begin
  ext_known:=TStringlist.Create;
  s:='Directory';
  icon:=Ticon.create;
  icon.handle:=GetIconFromType(s,ShellSmall);
  icons_small.addicon(icon);
  icon.handle:=GetIconFromType(s,ShellLarge);
  icons_large.addicon(icon);
  ExtractIconEx('%SystemRoot%\system32\SHELL32.dll'#0,0,h,x,1);
  icon.handle:=x;
  icons_small.addicon(icon);
  icon.handle:=h;
  icons_large.addicon(icon);
  icon.free;
  icon_dir:=TIcon.Create;
  ExtractIconEx('%SystemRoot%\system32\SHELL32.dll'#0,3,h,x,1);
  icon_dir.handle:=x;
  icon_host:=TIcon.Create;
  ExtractIconEx('%SystemRoot%\system32\SHELL32.dll'#0,17,h,x,1);
  icon_host.handle:=x;
  end;
(*@\\\*)
(*@/// procedure Tmainform.FormClose(Sender: TObject; var Action: TCloseAction); *)
procedure Tmainform.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ext_known.free;
  icon_host.free;
  icon_dir.free;
  end;
(*@\\\0000000412*)
(*@/// procedure Tmainform.btn_connectClick(Sender: TObject); *)
procedure Tmainform.btn_connectClick(Sender: TObject);
begin
  ftp.hostname:=edt_hostname.text;
  ftp.login;
{  btn_new.enabled:=true; }
  cbx_path.items.add(ftp.hostname);
  cbx_path.itemindex:=0;
  getdir('.');
  end;
(*@\\\0000000501*)
(*@/// procedure Tmainform.getdir(const s:string); *)
procedure Tmainform.getdir(const s:string);
var
  h: t_filedata;
  item: TListItem;
  ext: string;
  p: integer;
  icon: TIcon;
  handle_small, handle_large: THandle;
begin
  dirview.items.clear;
  ftp.getdir('.');
  while true do begin
    h:=ftp.getdirentry;
    if h.filetype=ft_none then BREAK;
    item:=dirview.items.add;
    item.caption:=h.name;
    if h.size>0 then
      item.subitems.add(inttostr(h.size))
    else
      item.subitems.add('');
      item.imageindex:=1;  (* windows flag *)
    case h.filetype of
      ft_dir: begin
        item.subitems.add('Directory');
        item.imageindex:=0;
        end;
      ft_file: item.subitems.add('File');
      ft_link: item.subitems.add('Link');
      end;
    item.subitems.add(datetimetostr(h.datetime));
    if (pos('.',h.name)<>0) and
       (h.filetype<>ft_dir) then begin
      ext:=lowercase(copy(h.name,posn('.',h.name,-1),length(h.name)));
      if ext_known.find(ext,p) then
        item.imageindex:=integer(ext_known.objects[p])
      else begin
        handle_small:=GetIconIndirect(ext,ShellSmall);
        handle_large:=GetIconIndirect(ext,ShellLarge);
        if handle_small<>0 then begin
          ext_known.add(ext);
          icon:=Ticon.create;
          icon.handle:=handle_small;
          p:=icons_small.addicon(icon);
          icon.handle:=handle_large;
          p:=icons_large.addicon(icon);
          icon.free;
          ext_known.objects[ext_known.count-1]:=TObject(p);
          item.imageindex:=p;
          end;
        end;
      end;
    end;
  end;
(*@\\\*)
(*@/// procedure Tmainform.btn_detailsClick(Sender: TObject); *)
procedure Tmainform.btn_detailsClick(Sender: TObject);
begin
  dirview.viewstyle:=vsReport;
  end;
(*@\\\*)
(*@/// procedure Tmainform.btn_listClick(Sender: TObject); *)
procedure Tmainform.btn_listClick(Sender: TObject);
begin
  dirview.viewstyle:=vsList;
  end;
(*@\\\*)
(*@/// procedure Tmainform.dirviewDblClick(Sender: TObject); *)
procedure Tmainform.dirviewDblClick(Sender: TObject);
begin
  if dirview.itemfocused=NIL then EXIT;
  if ftp.busy then EXIT;
  if dirview.itemfocused.subitems[1]='Directory' then begin
    ftp.changedir(dirview.itemfocused.caption);
    cbx_path.items.add(dirview.itemfocused.caption);
    getdir('.');
    cbx_path.itemindex:=cbx_path.items.count-1;
    btn_up.enabled:=true;
    end
  else begin
    dlg_save.filename:=dirview.itemfocused.caption;
    if dlg_save.execute then begin
      ftp.uri:=dirview.itemfocused.caption;
      size:=0;
      ftp.download;
{       TMemorystream(ftp.stream).savetofile(dlg_save.filename); }
      end;
    end;
  end;
(*@\\\0000001001*)
(*@/// procedure Tmainform.btn_upClick(Sender: TObject); *)
procedure Tmainform.btn_upClick(Sender: TObject);
begin
  if ftp.busy then EXIT;
  ftp.changedir('..');
  cbx_path.items.delete(cbx_path.items.count-1);
  cbx_path.itemindex:=cbx_path.items.count-1;
  getdir('.');
  end;
(*@\\\0000000401*)
(*@/// procedure Tmainform.mnu_viewClick(Sender: TObject); *)
procedure Tmainform.mnu_viewClick(Sender: TObject);
begin
  if false then
  else if sender=mnu_view_list then begin
    dirview.viewstyle:=vslist;
    btn_list.down:=true;
    end
  else if sender=mnu_view_details then begin
    dirview.viewstyle:=vsReport;
    btn_details.down:=true;
    end
  else if sender=mnu_view_big then
    dirview.viewstyle:=vsIcon
  else if sender=mnu_view_small then
    dirview.viewstyle:=vsSmallIcon;
  end;
(*@\\\*)
(*@/// procedure Tmainform.mnu_sortClick(Sender: TObject); *)
procedure Tmainform.mnu_sortClick(Sender: TObject);
begin
  dirview.customsort(sortlist,TMenuItem(sender).tag);
  end;
(*@\\\0000000403*)
(*@/// procedure Tmainform.dirviewColumnClick(Sender:TObject; Column:TListColumn); *)
procedure Tmainform.dirviewColumnClick(Sender: TObject; Column: TListColumn);
var
  i: integer;
begin
  for i:=dirview.columns.count-1 downto 0 do
    if dirview.column[i]=column then
      dirview.customsort(sortlist,i);
  end;
(*@\\\*)
(*@/// procedure Tmainform.cbx_pathDrawItem(Control: TWinControl; Index: Integer; *)
procedure Tmainform.cbx_pathDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  icon: TIcon;
  ins: integer;
begin
  (* any other way to decide wether header line or not? *)
  if rect.top>10 then
    ins:=index*10
  else
    ins:=0;
  cbx_path.canvas.textrect(rect,rect.left+ins+23,rect.top,
    cbx_path.items[index]);
  if index=0 then icon:=icon_host
             else icon:=icon_dir;
  drawiconex(cbx_path.canvas.handle,rect.left+ins+3,rect.top,
    icon.handle,16,16,0,0,di_normal);
  end;
(*@\\\0000000801*)
(*@/// procedure Tmainform.cbx_pathDblClick(Sender: TObject); *)
procedure Tmainform.cbx_pathDblClick(Sender: TObject);
var
  changed: boolean;
begin
  if ftp.busy then EXIT;
  changed:=false;
  while cbx_path.itemindex<cbx_path.items.count-1 do begin
    ftp.changedir('..');
    cbx_path.items.delete(cbx_path.items.count-1);
    changed:=true;
    end;
  if changed then getdir('.');
  end;
(*@\\\0000000601*)
(*@/// procedure Tmainform.chk_asyncClick(Sender: TObject); *)
procedure Tmainform.chk_asyncClick(Sender: TObject);
begin
  ftp.async:=chk_async.checked;
  end;
(*@\\\*)

(*@/// procedure Tmainform.ftp_complete(Sender:TObject; mode: t_ftp_mode); *)
procedure Tmainform.ftp_complete(Sender:TObject; mode: t_ftp_mode);
begin
  if mode=tftp_download then begin
    TMemorystream(ftp.stream).savetofile(dlg_save.filename);
    end;
  end;
(*@\\\0000000401*)
(*@/// procedure Tmainform.ftp_data(Sender:TObject; mode: t_ftp_mode; data:integer); *)
procedure Tmainform.ftp_data(Sender:TObject; mode: t_ftp_mode; data:integer);
begin
  if mode=tftp_download then begin
    size:=size+data;
    if t_ftp(sender).size=0 then
      status.simpletext:=inttostr(size)+' Bytes received'
    else
      status.simpletext:=inttostr(size)+' of '+
                         inttostr(t_ftp(sender).size)+' Bytes received'
    end;
  end;
(*@\\\003C000801000801000923000935000801*)
(*@/// procedure Tmainform.ftp_trace(const s: string; level: TTraceLevel); *)
procedure Tmainform.ftp_trace(const s: string; level: TTraceLevel);
begin
  case level of
    tt_proto_sent, tt_proto_get: status.simpletext:=s;
    end;
  end;
(*@\\\0000000201*)
(*@\\\0000000701*)
end.
(*@\\\0000000301*)
