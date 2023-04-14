unit Sendmail;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Starsock, Inetmail, StdCtrls, ExtCtrls;

const WM_SENDMSG=WM_USER+1;

type TSendMailForm = class(TForm)
    Status: TLabel;
    StatusBk: TPanel;
    StatusBar: TPanel;
    Stop: TButton;
    SendMail1: SendMail;
    procedure FormShow(Sender: TObject);
  private
    procedure WMSendMsg(var Msg: TMsg);message WM_SENDMSG;
  public
    { Public declarations }
  end;

var
  SendMailForm: TSendMailForm;

implementation

{$R *.DFM}

procedure TSendMailForm.FormShow(Sender: TObject);
begin
        Status.Caption:='Connecting to '+IniInfo.SMTPServer;
        PostMessage(Handle,WM_SENDMSG,0,0);
end;

procedure WMSendMsg(var Msg: TMsg);
begin
        with SendMail1 do
        begin
                SMTP_Server:=IniInfo.SMTPServer;
                SMTP_Port:=IniInfo.SMTPPort;
        end;

end.
