unit progressfrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls;

type TCancelProc=procedure of object;

type
  TProgress = class(TForm)
    Image1: TImage;
    Image2: TImage;
    ProgressBar: TProgressBar;
    GroupBox2: TGroupBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    CancelBtn: TButton;
    PaintBox1: TPaintBox;
    TransferLbl: TLabel;
    TimeLbl: TLabel;
    TimeLeftLbl: TLabel;
    TotTransferLbl: TLabel;
    TotTimeLbl: TLabel;
    TransferRateLbl: TLabel;
    BMP: TImage;
    procedure FormShow(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
        ThisTransferred,ThisTime,TotalTransferred,TotalTime: integer;
        Todo,anicycle: integer;
        send:Boolean;
  public
        CancelProc: TCancelProc;
        procedure StartNewTransfer(filename: string; filesize: integer;Sending: Boolean);
        procedure Progress(bytes: integer; time: integer);
        procedure EndTransfer;
  end;

var
  Progress: TProgress;

implementation

{$R *.DFM}

procedure TProgress.StartNewTransfer(filename: string; filesize: integer;Sending: Boolean);
begin
        todo:=filesize;
        ProgressBar.Position:=0;
        send:=Sending;
        filename:=ExtractFileName(filename);
        if Sending then Caption:=Format('Sending %s (%d bytes)',[filename,filesize])
        else Caption:=Format('Receiving %s (%d bytes)',[filename,filesize]);
end;

procedure TProgress.Progress(bytes: integer; time: integer);
var
        rate,pct: integer;
        h,m,s,tl: integer;
begin
        ThisTransferred:=bytes;
        ThisTime:=time;
        if todo<>0 then pct:=(bytes*100)div todo
        else pct:=0;
        ProgressBar.Position:=pct;
        TransferLbl.Caption:=IntToStr(bytes);
        time:=time div 1000;
        h:=time div 3600;
        m:=(time mod 3600) div 60;
        s:=(time mod 3600) mod 60;
        TimeLbl.Caption:=Format('%2d:%2.2d:%2.2d',[h,m,s]);
        tl:=(todo*time)div bytes-time;
        h:=tl div 3600;
        m:=(tl mod 3600) div 60;
        s:=(tl mod 3600) mod 60;
        TimeLeftLbl.Caption:=Format('%2d:%2.2d:%2.2d',[h,m,s]);
        TotTransferLbl.Caption:=IntToStr(TotalTransferred+ThisTransferred);
        tl:=(TotalTime+ThisTime)div 1000;
        h:=tl div 3600;
        m:=(tl mod 3600) div 60;
        s:=(tl mod 3600) mod 60;
        TotTimeLbl.Caption:=Format('%2d:%2.2d:%2.2d',[h,m,s]);
        if ((TotalTime+ThisTime)div 1000)<>0 then rate:=(TotalTransferred+ThisTransferred)*10 div 1024 div ((TotalTime+ThisTime)div 1000)
        else rate:=0;
        if rate<10 then
        begin
                if rate=0 then TransferRateLbl.Caption:='???'
                else
                begin
                        rate:=(TotalTransferred+ThisTransferred)div ((TotalTime+ThisTime)div 1000);
                        TransferRateLbl.Caption:=Format('%d bytes/sec',[rate]);
                end;
        end
        else
        begin
                h:=rate div 10;
                m:=rate mod 10;
                TransferRateLbl.Caption:=Format('%d.%d K/sec',[h,m]);
        end;
        if send then
        begin
                Inc(anicycle);
                if anicycle=20 then anicycle:=0;
        end
        else
        begin
                Dec(anicycle);
                if anicycle<0 then anicycle:=20;
        end;
        PaintBox1.Invalidate;
end;

procedure TProgress.EndTransfer;
begin
        ProgressBar.Position:=0;
        Inc(TotalTransferred,ThisTransferred);
        Inc(TotalTime,ThisTime);
end;

procedure TProgress.FormShow(Sender: TObject);
begin
        TotalTransferred:=0;
        TotalTime:=0;
        Top:=(Owner as TForm).Top+((Owner as TForm).ClientHeight-Height) div 2;
        Left:=(Owner as TForm).Left+((Owner as TForm).ClientWidth-Width) div 2;
end;

procedure TProgress.PaintBox1Paint(Sender: TObject);
var
        y: integer;
begin
        if (anicycle mod 2)=0 then y:=PaintBox1.Height div 4
        else
        begin
                if (anicycle-1) mod 4=0 then y:=0
                else y:=2*PaintBox1.Height div 4;
        end;
        PaintBox1.Canvas.Draw(anicycle*(PaintBox1.Width div 20),y,BMP.Picture.Graphic);
end;

procedure TProgress.CancelBtnClick(Sender: TObject);
begin
        CancelProc;
end;

end.
