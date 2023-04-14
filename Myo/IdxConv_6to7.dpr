        program IdxConv107

        uses
                Form, Classes, SysUtils

        Type
          TOldIndexFileRecord = Record
       		Deleted      : Boolean;
       		MesFrom      : String[22]; //★
       		Title        : String[60];
       		DateTime     : TDateTime;
       		FilePos      : Integer;
       		Size         : Integer;
      		Dummy        : Array[0..4] of Char;
         End;
         TIndexFileRecord = Record
                Deleted      : Boolean;
                ID           : String[8];  //★
                Handle       : String[14]; //★
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
                Writeln('MyoHostSystem (MTBBS) インデックスコンバートユーティリティ');
                Writeln(' Copyright (C) 1997.11.18 By MYO');
                Writeln('-----------------------------------------------------------');
                Writeln('');
                Writeln('本ソフトウェアは MTBBS Ver 1.06 以前のインデックスデータを Ver 1.07のものに変換します。データが破壊される恐れがありますので、あらかじめ"\MES"のディレクトリのバックアップを取った上で実行してください。');
                Writeln('');
                Writeln('開始してよろしいですか? 中止する場合は[CTRL]+[C]を押してください。');
                ReadLn;

             For i:=1 to 99 Do
             Begin
                 Fn := Format('MES\MES%.2s',[i]);
                 If FileExists(Fn+'.IDX') then
                   Begin
                      Writeln('コンバート中.....'+Fn+'.IDX')
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

            Writeln('*** コンバートが終了しました ****')
            Writeln('注意) 本プログラムは再度実行しないでください。インデックスが破壊されます。')
            Writeln('リターンキーを押してください. ');
            ReadLn;

        end.
