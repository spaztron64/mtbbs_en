// �v���p�e�B�G�f�B�^�̕s�v�ȕ��͉��̂P�s���폜���Ă��������B
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
  
  { TEditor �ɂ��� TStringsPropertyEditor ��K�p����ꍇ }
  RegisterPropertyEditor(
    TypeInfo(TStrings), TEditor, 'Lines', TStringsPropertyEditor);
  RegisterPropertyEditor(
    TypeInfo(TStrings), TEditor, 'ReserveWordList', TStringsPropertyEditor);

  { ���Ă� TStrings �ɑ΂��� TStringsPropertyEditor ��L���ɂ���ꍇ }
  {RegisterPropertyEditor(
    TypeInfo(TStrings), nil, '', TStringsPropertyEditor);}

  {$ENDIF}
end;

end.