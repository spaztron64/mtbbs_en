unit Packet;

interface

uses SysUtils, WinProcs, WinTypes, Messages,
     WinSock;

const
  { Request command identification }
  CMD_STOPSERVER = $FF;

  { System common Packet header difinication }
  HEADER_SIZE = 12;
  DATA_SIZE   = 2048;

type
  Theader = record
              Task_ID : byte;
              Req_ID  : byte;
              GUI_ID  : byte;
              SYS_ID  : byte;
              Len     : longint;
              Results : byte;
              unused  : array[1..3] of byte;
  end;

  Ppacket = ^Tpacket;

  Tpacket = record
              header: Theader;
              data  : array[0..DATA_SIZE] of char;
  end;

  function  GetLogFileName(ID: string): TFileName;
  procedure openLog(fname: TFileName);
  procedure closeLog(var flag: boolean);
  procedure sendLog(name: string; var buf: Tpacket);
  procedure recvLog(name: string; var buf: Tpacket);

implementation

var
  LogFd: TextFile;

function GetLogFileName(ID: string): TFileName;
begin
  Result := Copy(ID + FormatDateTime('hhnnss', Time), 1, 8) + '.LOG';
end;

procedure openLog(fname: TFileName);
begin
  AssignFile(LogFd, fname);
  Rewrite(LogFd);
end;

procedure closeLog(var flag: boolean);
begin
  if flag = True then closeFile(LogFd);
  flag := False;
end;

procedure sendLog(name: string; var buf: Tpacket);
var
  Hour, Min, Sec, MSec: word;
  rlen: integer;
begin
  DecodeTime(Time, Hour, Min, Sec, Msec);
  with buf.header do begin
    rlen := ntohl(Len);
    write(LogFd,
               IntToStr(Hour):2, ':',
               IntToStr(Min):2,  ':',
               IntToStr(Sec):2,  ':',
               IntToStr(MSec):3, ' ',
               name:8,
               ' S $', IntToHex(Task_ID, 2),
                 ' $', IntToHex(Req_ID, 2),
                 ' $', IntToHex(GUI_ID, 2),
                 ' $', IntToHex(SYS_ID, 2),
                 '  ', IntToStr(rLen):4,
                 ' $', IntToHex(Results, 2));
    if rLen <= 0 then
      writeln(LogFd)
    else begin
      buf.Data[rLen + 1] := Char($00);
      writeln(LogFd, ' ', StrPas(buf.Data));
    end;
  end;
end;

procedure recvLog(name: string; var buf: Tpacket);
var
  Hour, Min, Sec, MSec: word;
  rLen : integer;
begin
  DecodeTime(Time, Hour, Min, Sec, Msec);
  with buf.header do begin
    rlen := ntohl(Len);
    write(LogFd,
               IntToStr(Hour):2, ':',
               IntToStr(Min):2,  ':',
               IntToStr(Sec):2,  ':',
               IntToStr(MSec):3, ' ',
               name:8,
               ' R $', IntToHex(Task_ID, 2),
                 ' $', IntToHex(Req_ID, 2),
                 ' $', IntToHex(GUI_ID, 2),
                 ' $', IntToHex(SYS_ID, 2),
                 '  ', IntToStr(rLen):4,
                 ' $', IntToHex(Results, 2));
    if rLen <= 0 then
      writeln(LogFd)
    else begin
      buf.Data[rLen + 1] := Char($00);
      writeln(LogFd, ' ', StrPas(buf.Data));
    end;
  end;
end;

end.
