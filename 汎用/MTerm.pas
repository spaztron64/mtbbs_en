unit MTerm;

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CONSOLE, StdCtrls, WSockets, ExtCtrls, Buttons, Comm, MyoComm;

Const
    MyoTelNetVersion   = 'Version 1.00β';
    MyoTelNetCopyright = 'Copyright (C) 1997.11 Yoshihiro Myokan.';

type
  TMyoTerm = class(TCONSOLEWindow)
    TCPClient1: TTCPClient;
    KeyAccept: TSpeedButton;
    Label2: TLabel;
    Host: TEdit;
    Connecting: TSpeedButton;
    MYOCOMM1: TMYOCOMM;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    MYOCOMM2: TMYOCOMM;
    MYOCOMM3: TMYOCOMM;
    LineEdit: TPanel;
    Edit1: TEdit;
    Panel5: TPanel;
    Button1: TButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    procedure ConnectingClick(Sender: TObject);
    procedure KeyAcceptClick(Sender: TObject);
    procedure TCPClient1Close(Sender: TObject; Socket: Integer);
    procedure TCPClient1Connect(Sender: TObject; Socket: Integer);
    procedure TCPClient1Data(Sender: TObject; Socket: Integer);
    procedure TCPClient1Error(Sender: TObject; Error: Integer;
      Msg: String);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
  private

     _BackScroll   : Boolean;
     _KeyEnable    : Boolean;
     _Connect      : Boolean;

      ReadMode : (RM_None,RM_IAC1,RM_IAC2);
          Mode : (CM_None,CM_TelNet,CM_Modem);

       SendStrBuf : Array[0..4096] of Char;
       SRp        : Integer;
       SWp        : Integer;


     procedure KeyEnable(Enable : Boolean);
     procedure Connect(Enable : Boolean);
     Procedure Puts(S : String);
     procedure ClearLogs(B:Boolean);

  public


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

Procedure TMyoTerm.Puts(S : String);
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

procedure TMyoTerm.TCPClient1Close(Sender: TObject; Socket: Integer);
begin

     Connecting.Down := False;
     Connecting.Refresh;
     TCPClient1.Close;
     _Connect := False;

end;

procedure TMyoTerm.TCPClient1Connect(Sender: TObject; Socket: Integer);
begin

     Connecting.Down := True;
     Connecting.Refresh;
     _Connect := True;

end;

procedure TMyoTerm.TCPClient1Data(Sender: TObject; Socket: Integer);
Var
  Data    : String;
  i       : Integer;
  S       : String;
begin


  Data :=  TCPClient1.Read;

          S := Logs[Logs.Count - 1];
          For i:=1 to Length(Data) Do
          Begin
            Case ReadMode of
              RM_None :
                If ( (Data[i] < #32) or (Data[i] = #255)) then
                   Begin
                     If Data[i]=#255 then
                       ReadMode := RM_IAC1;
                     If Data[i]=#8 then
                       S       := Copy(S,1,Length(s)-1);
                     If Data[i]=#13 then
                      Begin
                        Logs[Logs.Count - 1] := S;
                        S := '';
                        Logs.Add('');
                      End;
                   End Else
                     s       := s       + Data[i];
              RM_IAC1 : ReadMode := RM_IAC2;
              RM_IAC2 : ReadMode := RM_None;
            End;
          End;
          Logs[Logs.Count - 1] := S;

   MainTextRePaint := True;

end;

procedure TMyoTerm.TCPClient1Error(Sender: TObject; Error: Integer;
  Msg: String);
begin

   _Connect := False;

end;

procedure TMyoTerm.FormKeyPress(Sender: TObject; var Key: Char);
begin

   If (ActiveControl=MainTextPanel) and _KeyEnable and _Connect then
     Begin
       Puts(Key);
       Key := #0;
     End;

end;

procedure TMyoTerm.Timer1Timer(Sender: TObject);
Var
   SS : String;
begin

  inherited;

       SS :='';
       If (SRp<>SWp) then
        While (SRp<>SWp) do
         Begin
          SS := SS + SendStrBuf[Srp];
          SRp := (Srp+1) mod 4095;
          If Length(SS)>1023 then Break;
         End;
        Case Mode of
         cm_Telnet : TCPClient1.Write(SS);
         cm_Modem  : MyoComm1.Sendstring(SS);
        End;



end;

procedure TMyoTerm.FormCreate(Sender: TObject);
begin
  inherited;

  ClearLogs(True);
  KeyEnable(True);

end;










procedure TMyoTerm.SpeedButton5Click(Sender: TObject);
begin

   LineEdit.Visible := SpeedButton5.Down;

end;

procedure TMyoTerm.Button1Click(Sender: TObject);
begin

   Puts(Edit1.Text+#13#10);
   Edit1.Text := '';

end;

procedure TMyoTerm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin

   If Key = #13 then
    Begin
      Button1Click(Sender);
      Key := #0;
    End;  

end;

end.
