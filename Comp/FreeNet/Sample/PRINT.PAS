unit Print;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls;

const
        WM_STARTPRINTING        =       WM_USER+1;

type
  TPrintProgress = class(TForm)
    BkPanel: TPanel;
    Label1: TLabel;
    StatusBar: TPanel;
    CancelBtn: TButton;
    procedure FormShow(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
        procedure WMStartPrinting(var Msg: TMsg);message WM_STARTPRINTING;
  public
        Lines: TStrings;
        PrinterFont: TFont;
        Cancelled: Boolean;
  end;

implementation

{$R *.DFM}

uses Printers;

procedure TPrintProgress.FormShow(Sender: TObject);
begin
        PostMessage(Handle,WM_STARTPRINTING,0,0);
end;

procedure TPrintProgress.WMStartPrinting(var Msg: TMsg);
var
        f: TextFile;
        i,todo: LongInt;
begin
        AssignPrn(f);
        Rewrite(f);
        Printer.Canvas.Font:=PrinterFont;
        todo:=Lines.Count-1;
        Cancelled:=False;
        i:=0;
        while (i<todo) and not Cancelled do
        begin
                WriteLn(f,Lines[i]);
                StatusBar.Width:=(i*BkPanel.Width) div todo;
                Inc(i);
                Application.ProcessMessages;
        end;
        CloseFile(f);
        ModalResult:=mrOk;
end;



procedure TPrintProgress.CancelBtnClick(Sender: TObject);
begin
        Cancelled:=True;
end;

end.
