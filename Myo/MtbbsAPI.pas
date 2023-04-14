unit MtbbsAPI;

(******************************************************

   MTBBS API Definition for MTBBS Ver 1.32

   Copyright (C) 1998.2-1998.3.25 By Yoshihiro Myokan.

 ******************************************************)

interface
Type
         TVersion          = Function : Pchar                     of Object;stdcall;
         TTerminated       = Function : Boolean                   of Object;stdcall;// =True �̎����ׂĂ̏����𒆎~���邱��
         TChangeWhere      = Procedure(s : Pchar)                 of Object;stdcall;//Where��ύX
         TSendln           = Procedure(s : PChar)                 of Object;stdcall;//�P�s���M
         TRecvln           = function : PChar                     of Object;stdcall;//�P�s��M
         TPuts             = Procedure(s : PChar)                 of Object;stdcall;//���M
         TYesNoInput       = Function(Prompt:Pchar):Boolean       of Object;stdcall;//YES�̂Ƃ�True�@�d���M�ɑΉ�
         TInput            = Function(Prompt : Pchar):Pchar       of Object;stdcall;//���� �d���M�ɑΉ�
         TInputCommand     = Function(Prompt:Pchar;CharInp:Boolean):PChar of Object;stdcall;//�d���M�ɑΉ�
         TWho              = Procedure                            of Object;stdcall;//���O�C����
         TTelegram         = Procedure                            of Object;stdcall;//�d�񑗐M
         TIsReceived       = Function:Boolean                     of Object;stdcall;//�P�s����M����Ă��邩
         TIsUsedChannel    = Function (Ch : LongInt):Boolean      of Object;stdcall;//�`�����l�����g���Ă��邩
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
          TUserInfo = Record  //�z���g��packed record�ɂ����������񂾂���MTBBS�����̂�
                              //�R�Q�r�b�g�P�ʂŃA�N�Z�X���s����unpackedRecord�Ȃ̂Ŏ蔲���ł��Ȃ������E�E
                              //�Ƃ����킯�ŁA���̌�����g���Ă�����͗v����(���Ԃ񂢂Ȃ��Ƃ���������)
                              //���Ă������AVC�Ƃ��ł͂��Ƃ��ƃv���O�C���̊J���͖����ȋC���E�E�E�E
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
                            Dummy : String[10]; //�\���ł�(^^;�������P�O(11)�o�C�g�E�E�E
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

             Dummy        :  Array[24..99] of TProcedure; //�\��
                             //  ���[��...����Ȃ��Ȃ����肵��(^^;
                             //  �Ȃ񂩂����Ɨǂ��󂯓n�����@�͖����̂��낤���E�E�E
         End;

implementation
end.
