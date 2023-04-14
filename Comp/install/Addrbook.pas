unit Addrbook;
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
  SysUtils, WinTypes, Messages, Classes, Graphics, Controls,
  Forms,ExtCtrls,StdCtrls;

type TAddressBookEntry=record
        LastName: string[40];
        FirstName: string[40];
        HomeMail: string[60];
        WorkMail: string[60];
        Nickname: string[20];
        Organization: string[60];
end;

type TAddressBookEntryPtr=^TAddressBookEntry;

type TAddressBookView=(abvCompact,abvExpanded);
type TAddressBookViewerSort=(absLastName,absFirstName,absEMail);

type TAddressBook=class(TComponent)
private
        FDirectory: string;
        FNumEntries,FDummyInt: integer;
        EntriesModified: Boolean;
        Entries: array[1..16000] of TAddressBookEntryPtr;
        FOnChange: TNotifyEvent;
        procedure SetDirectory(dir: string);
        function GetEntry(num: integer): TAddressBookEntry;
        procedure WriteEntries;
protected
        constructor Create(AOwner: TComponent);override;
        destructor Destroy;override;
public
        property Items[num: integer]: TAddressBookEntry read GetEntry;
        procedure AddEntry(entry: TAddressBookEntry);
        procedure DeleteEntry(number: integer);
        procedure ModifyEntry(number: integer; a: TAddressBookEntry);
        function FindEntry(firstname,lastname,address: string): integer;
published
        property Directory: string read FDirectory write SetDirectory;
        property NumEntries: integer read FNumEntries write FDummyInt;
        property OnChange: TNotifyEvent read FOnChange write FOnChange;
end;

type TAddressBookList=class(TListbox);

type TAddressBookViewer = class(TCustomControl)
private
        h,w,TabSelected: integer;
        TabsSwapped: Boolean;
        rings,tabs: TPaintBox;
        list: TAddressBookList;
        panel: TPanel;
        FView: TAddressBookView;
        FAddressBook: TAddressBook;
        FSortOrder: TAddressBookViewerSort;
        FFont: TFont;
        procedure RingsPaint(Sender: TObject);
        procedure TabsPaint(Sender: TObject);
        procedure TabsMouseDown(Sender: TObject; Button: TMouseButton;
           Shift: TShiftState; X, Y: Integer);
        procedure TabChanged(newtab: integer);
        procedure SetView(v: TAddressBookView);
        procedure SetAddressBook(a: TAddressBook);
        function GetAddressBook: TAddressBook;
        procedure ListDrawItem(Control: TWinControl; Index: Integer;
           R: TRect; State: TOwnerDrawState);
        procedure ListMouseDown(Sender: TObject; Button: TMouseButton;
           Shift: TShiftState; X, Y: Integer);
        procedure SetSortOrder(s: TAddressBookViewerSort);
        procedure SetFont(f: TFont);
        function GetIndex: integer;
protected
        constructor Create(AOwner: TComponent); override;
        destructor Destroy;override;
        procedure Paint;override;
        procedure Loaded;override;
public
        property ItemIndex: integer read GetIndex;
        procedure Update;
published
        property SelectedTab: integer read TabSelected write TabChanged;
        property View: TAddressBookView read FView write SetView;
        property AddressBook: TAddressBook read GetAddressBook write SetAddressBook;
        property SortOrder: TAddressBookViewerSort read FSortOrder write SetSortOrder;
        property Font: TFont read FFont write SetFont;
        property Align;
end;


implementation

{
======================= TAddressBookViewer component ====================
}

constructor TAddressBookViewer.Create(AOwner: TComponent);
begin
        inherited Create(AOwner);
        Width:=300;
        Height:=260;
        FFont:=TFont.Create;
        FFont.Name:='MS Sans Serif';
        FFont.Size:=8;
        FFont.Style:=[];
        panel:=TPanel.Create(self);
        panel.Parent:=self;
        panel.Align:=alClient;
        panel.BorderStyle:=bsSingle;
        panel.BevelOuter:=bvNone;
        rings:=TPaintBox.Create(self);
        rings.Parent:=panel;
        rings.Align:=alLeft;
        rings.Width:=25;
        rings.OnPaint:=RingsPaint;
        tabs:=TPaintBox.Create(self);
        tabs.Parent:=panel;
        tabs.Align:=alRight;
        tabs.Width:=42;
        tabs.OnPaint:=TabsPaint;
        tabs.OnMouseDown:=TabsMouseDown;
        list:=TAddressBookList.Create(self);
        list.Parent:=panel;
        list.Style:=lbOwnerDrawFixed;
        list.DragMode:=dmManual;
        list.OnMouseDown:=ListMouseDown;
        list.Top:=5;
        list.Left:=30;
        list.Sorted:=True;
        list.OnDrawItem:=ListDrawItem;
        list.ParentFont:=False;
        list.Font.Assign(FFont);
        TabSelected:=1;
end;

destructor TAddressBookViewer.Destroy;
begin
        rings.Destroy;
        tabs.Destroy;
        list.Destroy;
        panel.Destroy;
        FFont.Destroy;
        inherited Destroy;
end;

procedure TAddressBookViewer.Loaded;
begin
        SetFont(FFont);
end;

procedure TAddressBookViewer.SetFont(f: TFont);
begin
        FFont.Assign(f);
        List.Font.Assign(FFont);
        tabs.Font.Assign(FFont);
        SetView(FView);
end;

procedure TAddressBookViewer.RingsPaint(Sender: TObject);
var
        i,NumRings,y: integer;
begin
        with rings do
        begin
                Canvas.Brush.Color:=clGray;
                Canvas.Pen.Color:=clGray;
                Canvas.Rectangle(0,0,8,Height);
                Canvas.Brush.Color:=clLtGray;
                NumRings:=(rings.Height-10) div 10;
                for i:=0 to NumRings-1 do
                begin
                        Canvas.Pen.Color:=clBlack;
                        Canvas.Brush.Color:=clBlack;
                        y:=i*10+7;
                        Canvas.Rectangle(15,y,20,y+5);
                        Canvas.Pen.Color:=clGray;
                        Canvas.MoveTo(0,y+5);
                        Canvas.LineTo(17,y+4);
                        Canvas.MoveTo(0,y+4);
                        Canvas.LineTo(17,y+3);
                        Canvas.MoveTo(0,y+3);
                        Canvas.LineTo(17,y+2);
                        Canvas.Pen.Color:=clWhite;
                        Canvas.MoveTo(0,y+2);
                        Canvas.LineTo(17,y+1);
                end;
        end;
end;

procedure TAddressBookViewer.TabsPaint(Sender: TObject);
var
        i,x,y: integer;
        s: string[4];
        th,tw: integer;
        st,fl: integer;
        pts: array[1..4] of TPoint;
begin
        tabs.Canvas.Font.Assign(FFont);
        tabs.Canvas.Font.Style:=[];
        h:=tabs.Canvas.TextHeight('M')+6;
        w:=tabs.Canvas.TextWidth('M')+6;
        tabs.Width:=w*2+6;
        if TabSelected>13 then st:=TabSelected-13
        else st:=TabSelected;
        y:=0;
        x:=0;
        s[0]:=#1;
        tabs.Canvas.Pen.Color:=clBlack;
        tabs.Canvas.Brush.Color:=clLtGray;
        tabs.Canvas.MoveTo(x,0);
        tabs.Canvas.LineTo(x,tabs.Height);
        if TabSelected>13 then fl:=77
        else fl:=64;
        TabsSwapped:=(fl=77);
        pts[1].x:=x;
        pts[2].x:=x+w;
        pts[3].x:=x+w;
        pts[4].x:=x;
        for i:=1 to 13 do
        begin
                s[1]:=Char(fl+i);
                th:=tabs.Canvas.TextHeight(s);
                tw:=tabs.Canvas.TextWidth(s);
                tabs.Canvas.Pen.Color:=clBlack;
                if st=i then tabs.Canvas.Brush.Color:=clLtGray
                else tabs.Canvas.Brush.Color:=clWhite;
                pts[1].y:=y;
                pts[2].y:=y+2;
                pts[3].y:=y+h-2;
                pts[4].y:=y+h;
                tabs.Canvas.Polygon(pts);
                if st=i then
                begin
                        tabs.Canvas.Pen.Color:=clLtGray;
                        tabs.Canvas.MoveTo(x,y);
                        tabs.Canvas.LineTo(x,y+h);
                        tabs.Canvas.Font.Style:=[fsBold];
                end
                else tabs.Canvas.Font.Style:=[];
                tabs.Canvas.TextOut(x+(w-tw)div 2,y+(h-th) div 2,s);
                Inc(y,h);
        end;
        y:=3;
        x:=w+2;
        tabs.Canvas.MoveTo(x,0);
        tabs.Canvas.LineTo(x,tabs.Height);
        tabs.Canvas.Font.Style:=[];
        if TabSelected<14 then fl:=77
        else fl:=64;
        tabs.Canvas.Brush.Color:=clWhite;
        pts[1].x:=x;
        pts[2].x:=x+w;
        pts[3].x:=x+w;
        pts[4].x:=x;
        for i:=1 to 13 do
        begin
                s[1]:=Char(fl+i);
                th:=tabs.Canvas.TextHeight(s);
                tw:=tabs.Canvas.TextWidth(s);
                tabs.Canvas.Pen.Color:=clBlack;
                pts[1].y:=y;
                pts[2].y:=y+2;
                pts[3].y:=y+h-2;
                pts[4].y:=y+h;
                tabs.Canvas.Polygon(pts);
                tabs.Canvas.TextOut(x+(w-tw)div 2,y+(h-th) div 2,s);
                Inc(y,h);
        end;
end;

procedure TAddressBookViewer.TabsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
        if x>2*w+2 then Exit;
        if x<w then
        begin
                TabSelected:=y div h +1;
                if TabsSwapped then Inc(TabSelected,13);
        end
        else
        begin
                TabSelected:=(y-3) div h +1;
                if not TabsSwapped then Inc(TabSelected,13);
        end;
        Tabs.Repaint;
        Update;
end;

procedure TAddressBookViewer.TabChanged(newtab: integer);
begin
        TabSelected:=newtab;
        Tabs.Repaint;
        Update;
end;

procedure TAddressBookViewer.Paint;
begin
        tabs.Canvas.Font.Assign(FFont);
        tabs.Width:=2*(tabs.Canvas.TextWidth('M')+8);
        List.Width:=Width-rings.Width-tabs.Width-10;
        List.Height:=Height-10;
        inherited Paint;
end;

procedure TAddressBookViewer.SetView(v: TAddressBookView);
begin
        FView:=v;
        List.Canvas.Font.Assign(FFont);
        if v=abvCompact then List.ItemHeight:=List.Canvas.TextHeight('M')
        else List.ItemHeight:=4*List.Canvas.TextHeight('M')+2;
end;

procedure TAddressBookViewer.SetAddressBook(a: TAddressBook);
begin
        FAddressBook:=a;
        Update;
end;

function TAddressBookViewer.GetAddressBook: TAddressBook;
begin
        Result:=FAddressBook;
end;

procedure TAddressBookViewer.ListDrawItem(Control: TWinControl; Index: Integer;
  R: TRect; State: TOwnerDrawState);
var
        x,y: integer;
        s: string;
        i: integer;
begin
        if FAddressBook=nil then Exit;
        s:=List.Items[Index];
        i:=StrToInt(Copy(s,Pos('ª',s)+1,999));
        with List.Canvas do
        begin
                FillRect(R);
                x:=R.Left;
                y:=R.Top;
                if FView=abvCompact then
                begin
                        case FSortOrder of
                        absLastName,absFirstName:
                                begin
                                        if FSortOrder=absLastName then
                                           TextOut(x,y,FAddressBook.Items[i].LastName+', '+FAddressBook.Items[i].FirstName)
                                        else
                                           TextOut(x,y,FAddressBook.Items[i].FirstName+' '+FAddressBook.Items[i].LastName);
                                        if (FAddressBook.Items[i].HomeMail<>'') or (FAddressBook.Items[i].WorkMail<>'') then
                                        begin
                                                Inc(x,TextWidth(FAddressBook.Items[i].LastName+', '+
                                                    FAddressBook.Items[i].FirstName));
                                                TextOut(x,y,' (');
                                                Inc(x,TextWidth(' ('));
                                                if FAddressBook.Items[i].HomeMail<>'' then
                                                begin
                                                        TextOut(x,y,FAddressBook.Items[i].HomeMail);
                                                        Inc(x,TextWidth(FAddressBook.Items[i].HomeMail));
                                                        if FAddressBook.Items[i].WorkMail<>'' then
                                                        begin
                                                                TextOut(x,y,', ');
                                                                Inc(x,TextWidth(', '));
                                                        end;
                                                end;
                                                if FAddressBook.Items[i].WorkMail<>'' then
                                                   TextOut(x,y,FAddressBook.Items[i].WorkMail);
                                                Inc(x,TextWidth(FAddressBook.Items[i].WorkMail));
                                                TextOut(x,y,')');
                                        end;
                                end;
                        absEMail:
                                begin
                                        if (FAddressBook.Items[i].HomeMail<>'') or (FAddressBook.Items[i].WorkMail<>'') then
                                        begin
                                                if FAddressBook.Items[i].HomeMail<>'' then
                                                begin
                                                        TextOut(x,y,FAddressBook.Items[i].HomeMail);
                                                        Inc(x,TextWidth(FAddressBook.Items[i].HomeMail));
                                                        if FAddressBook.Items[i].WorkMail<>'' then
                                                        begin
                                                                TextOut(x,y,', ');
                                                                Inc(x,TextWidth(', '));
                                                        end;
                                                end;
                                                if FAddressBook.Items[i].WorkMail<>'' then
                                                   TextOut(x,y,FAddressBook.Items[i].WorkMail);
                                                Inc(x,TextWidth(FAddressBook.Items[i].WorkMail));
                                        end;
                                        TextOut(x,y,' ('+FAddressBook.Items[i].LastName+', '+
                                           FAddressBook.Items[i].FirstName+')');
                                end;
                        end;
                        Exit;
                end;
                Font.Style:=[fsBold];
                case FSortOrder of
                absLastName:
                        begin
                                TextOut(x,y,'Name: ');
                                Inc(x,TextWidth('Name: '));
                                Font.Style:=[];
                                TextOut(x,y,FAddressBook.Items[i].LastName+', '+FAddressBook.Items[i].FirstName);
                        end;
                absFirstName:
                        begin
                                TextOut(x,y,'Name: ');
                                Inc(x,TextWidth('Name: '));
                                Font.Style:=[];
                                TextOut(x,y,FAddressBook.Items[i].FirstName+' '+FAddressBook.Items[i].LastName);
                        end;
                absEMail:
                        begin
                                TextOut(x,y,'Address: ');
                                Inc(x,TextWidth('Address: '));
                                Font.Style:=[];
                                if FAddressBook.Items[i].HomeMail<>'' then
                                begin
                                        TextOut(x,y,FAddressBook.Items[i].HomeMail);
                                        Inc(x,TextWidth(FAddressBook.Items[i].HomeMail));
                                        if FAddressBook.Items[i].WorkMail<>'' then
                                        begin
                                                TextOut(x,y,', ');
                                                Inc(x,TextWidth(', '));
                                        end;
                                end;
                                if FAddressBook.Items[i].WorkMail<>'' then TextOut(x,y,FAddressBook.Items[i].WorkMail);
                        end;
                end;
                x:=0;
                Inc(y,TextHeight('M'));
                Font.Style:=[fsBold];
                case FSortOrder of
                absFirstName,absLastName:
                        begin
                                TextOut(x,y,'Organization: ');
                                Inc(x,TextWidth('Organization: '));
                                Font.Style:=[];
                                TextOut(x,y,FAddressBook.Items[i].Organization);
                        end;
                absEMail:
                        begin
                                TextOut(x,y,'Name: ');
                                Inc(x,TextWidth('Name: '));
                                Font.Style:=[];
                                TextOut(x,y,FAddressBook.Items[i].LastName+', '+FAddressBook.Items[i].FirstName);
                        end;
                end;
                x:=0;
                Inc(y,TextHeight('M'));
                Font.Style:=[fsBold];
                case FSortOrder of
                absFirstName,absLastName:
                        begin
                                TextOut(x,y,'Address: ');
                                Inc(x,TextWidth('Address: '));
                                Font.Style:=[];
                                if FAddressBook.Items[i].HomeMail<>'' then
                                begin
                                        TextOut(x,y,FAddressBook.Items[i].HomeMail);
                                        Inc(x,TextWidth(FAddressBook.Items[i].HomeMail));
                                        if FAddressBook.Items[i].WorkMail<>'' then
                                        begin
                                                TextOut(x,y,', ');
                                                Inc(x,TextWidth(', '));
                                        end;
                                end;
                                if FAddressBook.Items[i].WorkMail<>'' then TextOut(x,y,FAddressBook.Items[i].WorkMail);
                        end;
                absEMail:
                        begin
                                TextOut(x,y,'Organization: ');
                                Inc(x,TextWidth('Organization: '));
                                Font.Style:=[];
                                TextOut(x,y,FAddressBook.Items[i].Organization);
                        end;
                end;
                x:=0;
                Inc(y,TextHeight('M'));
                Font.Style:=[fsBold];
                TextOut(x,y,'Nickname: ');
                Inc(x,TextWidth('Nickname: '));
                Font.Style:=[];
                TextOut(x,y,FAddressBook.Items[i].Nickname);
                Inc(y,TextHeight('M'));
                MoveTo(0,y+1);
                LineTo(Width,y+1);
        end;
end;

function TAddressBookViewer.GetIndex: integer;
var
        i: integer;
        s: string;
begin
        if List.ItemIndex=-1 then Result:=-1
        else
        begin
                i:=List.ItemIndex;
                s:=List.Items[i];
                s:=Copy(s,Pos('ª',s)+1,999);
                Result:=StrToInt(s);
        end;
end;

{
Handles drag of item from address book listbox
}
procedure TAddressBookViewer.ListMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
        if (List.ItemIndex>=0) and (Button=mbLeft)then List.BeginDrag(False);
end;

procedure TAddressBookViewer.SetSortOrder(s: TAddressBookViewerSort);
begin
        FSortOrder:=s;
        Update;
end;

procedure TAddressBookViewer.Update;
var
        Target: char;
        Add: Boolean;
        i: integer;
        s,s2: string;
begin
        if FAddressBook=nil then Exit;
        List.Items.BeginUpdate;
        List.Items.Clear;
        Target:=Char(TabSelected+64);
        for i:=1 to FAddressBook.NumEntries do
        begin
                s2:=' ';
                case FSortOrder of
                absLastname:
                        s:=Uppercase(FAddressBook.Items[i].LastName);
                absFirstName:
                        s:=Uppercase(FAddressBook.Items[i].FirstName);
                absEMail:
                        begin
                                s:=Uppercase(FAddressBook.Items[i].HomeMail);
                                s2:=Uppercase(FAddressBook.Items[i].WorkMail);
                        end;
                end;
                Add:=(s[1]=Target) or (s2[1]=Target);
                if not Add then Continue;
                case FSortOrder of
                absLastName: List.Items.Add(Uppercase(FAddressBook.Items[i].LastName+' '+
                   FAddressBook.Items[i].FirstName)+'ª'+IntToStr(i));
                absFirstName: List.Items.Add(Uppercase(FAddressBook.Items[i].FirstName+' '+
                   FAddressBook.Items[i].LastName)+'ª'+IntToStr(i));
                absEMail: if s[1]=Target then List.Items.Add(Uppercase(FAddressBook.Items[i].HomeMail)+'ª'+IntToStr(i));
                            else List.Items.Add(Uppercase(FAddressBook.Items[i].WorkMail)+'ª'+IntToStr(i));
                end;
        end;
        List.Items.EndUpdate;
end;

{
========================== TAddressBook component =======================
}

constructor TAddressBook.Create(AOwner: TComponent);
begin
        inherited Create(AOwner);
        FNumEntries:=0;
        EntriesModified:=False;
end;

destructor TAddressBook.Destroy;
var
        i: integer;
begin
        if EntriesModified=True then WriteEntries;
        if FNumEntries<>0 then
        begin
                for i:=1 to FNumEntries do FreeMem(Entries[i],SizeOf(TAddressBookEntry));
        end;
        inherited Destroy;
end;

procedure TAddressBook.SetDirectory(dir: string);
var
        i: integer;
        f: File;
begin
        if dir='' then Exit;
        if EntriesModified then WriteEntries;
        if FNumEntries<>0 then
        begin
                for i:=1 to FNumEntries do FreeMem(Entries[i],SizeOf(TAddressBookEntry));
        end;
        FDirectory:=dir;
        if FDirectory[Length(FDirectory)]<>'\' then FDirectory:=FDirectory+'\';
        FNumEntries:=0;
        EntriesModified:=False;
        try
                AssignFile(f,FDirectory+'address.bk');
                Reset(f,Sizeof(TAddressBookEntry));
        except
                EntriesModified:=True;
                Exit;
        end;
        try
                while not Eof(f) do
                begin
                        Inc(FNumEntries);
                        GetMem(Entries[FNumEntries],Sizeof(TAddressBookEntry));
                        BlockRead(f,Entries[FNumEntries]^,1);
                end;
        except
                EntriesModified:=True;
        end;
        try
                CloseFile(f);
        except
                {}
        end;
        if Assigned(FOnChange) then FOnChange(self);
end;

procedure TAddressBook.WriteEntries;
var
        f: file;
        i: integer;
begin
        try
                AssignFile(f,FDirectory+'address.bk');
                Rewrite(f,Sizeof(TAddressBookEntry));
        except
                Exit;
        end;
        try
                for i:=1 to FNumEntries do BlockWrite(f,Entries[i]^,1);
        except
                {}
        end;
        try
                CloseFile(f);
        except
                {}
        end;
end;

function TAddressBook.GetEntry(num: integer): TAddressBookEntry;
begin
        if (num<1) or (num>FNumEntries) then raise ERangeError.Create('Index out of range')
        else Result:=Entries[num]^;
end;

procedure TAddressBook.AddEntry(entry: TAddressBookEntry);
begin
        if FNumEntries=16000 then raise ERangeError.Create('Index out of range')
        else
        begin
                Inc(FNumEntries);
                GetMem(Entries[FNumEntries],SizeOf(TAddressBookEntry));
                Entries[FNumEntries]^:=entry;
                EntriesModified:=True;
                if Assigned(FOnChange) then FOnChange(self);
        end;
end;

procedure TAddressBook.DeleteEntry(number: integer);
var
        i: integer;
begin
        if (number>FNumEntries) or (number<1) then ERangeError.Create('Index out of range')
        else
        begin
                FreeMem(Entries[number],SizeOf(TAddressBookEntry));
                for i:=number to FNumEntries-1 do Entries[i]:=Entries[i+1];
                Dec(FNumEntries);
                EntriesModified:=True;
        end;
end;

procedure TAddressBook.ModifyEntry(number: integer; a: TAddressBookEntry);
begin
        if (number>FNumEntries) or (number<1) then ERangeError.Create('Index out of range')
        else
        begin
                Entries[number]^:=a;
                EntriesModified:=True;
        end;
end;


function TAddressBook.FindEntry(firstname,lastname,address: string): integer;
var
        i: integer;
begin
        for i:=1 to FNumEntries do
        begin
                if (Lowercase(Entries[i]^.FirstName)=Lowercase(firstname))
                and (Lowercase(Entries[i]^.LastName)=Lowercase(lastname))
                and ((Lowercase(Entries[i]^.HomeMail)=Lowercase(address)) or
                     (Lowercase(Entries[i]^.WorkMail)=Lowercase(address))) then
                begin
                        Result:=i;
                        Exit;
                end;
        end;
        Result:=0;
end;

{=======================================================================}

end.
