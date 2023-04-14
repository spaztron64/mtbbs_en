unit d_main;
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
  tcpip,
  Menus,
  inifiles;
(*@\\\0000000201*)

type
(*@///   TUserData = class(TObject) *)
TUserData = class(TObject)
private
  f_answer: TStringlist;
  procedure SetAnswer(value:TStringlist);
public
  Requests: integer;
  property Answer: TStringlist read f_answer write setanswer;
  constructor Create;
  destructor Destroy; override;
  end;
(*@\\\0000000401*)
(*@///   TForm1 = class(TForm) *)
Tfrm_main = class(TForm)
  mem_text: TMemo;
  Finger: T_Fingerd;
  lbx_user: TListBox;
  mnu_pop: TPopupMenu;
  mnu_New: TMenuItem;
  mnu_del: TMenuItem;
  lbl_request: TLabel;
  lbl_no_req: TLabel;
  btn_save: TButton;
  procedure FingerFingerRequest(Sender: TObject; FingerInfo: TFingerInfo);
  procedure lbx_userClick(Sender: TObject);
  procedure mnuClick(Sender: TObject);
  procedure FormCreate(Sender: TObject);
  procedure mem_textChange(Sender: TObject);
  procedure btn_saveClick(Sender: TObject);
public
  current: integer;
end;
(*@\\\0000000B0D*)

var
  frm_main: Tfrm_main;
(*@\\\0000000701*)
(*@/// implementation *)
implementation

uses d_user;

const
  s_no_user_supplied='Default';
  s_inifile_name='FingerDemon.ini';

{$R *.DFM}

(*@/// constructor TUserData.Create; *)
constructor TUserData.Create;
begin
  inherited Create;
  f_answer:=TStringList.Create;
  end;
(*@\\\0000000314*)
(*@/// destructor TUserData.Destroy; *)
destructor TUserData.Destroy;
begin
  f_answer.Free;
  inherited destroy;
  end;
(*@\\\0000000415*)
(*@/// procedure TUserData.SetAnswer(value:TStringlist); *)
procedure TUserData.SetAnswer(value:TStringlist);
begin
  f_answer.assign(value);
  end;
(*@\\\0000000301*)

(*@/// procedure TForm1.FingerFingerRequest(Sender: TObject;FingerInfo: TFingerInfo); *)
procedure Tfrm_main.FingerFingerRequest(Sender: TObject;FingerInfo: TFingerInfo);
var
  i: integer;
  UserData: TUserData;
begin
  if fingerinfo.request='' then
    i:=lbx_user.items.indexof(s_no_user_supplied)
  else
    i:=lbx_user.items.indexof(fingerinfo.request);
  if i>=0 then begin
    UserData:=TUserData(lbx_user.items.objects[i]);
    Finger.answer:=UserData.answer;
    UserData.requests:=UserData.requests+1;
    if i=current then
      lbl_no_req.caption:=inttostr(userdata.requests);
    end
  else
    Finger.answer.clear;
  end;
(*@\\\0000000708*)

(*@/// procedure TForm1.lbx_userClick(Sender: TObject); *)
procedure Tfrm_main.lbx_userClick(Sender: TObject);
var
  UserData: TUserData;
begin
  current:=lbx_user.itemindex;
  UserData:=TUserData(lbx_user.items.objects[current]);
  mem_text.lines.assign(userdata.answer);
  lbl_no_req.caption:=inttostr(userdata.requests);
  end;
(*@\\\0000000115*)
(*@/// procedure TForm1.mnuClick(Sender: TObject); *)
procedure Tfrm_main.mnuClick(Sender: TObject);
var
  UserData: TUserData;
begin
  if sender=mnu_new then begin
    if frm_user.showmodal=mrOK then begin
      if lbx_user.items.indexof(frm_user.edt_user.text)=-1 then begin
        UserData:=TUserData.Create;
        lbx_user.items.addObject(frm_user.edt_user.text,Userdata);
        end;
      end;
    end
  else if sender=mnu_del then begin
    if lbx_user.itemindex>=0 then begin
      if current>lbx_user.itemindex then
        dec(current)
      else if current=lbx_user.itemindex then
        current:=-1;
      lbx_user.items.objects[lbx_user.itemindex].free;
      lbx_user.items.delete(lbx_user.itemindex);
      end;
    end
  end;
(*@\\\0000001101*)

(*@/// procedure TForm1.FormCreate(Sender: TObject); *)
procedure Tfrm_main.FormCreate(Sender: TObject);
var
  i,j: integer;
  UserData: TUserData;
  ini: TIniFile;
begin
  ini:=TIniFile.Create(s_inifile_name);
  ini.readsection('Users',lbx_user.items);
  for i:=0 to lbx_user.items.count-1 do begin
    lbx_user.items[i]:=ini.readstring('Users',lbx_user.items[i],'');
    Userdata:=TUserData.Create;
    lbx_user.items.objects[i]:=Userdata;
    ini.readsection('User '+lbx_user.items[i],userdata.answer);
    for j:=0 to userdata.answer.count-1 do
      userdata.answer.strings[j]:=ini.readstring('User '+lbx_user.items[i],
                                                 userdata.answer.strings[j],
                                                 '');
    end;
  if lbx_user.items.count=0 then begin
    UserData:=TUserData.Create;
    lbx_user.items.addobject(s_no_user_supplied,userdata);
    end;
  lbx_user.itemindex:=0;
  lbx_userClick(NIL);
  finger.action;      (* start the demon *)
  end;
(*@\\\0000000801*)

(*@/// procedure Tfrm_main.mem_textChange(Sender: TObject); *)
procedure Tfrm_main.mem_textChange(Sender: TObject);
var
  UserData: TUserData;
begin
  if current>=0 then begin
    UserData:=TUserData(lbx_user.items.objects[current]);
    userdata.answer.assign(mem_text.lines);
    end;
  end;
(*@\\\0000000108*)

(*@/// procedure Tfrm_main.btn_saveClick(Sender: TObject); *)
procedure Tfrm_main.btn_saveClick(Sender: TObject);
var
  i,j: integer;
  ini: TIniFile;
  UserData: TUserData;
  temp: TStringList;
begin
  ini:=TIniFile.Create(s_inifile_name);

  (* clean up the inifile *)
  temp:=TStringList.Create;
  ini.readsection('Users',temp);
  for i:=0 to temp.count-1 do begin
    temp.strings[i]:=ini.readstring('Users',temp.strings[i],'');
    ini.erasesection('User '+temp.strings[i]);
    end;
  temp.free;
  ini.erasesection('Users');

  (* save the data *)
  for i:=0 to lbx_user.items.count-1 do begin
    ini.writestring('Users',inttostr(i),lbx_user.items[i]);
    UserData:=TUserData(lbx_user.items.objects[i]);
    for j:=0 to userdata.answer.count-1 do
      ini.writestring('User '+lbx_user.items[i],inttostr(j),userdata.answer[j]);
    end;
  end;
(*@\\\0000000818*)
(*@\\\*)
end.
(*@\\\0000000201*)
