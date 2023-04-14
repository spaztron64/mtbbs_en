unit Strngvwr;
{
Copyright (©) 1997  Tony BenBrahim
This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Library General Public License as published by the Free
Software Foundation
This library is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Library General Public License for more details.
You should have received a copy of the GNU Library General Public License along
with this library; if not, write to the:

Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA  02111-1307, USA.
}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs,ExtCtrls,StdCtrls,Menus;

type TSVStrings=class(TStringList)
public
        StringsChanged: TNotifyEvent;
        procedure LoadFromFile(f: string);
        procedure Add(s: string);
        procedure Delete(n: integer);
        procedure Insert(n: integer;s: string);
        procedure Clear;
        procedure AddStrings(s: TStrings);
        procedure SetText(c: PChar);
        procedure Assign(s: TStrings);
end;

type TSVCanvas=class(TGraphicControl)
private
        FOnPaint: TNotifyEvent;
protected
        procedure Paint;override;
published
        property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
end;

type TSVLink=Record
        Link:   string;
        X0,X1,Y0,Y1: integer;
end;

type TSVLinkPtr=^TSVLink;

type TSVLinkEvent=procedure(Sender: TObject; Link: string) of object;

type TStringsViewer=class(TCustomControl)
private
        fdx,fdy: integer;
        FLines: TSVStrings;
        FFont: TFont;
        FColor: TColor;
        VScrollBar,HScrollBar: TScrollBar;
        Graphic: TSVCanvas;
        Panel: TPanel;
        CanMark,Marking,Marked: Boolean;
        MkL0,Mkc0,MkL1,Mkc1: integer;
        FOnChange,FOnClick,FOnDblClick: TNotifyEvent;
        FOnMouseDown,FOnMouseUp: TMouseEvent;
        FOnMouseMove: TMouseMoveEvent;
        FonKeyDown,FOnKeyUp: TKeyEvent;
        FOnKeyPress: TKeyPressEvent;
        FOnLink: TSVLinkEvent;
        Links: array[1..1000] of TSVLinkPtr;
        NumLinks: integer;
        procedure SetLines(l: TSVStrings);
        procedure SetColor(c: TColor);
        procedure SetFont(f: TFont);
        procedure PaintCanvas(Sender: TObject);
        procedure VScrollBarClick(Sender: TObject; ScrollCode: TScrollCode;
           var ScrollPos: Integer);
        procedure HScrollBarEnter(Sender: Tobject);
        procedure StringsChanged(Sender: TObject);
        procedure GraphicMouseDown(Sender: TObject; Button: TMouseButton;
           Shift: TShiftState; X, Y: Integer);
        procedure GraphicMouseUp(Sender: TObject; Button: TMouseButton;
           Shift: TShiftState; X, Y: Integer);
        procedure GraphicMouseMove(Sender: TObject;Shift: TShiftState;
           X, Y: Integer);
        procedure KeyPressed(Sender: TObject;var Key: char);
        procedure Clicked(Sender: TObject);
        procedure DblClicked(Sender: TObject);
        procedure KeyDown(Sender: TObject;var Key: word;Shift: TShiftState);
        procedure KeyUp(Sender: TObject;var Key: word;Shift: TShiftState);
protected
        constructor Create(AOwner: TComponent);override;
        destructor Destroy;override;
        procedure Loaded;override;
        procedure Paint;override;
public
        Modified: Boolean;
        procedure CopyToClipboard;
        procedure CutToClipboard;
        procedure Clear;
        procedure SelectAll;
published
        property Align;
        property Color: TColor read FColor write SetColor;
        property Font: TFont read FFont write SetFont;
        property HelpContext;
        property Hint;
        property Lines: TSVStrings read FLines write SetLines;
        property PopupMenu;
        property ShowHint;
        property TabOrder;
        property TabStop;
        property OnChange: TNotifyEvent read FOnChange write FOnChange;
        property OnClick: TNotifyEvent read FOnClick write FOnClick;
        property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
        property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
        property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
        property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
        property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
        property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
        property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
        property OnEnter;
        property OnExit;
        property OnDragDrop;
        property OnDragOver;
        property OnEndDrag;
        property OnLinkClicked: TSVLinkEvent read FOnLink write FOnLink;
end;

implementation

uses ClipBrd;

procedure TSVStrings.LoadFromFile(f: string);
begin
        inherited LoadFromFile(f);
        if Assigned(StringsChanged) then StringsChanged(self);
end;

procedure TSVStrings.Add(s: string);
begin
        inherited Add(s);
        if Assigned(StringsChanged) then StringsChanged(self);
end;

procedure TSVStrings.Delete(n: integer);
begin
        inherited Delete(n);
        if Assigned(StringsChanged) then StringsChanged(self);
end;

procedure TSVStrings.Insert(n: integer;s: string);
begin
        inherited Insert(n,s);
        if Assigned(StringsChanged) then StringsChanged(self);
end;

procedure TSVStrings.Clear;
begin
        inherited Clear;
        if Assigned(StringsChanged) then StringsChanged(self);
end;

procedure TSVStrings.AddStrings(s: TStrings);
begin
        inherited AddStrings(s);
        if Assigned(StringsChanged) then StringsChanged(self);
end;

procedure TSVStrings.SetText(c: PChar);
begin
        inherited SetText(c);
        if Assigned(StringsChanged) then StringsChanged(self);
end;

procedure TSVStrings.Assign(s: TStrings);
begin
        inherited Assign(s);
        if Assigned(StringsChanged) then StringsChanged(self);
end;

procedure TSVCanvas.Paint;
begin
        if Assigned(FOnPaint) then FOnPaint(self);
end;

constructor TStringsViewer.Create(AOwner: TComponent);
begin
        inherited Create(AOwner);
        FFont:=TFont.Create;
        FColor:=clWindow;
        Width:=100;
        Height:=50;
        VScrollBar:=TScrollBar.Create(self);
        VScrollBar.Kind:=sbVertical;
        VScrollBar.Top:=1;
        VScrollBar.Parent:=self;
        VScrollBar.OnScroll:=VScrollBarClick;
        VScrollBar.OnKeyPress:=KeyPressed;
        VScrollBar.OnKeyDown:=KeyDown;
        VScrollBar.OnKeyUp:=KeyUp;
        HScrollBar:=TScrollBar.Create(self);
        HScrollBar.Kind:=sbHorizontal;
        HScrollBar.Left:=1;
        HScrollBar.Parent:=self;
        HScrollBar.OnScroll:=VScrollBarClick;
        HScrollBar.OnEnter:=HScrollBarEnter;
        Panel:=TPanel.Create(self);
        Panel.Parent:=self;
        Panel.BevelOuter:=bvNone;
        Graphic:=TSVCanvas.Create(self);
        Graphic.Parent:=Panel;
        Graphic.Align:=alClient;
        Graphic.OnPaint:=PaintCanvas;
        Graphic.OnMouseDown:=GraphicMouseDown;
        Graphic.OnMouseUp:=GraphicMouseUp;
        Graphic.OnMouseMove:=GraphicMouseMove;
        Graphic.OnClick:=Clicked;
        Graphic.OnDblClick:=DblClicked;
        FLines:=TSVStrings.Create;
        FLines.StringsChanged:=StringsChanged;
        CanMark:=False;
        Modified:=False;
        NumLinks:=0;
        fdy:=1;
        fdx:=1;
end;

destructor TStringsViewer.Destroy;
var
        i: integer;
begin
        for i:=1 to NumLinks do FreeMem(Links[i],Sizeof(TSVLink));
        FLines.Destroy;
        VScrollBar.Destroy;
        HScrollBar.Destroy;
        FFont.Destroy;
        Graphic.Destroy;
        Panel.Destroy;
        inherited Destroy;
end;

procedure TStringsViewer.Loaded;
begin
        inherited Loaded;
        SetFont(FFont);
        SetColor(FColor);
end;

procedure TStringsViewer.SetColor(c: TColor);
begin
        FColor:=c;
        Panel.Color:=c;
        Invalidate;
end;

procedure TStringsViewer.SetFont(f: TFont);
begin
        FFont.Assign(f);
        FFont.Pitch:=fpFixed;
        Graphic.Canvas.Font.Assign(FFont);
        fdy:=Graphic.Canvas.TextHeight('M');
        fdx:=Graphic.Canvas.TextWidth('M');
        Invalidate;
end;

procedure TStringsViewer.SetLines(l: TSVStrings);
begin
        FLines.Assign(l);
        HScrollBar.Position:=0;
        VScrollBar.Position:=0;
        Invalidate;
end;

procedure TStringsViewer.StringsChanged(Sender: TObject);
begin
        VScrollBar.Max:=FLines.Count;
        Modified:=True;
        Graphic.Invalidate;
        if Assigned(FOnChange) then FOnChange(self);
end;

procedure TStringsViewer.Paint;
begin
        VScrollBar.Left:=Width-VScrollBar.Width-1;
        VScrollBar.Height:=Height-HScrollBar.Height-1;
        HScrollBar.Top:=VScrollBar.Height;
        HScrollBar.Width:=VScrollBar.Left;
        Panel.SetBounds(0,0,VScrollBar.Left-1,VScrollBar.Height-1);
        VScrollBar.LargeChange:=Graphic.Height div fdy;
        VScrollBar.SmallChange:=1;
        HScrollBar.LargeChange:=Graphic.Width div fdx;
        HScrollBar.SmallChange:=1;
        HScrollBar.Refresh;
        VScrollBar.Refresh;
        inherited Paint;
end;

procedure TStringsViewer.PaintCanvas(Sender: TObject);
var
        line,x,y,z,maxl,tx,t: integer;
        i,j: integer;
        ocb,ocf: TColor;
        ofs: TFontStyles;
        ps,s: string;
        Switched: Boolean;
begin
        for i:=1 to NumLinks do FreeMem(Links[i],Sizeof(TSVLink));
        NumLinks:=0;
        if (MkL1<MkL0) or ((MkL1=MkL0) and (Mkc1<Mkc0)) then
        begin
                t:=MkL0;
                MkL0:=MkL1;
                MkL1:=t;
                t:=Mkc0;
                Mkc0:=Mkc1;
                Mkc1:=t;
                Switched:=True;
        end
        else Switched:=False;
        with Graphic.Canvas do
        begin
                Font.Assign(FFont);
                Brush.Color:=FColor;
                Line:=VScrollBar.Position;
                y:=0;
                z:=0;
                x:=-HScrollBar.Position*fdx;
                maxl:=0;
                while (Line<FLines.Count) and (y<Graphic.Height) do
                begin
                        s:=Lines[Line];
                        if not (CanMark or Marked) then TabbedTextOut(Graphic.Canvas.Handle,x,y,@s[1],Length(s),0,z,0)
                        else
                        begin
                                if (Line<MkL0) or (Line>MkL1) then
                                   TabbedTextOut(Graphic.Canvas.Handle,x,y,@s[1],Length(s),0,z,0);
                                tx:=x;
                                if Line=MkL0 then
                                begin
                                        if MkL1=Line then
                                        begin
                                                ps:=Copy(s,1,Mkc0-1);
                                                TabbedTextOut(Graphic.Canvas.Handle,tx,y,@ps[1],Length(ps),0,z,0);
                                                Inc(tx,LOWORD(GetTabbedTextExtent(Graphic.Canvas.Handle,@ps[1],
                                                  Length(ps),0,z)));
                                                ocb:=Brush.Color;
                                                ocf:=Font.Color;
                                                Brush.Color:=clHighlight;
                                                Font.Color:=clHighlightText;
                                                ps:=Copy(s,Mkc0,Mkc1-Mkc0);
                                                TabbedTextOut(Graphic.Canvas.Handle,tx,y,@ps[1],Length(ps),0,z,0);
                                                Inc(tx,LOWORD(GetTabbedTextExtent(Graphic.Canvas.Handle,@ps[1],
                                                  Length(ps),0,z)));
                                                Brush.Color:=ocb;
                                                Font.Color:=ocf;
                                                ps:=Copy(s,Mkc1,999);
                                                TabbedTextOut(Graphic.Canvas.Handle,tx,y,@ps[1],Length(ps),0,z,0);
                                        end
                                        else
                                        begin
                                                ps:=Copy(s,1,Mkc0-1);
                                                TabbedTextOut(Graphic.Canvas.Handle,tx,y,@ps[1],Length(ps),0,z,0);
                                                Inc(tx,LOWORD(GetTabbedTextExtent(Graphic.Canvas.Handle,@ps[1],
                                                  Length(ps),0,z)));
                                                ocb:=Brush.Color;
                                                ocf:=Font.Color;
                                                Brush.Color:=clHighlight;
                                                Font.Color:=clHighlightText;
                                                ps:=Copy(s,Mkc0,999);
                                                TabbedTextOut(Graphic.Canvas.Handle,tx,y,@ps[1],Length(ps),0,z,0);
                                                Brush.Color:=ocb;
                                                Font.Color:=ocf;
                                        end;
                                end;
                                if (Line>MkL0) and (Line<MkL1) then
                                begin
                                        ocb:=Brush.Color;
                                        ocf:=Font.Color;
                                        Brush.Color:=clHighlight;
                                        Font.Color:=clHighlightText;
                                        TabbedTextOut(Graphic.Canvas.Handle,tx,y,@s[1],Length(s),0,z,0);
                                        Brush.Color:=ocb;
                                        Font.Color:=ocf;
                                end;
                                if ((Line=MkL1) and (Line<>MkL0)) then
                                begin
                                        ocb:=Brush.Color;
                                        ocf:=Font.Color;
                                        Brush.Color:=clHighlight;
                                        Font.Color:=clHighlightText;
                                        ps:=Copy(s,1,Mkc1);
                                        TabbedTextOut(Graphic.Canvas.Handle,tx,y,@ps[1],Length(ps),0,z,0);
                                        Inc(tx,LOWORD(GetTabbedTextExtent(Graphic.Canvas.Handle,@ps[1],Length(ps),0,z)));
                                        Brush.Color:=ocb;
                                        Font.Color:=ocf;
                                        ps:=Copy(s,Mkc1+1,999);
                                        TabbedTextOut(Graphic.Canvas.Handle,tx,y,@ps[1],Length(ps),0,z,0);
                                end;
                        end;
                        {draw link}
                        s:=Lines[Line];
                        tx:=x;
                        while Pos('http://',s)<>0 do
                        begin
                                i:=Pos('http://',s);
                                ps:=Copy(s,1,i-1);
                                Inc(tx,LOWORD(GetTabbedTextExtent(Graphic.Canvas.Handle,@ps[1],Length(ps),0,z)));
                                Delete(s,1,i-1);
                                i:=Pos(' ',s);
                                j:=Pos(#9,s);
                                if (j<>0) and ((j<i) or(i=0))  then i:=j;
                                if i=0 then i:=Length(s)+1;
                                ps:=Copy(s,1,i-1);
                                ocb:=Font.Color;
                                Font.color:=clBlue;
                                ofs:=Font.Style;
                                Font.Style:=[fsUnderline];
                                TextOut(tx,y,ps);
                                Inc(NumLinks);
                                GetMem(Links[NumLinks],Sizeof(TSVLink));
                                Links[NumLinks]^.Link:=ps;
                                Links[NumLinks]^.X0:=tx;
                                Links[NumLinks]^.Y0:=y;
                                Inc(tx,TextWidth(ps));
                                Links[NumLinks]^.X1:=tx;
                                Links[NumLinks]^.Y1:=y+fdy;
                                Font.Color:=ocb;
                                Font.Style:=ofs;
                                Delete(s,1,i-1);
                        end;
                        if Length(s)>maxl then maxl:=Length(s);
                        Inc(y,fdy);
                        Inc(Line);
                end;
                HScrollBar.Max:=maxl;
        end;
        if Switched then
        begin
                t:=MkL0;
                MkL0:=MkL1;
                MkL1:=t;
                t:=Mkc0;
                Mkc0:=Mkc1;
                Mkc1:=t;
        end;
end;

procedure TStringsViewer.VScrollBarClick(Sender: TObject; ScrollCode: TScrollCode; var
ScrollPos: Integer);
begin
        Graphic.Invalidate;
end;

procedure TStringsViewer.GraphicMouseDown(Sender: TObject; Button: TMouseButton;
           Shift: TShiftState; X, Y: Integer);
var
        i: integer;
        ct: TColor;
begin
        for i:=1 to NumLinks do
        begin
                if (X>=Links[i]^.X0) then
                        if (X<=Links[i]^.X1) then
                                if (Y>=Links[i]^.Y0) then
                                        if (Y<=Links[i]^.Y1) then
                                                if Assigned(FOnLink) then
                                                begin
                                                        ct:=Graphic.Canvas.Font.Color;
                                                        Graphic.Canvas.Font.Color:=clRed;
                                                        Graphic.Canvas.TextOut(Links[i]^.X0,Links[i]^.Y0,Links[i]^.Link);
                                                        Graphic.Canvas.Font.Color:=ct;
                                                        FOnLink(self,Links[i]^.Link);
                                                end;
        end;
        CanMark:=True;
        Marked:=False;
        MkL0:=VScrollBar.Position+Y div fdy;
        Mkc0:=HScrollBar.Position+X div fdx+1;
        MkL1:=MkL0;
        Mkc1:=Mkc0;
        PaintCanvas(self);
        if Assigned(FOnMouseDown) then FOnMouseDown(self,Button,Shift,X,Y);
end;

procedure TStringsViewer.GraphicMouseUp(Sender: TObject; Button: TMouseButton;
           Shift: TShiftState; X, Y: Integer);
begin
        if CanMark then Marked:=True;
        CanMark:=False;
        if Assigned(FOnMouseUp) then FOnMouseUp(self,Button,Shift,X,Y);
end;

procedure TStringsViewer.GraphicMouseMove(Sender: TObject;Shift: TShiftState;
           X, Y: Integer);
var
        t: integer;
begin
        if CanMark then
        begin
                MkL1:=VScrollBar.Position+Y div fdy;
                Mkc1:=HScrollBar.Position+X div fdx+1;
                PaintCanvas(self);
        end;
        if Assigned(FOnMouseMove) then FOnMouseMove(self,Shift,X,Y);
end;

procedure TStringsViewer.HScrollBarEnter(Sender: Tobject);
begin
        VScrollBar.SetFocus;
end;

procedure TStringsViewer.KeyPressed(Sender: TObject;var Key: char);
begin
        case Key of
        #1: {CTRL+A}
                begin
                        SelectAll;
                end;
        #27: {ESC}
                begin
                        Marked:=False;
                        PaintCanvas(self);
                end;
        #3,#24: {CTRL+C,CTRL+X}
                begin
                        CopyToClipboard;
                end;
        else
                begin
                ;
                end;
        end;
        if Assigned(FOnKeyPress) then FOnKeyPress(self,Key);
end;

procedure TStringsViewer.CutToClipboard;
begin
        CopyToClipboard;
end;

procedure TStringsViewer.CopyToClipboard;
var
        l: TStrings;
        Switched: Boolean;
        i,t: integer;
        s: string;
        c: PChar;
begin
        if not Marked then Exit;
        l:=TStringList.Create;
        if MkL1>=Lines.Count then MkL1:=Lines.Count-1;
        if MkL0>=Lines.Count then MkL0:=Lines.Count-1;
        if (MkL1<MkL0) or ((MkL1=MkL0) and (Mkc1<Mkc0)) then
        begin
                t:=MkL0;
                MkL0:=MkL1;
                MkL1:=t;
                t:=Mkc0;
                Mkc0:=Mkc1;
                Mkc1:=t;
                Switched:=True;
        end
        else Switched:=False;
        s:=Lines[MkL0];
        if MkL0=MkL1 then l.Add(Copy(s,Mkc0,Mkc1-Mkc0-1))
        else
        begin
                l.Add(Copy(s,Mkc0,999));
                for i:=MkL0+1 to MkL1-1 do l.Add(Lines[i]);
                s:=Lines[MkL1];
                l.Add(Copy(s,1,Mkc1));
        end;
        if StrLen(l.GetText)<31000 then Clipboard.SetTextBuf(l.GetText)
        else
        begin
                GetMem(c,31000);
                StrLCopy(c,l.GetText,30999);
                c[30999]:=#0;
                Clipboard.SetTextBuf(c);
                FreeMem(c,31000);
        end;
        if Switched then
        begin
                t:=MkL0;
                MkL0:=MkL1;
                MkL1:=t;
                t:=Mkc0;
                Mkc0:=Mkc1;
                Mkc1:=t;
        end;
        l.Destroy;
end;

procedure TStringsViewer.Clear;
begin
        Lines.Clear;
        HScrollBar.Position:=0;
        VScrollBar.Position:=0;
end;

procedure TStringsViewer.SelectAll;
begin
        MKL0:=0;
        MKL1:=Lines.Count-1;
        MKc0:=0;
        MKc1:=999;
        Marked:=True;
        PaintCanvas(Self);
end;

procedure TStringsViewer.Clicked(Sender: TObject);
begin
        if Assigned(FOnClick) then FOnClick(self);
end;

procedure TStringsViewer.DblClicked(Sender: TObject);
begin
        if Assigned(FOnDblClick) then FOnDblClick(self);
end;

procedure TStringsViewer.KeyDown(Sender: TObject;var Key: word;Shift: TShiftState);
begin
        if Assigned(FOnKeyDown) then FOnKeyDown(self,Key,Shift);
end;

procedure TStringsViewer.KeyUp(Sender: TObject;var Key: word;Shift: TShiftState);
begin
        if Assigned(FOnKeyUp) then FOnKeyUp(self,Key,Shift);
end;

end.
