program MyoHost;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  MtBbs in 'MtBbs.pas',
  UEdit in 'UEdit.pas' {User},
  UList in 'UList.pas' {UserList},
  UserSys in 'UserSys.pas',
  Define in 'Define.pas',
  MesBrd in 'MesBrd.pas',
  Modem in 'Modem.pas' {ModemSettingDialog},
  FileSys in 'FileSys.pas',
  MBrdEdit in 'MBrdEdit.pas' {MessageBoardEdit},
  SysMesEd in 'SysMesEd.pas' {SystemMessageEdit},
  EdDefine in 'EdDefine.pas' {EditDefine},
  MhostVer in 'MhostVer.pas' {MyoHostVersion},
  LogSys in 'LogSys.pas',
  CONSOLE in '..\”Ä—p\CONSOLE.pas' {CONSOLEWindow},
  AutoEd in 'AutoEd.pas' {Auto},
  Memo in 'Memo.pas' {MemoForm},
  RasF in 'RasF.pas' {RasForm},
  ExMtbbs in 'ExMtbbs.pas',
  MailSys in 'MailSys.pas',
  MailMan in 'MailMan.pas' {MailManager},
  FileTranSys in '..\”Ä—p\FileTranSys.pas',
  filebrd in 'filebrd.pas',
  FbrdEdit in 'FbrdEdit.pas' {FileBoardEdit},
  MtbbsAPI in 'MtbbsAPI.pas',
  plugsetup in 'plugsetup.pas' {PlugSetupDialog},
  MVCL in '..\”Ä—p\MVCL.pas',
  Monitor in 'Monitor.pas' {MonitorWindow},
  wwwmtbbs in 'wwwmtbbs.pas',
  mtids in 'mtids.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TUser, User);
  Application.CreateForm(TUserList, UserList);
  Application.CreateForm(TModemSettingDialog, ModemSettingDialog);
  Application.CreateForm(TMessageBoardEdit, MessageBoardEdit);
  Application.CreateForm(TSystemMessageEdit, SystemMessageEdit);
  Application.CreateForm(TEditDefine, EditDefine);
  Application.CreateForm(TMyoHostVersion, MyoHostVersion);
  Application.CreateForm(TAuto, Auto);
  Application.CreateForm(TMailManager, MailManager);
  Application.CreateForm(TFileBoardEdit, FileBoardEdit);
  Application.CreateForm(TPlugSetupDialog, PlugSetupDialog);
  Application.Run;


end.
