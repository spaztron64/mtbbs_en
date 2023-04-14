unit status;
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
(*@\\\0000001008*)

type
(*@///   Tfrm_status = class(TForm) *)
Tfrm_status = class(TForm)
    memo: TMemo;
public
  procedure DoTrace(const s:string; level:TTraceLevel);
end;
(*@\\\0000000436*)

var
  frm_status: Tfrm_status;
(*@\\\0000000301*)
(*@/// implementation *)
implementation

{$R *.DFM}

(*@/// procedure Tfrm_status.DoTrace(const s:string; level:TTraceLevel); *)
procedure Tfrm_status.DoTrace(const s:string; level:TTraceLevel);
begin
  case level of
    tt_proto_get, tt_proto_sent: memo.lines.add(s);
    end;
  end;
(*@\\\000E000135000140000422000422*)
(*@\\\0000000501*)
end.
(*@\\\0000000201*)
