program Starmail;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  Setupfrm in 'SETUPFRM.PAS' {SetupForm},
  Global in 'GLOBAL.PAS',
  Chkmail in 'CHKMAIL.PAS' {GetMailForm},
  Flashfrm in 'FLASHFRM.PAS' {Flash},
  Mbxform in 'MBXFORM.PAS' {MailboxForm},
  Viewmail in 'VIEWMAIL.PAS' {ViewMailForm},
  Print in 'PRINT.PAS' {PrintProgress},
  Transfer in 'TRANSFER.PAS' {TransferForm},
  Address in 'ADDRESS.PAS' {AddressForm},
  Newmail in 'NEWMAIL.PAS' {NewMessageForm},
  Options in 'OPTIONS.PAS' {OptionsForm},
  Addedtfm in 'ADDEDTFM.PAS' {AddEdit},
  Sndmail in 'SNDMAIL.PAS' {SendMailForm},
  Signatur in 'SIGNATUR.PAS' {SignatureForm},
  Attform in 'ATTFORM.PAS' {AttachmentForm},
  Mimeexec in 'MIMEEXEC.PAS' {MimeLaunchForm},
  Nmimetyp in 'NMIMETYP.PAS' {NewMimeTypeForm},
  Abook in 'ABOOK.PAS' {AddressBook},
  Mimeedit in 'MIMEEDIT.PAS' {MimeEditor};

{$R *.RES}

begin
  Application.Title := 'StarMail32 Light';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
