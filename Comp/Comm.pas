unit Comm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Dsgnintf;                                 // �v���p�e�B�G�f�B�^�[�p

const
  ASCII_XON  = $11;                         // XON����
  ASCII_XOFF = $13;                         // XOFF����

  dcb_OutxCtsFlow   = $00000004;
  dcb_OutxDsrFlow   = $00000008;
  dcb_Dtr_Enable    = $00000010;
  dcb_Dtr_Handshake = $00000020;
  dcb_OutX          = $00000100;
  dcb_InX           = $00000200;
  dcb_Rts_Enable    = $00001000;
  dcb_Rts_Handshake = $00002000;
  dcb_Rts_Toggle    = $00003000;

type
  TCommParityBits = (cpbNone, cpbOdd, cpbEven, cpbMark, cpbSpace);
  TCommByteSize = (cbs4, cbs5, cbs6, cbs7, cbs8);
  TCommStopBits = (csb1, csb15, csb2);
  TCommFlowControl = (cfcDtrDsr, cfcRtsCts, cfcXonXoff);
  TCommFlowControls = set of TCommFlowControl;
  TCommEvents = (evRxchar, evRxflag, evTxempty, evCts, evDsr,
                 evRlsd, evBreak, evErr, evRing, evPerr);
  TCommEventMask = set of TCommEvents;


  { �v���p�e�B�G�f�B�^�[ }
  TBaudProperty = class(TIntegerProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;


  { �ʐM�G���[�̂��߂̗�O�����N���X }
  ECommError = class(Exception);
  ECommOpenError = class(ECommError)
  private
    FErrorCode: Integer;
  public
    constructor Create(OpenErrorCode: Integer);
    property ErrorCode: Integer read FErrorCode;
  end;
  ECommReadWriteError = class(ECommError)
  private
    FErrorCode: DWord;
  public
    constructor Create(ReadWriteErrorCode: DWord);
    property ErrorCode: DWord read FErrorCode;
  end;


  { �ʐM�C�x���g�̂��߂̃��\�b�h�^ }
  TCommNotifyEvent = procedure (Sender: TObject; EventMask: TCommEventMask)
                            of object;
  TCommNotifyRxTxEvent = procedure (Sender: TObject; Size: Word)
                                of object;


  { ��M�X���b�h�̃N���X }
  TCommWatch = class(TThread)
  private
    FComDev: THandle;                       // �ʐM�f�o�C�X�E�n���h��
    FOwner: TComponent;                     // �e�R���|�[�l���g(= TComm)
  protected
    procedure Execute; override;            // �X���b�h�̃��C������
  public
                                            // �X���b�h�̃R���X�g���N�^
    constructor Create(AOwner: TComponent; ComDev: THandle);
  end;


  { �ʐM�R���|�[�l���g�̃N���X }
  TComm = class(TComponent)
  private
    FHandle: THandle;                        // �ʐM�f�o�C�X�E�n���h��
    FDCB: TDCB;                              // �ʐM�f�o�C�X����u���b�N
    FPort: Byte;                             // �ʐM�|�[�g�ԍ�
    FBaudRate: Integer;                      // �ʐM���x(bps)
    FBaudRateUserDefined: DWord;             // հ�ް��`�ʐM���x
    FByteSize: TCommByteSize;                // �f�[�^�r�b�g��
    FParityBits: TCommParityBits;            // �p���e�B�[�r�b�g��
    FStopBits: TCommStopBits;                // �X�g�b�v�r�b�g��
    FFlowControls: TCommFlowControls;        // �t���[����

    FInQueueSize: Word;                      // ��M�o�b�t�@�[�T�C�Y
    FOutQueueSize: Word;                     // ���M�o�b�t�@�[�T�C�Y
    FReceiveNotifySize: Integer;             // ��M�o�b�t�@�[�ʒm�o�C�g��
    FSendNotifySize: Integer;                // ���M�o�b�t�@�[�ʒm�o�C�g��
    FEventMask: TCommEventMask;              // �ʐM�C�x���g�}�X�N

    FOnCommEvent: TCommNotifyEvent;          // �ʐM�C�x���g�̔���
    FOnCommReceive: TCommNotifyRxTxEvent;    // ��M�C�x���g
    FOnCommTransmit: TCommNotifyRxTxEvent;   // ���M�C�x���g

    FReadOs: TOverlapped;                    // ��M�p�I�[�o�[���b�v�\����

    FThread: TCommWatch;                     // ��M�C�x���g�Ď��X���b�h

    procedure SetBaudRate(Value: Integer);
    procedure SetBaudRateUserDefined(Value: Word);
    procedure SetParityBits(Value: TCommParityBits);
    procedure SetByteSize(Value: TCommByteSize);
    procedure SetStopBits(Value: TCommStopBits);
    procedure SetFlowControls(Value: TCommFlowControls);
    procedure SetReceiveNotifySize(Value: Integer);
    procedure SetSendNotifySize(Value: Integer);
    procedure SetEventMask(Value: TCommEventMask);
    function GetDsrState: Boolean;

  protected
    procedure DoCommEvent(EvtMask: DWord); virtual;
    procedure DoCommReceive; virtual;
    procedure DoCommTransmit; virtual;

  public

    FWriteOs: TOverlapped;                   // ���M�p�I�[�o�[���b�v�\����

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    procedure Write(const Buffer; Size: Integer);
    procedure Read(Buffer: PChar; Size: Integer);
    procedure SendString(S: string);
    procedure SendBreak;
    property Handle: THandle read FHandle;

  published
    property Port: Byte read FPort write FPort default 1;
    property BaudRate: Integer read FBaudRate write SetBaudRate
                default 9600;
    property BaudRateUserDefined: DWord read FBaudRateUserDefined
                write FBaudRateUserDefined default 9600;
    property ParityBits: TCommParityBits read FParityBits write SetParityBits
                default cpbNone;
    property ByteSize: TCommByteSize read FByteSize write SetByteSize
                default cbs8;
    property StopBits: TCommStopBits read FStopBits write SetStopBits
                default csb1;
    property FlowControls: TCommFlowControls read FFlowControls
                write SetFlowControls default [cfcRtsCts];

    property InQueueSize: Word read FInQueueSize write FInQueueSize
                default 4096;
    property OutQueueSize: Word read FOutQueueSize write FOutQueueSize
                default 4096;
    property ReceiveNotifySize: Integer read FReceiveNotifySize
                write SetReceiveNotifySize default 3072;
    property SendNotifySize: Integer read FSendNotifySize
                write SetSendNotifySize default 1024;
    property EventMask: TCommEventMask read FEventMask write SetEventMask
                default [];

    property DsrState: Boolean read GetDsrState;

    property OnCommEvent: TCommNotifyEvent read FOnCommEvent
                write FOnCommEvent;
    property OnCommReceive: TCommNotifyRxTxEvent read FOnCommReceive
                write FOnCommReceive;
    property OnCommTransmit: TCommNotifyRxTxEvent read FOnCommTransmit
                write FOnCommTransmit;

  end;


procedure Register;

implementation


{ �I�u�W�F�N�g�̐��� }
constructor TComm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // �����l�̐ݒ�
  FHandle := -1;                            // �ʐM�f�o�C�X�E�n���h��
  FPort := 1;                               // �ʐM�|�[�g
  FBaudRate := 9600;                        // �ʐM���x
  FBaudRateUserDefined := 9600;             // ���[�U�[��`�ʐM���x
  FByteSize := cbs8;                        // �f�[�^�r�b�g��
  FParityBits := cpbNone;                   // �p���e�B�[�r�b�g��
  FStopBits := csb1;                        // �X�g�b�v�r�b�g��
  FFlowControls := [cfcRtsCts];             // �t���[����
  FInQueueSize := 4096;                     // ��M�o�b�t�@�[��
  FOutQueueSize := 4096;                    // ���M�o�b�t�@�[��
  FReceiveNotifySize := 3072;               // XOFF���M���E
  FSendNotifySize := 1024;                  // XON���M���E
  FEventMask := [];                         // �C�x���g�}�X�N
  FDCB.DCBLength := SizeOf(FDCB);           // �f�o�C�X����u���b�N���̐ݒ�
end;

{ �I�u�W�F�N�g�̔j�� }
destructor TComm.Destroy;
begin
  if FHandle >= 0 then                      // �ʐM���Ȃ�N���[�Y����
    Close;
  inherited Destroy;
end;


{----- �v���p�e�B�֘A�֐��Q ----------------------------------------}


{ �ʐM���x�̐ݒ� }
procedure TComm.SetBaudRate(Value: Integer);
begin
  FBaudRate := Value;
  if FHandle >= 0 then
  begin
    GetCommState(FHandle, FDCB);
    if FBaudRate <> -1 then                 // հ�ް��`�łȂ��ꍇ
      FDCB.BaudRate := FBaudRate
    else
      FDCB.BaudRate := FBaudRateUserDefined;
    SetCommState(FHandle, FDCB);
  end;
end;


{ ���[�U�[�w��ʐM���x�̐ݒ� }
procedure TComm.SetBaudRateUserDefined(Value: Word);
begin
  FBaudRateuserDefined := Value;
  SetBaudRate(-1);
end;


{ ����M����o�C�g�f�[�^�̃r�b�g���̐ݒ� }
procedure TComm.SetByteSize(Value: TCommByteSize);
begin
  FByteSize := Value;                       // �����ϐ��ɕۑ�
  if FHandle >= 0 then                      // �ʐM���I�[�v������Ă�����
  begin
    GetCommState(FHandle, FDCB);            // ���݂�TDCB�̎擾
    FDCB.ByteSize := 4 + Ord(FByteSize);    // �������ɂS�𑫂��ĂS����W��
    SetCommState(FHandle, FDCB);            // �V����TDCB���Z�b�g
  end;
end;


{ �p���e�B�[�r�b�g���̐ݒ� }
procedure TComm.SetParityBits(Value: TCommParityBits);
begin
  FParityBits := Value;                     // �����ϐ��ɕۑ�
  if FHandle >= 0 then                      // �ʐM���I�[�v������Ă�����
  begin
    GetCommState(FHandle, FDCB);            // ���݂�TDCB�̎擾
    FDCB.Parity := Ord(FParityBits);        // �����������̂܂ܐݒ�
    SetCommState(FHandle, FDCB);            // �V����TDCB���Z�b�g
  end;
end;


{ �X�g�b�v�r�b�g���̐ݒ� }
procedure TComm.SetStopBits(Value: TCommStopBits);
begin
  FStopBits := Value;                       // �����ϐ��ɕۑ�
  if FHandle >= 0 then                      // �ʐM���I�[�v������Ă�����
  begin
    GetCommState(FHandle, FDCB);            // ���݂�TDCB�̎擾
    FDCB.StopBits := Ord(FStopBits);        // �����������̂܂ܐݒ�
    SetCommState(FHandle, FDCB);            // �V����TDCB���Z�b�g
  end;
end;


{ �t���[��������̐ݒ� }
procedure TComm.SetFlowControls(Value: TCommFlowControls);
begin
  FFlowControls := Value;                   // �����ϐ��ɕۑ�
  if FHandle >= 0 then                      // �ʐM���I�[�v������Ă�����
  begin
    GetCommState(FHandle, FDCB);
    FDCB.Flags := FDCB.Flags and $FEC0C003; // fOutxCtsFlow
                                            // fOutxDsrFlow
                                            // fDtrControl
                                            // fOutX, fInX
                                            // fRtsControl ���I�t�ɂ���

    if cfcRtsCts in FFlowControls then      // RTS/CTS�t���[����̏ꍇ
      FDCB.Flags := FDCB.Flags or dcb_OutxCtsFlow or
                    dcb_Rts_Handshake
    else
      FDCB.Flags := FDCB.Flags or dcb_Rts_Enable;

    if cfcDtrDsr in FFlowControls then      // DTR/DSR�t���[����̏ꍇ
      FDCB.Flags := FDCB.Flags or dcb_OutxDsrFlow or
                    dcb_Dtr_Handshake
    else
      FDCB.Flags := FDCB.Flags or dcb_Dtr_Enable;

    if cfcXonXoff in FFlowControls then     // XON/XOFF�t���[����̏ꍇ
      FDCB.Flags := FDCB.Flags or dcb_OutX or dcb_InX;
    FDCB.XonChar := Char(ASCII_XON);
    FDCB.XoffChar := Char(ASCII_XOFF);

    FDCB.Flags := FDCB.Flags or $00000003;   // fBinary & fParity;
    SetCommState(FHandle, FDCB);
  end;
end;


{ ��M�o�b�t�@�̒ʒm�T�C�Y�̐ݒ� }
procedure TComm.SetReceiveNotifySize(Value: Integer);
begin
  FReceiveNotifySize := Value;              // �����ϐ��ɕۑ�
  if FHandle >= 0 then                      // �ʐM���I�[�v������Ă���Ȃ�
  begin
    GetCommState(FHandle, FDCB);            // ���݂�TDCB�̎擾
    FDCB.XoffLim := FInQueueSize - FReceiveNotifySize;
    SetCommState(FHandle, FDCB);            // �V����TDCB�̃Z�b�g
  end;
end;


{ ���M�o�b�t�@�̒ʒm�T�C�Y�̐ݒ� }
procedure TComm.SetSendNotifySize(Value: Integer);
begin
  FSendNotifySize := Value;                 // �����ϐ��ɕۑ�
  if FHandle >= 0 then                      // �ʐM���I�[�v������Ă���Ȃ�
  begin
    GetCommState(FHandle, FDCB);            // ���݂�TDCB�̎擾
    FDCB.XonLim := FSendNotifySize;         // �V�����l�̐ݒ�
    SetCommState(FHandle, FDCB);            // �V����TDCB�̃Z�b�g
  end;
end;


{ �ʐM�C�x���g�}�X�N�̐ݒ� }
procedure TComm.SetEventMask(Value: TCommEventMask);
var
  dwEvtMask: DWORD;
begin
  FEventMask := Value;                      // �����ϐ��ɕۑ�
  if FHandle >= 0 then                      // �ʐM���I�[�v������Ă���Ȃ�
  begin
    dwEvtMask := 0;                         // �C�x���g�}�X�N��������
    if evRxchar in FEventMask then          // ������M�C�x���g
      dwEvtMask := dwEvtMask or EV_RXCHAR;
    if evRxflag in FEventMask then          // �C�x���g�����̎�M
      dwEvtMask := dwEvtMask or EV_RXFLAG;
    if evTxEmpty in FEventMask then         // ���M�o�b�t�@����
      dwEvtMask := dwEvtMask or EV_TXEMPTY;
    if evCts in FEventMask then             // CTS�M���̕ω�
      dwEvtMask := dwEvtMask or EV_CTS;
    if evDsr in FEventMask then             // DSR�M���̕ω�
      dwEvtMask := dwEvtMask or EV_DSR;
    if evRlsd in FEventMask then            // RLSD(CD)�M���̕ω�
      dwEvtMask := dwEvtMask or EV_RLSD;
    if evBreak in FEventMask then           // �u���[�N�̌��o
      dwEvtMask := dwEvtMask or EV_BREAK;
    if evErr in FEventMask then             // �����ԃG���[
      dwEvtMask := dwEvtMask or EV_ERR;
    if evRing in FEventMask then            // �d�b���|�����Ă���
      dwEvtMask := dwEvtMask or EV_RING;
    if evPerr in FEventMask then            // �v�����^�G���[�H
      dwEvtMask := dwEvtMask or EV_PERR;
    SetCommMask(FHandle, dwEvtMask);        // �ʐM�C�x���g�}�X�N�̐ݒ�
  end;
end;


{ DSR�M���̏󋵂��擾����        }
{ True: DSR ON,   False: DSR OFF }
function TComm.GetDsrState: Boolean;
var
  ModemStat: DWORD;
begin
  if FHandle >= 0 then                      // �ʐM���I�[�v������Ă�����
  begin
    GetCommModemStatus(FHandle, ModemStat); // ���f���X�e�[�^�X�̎擾
    Result := ((ModemStat and MS_DSR_ON) = MS_DSR_ON);
  end
  else
    Result := False;
end;


{ �ʐM�C�x���g���� }
procedure TComm.DoCommEvent(EvtMask: DWord);
var
  EventMask: TCommEventMask;
begin
  //�ʐM����OnCommEvent���ݒ肳��Ă���ꍇ
  if (FHandle >= 0) and Assigned(FOnCommEvent) then
  begin
    EventMask := [];                            // �C�x���g�}�X�N�̏�����
    if (EvtMask and EV_BREAK)  = EV_BREAK  then // EV_BREAK   �u���[�N�M����M
      EventMask := EventMask + [evBreak];
    if (EvtMask and EV_CTS  )  = EV_CTS    then // EV_CTS     CTS�M���̕ω�
      EventMask := EventMask + [evCts];
    if (EvtMask and EV_DSR  )  = EV_DSR    then // EV_DSR     DSR�M���̕ω�
      EventMask := EventMask + [evDsr];
    if (EvtMask and EV_ERR  )  = EV_ERR    then // EV_ERR     �����ԃG���[
      EventMask := EventMask + [evErr];
    if (EvtMask and EV_RING )  = EV_RING   then // EV_RING    RI�M�����m
      EventMask := EventMask + [evRing];
    if (EvtMask and EV_RLSD )  = EV_RLSD   then // EV_RLSD    RLSD�M���̕ω�
      EventMask := EventMask + [evRlsd];
    if (EvtMask and EV_RXFLAG) = EV_RXFLAG then // EV_RXFLAG  �C�x���g������M
      EventMask := EventMask + [evRxFlag];
    FOnCommEvent(self, EventMask);
  end;
end;


{ �f�[�^��M�C�x���g���� }
procedure TComm.DoCommReceive;
var
  dwErrors: DWord;
  Stat: TComStat;
begin
  if (FHandle >= 0) and Assigned(FOnCommReceive) then
  begin
    ClearCommError(FHandle, dwErrors, @Stat);
    if Stat.cbInQue > 0 then
      FOnCommReceive(Self, Stat.cbInQue);
    ClearCommError(FHandle, dwErrors, @Stat);
  end;
end;


{ ���M�o�b�t�@�󂫃C�x���g���� }
procedure TComm.DoCommTransmit;
var
  dwErrors: DWord;
  Stat: TComStat;
begin
  if (FHandle >= 0) and Assigned(FOnCommTransmit) then
  begin
    ClearCommError(FHandle, dwErrors, @Stat);
    FOnCommTransmit(Self, Stat.cbOutQue);
  end;
end;


{----- �ʐM�{�̊֐��Q ----------------------------------------------}


{ �ʐM�|�[�g�̃I�[�v�� }
procedure TComm.Open;
var
  szPort: array [0..9] of Char;             // �|�[�g��
  CommTimeouts: TCommTimeouts;              // �^�C���A�E�g�\����
begin
  if FHandle < 0 then                       // �ʐM���łȂ���
  begin
    FReadOs.Offset := 0;                    // ��M�I�[�o�[���b�v�����p
    FReadOs.OffsetHigh := 0;
                                            // �C�x���g�I�u�W�F�N�g�̍쐬
    FReadOs.hEvent := CreateEvent(nil,      // �n���h�����p�����Ȃ�
                                  True,     // �蓮���Z�b�g�C�x���g
                                  False,    // ��V�O�i����Ԃŏ�����
                                  nil);     // �C�x���g�I�u�W�F�N�g�̖��O
    if FReadOs.hEvent = 0 then
      raise ECommOpenError(-2);             // �C�x���g���쐬�ł��Ȃ�

    FWriteOs.Offset := 0;                   // ���M�I�[�o�[���b�v�����p
    FWriteOs.OffsetHigh := 0;
                                            // �C�x���g�I�u�W�F�N�g�̍쐬
    FWriteOs.hEvent := CreateEvent(nil,     // �n���h�����p�����Ȃ�
                                   True,    // �蓮���Z�b�g�C�x���g
                                   False,   // ��V�O�i����Ԃŏ�����
                                   nil);    // �C�x���g�I�u�W�F�N�g�̖��O
    if FWriteOs.hEvent = 0 then
    begin
      CloseHandle(FReadOs.hEvent);          // ��M�p�C�x���g�̃N���[�Y
      raise ECommOpenError(-3);             // �C�x���g���쐬�ł��Ȃ�
    end;

    StrPCopy(szPort, 'COM'+ IntToStr(FPort));      // �|�[�g���̍쐬
    FHandle := CreateFile(szPort,                  // �|�[�g��
                          GENERIC_READ or GENERIC_WRITE,
                          0,                       // �r���I�g�p(*)
                          nil,                     // �Z�L�����e�B�[�����Ȃ�
                          OPEN_EXISTING,           // ����(*)
                          FILE_ATTRIBUTE_NORMAL or // �ʏ�
                          FILE_FLAG_OVERLAPPED,    // �I�[�o�[���b�v���o��
                          0);                      // �e���v���[�g�Ȃ�(*)
    if FHandle < 0 then                     // �G���[������
      raise ECommOpenError.Create(FHandle); // ��O�̐���

    // ����M�o�b�t�@�[�T�C�Y�̐ݒ�
    SetupComm(FHandle, FInQueueSize, FOutQueueSize);

    // ���ׂẴo�b�t�@�[����j������
    PurgeComm(FHandle, PURGE_TXABORT or
                       PURGE_RXABORT or
                       PURGE_TXCLEAR or
                       PURGE_RXCLEAR);

    // �^�C���A�E�g�̃Z�b�g�A�b�v
    CommTimeouts.ReadIntervalTimeout := MAXDWORD;
    CommTimeouts.ReadTotalTimeoutMultiplier := 0;
    CommTimeouts.ReadTotalTimeoutConstant := 1000;
    CommTimeouts.WriteTotalTimeoutMultiplier := 0;
    CommTimeouts.WriteTotalTimeoutConstant := 3000;
    SetCommTimeouts(FHandle, CommTimeouts);

    // �ʐM���̐ݒ�
    SetBaudRate(FBaudRate);                 // �ʐM���x
    SetByteSize(FByteSize);                 // �f�[�^�r�b�g��
    SetParityBits(FParityBits);             // �p���e�B�[�r�b�g��
    SetStopBits(FStopBits);                 // �X�g�b�v�r�b�g��

    SetFlowControls(FFlowControls);         // �t���[����
    SetReceiveNotifySize(FReceiveNotifySize);
    SetSendNotifySize(FSendNotifySize);

    SetEventMask(FEventMask);               // �C�x���g�}�X�N

    FThread := TCommWatch.Create(Self, FHandle);
                                            // ��M�Ď��X���b�h�̋N��

    EscapeCommFunction(FHandle, SETDTR);    // DTR���I���ɂ���
  end;
end;


{ �ʐM�|�[�g�̃N���[�Y }
procedure TComm.Close;
begin
  if FHandle >= 0 then
  begin
    SetCommMask(FHandle, 0);                // �ʒm�C�x���g���N���A����
                                            // �X���b�h���I��������
    while FThread.Terminated = True do;     // �X���b�h�̏I����҂�

    EscapeCommFunction(FHandle, CLRDTR);    // DTR���I�t�ɂ���

    // ���ׂẴo�b�t�@�[����j������
    PurgeComm(FHandle, PURGE_TXABORT or
                       PURGE_RXABORT or
                       PURGE_TXCLEAR or
                       PURGE_RXCLEAR);

    CloseHandle(FHandle);                   // �V���A���ʐM�̃N���[�Y
    FHandle := -1;                          // �ēx�I�[�v�����邽��

    CloseHandle(FReadOs.hEvent);            // ��M�C�x���g�̃N���[�Y
    Closehandle(FWriteOs.hEvent);           // ���M�C�x���g�̃N���[�Y
  end;
end;


{ �f�[�^�̑��M }
procedure TComm.Write(const Buffer; Size: Integer);
var
  dwError: DWord;
  Stat: TComStat;
  dwBytesWritten: DWord;
begin
  if FHandle < 0 then
    raise ECommError.Create('�ʐM���J�n����Ă��Ȃ��B');

  if FOutQueueSize < Size then
    raise ECommError.Create('���M�f�[�^������������B');

  repeat                                    // ���M�L���[���󂭂̂�҂�
//    Application.ProcessMessages;          // ���ꂪ����Ƒ��M���t�]����
    ClearCommError(FHandle, dwError, @Stat);
  until (FOutQueueSize - Stat.cbOutQue) >= Size;

  if not WriteFile(FHandle, Buffer, Size, dwBytesWritten, @FWriteOs) then
  begin
    if GetLastError = ERROR_IO_PENDING then // �I�[�o�[���b�v������
    begin
      while not GetOverlappedResult(FHandle, FWriteOs,
                  dwBytesWritten, True) do
      begin
        if GetLastError = ERROR_IO_INCOMPLETE then  // �܂��������Ȃ�
          Continue
        else
        begin
          ClearCommError(FHandle, dwError, @Stat);
          Break;
        end;
      end;
    end
    else
    begin                                   // ���̑��̃G���[����
      ClearCommError(FHandle, dwError, @Stat);
      raise ECommReadWriteError.Create(dwError);
    end;
  end;
end;


{ �f�[�^�̎�M }
procedure TComm.Read(Buffer: PChar; Size: Integer);
var
  dwError: DWord;
  Stat: TComStat;
  dwLength: DWord;
begin
  if FHandle < 0 then
    raise ECommError.Create('�ʐM���J�n����Ă��Ȃ��B');

  ClearCommError(FHandle, dwError, @Stat);
  dwlength := Size;
  if not ReadFile(FHandle, Buffer^, Size, dwLength, @FReadOs) then
  begin
    if GetLastError = ERROR_IO_PENDING then // �I�[�o�[���b�v�����̏ꍇ
    begin
      while not GetOverlappedResult(FHandle, FReadOs, dwlength, True) do
      begin
        if GetLastError = ERROR_IO_INCOMPLETE then   // �����������̏ꍇ
          Continue
        else
        begin
          ClearCommError(FHandle, dwError, @Stat);
          Break;
        end;
      end;
    end
    else
    begin                                   // ���̑��̃G���[����
      ClearCommError(FHandle, dwError, @Stat);   // �G���[���N���A
      raise ECommReadWriteError.Create(dwError); // ��O�̐���
    end;
  end;
end;


{ ������̑��M }
procedure TComm.SendString(S: string);
var
  Buf: PChar;
  Size: Integer;
begin
  Size := Length(S);                        // ������
  Buf := AllocMem(Size + 1);                // PChar�o�b�t�@�̊m��
  CopyMemory(Buf, PChar(S), Size);          // string����PChar�ɃR�s�[
  Write(Buf^, Length(S));                   // ���M����
  FreeMem(Buf,Size+1);                      // �������̉��
end;


{ �u���[�N�̑��M }
procedure TComm.SendBreak;
var
CurrentTime: DWord;
begin
  if not SetCommBreak(FHandle) then
    raise ECommReadWriteError.Create(GetLastError);
  CurrentTime := GetTickCount;
  while GetTickCount - CurrentTime < 500 do
    Application.ProcessMessages;
  ClearCommBreak(FHandle);
end;


{ ��M�X���b�h�֐� }
{ ��M�X���b�h�@�J�n���� }
constructor TCommWatch.Create(AOwner: TComponent; ComDev: THandle);
var
  dwEvtMask: DWORD;
begin
  inherited Create(True);                   // �T�X�y���h��Ԃō쐬
  FOwner := AOwner;                         // �I�[�i�[�̕ۑ�
  FComDev := ComDev;                        // �ʐM�n���h���̕ۑ�

  // ��M�����C�x���g���Z�b�g����
  GetCommMask(FComDev, dwEvtMask);          // ���݂̒ʐM�C�x���g�}�X�N�̎擾
  dwEvtMask := dwEvtMask or EV_RXCHAR;      // ��M�����C�x���g��ǉ�
  SetCommMask(FComDev, dwEvtMask);          // �V�����ʐM�C�x���g�}�X�N�̐ݒ�
  Resume;                                   // �X���b�h�̎��s�J�n
end;


{ ��M�X���b�h�@���C������ }
procedure TCommWatch.Execute;
var
  dwEvtMask: DWORD;
begin
  while True do                             // �ڑ����̓��[�v����
  begin
    dwEvtMask := 0;
    WaitCommEvent(FComDev, dwEvtMask, nil); // �ʐM�C�x���g�����̑ҋ@
    try
      if (dwEvtMask and EV_RXCHAR) = EV_RXCHAR then
        TComm(FOwner).DoCommReceive         // EV_RXCHAR  ������M
      else if (dwEvtMask and EV_TXEMPTY) = EV_TXEMPTY then
        TComm(FOwner).DoCommTransmit        // EV_TXEMPTY ���M�o�b�t�@�[����
      else if dwEvtMask <> 0 then
        TComm(FOwner).DoCommEvent(dwEvtMask)// EV_BREAK   �u���[�N�M����M
                                            // EV_CTS     CTS�M���̕ω�
                                            // EV_DSR     DSR�M���̕ω�
                                            // EV_ERR     �����ԃG���[
                                            // EV_RING    RI�M�����m
                                            // EV_RLSD    RLSD�M���̕ω�
                                            // EV_RXFLAG  �C�x���g������M
      else                                  // ���[�v���甲���o��
        Break;
    except
      Application.HandleException(self);    // �C�x���g�n���h���[�ŗ�O����
    end;
  end;
  FreeOnTerminate := True;                  // �I�����I�u�W�F�N�g��j��
end;


{----- �G���[�\���֐��Q --------------------------------------------}


{ �I�[�v���G���[�̕\�� }
constructor ECommOpenError.Create(OpenErrorCode: Integer);
var
  msg: string;
begin
  FErrorCode := OpenErrorCode;
  msg := Format('�I�[�v���G���[ ErrorCode = %d', [FErrorCode]);
  inherited Create(msg);
end;


{ ���o�̓G���[�̕\�� }
constructor ECommReadWriteError.Create(ReadWriteErrorCode: DWord);
var
  msg: string;
begin
  FErrorCode := ReadWriteErrorCode;
  msg := Format('���o�̓G���[ ErrorCode = %d', [FErrorCode]);
  inherited Create(msg);
end;


{----- �v���p�e�B�G�f�B�^�֐��Q ------------------------------------}


{ BaurRate�v���p�e�B�̃v���p�e�B�G�f�B�^ }
type
  TBaudEntry = record
    Value: Integer;
    name: string;
  end;

const
  BaudEntry: array [1..14] of TBaudEntry = (
      (Value: CBR_110;    Name: '   110bps'),
      (Value: CBR_300;    Name: '   300bps'),
      (Value: CBR_600;    Name: '   600bps'),
      (Value: CBR_1200;   Name: '  1200bps'),
      (Value: CBR_2400;   Name: '  2400bps'),
      (Value: CBR_4800;   Name: '  4800bps'),
      (Value: CBR_9600;   Name: '  9600bps'),
      (Value: CBR_14400;  Name: ' 14400bps'),
      (Value: CBR_19200;  Name: ' 19200bps'),
      (Value: CBR_38400;  Name: ' 38400bps'),
      (Value: CBR_56000;  Name: ' 56000bps'),
      (Value: CBR_128000; Name: '128000bps'),
      (Value: CBR_256000; Name: '256000bps'),
      (Value: -1;         Name: 'հ�ް��`'));


{ �v���p�e�B�̎�ʂ�Ԃ� }
function TBaudProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList];
end;

{ �񋓌^�̒l�𕶎���ɕϊ����� }
function TBaudProperty.GetValue: string;
var
  i: Integer;
  v: Integer;
begin
  v := GetOrdValue;                         // �񋓌^�̒l�̎擾
                                            // �e�[�u����T��
  for i := Low(BaudEntry) to High(BaudEntry) do
  begin
    if v = BaudEntry[i].Value then          // �������l����������
    begin
      Result := BaudEntry[i].Name;          // ������\����Ԃ�
      Exit;
    end;
  end;
  Result := 'հ�ް��`';
end;


{ �I�����ꂽ�l��񋓌^�̒l�ɕϊ� }
procedure TBaudProperty.SetValue(const Value: string);
var
  i: Integer;
begin
  for i := Low(BaudEntry) to High(BaudEntry) do
  begin
    if Value = BaudEntry[i].Name then
    begin
      SetOrdValue(BaudEntry[i].Value);
      Exit;
    end;
  end;
  raise EPropertyError.Create('Invalid Value');
end;


{ �I�u�W�F�N�g�C���X�y�N�^�̃h���b�v�R���{�{�b�N�X�ɕ\������l��߂� }
procedure TBaudProperty.GetValues(Proc: TGetStrProc);
var
  i: Integer;
begin
  for i := Low(BaudEntry) to High(BaudEntry) do
    Proc(BaudEntry[i].Name);
end;



{ �R���|�[�l���g�̓o�^ }
procedure Register;
begin
  RegisterComponents('Comm', [TComm]);
  RegisterPropertyEditor(TypeInfo(Integer), TComm, 'BaudRate', TBaudProperty);
end;

end.
