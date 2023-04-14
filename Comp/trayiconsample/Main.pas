unit Main;

interface

uses
  Messages, ShellApi, Windows,
  Classes, ComCtrls, Controls, Dialogs, ExtCtrls, Forms, Graphics, Menus,
  StdCtrls, SysUtils,
  TrayIcon;

type
  TFormMain = class(TForm)
    TrayIcon1: TTrayIcon;
    PopupMenuTrayIcon1: TPopupMenu;
    PopupMenuTrayIcon1Help: TMenuItem;
    PopupMenuTrayIcon1Sepa: TMenuItem;
    PopupMenuTrayIcon1Exit: TMenuItem;
    PopupMenuTrayIcon1About: TMenuItem;
    LabelTrayIcon1: TLabel;
    ButtonTrayIcon1: TButton;
    LabelTipHelp1: TLabel;
    EditTipHelp1: TEdit;
    RadioGroupTrayIcon1: TRadioGroup;
    RadioGroupCursor1: TGroupBox;
    LabelLocate1: TLabel;
    LabelCL1: TLabel;
    ButtonLB1: TButton;
    ButtonRB1: TButton;
    ImageTrayIcon1: TImage;
    BevelMain1: TBevel;
    TrayIcon2: TTrayIcon;
    LabelTrayIcon2: TLabel;
    ButtonTrayIcon2: TButton;
    LabelTipHelp2: TLabel;
    EditTipHelp2: TEdit;
    RadioGroupTrayIcon2: TRadioGroup;
    RadioGroupCursor2: TGroupBox;
    LabelLocate2: TLabel;
    LabelCL2: TLabel;
    ButtonLB2: TButton;
    ButtonRB2: TButton;
    ImageTrayIcon2: TImage;
    BevelMain2: TBevel;

    TrayIcon3: TTrayIcon;
    ImageList1: TImageList;
    LabelTrayIcon3: TLabel;
    ButtonTrayIcon3: TButton;
    LabelTipHelp3: TLabel;
    EditTipHelp3: TEdit;

    RadioGroupCursor3: TGroupBox;
    LabelLocate3: TLabel;
    LabelCL3: TLabel;
    ButtonLB3: TButton;
    ButtonRB3: TButton;
    RadioGroupTrayIcon3: TRadioGroup;
    LabelAnimateRate3: TLabel;
    TrackBarAnimateRate3: TTrackBar;
    ButtonAnimate3: TButton;
    ButtonAnimateStep3: TButton;

    procedure FormCreate(Sender: TObject);
    procedure ButtonTrayIcon1Click(Sender: TObject);
    procedure EditTipHelpExit(Sender: TObject);
    procedure EditTipHelp1KeyPress(Sender: TObject; var Key: Char);
    procedure RadioGroupTrayIcon1Click(Sender: TObject);
    procedure PopupMenuTrayIcon1AboutClick(Sender: TObject);
    procedure PopupMenuTrayIcon1ExitClick(Sender: TObject);
    procedure ButtonTrayIcon2Click(Sender: TObject);
    procedure RadioGroupTrayIcon2Click(Sender: TObject);
    procedure TrayIcon2DblClick(Sender: TObject);
    procedure ButtonTrayIcon3Click(Sender: TObject);
    procedure EditTipHelp3Exit(Sender: TObject);
    procedure EditTipHelp3KeyPress(Sender: TObject; var Key: Char);
    procedure RadioGroupTrayIcon3Click(Sender: TObject);
    procedure TrackBarAnimateRate3Change(Sender: TObject);
    procedure ButtonAnimate3Click(Sender: TObject);
    procedure ButtonAnimateStep3Click(Sender: TObject);
    procedure TrayIconMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TrayIconMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TrayIconMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    BmpTrayIcon1: TBitmap;
    BmpTrayIcon2: TBitmap;
  public
    { Public 宣言 }
  end;

var
  FormMain: TFormMain;
  AppsExe: Array[0..4] of String;

implementation

uses About;

{$R *.DFM}
{$R Icons.res}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  // ﾗﾝﾁｬ用ｱﾌﾟﾘｹｰｼｮﾝの登録
  AppsExe[0] := 'Pbrush.exe';
  AppsExe[1] := 'Notepad.exe';
  AppsExe[2] := 'Calc.exe';
  AppsExe[3] := 'Explorer.exe';
  AppsExe[4] := 'Mplayer.exe';

  // ﾄﾚｲｱｲｺﾝ1のｱｲｺﾝ設定
  TrayIcon1.Icon.Handle := LoadIcon(hInstance, 'ICON0');
  TrayIcon1.TipHelp := EditTipHelp1.Text;
  TrayIcon1.Visible := True;

  // ﾄﾚｲｱｲｺﾝ2のｱｲｺﾝ設定
  EditTipHelp2.Text := RadioGroupTrayIcon2.Items[0];
  TrayIcon2.Icon.Handle := ExtractIcon(hInstance, PChar(AppsExe[0]), 0);
  TrayIcon2.TipHelp := EditTipHelp2.Text;
  TrayIcon2.Visible := True;

  // ﾄﾚｲｱｲｺﾝ3のｱｲｺﾝ設定
  TrayIcon3.TipHelp := EditTipHelp3.Text;
  TrayIcon3.Visible := True;

  // 画面表示用拡大ｱｲｺﾝの表示
  BmpTrayIcon1 := TBitmap.Create;
  BmpTrayIcon1.Height := TrayIcon1.Icon.Height;
  BmpTrayIcon1.Width := TrayIcon1.Icon.Width;
  BmpTrayIcon1.Canvas.Draw(0, 0, TrayIcon1.Icon);
  ImageTrayIcon1.Picture.Assign(BmpTrayIcon1);
  BmpTrayIcon2 := TBitmap.Create;
  BmpTrayIcon2.Height := TrayIcon2.Icon.Height;
  BmpTrayIcon2.Width := TrayIcon2.Icon.Width;
  BmpTrayIcon2.Canvas.Draw(0, 0, TrayIcon2.Icon);
  ImageTrayIcon2.Picture.Assign(BmpTrayIcon2);
end;

procedure TFormMain.ButtonTrayIcon1Click(Sender: TObject);
begin
  // ｱｲｺﾝの表示/非表示の切替え
  TrayIcon1.Visible := Not TrayIcon1.Visible;
  if TrayIcon1.Visible then
    ButtonTrayIcon1.Caption := 'ｱｲｺﾝ非表示'
  else
    ButtonTrayIcon1.Caption := 'ｱｲｺﾝ表示'
end;

procedure TFormMain.EditTipHelpExit(Sender: TObject);
begin
  TrayIcon1.TipHelp := EditTipHelp1.Text;
end;

procedure TFormMain.EditTipHelp1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    TrayIcon1.TipHelp := EditTipHelp1.Text;
    Key := #0;
  end;
end;

procedure TFormMain.RadioGroupTrayIcon1Click(Sender: TObject);
var
  iconname: String;
begin
  // ｱｲｺﾝの切替え
  iconname := 'ICON' + IntToStr(RadioGroupTrayIcon1.ItemIndex);
  TrayIcon1.Icon.Handle := LoadIcon(hInstance, PChar(iconname));
  BmpTrayIcon1.Canvas.Brush.Style := bsSolid;
  BmpTrayIcon1.Canvas.FillRect(BmpTrayIcon1.Canvas.ClipRect);
  BmpTrayIcon1.Canvas.Draw(0, 0, TrayIcon1.Icon);
  ImageTrayIcon1.Picture.Assign(BmpTrayIcon1);
end;

procedure TFormMain.PopupMenuTrayIcon1AboutClick(Sender: TObject);
begin
  // "ﾊﾞｰｼﾞｮﾝ情報..."ﾀﾞｲｱﾛｸﾞﾎﾞｯｸｽの表示
  FormAbout := TFormAbout.Create(Self);
  try
    FormAbout.ShowModal;
  finally
    FormAbout.Free;
  end;
end;

procedure TFormMain.PopupMenuTrayIcon1ExitClick(Sender: TObject);
begin
  // ﾎﾟｯﾌﾟｱｯﾌﾟﾒﾆｭｰから"終了(X)"を選択した場合
  Close;
end;

procedure TFormMain.ButtonTrayIcon2Click(Sender: TObject);
begin
  // ｱｲｺﾝの表示/非表示の切替え
  TrayIcon2.Visible := Not TrayIcon2.Visible;
  if TrayIcon2.Visible then
    ButtonTrayIcon2.Caption := 'ｱｲｺﾝ非表示'
  else
    ButtonTrayIcon2.Caption := 'ｱｲｺﾝ表示'
end;

procedure TFormMain.RadioGroupTrayIcon2Click(Sender: TObject);
begin
  // ｱｲｺﾝの切替え
  TrayIcon2.Icon.Handle := ExtractIcon(hInstance,
    PChar(AppsExe[RadioGroupTrayIcon2.ItemIndex]), 0);
  EditTipHelp2.Text := RadioGroupTrayIcon2.Items[RadioGroupTrayIcon2.ItemIndex];
  TrayIcon2.TipHelp := EditTipHelp2.Text;
  BmpTrayIcon2.Canvas.Brush.Style := bsSolid;
  BmpTrayIcon2.Canvas.FillRect(BmpTrayIcon1.Canvas.ClipRect);
  BmpTrayIcon2.Canvas.Draw(0, 0, TrayIcon2.Icon);
  ImageTrayIcon2.Picture.Assign(BmpTrayIcon2);
end;

procedure TFormMain.TrayIcon2DblClick(Sender: TObject);
var
  si: TStartupInfo;
  pi: TProcessInformation;
begin
  // ｱｲｺﾝに表示されているｱﾌﾟﾘｹｰｼｮﾝの起動処理
  GetStartupInfo(si);
  CreateProcess( nil, PChar(AppsExe[RadioGroupTrayIcon2.ItemIndex]),
    nil, nil, False, CREATE_DEFAULT_ERROR_MODE, nil, nil, si, pi);
end;

procedure TFormMain.ButtonTrayIcon3Click(Sender: TObject);
begin
  // ｱｲｺﾝの表示/非表示の切替え
  TrayIcon3.Visible := Not TrayIcon3.Visible;
  if TrayIcon3.Visible then
    ButtonTrayIcon3.Caption := 'ｱｲｺﾝ非表示'
  else
    ButtonTrayIcon3.Caption := 'ｱｲｺﾝ表示'
end;

procedure TFormMain.EditTipHelp3Exit(Sender: TObject);
begin
  TrayIcon3.TipHelp := EditTipHelp3.Text;
end;

procedure TFormMain.EditTipHelp3KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    TrayIcon3.TipHelp := EditTipHelp3.Text;
    Key := #0;
  end;
end;

procedure TFormMain.RadioGroupTrayIcon3Click(Sender: TObject);
const
  AnimateModes: array[0..1] of TAnimateMode = (amAutomatic, amManual);
begin
  if TrayIcon3.Animated then
  begin
    if TrayIcon3.AnimateMode <> AnimateModes[RadioGroupTrayIcon3.ItemIndex] then
    begin
      TrayIcon3.AnimeteModeChange;
      if TrayIcon3.AnimateMode = amAutomatic then
	ButtonAnimateStep3.Enabled := False
      else
	ButtonAnimateStep3.Enabled := True;
    end;
  end;
end;

procedure TFormMain.TrackBarAnimateRate3Change(Sender: TObject);
begin
  TrayIcon3.AnimateRate := TrackBarAnimateRate3.Position;
end;

procedure TFormMain.ButtonAnimate3Click(Sender: TObject);
const
  AnimateModes: array[0..1] of TAnimateMode = (amAutomatic, amManual);
begin
  if not TrayIcon3.Animated then
  begin
    ButtonAnimate3.Caption := 'ｱﾆﾒｰｼｮﾝ停止';
    TrayIcon3.AnimatePlay(AnimateModes[RadioGroupTrayIcon3.ItemIndex]);
    if TrayIcon3.AnimateMode = amManual then
      ButtonAnimateStep3.Enabled := True;
  end
  else
  begin
    ButtonAnimate3.Caption := 'ｱﾆﾒｰｼｮﾝ開始';
    TrayIcon3.AnimateStop;
    ButtonAnimateStep3.Enabled := False;
  end;
end;

procedure TFormMain.ButtonAnimateStep3Click(Sender: TObject);
begin
  TrayIcon3.AnimateStep;
end;

procedure TFormMain.TrayIconMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  // ﾏｳｽｶｰｿﾙ位置の表示
  case TTrayIcon(Sender).Tag of
    1: LabelLocate1.Caption := Format('(%3d,%3d)', [X,Y]);
    2: LabelLocate2.Caption := Format('(%3d,%3d)', [X,Y]);
    3: LabelLocate3.Caption := Format('(%3d,%3d)', [X,Y]);
  end;
end;

procedure TFormMain.TrayIconMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case Button of
    mbLeft:
    begin
      case TTrayIcon(Sender).Tag of
	1: ButtonLB1.Enabled := True;
	2: ButtonLB2.Enabled := True;
	3: ButtonLB3.Enabled := True;
      end;
    end;
    mbRight:
    begin
      case TTrayIcon(Sender).Tag of
	1: ButtonRB1.Enabled := True;
	2: ButtonRB2.Enabled := True;
	3: ButtonRB3.Enabled := True;
      end;
    end;
  end;
end;

procedure TFormMain.TrayIconMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  case Button of
    mbLeft:
    begin
      case TTrayIcon(Sender).Tag of
	1: ButtonLB1.Enabled := False;
	2: ButtonLB2.Enabled := False;
	3: ButtonLB3.Enabled := False;
      end;
    end;
    mbRight:
    begin
      case TTrayIcon(Sender).Tag of
	1: ButtonRB1.Enabled := False;
	2: ButtonRB2.Enabled := False;
	3: ButtonRB3.Enabled := False;
      end;
    end;
  end;
end;

end.

