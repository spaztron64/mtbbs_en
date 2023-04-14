unit mtids;


(**************************************************************************
           MTIDS  MT IP DATABASE SYSTEM
               Copyright(C) 1999.8 By Yoshihiro Myokan
 **************************************************************************)


interface
uses Winsock;

Type


  TPacketRecord         = packed Record
                           Buf        : array[0..2] of char;//MT2,3
                           PacketSize : Integer;
                           ToHost     : String[8];
                           ToID       : String[8];
                           FromHost   : String[8];
                          End;

       TMTQSystemPortData  = packed Record   //4byte
                              MFTP        : word;//ファイル転送用のポート
                              DUMMY1      : word;//予備
                             End;
       TMTQPersonalServerData  = Array[0..3] of //パーソナル・サーバー情報 12Byte
                           packed Record   //3byte
                             Service     : byte; // 0..NO  1..FTP 2..WWW 3..TELNET 4..MTBBS
                             Port        : word;
                           End;
       TMTQLoginMode        = set of (UI_SERVER,UI_OPEN_IP,UI_2,UI_3,UI_4,UI_5,UI_6,UI_7);
                                   //接続待機を行っている,ｺﾝﾀｸﾄﾘｽﾄに登録されて無いﾕｰｻﾞｰに対してもIPアドレスを公開

   TMTQUserInfo          = packed Record//  25byte
                              SystemPortData     : TMTQSystemPortData;//4byte
                              PersonalServerData : TMTQPersonalServerData;//12byte
                              LoginMode          : TMTQLoginMode;//1byte
                              InAddr             : TInAddr;//4byte?! ＩＰアドレス
                              dummy              : integer;//4byte
                           end;
  TUserPacketFrom    = packed Record
                           Host   : String[8]; //add by host
                           ID     : String[8]; //add by host
                           Handle : String[14];//add by host if empty
                           EMail  : String[40];
                       End;
const
  UserPacketRecordDataMaxSize = 1024;
Type
  TUserPacketRecord    = packed Record //ユーザー同士がやり取りする際のパケット
                           Buf        : array[0..2] of char;//MT2
                           PacketSize : Integer;
                           ToHost     : String[8];
                           ToID       : String[8];
                           From       : TUserPacketFrom;
                           Info       : TMTQUserInfo;
                           DataType   : Byte;//0..Telegram 1..RequestContact 2..FileTransfer 3.prugin file
                           DateTime   : TDateTime;    //add by host
                           Data       : array[0..UserPacketRecordDataMaxSize-1] of char; //Max 512byte
                         End;

      TMTQTranFile = packed  Record
                        FileName     : String[64]; //65
                        Size         : Integer; //4
                     End;
      TFTRequest = (FTR_RECEIVE_SERVER,FTR_SEND_CLIENT,FTR_2,FTR_3,FTR_4,FTR_5,FTR_6,FTR_7);

   TMTQFileTranData  = packed Record      // TUserPacketRecord.Dataに含めるとする
                               Request    : TFTRequest;
                               FilesCount : Integer;
                               Files      : array[0..9] of TMTQTranFile;
                               Mes        : array[0..255] of char;
                             end;

  TConatctDataRecord    = packed Record
                           Host      : string[8];
                           ID        : string[8];
                           treatment : byte;//0..普通の扱い
                          end;

  TLoginPacketRecord    = packed Record
                           Buf        : array[0..2] of char;  //MT[0]
                           PacketSize : Integer;
                           ID         : String[8];
                           Password   : String[14];
                           Handle     : String[14];
                           Info       : TMTQUserInfo;
                           dummy      : integer;
                           ConatctUsersCount : integer;
                           ContactUsers : Array[0..39] of TConatctDataRecord; //MAX 40Users
                          End;

  TSystemPacketRecord  = packed Record //システムからのパケット
                           Buf       : array[0..2] of char;      //MT3
                           PacketSize: Integer;
                           ToHost    : String[8];
                           ToID      : String[8];
                           FromHost  : String[8];
                           DataType  : Byte;//0..LoginUserStatus
                           Data      : array[0..1023] of char;
                          End;

        TMTQUserStatus        = set of (US_ONLINE,US_CONTACT,US_2,US_3,US_4,US_5,US_6,US_7);
                                     //ｵﾝﾗｲﾝである,ｺﾝﾀｸﾄﾘｽﾄに登録されている
      TMTQUserData       = packed Record    //35byte
                               ID      : String[8];// 9byte
                               Status  : TMTQUserStatus; //1byte
                               Info    : TMTQUserInfo; //25Byte
                             end;

     TMTQUsersDataRecord =  packed Record //TSystemPacketRecord.Dataに含めるとする
                               Count : Integer;
                               Data  : Array [0..39] of TMTQUserData;
                            End;



  TMTIDSMessage = Record
                    ToID       : String[8];
                    DateTime   : TDateTime;
                    From       : TUserPacketFrom;
                    Info       : TMTQUserInfo;
                    DataType   : Byte;//0..Telegram 1..RequestContact 2..MTQ Standard Command 3.prugin file
                    Mes        : String;
                  End;

  TMTIDSClientData = Record
                      ID        : string[8];
                      Handle    : String[14];
                      Socket    : Integer;
                      Info      : TMTQUserInfo;
                      LoginTime : TDateTime;
                      LoginMode : Char;
               ContactListCount : integer;
                    ContactList : Array [0..99] of TConatctDataRecord;
                     End;

Function MTIDS_add(MTIDSClientData : TMTIDSClientData):integer;
Function MTIDS_IdToIndex(ID : string) : Integer;
Function MTIDS_AddSleepMessage(Mes : TMTIDSMessage) : Integer;
Function MTIDS_SearchSleepMessage(ID : string;StartIndex : Integer) : Integer;

var

          MTIDSClientDataBase : Array [0..99] of TMTIDSClientData;
          SleepMessages : Array[0..1999] of TMTIDSMessage;


implementation


Function MTIDS_add(MTIDSClientData : TMTIDSClientData):integer;
var
  i : integer;
Begin


   i := MTIDS_IdToIndex(MTIDSClientData.ID);
   Result := i;
    if i>-1 then
      MTIDSClientDataBase[i] := MTIDSClientData
   else
      for i:=0 to 99 do
           if MTIDSClientDataBase[i].ID='' then
             Begin
               MTIDSClientDataBase[i] := MTIDSClientData;
               Result := i;
               Exit;
             End;
End;


Function MTIDS_IdToIndex(ID : string) : Integer;
var
  i : integer;
Begin

   if ID ='' then     Result := -1
   else
    for i:=0 to 99 do
      if MTIDSClientDataBase[i].ID = ID then
       Begin
         Result := i;
         Exit;
       End;
    Result := -1
End;


Function MTIDS_SearchSleepMessage(ID : string;StartIndex : Integer) : Integer;
var
  i : integer;
Begin
    for i:=StartIndex to 1999 do
      if SleepMessages[i].ToID = ID then
       Begin
         Result := i;
         Exit;
       End;
    Result := -1
End;

Function MTIDS_AddSleepMessage(Mes : TMTIDSMessage) : Integer;
Begin
       Result := MTIDS_SearchSleepMessage('',0);
       if Result>-1 then
          SleepMessages[result] := Mes;
End;



end.
