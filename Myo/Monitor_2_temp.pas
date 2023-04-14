unit Monitor_2_temp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CONSOLE, Buttons, ExtCtrls, StdCtrls;

type
  TMonitorWindow2 = class(TCONSOLEWindow)
    BitBtn1: TBitBtn;
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private êÈåæ }
  public

     Fch : Integer;

  end;


implementation

uses Main;

{$R *.DFM}

procedure TMonitorWindow2.FormDestroy(Sender: TObject);
begin

  MainForm.Chs[FCh].MonitorWindow := Nil;
  inherited;

end;

procedure TMonitorWindow2.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

  Action := caFree;

  inherited;

end;

procedure TMonitorWindow2.BitBtn1Click(Sender: TObject);
begin

     Close;

end;

end.
