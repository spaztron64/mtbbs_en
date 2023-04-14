unit Global;

interface

uses Classes;

type TIniInfo=record
        UserName,UserID,Password: string;
        SMTPServer,POPServer: string;
        SMTPPort,POPPort: integer;
        LastMailBox,LastAttachment: integer;
end;

type TIniOptions=record
        AutoAddAddress: Boolean;
        FullHeaders: Boolean;
        SaveSent: Boolean;
        UseSignature: Boolean;
        AutoCheckMail: Boolean;
        AutoCheckStart: Boolean;
        AutoCheckMinutes: Integer;
        Browser: string;
end;

const
        IN_MAILBOX      =       1;
        OUT_MAILBOX     =       2;
        TRASH_MAILBOX   =       3;
        PENDING_MAILBOX =       4;

procedure LoadIniFile;
procedure SaveIniFile;
procedure ExtractAddress(line: string;var Address,Name: string);

var
        IniInfo: TIniInfo;
        IniOptions: TIniOptions;
        MailboxList: TStrings;
        AppDirectory: string;

implementation

uses Forms,IniFiles,SysUtils;

procedure LoadIniFile;
var
        f: TIniFile;
        AppDirectory: string;
begin
        AppDirectory:=ExtractFilePath(Application.ExeName);
        try
                f:=TIniFile.Create(AppDirectory+'starmail.ini');
                IniInfo.UserName:=f.ReadString('User','Name','');
                IniInfo.UserID:=f.ReadString('User','ID','');
                IniInfo.SMTPServer:=f.ReadString('SMTP','Server','');
                IniInfo.SMTPPort:=f.ReadInteger('SMTP','Port',25);
                IniInfo.POPServer:=f.ReadString('POP3','Server','');
                IniInfo.POPPort:=f.ReadInteger('POP3','Port',110);
                IniInfo.Password:=f.ReadString('POP3','Password','');
                IniInfo.LastMailbox:=f.ReadInteger('Mailbox','LastMailbox',-1);
                IniInfo.LastAttachment:=f.ReadInteger('Mailbox','LastAttachment',0);
                if IniInfo.LastMailbox=-1 then {create base mailboxes}
                begin
                        MailboxList.Add('m0=Messages Received');
                        MailboxList.Add('m1=Messages Sent');
                        MailboxList.Add('m2=TrashBasket');
                        MailboxList.Add('m3=Pending Messages');
                        IniInfo.LastMailbox:=3;
                        SaveIniFile;
                end
                else f.ReadSectionValues('Mailboxes',MailboxList);
                IniOptions.AutoAddAddress:=f.ReadBool('Options','AutoAddAddress',True);
                IniOptions.FullHeaders:=f.ReadBool('Options','FullHeaders',False);
                IniOptions.SaveSent:=f.ReadBool('Options','SaveSent',True);
                IniOptions.UseSignature:=f.ReadBool('Options','UseSignature',False);
                IniOptions.AutoCheckStart:=f.ReadBool('Options','AutoCheckStart',True);
                IniOptions.AutoCheckMail:=f.ReadBool('Options','AutoCheckMail',False);
                IniOptions.AutoCheckMinutes:=f.ReadInteger('Options','AutoCheckMinutes',30);
                IniOptions.Browser:=f.ReadString('Options','Browser','');
        finally
                f.Free;
        end;
end;

procedure SaveIniFile;
var
        f: TIniFile;
        AppDirectory,variable,value,s: string;
        i: integer;
begin
        AppDirectory:=ExtractFilePath(Application.ExeName);
        try
                f:=TIniFile.Create(AppDirectory+'starmail.ini');
                f.WriteString('User','Name',IniInfo.UserName);
                f.WriteString('User','ID',IniInfo.UserID);
                f.WriteString('SMTP','Server',IniInfo.SMTPServer);
                f.WriteInteger('SMTP','Port',IniInfo.SMTPPort);
                f.WriteString('POP3','Server',IniInfo.POPServer);
                f.WriteInteger('POP3','Port',IniInfo.POPPort);
                f.WriteString('POP3','Password',IniInfo.Password);
                f.WriteInteger('Mailbox','LastMailbox',IniInfo.LastMailbox);
                f.WriteInteger('Mailbox','LastAttachment',IniInfo.LastAttachment);
                for i:=0 to MailboxList.Count-1 do
                begin
                        s:=MailboxList[i];
                        variable:=Copy(s,1,Pos('=',s)-1);
                        value:=Copy(s,Pos('=',s)+1,999);
                        f.WriteString('Mailboxes',variable,value);
                end;
                f.WriteBool('Options','AutoAddAddress',IniOptions.AutoAddAddress);
                f.WriteBool('Options','FullHeaders',IniOptions.FullHeaders);
                f.WriteBool('Options','SaveSent',IniOptions.SaveSent);
                f.WriteBool('Options','UseSignature',IniOptions.UseSignature);
                f.WriteBool('Options','AutoCheckStart',IniOptions.AutoCheckStart);
                f.WriteBool('Options','AutoCheckMail',IniOptions.AutoCheckMail);
                f.WriteInteger('Options','AutoCheckMinutes',IniOptions.AutoCheckMinutes);
                f.WriteString('Options','Browser',IniOptions.Browser);
        finally
                f.Free;
        end;
end;

procedure ExtractAddress(line: string;var Address,Name: string);
begin
        {format 1:  FirstName LastName <EMailAddress>}
        if Pos('<',line)<>0 then
        begin
                address:=Copy(line,Pos('<',line)+1,Pos('>',line)-Pos('<',line)-1);
                name:=Copy(line,1,Pos('<',line)-1);
                while name[1]=' ' do Delete(name,1,1);
                while name[Length(name)]=' ' do Delete(name,Length(name),1);
                if name[1]='"' then Delete(Name,1,1);
                if name[Length(name)]='"' then Delete(name,Length(name),1);
        end;
        {format 2:  address (FirstName LastName)}
        if (Pos('(',line)<>0) and (Pos('<',line)=0) then
        begin
                name:=Copy(line,Pos('(',line)+1,Pos(')',line)-Pos('(',line)-1);
                if name[1]='"' then Delete(Name,1,1);
                if name[Length(name)]='"' then Delete(name,Length(name),1);
                address:=Copy(line,1,Pos('(',line)-1);
                while address[1]=' ' do Delete(address,1,1);
                while address[Length(address)]=' ' do Delete(address,Length(address),1);
        end;
        {format 3: address}
        if (Pos('<',line)=0) and (Pos('(',line)=0) then
        begin
                address:=line;
                name:='';
        end;
end;

end.
