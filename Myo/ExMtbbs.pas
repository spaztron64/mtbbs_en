unit ExMtbbs;
{

********************************************

   MTBBS 拡張ファンクションユニット

　　   Copyright (C) 1997.12.14 By MYO

********************************************


}

interface

uses SysUtils,Define;

Type

     TGoodByeMessage = Record
           DateTime  :  TDateTime;
           Handle    :  String[14];
           Mes       :  String[46];
     End;
     TFreePost = Record
           Handle    :  String[14];
           Mes       :  String[64];
     End;

       Procedure WriteGoodbyeMessage(Handle,Mes : String);
       Function ReadGoodbyeMessage : String;
       Procedure WriteFreePost(Handle,Mes : String);
       Function ReadFreePost : String;


implementation

uses
   Main,MtBBS,MVCL;



Procedure WriteGoodbyeMessage(Handle,Mes : string);
Var
    F : File of TGoodbyeMessage;
    GM        : TGoodbyeMessage;
Begin

  Mutex.Wait;

    Gm.DateTime := Now;
    Gm.Handle   := Handle;
    Gm.Mes      := Mes;

    AssignFile(F,AppPath+'Goodbye.MES');

    If Fileexists(AppPath+'Goodbye.MES') then Reset(F)
                                         Else Rewrite(F); //　新規作成

      Seek(F,FileSize(F));
      BlockWrite(F,gm,1);

    CloseFile(f);

   Mutex.Release;

End;

Function ReadGoodbyeMessage : String;
Var
    F  : File of TGoodbyeMessage;
    GM :         TGoodbyeMessage;
    i  : Integer;
Begin

  Mutex.Wait;

    Result := '';
    AssignFile(F,AppPath+'Goodbye.MES');

    If Fileexists(AppPath+'Goodbye.MES') then
     Begin
        Reset(F);
        i := FileSize(F)-GeneralDefine.Other.GoodbyeMessage_MaxSize;
        If i < 0 then i := 0;
        Seek(F,i);

        While Not Eof(F) do
         Begin
           BlockRead(F,Gm,1);
           Result := Result + Format('%.8s %.8s %.14s:%.46s',[
                DateToStr (Gm.DateTime)+'               '
                ,TimeToStr (Gm.DateTime)+'               '
                ,Gm.Handle              +'               '
                ,Gm.Mes])+#13#10;
         End;

         CloseFile(f);
     End;

  Mutex.Release;

End;


Procedure WriteFreePost(Handle,Mes : string);
Var
    F : File of TFreePost;
    FM        : TFreePost;
Begin

  Mutex.Wait;

    Fm.Handle   := Handle;
    Fm.Mes      := Mes;

    AssignFile(F,AppPath+'FreePost.MES');

    If Fileexists(AppPath+'FreePost.MES') then Reset(F)
                                          Else Rewrite(F); //　新規作成

      Seek(F,FileSize(F));
      BlockWrite(F,Fm,1);

    CloseFile(f);

  Mutex.Release;

End;

Function ReadFreePost : String;
Var
    F  : File of TFreePost;
    Fm :         TFreePost;
    i  : Integer;
Begin

  Mutex.Wait;

    Result := '';
    AssignFile(F,AppPath+'FreePost.MES');

    If Fileexists(AppPath+'FreePost.MES') then
     Begin
       Reset(F);
       i := FileSize(F)-GeneralDefine.Other.FreePost_MaxSize;
       If i < 0 then i := 0;
       Seek(F,i);

       While Not Eof(F) do
        Begin
          BlockRead(F,Fm,1);
          Result := Result + Format('%.14s:%.64s',[
               Fm.Handle              +'               '
              ,Fm.Mes])+#13#10;
        End;

       CloseFile(f);
     End;

  Mutex.Release;

End;


end.
