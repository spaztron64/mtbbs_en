unit Mainform;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls,
  WinSock;

type
  TForm2 = class(TForm)
    Exit: TButton;
    Label1: TLabel;
    Image1: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Progress: TLabel;
    Bevel1: TBevel;
    Cancel: TButton;
    procedure CancelClick(Sender: TObject);
    procedure ExitClick(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  Form2: TForm2;

implementation

{$R *.DFM}

procedure TForm2.CancelClick(Sender: TObject);
begin
  halt;
end;

procedure TForm2.ExitClick(Sender: TObject);
var
  cnt: integer;
  WsaData: TWSADATA;

begin
  if Exit.Default = False then begin
    Cancel.Enabled := False;
    Exit.Enabled := False;
    Exit.Default := True;
    Exit.Caption := 'Exit';

  { Closing all SOCKET }

    if (WSAStartUP($0101, WsaData) = 0) then begin
      for cnt := 1 to WsaData.iMaxSockets do begin
        closesocket(cnt);
        Progress.Caption := IntToStr(cnt);
      end;
    end;
    Exit.Enabled := True;
  end
  else
    close;
end;

end.
