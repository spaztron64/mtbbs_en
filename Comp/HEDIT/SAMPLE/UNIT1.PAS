unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Menus, HEditor, HtSearch, ExtCtrls;

type
  TOpenMenuList = class;

  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Editor1: TEditor;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    PopupMenu1: TPopupMenu;
    LoadFromFile1: TMenuItem;
    FileList1: TMenuItem;
    New1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Clear1: TMenuItem;
    PageClose1: TMenuItem;
    N1: TMenuItem;
    Edit1: TMenuItem;
    Find1: TMenuItem;
    Replace1: TMenuItem;
    EditorOption1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    SelectAll1: TMenuItem;
    DeleteLine1: TMenuItem;
    N2: TMenuItem;
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    mnuFind: TMenuItem;
    mnuFindForward: TMenuItem;
    mnuFindBackward: TMenuItem;
    AutoIndent1: TMenuItem;
    TabIndent1: TMenuItem;
    CaretFree1: TMenuItem;
    BriefCaret1: TMenuItem;
    CaretNextLine1: TMenuItem;
    WantTabs1: TMenuItem;
    SoftTab1: TMenuItem;
    CaretInTab1: TMenuItem;
    OverWrite1: TMenuItem;
    Reserve1: TMenuItem;
    DisposeBlank1: TMenuItem;
    ReadOnly1: TMenuItem;
    UnderLine1: TMenuItem;
    RetMark1: TMenuItem;
    TabSheet2: TTabSheet;
    Editor2: TEditor;
    DelimDBCS1: TMenuItem;
    EOF1: TMenuItem;
    FontDialog1: TFontDialog;
    Font1: TMenuItem;
    DefaultDrawing1: TMenuItem;
    DrawAllWords1: TMenuItem;
    ReserveFont1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    K1: TMenuItem;
    K2: TMenuItem;
    K3: TMenuItem;
    ReserveBkColor1: TMenuItem;
    ColorDialog1: TColorDialog;
    TabSheet3: TTabSheet;
    Editor3: TEditor;
    WordWrap2: TMenuItem;
    WordWrap1: TMenuItem;
    WrapByte1: TMenuItem;
    K4: TMenuItem;
    RowCol1: TMenuItem;
    LinesChar1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure LoadFromFile1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure PageClose1Click(Sender: TObject);
    procedure Replace1Click(Sender: TObject);
    procedure Cut1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure DeleteLine1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure Redo1Click(Sender: TObject);
    procedure mnuFindClick(Sender: TObject);
    procedure mnuFindForwardClick(Sender: TObject);
    procedure mnuFindBackwardClick(Sender: TObject);
    procedure AutoIndent1Click(Sender: TObject);
    procedure TabIndent1Click(Sender: TObject);
    procedure CaretFree1Click(Sender: TObject);
    procedure BriefCaret1Click(Sender: TObject);
    procedure CaretNextLine1Click(Sender: TObject);
    procedure WantTabs1Click(Sender: TObject);
    procedure SoftTab1Click(Sender: TObject);
    procedure CaretInTab1Click(Sender: TObject);
    procedure OverWrite1Click(Sender: TObject);
    procedure Reserve1Click(Sender: TObject);
    procedure DisposeBlank1Click(Sender: TObject);
    procedure ReadOnly1Click(Sender: TObject);
    procedure UnderLine1Click(Sender: TObject);
    procedure RetMark1Click(Sender: TObject);
    procedure CaretMoved(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure EditorChange(Sender: TObject);
    procedure DelimDBCS1Click(Sender: TObject);
    procedure Editor2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure EOF1Click(Sender: TObject);
    procedure Font1Click(Sender: TObject);
    procedure Editor2BeforeDrawWord(Sender: TObject; WordStr: string;
      Reserved: Boolean);
    procedure Editor2DrawLine(Sender: TObject; LineStr: string; X, Y,
      Index: Integer; ARect: TRect);
    procedure DefaultDrawing1Click(Sender: TObject);
    procedure DrawAllWords1Click(Sender: TObject);
    procedure ReserveFont1Click(Sender: TObject);
    procedure ReserveBkColor1Click(Sender: TObject);
    procedure Editor2Click(Sender: TObject);
    procedure WordWrap1Click(Sender: TObject);
    procedure WrapByte1Click(Sender: TObject);
    procedure RowColClick(Sender: TObject);
  private
    FileList: TStringList;
    FOpenMenuList: TOpenMenuList;
    FColor: Integer;
    FFontColor: Integer;
    FSelectBkColor: Integer;
    FSelectFontColor: Integer;
    FReserveBkColor: Integer;
    FReserveFontColor: Integer;
    FSearchValue: String;
    FReplaceValue: String;
    FSearchOptions: TSearchOptions;
    FHintWindow: THintWindow;
    procedure CreateNewSheet(FileName: String);
    function GetEditor: TEditor;
    procedure GetColorInfo;
    function Search: Boolean;
    procedure OpenMenuListSelected(Sender: TObject);
    procedure AdjustCharacterMargin;
    procedure ShowHintWindow(S: String);
    procedure HideHintWindow;
  end;

  TOpenMenuList = class(TStringList)
  public
    FOnClickProc: TNotifyEvent;
    FMenuItem: TMenuItem;
    constructor Create(OnClickProc: TNotifyEvent; MenuItem: TMenuItem);
    destructor Destroy; override;
    procedure BringToTop(const S: String);
    procedure ReadIni;
    procedure WriteIni;
    procedure RecreateMenu;
  end;

var
  Form1: TForm1;

implementation

uses
  Clipbrd, Registry, IniFiles, HSchfm, HReplfm, Typinfo;

{$R *.DFM}

procedure SetProperties(Source, Dest: TComponent; TypeKinds: TTypeKinds;
  ExceptProp: String);
var
  PropList: PPropList;
  I, Count: Integer;
begin
  Count := GetPropList(Source.ClassInfo, TypeKinds, nil);
  GetMem(PropList, Count * SizeOf(PPropInfo));
  try
    GetPropList(Source.ClassInfo, TypeKinds, PropList);
    for I := 0 to Count - 1 do
      if Pos(PropList[I].Name, ExceptProp) = 0 then
      {$IFDEF VER90}
      case PropList[I].PropType.Kind of
      {$ELSE}
      case PropList[I].PropType^.Kind of
      {$ENDIF}
        tkFloat:
          SetFloatProp(
            Dest, PropList[I], GetFloatProp(Source, PropList[I]));
        tkInteger, tkChar, tkEnumeration, tkSet, tkClass:
          SetOrdProp(
            Dest, PropList[I], GetOrdProp(Source, PropList[I]));
        tkMethod:
          SetMethodProp(
            Dest, PropList[I], GetMethodProp(Source, PropList[I]));
        tkString:
          SetStrProp(
            Dest, PropList[I], GetStrProp(Source, PropList[I]));
        { ? tkArray, tkRecord, tkInterface, tkInt64, tkDynArray ? }
      end;
  finally
    FreeMem(PropList, Count * SizeOf(PPropInfo));
  end;
end;


{  TOpenMenuList  }

constructor TOpenMenuList.Create(OnClickProc: TNotifyEvent;
    MenuItem: TMenuItem);
begin
  FOnClickProc := OnClickProc;
  FMenuItem := MenuItem;
  ReadIni;
  RecreateMenu;
end;

destructor TOpenMenuList.Destroy;
var
  I: Integer;
begin
  WriteIni;
  for I := FMenuItem.Count - 1 downto 0 do
    FMenuItem.Items[I].Free;
  inherited Destroy;
end;

procedure TOpenMenuList.BringToTop(const S: String);
begin
  if IndexOf(S) <> -1 then
    Delete(IndexOf(S));
  Insert(0, S);
  if Count > 8 then
    Delete(Count - 1);
  RecreateMenu;
end;

procedure TOpenMenuList.ReadIni;
var
  Ini: TIniFile;
  I, Cnt: Integer;
begin
  Ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    Cnt := Ini.ReadInteger('OpenMenuItems', 'Count', 0);
    for I := 0 to Cnt - 1 do
      Add(Ini.ReadString('OpenMenuItems', 'Item' + IntToStr(I), ''));
  finally
    Ini.Free;
  end;
end;

procedure TOpenMenuList.WriteIni;
var
  Ini: TIniFile;
  I: Integer;
begin
  Ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    Ini.WriteInteger('OpenMenuItems', 'Count', Count);
    for I := 0 to Count - 1 do
      Ini.WriteString('OpenMenuItems', 'Item' + IntToStr(I), Strings[I]);
  finally
    Ini.Free;
  end;
end;

procedure TOpenMenuList.RecreateMenu;
var
  I: Integer;
  Item: TMenuItem;
begin
  for I := FMenuItem.Count - 1 downto 0 do
    FMenuItem.Items[I].Free;
  for I := 0 to Count - 1 do
  begin
    Item := TMenuItem.Create(FMenuItem);
    Item.Caption := Strings[I];
    Item.OnClick := FOnClickProc;
    FMenuItem.Add(Item);
  end;
end;


{  TForm1  }

procedure TForm1.OpenMenuListSelected(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    CreateNewSheet(TMenuItem(Sender).Caption);
    GetEditor.Lines.LoadFromFile(TMenuItem(Sender).Caption);
    GetEditor.Modified := False;
    StatusBar1.Panels[1].Text := '';
    FOpenMenuList.BringToTop(TMenuItem(Sender).Caption);
  end;
end;

procedure TForm1.GetColorInfo;
var
  Reg: TRegIniFile;
  Mb, Id, Rw: String;
  I: Integer;
begin
  Reg := TRegIniFile.Create('Software\Borland\Delphi\3.0');
  try
    Id := Reg.ReadString('Highlight', 'Identifier', '');
    Mb := Reg.ReadString('Highlight', 'Marked_block', '');
    Rw := Reg.ReadString('Highlight', 'Reserved_word', '');
  finally
    Reg.Free;
  end;
  // éØï éq
  I := Pos(',', Id);
  FFontColor := StrToIntDef(Copy(Id, 1, I - 1), clYellow);
  Delete(Id, 1, I);
  I := Pos(',', Id);
  FColor := StrToIntDef(Copy(Id, 1, I - 1), clNavy);
  // ëIëóÃàÊ
  I := Pos(',', Mb);
  FSelectFontColor := StrToIntDef(Copy(Mb, 1, I - 1), clNavy);
  Delete(Mb, 1, I);
  I := Pos(',', Mb);
  FSelectBkColor := StrToIntDef(Copy(Mb, 1, I - 1), clSilver);
  // ó\ñÒåÍ
  I := Pos(',', Rw);
  FReserveFontColor := StrToIntDef(Copy(Rw, 1, I - 1), clWhite);
  Delete(Rw, 1, I);
  I := Pos(',', Rw);
  FReserveBkColor := StrToIntDef(Copy(Rw, 1, I - 1), clNavy);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FileList := TStringList.Create;
  FileList.Add('TEditor Demo  HEditor.int');
  FileList.Add('TEditor Demo  Drawing');
  FileList.Add('TEditor Demo  WordWrap');
  FOpenMenuList := TOpenMenuList.Create(OpenMenuListSelected, FileList1);
  Editor2.Delimiters := Editor2.Delimiters - [':', '.', '/'];
  FHintWindow := THintWindow.Create(Self);
  {GetColorInfo;
  Editor1.Color := FColor;
  Editor1.Font.Color := FFontColor;
  Editor1.SelectBkColor := FSelectBkColor;
  Editor1.SelectFontColor := FSelectFontColor;
  Editor1.ReserveFontColor := FReserveFontColor;
  Editor1.ReserveWordColor := True;
  Editor1.RetMarkColor := FReserveFontColor;
  Editor1.UnderLineColor := FReserveFontColor;}
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FileList.Free;
  FOpenMenuList.Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  PageControl1.ActivePage := TabSheet1;
  Editor1.SetFocus;
  PageControl1Change(Self);
  Editor1.Row := 0;
  Editor1.Col := 0;
end;

function TForm1.GetEditor: TEditor;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to PageControl1.ActivePage.ControlCount - 1 do
    if PageControl1.ActivePage.Controls[I] is TEditor then
    begin
      Result := PageControl1.ActivePage.Controls[I] as TEditor;
      Exit;
    end;
end;

procedure TForm1.CreateNewSheet(FileName: String);
var
  Sheet: TTabSheet;
  Editor: TEditor;
begin
  FileList.Add(FileName);
  Sheet := TTabSheet.Create(Self);
  Sheet.Caption := ChangeFileExt(ExtractFileName(FileName), '');
  Sheet.PageControl := PageControl1;
  Editor := TEditor.Create(Self);
  Editor.Parent := Sheet;
  // SetProperties Ç≥ÇÍÇÈÇÃÇæÇ™ÅAÉTÉCÉYÇæÇØÇÕéwíË
  Editor.Width := Sheet.Width;
  Editor.Height := Sheet.Height;
  // ÉtÉ@ÉCÉãñºÇ…âûÇ∂Çƒ Editor1, Editor3 Ç©ÇÁ Lines, WordWrap à»äOÇÃ
  // ÉvÉçÉpÉeÉBílÇéÛÇØåpÇÆ
  if AnsiCompareText('.pas', ExtractFileExt(FileName)) = 0 then
    SetProperties(Editor1, Editor, tkAny, 'Lines, WordWrap')
  else
    SetProperties(Editor3, Editor, tkAny, 'Lines, WordWrap');
  with PageControl1 do ActivePage := Pages[PageCount - 1];
  Editor.SetFocus;
  PageControl1Change(Self);
  Editor.Row := 0;
  Editor.Col := 0;
end;

procedure TForm1.LoadFromFile1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    CreateNewSheet(OpenDialog1.FileName);
    GetEditor.Lines.LoadFromFile(OpenDialog1.FileName);
    GetEditor.Modified := False;
    StatusBar1.Panels[1].Text := '';
    FOpenMenuList.BringToTop(OpenDialog1.FileName);
  end;
end;

procedure TForm1.New1Click(Sender: TObject);
begin
  CreateNewSheet('new file');
end;

procedure TForm1.Clear1Click(Sender: TObject);
begin
  GetEditor.Lines.Clear;
end;

procedure TForm1.PageClose1Click(Sender: TObject);
var
  Index: Integer;
begin
  Index := PageControl1.ActivePage.PageIndex;
  if Index = 0 then
  begin
    Close;
    Exit;
  end;
  FileList.Delete(Index);
  with PageControl1 do
  begin
    GetEditor.Free;
    ActivePage.Free;
    ActivePage := Pages[Index - 1];
  end;
  PageControl1Change(Self);
end;

procedure TForm1.CaretMoved(Sender: TObject);
var
  Editor: TEditor;
begin
  Editor := GetEditor;
  if RowCol1.Checked then
    StatusBar1.Panels[0].Text :=
      Format('%5d çs:%4d åÖ',
             [Editor.Row + 1, Editor.Col + 1])
  else
    StatusBar1.Panels[0].Text :=
      Format('%5d çs:%4d åÖ',
             [Editor.RowToLines(Editor.Row) + 1,
              Editor.ColToChar(Editor.Row, Editor.Col) + 1]);
end;

procedure TForm1.PageControl1Change(Sender: TObject);
begin
  GetEditor.SetFocus;
  Caption := FileList[PageControl1.ActivePage.PageIndex];
  CaretMoved(Self);
  if GetEditor.OverWrite then
    StatusBar1.Panels[2].Text := 'è„èëÇ´'
  else
    StatusBar1.Panels[2].Text := 'ë}ì¸';
  if GetEditor.Modified then
    StatusBar1.Panels[1].Text := 'ïœçX'
  else
    StatusBar1.Panels[1].Text := '';
end;

procedure TForm1.PopupMenu1Popup(Sender: TObject);
var
  Sel: Boolean;
  Editor: TEditor;
begin
  Editor := GetEditor;
  AutoIndent1.Checked := Editor.CaretAutoIndent;
  TabIndent1.Checked := Editor.TabIndent;
  CaretFree1.Checked := Editor.CaretFree;
  BriefCaret1.Checked := Boolean(TCaretStyle(Editor.CaretStyle));
  CaretNextLine1.Checked := Editor.CaretNextLine;
  WantTabs1.Checked := Editor.WantTabs;
  SoftTab1.Checked := Editor.SoftTab;
  CaretInTab1.Checked := Editor.CaretInTab;
  OverWrite1.Checked := not Editor.OverWrite;
  OverWrite1Click(Self);
  Reserve1.Checked := Editor.ReserveWordColor;
  DisposeBlank1.Checked := Editor.DisposeBlank;
  ReadOnly1.Checked := Editor.ReadOnly;
  Sel := Editor.SelLength > 0;
  Copy1.Enabled := Sel;
  Cut1.Enabled := Sel;
  Redo1.Enabled := Editor.CanRedo;
  Undo1.Enabled := Editor.CanUndo;
  Clear1.Enabled := PageControl1.ActivePage.PageIndex > 2;
  PageClose1.Enabled := PageControl1.ActivePage.PageIndex > 2;
  Save1.Enabled := (PageControl1.ActivePage.PageIndex > 2) and
                   (PageControl1.ActivePage.Caption <> 'new file');
  SaveAs1.Enabled := PageControl1.ActivePage.PageIndex > 2;
  UnderLine1.Checked := Editor.UnderLine;
  RetMark1.Checked := Editor.RetMark;
  Eof1.Checked := Editor.EofMark;
  DelimDBCS1.Checked := Editor.DelimDBCS;
  DefaultDrawing1.Checked := Editor.DefaultDrawing;
  DefaultDrawing1.Enabled := PageControl1.ActivePage.PageIndex = 1;
  DrawAllWords1.Checked := Editor.DrawAllWords;
  DrawAllWords1.Enabled := PageControl1.ActivePage.PageIndex = 1;
  WordWrap1.Checked := Editor.WordWrap;
  WrapByte1.Caption := 'WrapByte ' + IntToStr(Editor.WrapByte);
end;

procedure TForm1.AutoIndent1Click(Sender: TObject);
begin
  AutoIndent1.Checked := not AutoIndent1.Checked;
  GetEditor.CaretAutoIndent := AutoIndent1.Checked;
end;

procedure TForm1.CaretFree1Click(Sender: TObject);
begin
  CaretFree1.Checked := not CaretFree1.Checked;
  GetEditor.CaretFree := CaretFree1.Checked;
end;

procedure TForm1.BriefCaret1Click(Sender: TObject);
begin
  BriefCaret1.Checked := not BriefCaret1.Checked;
  GetEditor.CaretStyle := TCaretStyle(Ord(BriefCaret1.Checked));
end;

procedure TForm1.CaretNextLine1Click(Sender: TObject);
begin
  CaretNextLine1.Checked := not CaretNextLine1.Checked;
  GetEditor.CaretNextLine := CaretNextLine1.Checked;
end;

procedure TForm1.WantTabs1Click(Sender: TObject);
begin
  WantTabs1.Checked := not WantTabs1.Checked;
  GetEditor.WantTabs := WantTabs1.Checked;
end;

procedure TForm1.SoftTab1Click(Sender: TObject);
begin
  SoftTab1.Checked := not SoftTab1.Checked;
  GetEditor.SoftTab := SoftTab1.Checked;
end;

procedure TForm1.CaretInTab1Click(Sender: TObject);
begin
  CaretInTab1.Checked := not CaretInTab1.Checked;
  GetEditor.CaretInTab := CaretInTab1.Checked;
end;

procedure TForm1.OverWrite1Click(Sender: TObject);
begin
  OverWrite1.Checked := not OverWrite1.Checked;
  if OverWrite1.Checked then
    StatusBar1.Panels[2].Text := 'è„èëÇ´'
  else
    StatusBar1.Panels[2].Text := 'ë}ì¸';
  GetEditor.OverWrite := OverWrite1.Checked;
end;

procedure TForm1.Cut1Click(Sender: TObject);
begin
  GetEditor.CutToClipboard;
end;

procedure TForm1.Copy1Click(Sender: TObject);
begin
  GetEditor.CopyToClipboard;
end;

procedure TForm1.Paste1Click(Sender: TObject);
begin
  GetEditor.PasteFromClipboard;
end;

procedure TForm1.SelectAll1Click(Sender: TObject);
begin
  GetEditor.SelectAll;
end;

procedure TForm1.DeleteLine1Click(Sender: TObject);
begin
  GetEditor.DeleteRow(GetEditor.Row);
end;

procedure TForm1.Reserve1Click(Sender: TObject);
begin
  Reserve1.Checked := not Reserve1.Checked;
  GetEditor.ReserveWordColor := Reserve1.Checked;
end;

procedure TForm1.DisposeBlank1Click(Sender: TObject);
begin
  DisposeBlank1.Checked := not DisposeBlank1.Checked;
  GetEditor.DisposeBlank :=  DisposeBlank1.Checked;
end;

procedure TForm1.EditorChange(Sender: TObject);
begin
  StatusBar1.Panels[1].Text := 'ïœçX';
end;

procedure TForm1.ReadOnly1Click(Sender: TObject);
begin
  ReadOnly1.Checked := not ReadOnly1.Checked;
  GetEditor.ReadOnly := ReadOnly1.Checked;
end;

procedure TForm1.AdjustCharacterMargin;
var
  TM: TTextMetric;
  F, R: Integer;
begin
  with GetEditor do
  begin
    Canvas.Font.Assign(Font);
    GetTextMetrics(Canvas.Handle, TM);
    F := TM.tmAveCharWidth;
    Canvas.Font.Assign(ReserveWordFont);
    GetTextMetrics(Canvas.Handle, TM);
    R := TM.tmAveCharWidth;
    if F < R then
      CharacterMargin := R - F
    else
      CharacterMargin := 0;
  end;
end;

procedure TForm1.Font1Click(Sender: TObject);
begin
  FontDialog1.Font.Assign(GetEditor.Font);
  if FontDialog1.Execute then
  begin
    GetEditor.Font.Assign(FontDialog1.Font);
    AdjustCharacterMargin;
  end;
end;

procedure TForm1.ReserveFont1Click(Sender: TObject);
begin
  FontDialog1.Font.Assign(GetEditor.ReserveWordFont);
  if FontDialog1.Execute then
  begin
    GetEditor.ReserveWordFont.Assign(FontDialog1.Font);
    AdjustCharacterMargin;
  end;
end;


procedure TForm1.UnderLine1Click(Sender: TObject);
begin
  UnderLine1.Checked := not UnderLine1.Checked;
  GetEditor.UnderLine := UnderLine1.Checked;
end;

procedure TForm1.TabIndent1Click(Sender: TObject);
begin
  TabIndent1.Checked := not TabIndent1.Checked;
  GetEditor.TabIndent := TabIndent1.Checked;
end;

procedure TForm1.Undo1Click(Sender: TObject);
begin
  GetEditor.Undo;
end;

procedure TForm1.Redo1Click(Sender: TObject);
begin
  GetEditor.Redo;
end;

procedure TForm1.Save1Click(Sender: TObject);
var
  FileName: String;
begin
  if PageControl1.ActivePage.PageIndex > 2 then
  begin
    FileName := FileList[PageControl1.ActivePage.PageIndex];
    GetEditor.Lines.SaveToFile(FileName);
    GetEditor.Modified := False;
    PageControl1Change(Self);
  end;
end;

procedure TForm1.SaveAs1Click(Sender: TObject);
begin
  if PageControl1.ActivePage.PageIndex > 2 then
  begin
    if SaveDialog1.Execute then
    begin
      GetEditor.Lines.SaveToFile(SaveDialog1.FileName);
      FileList[PageControl1.ActivePage.PageIndex] := SaveDialog1.FileName;
      PageControl1.ActivePage.Caption :=
        ChangeFileExt(ExtractFileName(SaveDialog1.FileName), '');
      GetEditor.Modified := False;
      PageControl1Change(Self);
    end;
  end;
end;

procedure TForm1.RetMark1Click(Sender: TObject);
begin
  RetMark1.Checked := not RetMark1.Checked;
  GetEditor.RetMark := RetMark1.Checked;
end;

procedure TForm1.EOF1Click(Sender: TObject);
begin
  Eof1.Checked := not Eof1.Checked;
  GetEditor.EofMark := Eof1.Checked;
end;

procedure TForm1.DelimDBCS1Click(Sender: TObject);
begin
  DelimDBCS1.Checked := not DelimDBCS1.Checked;
  GetEditor.DelimDBCS := DelimDBCS1.Checked;
end;

procedure TForm1.DefaultDrawing1Click(Sender: TObject);
begin
  DefaultDrawing1.Checked := not DefaultDrawing1.Checked;
  GetEditor.DefaultDrawing := DefaultDrawing1.Checked;
end;

procedure TForm1.DrawAllWords1Click(Sender: TObject);
begin
  DrawAllWords1.Checked := not DrawAllWords1.Checked;
  GetEditor.DrawAllWords := DrawAllWords1.Checked;
end;

procedure TForm1.ReserveBkColor1Click(Sender: TObject);
begin
  ColorDialog1.Color := GetEditor.ReserveBkColor;
  if ColorDialog1.Execute then
    GetEditor.ReserveBkColor := ColorDialog1.Color;
end;

// åüçı

function TForm1.Search: Boolean;
var
  Info: TSearchInfo;
begin
  Result := False;
  with GetEditor do
  begin
    Info.Start := SelStart;
    Info.Length := SelLength;
    // cf HTSearch.pas
    if SearchText(PChar(Lines.Text),
                  Info, FSearchValue, FSearchOptions) then
    begin
      SelStart := Info.Start;
      SelLength := Info.Length;
      if Row - TopRow > RowCount * 4 div 5 then
        TopRow := Row - RowCount div 3
      else
        if Row - TopRow < RowCount div 5 then
          TopRow := Row - RowCount div 3;
      Result := True;
    end
    else
      ShowMessage('åüçıï∂éöóÒ  '' ' + FSearchValue + ' ''' + #13#10 +
                  'ÇÕå©Ç¬Ç©ÇËÇ‹ÇπÇÒÇ≈ÇµÇΩÅB');
  end;
end;

procedure TForm1.mnuFindClick(Sender: TObject);
begin
  if TFormSearch.Execute(FSearchValue, FSearchOptions) then
    Search;
end;

procedure TForm1.mnuFindForwardClick(Sender: TObject);
begin
  if FSearchValue <> '' then
  begin
    Include(FSearchOptions, sfrDown);
    Search;
  end;
end;

procedure TForm1.mnuFindBackwardClick(Sender: TObject);
begin
  if FSearchValue <> '' then
  begin
    Exclude(FSearchOptions, sfrDown);
    Search;
  end;
end;

procedure TForm1.Replace1Click(Sender: TObject);
var
  Editor: TEditor;
  CaretPoint: TPoint;
  MsgForm: TForm;
  Choice: Word;

  procedure ReplaceEditor;
  begin
    Editor.SelText := FReplaceValue;
  end;

begin
  if TFormReplace.Execute(
       FSearchValue, FReplaceValue, FSearchOptions) then
  begin
    Editor := GetEditor;
    while Search do
    begin
      if sfrReplaceConfirm in FSearchOptions then
      begin
        // get screen position
        GetCaretPos(CaretPoint);
        CaretPoint := Editor.ClientToScreen(CaretPoint);
        // TMessageForm.Create fc Dialogs.pas
        MsgForm :=
          CreateMessageDialog(
            '' + ' ' + FSearchValue + ' ' + '' + '  Ç' + #13#10+
            '' + ' ' + FReplaceValue + ' ' + '' + '  Ç… íuÇ´ä∑Ç¶Ç‹Ç∑Ç©ÅH',
            mtConfirmation, [mbYes, mbNo, mbCancel, mbAll]);
        try
          // positioning
          MsgForm.Top := CaretPoint.Y - MsgForm.Height - Editor.RowHeight;
          if MsgForm.Top < 0 then
            MsgForm.Top := CaretPoint.Y + Editor.RowHeight;
          MsgForm.Left := CaretPoint.X + 2;
          if (MsgForm.Left + MsgForm.Width) > Screen.Width then
            MsgForm.Left := Screen.Width - MsgForm.Width - 4;
          // display
          Choice := MsgForm.ShowModal;
        finally
          MsgForm.Free;
        end;

        case Choice of
          mrYes: ReplaceEditor;
          mrNo: ;
          mrCancel: Exit;
          mrAll:
            begin
              ReplaceEditor;
              Include(FSearchOptions, sfrReplaceAll);
              Exclude(FSearchOptions, sfrReplaceConfirm);
            end;
        end;
      end
      else
        ReplaceEditor;
      if not(sfrReplaceAll in FSearchOptions) then
        Exit;
    end;
  end;
end;

procedure TForm1.Editor2BeforeDrawWord(Sender: TObject; WordStr: string;
  Reserved: Boolean);
begin
  if (Pos('http', WordStr) > 0) then
  begin
    Editor2.Canvas.Font.Style :=
      Editor2.Canvas.Font.Style + [fsUnderline];
    Editor2.Canvas.Font.Color := clAqua;
  end
  else
    if (WordStr = 'ï`âÊÇµÇΩÉÇÉmÇ÷ÇÃè„èëÇ´Ç∆Ç»ÇËÇ‹Ç∑ÅB') or
       (WordStr = 'ÉÜÅ[ÉUÅ[Ç™ëçÇƒÇï`âÊÇµÇ»ÇØÇÍÇŒÇ»ÇËÇ‹ÇπÇÒÅB') then
    begin
      Editor2.Canvas.Font.Style :=
        Editor2.Canvas.Font.Style + [fsUnderline, fsBold];
      Editor2.Canvas.Font.Color := clLime;
    end
    else
      if WordStr = 'ëæéöÇ‚éŒëÃÇéwíËÇ∑ÇÈÇ±Ç∆Ç™â¬î\Ç…Ç»ÇËÇ‹ÇµÇΩÅI' then
      begin
        Editor2.Canvas.Font.Style :=
          Editor2.Canvas.Font.Style + [fsBold, fsItalic, fsUnderline];
        Editor2.Canvas.Font.Color := clRed;
      end
      else
        if (WordStr = 'ÇRÇ…Ç∑ÇÈ') or
           (WordStr = 'ÇOÇ…ñﬂÇ∑') then
        begin
          Editor2.Canvas.Font.Style :=
            Editor2.Canvas.Font.Style + [fsBold, fsUnderline];
          Editor2.Canvas.Font.Color := clAqua;
        end;
end;

procedure TForm1.Editor2DrawLine(Sender: TObject; LineStr: string; X, Y,
  Index: Integer; ARect: TRect);
begin
  if Pos('copyright(c)1998-1999 ñ{ìcèüïF <katsuhiko.honda@nifty.ne.jp>', LineStr) > 0 then
  begin
    Editor2.Canvas.Brush.Color := Editor2.Color;
    Editor2.Canvas.Font.Assign(Editor2.Font);
    Editor2.Canvas.Font.Color := clGray;
    Editor2.DrawTextRect(ARect, X, Y, LineStr, ETO_CLIPPED or ETO_OPAQUE);
  end
  else
    if LineStr = 'Canvas.Font.Name := ''ÇlÇr ÇoÉSÉVÉbÉN'' Ç±ÇÒÇ»ä¥Ç∂Ç≈ï`âÊÇ≥ÇÍÇƒÇµÇ‹Ç¢Ç‹Ç∑ÅB' then
    begin
      Editor2.Canvas.Font.Name := 'ÇlÇr ÇoÉSÉVÉbÉN';
      Editor2.Canvas.Font.Size := 12;
      Editor2.DrawTextRect(ARect, X, Y, LineStr, ETO_CLIPPED or ETO_OPAQUE);
    end;
end;

procedure TForm1.Editor2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  S: String;
  aPos: TPoint;
begin
  aPos.X := X; aPos.Y := Y;
  S := Editor2.WordFromPos(aPos);
  if (Pos('http', S) > 0) or
     (S = 'ÇRÇ…Ç∑ÇÈ') or
     (S = 'ÇOÇ…ñﬂÇ∑') then
    Editor2.Cursor := crDefault
  else
    Editor2.Cursor := crIBeam;

  if S = 'ÇRÇ…Ç∑ÇÈ' then
    S := 'CharacterMargin ÇÇRÇ…ê›íËÇµÇ‹Ç∑'
  else
    if S = 'ÇOÇ…ñﬂÇ∑' then
      S := 'CharacterMargin ÇÇOÇ…ñﬂÇµÇ‹Ç∑ÅB'
    else
      S := '';
  if S <> '' then
    ShowHintWindow(S)
  else
    HideHintWindow;
end;

procedure TForm1.Editor2Click(Sender: TObject);
var
  S: String;
  APos: TPoint;
begin
  GetCursorPos(APos);
  S := Editor2.WordFromPos(Editor2.ScreenToClient(APos));
  if S = 'ÇRÇ…Ç∑ÇÈ' then
    Editor2.CharacterMargin := 3
  else
    if S = 'ÇOÇ…ñﬂÇ∑' then
      Editor2.CharacterMargin := 0;
end;

procedure TForm1.ShowHintWindow(S: String);
var
  CursorHeight: Integer;
  Rect: TRect;
  Pos: TPoint;
begin
  if not FHintWindow.HandleAllocated then
    FHintWindow.HandleNeeded;
  CursorHeight := GetSystemMetrics(SM_CYCAPTION);
  GetCursorPos(Pos);
  Rect := Bounds(0, 0, Screen.Width, 0);
  DrawText(FHintWindow.Canvas.Handle, PChar(S),
    -1, Rect, DT_CALCRECT or DT_LEFT or DT_WORDBREAK or DT_NOPREFIX);
  OffsetRect(Rect, Pos.X, Pos.Y + CursorHeight);
  Inc(Rect.Right, 6);
  Inc(Rect.Bottom, 2);
  FHintWindow.ActivateHint(Rect, S);
end;

procedure TForm1.HideHintWindow;
begin
  if FHintWindow.HandleAllocated then
    FHintWindow.ReleaseHandle;
end;

procedure TForm1.WordWrap1Click(Sender: TObject);
begin
  WordWrap1.Checked := not WordWrap1.Checked;
  GetEditor.WordWrap := WordWrap1.Checked;
end;

procedure TForm1.WrapByte1Click(Sender: TObject);
var
  S: String;
begin
  S := IntToStr(GetEditor.WrapByte);
  if InputQuery('TEditor.WrapByte', 'ê‹ÇËï‘Ç∑ï∂éöêîÇì¸óÕ', S) then
    GetEditor.WrapByte := StrToIntDef(S, 0);
end;

procedure TForm1.RowColClick(Sender: TObject);
begin
  if Sender = RowCol1 then
  begin
    RowCol1.Checked := True;
    LinesChar1.Checked := False;
  end
  else
  begin
    RowCol1.Checked := False;
    LinesChar1.Checked := True;
  end;
  CaretMoved(Self);
end;

end.

