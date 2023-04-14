unit Mimemgr;
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

uses ShellAPI, WinProcs, WinTypes;

const
        STANDARD_DEFS   =       23;

type TMimeAction=(maPrompt,maLaunch,maInternal);

type TMIMEDefinition=record
        MimeType: string[40];
        MimeAction: TMimeAction;
        Description: string[30];
        {$IFDEF WIN32}
        Application: string[255];
        {$ENDIF}
        Extension: string[3];
end;

type TMimeDefPtr=^TMimeDefinition;

type TMimeManager=class(TObject)
private
        filename: string;
        Definitions: array[1..2000] of TMimeDefPtr;
        NumDefs: integer;
        function GetIndex(MimeType: string): integer;
public
        constructor Create(fn: string);
        destructor Destroy;
        function GetMimeType(fn: string): string;
        function GetNumDefinitions: integer;
        function GetDefinition(n: integer): TMimeDefinition;
        function GetApplication(MimeType: string): string;
        function GetDefaultExtension(MimeType: string): string;
        function SuggestApplication(name: string): string;
        function GetAction(MimeType: string): TMimeAction;
        procedure RegisterApplication(MimeType,Application: string);
        function Launch(Filename,MimeType: string): Boolean;
        procedure AddMimeType(t: TMimeDefinition);
        procedure DeleteDefinition(n: integer);
end;

implementation

uses SysUtils;

constructor TMIMEManager.Create(fn: string);
var
        f: file;
        Loaded: Boolean;
        i: integer;
begin
        NumDefs:=0;
        Loaded:=False;
        filename:=fn;
        try
                AssignFile(f,filename);
                Reset(f,Sizeof(TMimeDefinition));
                while not Eof(f) do
                begin
                        Inc(NumDefs);
                        GetMem(Definitions[NumDefs],Sizeof(TMimeDefinition));
                        BlockRead(f,Definitions[NumDefs]^,1);
                end;
                CloseFile(f);
                Loaded:=True;
        except
                {}
        end;
        if Loaded=False then
        begin
                AssignFile(f,filename);
                Rewrite(f,Sizeof(TMimeDefinition));
                for i:=1 to STANDARD_DEFS do
                begin
                        Inc(NumDefs);
                        GetMem(Definitions[NumDefs],Sizeof(TMimeDefinition));
                        case i of
                        1: {application/octet-stream}
                                begin
                                        Definitions[i]^.MimeType:='application/octet-stream';
                                        Definitions[i]^.Extension:='';
                                        Definitions[i]^.Description:='Unknown file format';
                                end;
                        2: {image/gif}
                                begin
                                        Definitions[i]^.MimeType:='image/gif';
                                        Definitions[i]^.Extension:='gif';
                                        Definitions[i]^.Description:='CIS Graphic Interchange Format';
                                end;
                        3: {image/jpeg}
                                begin
                                        Definitions[i]^.MimeType:='image/jpeg';
                                        Definitions[i]^.Extension:='jpg';
                                        Definitions[i]^.Description:='JPEG graphic format';
                                end;
                        4: {image/tiff}
                                begin
                                        Definitions[i]^.MimeType:='image/tiff';
                                        Definitions[i]^.Extension:='tif';
                                        Definitions[i]^.Description:='Tagged Image File Format';
                                end;
                        5: {message/rfc822}
                                begin
                                        Definitions[i]^.MimeType:='message/rfc822';
                                        Definitions[i]^.Extension:='';
                                        Definitions[i]^.Description:='RFC 822 Format message';
                                end;
                        6: {message/partial}
                                begin
                                        Definitions[i]^.MimeType:='message/partial';
                                        Definitions[i]^.Extension:='';
                                        Definitions[i]^.Description:='Partial RFC 822 message';
                                end;
                        7: {message/news}
                                begin
                                        Definitions[i]^.MimeType:='message/news';
                                        Definitions[i]^.Extension:='';
                                        Definitions[i]^.Description:='Usenet News message format';
                                end;
                        8: {video/mpeg}
                                begin
                                        Definitions[i]^.MimeType:='video/mpeg';
                                        Definitions[i]^.Extension:='mpg';
                                        Definitions[i]^.Description:='MPEG video format';
                                end;
                        9: {video/quicktime}
                                begin
                                        Definitions[i]^.MimeType:='video/quicktime';
                                        Definitions[i]^.Extension:='mov';
                                        Definitions[i]^.Description:='Apple QuickTime video';
                                end;
                        10: {audio/basic}
                                begin
                                        Definitions[i]^.MimeType:='audio/basic';
                                        Definitions[i]^.Extension:='au';
                                        Definitions[i]^.Description:='Sun music format';
                                end;
                        11: {application/postscript}
                                begin
                                        Definitions[i]^.MimeType:='application/postscript';
                                        Definitions[i]^.Extension:='ps';
                                        Definitions[i]^.Description:='Postscript document';
                                end;
                        12: {application/rtf}
                                begin
                                        Definitions[i]^.MimeType:='application/rtf';
                                        Definitions[i]^.Extension:='rtf';
                                        Definitions[i]^.Description:='Rich Text Format';
                                end;
                        13: {application/wordperfect5.1}
                                begin
                                        Definitions[i]^.MimeType:='application/wordperfect5.1';
                                        Definitions[i]^.Extension:='wpd';
                                        Definitions[i]^.Description:='WordPerfect 5.1 Document';
                                end;
                        14: {application/pdf}
                                begin
                                        Definitions[i]^.MimeType:='application/pdf';
                                        Definitions[i]^.Extension:='pdf';
                                        Definitions[i]^.Description:='Adobe Portable Document Format';
                                end;
                        15: {application/msword}
                                begin
                                        Definitions[i]^.MimeType:='application/msword';
                                        Definitions[i]^.Extension:='doc';
                                        Definitions[i]^.Description:='Microsoft Word Document';
                                end;
                        16: {application/zip}
                                begin
                                        Definitions[i]^.MimeType:='application/zip';
                                        Definitions[i]^.Extension:='zip';
                                        Definitions[i]^.Description:='ZIP compressed archive';
                                end;
                        17: {text/plain}
                                begin
                                        Definitions[i]^.MimeType:='text/plain';
                                        Definitions[i]^.Extension:='txt';
                                        Definitions[i]^.Description:='Plain text document';
                                end;
                        18: {text/enriched}
                                begin
                                        Definitions[i]^.MimeType:='text/enriched';
                                        Definitions[i]^.Extension:='';
                                        Definitions[i]^.Description:='Enriched text format';
                                end;
                        19: {text/richtext}
                                begin
                                        Definitions[i]^.MimeType:='text/richtext';
                                        Definitions[i]^.Extension:='';
                                        Definitions[i]^.Description:='Rich Text document';
                                end;
                         {everything below not IANA registered!!!}
                        20: {text/html}
                                begin
                                        Definitions[i]^.MimeType:='text/html';
                                        Definitions[i]^.Extension:='htm';
                                        Definitions[i]^.Description:='HTML document';
                                end;
                        21: {image/x-bitmap}
                                begin
                                        Definitions[i]^.MimeType:='image/x-bitmap';
                                        Definitions[i]^.Extension:='bmp';
                                        Definitions[i]^.Description:='Microsoft Bitmap Image';
                                end;
                        22: {video/x-msvideo}
                                begin
                                        Definitions[i]^.MimeType:='video/x-msvideo';
                                        Definitions[i]^.Extension:='avi';
                                        Definitions[i]^.Description:='Microsoft video format';
                                end;
                        23: {audio/x-wav}
                                begin
                                        Definitions[i]^.MimeType:='audio/x-wave';
                                        Definitions[i]^.Extension:='wav';
                                        Definitions[i]^.Description:='Microsoft wave sound';
                                end;
                        end;
                        Definitions[i]^.Application:='';
                        Definitions[i]^.MimeAction:=maPrompt;
                        BlockWrite(f,Definitions[i]^,1);
                end;
                CloseFile(f);
        end;
end;

destructor TMimeManager.Destroy;
var
        i: integer;
        f: file;
begin
        try
                AssignFile(f,filename);
                Rewrite(f,Sizeof(TMimeDefinition));
                for i:=1 to NumDefs do BlockWrite(f,Definitions[i]^,1);
                CloseFile(f);
        except
                {}
        end;
        for i:=1 to NumDefs do FreeMem(Definitions[i],SizeOf(TMimeDefinition));
end;

function TMimeManager.GetIndex(MimeType: string): integer;
var
        i: integer;
begin
        for i:=1 to NumDefs do
        begin
                if Lowercase(MimeType)=Lowercase(Definitions[i]^.MimeType) then
                begin
                        Result:=i;
                        Exit;
                end;
        end;
        Result:=0;
end;

function TMimeManager.GetMimeType(fn: string): string;
var
        ext: string[3];
        s: string;
        i: integer;
begin
        s:=ExtractFileExt(fn);
        Delete(s,1,1);
        if s='' then
        begin
                Result:='application/octet-stream';
                Exit;
        end;
        ext:=s;
        for i:=1 to NumDefs do
        begin
                if Lowercase(Definitions[i]^.Extension)=Lowercase(ext) then
                begin
                        Result:=Definitions[i]^.MimeType;
                        Exit;
                end;
        end;
        Result:='application/octet-stream';
end;

function TMimeManager.GetNumDefinitions: integer;
begin
        Result:=NumDefs;
end;

function TMimeManager.GetDefinition(n: integer): TMimeDefinition;
begin
        if (n<0) or (n>NumDefs) then raise ERangeError.Create('Index out of range');
        Result:=Definitions[n]^;
end;

function TMimeManager.GetApplication(MimeType: string): string;
var
        i: integer;
begin
        i:=GetIndex(MimeType);
        if i<>0 then Result:=Definitions[i]^.Application
        else Result:='';
end;

function TMimeManager.GetDefaultExtension(MimeType: string): string;
var
        i: integer;
begin
        i:=GetIndex(MimeType);
        if i<>0 then Result:=Definitions[i]^.Extension
        else Result:='';
end;


function TMimeManager.GetAction(MimeType: string): TMimeAction;
var
        i: integer;
begin
        i:=GetIndex(MimeType);
        if i>1 then Result:=Definitions[i]^.MIMEAction {prompt always for application/octet-stream}
        else Result:=maPrompt;
end;

function TMimeManager.SuggestApplication(name: string): string;
var
        FileName: string;
        Directory: Char;
        Res: String[255];
begin
        FileName:=name+#0;
        Directory:=#0;
        if FindExecutable(@FileName[1], @Directory, @Res[1])>32 then
        begin
                Res[0]:=Char(StrLen(@Res[1]));
                Result:=Res;
        end
        else Result:='';
end;

procedure TMimeManager.RegisterApplication(MimeType,Application: string);
var
        i: integer;
begin
        i:=GetIndex(MimeType);
        if i<>0 then
        begin
                Definitions[i]^.Application:=Application;
                if i>1 then Definitions[i]^.MIMEAction:=maLaunch;
        end;
end;

function TMimeManager.Launch(Filename,MimeType: string): Boolean;
var
        i: integer;
        App: string;
begin
        i:=GetIndex(MimeType);
        if i<>0 then
        begin
                App:=Definitions[i]^.Application;
                if App='' then App:=SuggestApplication(FileName);
                if App<>'' then
                begin
                        App:=App+' '+FileName+#0;
                        if WinExec(@App[1],SW_SHOW)>32 then Result:=True
                        else Result:=False;
                        Exit;
                end;
        end;
        Result:=False;
end;

procedure TMimeManager.DeleteDefinition(n: integer);
var
        i: integer;
begin
        if (n<1) or (n>NumDefs) then ERangeError.Create('Index out of range');
        if n<STANDARD_DEFS then Exit;
        FreeMem(Definitions[n],Sizeof(TMimeDefinition));
        for i:=n to NumDefs-1 do Definitions[i]:=Definitions[i+1];
        Dec(NumDefs);
end;

procedure TMimeManager.AddMimeType(t: TMimeDefinition);
var
        i: integer;
begin
        for i:=1 to NumDefs do
        begin
                if (Lowercase(Definitions[i]^.MimeType)=Lowercase(t.MimeType)) and
                   (Lowercase(Definitions[i]^.Extension)=Lowercase(t.Extension)) then
                begin
                        Definitions[i]^:=t;
                        Exit;
                end;
        end;
        Inc(NumDefs);
        GetMem(Definitions[NumDefs],Sizeof(TMimeDefinition));
        Definitions[NumDefs]^:=t;
end;

end.
