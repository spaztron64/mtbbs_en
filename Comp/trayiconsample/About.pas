unit About;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TFormAbout = class(TForm)
    BevelTrayIconAbout: TBevel;
    ImageTrayIcon: TImage;
    LabelTrayIconTitle1: TLabel;
    LabelTrayIconTitle2: TLabel;
    LabelCopyright: TLabel;
    ButtonClose: TButton;

    procedure ButtonCloseClick(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  FormAbout: TFormAbout;

implementation

{$R *.DFM}

procedure TFormAbout.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

end.
