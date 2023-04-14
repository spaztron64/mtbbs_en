unit LightStr;

{     　 TLightStringsクラス Ver β5   }

interface

   uses Windows,SysUtils,Classes,Grids;

type
  TSortCompfunc = function(S1,S2: string): Integer;

  TLightItems = array [0..MaxListSize]of string;
                //文字列の配列です。
  PLightItems =^TLightItems;

  TLightStrings = Class(TObject)
  private
    FList    : PLightItems;
    FCount   : Integer;
    FCapacity: Integer;
    function Get(Index: Integer):string;
    procedure Put(Index: Integer; Item:string);
  protected
    function  GetTextStr:string;virtual;
    procedure SetTextStr(const Text:string);virtual;
    procedure SetCount(NewCount:Integer);virtual;
    procedure SetCapacity(NewCapacity: Integer);virtual;
    procedure SetCommaText(Value:string);virtual;
    function  GetCommaText:string;virtual;
    procedure Error;virtual;
  public
    destructor Destroy; override;

    //ここから下、ほとんどTStringsと同じ様に使えます。
    procedure LoadFromFile(const Filename:string);virtual;
    procedure SaveToFile(const FileName:string);virtual;
    procedure SaveToStream(Stream:TStream);virtual;
    procedure LoadFromStream(Stream:TStream);virtual;
    function Add(Item:string): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    procedure Insert(Index: Integer; Item: string);
    procedure AddStrings(Source:TStrings);
    procedure Assign(Source:TStrings);
    //ここまではTStringsと同じです。

    procedure CopyTo(Dest:TStrings);
    //他のTStringsにコピーします。

    function IndexOf(Item: string): Integer;virtual;
    //高速化のため大文字小文字を区別する仕様になってます。

    property CommaText:string read GetCommaText write SetCommaText;
    //TStringsのCommaTextとは違い、長さ無制限です。(Delphi2.0のTStrings.commmaTextは4KBまで)
    //但しフィールドに二重引用符'"'や改行コードが入ると異常動作します。

    procedure Sort(Comp:TSortCompFunc);

    function Find(FindText:string;var L,C:Integer):Boolean;

    property Text    :string read GetTextStr write SetTextStr;
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count   : Integer read FCount write SetCount ;
    property Items[Index: Integer]: string read Get write Put; default;
  end;

implementation

const
  CharPerLine=28; { テキストファイルの
                   平均の一行の文字数(仮定) 少し小さめに }
  GrowSize   =32;  //キャパを一度に広げる量

function TextFileSize(var F: TextFile):integer;
begin
  with TTextRec(F) do begin
    Result:=FileSeek(Handle,0,2);
    FileSeek(Handle,0,0);
  end;
end;

function TLightStrings.Add(Item:string): Integer;
begin
  Result := FCount;
  if Result = FCapacity then     //キャパシティに余裕がなければ
       SetCapacity(FCapacity+GrowSize);//広げる
  FList^[Result] := Item;
  Inc(FCount);
end;

procedure TLightStrings.AddStrings(Source:TStrings);
var C,I:Integer;
begin
  C:=Source.Count;
  SetCapacity(Count+C);
  for I:=0 to Source.Count-1 do Add(Source[i]);
end;

procedure TLightStrings.Assign(Source:TStrings);
begin
  Clear;
  AddStrings(Source);
end;

procedure TLightStrings.Clear;
begin
  if FCapacity>0 then
  begin
    Finalize(FList^[0], FCount);//長い文字列の破棄
    SetCount(0);
    SetCapacity(0);
  end;
end;

procedure TLightStrings.CopyTo(Dest:TStrings);
var I:Integer;
begin
  Dest.Clear;
  if (Dest is TStringList) or (Dest is TStringGridStrings)
    then
      begin
        for I:=0 to Count-1 do Dest.Add('');
        for I:=0 to Count-1 do Dest[i]:=Get(i);
      end
    else for I:=0 to Count-1 do Dest.Add(Get(I));
end;

procedure TLightStrings.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Error;
  FList^[Index]:='';
  Dec(FCount);
  if Index < FCount then
    System.Move(Pointer(FList^[Index + 1]),
      Pointer(FList^[Index]),(FCount - Index) * SizeOf(string));
  Pointer(FList^[FCount]):=nil;
end;

destructor TLightStrings.Destroy;
begin
  Clear;
  Inherited;
end;

procedure TLightStrings.Error;
begin
  raise Exception.Create('インデックスがリストの範囲を超えています');
end;

procedure TLightStrings.Exchange(Index1, Index2: Integer);
var Tmp:Pointer;
begin
   if (Index1 < 0) or (Index1 >= FCount) or
    (Index2 < 0) or (Index2 >= FCount) then Error;
   if Index1=Index2 then Exit;
   Tmp:=Pointer(FList^[Index1]);
   Pointer(FList^[Index1]):=Pointer(FList^[Index2]);
   Pointer(FList^[Index2]):=Tmp;
end;

function TLightStrings.Find(FindText:string ;var L,C:Integer):Boolean;
var
    Cl,Cu   : Char;
    I       : Integer;
    S       : string;
begin
  Result:=True;
  Cl:=AnsiLowerCase(FindText[1])[1];
  Cu:=AnsiUpperCase(FindText[1])[1];
  while L < Count do begin
    S:=Get(L);
    I:=Length(S)-Length(FindText)+1;
    while C <= I do begin
      if (S[C]=Cl) or (S[C]=Cu) then
        if StrLIComp(PChar(S)+C-1,PChar(FindText)
             ,Length(FindText)) = 0 then Exit;
      inc(C);
    end;
    Inc(L);C:=1;
  end;
  Result:=False;
end;

function TLightStrings.Get(Index:Integer):string;
begin
  if (Index < 0) or (Index >= FCount) then Error;
  Result := FList^[Index];
end;

const
    Blank  = #32;
    Comma  = #44;
    DQ     = #34;

function TLightStrings.GetCommaText:string;
const
    Buff   = 4*1024;
    GrowSize = 1024;
var Quote  : Boolean;
    I,J    : Integer;
    S      : string;
    P,Org  : PChar;
  Procedure Grow;
  var OffSet:Integer;
  begin
    OffSet:=P-Org;
    SetLength(Result,Length(Result)+GrowSize);
    Org:=PChar(Result);
    P:=Org+Offset;
  end;
begin
  SetLength(Result,Buff);
  Org:=PChar(Result);
  P:=Org;
  for I:=0 to Count-1 do
    begin
      S:=Get(i);
      if Length(result)-(P-Org) < Length(S)+3 then Grow;
      Quote:=False;
      for J:=1 to Length(S) do
        if S[j] in [Comma,Blank] then
          begin
            Quote:=True;
            P^:=DQ;
            Inc(P);
            Break;
          end;
        Move(PChar(S)^,P^,Length(S));
        Inc(P,Length(S));
        if Quote then begin
                        P^:=DQ;
                        Inc(P);
                      end;
        P^:=Comma;
        Inc(P);
    end;
  SetLength(Result,P-Org-1);
end;


function TLightStrings.GetTextStr:string;
var
  I, L, Size: Integer;
  P: PChar;
  S: string;
begin
  Size := 0;
  for I := 0 to FCount - 1 do Inc(Size, Length(Get(I)) + 2);
  SetLength(Result,Size);
  P := PChar(Result);
  for I := 0 to FCount - 1 do
  begin
    S := Get(I);
    L := Length(S);
    if L <> 0 then
    begin
      System.Move(PChar(S)^, P^, L);
      Inc(P, L);
    end;
    P^ := #13;
    Inc(P);
    P^ := #10;
    Inc(P);
  end;
end;

function TLightStrings.IndexOf(Item:string): Integer;
begin
  for Result := 0 to FCount - 1 do
    if Get(Result)=Item then Exit;
  Result := -1;
end;

procedure TLightStrings.Insert(Index: Integer; Item:string);
begin
  if Index > Fcount then Error;
  if FCount = FCapacity then SetCapacity(FCapacity+GrowSize);
  if Index < FCount then
    System.Move(Pointer(FList^[Index]),Pointer(FList^[Index + 1]),
      (FCount - Index) * SizeOf(string));
  Pointer(FList^[Index]):=nil;
  FList^[Index]:=Item;
  Inc(FCount);
end;

procedure TLightStrings.LoadFromFile(const Filename:string);
const BS=1024*8;
var  F : Textfile;
   Buff:array[1..BS]of Byte;
   S   : string;
begin
  Clear;
  AssignFile(F,Filename);
  System.SetTextBuf(F,Buff,BS);
  Reset(F);
  try
    SetCapacity(TextFileSize(F) div CharPerLine);
    while not EOF(F) do begin
      Readln(F,S);
      Add(S);
    end;
  finally
    CloseFile(F);
  end;
  SetCapacity(FCount);
end;

procedure TLightStrings.LoadFromStream(Stream:TStream);
var S   : string;
    Size: Integer;
begin
  Clear;
  Size:=Stream.Size-Stream.Position;
  if Size=0 then Exit;
  SetLength(S,Size);
  Stream.Read(PChar(S)^,Size);
  SetTextStr(S);
end;

procedure TLightStrings.Put(Index:Integer;Item:string);
begin
    if (Index < 0) or (Index >= FCount) then Error;
  FList^[Index] := Item;
end;

procedure TLightStrings.SaveToFile(Const FileName:string);
const BS=1024*8;
var  F : Textfile;
   Buff:array[1..BS]of Byte;
   I   :Integer;
begin
  AssignFile(F,Filename);
  System.SetTextBuf(F,Buff,BS);
  ReWrite(F);
  try
    for I:=0 to count-1 do
      Writeln(F,Get(I));
  finally
    CloseFile(F);
  end;
end;

procedure TLightStrings.SaveToStream(Stream:TStream);
var S:string;
begin
  S:=GetTextStr;
  Stream.Write(PChar(S)^,Length(S));
end;

procedure TLightStrings.SetCapacity(NewCapacity: Integer);
begin
  if NewCapacity > MaxListSize then Error;
  if NewCapacity = FCapacity then Exit;
  if NewCapacity < FCount then Error;
    ReallocMem(FList, NewCapacity * SizeOf(string));
  if NewCapacity > FCapacity then
    Initialize(FList^[FCount],NewCapacity-FCapacity);
      //長い文字列の初期化
  FCapacity:=NewCapacity;
end;

procedure TLightStrings.SetCount(NewCount:Integer);
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then Error;
  if NewCount > FCapacity then SetCapacity(NewCount);
  if NewCount < FCount then finalize(FList^[NewCount],FCount-NewCount);
  FCount := NewCount;
end;

procedure TLightStrings.SetTextStr(const Text:string);
var
  P, Start: PChar;
  S: string;
begin
  Clear;
  P := PChar(Text);
  if P = nil then Exit;
  SetCapacity(Length(Text)div CharPerLine);
  repeat
    Start := P;
    while not (P^ in [#0, #10, #13]) do Inc(P);
    SetString(S, Start, P - Start);
    Add(S);
    if P^ = #13 then Inc(P);
    if P^ = #10 then Inc(P);
  until P^ = #0;
  SetCapacity(FCount);
end;



procedure TLightStrings.SetCommaText(Value:string);
var Quote  : Boolean;
    S      : string;
    P,Start: PChar;
begin
  Clear;
  Start:=PChar(Value);
  while Length(Value)>(Start-PChar(Value)) do begin
    Quote:=Start^=DQ;
    if Quote then Inc(Start);
    P:=Start;
    while (P^<>#13) and (P^<>#0) do
    begin
      if (P^=Comma)and (not Quote) then Break;
      if P^=DQ then Break;
      Inc(P);
    end;
    SetString(S,Start,P-Start);
    Start:=P+1+Byte(Quote);
    Add(S);
  end;
end;


procedure TLightStrings.Sort(Comp:TSortCompFunc);
  procedure QuickSort(First,Last: Integer);
  var
    I, J: Integer;
    P: string;
  begin
    repeat
      I := First;
      J := Last;
      P := FList^[(First + Last) shr 1]; // Div 2 より高速
      repeat
        while Comp(FList^[I], P) < 0 do Inc(I);
        while Comp(FList^[J], P) > 0 do Dec(J);
        if I <= J then
        begin
          Exchange(I, J);
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if First < J then QuickSort(First, J);
      First := I;
    until I >= Last;
  end;
begin
  if FCount>1 then QuickSort(0,FCount-1);
end;


end.

