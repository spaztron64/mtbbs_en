unit wwwmtbbs;

interface
uses mtbbs,mesbrd,main,Classes,SysUtils,Define,plugsetup,UserSys,LogSys,windows,Forms;

   Procedure WWWGET(socket : integer;IP : string;URI : string);
   Procedure WWWPOST(socket : integer;IP : string;URI : string;buf : string);
   Procedure WWWReceive(Sender: TObject;Socket: Integer);
   Procedure FreeWWWCh(WWWch : Integer);

implementation


Const
 errMes = MyoHostVer+'<p><font color="#FF0000" size="7"><em>MTBBS</em></font><font'
         +'size="7"><em> </em></font><font color="#0080FF" size="7"><em>WWWサーバー</em></font></p>'
         +'<h1>無効なURLです</h1>';
 accesserrMes = MyoHostVer+'<p><font color="#FF0000" size="7"><em>MTBBS</em></font><font'
         +'size="7"><em> </em></font><font color="#0080FF" size="7"><em>WWWサーバー</em></font></p>'
         +'<h1>アクセス権がありません</h1>';

 mtwwwMes = MyoHostVer+'<p><font color="#FF0000" size="7"><em>MTBBS</em></font><font'
         +'size="7"><em> </em></font><font color="#0080FF" size="7"><em>WWWサーバー</em></font></p>'
         ;

LoginMes = '<BR>'
          +'<center><font color="#FF0000" size="7"><em>MTBBS</em></font>'#13#10
          +'<font color="#0080FF" size="7"><em>WWW</em></font></center>'#13#10
          +'<center>'#13#10
          +' <form ACTION="LOGIN/" method="POST">'#13#10
          +'    <TABLE>'#13#10
          +'            <TR><TD>ユーザーID :</TD><TD><input type="text" size="20" name="USERID"></TD></TR>'#13#10
          +'            <TR><TD>パスワード :</TD><TD><input type="password" size="20" name="PASSWORD"></TD></TR>'#13#10
          +'            <TR><TD>ハンドルネーム :</TD><TD><input type="text" size="20" name="HANDLENAME" ><BR>'#13#10
          +'              <font color="#FF0000" size="2">ゲストログインの場合</font></TD></TR>'#13#10
          +'    </TABLE>      <input type="submit" name="LOGIN" value="ログイン">'#13#10
          +' </form>'#13#10
          +'</center><BR>'#13#10
          +'<center>'#13#10
          +'      <a href="MES/"><font size="5">メッセージボードを覗く</font></a><BR>'#13#10
          +'      <a href="VER/">バージョン情報</a>'#13#10
          +'      <a href="SYSINFO/">システム情報</a><BR>'#13#10
          +'      <a href="APPLY/"><font size="5">入会手続き</font></a>'#13#10
          +'</center>'#13#10;

Var

   User  : TUser;
   MyCh  : Integer;
   SendHTML : Boolean;
   sendStr : string;
   TopURI : String;

procedure WWWSend(Socket : Integer;S : String);
Begin
            MainForm.WWWServer.Write(Socket,
                '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'#13#10
               +'<HTML>'#13#10
               +' <HEAD>'#13#10
               +'  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=Shift_JIS">'#13#10
               +' </HEAD>'#13#10
               +'<body bgcolor="#D2EAFF">'#13#10
               +S+#13#10
               +'</body>'#13#10
               +'</HTML>');
End;


Procedure FreeWWWCh(WWWch : Integer);
Begin

          WWWUsers[WWWch].Enabled := False;

End;


procedure Sendln(S : String);
Begin
 SendStr := SendStr + s+#13#10;
End;

procedure Puts(S : String);
Begin
 SendStr := SendStr + s;
End;

Function CheckUseLevel(kinou : TKinou):Boolean;   //注)(Result = True).. 使用禁止
Begin

    If GeneralDefine.CanUseLevels[Kinou][User.Level] then
       Result := False
    Else Begin
       SendLn('<H1>使用権がありません</H1>');
{       If  (GeneralDefine.Apply.AutoRegist)
        and GeneralDefine.CanUseLevels[Kinou][GeneralDefine.Apply.StartLevel]
        and (User.Level = 0)
       then
         SendLn('<a href='+'>トップ</a>');
 }
       Result := True;
    End;

End;

Const
   textStart = '<TABLE BORDER><tr><td colspan="2" bgcolor="#FFFFFF"><PRE>';
   textend = '</PRE></td></tr></TABLE>';


Function MakeText(S : String) : String;
Var
  i : Integer;

    Function Conv(c : Char) : String;
    Var
      Hour,Dummy : Word;
    Begin
        Case c of
          'H' :  Result := User.HandleName;
          'I' :  Result := User.ID;
          'T' :  Result := TimeToStr(Now);
          'D' :  Result := DateToStr(Now);
          'W' :  Case DayOfWeek(Now) of
                  1: Result :='日';
                  2: Result :='月';
                  3: Result :='火';
                  4: Result :='水';
                  5: Result :='木';
                  6: Result :='金';
                  7: Result :='土';
                 End;
          'C' :  Result := TimeToStr(Now - User.LoginTime);
          'N' :  Result := IntToStr(AccessCount+GeneralDefine.Other.AccessCountReset);
          'A' :  Begin
                   DecodeTime(Now, Hour, dummy,dummy,dummy);
                   Case Hour of
                      0..4,18..23    : Result :='こんばんは';
                      5..10          : Result :='おはようございます';
                      11..17         : Result :='こんにちは';
                   End;
                 End;
          'V' :  Result := MTBBSVERSION;
          'L' :  Result := IntToStr(User.Level);
          'X' :  Result := OkotobaStrs[Random(OkotobaStrs.Count)];
           Else
            Result := '%';
        End;

     End;

begin

  Result := '';

  i := 1;
  While i <= Length(S) Do
   Begin

    If (S[i]='%') and  (i+1 < Length(S)) then
     Begin
       Inc(i);
       Result := Result + Conv(S[i]);
     End
     Else
       Result := Result + S[i];

     Inc(i);

   End;


End;

Procedure PlayLoginSound;
Begin
 If GeneralDefine.Sound.PlayLogin then
 Try
  With MainForm Do
   Begin
     MediaPlayer1.FileName := GeneralDefine.Sound.LoginFileName;
     MediaPlayer1.Open;
     MediaPlayer1.Play;
   End;
 Except
   MainForm.MtbbsStsAdd('サウンドファイルを再生できません');
 End;

End;

Procedure PlayLogoutSound;
Begin

 If GeneralDefine.Sound.PlayLogout then
 Try
  With MainForm Do
   Begin
     MediaPlayer1.FileName := GeneralDefine.Sound.LogoutFileName;
     MediaPlayer1.Open;
     MediaPlayer1.Play;
   End;
 Except
   MainForm.MtbbsStsAdd('サウンドファイルを再生できません');
 End;
End;

Procedure ReceiveTelegram;
Var
  j:integer;
Begin

 if mych<0 then exit;
        If WWWUsers[MyCh].Telegrams.Count >0 then
          With WWWUsers[MyCh] do
           Begin
             For j := 0 to WWWUsers[MyCh].Telegrams.Count -1 Do
             Begin
               Sendln(textstart);
               Sendln('============================================================');
               SendLn('電報です。発信人は '
               +Copy(Telegrams[j],1,Pos(#1,Telegrams[j])-1)
               +' さんです。');
               SendLn(Copy(Telegrams[j],Pos(#1,Telegrams[j])+1,256));
               SendLn('============================================================');
               if StrToIntDef(Copy(Telegrams[j],3,2),-1)>-1 then
                    Sendln('<a href ="'+topuri+'BBS/TELEGRAM/'+Copy(Telegrams[j],3,2)+'">この電報への返事を書く</a>'+textend)
               else
                    Sendln(textend);
              End;
             Telegrams.Clear;
           End;

End;

procedure UserInit(Ip : String);
Var
   i : integer;
Begin

  With User do
   Begin
     Level      := 0;
     Where      := 'Login';
     ID         := 'GUEST';
     HandleName := 'ゲスト';
     Memo       := '';
     LastRead     := Now - GeneralDefine.User.GuestLastReadDate;
     LastFileNews := Now - GeneralDefine.User.GuestLastReadDate;
     LoginTime  := Now;
     UseLoginReport := True;
     For i := 0 to 99 do
        NewsEnableBoards[i] := True;
     With Options do
       Begin
         AddMessageEof := False;
       End;
   End;

   MyCh := -1;

   for i := 0 to 9 do
      if (Ip = WWWUsers[i].ip) and (WWWUsers[i].Enabled=True) then
        Begin
          User := WWWUsers[i].User;
          WWWUsers[i].IdleStartTime := GetTickCount;
          MyCh := i;
          Break;
        End;


End;

procedure MakeHeadHTML;
Begin

   if MyCh<0 then
    Sendln(
           '<center><table border="1" cellpadding="1" cellspacing="0">'#13#10
          +'  <tr>'#13#10
          +'    <td bgcolor="#800080" nowrap><b><font color ="#FFFF80" size="2">ログインしていません</font></b></td>'#13#10
          +'    <td bgcolor="#E8FFE8" nowrap><b><font size="2"><a href="'+topuri+'BBS/">MTBBSログイン</a></font></b></td>'#13#10
          +'    <td bgcolor="#E8FFE8" nowrap><b><font size="2"><a href="'+topuri+'BBS/APPLY/">会員登録</a></font></b></td>'#13#10
          +'    <td bgcolor="#E8FFE8" nowrap><b><font size="2"><a href="'+topuri+'">トップ</a></font></b></td>'#13#10
          +'  </tr>'#13#10
          +'</table></center><hr>')

   else
    Begin
      Sendln(
           '<center><table border="1" cellpadding="1" cellspacing="0">'#13#10
          +'  <tr>'#13#10
          +'    <td bgcolor="#800080" nowrap><b><font color ="#FFFF80" size="2">'+Format('CH%.2d',[99-mych])+'</font></b></td>'#13#10
          +'    <td bgcolor="#FFEBE1" nowrap><b><font size="2"><a href="'+topuri+'BBS/LOGOUT/">ログアウト</a></font></b></td>'#13#10
          +'    <td bgcolor="#E8FFE8" nowrap><b><font size="2"><a href="'+topuri+'BBS/WHO/">ログイン状況</a></font></b></td>'#13#10
          +'    <td bgcolor="#E8FFE8" nowrap><b><font size="2"><a href="'+topuri+'BBS/MES/">メッセージボード</a></font></b></td>'#13#10
          +'    <td bgcolor="#E8FFE8" nowrap><b><font size="2"><a href="'+topuri+'BBS/TELEGRAM/">電報送信</a></font></b></td>'#13#10
          +'    <td bgcolor="#E8FFE8" nowrap><b><font size="2"><a href="'+topuri+'BBS/LOG/">ログ</a></font></b></td>'#13#10
          +'    <td bgcolor="#E8FFE8" nowrap><b><font size="2"><a href="'+topuri+'BBS/MES/NEWS/">末読一気読み</a></font></b></td>'#13#10
//          +'    <td bgcolor="#E8FFE8" nowrap><b><font size="2"><a href="'+topuri+'MAIN/">メイン</a></font></b></td>'#13#10
//          +'    <td bgcolor="#FFFFE6 nowrap><B><font size="2">IP: </font><font color="#0000FF" size="2">'+             ip+'</font></B></td>'#13#10
          );
      If User.Level=0 then
          Sendln('    <td bgcolor="#E8FFE8" nowrap><b><font size="2"><a href="'+topuri+'BBS/APPLY/">会員登録</a></font></b></td>');
       SendLn('    <td bgcolor="#FFFFE6" nowrap><B><font size="2">ID: </font><font color="#0000FF" size="2">'+        User.ID+'</font></B></td>');
       SendLn('    <td bgcolor="#FFFFE6" nowrap><B><font size="2">HANDLE: </font><font color="#0000FF" size="2">'+User.HandleName+'</font></B></td>');
       SendLn('    <td bgcolor="#FFFFE6" nowrap><B><font color="#0000FF" size="2">'+TimeToStr(Now-WWWUsers[MyCh].User.LoginTime)+'</font></B></td>');
       SendLn('  </tr>');
       SendLn('</table></center><hr>');

       ReceiveTelegram;
      End;

End;

procedure Logout(Ip : String);
Var
  Log : TAccessLog;
Begin

    if (Ip = WWWUsers[mych].ip) and (WWWUsers[mych].Enabled=True) then
        Begin
         SendStr := '<H1>ログアウトしました</H1>';
         Sendln('<a href="'+topuri+'BBS/">MTBBSログイン</a> |');
         Sendln('<a href="'+topuri    +'">トップページ</a><hr>');
         Sendln(textstart);
         Sendln(MakeText(LogOutMessage));
         Sendln('---------------------------------');
         Sendln(' ご利用ありがとうございました。');
         Sendln(' 接続時間 : '+TimeToStr(Now-User.LoginTime));
         Sendln('---------------------------------');
         Sendln(textend);
         FreeWWWCh(mych);
         MainForm.WWWSTSAdd(format('WWW_CH%.1d(%.2d)を開放しました',[mych,99-mych]));

          Log.Ch     := 99-Mych;
          Log.Handle := User.HandleName;
          Log.Id     := User.Id;
                //       TCPIP#23
          Log.Way    := 'WWW      '+Ip;
          Log.InTime := User.LoginTime;
          Log.OutTime:= Now;
          AddAccessLog(Log);

        End
        Else
         Sendln('<H1>ログインしていません</H1>');

End;

Function AddUserIP(ip_ : string;User_ : TUser):boolean;
var
   i : integer;
Begin

 Result := False;

 for i := 0 to 9 do
   if WWWUsers[i].Enabled then
       If User.ID<>GeneralDefine.User.GuestID then
          If User.ID = WWWUsers[i].User.ID then
          With WWWUsers[i] do
           Begin
             IP              := IP_;
             Buf             := '';
             ContentLength   := 0;
             Status          := 0;
             URI             :='';
             FreeWWWCh(mych);
             Exit;
           End;

 for i := 0 to 9 do
   if WWWUsers[i].Enabled = False then
     With WWWUsers[i] do
      Begin
        Enabled         := true;
        User            := User_;
        IP              := IP_;
        IdleStartTime   := GetTickCount;
        Buf             :='';
        URI             :='';
        ContentLength   := 0;
        Status          := 0;
       Result := True;
       MainForm.WWWSTSAdd('IP'+ip_+format('に対しWWW_CH%.1d(%.2d)を割り当てました',[i,99-i]));
       Break;
      End;

End;


Function WhoStr : String;
Var
  i : integer;
Begin


       Result := '<B>ログイン状況</B><TABLE BORDER><TR><TD>CH</TD><TD>ユーザID</TD><TD>ハ ン ド ル</TD><TD>接続形式</TD><TD>状態</TD><TD>接続開始</TD><TD>メ モ</TD><TR>'#13#10;
       For i:=0 to 99 Do
       if MainForm.Chs[i].Mode <> Cm_None then
        Begin
         With MainForm.Chs[i].Thread Do
           Result := Result+(Format(
           '<TR><TD>%.2d</TD><TD>%.8s</TD><TD>%.14s</TD><TD>%.8s</TD><TD>%.8s</TD><TD>%.8s</TD><TD>%.25s</TD></TR>'
           +#13#10
            ,[i,User.ID+'        ',User.HandleName+'              ',MainForm.Chs[i].Way+'               '
            ,User.Where+'        ',TimeToStr(User.LoginTime)+'        ',User.Memo]) );
         End;

       For i:=0 to 9 Do
       if WWWUsers[i].Enabled then
        Begin
         With WWWUsers[i] Do
           Result := Result+(Format(
           '<TR><TD>%.2d</TD><TD>%.8s</TD><TD>%.14s</TD><TD>%.8s</TD><TD>%.8s</TD><TD>%.8s</TD><TD>%.25s</TD></TR>'
           +#13#10
            ,[99-i,User.ID+'        ',User.HandleName+'              ','WWW'
            ,User.Where+'        ',TimeToStr(User.LoginTime)+'        ',User.Memo]) );
         End;

        Result := Result +'</TABLE>';
End;

Function ChatRoomListStr : String;
Var
  i,j,n : integer;
  s : string;
Begin


       Result := '<B>チャットルーム開設状況</B><TABLE BORDER><TR><TD>番号</TD><TD>開設者ID</TD><TD>開設者ハンドル</TD><TD>チャットルーム名</TD><TD>人数</TD><TD>状態</TD><TR>'#13#10;

    For i:=1 to 20 do
     Begin
       n := 0;
       for j:= 0 to 99 do
         if MainForm.Chs[j].Mode <> Cm_None then
           if TMtbbs(MainForm.Chs[j].Thread).MyChatRoom = i then
              inc(n);         if MainForm.Chs[j].Mode <> Cm_None then
           if TMtbbs(MainForm.Chs[j].Thread).MyChatRoom = i then
              inc(n);
       With ChatRooms[i] do
        if id<>'' then
          Begin
            if lock then s:='ロック' else s:='オープン';
            Result := Result+(Format(
            '<TR><TD>%.2d</TD><TD>%.8s</TD><TD>%.14s</TD><TD>%.30s</TD><TD>%.2d</TD><TD>%s</TD></TD></TR>'
            +#13#10
            ,[i,ID+'        ',Handle+'              ',RoomTitle+'               ',n,s]) );
         End;
     End;
        Result := Result +'</TABLE>注:WWW接続ではチャットルームをご利用頂けません.';
End;




Function BoardsStr : String;
Var
      s : String;
      i : Integer;
      MidokuSum    : Integer;
      CountSum     : Integer;
      Midoku       : Integer;
      Count        : Integer;
      Year, Month, Day : Word;
Begin
          Result := '<B>メッセージボード一覧</B>';
          Result := Result +('<TABLE BORDER><TR><TD>番号</TD><TD>ラベル</TD><TD>タイトル</TD><TD>総数(未読)</TD><TD>最新</TD><TD>管理者ID</TD><TD>News</TD></TR>'#13#10);
  MidokuSum := 0;
  CountSum := 0;

     For i:=1 to 99 do
       With MessageBoards[i] do
          if Enabled and ((ReadLevel <= User.Level) or (WriteLevel <= User.Level)) then
            Begin
              DecodeDate(MessageBoards[i].LastModified,Year, Month, Day);
              MessageBoard.GetMidokuPoint(i,User.LastRead,Count,Midoku);
              If User.NewsEnableBoards[i] then s := '有効'
                                          else s := '無効';
              if MessageBoards[i].EnforcedNews then
                Begin
                   User.NewsEnableBoards[i] := True;
                   s := '必読';
                End;

              Result :=Result +(Format('<TR><TD><a href="%.2d/">%.4d</a></TD><TD><a href="%.2d/">%.8s</a></TD><TD>%.32s</TD><TD>%.4d(%.4d)</TD><TD>%.2d/%.2d</TD><TD>%.8s</TD><TD>%.4s</TD></TR>'
              ,[i,i,i,Name,Title,Count,Count-Midoku+1,Month,Day,SigopID+'         ',s])+#13#10);
              MidokuSum := MidokuSum + Count-Midoku+1;
              CountSum  := CountSum  + COUNT;
            End;

  Result :=Result +(Format('<TR><TD colspan="3"></TD><TD colspan="3">Total %.4d(%.4d)</TD>',[CountSum,MidokuSum])+#13#10
  +'</TABLE>');

End;


Function Version : string;
Var
   i : Integer;
   Hour,Min,Sec,MSec : Word;
Begin

    User.Where := 'Version';

 Result := textstart+HostVersionMessage+#13#10;
 DecodeTime(Now - SystemStartDateTime,Hour,Min,Sec,MSec);
 Result := Result+(Format('<<　稼働時間 [ %.4d日%.2d時間%.2d分%.2d秒 (開始:'+DateTimeToStr(SystemStartDateTime)+') ] >>',[Trunc(Now - SystemStartDateTime),Hour,Min,Sec]))+#13#10;

  If PluginsCount= 0 then
     Result := Result+('<< プラグインはインストールされていません >>')+#13#10
   else
    Begin
      Result := Result+(Format('<< %.d個のプラグインがインストールされています >>',[PluginsCount]))+#13#10'<HR>'#13#10;
       For i := 0 to PluginsCount - 1 do
        Begin
          Result := Result+(Plugins[i].Information)+#13#10'<HR>'#13#10;
        End;
    End;
   Result := Result + textend;

End;


Function MakeQuoteStr(s: string):string;
Var
  i : integer;
Begin

   Result :='> ';
    For i:=1 to Length(s) do
       Case s[i] of
         #13 : Result := Result  + #13#10'>';
         #10 : ;
        else
           Result := Result + s[i];
       End;

end;


Procedure News;
Var
   s        : String;
   UI       : TUserInit;
   NewsDate : TDateTime;
   EP,MP,i   : Integer;
   ReadStartTime : TDateTime;
   Mes : TMessage;
      Procedure Readm(BoardNo,SN,EN : Integer);
      Var
         Messages : Array [0..30] of TMessage;
         l,m      : Integer;

         Function MakeMessageHead(Mes : TMessage) : String;
         var
           Year, Month, Day, Hour, Min, Sec, MSec: Word;
         begin

           DecodeDate(Mes.DateTime,Year,Month, Day);
           Year := Year - 1900;
           If Year > 99 then Year := Year - 100;
           DecodeTime(Mes.DateTime,Hour,Min, Sec, MSec);

              Result :=
                Format('Message  #%.4d is from: %s',[Mes.No,Mes.ID +' '+Mes.Handle])+#13#10
               +Format('Time: %.2d/%.2d/%.2d %.2d:%.2d:%.2d Section %d: %s',[Year,Month,Day,Hour,Min,Sec,Mes.BoardNo,MessageBoards[Mes.BoardNo].Title])+#13#10
               +'Subj: '+Mes.Title+#13#10;
         End;

      Begin
        For l := 0 to (EN - SN) Div 30 Do
          Begin
             For m := 0 to MessageBoard.Readm(BoardNo,Sn + l*30,SN + l*30+29,Messages)-1 Do
               Begin
                    Mes := Messages[m];
                               SendStr := SendStr +
                                 '<table border="3" cellpadding="2" bgcolor="#EAEAEA">'#13#10
                                +' <tr>'#13#10

                                +  '<td align="center" colspan="2">'
                                +  Format('<font color="#0000FF" size="2">%d:%s</font> | ',[i,MessageBoards[i].Name])
                                +'＜＜前のメッセージ | <B>'+Format('%.4d',[Sn + l*30+m])+ '</B> | 次のメッセージ＞＞';
                                if (MessageBoards[i].WriteLevel <= User.Level) and (MyCh>-1) then
                                   Sendln(Format(' | <a href="../%.2d/WRITE/%.4d">返事を書く</a>',[i,Sn + l*30+m]))
                                else
                                   Sendln(' | 返事を書く');

                             if Mes.No>0 then
                              Begin
                                SendStr := SendStr
                                +' </tr>'#13#10
                                +' <tr>'#13#10
                                +'  <td nowrap><b>投稿者：</b><font color="#800060">'+Mes.ID+' / '+Mes.Handle+'</font></td>'#13#10
                                +'  <td nowrap><b>投稿日時：</b><font color="#800060">'+DateTimeToStr(Mes.DateTime)+'</font></td>'#13#10
                                +' </tr>'#13#10
                                +' <tr>'#13#10
                                +'  <td nowrap colspan="2"><font color="#FF0000"><b>'+Mes.Title+'</b></font></td>'#13#10
                                +' </tr>'#13#10
                                +' <tr>'#13#10
                                +'  <td colspan="2" bgcolor="#FFFFFF"><PRE>'+Mes.Text+'</PRE></td>'#13#10
                                +' </tr></table>';
                              End
                              Else
                                SendStr := SendStr +' <tr>'#13#10
                                +'  <td colspan="2">削除されています</td>'#13#10
                                +' </tr></table>'#13#10;
                                if (MessageBoards[i].WriteLevel <= User.Level) and (MyCh>-1) then
                                   Puts(Format('<a href="../%.2d/WRITE/">このボードにメッセージを書く</a>',[i]));
                                SendStr := SendStr +'<hr>';


//                 Puts(#13#10+MakeMessageHead()+Messages[m].Text);

               End;


          End;
        Sendln('');
      End;

Begin

    User.Where := 'News';
    ReadStartTime := Now;

//    NewsDate := StrToDateTimeDef(s,EncodeDate(1,1,1));

    If User.Level <1 then
      UI.LastRead := User.LastRead //ゲスト
    else
      UI := GetUserInit(User.ID);


     NewsDate := User.LastRead;

    Puts('<H1>日付が '+DateTimeToStr(NewsDate)+' 以降のものを読みます。</H1>'#13#10);

     For i:=1 to 99 do
       With MessageBoards[i] do
          if Enabled and (ReadLevel <= User.Level) then
            Begin
              MessageBoard.GetMidokuPoint(i,NewsDate,EP,MP);
              Puts(Format('%.4d: %.8s %.32s 総数: %.4d ',[i,Name+'          ',Title+' ････････････････････････････････････････････････････････････････<BR>',EP]));

              If User.NewsEnableBoards[i] then
               Begin
                If Ep >= Mp then
                 Begin
                  Puts(#13#10'<H3>新しいメッセージが '+IntToStr(Ep-Mp + 1)+' 個あります。</H3>'#13#10);
                  Readm(i,Mp,Ep);     //　連続読み
                                Sendln(
                                  '<a href="../'+Format('%.2d/',[i])+'01">最初のメッセージ</a> | '
                                + '<a href="../'+Format('%.2d/%.4d',[i,MessageBoards[i].MaxMessageNo])+'">最新のメッセージ</a> | '
//                                + '<a href="*'+IntToStr(j)+'">前の５０件</a> | '
//                                + '<a href="*'+IntToStr(j+50)+'">次の５０件</a> | '
                                + '<a href="../">ボード一覧</a> | '
                                + '<a href="../../">トップページ</a>'
                                + '<hr>'#13#10
                           );//     + MessageBoard.GetMessageListHTML(i,j+5,10,['ALL'],j));
                 End
                 Else
                   Sendln('... 未読なし<BR>');
               End
               Else
                 Sendln('... スキップ<BR>');
            End;

   UI.LastRead := ReadStartTime;
   User.LastRead := ReadStartTime;

    if User.Level > 0 then
        OutUserInit(User.ID,UI);
End;

{
     if (j > 0) and (10000>j) then
                           Begin
                               Mes := MessageBoard.Read(i,j);
                               SendStr := SendStr +
                                 '<table border="3" cellpadding="2" bgcolor="#EAEAEA">'#13#10
                                +' <tr>'#13#10
                                +  '<td align="center" colspan="2">';
                                a := '＜＜前のメッセージ';
                                  if j>1 then
                                      a :=  '<a href="'+IntToStr(j-1)+'">'+a+'</a>';
                                SendStr := SendStr + a + ' | <B>'+Format('%.4d',[j])+ '</B> | ';
                                a := '次のメッセージ＞＞';
                                  if j<MessageBoards[i].MaxMessageNo then
                                      a :=  '<a href="'+IntToStr(j+1)+'">'+a+'</a>';
                                SendStr := SendStr + a;
                                if (MessageBoards[i].WriteLevel <= User.Level) and (MyCh>-1) then
                                   Sendln(' | <a href="WRITE/'+IntToStr(j)+'">返事を書く</a>')
                                else
                                   Sendln(' | 返事を書く');

                             if Mes.No>0 then
                              Begin
                                SendStr := SendStr
                                +' </tr>'#13#10
                                +' <tr>'#13#10
                                +'  <td nowrap><b>投稿者：</b><font color="#800060">'+Mes.ID+' / '+Mes.Handle+'</font></td>'#13#10
                                +'  <td nowrap><b>投稿日時：</b><font color="#800060">'+DateTimeToStr(Mes.DateTime)+'</font></td>'#13#10
                                +' </tr>'#13#10
                                +' <tr>'#13#10
                                +'  <td nowrap colspan="2"><font color="#FF0000"><b>'+Mes.Title+'</b></font></td>'#13#10
                                +' </tr>'#13#10
                                +' <tr>'#13#10
                                +'  <td colspan="2" bgcolor="#FFFFFF"><PRE>'+Mes.Text+'</PRE></td>'#13#10
                                +' </tr>';
                              End
                              Else
                                SendStr := SendStr +' <tr>'#13#10
                                +'  <td colspan="2">削除されています</td>'#13#10
                                +' </tr>';

                                SendStr := SendStr +
                                 '</table>'#13#10'<hr>';
                                if (MessageBoards[i].WriteLevel <= User.Level) and (MyCh>-1) then
                                   Puts('<a href="WRITE/">メッセージを書く</a> | ')
                                else
                                   Puts('メッセージを書く | ');

                                Sendln(
                                  '<a href="01">最初のメッセージ</a> | '
                                + '<a href="'+IntToStr(MessageBoards[i].MaxMessageNo)+'">最新のメッセージ</a> | '
                                + '<a href="*'+IntToStr(j)+'">前の５０件</a> | '
                                + '<a href="*'+IntToStr(j+50)+'">次の５０件</a> | '
                                + '<a href="../">ボード一覧</a> | '
                                + '<a href="../../">トップページ</a>'
                                + '<hr>'#13#10
                                + MessageBoard.GetMessageListHTML(i,j+5,10,['ALL'],j));
                           End

}


Procedure WWWMessageBoard(s:string);
Var
      Mes : TMessage;
        a : string;
      i,j,k : integer;
Begin

    User.Where := 'Board';

      if s='' then
                    SendLn(BoardsStr)
              else
               Begin
                    i := StrToIntDef(Copy(s,1,Pos('/',s+'/')-1),0);
                    if (i > 0) and (100>i) then
                    Begin
                      if MessageBoards[i].ReadLevel  > User.Level then
                         SendLn(accesserrMes)
                      else
                        Begin
                          s := Copy(s,Pos('/',s+'/')+1,99);
                          If Pos('WRITE/',s)>0 then     ///メッセージ書きこみ
                            Begin

                               Sendln('<H1>メッセージの作成</H1>'
                               +'<form ACTION="'+topuri+'BBS/MES/WRITE/" method="POST">'#13#10
                               +'    メッセージボード名 : <br>'#13#10
                               +'    <select name="BOARD" size="1">');
                                for k:=1 to 99 do
                                   if MessageBoards[k].Enabled and (MessageBoards[k].WriteLevel <= User.Level) then
                                      if i=k then
                                        Sendln('        <option selected value="'+IntToStr(i)+'">'+MessageBoards[k].Title+'</option>')
                                      else
                                        Sendln('        <option value="'+IntToStr(i)+'">'+MessageBoards[k].Title+'</option>');
                               Sendln('    </select>');
                               j := StrToIntDef(Copy(s,Pos('WRITE/',s)+6,99),-1);
                               If j>0 then
                               Begin
                                 Mes := MessageBoard.Read(i,j);
                                 If Mes.No<1 then
                                  Begin
                                     Sendln('<H1>エラー:レス対象のメッセージが見つからない</H1>');
                                     Exit;
                                  End;
                                 s := Mes.Title;
                                 If Copy(s,1,3) = 'Re:' then
                                       s := Copy(s,Pos(')',s)+1,80);
                                 If Mes.BoardNo > 0 then
                                       s := Format('Re:%d)',[Mes.No])+s
                                   Else
                                      s := 'Re:'+s;
                               End
                               Else
                                 s := 'タイトルを入れてください';

                               Sendln(
                                '    <br><br>'#13#10
                               +'    タイトル(60文字以内) : <br>'#13#10
                               +'    <input type="text" size="60" maxlength="60" name="TITLE" value="'+s+'"><br><br>');

                               if s[1]='R' then
                                    s:=makequotestr(Mes.Text)
                                 else
                                    s:='どもども、WWWから書いています。';
                               Sendln(
                                '    本文 :(5000字以内)<br>'#13#10
                               +'    <textarea name="TEXT" rows="10" maxlength="5000" cols="78">'#13#10
                               +s
                               +'    </textarea><br>'#13#10
                               +'    <input type="submit" name="B1" value="メッセージを送信する">'#13#10
                               +'</form>');
                               Exit;
                            End;

                          if s='' then
                              j := MessageBoards[i].MaxMessageNo
                          else
                              j := StrToIntDef(s,0);

                          if (j > 0) and (10000>j) then
                           Begin
                               Mes := MessageBoard.Read(i,j);
                               SendStr := SendStr +
                                 '<table border="3" cellpadding="2" bgcolor="#EAEAEA">'#13#10
                                +' <tr>'#13#10
                                +  '<td align="center" colspan="2">'
                                +  Format('<font color="#0000FF" size="2">%d:%s </font>| ',[i,MessageBoards[i].Name]);


                                a := '＜＜前のメッセージ';
                                  if j>1 then
                                      a :=  '<a href="'+IntToStr(j-1)+'">'+a+'</a>';
                                SendStr := SendStr + a + ' | <B>'+Format('%.4d',[j])+ '</B> | ';
                                a := '次のメッセージ＞＞';
                                  if j<MessageBoards[i].MaxMessageNo then
                                      a :=  '<a href="'+IntToStr(j+1)+'">'+a+'</a>';
                                SendStr := SendStr + a;
                                if (MessageBoards[i].WriteLevel <= User.Level) and (MyCh>-1) then
                                   Sendln(' | <a href="WRITE/'+IntToStr(j)+'">返事を書く</a>')
                                else
                                   Sendln(' | 返事を書く');

                             if Mes.No>0 then
                              Begin
                                SendStr := SendStr
                                +' </tr>'#13#10
                                +' <tr>'#13#10
                                +'  <td nowrap><b>投稿者：</b><font color="#800060">'+Mes.ID+' / '+Mes.Handle+'</font></td>'#13#10
                                +'  <td nowrap><b>投稿日時：</b><font color="#800060">'+DateTimeToStr(Mes.DateTime)+'</font></td>'#13#10
                                +' </tr>'#13#10
                                +' <tr>'#13#10
                                +'  <td nowrap colspan="2"><font color="#FF0000"><b>'+Mes.Title+'</b></font></td>'#13#10
                                +' </tr>'#13#10
                                +' <tr>'#13#10
                                +'  <td colspan="2" bgcolor="#FFFFFF"><PRE>'+Mes.Text+'</PRE></td>'#13#10
                                +' </tr>';
                              End
                              Else
                                SendStr := SendStr +' <tr>'#13#10
                                +'  <td colspan="2">削除されています</td>'#13#10
                                +' </tr>';

                                SendStr := SendStr +
                                 '</table>'#13#10'<hr>';
                                if (MessageBoards[i].WriteLevel <= User.Level) and (MyCh>-1) then
                                   Puts('<a href="WRITE/">メッセージを書く</a> | ')
                                else
                                   Puts('メッセージを書く | ');

                                Sendln(
                                  '<a href="01">最初のメッセージ</a> | '
                                + '<a href="'+IntToStr(MessageBoards[i].MaxMessageNo)+'">最新のメッセージ</a> | '
                                + '<a href="*'+IntToStr(j)+'">前の５０件</a> | '
                                + '<a href="*'+IntToStr(j+50)+'">次の５０件</a> | '
                                + '<a href="../">ボード一覧</a> | '
                                + '<a href="../../">トップページ</a>'
                                + '<hr>'#13#10
                                + MessageBoard.GetMessageListHTML(i,j+5,10,['ALL'],j));
                           End
                          else
                           Begin
                            j := StrToIntDef(Copy(s,2,10),0);
                            if Not((j > 0) and (10000>j)) then
                                 j := MessageBoards[i].MaxMessageNo;
                             SendLn(    '<a href="WRITE/">メッセージを書く</a> | '
                                      + '<a href="01">最初のメッセージ</a> | '
                                      + '<a href="'+IntToStr(MessageBoards[i].MaxMessageNo)+'">最新のメッセージ</a> | '
                                      + '<a href="*'+IntToStr(j-50)+'">前の５０件</a> | '
                                      + '<a href="*'+IntToStr(j+50)+'">次の５０件</a> | '
                                      + '<a href="../">ボード一覧</a> | '
                                      + '<a href="../../">トップページ</a>'
                                      + '<hr>'#13#10
                                      + MessageBoard.GetMessageListHTML(i,j,50,['ALL'],-9999)
                                   );
                           End;
                        End;
                    End;
               End;

End;




Procedure maketopuri(URI : String);
var
  i : integer;
Begin

    if Pos('/',URI)=0 then TopURI := './'
    else
     begin
       topuri :='';
       For i:=1 to length(URI) do
         if uri[i]='/' then
          TopURI := TopURI+'../';
     end;

End;



Procedure Telegram(URI : String);
Begin

  If CheckUseLevel(_Telegram) then Exit;
  User.Where := 'Telegram';

   Sendln('<center>'#13#10
         +'<H1>電報送信</H1>'#13#10
         +' <form ACTION="SEND/" method="POST">'#13#10
         +'    <TABLE> <TR><TD>電報を送るチャンネル :</TD><TD><input type="text" size="2" name="TOCH" value="'+IntToStr(StrToIntDef(Copy(URI,Pos('TELEGRAM/',URI)+9,2),0))+'"></TD></TR>'#13#10
         +'            <TR><TD>送るメッセージ :</TD><TD><input type="text" size="80" name="MESSAGE"></TD></TR>'#13#10
         +'    </TABLE>      <input type="submit" name="SEND" value="送信">'#13#10
         +' </form>'#13#10
         +'</center>'
         +whostr);

End;


Procedure Log;
Var
   i,j : Integer;
   Log : ^TAccessLog;
Begin

  If CheckUseLevel(_Log) then Exit;
  User.Where := 'Log';

  Puts(TextStart+#13#10);
  Puts('ユーザID  ハ ン ド ル   CH 接続形式   日 付   ログイン  ログアウト 接続時間'#13#10);
  Puts('-------- -------------- -- --------- -------- --------   --------  --------'#13#10);

  Log := AllocMem(SizeOf(TAccessLog)*(GeneralDefine.Other.Log_MaxSize+1));

  j := GetAccessLog(Log^,GeneralDefine.Other.Log_MaxSize);

   For i := 0 to j-1 do
    With Log^ do
     Begin
      Puts(Format('%.8s %.14s %.2d %.9s %.8s %.8s-->%.8s (%.8s)'#13#10,
      [Id+'         ',Handle+'               ',Ch,Way+'         '
       ,DateToStr(InTime)+'         ',TimeToStr(InTime)+'         '
       ,TimeToStr(OutTime)+'         ',TimeToStr(OutTime - InTime)+'         ']));
      Inc(Log);
     End;
   Dec(Log,j);

  FreeMem(Log,SizeOf(TAccessLog)*(GeneralDefine.Other.Log_MaxSize+1));

  Puts('-------- -------------- -- --------- -------- --------   --------  --------'#13#10);
  Puts(Textend);


End;

Procedure SendUserInfo;
Var
   UI : TUserInit;
Begin

     UI := GetUserInit(User.ID);
     SendStr := SendStr+
                 '<TABLE BORDER bgcolor="#EEFFEE">'#13#10
                +'<TR><TD>ID / ハンドル</TD><TD>'+User.ID+' / '+User.HandleName+'</TD>'#13#10
                +'<TR><TD>レベル</TD><TD>'+IntToStr(User.Level)+'</TD>'#13#10
                +'<TR><TD>最終ログイン</TD><TD>'+DateTimeToStr(UI.LastLogin)+'</TD>'#13#10
                +'<TR><TD>未読日時</TD><TD>'+DateTimeToStr(User.LastRead )+'</TD>'#13#10
                +'<TR><TD>アクセス回数</TD><TD>'+IntToStr(UI.AccessCount)+'</TD>'#13#10
                +'</TABLE>'#13#10;

End;

Procedure Apply;

           Function m(i : Integer) : String;
           Begin
              Result := ' ';
              With GeneralDefine.Profile do
                Case i of
                 1: if Address  then Result := '*';
                 2: if Name     then Result := '*';
                 3: if Tel      then Result := '*';
                 4: if Hobby    then Result := '*';
                 5: if BirthDay then Result := '*';
                 6: if Comment  then Result := '*';
                 7: if Email    then Result := '*';
                End;
           End;
Begin

  User.Where := 'Apply';

  If User.Level <> 0 then
   Begin
       Puts('<H1> あなたはすでに会員登録されています</H1>');
       Exit;
   End;

   Sendln('<H1>会員登録(MTBBS/MTQ共通)</H1>');
   Puts(textstart+#13#10+MakeText(ApplyInfoMessage)+textend);
   If (Not GeneralDefine.Apply.AutoRegist) then
         Exit;
   Sendln(' <form ACTION="REGISTER/" method="POST">'#13#10
         +'   <center><hr><TABLE>');
   If GeneralDefine.Apply.UseFreeID then
      Sendln('        <TR><TD nowrap>ユーザーＩＤ :</TD><TD><input type="text" maxlength="8" size="10" name="ID"><br>'#13#10
            +'           <font size="3" color="#FF0000">ご希望のIDを半角英数字８字以内で入力してください。空欄にしておくと自動作成されます。</font></TD></TR>')
    else
           Sendln('<input type="hidden" maxlength="8" size="10" name="ID">');

   Sendln('        <TR><TD nowrap>パスワード :          </TD><TD><input type="text" maxlength="8" size="10" name="PASSWORD"><br>'#13#10
         +'           <font size="3" color="#FF0000">空欄にしておくと自動作成されます。</font></TD></TR>');
   Sendln('        <TR><TD nowrap>'+m(1)+'住所     :    </TD><TD><input type="text" maxlength="60" size="62" name="ADDRESS"></TD></TR>');
   Sendln('        <TR><TD nowrap>'+m(2)+'氏名     :    </TD><TD><input type="text" maxlength="30" size="32" name="NAME"></TD></TR>');
   Sendln('        <TR><TD nowrap>'+m(3)+'電話番号 :  </TD><TD><input type="text" maxlength="20" size="22" name="TEL"></TD></TR>');
   Sendln('        <TR><TD nowrap>'+m(4)+'趣味     :    </TD><TD><input type="text" maxlength="60"　size="62" name="HOBBY"></TD></TR>');
   Sendln('        <TR><TD nowrap>'+m(5)+'生年月日 :</TD><TD><input type="text" maxlength="6" size="7" name="BIRTHDAY"><br>'#13#10
         +'           <font size="3" color="#FF0000">例)[800609]←1980年6月9日生まれ...yymmdd(yy:西暦下二桁/mm:月/dd:日)</font></TD></TR>');
   Sendln('        <TR><TD nowrap>'+'*'+'ハンドルネーム :</TD><TD><input type="text" maxlength="14" size="16" name="HANDLE"></TD></TR>');
   Sendln('        <TR><TD nowrap>'+m(6)+'コメント :</TD><TD><input type="text" maxlength="160" size="70" name="COMMENT"><BR>'#13#10
         +'           <font size="3" color="#FF0000">ネットを何処で知ったか・・、要望等何でも...</font></TD></TR>');
   Sendln('        <TR><TD nowrap>'+m(7)+'E-MAIL   :  </TD><TD><input type="text" maxlength="45" size="45" name="EMAIL"></TD></TR>');
   Sendln('           </TABLE><hr>'#13#10
         +'    <input type="submit" name="REGISTER" value="以上の内容で登録します">'#13#10
         +'   </center>'#13#10
         +'</form>');
   Sendln('注)"*"印がついている項目については他の一般会員が自由に閲覧できます。'
         +'<font color="#FF0000">"*"印が無い個人情報についてはＳＹＳＯＰ(管理者)以外の会員は見ることができません。</font>');


End;







procedure WWWGET(Socket : Integer;IP : string;URI : String);

   Function ConvWinStyleFileName(s : String) : String;
   Var n : integer;
   begin
    Result := s;
    for n:=1 to length(s) do
      if s[n]='/' then Result[n]:='\';
   end;

             Procedure WWWUpLoadFile(FileName :string;Socket : Integer);
             Var
               s,SendS  : String;
                i : Integer;
             Begin
               If Pos('..',FileName)>0 then
                 Begin
                    Sendln(mtwwwmes+'<h1>無効なURL</h1>');
                    Exit;
                 End;

               If Length(FileName)>0 then
                  If FileName[Length(FileName)]='\' then
                   Begin
                       If FileExists(FileName+'Index.html') then
                          FileName := FileName+'Index.html'
                        else
                          If FileExists(FileName+'Index.htm') then
                              FileName := FileName+'Index.htm';
                   End;

               If FileExists(FileName) then
                Begin
                 For i:= 0 to 99 do
                  if WWWSendFiles[i].Socket = 0 then
                   Begin
                     WWWSendFiles[i].Socket := Socket;
                     WWWSendFiles[i].Rp     := 0;

                     s := UpperCase(ExtractFileExt(FileName));

                     AssignFile(WWWSendFiles[i].F,FileName);
                     Reset(WWWSendFiles[i].F );


                     SendS :=
                      'HTTP/1.0 200 Document follows'#13#10
                     +'MIME-Version: 1.0'#13#10
                     +'Server: MtWeb/1.00'#13#10;

                     If Pos('.HTM',s)>0 then
                       SendS := SendS +'Content-Type: text/html'#13#10
                      else
                     If s ='.JPG' then
                       SendS := SendS +'Content-Type: image/jpg'#13#10
                      else
                     If s ='.GIF' then
                       SendS := SendS +'Content-Type: image/gif'#13#10;

                     SendS := SendS +'Connection: Keep-Alive'#13#10;
{
                     If (SendStr<>'') and (Pos('.HTM',s)>0) then
                        SendStr := SendS+'Content-Length: '+IntToStr(FileSize(WWWSendFiles[i].F )+Length(SendStr))+#13#10
                             +#13#10+SendStr
                      else}

                     SendStr := SendS+'Content-Length: '+IntToStr(FileSize(WWWSendFiles[i].F ))+#13#10
                             +#13#10;


                     SendHTML := False;
                     Exit;
                   End;
                End Else
                 Begin
                   Sendln(mtwwwmes+'<h1>ファイルが見つかりません</h1>'
                   +'<h1><a href="'+topuri+'BBS/">ＭＴＢＢＳログイン</a></h1><br>');
                   If URI = '' then
                      Sendln('root = '+GeneralDefine.TcpIP.WWWroot+'<br>'#13#10
                      +'index.htmlまたはindex.htmという名前のHTMLファイルを置いてください');

                 End;
               End;

Begin


        If URI='BBS/' then
          Begin
            Sendln(MyoHostVer);
            Puts(textstart+MakeText(OpeningMessage)+#13#10+textend);
            Sendln(LoginMes);
            If GeneralDefine.CanUseLevels[_Whos][User.Level] then
               Begin
                 Sendln('<hr>'+WhoStr);
                 Sendln('<hr>'+ChatRoomListStr);
               End;
          End
          Else
           Begin
             if Copy(URI,1,4)<>'BBS/' then
                 WWWUpLoadFile(
                    GeneralDefine.TcpIP.WWWroot+ConvWinStyleFileName(URI),Socket)
             else
             if Copy(URI,1,4)='MTQ/' then
              Begin
      //          Sendln(MTQInfo)
              End
               else
                Begin
                 if URI='BBS/SYSINFO/' then
                   Sendln(textstart+#13#10+SysInfoMessage+textend)
                  else
                    if URI='BBS/VER/' then
                      Sendln(Version)
                     else
                      if Copy(URI,1,13)='BBS/MES/NEWS/' then
                         News
                       else
                       if Copy(URI,1,8)='BBS/MES/' then
                         WWWMessageBoard(Copy(URI,9,1024))
                        else
                          if URI='BBS/APPLY/' then
                            Apply
                         else
                          if MyCh>-1 then // ログインしているとき
                          Begin
                           if Pos('BBS/WHO/',URI)>0 then
                            Begin
                              If not CheckUseLevel(_Whos) then
                                  Sendln(WhoStr);
                            End
                            else
                              if Pos('BBS/LOGOUT/',URI)>0 then
                                Begin
                                 ReceiveTelegram;
                                 Logout(ip);
                                end
                               else
                                 if Copy(URI,1,13)='BBS/TELEGRAM/' then
                                    Telegram(URI)
                                   else
                                    if Copy(URI,1,13)='BBS/LOG/' then
                                       Log
                                     else
                                       Sendln(errMes+#13#10'<br>'#13#10+URI);
                          End
                           else
                             Sendln('*'+errMes+#13#10'<br>'#13#10+URI);
                End;

           End;

End;

      Function WWWToText(s : string) : String;
      Var
        i : Integer;
      Begin
       i:=1;
       Result := '';
       While i<=length(s) do
        Case s[i] of
          '%' : Begin
                  Result := Result + Char(StrToIntDef('$'+Copy(s,i+1,2),0));
                  i:=i+3;
                end;
          '+' : Begin
                  Result := Result + ' ';
                  Inc(i);
                End;
         Else
                Begin
                  Result := Result +s[i];
                  Inc(i);
                 End;
        End;
      End;

Function GetStr(searchStr : String;s : string):string;
Var
   i : integer;
   a : string;

Begin

   i := Pos(UpperCase(SearchStr)+'=',s);
 if i<1 then
    Result := ''
 else
  Begin
   a := Copy(s,i+Length(SearchStr)+1,5000);
   Result := WWWToText(Copy(a,1,Pos('&',a+'&')-1));
  End;
End;

Function MakeMessageHead(Mes : TMessage) : String;
var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin

  DecodeDate(Mes.DateTime,Year,Month, Day);
  Year := Year - 1900;
  If Year > 99 then Year := Year - 100;
  DecodeTime(Mes.DateTime,Hour,Min, Sec, MSec);

     Result :=
       Format('Message  #%.4d is from: %s',[Mes.No,Mes.ID +' '+Mes.Handle])+#13#10
      +Format('Time: %.2d/%.2d/%.2d %.2d:%.2d:%.2d Section %d: %s',[Year,Month,Day,Hour,Min,Sec,Mes.BoardNo,MessageBoards[Mes.BoardNo].Title])+#13#10
      +'Subj: '+Mes.Title+#13#10;

End;


Procedure WWWPOST(socket : integer;ip : string;URI : string;buf : string);

   ///-------------------------------/
      Procedure Login;
      Var
        UI : TUserInit;
        i : Integer;
      Begin

         If MyCh > -1 then
                  Begin
                    SendLn('<H1>既にログインしています</H1>');
                    Exit;
                  End;

         User.ID := UpperCase(GetStr('ID',buf));

         If User.ID = GeneralDefine.User.GuestID then
           Begin
            User.HandleName := Trim(GetStr('HANDLENAME',buf));
            if User.HandleName='' then User.HandleName := 'ゲスト';
           end
           else
            Begin
              UI      := GetUserInit(User.ID);
              if UI.Password = GetStr('PASSWORD',buf) then
               Begin
                 User.HandleName := UI.Handle;
                 User.Memo       := UI.Memo;
                 User.Level      := UI.Level;
                 User.LastRead   := UI.LastRead;
                 User.LastFileNews := UI.LastFileNews;
                 User.UseLoginReport := UI.UseLoginReport;
                 User.NewsEnableBoards := UI.NewsEnableBoards;
                 User.ReceiveTelegramBell := UI.ReceiveTelegramBell;
               End
                 Else
                  begin
                //   AddLoginError(MainForm.chs[Fch].Way,Id,s);
                     SendLn('<H1>ＩＤまたはパスワードが正しくありません</H1>');
                     SendLn('<a href="../">戻る</a>');
                     Exit;
                  end;
            End;

               if AddUserIP(ip,user) then
                  Begin
                    SendStr :='';
                    User.LoginTime := Now;
                    UserInit(ip);
                    makeHeadHTML;
                    SendLn('<H1>ログインしました</H1>');
                    SendUserInfo;
                    Sendln('<H3><font color="#FF0000">終了するときには必ず左上のログアウトをクリックしてください。</font></h3>');
                    Puts(textstart+MakeText(LoginMessage)+#13#10+textend);
                       PlayLoginSound; //
                    MainForm.MtbbsStsAdd('ユーザーがログインしました. '+User.ID+' / '+User.HandleName);
                     For i := 0 to 99 do
                      Begin
                       if  (MainForm.Chs[i].Thread <> nil) and MainForm.Chs[i].Thread.User.UseLoginReport and GeneralDefine.Telegram.LoginTelegram then
                           MainForm.Chs[i].Thread.Telegrams.Add('<< MTBBS SYSTEM >>'+#1+Format('チャンネル[%.2d]に %.8s %.14s さんがログインしました。',[99-mych,User.ID,User.HandleName]));
                      End;
                     For i := 0 to 9 do
                      Begin
                       if (mych<>i) and WWWUsers[i].Enabled and WWWUsers[i].User.UseLoginReport and GeneralDefine.Telegram.LoginTelegram then
                           WWWUsers[i].Telegrams.Add('<< MTBBS SYSTEM >>'+#1+Format('チャンネル[%.2d]に %.8s %.14s さんがログインしました。',[99-mych,User.ID,User.HandleName]));
                      End;
                  End
                 else
                  Begin
                    SendLn('*** エラー(www接続最大数を超えました) ***');
                    Sendln('<H1>もうしばらく待ってから再接続してください</H1>');
                    Exit;
                  End
      End;

      Procedure WriteMessage;
      Var
         mes : TMessage;
      Begin
          Mes.BoardNo  := StrToIntDef(GetStr('BOARD',buf),0);
          If (Mes.BoardNo<1) or (Mes.BoardNo>99) then
            Begin
                 Sendln('<H1>エラー..boardno</H1>');
                 Exit;
            End;
          If MessageBoards[Mes.BoardNo].WriteLevel> User.Level then
            Begin
                 Sendln('<H1>アクセス権がありません</H1>');
                 Exit;
            End;
          Mes.No       := MessageBoards[Mes.BoardNo].MaxMessageNo+1;
          Mes.Handle   := User.HandleName;
          Mes.ID       := User.ID;
          Mes.DateTime := Now;
          Mes.Title    := GetStr('TITLE',buf);
          Mes.Text     := GetStr('TEXT',buf)+#13#10;
          Mes.MesTo    :='ALL';
          If MessageBoard.Write(Mes.BoardNo,Mes) then
               Sendln('<H1>メッセージを書きこみました</H1>')
            else
               Sendln('<H1>メッセージの書きこみに失敗しました</H1>');
          Puts(Textstart+#13#10+MakeMessageHead(Mes)+#13#10+Mes.Text+Textend);
      End;



      Procedure UserRegister;
      Var
         UI : TUserInit;
         Text : String;
             Function CheckStr(s : String) : Boolean;
              Var
                 i  : Integer;
                 a  : String;
              Begin
               Result := True;
               for i := 1 to Length(s) do
                 if (s[i]<#33) or (#122<s[i]) then
                    Result := False;
              End;
      Const
         backmes = #13#10'<H2>ブラウザの「戻る(BACK)」ボタンを押し修正してください</H2>';
      Begin

           UI := DefaultUserInit;

           UI.Id       := UpperCase(GetStr('ID',buf));
           UI.Password := GetStr('Password',buf);
           UI.Address  := GetStr('Address',buf);
           UI.Name     := GetStr('Name',buf);
           UI.Telno    := GetStr('Tel',buf);
           UI.Hobby    := GetStr('Hobby',buf);
           UI.BirthDay := GetStr('BirthDay',buf);
           UI.Handle   := GetStr('Handle',buf);
           UI.Comment  := GetStr('Comment',buf);
           UI.Email    := GetStr('Email',buf);

           if UI.Id= '' then
               UI.Id := MakeUserID
            else
             Begin
                If CheckStr(UI.ID)=FALSE then
                    Begin
                      Sendln('<h2>ID:不正な文字が含まれています。半角英数字のみでお願いします。</h2>'+backmes);
                      exit;
                    End;
                If (SearchUser(UI.ID)<>-1) then
                    Begin
                      Sendln('<h2>指定されたＩＤは既に使用されています</h2>'+backmes);
                      exit;
                    End;
                If (StrToIntDef(Copy(UI.ID,Length(GeneralDefine.Apply.IdHead)+1,99),-1)>-1)
                  and (GeneralDefine.Apply.IdHead=Copy(UI.ID,1,Length(GeneralDefine.Apply.IdHead))) then
                    Begin
                      Sendln('<h2>指定されたＩＤは使用できません<h2>'+backmes);
                      exit;
                    End;
             End;
           if UI.Password= '' then
              Begin
                Randomize;
                UI.Password := IntToHex(Random($FFFFFFFF),8);
              End
            Else
             If CheckStr(UI.Password)=FALSE then
                  Begin
                      Sendln('<h2>PASSWORD:不正な文字が含まれています。半角英数字のみでお願いします。</h2>'+backmes);
                      exit;
                   End;
           if UI.Address='' then
               Begin
                   Sendln('<h2>「住所」が入力されていません</h2>'+backmes);
                   exit;
               End;
           if UI.Name= '' then
               Begin
                   Sendln('<h2>「氏名」が入力されていません</h2>'+backmes);
                   exit;
               End;
           if UI.Handle= '' then
               Begin
                   Sendln('<h2>「ハンドルネーム」が入力されていません</h2>'+backmes);
                   exit;
               End;

            UI.Level    := GeneralDefine.Apply.StartLevel;
            UI.SignOn   := Now;
            OutUserInit(UI.ID,UI);
            Sendln('<p><font color="#0000FF" size="6"><B>'+UI.Handle+'</B></font>'#13#10
                  +'<font color="#FF8000" size="6"><B>さん、入会おめでとうございます</B></font></p>');
            Sendln('<HR><p><font size="5">あなたの<br>');
            Sendln('<font size="5"><b>ユーザーID</b>は、</font>'#13#10
                  +'<font color="#FF0000" size="7"><b>'+UI.ID+'</b></font><br>');
            Sendln('<font size="5"><b>パスワード</b>は、</font>'#13#10
                  +'<font color="#FF0000" size="7"><b>'+UI.Password+'</b></font><br>');
            Sendln('です。忘れないように、必ず控えておいてください。</font></P>');
            Sendln('<a href="../../">トップページへ</a><HR><BR>');
            Sendln(textstart+#13#10);
            Text := ' Ｉ　Ｄ   : '+UI.ID+#13#10
                   +'パスワード: '+UI.Password+#13#10
                   +' 住 所    : '+UI.Address+#13#10
                   +' 氏 名    : '+UI.Name+#13#10
                   +'電話番号  : '+UI.TelNo+#13#10
                   +' 趣 味    : '+UI.Hobby+#13#10
                   +'生年月日  : '+UI.BirthDay+#13#10
                   +'入会日時  : '+DateTimeToStr(UI.SignOn)+#13#10
                   +'コメント  : '+UI.Comment+#13#10
                   +'E-MAIL    : '+UI.EMail+#13#10;
            SendStr := SendStr + Text;
            Sendln('この内容を変更する場合はtelnetでログインしｏコマンドを使用してください。'#13#10+textend);
            User.Level := -1;
            SendMailFromSystemToSysop('会員登録がありました[WWW]',Text);

      End;


      Procedure SendTelegram;
      Var
         ch : integer;
         mes : String;
      Begin

          If CheckUseLevel(_Telegram) then Exit;
          ch := StrToIntDef(GetStr('TOCH',buf),-1);

          if (ch<0) or (ch>99) then
             Begin
                Sendln('<H1>電報を送るチャンネルの指定が正しくありません</H1>');
                Exit;
             End;

          if (MainForm.Chs[ch].mode = Cm_None) and not(IsUsedWWWch(ch)) then
          Begin
              Sendln('<H1>ログインされていません</H1>');
              Sendln('残念ながら電報は届きませんでした(T_T)<BR>');
              Exit;
          End;

           mes := GetStr('MESSAGE',buf);

           if IsUsedWWWch(ch) then
            Begin
              wwwusers[99-ch].Telegrams.Add(
                 Format('CH%.2d %.14s',[99-mych,User.HandleName])+#1+mes);
              Sendln('<H1>'+WWWUsers[99-ch].User.HandleName+' さんへ電報を送信しました</H1>');
            End
            Else
             Begin
              MainForm.Chs[ch].Thread.Telegrams.Add(
                 Format('CH%.2d %.14s',[99-mych,User.HandleName])+#1+mes);
              Sendln('<H1>'+MainForm.Chs[ch].Thread.User.HandleName+' さんが電報を読んだはずです☆ミ</H1>');
             End;
      End;




   ///-------------------------------/ Procedure WWWPOST(socket : integer;ip : string;URI : string;buf : string);


Begin

   If URI='BBS/LOGIN/' then
     Login
     else
      If URI='BBS/APPLY/REGISTER/' then
         UserRegister
       else
        Begin
         if MyCh>-1 then // ログインしているとき
                  Begin
                   If URI='BBS/TELEGRAM/SEND/' then SendTelegram
                     else
                      If URI='BBS/MES/WRITE/' then WriteMessage
                       else
                         Sendln(errMes);
                  End
                  Else
                   Sendln('*'+errMes);
        End;


End;



Function GetInfoStr(searchStr : String;s : string):string;
Var
   i : integer;
   a : string;
Begin

   i := Pos(UpperCase(SearchStr)+':',UpperCase(s));
 if i<1 then
    Result := ''
 else
  Begin
   a := Copy(s,i+Length(SearchStr)+1,100);
   Result := Copy(a,1,Pos(#13,a)-1);
  End;

End;


Procedure WWWReceive(Sender: TObject;Socket: Integer);
Var
   s,URI,ip  : String;
   i : integer;

      {
      Function WWWLength(s : string) : Integer;  //高速化のため・・・・
      Var
        i,n : Integer;
      Begin
       n:=0;
       For i:=1 to length(s) do
          if s[i]='%' then
             inc(n);

       Result := Length(s)-n*2;

      End;
      }

     Procedure SetUri;
     Begin
      URI := Copy(s,Pos('/',s)+1,256);
      URI := WWWToText(Copy(URI,1,Pos(' ',URI)-1));
     End;

begin

    SendStr := '';
    SendHTML := True;
    s  := MainForm.WWWServer.Read(Socket);
    ip := MainForm.WWWServer.PeerToAddress(Socket);
    UserInit(ip);

    if (MyCh=-1) and (WWWUsers[MyCh].Ip<>'') and (Ip<>WWWUsers[MyCh].Ip) then
     Begin
       Sendln('<H1>MTBBS SERVER  ERROR</H1>原因:同時に複数の非チャンネル割り当て者によるPOST処理があったと思われます。リロードしてください。');
       WWWUsers[MyCh].Ip            := '';
       WWWUsers[MyCh].Buf           :='';
       WWWUsers[MyCh].URI           :='';
       WWWUsers[MyCh].ContentLength := 0;
       WWWUsers[MyCh].Status        := 0;
     End
   else
  While true  do
    Case  WWWUsers[MyCh].Status of
      0 : If Pos('GET',s)>0 then
           Begin
             seturi;
             maketopuri(URI);
             makeheadhtml;
             MainForm.WWWStsAdd(ip+'get-> '+URI);
             WWWGET(socket,ip,URI);
             Break;
           End
          else
           If Pos('POST',s)>0 then
             Begin
              SetUri;
              If MyCh = -1 then
                 WWWUsers[MyCh].ip         := Ip;     // Mych=-1 ....仮割り当てチャンネル NETSCAPE対策
              WWWUsers[MyCh].ContentLength := -1;
              WWWUsers[MyCh].URI           := URI;
              Inc(WWWUsers[MyCh].Status);
             End
             Else
               Exit;
      1 : Begin
            WWWUsers[MyCh].ContentLength := StrToIntDef(GetInfoStr('Content-Length',s),-1);
            If WWWUsers[MyCh].ContentLength>-1 then
            Begin
                  WWWUsers[MyCh].Buf := '';
                  Inc(WWWUsers[MyCh].Status);
            End else
              Exit;
          End;
      2 : Begin
             WWWUsers[MyCh].Buf := WWWUsers[MyCh].Buf + s;
             if (Pos(#13#10#13#10,WWWUsers[MyCh].buf)>0) and
                (Length(WWWUsers[MyCh].Buf)-(Pos(#13#10#13#10,WWWUsers[MyCh].buf)+3) >= WWWUsers[MyCh].ContentLength) then
                 Inc(WWWUsers[MyCh].Status)
             Else
                 Exit;
          End;
      3 : Begin
            URI := WWWUsers[MyCh].URI;
            maketopuri(URI);
            makeheadhtml;
            If MyCh=-1 then WWWUsers[-1].ip:='';
            i := MyCh;
            WWWPOST(socket,ip,URI,WWWUsers[MyCh].Buf);
            WWWUsers[i].Buf           :='';
            WWWUsers[i].ContentLength := 0;
            WWWUsers[i].Status        := 0;
            break;
          End;
    End;

  {

   If (WWWUsers[MyCh].ContentLength<>0) and ((WWWUsers[-1].ip=ip) or (MyCh>-1)) then
           Begin
              With WWWUsers[MyCh] Do
               Begin
                if ContentLength=-1 then
                 Begin
                   ContentLength := StrToIntDef(GetInfoStr('Content-Length',s),-1);
                   Content := Content + Copy(s,Pos(#13#10#13#10,s)+4,1024);
                 End
                 Else
                   Content := Content + s;
                if  Length(Content) < ContentLength then Exit;
               End;
              URI                    := WWWUsers[MyCh].URI;
              maketopuri(URI);
              makeheadhtml;
              WWWPOST(socket,ip,URI,WWWUsers[MyCh].Content);
              MainForm.WWWStsAdd(Ip+'postdata?->'+URI);
              WWWUsers[MyCh].Content :='';
              WWWUsers[MyCh].ContentLength := 0;
              If MyCh=-1 then WWWUsers[-1].ip:='';
            End
    else
    If Pos('GET',s)>0 then
      Begin
        seturi;
        makeheadhtml;
        MainForm.WWWStsAdd(ip+'get-> '+URI);
        WWWGET(socket,ip,URI);
      End
    else
     If Pos('POST',s)>0 then
       Begin

         if Pos(#13#10#13#10,s)>0 then
             Content := Copy(s,Pos(#13#10#13#10,s)+4,1024)
         else
             Content := '';
                      //あーきたないなぁ・・・・Netscapeは一回目の送信でContentを送ってくれない
         ContentLength := StrToIntDef(GetInfoStr('Content-Length',s),-1);
         If (ContentLength=-1) or (Length(Content)<ContentLength) then
            Begin
                  Exit;
            End;

       End
      else
              Sendln('<H1>MTBBS SERVER  ERROR</H1>原因:同時に複数の非チャンネル割り当て者によるPOST処理があったと思われます');
     }

  If SendHTML then
    Begin
       WWWSend(Socket,SendStr);
       MainForm.WWWServer.Disconnect(Socket);
    End
    Else
       MainForm.WWWServer.Write(Socket,SendStr);


End;




end.
