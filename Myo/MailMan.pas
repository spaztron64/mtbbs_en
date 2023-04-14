unit MailMan;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Grids,MailSys, ComCtrls,Dialogs;

type
  TMailManager = class(TForm)
    OKBtn: TButton;
    StringGrid1: TStringGrid;
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    LimitDate: TEdit;
    Label2: TLabel;
    FromIDs: TMemo;
    LimitFromID: TCheckBox;
    LimitToID: TCheckBox;
    ToIDs: TMemo;
    Label1: TLabel;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  MailManager: TMailManager;

implementation

{$R *.DFM}


procedure TMailManager.FormCreate(Sender: TObject);
begin

  StringGrid1.Cells[0,0] := 'IDX';
  StringGrid1.Cells[1,0] := '送信者';
  StringGrid1.Cells[2,0] := '受信者';
  StringGrid1.Cells[3,0] := '日時';
  StringGrid1.Cells[4,0] := '状態';
  StringGrid1.Cells[5,0] := 'タイトル';

end;

procedure TMailManager.FormShow(Sender: TObject);
Var
   i,j : Integer;
   M   : TMail;
   MailSystem : TMailSystem;

   Function CheckIDS(ID : String;Memo : TMemo) : Boolean;
   Var
     i : Integer;
   Begin
      Result := False;
      For i := 0 to Memo.Lines.Count - 1 Do
        If ID = Memo.Lines[i] then
         Begin
           Result := True;
           Exit;
         End;
   End;

begin


  j := 0;
 MailSystem := TMailSystem.Create;

  StringGrid1.RowCount := 100;

         StringGrid1.Cells[0,1] := '';
         StringGrid1.Cells[1,1] := '';
         StringGrid1.Cells[2,1] := '';
         StringGrid1.Cells[3,1] := '';
         StringGrid1.Cells[4,1] := '';
         StringGrid1.Cells[5,1] := '';

  For i := 0 to MailMax do
    if Not(Mails[i].Status = MS_Deleted) then
     Begin
        Repeat
          With Mails[i] do
           Begin
            If LimitFromID.Checked Then
              If Not CheckIDS(FromID,FromIDs) Then Break;
            If LimitToID  .Checked Then
              If Not CheckIDS(ToID  ,  ToIDs) Then Break;
            If (Now - DateTime) < (StrToInt(LimitDate.Text)) then Break;
           End;

         M := MailSystem.ReadHead(i,false);
         StringGrid1.Cells[0,j+1] := IntToStr(i);
         StringGrid1.Cells[1,j+1] := M.FromID;
         StringGrid1.Cells[2,j+1] := M.ToID;
         StringGrid1.Cells[3,j+1] := DateTimeToStr(M.DateTime);
         Case M.Status of
           MS_NoRead : StringGrid1.Cells[4,j+1] := '未読';
           MS_Read   : StringGrid1.Cells[4,j+1] := '既読';
         End;
         StringGrid1.Cells[5,j+1] := M.Title;
         Inc(j);
        Until True;

         If 99 < j+1 then Break;
     End;

  if J+1 < 2 then j := 1;

  StringGrid1.RowCount := J+1;

 MailSystem.Free;

end;



procedure TMailManager.Button1Click(Sender: TObject);
Var
  i : Integer;
  MailSystem : TMailSystem;
  n : Integer;
begin

   If MessageDlg( '表示されているすべてのメールが削除されます。よろしいですか？'
           ,mtConfirmation,[mbYes,mbNo], 0)
           = mrNO then Exit;

 MailSystem := TMailSystem.Create;


    For  i := 1 to StringGrid1.RowCount - 1 do
     Begin
       n := StrToIntDef(StringGrid1.Cells[0,i],-1);
       If n > -1 then
           MailSystem.Kill(n);
     End;


 MailSystem.Free;
 FormShow(Sender);


end;


procedure TMailManager.Button2Click(Sender: TObject);
Var
  MailSystem : TMailSystem;
  n : Integer;
begin

   If MessageDlg( '削除してよろしいですか？'
           ,mtConfirmation,[mbYes,mbNo], 0)
           = mrNO then Exit;

  MailSystem := TMailSystem.Create;

     n := StrToIntDef(StringGrid1.Cells[0,StringGrid1.Selection.Top],-1);
     If n > -1 then
           MailSystem.Kill(n);

 MailSystem.Free;

 FormShow(Sender);

end;

end.
