unit Lan_lan;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs
  ,netapi;

type

  TNetUserInfo = Record
                       UserName  : string;
                       FullName  : string;
                       Comment   : string;
                       LogonTime : TDateTime;
                       USER_INFO_2 : TUSER_INFO_2
                 End;

  TOnGetNetUserInfo = Procedure (Sender : TObject;Index : integer) of object;


  TLanlan = class(TComponent)
  private
        FOnGetNetUserInfo : TOnGetNetUserInfo;

        FComputers         : TStringList;
        FComputersUserInfo : array of TNetUserInfo;

        FThreads           : integer;

  protected
  public

        constructor Create(AOwner: TComponent);override;
        destructor Destroy;override;

        procedure NET_SEND(toName,Mes : string);
        Function GetNetUserInfo(Var NetUserInfo : TNetUserInfo):boolean;
        procedure RefreshLogonUserInfo;

  published

        property Computers: TStringList read FComputers write FComputers;
        property Threads:integer read FThreads write FThreads;
        //�C�x���g
        property OnGetNetUserInfo: TOnGetNetUserInfo read FOnGetNetUserInfo write FOnGetNetUserInfo;

  end;

  TLanlanThread = class(TThread)//���[�U���擾�p�X���b�h�I�u�W�F�N�g
  private
        LanLan : TLanlan;
        startIndex,endIndex : integer;
        FIndex : integer;
        procedure OnGetNetUserInfo;
  protected
        procedure Execute; override;
  public
        constructor Create(Owner: TLanlan;startI,endI : integer);
        Function GetNetUserInfo(UserName : string;Var NetUserInfo : TNetUserInfo):boolean;
  end;

procedure Register;

implementation


procedure Register;
begin
  RegisterComponents('MYO', [TLanlan]);
end;

constructor TTLanlan.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FComputers = TStringList.Create;

end;

destructor TTLanlan.Destroy;
begin

  FComputers.Free;
  inherited Destroy;
end;

(************************************

�k�`�m�k�`�m�R���|���C�����[�`��

************************************)

(*���b�Z�[�W���M�E�E�ENET SEND�R�}���h�Ɠ���*)
procedure TLanlan.Net_Send(toName,Mes : string);
var
      MsgName : LPWSTR;
      Buf : PBYTE;
      BufLen : DWORD;
begin

    BufLen := length(mes)*2;
    GetMem( MsgName   ,64);
    GetMem( Buf       ,BufLen+1);
    StringToWideChar(ToName,MsgName,64);
    StringToWideChar(Mes   ,LPWSTR(Buf),BufLen);
      NetMessageBufferSend (
        nil
       ,msgname
       ,nil
       ,buf
       ,buflen
      );
    FreeMem( MsgName   ,64);
    FreeMem( Buf       ,BufLen+1);

end;

procedure TLanlan.RefreshLogonUserInfo;
var
   i : integer;
begin
    TLanlanThread.Create(self,0,FComputers.count - 1);
end;



(************************************

���[�U�[���擾�p�X���b�h���[�`��

************************************)

constructor TLanlanThread.Create(Owner: TLanLan;startI,endI : integer);
Begin
     startIndex := startI;
     endIndex   := endI;
     Lanlan     := Owner;
     Resume;
End;

procedure TLanlanThread.OnGetNetUserInfo;
Begin
     Lanlan.FOnGetNetUserInfo(lanlan,FIndex);
End;

constructor TLanlanThread.Execute;
Begin

    For i:=startIndex to endIndex do
      if GetNetUserInfo(Lanlan.ComputersUserInfo[i]) then
        Begin
          FIndex := i;
          Synchronize(OnGetNetUserInfo); //���̃X���b�h�Ɠ������킹
        End;
    FreeOnTerminate := True;

End;

Function TLanlanThread.GetNetUserInfo(Var NetUserInfo : TNetUserInfo):boolean;
var
   Registry : TRegistry;
   UserName : LPWSTR;
   Srv : LPWSTR;
   buf : PUSER_INFO_2;
var
  TimeZoneInformation: TTimeZoneInformation;
Begin

   GetTimeZoneInformation(TimeZoneInformation);
   //���E�W�����Ƃ̍����v�Z
   //showmessage(IntToStr(round(encodedate(1970,1,1)-encodedate(1889,12,31))));

   GetMem(UserName,64);
   GetMem(srv,64);

     StringToWideChar(Edit1.text,UserName,64);
     Registry := TRegistry.Create;
     With Registry do//���[�U�[�����擾����T�[�o�������W�X�g������擾
      Begin
              RootKey:= HKEY_CURRENT_USER;
              if OpenKey('Volatile Environment',false) then
                  StringToWideChar(ReadString('LOGONSERVER'),srv,64)
              else
                  srv := nil;
          Free;
      End;

   buf := nil;

    NetUserGetInfo(srv,UserName,2,PBYTE(buf));

   if buf=nil then
      Result := false //�擾���s
   else
    with NetUserInfo do
     Begin
      Result := true;

       LogonTime := buf^.usri2_last_logon;
        LogonTime := LogonTime/(24*3600)//time_t->TDateTime
         +25588//1970-1889�N�{��?!
         -TimeZoneInformation.Bias/(60*24);//��������
       Comment  := buf^.usri2_comment;
       FullName := buf^.usri2_full_name;

     End;

     FreeMem(srv,64);
     FreeMem(UserName,64)

end;



end.
