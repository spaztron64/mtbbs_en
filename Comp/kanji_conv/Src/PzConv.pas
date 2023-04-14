unit PzConv;
{
--------------------------------------------------------------------------------
★★★★★★★★★★★★★★★★★★★★★★★★ 文字コード変換総合コンポーネント

  プロパティ
  JisByteCodeType: TJisByteCodeType
    JISコードの際の1バイトコードの設定
      btAscii        'ESC(B'が付加される *default
      btRoman        'ESC(J'が付加される

  JisKanaConvType: TJisKanaConvType
    JIS,EUC変換の際半角カナの扱い方法
      ktNone         何もしない
      ktZenWithDaku  濁点を含む2バイトコードに変換する 例：ﾋﾞﾋﾞﾃﾞ > ビビデ *default
      ktZenSepaDaku  濁点を含まず別々にして変換する    例：ﾊﾞﾋﾞﾃﾞ > ハﾞヒﾞテﾞ

  特殊な場合を除いてデフォルト値で問題ありません


★★★★★★★★★★★★★★★ JIS、SJisコード変換プログラム
  JIS ＜－＞ ShiftJIS相互変換プログラム
  ISO-2022-JP文字セットを作成することができますのでメールなどの送受信ができます

  １．文字列をJISからShiftJISにコード変換する
    function JisToSJis(const s: AnsiString): AnsiString
                            sにJIS文字列を指定するとShiftJISコードが戻り値に入る

  ２．文字列をShiftJISからJISにコード変換する
    function SJisToJis(const s: AnsiString): AnsiString
                            sにShiftJIS文字列を指定するとJISコードが戻り値に入る
                            プロパティJisKanaConvTypeの設定によって半角カタカナの
                            扱いが変化します


★★★★★★★★★★★★★★★ EUC、SJisコード変換プログラム
  EUC ＜－＞ ShiftJIS相互変換プログラム
  EUC文字セットを作成することができますのでUNIX系ソフトとのやりとりができます
  ※2bytes固定EUCはサポートしていませんが、現在ほとんど使われていません

  １．文字列をEUCからShiftJISにコード変換する
    function EucToSJis(const s: AnsiString): AnsiString
                            sにEUC文字列を指定するとShiftJISコードが戻り値に入る

  ２．文字列をShiftJISからEUCにコード変換する
    function SJisToEuc(const s: AnsiString): AnsiString
                            sにShiftJIS文字列を指定するとEUCコードが戻り値に入る
                            プロパティJisKanaConvTypeの設定によって半角カタカナの
                            扱いが変化します


★★★★★★★★★★★★★★★ Base64コード変換プログラム
  MIMEで使用しているコード変換です

  １．Base64コードにエンコードする
    function B64Encode(const s: AnsiString): AnsiString;

  ２．Base64コードをデコードする
    function B64Decode(const s: AnsiString): AnsiString;

  ３．MIMEヘッダ部分をエンコードする (JIS＋Base64）
    function MIMEHeaderEncode(const s: AnsiString): AnsiString;
                            sに文字列を指定すると'=?ISO-2022-JP?B?'の付いた
                            MIMEヘッダにエンコードした符号化文字列が戻り値に入る

  ４．MIMEヘッダ部分をデコードする (JIS＋Base64）
    function MIMEHeaderDecode(const s: AnsiString): AnsiString;
                            sにMIMEヘッダ文字列を指定するとShiftJISコードが戻り値に入る


★★★★★★★★★★★★★★★ Ｗｅｂコード変換プログラム
  Ｗｅｂサーバ等で使用しているコード変換です
  ８ビット目がたっている文字を%nnの形でエンコード／デコードします

  １．Ｗｅｂコードにエンコードする
    function WebEncode(const s: AnsiString): AnsiString;
                            文字列内で８ビット目が”１”の文字を１６進表記”%nn”
                            に変換する (' '->'+')

  ２．Ｗｅｂコードをデコードする
    function WebDecode(const s: AnsiString): AnsiString;
                            文字列内のエンコードされた%nn部分を通常の文字に変換
                            する ('+'->' ')

--------------------------------------------------------------------------------
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

const
  CODE_TABLE :
    array[0..62,0..1] of byte =
    ( (129, 66),(129,117),(129,118),(129, 65),(129, 69),(131,146),(131, 64),
      (131, 66),(131, 68),(131, 70),(131, 72),(131,131),(131,133),(131,135),
      (131, 98),(129, 91),(131, 65),(131, 67),(131, 69),(131, 71),(131, 73),
      (131, 74),(131, 76),(131, 78),(131, 80),(131, 82),(131, 84),(131, 86),
      (131, 88),(131, 90),(131, 92),(131, 94),(131, 96),(131, 99),(131,101),
      (131,103),(131,105),(131,106),(131,107),(131,108),(131,109),(131,110),
      (131,113),(131,116),(131,119),(131,122),(131,125),(131,126),(131,128),
      (131,129),(131,130),(131,132),(131,134),(131,136),(131,137),(131,138),
      (131,139),(131,140),(131,141),(131,143),(131,147),(129, 74),(129, 75) );

type
  // Byte Code Type     >>>>>>>>>     Ascii='(B'  Roman='(J'
  TJisByteCodeType = (btAscii, btRoman);
  // if conv to JIS
  TJisKanaConvType = (ktNone, ktZenWithDaku, ktZenSepaDaku);
  // Class
  TPzConv = class(TComponent)
  private
    { Private 宣言 }
    FJisByteCodeType: TJisByteCodeType;
    FJisKanaConvType: TJisKanaConvType;
  protected
    { Protected 宣言 }
    // For JIS convert
    function Jis_SJis(c0,c1: AnsiChar): AnsiString;
    function SJis_Jis(c0,c1: AnsiChar): AnsiString;
    function IsDakuten(c: AnsiChar): boolean;
    function IsHanDakuten(c: AnsiChar): boolean;
    function IsHanKana(c: AnsiChar): boolean;
    // For WEB convert
    function Hex2Int(c: AnsiChar): Byte;
    function Int2Hex(c: AnsiChar): AnsiString;
    // For Base64 convert
    function B642Int(c: AnsiChar): Byte;
    function Int2B64(c: Byte): AnsiChar;
    // For Hankaku Operation
    function HanToZen (const s: AnsiString): AnsiString;
    function HanToZen2(const s: AnsiString): AnsiString;
    // For EUC convert
    function IsEuc(c: AnsiChar): boolean;
  public
    { Public 宣言 }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //Functions
    function JisToSJis(const s: AnsiString): AnsiString;
    function SJisToJis(const s: AnsiString): AnsiString;
    function EucToSJis(const s: AnsiString): AnsiString;
    function SJisToEuc(const s: AnsiString): AnsiString;
    function B64Encode(const s: AnsiString): AnsiString;
    function B64Decode(const s: AnsiString): AnsiString;
    function MIMEHeaderEncode(const s: AnsiString): AnsiString;
    function MIMEHeaderDecode(const s: AnsiString): AnsiString;
    function WebEncode(const s: AnsiString): AnsiString;
    function WebDecode(const s: AnsiString): AnsiString;
  published
    { Published 宣言 }
    property JisByteCodeType: TJisByteCodeType read FJisByteCodeType write FJisByteCodeType;
    property JisKanaConvType: TJisKanaConvType read FJisKanaConvType write FJisKanaConvType;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TPzConv]);
end;

constructor TPzConv.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
    FJisByteCodeType := btAscii;
    FJisKanaConvType := ktZenWithDaku;
end;

destructor TPzConv.Destroy;
begin
  inherited Destroy;
end;

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////privateな関数

///// JISコードをSJISコードに変換 - 1文字
function TPzConv.Jis_SJis(c0,c1: AnsiChar): AnsiString;
var
  b0,b1,off: byte;
begin
  b0 := Byte(c0);
  b1 := Byte(c1);
  Result := '';
  if (b0 < 33) or (b0 > 126) then exit;
  off := 126;
  if b0 mod 2 = 1 then
    if b1 < 96 then off := 31 else off := 32;
  b1 := b1 + off;
  if b0 < 95 then off := 112 else off := 176;
  b0 := ((b0 + 1) shr 1) + off;
  Result := AnsiChar(b0) + AnsiChar(b1);
end;

///// SJISコードをJISコードに変換 - 1文字
function TPzConv.SJis_Jis(c0,c1: AnsiChar): AnsiString;
var
  b0,b1,adj,off: byte;
begin
  b0 := Byte(c0);
  b1 := Byte(c1);
  Result := '';
  if b0 <= 159 then off := 112 else off := 176;
  if b1 < 159  then adj := 1   else adj := 0;
  b0 := ((b0 - off) shl 1) - adj;
  off := 126;
  if b1 < 127 then off := 31 else if b1 < 159 then off := 32;
  b1 := b1 - off;
  Result := AnsiChar(b0) + AnsiChar(b1);
end;

///// 濁点か
function TPzConv.IsDakuten (c: AnsiChar): boolean;
var i: byte;
begin
  i := Byte(c);
  if  ((i >= 182) and (i <= 196))
   or ((i >= 202) and (i <= 206))
   or  (i = 179)  then result := true
  else result := false;
end;

///// 半濁点か
function TPzConv.IsHanDakuten (c: AnsiChar): boolean;
var i: byte;
begin
  i := Byte(c);
  if (i >= 202) and (i <= 206) then result := true
  else result := false;
end;

///// 半角カタカナか
function TPzConv.IsHanKana (c: AnsiChar): boolean;
var i: byte;
begin
  i := Byte(c);
  if (i >= 161) and (i <= 223) then result := true
  else result := false;
end;

///// Hex(Char)をinteger(Byte)に変換
function TPzConv.Hex2Int(c: AnsiChar): Byte;
begin
  result := 0;
  if ('0' <= c) and (c <= '9') then
    result := Byte(c) - Byte('0')
  else if ('a' <= c) and (c <= 'f') then
    result := Byte(c) - Byte('a') + 10
  else if ('A' <= c) and (c <= 'F') then
    result := Byte(c) - Byte('A') + 10;
end;

///// integer(Char)をHex(Char X 2)に変換
function TPzConv.Int2Hex(c: AnsiChar): AnsiString;
var
  i0,i1: Integer;
  b: Byte;
begin
  result := '';
  b := Byte(c);
  i0 := b shr 4;
  i1 := b and $0F;
  //
  if (0 <= i0) and (i0 <= 9) then
    result := AnsiChar(i0 + Integer('0'))
  else if (10 <= i0) and (i0 <= 15) then
    result := AnsiChar((i0 - 10) + Integer('a'));
  //
  if (0 <= i1) and (i1 <= 9) then
    result := result + AnsiChar(i1 + Integer('0'))
  else if (10 <= i1) and (i1 <= 15) then
    result := result + AnsiChar((i1 - 10) + Integer('a'));
end;

///// Base64コードを整数に変換
function TPzConv.B642Int(c: AnsiChar): Byte;
begin
  case c of
    'A'..'Z': result := Byte(c) - 65;
    'a'..'z': result := Byte(c) - 71;
    '0'..'9': result := Byte(c) + 4;
    '+':      result := 62;
    '/':      result := 63;
    else      result := 64;
  end;
end;

///// 整数をBase64コードに変換
function TPzConv.Int2B64(c: Byte): AnsiChar;
begin
  case c of
    0..25:  result := Char(c + 65);
    26..51: result := Char(c + 71);
    52..61: result := Char(c - 4);
    62:     result := '+';
    63:     result := '/'
    else    result := '=';
  end;
end;

///// Ascii 8bit 半角カタカナをSJIS 全角コードに変換 濁点判定あり
function TPzConv.HanToZen (const s: AnsiString): AnsiString;
var
  c0,c1: AnsiChar;
  b0,b1: Byte;
  fDaku,fHandaku,fDbyte: boolean;
  i,len: integer;
begin
  Result := '';
  len := length(s);
  i := 1;
  While (i <= len) do
  begin
    //第１、２バイトをテーブルから
    c0 := s[i];
    c1 := s[i+1];
    //１バイト目が半角仮名でないならスキップ
    if (not IsHanKana(c0)) or (not (ByteType(s,i) = mbSingleByte)) then
    begin
      result := result + c0;
      inc(i);
      continue;
    end;
    //FLAG 初期化
    fDaku := false; fHandaku := false; fDbyte := false;
    //濁点チェック
    if Byte(c1) = 222 then
    begin
      if IsDakuten(c0) then fDaku := true;
    //半濁点チェック
    end else if Byte(c1) = 223 then
      if IsHanDakuten(c0) then fHandaku := true;
    //テーブル変換
    b0 := CODE_TABLE[byte(c0)-161,0];
    b1 := CODE_TABLE[byte(c0)-161,1];
    //濁点の場合
    if fDaku then
    begin
      if ((b1 >= 74) and (b1 <= 103)) or ((b1 >= 110) and (b1 <=122)) then
      begin
        b1 := b1 + 1;
        fDbyte := true;
      end else if (b0 = 131) and (b1 = 69) then
      begin
        b1 := 148;
        fDbyte := true;
      end;
    end else if (fHandaku) and (b1 >= 110) and (b1 <= 122) then
    begin
      b1 := b1 + 2;
      fDbyte := true;
    end;
    result := result + AnsiChar(b0);
    result := result + AnsiChar(b1);
    inc(i);
    if fDbyte then inc(i);
  end;{while}
end;

///// Ascii 8bit 半角カタカナをSJIS 全角コードに変換 濁点判定なし
function TPzConv.HanToZen2 (const s: AnsiString): AnsiString;
var
  c0   : AnsiChar;
  b0,b1: Byte;
  i,len: integer;
begin
  Result := '';
  len := length(s);
  i := 1;
  While (i <= len) do
  begin
    //第１、２バイトをテーブルから
    c0 := s[i];
    //１バイト目が半角仮名でないならスキップ
    if (not IsHanKana(c0)) or (not (ByteType(s,i) = mbSingleByte)) then
    begin
      result := result + c0;
      inc(i);
      continue;
    end;
    //テーブル変換
    if Byte(c0) = 222 then {濁点}
    begin
      b0 := $81;  //129
      b1 := $4a;  // 74
    end else
    if Byte(c0) = 223 then {半濁点}
    begin
      b0 := $81;  //129
      b1 := $4b;  // 75
    end else
    begin
      b0 := CODE_TABLE[byte(c0)-161,0];
      b1 := CODE_TABLE[byte(c0)-161,1];
    end;
    //
    result := result + AnsiChar(b0);
    result := result + AnsiChar(b1);
    inc(i);
  end;{while}
end;

///// EUC(Code set 1)に該当するか
function TPzConv.IsEuc (c: AnsiChar): boolean;
var i: byte;
begin
  i := Byte(c);
  if (i >= 161) and (i <= 254) then result := true
  else result := false;
end;


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////publicな関数

///// JISコードをSJISコードに変換
function TPzConv.JisToSJis(const s: AnsiString): AnsiString;
var
i: integer;
flg: boolean;
begin
  flg := false;
  Result := '';
  i := 1;
  while (i <= Length(s)) do
  begin
    if Copy(s,i,3) = #27 + '$B' then
    begin
      flg := true;
      i   := i + 3;
      continue;     //空の文字列がありえるので
    end;
    if (Copy(s,i,3) = #27 + '(B') or (Copy(s,i,3) = #27 + '(J') then
    begin
      flg := false;
      i   := i + 3;
      continue;     //空の文字列がありえるので
    end;

    if flg then
    begin
      if Length(s) > i then Result := Result + Jis_Sjis(s[i],s[i+1]);
      inc(i);
    end else
      Result := Result + s[i];

    inc(i);
  end;
end;

///// SJISコードをJISコードに変換
function TPzConv.SJisToJis(const s: AnsiString): AnsiString;
var
i: integer;
flg: boolean;
st: AnsiString;
begin
  //Init
  flg := false;
  Result := '';
  //Kana
  if FJisKanaConvType = ktZenWithDaku then
    st := HanToZen(s)
  else if FJisKanaConvType = ktZenSepaDaku then
    st := HanToZen2(s)
  else
    st := s;
  //Loop
  i := 1;
  while (i <= Length(st)) do
  begin
    if ByteType(st,i) = mbLeadByte then
    begin
      if not flg then //New Kanji
      begin
        flg    := true;
        Result := Result + #27 + '$B'; //Kanji IN 追加
      end;
      Result := Result + Sjis_Jis(st[i],st[i+1]);
      inc(i);
    end else
    begin
      if flg then
      begin
        flg    := false;
        if FJisByteCodeType = btAscii then
          Result := Result + #27 + '(B'  //Ascii IN 追加
        else
          Result := Result + #27 + '(J'; //Roman IN 追加
      end;
      Result := Result + st[i];
    end;
    inc(i);
  end;
  if flg then
  begin
    if FJisByteCodeType = btAscii then
      Result := Result + #27 + '(B'  //Ascii IN 追加
    else
      Result := Result + #27 + '(J'; //Roman IN 追加
  end;
end;

///// EUCコードをSJISコードに変換
function TPzConv.EucToSjis(const s: AnsiString): AnsiString;
var
i: integer;
b0,b1: byte;
begin
  //Init
  Result := '';
  //Loop
  i := 1;
  while (i <= Length(s)) do
  begin
    if IsEuc(s[i]) then
    begin
      b0 := byte(s[i]);
      b1 := byte(s[i+1]);
      b0 := b0 - 128;
      b1 := b1 - 128;
      Result := Result + Jis_SJis(AnsiChar(b0),AnsiChar(b1));
      inc(i);
    end else if (byte(s[i]) = 142) and (IsHanKana(s[i+1])) then
    begin //Kana (Code Set 0) $8E + Code
      Result := Result + s[i+1];
      inc(i);
    end else
    begin
      Result := Result + s[i];
    end;
    inc(i);
  end;
end;

///// SJISコードをEUCコードに変換
function TPzConv.SJisToEuc(const s: AnsiString): AnsiString;
var
i: integer;
st,temp: AnsiString;
b0,b1: byte;
begin
  //Init
  Result := '';
  //Kana
  if FJisKanaConvType = ktZenWithDaku then
    st := HanToZen(s)
  else if FJisKanaConvType = ktZenSepaDaku then
    st := HanToZen2(s)
  else
    st := s;
  //Loop
  i := 1;
  while (i <= Length(st)) do
  begin
    if ByteType(st,i) = mbLeadByte then
    begin
      temp := Sjis_Jis(st[i],st[i+1]);
      b0 := byte(temp[1]);
      b1 := byte(temp[2]);
      b0 := b0 + 128;
      b1 := b1 + 128;
      Result := Result + AnsiChar(b0) + AnsiChar(b1);
      inc(i);
    end else if IsHanKana(st[i]) then
    begin
      Result := Result + #142 + st[i];
    end else
    begin
      Result := Result + st[i];
    end;
    inc(i);
  end;
end;

///// 文字列内で８ビット目が”１”の文字を１６進表記”%nn”に変換
function TPzConv.WebEncode(const s: AnsiString): AnsiString;
var
  i: Integer;
  b: Byte;
begin
  Result := '';
  i := 1;
  while (i <= length(s)) do
  begin
    b := Byte(s[i]);
    if (b shr 7) = 1 then
      Result := Result + '%' + Int2Hex(s[i])
    else if s[i] = ' ' then
      Result := Result + '+'   // Modified 98.3.25 (' '->'+')
    else
      Result := Result + s[i];
    inc(i);
  end;
end;

///// 文字列内の%nn部分を通常の文字に変換
function TPzConv.WebDecode(const s: AnsiString): AnsiString;
var
  i:     Integer;
  h,l :  Byte;
  sbyte: AnsiChar;
begin
  Result := '';
  i := 1;
  while (i <= length(s)) do
  begin
    sbyte := s[i];
    inc(i);
    if sbyte = '%' then
    begin
      sbyte := s[i];
      inc(i);
      h := Hex2Int(sbyte);
      sbyte := s[i];
      inc(i);
      l := Hex2Int(sbyte);
      sbyte := Char(h*16 + l);
    end;
    if sbyte = '+' then sbyte := ' ';  { '+' ==>> ' ' }
    Result := Result + sbyte;
  end;
end;

///// Base64encode
function TPzConv.B64Encode(const s: AnsiString): AnsiString;
var
  i,pos4,len: Integer;
  b: Byte;
begin
  Result := '';
  len := length(s);
  if len = 0 then exit;
  i    := 1;
  pos4 := 1;
  while not(i > len) do
  begin
    case pos4 of
      1: begin                   // [876543]21 - 87654321 - 87654321
        b := Byte(s[i]) shr 2;
        result := result + Int2B64(b);
        if i = len then result := result + Int2B64((Byte(s[i]) and $03) shl 4) + '==';
      end;
      2: begin                   // 876543[21 - 8765]4321 - 87654321
        b := Byte(s[i-1]) and $03;
        b := (b shl 4) or (Byte(s[i]) shr 4);
        result := result + Int2B64(b);
        if i = len then result := result + Int2B64((Byte(s[i]) and $0f) shl 2) + '=';
      end;
      3: begin                   // 87654321 - 8765[4321 - 87][654321]
        b := Byte(s[i-1]) and $0f;
        b := (b shl 2) or (Byte(s[i]) shr 6);
        result := result + Int2B64(b);
        // pos4 = 4
        b := Byte(s[i])and $3f;
        result := result + Int2B64(b);
      end;
    end;
    inc(i);
    inc(pos4);
    if pos4 = 4 then pos4 := 1;
  end;
end;

///// Base64decode
function TPzConv.B64Decode(const s: AnsiString): AnsiString;
var
  i,pos4,len: Integer;
  c: array[1..3] of AnsiChar;
  b: Byte;
begin
  Result := '';
  len := length(s);
  if len = 0 then exit;
  i    := 1;
  pos4 := 1;
  while not(i > len) do
  begin
    b := B642Int(s[i]);
    case pos4 of
      1: begin
        c[1] := Char( b shl 2 );
      end;
      2: begin
        c[1] := Char( Byte(c[1]) or ((b and $30) shr 4) );
        c[2] := Char( (b and $0f) shl 4 );
      end;
      3: begin
        c[2] := Char( Byte(c[2]) or ((b and $3c) shr 2) );
        c[3] := Char( (b and $03) shl 6 );
      end;
      4: begin
        c[3] := Char( Byte(c[3]) or (b and $3f) );
      end;
    end;
    if pos4 = 4 then
    begin
      result := result + c[1];
      if Byte(c[2]) <> 0 then result := result + c[2];
      if Byte(c[3]) <> 0 then result := result + c[3];
    end;
    inc(i);
    inc(pos4);
    if pos4 = 5 then pos4 := 1;
  end;
end;

///// MIME Header Encode
function TPzConv.MIMEHeaderEncode(const s: AnsiString): AnsiString;
var
  s2: AnsiString;
  i:  Integer;
  flg:Boolean;
begin
  //Init
  Result := '';
  flg := True;
  if s = '' then Exit;
  //2bytes文字があるかチェック
  for i := 1 to Length(s) do
    if ByteType(s,i) = mbLeadByte then flg := False;
  if flg then
  begin
    Result := s;
    Exit;
  end;
  //Kana Convert
  if      FJisKanaConvType = ktZenWithDaku then s2 := HanToZen(s)
  else if FJisKanaConvType = ktZenSepaDaku then s2 := HanToZen2(s)
  else                                          s2 := s;
  //Loop 2バイトコード部をJISコードに変換
  s2 := SJisToJis(s2);
  //Base64
  s2 := B64Encode(s2);
  //Header Code
  Result := '=?ISO-2022-JP?B?' + s2 + '?=';
end;

///// MIME Header Decode
function TPzConv.MIMEHeaderDecode(const s: AnsiString): AnsiString;
var
i:   integer;
flg: boolean;
s2:  AnsiString;
begin
  flg    := false;
  Result := '';
  if s = '' then Exit;
  s2     := '';
  i      := 1;
  while (i <= Length(s)) do
  begin
    if UpperCase(Copy(s,i,16)) = '=?ISO-2022-JP?B?' then
    begin
      flg := true;
      i   := i + 16;
      continue;
    end;
    if Copy(s,i,2) = '?=' then
    begin
      flg := false;
      i   := i + 2;
    end;

    if flg then
    begin
      if Length(s) >= i then s2 := s2 + s[i];
    end
    else begin
      if s2 <> '' then
      begin
        s2 := B64Decode(s2);
        Result := Result + JisToSjis(s2);
        s2 := '';
      end;
      if Length(s) >= i then Result := Result + s[i];
    end;
    inc(i);
  end;
end;



end.
