// Visual Component for Delphi - TrayIcon Component
//
// Contents    : TTrayIcon	トレイアイコンコンポーネント
// Last Update : 10/1/97	Release 1.10
// Author      : Yukio Tsujihara

unit TrayIcon;

interface

uses
  Messages, ShellApi, Windows,
  Classes, Controls, Graphics, ExtCtrls, Forms, Menus, SysUtils ;

const
  tiAddIcon = 0;
  tiModifyIcon = 1;
  tiDeleteIcon = 2;
  NotifyIconErrMessage = 'タスクトレイにアイコンを登録できません。';
  WM_NotifyIconMessage = WM_User + 200;

type
  TAnimateMode = (amAutomatic, amManual);

  TTrayIcon = class(TComponent)
  private
    FAnimated: Boolean;
    FAnimateIcons: TImageList;
    FAnimateMode: TAnimateMode;
    FAnimateRate: Integer;
    FAutoPopup: Boolean;
    FIcon: TIcon;
    FLBPopupMenu: TPopupMenu;
    FRBPopupMenu: TPopupMenu;
    FTipHelp: String;
    FVisible: Boolean;
    FOnDblClick: TNotifyEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnMouseDown, FOnMouseUp: TMouseEvent;

    AnimateFrame: Integer;
    AnimateIcon: TIcon;
    AnimateTimer: TTimer;
    IconID: UINT;
    IconRegisted: Boolean;
    NIconData: PNotifyIconDataA;
  protected
    procedure DoAnimate(Sender: TObject);
    procedure IconChange(Sender: TObject);
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    procedure SetAnimateIcons(Value: TImageList);
    procedure SetAnimateRate(Value: Integer);
    procedure SetAutoPopup(Value: Boolean);
    procedure SetIcon(Value: TIcon);
    procedure SetLBPopupMenu(Value: TPopupMenu);
    procedure SetRBPopupMenu(Value: TPopupMenu);
    procedure SetTipHelp(Value: String);
    procedure SetTrayIcon(Value: Integer);
    procedure SetVisible(Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Loaded; override;
    destructor Destroy; override;
    procedure AnimeteModeChange;
    procedure AnimatePlay(AAnimateMode: TAnimateMode);
    procedure AnimateStep;
    procedure AnimateStop;

    property Animated: Boolean read FAnimated;
    property AnimateMode: TAnimateMode read FAnimateMode;
  published
    property AnimateIcons: TImageList read FAnimateIcons write SetAnimateIcons;
    property AnimateRate: Integer read FAnimateRate write SetAnimateRate
      default 500;
    property AutoPopup: Boolean read FAutoPopup write SetAutoPopup default True;
    property Icon: TIcon read FIcon write SetIcon;
    property LBPopupMenu: TPopupMenu read FLBPopupMenu write SetLBPopupmenu;
    property RBPopupMenu: TPopupMenu read FRBPopupMenu write SetRBPopupmenu;
    property TipHelp: String read FTipHelp write SetTipHelp;
    property Visible: Boolean read FVisible write SetVisible default False;

    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
  end;

  // Shell_NotifyIcon用非表示ウィンドウクラスの定義
  TCallbackWindow = Class(TWinControl)
  private
    procedure CallbackWndProc(var Msg: TMessage); Message WM_NotifyIconMessage;
  end;

procedure Register;

implementation

var
  CallbackWindow: TCallbackWindow;
  IconIDList: TStringList;

constructor TTrayIcon.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // Iconプロパティ用アイコンデータ領域確保
  FIcon := TIcon.Create;
  // デザイン時でない場合、アイコンのOnChangeイベントを設定
  if not (csDesigning in ComponentState) then
    FIcon.OnChange := IconChange;
  IconRegisted := False;

  // アニメーション関連プロパティのデフォルト値の設定
  FAnimated := False;
  FAnimateMode := amAutomatic;
  FAnimateRate := 500;
  AnimateFrame := 0;
  AnimateIcon := Nil;
  AnimateTimer := Nil;

  // プロパティのデフォルト値の設定
  FAutoPopup := True;
  FTipHelp := 'TipHelp';
  FVisible := False;
  if IconIDList.Count > 0 then
  begin
    IconID := StrToInt(IconIDList[IconIDList.Count - 1]) + 1;
    if IconID > 99 then
      Raise EOutOfMemory.Create(NotifyIconErrMessage);
  end
  else
    IconID := 1;
  IconIDList.AddObject(IntToStr(IconID), Self);

  // デザイン時でない場合の初期化
  if not (csDesigning in ComponentState) then
  begin
    // Shell_NotifyIcon用非表示コールバックウィンドウが生成されていない場合
    if CallbackWIndow = Nil then
    begin
      CallbackWindow := TCallbackWindow.Create(Owner);
      CallbackWindow.Parent := TWinControl(Owner);
    end;

    // Shell_NotifyIcon用データ領域確保と初期化
    New(NIconData);
    with NIconData^ do
    begin
      cbSize := Sizeof(TNotifyIconDataA);
      uCallBackMessage := WM_NotifyIconMessage;
      uID := IconID;
    end;
  end;
end;

procedure TTrayIcon.Loaded;
begin
  // デザイン時でない場合、アイコンの登録
  if not (csDesigning in ComponentState) then
    SetTrayIcon(tiAddIcon);

  inherited Loaded;
end;

destructor TTrayIcon.Destroy;
begin
  // デザイン時でない場合、破棄処理
  if not (csDesigning in ComponentState) then
  begin
    // トレイにアイコンが表示されている場合、アイコンの破棄
    if IconRegisted then
      SetTrayIcon(tiDeleteIcon);

    // Shell_NotifyIcon用データ領域破棄
    Dispose(NIconData);

    AnimateTimer.Free;
    AnimateIcon.Free;
  end;

  IconIDList.Delete(IconIDList.IndexOf(IntToStr(IconID)));
  FIcon.Free;

  inherited Destroy;
end;

procedure TTrayIcon.AnimeteModeChange;
begin
  if FAnimated then
  begin
    // アニメーションモードが自動の場合
    if FAnimateMode = amAutomatic then
    begin
      AnimateTimer.Free;
      AnimateTimer := Nil;
      // アニメーションモードを手動に変更
      FAnimateMode := amManual;
    end
    else
    begin
      // アニメーションモードが手動の場合
      AnimateTimer := TTimer.Create(Self);
      with AnimateTimer do
      begin
	Interval := FAnimateRate;
	OnTimer := DoAnimate;
      end;
      // アニメーションモードを自動に変更
      FAnimateMode := amAutomatic;
    end;
  end;
end;

procedure TTrayIcon.AnimatePlay(AAnimateMode: TAnimateMode);
begin
  // アニメーション中でなく、アニメーションアイコンが設定されている場合
  if (not FAnimated) and (FAnimateIcons <> Nil) then
  begin
    // アニメーションアイコンに１つ以上のアイコンが登録されている場合
    if FAnimateIcons.Count > 0 then
    begin
      // アニメーション関連の変数を初期化
      AnimateFrame := 0;
      FAnimated := True;
      FAnimateMode := AAnimateMode;

      // アニメーションアイコン用アイコンデータ領域確保
      AnimateIcon := TIcon.Create;

      // アニメーションモードが自動の場合
      if AAnimateMode = amAutomatic then
      begin
	AnimateTimer := TTimer.Create(Self);
	with AnimateTimer do
	begin
	  Interval := FAnimateRate;
	  OnTimer := DoAnimate;
	end;
      end;
      DoAnimate(Self);
    end;
  end;
end;

procedure TTrayIcon.AnimateStep;
begin
  // アニメーション中で手動アニメーションの場合
  if FAnimated and (FAnimateMode = amManual) then
    DoAnimate(Self);
end;

procedure TTrayIcon.AnimateStop;
begin
  // アニメーションが開始されている場合、アニメーションを停止
  if FAnimated then
  begin
    // アニメーション関連の領域の解放
    AnimateTimer.Free;
    AnimateTimer := Nil;
    AnimateIcon.Free;
    AnimateIcon := Nil;
    FAnimated := False;

    // アニメーションアイコンをもとのアイコンに変更
    IconChange(Self);
  end;
end;

procedure TTrayIcon.DoAnimate(Sender: TObject);
begin
  // AnimateIconsの内容が変更され、全くアイコンが存在しなくなった場合
  if FAnimateIcons.Count = 0 then
  begin
    AnimateStop;
    Exit;
  end;

  // AnimateIconsの内容が変更され、次に表示するアイコンがなくなってしまった場合
  // 最初のアイコンに戻る
  if AnimateFrame > (FAnimateIcons.Count - 1) then
    AnimateFrame := 0;

  // アイコンの変更と反映
  FAnimateIcons.GetIcon(AnimateFrame, AnimateIcon);
  IconChange(Self);

  // 次に表示するアイコンの設定
  if AnimateFrame < (FAnimateIcons.Count - 1) then
    Inc(AnimateFrame)
  else
    AnimateFrame := 0;
end;

procedure TTrayIcon.IconChange(Sender: TObject);
begin
  // トレイにアイコンが表示されている場合、アイコンの変更
  if IconRegisted then
    SetTrayIcon(tiModifyIcon);
end;

procedure TTrayIcon.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  // フォーム上の他のコンポーネントが削除された場合
  if (Operation = opRemove) then
  begin
    // 削除されたコンポーネントがTPopupMenuで、
    // LBPopupMenu、RBPopupMenuに設定されていた場合、設定を無効に変更
    if AComponent Is TPopupMenu then
    begin
      if AComponent = FLBPopupMenu then
	FLBPopupMenu := Nil
      else if AComponent = FRBPopupMenu then
	FRBPopupMenu := Nil;
    end
    // 削除されたコンポーネントがTImageListで、
    // AnimateIconsに設定された場合、設定を無効に変更
    else if (AComponent Is TImageList) and (AComponent = FAnimateIcons) then
      FAnimateIcons := Nil;
  end;
end;

procedure TTrayIcon.SetAnimateIcons(Value: TImageList);
begin
  if (Value <> FAnimateIcons) and (not FAnimated) then
  begin
    AnimateFrame := 0;
    FAnimateIcons := Value;
  end;
  if FAnimateIcons <> Nil then
    Value.FreeNotification(Self);
end;

procedure TTrayIcon.SetAnimateRate(Value: Integer);
begin
  if Value <> FAnimateRate then
  begin
    if Value < 100 then
      Value := 100;
    FAnimateRate := Value;

    // アニメーション中で自動アニメーションモードの場合、直にプロパティ値を反映
    if Animated and (FAnimateMode = amAutomatic) then
      AnimateTimer.Interval := FAnimateRate;
  end;
end;

procedure TTrayIcon.SetAutoPopup(Value: Boolean);
begin
  if Value <> FAutoPopup then
    FAutoPopup := Value;
end;

procedure TTrayIcon.SetIcon(Value: TIcon);
begin
  if Value <> FIcon then
  begin
    // アイコンが設定された場合
    if Value <> Nil then
      FIcon.Assign(Value)
    // アイコンがクリア(削除)された場合
    else
    begin
      FIcon.ReleaseHandle;
      FIcon.Handle := 0;

      // アイコンを非表示にするため、VisibleプロパティをFalseに設定
      Visible := False;
    end;
  end;
end;

procedure TTrayIcon.SetLBPopupMenu(Value: TPopupMenu);
begin
  if Value <> FLBPopupMenu then
    FLBPopupMenu := Value;
  if FLBPopupMenu <> Nil then
    Value.FreeNotification(Self);
end;

procedure TTrayIcon.SetRBPopupMenu(Value: TPopupMenu);
begin
  if Value <> FRBPopupMenu then
    FRBPopupMenu := Value;
  if FRBPopupMenu <> Nil then
    Value.FreeNotification(Self);
end;

procedure TTrayIcon.SetTipHelp(Value: String);
begin
  if FTipHelp <> Copy(Value, 1, 62) then
  begin
    FTipHelp := Copy(Value, 1, 62);

    // デザイン時でなく、トレイにアイコンが表示されている場合、チップヘルプの変更
    if (not (csDesigning in ComponentState)) and IconRegisted then
      SetTrayIcon(tiModifyIcon);
  end;
end;

procedure TTrayIcon.SetTrayIcon(Value: Integer);
begin
  // Shell_NotifyIcon用データ領域にプロパティの値を設定
  with NIconData^ do
  begin
    if not FAnimated then
      hIcon := FIcon.Handle
    else
      hIcon := AnimateIcon.Handle;
    StrCopy(szTip, PChar(FTipHelp));
    if FtipHelp <> '' then
      uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP
    else
      uFlags := NIF_MESSAGE or NIF_ICON;
  end;

  case Value of
    tiAddIcon:
    begin
      // VisibleプロパティがTrueの場合、アイコンの登録
      if FVisible then
      begin
	// Shell_NotifyIcon用ウィンドウハンドルの(再)設定
	NIconData^.Wnd := CallbackWindow.Handle;
	if not Shell_NotifyIcon(NIM_ADD, NIconData) then
	  Raise EOutOfMemory.Create(NotifyIconErrMessage);
	IconRegisted := True;
      end;
    end;
    tiModifyIcon:
    begin
      if not Shell_NotifyIcon(NIM_MODIFY, NIconData) then
	Raise EOutOfMemory.Create(NotifyIconErrMessage);
    end;
    tiDeleteIcon:
    begin
      Shell_NotifyIcon(NIM_DELETE, NIconData);
      IconRegisted := False;
    end;
  end;
end;

procedure TTrayIcon.SetVisible(Value: Boolean);
begin
  if Value <> FVisible then
  begin
    if FIcon.Handle <> 0 then
      FVisible := Value
    else
      FVisible := False;

    // デザイン時でなく、コンポーネントをロード中でない場合、表示・非表示の切替え
    if not (csDesigning in ComponentState)
      and not (csLoading in ComponentState) then
    begin
      // 非表示→表示へ切替えた場合
      if FVisible then
	SetTrayIcon(tiAddIcon)
      // 表示→非表示へ切替えた場合
      else if IconRegisted then
	SetTrayIcon(tiDeleteIcon);
    end;
  end;
end;

procedure TCallbackWindow.CallbackWndProc(var Msg: TMessage);
var
  cursorpos: TPoint;
  objindex: Integer;
  sender: TTrayIcon;
begin
  // TTrayIconオブジェクトのインデックス位置の設定
  objindex := IconIDList.IndexOf(IntToStr(Msg.wParam));
  if objindex >= 0 then
    sender := TTrayIcon(IconIDList.Objects[objindex])
  else
    Exit;

  // マウスカーソルの現在位置取得
  GetCursorPos(cursorpos);

  // マウスのメッセージにより処理分岐
  case Msg.lParam of
    // アイコン上の通過時
    WM_MOUSEMOVE:
    begin
      if Assigned(sender.OnMouseMove) then
	sender.OnMouseMove(sender, [], cursorpos.X, cursorpos.Y);
    end;
    // 左ボタンのダウン時
    WM_LBUTTONDOWN:
    begin
      // 左ボタンにポップアップメニューを割り当てて、AutoPopupがTrueの場合
      if Assigned(sender.LBPopupMenu) and sender.AutoPopup then
      begin
	if sender.Owner is TForm then
	begin
	  SetForegroundWindow(TForm(sender.Owner).Handle);
	  Application.ProcessMessages;
	end;
	sender.LBPopupMenu.Popup(cursorpos.X, cursorpos.Y);
      end
      else if Assigned(sender.OnMouseDown) then
	sender.OnMouseDown(sender, mbLeft, [ssLeft], cursorpos.X, cursorpos.Y);
    end;
    // 左ボタンのアップ時
    WM_LBUTTONUP:
    begin
      if Assigned(sender.OnMouseUp) then
	sender.OnMouseUp(sender, mbLeft, [ssLeft], cursorpos.X, cursorpos.Y);
    end;
    // 左ボタンのダブルクリック時
    WM_LBUTTONDBLCLK:
    begin
      if Assigned(sender.OnDblClick) then
	sender.OnDblClick(sender);
    end;
    // 中ボタンのダウン時
    WM_MBUTTONDOWN:
    begin
      if Assigned(sender.OnMouseDown) then
	sender.OnMouseDown(sender, mbMiddle, [ssMiddle],
	  cursorpos.X, cursorpos.Y);
    end;
    // 中ボタンのアップ時
    WM_MBUTTONUP:
    begin
      if Assigned(sender.OnMouseUp) then
	sender.OnMouseUp(sender, mbMiddle, [ssMiddle],
	  cursorpos.X, cursorpos.Y);
    end;
    // 右ボタンのダウン時
    WM_RBUTTONDOWN:
    begin
      // 右ボタンにポップアップメニューを割り当てて、AutoPopupがTrueの場合
      if Assigned(sender.RBPopupMenu) and sender.AutoPopup then
      begin
	if sender.Owner is TForm then
	begin
	  SetForegroundWindow(TForm(sender.Owner).Handle);
	  Application.ProcessMessages;
	end;
	sender.RBPopupMenu.Popup(cursorpos.X, cursorpos.Y);
      end
      else if Assigned(sender.OnMouseDown) then
	sender.OnMouseDown(sender, mbRight, [ssRight],
	  cursorpos.X, cursorpos.Y);
    end;
    // 右ボタンのアップ時
    WM_RBUTTONUP:
    begin
      if Assigned(sender.OnMouseUp) then
	sender.OnMouseUp(sender, mbRight, [ssRight],
	  cursorpos.X, cursorpos.Y);
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('Win32', [TTrayIcon]);
end;

initialization
  // Shell_NotifyIcon用非表示ウィンドウクラスの初期化
  CallbackWIndow := Nil;

  // Shell_NotifyIcon用Icon IDリストの生成
  IconIDList := TStringList.Create;
  IconIDList.Sorted := False;

finalization
  // Shell_NotifyIcon用Icon IDリストの解放
  IconIDList.Free;

end.

