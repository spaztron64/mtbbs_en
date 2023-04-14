unit Monitor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CONSOLE, StdCtrls, Buttons, ExtCtrls;

type

  TMonitorWindow = class(TCONSOLEWindow)
     BitBtn1: TBitBtn;
     procedure BitBtn1Click(Sender: TObject);
     procedure FormDestroy(Sender: TObject);
     procedure FormClose(Sender: TObject;
      var Action: TCloseAction);
  private
    { Private êÈåæ }
  public

     Fch : Integer;

  end;


implementation

uses Main;

{$R *.DFM}

procedure TMonitorWindow.FormDestroy(Sender: TObject);
begin

  MainForm.Chs[FCh].MonitorWindow := Nil;
  inherited;

end;

procedure TMonitorWindow.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

  Action := caFree;

  inherited;

end;

procedure TMonitorWindow.BitBtn1Click(Sender: TObject);
begin

     Close;

end;

end.
