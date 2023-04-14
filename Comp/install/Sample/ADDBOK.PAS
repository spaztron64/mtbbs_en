unit Addbok;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Addbkvw, Addrbook;

type
  TForm1 = class(TForm)
    AddressBookViewer1: TAddressBookViewer;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

end.
