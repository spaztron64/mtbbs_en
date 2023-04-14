unit UserSys;
{

********************************************

   MTBBS ユーザー管理ユニット

       Copyright (C) 1997.10.7 By MYO

********************************************

}


interface
uses
    SysUtils,Forms,Windows;
Const

   UserInitsMax = 3000;// メンバ数の上限

Type

   TNewsEnableBoards = Array[0..99] of Boolean;

   TUserInit = Record
                      ID : String[8];
                Password : String[8];
                  Handle : String[14];
                   Level : Integer;
//
                 Address : String[60];
                 Name    : String[30];
                 Telno   : String[20];
                 Hobby   : String[60];
                 BirthDay: String[6];
                 Comment : String[160];
//
             AccessCount : Integer;
               LastLogin : TDateTime;
               LastRead  : TDateTime;
                    Memo : String[25];
                  SignOn : TDateTime;
          UseLoginReport : Boolean;
        NewsEnableBoards : TNewsEnableBoards;
                   Email : String[45];
                    //  予備
            LastFileNews : TDatetime;
     ReceiveTelegramBell : Boolean;
                   Dummy : String[10];
//
   End;


 Procedure OutUserInit(ID : String;UI : TUserInit)          ; //ユーザー情報の書き込み
 Function  DeleteUser (ID : String) : Boolean;                        //ユーザーの抹消　
 Function  GetUserInit(ID : String): TUserInit; //ユーザー情報の拾得
 Function  GetUserList : String;                                     //ユーザー一覧の拾得
 Function DefaultUserInit : TUserInit;
 Function SearchUser(ID : String) : Integer; // ID -> 内部Index 　
 Procedure SaveUserInits;
 Procedure LoadUserInits;
 Procedure SaveUserInit(Index : Integer);
 Procedure LoadUserInit(Index : Integer);

 Function MakeUserID : String;

Var

   UserInits      : Array [0..UserInitsMax] of TUserInit;
   UserInitsCount : Integer;

implementation
Uses
   Define,MVCL;


Procedure LoadUserInits_;
Var
   F : File of TUserInit;
   FN : String;
Begin

   FN := ExtractFilePath(Application.ExeName)+'User.dat';

   If FileExists(FN) then
    Begin
      AssignFile(F,FN);
      Reset(F);
       BlockRead(F,UserInits,UserInitsMax,UserInitsCount);
      CloseFile(F);
    End
    Else
      UserInitsCount := 0;

End;

Procedure LoadUserInits;
Begin

  Mutex.Wait;

     LoadUserInits_;

  Mutex.Release;

End;

Procedure SaveUserInits;
Var
   F   : File of TUserInit;
   FN  : String;
   a   : String;
Begin

  Mutex.Wait;

  FN := ExtractFilePath(Application.ExeName)+'User.dat';

     a := ChangeFileExt(fn,'.BAK');
     CopyFile(Pchar(Fn),Pchar(a),false);
     AssignFile(F,FN);
     Rewrite(F);
      BlockWrite(F,UserInits,UserInitsCount);
     CloseFile(F);

  Mutex.Release;

End;

Procedure SaveUserInit(Index : Integer);
Var
   F  : File of TUserInit;
   FN : String;
Begin

  Mutex.Wait;

  FN := ExtractFilePath(Application.ExeName)+'User.dat';

     AssignFile(F,FN);
     Reset(F);
      Seek(f,Index);
      Write(F,UserInits[Index]);
     CloseFile(F);

  Mutex.Release;

End;
Procedure LoadUserInit(Index : Integer);
Var
   F  : File of TUserInit;
   FN : String;
Begin

  Mutex.Wait;

  FN := ExtractFilePath(Application.ExeName)+'User.dat';

     AssignFile(F,FN);
     Reset(F);
      Seek(f,Index);
      Read(F,UserInits[Index]);
     CloseFile(F);

  Mutex.Release;

End;


Function SearchUser(ID : String) : Integer; // ID -> 内部Index 　内部ファンクション
Var
   i : Integer;
Begin

  Mutex.Wait;

  Result := -1;

     For i:=0 to UserInitsCount-1 do
      If ID = UserInits[i].ID then
       begin
         Result := i;
         Break;
       End;

  Mutex.Release;


End;

Procedure OutUserInit(ID : String;UI : TUserInit);
Var
   n : Integer;
Begin

  Mutex.Wait;

     n := SearchUser(ID);
     if n = -1 then   // 新規登録
       Begin
        If UserInitsCount<UserInitsMax then
         Begin
           UserInits[UserInitsCount] := UI;
           Inc(UserInitsCount);
           SaveUserInits;
         End;
       End
      Else
       Begin
        UserInits[n] := UI;
        SaveUserInit(n);
       End;

  Mutex.Release;

End;

Function GetUserInit(ID : String) : TUserInit;
Var
   n : Integer;
Begin

  Mutex.Wait;

     n := SearchUser(ID);
     if n = -1 then   //　該当IDが存在しない
       Result := DefaultUserInit
     Else
      Begin
       Result := UserInits[n];
      End;

  Mutex.Release;


End;

Function GetUserList : String;
Var
   i : Integer;
Begin

  Mutex.Wait;

    Result := '';
    For i := 0 to UserInitsCount - 1 Do
        Result := Result
        + Format('%.8s %.14s',[UserInits[i].ID+'                   ',UserInits[i].Handle])
        + #13#10;

  Mutex.Release;


End;

Function DeleteUser(ID : String) : Boolean;
Var
   n,i : Integer;
Begin

  Mutex.Wait;

    LoadUserInits;

     n := SearchUser(ID);
     if n = -1 then   //　該当IDが存在しない
       Result := False
     Else
      Begin
       For i := n to UserInitsCount - 2 Do
         UserInits[i] := UserInits[i+1];
       Result := True;
       Dec(UserInitsCount);
      End;

    SaveUserInits;

  Mutex.Release;

End;

Function MakeUserID : String;
Var
   a : String;
   i,T,m : Integer;
Begin

    LoadUserInits;
    a := GeneralDefine.Apply.IdHead;
    m := -1;
     For i := 0 to UserInitsCount-1 do
      If a = Copy(UserInits[i].ID,1,Length(a)) then
       Begin
         t := StrToIntDef(Copy(UserInits[i].ID,Length(a)+1,80),-1);
         if (m < t) then
            m := t;
       End;

  if m = 41 then Inc(m);      //４２をとばす・・・

  Result := GeneralDefine.Apply.IdHead
           +Format ('%.'+IntToStr(GeneralDefine.Apply.IdNumLength)+'d',[m+1]);


End;

Function DefaultUserInit : TUserInit;
Var
  i : Integer;
Begin

   Randomize;
   Result.          ID := 'NEW'+IntToHex(Random($FFFFF),5);
   Result.    Password := IntToHex(Random($FFFFFFFF),8);
   Result.      Handle := '新規ユーザー';
   Result.       Level := 1;
   Result. AccessCount := 0;
   Result.     Address := '住所';
   Result.        Name := '氏名';
   Result.       TelNo := 'TEL';
   Result.       Hobby := '趣味';
   Result.    BirthDay := '800609';
   Result.    Comment  := '一言';
   Result.       Memo  := '';
   Result.   LastLogin := Now;
   Result.   LastRead  := Now - GeneralDefine.User.GuestLastReadDate;
   Result.LastFileNews := Now - GeneralDefine.User.GuestLastReadDate;
   Result.UseLoginReport      := True;
   Result.ReceiveTelegramBell := True;
   Result.     Email   := 'E-MAIL';

   For i := 0  To 99 Do
      Result.NewsEnableBoards[i] := True;

   Result.       Dummy := '********************************************************'
                         +'********************************************************'
                         +'********************************************************'
                         +'********************************************************';


End;

initialization

    LoadUserInits_;


end.
