unit Chkmain;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls,
  WinSock;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Ok: TButton;
    Label11: TLabel;
    Label12: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Image1: TImage;
    procedure OkClick(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.OkClick(Sender: TObject);
var
  pWsData: TWSADATA;
begin
  if Ok.Default then halt
          else begin
            Ok.Default := True;
            Ok.Caption := 'OK';
            if (WSAStartup($0101, pWsData) = 0) then begin

               { Check return value of WSAStartup }

               with Form1, pWsData do begin
                   Label7.Caption := IntToHex(longint(wVersion), 4);
                   Label8.Caption := szSystemStatus;
                   Label9.Caption := IntToStr(iMaxSockets);
                   Label10.Caption := IntToStr(iMaxUdpDg);
                   Label12.Caption := StrPas(szDescription);
               end;
               WSACleanUp;
            end;
  end;
end;

end.
