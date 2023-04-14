unit Define;
{

********************************************

   MTBBS 総合設定ユニット

　　   Copyright (C) 1997.10.9 By MYO

********************************************


}
interface
uses
    SysUtils,Forms,Classes;


Const

   MTBBSVERSION ='3.02';

   DefMainMenuMessage =
    	 'MTBBS Ver %V 《メインメニュー》   %T  %I / %H'#13#10
        +'BOARD/MAIL -------------  INFORMATION ------------  OTHERS -----------------'#13#10
	+'[N]ews  新しいものを読む| [A]pply   入会手続き    | [Q]uit    回線を切る'#13#10
	+'[N@]    連続 News       | [H]elp    コマンド解説  | [I]nstall 端末等の設定'#13#10
	+'[R]ead  メッセージを読む| [U]sers   会員リスト    | [W]ho     ログイン状況'#13#10
	+'[E]nter メッセージの書込| [L]og     ログ記録      | [C]hat    チャット・電報'#13#10
	+'[K]ill  メッセージの削除| pr[O]file プロフィール  | [T]elegram 電報'#13#10
	+'[#]     ステータスの表示| s[Y]sinfo ホストの紹介  | e[X]who   IPアドレス表示'#13#10
	+'[M]ail  メ  ー  ルを読む| [_]       Version 表示  | [F]ile    ファイルボード'#13#10
	+'[P]ost  伝言板　　　  　| [S]ysop   SYSOP呼び出し | [FN]      新着ファイル'#13#10
       ;


   FileMenuMessage =
         'MTBBS Ver '+MTBBSVERSION+'《ファイルボードメニュー》'#13#10
        +' コマンド ---------------- ダウンロード ------------  アップロード------------'#13#10
        +'  [L]ist    ファイルリスト| [ZD] : Zmodem Download   | [FU] : FTP経由でUpload'#13#10
        +'  [K]ill    削　　　除    | [YD] : Ymodem Download   | [ZU] : Zmodem Upload'#13#10
        +'  [I]nfo    情　　　報    | [MD] : Mlink  Download   | [YU] : Ymodem Upload'#13#10
        +'  [?]       Fileメニュー  | [XD] : Xmodem Download   | [MU] : Mlink  Upload'#13#10
        +'  [0]       終　　　了    | [D]  : ファイル情報を読む| [XU] : Xmodem Upload'#13#10;

   ReadMenuMessage =
        '                                                                / read menu '#13#10
       +'COMMANDS ---------------  COMMANDS ---------------  番号指定 ---------------'#13#10
       +'[R]ead       順番に読む  | [#]     status          |  n   nから昇順に読む    '#13#10
       +'[I]ndividual 特定の番号  | [?]     メニュー        | -n   nから逆順に読む    '#13#10
       +'[S]earch     検　　索　  | [0]     終　　了        |  0   最初から昇順に読む '#13#10
       +'[L]ist      タイトルのみ |                         |[RET] 最後から逆順に読む '#13#10;


   InstallMenuMessage =
         '                                                               / install menu '#13#10
        +'---------------------------------- INSTALL -----------------------------------'#13#10
        +'[-]:改行コード　 | [P]:パスワード 　 | [H]:ハンドル  　  | [M]:メモ         '#13#10
        +'[N]:巡回リスト   | [-]:ESC 使用  　  | [-]:YMODEM-g 　   | [B]:電報着信ベル '#13#10
        +'[-]:ｱｸｾｽﾛｸﾞ表示　| [-]:ｱｸｾｽﾛｸﾞ範囲   | [-]:ｽｷｯﾌﾟﾎﾞｰﾄﾞ表示| [R]:未読日時     '#13#10
        +'[A]:ログイン通知 |                   |                   | [0]:end          '#13#10;

   ChatMenuMessage =
         '                                                            / chat menu'#13#10
        +'-------------------------------- CHAT ----------------------------------'#13#10
        +'[W]ho     ログイン状況 | [E]cho   ECHO ON/OFF | [T]elegram 電報を送る'#13#10
        +'pr[O]file プロフィール | [?]      この説明　  | [N]ow      現在時刻'#13#10
        +'[M]ain    MAINコマンド | [S]ysop  SYSOP 呼出し| //,／／　  終了'#13#10
        +'[C]hat    ﾁｬｯﾄﾙｰﾑ編集  |                      |                '#13#10;


   SysopMenuMessage =
         '                                                                 / sysop menu'#13#10
        +'------------------------------------------------------------------------------'#13#10
        +'[A] 会員登録     | [Q] ﾛｸﾞｱｳﾄ(記録無し)| [-] ﾀﾞｳﾝﾛｰﾄﾞリスト  | [-]ボード定義変更'#13#10
        +'[-] 利用許可変更 | [-] ファイル操作    | [L] レベル変更      | [-]メッセージ登録'#13#10
        +'[R] 設定再読込   | [-] 入会承認        | [K] チャンネル開放  | [0]end'#13#10;

   HostVersionMessage  =
        #13#10
        +' ホストプログラム ＭＴＢＢＳ Version '+MTBBSVERSION+#13#10
        +' Copyright(C) 1997.10,1999.8 By Yoshihiro Myokan (ＭＹＯ)'#13#10
        +#13#10
        +'-------------------------------------------------------'#13#10
        +' MTBBSの最新版・情報等は以下のホームページにあります。'#13#10
        +'  http://member.nifty.ne.jp/myo/mtbbs/ [MTBBS開発室]'#13#10
        +'-------------------------------------------------------'#13#10;

   DefHelpMessage = #13#10'<< ごめんなさい・・準備中です >>'#13#10 ;

   DefChatRoomOpeningMessage = #13#10#13#10
        +'======================================================'#13#10
        +'        チャットルームへようこそ (^^)/                '#13#10
        +'======================================================'#13#10;


   DefOpeningMessage = #13#10#13#10' KANJI CODE = [SHIFT JIS] '#13#10
                   +#13#10
                   +'今日は、%D %W曜日です。'#13#10
                   +'---------------------------------------------------------'#13#10
                   +'ＭＴＢＢＳへようこそ！'#13#10
                   +'ＭＴＢＢＳはTelnetで接続可能なホストプログラムです。'#13#10
                   +'Delphi3によって開発されておりWindows95/NT上で動作します。'#13#10
                   +'---------------------------------------------------------'#13#10
                   +#13#10'<<< あなたは、%N番目のログイン者です >>>'+#13#10#13#10
                   +'#ゲストでログインする場合は guest と入力してください.'#13#10;

   DefLogoutMessage  = #13#10
                  +'%H さん、ログインありがとうございました。'#13#10
                  +'またいらしてくださいね。'#13#10
                  +'(^^)/~'#13#10;

   DefLoginMessage  = #13#10+'%Hさん、%A・・'#13#10+'お越し頂きありがとうございます。'#13#10#13#10;

   DefFileBoardInfoMessage =
                   ' ファイルボードへようこそ（＾＾／'#13#10
                  +'-------------------------------------------------------------------------'#13#10
                  +'　まだTELNETではX,Y,ZMODEM,MLINKの転送ができません。ご注意ください。'#13#10
                  +'  なお、ＦＴＰでファイルボードにアクセスできるようになっていますので'#13#10
                  +'インターネット経由での接続の方はお試しください。'#13#10
                  +'　ＦＴＰを使用したアップロードも可能となっております。'#13#10
                  +'-------------------------------------------------------------------------'#13#10
                  ;
   DefSysInfoMessage  =
         '【 名　称 】ＭＴＢＢＳネット'#13#10
        +'【 運営者 】SYSOP'#13#10
        +'【 回　線 】Telnet(９９チャンネル)'#13#10
        +'【 ホスト 】'#13#10
        +'【        】ＭＴＢＢＳ Version '+MTBBSVERSION+#13#10
        +'【 会員数 】０人 (00/00/00現在)'#13#10
        +'【入会方法】オンラインサインアップ'#13#10
        +'【サービス】メール、メッセージボード、ファイルボード、電報、チャット..etc'#13#10
        ;
   DefApplyInfoMessage = #13#10;

   DefOkotobaStrs =
                   'どもども'#13#10
                  +'時代はDelphi'#13#10
                  +'親しき仲にも礼儀あり'#13#10
                  +'弘法筆を選ばず'#13#10
                  +'ただより安いものはない'#13#10
                  +'ちりも積もれば山となる'#13#10
                  +'天は人の上に人を造らず人の下に人を造らず'#13#10
                  +'泣いて暮らすも一生笑って暮らすも一生'#13#10
                  +'でるふぁいは打たれる'#13#10
                  +'必要は発明の母'#13#10
                  +'人の噂も七十五日'#13#10
                  +'人は見かけによらぬもの'#13#10
                  +'人の振り見て我が振り直せ'#13#10
                  +'人の口には戸は立てられぬ'#13#10
                  +'百聞は一見に如かず'#13#10
                  +'負けるが勝ち'#13#10
                  +'迷わぬ物に悟りなし'#13#10
                  +'桃栗三年柿八年'#13#10
                  +'ローマは一日にしてならず'#13#10
                  +'明日の百より今日の五十'#13#10
                  +'当たって砕けよ'#13#10
                  +'阿呆につける薬なし'#13#10
                  +'案ずるより生むが易い'#13#10
                  +'一度死ねば二度は死なぬ'#13#10
                  +'一日は十日の遅れ'#13#10
                  +'犬も歩けば棒に当たる'#13#10
                  +'井の中の蛙大海を知らず'#13#10
                  +'陰徳あれば陽報あり'#13#10
                  +'上には上がある'#13#10
                  +'嘘つきは泥棒の始まり'#13#10
                  +'うまいことは二度考えよ'#13#10
                  +'噂をすれば影がさす'#13#10
                  +'遠慮なければ近憂あり'#13#10;


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
          AutoRegist   : Boolean;   //自動登録をするか
          UseFreeID    : Boolean;   //自由なIDを使用できるようにするか
          IDHead       : String[8]; //IDのヘッダ
          IDNumLength  : Integer;   //IDの数字部分の長さ
          StartLevel   : Integer;
          StartLastReadDate : Integer;
       End;
      Telegram : Record
          GuestUse     : Boolean;   //ゲストでも電報を使用可能か
          RecvMax      : Integer;   //電報の受信可能数
          LoginTelegram: Boolean;
       End;
      User    : Record
          SysopCall      : Boolean;   //Sysopコールを使用するか
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
