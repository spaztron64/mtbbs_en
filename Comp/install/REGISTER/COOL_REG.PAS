(*=============================================================================\
  CoolMenu98 Version 2.02 for Borland Delphi 3.x

  TMainCool    Component
  TPopupCool   Component
  TCoolMenuBar Component

  TMenuItemProperty  PropertyEditor  for TMainCool, TPopupCool
  TPopupCoolProperty PropertyEditor  for TPopupCool
  TMainCoolProperty  PropertyEditor  for TMainCool
  TCoolMenuBarEditor ComponentEditor for TCoolMenuBar
  TMenuImage         ComponentEditor for TMainCool, TPopupCool

  NIFTY-Serve ID: GCH02346
  E-Mail : k_nakano@mxb.meshnet.or.jp
                        CopyRight(C) 1996-1998 Nakanon
\=============================================================================*)
unit Cool_Reg;

interface

procedure Register;

implementation

uses
  Classes, DsgnIntf, Menus, CoolMenu, CoolMBar, EMenuImg, CoolEdit;

procedure Register;
begin
  RegisterComponents('Nakanon', [TMainCool, TPopupCool]);
  RegisterComponents('Nakanon', [TCoolMenuBar]);

  RegisterComponentEditor(TCoolMenuBar, TCoolMenuBarEditor);
  RegisterComponentEditor(TMainCool, TMenuImageEditor);
  RegisterComponentEditor(TPopupCool, TMenuImageEditor);

  RegisterPropertyEditor(TypeInfo(TMenuItem), TItemImage, '', TMenuItemProperty);
  RegisterPropertyEditor(TypeInfo(TMenu), TPopupCool, '', TPopupCoolProperty);
  RegisterPropertyEditor(TypeInfo(TMenu), TMainCool, '', TMainCoolProperty);
end;

end.
