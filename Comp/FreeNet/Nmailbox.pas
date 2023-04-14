unit NMailBox;
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
  Forms,StdCtrls,ExtCtrls;

const WM_MBNOTIFY=WM_USER+1;

type TMailboxNotification=(mnAdd,mnDelete,mnFlag,mnClearAll,mnDeleteMailbox,mnDestroying);

type TNMailBoxError=(NoError,AlreadyExists,InvalidDirectory,FileError,
                    InvalidNMailBox);
{$IFDEF WIN32}
{$A-}
{$ENDIF}
type NMailBoxIndex=record
        FromName,ToName: string[80];
        Subject,Date: string[40];
        Size,Lines,Start: LongInt;
        FirstAtt,LastAtt: LongInt;
        {$IFDEF WIN32}
        Part: SmallInt;
        Flag: Char;
                {$ENDIF}
end;


type TMailboxViewerControl=class(TWinControl)
protected
        procedure Notify(Event: TMailboxNotification; Item: integer);virtual;
end;

type MBName=string[8];

type TMBVNotifications=record
        Control: TMailboxViewerControl;
        MailboxName: MBName;
end;

type
  TNMailBox = class(TComponent)
  private
        FDirectory:                     string;
        FMailBoxes:                     TStrings;
        FMail:                          TStrings;
        CMBName:                        string;
        CMBNum:                         integer;
        FFrom,Fto,FSub:                 string;
        FLines,Fsize,DumLint:           LongInt;
        FMBSize,FMBtrsize:               LongInt;
        FMsgNum,FMsgCnt,DumInt:         integer;
        FDate:                          string;
        FPart:                          integer;
        FFlag:                          char;
        a1,a2:                          LongInt;
        {Notifications}
        Notifications: array[1..256] of TMBVNotifications;
        procedure Notify(MB: MBName;Event: TMailboxNotification;Item: integer);
        {End Notifications}
        procedure SetDirectory(directory: string);
        procedure SetMailBoxes(s: TStrings);
        procedure SetMail(s: TStrings);
        procedure SetCMBNumber(number: integer);
        procedure SetCMBName(name: string);
        procedure SetMsgNum(n: integer);
        procedure InitIndex;
  protected
        constructor Create(Parent: TComponent); override;
        destructor Destroy;override;
  public
        procedure CreateMailBox(name: string);
        procedure AddMail;
        procedure LoadMail;
        procedure DeleteMail;
        procedure TransferTo(name: string);
        procedure Compress;
        procedure EmptyMailbox(num: integer);
        procedure UpdateFlag(c: char);
        function MailboxFile(i: integer): string;
        function MailboxName(i: integer): string;
        {notification functions. use at your own risk, intended for
        NMailboxViewer component}
        function RegisterNotify(Control: TMailboxViewerControl;MailboxName: MBName): Boolean;
        procedure UnregisterNotify(Control: TMailboxViewerControl);
  published
        property MailBoxDirectory: string read FDirectory write SetDirectory;
        property MailBoxes: TStrings read FMailBoxes write SetMailBoxes;
        property CurrentMailBoxName: string read CMBName write SetCMBName;
        property CurrentMailBoxNumber: integer read CMBNum write SetCMBNumber;
        property CurrentMailBoxMessages: integer read FMsgCnt write DumInt;
        property CurrentNMailBoxSize: Longint read FMBSize write DumLInt;
        property CurrentNMailBoxTrash: Longint read FMBtrsize write DumLint;
        property Msg_Text: TStrings read FMail write SetMail;
        property Msg_From: string read FFrom write FFrom;
        property Msg_Date: string read FDate write FDate;
        property Msg_To: string read FTo write FTo;
        property Msg_Subject: string read FSub write FSub;
        property Msg_Lines: LongInt read FLines write DumLInt;
        property Msg_Size: LongInt read FSize write DumLInt;
        property Msg_Number: integer read FMsgNum write SetMsgNum;
        property Msg_Part: integer read FPart write FPart;
        property Msg_Flag: char read FFlag write FFlag;
        property Msg_AttachStart: LongInt read a1 write a1;
        property Msg_AttachEnd: LongInt read a2 write a2;
end;

const
        MBV_PARENT      =       WM_USER+1;
        MBV_SETMESSAGE  =       WM_USER+2;
        MBV_CLOSE       =       WM_USER+3;
        MBV_UPDATEINFO  =       WM_USER+4;

type EInvalidForm=class(Exception);

type TFormClass=class of TForm;

type TMailboxViewerRecord=record
        Name: String[60];
        Subject: String[80];
        Date: String[40];
        Size: LongInt;
        Flag: Char;
        Attachments: Boolean;
end;

type TViewerInfo=record
        Handle: THandle;
        MessageNumber: integer;
end;

type TMailboxViewerRecordPtr=^TMailboxViewerRecord;

type TMBCustomListBox=class(TCustomListbox)
public
        SW: array[1..5] of integer;
        ABM,UBM,QBM,VBM,SBM: TBitmap;
        DragEnabled,DropEnabled: Boolean;
protected
        constructor Create(AOwner: TComponent);override;
        destructor Destroy;override;
        procedure DrawItem(Idx: Integer; R: TRect; State: TOwnerDrawState);override;
private
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
        procedure DragOver(Sender, Source: TObject; X, Y: Integer;State: TDragState; var Accept: Boolean);
        procedure DragDrop(Sender, Source: TObject; X, Y: Integer);
        procedure EndDrag(Sender, Target: TObject; X, Y: Integer);
end;

type TMBHeader=class(THeader)
protected
        constructor Create(AOwner: TComponent);override;
        destructor Destroy;override;
published
        property OnMouseDown;
        property OnMouseUp;
end;

type TMBClickEvent=procedure(Sender: TObject;MessageNumber: integer) of object;

type NMailboxViewer = class(TMailboxViewerControl)
private
        Index: array[1..10000] of integer;
        Messages: array[1..10000] of TMailboxViewerRecordPtr;
        Viewers: array[1..256] of TViewerInfo;
        FOnClick,FOnDblCLick: TMBClickEvent;
        FOnChange: TNotifyEvent;
        Header: TMBHeader;
        ListBox: TMBCustomListBox;
        FFont: TFont;
        MBNum: integer;
        MB: TNMailbox;
        DDEnabled: Boolean;
        Initialized: Boolean;
        SX,SY: integer;
        MinW: array[1..5] of integer;
        CMBName: MBName;
        FNumMessages: integer;
        FNewTop: Boolean;
        WMgr: Boolean;
        VFClass: TFormClass;
        FMain: TForm;
        procedure SetFont(f: TFont);
        procedure SetSections(s: TStrings);
        function GetSections: TStrings;
        procedure HeaderSized(Sender: TObject;s,x:integer);
        procedure SetMBNum(n: integer);
        procedure HMouseDown(Sender:TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure HMouseUp(Sender:TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
        procedure SetUBM(b: TBitmap);
        procedure SetABM(b: TBitmap);
        procedure SetQBM(b: TBitmap);
        procedure SetVBM(b: TBitmap);
        procedure SetSBM(b: TBitmap);
        function GetUBM: TBitmap;
        function GetABM: TBitmap;
        function GetQBM: TBitmap;
        function GetVBM: TBitmap;
        function GetSBM: TBitmap;
        procedure SetIndex(i: integer);
        function GetIndex: integer;
        procedure ListboxDblClick(Sender: TObject);
        procedure ListboxClick(Sender: TObject);
        function GetSelected(Index: integer):Boolean;
        function GetDropEnabled: Boolean;
        function GetDragEnabled: Boolean;
        procedure SetDragEnabled(s: Boolean);
        procedure SetDropEnabled(s: Boolean);
        procedure Refresh;
        procedure SetMB(mbx: TNMailbox);
        procedure SetNewTop(b: Boolean);
        function FindFormWithMessage(msg: integer): THandle;
protected
        constructor Create(AOwner: TComponent);override;
        destructor Destroy;override;
        procedure Loaded;override;
        procedure Notify(Event: TMailboxNotification; Item: integer);override;
        procedure LoadItems;
public
        procedure SetHeaderSize(x,s: integer);
        function IndexToMessageNumber(n: integer): integer;
        procedure EnableMessageViewerManager(MessageViewerFormClass: TFormClass);
        procedure ViewSelectedMessages;
        procedure NextMessage(h: Thandle);
        procedure PreviousMessage(h: THandle);
        procedure TransferSelectedMessages(TargetMailboxNumber: integer);
        procedure DeleteSelectedMessages;
        property NumMessages: integer read FNumMessages;
        property Selected[Index: Integer]: Boolean read GetSelected;
published
        property Font: TFont read FFont write SetFont;
        property Mailbox: TNMailbox read MB write SetMB;
        property SectionNames: TStrings read GetSections write SetSections;
        property MailboxNumber: Integer read MBNum write SetMBNum;
        property AttachmentBitmap: TBitmap read GetABM write SetABM;
        property UnreadBitmap: TBitmap read GetUBM write SetUBM;
        property ReadBitmap: TBitmap read GetVBM write SetVBM;
        property RepliedBitmap: TBitmap read GetSBM write SetSBM;
        property QueuedBitmap: TBitmap read GetQBM write SetQBM;
        property Align;
        property OnChange: TNotifyEvent read FOnChange write FOnChange;
        property OnMessageDoubleClick: TMBClickEvent read FOnDblClick write FOnDblClick;
        property OnMessageClick: TMBClickEvent read FOnClick write FOnClick;
        property ItemIndex: integer read GetIndex write SetIndex;
        property DragEnabled: Boolean read GetDragEnabled write SetDragEnabled;
        property DropEnabled: Boolean read GetDropEnabled write SetDropEnabled;
        property NewMessageTop: Boolean read FNewTop write SetNewTop;
end;

implementation

uses FileCtrl;


constructor TNMailBox.Create(Parent: TComponent);
var
        i: integer;
begin
        inherited Create(Parent);
        FMailBoxes:=TStringList.Create;
        FMail:=TStringList.Create;
        for i:=1 to 256 do Notifications[i].Control:=nil;
end;

destructor TNMailBox.Destroy;
var
        i: integer;
begin
        for i:=1 to 256 do
        begin
                if Notifications[i].Control<>nil then
                   Notifications[i].Control.Notify(mnDestroying,0);
        end;
        FMailBoxes.Free;
        FMail.Free;
        inherited Destroy;
end;

procedure TNMailBox.SetMailBoxes(s: TStrings);
begin
        FMailBoxes.Assign(s);
end;

procedure TNMailBox.SetMail(s: TStrings);
begin
        FMail.Assign(s);
end;

procedure TNMailBox.SetDirectory(directory: string);
var
        i: integer;
begin
        if directory='' then Exit;
        if directory[Length(directory)]<>'\' then directory:=directory+'\';
        FDirectory:=directory;
        ForceDirectories(FDirectory);
        for i:=1 to Mailboxes.Count do
        begin
                if not FileExists(FDirectory+MailboxFile(i)+'.mbx') then
                   CreateMailbox(MailboxFile(i));
        end;
end;

function TNMailBox.MailboxFile(i: integer): string;
begin
        Result:=Copy(MailBoxes[i-1],1,Pos('=',MailBoxes[i-1])-1);
end;

function TNMailBox.MailboxName(i: integer): string;
begin
        Result:=Copy(MailBoxes[i-1],Pos('=',MailBoxes[i-1])+1,99);
end;

procedure TNMailBox.CreateMailBox(name: string);
var
        f:              file;
        fh:             integer;
        MBIdxRec:       NMailBoxIndex;
begin
        if FDirectory='' then Exit;
        if FileExists(FDirectory+name+'.idx') then Exit;
        AssignFile(f,FDirectory+name+'.idx');
        Rewrite(f,sizeof(NMailBoxIndex));
        MBIdxRec.Start:=0;
        MBIdxRec.Lines:=0;{trash size}
        MBIdxRec.Size:=0;
        MBIdxRec.Part:=0; {msgcnt}
        MBIdxRec.FirstAtt:=0;
        MBIdxRec.LastAtt:=0;
        BlockWrite(f,MBIdxRec,1);
        CloseFile(f);
        fh:=FileCreate(FDirectory+name+'.mbx');
        FileClose(fh);
end;

procedure TNMailBox.SetCMBNumber(number: integer);
begin
        if number=0 then Exit;
        if number>FMailBoxes.Count then
        begin
                CMBNum:=0;
                CMBName:=''
        end
        else
        begin
                CMBNum:=number;
                CMBName:=MailboxFile(number);
        end;
        InitIndex;
end;

procedure TNMailBox.SetCMBName(name: string);
var
        i: integer;
begin
        if name='' then Exit;
        CMBNum:=0;
        CMBName:='';
        i:=1;
        while (i<=FMailBoxes.Count) and (CMBNum=0) do
        begin
                if LowerCase(name)=LowerCase(MailboxFile(i)) then
                begin
                        CMBNum:=i;
                        CMBName:=MailboxFile(i);
                end;
                Inc(i);
        end;
        InitIndex;
end;

procedure TNMailBox.InitIndex;
var
        fname:          string;
        f:              file;
        MBIdxRec:       NMailBoxIndex;
begin
        fname:=Fdirectory+CMBName+'.idx';
        AssignFile(f,fname);
        Reset(f,SizeOf(NMailBoxIndex));
        BlockRead(f,MBIdxRec,1);
        FMBSize:=MBIdxRec.Size;
        FMsgCnt:=MBIdxRec.Part;
        FMBtrsize:=MBIdxRec.Lines;
        if FMsgCnt>0 then
        begin
                BlockRead(f,MBIdxRec,1);
                FSub:=MBIdxRec.Subject;
                FFrom:=MBIdxRec.FromName;
                FTo:=MBIDxRec.ToName;
                FDate:=MBIdxRec.Date;
                FSIze:=MBIdxRec.Size;
                FLines:=MBIdxRec.Lines;
                FPart:=MBIdxRec.Part;
                FFlag:=MBIdxRec.Flag;
                a1:=MBIdxRec.FirstAtt;
                a2:=MBIdxRec.LastAtt;
                FMsgNum:=1;
        end
        else
        begin
                FSub:='';
                FFrom:='';
                FTo:='';
                FDate:='';
                FPart:=0;
                FSize:=0;
                FLines:=0;
                FFlag:=' ';
                FMsgNum:=0;
                a1:=0;
                a2:=0;
        end;
        CloseFile(f);
end;

procedure TNMailBox.SetMsgNum(n: integer);
var
        f:              file;
        MBIdxRec:       NMailBoxIndex;
begin
        if n<1 then n:=1;
        if n>FMsgCnt then Exit;
        AssignFile(f,Fdirectory+CMBName+'.idx');
        Reset(f,Sizeof(NMailBoxIndex));
        Seek(f,n);
        BlockRead(f,MBIdxRec,1);
        CloseFile(f);
        FSub:=MBIdxRec.Subject;
        FFrom:=MBIdxRec.FromName;
        FTo:=MBIdxRec.ToName;
        FDate:=MBIdxRec.Date;
        FLines:=MBIdxRec.Lines;
        FSize:=MBIdxRec.Size;
        FPart:=MBIdxRec.Part;
        FFlag:=MBIdxRec.Flag;
        a1:=MBIdxRec.FirstAtt;
        a2:=MBIdxRec.LastAtt;
        FMsgNum:=n;
end;

procedure TNMailBox.LoadMail;
var
        f:      file;
        p:      Pchar;
        MBIdxRec:       NMailBoxIndex;
begin
        FMail.Clear;
        AssignFile(f,FDirectory+CMBName+'.idx');
        Reset(f,SizeOf(NMailBoxIndex));
        Seek(f,FMsgNum);
        BlockRead(f,MBIdxRec,1);
        CloseFile(f);
        AssignFile(f,FDirectory+CMBName+'.mbx');
        Reset(f,1);
        Seek(f,MBIDXRec.Start);
        GetMem(p,MBIdxRec.Size);
        BlockRead(f,p^,MBIdxRec.Size);
        FMail.SetText(p);
        FreeMem(p,MBIdxRec.Size);
        CloseFile(f);
end;

procedure TNMailBox.AddMail;
var
        f:                      file;
        trsize:                 LongInt;
        p:                      PChar;
        MBIdxRec:               NMailBoxIndex;
begin
        if (CMBNum=0) or (FDirectory='') then Exit;
        if FMail.Count=0 then Exit;
        AssignFile(f,FDirectory+CMBName+'.idx');
        Reset(f,SizeOf(NMailBoxIndex));
        BlockRead(f,MBIdxRec,1);
        CloseFile(f);
        AssignFile(f,FDirectory+CMBName+'.mbx');
        Reset(f,1);
        Seek(f,MBIdxRec.Start);
        p:=FMail.GetText;
        BlockWrite(f,p^,StrLen(p)+1);
        CloseFile(f);
        AssignFile(f,FDirectory+CMBName+'.idx');
        Reset(f,SizeOf(NMailBoxIndex));
        BlockRead(f,MBIdxRec,1);
        trsize:=MBIdxRec.Lines;
        Seek(f,FMsgCnt+1);
        MBIdxRec.Subject:=FSub;
        MBIdxRec.FromName:=FFrom;
        MBIdxRec.ToName:=FTo;
        MBIdxRec.Date:=FDate;
        MBIdxRec.Part:=FPart;
        MBIdxRec.Lines:=FMail.Count;
        MBIdxRec.Size:=StrLen(p)+1;
        MBIdxRec.FirstAtt:=a1;
        MBIdxRec.LastAtt:=a2;
        MBIdxRec.Flag:=FFlag;
        BlockWrite(f,MBIdxRec,1);
        Seek(f,0);
        Inc(FMsgCnt);
        Inc(FMBSize,StrLen(p)+1);
        MBIdxRec.Size:=FMBSize;
        MBIdxRec.Lines:=trsize;
        MBIdxRec.Part:=FMsgCnt;
        MBIdxRec.Start:=FMBSize;
        BlockWrite(f,MBIdxRec,1);
        CloseFile(f);
        Notify(CMBName,mnAdd,FMsgCnt);
end;

procedure TNMailBox.UpdateFlag(c: char);
var
        f:              file;
        MBIdxRec:       NMailBoxIndex;
begin
        if FMsgNum=0 then Exit;
        AssignFile(f,Fdirectory+CMBName+'.idx');
        Reset(f,Sizeof(NMailBoxIndex));
        Seek(f,FMsgNum);
        BlockRead(f,MBIdxRec,1);
        FFlag:=c;
        MBIdxRec.Flag:=FFlag;
        Seek(f,FMsgNum);
        BlockWrite(f,MBIdxRec,1);
        CloseFile(f);
        Notify(CMBName,mnFlag,FMsgNum);
end;

procedure TNMailBox.DeleteMail;
var
        tmp,new:        file;
        i:              integer;
        trsize:         LongInt;
        MBIdxRec:       NMailBoxIndex;
begin
        AssignFile(tmp,Fdirectory+CMBName+'.idx');
        Reset(tmp,Sizeof(NMailBoxIndex));
        BlockRead(tmp,MBIdxRec,1);
        FMsgCnt:=MBIdxRec.Part;
        CloseFile(tmp);
        if FMsgCnt=0 then Exit;
        if FMsgNum>FMsgCnt then Exit;
        {$IFDEF WIN32}
        SysUtils.DeleteFile(FDirectory+'temp.idx');
                {$ENDIF}
        if not RenameFile(FDirectory+CMBName+'.idx',FDirectory+'temp.idx') then Exit;
        AssignFile(tmp,FDirectory+'temp.idx');
        AssignFile(new,FDirectory+CMBName+'.idx');
        Rewrite(new,Sizeof(NMailBoxIndex));
        Reset(tmp,Sizeof(NMailBoxIndex));
        for i:=0 to FMsgCnt do
        begin
                BlockRead(tmp,MBIdxRec,1);
                if i<>FMsgNum then BlockWrite(new,MBIdxRec,1)
                else trsize:=MBIdxRec.Size;
        end;
        seek(new,0);
        Dec(FMsgCnt);
        BlockRead(new,MBIdxRec,1);
        MBIdxRec.Lines:=MBIdxRec.Lines+trsize;
        MBIdxRec.Part:=FMsgCnt;
        FMBTrSize:=MBIdxRec.Lines+trsize;
        seek(new,0);
        BlockWrite(new,MBIdxRec,1);
        CloseFile(new);
        CloseFile(tmp);
        Notify(CMBName,mnDelete,FMsgNum);
end;

procedure TNMailBox.Compress;
var
        i,cm,fh:        integer;
        f:              file;
        MBIdxRec:       NMailBoxIndex;
begin
        if FDirectory='' then Exit;
        AssignFile(f,FDirectory+'sjgafhge'+'.idx');
        Rewrite(f,sizeof(NMailBoxIndex));
        MBIdxRec.Start:=0;
        MBIdxRec.Lines:=0;
        MBIdxRec.Size:=0;
        MBIdxRec.Part:=0;
        BlockWrite(f,MBIdxRec,1);
        CloseFile(f);
        fh:=FileCreate(FDirectory+'sjgafhge'+'.mbx');
        FileClose(fh);
        MailBoxes.Add(name);
        cm:=CMBNum;
        for i:=1 to FMsgCnt do
        begin
                SetCMBNumber(cm);
                SetMsgNum(1);
                TransferTo('sjgafhge');
        end;
        SetCMBNumber(cm);
        {$IFDEF WIN32}
        SysUtils.DeleteFile(FDirectory+CMBName+'.idx');
        SysUtils.DeleteFile(FDirectory+CMBName+'.mbx');
                {$ENDIF}
        AssignFile(f,FDirectory+'sjgafhge'+'.idx');
        Rename(f,FDirectory+CMBName+'.idx');
        AssignFile(f,FDirectory+'sjgafhge'+'.mbx');
        Rename(f,FDirectory+CMBName+'.mbx');
        FMailBoxes.Delete(FMailBoxes.Count-1);
        InitIndex;
end;

procedure TNMailBox.EmptyMailbox(num: integer);
var
        fh:             integer;
        f:              file;
        MBIdxRec:       NMailBoxIndex;
begin
        if FDirectory='' then Exit;
        AssignFile(f,FDirectory+MailboxFile(num)+'.idx');
        Rewrite(f,sizeof(NMailBoxIndex));
        MBIdxRec.Start:=0;
        MBIdxRec.Lines:=0;
        MBIdxRec.Size:=0;
        MBIdxRec.Part:=0;
        BlockWrite(f,MBIdxRec,1);
        CloseFile(f);
        fh:=FileCreate(FDirectory+MailboxFile(num)+'.mbx');
        FileClose(fh);
        if CMBNum=num then InitIndex;
        Notify(CMBName,mnClearAll,0);
end;

procedure TNMailBox.TransferTo(name: string);
var
        f1,f2:          file;
        p:              PChar;
        MBIdxRec2:      NMailBoxIndex;
        MBIdxRec1:      NMailBoxIndex;
        n1:             MBName;
        n2:             integer;
begin
        if FMsgCnt=0 then Exit;
        FMail.Clear;
        AssignFile(f1,FDirectory+CMBName+'.idx');
        Reset(f1,Sizeof(MBIdxRec1));
        Seek(f1,FMsgNum);
        BlockRead(f1,MBIdxRec1,1);
        CloseFile(f1);
        AssignFile(f2,FDirectory+name+'.idx');
        Reset(f2,Sizeof(MBIdxRec2));
        BlockRead(f2,MBIdxRec2,1);
        CloseFile(f2);
        AssignFile(f1,FDirectory+CMBName+'.mbx');
        AssignFile(f2,FDirectory+name+'.mbx');
        Reset(f1,1);
        Seek(f1,MBIdxRec1.Start);
        Reset(f2,1);
        Seek(f2,MBIdxRec2.Start);
        GetMem(p,MBIdxRec1.Size+1);
        BlockRead(f1,p^,MBIdxRec1.Size);
        BlockWrite(f2,p^,MBIdxRec1.Size);
        FreeMem(p,MBIdxRec1.Size);
        CloseFile(f1);
        CloseFile(f2);
        AssignFile(f2,FDirectory+name+'.idx');
        Reset(f2,SizeOf(NMailBoxIndex));
        Seek(f2,MBIdxRec2.Part+1);
        MBIdxRec1.Start:=MBIdxRec2.Start;
        MBIdxRec1.Subject:=FSub;
        MBIdxRec1.FromName:=FFrom;
        MBIdxRec1.ToName:=FTo;
        MBIdxRec1.Date:=FDate;
        MBIdxRec1.Part:=FPart;
        MBIdxRec1.Lines:=FLines;
        MBIdxRec1.Size:=FSize;
        MBIdxRec1.Flag:=FFLag;
        MBIdxRec1.FirstAtt:=a1;
        MBIdxRec1.LastAtt:=a2;
        BlockWrite(f2,MBIdxRec1,1);
        Seek(f2,0);
        MBIdxRec2.Start:=MBIdxRec2.Start+FSize;
        MBIdxRec2.Size:=FSize+MBIdxRec2.Size;
        MBIdxRec2.Part:=MBIdxRec2.Part+1;
        BlockWrite(f2,MBIdxRec2,1);
        CloseFile(f2);
        n1:=name;
        n2:=MBIDXRec2.Part;
        DeleteMail;
        Notify(n1,mnAdd,n2);
end;

{
MailboxViewerControl notification functions
}
function TNMailbox.RegisterNotify(Control: TMailboxViewerControl;MailboxName: MBName): Boolean;
var
        i: integer;
begin
        for i:=1 to 256 do
        begin
                if Notifications[i].Control=nil then
                begin
                        Notifications[i].Control:=Control;
                        Notifications[i].MailboxName:=MailboxName;
                        Result:=True;
                        Exit;
                end;
        end;
        Result:=False;
end;

procedure TNMailbox.UnregisterNotify(Control: TMailboxViewerControl);
var
        i: integer;
begin
        for i:=1 to 256 do
        begin
                if Notifications[i].Control=Control then
                begin
                        Notifications[i].Control:=nil;
                        Break;
                end;
        end;
end;

procedure TNMailbox.Notify(MB: MBName;Event: TMailboxNotification;Item: integer);
var
        i: integer;
begin
        for i:=1 to 256 do
        begin
                if Notifications[i].Control<>nil then
                begin
                        if Notifications[i].MailboxName=MB then
                        begin
                                Notifications[i].Control.Notify(Event,Item);
                        end;
                end;
        end;
end;

procedure TMailboxViewerControl.Notify(Event: TMailboxNotification; Item: integer);
begin
        ;
end;

constructor NMAilboxViewer.Create(AOwner: TComponent);
begin
        inherited Create(AOwner);
        Width:=350;
        Height:=250;
        Header:=TMBHeader.Create(self);
        Header.Parent:=self as TWinControl;
        Header.Align:=alTop;
        Header.Visible:=True;
        Header.OnSized:=HeaderSized;
        Header.OnMouseDown:=HMouseDown;
        Header.OnMouseUp:=HMouseUp;
        ListBox:=TMBCustomListBox.Create(self);
        Listbox.Parent:=self as TWinControl;
        Listbox.Align:=alClient;
        Listbox.Visible:=True;
        Listbox.DragMode:=dmManual;
        Listbox.OnDragOver:=Listbox.DragOver;
        Listbox.OnDragDrop:=Listbox.DragDrop;
        Listbox.OnEndDrag:=Listbox.EndDrag;
        Listbox.MultiSelect:=True;
        Listbox.ExtendedSelect:=True;
        Listbox.OnDblClick:=ListboxDblClick;
        Listbox.OnClick:=ListboxClick;
        FFont:=TFont.Create;
        FNumMessages:=0;
        CMBName:='';
        MB:=nil;
        WMgr:=False;
end;

destructor NMailboxViewer.Destroy;
var
        i: integer;
        c: TWinControl;
begin
        if Assigned(MB) and (CMBName<>'') then MB.UnregisterNotify(self);
        for i:=1 to FNumMessages do FreeMem(Messages[i],SizeOf(TMailboxViewerRecord));
        if WMgr then {close all open viewmail forms}
        begin
                for i:=1 to 256 do
                begin
                        c:=FindControl(Viewers[i].Handle);
                        if (c<>nil) and (c is VFClass) then
                        begin
                                try
                                        (c as TForm).Show;
                                        c.BringToFront;
                                        SendMessage(Viewers[i].Handle,MBV_CLOSE,0,0);
                                except
                                        ;
                                end;
                        end;
                end;
        end;
        Header.Destroy;
        Listbox.Destroy;
        FFont.Destroy;
        inherited Destroy;
end;

function NMailboxViewer.GetDropEnabled: Boolean;
begin
        Result:=Listbox.DropEnabled;
end;

function NMailboxViewer.GetDragEnabled: Boolean;
begin
        Result:=Listbox.DragEnabled;
end;

procedure NMailboxViewer.SetDragEnabled(s: Boolean);
begin
        Listbox.DragEnabled:=s;
end;

procedure NMailboxViewer.SetDropEnabled(s: Boolean);
begin
        Listbox.DropEnabled:=s;
end;

procedure NMailboxViewer.SetIndex(i: integer);
begin
        Listbox.ItemIndex:=i;
end;

function NMailboxViewer.GetIndex: integer;
begin
        Result:=Listbox.ItemIndex;
end;

function NMailboxViewer.GetSelected(Index: integer):Boolean;
begin
        Result:=Listbox.Selected[Index];
end;

procedure NMailboxViewer.SetUBM(b: TBitmap);
begin
        Listbox.UBM.Assign(b);
end;

procedure NMailboxViewer.SetABM(b: TBitmap);
begin
        Listbox.ABM.Assign(b);
end;

procedure NMailboxViewer.SetQBM(b: TBitmap);
begin
        Listbox.QBM.Assign(b);
end;

procedure NMailboxViewer.SetSBM(b: TBitmap);
begin
        Listbox.SBM.Assign(b);
end;

procedure NMailboxViewer.SetVBM(b: TBitmap);
begin
        Listbox.VBM.Assign(b);
end;

function NMailboxViewer.GetUBM: TBitmap;
begin
        Result:=Listbox.UBM;
end;

function NMailboxViewer.GetABM: TBitmap;
begin
        Result:=Listbox.ABM;
end;

function NMailboxViewer.GetQBM: TBitmap;
begin
        Result:=Listbox.QBM;
end;

function NMailboxViewer.GetSBM: TBitmap;
begin
        Result:=Listbox.SBM;
end;

function NMailboxViewer.GetVBM: TBitmap;
begin
        Result:=Listbox.VBM;
end;

procedure NMailboxViewer.Loaded;
var
        i: integer;
begin
        inherited Loaded;
        if (MBNum<>0) and Assigned(MB) then LoadItems;
        Initialized:=True;
        SetFont(FFont);
        for i:=1 to 5 do Listbox.SW[i]:=Header.SectionWidth[i-1];
        if SectionNames.Count<1 then Header.Sections.Add('Status');
        if SectionNames.Count<2 then Header.Sections.Add('From');
        if SectionNames.Count<3 then Header.Sections.Add('Date');
        if SectionNames.Count<4 then Header.Sections.Add('Size');
        if SectionNames.Count<5 then Header.Sections.Add('Subject');
        with Listbox.Canvas do
        begin
                for i:=0 to 4 do MinW[i+1]:=TextWidth(Header.Sections[i])+4;
        end;
end;

procedure NMailboxViewer.SetMB(mbx: TNMailbox);
begin
        Initialized:=False;
        if Assigned(MB) and (CMBName<>'') then MB.UnregisterNotify(self);
        MB:=mbx;
        if MBNum<>0 then
        begin
                MB.CurrentMailboxNumber:=MBNum;
                CMBName:=MB.CurrentMailboxName;
                MB.RegisterNotify(self,CMBName);
        end;
        LoadItems;
end;

procedure NMailboxViewer.SetMBNum(n: integer);
begin
        Initialized:=False;
        if Assigned(MB) and (CMBName<>'') then MB.UnregisterNotify(self);
        MBNum:=n;
        if Assigned(MB) then
        begin
                MB.CurrentMailboxNumber:=n;
                CMBName:=MB.CurrentMailboxName;
                MB.RegisterNotify(self,CMBName);
        end;
        LoadItems;
end;

procedure NMailboxViewer.SetFont(f: TFont);
begin
        FFont.Assign(f);
        Header.Font:=FFont;
        with Listbox.Canvas do
        begin
                Font:=FFont;
                Header.Height:=TextHeight('A')+4;
        end;
end;

procedure NMailBoxViewer.SetSections(s: TStrings);
var
        i: integer;
begin
        Header.Sections.Assign(s);
        if SectionNames.Count<1 then Header.Sections.Add('Status');
        if SectionNames.Count<2 then Header.Sections.Add('From');
        if SectionNames.Count<3 then Header.Sections.Add('Date');
        if SectionNames.Count<4 then Header.Sections.Add('Size');
        if SectionNames.Count<5 then Header.Sections.Add('Subject');
        with Listbox.Canvas do
        begin
                for i:=0 to 3 do MinW[i+1]:=TextWidth(Header.Sections[i]);
        end;
end;

function NMailboxViewer.GetSections: TStrings;
begin
        Result:=Header.Sections;
end;

procedure NMailboxViewer.LoadItems;
var
        s: string;
        i: integer;
begin
        if not Assigned(MB) or (MBNum=0) then Exit;
        Listbox.Items.BeginUpdate;
        Listbox.Items.Clear;
        MB.CurrentMailboxNumber:=MBNum;
        Application.ProcessMessages;
        for i:=1 to FNumMessages do FreeMem(Messages[i],SizeOf(TMailboxViewerRecord));
        for i:=1 to MB.CurrentMailboxMessages do
        begin
                with MB do
                begin
                        Msg_Number:=i;
                        GetMem(Messages[i],Sizeof(TMailboxViewerRecord));
                        Messages[i]^.Name:=Msg_From;
                        Messages[i]^.Subject:=Msg_Subject;
                        Messages[i]^.Date:=Msg_Date;
                        Messages[i]^.Size:=Msg_Size;
                        Messages[i]^.Flag:=Msg_Flag;
                        Messages[i]^.Attachments:=(Msg_AttachStart>0);
                        if FNewTop then Index[i]:=MB.CurrentMailboxMessages-i+1
                        else Index[i]:=i;
                end;
                Listbox.Items.Add('*');
        end;
        FNumMessages:=MB.CurrentMailboxMessages;
        Listbox.Items.EndUpdate;
        if Assigned(FOnChange) then FOnChange(self);
        Initialized:=True;
end;

procedure NMailboxViewer.Refresh;
begin
        Listbox.Invalidate;
end;

constructor TMBCustomListbox.Create(AOwner: TComponent);
begin
        inherited Create(AOwner);
        ABM:=TBitmap.Create;
        UBM:=TBitmap.Create;
        QBM:=TBitmap.Create;
        VBM:=TBitmap.Create;
        SBM:=TBitmap.Create;
        Style:=lbOwnerDrawFixed;
end;

destructor TMBCustomListbox.Destroy;
begin
        ABM.Destroy;
        UBM.Destroy;
        QBM.Destroy;
        VBM.Destroy;
        SBM.Destroy;
        inherited Destroy;
end;

constructor TMBHeader.Create(AOwner: TComponent);
begin
        inherited Create(AOwner);
end;

destructor TMBHeader.Destroy;
begin
        inherited Destroy;
end;

procedure TMBCustomListbox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
        if not DragEnabled then Exit;
        if (ssShift in Shift) or (ssCtrl in Shift) then Exit;
        if Button = mbLeft then
        begin
                if ItemAtPos(Point(X, Y), True)>= 0 then BeginDrag(False);
        end;
end;

procedure TMBCustomListbox.DragOver(Sender, Source: TObject; X, Y: Integer;State: TDragState; var Accept: Boolean);
begin
        if DropEnabled and (Source is TMBCustomListbox) and (Source<>Sender) then Accept:=True
        else Accept:=False;
end;

procedure TMBCustomListbox.DragDrop(Sender, Source: TObject; X, Y: Integer);
begin
        ;
end;

procedure TMBCustomListbox.EndDrag(Sender, Target: TObject; X, Y: Integer);
var
        DestMB: integer;
        PMB: TNMailbox;
        s: string;
begin
        if Target<>nil then
        begin
                DestMB:=((Target as TMBCustomListbox).Owner as NMailboxViewer).MBNum;
                PMB:=(Owner as NMailboxViewer).MB;
                s:=PMB.MailboxFile(DestMB);
                PMB.CurrentMailboxNumber:=(Owner as NMailboxViewer).MBNum;
                PMB.Msg_Number:=(parent as NMailboxViewer).IndexToMessageNumber(ItemIndex);
                PMB.TransferTo(s);
        end;
end;

function NMailboxViewer.IndexToMessageNumber(n: integer): integer;
begin
        Result:=Index[n+1]
end;

procedure TMBCustomListBox.DrawItem(Idx: Integer; R: TRect; State: TOwnerDrawState);
var
        s: string;
        m: TMailboxViewerRecord;
        i,offset: integer;
        c: TColor;
        n,w: integer;
begin
        with Canvas do
        begin
                FillRect(R);
                c:=Font.Color;
                Font:=(Owner as NMailboxViewer).Font;
                Font.Color:=c;
                i:=(Parent as NMailboxViewer).Index[Idx+1];
                m:=(Parent as NMailboxViewer).Messages[i]^;
                case m.Flag of
                'u','U': if Assigned(UBM) then Draw(R.Left+2,R.Top,UBM);
                'v','V': if Assigned(VBM) then Draw(R.Left+2,R.Top,VBM);
                'r','R': if Assigned(SBM) then Draw(R.Left+2,R.Top,SBM);
                'q','Q': if Assigned(QBM) then Draw(R.Left+2,R.Top,QBM);
                end;
                if (m.Attachments) and Assigned(ABM) then Draw(R.Left+20,R.Top,ABM);
                Pen.Color:=clBlack;
                offset:=SW[1];
                MoveTo(offset,0);
                LineTo(offset,height);
                TextRect(Rect(R.Left+offset+2,R.Top,R.Left+offset+SW[2]-2,R.Bottom),R.Left+offset+2,R.Top,m.Name);
                Inc(offset,SW[2]);
                MoveTo(offset,0);
                LineTo(offset,height);
                TextRect(Rect(R.Left+offset+2,R.Top,R.Left+offset+SW[3]-2,R.Bottom),R.Left+offset+2,R.Top,m.Date);
                Inc(offset,SW[3]);
                MoveTo(offset,0);
                LineTo(offset,height);
                s:=IntToStr((m.Size shr 10)+1);
                w:=TextWidth(s);
                TextRect(Rect(R.Left+offset+2,R.Top,R.Right-2,R.Bottom),R.Left+offset+((SW[4]-w)div 2),R.Top,s);
                Inc(offset,SW[4]);
                MoveTo(offset,0);
                LineTo(offset,height);
                TextRect(Rect(R.Left+offset+2,R.Top,R.Right-2,R.Bottom),R.Left+offset+2,R.Top,m.Subject);
        end;
end;

procedure NMailboxViewer.SetHeaderSize(x,s: integer);
begin
        if s<MinW[x+1] then s:=MinW[x+1];
        Header.SectionWidth[x-1]:=s;
        Listbox.SW[x]:=s;
        Listbox.Repaint;
end;

procedure NMailboxViewer.HeaderSized(Sender: TObject;s,x: integer);
var
        i: integer;
begin
        if x<MinW[s+1] then Header.SectionWidth[s]:=MinW[s+1];
        for i:=1 to 4 do Listbox.SW[i]:=Header.SectionWidth[i-1];
        Listbox.Repaint;
end;

procedure NMailboxViewer.HMouseDown(Sender:TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
        if (X>0) and (X<Header.Width) and (Y>0) and (Y<Header.Height) then
        begin
                SX:=X;
                SY:=Y;
        end;
end;

procedure NMailboxViewer.HMouseUp(Sender:TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
        sortcol,i,j,tmp: integer;
        r1,r2: TMailboxViewerRecord;
        DoSwap: Boolean;
begin
        if (X=SX) and (SY=Y) then
        begin
                Screen.cursor:=crHourglass;
                Listbox.Items.BeginUpdate;
                for i:=1 to 5 do
                begin
                        if X<Header.SectionWidth[i-1] then
                        begin
                                sortcol:=i;
                                break;
                        end
                        else Dec(X,Header.SectionWidth[i-1]);
                end;
                for i:=1 to FNumMessages-1 do
                begin
                        r1:=Messages[Index[i]]^;
                        for j:=i+1 to FNumMessages do
                        begin
                                r2:=Messages[Index[j]]^;
                                DoSwap:=False;
                                case sortcol of
                                1:
                                        begin
                                                case Button of
                                                mbLeft: DoSwap:=(r2.Flag<r1.Flag);
                                                mbRight: DoSwap:=(r1.Flag<r2.Flag);
                                                end;
                                        end;
                                2:
                                        begin
                                                case Button of
                                                mbLeft: DoSwap:=(r2.Name<r1.Name);
                                                mbRight: DoSwap:=(r1.Name<r2.Name);
                                                end;
                                        end;
                                3:
                                        begin
                                                case Button of
                                                mbLeft: DoSwap:=(Index[i]>Index[j]);
                                                mbRight: DoSwap:=(Index[i]<Index[j]);
                                                end;
                                        end;
                                4:
                                        begin
                                                case Button of
                                                mbLeft: DoSwap:=(r2.Size<r1.Size);
                                                mbRight: DoSwap:=(r1.Size<r2.Size);
                                                end;
                                        end;
                                5:
                                        begin
                                                case Button of
                                                mbLeft: DoSwap:=(r2.Subject<r1.Subject);
                                                mbRight:DoSwap:=(r1.Subject<r2.Subject);
                                                end;
                                        end;
                                end;
                                if DoSwap then
                                begin

                                        tmp:=Index[i];
                                        Index[i]:=Index[j];
                                        Index[j]:=tmp;
                                        r1:=r2;
                                end;
                        end;
                end;
                Listbox.Items.EndUpdate;
                Screen.cursor:=crDefault;
        end;
end;

procedure NMailboxViewer.SetNewTop(b: Boolean);
var
        i: integer;
begin
        FNewTop:=b;
        if FNewTop then
        begin
                for i:=1 to NumMessages do
                begin
                        Index[i]:=NumMessages-i+1;
                end;
        end
        else
        begin
                for i:=1 to NumMessages do
                begin
                        Index[i]:=i;
                end;
        end;
        Refresh;
end;

procedure NMailboxViewer.Notify(Event: TMailboxNotification; Item: integer);
var
        i,idx: integer;
begin
        case Event of
        mnAdd:
                begin
                        with MB do
                        begin
                                CurrentMailboxNumber:=MBNum;
                                Msg_Number:=Item;
                                GetMem(Messages[Item],Sizeof(TMailboxViewerRecord));
                                Messages[Item]^.Name:=Msg_From;
                                Messages[Item]^.Subject:=Msg_Subject;
                                Messages[Item]^.Date:=Msg_Date;
                                Messages[Item]^.Size:=Msg_Size;
                                Messages[Item]^.Flag:=Msg_Flag;
                                Messages[Item]^.Attachments:=(Msg_AttachStart>0);
                                Index[Item]:=Item;
                        end;
                        Listbox.Items.Add('*');
                        Refresh;
                        Inc(FNumMessages);
                        if Assigned(FOnChange) then FOnChange(self);
                end;
        mnDelete:
                begin
                        for i:=1 to FNumMessages do
                        begin
                                if Index[i]=Item then
                                begin
                                        idx:=i;
                                        Break;
                                end;
                        end;
                        FreeMem(Messages[Item],SizeOf(TMailboxViewerRecord));
                        for i:=Item to FNumMessages-1 do Messages[i]:=Messages[i+1];
                        for i:=idx to FNumMessages-1 do Index[i]:=Index[i+1];
                        Dec(FNumMessages);
                        for i:=1 to FNumMessages do
                        begin
                                if Index[i]>Item then Dec(Index[i]);
                        end;
                        Listbox.Items.Delete(0);
                        Refresh;
                        if Assigned(FOnChange) then FOnChange(self);
                        if WMgr then
                        begin
                                for i:=1 to 256 do
                                begin
                                        if (Viewers[i].Handle<>0) and (FindControl(Viewers[i].Handle)<>nil) then
                                        begin
                                                if Viewers[i].MessageNumber=item then
                                                begin
                                                        try
                                                                SendMessage(Viewers[i].Handle,MBV_CLOSE,0,0);
                                                        except
                                                                ;
                                                        end;
                                                        Viewers[i].Handle:=0;
                                                        Viewers[i].MessageNumber:=-1;
                                                end;
                                                if Viewers[i].MessageNumber>item then
                                                begin
                                                        Dec(Viewers[i].MessageNumber);
                                                        SendMessage(Viewers[i].Handle,MBV_UPDATEINFO,MBNum,
                                                           Viewers[i].MessageNumber);
                                                end;
                                        end;
                                end;
                        end;
                end;
        mnFlag:
                begin
                        Messages[Item]^.Flag:=MB.Msg_Flag;
                        Refresh;
                end;
        mnClearAll:
                begin
                        for i:=1 to FNumMessages do FreeMem(Messages[i],SizeOf(TMailboxViewerRecord));
                        FNumMessages:=0;
                        Listbox.Clear;
                        if Assigned(FOnChange) then FOnChange(self);
                        if WMgr then
                        begin
                                for i:=1 to 256 do
                                begin
                                        if (Viewers[i].Handle<>0) and (FindControl(Viewers[i].Handle)<>nil) then
                                        begin
                                                try
                                                        SendMessage(Viewers[i].Handle,MBV_CLOSE,0,0);
                                                except
                                                        ;
                                                end;
                                                Viewers[i].Handle:=0;
                                                Viewers[i].MessageNumber:=-1;
                                        end;
                                end;
                        end;
                end;
        mnDestroying:
                begin
                        for i:=1 to FNumMessages do FreeMem(Messages[i],SizeOf(TMailboxViewerRecord));
                        FNumMessages:=0;
                        Listbox.Clear;
                        if Assigned(FOnChange) then FOnChange(self);
                        MB:=nil;
                end;
        end;
end;

procedure NMailboxViewer.EnableMessageViewerManager(MessageViewerFormClass: TFormClass);
var
        Child: TWinControl;
begin
        VFClass:=MessageViewerFormClass;
        {find Main form}
        Child:=self;
        while Child.Parent<>nil do Child:=Child.Parent;
        FMain:=(Child as TForm);
        WMgr:=True;
end;

procedure NMailboxViewer.ListboxDblClick(Sender: TObject);
begin
        if not WMgr then
        begin
                if Assigned(FOnDblClick) then FOnDblClick(self,IndexToMessageNumber(Listbox.ItemIndex));
        end
        else ViewSelectedMessages;
end;

procedure NMailboxViewer.ListboxClick(Sender: TObject);
begin
        if not WMgr then
        begin
                if Assigned(FOnClick) then FOnClick(self,IndexToMessageNumber(Listbox.ItemIndex));
        end;
end;

procedure NMailboxViewer.ViewSelectedMessages;
var
        f: TForm;
        msg: integer;
        i,j: integer;
        h: Thandle;
begin
        if not WMgr then Exit;
        for i:=0 to NumMessages-1 do
        begin
                if Selected[i] then
                begin
                        msg:=IndexToMessageNumber(i);
                        h:=FindFormWithMessage(msg);
                        if h=0 then
                        begin
                                for j:=1 to 256 do
                                begin
                                        if (Viewers[j].Handle=0) then
                                        begin
                                                try
                                                        f:=VFClass.Create(FMain);
                                                        Viewers[j].Handle:=f.Handle;
                                                        SendMessage(f.Handle,MBV_PARENT,0,LongInt(self));
                                                        SendMessage(f.Handle,MBV_SETMESSAGE,MBNum,msg);
                                                        Viewers[j].MessageNumber:=msg;
                                                except
                                                        ;
                                                end;
                                                Break;
                                        end;
                                end;
                        end;
                end;
        end;
end;

procedure NMailboxViewer.NextMessage(h: THandle);
var
        i,msg,idx,entry: integer;
        h2: THandle;
begin
        if not WMgr then Exit;
        msg:=0;
        for i:=1 to 256 do
        begin
                if Viewers[i].Handle=h then
                begin
                        msg:=Viewers[i].MessageNumber;
                        entry:=i;
                        Break;
                end;
        end;
        if msg=0 then Exit;
        for i:=1 to NumMessages do
        begin
                if Index[i]=msg then
                begin
                        idx:=i;
                        Break;
                end;
        end;
        if idx=NumMessages then Exit; {last message}
        msg:=IndexToMessageNumber(idx);
        h2:=FindFormWithMessage(msg);
        if h2=0 then
        begin
                SendMessage(h,MBV_SETMESSAGE,MBNum,msg);
                Viewers[entry].MessageNumber:=msg;
        end;
end;

procedure NMailboxViewer.PreviousMessage(h: THandle);
var
        i,msg,idx,entry: integer;
        h2: THandle;
begin
        if not WMgr then Exit;
        msg:=0;
        for i:=1 to 256 do
        begin
                if Viewers[i].Handle=h then
                begin
                        msg:=Viewers[i].MessageNumber;
                        entry:=i;
                        Break;
                end;
        end;
        if msg=0 then Exit;
        for i:=1 to NumMessages do
        begin
                if Index[i]=msg then
                begin
                        idx:=i;
                        Break;
                end;
        end;
        if idx=1 then Exit; {first message}
        msg:=IndexToMessageNumber(idx-2);
        h2:=FindFormWithMessage(msg);
        if h2=0 then
        begin
                SendMessage(h,MBV_SETMESSAGE,MBNum,msg);
                Viewers[entry].MessageNumber:=msg;
        end;
end;

function NMailboxViewer.FindFormWithMessage(msg: integer): THandle;
var
        i: integer;
        c: TWinControl;
begin
        for i:=1 to 256 do
        begin
                if (Viewers[i].Handle<>0) and (FindControl(Viewers[i].Handle)<>nil) then
                begin
                        if Viewers[i].MessageNumber=msg then
                        begin
                                c:=FindControl(Viewers[i].Handle);
                                if (c<>nil) and (c is VFClass) then
                                begin
                                        try
                                                (c as TForm).Show;
                                                c.BringToFront;
                                                Result:=Viewers[i].Handle;
                                        except
                                                Viewers[i].Handle:=0;
                                                Viewers[i].MessageNumber:=-1;
                                                Result:=0;
                                        end;
                                end;
                                Exit;
                        end;
                end;
        end;
        Result:=0;
end;

procedure NMailboxViewer.TransferSelectedMessages(TargetMailboxNumber: integer);
var
        MessageNumber,i: integer;
begin
        i:=0;
        while i<NumMessages do
        begin
                if Selected[i] then
                begin
                        MessageNumber:=IndexToMessageNumber(i);
                        with Mailbox do
                        begin
                                CurrentMailboxNumber:=MailboxNumber;
                                Msg_Number:=MessageNumber;
                                TransferTo(MailboxFile(TargetMailboxNumber));
                        end;
                end
                else Inc(i);
        end;
end;

procedure NMailboxViewer.DeleteSelectedMessages;
var
        MessageNumber,i: integer;
begin
        i:=0;
        while i<NumMessages do
        begin
                if Selected[i] then
                begin
                        MessageNumber:=IndexToMessageNumber(i);
                        with Mailbox do
                        begin
                                CurrentMailboxNumber:=MailboxNumber;
                                Msg_Number:=MessageNumber;
                                DeleteMail;
                        end;
                end
                else Inc(i);
        end;
end;

{=======================================================================}

end.
