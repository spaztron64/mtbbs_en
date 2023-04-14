unit Define;
{

********************************************

   MTBBS �����ݒ胆�j�b�g  //

�@�@   Copyright (C) 1997.10.9 By MYO

********************************************


}
interface
uses
    SysUtils,Forms,Classes;


Const

   MTBBSVERSION ='3.03';

   DefMainMenuMessage =
    	 'MTBBS Ver %V �sMain Menu�t   %T  %I / %H'#13#10
        +'BOARD/MAIL -------------  INFORMATION ------------  OTHERS -----------------'#13#10
	+'[N]ews  Read the news   | [A]pply   Register      | [Q]uit    Log out'#13#10
	+'[N@]    Continuous news | [H]elp    Show cmd usage| [I]nstall More settings'#13#10
	+'[R]ead  Read posts      | [U]sers   List members  | [W]ho     Show active users'#13#10
	+'[E]nter Write a post    | [L]og     Show logs     | [C]hat    Chatrooms'#13#10
	+'[K]ill  Delete a post   | pr[O]file Show profile  | [T]elegram Private msgs'#13#10
	+'[#]     Display status  | s[Y]sinfo Show host info| e[X]who   Show active IPs'#13#10
	+'[M]ail  Read your mail  | [_]       Show version  | [F]ile    File board'#13#10
	+'[P]ost  Post on freechat| [S]ysop   Call SysOp    | [FN]      File news'#13#10
       ;


   FileMenuMessage =
         'MTBBS Ver '+MTBBSVERSION+'�sFile board menu�t'#13#10
        +' Commands ---------------- Download----- -----------  Upload----------------'#13#10
        +'  [L]ist    List Files   | [ZD] : Zmodem Download  | [FU] : Upload via FTP'#13#10
        +'  [K]ill    Delete       | [YD] : Ymodem Download  | [ZU] : Zmodem Upload'#13#10
        +'  [I]nfo    Show info    | [MD] : Mlink  Download  | [YU] : Ymodem Upload'#13#10
        +'  [?]       File menu    | [XD] : Xmodem Download  | [MU] : Mlink  Upload'#13#10
        +'  [0]       Quit         | [D]  : Read file info   | [XU] : Xmodem Upload'#13#10;

   ReadMenuMessage =
        '                                                                / read menu '#13#10
       +'COMMANDS ---------------  COMMANDS ------------  COMMANDS ---------------'#13#10
       +'[R]ead       Read posts  | [#] Status          |  n Read ascending from n '#13#10
       +'[I]ndividual Read 1 post | [?] Menu            | -n Read descending from n'#13#10
       +'[S]earch     Search posts| [0] Quit            |  0 Read asc. from start '#13#10
       +'[L]ist       List titles |                     |[RET] Read desc. from start '#13#10;


   InstallMenuMessage =
         '                                                               / install menu '#13#10
        +'---------------------------------- INSTALL -----------------------------------'#13#10
        +'[-]:Newline code | [P]:Set password  | [H]:Set handle�@  | [M]:Write memo   '#13#10
        +'[N]:Cycle list   | [-]:ESC use   �@  | [-]:YMODEM-g �@   | [B]:Set PM bell  '#13#10
        +'[-]:Acc. log show| [-]:Acc. log range| [-]:Skip board dsp| [R]:Unread date  '#13#10
        +'[A]:Login notif  |                   |                   | [0]:end          '#13#10;

   ChatMenuMessage =
         '                                                            / chat menu'#13#10
        +'-------------------------------- CHAT ----------------------------------'#13#10
        +'[W]ho     Show users   | [E]cho   ECHO ON/OFF | [T]elegram Send PM     '#13#10
        +'pr[O]file Show profile | [?]      Print this  | [N]ow      Current time'#13#10
        +'[M]ain    MAIN command | [S]ysop  Call SysOp  | //,�^�^�@  Leave'#13#10
        +'[C]hat    Edit chatroom|                      |                '#13#10;


   SysopMenuMessage =
         '                                                                 / sysop menu'#13#10
        +'------------------------------------------------------------------------------'#13#10
        +'[A] Register user| [Q] Silent logout   | [-] Download list   | [-]Board def.  '#13#10
        +'[-] Set permits  | [-] File operations | [L] Set level       | [-]Message reg.'#13#10
        +'[R] Reload config| [-] Verify new user | [K] Open channel    | [0]end'#13#10;

   HostVersionMessage  =
        #13#10
        +' Host program �l�s�a�a�r Version '+MTBBSVERSION+#13#10
        +' Copyright(C) 1997.10,1999.8 By Yoshihiro Myokan (�l�x�n)'#13#10
        +' Translated and enhanced by Aleksa Odzakovic (spaztron64)'#13#10
        +'-------------------------------------------------------'#13#10
        +'  Want to host your own instance? Get it at '#13#10
        +'  https://archive.org/details/mtbbs-source'#13#10
        +'-------------------------------------------------------'#13#10;

   DefHelpMessage = #13#10'<< Sorry, this is still under construction... >>'#13#10 ;

   DefChatRoomOpeningMessage = #13#10#13#10
        +'======================================================'#13#10
        +'        Welcome to the chat room! (^^)/               '#13#10
        +'======================================================'#13#10;


   DefOpeningMessage = #13#10' KANJI CODE = [SHIFT JIS] '#13#10
                   +#13#10
                   +'Today is %D %W'#13#10
                   +'---------------------------------------------------------'#13#10
                   +'Welcome to the PC-9800 Central Bulletin Board!'#13#10
                   +'Powered by MTBBS, a Telnet/WWW bulletin board host program'#13#10
                   +'Written for Windows 95/NT in Delphi 3'#13#10
                   +'---------------------------------------------------------'#13#10
                   +#13#10'<<< You are visitor number %N. >>>'+#13#10#13#10
                   +'If you do not have an account, login as "guest".'#13#10;

   DefLogoutMessage  = #13#10
                  +'%H, thank you for logging in today.'#13#10
                  +'We hope to see you soon again!'#13#10
                  +'(^^)/~'#13#10;

   DefLoginMessage  = #13#10+'Greetings %H!'#13#10+'Good to see you!'#13#10#13#10;

   DefFileBoardInfoMessage =
                   ' Welcome to the file board�i�O�O�^'#13#10
                  +'-------------------------------------------------------------------------'#13#10
                  +' Note that X,Y,ZModem transfers over Telnet are still broken.'#13#10
                  +' Myo never got around to fixing them and I still do not know what to do.'#13#10
                  +' For the time being, please use a raw socket connection instead.'#13#10
                  +' Ex. socat /dev/com2,b9600,raw,echo=0 TCP:defiance.lameguy64.net:6502'#13#10
                  +'-------------------------------------------------------------------------'#13#10
                  ;
   DefSysInfoMessage  =
         '�y Name �zPC-9800 Central Bulletin Board'#13#10
        +'�y SysOp �zspaztron64'#13#10
        +'�y Line �zTelnet (up to 99 channels)'#13#10
        +'�y Host �z'#13#10
        +'�y        �z�l�s�a�a�r Version '+MTBBSVERSION+#13#10
        +'�y Members �z�O�l (00/00/00����)'#13#10
        +'�y How to join �zAccount registration on Telnet or WWW'#13#10
        +'�y Services �zMail�AMessage boards�AFile boards�APMs�AChat.. etc'#13#10
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
