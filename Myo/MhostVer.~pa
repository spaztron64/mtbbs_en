unit MhostVer;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TMyoHostVersion = class(TForm)
    Panel1: TPanel;
    ProductName: TLabel;
    Version: TLabel;
    OKButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  MyoHostVersion: TMyoHostVersion;

implementation

{$R *.DFM}

uses define;

procedure TMyoHostVersion.FormCreate(Sender: TObject);
begin

  Version.Caption := 'Version '+MTBBSVERSION;

end;

end.

