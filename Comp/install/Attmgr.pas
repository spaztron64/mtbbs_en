unit Attmgr;
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
  Forms, Dialogs,AttDef,IniFiles,FileCtrl;

type TAttachmentManager = class(TComponent)
private
        FAttDirectory: string;
        AttachmentCount: LongInt;
        r: TMimeAttachment;
        TempFiles: TStrings;
        function GetAttDir: string;
        procedure SetAttDir(s: string);
protected
        constructor Create(AOwner: TComponent);override;
        destructor Destroy;override;
        procedure Loaded;override;
public
        function NewAttachment(var AttachRec: TMIMEAttachment): LongInt;
        procedure Delete(Number: LongInt;NewLocation: string);
        procedure Update(Number: LongInt;AttachRec: TMimeAttachment);
        function Retrieve(Number: LongInt): TMimeAttachment;
        procedure Copy(AttNumber: LongInt;Location: String);
        function GetTempFile(AttNumber: LongInt;Extension: string): string;
published
        property AttachmentDirectory: string read GetAttDir write SetAttDir;
end;

{ (defined in AttDef)
type TMIMEAttachment=record
        Name: string[255];
        MimeType: string[80];
        Disposition: string[30];
        Description: string[255];
        Size: LongInt;
        ContentID: string[40];
        Location: string[255];
        Stored: Boolean;
end;
}

implementation

constructor TAttachmentManager.Create(AOwner: TComponent);
begin
        inherited Create(AOwner);
        TempFiles:=TStringList.Create;
        FAttDirectory:='';
end;

destructor TAttachmentManager.Destroy;
begin
        TempFiles.Destroy;
        inherited Destroy;
end;

procedure TAttachmentManager.Loaded;
var
        f: file;
begin
        if csDesigning in ComponentState then Exit;
        if not FileExists(AttachmentDirectory+'attach.idx') then
        begin
                AssignFile(f,AttachmentDirectory+'attach.idx');
                Rewrite(f,Sizeof(TMimeAttachment));
                r.Size:=0;
                BlockWrite(f,r,1);
                CloseFile(f);
        end;
        AssignFile(f,AttachmentDirectory+'attach.idx');
        Reset(f,Sizeof(TMimeAttachment));
        try
                BlockRead(f,r,1);
        except
                Seek(f,0);
                r.Size:=0;
                BlockWrite(f,r,1);
        end;
        AttachmentCount:=r.Size;
        CloseFile(f);
end;

function TAttachmentManager.NewAttachment(var AttachRec: TMIMEAttachment): LongInt;
var
        f: File;
        s: string;
        r: TMimeAttachment;
begin
        Inc(AttachmentCount);
        s:='a'+IntToStr(AttachmentCount);
        if AttachRec.Location='' then
        begin
                AttachRec.Location:=AttachmentDirectory+s;
                AttachRec.Stored:=True;
        end
        else AttachRec.Stored:=False;
        AssignFile(f,AttachmentDirectory+'attach.idx');
        Reset(f,sizeof(TMimeAttachment));
        r.Size:=AttachmentCount;
        Seek(f,0);
        BlockWrite(f,r,1);
        Seek(f,AttachmentCount);
        BlockWrite(f,AttachRec,1);
        CloseFile(f);
        Result:=AttachmentCount;
end;

procedure TAttachmentManager.Update(Number: LongInt;AttachRec: TMimeAttachment);
var
        f: file;
begin
        AssignFile(f,AttachmentDirectory+'attach.idx');
        Reset(f,sizeof(TMimeAttachment));
        Seek(f,Number);
        BlockWrite(f,AttachRec,1);
        CloseFile(f);
end;

function TAttachmentManager.Retrieve(Number: LongInt): TMimeAttachment;
var
        f: file;
begin
        AssignFile(f,AttachmentDirectory+'attach.idx');
        Reset(f,sizeof(TMimeAttachment));
        Seek(f,Number);
        BlockRead(f,r,1);
        CloseFile(f);
        Result:=r;
end;

procedure TAttachmentManager.Delete(Number: LongInt;NewLocation: string);
var
        f: file;
begin
        Retrieve(Number);
        if r.Stored then
        begin
                AssignFile(f,r.Location);
                Erase(f);
        end;
        AssignFile(f,AttachmentDirectory+'attach.idx');
        Reset(f,sizeof(TMimeAttachment));
        r.Stored:=False;
        r.Location:=NewLocation;
        BlockWrite(f,r,1);
        CloseFile(f);
end;

procedure TAttachmentManager.Copy(AttNumber: LongInt;Location: String);
var
        FromF, ToF: file;
        NumRead, NumWritten: Integer;
        Buf: array[1..2048] of Char;
        A: TMimeAttachment;
begin
        A:=Retrieve(AttNumber);
        AssignFile(FromF,A.Location);
        AssignFile(ToF,Location);
        Rewrite(ToF, 1);
        Reset(FromF,1);
        repeat
                BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
                BlockWrite(ToF, Buf, NumRead, NumWritten);
        until (NumRead = 0) or (NumWritten <> NumRead);
        System.CloseFile(FromF);
        System.CloseFile(ToF);
end;

function TAttachmentManager.GetTempFile(AttNumber: LongInt;extension: string): string;
var
        buf: string[255];
        A: TMimeAttachment;
begin
        A:=Retrieve(AttNumber);
        if not A.Stored then Result:=A.Location
        else
        begin
                GetWindowsDirectory(@buf[1],200);
                buf[0]:=Char(StrLen(@buf[1]));
                if buf[Length(buf)]<>'\' then buf:=buf+'\';
                buf:=buf+'temp\';
                ForceDirectories(buf);
                buf:=buf+ExtractFileName(A.Location)+'.'+extension;
                try
                        TempFiles.Add(buf);
                except
                        {}
                end;
                Copy(AttNumber,buf);
                Result:=buf;
        end;
end;

function TAttachmentManager.GetAttDir: string;
begin
        if csDesigning in ComponentState then Result:=FAttDirectory
        else
        begin
                if (FAttDirectory='') then SetAttDir(ExtractFilePath(Application.ExeName)+'attach\');
                Result:=FAttDirectory;
        end;
end;

procedure TAttachmentManager.SetAttDir(s: string);
begin
        FAttDirectory:=s;
        ForceDirectories(FAttDirectory);
end;

end.
