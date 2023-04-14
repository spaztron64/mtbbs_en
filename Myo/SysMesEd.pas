unit SysMesEd;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls;

type
  TSystemMessageEdit = class(TForm)
    Memo1: TMemo;
    TabControl1: TTabControl;
    Panel1: TPanel;
    OKBtn: TButton;
    CancelBtn: TButton;
    Memo2: TMemo;
    procedure TabControl1Change(Sender: TObject);
    procedure TabControl1Changing(Sender: TObject;
      var AllowChange: Boolean);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  SystemMessageEdit: TSystemMessageEdit;




implementation

uses Define, Main;

{$R *.DFM}



procedure TSystemMessageEdit.TabControl1Change(Sender: TObject);
begin

 Case TabControl1.TabIndex of
     0 : Memo1.Text := OpeningMessage;
     1 : Memo1.Text := LoginMessage;
     2 : Memo1.Text := LogoutMessage;
     3 : Memo1.Text := ApplyInfoMessage;
     4 : Memo1.Text := SysInfoMessage;
     5 : Memo1.Text := ChatRoomOpeningMessage;
     6 : Memo1.Text := MainMenuMessage;
     7 : Memo1.Text := HelpMessage;
     8 : Memo1.Text := FileBoardInfoMessage;
     9 : Memo1.Text := OkotobaStrs.Text;
 End;

end;

procedure TSystemMessageEdit.TabControl1Changing(Sender: TObject;
  var AllowChange: Boolean);
begin


 Case TabControl1.TabIndex of
     0 : OpeningMessage   := Memo1.Text;
     1 : LoginMessage     := Memo1.Text;
     2 : LogoutMessage    := Memo1.Text;
     3 : ApplyInfoMessage := Memo1.Text;
     4 : SysInfoMessage   := Memo1.Text;
     5 : ChatRoomOpeningMessage := Memo1.Text;
     6 : MainMenuMessage  := Memo1.Text;
     7 : HelpMessage      := Memo1.Text;
     8 : FileBoardInfoMessage := Memo1.Text;
     9 : OkotobaStrs.Text := Memo1.Text;

 End;

end;

procedure TSystemMessageEdit.OKBtnClick(Sender: TObject);
Var
  dummy : Boolean;

  Procedure Save(S : String;Fn : String);
  Var
    F : File of Char;
    P : PChar;
  Begin

    AssignFile(F,AppPath + 'SYSMES\' + Fn);
     ReWrite(F);
     P := PChar(S);
     BlockWrite(F,P^,Length(S));
    CloseFile(f);

  End;

begin

 TabControl1Changing(Sender,dummy);

   CreateDir(AppPath + 'SYSMES\');

   Save(OpeningMessage           ,'LogIn.TXT');
   Save(LoginMessage             ,'LogIn2.TXT');
   Save(LogoutMessage            ,'LogOut.TXT');
   Save(ApplyInfoMessage         ,'Apply.TXT');
   Save(SysInfoMessage           ,'SysInfo.TXT');
   Save(ChatRoomOpeningMessage   ,'ChatMenu.TXT');
   Save(MainMenuMessage          ,'MainMenu.TXT');
   Save(HelpMessage              ,'Help.TXT');
   Save(FileBoardInfoMessage     ,'FBrdInfo.TXT');
   Save(OkotobaStrs.Text         ,'Okotoba.TXT');


end;

procedure TSystemMessageEdit.FormCreate(Sender: TObject);

   Function Load(Def : String;Fn : String):String;
   Var
     F : File Of Char;
     P : PChar;
   Begin

  Fn := AppPath + 'SYSMES\'+Fn;

    If Not FileExists(Fn) then
     Begin
       Result := Def;
       Exit;
     End;

     AssignFile(F,Fn);
     Reset(F);
      P := AllocMem(FileSize(f)+1);
       BlockRead(F,P^,FileSize(F));
       Result := StrPas(P);
      FreeMem(P,FileSize(f)+1);
     CloseFile(f);

   End;

begin

   OpeningMessage          := Load(DefOpeningMessage           ,'LogIn.TXT');
   LoginMessage            := Load(DefLogInMessage             ,'LogIn2.TXT');
   LogoutMessage           := Load(DefLogOutMessage            ,'LogOut.TXT');
   ApplyInfoMessage        := Load(DefApplyInfoMessage         ,'Apply.TXT');
   SysInfoMessage          := Load(DefSysInfoMessage           ,'SysInfo.TXT');
   ChatRoomOpeningMessage  := Load(DefChatRoomOpeningMessage   ,'ChatMenu.TXT');
   MainMenuMessage         := Load(DefMainMenuMessage          ,'MainMenu.TXT');
   HelpMessage             := Load(DefHelpMessage              ,'Help.TXT');
   FileBoardInfoMessage    := Load(DefFileBoardInfoMessage     ,'FBrdInfo.TXT');
   OkotobaStrs.Text        := Load(DefOkotobaStrs              ,'Okotoba.TXT');

end;

procedure TSystemMessageEdit.FormShow(Sender: TObject);
begin

     TabControl1Change(Sender);

end;

procedure TSystemMessageEdit.CancelBtnClick(Sender: TObject);
begin

   FormCreate(Sender);

end;

end.
