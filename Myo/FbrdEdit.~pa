unit FbrdEdit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TFileBoardEdit = class(TForm)
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    OKBtn: TButton;
    ListBox1: TListBox;
    Title: TEdit;
    BoardLabel: TEdit;
    enabled: TCheckBox;
    ReadLevel: TEdit;
    WriteLevel: TEdit;
    Sigop: TEdit;
    BoardNo: TPanel;
    procedure ListBox1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure enabledClick(Sender: TObject);
    procedure ReadLevelChange(Sender: TObject);
    procedure WriteLevelChange(Sender: TObject);
    procedure TitleChange(Sender: TObject);
    procedure BoardLabelChange(Sender: TObject);
    procedure SigopChange(Sender: TObject);
  private
     Bn : Integer;
  public
    { Public êÈåæ }
  end;

var
  FileBoardEdit: TFileBoardEdit;

implementation

{$R *.DFM}


uses FileBrd;

procedure TFileBoardEdit.ListBox1Click(Sender: TObject);
Var
   B : TFileBoard;
begin

     Bn  := ListBox1.ItemIndex+1;
     BoardNo.Caption := IntToStr(Bn);

     B := FileBoards[ListBox1.ItemIndex+1];

      Enabled.Checked      := B.Enabled;
      ReadLevel.Text       := IntToStr(B.ReadLevel);
      WriteLevel.Text      := IntToStr(B.WriteLevel);
      Title.Text           := B.Title;
      BoardLabel.Text      := B.Name;
      SigOp.Text           := B.BoardOpID;

end;

Function  MakeItemStr(n : Integer) : String;
Var
   B : TFileBoard;
Begin

     B := FileBoards[n];

       Result := Format('%.2d:',[n]);
       If b.Enabled then
          Result := Result+'Åõ'
       else
          Result := Result+'Å~';
       Result := Result + Format('%.8s %.32s',[b.Name+'              ',b.Title]);

End;


procedure TFileBoardEdit.FormShow(Sender: TObject);
Var
   i : Integer;
   s : string;
   B : TFileBoard;
begin

  ListBox1.Clear;

   For i := 1 To 99 Do
      ListBox1.Items.Add(MakeItemStr(i));

  ListBox1.ItemIndex := 0;
  ListBox1Click(Sender);

end;

procedure TFileBoardEdit.OKBtnClick(Sender: TObject);
begin

     FileBoardsSave;

end;

procedure TFileBoardEdit.enabledClick(Sender: TObject);
begin

     FileBoards[Bn].Enabled := Enabled.Checked;
     ListBox1.Items[Bn-1] := MakeItemStr(Bn);

end;

procedure TFileBoardEdit.ReadLevelChange(Sender: TObject);
begin

     FileBoards[Bn].ReadLevel := StrToIntDef(ReadLevel.Text,1);

end;

procedure TFileBoardEdit.WriteLevelChange(Sender: TObject);
begin

     FileBoards[Bn].WriteLevel := StrToIntDef(ReadLevel.Text,1);

end;

procedure TFileBoardEdit.TitleChange(Sender: TObject);
begin

     FileBoards[Bn].Title := Title.Text;
     ListBox1.Items[Bn-1] := MakeItemStr(Bn);

end;

procedure TFileBoardEdit.BoardLabelChange(Sender: TObject);
begin
     FileBoards[Bn].Name := UpperCase(BoardLabel.Text);
     ListBox1.Items[Bn-1] := MakeItemStr(Bn);

end;

procedure TFileBoardEdit.SigopChange(Sender: TObject);
begin

     FileBoards[Bn].BoardOpId := SigOp.Text;

end;

end.
