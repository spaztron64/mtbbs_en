unit Memo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TMemoForm = class(TForm)
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private �錾 }
  public
    { Public �錾 }
  end;

var
  MemoForm: TMemoForm;

implementation

{$R *.DFM}

procedure TMemoForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  Action := caFree;

end;

end.
