        program IdxConv107

        uses
                Form, Classes, SysUtils

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

        begin

                Writeln('-----------------------------------------------------------');
                Writeln('MyoHostSystem (MTBBS) �C���f�b�N�X�R���o�[�g���[�e�B���e�B');
                Writeln(' Copyright (C) 1997.11.18 By MYO');
                Writeln('-----------------------------------------------------------');
                Writeln('');
                Writeln('�{�\�t�g�E�F�A�� MTBBS Ver 1.06 �ȑO�̃C���f�b�N�X�f�[�^�� Ver 1.07�̂��̂ɕϊ����܂��B�f�[�^���j�󂳂�鋰�ꂪ����܂��̂ŁA���炩����"\MES"�̃f�B���N�g���̃o�b�N�A�b�v���������Ŏ��s���Ă��������B');
                Writeln('');
                Writeln('�J�n���Ă�낵���ł���? ���~����ꍇ��[CTRL]+[C]�������Ă��������B');
                ReadLn;

             For i:=1 to 99 Do
             Begin
                 Fn := Format('MES\MES%.2s',[i]);
                 If FileExists(Fn+'.IDX') then
                   Begin
                      Writeln('�R���o�[�g��.....'+Fn+'.IDX')
                      AssignFile(FOld,Fn+'.IDX');
                      Reset(FOld);
                      AssignFile(Fnew,Fn+'.TMP');
                      ReWrite(Fnew);
                        While Not Eof(Fold) do
                         Begin
                           OldIndex := Read(Fold);
                            NewIndex.Deleted  := OldIndex.Deleted;
                            NewIndex.ID       := Copy(OldIndex.MesFrom,1,Pos(' ',OldIndex.MesFrom)-1);
                            NewIndex.Handle      Copy(OldIndex.MesFrom,Pos(' ',OldIndex.MesFrom)+1,99);
                            NewIndex.Title    := OldIndex.Title;;
                            NewIndex.DateTime := OldIndex.DateTime;
                            NewIndex.FilePos  := OldIndex.FilePos;
                            NewIndex.Size     := OldIndex.Size;
                            NewIndex.Dummy    := OldIndex.Dummy;
                           Write(Fnew,NewIndex);
                         End;
                      CloseFile(FOld);
                      DeleteFile(Fn+'.IDX');
                      Rename(FNew,Fn+'.IDX');
                      CloseFile(FNew);
                   End;
             End;

            Writeln('*** �R���o�[�g���I�����܂��� ****')
            Writeln('����) �{�v���O�����͍ēx���s���Ȃ��ł��������B�C���f�b�N�X���j�󂳂�܂��B')
            Writeln('���^�[���L�[�������Ă�������. ');
            ReadLn;

        end.
