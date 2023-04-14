unit Define;
{

********************************************

   MTBBS �����ݒ胆�j�b�g

�@�@   Copyright (C) 1997.10.9 By MYO

********************************************


}
interface
uses
    SysUtils,Forms,Classes;


Const

   MTBBSVERSION ='3.02';

   DefMainMenuMessage =
    	 'MTBBS Ver %V �s���C�����j���[�t   %T  %I / %H'#13#10
        +'BOARD/MAIL -------------  INFORMATION ------------  OTHERS -----------------'#13#10
	+'[N]ews  �V�������̂�ǂ�| [A]pply   ����葱��    | [Q]uit    �����؂�'#13#10
	+'[N@]    �A�� News       | [H]elp    �R�}���h���  | [I]nstall �[�����̐ݒ�'#13#10
	+'[R]ead  ���b�Z�[�W��ǂ�| [U]sers   ������X�g    | [W]ho     ���O�C����'#13#10
	+'[E]nter ���b�Z�[�W�̏���| [L]og     ���O�L�^      | [C]hat    �`���b�g�E�d��'#13#10
	+'[K]ill  ���b�Z�[�W�̍폜| pr[O]file �v���t�B�[��  | [T]elegram �d��'#13#10
	+'[#]     �X�e�[�^�X�̕\��| s[Y]sinfo �z�X�g�̏Љ�  | e[X]who   IP�A�h���X�\��'#13#10
	+'[M]ail  ��  �[  ����ǂ�| [_]       Version �\��  | [F]ile    �t�@�C���{�[�h'#13#10
	+'[P]ost  �`���@�@�@  �@| [S]ysop   SYSOP�Ăяo�� | [FN]      �V���t�@�C��'#13#10
       ;


   FileMenuMessage =
         'MTBBS Ver '+MTBBSVERSION+'�s�t�@�C���{�[�h���j���[�t'#13#10
        +' �R�}���h ---------------- �_�E�����[�h ------------  �A�b�v���[�h------------'#13#10
        +'  [L]ist    �t�@�C�����X�g| [ZD] : Zmodem Download   | [FU] : FTP�o�R��Upload'#13#10
        +'  [K]ill    ��@�@�@��    | [YD] : Ymodem Download   | [ZU] : Zmodem Upload'#13#10
        +'  [I]nfo    ��@�@�@��    | [MD] : Mlink  Download   | [YU] : Ymodem Upload'#13#10
        +'  [?]       File���j���[  | [XD] : Xmodem Download   | [MU] : Mlink  Upload'#13#10
        +'  [0]       �I�@�@�@��    | [D]  : �t�@�C������ǂ�| [XU] : Xmodem Upload'#13#10;

   ReadMenuMessage =
        '                                                                / read menu '#13#10
       +'COMMANDS ---------------  COMMANDS ---------------  �ԍ��w�� ---------------'#13#10
       +'[R]ead       ���Ԃɓǂ�  | [#]     status          |  n   n���珸���ɓǂ�    '#13#10
       +'[I]ndividual ����̔ԍ�  | [?]     ���j���[        | -n   n����t���ɓǂ�    '#13#10
       +'[S]earch     ���@�@���@  | [0]     �I�@�@��        |  0   �ŏ����珸���ɓǂ� '#13#10
       +'[L]ist      �^�C�g���̂� |                         |[RET] �Ōォ��t���ɓǂ� '#13#10;


   InstallMenuMessage =
         '                                                               / install menu '#13#10
        +'---------------------------------- INSTALL -----------------------------------'#13#10
        +'[-]:���s�R�[�h�@ | [P]:�p�X���[�h �@ | [H]:�n���h��  �@  | [M]:����         '#13#10
        +'[N]:���񃊃X�g   | [-]:ESC �g�p  �@  | [-]:YMODEM-g �@   | [B]:�d�񒅐M�x�� '#13#10
        +'[-]:����۸ޕ\���@| [-]:����۸ޔ͈�   | [-]:������ް�ޕ\��| [R]:���Ǔ���     '#13#10
        +'[A]:���O�C���ʒm |                   |                   | [0]:end          '#13#10;

   ChatMenuMessage =
         '                                                            / chat menu'#13#10
        +'-------------------------------- CHAT ----------------------------------'#13#10
        +'[W]ho     ���O�C���� | [E]cho   ECHO ON/OFF | [T]elegram �d��𑗂�'#13#10
        +'pr[O]file �v���t�B�[�� | [?]      ���̐����@  | [N]ow      ���ݎ���'#13#10
        +'[M]ain    MAIN�R�}���h | [S]ysop  SYSOP �ďo��| //,�^�^�@  �I��'#13#10
        +'[C]hat    ����ٰѕҏW  |                      |                '#13#10;


   SysopMenuMessage =
         '                                                                 / sysop menu'#13#10
        +'------------------------------------------------------------------------------'#13#10
        +'[A] ����o�^     | [Q] ۸ޱ��(�L�^����)| [-] �޳�۰�ރ��X�g  | [-]�{�[�h��`�ύX'#13#10
        +'[-] ���p���ύX | [-] �t�@�C������    | [L] ���x���ύX      | [-]���b�Z�[�W�o�^'#13#10
        +'[R] �ݒ�ēǍ�   | [-] ����F        | [K] �`�����l���J��  | [0]end'#13#10;

   HostVersionMessage  =
        #13#10
        +' �z�X�g�v���O���� �l�s�a�a�r Version '+MTBBSVERSION+#13#10
        +' Copyright(C) 1997.10,1999.8 By Yoshihiro Myokan (�l�x�n)'#13#10
        +#13#10
        +'-------------------------------------------------------'#13#10
        +' MTBBS�̍ŐV�ŁE��񓙂͈ȉ��̃z�[���y�[�W�ɂ���܂��B'#13#10
        +'  http://member.nifty.ne.jp/myo/mtbbs/ [MTBBS�J����]'#13#10
        +'-------------------------------------------------------'#13#10;

   DefHelpMessage = #13#10'<< ���߂�Ȃ����E�E�������ł� >>'#13#10 ;

   DefChatRoomOpeningMessage = #13#10#13#10
        +'======================================================'#13#10
        +'        �`���b�g���[���ւ悤���� (^^)/                '#13#10
        +'======================================================'#13#10;


   DefOpeningMessage = #13#10#13#10' KANJI CODE = [SHIFT JIS] '#13#10
                   +#13#10
                   +'�����́A%D %W�j���ł��B'#13#10
                   +'---------------------------------------------------------'#13#10
                   +'�l�s�a�a�r�ւ悤�����I'#13#10
                   +'�l�s�a�a�r��Telnet�Őڑ��\�ȃz�X�g�v���O�����ł��B'#13#10
                   +'Delphi3�ɂ���ĊJ������Ă���Windows95/NT��œ��삵�܂��B'#13#10
                   +'---------------------------------------------------------'#13#10
                   +#13#10'<<< ���Ȃ��́A%N�Ԗڂ̃��O�C���҂ł� >>>'+#13#10#13#10
                   +'#�Q�X�g�Ń��O�C������ꍇ�� guest �Ɠ��͂��Ă�������.'#13#10;

   DefLogoutMessage  = #13#10
                  +'%H ����A���O�C�����肪�Ƃ��������܂����B'#13#10
                  +'�܂����炵�Ă��������ˁB'#13#10
                  +'(^^)/~'#13#10;

   DefLoginMessage  = #13#10+'%H����A%A�E�E'#13#10+'���z���������肪�Ƃ��������܂��B'#13#10#13#10;

   DefFileBoardInfoMessage =
                   ' �t�@�C���{�[�h�ւ悤�����i�O�O�^'#13#10
                  +'-------------------------------------------------------------------------'#13#10
                  +'�@�܂�TELNET�ł�X,Y,ZMODEM,MLINK�̓]�����ł��܂���B�����ӂ��������B'#13#10
                  +'  �Ȃ��A�e�s�o�Ńt�@�C���{�[�h�ɃA�N�Z�X�ł���悤�ɂȂ��Ă��܂��̂�'#13#10
                  +'�C���^�[�l�b�g�o�R�ł̐ڑ��̕��͂��������������B'#13#10
                  +'�@�e�s�o���g�p�����A�b�v���[�h���\�ƂȂ��Ă���܂��B'#13#10
                  +'-------------------------------------------------------------------------'#13#10
                  ;
   DefSysInfoMessage  =
         '�y ���@�� �z�l�s�a�a�r�l�b�g'#13#10
        +'�y �^�c�� �zSYSOP'#13#10
        +'�y ��@�� �zTelnet(�X�X�`�����l��)'#13#10
        +'�y �z�X�g �z'#13#10
        +'�y        �z�l�s�a�a�r Version '+MTBBSVERSION+#13#10
        +'�y ����� �z�O�l (00/00/00����)'#13#10
        +'�y������@�z�I�����C���T�C���A�b�v'#13#10
        +'�y�T�[�r�X�z���[���A���b�Z�[�W�{�[�h�A�t�@�C���{�[�h�A�d��A�`���b�g..etc'#13#10
        ;
   DefApplyInfoMessage = #13#10;

   DefOkotobaStrs =
                   '�ǂ��ǂ�'#13#10
                  +'�����Delphi'#13#10
                  +'�e�������ɂ���V����'#13#10
                  +'�O�@�M��I�΂�'#13#10
                  +'�������������̂͂Ȃ�'#13#10
                  +'������ς���ΎR�ƂȂ�'#13#10
                  +'�V�͐l�̏�ɐl�𑢂炸�l�̉��ɐl�𑢂炸'#13#10
                  +'�����ĕ�炷���ꐶ�΂��ĕ�炷���ꐶ'#13#10
                  +'�ł�ӂ����͑ł����'#13#10
                  +'�K�v�͔����̕�'#13#10
                  +'�l�̉\�����\�ܓ�'#13#10
                  +'�l�͌������ɂ��ʂ���'#13#10
                  +'�l�̐U�茩�ĉ䂪�U�蒼��'#13#10
                  +'�l�̌��ɂ͌˂͗��Ă���'#13#10
                  +'�S���͈ꌩ�ɔ@����'#13#10
                  +'�����邪����'#13#10
                  +'����ʕ��Ɍ��Ȃ�'#13#10
                  +'���I�O�N�`���N'#13#10
                  +'���[�}�͈���ɂ��ĂȂ炸'#13#10
                  +'�����̕S��荡���̌܏\'#13#10
                  +'�������čӂ���'#13#10
                  +'�����ɂ����Ȃ�'#13#10
                  +'�Ă����萶�ނ��Ղ�'#13#10
                  +'��x���˂Γ�x�͎��Ȃ�'#13#10
                  +'����͏\���̒x��'#13#10
                  +'���������Ζ_�ɓ�����'#13#10
                  +'��̒��̊^��C��m�炸'#13#10
                  +'�A������Ηz�񂠂�'#13#10
                  +'��ɂ͏オ����'#13#10
                  +'�R���͓D�_�̎n�܂�'#13#10
                  +'���܂����Ƃ͓�x�l����'#13#10
                  +'�\������Ήe������'#13#10
                  +'�����Ȃ���΋ߗJ����'#13#10;


  Var
     MainMenuMessage          ,
     HelpMessage              ,
     OpeningMessage           ,
     LoginMessage             ,
     LogoutMessage            ,
     ApplyInfoMessage         ,
     SysInfoMessage           ,
     FileBoardInfoMessage     ,
     ChatRoomOpeningMessage     : String;
     OkotobaStrs : Tstringlist;


  Type


   TKinou      = (_Users,_Whos,_Chat,_Telegram,_SysopCall,_Profile,_Log,_Ip,_EnterMail,_Mail,_FreePost,_11,_12,_13,_14,_15,_16,_17,_18,_19,_20,_21,_22,_23,_24,_25,_26,_27,_28,_29);
   TUserLevel  = -1..9;
   TLevels     = Array [TUserLevel] of Boolean;


   TGeneralDefine = Record
      Apply : Record
          AutoRegist   : Boolean;   //�����o�^�����邩
          UseFreeID    : Boolean;   //���R��ID���g�p�ł���悤�ɂ��邩
          IDHead       : String[8]; //ID�̃w�b�_
          IDNumLength  : Integer;   //ID�̐��������̒���
          StartLevel   : Integer;
          StartLastReadDate : Integer;
       End;
      Telegram : Record
          GuestUse     : Boolean;   //�Q�X�g�ł��d����g�p�\��
          RecvMax      : Integer;   //�d��̎�M�\��
          LoginTelegram: Boolean;
       End;
      User    : Record
          SysopCall      : Boolean;   //Sysop�R�[�����g�p���邩
          GuestID        : String[8];
          GoodbyeMessage : Boolean;
          GuestLastReadDate : Integer;
          SysopLevel     : Integer;
       End;
      Other    : Record
          Log_MaxSize      : Integer;
          FreePost_MaxSize : Integer;
          GoodbyeMessage_MaxSize : Integer;
          ReadPromptBeforeMessage : Boolean;
          AccessCountReset : Integer;
       End;

      Chat     : Record
          BackLogLines : Integer;
          SaveLog      : Boolean;
          LogFileName  : String;
       End;

      Profile : Record
          Name         : Boolean;
          Address      : Boolean;
          Tel          : Boolean;
          Hobby        : Boolean;
          BirthDay     : Boolean;
          SignOn       : Boolean;
          Comment      : Boolean;
          Email        : Boolean;
       End;

      TCPIP : Record
          Port             : String;
          wwwPort          : String;
          MaxClientsLimit  : Integer;
          MaxSameIp        : Integer;
          IdleTimeLimit    : Integer;
          wwwIdleTimeLimit : Integer;
          WWWroot          : String;
      End;



      Mail  : Record
          SaveDayLimit        : Integer;
          UseGuestMailToSysop : Boolean;
          BoxSize             : Integer;
          OneSendMax          : Integer;
      End;

      StartUp  : Record
          OpenTelnet         : Boolean;
          OpenModem          : Boolean;
          OpenWWW            : Boolean;
          OpenMTIDS          : Boolean;
          StartTinou         : Boolean;
          minimize           : Boolean;
      End;

      Sound : Record
          PlayLogin          : Boolean;
          PlayLogout         : Boolean;
          PlaySysopCall      : Boolean;
          LoginFileName      : String;
          LogoutFileName     : String;
          SysopCallFileName  : String;
      End;

      MTIDS : Record
          HostName           : String[8];
          Port               : String;
      End;



      CanUseLevels     : Array[TKinou] of TLevels;

   End;

Var

   GeneralDefine : TGeneralDefine;

implementation

Initialization
   OkotobaStrs := TStringList.Create;

Finalization
   OkotobaStrs.Free;

end.
