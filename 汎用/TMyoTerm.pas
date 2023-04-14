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
    Logs.Add(' �@�V���v���ʐM�\�t�g �l�����s�d�k�m�d�s '+MyoTelNetVersion);
    Logs.Add('     '+MyoTelnetCopyright);
    Logs.Add('--------------------------------------------------------');
    Logs.Add('');
    Logs.Add('�@�{�\�t�g�E�F�A�͈ȉ��̃R���|�[�l���g���g�p���Ă��܂��B');
    Logs.Add('');
{    Logs.Add('�y*�V���A������M��*�z');
    Logs.Add('  Delphi�V���A���ʐM�R���|�[�l���g"TComm" / Duke��');
    Logs.Add('');
    Logs.Add('�y*�t�@�C���]����*�z');
    Logs.Add('  Delphi X,Y,ZMODEM,MLINK ̧�ٓ]�����߰���"TMyoComm" / MYO');
    Logs.Add('�@ KT621ASR.LZH �z�X�g�v���O���� KTBBS �\�[�X�t�@�C����');
    Logs.Add('   TransSys.Pas��Delphi�p�ɉ����������ł��B');
    Logs.Add(' �@�y�g�`�k�z����ASeishi����A����ڂ������ ����A���肪�Ƃ��������܂����B');
}
    Logs.Add('�y*TCP/IP�ʐM��*�z');
    Logs.Add('  WSockets version 1.20 - Delphi 2 and 3 WinSocket Classes: ');
    Logs.Add('  Copyright (C) 1997 by Robert T.Palmqvist');
    Logs.Add('');
    Logs.Add('�y*���̑�*�z');
    Logs.Add('�@Delphi �����񃊃X�g�I�u�W�F�N�g�@"TLightStrings" / �ׂ���');
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
