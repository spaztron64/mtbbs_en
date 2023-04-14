unit newsmain;
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
  tcpip,
  StdCtrls,
  Spin,
  Menus,
  inifiles;
(*@\\\*)

type
(*@///   Tmainform = class(TForm) *)
Tmainform = class(TForm)
  lbx_newsgroups: TListBox;
  edt_hostname: TEdit;
  lbl_hostname: TLabel;
  lbl_groups: TLabel;
  edt_article: TSpinEdit;
  lbl_article: TLabel;
  mem_article: TMemo;
  btn_connect: TButton;
  lbl_count: TLabel;
  NNTP: T_NNTP;
  mnu_groups: TPopupMenu;
  mnu_getall: TMenuItem;
  mnu_getnew: TMenuItem;
  mnu_article: TPopupMenu;
  mnu_save: TMenuItem;
  dlg_save: TSaveDialog;
  procedure lbx_newsgroupsDblClick(Sender: TObject);
  procedure btn_connectClick(Sender: TObject);
  procedure edt_articleChange(Sender: TObject);
  procedure mnu_getallClick(Sender: TObject);
  procedure mnu_getnewClick(Sender: TObject);
  procedure FormCreate(Sender: TObject);
  procedure FormClose(Sender: TObject; var Action: TCloseAction);
  procedure mnu_saveClick(Sender: TObject);
private
  last: integer;
  active: boolean;
end;
(*@\\\0000001D01*)

var
  mainform: Tmainform;
(*@\\\0000000601*)
(*@/// implementation *)
implementation

{$R *.DFM}

const
  ininame='mininews.ini';

(*@/// procedure Tmainform.lbx_newsgroupsDblClick(Sender: TObject); *)
procedure Tmainform.lbx_newsgroupsDblClick(Sender: TObject);
var
  lo,hi,count: integer;
begin
  try
    screen.cursor:=crHourglass;
    nntp.setgroup(lbx_newsgroups.items[lbx_newsgroups.itemindex],lo,hi,count);
    edt_article.minvalue:=lo;
    edt_article.maxvalue:=hi;
    edt_article.value:=lo;
    lbl_count.caption:='Articles: '+inttostr(count);
  except
    lbx_newsgroups.items.delete(lbx_newsgroups.itemindex);
    end;
  screen.cursor:=crDefault;
  end;
(*@\\\0000001003*)
(*@/// procedure Tmainform.btn_connectClick(Sender: TObject); *)
procedure Tmainform.btn_connectClick(Sender: TObject);
begin
  nntp.hostname:=edt_hostname.text;
  screen.cursor:=crHourglass;
  nntp.login;
  screen.cursor:=crDefault;
  lbx_newsgroups.enabled:=true;
  edt_article.enabled:=true;
  end;
(*@\\\0000000903*)
(*@/// procedure Tmainform.edt_articleChange(Sender: TObject); *)
procedure Tmainform.edt_articleChange(Sender: TObject);
begin
  screen.cursor:=crHourglass;
  nntp.getarticlenr(edt_article.value);
  mem_article.lines.assign(nntp.news);
  screen.cursor:=crDefault;
  end;
(*@\\\0000000703*)
(*@/// procedure Tmainform.mnu_getallClick(Sender: TObject); *)
procedure Tmainform.mnu_getallClick(Sender: TObject);
begin
  if MessageDlg('This may take some time. Are you sure?',
    mtConfirmation,mbOkCancel,0) = mrOK then begin
    screen.cursor:=crHourglass;
    nntp.getallnewsgroups;
    lbx_newsgroups.items.assign(nntp.newsgroups);
    last:=round(now);
    screen.cursor:=crDefault;
    end;
  end;
(*@\\\0000000B03*)
(*@/// procedure Tmainform.mnu_getnewClick(Sender: TObject); *)
procedure Tmainform.mnu_getnewClick(Sender: TObject);
begin
  screen.cursor:=crHourglass;
  nntp.getnewnewsgroups(last);
  lbx_newsgroups.items.addstrings(nntp.newsgroups);
  last:=round(now);
  screen.cursor:=crDefault;
  end;
(*@\\\0000000803*)
(*@/// procedure Tmainform.FormCreate(Sender: TObject); *)
procedure Tmainform.FormCreate(Sender: TObject);
var
  ini: TInifile;
  i: integer;
  s: string;
begin
  ini:=TInifile.create(ininame);
  last:=ini.readinteger('Data','NewsgroupsLast',round(now));
  i:=0;
  while true do begin
    s:=ini.readstring('Newsgroups',inttostr(i),'*');
    if s='*' then
    BREAK
      else if lbx_newsgroups.items.indexof(s)=-1 then
        lbx_newsgroups.items.add(s);
    inc(i);
    end;
  end;
(*@\\\0000001203*)
(*@/// procedure Tmainform.FormClose(Sender: TObject; var Action: TCloseAction); *)
procedure Tmainform.FormClose(Sender: TObject; var Action: TCloseAction);
var
  ini: TInifile;
  i: integer;
begin
  ini:=TInifile.create(ininame);
  ini.writeinteger('Data','NewsgroupsLast',last);
  for i:=0 to lbx_newsgroups.items.count-1 do
    ini.writestring('Newsgroups',inttostr(i),lbx_newsgroups.items[i]);
  ini.free;
  end;
(*@\\\0000000B03*)
(*@/// procedure Tmainform.mnu_saveClick(Sender: TObject); *)
procedure Tmainform.mnu_saveClick(Sender: TObject);
begin
  if dlg_save.execute then
    mem_article.lines.savetofile(dlg_save.filename);
  end;
(*@\\\0000000401*)
(*@\\\0000000C01*)
end.
(*@\\\0000000301*)
