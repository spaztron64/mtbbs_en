{
GNETMAIL- Internet Mail Component for Delphi
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

{history
        1.3.1   Oct-28  -fixed Linux bug for good.
                        -made Read function protected from messages
                        dispatched during yields.can now step through
                        code while receiving mail!
        1.3.2   Oct-31  -changed declaration for OnAttachmentName
                        now returns all attachment MIME headers in a
                        TMIME attachment structure. Users fills in
                        Location field when event is received.
                        -added ProcessMimeHeaders function to handle
                        attachments recursively, so that nested attachments
                        can be handled correctly.
                        -now correctly reports Info of gmNumberMessage
                        -now correctly handles pre-MIME messages (was fooled if
                         a blank line occured in the pre-MIME messages.
        1.3.4  Jan 13   -added UIDL property
                        -added TUIDLManager object
        1.3.5  Jan 17   -added QuitAsap method (if before message retrieval,
                         quits right away, other wise waits for current message
                         to finish)
                        -made Available event occur after disconnect.
        1.3.6  Jan 20   -TUILDManager object deleted, UIDL function now
                         integrated in component.
        1.3.7  Jan 21   -Deleted obsolete gmXxxx. gmAvailable is now always
                         last notification in transaction.
        1.3.8  Jan 26   -Fixed bug with boundary (forgot to change to MIMEBoundary[])
        1.3.9  Feb 14   -fixed bug with boundary split header.
                        -keep duplicate messages from being added to DiffUIDL.
        1.3.10 March 2  -Delphi 2.0 compatible version!
        1.3.11 March 6  -added Msg_ID property.
        1.3.12 April 20 -fixed step 6 bug with 0 length strings.
        1.3.13 May 12   -added timeout function
                        -added decoding of RFC1522 headers.
                        -reaaranged error handling.
}


unit Gnetmail;

interface

uses StarSock,Classes,Forms,WinTypes,SysUtils,AttDef,messages;

const WM_AVAILABLE      =       WM_USER+2;

type MIME_Encoding=(plain,Base64,QuotedPrintable);

type GetMailInfo=(gmServerConnected,gmServerDisconnected,
                gmNumberMessage,gmMessageSize,gmGettingMessage,gmTraceIn,
                gmTraceOut,gmUIDLList,gmUIDLSupport,gmAlreadyBusy,
                gmAccessGranted,gmLogin,gmResolvingAddress,gmAddressResolved);

type GetMailError=(gmNone,gmWInsockNotInitialized,gmNetworkDown,gmInvalidAddress,gmInternalError,
                    gmGeneralWinsockError,gmConnAborted,gmConnReset,gmConnectTimeOut,
                    gmOutofSockets,gmNetworkUnreachable,gmAddressNotAvailable,
                    gmConnectionRefused,gmProtocolError,gmCanceled,gmUnknown,
                    gmAddressResolutionError,gmPrematureDisconnect,
                    gmHostUnreachable,gmAccessDenied);


type TGetMailAction=(None,Get_Mail,Cancel_GetMail);
type TMIMEAttachmentPtr=^TMIMEAttachment;
TGetMailInfoEvent = procedure (Sender : TObject; info: GetMailInfo; addinfo: string) of object;
TGetMailErrorEvent = procedure (Sender : TObject; error: GetMailError; addinfo: string) of object;
TGetMessageEvent= procedure (Sender:TObject) of object;
TGetHeadersEvent= procedure (Sender:TObject)of object;
TAttachmentEvent= procedure (Sender:TObject;Attachment: TMIMEAttachmentPtr)of object;
TNewLineProc=procedure(line:string) of object;
TGMDataEvent=procedure (Sender: TObject; data: string) of object;

type GetMail = class(TStarSocket)
        private
                AttRec:                 TMimeAttachment;
                spline:                 string;
                mtype:                  string;
                tmpline:                string;
                MailInfoEvt:            TGetMailInfoEvent;
                MailErrorEvt:           TGetMailErrorEvent;
                GetMessageEvt:          TGetMessageEvent;
                GetHeadersEvt:          TGetHeadersEvent;
                content:                string;
                AttNameEvt:             TAttachmentEvent;
                AttStoredEvt:           TAttachmentEvent;
                ProtocolInput:          TNewLineProc;
                FID,FPassword:          string;
                FFrom,FTo:              string;
                FSubject,FDate:         string;
                FMNum:                  integer;
                FSize:                  Longint;
                FAction:                TGetMailAction;
                FMsgCnt:                integer;
                FODel,FOpvw,FOSkip:     Boolean;
                CurMsg:                 integer;
                MimeBoundary:           array[1..32] of string;
                {$IFDEF WIN32}
                lineout:                string;
                {$ENDIF}
                NestingLevel:           integer;
                ProcHeaders,AttSkip:    Boolean;
                AttEncoding:            MIME_Encoding;
                MainEncoding:           MIME_Encoding;
                BndLine,MultiPart:      Boolean;
                boundaries:             integer;
                attfile:                integer;
                OnHold,Aborted:         Boolean;
                MailStrings:            TStrings;
                OMD:                    TGMDataEvent;
                Flush:                  Boolean;
                AttSize:                Longint;
                FUIDL,FMsg_ID:          string;
                EarlyQuit,DLStarted:    Boolean;
                FUIDLList,NewUIDL,DiffUIDL,DiffUIDL2,NewUIDL2: TStrings;
                UIDLSupported:          Boolean;
                FSuccess:               Boolean;
                FVersion,DummyS:        string;
                step:                   integer;
                PartialLine:            string;
                FError:                 GetMailError;
                FDone:                  TNotifyEvent;
                Busy:                   Boolean;
                function RecvText : string;
                procedure CloseProc;
                procedure DoMailError(error: GetMailError; add: string);
                procedure Write(line: string);
                procedure RawWrite(data: string);
                procedure SetPort(p: u_short);
                procedure DidConnect(Sender: TObject);
                procedure DoDisconnect(Sender:TObject);
                procedure DoRead(Sender:TObject);
                procedure MailAction(act: TGetMailAction);
                procedure DoMailInfo(info: GetMailInfo; add: string);
                procedure POP3Login(line:string);
                procedure POP3GetMail(line: string);
                function QuotedDecode(var line: string): Boolean;
                procedure Store_base64(line: string);
                procedure Store_Plain(line: string);
                function ExtractHeader(line: string;header: string;var stringvar: string):Boolean;
                function ExtractString(line:string;name:string): string;
                procedure SetMailStrings(s:TStrings);
                procedure ProcessMimeHeaders(line: string);
                procedure POP3MessageDone;
                procedure NewMimeSection;
                procedure IsAvailable(var Message: TMessage);message WM_AVAILABLE;
                procedure SetUIDLList(s: TStrings);
                procedure AskForNextMessage;
                function NextMessage: Boolean;
                function CheckRFC1522(s: string): string;
                procedure SetWinsockStarted(b: Boolean);
                function GetWinsockStarted: Boolean;
                function CheckError: Boolean;
                procedure TimedOut(Sender: TObject);
        protected
                procedure  LookupNameDone;override;
                constructor Create(AOwner: TComponent);override;
                destructor Destroy;override;
        public
                function IsHeader(name: string; var value: string): Boolean;
                procedure DoGetMail;
                procedure QuitAsap;
                property Success: Boolean read FSuccess;
                property Error: GetMailError read FError;
                property Msg_Size: longint read FSize;
                property Msg_Date: string read FDate;
                property Msg_From: string read FFrom;
                property Msg_To: string read FTo;
                property Msg_Subject: string read FSubject;
                property Msg_UIDL: string read FUIDL;
                property Msg_ID: string read FMsg_ID;
                property Msg_Number: integer read FMNum;
                property Message_Count: integer read FMSgCnt;
                property Mail_Text: TStrings read MailStrings write SetMailStrings;
                property UIDLList: TStrings read FUIDLList write SetUIDLList;
        published
                property Opt_Delete: Boolean read FODel write FODel;
                property Opt_Preview: Boolean read FOPvw write FOPvw;
                property Opt_Skip: Boolean read FOSkip write FOSkip;
                property Mail_Action: TGetMailAction read FAction write MailAction;
                property Mail_Server: string read Server write SetServer;
                property Mail_Port: u_short read Port write Port;
                property User_ID: string read FID write FID;
                property User_Password: string read FPassword write FPassword;
                property OnMailInfo: TGetMailInfoEvent read MailInfoEvt write MailInfoEvt;
                property OnMailError: TGetMailErrorEvent read MailErrorEvt write MailErrorEvt;
                property OnDone: TNotifyEvent read FDone write FDone;
                property OnMessageLoaded: TGetMessageEvent read GetMessageEvt write GetMessageEvt;
                property OnHeadersLoaded: TGetHeadersEvent read GetHeadersEvt write GetHeadersEvt;
                property OnAttachmentGetLocation: TAttachmentEvent read AttNameEvt write AttNameEvt;
                property OnAttachmentStored: TAttachmentEvent read AttStoredEvt write AttStoredEvt;
                property OnMessageData: TGMDataEvent read OMD write OMD;
                property WinsockStarted: Boolean read GetWinsockStarted write SetWinsockStarted;
                property Version: string read FVersion write DummyS;
                property TimeoutConnect;
                property TimeoutArp;
end;

type TUIDLManager=class(TObject)
private
        old,new: TStrings;
        fn: string;
        err: Boolean;
public
        constructor Create(filename: string);
        destructor Destroy;
        function ProcessMessageID(id: string): Boolean;
        procedure Error;
end;

implementation

{================================  TUIDLManager =======================}

constructor TUIDLManager.Create(filename: string);
begin
        err:=False;
        fn:=filename;
        old:=TStringList.Create;
        new:=TStringList.Create;
        try
                old.LoadFromFile(filename);
        except
                ;
        end;
end;

destructor TUIDLManager.Destroy;
begin
        if not err then
        begin
                try
                        new.SaveToFile(fn);
                except
                        {}
                end;
        end;
end;

function TUIDLManager.ProcessMessageID(id: string): Boolean;
begin
        new.Add(id);
        Result:=(old.IndexOf(id)=-1);
end;

procedure TUIDLManager.Error;
begin
        err:=True;
end;

{============================ GetMail =============================}

constructor GetMail.Create(AOwner: TComponent);
begin
        inherited Create(AOwner);
        MailStrings:=TStringList.Create;
        FUIDLList:=TStringList.Create;
        NewUIDL:=TStringList.Create;
        NewUIDL2:=TStringList.Create;
        DiffUIDL:=TStringList.Create;
        DiffUIDL2:=TStringList.Create;
        FVersion:='GetMail 1.3.13';
        Busy:=False;
        CurMsg:=0;
        CustomMessage:=IsAvailable;
        Port:=110;
end;

destructor GetMail.Destroy;
begin
        MailStrings.Free;
        FUIDLList.Free;
        NewUIDL.Free;
        NewUIDL2.Free;
        DiffUIDL.Free;
        DiffUIDL2.Free;
        inherited Destroy;
end;

procedure GetMail.IsAvailable(var Message: TMessage);
begin
        Busy:=False;
        If Assigned(FDone) then FDone(self);
end;

procedure GetMail.SetMailStrings(s: TStrings);
begin
        MailStrings.Assign(s);
end;

procedure GetMail.SetUIDLList(s: TStrings);
begin
        FUIDLList.Assign(s);
end;

procedure GetMail.DoMailInfo(info: GetMailInfo; add: string);
begin
        if Assigned(MailInfoEvt) then MailInfoEvt(self,info,add);
end;

procedure GetMail.SetPort(p:u_short);
begin
        if p=0 then Port:=110
        else Port:=p;
end;

procedure GetMail.DidConnect(Sender: TObject);
begin
        if CheckError then Exit;
        step:=0;
        {$IFDEF WIN32}
        lineout:='';
        {$ENDIF}
        DoMailInfo(gmServerConnected,Address);
        PartialLine:='';
        FSuccess:=False;
end;

procedure GetMail.DoDisconnect(Sender:TObject);
begin
        if CheckError then Exit;
        DoMailInfo(gmServerDisconnected,'');
        if not FSuccess then
        begin
                DoMailError(gmPrematureDisconnect,'Prematurely Disconnected');
                FError:=gmPrematureDisconnect;
        end;
        PostMessage(Handle,WM_AVAILABLE,0,0);
end;

procedure GetMail.MailAction(act: TGetMailAction);
begin
        case act of
        Get_Mail: DoGetMail;
        Cancel_GetMail:
                begin
                        FError:=gmCanceled;
                        CloseProc;
                end;
        end;
end;

procedure GetMail.Write(line: string);
var
        data: string;
begin
        data:=Copy(line,1,253)+chr(13)+chr(10);
        RawWrite(data);
end;

procedure GetMail.RawWrite(data: string);
begin
        if Aborted then Exit;
        DoMailInfo(gmTraceOut,data);
        while data<>'' do
        begin
                Application.ProcessMessages;
                if Aborted then Exit;
                Delete(data,1,SendBuf(PChar(@data[1]), Length(data)));
                if CheckError then Exit;
        end;
end;

procedure GetMail.DoGetMail;
begin
        if Busy then
        begin
		DoMailInfo(gmAlreadyBusy,'');
                Exit;
        end;
        OnTimeOut:=TimedOut;
        Aborted:=False;
        Busy:=True;
        FSuccess:=False;
        DLStarted:=False;
        EarlyQuit:=False;
        WinsockStarted:=True;
        if not WinsockStarted then
        begin
                DoMailError(gmWinsockNotInitialized,'Winsock not initiliazed');
                FError:=gmWinsockNotInitialized;
                CloseProc;
                Exit;
        end;
        OnConnected:=DidConnect;
        OnReadReady:=DoRead;
        OnDisconnected:=DoDisconnect;
        ProtocolInput:=POP3Login;
        CreateTCPSocket;
        if CheckError then Exit;
        if Address<>'' then FillAddress(Address)
        else
        begin
                DoMailInfo(gmResolvingAddress,Host);
                LookupName(Host);
                CheckError;
                Exit;
        end;
        FillPort(Port);
        Connect;
        if CheckError then Exit;
end;

procedure GetMail.LookupNameDone;
begin
        if CheckError then Exit;
        FillName;
        FillPort(Port);
        Address:=GetAddressString;
        DoMailInfo(gmAddressResolved,Address);
        Connect;
        if CheckError then Exit;
end;

procedure GetMail.TimedOut(Sender: TObject);
begin
        FError:=gmConnectTimeOut;
        DoMailError(gmCOnnectTimeOut,'Connection timed out');
        CloseProc;
end;

procedure GetMail.DoRead(Sender: TObject);
var
        linein,newline:         string;
        {$IFDEF WIN32}
        el:                     integer;
        {$ENDIF}
begin
        if OnHold then Exit;
        if Aborted then Exit;
        while True do
        begin
                if Aborted then Exit;
                linein:=RecvText;
                if CheckError then Exit;
                {$IFDEF WIN32}
                if Length(linein)=0 then Exit;
                linein:=PartialLine+linein;
                repeat
                        el:=Pos(#13+#10,linein);
                        if el<>0 then
                        begin
                                newline:=Copy(linein,1,el-1);
                                Delete(linein,1,el+1);
                                OnHold:=True;
                                ProtocolInput(newline);
                                OnHold:=False;
                                if Aborted then Exit;
                        end;
                until el=0;
                PartialLine:=linein;
                {$ENDIF}
        end;
end;

procedure GetMail.POP3Login(line:string);
var
        i: integer;
        s: string;
begin
        case step of
        0:
                begin
                        if line[1]='+' then
                        begin
                                Write('USER '+FID);
                                Inc(step);
                        end;
                        if line[1]='-' then
                        begin
                                DoMailError(gmAccessDenied,'Access Denied');
                                FError:=gmAccessDenied;
                                step:=100;
                                CloseProc;
                        end;
                end;
        1:
                begin
                        if line[1]='+' then
                        begin
                                DoMailInfo(gmLogin,'');
                                Write('PASS '+FPassword);
                                Inc(step);
                        end;
                        if line[1]='-' then
                        begin
                                DoMailError(gmAccessDenied,'Access Denied');
                                FError:=gmAccessDenied;
                                step:=100;
                                CloseProc;
                        end;
                end;
        2:
                begin
                        if line[1]='-' then
                        begin
                                DoMailError(gmAccessDenied,'Access Denied');
                                FError:=gmAccessDenied;
                                step:=100;
                                CloseProc;
                        end;
                        if line[1]='+' then
                        begin
                                DoMailInfo(gmAccessGranted,'Access Granted');
                                FMsgCnt:=0;
                                Write('UIDL');
                                Inc(step);
                        end;
                end;
        3:      {we are trying the UIDL command if not supported then go to STAT}
                begin
                        case line[1] of
                        '-':
                                begin
                                        UIDLSupported:=False;
                                        DoMailInfo(gmUIDLSupport,'0');
                                        Write('STAT');
                                        Inc(step);
                                end;
                        '+':
                                begin
                                        DoMailInfo(gmUIDLList,'');
                                        UIDLSupported:=True;
                                        DoMailInfo(gmUIDLSupport,'1');
                                        if DiffUIDL.Count>0 then DiffUIDL.Clear;
                                        if DiffUIDL2.Count>0 then DiffUIDL2.Clear;
                                        if NewUIDL.Count>0 then NewUIDL.Clear;
                                end;
                        '.':
                                begin
                                        if NewUIDL.Count>0 then
                                        begin
                                                NewUIDL.Clear;
                                                NewUIDL.Assign(NewUIDL2);
                                        end;
                                        FMsgCnt:=DiffUIDL.Count;
                                        if Message_Count=0 then
                                        begin
                                                if FUIDLList.Count>0 then FUIDLList.Clear;
                                                if NewUIDL.Count>0 then FUIDLList.Assign(NewUIDL);
                                                DoMailInfo(gmNumberMessage,'0');
                                                FSuccess:=True;
                                                Write('QUIT');
                                                step:=999;
                                        end
                                        else
                                        begin
                                                DoMailInfo(gmNumberMessage,IntToStr(Message_Count));
                                                step:=0;
                                                ProtocolInput:=POP3GetMail;
                                                DLStarted:=True;
                                                CurMsg:=0;
                                                POP3GetMail('');
                                        end;
                                end;
                        else
                                begin
                                        NewUIDL.Add(line);
                                        s:=line;
                                        Delete(s,1,Pos(' ',s));
                                        if (FUIDLList.IndexOf(s)=-1) and (DiffUIDL2.IndexOf(s)=-1) then
                                        begin
                                                DiffUIDL.Add(line);
                                                DiffUIDL2.Add(s);
                                        end;
                                        NewUIDL2.Add(s);
                                end;
                        end;
                end;
        4:      {this only runs if the UIDL command fails}
                begin
                        case line[1] of
                        '-':
                                begin
                                        DoMailError(gmProtocolError,'Unexpected response: '+line);
                                        FError:=gmProtocolError;
                                        step:=100;
                                        CloseProc;
                                end;
                        '+':
                                begin
                                        for i:=5 to Length(line) do
                                        begin
                                                if line[i]=' ' then
                                                begin
                                                        try
                                                                FMsgCnt:=StrToInt(Copy(line,5,i-5));
                                                        except
                                                                FMsgCnt:=0;
                                                        end;
                                                        DoMailInfo(gmNumberMessage,IntToStr(FMsgCnt));
                                                        break;
                                                end;
                                        end;
                                        if Message_Count=0 then
                                        begin
                                                FSuccess:=True;
                                                Write('QUIT');
                                                Inc(step);
                                        end
                                        else
                                        begin
                                                step:=0;
                                                ProtocolInput:=POP3GetMail;
                                                DLStarted:=True;
                                                CurMsg:=0;
                                                POP3GetMail('');
                                        end;
                                end;
                        end;
                end;
        end;
end;

procedure GetMail.ProcessMIMEHeaders(line: string);
var
        s,t: string;
        i: integer;
        {$IFDEF WIN32}
        v: string;
        ex: Boolean;
        {$ENDIF}
begin
        s:='';
        {$IFDEF WIN32}
        v:=AttRec.Description;
        ExtractHeader(line,'Content-Description: ',v);
        AttRec.Description:=v;
                {$ENDIF}
        if ExtractHeader(line,'Content-Disposition: ',s) then
        begin
                i:=Pos(';',s);
                if i>0 then
                begin
                        AttRec.Disposition:=Copy(s,1,i-1);
                        t:=ExtractString(s,'filename');
                        if t<>'' then AttRec.Name:=t;
                end
                else AttRec.Disposition:=s;
        end;
        {$IFDEF WIN32}
        v:=AttRec.ContentID;
        ExtractHeader(line,'Content-ID: ',v);
        AttRec.ContentID:=v;
                {$ENDIF}
        {$IFDEF WIN32}
        v:=mtype;
        ex:=ExtractHeader(line,'Content-Type: ',v);
        mtype:=v;
        if ex then
                {$ENDIF}
        begin
                if Pos(';',mtype)>0 then AttRec.MimeType:=Copy(mtype,1,Pos(';',mtype)-1)
                else AttRec.MimeType:=mtype;
                if Pos('multipart/',Lowercase(AttRec.MIMEType))>0 then
                begin
                        Inc(NestingLevel);{we're in trouble if >32}
                        Multipart:=True;
                        MimeBoundary[NestingLevel]:=ExtractString(mtype,'boundary');
                end;
        end;
        {next line is to catch split headers fixed v1.3}
        {fixed again 1.3.9 :-(}
        if Multipart and (MimeBoundary[NestingLevel]='') then
          MimeBoundary[NestingLevel]:=ExtractString(line,'boundary');
        if ExtractHeader(line,'Content-Transfer-Encoding: ',content) then
        begin
                if Pos('quoted',Lowercase(content))>0 then MainEncoding:=QuotedPrintable;
                if Pos('base64',Lowercase(content))>0 then MainEncoding:=Base64;
                if Pos('7bit',Lowercase(content))>0 then MainEncoding:=Plain;
                if Pos('8bit',Lowercase(content))>0 then MainEncoding:=Plain;
                if Pos('binary',Lowercase(content))>0 then MainEncoding:=Plain;
                t:=ExtractString(line,'name');
                if t<>'' then AttRec.name:=t;
        end;
        {$IFDEF WIN32}
        v:=AttRec.ContentID;
        ExtractHeader(line,'Content-ID: ',v);
        AttRec.ContentID:=v;
        v:=AttRec.Disposition;
        ExtractHeader(line,'Content-Disposition: ',v);
        AttRec.Disposition:=v;
                {$ENDIF}
end;

procedure GetMail.POP3MessageDone;
begin
        if assigned(GetMessageEvt) then GetMessageEvt(self);
        Mail_Text.Clear;
        FFrom:='';
        FSubject:='';
        FDate:='';
        FTo:='';
        FSize:=0;
        if Opt_Delete then
        begin
                Write('DELE '+IntToStr(curMsg));
                Opt_Delete:=False;
                step:=3;
                Exit;
        end;
        AskForNextMessage;
end;

procedure GetMail.AskForNextMessage;
begin
        if (not NextMessage) or EarlyQuit then
        begin
                FSuccess:=True;
                Write('QUIT');
                step:=4;
                Exit;
        end;
        FMNum:=curMsg;
        if Opt_Preview then
        begin
                Write('TOP '+IntToSTr(CurMsg)+' 0');
                step:=5;
        end
        else
        begin
                Write('RETR '+IntToStr(CurMsg));
                step:=1;
        end;
end;

procedure GetMail.NewMimeSection;
begin
        Inc(boundaries);
        step:=9;
        MainEncoding:=Plain;
        AttRec.MimeType:='text/plain';
        AttRec.Description:='';
        AttRec.ContentID:='';
        AttRec.Disposition:='';
        AttRec.Name:='';
        AttRec.Location:='';
        AttRec.Size:=0;
        AttRec.Stored:=False;
        Multipart:=False;
end;

function GetMail.NextMessage: Boolean;
var
        s: string;
begin
        if not UIDLSupported then
        begin
                 Inc(CurMsg);
                 Result:=(CurMsg<=Message_Count);
        end
        else
        begin
                if DiffUIDL.Count=0 then Result:=False
                else
                begin
                        s:=DiffUIDL[0];
                        Delete(s,Pos(' ',s),999);
                        CurMsg:=StrToInt(s);
                        DiffUIDL.Delete(0);
                        Result:=True;
                end;
        end;
end;

procedure GetMail.POP3GetMail(line: string);
var
        i:                      integer;
        size:                   string;
begin
        case step of
        0:
                begin
                        NextMessage;
                        Mail_Text.Clear;
                        boundaries:=0;
                        FFrom:='';
                        FSubject:='';
                        FDate:='';
                        FTo:='';
                        FSize:=0;
                        FMNum:=curMsg;
                        if Opt_Preview then
                        begin
                                Write('TOP '+IntToStr(CurMsg)+' 0');
                                step:=5;
                        end
                        else
                        begin
                                Write('RETR '+IntToStr(CurMsg));
                                step:=1;
                        end;
                end;
        1: {after RETR n}
                begin
                        if line[1]='-' then
                        begin
                                DoMailError(gmProtocolError,'Unexpected response: '+line);
                                FError:=gmProtocolError;
                                step:=100;
                                CloseProc;
                                Exit;
                        end;
                        step:=2; {start new message}
                        size:=Copy(line,1,Pos(' octets',line)-1);{Linux bug fix!}
                        for i:=Length(size) downto 1 do
                        begin
                                if (size[i]<'0') or (size[i]>'9') then break;
                        end;
                        size:=Copy(size,i+1,99);
                        FSize:=0;
                        DoMailInfo(gmMessageSize,size);
                        ProcHeaders:=True;
                        MultiPart:=False;
                        MainEncoding:=plain;
                        NestingLevel:=0;
                        boundaries:=0;
                        AttRec.MimeType:='text/plain';
                        AttRec.Description:='';
                        AttRec.ContentID:='';
                        AttRec.Disposition:='';
                        AttRec.Name:='';
                        AttRec.Location:='';
                        AttRec.Size:=0;
                        AttRec.Stored:=False;
                end;
        2: {after +OK on RETR n}
                begin
                        if (line='.') then
                        begin
                                Pop3MessageDone;
                                Exit;
                        end;
                        FSize:=FSize+Length(line)+2;
                        DoMailInfo(gmGettingMessage,IntToStr(FSize));
                        if ProcHeaders then
                        begin
                                if line=''then
                                begin
                                        ProcHeaders:=False;
                                        if MultiPart then step:=12
                                        else
                                        begin
                                                if Copy(Lowercase(AttRec.MimeType),1,4)='text' then step:=2
                                                else
                                                begin
                                                        step:=11;
                                                        AttSize:=0;
                                                        if Assigned(AttNameEvt) then AttNameEvt(self,@AttRec);
                                                        if AttRec.Location='' then AttSkip:=True
                                                        else
                                                        begin
                                                                attfile:=FileCreate(AttRec.Location);
                                                                if attfile>0 then AttSkip:=False
                                                                else AttSkip:=True;
                                                                AttEncoding:=MainEncoding;
                                                        end;
                                                end;
                                        end;
                                end;
                                ExtractHeader(line,'Subject: ',FSubject);
                                ExtractHeader(line,'Date: ',FDate);
                                ExtractHeader(line,'From: ',FFrom);
                                ExtractHeader(line,'To: ',FTo);
                                ExtractHeader(line,'X-UIDL: ',FUIDL);
                                ExtractHeader(line,'Message-ID: ',FMsg_ID);
                                ProcessMimeHeaders(line);
                        end;
                        {bug lurking here!!!}
                        if not ProcHeaders and (MainEncoding=QuotedPrintable) then
                        begin
                                if not QuotedDecode(line) then Exit;{partial line}
                        end;
                        if ProcHeaders then line:=CheckRFC1522(line);
                        try
                                if Assigned(OMD) then OMD(self,line);
                                Mail_Text.Add(line);
                        except
                                if assigned(GetMessageEvt) then GetMessageEvt(self);
                                Mail_Text.Clear;
                                Mail_Text.Add(line);
                        end;
                end;
        3: {after DELE n}
                begin
                        if line[1]='-' then
                        begin
                                DoMailError(gmProtocolError,'Unexpected response: '+line);
                                FError:=gmProtocolError;
                                step:=100;
                                CloseProc;
                                Exit;
                        end;
                        AskForNextMessage;
                end;
        4: {after QUIT}
                begin
                        if line[1]='-' then
                        begin
                                DoMailError(gmProtocolError,'Unexpected response: '+line);
                                FError:=gmProtocolError;
                                step:=100;
                                CloseProc;
                                Exit;
                        end
                        else FSuccess:=True;
                        if not EarlyQuit then
                        begin
                                if FUIDLList.Count>0 then FUIDLList.Clear;
                                if NewUIDL.Count>0 then FUIDLList.Assign(NewUIDL);
                        end;
                end;
        5: {after TOP n 0}
                begin
                        if line[1]='-' then
                        begin
                                DoMailError(gmProtocolError,'Unexpected response: '+line);
                                FError:=gmProtocolError;
                                step:=100;
                                CloseProc;
                                Exit;
                        end
                        else
                        begin
                                size:=Copy(line,1,Pos(' octets',line)-1);{Linux bug fix!}
                                for i:=Length(size) downto 1 do
                                begin
                                        if (size[i]<'0') or (size[i]>'9') then break;
                                end;
                                size:=Copy(size,i+1,99);
                                FSize:=0;
                                DoMailInfo(gmMessageSize,size);
                                step:=6;
                        end;
                end;
        6: {after +OK on TOP n 0}
                begin
                        if line='.' then
                        begin
                                if assigned(GetHeadersEvt) then GetHeadersEvt(self);
                                Mail_Text.Clear;
                                FFrom:='';
                                FSubject:='';
                                FDate:='';
                                FTo:='';
                                FSize:=0;
                                if Opt_Delete then
                                begin
                                        Write('DELE '+IntToStr(curMsg));
                                        Opt_Delete:=False;
                                        step:=3;
                                        Exit;
                                end;
                                if not Opt_Skip then
                                begin
                                        Write('RETR '+IntToStr(curMsg));
                                        step:=1;
                                        Exit;
                                end;
                                Opt_Skip:=False;
                                if (not NextMessage) or EarlyQuit then
                                begin
                                        FSuccess:=True;
                                        Write('QUIT');
                                        step:=4;
                                        Exit;
                                end;
                                FMNum:=curMsg;
                                Write('TOP '+IntToSTr(CurMsg)+' 0');
                                step:=5;
                                Exit;
                        end;
                        try
                                Mail_Text.Add(line);
                                FSize:=FSize+Length(line);
                                ExtractHeader(line,'Subject: ',FSubject);
                                ExtractHeader(line,'Date: ',FDate);
                                ExtractHeader(line,'From: ',FFrom);
                                ExtractHeader(line,'To: ',FTo);
                                ExtractHeader(line,'X-UIDL: ',FUIDL);
                                ExtractHeader(line,'Message_ID: ',FMsg_ID);
                        except
                                {}
                        end;
                end;
        8: {attachment body}
                begin
                        FSize:=FSize+Length(line)+2;
                        DoMailInfo(gmGettingMessage,IntToStr(FSize));
                        if Pos('--'+MIMEBoundary[NestingLevel]+'--',line)>0 then
                        begin
                                if not AttSkip then FileClose(attfile);
                                AttRec.Size:=AttSize;
                                if Assigned(AttStoredEvt) then AttStoredEvt(self,@AttRec);
                                Dec(NestingLevel);
                                if NestingLevel=0 then step:=2
                                else step:=12;
                                Exit;
                        end;
                        if Pos('--'+MIMEBoundary[NestingLevel],line)>0 then
                        begin
                                if not AttSkip then FileClose(attfile);
                                AttRec.Size:=AttSize;
                                if Assigned(AttStoredEvt) then AttStoredEvt(self,@AttRec);
                                NewMimeSection;
                                Exit;
                        end;
                        if not AttSkip then
                        begin
                                case AttEncoding of
                                plain,QuotedPrintable: Store_Plain(line);
                                base64: Store_base64(line);
                                end;
                        end;
                end;
        9: {start multipart section headers}
                begin
                        FSize:=FSize+Length(line)+2;
                        DoMailInfo(gmGettingMessage,IntToStr(FSize));
                        ProcessMIMEHeaders(line);
                        if line='' then
                        begin
                                if Multipart then step:=12
                                else
                                begin
                                        if (boundaries<>1) or (Lowercase(Copy(AttRec.MIMEType,1,4))<>'text') then
                                        begin
                                                if Assigned(AttNameEvt) then AttNameEvt(self,@AttRec);
                                                if AttRec.Location='' then AttSkip:=True
                                                else
                                                begin
                                                        attfile:=FileCreate(AttRec.Location);
                                                        if attfile>0 then AttSkip:=False
                                                        else AttSkip:=True;
                                                        AttEncoding:=MainEncoding;
                                                end;
                                                AttEncoding:=MainEncoding;
                                                AttSize:=0;
                                                Step:=8;
                                        end
                                        else Step:=10;
                                end;
                        end;
                end;
        10: {first part of multipart, body}
                begin
                        FSize:=FSize+Length(line)+2;
                        DoMailInfo(gmGettingMessage,IntToStr(FSize));
                        if Pos('--'+MIMEBoundary[NestingLevel]+'--',line)>0 then
                        begin
                                Dec(NestingLevel);
                                if NestingLevel=0 then step:=2
                                else step:=12;
                                Exit;
                        end;
                        if Pos('--'+MIMEBoundary[NestingLevel],line)>0 then
                        begin
                                NewMimeSection;
                                Exit;
                        end;
                        if not QuotedDecode(line) then Exit;
                        try
                                if Assigned(OMD) then OMD(self,line);
                                Mail_Text.Add(line);
                        except
                                if assigned(GetMessageEvt) then GetMessageEvt(self);
                                Mail_Text.Clear;
                                Mail_Text.Add(line);
                        end;
                end;
        11: {one part which is not text}
                begin
                        FSize:=FSize+Length(line)+2;
                        DoMailInfo(gmGettingMessage,IntToStr(FSize));
                        if (line='.') then
                        begin
                                if not AttSkip then FileClose(attfile);
                                AttRec.Size:=AttSize;
                                if Assigned(AttStoredEvt) then AttStoredEvt(self,@AttRec);
                                Pop3MessageDone;
                                Exit;
                        end;
                        if AttSkip then Exit;
                        case MainEncoding of
                        plain,QuotedPrintable: Store_Plain(line);
                        Base64: Store_Base64(line);
                        end;
                end;
        12:{start multipart, look for boundary}
                begin
                        FSize:=FSize+Length(line)+2;
                        DoMailInfo(gmGettingMessage,IntToStr(FSize));
                        if Pos('--'+MIMEBoundary[NestingLevel]+'--',line)>0 then
                        begin
                                Dec(NestingLevel);
                                if NestingLevel=0 then step:=2;
                                Exit;
                        end;
                        if Pos('--'+MimeBoundary[NestingLevel],line)>0 then NewMimeSection;
                end;
        end;
end;

procedure GetMail.Store_Plain(line: string);
begin
        if AttEncoding=QuotedPrintable then
        begin
                if not QuotedDecode(line) then Exit;
        end;
        {$IFDEF WIN32}
        FileWrite(attfile,line[1],Length(line));
                {$ENDIF}
        Inc(AttSize,Length(line));
        line:=#13+#10;
        FileWrite(attfile,line[1],2);
end;

function GetMail.QuotedDecode(var line: string): Boolean;
var
        i,j,hex:      integer;
begin
        j:=0; {values 0-plain 1-first hex 2-second hex}
        for i:=1 to Length(line) do
        begin
                case j of
                0:
                        begin
                                if line[i]<>'=' then tmpline:=tmpline+line[i]
                                else j:=1;
                        end;
                1:
                        begin
                                if line[i]<='9' then hex:=(Ord(line[i])-Ord('0'))*16
                                else hex:=(Ord(line[i])-55)*16;
                                j:=2;
                        end;
                2:
                        begin
                                if line[i]<='9' then hex:=hex+(Ord(line[i])-Ord('0'))
                                else hex:=hex+Ord(line[i])-55;
                                tmpline:=tmpline+Chr(hex);
                                j:=0;
                        end;
                end;
        end;
        if j=1 then Result:=False {soft break}
        else
        begin
                Result:=True;
                line:=tmpline;
                tmpline:='';
        end;
end;

procedure GetMail.QuitAsap;
begin
        if DLStarted then EarlyQuit:=True
        else MailAction(Cancel_GetMail);
end;

procedure GetMail.Store_base64(line: string);
var
        a1:                             array[1..4] of byte;
        b1:                             array[1..3] of byte;
        j:                              integer;
        byte_ptr,real_bytes:            integer;
begin
        byte_ptr:=0;
        for j:=1 to Length(line) do
        begin
                Inc(byte_ptr);
                case line[j] of
                'A'..'Z': a1[byte_ptr]:=Ord(line[j])-65;
                'a'..'z': a1[byte_ptr]:=Ord(line[j])-71;
                '0'..'9': a1[byte_ptr]:=Ord(line[j])+4;
                '+': a1[byte_ptr]:=62;
                '/': a1[byte_ptr]:=63;
                '=': a1[byte_ptr]:=64;
                end;
                if byte_ptr=4 then
                begin
                        byte_ptr:=0;
                        real_bytes:=3;
                        if a1[1]=64 then real_bytes:=0;
                        if a1[3]=64 then
                        begin
                                a1[3]:=0;
                                a1[4]:=0;
                                real_bytes:=1;
                        end;
                        if a1[4]=64 then
                        begin
                                a1[4]:=0;
                                real_bytes:=2;
                        end;
                        b1[1]:=a1[1]*4+(a1[2] div 16);
                        b1[2]:=(a1[2] mod 16)*16+(a1[3]div 4);
                        b1[3]:=(a1[3] mod 4)*64 +a1[4];
                        FileWrite(attfile,b1,real_bytes);
                        Inc(AttSize,real_bytes);
                end;
        end;
end;

function GetMail.ExtractHeader(line: string;header: string;var stringvar:string):Boolean;
begin
        if CompareText(header,Copy(line,1,Length(header)))=0 then
        begin
                stringvar:=Copy(line,Length(header)+1,Length(line));
                stringvar:=CheckRFC1522(stringvar);
                Result:=True;
        end
        else Result:=False;
end;

function GetMail.CheckRFC1522(s: string): string;
var
        i,s1,s2,s3: integer;
        t,v: string;
        Encoding: char;
        hex,step: integer;
begin
        s1:=Pos('=?',s);
        if s1>0 then
        begin
                for s2:=Length(s)-1 downto 1 do
                begin
                        if Copy(s,s2,2)='?=' then Break;
                end;
        end;
        if (s1=0) or (s2=1) then
        begin
                Result:=s;
                Exit;
        end;
        t:=Copy(s,s1+2,s2-2-s1);
        s3:=Pos('?',t);
        Delete(t,1,s3);
        Encoding:=t[1];
        Delete(t,1,2);
        v:='';
        step:=0;
        case Encoding of
        'Q':
                while t<>'' do
                begin
                        case step of
                        0:
                                begin
                                        case t[1] of
                                        '_': v:=v+' ';
                                        '=': step:=1;
                                        else v:=v+t[1];
                                        end;
                                end;
                        1:
                                begin
                                        if t[1]<='9' then hex:=(Ord(t[1])-Ord('0'))*16
                                        else hex:=(Ord(t[1])-55)*16;
                                        step:=2;
                                end;
                        2:
                                begin
                                        if t[1]<='9' then hex:=hex+(Ord(t[1])-Ord('0'))
                                        else hex:=hex+Ord(t[1])-55;
                                        v:=v+Chr(hex);
                                        step:=0;
                                end;
                        end;
                        Delete(t,1,1);
                end;
        end;
        Result:=Copy(s,1,s1-1)+v+Copy(s,s2+2,999);
end;

function GetMail.IsHeader(name: string; var value: string): Boolean;
var
        i:      integer;
begin
        name:=name+': ';
        for i:=0 to Mail_Text.Count-1 do
        begin
                if ExtractHeader(Mail_Text[i],name,value) then
                begin
                        Result:=True;
                        Exit;
                end;
        end;
        Result:=False;
end;

function GetMail.ExtractString(line:string;name:string): string;
var
        start,i : integer;
begin
        name:=Lowercase(name)+'="';
        start:=Pos(name,Lowercase(line));
        if start<>0 then
        begin
                start:=start+Length(name);
                for i:=start+1 to Length(line) do
                begin
                        if line[i]='"' then
                        begin
                                Result:=Copy(line,start,i-start);
                                Exit;
                        end;
                end;
        end
        else Result:='';
end;

function GetMail.CheckError: Boolean;
var
        errs: string;
begin
        if Aborted then Exit;
        if LastError=0 then
        begin
                Ferror:=gmNone;
                Result:=False;
        end
        else
        begin
                case LastError of
                WSANOTINITIALISED:
                        begin
                                FError:=gmWinsockNotInitialized;
                                errs:='Winsock not initialized';
                        end;
                WSAENETDOWN:
                        begin
                                FError:=gmNetworkDown;
                                errs:='Network down';
                        end;
                WSAEACCES:
                        begin
                                FError:=gmInvalidAddress;
                                errs:='Invalid address specified';
                        end;
                WSAEFAULT,WSAENOTSOCK,WSAEOPNOTSUPP,WSAESHUTDOWN,WSAEMSGSIZE,WSAENOTCONN,
                WSAEADDRINUSE,WSAEINPROGRESS,WSAEINTR,WSAEAFNOSUPPORT,WSAEINVAL,WSAEISCONN:
                        begin
                                FError:=gmInternalError;
                                errs:='Unexpected internal error in component';
                        end;
                WSAETIMEDOUT:
                        begin
                                FError:=gmConnectTimeout;
                                errs:='timeout';
                        end;
                WSAEMFILE:
                        begin
                                FError:=gmOutofSockets;
                                errs:='Out of sockets';
                        end;
                WSAENETUNREACH:
                        begin
                                FError:=gmNetworkUnreachable;
                                errs:='Network unreachable';
                        end;
                WSAEADDRNOTAVAIL:
                        begin
                                FError:=gmAddressNotAvailable;
                                errs:='Address not available';
                        end;
                WSAECONNREFUSED:
                        begin
                                FError:=gmConnectionRefused;
                                errs:='Connection Refused';
                        end;
                WSAENETRESET,WSAENOBUFS:
                        begin
                                FError:=gmGeneralWinsockError;
                                errs:='General Winsock Error';
                        end;
                WSAECONNABORTED:
                        begin
                                Ferror:=gmConnAborted;
                                errs:='Connection aborted due to timeout or other failure';
                        end;
                WSAECONNRESET:
                        begin
                                Ferror:=gmConnReset;
                                errs:='Connection reset by remote side';
                        end;
                WSAHOST_NOT_FOUND,WSATRY_AGAIN,WSANO_RECOVERY,WSANO_DATA:
                        begin
                                FError:=gmAddressResolutionError;
                                errs:='Address resolution error';
                        end;
                WSAEHOSTUNREACH:
                        begin
                                FError:=gmHostUnreachable;
                                errs:='Host Unreachable';
                        end;
                else
                        begin
                                FError:=gmUnknown;
                                errs:='Unknown Error';
                        end;
                end;
                DoMailError(FError,errs);
                Result:=True;
                CloseProc;
        end;
end;

procedure GetMail.DoMailError(error: GetMailError; add: string);
begin
        if Assigned(MailErrorEvt) then MailErrorEvt(self,error,add);
end;

procedure GetMail.CloseProc;
begin
        if Aborted then Exit;
        Aborted:=True;
        Disconnect;
        PostMessage(Handle,WM_AVAILABLE,0,0);
end;

function GetMail.RecvText : string;
var
        n		: integer;
        {$IFDEF WIN32}
        buf:            array[0..2048] of char;
        {$ENDIF}
begin
        {$IFDEF WIN32}
        n:=RecvBuf(buf,2048);
        buf[n]:=#0;
        Result:=buf;
        {$ENDIF}
end;

function GetMail.GetWinsockStarted: Boolean;
begin
        Result:=WinsockInitialized;
end;

procedure GetMail.SetWinsockStarted(b: Boolean);
begin
        if b then InitializeWinsock
        else UnloadWinsock;
end;

end.

