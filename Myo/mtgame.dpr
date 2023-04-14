library mtgame;

{ DLL �ł̃������Ǘ��ɂ���:
  �������� DLL ��������Ԃ�l�Ƃ��� String �^���g���֐�/�葱����
  �G�N�X�|�[�g����ꍇ�A�ȉ��� USES �߂Ƃ��� DLL ���g���v���W�F�N�g�\�[�X��
  USES �߂̗����ɁA�ŏ��Ɍ���郆�j�b�g�Ƃ��� ShareMem ���w�肵�Ȃ���
  �΂Ȃ�܂���B
  ����͍\���̂�N���X�ɖ��ߍ��܂�Ă���ꍇ���܂� String �^�� DLL
  �Ƃ���肷��ꍇ�ɕK���K�v�ƂȂ�܂��B
  ShareMem �͋��p����Ȱ�ެ�ł��� DELPHIMM.DLL �Ƃ̃C���^�[�t�F�[�X
  �ł��B���Ȃ��� DLL �ƈꏏ�ɔz�z����K�v������܂��B
  DELPHIMM.DLL ���g���̂������ɂ́APChar �܂��� ShortString �^��
  �g���ĕ�����̂����������Ȃ��Ă��������B}

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
         Sendln('*** �v���C���[���ɓ���܂��� ***');
         User.Where := 'Game';
         While Not Terminated^ do
         Begin
             Case (InputCommand(#13#10'GAME ROOM (R:�ΐ�I�Z�� T:�d�� W:۸޲ݏ� ?:help 0:end)>',True)+'*')[1] of
               'T' : Telegram;
               'W' : Who;
               '?' : Sendln('<< ���߂�Ȃ����������ł� >>');
               'R' : Osero;
               '0' : Break;
             End;
       End;
      Sendln('*** �v���C���[������o�܂��� ***');
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
              mtbbs.Sendln('*** �g�p����Ă��܂��� ***');
              Exit;
           End;

         mtbbs.Sendln('R ���p��ID  �n���h��  ��    ���p��ID  �n���h��  ��   ���');
         mtbbs.Sendln('- -------- -------------- / -------- -------------- -------');

            If Users[0]+Users[1] < 0 then
               s := '���g�p';
            If (Users[0]>-1) or (Users[1]>-1) then
               If (Users[0]>-1) and (Users[1]>-1) then
                 s := '�ΐ풆'
               else
                 s := '�ҋ@��';

         Mtbbs.Sendln(Format('%.d %.8s %.14s / %.8s %.14s %s',
             [RoomNo,ChToId(Users[0])+'                ',ChToHandle(Users[0])+'                      '
                    ,ChToId(Users[1])+'                ',ChToHandle(Users[1])+'                      '
               ,S]));

         mtbbs.Sendln('�@�@�O�P�Q�R�S�T�U�V�W�X');
         mtbbs.Sendln('  �{�|�|�|�|�|�|�|�|�|�|�{');

         For y := 0 to 9 do
          Begin
            Case y of
              0 : t := '�O';
              1 : t := '�P';
              2 : t := '�Q';
              3 : t := '�R';
              4 : t := '�S';
              5 : t := '�T';
              6 : t := '�U';
              7 : t := '�V';
              8 : t := '�W';
              9 : t := '�X';
            End;
            s := t + '�b';
            For x := 0 to 9 do
              Case OseroRooms[RoomNo].Ban[x,y] of
               K_None : s := S +Format('%.d%.d',[x,y]);
               K_Siro : s := S +'��';
               K_Kuro : s := S +'��';
              End;
            s := s+'�b' + t;
           mtbbs.Sendln(s);
          End;

         mtbbs.Sendln('  �{�|�|�|�|�|�|�|�|�|�|�{');
         mtbbs.Sendln('�@�@�O�P�Q�R�S�T�U�V�W�X');

         Case OseroRooms[RoomNo].Turn of
                   0 : S := '��';
                   1 : s := '��';
         End;

         mtbbs.Sendln(s+'�̔Ԃł��B ........ ['+DateTimeToStr(Now)+']');

        End;
   End;


   Procedure BatteleList;
   Var
      i : Integer;
      s : String;
   Begin

     With Mtbbs do
      Begin

       Sendln(#13#10'R ���p��ID  �n���h��        ���p��ID  �n���h��      ���');
       Sendln('- -------- -------------- / -------- -------------- -------');

       For i := 1 to 5 do
         With OseroRooms[i] do
          Begin

            If Users[0]+Users[1] < 0 then
               s := '���g�p';
            If (Users[0]>-1) or (Users[1]>-1) then
               If (Users[0]>-1) and (Users[1]>-1) then
                 s := '�ΐ풆'
               else
                 s := '�ҋ@��';

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
                mtbbs.Sendln('*** �ΐ�҂�҂��܂� ***');
                iro      := 0;
              End
            Else
             If (Users[0] > -1) and (Users[1] > -1) then
               Begin
                   Mtbbs.Sendln('*** ���̕����͌��ݎg�p���ł� ***');
                   Exit;
               End
               Else
                Begin
                  If Users[0]<0 then iro := 0
                                else iro := 1;

                  Users[iro] := Mtbbs.Fch;
                  MainForm.Chs[Users[1-iro]].Thread.Telegrams.Add('<< OSERO SYSTEM >>'+#1+'���Ȃ��̑��肪���܂�܂����B');
                  MainForm.Chs[Users[Turn]].Thread.Telegrams.Add('<< OSERO SYSTEM >>'+#1+'���Ȃ��̔ԂɂȂ�܂����B');
                End;


          View(RoomNo);

          While Not Terminated^ do
           Begin

                Case iro of
                   0 : s := '��';
                   1 : s := '��';
                End;

               s  := mtbbs.InputCommand(#13#10+s+'([��][�c] / R:�Օ\�� N:�V�K�Q�[�� T:�d�� W:۸޲ݏ� ?:help C:���~)>',True);
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
                             if Users[Turn]>-1 then  MainForm.Chs[Users[Turn]].Thread.Telegrams.Add('<< OSERO SYSTEM >>'+#1+'���Ȃ��̔ԂɂȂ�܂����B');
                             View(RoomNo);
                          End
                          Else
                            mtbbs.Sendln('*** ���Ȃ��̔Ԃł͂���܂��� ***');
                      End
                End
                Else
                With Mtbbs do
                 Case (s+'*')[1] of
                   'R' : View(RoomNo);
                   'L' : BatteleList;
                   'N' : ClearBan;
                   'V' : Begin
                           a := InputCommand(#13#10'���[���ԍ��́H',true);
                           If StrToIntDef(a,-1)>0 then
                             View(StrToInt(a));
                         End;
                   'C' : Begin
                           if Users[1-iro] > -1 then MainForm.Chs[Users[1-iro]].Thread.Telegrams.Add('<< OSERO SYSTEM >>'+#1+'���肪�Q�[����������܂����B');
                           Break;
                         End;
                   'W' : Who;
                   'T' : Telegram;
                   '?' : Sendln('<< ���߂�Ȃ����������ł� >>');
                  End;
           End;

           Users[iro] := -1;

        End;


   End;




Begin

   With Mtbbs Do
      Begin
         Sendln('*** �I�Z�����[���ɓ���܂��� ***');
         User.Where := 'Osero';
         While Not Terminated^ do
         Begin
           a:= UpperCase(InputCommand(#13#10'OSERO ROOM (L:�ΐ�� V:�ϐ� J:�Q�� T:�d�� W:۸޲ݏ� ?:help 0:end)>',True))+'*';
             Case a[1] of
               'L' : BatteleList;
               'V' : Begin
                        a := InputCommand(#13#10'���[���ԍ��́H',true);
                        If StrToIntDef(a,-1)>0 then
                          View(StrToInt(a));
                     End;
               '0' : Break;
               'W' : Who;
               'T' : Telegram;
               'J' : Begin
                        a := InputCommand(#13#10'���[���ԍ��́H',true);
                        If StrToIntDef(a,-1)>0 then
                          Join(StrToInt(a));
                     End;
               '?' : Sendln('<< ���߂�Ȃ����������ł� >>');
             End;
        End;

      Sendln('*** �I�Z�����[������o�܂��� ***');
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
