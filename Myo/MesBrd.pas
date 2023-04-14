unit MesBrd;
{

(***************************************************

   MTBBS メッセージボード入出力ユニット

　　   Copyright (C) 1997.10.18 By Yoshihiro Myokan.

****************************************************)

}

interface

uses
    SysUtils,Forms,Classes,Windows;


Type

  TBoard = Record
       Enabled      : Boolean;
       Name         : String[8];
       Title        : String[32];
       ReadLevel    : Integer;
       WriteLevel   : Integer;
       SigOpID      : String[8];
       LastModified : TDateTime;
       MaxMessageNo : Integer;
       EnforcedNews : Boolean;
       Dummy        : Array [0..126] of Char;
  End;

  TMessage = Record
       No           : Integer;       // = 0 の時は無効とする
       ID           : String[8];
       Handle       : String[14];
       MesTo        : String[22];
       DateTime     : TDateTime;
       Title        : String[60];
       Text         : String;
       BoardNo      : Integer;
  End;

  TIndexFileRecord = Record
       Deleted      : Boolean;
       ID           : String[8];
       Handle       : String[14];
       Title        : String[60];
       DateTime     : TDateTime;
       FilePos      : Integer;
       Size         : Integer;
       Dummy        : Array[0..4] of Char;
  End;

  TMessageBoard = class(TObject)
     // オブジェクト　Createしてから使う^^;
     // スレッドごとに分けた方が絶対安全だからね・・・・・

       Function GetMessageList(BoardNo,StartNo : Integer;IDs : Array of String) : String;
       Function GetMessageListHTML(BoardNo,StartNo,max : Integer;IDs : Array of String;rp : integer) : String;

       Function  Read   (BoardNo,N    : Integer) : TMessage;
       Function  Readm (BoardNo,SN,EN : Integer;Var Mes : Array of TMessage) : Integer;

       Function  Write (BoardNo : Integer;Mes   : TMessage) : Boolean;   // メッセージの書き込み
       Procedure GetMidokuPoint(BoardNo : Integer;D : TDateTime;
                                Var Ep,Mp : Integer);
       Procedure Kill(BoardNo : Integer;No : Integer);

  End;


Var

   MessageBoards : Array [0..99] of TBoard;

   MessageBoardsChange : Boolean;   // これがTrueの場合MessageBoardsSaveを呼び出す

   UsingFile  : Boolean;                 //　ファイルにアクセス中

   Function  BoardNameToIndex(BoardName : String) : Integer;
        // ボードラベル－＞ボード番号 (ボード番号の文字列もＯＫ)

   Procedure MessageBoardsSave;
   Procedure MessageBoardsLoad;


implementation

Var
     FMesFilePath : String;      //　メッセージファイルを入れるディレクトリ


// メッセージの書き込み
Function TMessageBoard.Write (BoardNo : Integer;Mes   : TMessage) : Boolean;
Var

    IdxF       : File         of TIndexFileRecord;
    MesF       : File         of Char;
    FN         : String;
    WS         : String;

    Buf        : PChar;
      i        : Integer;
    IndexFileRecord : TIndexFileRecord;
Begin

   Result := False;

    FN := FMesFilePath + 'MES' + Format('%.2d',[BoardNo]);

    While UsingFile Do //ファイルが使用中ならループする
       Sleep(50);

    UsingFile := True;
  Try

     AssignFile(IdxF,FN+'.IDX');
     AssignFile(MesF,FN+'.TXT');

      If Fileexists(FN+'.IDX') then Reset(IdxF)
                        Else Rewrite(IdxF); //　新規作成
      If Fileexists(FN+'.TXT') then Reset(MesF)
                        Else Rewrite(MesF); //　新規作成

      i := FileSize(IdxF);
      While i>0 do
       Begin
         Seek(IdxF,i-1);
         BlockRead(IdxF,IndexFileRecord,1);
         if Not IndexFileRecord.Deleted then Break;
         Dec(i);
       End;

      Mes.No             := i+1;

      IndexFileRecord.FilePos := FileSize(MesF);
      Seek(MesF,IndexFileRecord.FilePos);

      WS := Format('#%.6d',[Mes.No])+#13#10+Mes.Text;
       Buf := PChar(Ws);                 //うーーんこれで良かったのか^^;;
//       Buf := AllocMem(Length(Ws)+1);
//        StrPCopy(Buf,WS);      //これじゃ２５６文字までしか駄目らしい
        BlockWrite(MesF,Buf^,Length(WS));  // PChar(Ws)は受け付けず^^;;
//       FreeMem(Buf,Length(Ws)+1);

       IndexFileRecord.Deleted      := False;
       IndexFileRecord.ID           := Mes.ID;
       IndexFileRecord.Handle       := Mes.Handle;
       IndexFileRecord.Title        := Mes.Title;
       IndexFileRecord.DateTime     := Mes.DateTime;
       IndexFileRecord.Size         := Length(Ws);
       IndexFileRecord.Dummy[0]     := #0;
       IndexFileRecord.Dummy[1]     := #0;
       IndexFileRecord.Dummy[2]     := #0;
       IndexFileRecord.Dummy[3]     := #0;
       IndexFileRecord.Dummy[4]     := #0;

      Seek(IdxF,Mes.No-1);
      BlockWrite(IdxF,IndexFileRecord,1);
      MessageBoards[BoardNo].LastModified := Now;
      MessageBoards[BoardNo].MaxMessageNo := Mes.No;
      MessageBoardsChange := True;

  Finally
    CloseFile(IdxF);
    CloseFile(MesF);
    UsingFile := False;
  End;

  Result := True;

End;

// ボードラベル－＞ボード番号 (ボード番号の文字列もＯＫ)
Function  BoardNameToIndex(BoardName : String) : Integer;
Var
   i : Integer;
Begin

   Result := StrToIntDef(BoardName,0);

   If (Result < 0) and (Result > 99) then Result := 0;

   For i := 1 to 99 do
       If MessageBoards[i].Name = UpperCase(BoardName) then
          Begin
            Result := i;
            Break;
          End;

End;


Function TMessageBoard.GetMessageList(BoardNo,StartNo : Integer;IDs : Array of String) : String;
Var
    F          : File         of TIndexFileRecord;
    Buf        : Array[0..50] of TIndexFileRecord;
    ReadBlocks : Integer;
    FN         : String;
    i,j,k      : Integer;
Begin

    Result := '';
    FN := FMesFilePath + 'MES'+Format('%.2d',[BoardNo])+'.IDX';

    If Not FileExists(FN) then
       Exit;

    While UsingFile Do //ファイルが使用中ならループする
       Sleep(50);

    UsingFile := True;

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
                  Result := Result + Format('%.4d: %.8s  %.8s %.60s',[i*50+j+1
                  ,Buf[j].ID+'        ',DateToStr(Buf[j].DateTime),Buf[j].Title])+#13#10;
                  Break;
                End;
     End;

    CloseFile(F);
    UsingFile := False;

End;



Function TMessageBoard.GetMessageListHTML(BoardNo,StartNo,Max : Integer;IDs : Array of String;rp : Integer) : String;
Var
    F          : File         of TIndexFileRecord;
    Buf        : Array[0..50] of TIndexFileRecord;
    ReadBlocks : Integer;
    FN         : String;
    i,j,k      : Integer;
    mesno      : Integer;
Begin

    Result := '<TABLE><TR><TD><B>番号</B></TD><TD><B>ＩＤ</B></TD><TD><B>日付</B></TD><TD><B>タイトル</B></TD></TR>'#13#10;
    FN := FMesFilePath + 'MES'+Format('%.2d',[BoardNo])+'.IDX';

    If Not FileExists(FN) then
       Exit;
    UsingFile := True;
    AssignFile(F,FN);
    Reset(F);

     if StartNo > FileSize(F) then
            StartNo := FileSize(F);

     if Max>50 then Max:= 50;

     i := StartNo-Max;
     if i<0 then i := 0;

      Seek(F,i);
      BlockRead(F,Buf,Max,ReadBlocks);
        For j := ReadBlocks-1 Downto 0 do
          begin
           If (Buf[j].Deleted = False) then
            For k := Low(IDs) to High(IDs) do
              If (IDs[k] = 'ALL') or (IDs[k] = Buf[j].ID) then
                Begin
                  mesno := i + j+1;
                  if mesno = rp then
                     Result := Result + Format('<TR><TD><font color="#FF0000"><B>%.4d←</B></font></TD><TD>%.8s</TD><TD>%.8s</TD><TD>%.60s</TD><TD></TR>',[mesno
                    ,Buf[j].ID+'        ',DateToStr(Buf[j].DateTime),Buf[j].Title])+#13#10
                  else
                    Result := Result + Format('<TR><TD><a href="%.4d">%.4d</a></TD><TD>%.8s</TD><TD>%.8s</TD><TD><a href="%.4d">%.60s</a></TD><TD></TR>',[mesno,mesno
                    ,Buf[j].ID+'        ',DateToStr(Buf[j].DateTime),mesno,Buf[j].Title])+#13#10;
                  Break;
                End;
          end;
      Result := Result + '</TABLE>'#13#10;
{
   Result := Result + '<hr>'#13#10
                    + '<a href=""最初のメッセージ'</a>
                    + '<a href="">'最新のメッセージ'</a>

 }

    CloseFile(F);
    UsingFile := False;

End;




Function TMessageBoard.Readm (BoardNo,SN,EN : Integer;Var Mes : Array of TMessage) : Integer;
Var

    IdxF       : File         of TIndexFileRecord;
    MesF       : File;
    FN         : String;
    Buf        : PChar;

    i          : Integer;
    ReadSize   : Integer;

    MesFilePos  : ^Integer;
    MesFileSize : ^Integer;

    IndexFileRecord : TIndexFileRecord;

Begin

  Result := 0;


    FN := FMesFilePath + 'MES'+Format('%.2d',[BoardNo])+'.IDX';

    If Not FileExists(FN) then Exit;

    While UsingFile Do //ファイルが使用中ならループする
       Sleep(50);

    UsingFile := True;

    AssignFile(IdxF,FN);
    Reset(IdxF);

    If FileSize(IdxF)<En then EN := FileSize(IdxF);

  MesFilePos  := AllocMem((En-Sn+2)* SizeOf(Integer));
  MesFileSize := AllocMem((En-Sn+2)* SizeOf(Integer));

     For i :=SN to EN Do
       Begin
        Seek(IdxF,i-1);
        BlockRead(IdxF,IndexFileRecord,1);
        if Not IndexFileRecord.Deleted Then
          Begin
            Inc(Result);
            MesFilePos^           :=  IndexFileRecord.FilePos;
            MesFileSize^          :=  IndexFileRecord.Size;
            Inc(MesFilePos);
            Inc(MesFileSize);
            Mes[Result-1].No      :=  i;
            Mes[Result-1].BoardNo :=  BoardNo;
            Mes[Result-1].ID      :=  IndexFileRecord.ID;
            Mes[Result-1].Handle  :=  IndexFileRecord.Handle;
            Mes[Result-1].Title   :=  IndexFileRecord.Title;
            Mes[Result-1].DateTime:=  IndexFileRecord.DateTime;
          End;
       End;

    CloseFile(IdxF);
    UsingFile := False;

    FN := FMesFilePath + 'MES' + Format('%.2d',[BoardNo]) + '.TXT';

    While UsingFile Do //ファイルが使用中ならループする
       Sleep(50);

    UsingFile := True;

    AssignFile(MesF,FN);
    Reset(MesF,1);

    Dec(MesFilePos,Result);
    Dec(MesFileSize,Result);

    For i:=0 to Result -1 Do
     Begin
       Seek(MesF,MesFilePos^ + 7);
       Inc(MesFilePos);
       Buf := AllocMem(MesFileSize^+1);
         BlockRead(MesF,Buf^,MesFileSize^-7,ReadSize);
         Mes[i].Text := StrPas(Buf);
       FreeMem(Buf,MesFileSize^+1);
       Inc(MesFileSize);
     End;

    CloseFile(MesF);
    UsingFile := False;

  Dec(MesFilePos,Result);
  Dec(MesFileSize,Result);
  FreeMem(MesFilePos,(En-Sn+2)* SizeOf(Integer));
  FreeMem(MesFileSize,(En-Sn+2)* SizeOf(Integer));


End;



Function TMessageBoard.Read(BoardNo,N : Integer) : TMessage;
//  Result.No ... = 0 メッセージが削除されている = -1 存在しない
Var

    IdxF       : File         of TIndexFileRecord;
    MesF       : File         of Char;
    FN         : String;
    WS         : String;
    ReadSize   : Integer; 
    Buf        : PChar;

    IndexFileRecord : TIndexFileRecord;
Begin

  Result.No := -1;

   FN := FMesFilePath + 'MES'+Format('%.2d',[BoardNo])+'.IDX';

   If (N < 1) or (Not FileExists(FN)) then Exit;

  Try

    While UsingFile Do //ファイルが使用中ならループする
       Sleep(50);
       
    UsingFile := True;

    AssignFile(IdxF,FN);
    Reset(IdxF);

    Result.No      :=  N;

      If N <= FileSize(IdxF) then
       Begin
        Seek(IdxF,N-1);
        BlockRead(IdxF,IndexFileRecord,1);
       End else
         Result.No := -1;

  Finally
    CloseFile(IdxF);
    UsingFile := False;
  End;

  If Result.No < 1 then Exit;

///
       Result.BoardNo :=  BoardNo;
       Result.ID      :=  IndexFileRecord.ID;
       Result.Handle  :=  IndexFileRecord.Handle;
       Result.Title   :=  IndexFileRecord.Title;
       Result.DateTime:=  IndexFileRecord.DateTime;
//
      If IndexFileRecord.Deleted then
         Result.No := 0;

  FN := FMesFilePath + 'MES' + Format('%.2d',[BoardNo]) + '.TXT';

    While UsingFile Do //ファイルが使用中ならループする
       Sleep(50);
    UsingFile := True;

  Try
    AssignFile(MesF,FN);
    Reset(MesF);
     Seek(MesF,IndexFileRecord.FilePos + 7);
      Buf := AllocMem(IndexFileRecord.Size+1);
       BlockRead(MesF,Buf^,IndexFileRecord.Size - 7,ReadSize);
       Result.Text := StrPas(Buf);
      FreeMem(Buf,IndexFileRecord.Size+1);

  Finally
    CloseFile(MesF);
    UsingFile := False;
  End;

End;

// メッセージの削除
Procedure TMessageBoard.Kill(BoardNo : Integer;No : Integer);
Var

    IdxF       : File         of TIndexFileRecord;
    MesF       : File         of Char;
    FN         : String;
    IndexFileRecord : TIndexFileRecord;
Begin

    FN := FMesFilePath + 'MES' + Format('%.2d',[BoardNo]);
    If Not Fileexists(FN+'.IDX') then Exit;

    While UsingFile Do //ファイルが使用中ならループする
       Sleep(50);
    UsingFile := True;

  Try
     AssignFile(IdxF,FN+'.IDX');
     Reset(IdxF);

     If ( 0<No) and (No <= FileSize(IdxF)) then
      Begin
         Seek(IdxF,No-1);
         BlockRead (IdxF,IndexFileRecord,1);
         If FileSize(IdxF) = No then
          Begin

               FN := FMesFilePath + 'MES' + Format('%.2d',[BoardNo]) + '.TXT';
               AssignFile(MesF,FN);
                 Reset(MesF);
                 Seek(MesF,IndexFileRecord.FilePos);
                 Truncate(MesF);
               CloseFile(MesF);

             Seek(IdxF,No-1);
             Truncate(IdxF);
             MessageBoards[BoardNo].MaxMessageNo := FileSize(IdxF);
             MessageBoardsChange := True;
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
    UsingFile := False;
  End;


End;


// 日時－＞　メッセージ番号
Procedure TMessageBoard.GetMidokuPoint(BoardNo : Integer;D : TDateTime
                                   ;Var Ep,Mp : Integer);
Var

    F          : File         of TIndexFileRecord;
    Buf        : Array[0..50] of TIndexFileRecord;
    ReadBlocks : Integer;
    FN         : String;
    i,j        : Integer;
Begin

    Ep := 0;
    Mp := 1;

    FN := FMesFilePath + 'MES'+Format('%.2d',[BoardNo])+'.IDX';

    If Not FileExists(FN) then
       Exit;

    While UsingFile Do //ファイルが使用中ならループする
       Sleep(50);
    UsingFile := True;

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
    UsingFile := False;

End;

Var
   BoardsFName : String;
   BoardsF     : File of TBoard;
   i,j         : Integer;

Procedure MessageBoardsSave;
Begin

       AssignFile(BoardsF,BoardsFName);
        ReWrite(BoardsF);
        BlockWrite(BoardsF,MessageBoards[1],99);
       CloseFile(BoardsF);

End;

Procedure MessageBoardsLoad;
Begin

 If FileExists(BoardsFName) then
    Begin
       AssignFile(BoardsF,BoardsFName);
       Reset(BoardsF);
       BlockRead(BoardsF,MessageBoards[1],99);
       CloseFile(BoardsF);
    End Else
     Begin
      For i := 1 to 99 do
         With MessageBoards[i] Do
           Begin
            Enabled      := False;
            Name         := 'M'+Format('%.2d',[i]);
            Title        := 'Message board'+Format('%.2d',[i]);
            ReadLevel    := 1;
            WriteLevel   := 1;
            SigOpID      := 'SYSOP';
            LastModified := Now;
            MaxMessageNo := 0;
            EnforcedNews := False;

             For j := 0 to 126 do
               Dummy[j]  := #0;
           End;
        /// デフォルトボード
           With MessageBoards[1] Do
            Begin
               Enabled      := True;
               Name         := 'INFO';
               Title        := 'Announcements';
               ReadLevel    := 0;
               WriteLevel   := 5;
               EnforcedNews := True;
             End;
           With MessageBoards[5] Do
            Begin
               Enabled      := True;
               Name         := 'INTRO';
               Title        := 'Self-introduction';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With MessageBoards[10] Do
            Begin
               Enabled      := True;
               Name         := 'DANWA';
               Title        := 'User discussions';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With MessageBoards[11] Do
            Begin
               Enabled      := True;
               Name         := 'STAFF';
               Title        := 'Staff discussions';
               ReadLevel    := 3;
               WriteLevel   := 3;
             End;
           With MessageBoards[20] Do
            Begin
               Enabled      := True;
               Name         := 'COMPU';
               Title        := 'Computers and technology';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With MessageBoards[21] Do
            Begin
               Enabled      := True;
               Name         := 'MUSIC';
               Title        := 'Music';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With MessageBoards[22] Do
            Begin
               Enabled      := True;
               Name         := 'ANIME';
               Title        := 'Animation';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With MessageBoards[99] Do
            Begin
               Enabled      := True;
               Name         := 'FREE';
               Title        := 'Off-topic';
               ReadLevel    := 0;
               WriteLevel   := 0;
             End;
     End;

 MessageBoardsChange := False;

End;

initialization

  FMesFilePath := ExtractFilePath(Application.ExeName)+'Mes\';
  CreateDir(FMesFilePath);
  BoardsFName := ExtractFilePath(Application.ExeName)+'Boards.Dat';

  MessageBoardsLoad;

Finalization


end.
