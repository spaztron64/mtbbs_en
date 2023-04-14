unit FileBrd;

(***************************************************

   MTBBS ファイルボード入出力ユニット

　　   Copyright (C) 1997.12.14 By Yoshihiro Myokan.

****************************************************)

interface
uses
    SysUtils,Forms,Classes,Windows;

Type

  TFileBoard = Record
       Enabled      : Boolean;
       Name         : String[8];
       Title        : String[32];
       ReadLevel    : Integer;
       WriteLevel   : Integer;
       BoardOpID    : String[8];
       LastModified : TDateTime;
       MaxFileNo    : Integer;
       Dummy        : Array [0..126] of Char;
  End;

  TFileInfo = Record
       Enabled      : Boolean;
       No           : Integer;       // = 0 の時は無効とする
       ID           : String[8];
       DateTime     : TDateTime;
       Title        : String[60];
       FileName     : String[12];
       FileSize     : Integer;
       Text         : String;
       BoardNo      : Integer;
       DownLoad     : Integer;
  End;

  TFileBoardIndexRecord = Record
       Deleted      : Boolean;
       Enabled      : Boolean;
       ID           : String[8];
       Title        : String[60];
       DateTime     : TDateTime;
       FileName     : String[12];
       FileSize     : Integer;
       Download     : Integer;
       Dummy        : Array[0..4] of Char;
  End;


Var

   FileBoards : Array [0..99] of TFileBoard;
   FFileBoardPath : String;      //　メッセージファイルを入れるディレクトリ

       Function  FileBoardGetFileList(BoardNo,StartNo : Integer;IDs : Array of String) : String;
       Function  FileBoardRead   (BoardNo,N    : Integer;UpDownloadCount : Boolean) : TFileInfo;
       Function  FileBoardReadm (BoardNo,SN,EN : Integer;Var FileInfo : Array of TFileInfo) : Integer;
       Function  FileBoardWrite (BoardNo : Integer;FileInfo   : TFileInfo) : Integer;   // メッセージの書き込み
       Procedure FileBoardGetMidokuPoint(BoardNo : Integer;D : TDateTime;
                                Var Ep,Mp : Integer);
       Procedure FileBoardKill(BoardNo : Integer;No : Integer);

   Function  FileBoardNameToIndex(BoardName : String) : Integer;
        // ボードラベル－＞ボード番号 (ボード番号の文字列もＯＫ)

   Procedure FileBoardsSave;
   Procedure FileBoardsLoad;

implementation
uses MVCL;


// メッセージの書き込み
Function FileBoardWrite (BoardNo : Integer;FileInfo : TFileInfo) : Integer;
Var

    IdxF       : File         of TFileBoardIndexRecord;
    MesF       : File         of Char;
    FN         : String;
    WS         : String;

    Buf        : PChar;
      i        : Integer;
    IndexFileRecord : TFileBoardIndexRecord;
Begin

   Result := -1;
   Mutex.Wait;

  Try

      Fn := FFileBoardPath + FileBoards[BoardNo].Name + Format('\FILES.IDX',[BoardNo]);
      AssignFile(IdxF,Fn);

      If Fileexists(FN) then Reset(IdxF)
                        Else Rewrite(IdxF); //　新規作成

      i := FileSize(IdxF);
      While i>0 do
       Begin
         Seek(IdxF,i-1);
         BlockRead(IdxF,IndexFileRecord,1);
         if Not IndexFileRecord.Deleted then Break;
         Dec(i);
       End;

       FileInfo.No             := i+1;
       Result := FileInfo.No;
       IndexFileRecord.Deleted      := False;
       IndexFileRecord.Enabled      := True;
       IndexFileRecord.ID           := FileInfo.ID;
       IndexFileRecord.Title        := FileInfo.Title;
       IndexFileRecord.DateTime     := FileInfo.DateTime;
       IndexFileRecord.FileSize     := FileInfo.FileSize;
       IndexFileRecord.FileName     := FileInfo.FileName;
       IndexFileRecord.DownLoad     := 0;
       IndexFileRecord.Dummy[0]     := #0;
       IndexFileRecord.Dummy[1]     := #0;
       IndexFileRecord.Dummy[2]     := #0;
       IndexFileRecord.Dummy[3]     := #0;
       IndexFileRecord.Dummy[4]     := #0;

      Seek(IdxF,FileInfo.No-1);
      BlockWrite(IdxF,IndexFileRecord,1);

      FileBoards[BoardNo].LastModified := Now;
      FileBoards[BoardNo].MaxFileNo := FileInfo.No;

      FileBoardsSave;

     FN := FFileBoardPath + FileBoards[BoardNo].Name;
     CreateDir(fn);

     Fn := Fn + '\'+Format('%.3d',[FileInfo.No])+'.'+FileInfo.FileName;

     If FileInfo.Text<>'' then
      Begin
         AssignFile(MesF,FN+'.TXT');
         Rewrite(MesF); //　新規作成

         WS := FileInfo.Text;
         Buf := PChar(Ws);                 //うーーんこれで良かったのか^^;;
         BlockWrite(MesF,Buf^,Length(WS));  // PChar(Ws)は受け付けず^^;;
         CloseFile(MesF);
      End
      Else
       Begin
         Fn := Fn +'.TXT';
         DeleteFile(Pchar(Fn));
       End;

  Finally
    CloseFile(IdxF);
    Mutex.Release;
  End;


End;

// ボードラベル－＞ボード番号 (ボード番号の文字列もＯＫ)
Function  FileBoardNameToIndex(BoardName : String) : Integer;
Var
   i : Integer;
Begin

  Mutex.Wait;

   Result := StrToIntDef(BoardName,0);

   If (Result < 0) and (Result > 99) then Result := 0;

   For i := 1 to 99 do
       If FileBoards[i].Name = UpperCase(BoardName) then
          Begin
            Result := i;
            Break;
          End;

  Mutex.Release;

End;


Function FileBoardGetFileList(BoardNo,StartNo : Integer;IDs : Array of String) : String;
Var
    F          : File         of TFileBoardIndexRecord;
    Buf        : Array[0..50] of TFileBoardIndexRecord;
    ReadBlocks : Integer;
    FN         : String;
    i,j,k      : Integer;
    Fsize      : String;
Begin

    Mutex.Wait;

    Result := '';
    Fn := FFileBoardPath + FileBoards[BoardNo].Name + '\FILES.IDX';
    If Not FileExists(FN) then
      Begin
         Mutex.Release;
         Exit;
      End;

    AssignFile(F,FN);
    Reset(F);

  if StartNo <= FileSize(F) then
    For i := (StartNo div 50) To ( FileSize(F) div 50 ) Do
     Begin
       Seek(F,i*50);
       BlockRead(F,Buf,50,ReadBlocks);
        For j := 0 to ReadBlocks-1 do
           If (Buf[j].Deleted = False) and (StartNo <= i*50+j+1) then
            For k := Low(IDs) to High(IDs) do
              If (IDs[k] = 'ALL') or (IDs[k] = Buf[j].ID) then
                Begin
                  If Buf[j].FileSize < 10000 then FSize := Format('%.4d',[Buf[j].FileSize])
                    else
                      If Buf[j].FileSize < 1000*1000 then FSize := Format('%.3dK',[Buf[j].FileSize Div 1000])
                        else
                          FSize := Format('%.3dM',[Buf[j].FileSize Div (1000*1000)]);
                  Result := Result + Format('%.3d:%.12s %.4s %.3d %.8s %.8s %.35s'
                  ,[i*50+j+1,Buf[j].FileName+'             ',FSize,Buf[j].Download,DateToStr(Buf[j].DateTime)+'             ',Buf[j].ID+'        ',Buf[j].Title])+#13#10;
                  Break;
                End;
     End;

    CloseFile(F);
    Mutex.Release;

End;

Function FileBoardReadm (BoardNo,SN,EN : Integer;Var FileInfo : Array of TFileInfo) : Integer;
Var

    IdxF       : File         of TFileBoardIndexRecord;
    MesF       : File         of Char;
    FN         : String;
    Buf        : PChar;
    i          : Integer;
    ReadSize   : Integer;
    IndexFileRecord : TFileBoardIndexRecord;

Begin

 Mutex.Wait;

    Result := 0;

    Fn := FFileBoardPath + FileBoards[BoardNo].Name + '\FILES.IDX';
    If Not FileExists(FN) then
      Begin
         Mutex.Release;
         Exit;
      End;

    AssignFile(IdxF,FN);
    Reset(IdxF);

    If FileSize(IdxF)<En then EN := FileSize(IdxF);

     For i :=SN to EN Do
       Begin
        Seek(IdxF,i-1);
        BlockRead(IdxF,IndexFileRecord,1);
        if Not IndexFileRecord.Deleted Then
          Begin
            Inc(Result);
            FileInfo[Result-1].No      :=  i;
            FileInfo[Result-1].BoardNo :=  BoardNo;
            FileInfo[Result-1].ID      :=  IndexFileRecord.ID;
            FileInfo[Result-1].Title   :=  IndexFileRecord.Title;
            FileInfo[Result-1].DateTime:=  IndexFileRecord.DateTime;
            FileInfo[Result-1].Download:=  IndexFileRecord.Download;
            FileInfo[Result-1].FileName:=  IndexFileRecord.FileName;
            FileInfo[Result-1].FileSize:=  IndexFileRecord.FileSize;
          End;
       End;

    CloseFile(IdxF);

    For i:=0 to Result -1 Do
     Begin
       Fn := FFileboardPath + FileBoards[BoardNo].Name + '\'+Format('%.3d',[FileInfo[i].No])+'.'+FileInfo[i].FileName+'.TXT';
       If FileExists(Fn) then
        Begin
         AssignFile(MesF,FN);
         Reset(MesF);
         Buf := AllocMem(FileSize(MesF)+1);
           BlockRead(MesF,Buf^,FileSize(MesF),ReadSize);
           FileInfo[i].Text := StrPas(Buf);
         FreeMem(Buf,FileSize(MesF)+1);
         CloseFile(MesF);
        End;
     End;

    Mutex.Release;

End;



Function FileBoardRead(BoardNo,N : Integer;UpDownloadCount : Boolean) : TFileInfo;
//  Result.No ... = 0 メッセージが削除されている = -1 存在しない
Var

    IdxF       : File         of TFileBoardIndexRecord;
    MesF       : File         of Char;
    FN         : String;
    WS         : String;
    ReadSize   : Integer;
    Buf        : PChar;

    IndexFileRecord : TFileBoardIndexRecord;
Begin

 Mutex.Wait;

   Result.No := -1;

   Fn := FFileBoardPath + FileBoards[BoardNo].Name + '\FILES.IDX';
   If (N < 1) or (Not FileExists(FN)) then
      Begin
         Mutex.Release;
         Exit;
      End;

  Try

    AssignFile(IdxF,FN);
    Reset(IdxF);

    Result.No      :=  N;

      If N <= FileSize(IdxF) then
       Begin
        Seek(IdxF,N-1);
        BlockRead(IdxF,IndexFileRecord,1);
        If UpDownloadCount then
         Begin
           Inc(IndexFileRecord.Download);
           Seek(IdxF,N-1);
           BlockWrite(IdxF,IndexFileRecord,1);
         End;

       End else
             Result.No := -1;

  Finally
    CloseFile(IdxF);
  End;

  If Result.No<1 then
      Begin
         Mutex.Release;
         Exit;
      End;

            Result.No       := N;
            Result.BoardNo  := BoardNo;
            Result.ID       := IndexFileRecord.ID;
            Result.Title    := IndexFileRecord.Title;
            Result.DateTime := IndexFileRecord.DateTime;
            Result.Download := IndexFileRecord.Download;
            Result.FileName := IndexFileRecord.FileName;
            Result.FileSize := IndexFileRecord.FileSize;
//
      If IndexFileRecord.Deleted then
         Result.No := 0;

   If Result.No < 1 then
      Begin
         Mutex.Release;
         Exit;
      End;

   Fn := FFileBoardPath + FileBoards[BoardNo].Name + '\'+Format('%.3d',[Result.No])+'.'+Result.FileName+'.TXT';

   Result.Text := '';
   If Fileexists(fn) Then
    Begin

      Try
        AssignFile(MesF,FN);
        Reset(MesF);
        Buf := AllocMem(FileSize(MesF)+1);
         BlockRead(MesF,Buf^,FileSize(MesF),ReadSize);
         Result.Text := StrPas(Buf);
        FreeMem(Buf,FileSize(MesF)+1);

      Finally
        CloseFile(MesF);
      End;
    End;

   Mutex.Release;


End;

// メッセージの削除
Procedure FileBoardKill(BoardNo : Integer;No : Integer);
Var

    IdxF       : File         of TFileBoardIndexRecord;
    FN         : String;
    IndexFileRecord : TFileBoardIndexRecord;
Begin

   Mutex.Wait;

    Fn := FFileBoardPath + FileBoards[BoardNo].Name + '\FILES.IDX';
    If Not Fileexists(FN) then
      Begin
         Mutex.Release;
         Exit;
      End;


  Try
     AssignFile(IdxF,FN);
     Reset(IdxF);

     If ( 0<No) and (No <= FileSize(IdxF)) then
      Begin
         Seek(IdxF,No-1);
         BlockRead (IdxF,IndexFileRecord,1);

            Fn := FFileBoardPath + FileBoards[BoardNo].Name + '\'+Format('%.3d',[No])+'.'+IndexFileRecord.FileName;
            DeleteFile(Pchar(Fn));
            Fn := Fn + '.TXT';
            DeleteFile(Pchar(Fn));

         If FileSize(IdxF) = No then
          Begin
            Seek(IdxF,No-1);
            Truncate(IdxF);
            FileBoards[BoardNo].MaxFileNo := FileSize(IdxF);
            FileBoardsSave;
          End
         Else
          Begin
            IndexFileRecord.Deleted := True;         //削除フラグをONにする
            Seek(IdxF,No-1);                           //つまり実際には削除されない^^;
            BlockWrite(IdxF,IndexFileRecord,1);
          End;

      End;

  Finally
    CloseFile(IdxF);
  End;

  Mutex.Release;

End;


// 日時－＞　メッセージ番号
Procedure FileBoardGetMidokuPoint(BoardNo : Integer;D : TDateTime
                                   ;Var Ep,Mp : Integer);
Var

    F          : File         of TFileBoardIndexRecord;
    Buf        : Array[0..50] of TFileBoardIndexRecord;
    ReadBlocks : Integer;
    FN         : String;
    i,j        : Integer;
Begin

  Mutex.Wait;

    Ep := 0;
    Mp := 1;

    Fn := FFileBoardPath + FileBoards[BoardNo].Name + '\FILES.IDX';
    If Not FileExists(FN) then
      Begin
         Mutex.Release;
         Exit;
      End;

    AssignFile(F,FN);
    Reset(F);

    Ep := FileSize(F);
    Mp := Ep + 1;

    For i := ( FileSize(F) div 50 ) DownTo 0 do
        //  処理の高速化のため逆向きに50Blockずつ
     Begin
       Seek(F,i*50);
       BlockRead(F,Buf,50,ReadBlocks);
        For j := ReadBlocks-1 DownTo 0 do
         Begin
           If (Buf[j].DateTime < D) and (not Buf[j].Deleted) then
            Begin
               ReadBlocks := -1;
               Break;
            End;
           If  Buf[j].Deleted = False Then
               Mp := i*50+j + 1;
         End;
        If ReadBlocks<0 then Break;
     End;

    CloseFile(F);
   Mutex.Release;

End;

Var
   BoardsFName : String;
   BoardsF     : File of TFileBoard;
   i,j         : Integer;

Procedure FileBoardsSave;
Begin

   Mutex.Wait;

       AssignFile(BoardsF,BoardsFName);
        ReWrite(BoardsF);
        BlockWrite(BoardsF,FileBoards[1],99);
       CloseFile(BoardsF);

   Mutex.Release;

End;

Procedure FileBoardsLoad;
Begin

 If FileExists(BoardsFName) then
    Begin
       AssignFile(BoardsF,BoardsFName);
       Reset(BoardsF);
       BlockRead(BoardsF,FileBoards[1],99);
       CloseFile(BoardsF);
    End Else
     Begin
      For i := 1 to 99 do
         With FileBoards[i] Do
           Begin
            Enabled      := False;
            Name         := 'FB'+Format('%.2d',[i]);
            Title        := 'File board'+Format('%.2d',[i]);
            ReadLevel    := 1;
            WriteLevel   := 1;
            BoardOpID    := 'SYSOP';
            LastModified := Now;
            MaxFileNo    := 0;
             For j := 0 to 126 do
               Dummy[j]  := #0;
           End;
        /// デフォルトボード
           With FileBoards[1] Do
            Begin
               Enabled      := True;
               Name         := 'MTBBS';
               Title        := 'MTBBS Related Files';
               ReadLevel    := 0;
               WriteLevel   := 0;
             End;
           With FileBoards[5] Do
            Begin
               Enabled      := True;
               Name         := 'COM';
               Title        := 'Comms software';
               ReadLevel    := 0;
               WriteLevel   := 0;
             End;
           With FileBoards[10] Do
            Begin
               Enabled      := True;
               Name         := 'WIN';
               Title        := 'Windows sofware';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With FileBoards[11] Do
            Begin
               Enabled      := True;
               Name         := 'WINGAME';
               Title        := 'Windows games';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With FileBoards[12] Do
            Begin
               Enabled      := True;
               Name         := 'DOS';
               Title        := 'DOS software';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With FileBoards[13] Do
            Begin
               Enabled      := True;
               Name         := 'SOFT';
               Title        := 'MAC/UNIX/88/MSX software';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;

           With FileBoards[20] Do
            Begin
               Enabled      := True;
               Name         := 'TEXT';
               Title        := 'Text files';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With FileBoards[21] Do
            Begin
               Enabled      := True;
               Name         := 'MIDI';
               Title        := 'MIDIs';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With FileBoards[22] Do
            Begin
               Enabled      := True;
               Name         := 'CG';
               Title        := 'CGs and other art';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With FileBoards[23] Do
            Begin
               Enabled      := True;
               Name         := 'DATA';
               Title        := 'Misc. files';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;

           With FileBoards[99] Do
            Begin
               Enabled      := True;
               Name         := 'GOMI';
               Title        := 'Rubbish';
               ReadLevel    := 0;
               WriteLevel   := 0;
             End;
     End;


       For i := 1 to 99 do
         With FileBoards[i] do
           If Enabled then
            Begin
               CreateDir(FFileBoardPath + Name);
               Application.ProcessMessages;
            End;


       Createdir(FFileBoardPath+'upload');
End;

initialization

  FFileBoardPath := ExtractFilePath(Application.ExeName)+'File\';
  CreateDir(FFileBoardPath);
  BoardsFName := ExtractFilePath(Application.ExeName)+'FBoards.Dat';

  FileBoardsLoad;

Finalization


end.
