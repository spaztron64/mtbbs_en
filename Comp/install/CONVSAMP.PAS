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
    { Private �錾 }
  public
    { Public �錾 }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
var
  sample1,sample2,sz:AnsiString;
begin
  //�d�t�b�R�[�h
  sample1:='���������ɥ���ץ� EUC by rayesper. ���Σ�';
  //�i�h�r�R�[�h
  sample2:='$B4A;z%3!<%I%5%s%W%k(B JIS by rayesper. $B$=$N#2(B';

  label2.caption:='�ϊ��O�F'+sample1;
  label3.caption:='�ϊ���F'+AutoSjisConv1.ToSjis(sample1);
  label5.caption:='�ϊ��O�F'+sample2;
  label6.caption:='�ϊ���F'+AutoSjisConv1.ToSjis(sample2);

end;


end.
