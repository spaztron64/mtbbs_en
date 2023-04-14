        program IdxConv107;

        uses
                 SysUtils;

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
                  i : Integer;

        begin

                Writeln('------------------------------------------------------------');
                Writeln(' MyoHostSystem (MTBBS) インデックスコンバートユーティリティ');
                Writeln('  Copyright (C) 1997.11.18 By MYO');
                Writeln('------------------------------------------------------------');
                Writeln('');
                Writeln('　本プログラムは MTBBS Ver 1.06以前のメッセージボード・インデックスデータを Ver 1.07以降のものに変換します。');
                Writeln('　データが破壊される恐れがありますので、あらかじめディレクトリ"\MES"のバックアップを取った上で実行してください。');
                Writeln('');
                Writeln('　開始してよろしいですか? 開始する場合は[ENTER] 中止する場合は[CTRL]+[C]を押してください。');
                ReadLn;

                If Not FileExists('Boards.Dat') then
                 Begin
                    Writeln('*** メッセージボードが見つかりません ***');
                    Writeln('本プログラムはMyoHost.exeと同じディレクトリ内で実行してください。');
                    Writeln('-- [ENTER]キーを押してください --');
                    ReadLn;
                    Exit;
                 End;

             For i:=1 to 99 Do
             Begin
                 Fn := Format('MES\MES%.2d',[i]);
                 If FileExists(Fn+'.IDX') then
                   Begin
                      Writeln('コンバート中.....'+Fn+'.IDX');
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

            Writeln('　*** コンバートが終了しました ****');
            Writeln('注) 本プログラムは再度実行しないでください。インデックスが破壊されます。');
            Writeln('--　[ENTER]キーを押してください --');
            ReadLn;

        end.
