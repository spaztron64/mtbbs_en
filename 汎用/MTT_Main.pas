unit MTT_Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CONSOLE, ExtCtrls, Buttons, StdCtrls, Menus;

type
  TCONSOLEWindow1 = class(TCONSOLEWindow)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Window1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    E1: TMenuItem;
    E2: TMenuItem;
    E3: TMenuItem;
    C1: TMenuItem;
    ComboBox1: TComboBox;
    Label2: TLabel;
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  CONSOLEWindow1: TCONSOLEWindow1;

implementation

{$R *.DFM}

end.
