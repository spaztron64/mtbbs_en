unit Inetmail;
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
{
Modification History:
=====================
1.3.1           10/14/95        Added support for quoted printable encoding
1.3.2           11/14/95        Added AddAttachment method, which allows
                                user to specify MimeType and desired
                                encoding.
1.3.3           11/27/95        Added UUEncoding
                                Fixed bug in Quoted-Printable which deleted
                                blank lines.
1.3.4           12/1/95         Added separate To, cc and Bcc Lists
                                Added StayConnected property
1.3.5           2/19/96         Changed line limit from 253 to 998
1.3.6           4/14/96         Added SendingMail for last portion of message
1.3.7           5/3/96          Fixed Quoted Printable Encoding, now works 100%
                                Added encoding of headers per RFC 1522
                                Added MessageSize notification
                                Fixed Bug with Atts array (range check)
1.3.8           5/12/96         Added TimeOut functions
                                Rearranged Error handling
                                Eliminated Status property, replaced w/ Busy
1.3.9           5/30/96         Fixed so that plain text msgs sent as plain text.
                                Clear all address properties at end of transaction.
}

interface

uses StarSock,Classes,WinTypes,SysUtils,Messages;

const SM_VERSION='1.3.9';

const
        WM_AVAILABLE=WM_USER+2;


type SendMailInfo=(smServerConnected,smTraceIn,smTraceOut,
                   smServerDisconnected,smMessageAccepted,
                   smAttachmentName,smAttachmentSize,smAttachmentBytes,
                   smBadAddress,smRecipient,smMessageSize,smSendingMessage,
                   smBadAttachment,smAlreadyBusy,
                   smAddressResolved,smResolvingAddress
                   );

type SendMailError=(smNone,smWInsockNotInitialized,smNetworkDown,smInvalidAddress,smInternalError,
                    smGeneralWinsockError,smConnAborted,smConnReset,smConnectTimeOut,
                    smOutofSockets,smNetworkUnreachable,smAddressNotAvailable,
                    smConnectionRefused,smProtocolError,smCanceled,smUnknown,
                    smAddressResolutionError,smPrematureDisconnect,smMailDestinationError,
                    smHostUnreachable);

type TMailAction=(None,Send_Mail,Cancel_SendMail);

TSendMailEvent= procedure (Sender: TObject; var data:string) of object;

TSendMailInfoEvent = procedure (Sender : TObject; info: SendMailInfo; addinfo: string) of object;
TSendMailErrorEvent=procedure(Sender: TObject;error: SendMailError; addinfo: string) of object;

type TMailEncoding=(meDefault,meMimeBase64,meMimeQuoted,meMimePlain,meUUencode);

type TSendMailAttachment=record
        Name: string[255];
        Encoding: TMailEncoding;
        MimeType: string[80];
        MimeDisposition: string[30];
        MimeDescription: string[255];
        Location: string[255];
end;

type TSendMailAttachmentPtr=^TSendMailAttachment;

type SendMail = class(TStarSocket)
        private
                step: integer;
                PartialLine: string;
                MailInfoEvt:            TSendMailInfoEvent;
                MailErrorEvt:           TSendMailErrorEvent;
                FFeed:                  TSendMailEvent;
                FReply:                 string;
                FFName:                 string;
                FTAddress:              string;
                FTName:                 string;
                FSubject:               string;
                MailStrings:            TStrings;
                ccStrings:              TStrings;
                BccStrings:             TStrings;
                ToStrings:              TStrings;
                AttachStrings:          TStrings;
                HeaderList:             TStrings;
                FAction:                TMailAction;
                FError:                 SendMailError;
                Busy:                   Boolean;
                FDone:                  TNotifyEvent;
                datastep,datanum,dataline: integer;
                current_list,num_list:  integer;
                boundary:               string;
                FeedLine:               string;
                ContinueFeeding:        Boolean;
                QuotedEncode:           Boolean;
                Atts: array[1..256] of TSendMailAttachmentPtr;
                AttNum:                 integer;
                KeepOpen,OnHold,Aborted:Boolean;
                lastaddress: string;
                substep: integer;
                ToOffset,ccOffset,BccOffset: integer;
                curqlen: integer;
                FSuccess: Boolean;
                FVersion,DummyS: string;
                function CheckError: Boolean;
                function RecvText : string;
                procedure Write(line: string);
                procedure RawWrite(data: string);
                procedure DidConnect(Sender: TObject);
                procedure DoDisconnect(Sender:TObject);
                procedure DoRead(Sender:TObject);
                procedure MailAction(act: TMailAction);
                procedure DoMailInfo(info: SendMailInfo; add: string);
                procedure DoMailError(error: SendMailError; add: string);
                procedure NewLineRead(line: string);
                procedure Base64Send(filename,Name,MimeType,Description,Disposition: string);
                procedure PlainSend(filename,Name,MimeType,Description,Disposition: string);
                procedure QuotedSend(filename,Name,MimeType,Description,Disposition: string);
                procedure UUEncodeSend(filename,Name,MimeType,Description,Disposition: string);
                procedure SetMailStrings(s:TStrings);
                procedure SetccStrings(s:TStrings);
                procedure SetBccStrings(s:TStrings);
                procedure SetToStrings(s:TStrings);
                procedure SetAttStrings(s:TStrings);
                procedure SetHeaderList(s:TStrings);
                procedure DoSendMail;
                procedure IsAvailable(var Message: TMessage);message WM_AVAILABLE;
                function EncodingNeeded(buf: PChar): Boolean;
                procedure QuotedSendBuffer(buf: PChar;size: LongInt);
                procedure SplitAddress(s: string;var address,name: string);
                procedure CloseProc;
                procedure WriteBuffer(Buf: PChar;BufLen: integer);
                function CheckHeaderString(s: string): string;
                function CheckHeader(s: string): string;
                procedure UUEncode(buf: PChar;size: integer);
                procedure SetWinsockStarted(b: Boolean);
                function GetWinsockStarted: Boolean;
                procedure TimedOut(Sender: TObject);
        protected
                constructor Create(AOwner: TComponent);override;
                destructor Destroy;override;
                function RecommendEncodingMethod(filename: string): TMailEncoding;
                procedure LookupNameDone;override;
        public
                property Success: Boolean read FSuccess;
                procedure AddAttachment(att: TSendMailAttachment);
                procedure ClearAttachments;
                property Error: SendMailError read FError;
        published
                property SMTP_Server: string read Server write SetServer;
                property FROM_Name: string read FFName write FFName;
                property FROM_Address: string read FReply write FReply;
                property TO_Name: string read FTName write FTName;
                property TO_Address: string read FTAddress write FTAddress;
                property Subject: string read FSubject write FSubject;
                property SMTP_Port: u_short read Port write Port;
                property Action: TMailAction read FAction write MailAction;
                property OnMailInfo: TSendMailInfoEvent read MailInfoEvt write MailInfoEvt;
                property OnMailError: TSendMailErrorEvent read MailErrorEvt write MailErrorEvt;
                property MailText: TStrings read MailStrings write SetMailStrings;
                property Listcc: TStrings read ccStrings write SetccStrings;
                property ListBcc: TStrings read bccStrings write SetBccStrings;
                property ListTo: TStrings read ToStrings write SetToStrings;
                property Attachments: TStrings read AttachStrings write SetAttStrings;
                property Headers: TStrings read HeaderList write SetHeaderList;
                property OnFeedData: TSendMailEvent read FFeed write FFeed;
                property KeepConnectionOpen: Boolean read KeepOpen write KeepOpen;
                property WinsockStarted: Boolean read GetWinsockStarted write SetWinsockStarted;
                property Version: string read FVersion write DummyS;
                property TimeoutConnect;
                property TimeoutArp;
                property OnDone: TNotifyEvent read FDone write FDone;
end;

const
  _Code64: string[64]=('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/');
  _UUCode: string[64]=(' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_');
  CodeQuoted: string[16]=('0123456789ABCDEF');

implementation

uses Forms
;


constructor SendMail.Create(AOwner: TComponent);
var
        i: integer;
begin
        inherited Create(AOwner);
        MailStrings:=TStringList.Create;
        ccStrings:=TStringList.Create;
        BccStrings:=TStringList.Create;
        ToStrings:=TStringList.Create;
        AttachStrings:=TStringList.Create;
        HeaderList:=TStringList.Create;
        CustomMessage:=IsAvailable;
        port:=25;
        FVersion:='SendMail '+SM_VERSION;
        Busy:=False;
        for i:=1 to 256 do Atts[i]:=nil;
end;

destructor SendMail.Destroy;
var
        i: integer;
begin
        MailStrings.Free;
        ccStrings.Free;
        BccStrings.Free;
        ToStrings.Free;
        HeaderList.Free;
        AttachStrings.Free;
        for i:=1 to 256 do
        begin
                if Assigned(Atts[i]) then FreeMem(Atts[i],Sizeof(TSendMailAttachment));
        end;
        inherited Destroy;
end;

procedure SendMail.AddAttachment(att: TSendMailAttachment);
var
        i: integer;
begin
        i:=Attachments.Count+1;
        if i>256 then Exit;
        GetMem(Atts[i],Sizeof(TSendMailAttachment));
        Atts[i]^:=att;
        Attachments.Add(att.Location);
end;

procedure SendMail.ClearAttachments;
var
        i: integer;
begin
        for i:=1 to 256 do
        begin
                if Assigned(Atts[i]) then
		begin
			FreeMem(Atts[i],sizeof(TSendMailAttachment));
			Atts[i]:=nil;
		end;
        end;
        if Attachments.Count>0 then Attachments.Clear;
end;

procedure SendMail.IsAvailable(var Message: TMessage);
begin
        Busy:=False;
        if Assigned(FDone) then FDone(self);
end;

{==================  core routines =====================}

procedure SendMail.DoMailInfo(info: SendMailInfo; add: string);
begin
        if Assigned(MailInfoEvt) then MailInfoEvt(self,info,add);
end;

procedure SendMail.DoMailError(error: SendMailError; add: string);
begin
        if Assigned(MailErrorEvt) then MailErrorEvt(self,error,add);
end;

procedure SendMail.Write(line: string);
var
        data: string;
begin
        data:=Copy(line,1,253)+chr(13)+chr(10);
        RawWrite(data);
end;

procedure SendMail.RawWrite(data: string);
begin
        if Aborted then Exit;
        DoMailInfo(smTraceOut,data);
        while data<>'' do
        begin
                Application.ProcessMessages;
                if Aborted then Exit;
                Delete(data,1,SendBuf(PChar(@data[1]), Length(data)));
                if CheckError then Exit;
        end;
end;

procedure SendMail.WriteBuffer(Buf: PChar;BufLen: integer);
var
        totsent: integer;
begin
        if Aborted then Exit;
        totsent:=0;
        {$IFDEF WIN32}
        DoMailInfo(smTraceOut,Buf);
        {$ENDIF}
        while totsent<BufLen do
        begin
                Application.ProcessMessages;
                if Aborted then Exit;
                Inc(totsent,SendBuf(Buf+totsent,BufLen-totsent));
                if CheckError then Exit;
        end;
end;

{================== event handlers ====================================}
procedure SendMail.DidConnect(Sender: TObject);
begin
        if CheckError then Exit;
        step:=0;
        DoMailInfo(smServerConnected,Address);
        PartialLine:='';
        FSuccess:=False;
end;

procedure SendMail.DoDisconnect(Sender:TObject);
begin
        if CheckError then Exit;
        DoMailInfo(smServerDisconnected,'');
        if not FSuccess then
        begin
                DoMailError(smPrematureDisconnect,'Prematurely Disconnected');
                FError:=smPrematureDisconnect;
        end;
        PostMessage(Handle,WM_AVAILABLE,0,0);
end;

procedure SendMail.DoRead(Sender: TObject);
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
                                NewLineRead(newline);
                                OnHold:=False;
                                if Aborted then Exit;
                        end;
                until el=0;
                PartialLine:=linein;
                {$ENDIF}
        end;
end;

{=============== specific routines ============================}

procedure SendMail.MailAction(act: TMailAction);
begin
        case act of
        Send_Mail: DoSendMail;
        Cancel_SendMail:
                begin
                        FError:=smCanceled;
                        CloseProc;
                end;
        end;
end;

procedure SendMail.PlainSend(filename,Name,MimeType,Description,Disposition: string);
var
        f:                              TextFile;
        s:                              string;
begin
        if Aborted then Exit;
        DoMailInfo(smAttachmentName,filename);
        AssignFile(f,filename);
        Reset(f);
        Write('--'+boundary);
        if Name='' then Name:=ExtractFileName(FileName);
        if MimeType='' then MimeType:='text/plain';
        Write('Content-Type: '+MimeType+'; name="'+Name+'"');
        if disposition<>'' then Write('Content-Disposition: '+disposition+'; filename="'+ExtractFileName(filename)+'"');
        if description<>'' then Write('Content-Description: '+description);
        Write('');
        while not Eof(f) do
        begin
                if Aborted then
                begin
                        CloseFile(f);
                        Exit;
                end;
                ReadLn(f,s);
                Write(s);
        end;
        CloseFile(f);
end;

procedure SendMail.QuotedSendBuffer(buf: PChar;size: LongInt);
var
        outbuf: PChar;
        inptr,outptr,curlen: integer;
begin
        outptr:=0;
        GetMem(outbuf,size*5);
        for inptr:=0 to size-1 do
        begin
                case buf[inptr] of
                #0..#32,#61,#127..#255:
                        begin
                                outbuf[outptr]:='=';
                                outbuf[outptr+1]:=CodeQuoted[(Ord(buf[inptr]) div 16)+1];
                                outbuf[outptr+2]:=CodeQuoted[(Ord(buf[inptr]) mod 16)+1];
                                Inc(outptr,3);
                                Inc(curqlen,3);
                        end;
                else
                       begin
                                outbuf[outptr]:=buf[inptr];
                                Inc(outptr);
                                Inc(curqlen);
                       end;
                end;
                if curqlen>70 then
                begin
                        curqlen:=0;
                        outbuf[outptr]:='=';
                        outbuf[outptr+1]:=#13;
                        outbuf[outptr+2]:=#10;
                        Inc(outptr,3);
                end;
        end;
        outbuf[outptr]:=#0;
        WriteBuffer(outbuf,outptr);
        FreeMem(outbuf,5*size);
end;

procedure SendMail.QuotedSend(filename,Name,MimeType,Description,Disposition: string);
var
        f: File;
        buf: array[0..2048] of Char;
        numread: integer;
begin
        DoMailInfo(smAttachmentName,filename);
        AssignFile(f,filename);
        Reset(f,1);
        Write('--'+boundary);
        if Name='' then Name:=ExtractFileName(FileName);
        if MimeType='' then MimeType:='text/plain';
        Write('Content-Type: '+MimeType+'; name="'+Name+'"');
        Write('Content-Transfer-Encoding: Quoted-Printable');
        if disposition<>'' then Write('Content-Disposition: '+disposition+'; filename="'+ExtractFileName(filename)+'"');
        if description<>'' then Write('Content-Description: '+description);
        Write('');
        curqlen:=0;
        while not Eof(f) do
        begin
                if Aborted then
                begin
                        CloseFile(f);
                        Exit;
                end;
                BlockRead(f,buf,2048,numread);
                QuotedSendBuffer(buf,numread);
        end;
        CloseFile(f);
        Write('');
end;

procedure SendMail.UUencodeSend(filename,Name,MimeType,Description,Disposition: string);
var
        f: File;
        buf: array[0..2048] of Char;
        numread: integer;
        altName: string;
        i: integer;
begin
        DoMailInfo(smAttachmentName,filename);
        AssignFile(f,filename);
        Reset(f,1);
        if Name='' then Name:=ExtractFileName(FileName);
        altName:=Name;
        for i:=Length(Name) downto 1 do
        begin
                if Name[i]='.' then
                begin
                        Delete(altName,i,9999);
                        Break;
                end;
        end;
        altName:=altName+'.uue';
        Write('--'+boundary);
        Write('Content-Type: application/octet-stream; name="'+altName+'"');
        if disposition<>'' then Write('Content-Disposition: '+disposition+'; filename="'+altName+'"');
        if description<>'' then Write('Content-Description: '+description);
        Write('');
        Write('=============================================================');
        if name<>'' then Write('begin 666 '+name)
        else Write('begin 666 '+ExtractFileName(filename));
        while not Eof(f) do
        begin
                BlockRead(f,buf,1800,numread);
                UUEncode(buf,numread);
        end;
        CloseFile(f);
        Write('');
        Write('end');
end;

procedure SendMail.UUEncode(buf: PChar;size: integer);
var
        outbuf: PChar;
        leftover,outptr,i,j,l: integer;
        b: array[0..2] of Char;
begin
        GetMem(outbuf,size*2);
        outptr:=0;
        for i:=0 to (size div 45)-1 do
        begin
                outbuf[outptr]:='M';
                Inc(outptr);
                for j:=0 to 14 do
                begin
                        l:=i*45+j*3;
                        outbuf[outptr]:=_UUCode[(Ord(buf[l])div 4)+1];
                        outbuf[outptr+1]:=_UUCode[(Ord(buf[l]) mod 4)*16 +(Ord(buf[l+1]) div 16)+1];
                        outbuf[outptr+2]:=_UUCode[(Ord(buf[l+1]) mod 16)*4 +(Ord(buf[l+2]) div 64)+1];
                        outbuf[outptr+3]:=_UUCode[Ord(buf[l+2]) mod 64+1];
                        Inc(outptr,4);
                end;
                outbuf[outptr]:=#13;
                outbuf[outptr+1]:=#10;
                Inc(outptr,2);
        end;
        leftover:=size mod 45;
        if leftover>0 then
        begin
                outbuf[outptr]:=Char(leftover+32);
                Inc(outptr);
                for i:=0 to (leftover div 3)-1 do
                begin
                        l:=(size-leftover)+i*3;
                        outbuf[outptr]:=_UUCode[(Ord(buf[l])div 4)+1];
                        outbuf[outptr+1]:=_UUCode[(Ord(buf[l]) mod 4)*16 +(Ord(buf[l+1]) div 16)+1];
                        outbuf[outptr+2]:=_UUCode[(Ord(buf[l+1]) mod 16)*4 +(Ord(buf[l+2]) div 64)+1];
                        outbuf[outptr+3]:=_UUCode[Ord(buf[l+2]) mod 64+1];
                        Inc(outptr,4);
                end;
                leftover:=size mod 3;
                if leftover>0 then
                begin
                        l:=3*(size div 3);
                        for i:=0 to 2 do b[i]:=' ';
                        for i:=0 to leftover-1 do b[i]:=buf[l+i];
                        outbuf[outptr]:=_UUCode[(Ord(b[0])div 4)+1];
                        outbuf[outptr+1]:=_UUCode[(Ord(b[0]) mod 4)*16 +(Ord(b[1]) div 16)+1];
                        outbuf[outptr+2]:=_UUCode[(Ord(b[1]) mod 16)*4 +(Ord(b[2]) div 64)+1];
                        outbuf[outptr+3]:=_UUCode[Ord(b[2]) mod 64+1];
                        Inc(outptr,4);
                end;
                outbuf[outptr]:=#13;
                outbuf[outptr+1]:=#10;
                Inc(outptr,2);
        end;
        WriteBuffer(outbuf,outptr);
        FreeMem(outbuf,size*2);
end;

procedure SendMail.Base64Send(filename,Name,MimeType,Description,Disposition: string);
var
        afile:                          file;
        i:                              longint;
        quads:                          integer;
        bsent:                          Longint;
        b:                              array[0..2279] of byte;
        j,k,l,m:                        integer;
        stream:                         string[76];
begin
        DoMailInfo(smAttachmentName,filename);
        AssignFile(afile,filename);
        Reset(afile,1);
        Write('--'+boundary);
        if Name='' then Name:=ExtractFileName(FileName);
        Write('Content-Type: '+MimeType+'; name="'+Name+'"');
        Write('Content-Transfer-Encoding: base64');
        if disposition<>'' then Write('Content-Disposition: '+disposition+'; filename="'+ExtractFileName(filename)+'"');
        if description<>'' then Write('Content-Description: '+description);
        Write('');
        stream:='';
        quads:=0;
        DoMailInfo(smAttachmentSize,IntToStr(Filesize(afile)));
        bsent:=0;
        j:=Filesize(afile) div 2280;
        for i:=1 to j do
        begin
                if Aborted then
                begin
                        CloseFile(afile);
                        Exit;
                end;
                BlockRead(afile,b,2280);
                for m:=0 to 39 do
                begin
                        for k:=0 to 18 do
                        begin
                                l:=57*m+3*k;
                                stream[quads+1]:=_Code64[(b[l]div 4)+1];
                                stream[quads+2]:=_Code64[(b[l] mod 4)*16 +(b[l+1] div 16)+1];
                                stream[quads+3]:=_Code64[(b[l+1] mod 16)*4 +(b[l+2] div 64)+1];
                                stream[quads+4]:=_Code64[b[l+2] mod 64+1];
                                Inc(quads,4);
                                if quads=76 then
                                begin
                                        if Aborted then
                                        begin
                                                CloseFile(afile);
                                                Exit;
                                        end;
                                        stream[0]:=#76;
                                        Write(stream);
                                        bsent:=bsent+57;
                                        DoMailInfo(smAttachmentBytes,IntToStr(bsent));
                                        quads:=0;
                                end;
                        end;
                end;
        end;
        j:=(Filesize(afile) mod 2280) div 3;
        for i:=1 to j do
        begin
                if Aborted then
                begin
                        CloseFile(afile);
                        Exit;
                end;
                BlockRead(afile,b,3);
                stream[quads+1]:=_Code64[(b[0]div 4)+1];
                stream[quads+2]:=_Code64[(b[0] mod 4)*16 +(b[1] div 16)+1];
                stream[quads+3]:=_Code64[(b[1] mod 16)*4 +(b[2] div 64)+1];
                stream[quads+4]:=_Code64[b[2] mod 64+1];
                Inc(quads,4);
                if quads=76 then
                begin
                        stream[0]:=#76;
                        Write(stream);
                        bsent:=bsent+57;
                        DoMailInfo(smAttachmentBytes,IntToStr(bsent));
                        quads:=0;
                end;
        end;
        if (Filesize(afile) mod 3) = 2 then
        begin
                BlockRead(afile,b,2);
                stream[quads+1]:=_Code64[(b[0]div 4)+1];
                stream[quads+2]:=_Code64[(b[0] mod 4)*16 +(b[1] div 16)+1];
                stream[quads+3]:=_Code64[(b[1] mod 16)*4 +1];
                stream[quads+4]:='=';
                Inc(quads,4);
        end;
        if (Filesize(afile) mod 3) = 1 then
        begin
                BlockRead(afile,b,1);
                stream[quads+1]:=_Code64[(b[0]div 4)+1];
                stream[quads+2]:=_Code64[(b[0] mod 4)*16 +1];
                stream[quads+3]:='=';
                stream[quads+4]:='=';
                Inc(quads,4);
        end;
        stream[0]:=Chr(quads);
        if quads>0 then Write(stream);
        bsent:=bsent+3;
        DoMailInfo(smAttachmentBytes,IntToStr(bsent));
        CloseFile(afile);
end;

function SendMail.EncodingNeeded(buf: PChar): Boolean;
var
        i: LongInt;
begin
        for i:=0 to StrLen(buf)-1 do
        begin
                case (buf+i)^ of
                #0..#9,#11,#12,#14..#31,#127..#255:
                        begin
                                Result:=True;
                                Exit;
                        end;
                end;
        end;
        Result:=False;
end;

function SendMail.RecommendEncodingMethod(filename: string): TMailEncoding;
var
        f: file;
        buf: array[1..2048] of char;
        Base64Size,QuotedSize,total,unprint,MaybeUnprint: LongInt;
        i,bytesRead: integer;
begin
        total:=0;
        unprint:=0;
        MaybeUnprint:=0;
        try
                AssignFile(f,filename);
                Reset(f,1);
        except
                Result:=meMimeBase64;
                Exit;
        end;
        while not Eof(f) do
        begin
                BlockRead(f,buf,2048,bytesRead);
                Inc(Total,bytesRead);
                for i:=1 to BytesRead do
                begin
                        case buf[i] of
                        #127..#255:Inc(Unprint);
                        #0..#32,#61: Inc(MaybeUnprint);
                        end;
                end;
        end;
        If Unprint>0 then
        begin
                Base64Size:=(Total shr 2) div 3;
                QuotedSize:=Total+((Unprint+MaybeUnprint) shr 1);
                if QuotedSize>Base64Size then Result:=meMimeBase64
                else Result:=meMimeQuoted;
        end
        else Result:=meMimePlain;
        CloseFile(f);
end;


procedure SendMail.NewLineRead(line: string);
var
        i:                      integer;
        address,name:           string;
        fs:                     LongInt;
        MailBuf:                PChar;
        MailBufSent,MailBufLen: LongInt;
begin
        DoMailInfo(smTraceIn,line);
        case line[1] of
        '4','5','-':
                begin
                        if step=3 then
                        begin
                                DoMailInfo(smBadAddress,lastaddress);
                        end
                        else
                        begin
                                DoMailError(smProtocolError,'Unexpected response: '+line);
                                FError:=smProtocolError;
                                CloseProc;
                                Exit;
                        end;
                end;
        end;
        if line[4]='-' then exit;
        case step of
        0: Write('HELO '+GetLocalHost);
        1: Write('MAIL FROM:<'+FROM_Address+'>');
        2:
                begin
                        Write('RCPT TO:<'+TO_Address+'>');
                        if Aborted then Exit;
                        lastaddress:=TO_Address;
                        current_List:=-1;
                        num_list:=ToStrings.Count-1-ToOffset;
                        substep:=1;
                        while (num_list=-1) do
                        begin
                                if Aborted then Exit;
                                Inc(substep);
                                case substep of
                                2: num_list:=ccStrings.Count-1-ccOffset;
                                3: num_list:=BccStrings.Count-1-BccOffset;
                                4: num_list:=0;
                                end;
                        end;
                        DoMailInfo(smRecipient,TO_Address);
                end;
        3:
                begin
                        if Aborted then Exit;
                        case substep of
                        1:
                                begin
                                        if current_list<num_list then
                                        begin
                                                Inc(current_list);
                                                SplitAddress(ToStrings[current_list+ToOffset],lastaddress,name);
                                                Write('RCPT TO:<'+lastaddress+'>');
                                                DoMailInfo(smRecipient,lastaddress);
                                        end;
                                end;
                        2:
                                begin
                                        if current_list<num_list then
                                        begin
                                                Inc(current_list);
                                                SplitAddress(ccStrings[current_list+ccOffset],lastaddress,name);
                                                Write('RCPT TO:<'+lastaddress+'>');
                                                DoMailInfo(smRecipient,lastaddress);
                                        end;
                                end;
                        3:
                                begin
                                        if current_list<num_list then
                                        begin
                                                Inc(current_list);
                                                SplitAddress(BccStrings[current_list+BccOffset],lastaddress,name);
                                                Write('RCPT TO:<'+lastaddress+'>');
                                                DoMailInfo(smRecipient,lastaddress);
                                        end;
                                end;
                        4:
                                begin
                                        Write('DATA');
                                        Inc(step);
                                end;
                        end;
                        if current_list=num_list then
                        begin
                                num_list:=-1;
                                while (num_list=-1) do
                                begin
                                        Inc(substep);
                                        case substep of
                                        2: num_list:=ccStrings.Count-1-ccOffset;
                                        3: num_list:=BccStrings.Count-1-BccOffset;
                                        4: num_list:=0;
                                        end;
                                end;
                                current_list:=-1;
                        end;
                end;
        5:
                begin
                        boundary:='==============ghyurgtfy573======___';
                        Write('From: '+CheckHeaderString(From_Name)+' <'+From_Address+'>');
                        if ToStrings.Count>0 then
                        begin
                                for i:=0 to ToStrings.Count-1 do
                                begin
                                        if Aborted then Exit;
                                        SplitAddress(ToStrings[i],address,name);
                                        if name<>'' then Write('To: '+CheckHeaderString(name)+' <'+address+'>')
                                        else Write('To: '+address+';');
                                end;
                        end;
                        if ccStrings.Count>0 then
                        begin
                                for i:=0 to ccStrings.Count-1 do
                                begin
                                        if Aborted then Exit;
                                        SplitAddress(ccStrings[i],address,name);
                                        if name<>'' then Write('cc: '+CheckHeaderString(name)+' <'+address+'>')
                                        else Write('cc: '+address);
                                end;
                        end;
                        if Subject<>'' then Write(CheckHeader('Subject: '+Subject));
                        Write('Mime-Version: 1.0');
                        if Attachments.Count=0 then
                        begin
                                Write('Content-Type: text/plain; charset="us-ascii"');
                                {$IFDEF WIN32}
                                QuotedEncode:=EncodingNeeded(PChar(MailText.Text));
                                {$ENDIF}
                                if QuotedEncode then Write('Content-Transfer-Encoding: quoted-printable');
                        end
                        else Write('Content-Type: multipart/mixed; boundary="'+boundary+'"');
                        if Headers.Count>0 then
                        begin
                                for i:=1 to Headers.Count do
                                begin
                                        Write(CheckHeader(Headers[i-1]));
                                end;
                        end;
                        Write('');
                        if (Attachments.Count>0) and (MailText.Count>0) then
                        begin
                                Write('--'+boundary);
                                Write('Content-Type: text/plain; charset="us-ascii"');
                                if QuotedEncode then Write('Content-Transfer-Encoding: quoted-printable');
                                Write('');
                        end;
                        ContinueFeeding:=True;
                        fs:=0;
                        while Assigned(FFeed) and ContinueFeeding do
                        begin
                                FeedLine:='';
                                if Assigned(FFeed) then FFeed(self,FeedLine);
                                if FeedLine='' then ContinueFeeding:=False
                                else
                                begin
                                        {$IFDEF WIN32}
                                        Inc(fs,Length(FeedLine));
                                        {$ENDIF}
                                        DoMailInfo(smSendingMessage,IntToStr(fs));
                                        RawWrite(FeedLine);
                                end;
                        end;
                        If MailText.Count> 0 then
                        begin
                                MailBuf:=MailText.GetText;
                                MailBufLen:=StrLen(MailBuf);
                                DoMailInfo(smMessageSize,IntToStr(MailBufLen));
                                MailBufSent:=0;
                                curqlen:=0;
                                for i:=1 to (MailBufLen div 2048) do
                                begin
                                        if Aborted then Exit;
                                        if QuotedEncode then QuotedSendBuffer(MailBuf+MailBufSent,2048)
                                        else WriteBuffer(MailBuf+MailBufSent,2048);
                                        Inc(MailBufSent,2048);
                                        DoMailInfo(smSendingMessage,IntToStr(MailBufSent));
                                end;
                                if (MailBufLen mod 2048)<>0 then
                                begin
                                        if QuotedEncode then QuotedSendBuffer(MailBuf+MailBufSent,MailBufLen mod 2048)
                                        else WriteBuffer(MailBuf+MailBufSent,MailBufLen mod 2048);
                                        DoMailInfo(smSendingMessage,IntToStr(MailBufLen));
                                end;
                                Write('');
                        end;
                        if Attachments.Count>0 then
                        begin
                                for i:=1 to Attachments.Count do
                                begin
                                        if Aborted then Exit;
                                        if Assigned(Atts[i]) then
                                        begin
                                                if Atts[i]^.Encoding=meDefault then
                                                begin
                                                        Atts[i]^.Encoding:=RecommendEncodingMethod(Atts[i]^.Location);
                                                end;
						if Atts[i]^.MimeType='' then Atts[i]^.MimeType:='application/octet-stream';
						if Atts[i]^.MimeDisposition='' then Atts[i]^.MimeDisposition:='attachment';
                                                case Atts[i]^.Encoding of
                                                meMimeBase64:
                                                        begin
                                                                try
                                                                        Base64Send(Atts[i]^.Location,Atts[i]^.Name,
                                                                          Atts[i]^.MimeType,Atts[i]^.MimeDescription,
                                                                          Atts[i]^.MimeDisposition);
                                                                except
                                                                        DoMailInfo(smBadAttachment,Atts[i]^.Location);
                                                                end;
                                                        end;
                                                meMimeQuoted:
                                                        begin
                                                                try
                                                                        QuotedSend(Atts[i]^.Location,Atts[i]^.Name,
                                                                          Atts[i]^.MimeType,Atts[i]^.MimeDescription,
                                                                          Atts[i]^.MimeDisposition);
                                                                except
                                                                        DoMailInfo(smBadAttachment,Atts[i]^.Location);
                                                                end;

                                                        end;
                                                meMimePlain:
                                                        begin
                                                                try
                                                                        PlainSend(Atts[i]^.Location,Atts[i]^.Name,
                                                                          Atts[i]^.MimeType,Atts[i]^.MimeDescription,
                                                                          Atts[i]^.MimeDisposition);
                                                                except
                                                                        DoMailInfo(smBadAttachment,Atts[i]^.Location);
                                                                end;
                                                        end;
                                                meUUencode:
                                                        begin
                                                                try
                                                                        UUEncodeSend(Atts[i]^.Location,Atts[i]^.Name,
                                                                          Atts[i]^.MimeType,Atts[i]^.MimeDescription,
                                                                          Atts[i]^.MimeDisposition);
                                                                except
                                                                        DoMailInfo(smBadAttachment,Atts[i]^.Location);
                                                                end;
                                                        end;
                                                end;
                                        end
                                        else
                                        begin
                                                try
                                                        Base64Send(Attachments[i-1],'',
                                                         'application/octect-stream','',
                                                         'attachment');
                                                except
                                                        DoMailInfo(smBadAttachment,Attachments[i-1]);
                                                end;
                                        end;
                                end;
                                Write('--'+boundary+'--');
                                Write('');
                        end;
                        if not Aborted then Write('.');
                end;
        6:
                begin
                        if Aborted then Exit;
                        DoMailInfo(smMessageAccepted,'');
                        FSuccess:=True;
                        if KeepOpen then
                        begin
                                PostMessage(handle,WM_AVAILABLE,0,0);
                                Exit;
                        end;
                        Write('QUIT');
                end;
        end;
        if step<>3 then Inc(step);
end;

procedure SendMail.CloseProc;
begin
        if Aborted then Exit;
        FTAddress:='';
        FTName:='';
        if ToStrings.Count>0 then ToStrings.Clear;
        if ccStrings.Count>0 then ccStrings.Clear;
        if BccStrings.Count>0 then BccStrings.Clear;
        Aborted:=True;
        Disconnect;
        PostMessage(Handle,WM_AVAILABLE,0,0);
end;

procedure SendMail.SplitAddress(s: string;var address,name: string);
var
        i: integer;
begin
        i:=Pos('|',s);
        if i>0 then
        begin
                address:=Copy(s,1,i-1);
                name:=Copy(s,i+1,999);
        end
        else
        begin
                address:=s;
                name:='';
        end;
end;

procedure SendMail.DoSendMail;
begin
        if Busy then
        begin
		DoMailInfo(smAlreadyBusy,'');
                Exit;
        end;
        OnTimeOut:=TimedOut;
        Aborted:=False;
        Busy:=True;
        FSuccess:=False;
        ToOffset:=0;
        ccOffset:=0;
        BccOffset:=0;
        if FTAddress='' then
        begin
                if ToStrings.Count>0 then
                begin
                        SplitAddress(ToStrings[0],FTAddress,FTName);
                        ToOffset:=1;
                end;
                if (FTAddress='') and (ccStrings.Count>0) then
                begin
                        SplitAddress(ccStrings[0],FTAddress,FTName);
                        ccOffset:=1;
                end;
                if (FTAddress='') and (BccStrings.Count>0) then
                begin
                        SplitAddress(BccStrings[0],FTAddress,FTName);
                        BccOffset:=1;
                end;
        end
        else
        begin
                ToStrings.Insert(0,FTAddress+'|'+FTName);
                ToOffset:=1;
        end;
        if FTAddress='' then
        begin
		DoMailError(smMailDestinationError,'Mail Destination Error');
                CloseProc;
        end;
        if not IsConnected then
        begin
                WinsockStarted:=True;
                if not WinsockStarted then
                begin
                        DoMailError(smWinsockNotInitialized,'Winsock not initiliazed');
			FError:=smWinsockNotInitialized;
                        CloseProc;
                        Exit;
                end;
                OnConnected:=DidConnect;
                OnReadReady:=DoRead;
                OnDisconnected:=DoDisconnect;
                CreateTCPSocket;
                if CheckError then Exit;
                if Address<>'' then FillAddress(Address)
                else
                begin
                        DoMailInfo(smResolvingAddress,Host);
                        LookupName(Host);
                        CheckError;
                        Exit;
                end;
                FillPort(Port);
                Connect;
                if CheckError then Exit;
        end
        else
        begin
                step:=1;
                PartialLine:='';
                NewLineRead(' ');
        end;
end;

procedure SendMail.LookupNameDone;
begin
        if CheckError then Exit;
        FillName;
        FillPort(Port);
        Address:=GetAddressString;
        DoMailInfo(smAddressResolved,Address);
        Connect;
        if CheckError then Exit;
end;

procedure SendMail.TimedOut(Sender: TObject);
begin
        FError:=smConnectTimeOut;
        DoMailError(smCOnnectTimeOut,'Connection timed out');
        CloseProc;
end;

procedure SendMail.SetMailStrings(s: TStrings);
begin
        MailStrings.Assign(s);
end;

procedure SendMail.SetccStrings(s: TStrings);
begin
        ccStrings.Assign(s);
end;

procedure SendMail.SetBccStrings(s: TStrings);
begin
        BccStrings.Assign(s);
end;

procedure SendMail.SetToStrings(s: TStrings);
begin
        ToStrings.Assign(s);
end;

procedure SendMail.SetAttStrings(s: TStrings);
begin
        AttachStrings.Assign(s);
end;

procedure SendMail.SetHeaderList(s: TStrings);
begin
        HeaderList.Assign(s);
end;

function SendMail.CheckHeaderString(s: string): string;
var
        i,j: integer;
        r: string;
begin
        for i:=1 to Length(s) do
        begin
                if s[i]>#126 then
                begin
                        r:='=?ISO-8859-1?Q?';
                        j:=0;
                        while j<Length(s) do
                        begin
                                Inc(j);
                                case s[j] of
                                #32: r:=r+'_';
                                #0..#31,#61,#127..#255:
                                        begin
                                                r:=r+'=';
                                                r:=r+CodeQuoted[(Ord(s[j]) div 16)+1];
                                                r:=r+CodeQuoted[(Ord(s[j]) mod 16)+1];
                                        end;
                                else r:=r+s[j];
                                end;
                        end;
                        r:=r+'?=';
                        Result:=r;
                        Exit;
                end;
        end;
        Result:=s;
end;

function SendMail.CheckHeader(s: string): string;
var
        i: integer;
begin
        i:=Pos(': ',s);
        if i=0 then
        begin
                Result:=s; {Someone made an invalid custom header!}
                Exit;
        end;
        Result:=Copy(s,1,i+1)+CheckHeaderString(Copy(s,i+2,999))+'  ';
end;

function SendMail.RecvText : string;
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

function SendMail.GetWinsockStarted: Boolean;
begin
        Result:=WinsockInitialized;
end;

procedure SendMail.SetWinsockStarted(b: Boolean);
begin
        if b then InitializeWinsock
        else UnloadWinsock;
end;

function SendMail.CheckError: Boolean;
var
        errs: string;
begin
        if Aborted then Exit;
        if LastError=0 then
        begin
                Ferror:=smNone;
                Result:=False;
        end
        else
        begin
                case LastError of
                WSANOTINITIALISED:
                        begin
                                FError:=smWinsockNotInitialized;
                                errs:='Winsock not initialized';
                        end;
                WSAENETDOWN:
                        begin
                                FError:=smNetworkDown;
                                errs:='Network down';
                        end;
                WSAEACCES:
                        begin
                                FError:=smInvalidAddress;
                                errs:='Invalid address specified';
                        end;
                WSAEFAULT,WSAENOTSOCK,WSAEOPNOTSUPP,WSAESHUTDOWN,WSAEMSGSIZE,WSAENOTCONN,
                WSAEADDRINUSE,WSAEINPROGRESS,WSAEINTR,WSAEAFNOSUPPORT,WSAEINVAL,WSAEISCONN:
                        begin
                                FError:=smInternalError;
                                errs:='Unexpected internal error in component';
                        end;
                WSAETIMEDOUT:
                        begin
                                FError:=smConnectTimeout;
                                errs:='timeout';
                        end;
                WSAEMFILE:
                        begin
                                FError:=smOutofSockets;
                                errs:='Out of sockets';
                        end;
                WSAENETUNREACH:
                        begin
                                FError:=smNetworkUnreachable;
                                errs:='Network unreachable';
                        end;
                WSAEADDRNOTAVAIL:
                        begin
                                FError:=smAddressNotAvailable;
                                errs:='Address not available';
                        end;
                WSAECONNREFUSED:
                        begin
                                FError:=smConnectionRefused;
                                errs:='Connection Refused';
                        end;
                WSAENETRESET,WSAENOBUFS:
                        begin
                                FError:=smGeneralWinsockError;
                                errs:='General Winsock Error';
                        end;
                WSAECONNABORTED:
                        begin
                                Ferror:=smConnAborted;
                                errs:='Connection aborted due to timeout or other failure';
                        end;
                WSAECONNRESET:
                        begin
                                Ferror:=smConnReset;
                                errs:='Connection reset by remote side';
                        end;
                WSAHOST_NOT_FOUND,WSATRY_AGAIN,WSANO_RECOVERY,WSANO_DATA:
                        begin
                                FError:=smAddressResolutionError;
                                errs:='Address resolution error';
                        end;
                WSAEHOSTUNREACH:
                        begin
                                FError:=smHostUnreachable;
                                errs:='Host Unreachable';
                        end;
                else
                        begin
                                FError:=smUnknown;
                                errs:='Unknown Error';
                        end;
                end;
                DoMailError(FError,errs);
                Result:=True;
                CloseProc;
        end;
end;

{=======================================================================}

end.
