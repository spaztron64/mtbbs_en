unit smtpmain;
(*@/// interface *)
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, tcpip;

type
(*@///   TForm1 = class(TForm) *)
TForm1 = class(TForm)
  edt_from: TEdit;
  edt_to: TEdit;
  lbl_from: TLabel;
  lbl_to: TLabel;
  mem_text: TMemo;
  lbl_text: TLabel;
  btn_go: TButton;
  SMTP: T_SMTP;
  Mail: T_Mail;
  lbl_subject: TLabel;
  edt_subject: TEdit;
  lbl_host: TLabel;
  edt_host: TEdit;
  Mime: T_Mime;
  btn_attach: TButton;
  procedure btn_goClick(Sender: TObject);
  procedure btn_attachClick(Sender: TObject);
  procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
protected
  attached_files: TStringList;
end;
(*@\\\003C001501001601001101001101001310*)

var
  Form1: TForm1;
(*@\\\0000000801*)
(*@/// implementation *)
implementation

uses attach;

{$R *.DFM}

(*@/// procedure TForm1.btn_goClick(Sender: TObject); *)
procedure TForm1.btn_goClick(Sender: TObject);
var
  i: integer;
begin
  mail.from:=edt_from.text;
  mail.Recipients.clear;
  mail.Recipients.add(edt_to.text);
  mail.body.assign(mem_text.lines);
  mail.subject:=edt_subject.text;
  mail.smtp.hostname:=edt_host.text;
  if self.attached_files.count=0 then
    mail.action
  else begin
    for i:=0 to self.attached_files.count-1 do
      mime.attachfile(self.attached_files[i]);
    mime.action;
    end;
  end;
(*@\\\0000000F01*)
(*@/// procedure TForm1.btn_attachClick(Sender: TObject); *)
procedure TForm1.btn_attachClick(Sender: TObject);
begin
  frm_attach.clientwidth:=237;
  frm_attach.lbx_attach.items.assign(self.attached_files);
  if frm_attach.showmodal = mrOK then
    self.attached_files.assign(frm_attach.lbx_attach.items)
end;
(*@\\\0000000605*)
(*@/// procedure TForm1.FormCreate(Sender: TObject); *)
procedure TForm1.FormCreate(Sender: TObject);
begin
  attached_files:=TStringlist.create;
  end;
(*@\\\0000000301*)
(*@\\\0000000915*)
procedure TForm1.FormDestroy(Sender: TObject);
begin
  attached_files.free;
  end;

end.
(*@\\\0002000301000301*)
