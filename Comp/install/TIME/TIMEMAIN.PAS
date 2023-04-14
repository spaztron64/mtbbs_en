unit timemain;
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
  time: T_Time;
  lbl_host: TLabel;
  edt_hostname: TEdit;
  lbl_time: TLabel;
  edt_time: TEdit;
  btn_action: TButton;
  btn_set: TButton;
  lbl_offset: TLabel;
  edt_offset: TEdit;
  procedure btn_actionClick(Sender: TObject);
  procedure btn_setClick(Sender: TObject);
private
  offset: integer;
end;
(*@\\\0000000C01*)

procedure SetDate(y:word; m,d: byte);
procedure SetTime(h,m,s,ms: byte);

var
  Form1: TForm1;
(*@\\\0000000601*)
(*@/// implementation *)
implementation

{$R *.DFM}

(*@/// procedure SetDate(y:word; m,d: byte); *)
procedure SetDate(y:word; m,d: byte);
(*@/// 16bit version - calling INT $21 subcode $2b *)
(*$ifdef ver80 *)
(*@/// procedure SetDateDOS(y:word; m,d: byte); *)
procedure SetDateDOS(y:word; m,d: byte);
assembler;
asm
  mov   ah,$2b
  mov   dl,[d]
  mov   dh,[m]
  mov   cx,[y]
  int   $21
  end;
(*@\\\*)
type
(*@///   TSystemTime = record *)
PSystemTime = ^TSystemTime;
TSystemTime = record
  wYear: Word;
  wMonth: Word;
  wDayOfWeek: Word;
  wDay: Word;
  wHour: Word;
  wMinute: Word;
  wSecond: Word;
  wMilliseconds: Word;
end;
(*@\\\*)
var
  LL32:function (LibFileName: PChar; handle: longint; special: longint):Longint;
  FL32:function (hDll: Longint):boolean;
  GA32:function (hDll: Longint; functionname: PChar):longint;
  CP32:function (buffer:TSystemTime; prochandle,adressconvert,dwParams:Longint):longint;
  hdll32,dummy,farproc,farproc2: longint;
  hdll:THandle;
  systime : TSystemTime;
begin
  hDll:=GetModuleHandle('kernel');                  { get the 16bit handle of kernel }
  @LL32:=GetProcAddress(hdll,'LoadLibraryEx32W');   { get the thunking layer functions }
  @FL32:=GetProcAddress(hdll,'FreeLibrary32W');
  @GA32:=GetProcAddress(hdll,'GetProcAddress32W');
  @CP32:=GetProcAddress(hdll,'CallProc32W');
(*@///   if possible then   call Get/SetSystemTime via Thunking *)
if (@LL32<>NIL) and
   (@FL32<>NIL) and
   (@GA32<>NIL) and
   (@CP32<>NIL) then begin
  hDll32:=LL32('kernel32.dll',dummy,1);            { get the 32bit handle of kernel32 }
  farproc:=GA32(hDll32,'GetLocalTime');  { get the 32bit adress of the function }
  CP32(systime,farproc,1,1);
  systime.wday := d;
  systime.wmonth := m;
  systime.wyear := y;
  farproc2:=GA32(hDll32,'SetLocalTime');  { get the 32bit adress of the function }
  CP32(systime,farproc2,1,1);
  FL32(hDll32);                                    { and free the 32bit dll }
  end
(*@\\\*)
  else SetDateDOS(y,m,d);
  end;
(*@\\\*)
(*@/// 32bit version - calling API function SetLocalTime *)
(*$else *)
var
  systime : TSystemTime;
begin
  GetLocalTime(systime);   (* to leave the time unchanged *)
  systime.wday := d;
  systime.wmonth := m;
  systime.wyear := y;
  SetLocalTime(systime);
  end;
(*$endif *)
(*@\\\0000000601*)
(*@\\\0000000201*)
(*@/// procedure SetTime(h,m,s,ms: byte); *)
procedure SetTime(h,m,s,ms: byte);
(*@/// 16bit version - calling INT $21 subcode $2b *)
(*$ifdef ver80 *)
(*@/// procedure SetTimeDOS(h,m,s,ms: byte); *)
procedure SetTimeDOS(h,m,s,ms: byte);
assembler;
asm
  mov   ah,$2d
  mov   ch,[h]
  mov   cl,[m]
  mov   dh,[s]
  mov   dl,[ms]
  int   $21
  end;
(*@\\\*)
type
(*@///   TSystemTime = record *)
PSystemTime = ^TSystemTime;
TSystemTime = record
  wYear: Word;
  wMonth: Word;
  wDayOfWeek: Word;
  wDay: Word;
  wHour: Word;
  wMinute: Word;
  wSecond: Word;
  wMilliseconds: Word;
end;
(*@\\\*)
var
  LL32:function (LibFileName: PChar; handle: longint; special: longint):Longint;
  FL32:function (hDll: Longint):boolean;
  GA32:function (hDll: Longint; functionname: PChar):longint;
  CP32:function (buffer:TSystemTime; prochandle,adressconvert,dwParams:Longint):longint;
  hdll32,dummy,farproc,farproc2: longint;
  hdll:THandle;
  systime : TSystemTime;
begin
  hDll:=GetModuleHandle('kernel');                  { get the 16bit handle of kernel }
  @LL32:=GetProcAddress(hdll,'LoadLibraryEx32W');   { get the thunking layer functions }
  @FL32:=GetProcAddress(hdll,'FreeLibrary32W');
  @GA32:=GetProcAddress(hdll,'GetProcAddress32W');
  @CP32:=GetProcAddress(hdll,'CallProc32W');
(*@///   if possible then   call Get/SetSystemTime via Thunking *)
if (@LL32<>NIL) and
   (@FL32<>NIL) and
   (@GA32<>NIL) and
   (@CP32<>NIL) then begin
  hDll32:=LL32('kernel32.dll',dummy,1);            { get the 32bit handle of kernel32 }
  farproc:=GA32(hDll32,'GetLocalTime');  { get the 32bit adress of the function }
  CP32(systime,farproc,1,1);
  systime.whour := h;
  systime.wminute := m;
  systime.wsecond := s;
  systime.wmilliseconds := ms;
  farproc2:=GA32(hDll32,'SetLocalTime');  { get the 32bit adress of the function }
  CP32(systime,farproc2,1,1);
  FL32(hDll32);                                    { and free the 32bit dll }
  end
(*@\\\0000000C01*)
  else SetTimeDOS(h,m,s,ms);
  end;
(*@\\\0000001301*)
(*@/// 32bit version - calling API function SetLocalTime *)
(*$else *)
var
  systime : TSystemTime;
begin
  GetLocalTime(systime);  (* to leave the date unchanged *)
  systime.whour := h;
  systime.wminute := m;
  systime.wsecond := s;
  systime.wmilliseconds := ms;
  SetLocalTime(systime);
  end;
(*$endif *)
(*@\\\0000000601*)
(*@\\\0000000201*)

(*@/// procedure TForm1.btn_actionClick(Sender: TObject); *)
procedure TForm1.btn_actionClick(Sender: TObject);
begin
  time.hostname:=edt_hostname.text;
  time.action;
  edt_time.text:=datetimetostr(time.time);
  offset:=round((time.time-now)*86400);
  edt_offset.text:=inttostr(offset)+' seconds';
  btn_set.enabled:=true;
  end;
(*@\\\0000000301*)
(*@/// procedure TForm1.btn_setClick(Sender: TObject); *)
procedure TForm1.btn_setClick(Sender: TObject);
var
  y,m,d,h,n,s,ms: word;
  new_now: TDateTime;
begin
  if offset<>0 then begin
    new_now:=now+offset/86400;
    decodedate(new_now,y,m,d);
    decodetime(new_now,h,n,s,ms);
    setdate(y,m,d);
    settime(h,n,s,ms);
    end;
  end;
(*@\\\0000000B01*)
(*@\\\0000000901*)
end.
(*@\\\0000000301*)
