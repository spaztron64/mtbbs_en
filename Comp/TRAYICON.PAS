// Visual Component for Delphi - TrayIcon Component
//
// Contents    : TTrayIcon	�g���C�A�C�R���R���|�[�l���g
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
  NotifyIconErrMessage = '�^�X�N�g���C�ɃA�C�R����o�^�ł��܂���B';
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

  // Shell_NotifyIcon�p��\���E�B���h�E�N���X�̒�`
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

  // Icon�v���p�e�B�p�A�C�R���f�[�^�̈�m��
  FIcon := TIcon.Create;
  // �f�U�C�����łȂ��ꍇ�A�A�C�R����OnChange�C�x���g��ݒ�
  if not (csDesigning in ComponentState) then
    FIcon.OnChange := IconChange;
  IconRegisted := False;

  // �A�j���[�V�����֘A�v���p�e�B�̃f�t�H���g�l�̐ݒ�
  FAnimated := False;
  FAnimateMode := amAutomatic;
  FAnimateRate := 500;
  AnimateFrame := 0;
  AnimateIcon := Nil;
  AnimateTimer := Nil;

  // �v���p�e�B�̃f�t�H���g�l�̐ݒ�
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

  // �f�U�C�����łȂ��ꍇ�̏�����
  if not (csDesigning in ComponentState) then
  begin
    // Shell_NotifyIcon�p��\���R�[���o�b�N�E�B���h�E����������Ă��Ȃ��ꍇ
    if CallbackWIndow = Nil then
    begin
      CallbackWindow := TCallbackWindow.Create(Owner);
      CallbackWindow.Parent := TWinControl(Owner);
    end;

    // Shell_NotifyIcon�p�f�[�^�̈�m�ۂƏ�����
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
  // �f�U�C�����łȂ��ꍇ�A�A�C�R���̓o�^
  if not (csDesigning in ComponentState) then
    SetTrayIcon(tiAddIcon);

  inherited Loaded;
end;

destructor TTrayIcon.Destroy;
begin
  // �f�U�C�����łȂ��ꍇ�A�j������
  if not (csDesigning in ComponentState) then
  begin
    // �g���C�ɃA�C�R�����\������Ă���ꍇ�A�A�C�R���̔j��
    if IconRegisted then
      SetTrayIcon(tiDeleteIcon);

    // Shell_NotifyIcon�p�f�[�^�̈�j��
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
    // �A�j���[�V�������[�h�������̏ꍇ
    if FAnimateMode = amAutomatic then
    begin
      AnimateTimer.Free;
      AnimateTimer := Nil;
      // �A�j���[�V�������[�h���蓮�ɕύX
      FAnimateMode := amManual;
    end
    else
    begin
      // �A�j���[�V�������[�h���蓮�̏ꍇ
      AnimateTimer := TTimer.Create(Self);
      with AnimateTimer do
      begin
	Interval := FAnimateRate;
	OnTimer := DoAnimate;
      end;
      // �A�j���[�V�������[�h�������ɕύX
      FAnimateMode := amAutomatic;
    end;
  end;
end;

procedure TTrayIcon.AnimatePlay(AAnimateMode: TAnimateMode);
begin
  // �A�j���[�V�������łȂ��A�A�j���[�V�����A�C�R�����ݒ肳��Ă���ꍇ
  if (not FAnimated) and (FAnimateIcons <> Nil) then
  begin
    // �A�j���[�V�����A�C�R���ɂP�ȏ�̃A�C�R�����o�^����Ă���ꍇ
    if FAnimateIcons.Count > 0 then
    begin
      // �A�j���[�V�����֘A�̕ϐ���������
      AnimateFrame := 0;
      FAnimated := True;
      FAnimateMode := AAnimateMode;

      // �A�j���[�V�����A�C�R���p�A�C�R���f�[�^�̈�m��
      AnimateIcon := TIcon.Create;

      // �A�j���[�V�������[�h�������̏ꍇ
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
  // �A�j���[�V�������Ŏ蓮�A�j���[�V�����̏ꍇ
  if FAnimated and (FAnimateMode = amManual) then
    DoAnimate(Self);
end;

procedure TTrayIcon.AnimateStop;
begin
  // �A�j���[�V�������J�n����Ă���ꍇ�A�A�j���[�V�������~
  if FAnimated then
  begin
    // �A�j���[�V�����֘A�̗̈�̉��
    AnimateTimer.Free;
    AnimateTimer := Nil;
    AnimateIcon.Free;
    AnimateIcon := Nil;
    FAnimated := False;

    // �A�j���[�V�����A�C�R�������Ƃ̃A�C�R���ɕύX
    IconChange(Self);
  end;
end;

procedure TTrayIcon.DoAnimate(Sender: TObject);
begin
  // AnimateIcons�̓��e���ύX����A�S���A�C�R�������݂��Ȃ��Ȃ����ꍇ
  if FAnimateIcons.Count = 0 then
  begin
    AnimateStop;
    Exit;
  end;

  // AnimateIcons�̓��e���ύX����A���ɕ\������A�C�R�����Ȃ��Ȃ��Ă��܂����ꍇ
  // �ŏ��̃A�C�R���ɖ߂�
  if AnimateFrame > (FAnimateIcons.Count - 1) then
    AnimateFrame := 0;

  // �A�C�R���̕ύX�Ɣ��f
  FAnimateIcons.GetIcon(AnimateFrame, AnimateIcon);
  IconChange(Self);

  // ���ɕ\������A�C�R���̐ݒ�
  if AnimateFrame < (FAnimateIcons.Count - 1) then
    Inc(AnimateFrame)
  else
    AnimateFrame := 0;
end;

procedure TTrayIcon.IconChange(Sender: TObject);
begin
  // �g���C�ɃA�C�R�����\������Ă���ꍇ�A�A�C�R���̕ύX
  if IconRegisted then
    SetTrayIcon(tiModifyIcon);
end;

procedure TTrayIcon.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  // �t�H�[����̑��̃R���|�[�l���g���폜���ꂽ�ꍇ
  if (Operation = opRemove) then
  begin
    // �폜���ꂽ�R���|�[�l���g��TPopupMenu�ŁA
    // LBPopupMenu�ARBPopupMenu�ɐݒ肳��Ă����ꍇ�A�ݒ�𖳌��ɕύX
    if AComponent Is TPopupMenu then
    begin
      if AComponent = FLBPopupMenu then
	FLBPopupMenu := Nil
      else if AComponent = FRBPopupMenu then
	FRBPopupMenu := Nil;
    end
    // �폜���ꂽ�R���|�[�l���g��TImageList�ŁA
    // AnimateIcons�ɐݒ肳�ꂽ�ꍇ�A�ݒ�𖳌��ɕύX
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

    // �A�j���[�V�������Ŏ����A�j���[�V�������[�h�̏ꍇ�A���Ƀv���p�e�B�l�𔽉f
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
    // �A�C�R�����ݒ肳�ꂽ�ꍇ
    if Value <> Nil then
      FIcon.Assign(Value)
    // �A�C�R�����N���A(�폜)���ꂽ�ꍇ
    else
    begin
      FIcon.ReleaseHandle;
      FIcon.Handle := 0;

      // �A�C�R�����\���ɂ��邽�߁AVisible�v���p�e�B��False�ɐݒ�
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

    // �f�U�C�����łȂ��A�g���C�ɃA�C�R�����\������Ă���ꍇ�A�`�b�v�w���v�̕ύX
    if (not (csDesigning in ComponentState)) and IconRegisted then
      SetTrayIcon(tiModifyIcon);
  end;
end;

procedure TTrayIcon.SetTrayIcon(Value: Integer);
begin
  // Shell_NotifyIcon�p�f�[�^�̈�Ƀv���p�e�B�̒l��ݒ�
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
      // Visible�v���p�e�B��True�̏ꍇ�A�A�C�R���̓o�^
      if FVisible then
      begin
	// Shell_NotifyIcon�p�E�B���h�E�n���h����(��)�ݒ�
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

    // �f�U�C�����łȂ��A�R���|�[�l���g�����[�h���łȂ��ꍇ�A�\���E��\���̐ؑւ�
    if not (csDesigning in ComponentState)
      and not (csLoading in ComponentState) then
    begin
      // ��\�����\���֐ؑւ����ꍇ
      if FVisible then
	SetTrayIcon(tiAddIcon)
      // �\������\���֐ؑւ����ꍇ
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
  // TTrayIcon�I�u�W�F�N�g�̃C���f�b�N�X�ʒu�̐ݒ�
  objindex := IconIDList.IndexOf(IntToStr(Msg.wParam));
  if objindex >= 0 then
    sender := TTrayIcon(IconIDList.Objects[objindex])
  else
    Exit;

  // �}�E�X�J�[�\���̌��݈ʒu�擾
  GetCursorPos(cursorpos);

  // �}�E�X�̃��b�Z�[�W�ɂ�菈������
  case Msg.lParam of
    // �A�C�R����̒ʉߎ�
    WM_MOUSEMOVE:
    begin
      if Assigned(sender.OnMouseMove) then
	sender.OnMouseMove(sender, [], cursorpos.X, cursorpos.Y);
    end;
    // ���{�^���̃_�E����
    WM_LBUTTONDOWN:
    begin
      // ���{�^���Ƀ|�b�v�A�b�v���j���[�����蓖�ĂāAAutoPopup��True�̏ꍇ
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
    // ���{�^���̃A�b�v��
    WM_LBUTTONUP:
    begin
      if Assigned(sender.OnMouseUp) then
	sender.OnMouseUp(sender, mbLeft, [ssLeft], cursorpos.X, cursorpos.Y);
    end;
    // ���{�^���̃_�u���N���b�N��
    WM_LBUTTONDBLCLK:
    begin
      if Assigned(sender.OnDblClick) then
	sender.OnDblClick(sender);
    end;
    // ���{�^���̃_�E����
    WM_MBUTTONDOWN:
    begin
      if Assigned(sender.OnMouseDown) then
	sender.OnMouseDown(sender, mbMiddle, [ssMiddle],
	  cursorpos.X, cursorpos.Y);
    end;
    // ���{�^���̃A�b�v��
    WM_MBUTTONUP:
    begin
      if Assigned(sender.OnMouseUp) then
	sender.OnMouseUp(sender, mbMiddle, [ssMiddle],
	  cursorpos.X, cursorpos.Y);
    end;
    // �E�{�^���̃_�E����
    WM_RBUTTONDOWN:
    begin
      // �E�{�^���Ƀ|�b�v�A�b�v���j���[�����蓖�ĂāAAutoPopup��True�̏ꍇ
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
    // �E�{�^���̃A�b�v��
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
  // Shell_NotifyIcon�p��\���E�B���h�E�N���X�̏�����
  CallbackWIndow := Nil;

  // Shell_NotifyIcon�pIcon ID���X�g�̐���
  IconIDList := TStringList.Create;
  IconIDList.Sorted := False;

finalization
  // Shell_NotifyIcon�pIcon ID���X�g�̉��
  IconIDList.Free;

end.
