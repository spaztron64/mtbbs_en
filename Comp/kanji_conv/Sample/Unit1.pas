unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, PzConv;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Button1: TButton;
    Label1: TLabel;
    Button2: TButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Edit4: TEdit;
    Button3: TButton;
    Edit5: TEdit;
    Label2: TLabel;
    Edit6: TEdit;
    Edit7: TEdit;
    Bevel3: TBevel;
    Button4: TButton;
    Edit8: TEdit;
    Edit9: TEdit;
    Label3: TLabel;
    Bevel4: TBevel;
    Edit10: TEdit;
    Button5: TButton;
    Button6: TButton;
    Edit11: TEdit;
    Label4: TLabel;
    Edit12: TEdit;
    Button7: TButton;
    PzConv1: TPzConv;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  Form1: TForm1;

implementation


{$R *.DFM}



procedure TForm1.Button1Click(Sender: TObject);
begin
  PzConv1.JisKanaConvType := ktZenWithDaku;
  Edit2.Text := PzConv1.SjisToJis(Edit1.Text);
  Edit3.Text := PzConv1.JisToSjis(Edit2.Text);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  PzConv1.JisKanaConvType := ktZenSepaDaku;
  Edit2.Text := PzConv1.SjisToJis(Edit1.Text);
  Edit3.Text := PzConv1.JisToSjis(Edit2.Text);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Edit5.Text := PzConv1.WebEncode(Edit4.Text);
  Edit6.Text := PzConv1.WebDecode(Edit5.Text);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  //通常JISコードにしてBase64コード化します
  Edit8.Text := PzConv1.B64Encode(PzConv1.SjisToJis(Edit7.Text));
  Edit9.Text := PzConv1.JisToSjis(PzConv1.B64Decode(Edit8.Text));
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  PzConv1.JisKanaConvType := ktZenWithDaku;
  Edit11.Text := PzConv1.SjisToEuc(Edit10.Text);
  Edit12.Text := PzConv1.EucToSjis(Edit11.Text);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  PzConv1.JisKanaConvType := ktZenSepaDaku;
  Edit11.Text := PzConv1.SjisToEuc(Edit10.Text);
  Edit12.Text := PzConv1.EucToSjis(Edit11.Text);
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  Edit8.Text := PzConv1.MIMEHeaderEncode(Edit7.Text);
  Edit9.Text := PzConv1.MIMEHeaderDecode(Edit8.Text);
end;

end.
