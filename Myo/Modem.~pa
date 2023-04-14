unit Modem;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls,IniFiles;


type

  TModemSetting = Record
    Enabled  : Boolean;
    Port     : Integer;
    BaudRate : Integer;
    ClearCommand : String;
  End;

  TModemSettingDialog = class(TForm)
    OKBtn: TButton;
    TabControl1: TTabControl;
    Rate: TComboBox;
    Port: TComboBox;
    Label2: TLabel;
    Label1: TLabel;
    Label3: TLabel;
    ClearCommand: TEdit;
    Enabled: TCheckBox;
    procedure TabControl1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabControl1Changing(Sender: TObject;
      var AllowChange: Boolean);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EnabledClick(Sender: TObject);
  private
    FiniFileName : String;
  public
    { Public êÈåæ }
  end;

var

  ModemSettingDialog : TModemSettingDialog;
  ModemSetting : Array [0..4] of TModemSetting;

implementation

uses Main;


{$R *.DFM}



procedure TModemSettingDialog.TabControl1Change(Sender: TObject);
begin

     Enabled.Checked   := ModemSetting[TabControl1.TabIndex].Enabled;
     EnabledClick(Sender);
     Port.ItemIndex    := ModemSetting[TabControl1.TabIndex].Port-1;
     Rate.Text         := IntToStr(ModemSetting[TabControl1.TabIndex].BaudRate);
     ClearCommand.Text := ModemSetting[TabControl1.TabIndex].ClearCommand;

end;

procedure TModemSettingDialog.FormShow(Sender: TObject);
begin

   TabControl1Change(Sender);

end;

procedure TModemSettingDialog.TabControl1Changing(Sender: TObject;
  var AllowChange: Boolean);
begin

     ModemSetting[TabControl1.TabIndex].Enabled      := Enabled.Checked;
     ModemSetting[TabControl1.TabIndex].Port         := Port.ItemIndex+1;
     ModemSetting[TabControl1.TabIndex].BaudRate     := StrToIntDef(Rate.Text,56000);
     ModemSetting[TabControl1.TabIndex].ClearCommand := ClearCommand.Text;

end;

procedure TModemSettingDialog.FormHide(Sender: TObject);
Var
   Dummy : Boolean;
begin

   TabControl1Changing(Sender,Dummy);

end;

procedure TModemSettingDialog.FormCreate(Sender: TObject);
Var
   Ini : TiniFile;
   i   : Integer;
begin

  FiniFileName := AppPath+ 'Modem.INI';

  Ini := TIniFile.Create(FiniFileName);

  With Ini Do
   Begin
    For i :=0 to 3 do
     Begin
       ModemSetting[i].Enabled      := Boolean(ReadInteger('Modem'+IntToStr(i),'Enabled',Integer(False)));
       ModemSetting[i].Port         := ReadInteger('Modem'+IntToStr(i),'Port',i+1);
       ModemSetting[i].BaudRate     := ReadInteger('Modem'+IntToStr(i),'BaudRate',56000);
       ModemSetting[i].ClearCommand := ReadString ('Modem'+IntToStr(i),'ClearCommand','ATZ');
     End;
    Free;
   End;

end;

procedure TModemSettingDialog.FormDestroy(Sender: TObject);
Var
   Ini : TiniFile;
   i   : Integer;
begin

  Ini := TIniFile.Create(FiniFileName);

  With Ini Do
   Begin
    For i :=0 to 3 do
     Begin
       WriteInteger('Modem'+IntToStr(i),'Enabled'     ,Integer(ModemSetting[i].Enabled));
       WriteInteger('Modem'+IntToStr(i),'Port'        ,ModemSetting[i].Port);
       WriteInteger('Modem'+IntToStr(i),'BaudRate'    ,ModemSetting[i].BaudRate);
       WriteString ('Modem'+IntToStr(i),'ClearCommand',ModemSetting[i].ClearCommand);
     End;
    Free;
   End;

end;

procedure TModemSettingDialog.EnabledClick(Sender: TObject);
begin

     Port.Enabled := Enabled.Checked;
     Rate.Enabled := Enabled.Checked;
     ClearCommand.Enabled := Enabled.Checked;

end;

end.
