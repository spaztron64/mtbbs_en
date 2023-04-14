unit Ftpinput;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TInputForm = class(TForm)
    Prompt: TLabel;
    Input: TEdit;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InputForm: TInputForm;

implementation

{$R *.DFM}

end.
