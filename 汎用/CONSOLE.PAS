unit CONSOLE;

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls,LightStr, Menus,clipbrd;

type
  TCONSOLEWindow = class(TForm)
    Timer1: TTimer;
    Panel1: TPanel;
    Splitter1: TSplitter;
    BackTextPanel: TPanel;
    BackText: TPaintBox;
    Label3: TLabel;
    MainTextPanel: TPanel;
    MainText: TPaintBox;
    Label1: TLabel;
    Panel4: TPanel;
    BackTextScrollBar: TScrollBar;
    Panel2: TPanel;
    BackScrollButton: TSpeedButton;
    Label4: TLabel;
    SpeedButton3: TSpeedButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure MainTextClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure MainTextPanelEnter(Sender: TObject);
    procedure MainTextPanelExit(Sender: TObject);
    procedure BackTextPanelResize(Sender: TObject);
    procedure MainTextPanelResize(Sender: TObject);
    procedure MainTextPaint(Sender: TObject);
    procedure BackTextPaint(Sender: TObject);
    procedure BackTextScrollBarChange(Sender: TObject);
    procedure BackTextMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BackTextMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BackTextMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BackTextPanelClick(Sender: TObject);
    procedure BackScrollButtonClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure BackTextScrollBarEnter(Sender: TObject);
    procedure Edit1Change(Sender: TObject);

  private

     CaretLeft,CaretTop  : Integer;
    CaretEnabled  : Boolean;

    ScrollCount : Integer;

    procedure MainTextOut;
    procedure BackTextOut;
    procedure MainTextScroll;

    procedure AppOnMessage(var msg: TMsg; var handled: Boolean);
    Function MainTextKeyDown(var msg: TWmKeyDown) : Boolean;
    Procedure WMGetMinMaxInfo(Var Msg:TWMGetMinMaxInfo);

  public

    FontHeight,FontWidth  : Integer;

      Logs  : TLightStrings;
      MainTextRePaint         : Boolean;//‰æ–Ê•`‰æƒtƒ‰ƒO

      DrawStartPoint,DrawPoint,SelStartY,SelStartX,SelEndX,SelEndY : Integer;
      BackTextStartPoint                  : Integer;
      BackTextSelected,BackTextDragging   : Boolean;

      _BackScroll   : Boolean;

     procedure AddStr(Data : String);
     procedure BackScroll(Enable : Boolean);
     procedure AppOnActivate(Sender: TObject);
     procedure AppOnDeActivate(Sender: TObject);
     Function GetSelBackText:String;

  end;

implementation
uses MVCL;

{$R *.DFM}


procedure TCONSOLEWindow.BackScroll(Enable : Boolean);
Begin

  _BackScroll           := Enable;
  BackScrollButton.Down := Enable;
  Splitter1.Visible     := Enable;
  BackTextPanel.Visible := Enable;

End;

procedure TCONSOLEWindow.FormCreate(Sender: TObject);
begin

  FontHeight := MainText.Canvas.TextHeight('A');
  FontWidth  := MainText.Canvas.TextWidth('A');

  Application.OnMessage := AppOnMessage;

     Application.OnActivate   := AppOnActivate;
     Application.OnDeActivate := AppOnDeActivate;

     Logs := TLightStrings.Create;
     Logs.Add('');
     Logs.Add('');

     BackScroll(False);

  CaretEnabled := False;
   {
    MaintextPanel .Canvas.ClipRect := (0,0,0,0);
    BacktextPanel .Canvas.ClipRect := (0,0,0,0);
            Panel1.Canvas.ClipRect := (0,0,0,0);
    }

end;

procedure TCONSOLEWindow.FormDestroy(Sender: TObject);
begin


     Logs.Free;

end;

procedure TCONSOLEWindow.AddStr(Data : String);
Var
   i : Integer;
   S : String;
Begin

   Mutex.Wait;

          S := Logs[Logs.Count - 1];
          For i:=1 to Length(Data) Do
          Begin
                If (Data[i] < #32) then
                   Begin
                     If Data[i]=#8 then
                       S       := Copy(S,1,Length(s)-1);
                     If Data[i]=#13 then
                      Begin
                        Logs[Logs.Count - 1] := S;
                        S := '';
                        Logs.Add('');
                    //    Inc(ScrollCount);
                      End;
                   End Else
                     s       := s       + Data[i];
          End;
          Logs[Logs.Count - 1] := S;

    MainTextRepaint := True;

   Mutex.Release;

End;




procedure TCONSOLEWindow.Timer1Timer(Sender: TObject);
Var
   SS : String;
begin


   if Logs.Count-1 <= BackTextScrollBar.Min then BackTextScrollBar.Max := BackTextScrollBar.Min
                                            else BackTextScrollBar.Max := Logs.Count-1;
   if MainTextRePaint then
      MainTextOut
     else
       if ScrollCount> 0 then
          MainTextscroll;

end;


procedure TCONSOLEWindow.FormActivate(Sender: TObject);
begin


   MainTextRePaint:=True;
   If MainTextPanel=ActiveControl Then
      MainTextPanelEnter(Sender);

end;

procedure TCONSOLEWindow.FormDeactivate(Sender: TObject);
begin

   If MainTextPanel=ActiveControl Then
      MainTextPanelExit(Sender);

end;

procedure TCONSOLEWindow.MainTextPanelEnter(Sender: TObject);
begin

  If  CaretEnabled then Exit;


     CreateCaret(MainTextPanel.Handle,0,10,20);
     SetCaretPos(CaretLeft,CaretTop);
     CaretEnabled := True;
     ShowCaret(MainTextPanel.Handle);

end;

procedure TCONSOLEWindow.AppOnActivate(Sender: TObject);
begin

  If Screen.ActiveForm = Self then
   Begin
        FormActivate(Sender);
   End;

end;

procedure TCONSOLEWindow.AppOnDeActivate(Sender: TObject);
begin
 If Screen.ActiveForm = Self then
   Begin
        FormDeActivate(Sender);
   End;
end;

procedure TCONSOLEWindow.MainTextPanelExit(Sender: TObject);
begin

  If  Not CaretEnabled then Exit;
   CaretEnabled := False;
   DestroyCaret;

end;


procedure TCONSOLEWindow.MainTextClick(Sender: TObject);
begin

    MainTextPanel.SetFocus;

end;


Function TCONSOLEWindow.MainTextKeyDown(var msg: TWmKeyDown) : Boolean;
Var
    h:Integer;
begin

  h:=(BackText.Height div (-BackText.Font.Height));

 Result:=False;

  case msg.CharCode of
    VK_UP: Begin
      Result:=True;
      if Not(_BackScroll) Then
       Begin
         BackTextScrollBar.Position := Logs.Count-1;
         BackScroll(True)
       End
       Else
       if BackTextScrollBar.Position>0 then
          BackTextScrollBar.Position:=BackTextScrollBar.Position-1;
     End;
    VK_DOWN: Begin
      Result:=True;
      if BackTextScrollBar.Position < Logs.Count-1 then
         BackTextScrollBar.Position:=BackTextScrollBar.Position+1
      else
         If _BackScroll then BackScroll(False);

     End;
    VK_PRIOR: //* Page Up */
     Begin
      Result:=True;
      if Not(_BackScroll) Then
       Begin
         BackTextScrollBar.Position := Logs.Count-1;
         BackScroll(True)
       End
       Else
         if BackTextScrollBar.Position>h then BackTextScrollBar.Position:=BackTextScrollBar.Position-h
                                         Else BackTextScrollBar.Position:=0;
     End;
    VK_NEXT: //* Page Down */
     Begin
      Result:=True;
      If _BackScroll then
           if BackTextScrollBar.Position < Logs.Count-1-h then BackTextScrollBar.Position:=BackTextScrollBar.Position+h
                                                          Else BackScroll(False);

     End;
    VK_ESCAPE:
     if _BackScroll Then Begin
      Result:=True;
      BackScroll(False);
      MainTextPanel.SetFocus;
     End;

  end;

  inherited;
end;





procedure TCONSOLEWindow.AppOnMessage(var msg: TMsg; var handled: Boolean);
var
  Mes:TMessage;
begin
  If Screen.ActiveForm<>Self Then Exit;

    Mes.msg := msg.message;
    Mes.WParam := msg.WParam;
    Mes.LParam := msg.LParam;

  case msg.message of
    WM_KEYDOWN: Begin

    If ActiveControl=MainTextPanel then
      Begin
         if MainTextKeyDown(TWmKeyDown(Mes))
           then msg.message:=0;
      End;
    end;

  end;

end;

Procedure TCONSOLEWindow.WMGetMinMaxInfo(Var Msg:TWMGetMinMaxInfo);
Begin
  inherited;
  Msg.MinMaxInfo^.ptMaxSize.x:=Width;
  Msg.MinMaxInfo^.ptMaxTrackSize.X:=Width;
  Msg.MinMaxInfo^.ptMinTrackSize.x:=Width;
End;


procedure TCONSOLEWindow.BackTextPanelResize(Sender: TObject);
Var
   i : Integer;
begin

    BackTextScrollBar.Height := BackText.Height;

   i := BackText.Height div (-BackText.Font.Height);
   if i>BackTextScrollBar.max then BackTextScrollBar.max := i;
   BackTextScrollBar.min := i;

end;

//------------------------ •`‰æƒ‹[ƒ`ƒ“


procedure TCONSOLEWindow.MainTextScroll;
Var
  i, h         : Integer;
  R            : TRect;
  DrawStr      : String;
  CaretVisible : Boolean;
  TextHeight   : Integer;
Begin

  MainText.Canvas.TryLock;

    DrawStr :='';

      For i := Logs.Count -1 - ScrollCount to Logs.Count - 1 do
          DrawStr  := DrawStr + Copy(logs[i]
           +'                                                                                               '
                     ,1,100)+#13#10;

     DrawStr := DrawStr + '                                                                      ';
     MainTextRePaint:=False;

     CaretVisible := (ActiveControl = MainTextPanel) and (Screen.ActiveForm = Self) and Application.Active;
     CaretLeft    := MainText.Left + 8*Length(Logs[Logs.Count-1]);
     CaretTop := MainText.Top + ((-MainText.Font.Height)-1)*(Logs.Count-1-h);
     If CaretLeft  > MainText.Left  + MainText.Width - 8 then
        CaretLeft := MainText.Left  + MainText.Width - 8;

     if CaretVisible then HideCaret(MainTextPanel.Handle);

      With MainText do
       Begin
         Bitblt(Canvas.Handle,0,-ScrollCount*TextHeight,Width,Height,Canvas.Handle,0,0,SrcCopy);
         Canvas.TextOut(0,(Height div TextHeight - ScrollCount) * TextHeight,DrawStr);
       End;

     if CaretVisible then
        Begin
          SetCaretPos(CaretLeft,CaretTop);
          ShowCaret(MainTextPanel.Handle);
        End;

     ScrollCount := 0;

  MainText.Canvas.UnLock;


End;

procedure TCONSOLEWindow.MainTextOut;
Var
  i, h         : Integer;
  R            : TRect;
  DrawStr      : String;
  CaretVisible : Boolean;
//  Rect : TRect;
Begin

  MainText.Canvas.TryLock;

    DrawStr :='';

      H  := Logs.Count-(MainText.Height div (FontHeight+4));
      if H < 1 then H := 1;

      For i:=h to Logs.Count-1 do
       Begin
           DrawStr  := DrawStr + Copy(logs[i]
           +'                                                                                               '
                     ,1,100)+#13#10;
       End;
      DrawStr := DrawStr + '                                                                      ';
     MainTextRePaint:=False;

     CaretVisible := (ActiveControl = MainTextPanel) and (Screen.ActiveForm = Self) and Application.Active;

     CaretLeft    := MainText.Left + MainText.Canvas.TextWidth(Logs[Logs.Count-1]);
     CaretTop     := MainText.Top  + (FontHeight+4)*(Logs.Count-h-1);

     If CaretLeft  > MainText.Left  + MainText.Width - FontWidth then
        CaretLeft := MainText.Left  + MainText.Width - FontWidth;

     if CaretVisible then HideCaret(MainTextPanel.Handle);


    r := Rect(0,0,MainText.Width,MainText.Height);
     DrawText(MainText.Canvas.Handle,PChar(DrawStr),Length(DrawStr),r,DT_LEFT);

{     With Rect Do
       Begin
         Left := 0;
         Top  := 0;
         Right  := MainText.width;
         Bottom := MainText.Height;
       End;
 }

//     MainText.Canvas.TextRect(R,0,0,DrawStr);


     if CaretVisible then
        Begin
          SetCaretPos(CaretLeft,CaretTop);
          ShowCaret(MainTextPanel.Handle);
        End;

  MainText.Canvas.UnLock;


End;


procedure TCONSOLEWindow.BackTextOut;
Var
  P: PChar;
  i,j,SX,SY,EX,EY,SSX : Integer;
Begin

  P := StrAlloc(120);
  DrawPoint := BackTextScrollBar.Position;
  If DrawPoint > Logs.Count-1 then DrawPoint := Logs.Count-1;

 With BackText do Begin

    DrawStartPoint := DrawPoint - Height div (FontHeight+4)+1;
    if DrawStartPoint<0 then
      Begin
       DrawStartPoint:=0;
       //DrawPoint:=(Height div (-Font.Height))+1;
       DrawPoint := Logs.Count-1;
      End;

    j:=0;

    If BackTextSelected=False then
     for i:=DrawStartPoint to DrawPoint do
      Begin
       StrPLCopy(P,Logs[i]+
         '                                                                                    '
           ,100);
         Canvas.TextOut(0, j, StrPas(p));
       J:=j+FontHeight+4;
      End
     Else Begin
     SY:=SelStartY;
     SX:=SelStartX;
     EY:=SelEndY;
     EX:=SelEndX;
     If  EY<SY              Then Begin EY:=SY;SY:=SelEndY;EX:=SX;SX:=SelEndX;End;
     If (EY=SY) And (EX<SX) Then Begin EX:=SX;SX:=SelEndX;End;

     if (SY < DrawStartPoint) and (DrawStartPoint <= EY)then Begin SY:=DrawStartPoint;SX:=0;End;
     for i:=DrawStartPoint to DrawPoint do
      Begin
        If  ((DrawStartPoint <= i) And (i < SY       )) or
            ((SY             <  i) And (i < EY  )) or
             (EY        <  i)                         Then Begin
           StrPLCopy(P,Logs[i]+'                                                                                    '
           ,100);
           Canvas.TextOut(0, j, StrPas(p));
        End;

        SSX:=0;
        If i = SY then Begin
          StrPLCopy(P,Logs[SY]+'                                                                                          '
                             ,SX+1);
          Canvas.TextOut(0, j, StrPas(p));
          StrPLCopy(P,Copy(Logs[SY]+'                                                                                    '
                       ,SX+1,100),100);
          Canvas.Brush.Color := clBlue;
          Canvas.Font.Color := clYellow;
          Canvas.TextOut(FontWidth*SX, j, StrPas(p));
          SSX:=SX;
        End;
        If EY = i Then Begin
          StrPLCopy(P,Copy(Logs[i]+'                                                                                                         '
          ,SSX+1,100),EX+1-SSX);
          Canvas.TextOut(FontWidth*SSX, j, StrPas(p));
          StrPLCopy(P,Copy(Logs[i],EX+1,100)+'                                                                                    '
                                     ,100-EX);
          Canvas.Brush.Color := clWhite;
          Canvas.Font.Color := clBlack;
          Canvas.TextOut(FontWidth*EX, j, StrPas(p));
        End;

       J:=j+FontHeight+4;
      End;

          Canvas.Brush.Color := clWhite;
          Canvas.Font.Color := clBlack;

     End; // if Selected=False Else
    Canvas.TextOut(0, j,'                                                                                                    ');
  End;  // With PaintBox2
 StrDispose(P);


End;





procedure TCONSOLEWindow.MainTextPanelResize(Sender: TObject);
begin


     MainTextRePaint := True;


end;
procedure TCONSOLEWindow.MainTextPaint(Sender: TObject);
begin
     MainTextRePaint := True;
end;

procedure TCONSOLEWindow.BackTextPaint(Sender: TObject);
begin
    BackTextOut;
end;
procedure TCONSOLEWindow.BackTextScrollBarChange(Sender: TObject);
begin
     BackTextOut;
end;

procedure TCONSOLEWindow.BackTextMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    SelStartX:= X Div 8 ;
    SelStartY:=(Y Div (-BackText.Font.Height) + DrawStartPoint) ;
    BackTextSelected:=False;
    BackTextDragging:=True;

end;

procedure TCONSOLEWindow.BackTextMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin

  If BackTextDragging Then Begin

    SelEndX  := X Div 8;
    SelEndY  := Y Div (-BackText.Font.Height) + DrawStartPoint;

    If SelEndX<0 then SelEndX:=0;
    If (Y<0) then BackTextScrollBar.Position:=
      BackTextScrollBar.Position+Y Div (-BackText.Font.Height);
    If (DrawPoint<SelEndY) then BackTextScrollBar.Position:=
      BackTextScrollBar.Position+(SelEndY-DrawPoint);

    If Abs(SelEndX-SelStartX)+Abs(SelEndY-SelStartY)>0 then
      BackTextSelected:=True
    Else
     BackTextSelected:=False;

    BackTextOut;

  End;

end;

procedure TCONSOLEWindow.BackTextMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

    SelEndX  := X Div 8;
    SelEndY  := Y Div (-BackText.Font.Height) + DrawStartPoint;
    If SelEndX<0 then SelEndX:=0;
    BackTextDragging:=False;
    BackTextOut;

end;

procedure TCONSOLEWindow.BackTextPanelClick(Sender: TObject);
begin
    MainTextPanel.SetFocus;
end;


procedure TCONSOLEWindow.BackScrollButtonClick(Sender: TObject);
begin

     BackScroll(Not(_BackScroll));

end;

Function TCONSOLEWindow.GetSelBackText:String;
Var
  s:String;
  SY,SX,EX,EY,i :Integer;
Begin
     s:='';
     Result:='';
     If Not(BackTextSelected) then exit;
     SY:=SelStartY;
     SX:=SelStartX;
     EY:=SelEndY;
     EX:=SelEndX;

     If  EY<SY              Then Begin EY:=SY;SY:=SelEndY;EX:=SX;SX:=SelEndX;End;
     If (EY=SY) And (EX<SX) Then Begin EX:=SX;SX:=SelEndX;End;

     If EY>=Logs.Count then EY := Logs.Count-1;
      if (SY < 1) then Begin SY:=1;SX:=0;End;


     If Sy=Ey then S:=Copy(Logs[SY],SX+1,EX-SX+1)
     Else Begin
       S:=s+Copy(Logs[SY],SX+1,100)+#13#10;
       If EY-SY>1 then
        For i:=SY+1 to EY-1 Do
          S:=S+Logs[i]+#13#10;
       S:=s+Copy(Logs[EY],1,EX+1)+#13#10;
     End;
   Result:=S;
End;


procedure TCONSOLEWindow.FormResize(Sender: TObject);
begin

  If Height < BackTextPanel.Height+BackTextPanel.Top then
     BackTextPanel.Height := Height-BackTextPanel.Top - 16;

end;


procedure TCONSOLEWindow.SpeedButton3Click(Sender: TObject);
begin

  If ActiveControl=MainTextPanel Then Begin
     ClipBoard.AsText:=GetSelBackText;
  End Else
    (TEdit(Self.ActiveControl)).CopyToClipBoard;

end;

procedure TCONSOLEWindow.BackTextScrollBarEnter(Sender: TObject);
begin

   MainTextPanel.SetFocus;

end;

procedure TCONSOLEWindow.Edit1Change(Sender: TObject);
begin
  MainTextRepaint := True;
end;

end.
