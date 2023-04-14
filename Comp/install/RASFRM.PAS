unit rasfrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Rascomp32;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    btnDial: TButton;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure RASConnect(Sender: TObject);
    procedure btnDialClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  RAS : TRAS;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  RAS:=TRAS.Create(self);
  case RAS.fRASAPI of
    0 : begin
      RAS.GetPhoneBookEntries;
      Listbox1.Items.Assign (RAS.PhoneBookEntries);
    end;
    1 : ShowMessage('RASAPI32.DLL Ç™å©Ç¬Ç©ÇËÇ‹ÇπÇÒ');
    2 : ShowMessage('RASAPI32.DLL Ç™ê≥èÌÇ≈Ç†ÇËÇ‹ÇπÇÒ');
  end;
end;

procedure TForm1.RASConnect(Sender: TObject);
begin
  ShowMessage ('Connected!');
end;

procedure TForm1.btnDialClick(Sender: TObject);
begin

  RAS.EntryName := Listbox1.Items[Listbox1.ItemIndex];

  RAS.UserName:='myo';
  RAS.PassWord:='49w6nr4w';

  RAS.Connect;

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Ras.Disconnect;
end;

end.
