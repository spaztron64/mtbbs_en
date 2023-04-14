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
         Sendln('*** You have entered the play room ***');
         User.Where := 'Game';
         While Not Terminated^ do
         Begin
             Case (InputCommand(#13#10'GAME ROOM (R:Reversi T:ìdïÒ W:Show users ?:help 0:end)>',True)+'*')[1] of
               'T' : Telegram;
               'W' : Who;
               '?' : Sendln('<< Ç≤ÇﬂÇÒÇ»Ç≥Ç¢èÄîıíÜÇ≈Ç∑ >>');
               'R' : Osero;
               '0' : Break;
             End;
       End;
      Sendln('*** You have left the playroom ***');
   End;

End;



Procedure TMtBbsGame.Osero;
Var
  a : String;

   Procedure View(RoomNo : Integer);
   Var
      x,y : Integer;
      s,t : String;
   Begin

     With OseroRooms[RoomNo] Do
       Begin
         If (Users[0] < 0) and (Users[1] < 0) then
           Begin
              mtbbs.Sendln('*** Not in use ***');
              Exit;
           End;

         mtbbs.Sendln('R User ID     Handle   Åõ      User ID    Handle      Status');
         mtbbs.Sendln('- -------- -------------- / -------- -------------- -------');

            If Users[0]+Users[1] < 0 then
               s := 'Empty';
            If (Users[0]>-1) or (Users[1]>-1) then
               If (Users[0]>-1) and (Users[1]>-1) then
                 s := 'Playing'
               else
                 s := 'Waiting';

         Mtbbs.Sendln(Format('%.d %.8s %.14s / %.8s %.14s %s',
             [RoomNo,ChToId(Users[0])+'                ',ChToHandle(Users[0])+'                      '
                    ,ChToId(Users[1])+'                ',ChToHandle(Users[1])+'                      '
               ,S]));

         mtbbs.Sendln('Å@Å@ÇOÇPÇQÇRÇSÇTÇUÇVÇWÇX');
         mtbbs.Sendln('  Å{Å|Å|Å|Å|Å|Å|Å|Å|Å|Å|Å{');

         For y := 0 to 9 do
          Begin
            Case y of
              0 : t := 'ÇO';
              1 : t := 'ÇP';
              2 : t := 'ÇQ';
              3 : t := 'ÇR';
              4 : t := 'ÇS';
              5 : t := 'ÇT';
              6 : t := 'ÇU';
              7 : t := 'ÇV';
              8 : t := 'ÇW';
              9 : t := 'ÇX';
            End;
            s := t + 'Åb';
            For x := 0 to 9 do
              Case OseroRooms[RoomNo].Ban[x,y] of
               K_None : s := S +Format('%.d%.d',[x,y]);
               K_Siro : s := S +'Åõ';
               K_Kuro : s := S +'Åú';
              End;
            s := s+'Åb' + t;
           mtbbs.Sendln(s);
          End;

         mtbbs.Sendln('  Å{Å|Å|Å|Å|Å|Å|Å|Å|Å|Å|Å{');
         mtbbs.Sendln('Å@Å@ÇOÇPÇQÇRÇSÇTÇUÇVÇWÇX');

         Case OseroRooms[RoomNo].Turn of
                   0 : S := 'Åõ';
                   1 : s := 'Åú';
         End;

         mtbbs.Sendln(s+'is taking the turn ........ ['+DateTimeToStr(Now)+']');

        End;
   End;


   Procedure BatteleList;
   Var
      i : Integer;
      s : String;
   Begin

     With Mtbbs do
      Begin

       Sendln(#13#10'R User ID     Handle   Åõ      User ID    Handle      Status');
       Sendln('- -------- -------------- / -------- -------------- -------');

       For i := 1 to 5 do
         With OseroRooms[i] do
          Begin

            If Users[0]+Users[1] < 0 then
               s := 'Empty';
            If (Users[0]>-1) or (Users[1]>-1) then
               If (Users[0]>-1) and (Users[1]>-1) then
                 s := 'Playing'
               else
                 s := 'Waiting';

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
                mtbbs.Sendln('*** Waiting for players ***');
                iro      := 0;
              End
            Else
             If (Users[0] > -1) and (Users[1] > -1) then
               Begin
                   Mtbbs.Sendln('*** This room is occupied. ***');
                   Exit;
               End
               Else
                Begin
                  If Users[0]<0 then iro := 0
                                else iro := 1;

                  Users[iro] := Mtbbs.Fch;
                  MainForm.Chs[Users[1-iro]].Thread.Telegrams.Add('<< OSERO SYSTEM >>'+#1+'Your partner has been selected.');
                  MainForm.Chs[Users[Turn]].Thread.Telegrams.Add('<< OSERO SYSTEM >>'+#1+'Your turn.');
                End;


          View(RoomNo);

          While Not Terminated^ do
           Begin

                Case iro of
                   0 : s := 'Åõ';
                   1 : s := 'Åú';
                End;

               s  := mtbbs.InputCommand(#13#10+s+'([Hori][Vert] / R:Draw board N:New game T:PM W:Show users ?:help C:Abort)>',True);
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
                             if Users[Turn]>-1 then  MainForm.Chs[Users[Turn]].Thread.Telegrams.Add('<< OSERO SYSTEM >>'+#1+'Your turn.');
                             View(RoomNo);
                          End
                          Else
                            mtbbs.Sendln('*** Not your turn! ***');
                      End
                End
                Else
                With Mtbbs do
                 Case (s+'*')[1] of
                   'R' : View(RoomNo);
                   'L' : BatteleList;
                   'N' : ClearBan;
                   'V' : Begin
                           a := InputCommand(#13#10'Select room by number.',true);
                           If StrToIntDef(a,-1)>0 then
                             View(StrToInt(a));
                         End;
                   'C' : Begin
                           if Users[1-iro] > -1 then MainForm.Chs[Users[1-iro]].Thread.Telegrams.Add('<< OSERO SYSTEM >>'+#1+'Opponent has left the game.');
                           Break;
                         End;
                   'W' : Who;
                   'T' : Telegram;
                   '?' : Sendln('<< Ç≤ÇﬂÇÒÇ»Ç≥Ç¢èÄîıíÜÇ≈Ç∑ >>');
                  End;
           End;

           Users[iro] := -1;

        End;


   End;




Begin

   With Mtbbs Do
      Begin
         Sendln('*** Entered the Reversi room ***');
         User.Where := 'Osero';
         While Not Terminated^ do
         Begin
           a:= UpperCase(InputCommand(#13#10'OSERO ROOM (L:Match status V:Spectate J:Join T:PM W:Show users ?:help 0:end)>',True))+'*';
             Case a[1] of
               'L' : BatteleList;
               'V' : Begin
                        a := InputCommand(#13#10'Room number is?',true);
                        If StrToIntDef(a,-1)>0 then
                          View(StrToInt(a));
                     End;
               '0' : Break;
               'W' : Who;
               'T' : Telegram;
               'J' : Begin
                        a := InputCommand(#13#10'Room number is?',true);
                        If StrToIntDef(a,-1)>0 then
                          Join(StrToInt(a));
                     End;
               '?' : Sendln('<< Getting ready... >>');
             End;
        End;

      Sendln('*** You left the Reversi room. ***');
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
