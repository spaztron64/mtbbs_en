unit MailSys;
{

********************************************

   MTBBS メールシステムユニット

　　   Copyright (C) 1997.12.31 By MYO

********************************************


}
Interface

uses
    SysUtils,Forms,Classes,Windows,Define;

Const
   MailMax = 9999;

Type

  TMailStatus = (MS_Deleted,MS_NoRead,MS_Read);

  TMail = Record
       Status       : TMailStatus;
       ToID         : String[8];
       FromID       : String[8];
       MailTo       : String[40];
       MailFrom     : String[40]; // Handle or E-Mail Address
       Title        : String[60];
       DateTime     : TDateTime;
       IsBmail      : Boolean;
       Dummy        : Array [0..63] of Char;
  End;

  TMailSystem = Class(TObject)

     private

     protected


     public

      LastErr  : String;

      Function  Write(Mail : TMail;Text : String):Integer;
      Function  Search(StartIndex : Integer;ID : String;IncludeRecvMail,IncludeSendMail : Boolean) : Integer;
      Function  Sort(MailsIndex : Pointer;Max : Integer;ID : String;IncludeRecvMail,IncludeSendMail : Boolean) : Integer;
      Function  ReadHead(Index : Integer;ChangeRead : Boolean):TMail;
      Function  ReadText(Index : Integer):String;
      Procedure Kill(Index : Integer);

  end;


Var

   Mails : Array [0..MailMax] of
     Record
       ToID         : String[8];
       FromID       : String[8];
       Status       : TMailStatus;
       DateTime     : TDateTime;
     End;

   MailsMaxIndex : Integer;

   Mail_UsingFile      : Boolean;                 //　ファイルにアクセス中

   FMailFilePath : String;



implementation


Function  TMailSystem.Search(StartIndex : Integer;ID : String;IncludeRecvMail,IncludeSendMail : Boolean):Integer;
Var
  i : Integer;
Begin

  result := -1;

  For i := StartIndex to MailsMaxIndex do
    If ((IncludeRecvMail and (Mails[i].ToID=ID)) or (IncludeSendMail and (Mails[i].FromID=ID)))
     and (Mails[i].Status <> MS_Deleted) then
      Begin
         Result := i;
         exit;
      End;

End;


Function  TMailSystem.ReadHead(Index : Integer;ChangeRead : Boolean):TMail;
Var
   F : File of Tmail;
   M : TMail;
Begin


   Result.Status := Mails[index].Status;

   If  Mails[index].Status = MS_Deleted then Exit;


   While Mail_UsingFile Do
       Sleep(50);

   Mail_UsingFile := True;

     Try
       AssignFile(f,FMailFilePath+'Mails.dat');
       Reset(f);
        Seek(f,index);
        BlockRead(f,M,1);
        Result := M;
        If ChangeRead then
          Begin
             Seek(f,index);
             M.Status := MS_Read;
             BlockWrite(f,M,1);
          End;
       CloseFile(f);
     Except
       LastErr := 'File write error!';
     End;

   Mail_UsingFile := False;


End;

Function  TMailSystem.ReadText(Index : Integer):String;
Var
   f  : File of Char;
   Fn : String;
   Buf : PChar;
Begin


   While Mail_UsingFile Do
       Sleep(50);

   Mail_UsingFile := True;

     Try
       Fn := FMailFilePath+Format('%.2d',[index div 100]);
       Fn := Fn +  Format('\%.2d.TXT',[index mod 100]);
       AssignFile(f,Fn);
       Reset(f);

       Buf := AllocMem(FileSize(f)+1);
         BlockRead(F,Buf^,FileSize(f));
         Result := StrPas(Buf);
       FreeMem(Buf,FileSize(f)+1);
       CloseFile(f);

     Except
       LastErr := 'File read error.';
     End;

   Mail_UsingFile := False;


End;


Function TMailSystem.Sort(MailsIndex : Pointer;Max : Integer;ID : String;IncludeRecvMail : Boolean;IncludeSendMail : Boolean) : Integer;
Type
  TMailsIndex = Array[0..99] of Integer;

Var

   MailsDateTime : Array[0..99] of TDateTime;
   i,j,n         : Integer;
Begin

   i := -1;

  Result := 0;

  While true Do
   Begin

      i := Search(i+1,ID,IncludeRecvMail,IncludeSendMail);

      If (i = -1) or (Result >= max) then Break;

      n := Result;
      For j := 0 to Result-1 Do
         if MailsDateTime[j] > Mails[i].DateTime then
          Begin
            n := j;
            break;
          End;

      For j := Result - 1 Downto n Do
       Begin
         TMailsIndex(MailsIndex^)[j+1] := TMailsIndex(MailsIndex^)[j];
         MailsDateTime[j+1] := MailsDateTime[j];
       End;

       TMailsIndex(MailsIndex^)[n] := i;
      MailsDateTime[n] := Mails[i].DateTime;
      Inc(Result);

   End;

End;


Function  TMailSystem.Write(Mail : TMail;Text : String):Integer;
Var
  i,j : integer;
  F : File of Char;
  Buf : PChar;
  M : TMail;
  Fn : String;
  MailF : File Of TMail;
Begin

  M := Mail;

  Result := -1;

  j := 0;

  For i := 0 to MailMax do
    If (Mails[i].ToID=M.ToID) and (Mails[i].Status <> MS_Deleted) then
      Inc(j);

  If GeneralDefine.Mail.BoxSize <= j then
   Begin
      LastErr := 'The recipient mailbox is full.';
      Exit;
   End;

  For i := 0 to MailMax do
   If Mails[i].Status = MS_Deleted then
    Begin

       If MailsMaxIndex < i then MailsMaxIndex := i;

       M.Status              := MS_NoRead;
       M.DateTime            := Now;
       Mails[i].Status       := MS_NoRead;
       Mails[i].ToID         := M.ToID;
       Mails[i].FromID       := M.FromID;


   While Mail_UsingFile Do
       Sleep(50);

   Mail_UsingFile := True;

     Try
       AssignFile(MailF,FMailFilePath+'Mails.dat');
       Reset(MailF);
        Seek(MailF,i);
        BlockWrite(MailF,M,1);
       CloseFile(MailF);
       Fn := FMailFilePath+Format('%.2d',[i div 100]);
       CreateDir(Fn);
       Fn := Fn +  Format('\%.2d.TXT',[i mod 100]);
       AssignFile(f,Fn);
       ReWrite(F);
        Buf := Pchar(Text);
        blockWrite(F,Buf^,Length(Text));
       CloseFile(F);
     Except
       LastErr := 'File write error.';
     End;

    Mail_UsingFile := False;

       Result  := i;
       LastErr := ' err ';
      Exit;
    End;

   LastErr := 'Host system is out of space for mail.';

End;

Procedure TMailSystem.Kill(Index : Integer);
Var
   F    : File of Tmail;
   Mail : TMail;
   a    : String;
Begin


   If  Mails[index].Status = MS_Deleted then Exit;

   While Mail_UsingFile Do
       Sleep(50);

   Mail_UsingFile := True;

   Mails[Index].Status := MS_Deleted;
   Mail        .Status := MS_Deleted;

     Try
       AssignFile(f,FMailFilePath+'Mails.dat');
       Reset(f);
        Seek(f,index);
        BlockWrite(f,Mail,1);
       CloseFile(f);
       a :=  FMailFilePath+Format('%.2d',[Index div 100])
           + Format('\%.2d.TXT',[Index mod 100]);
       DeleteFile(Pchar(a));
       a := ChangeFileExt(a,'.BIN');
       DeleteFile(Pchar(a));
     Except
       LastErr := 'Failed to delete mail.';
     End;

   Mail_UsingFile := False;


End;



Var
   F   : File of TMail;
   TF  : TextFile;
   M   : TMail;
   i   : integer;
initialization

   For i := 0 to MailMax do
    Begin
      Mails[i].ToID   := '';
      Mails[i].FromID := '';
      Mails[i].Status := MS_Deleted;
    End;

   FMailFilePath := ExtractFilePath(Application.ExeName)+'Mail\';
   CreateDir(FMailFilePath);
   AssignFile(f,FMailFilePath+'Mails.dat');

   If FileExists(FMailFilePath+'Mails.dat') then
    Begin
      Reset(F);
      For i := 0 to FileSize(f)-1 do
       Begin
         BlockRead(F,M,1);
         Mails[i].ToID     := M.ToID;
         Mails[i].FromID   := M.FromID;
         Mails[i].Status   := M.Status;
         Mails[i].DateTime := M.DateTime;
       End;
       MailsMaxIndex := FileSize(f)-1;
    End
   else
    Begin

       M.Status       := MS_NoRead;
       M.ToID         := 'SYSOP';
       M.IsBmail      := False;
       M.MailTo       := 'シスオペ様';
       M.FromID       := 'INETMAIL'; // Handle or E-Mail Address
       M.MailFrom     := 'myo@tky2.3web.ne.jp'; // Handle or E-Mail Address
       M.Title        := 'ＭＴＢＢＳへようこそ！！';
       M.DateTime     := Now;

       Mails[0].Status   := M.Status;
       Mails[0].ToID     := M.ToID;
       Mails[0].FromID   := M.FromID;
       Mails[0].DateTime := Now;

       ReWrite(F);
        BlockWrite(F,M,1);
       CloseFile(F);

       CreateDir(FMailFilePath+'00');
       AssignFile(Tf,FMailFilePath+'00\00.TXT');
       ReWrite(TF);
        Writeln(TF,'');
        Writeln(TF,'Thank you for installing MTBBS.');
        Writeln(TF,'');
       CloseFile(TF);
       MailsMaxIndex := 0;

    End;

   Mail_UsingFile := False;

end.
