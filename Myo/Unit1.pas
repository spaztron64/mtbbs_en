unit FileBrd;

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

  TFileMessage = Record
       No           : Integer;       // = 0 �̎��͖����Ƃ���
       ID           : String[8];
       DateTime     : TDateTime;
       Title        : String[60];
       FileName     : String[12];
       Text         : String;
       BoardNo      : Integer;
  End;

  TFileBoardIndexRecord = Record
       Deleted      : Boolean;
       Enabled      : Boolean;
       ID           : String[8];
       Title        : String[60];
       DateTime     : TDateTime;
       FilePos      : Integer;
       Size         : Integer;
       Dummy        : Array[0..4] of Char;
  End;

  TFileBoard = class(TObject)
     // �I�u�W�F�N�g�@Create���Ă���g��^^;
     // �X���b�h���Ƃɕ�����������Έ��S������ˁE�E�E�E�E

       Function GetFileList(BoardNo,StartNo : Integer;IDs : Array of String) : String;

       Function  Read   (BoardNo,N    : Integer) : TMessage;
       Function  Readm (BoardNo,SN,EN : Integer;Var Mes : Array of TMessage) : Integer;

       Function  Write (BoardNo : Integer;Mes   : TMessage) : Boolean;   // ���b�Z�[�W�̏�������
       Procedure GetMidokuPoint(BoardNo : Integer;D : TDateTime;
                                Var Ep,Mp : Integer);
       Procedure Kill(BoardNo : Integer;No : Integer);

  End;


Var

   MessageBoards : Array [0..99] of TBoard;
   MessageBoardsChange : Boolean;   // ���ꂪTrue�̏ꍇMessageBoardsSave���Ăяo��

   UsingFile  : Boolean;                 //�@�t�@�C���ɃA�N�Z�X��

   Function  BoardNameToIndex(BoardName : String) : Integer;
        // �{�[�h���x���|���{�[�h�ԍ� (�{�[�h�ԍ��̕�������n�j)

   Procedure MessageBoardsSave;


implementation

Var
     FMesFilePath : String;      //�@���b�Z�[�W�t�@�C��������f�B���N�g��


// ���b�Z�[�W�̏�������
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

    While UsingFile Do //�t�@�C�����g�p���Ȃ烋�[�v����
       Sleep(50);

    UsingFile := True;
  Try

     AssignFile(IdxF,FN+'.IDX');
     AssignFile(MesF,FN+'.TXT');

      If Fileexists(FN+'.IDX') then Reset(IdxF)
                        Else Rewrite(IdxF); //�@�V�K�쐬
      If Fileexists(FN+'.TXT') then Reset(MesF)
                        Else Rewrite(MesF); //�@�V�K�쐬

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
       Buf := PChar(Ws);                 //���[�[�񂱂�ŗǂ������̂�^^;;
//       Buf := AllocMem(Length(Ws)+1);
//        StrPCopy(Buf,WS);      //���ꂶ��Q�T�U�����܂ł����ʖڂ炵��
        BlockWrite(MesF,Buf^,Length(WS));  // PChar(Ws)�͎󂯕t����^^;;
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

// �{�[�h���x���|���{�[�h�ԍ� (�{�[�h�ԍ��̕�������n�j)
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

    While UsingFile Do //�t�@�C�����g�p���Ȃ烋�[�v����
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

    While UsingFile Do //�t�@�C�����g�p���Ȃ烋�[�v����
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

    While UsingFile Do //�t�@�C�����g�p���Ȃ烋�[�v����
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
//  Result.No ... = 0 ���b�Z�[�W���폜����Ă��� = -1 ���݂��Ȃ�
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

    While UsingFile Do //�t�@�C�����g�p���Ȃ烋�[�v����
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

    While UsingFile Do //�t�@�C�����g�p���Ȃ烋�[�v����
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

// ���b�Z�[�W�̍폜
Procedure TMessageBoard.Kill(BoardNo : Integer;No : Integer);
Var

    IdxF       : File         of TIndexFileRecord;
    MesF       : File         of Char;
    FN         : String;
    IndexFileRecord : TIndexFileRecord;
Begin

    FN := FMesFilePath + 'MES' + Format('%.2d',[BoardNo]);
    If Not Fileexists(FN+'.IDX') then Exit;

    While UsingFile Do //�t�@�C�����g�p���Ȃ烋�[�v����
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

          End
         Else
          Begin
            IndexFileRecord.Deleted := True;         //�폜�t���O��ON�ɂ���
            Seek(IdxF,No-1);                           //�܂���ۂɂ͍폜����Ȃ�^^;
            BlockWrite(IdxF,IndexFileRecord,1);
          End;

      End;

  Finally
    CloseFile(IdxF);
    UsingFile := False;
  End;


End;


// �����|���@���b�Z�[�W�ԍ�
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

    While UsingFile Do //�t�@�C�����g�p���Ȃ烋�[�v����
       Sleep(50);
    UsingFile := True;

    AssignFile(F,FN);
    Reset(F);

    Ep := FileSize(F);
    Mp := Ep + 1;

    For i := ( FileSize(F) div 50 ) DownTo 0 do
        //  �����̍������̂��ߋt������50Block����
     Begin
       Seek(F,i*50);
       BlockRead(F,Buf,50,ReadBlocks);
        For j := ReadBlocks-1 DownTo 0 do
         Begin
           If Buf[j].DateTime < D then
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


initialization

 FMesFilePath := ExtractFilePath(Application.ExeName)+'Mes\';
 CreateDir(FMesFilePath);


 BoardsFName := ExtractFilePath(Application.ExeName)+'Boards.Dat';

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
            Title        := '���b�Z�[�W�{�[�h'+Format('%.2d',[i]);
            ReadLevel    := 1;
            WriteLevel   := 1;
            SigOpID      := 'SYSOP';
            LastModified := Now;
            MaxMessageNo := 0;
            EnforcedNews := False;

             For j := 0 to 126 do
               Dummy[j]  := #0;
           End;
        /// �f�t�H���g�{�[�h
           With MessageBoards[1] Do
            Begin
               Enabled      := True;
               Name         := 'INFO';
               Title        := '�V�X�e������̂��m�点';
               ReadLevel    := 0;
               WriteLevel   := 5;
               EnforcedNews := True;
             End;
           With MessageBoards[5] Do
            Begin
               Enabled      := True;
               Name         := 'INTRO';
               Title        := '���ȏЉ�';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With MessageBoards[10] Do
            Begin
               Enabled      := True;
               Name         := 'DANWA';
               Title        := '���[�U�[�k�b��';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With MessageBoards[11] Do
            Begin
               Enabled      := True;
               Name         := 'STAFF';
               Title        := '�X�^�b�t�k�b��';
               ReadLevel    := 3;
               WriteLevel   := 3;
             End;
           With MessageBoards[20] Do
            Begin
               Enabled      := True;
               Name         := 'COMPU';
               Title        := '�R���s���[�^�[�̘b';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With MessageBoards[21] Do
            Begin
               Enabled      := True;
               Name         := 'MUSIC';
               Title        := '���y�֌W�̘b';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With MessageBoards[22] Do
            Begin
               Enabled      := True;
               Name         := 'ANIME';
               Title        := '�A�j���֌W�̘b';
               ReadLevel    := 1;
               WriteLevel   := 1;
             End;
           With MessageBoards[99] Do
            Begin
               Enabled      := True;
               Name         := 'FREE';
               Title        := '�t���[�{�[�h';
               ReadLevel    := 0;
               WriteLevel   := 0;
             End;
     End;

 MessageBoardsChange := False;

Finalization


end.
