unit MtbbsAPI;

(******************************************************

   MTBBS API Definition for MTBBS Ver 1.32

   Copyright (C) 1998.2-1998.3.25 By Yoshihiro Myokan.

 ******************************************************)

interface
Type
         TVersion          = Function : Pchar                     of Object;stdcall;
         TTerminated       = Function : Boolean                   of Object;stdcall;// =True の時すべての処理を中止すること
         TChangeWhere      = Procedure(s : Pchar)                 of Object;stdcall;//Whereを変更
         TSendln           = Procedure(s : PChar)                 of Object;stdcall;//１行送信
         TRecvln           = function : PChar                     of Object;stdcall;//１行受信
         TPuts             = Procedure(s : PChar)                 of Object;stdcall;//送信
         TYesNoInput       = Function(Prompt:Pchar):Boolean       of Object;stdcall;//YESのときTrue　電報受信に対応
         TInput            = Function(Prompt : Pchar):Pchar       of Object;stdcall;//入力 電報受信に対応
         TInputCommand     = Function(Prompt:Pchar;CharInp:Boolean):PChar of Object;stdcall;//電報受信に対応
         TWho              = Procedure                            of Object;stdcall;//ログイン状況
         TTelegram         = Procedure                            of Object;stdcall;//電報送信
         TIsReceived       = Function:Boolean                     of Object;stdcall;//１行分受信されているか
         TIsUsedChannel    = Function (Ch : LongInt):Boolean      of Object;stdcall;//チャンネルが使われているか
          TUserData        = packed Record
            ID         : string[8];
            HandleName : String[14];
            Memo       : String[25];
            Level      : Integer;
            Where      : String[8];
          End;
         TGetLoginUserData = Function (Ch : LongInt):TUserData    of Object;stdcall;
         TPutEchoStrs      = Procedure                            of Object;stdcall;
         TInputText        = Function  : Pchar                    of Object;stdcall;
         TRecvTelegram     = Procedure                            of Object;stdcall;
         TSendTelegram     = Procedure(ToCh : Integer;From : PChar;Mes : Pchar)  of Object;stdcall;
         TUsersCount       = Function : Integer                   of Object;stdcall;
         TSearchUser       = Function (ID : PChar):Integer        of Object;stdcall;
          TUserInfo = Record  //ホントはpacked recordにしたかったんだけどMTBBS内部のが
                              //３２ビット単位でアクセスが行われるunpackedRecordなので手抜きできなかった・・
                              //というわけで、他の言語を使われている方は要注意(たぶんいないとおもうけど)
                              //っていうか、VCとかではもともとプラグインの開発は無理な気も・・・・
                               ID : String[8];
                         Password : String[8];
                           Handle : String[14];
                            Level : Integer;
                          Address : String[60];
                          Name    : String[30];
                          Telno   : String[20];
                          Hobby   : String[60];
                          BirthDay: String[6];
                          Comment : String[160];
                      AccessCount : Integer;
                        LastLogin : TDateTime;
                        LastRead  : TDateTime;
                             Memo : String[25];
                           SignOn : TDateTime;
                   UseLoginReport : Boolean;
                 NewsEnableBoards : Array[0..99] of Boolean;
                            Email : String[45];
                     LastFileNews : TDatetime;
              ReceiveTelegramBell : Boolean;
                            Dummy : String[10]; //予備です(^^;たった１０(11)バイト・・・
          End;   //
         TReadUserInfo      = Function  (Index : Integer):TUserInfo of Object;stdcall;
         TWriteUserInfo     = Procedure (Index : Integer;UserInfo : TUserInfo) of Object;stdcall;
         TGetLastReceiveLine= Function : Pchar of Object;stdcall;
         TIsReceivedTelegram= Function : Boolean of Object;stdcall;

         TProcedure = procedure of object;stdcall;
         TMtAPIRecord = packed Record
             Version            :  TVersion;       //0
             Terminated         :  TTerminated;    //1
             ChangeWhere        :  TChangeWhere;   //2
             Sendln             :  TSendln;        //3
             Recvln             :  TRecvln;        //4
             Puts               :  TPuts;          //5
             YesNoInput         :  TYesNoInput;    //6
             Input              :  TInput;         //7
             InputCommand       :  TInputCommand;  //8
             Who                :  TWho;           //9
             Telegram           :  TTelegram;      //10
             IsReceived         :  TIsReceived;    //11
             IsUsedChannel      :  TIsUsedChannel;//12
             GetLoginUserData   :  TGetLoginUserData;//13
             PutEchoStrs        :  TPutEchoStrs;   //14
             InputText          :  TInputText;     //15
             RecvTelegram       :  TRecvtelegram;  //16
             SendTelegram       :  TSendTelegram;  //17
             UsersCount         :  TUsersCount;    //18
             SearchUser         :  TSearchUser;    //19;
             ReadUserInfo       :  TReadUserInfo;  //20;
             WriteUserInfo      :  TWriteUserInfo; //21;
             GetLastReceiveLine :  TGetLastReceiveLine;//22
             IsReceivedTelegram :  TIsReceivedTelegram;//23

             Dummy        :  Array[24..99] of TProcedure; //予備
                             //  うーん...足りなくなったりして(^^;
                             //  なんかもっと良い受け渡し方法は無いのだろうか・・・
         End;

implementation
end.
