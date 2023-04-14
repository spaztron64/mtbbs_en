unit Smdialog;
{
Copyright (©) 1997  Tony BenBrahim
This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Library General Public License as published by the Free
Software Foundation
This library is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Library General Public License for more details.
You should have received a copy of the GNU Library General Public License along
with this library; if not, write to the:

Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA  02111-1307, USA.
}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  ExtCtrls,StdCtrls,Forms, Dialogs,InetMail,dsgnintf,TabNotBk;

type SendMailDialogObjects=(StatusText,StatusBar,ByteCounter,CancelButton);
TSendMailDialogOptions=set of SendMailDialogObjects;

type TSendMailDialogPos=(ScreenCenter,Custom);

const
     WM_STARTUP=WM_USER+3;

type TUpdateCallbackProc=procedure of object;

type
  Tsmdlg = class(TForm)
    Status: TLabel;
    SendMail: SendMail;
    Timer: TTimer;
    counter: TLabel;
    cancel: TButton;
    Panel1: TPanel;
    PaintBox1: TPaintBox;
    procedure TimerTimer(Sender: TObject);
    procedure SendMailMailInfo(Sender: TObject; info: SendMailInfo;addinfo: String);
    procedure FormShow(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure cancelClick(Sender: TObject);
  private
        done,todo: Longint;
        procedure MailDone(Sender: TObject);
        procedure StartUp(var Msg: TMsg); message WM_STARTUP;
  public
        FDemo: Boolean;
        OnNextMessage: TNotifyEvent;
        UpdateInfoCallBack: TUpdateCallbackProc;
        tconnecting,tconnected,tsend,trecpt,tcancel,tattach: string;
        c1,c2: TColor;
        OnMailInfo: TSendMailInfoEvent;
        toi: word;
  end;

type SendMailDialog = class(TComponent)
        private
                FCaption:                               string;
                FKeepOpen:                              Boolean;
                FNextMsg:                               TNotifyEvent;
                FServer,FFName,FReply,FTName,FSubject:  string;
                FTAddress:                              string;
                FPort:                                  integer;
                d:                                      Tsmdlg;
                FText:                                  TStrings;
                MailStrings:            TStrings;
                AttachStrings:          TStrings;
                HeaderList:             TStrings;
                MI:                     SendMailInfo;
                bs:                                     TFormBorderStyle;
                ftop,fleft:                             integer;
                FFont:                                  TFont;
                FStatusColor:                           TColor;
                FStatusBk:                              TColor;
                FColor:                                 TColor;
                FOptions:                               TSendMailDialogOptions;
                FWidth,FHeight:                         integer;
                FInit:                                  Boolean;
                FPos:                                   TSendMailDialogPos;
                FLang:                                  TStrings;
                FVersion,DummyS:                        string;
                FDemo:                                  Boolean;
                OSMFD:                                  TSendMailEvent;
                OSMI:                                   TSendMailInfoEvent;
                FTimeOut:                               word;
                FListTo,FListcc,FListBcc:               TStrings;
                procedure SetFFont(f: TFont);
                procedure SetFLang(s: TStrings);
                procedure MeasureText(s: string;var x: integer;var y: integer);
                procedure SetMailStrings(s:TStrings);
                procedure SetListTo(s: TStrings);
                procedure SetListcc(s: TStrings);
                procedure SetListBcc(s: TStrings);
                procedure SetAttStrings(s:TStrings);
                procedure SetHeaderList(s:TStrings);
                procedure UpdateInfo;
        protected
                property Initialized: Boolean read FInit write FInit;
        public
                function Execute: Boolean;
                procedure Demo;
                constructor Create(owner: TComponent);override;
                destructor Destroy;override;
        published
                property Caption: string read FCaption write FCaption;
                property SMTP_Server: string read FServer write FServer;
                property FROM_Name: string read FFName write FFName;
                property FROM_Address: string read FReply write FReply;
                property TO_Name: string read FTName write FTName;
                property TO_Address: string read FTAddress write FTAddress;
                property Subject: string read FSubject write FSubject;
                property SMTP_Port: integer read FPort write FPort;
                property MailText: TStrings read MailStrings write SetMailStrings;
                property Attachments: TStrings read AttachStrings write SetAttStrings;
                property Headers: TStrings read HeaderList write SetHeaderList;
                property Status: SendMailInfo read MI write MI;
                property Border: TFormBorderStyle read bs write bs;
                property WindowTop: integer read ftop write ftop;
                property WindowLeft: integer read fleft write fleft;
                property Color: TColor read FColor write FColor;
                property Font: TFont read FFont write SetFFont;
                property StatusBarColor: TColor read FStatusColor write FStatusColor;
                property StatusBarBackground: TColor read FStatusBk write FStatusBk;
                property Options: TSendMailDialogOptions read FOptions write FOptions;
                property StatusBarHeight: integer read FHeight write FHeight;
                property StatusBarWidth: integer read FWidth write FWidth;
                property Position: TSendMailDialogPos read FPos write FPos;
                property LanguageStrings: TStrings read FLang write SetFLang;
                property Version: string read Fversion write DummyS;
                property OnSendMailInfo: TSendMailInfoEvent read OSMI write OSMI;
                property OnSendMailFeedData: TSendMailEvent read OSMFD write OSMFD;
                property TimeOut: word read FTimeOut write FTimeOut;
                property KeepConnectionOpen: Boolean read FKeepOpen write FKeepOpen;
                property OnSetupNextMessage: TNotifyEvent read FNextMsg write FNextMsg;
                property ListTo: TStrings read FListTo write SetListTo;
                property Listcc: TStrings read FListcc write SetListcc;
                property ListBcc: TStrings read FListBcc write SetListBcc;
end;

type SendMailDialogEditor=class(TComponentEditor)
        public
                procedure Edit;override;
                function GetVerb(Index: integer): string; override;
                function GetVerbCount: integer; override;
                procedure ExecuteVerb(Index: integer);override;
end;

type
  TSendMailDialogCE = class(TForm)
    TabbedNotebook1: TTabbedNotebook;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    poscenter: TRadioButton;
    poscustom: TRadioButton;
    Label3: TLabel;
    Label4: TLabel;
    etop: TEdit;
    eleft: TEdit;
    GroupBox3: TGroupBox;
    rbdialog: TRadioButton;
    rbsingle: TRadioButton;
    rbnone: TRadioButton;
    Color: TGroupBox;
    bkcol: TShape;
    txtcol: TShape;
    Label5: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    FontSample: TPaintBox;
    GroupBox4: TGroupBox;
    sttext: TCheckBox;
    stcounter: TCheckBox;
    stcancel: TCheckBox;
    stbar: TCheckBox;
    GroupBox5: TGroupBox;
    eheight: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    ewidth: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Button7: TButton;
    Button8: TButton;
    stcol: TShape;
    stbk: TShape;
    Label8: TLabel;
    Label9: TLabel;
    tconnecting: TEdit;
    tconnected: TEdit;
    Label10: TLabel;
    trecpt: TEdit;
    Label11: TLabel;
    tsend: TEdit;
    Label12: TLabel;
    tattach: TEdit;
    Label13: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    Label14: TLabel;
    Label15: TLabel;
    tcancel: TEdit;
    procedure Button6Click(Sender: TObject);
    procedure FontSamplePaint(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure stbarClick(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  public
        FDemo: Boolean;
  end;

var
        smdlg: Tsmdlg;

implementation

{$R SMDLGFRM.DFM}
{$R SMDGEDT.DFM}

{========================== Editor Code =============================}

function SendMailDialogEditor.GetVerb(Index: integer): string;
begin
        case Index of
        0: Result:='Edit Component';
        1: Result:='View Dialog Box';
        2: Result:='-';
        end;
end;

function SendMailDialogEditor.GetVerbCount: integer;
begin
        Result:=3;
end;

procedure SendMailDialogEditor.ExecuteVerb(Index: integer);
begin
        case Index of
        0: Edit;
        1: (Component as SendMailDialog).Demo;
        end;
end;

procedure SendMailDialogEditor.Edit;
var
       d:       TSendMailDialogCE;
       c:       SendMailDialog;
begin
        try
                d:=TSendMailDialogCE.Create(Application.MainForm);
                c:=Component as SendMailDialog;
                case c.Border of
                bsDialog: d.rbdialog.Checked:=True;
                bsNone: d.rbnone.Checked:=True;
                bsSingle: d.rbsingle.Checked:=True;
                end;
                d.eheight.Text:=IntToStr(c.StatusBarHeight);
                d.ewidth.Text:=IntToStr(c.StatusBarWidth);
                d.sttext.Checked:=StatusText in c.Options;
                d.stbar.Checked:=StatusBar in c.Options;
                d.stcancel.Checked:=CancelButton in c.Options;
                d.stcounter.Checked:=ByteCounter in c.Options;
                d.GroupBox5.Visible:=StatusBar in c.Options;
                d.etop.Text:=IntToStr(c.WindowTop);
                d.eleft.Text:=IntToStr(c.WindowLeft);
                d.bkcol.Brush.Color:=c.Color;
                d.txtcol.Brush.Color:=c.Font.Color;
                d.FontSample.Font.Assign(c.Font);
                d.stcol.Brush.Color:=c.StatusBarColor;
                d.stbk.Brush.Color:=c.StatusBarBackground;
                d.tconnecting.Text:=c.LanguageStrings[0];
                d.tconnected.Text:=c.LanguageStrings[1];
                d.trecpt.Text:=c.LanguageStrings[2];
                d.tsend.Text:=c.LanguageStrings[3];
                d.tattach.Text:=c.LanguageStrings[4];
                d.tcancel.Text:=c.LanguageStrings[5];
                case c.Position of
                ScreenCenter: d.poscenter.Checked:=True;
                Custom: d.poscustom.Checked:=True;
                end;
                if d.ShowModal=mrOk then
                begin
                        c.LanguageStrings.Clear;
                        c.LanguageStrings.Add(d.tconnecting.Text);
                        c.LanguageStrings.Add(d.tconnected.Text);
                        c.LanguageStrings.Add(d.trecpt.Text);
                        c.LanguageStrings.Add(d.tsend.Text);
                        c.LanguageStrings.Add(d.tattach.Text);
                        c.LanguageStrings.Add(d.tcancel.Text);
                        c.Options:=[];
                        if d.sttext.Checked then c.options:=c.options+[StatusText];
                        if d.stbar.Checked then c.options:=c.options+[StatusBar];
                        if d.stcounter.Checked then c.options:=c.options+[ByteCounter];
                        if d.stcancel.Checked then c.options:=c.options+[CancelButton];
                        if d.poscenter.Checked then c.Position:=screencenter;
                        if d.poscustom.Checked then c.Position:=custom;
                        c.Color:=d.bkcol.Brush.Color;
                        c.StatusBarColor:=d.stcol.Brush.Color;
                        c.StatusBarBackground:=d.stbk.Brush.Color;
                        c.Font.Assign(d.FontSample.Font);
                        if d.rbdialog.Checked then c.Border:=bsDialog;
                        if d.rbnone.Checked then c.Border:=bsNone;
                        if d.rbsingle.Checked then c.Border:=bsSingle;
                        try
                                c.WindowTop:=StrToInt(d.etop.Text);
                        except
                                ShowMessage('Invalid property value for Top');
                        end;
                        try
                                c.WindowLeft:=StrToInt(d.eleft.Text);
                        except
                                ShowMessage('Invalid property value for Left');
                        end;
                        try
                                c.StatusBarHeight:=StrToInt(d.eheight.Text);
                        except
                                ShowMessage('Invalid property value for StatusBarHeight');
                        end;
                        try
                                c.StatusBarWidth:=StrToInt(d.ewidth.Text);
                        except
                                ShowMessage('Invalid property value for StatusBarWidth');
                        end;
                        Designer.Modified;
                        if d.FDemo then
                        begin
                                d.Fdemo:=False;
                                c.Demo;
                        end;
                end;
        finally
                d.Destroy;
        end;
end;

{=========================== Component Code =========================}


constructor SendMailDialog.Create(owner: TComponent);
begin
        inherited Create(owner);
        MailStrings:=TStringList.Create;
        AttachStrings:=TStringList.Create;
        HeaderList:=TStringList.Create;
        FFont:=TFont.Create;
        FLang:=TStringList.Create;
        FVersion:='SendMailDialog version 1.2';
        FPort:=25;
        FListTo:=TStringList.Create;
        FListcc:=TStringList.Create;
        FListBcc:=TStringList.Create;
        if not Initialized then
        begin
                Color:=clSilver;
                StatusBarColor:=clBlue;
                StatusBarBackground:=clWhite;
                StatusBarHeight:=18;
                StatusBarWidth:=200;
                Font.Color:=clBlack;
                Options:=[StatusText,StatusBar,ByteCounter,CancelButton];
                Border:=bsDialog;
                FInit:=True;
                Position:=ScreenCenter;
                FLang.Clear;
        end;
        if FLang.Count=0 then FLang.Add('Connecting to');
        if FLang.Count=1 then FLang.Add('Connected to');
        if FLang.Count=2 then FLang.Add('Recipient #');
        if FLang.Count=3 then FLang.Add('Sending Mail');
        if FLang.Count=4 then FLang.Add('Attachment');
        if FLang.Count=5 then FLang.Add('Cancel');
        if FTimeout=0 then FTimeOut:=30000;
end;

destructor SendMailDialog.Destroy;
begin
        MailStrings.Free;
        AttachStrings.Free;
        HeaderList.Free;
        FFont.Free;
        FLang.Free;
        FListTo.Free;
        FListcc.Free;
        FListBcc.Free;
        inherited Destroy;
end;

procedure SendMailDialog.SetFFont(f: TFont);
begin
        FFont.Assign(f);
end;

procedure SendMailDialog.SetFLang(s: TStrings);
begin
        FLang.Assign(s);
end;

procedure SendMailDialog.MeasureText(s: string;var x: integer;var y: integer);
begin
        with d.Canvas do
        begin
                x:=TextWidth(s);
                y:=TextHeight(s);
        end;
end;

procedure SendMailDialog.UpdateInfo;
begin
        d.SendMail.FROM_Name:=FFName;
        d.SendMail.FROM_Address:=FReply;
        d.SendMail.TO_Name:=FTName;
        d.SendMail.TO_Address:=FTAddress;
        d.SendMail.Subject:=FSubject;
        d.SendMail.MailText:=MailStrings;
        d.SendMail.Attachments:=AttachStrings;
        d.SendMail.Headers:=HeaderList;
        d.SendMail.OnFeedData:=OSMFD;
        d.SendMail.KeepConnectionOpen:=FKeepOpen;
        d.SendMail.ListTo:=FListTo;
        d.SendMail.Listcc:=FListcc;
        d.SendMail.ListBcc:=FListBcc;
end;

function SendMailDialog.Execute: Boolean;
var
        i,x,y,maxx: integer;
begin
        try
                d:=Tsmdlg.Create(Application);
                d.FDemo:=FDemo;
                d.caption:=FCaption;
                if Position=ScreenCenter then d.Position:=poScreenCenter
                else
                begin
                        d.Position:=poDesigned;
                        d.Left:=WindowLeft;
                        d.Top:=WindowTop;
                end;
                d.BorderStyle:=Border;
                d.Color:=Color;
                d.Font.Assign(Font);
                d.Panel1.Width:=StatusBarWidth;
                d.Panel1.Height:=StatusBarHeight;
                d.ClientHeight:=3;
                d.ClientWidth:=3;
                if StatusText in Options then
                begin
                        maxx:=0;
                        for i:=0 to 3 do
                        begin
                                case i of
                                0: MeasureText(LanguageStrings[i]+' sam.neosoft.com.xxx',x,y);
                                1: MeasureText(LanguageStrings[i]+' 199.199.199.199 ',x,y);
                                2: MeasureText(LanguageStrings[i]+' ddd!ddgdgd!djhdhd!@dddhhd.cccc.com',x,y);
                                3: MeasureText(LanguageStrings[i]+' dddddddd.ddd',x,y);
                                end;
                                if x>maxx then maxx:=x;
                        end;
                        d.Status.Height:=y+6;
                        d.Status.Width:=maxx+6;
                        d.Status.Top:=d.ClientHeight;
                        d.Status.Left:=0;
                        d.ClientHeight:=d.ClientHeight+d.Status.Height;
                        d.ClientWidth:=d.Status.Width+6;
                        d.Status.Visible:=True;
                end
                else d.Status.Visible:=False;
                if StatusBar in Options then
                begin
                        d.Panel1.Top:=d.ClientHeight;
                        d.Panel1.Width:=StatusBarWidth;
                        d.Panel1.height:=StatusBarHeight;
                        d.ClientHeight:=d.ClientHeight+StatusBarHeight+3;
                        d.Panel1.Visible:=True;
                        if d.Panel1.Width+6>d.ClientWidth then d.ClientWidth:=d.Panel1.Width+6;
                end
                else d.Panel1.Visible:=False;
                if ByteCounter in Options then
                begin
                        d.Counter.Visible:=True;
                        MeasureText('99999999',x,y);
                        d.Counter.Left:=3;
                        d.Counter.Width:=x+6;
                        d.Counter.Height:=y;
                        d.Counter.Top:=d.ClientHeight+3;
                        if not (CancelButton in Options) then d.ClientHeight:=d.ClientHeight+y+6;
                end
                else d.Counter.Visible:=False;
                if CancelButton in Options then
                begin
                        d.Cancel.Visible:=True;
                        MeasureText(LanguageStrings[4],x,y);
                        d.Cancel.Caption:=LanguageStrings[5];
                        d.Cancel.Width:=x+16;
                        d.Cancel.Height:=y+10;
                        if not (ByteCounter in Options) then d.cancel.top:=d.ClientHeight+3
                        else d.cancel.top:=d.counter.top;
                        d.ClientHeight:=d.ClientHeight+d.Cancel.Height+3;
                end
                else d.Cancel.Visible:=False;
                if (ByteCounter in Options) and (CancelButton in Options) then
                begin
                        if d.Cancel.Width+d.Counter.Width+12>d.ClientWidth then
                                d.ClientWidth:=d.Cancel.Width+d.Counter.Width+12;
                        d.Cancel.Left:=d.ClientWidth-d.Cancel.Width-3;
                end;
                if (ByteCounter in Options) and not (CancelButton in Options) then
                begin
                        if d.Counter.Width+6>d.ClientWidth then
                                d.ClientWidth:=d.Counter.Width+6;
                        d.Counter.Left:=(d.ClientWidth-d.Counter.Width)div 2;
                end;
                if not (ByteCounter in Options) and (CancelButton in Options) then
                begin
                        if d.Cancel.Width+6>d.ClientWidth then
                                d.ClientWidth:=d.Cancel.Width+6;
                        d.Cancel.Left:=(d.ClientWidth-d.Cancel.Width) div 2;
                end;
                d.Status.Width:=d.ClientWidth;
                d.Panel1.Left:=(d.ClientWidth-d.Panel1.Width)div 2;
                d.ClientHeight:=d.ClientHeight+3;
                d.caption:=FCaption;
                d.OnNextMessage:=FNextMsg;
                d.SendMail.SMTP_Port:=FPort;
                d.SendMail.SMTP_Server:=FServer;
                UpdateInfo;
                d.UpdateInfoCallBack:=UpdateInfo;
                d.OnMailInfo:=OSMI;
                d.tconnecting:=LanguageStrings[0];
                d.tconnected:=LanguageStrings[1];
                d.trecpt:=LanguageStrings[2];
                d.tsend:=LanguageStrings[3];
                d.tattach:=LanguageStrings[4];
                d.c1:=StatusBarColor;
                d.Panel1.Color:=StatusBarBackground;
                d.c2:=StatusBarBackground;
                d.toi:=FTimeOut;
                d.ShowModal;
                if d.SendMail.Success then Result:=True
                else Result:=False;
        finally
                d.Free;
        end;
end;

procedure SendMailDialog.SetMailStrings(s: TStrings);
begin
        if Assigned(s) then MailStrings.Assign(s);
end;

procedure SendMailDialog.SetAttStrings(s: TStrings);
begin
        if Assigned(s) then AttachStrings.Assign(s);
end;

procedure SendMailDialog.SetHeaderList(s: TStrings);
begin
        if Assigned(s) then HeaderList.Assign(s);
end;

procedure SendMailDialog.SetListTo(s: TStrings);
begin
        if Assigned(s) then FListTo.Assign(s);
end;

procedure SendMailDialog.SetListcc(s: TStrings);
begin
        if Assigned(s) then FListcc.Assign(s);
end;

procedure SendMailDialog.SetListBcc(s: TStrings);
begin
        if Assigned(s) then FListBcc.Assign(s);
end;

procedure SendmailDialog.Demo;
begin
        FDemo:=True;
        Execute;
        FDemo:=False;
end;

{Sendmail dialog form code}
procedure Tsmdlg.TimerTimer(Sender: TObject);
begin
        SendMail.Action:=Cancel_SendMail;
        ModalResult:=1;
end;

procedure Tsmdlg.MailDone(Sender: TObject);
begin
        if SendMail.KeepConnectionOpen then
        begin
                if Assigned(OnNextMessage) then
                begin
                        Timer.Enabled:=False;
                        OnNextMessage(self);
                        UpdateInfoCallback;
                        done:=0;
                        PaintBox1.Invalidate;
                        Caption:='';
                        Timer.Enabled:=True;
                        SendMail.Action:=Send_Mail;
                        Exit;
                end;
        end;
        ModalResult:=1;
end;

procedure Tsmdlg.StartUp(var Msg: TMsg);
begin
        todo:=StrLen(SendMail.MailText.GetText);
        SendMail.Action:=Send_Mail;
end;

procedure Tsmdlg.SendMailMailInfo(Sender: TObject; info: SendMailInfo;
  addinfo: String);
begin
        Timer.Enabled:=False;
        Timer.Enabled:=True;
        if Assigned(OnMailInfo) then OnMailInfo(Sender,info,addinfo);
        case info of
        smServerConnected: Status.Caption:=tconnected+' '+addinfo;
        smRecipient: Status.Caption:=trecpt+' '+addinfo;
        smSendingMessage:
                begin
                        Status.Caption:=tsend;
                        done:=StrToInt(addinfo);
                        counter.caption:=addinfo;
                        PaintBox1Paint(self);
                end;
        smAttachmentName:
                begin
                        Status.Caption:=tattach+' '+ExtractFilename(addinfo);
                        todo:=1;
                        done:=0;
                        PaintBox1.Invalidate;
                end;
        smAttachmentSize:
                begin
                        todo:=StrToInt(addinfo);
                        PaintBox1Paint(self);
                end;
        smAttachmentBytes:
                begin
                        done:=StrToInt(addinfo);
                        counter.caption:=addinfo;
                        PaintBox1Paint(self);
                end;
        end;
end;

procedure Tsmdlg.FormShow(Sender: TObject);
begin
        if FDemo then
        begin
                done:=100;
                todo:=300;
                PaintBox1.Invalidate;
                Timer.Interval:=toi;
                Timer.Enabled:=True;
                Status.Caption:=tsend;
                Counter.Caption:='34580';
                Exit;
        end;
        todo:=0;
        If SendMail.Subject<>'' then Inc(todo);
        done:=0;
        PaintBox1.Invalidate;
        Timer.Enabled:=True;
        SendMail.OnMailInfo:=SendMailMailInfo;
        SendMail.OnDone:=MailDone;
        Status.Caption:=tconnecting+' '+SendMail.SMTP_Server;
        PostMessage(Handle,WM_STARTUP,0,0);
end;

procedure Tsmdlg.PaintBox1Paint(Sender: TObject);
var
        sub: Longint;
        divs: integer;
begin
        if todo=0 then Exit;
        with PaintBox1 do
        begin
                with Canvas do
                begin
                        sub:=(PaintBox1.Width)*done;
                        sub:=sub div todo;
                        Brush.Color:=c1;
                        Rectangle(0,0,sub,Height);
                end;
        end;
end;

procedure Tsmdlg.cancelClick(Sender: TObject);
begin
        SendMail.Action:=Cancel_SendMail;
        ModalResult:=mrCancel;
end;

{SendMail dialog component editor form code}
procedure TSendMailDialogCE.Button6Click(Sender: TObject);
var
        fed: TFontDialog;
begin
        try
                fed:=TFontDialog.Create(self);
                fed.Font:=FontSample.Font;
                if fed.execute then
                begin
                        FontSample.Font:=fed.Font;
                        txtcol.Brush.Color:=fed.Font.Color;
                        FontSample.Invalidate;
                end;
        finally
                fed.Destroy;
        end;
end;

procedure TSendMailDialogCE.FontSamplePaint(Sender: TObject);
begin
        with FontSample.Canvas do
        begin
                Brush.Color:=bkcol.Brush.Color;
                Pen.Color:=clBlack;
                Rectangle(0,0,FontSample.Width-1,FontSample.Height-1);
                Font.Color:=txtcol.Brush.Color;
                TextOut(5,5,'AaBbCcDd');
                Moveto(0,0);
                LineTo(FontSample.Width,0);
                LineTo(FontSample.Width,FontSample.Height);
                LineTo(0,FontSample.Height);
                LineTo(0,0);
        end;
end;

procedure TSendMailDialogCE.Button2Click(Sender: TObject);
var
        ced: TColorDialog;
begin
        try
                ced:=TColorDialog.Create(self);
                ced.Color:=txtcol.Brush.Color;
                if ced.Execute then
                begin
                        txtcol.Brush.Color:=ced.Color;
                        FontSample.Invalidate;

                end;
        finally
                ced.Destroy;
        end;
end;

procedure TSendMailDialogCE.Button1Click(Sender: TObject);
var
        ced: TColorDialog;
begin
        try
                ced:=TColorDialog.Create(self);
                ced.Color:=bkcol.Brush.Color;
                if ced.Execute then
                begin
                        bkcol.Brush.Color:=ced.Color;
                        FontSample.Invalidate;

                end;
        finally
                ced.Destroy;
        end;
end;

procedure TSendMailDialogCE.stbarClick(Sender: TObject);
begin
        if stbar.Checked then GroupBox5.Visible:=True
        else GroupBox5.Visible:=false;
end;

procedure TSendMailDialogCE.Button7Click(Sender: TObject);
var
        ced: TColorDialog;
begin
        try
                ced:=TColorDialog.Create(self);
                ced.Color:=stcol.Brush.Color;
                if ced.Execute then stcol.Brush.Color:=ced.Color;
        finally
                ced.Destroy;
        end;
end;

procedure TSendMailDialogCE.Button8Click(Sender: TObject);
var
        ced: TColorDialog;
begin
        try
                ced:=TColorDialog.Create(self);
                ced.Color:=stbk.Brush.Color;
                if ced.Execute then stbk.Brush.Color:=ced.Color;
        finally
                ced.Destroy;
        end;
end;

procedure TSendMailDialogCE.Button5Click(Sender: TObject);
begin
        FDemo:=True;
        ModalResult:=mrOk;
end;

end.
