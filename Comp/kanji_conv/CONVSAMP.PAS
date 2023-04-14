unit convsamp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  sjisconv, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    AutoSjisConv1: TAutoSjisConv;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private éŒ¾ }
  public
    { Public éŒ¾ }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
var
  sample1,sample2,sz:AnsiString;
begin
  //‚d‚t‚bƒR[ƒh
  sample1:='´Á»ú¥³¡¼¥É¥µ¥ó¥×¥ë EUC by rayesper. ¤½¤Î£±';
  //‚i‚h‚rƒR[ƒh
  sample2:='$B4A;z%3!<%I%5%s%W%k(B JIS by rayesper. $B$=$N#2(B';

  label2.caption:='•ÏŠ·‘OF'+sample1;
  label3.caption:='•ÏŠ·ŒãF'+AutoSjisConv1.ToSjis(sample1);
  label5.caption:='•ÏŠ·‘OF'+sample2;
  label6.caption:='•ÏŠ·ŒãF'+AutoSjisConv1.ToSjis(sample2);

end;


end.
