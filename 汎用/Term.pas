unit Term;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CONSOLE, ExtCtrls, Buttons, StdCtrls,Clipbrd;

type
  TTerminal = class(TCONSOLEWindow)
    Panel3: TPanel;
    AcceptKey: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton4: TSpeedButton;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  Terminal: TTerminal;

implementation

uses Main,MVCL;

{$R *.DFM}

procedure TTerminal.FormKeyPress(Sender: TObject; var Key: Char);
begin

  inherited;

  If AcceptKey.Down then
   Begin
     MainForm.Puts(Key);
     Key := #0;
   End;

end;

procedure TTerminal.SpeedButton1Click(Sender: TObject);
begin

  inherited;
  Mt.Terminate;
  Caption := 'ターミナル / 切断しました..'+MainForm.TCP.Host;


end;











procedure TTerminal.SpeedButton2Click(Sender: TObject);
begin

  inherited;
  Logs.Clear;
  Logs.Add('');
  Logs.Add('');



end;

procedure TTerminal.Timer1Timer(Sender: TObject);
begin
  inherited;

  if IntToStr(Logs.Count)<>Label4.Caption then
   Label4.Caption := IntToStr(Logs.Count);

end;




procedure TTerminal.SpeedButton4Click(Sender: TObject);
begin
  inherited;
  MainForm.Puts(ClipBoard.AsText);

end;

end.
