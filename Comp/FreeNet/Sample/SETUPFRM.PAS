unit Setupfrm;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons;

type
  TSetupForm = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    UserEdt: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SMTPServerEdt: TEdit;
    SMTPPortEdt: TEdit;
    GroupBox3: TGroupBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    POP3Server: TEdit;
    POP3Port: TEdit;
    POP3PasswordEdt: TEdit;
    NameEdt: TEdit;
    procedure UserEdtExit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

{this is used to verify all form fields}
procedure TSetupForm.UserEdtExit(Sender: TObject);
var
        infoname,msg: string;
begin
        with Sender as TEdit do
        begin
                case Tag of
                1: infoname:='your name.';
                2: infoname:='your user ID.';
                3: infoname:='the name or address of your SMTP server.';
                4: infoname:='the port used by your SMTP server.';
                5: infoname:='the name or address of your POP3 server.';
                6: infoname:='the port used by your POP3 server.';
                7: infoname:='the password used to login to your POP3 server.';
                end;
                if Text='' then
                begin
                        Color:=clYellow;
                        msg:='You must specify '+infoname;
                        if Tag>1 then msg:=msg+' If you do not know this '+
                          'information, you should contact your Internet '+
                          'service provider.';
                        ShowMessage(msg);
                        ActiveControl:=Sender as TWinControl;
                        Color:=clWindow;
                        Exit;
                end;
                if (Tag=4) or (Tag=6) then
                begin
                        try
                                StrToInt(Text);
                        except
                                Color:=clYellow;
                                ShowMessage('You must specify a number for '+
                                  infoname);
                                ActiveControl:=Sender as TWinControl;
                                Color:=clWindow;
                        end;
                end;
        end;
end;

end.
