unit UList;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls,Dialogs;

type
  TUserList = class(TForm)
    OKBtn: TButton;
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  UserList: TUserList;

implementation

uses UEdit,UserSys;

{$R *.DFM}


procedure TUserList.Button1Click(Sender: TObject);
begin

   User.UserInit := DefaultUserInit;
   User.UserInit.SignOn := Now;
   User.Showmodal;

end;

procedure TUserList.FormShow(Sender: TObject);
begin

     ListBox1.Items.Text := GetUserList;

end;

procedure TUserList.Button3Click(Sender: TObject);
Var
  a : String;
begin

     If ListBox1.ItemIndex>-1 then
       Begin
        a := ListBox1.Items[ListBox1.ItemIndex];
        User.UserInit := GetUserInit(Copy(a,1,Pos(' ',a)-1));
        User.ShowModal;
       End;


end;

procedure TUserList.Button2Click(Sender: TObject);
Var
  a : String;
  UI : TUserInit;
begin



     If ListBox1.ItemIndex>-1 then
       Begin
       a := ListBox1.Items[ListBox1.ItemIndex];
       a := Copy(a,1,Pos(' ',a)-1);
        Case MessageDlg(a+' を完全に抹消しますか? '#13#10
                       +'「はい」を選択すると該当IDの復活はできません.'#13#10
                       +'「いいえ」を選択するとレベル０(抹消会員)に指定されます.'#13#10
         ,mtConfirmation,[mbYes,mbNo,mbCancel], 0) of
         mrYes : DeleteUser(a);
         mrNo   : Begin
                  UI := GetUserInit(a);
                  UI.Level := 0;
                  OutUserInit(a,UI);
               End;
         mrCancel : Exit;
        End;
        FormShow(UserList);
       End;

end;

end.
