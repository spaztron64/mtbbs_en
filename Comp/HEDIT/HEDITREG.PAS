// プロパティエディタの不要な方は下の１行を削除してください。
{$DEFINE TEDITOR_PROPERTY_EDITOR}

unit HEditReg;

interface

uses
  Classes, DsgnIntf;

procedure Register;

implementation

uses
  HEditor {$IFDEF TEDITOR_PROPERTY_EDITOR} , HStrProp {$ENDIF} ;

procedure Register;
begin
  RegisterComponents('Samples', [TEditor]);

  {$IFDEF TEDITOR_PROPERTY_EDITOR}
  
  { TEditor にだけ TStringsPropertyEditor を適用する場合 }
  RegisterPropertyEditor(
    TypeInfo(TStrings), TEditor, 'Lines', TStringsPropertyEditor);
  RegisterPropertyEditor(
    TypeInfo(TStrings), TEditor, 'ReserveWordList', TStringsPropertyEditor);

  { 総ての TStrings に対して TStringsPropertyEditor を有効にする場合 }
  {RegisterPropertyEditor(
    TypeInfo(TStrings), nil, '', TStringsPropertyEditor);}

  {$ENDIF}
end;

end.
