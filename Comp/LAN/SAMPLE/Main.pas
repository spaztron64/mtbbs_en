unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, UserList;

type
  TForm1 = class(TForm)
    UserList1: TUserList;
    BitBtn1: TBitBtn;
    ListBox1: TListBox;
    Button1: TButton;
    Edit1: TEdit;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  i : Integer;
begin

  UserList1.ServerName := Edit1.Text;

  UserList1.SetItems;
  for i:=0 to UserList1.Count-1 do
  begin
    UserList1.Index := i;
    ListBox1.Items.Add( UserList1.UserName );
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i : Integer;
begin
  UserList1.ServerName := Edit1.Text;
  UserList1.SetItems;
  for i:=0 to UserList1.Count-1 do
  begin
    UserList1.Index := i;
    ListBox1.Items.Add( UserList1.UserName
                        +'/'+UserList1.Comments
                        +'/'+UserList1.UserComments
                        +'/'+UserList1.FullName
     );
  end;
end;

end.
