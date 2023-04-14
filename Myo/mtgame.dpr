library mtgame;

{ DLL でのメモリ管理について:
  もしこの DLL が引数や返り値として String 型を使う関数/手続きを
  エクスポートする場合、以下の USES 節とこの DLL を使うプロジェクトソースの
  USES 節の両方に、最初に現れるユニットとして ShareMem を指定しなけれ
  ばなりません。
  これは構造体やクラスに埋め込まれている場合も含め String 型を DLL
  とやり取りする場合に必ず必要となります。
  ShareMem は共用ﾒﾓﾘﾏﾈｰｼﾞｬである DELPHIMM.DLL とのインターフェース
  です。あなたの DLL と一緒に配布する必要があります。
  DELPHIMM.DLL を使うのを避けるには、PChar または ShortString 型を
  使って文字列のやり取りをおこなってください。}

uses
  SysUtils,
  Classes;

begin



unit game;


interface

uses SysUtils,Mtbbs,Main;

Type

   TMtBbsGame = class(TObject)
     private

        Function ChToID(Ch: Integer) : String;
        Function ChToHandle(Ch: Integer) : String;

        Procedure Osero;

     protected
     public

       Mtbbs : TMtbbs;
       Terminated : ^Boolean;

       Procedure Main;
       constructor Create(AOwner :TObject);


   end;

   TOseroKoma = (K_None,K_Siro,K_Kuro);
   TBan = Array[0..9,0..9] of TOseroKoma;

Var

   OseroRooms : Array[1..5] of Record
                  Users  : Array[0..1] of Integer;
                  Ban    : TBan;
                  Turn   : 0..1;
                End;

implementation

constructor TMtBbsGame.Create(AOwner :TObject);
Begin

    Mtbbs := TMtbbs(AOwner);

End;

Function TMtBbsGame.ChToID(Ch: Integer) : String;
Begin
   If ch>-1 then
     Result := MainForm.Chs[ch].Thread.User.ID;
End;
Function TMtBbsGame.ChToHandle(Ch: Integer) : String;
Begin
   If ch>-1 then
     Result := MainForm.Chs[ch].Thread.User.HandleName;
End;


Procedure TMtBbsGame.Main;
Begin

   With Mtbbs Do
    Begin
         Sendln('*** プレイルームに入りました ***');
         User.Where := 'Game';
         While Not Terminated^ do
         Begin
             Case (InputCommand(#13#10'GAME ROOM (R:対戦オセロ T:電報 W:ﾛｸﾞｲﾝ状況 ?:help 0:end)>',True)+'*')[1] of
               'T' : Telegram;
               'W' : Who;
               '?' : Sendln('<< ごめんなさい準備中です >>');
               'R' : Osero;
               '0' : Break;
             End;
       End;
      Sendln('*** プレイルームから出ました ***');
   End;

End;



Procedure TMtBbsGame.Osero;
Var
  a : String[20];

   Procedure View(RoomNo : Integer);
   Var
      x,y : Integer;
      s   : String[20];
      t   : string[2];
   Begin

     With OseroRooms[RoomNo] Do
       Begin
         If (Users[0] < 0) and (Users[1] < 0) then
           Begin
              mtbbs.Sendln('*** 使用されていません ***');
              Exit;
           End;

         mtbbs.Sendln('R 利用者ID  ハンドル  ○    利用者ID  ハンドル  ●   状態');
         mtbbs.Sendln('- -------- -------------- / -------- -------------- -------');

            If Users[0]+Users[1] < 0 then
               s := '未使用';
            If (Users[0]>-1) or (Users[1]>-1) then
               If (Users[0]>-1) and (Users[1]>-1) then
                 s := '対戦中'
               else
                 s := '待機中';

         Mtbbs.Sendln(Format('%.d %.8s %.14s / %.8s %.14s %s',
             [RoomNo,ChToId(Users[0])+'                ',ChToHandle(Users[0])+'                      '
                    ,ChToId(Users[1])+'                ',ChToHandle(Users[1])+'                      '
               ,S]));

         mtbbs.Sendln('　　０１２３４５６７８９');
         mtbbs.Sendln('  ＋－－－－－－－－－－＋');

         For y := 0 to 9 do
          Begin
            Case y of
              0 : t := '０';
              1 : t := '１';
              2 : t := '２';
              3 : t := '３';
              4 : t := '４';
              5 : t := '５';
              6 : t := '６';
              7 : t := '７';
              8 : t := '８';
              9 : t := '９';
            End;
            s := t + '｜';
            For x := 0 to 9 do
              Case OseroRooms[RoomNo].Ban[x,y] of
               K_None : s := S +Format('%.d%.d',[x,y]);
               K_Siro : s := S +'○';
               K_Kuro : s := S +'●';
              End;
            s := s+'｜' + t;
           mtbbs.Sendln(s);
          End;

         mtbbs.Sendln('  ＋－－－－－－－－－－＋');
         mtbbs.Sendln('　　０１２３４５６７８９');

         Case OseroRooms[RoomNo].Turn of
                   0 : S := '○';
                   1 : s := '●';
         End;

         mtbbs.Sendln(s+'の番です。 ........ ['+DateTimeToStr(Now)+']');

        End;
   End;


   Procedure BatteleList;
   Var
      i : Integer;
      s : String;
   Begin

     With Mtbbs do
      Begin

       Sendln(#13#10'R 利用者ID  ハンドル        利用者ID  ハンドル      状態');
       Sendln('- -------- -------------- / -------- -------------- -------');

       For i := 1 to 5 do
         With OseroRooms[i] do
          Begin

            If Users[0]+Users[1] < 0 then
               s := '未使用';
            If (Users[0]>-1) or (Users[1]>-1) then
               If (Users[0]>-1) and (Users[1]>-1) then
                 s := '対戦中'
               else
                 s := '待機中';

            Mtbbs.Sendln(Format('%.d %.8s %.14s / %.8s %.14s %s',
             [i,ChToId(Users[0])+'              ',ChToHandle(Users[0])+'                '
               ,ChToId(Users[1])+'              ',ChToHandle(Users[1])+'                '
               ,S]));
          End;

      End;


   End;

   Procedure Join(RoomNo : Integer);
   Var

      iro : 0..1;
      s   : String;

       Procedure ClearBan;
       Var
         x,y : Integer;
       Begin
         With OseroRooms[RoomNo] do
           Begin
             For x := 0 to 9 Do
                For y := 0 to 9 Do
                 Ban[x,y] := K_None;
             Ban[4,4] := K_Kuro;Ban[5,4] := K_Siro;
             Ban[4,5] := K_Siro;Ban[5,5] := K_Kuro;
           End;
       End;

   Begin

      With OseroRooms[RoomNo] do
        Begin

            If (Users[0] < 0) and (Users[1] < 0)then
              Begin
                Users[0] := Mtbbs.Fch;
                Turn     := 0;
                ClearBan;
                mtbbs.Sendln('*** 対戦者を待ちます ***');
                iro      := 0;
              End
            Else
             If (Users[0] > -1) and (Users[1] > -1) then
               Begin
                   Mtbbs.Sendln('*** この部屋は現在使用中です ***');
                   Exit;
               End
               Else
                Begin
                  If Users[0]<0 then iro := 0
                                else iro := 1;

                  Users[iro] := Mtbbs.Fch;
                  MainForm.Chs[Users[1-iro]].Thread.Telegrams.Add('<< OSERO SYSTEM >>'+#1+'あなたの相手が決まりました。');
                  MainForm.Chs[Users[Turn]].Thread.Telegrams.Add('<< OSERO SYSTEM >>'+#1+'あなたの番になりました。');
                End;


          View(RoomNo);

          While Not Terminated^ do
           Begin

                Case iro of
                   0 : s := '○';
                   1 : s := '●';
                End;

               s  := mtbbs.InputCommand(#13#10+s+'([横][縦] / R:盤表示 N:新規ゲーム T:電報 W:ﾛｸﾞｲﾝ状況 ?:help C:中止)>',True);
               If Length(s) = 2 then
                Begin
                   If StrToIntDef(s,-1)>-1 then
                      Begin
                         If Turn = iro then
                          Begin
                             Case iro of
                                0 : Ban[StrToInt(s[1]),StrToInt(s[2])] := K_Siro;
                                1 : Ban[StrToInt(s[1]),StrToInt(s[2])] := K_Kuro;
                             End;
                             If Turn = 0 then Turn := 1
                                         else Turn := 0;
                             if Users[Turn]>-1 then  MainForm.Chs[Users[Turn]].Thread.Telegrams.Add('<< OSERO SYSTEM >>'+#1+'あなたの番になりました。');
                             View(RoomNo);
                          End
                          Else
                            mtbbs.Sendln('*** あなたの番ではありません ***');
                      End
                End
                Else
                With Mtbbs do
                 Case (s+'*')[1] of
                   'R' : View(RoomNo);
                   'L' : BatteleList;
                   'N' : ClearBan;
                   'V' : Begin
                           a := InputCommand(#13#10'ルーム番号は？',true);
                           If StrToIntDef(a,-1)>0 then
                             View(StrToInt(a));
                         End;
                   'C' : Begin
                           if Users[1-iro] > -1 then MainForm.Chs[Users[1-iro]].Thread.Telegrams.Add('<< OSERO SYSTEM >>'+#1+'相手がゲームを放棄しました。');
                           Break;
                         End;
                   'W' : Who;
                   'T' : Telegram;
                   '?' : Sendln('<< ごめんなさい準備中です >>');
                  End;
           End;

           Users[iro] := -1;

        End;


   End;




Begin

   With Mtbbs Do
      Begin
         Sendln('*** オセロルームに入りました ***');
         User.Where := 'Osero';
         While Not Terminated^ do
         Begin
           a:= UpperCase(InputCommand(#13#10'OSERO ROOM (L:対戦状況 V:観戦 J:参加 T:電報 W:ﾛｸﾞｲﾝ状況 ?:help 0:end)>',True))+'*';
             Case a[1] of
               'L' : BatteleList;
               'V' : Begin
                        a := InputCommand(#13#10'ルーム番号は？',true);
                        If StrToIntDef(a,-1)>0 then
                          View(StrToInt(a));
                     End;
               '0' : Break;
               'W' : Who;
               'T' : Telegram;
               'J' : Begin
                        a := InputCommand(#13#10'ルーム番号は？',true);
                        If StrToIntDef(a,-1)>0 then
                          Join(StrToInt(a));
                     End;
               '?' : Sendln('<< ごめんなさい準備中です >>');
             End;
        End;

      Sendln('*** オセロルームから出ました ***');
      End;

End;

Var
     i : Integer;

Initialization

   For i := 1 to 5 do
     Begin
         OseroRooms[i].Users[0] := -1;
         OseroRooms[i].Users[1] := -1;
     End;

end.
