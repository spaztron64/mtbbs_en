unit Sndmail;

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
    procedure SendMail1MailInfo(Sender: TObject; info: SendMailInfo;addinfo: String);
    procedure SendMail1MailError(Sender: TObject; error: SendMailError;
      addinfo: string);
    procedure SendMail1Done(Sender: TObject);
  private
        todo, done: LongInt;
        procedure WMSendMsg(var Msg: TMsg);message WM_SENDMSG;
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

uses Global;

procedure TSendMailForm.FormShow(Sender: TObject);
begin
        Status.Caption:='Connecting to '+IniInfo.SMTPServer;
        PostMessage(Handle,WM_SENDMSG,0,0);
end;

procedure TSendMailForm.WMSendMsg(var Msg: TMsg);
begin
        with SendMail1 do
        begin
                SMTP_Server:=IniInfo.SMTPServer;
                SMTP_Port:=IniInfo.SMTPPort;
                Action:=Send_Mail;
        end;
end;


procedure TSendMailForm.SendMail1MailInfo(Sender: TObject; info: SendMailInfo;
  addinfo: String);
var
        l: longint;
begin
        case info of
        smResolvingAddress: Status.Caption:='Resolving '+addinfo;
        smAddressResolved: Status.Caption:='Connected to '+addinfo;
        smServerConnected: Status.Caption:='Connected to '+addinfo;
        smServerDisconnected: Status.Caption:='Disconnected';
        smSendingMessage:
                begin
                        Status.Caption:='Sending Message';
                        done:=StrToInt(addinfo);
                        l:=(done*StatusBk.Width) div todo;
                        StatusBar.Width:=l;
                end;
        smMessageSize: todo:=StrToInt(addinfo);
        smMessageAccepted: Status.Caption:='Message sent';
        smRecipient: Status.Caption:='To: '+addinfo;
        smBadAddress: Status.Caption:='Recipient '+addinfo+' Rejected!';
        smAttachmentName: Status.Caption:='Sending attachment '+addinfo;
        smAttachmentSize:
                begin
                        todo:=StrToInt(addinfo);
                        StatusBar.Width:=0;
                end;
        smAttachmentBytes:
                begin
                        done:=StrToInt(addinfo);
                        l:=(done*StatusBk.Width) div todo;
                        StatusBar.Width:=l;
                end;
        end;
end;


procedure TSendMailForm.SendMail1MailError(Sender: TObject;
  error: SendMailError; addinfo: string);
begin
       case error of
       smWInsockNotInitialized: Application.MessageBox('The winsock interface could not be '+
                'initialized. Make sure that winsock is installed on your system.',
                'Winsock Error',MB_OK+MB_ICONSTOP);
       smNetworkUnreachable,smAddressNotAvailable,smHostUnreachable,smNetworkDown: Application.MessageBox('The network is '+
                'down. Make sure that you have established a connection to the network.',
                'Network Down Error',MB_OK+MB_ICONSTOP);
       smInvalidAddress,smAddressResolutionError: Application.MessageBox('StarMail could not find your SMTP mail server. '+
                'Check that you are connected to your service provider and '+
                'that your setup information is correct.','Name Resolution Error',MB_OK+MB_ICONSTOP);
       smInternalError,smGeneralWinsockError,smUnknown: Application.MessageBox('An unexpected error occured',
                'Unexpected Error',MB_OK+MB_ICONSTOP);
       smPrematureDisconnect,smConnAborted,smConnReset: Application.MessageBox('The connection was unexpectedly closed by the'+
                ' remote server','Premature Disconnect Error',MB_OK+MB_ICONSTOP);
       smConnectTimeOut: Application.MessageBox('The connection attempt to the server timed out.','Connect Timeout Error',
                MB_OK+MB_ICONSTOP);
       smOutofSockets: Application.MessageBox('The winsock is out of sockets. Close a winsock application before trying '+
                'again.','Out of Sockets Error',MB_OK+MB_ICONSTOP);
       smConnectionRefused: Application.MessageBox('The mail server refused the connection. Make sure that you have '+
                'entered the correct value in setup for your SMTP server.','Connection Rejected Error',MB_OK+MB_ICONSTOP);
       smProtocolError: Application.MessageBox('An unexpected response was received from the mail server. Make sure that you '+
                'have entered the correct value in setup for your SMTP port.','Unexpected Response Error',MB_OK+MB_ICONSTOP);
       smCanceled:Application.MessageBox('The sending of mail was canceled.','Transaction Canceled',MB_OK+MB_ICONSTOP);
       smMailDestinationError: Application.MessageBox('No recipients were specified for the message.',
                'No Recipients Error',MB_OK+MB_ICONSTOP);
       end;
end;

procedure TSendMailForm.SendMail1Done(Sender: TObject);
begin
        if SendMail1.Success then ModalResult:=mrOK
        else ModalResult:=mrCancel;
end;

end.
