unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StrSortGrid, StdCtrls, Buttons;

type
  TForm1 = class(TForm)
    StrSortGrid1: TStrSortGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
StrSortGrid1.Rows[0].CommaText:='No,列１,列２,列３,列４';
StrSortGrid1.Rows[1].CommaText:='1,CDE,JRDK,12234,その他';
StrSortGrid1.Rows[2].CommaText:='2,ACC,ARRK,38234,よろしく';
StrSortGrid1.Rows[3].CommaText:='3,ZBC,ARRS,30923,ＳＴＲ';
StrSortGrid1.Rows[4].CommaText:='4,KRBC,KRBA,30223,りんご';
StrSortGrid1.Rows[5].CommaText:='5,ARCC,RRCRFDK,30423,みかん';
StrSortGrid1.Rows[6].CommaText:='6,RRBC,BRRFDK,30953,かんと';
StrSortGrid1.Rows[7].CommaText:='7,ARBC,FRRFDK,10923,ｻｰﾌ';
{
StrSortGrid1.RowCount:=3;
StrSortGrid1.Rows[0].CommaText:='1,2,3,4,5,6';
StrSortGrid1.Rows[1].CommaText:='2,3,4,2,6,5';
StrSortGrid1.Rows[2].CommaText:='3,1,5,6,2,3';
 }
end;

end.
