unit plugsetup;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Dialogs,MtbbsAPI, Menus;

type
  TPlugSetupDialog = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    ListBox1: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label4: TLabel;
    Edit2: TEdit;
    OpenDialog1: TOpenDialog;
    Label5: TLabel;
    Edit3: TEdit;
    Memo1: TMemo;
    Bevel1: TBevel;
    Label6: TLabel;
    Edit4: TEdit;
    Label7: TLabel;
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Edit4Change(Sender: TObject);
  private
       Procedure menuitemClick(Sender : TObject);
  public
    { Public 宣言 }
  end;

  TDummyCommand = Array [0..9] of String[16];

  TInstalledPlugin = Record
      FileName    : String[255];
      Name        : String[30];
      CanUseLevel : Integer;
      MainCommand : String[16];
      ChatCommand : String[16];
      Dummy       : TDummyCommand;
  End;

      TInstallInfo = Packed Record
         MainCommand : String[16];
         ChatCommand : String[16];
         Dummy       : TDummyCommand;
      End;

      TPlugInstallInformation = Function  : TInstallInfo                   ;stdcall;
      TPlugInformation        = Function  : Pchar                          ;stdcall;
      TPlugCreate             = Procedure (Ch : LongInt;Api : TMtApiRecord) ;stdcall;
      TPlugFree               = Procedure (Ch : LongInt)                   ;stdcall;
      TPlugCall               = Procedure (ch : LongInt)                   ;stdcall;
      TPlugOnLogin            = Procedure (ch : LongInt)                   ;stdcall;
      TPlugOnLogout           = Procedure (ch : LongInt)                   ;stdcall;
      TPlugOnGoodbye          = Procedure (ch : LongInt)                   ;stdcall;
      TPlugIsCalled           = Function  : Boolean                        ;stdcall;
      TPlugName               = Function  : Pchar                          ;stdcall;
      TPlugSetup              = Procedure                                  ;stdcall;

  TPlugin = Record

     Name        : String[30];
     MainCommand : String[16];
     ChatCommand : String[16];
     CanUseLevel : Integer;
     Dummy       : TDummyCommand;
     Handle      : THandle;
     menuitem    : Tmenuitem;

     Created     : Array [0..99] of Boolean;

     InstallInformation : TPlugInstallInformation ;
     Information        : TPlugInformation        ;
     Create             : TPlugCreate             ;
     Free               : TPlugFree               ;
     Call               : TPlugCall               ;
     OnLogin            : TPlugOnLogin            ;
     OnLogout           : TPlugOnLogout           ;
     OnGoodbye          : TPlugOnGoodbye           ;
     IsCalled           : TPlugIsCalled           ;
     Setup              : TPlugSetup              ;

  End;


var
  PlugSetupDialog: TPlugSetupDialog;

  InstalledPlugins      : array[0..29] of TInstalledPlugin;
  InstalledPluginsCount : Integer;

  Plugins : array[0..29] of TPlugin;
  PluginsCount : Integer;

   Procedure FreePlugin;
   Procedure LoadPlugin;

implementation

uses Main;



Function LoadPlugDll(FileName : String) : TPlugin;
Var
     PlugName : TPlugName;
     InstallInfo:  TInstallInfo;
     i : Integer;

Begin


   With Result Do
    Begin

      Handle := LoadLibrary(Pchar(FileName));

      if Handle = 0 then
            MessageBox(0,Pchar('プラグインをロード出来ません...'+FileName),'Error',MB_ICONSTOP or MB_OK)
      Else
         Begin
              Try
                  @PlugName           := GetProcAddress(Handle,'Name');
                  Name := PlugName;
                  @InstallInformation := GetProcAddress(Handle,'InstallInformation');
                   InstallInfo := InstallInformation;
                     MainCommand := InstallInfo.MainCommand;
                     ChatCommand := InstallInfo.ChatCommand;
                     Dummy       := InstallInfo.Dummy;
                  @Information        := GetProcAddress(Handle,'Information');
                  @Create             := GetProcAddress(Handle,'Create');
                  @Free               := GetProcAddress(Handle,'Free');
                  @Call               := GetProcAddress(Handle,'Call');

                  @OnLogin            := GetProcAddress(Handle,'OnLogin');
                  @OnLogout           := GetProcAddress(Handle,'OnLogout');
                  @OnGoodbye          := GetProcAddress(Handle,'OnGoodbye');

                  @IsCalled           := GetProcAddress(Handle,'IsCalled');
                  @Setup              := GetProcAddress(Handle,'Setup');

                   Except
                     FreeLibrary(Handle);
                     Handle := 0;
                     MessageBox(0,Pchar('プラグインのロードに失敗しました...'+FileName),'Error',MB_ICONSTOP or MB_OK);
                   End;
         End;
    End;

End;


Procedure TPlugSetupDialog.menuitemClick(Sender : TObject);
Var
  i : Integer;
Begin


     For i := 0 To PluginsCount - 1 Do
      If Plugins[i].MenuItem = Sender then
           Plugins[i].Setup;

End;


Procedure LoadPlugin;
Var
   FileName : String;
   F        : File of TPlugin;
   Plugin   : TPlugin;
   i,j      : Integer;
   s        : String;

Begin

    PluginsCount := 0;

    If InstalledPluginsCount=0 then Exit;
    
       For i := 0 To InstalledPluginsCount - 1 Do
         Begin
            Plugin := LoadPlugDll(InstalledPlugins[i].FileName);
            If Plugin.Handle <> 0 then
             Begin
                Plugins[PluginsCount] := Plugin;
                Plugins[PluginsCount].MainCommand := InstalledPlugins[i].MainCommand;
                Plugins[PluginsCount].ChatCommand := InstalledPlugins[i].ChatCommand;
                Plugins[PluginsCount].CanUseLevel := InstalledPlugins[i].CanUseLevel;
                Plugins[PluginsCount].menuitem := TMenuItem.Create(MainForm); // メニューアイテムを作成する
                with Plugins[PluginsCount].menuitem do
                  begin
                    Caption := Plugin.Name;
                    OnClick := PlugSetupDialog.menuitemClick;
                  end;
                MainForm.PluginMenu.Add(Plugins[PluginsCount].menuitem);
                For j := 0 to 99 do
                    Plugins[PluginsCount].Created[i] := False;
                Inc(PluginsCount);
             End;
         End;

     MainForm.mLoadPlugin.Enabled := False;
     MainForm.mFreePlugin.Enabled := True;

End;

Procedure FreePlugin;
Var
  i : Integer;
Begin

    For i := 0 To PluginsCount - 1 Do
        If Plugins[i].IsCalled then
          Begin
            MessageBox(0,'使用中のプラグインがあります。','プラグインの開放',MB_ICONSTOP or MB_OK);
            Exit;
          End;

    For i := 0 To PluginsCount - 1 Do
      Begin
         FreeLibrary(Plugins[i].Handle);
         Plugins[i].Menuitem.Free;
      End;   
     PluginsCount := 0;
     MainForm.mLoadPlugin.Enabled := True;
     MainForm.mFreePlugin.Enabled := False;

End;

Procedure LoadInstalledPlugins;
Var

   FileName : String;
   F        : File of TInstalledPlugin;

Begin

    InstalledPluginsCount := 0;

    FileName := ExtractFilePath(Application.ExeName)+'plugins.dat';

    If FileExists(FileName) then
     Begin
       AssignFile(f,FileName);
       Reset(f);
        BlockRead(f,InstalledPlugins,FileSize(f),InstalledPluginsCount);
       CloseFile(f);
     End;

End;

Procedure SaveInstalledPlugins;
Var

   FileName : String;
   F        : File of TInstalledPlugin;

Begin

    FileName := ExtractFilePath(Application.ExeName)+'plugins.dat';

       AssignFile(f,FileName);
       Rewrite(f);
        BlockWrite(f,InstalledPlugins,InstalledPluginsCount);
       CloseFile(f);

End;


{$R *.DFM}

procedure TPlugSetupDialog.FormShow(Sender: TObject);
Var
   i : Integer;
begin

   Memo1.Enabled     := False;
   Edit3.Enabled     := False;
   Edit4.Enabled     := False;
   GroupBox1.Enabled := False;
   Button2.Enabled   := False;

   ListBox1.Clear;
   For i := 0 to InstalledPluginsCount - 1 do
    Begin
      ListBox1.Items.add(InstalledPlugins[i].Name);
    End;


end;

procedure TPlugSetupDialog.OKBtnClick(Sender: TObject);
begin

     SaveInstalledPlugins;

end;

procedure TPlugSetupDialog.CancelBtnClick(Sender: TObject);
begin

      LoadInstalledPlugins;

end;

procedure TPlugSetupDialog.Button1Click(Sender: TObject);
Var
   Plugin : TPlugin;
begin


  If OpenDialog1.Execute then
   Begin
     Plugin := LoadPlugDll(OpenDialog1.FileName);
     If Plugin.Handle<>0 then
      Begin
       With InstalledPlugins[InstalledPluginsCount] do
         Begin
            FileName    := OpenDialog1.FileName;
            Name        := Plugin.Name;
            CanUseLevel := -1;
            MainCommand := Plugin.MainCommand;
            ChatCommand := Plugin.ChatCommand;
            Dummy       := Plugin.Dummy;
          End;
         FreeLibrary(Plugin.Handle);
         Inc(InstalledPluginsCount);
      End;
      FormShow(Sender);
   End;

end;


procedure TPlugSetupDialog.ListBox1Click(Sender: TObject);
Var
   Plugin : TPlugin;
begin

   Memo1.Enabled := True;
   Edit3.Enabled := True;
   Edit4.Enabled := True;
   GroupBox1.Enabled := True;
   Button2.Enabled := True;

   Plugin := LoadPlugDll(InstalledPlugins[ListBox1.ItemIndex].FileName);
   If Plugin.Handle <> 0 then
    Begin
       Memo1.Text := Plugin.Information;
       FreeLibrary(Plugin.Handle);
    End;

    With InstalledPlugins[ListBox1.ItemIndex] do
     Begin
       Edit3.Text := FileName;
       Edit1.Text := MainCommand;
       Edit2.Text := ChatCommand;
       Edit4.Text := IntToStr(CanUseLevel);
     End;

End;



procedure TPlugSetupDialog.Edit3Change(Sender: TObject);
begin

   InstalledPlugins[ListBox1.ItemIndex].FileName := Edit3.Text;

end;

procedure TPlugSetupDialog.Edit1Change(Sender: TObject);
begin

   InstalledPlugins[ListBox1.ItemIndex].MainCommand := UpperCase(Edit1.Text);

end;

procedure TPlugSetupDialog.Edit2Change(Sender: TObject);
begin

   InstalledPlugins[ListBox1.ItemIndex].ChatCommand := UpperCase(Edit2.Text);

end;

procedure TPlugSetupDialog.Button2Click(Sender: TObject);
Var
  i : Integer;
begin

   For i := ListBox1.ItemIndex+1 to ListBox1.Items.Count-1 Do
     InstalledPlugins[i-1] := InstalledPlugins[i];

   Dec(InstalledPluginsCount);
   FormShow(Sender);

end;




procedure TPlugSetupDialog.FormCreate(Sender: TObject);
begin
    LoadInstalledPlugins;
    LoadPlugin;

end;



procedure TPlugSetupDialog.Edit4Change(Sender: TObject);
begin

   InstalledPlugins[ListBox1.ItemIndex].CanUseLevel := StrToIntDef(Edit4.Text,-1);

end;

end.
