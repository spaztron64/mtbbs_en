unit Define;
{

********************************************

   MTBBS ‘‡İ’èƒ†ƒjƒbƒg  //

@@   Copyright (C) 1997.10.9 By MYO

********************************************


}
interface
uses
    SysUtils,Forms,Classes;


Const

   MTBBSVERSION ='3.03';

   DefMainMenuMessage =
    	 'MTBBS Ver %V sMain Menut   %T  %I / %H'#13#10
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
         'MTBBS Ver '+MTBBSVERSION+'sFile board menut'#13#10
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
        +'[-]:Newline code | [P]:Set password  | [H]:Set handle@  | [M]:Write memo   '#13#10
        +'[N]:Cycle list   | [-]:ESC use   @  | [-]:YMODEM-g @   | [B]:Set PM bell  '#13#10
        +'[-]:Acc. log show| [-]:Acc. log range| [-]:Skip board dsp| [R]:Unread date  '#13#10
        +'[A]:Login notif  |                   |                   | [0]:end          '#13#10;

   ChatMenuMessage =
         '                                                            / chat menu'#13#10
        +'-------------------------------- CHAT ----------------------------------'#13#10
        +'[W]ho     Show users   | [E]cho   ECHO ON/OFF | [T]elegram Send PM     '#13#10
        +'pr[O]file Show profile | [?]      Print this  | [N]ow      Current time'#13#10
        +'[M]ain    MAIN command | [S]ysop  Call SysOp  | //,^^@  Leave'#13#10
        +'[C]hat    Edit chatroom|                      |                '#13#10;


   SysopMenuMessage =
         '                                                                 / sysop menu'#13#10
        +'------------------------------------------------------------------------------'#13#10
        +'[A] Register user| [Q] Silent logout   | [-] Download list   | [-]Board def.  '#13#10
        +'[-] Set permits  | [-] File operations | [L] Set level       | [-]Message reg.'#13#10
        +'[R] Reload config| [-] Verify new user | [K] Open channel    | [0]end'#13#10;

   HostVersionMessage  =
        #13#10
        +' Host program ‚l‚s‚a‚a‚r Version '+MTBBSVERSION+#13#10
        +' Copyright(C) 1997.10,1999.8 By Yoshihiro Myokan (‚l‚x‚n)'#13#10
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
                   ' Welcome to the file boardiOO^'#13#10
                  +'-------------------------------------------------------------------------'#13#10
                  +' Note that X,Y,ZModem transfers over Telnet are still broken.'#13#10
                  +' Myo never got around to fixing them and I still do not know what to do.'#13#10
                  +' For the time being, please use a raw socket connection instead.'#13#10
                  +' Ex. socat /dev/com2,b9600,raw,echo=0 TCP:defiance.lameguy64.net:6502'#13#10
                  +'-------------------------------------------------------------------------'#13#10
                  ;
   DefSysInfoMessage  =
         'y Name zPC-9800 Central Bulletin Board'#13#10
        +'y SysOp zspaztron64'#13#10
        +'y Line zTelnet (up to 99 channels)'#13#10
        +'y Host z'#13#10
        +'y        z‚l‚s‚a‚a‚r Version '+MTBBSVERSION+#13#10
        +'y Members z‚Ol (00/00/00Œ»İ)'#13#10
        +'y How to join zAccount registration on Telnet or WWW'#13#10
        +'y Services zMailAMessage boardsAFile boardsAPMsAChat.. etc'#13#10
        ;
   DefApplyInfoMessage = #13#10;

   DefOkotobaStrs =
                   '‚Ç‚à‚Ç‚à'#13#10
                  +'‘ã‚ÍDelphi'#13#10
                  +'e‚µ‚«’‡‚É‚à—ç‹V‚ ‚è'#13#10
                  +'O–@•M‚ğ‘I‚Î‚¸'#13#10
                  +'‚½‚¾‚æ‚èˆÀ‚¢‚à‚Ì‚Í‚È‚¢'#13#10
                  +'‚¿‚è‚àÏ‚à‚ê‚ÎR‚Æ‚È‚é'#13#10
                  +'“V‚Íl‚Ìã‚Él‚ğ‘¢‚ç‚¸l‚Ì‰º‚Él‚ğ‘¢‚ç‚¸'#13#10
                  +'‹ƒ‚¢‚Ä•é‚ç‚·‚àˆê¶Î‚Á‚Ä•é‚ç‚·‚àˆê¶'#13#10
                  +'‚Å‚é‚Ó‚Ÿ‚¢‚Í‘Å‚½‚ê‚é'#13#10
                  +'•K—v‚Í”­–¾‚Ì•ê'#13#10
                  +'l‚Ì‰\‚àµ\ŒÜ“ú'#13#10
                  +'l‚ÍŒ©‚©‚¯‚É‚æ‚ç‚Ê‚à‚Ì'#13#10
                  +'l‚ÌU‚èŒ©‚Ä‰ä‚ªU‚è’¼‚¹'#13#10
                  +'l‚ÌŒû‚É‚ÍŒË‚Í—§‚Ä‚ç‚ê‚Ê'#13#10
                  +'•S•·‚ÍˆêŒ©‚É”@‚©‚¸'#13#10
                  +'•‰‚¯‚é‚ªŸ‚¿'#13#10
                  +'–À‚í‚Ê•¨‚ÉŒå‚è‚È‚µ'#13#10
                  +'“ŒIO”NŠ`”ª”N'#13#10
                  +'ƒ[ƒ}‚Íˆê“ú‚É‚µ‚Ä‚È‚ç‚¸'#13#10
                  +'–¾“ú‚Ì•S‚æ‚è¡“ú‚ÌŒÜ\'#13#10
                  +'“–‚½‚Á‚ÄÓ‚¯‚æ'#13#10
                  +'ˆ¢•ğ‚É‚Â‚¯‚é–ò‚È‚µ'#13#10
                  +'ˆÄ‚¸‚é‚æ‚è¶‚Ş‚ªˆÕ‚¢'#13#10
                  +'ˆê“x€‚Ë‚Î“ñ“x‚Í€‚È‚Ê'#13#10
                  +'ˆê“ú‚Í\“ú‚Ì’x‚ê'#13#10
                  +'Œ¢‚à•à‚¯‚Î–_‚É“–‚½‚é'#13#10
                  +'ˆä‚Ì’†‚ÌŠ^‘åŠC‚ğ’m‚ç‚¸'#13#10
                  +'‰A“¿‚ ‚ê‚Î—z•ñ‚ ‚è'#13#10
                  +'ã‚É‚Íã‚ª‚ ‚é'#13#10
                  +'‰R‚Â‚«‚Í“D–_‚Ìn‚Ü‚è'#13#10
                  +'‚¤‚Ü‚¢‚±‚Æ‚Í“ñ“xl‚¦‚æ'#13#10
                  +'‰\‚ğ‚·‚ê‚Î‰e‚ª‚³‚·'#13#10
                  +'‰“—¶‚È‚¯‚ê‚Î‹ß—J‚ ‚è'#13#10;


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
          AutoRegist   : Boolean;   //©“®“o˜^‚ğ‚·‚é‚©
          UseFreeID    : Boolean;   //©—R‚ÈID‚ğg—p‚Å‚«‚é‚æ‚¤‚É‚·‚é‚©
          IDHead       : String[8]; //ID‚Ìƒwƒbƒ_
          IDNumLength  : Integer;   //ID‚Ì”š•”•ª‚Ì’·‚³
          StartLevel   : Integer;
          StartLastReadDate : Integer;
       End;
      Telegram : Record
          GuestUse     : Boolean;   //ƒQƒXƒg‚Å‚à“d•ñ‚ğg—p‰Â”\‚©
          RecvMax      : Integer;   //“d•ñ‚ÌóM‰Â”\”
          LoginTelegram: Boolean;
       End;
      User    : Record
          SysopCall      : Boolean;   //SysopƒR[ƒ‹‚ğg—p‚·‚é‚©
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
