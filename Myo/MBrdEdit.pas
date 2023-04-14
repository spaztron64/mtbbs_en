unit MBrdEdit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TMessageBoardEdit = class(TForm)
    OKBtn: TButton;
    ListBox1: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Title: TEdit;
    BoardLabel: TEdit;
    enabled: TCheckBox;
    Label3: TLabel;
    ReadLevel: TEdit;
    Label4: TLabel;
    WriteLevel: TEdit;
    Label5: TLabel;
    Sigop: TEdit;
    BoardNo: TPanel;
    Label6: TLabel;
    Bevel1: TBevel;
    EnforcedNews: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure enabledClick(Sender: TObject);
    procedure ReadLevelChange(Sender: TObject);
    procedure WriteLevelChange(Sender: TObject);
    procedure TitleChange(Sender: TObject);
    procedure BoardLabelChange(Sender: TObject);
    procedure SigopChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EnforcedNewsClick(Sender: TObject);
  private
     Bn : Integer;

  public
    { Public êÈåæ }
  end;

var
  MessageBoardEdit: TMessageBoardEdit;

implementation

{$R *.DFM}

uses
   MesBrd;

Function  MakeItemStr(n : Integer) : String;
Var
   B : TBoard;
Begin

     B := MessageBoards[n];

       Result := Format('%.2d:',[n]);
       If b.Enabled then
          Result := Result+'Åõ'
       else
          Result := Result+'Å~';
       Result := Result + Format('%.8s %.32s',[b.Name+'              ',b.Title]);

End;

procedure TMessageBoardEdit.FormShow(Sender: TObject);
Var
   i : Integer;
   s : string;
   B : TBoard;
begin

  ListBox1.Clear;

   For i := 1 To 99 Do
      ListBox1.Items.Add(MakeItemStr(i));

  ListBox1.ItemIndex := 0;
  ListBox1Click(Sender);

end;

procedure TMessageBoardEdit.ListBox1Click(Sender: TObject);
Var
   B : TBoard;
begin

     Bn  := ListBox1.ItemIndex+1;
     BoardNo.Caption := IntToStr(Bn);

     B := MessageBoards[ListBox1.ItemIndex+1];

      Enabled.Checked      := B.Enabled;
      ReadLevel.Text       := IntToStr(B.ReadLevel);
      WriteLevel.Text      := IntToStr(B.WriteLevel);
      Title.Text           := B.Title;
      BoardLabel.Text      := B.Name;
      SigOp.Text           := B.SigOpID;
      EnforcedNews.Checked := B.EnforcedNews;

end;

procedure TMessageBoardEdit.enabledClick(Sender: TObject);
begin

     MessageBoards[Bn].Enabled := Enabled.Checked;
     ListBox1.Items[Bn-1] := MakeItemStr(Bn);

end;

procedure TMessageBoardEdit.ReadLevelChange(Sender: TObject);
begin
     MessageBoards[Bn].ReadLevel := StrToIntDef(ReadLevel.Text,1);
end;

procedure TMessageBoardEdit.WriteLevelChange(Sender: TObject);
begin
     MessageBoards[Bn].WriteLevel := StrToIntDef(WriteLevel.Text,1);
end;

procedure TMessageBoardEdit.TitleChange(Sender: TObject);
begin
     MessageBoards[Bn].Title := Title.Text;
     ListBox1.Items[Bn-1] := MakeItemStr(Bn);
end;

procedure TMessageBoardEdit.BoardLabelChange(Sender: TObject);
begin
     MessageBoards[Bn].Name := UpperCase(BoardLabel.Text);
     ListBox1.Items[Bn-1] := MakeItemStr(Bn);
end;

procedure TMessageBoardEdit.SigopChange(Sender: TObject);
begin

     MessageBoards[Bn].SigOpId := SigOp.Text;

end;


procedure TMessageBoardEdit.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

     MessageBoardsChange := True;

end;

procedure TMessageBoardEdit.EnforcedNewsClick(Sender: TObject);
begin

     MessageBoards[Bn].EnforcedNews := EnforcedNews.Checked;

end;

end.
