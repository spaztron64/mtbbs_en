unit ServerProperty;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls;

type
  TServerPropertyForm = class(TForm)
    Image1: TImage;
    PageControl: TPageControl;
    ServerPage: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    NameEdt: TEdit;
    ServerEdt: TEdit;
    PortEdt: TEdit;
    Label4: TLabel;
    DescriptionMemo: TMemo;
    Button1: TButton;
    Button2: TButton;
    UserPage: TTabSheet;
    UserEdt: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    PasswordEdt: TEdit;
    Label7: TLabel;
    AccountEdt: TEdit;
    AnonymousCB: TCheckBox;
    CheckBox2: TCheckBox;
    UpDown1: TUpDown;
    Edit7: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    EMailEdt: TEdit;
    TabSheet3: TTabSheet;
    Label10: TLabel;
    Label11: TLabel;
    LocalDirEdt: TEdit;
    Button3: TButton;
    RemoteDirEdt: TEdit;
    Button4: TButton;
    TabSheet4: TTabSheet;
    Label12: TLabel;
    TabSheet5: TTabSheet;
    Label13: TLabel;
    SavePasswordCB: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure AnonymousCBClick(Sender: TObject);
  private
    { Private declarations }
  public
        Update: Boolean;
  end;

implementation

{$R *.DFM}

uses IniFiles;

procedure TServerPropertyForm.Button1Click(Sender: TObject);
var
        f: TSearchRec;
        r: integer;
        i: TIniFile;
        buf: PChar;
begin
        if NameEdt.Text='' then
        begin
                PageControl.ActivePage:=ServerPage;
                ActiveControl:=NameEdt;
                NameEdt.Color:=clRed;
                MessageDlg('You must specify a name for the connection.',mtError,[mbOk],0);
                NameEdt.Color:=clWhite;
                Exit;
        end;
        {check for duplicate name}
        if not Update then
        begin
                r:=FindFirst(ExtractFilePath(Application.ExeName)+'\'+NameEdt.Text+'.ftp',faAnyFile,f);
                if r=0 then
                begin
                        PageControl.ActivePage:=ServerPage;
                        ActiveControl:=NameEdt;
                        NameEdt.Color:=clRed;
                        MessageDlg('An FTP connection called '+NameEdt.Text+' already exists. Please '+
                           'enter another name.',mtError,[mbOk],0);
                        NameEdt.Color:=clWhite;
                        FindClose(f);
                        Exit;
                end;
        end;
        FindClose(f);
        if ServerEdt.Text='' then
        begin
                PageControl.ActivePage:=ServerPage;
                ActiveControl:=ServerEdt;
                ServerEdt.Color:=clRed;
                MessageDlg('You must specify an FTP server to connect to.',mtError,[mbOk],0);
                ServerEdt.Color:=clWhite;
                Exit;
        end;
        try
                StrToInt(PortEdt.Text);
        except
                PageControl.ActivePage:=ServerPage;
                ActiveControl:=PortEdt;
                PortEdt.Color:=clRed;
                MessageDlg('You must specify a number for the FTP port (usually 25).',mtError,[mbOk],0);
                PortEdt.Color:=clWhite;
                Exit;
        end;
        if StrToInt(PortEdt.Text)<>21 then
        begin
                if MessageDlg('You specified an FTP port value of '+PortEdt.Text+'. This value is normally '+
                   '21. Are you sure you want to keep this value?',mtInformation,[mbYes,mbNo],0)=mrNo then PortEdt.Text:='21';
        end;
        if not AnonymousCB.Checked then
        begin
                if UserEdt.Text='' then
                begin
                        PageControl.ActivePage:=UserPage;
                        ActiveControl:=UserEdt;
                        UserEdt.Color:=clRed;
                        MessageDlg('You must specify a user ID or check the Anonymous Login box',mtError,[mbOk],0);
                        UserEdt.Color:=clWhite;
                        Exit;
                end;
                if PasswordEdt.Text='' then
                begin
                        PageControl.ActivePage:=UserPage;
                        ActiveControl:=PasswordEdt;
                        PasswordEdt.Color:=clRed;
                        MessageDlg('You must specify a Password or check the Anonymous Login box',mtError,[mbOk],0);
                        PasswordEdt.Color:=clWhite;
                        Exit;
                end;
        end
        else
        begin
                if EMailEdt.Text='' then
                begin
                        PageControl.ActivePage:=UserPage;
                        ActiveControl:=EMailEdt;
                        if MessageDlg('It is customary to send your E-mail address as the password when logging in '+
                           'anonymously. Do you want to enter your E-mail address?',mtInformation,[mbYes,mbNo],0)=mrYes then Exit;
                end;
        end;
        {let's write the *.ftp file, which is really an ini file with an ftp extension}
        i:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'\'+NameEdt.Text+'.ftp');
        i.WriteString('Server','name',NameEdt.Text);
        i.WriteString('Server','server',ServerEdt.Text);
        i.WriteInteger('Server','port',StrToInt(PortEdt.Text));
        r:=DescriptionMemo.GetTextLen+1;
        GetMem(buf,r);
        DescriptionMemo.GetTextBuf(buf,r);
        i.WriteString('Server','description',String(buf));
        FreeMem(buf,r);
        i.WriteString('User','user',UserEdt.Text);
        if SavePasswordCB.Checked then i.WriteString('User','password',PasswordEdt.Text);
        i.WriteBool('User','SavePassword',SavePasswordCB.Checked);
        i.WriteString('User','account',AccountEdt.Text);
        i.WriteBool('User','Anonymous',AnonymousCB.Checked);
        i.WriteString('Directories','Local',LocalDirEdt.Text);
        i.WriteString('Directories','Remote',RemoteDirEdt.Text);
        i.Destroy;
        ModalResult:=mrOk;
end;

procedure TServerPropertyForm.AnonymousCBClick(Sender: TObject);
begin
        if AnonymousCB.Checked then
        begin
                UserEdt.Enabled:=False;
                PasswordEdt.Enabled:=False;
                AccountEdt.Enabled:=False;
                EMailEdt.Enabled:=True;
        end
        else
        begin
                UserEdt.Enabled:=True;
                PasswordEdt.Enabled:=True;
                AccountEdt.Enabled:=True;
                EMailEdt.Enabled:=False;
        end;
end;

end.
