unit UEdit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls,UserSys, ComCtrls;

type
  TUser = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    Address: TEdit;
    Label6: TLabel;
    Name: TEdit;
    Label7: TLabel;
    TelNo: TEdit;
    Label8: TLabel;
    Hobby: TEdit;
    Label9: TLabel;
    Comment: TMemo;
    GroupBox2: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    AccessCount: TEdit;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ID: TEdit;
    Handle: TEdit;
    Level: TEdit;
    Button3: TButton;
    Password: TEdit;
    Button4: TButton;
    LastLoginDate: TDateTimePicker;
    LastLoginTime: TDateTimePicker;
    EditID: TLabel;
    Label13: TLabel;
    Label12: TLabel;
    BirthDay: TEdit;
    Label14: TLabel;
    SignOnDate: TDateTimePicker;
    SignOnTime: TDateTimePicker;
    Label15: TLabel;
    Email: TEdit;
    Bevel1: TBevel;
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure LevelChange(Sender: TObject);
  private

  public

    UserInit : TUserInit;

  end;

var
  User: TUser;

implementation

uses UList;

{$R *.DFM}


procedure TUser.FormShow(Sender: TObject);
begin

     ID         .Text := UserInit.ID;
     EditID  .Caption := UserInit.ID;

     Handle     .Text := UserInit.Handle;
     Level      .Text := IntToStr(UserInit.Level);
     Password   .Text := UserInit.Password;

     SignOnDate .Date := UserInit.SignOn;
     SignOnTime .Time := UserInit.SignOn;

 //
     Address    .Text := UserInit.Address;
     Name       .Text := UserInit.Name;
     TelNo      .Text := UserInit.TelNo;
     Hobby      .Text := UserInit.Hobby;
     BirthDay   .Text := UserInit.BirthDay;
     Comment    .Text := UserInit.Comment;
     EMail      .Text := UserInit.Email;
//
     AccessCount.Text := IntToStr(UserInit.AccessCount);
     LastLoginDate.Date := UserInit.LastLogin;
     LastLoginTime.Time := UserInit.LastLogin;


end;

procedure TUser.OKBtnClick(Sender: TObject);
Var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;

begin

     UserInit.ID      := UpperCase(ID        .Text);
     UserInit.Handle  := Handle    .Text;
     UserInit.Level   := StrToIntDef(Level.Text,1);
     UserInit.Password:= Password   .Text;



     UserInit.SignOn  := Trunc(SignOnDate.Date) + SignOnTime.Time - Trunc(SignOnTime.Time);
//
     UserInit.Address := Address    .Text;
     UserInit.Name    := Name       .Text;
     UserInit.TelNo   := TelNo      .Text;
     UserInit.Hobby   := Hobby      .Text;
     UserInit.BirthDay:= BirthDay   .Text;
     UserInit.Comment := Comment    .Text;
     UserInit.Email   := Email      .Text;
//
     UserInit.AccessCount := StrToIntDef(AccessCount.Text,0);
     UserInit.LastLogin   := Trunc(LastLoginDate.Date) +  LastLoginTime.Time - Trunc(LastLoginTime.Time);

 OutUserInit(EditID.Caption,UserInit);

  If UserList.Visible then
     UserList.FormShow(UserList);


end;

procedure TUser.Button3Click(Sender: TObject);
begin

    Level.Text := IntToStr(StrToIntDef(Level.Text,1)+1);

end;

procedure TUser.Button4Click(Sender: TObject);
begin

    Level.Text := IntToStr(StrToIntDef(Level.Text,1)-1);

end;

procedure TUser.LevelChange(Sender: TObject);
begin

 If (9< StrToIntDef(Level.Text,1)) or (StrToIntDef(Level.Text,1)<-1) then
    Level.Text := '1';

end;



end.
