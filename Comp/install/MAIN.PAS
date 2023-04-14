unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls,
  Nb, ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Memo1: TMemo;
    Panel2: TPanel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


{---------------------------------------------}
{ enumerate the lana's  - works only on WIN32 }
{---------------------------------------------}
function NbLanaEnum: TLana_Enum;
var
  NCB: TNCB;
  L_Enum: TLana_Enum;
  RetCode: Word;
begin
{$IFDEF WIN32}
  FillChar(NCB, SizeOf(NCB), 0);
  FillChar(L_Enum, SizeOf(TLana_Enum), 0);
  NCB.Command := NCB_ENUM;
  NCB.Buf := @L_Enum;
  NCB.Length := Sizeof(L_Enum);
  RetCode := NetBiosCmd(NCB);
  if RetCode <> NRC_GOODRET then begin
    L_Enum.Length := 0;
    L_Enum.Lana[0] := Byte(RetCode);
  end;
{$ELSE}                     { not supported for WIN16, fake LANA 0 }
  L_Enum.Length := 1;
  L_Enum.Lana[0] := 0;
{$ENDIF}
  Result := L_Enum;
end;

{----------------------------------------}
{ Reset the lana - don't for WIN16 !     }
{----------------------------------------}
function NbReset(l: Byte): Word;
var
  NCB: TNCB;
begin
{$IFNDEF WIN32}             { will reset all your connections for WIN16 }
  Result := NRC_GOODRET;    { so just fake a reset for Win16            }
{$ELSE}
  FillChar(NCB, SizeOf(NCB), 0);
  NCB.Command := NCB_RESET;
  NCB.Lana_Num := l;
  Result := NetBiosCmd(NCB);
{$ENDIF}
end;
{----------------------------------------}
{ return the MAC address of an interface }
{ in the form of a string like :         }
{ 'xx:xx:xx:xx:xx:xx'                    }
{ using the definitions in nb.pas        }
{----------------------------------------}

function NbGetMacAddr(LanaNum: Integer): String;
var
  NCB: TNCB;
  AdpStat: TAdpStat;
  RetCode: Word;
begin
  FillChar(NCB, SizeOf(NCB), 0);
  FillChar(AdpStat, SizeOf(AdpStat), 0);
  NCB.Command := NCB_ADPSTAT;
  NCB.Buf := @AdpStat;
  NCB.Length := Sizeof(AdpStat);
  FillChar(NCB.CallName, Sizeof(TNBName), $20);
  NCB.CallName[0] := Byte('*');
  NCB.Lana_Num := LanaNum;
  RetCode := NetBiosCmd(NCB);
  if RetCode = NRC_GOODRET then begin
    Result := Format('%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x',
                   [AdpStat.ID[0],
                   AdpStat.ID[1],
                   AdpStat.ID[2],
                   AdpStat.ID[3],
                   AdpStat.ID[4],
                   AdpStat.ID[5]
                   ]);
  end else begin
    Result := '??:??:??:??:??:??';
  end;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  L_Enum : TLana_Enum;
  RetCode: Word;
  i: Integer;
begin
  L_Enum := NbLanaEnum;                       { enumerate lanas for WIN NT }
  if L_Enum.Length = 0 then begin
    Button1.Caption := Format('LanaEnum err=%2.2x', [L_Enum.Lana[0]]);
    exit;
  end;

  for i := 0 to (L_Enum.Length - 1)do begin   { for every lana found       }

    RetCode := NbReset(L_Enum.Lana[i]);       { Reset lana for WIN NT      }
    if RetCode <> NRC_GOODRET then begin
       Button1.Caption := Format('Reset Lana %d err=%2.2x',[i, RetCode]);
       exit;
    end;
                                             { Get MAC Address             }
    Memo1.Lines.Add(Format('Lana %x = %s', [L_Enum.Lana[i], NbGetMacAddr(i)]));

  end;

  Button1.Caption := 'Stop';
end;

end.
