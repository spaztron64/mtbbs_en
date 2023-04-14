        program IdxConv107;

        uses
                 SysUtils;

        Type
          TOldIndexFileRecord = Record
       		Deleted      : Boolean;
       		MesFrom      : String[22]; //��
       		Title        : String[60];
       		DateTime     : TDateTime;
       		FilePos      : Integer;
       		Size         : Integer;
      		Dummy        : Array[0..4] of Char;
         End;
         TIndexFileRecord = Record
                Deleted      : Boolean;
                ID           : String[8];  //��
                Handle       : String[14]; //��
                Title        : String[60];
                DateTime     : TDateTime;
                FilePos      : Integer;
                Size         : Integer;
                Dummy        : Array[0..4] of Char;
         End;

        Var
             Fn : String;
             Fold  : File of TOldIndexFileRecord;
             Fnew  : File of    TIndexFileRecord;
           OldIndex : TOldIndexFileRecord;
           NewIndex : TIndexFileRecord;
                  i : Integer;

        begin

                Writeln('------------------------------------------------------------');
                Writeln(' MyoHostSystem (MTBBS) �C���f�b�N�X�R���o�[�g���[�e�B���e�B');
                Writeln('  Copyright (C) 1997.11.18 By MYO');
                Writeln('------------------------------------------------------------');
                Writeln('');
                Writeln('�@�{�v���O������ MTBBS Ver 1.06�ȑO�̃��b�Z�[�W�{�[�h�E�C���f�b�N�X�f�[�^�� Ver 1.07�ȍ~�̂��̂ɕϊ����܂��B');
                Writeln('�@�f�[�^���j�󂳂�鋰�ꂪ����܂��̂ŁA���炩���߃f�B���N�g��"\MES"�̃o�b�N�A�b�v���������Ŏ��s���Ă��������B');
                Writeln('');
                Writeln('�@�J�n���Ă�낵���ł���? �J�n����ꍇ��[ENTER] ���~����ꍇ��[CTRL]+[C]�������Ă��������B');
                ReadLn;

                If Not FileExists('Boards.Dat') then
                 Begin
                    Writeln('*** ���b�Z�[�W�{�[�h��������܂��� ***');
                    Writeln('�{�v���O������MyoHost.exe�Ɠ����f�B���N�g�����Ŏ��s���Ă��������B');
                    Writeln('-- [ENTER]�L�[�������Ă������� --');
                    ReadLn;
                    Exit;
                 End;

             For i:=1 to 99 Do
             Begin
                 Fn := Format('MES\MES%.2d',[i]);
                 If FileExists(Fn+'.IDX') then
                   Begin
                      Writeln('�R���o�[�g��.....'+Fn+'.IDX');
                      AssignFile(FOld,Fn+'.IDX');
                      Reset(FOld);
                      AssignFile(Fnew,Fn+'.TMP');
                      ReWrite(Fnew);
                        While Not Eof(Fold) do
                         Begin
                           BlockRead(Fold,OldIndex,1);
                            NewIndex.Deleted  := OldIndex.Deleted;
                            NewIndex.ID       := Copy(OldIndex.MesFrom,1,Pos(' ',OldIndex.MesFrom)-1);
                            NewIndex.Handle   := Copy(OldIndex.MesFrom,Pos(' ',OldIndex.MesFrom)+1,99);
                            NewIndex.Title    := OldIndex.Title;;
                            NewIndex.DateTime := OldIndex.DateTime;
                            NewIndex.FilePos  := OldIndex.FilePos;
                            NewIndex.Size     := OldIndex.Size;
                            NewIndex.Dummy[0] := #0;
                            NewIndex.Dummy[1] := #0;
                            NewIndex.Dummy[2] := #0;
                            NewIndex.Dummy[3] := #0;
                            NewIndex.Dummy[4] := #0;
                           BlockWrite(Fnew,NewIndex,1);
                         End;
                      CloseFile(FOld);
                      CloseFile(FNew);
                      DeleteFile(Fn+'.IDX');
                      RenameFile(Fn+'.TMP',Fn+'.IDX');
                   End;
             End;

            Writeln('�@*** �R���o�[�g���I�����܂��� ****');
            Writeln('��) �{�v���O�����͍ēx���s���Ȃ��ł��������B�C���f�b�N�X���j�󂳂�܂��B');
            Writeln('--�@[ENTER]�L�[�������Ă������� --');
            ReadLn;

        end.
