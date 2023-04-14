unit TMyoTerm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CONSOLE, StdCtrls, WSockets, ExtCtrls, Buttons;

type
  TMyoTerm = class(TCONSOLEWindow)
    TCPClient1: TTCPClient;
    KeyAccept: TSpeedButton;
    Label2: TLabel;
    Host: TEdit;
    Connecting: TSpeedButton;
    procedure ConnectingClick(Sender: TObject);
    procedure KeyAcceptClick(Sender: TObject);
  private

     _BackScroll   : Boolean;
     _KeyEnable    : Boolean;
     _Connect      : Boolean;

     procedure BackScroll(Enable : Boolean);
     procedure KeyEnable(Enable : Boolean);
     procedure Connect(Enable : Boolean);
     Procedure Puts(S : String);
     procedure ClearLogs(B:Boolean);

  public

      procedure ClearLogs(B:Boolean);

  end;

var
  MyoTerm: TMyoTerm;

implementation

{$R *.DFM}



procedure TMyoTerm.KeyEnable(Enable : Boolean);
Begin

  KeyAccept.Down := Enable;
  KeyAccept.Refresh;
  _KeyEnable     := Enable;

End;

procedure TMyoTerm.Connect(Enable : Boolean);
Begin

   Connecting.Down := False;
   Connecting.Refresh;

   Mode := cm_Telnet;

     if  _Connect then
      Begin
          _Connect := False;
          TCPClient1.Close;
      End else
      Begin
          TCPClient1.Close;
          TCPClient1.Host := Host.Text;
          TCPClient1.Open;
      End;

End;

Procedure Puts(S : String);
Var
   i : Integer;

  Function FreeSize : Integer;
  Begin
    if MyoTerm.Srp<=MyoTerm.Swp then
      Result := MyoTerm.Srp + (4095-MyoTerm.Swp)
    Else
      Result := MyoTerm.Srp - MyoTerm.Swp;
  End;


Begin

   For i:=1 to Length(s) do
    Begin
      MyoTerm.SendStrBuf[MyoTerm.SWp] := s[i];
      MyoTerm.SWp :=(MyoTerm.Swp+1) mod 4095;
    End;

End;


procedure TMyoTerm.ClearLogs(B:Boolean);
begin

  DrawPoint := 0;
  SelStartX:=0;
  SelStartY:=0;
  SelEndX:=0;
  SelEndY:=0;
  BackTextSelected:=False;
  BackTextDragging:=False;
  Logs.Clear;
   Logs.Add('');
   If b then Begin
    Logs.Add('--------------------------------------------------------');
    Logs.Add(' 　シンプル通信ソフト ＭｙｏＴＥＬＮＥＴ '+MyoTelNetVersion);
    Logs.Add('     '+MyoTelnetCopyright);
    Logs.Add('--------------------------------------------------------');
    Logs.Add('');
    Logs.Add('　本ソフトウェアは以下のコンポーネントを使用しています。');
    Logs.Add('');
{    Logs.Add('【*シリアル送受信部*】');
    Logs.Add('  Delphiシリアル通信コンポーネント"TComm" / Duke氏');
    Logs.Add('');
    Logs.Add('【*ファイル転送部*】');
    Logs.Add('  Delphi X,Y,ZMODEM,MLINK ﾌｧｲﾙ転送ｺﾝﾎﾟｰﾈﾝﾄ"TMyoComm" / MYO');
    Logs.Add('　 KT621ASR.LZH ホストプログラム KTBBS ソースファイルの');
    Logs.Add('   TransSys.PasをDelphi用に改造した物です。');
    Logs.Add(' 　【ＨＡＬ】さん、Seishiさん、もろぼし☆らむ さん、ありがとうございました。');
}
    Logs.Add('【*TCP/IP通信部*】');
    Logs.Add('  WSockets version 1.20 - Delphi 2 and 3 WinSocket Classes: ');
    Logs.Add('  Copyright (C) 1997 by Robert T.Palmqvist');
    Logs.Add('');
    Logs.Add('【*その他*】');
    Logs.Add('　Delphi 文字列リストオブジェクト　"TLightStrings" / べあ氏');
    Logs.Add('');

   End;
    Logs.Add('');

   BackTextPanelResize(MyoTerm);
   BackTextScrollBar.Position := BackTextScrollBar.Min;

  MainTextRePaint := True;

end;



Procedure Puts(S : String);
Var
   i : Integer;

  Function FreeSize : Integer;
  Begin
    if MyoTerm.Srp<=MyoTerm.Swp then
      Result := MyoTerm.Srp + (4095-MyoTerm.Swp)
    Else
      Result := MyoTerm.Srp - MyoTerm.Swp;
  End;


Begin

   For i:=1 to Length(s) do
    Begin
      MyoTerm.SendStrBuf[MyoTerm.SWp] := s[i];
      MyoTerm.SWp :=(MyoTerm.Swp+1) mod 4095;
    End;

End;







procedure TMyoTerm.ConnectingClick(Sender: TObject);
begin

   Connect(Not(_Connect));

end;

procedure TMyoTerm.KeyAcceptClick(Sender: TObject);
begin

      if _KeyEnable then KeyEnable(False)
                    else KeyEnable(True);

end;

end.
