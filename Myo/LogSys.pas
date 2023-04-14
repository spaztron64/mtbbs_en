unit LogSys;
{

********************************************

   MTBBS ログ管理ユニット

　　   Copyright (C) 1997.11.5 By MYO

********************************************

}

interface

uses
  SysUtils,Forms;

 Var
   AccessCount : Integer;

 Type

     TAccessLog = Record
         Ch        :  Integer;
         Way       :  String[40];
         Id        :  String[8];
         Handle    :  String[14];
         InTime    :  TDateTime;
         OutTime   :  TDateTime;
     End;

  Procedure AddAccessLog(Log : TAccessLog);
  Function GetAccessLog(Var Log : Array of TAccessLog;i : Integer) : Integer;

implementation
uses
  Main,MVCL;

Procedure AddAccessLog(Log : TAccessLog);
Var
    F : File of TAccessLog;
Begin

  Mutex.Wait;

    AssignFile(F,AppPath+'LOG.DAT');

    If Fileexists(AppPath+'LOG.DAT') then Reset(F)
                                     Else Rewrite(F); //　新規作成

      Seek(F,FileSize(F));
      BlockWrite(F,Log,1);

    AccessCount := FileSize(F);

    CloseFile(f);

  Mutex.Release;

End;

Function GetAccessLog(Var Log : Array of TAccessLog;i : Integer) : Integer;
Var
    F : File of TAccessLog;
    j : Integer;
Begin

  Mutex.Wait;

    Result := 0;
    AssignFile(F,AppPath+'LOG.DAT');

    If Fileexists(AppPath+'LOG.DAT') then
     Begin
       Reset(F);
       j := FileSize(F)-i;
       If j < 0 then j := 0;
       Seek(F,j);
       BlockRead(F,Log,i,Result);
       CloseFile(f);
     End;

   Mutex.Release;

End;

Var
    F : File of TAccessLog;

initialization

  If FileExists(ExtractFilePath(Application.ExeName)+'LOG.DAT') then
   Begin
     AssignFile(F,ExtractFilePath(Application.ExeName)+'LOG.DAT');
     Reset(f);
     AccessCount := FileSize(F);
     CloseFile(f);
   End
   Else
      AccessCount := 0;


end.
