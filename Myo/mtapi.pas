unit mtapi;
interface

uses SysUtils,MTbbsAPI;

Type

   TMtAPI = class(TObject)
     private
          Function Version : LongInt;stdcall;
          Function Terminated_ : Boolean;stdcall;
          Procedure ChangeWhere(s : Pchar);stdcall;
          Procedure Sendln(s : PChar);stdcall;
          Function Recvln : PChar;stdcall;
          Procedure Puts(s : PChar);stdcall;
          Function YesNoInput(Prompt:Pchar):Boolean;stdcall;
          Function Input(Prompt:Pchar):Pchar;stdcall;
          Function InputCommand(Prompt:Pchar;CharInp:Boolean):Pchar;stdcall;
          Procedure Who;stdcall;
          Procedure Telegram;stdcall;
     protected
     public
       Terminated : ^Boolean;
       API        : TMtbbsAPI;
   end;


implementation

uses
    Mtbbs,Main;

constructor TMtAPI.Create(AOwner :TObject);
Begin

    Mtbbs := TMtbbs(AOwner);
    API.Version     := Version;
    API.Terminated  := Terminated;
    API.ChangeWhere := ChangeWhere;
    API.Sendln      := Sendln;
    API.Recvln      := Recvln;
    API.Puts        := Puts;
    API.YesNoInput  := YesNoInput;
    API.Input       := Input;
    API.InputCommand:= InputCommand;
    API.Who         := Who;
    API.Telegram    := Telegram;
End;

Function TMtAPI.Version : LongInt;stdcall;
Begin
  Result := 130;
End;

Function TMtAPI.Terminated : Boolean;stdcall;
Begin
  Result := Terminated^;
End;

Procedure TMtAPI.ChangeWhere(s : Pchar);stdcall;
Begin
   Mtbbs.User.Where := s;
End;

Procedure TMtAPI.Sendln(s : PChar);stdcall;
Begin
   Mtbbs.Sendln(s);
End;

Function TMtAPI.Recvln : PChar;stdcall;
Begin
  Result := Mtbbs.Recvln;
End;

Procedure MTAPI.Puts(s : PChar);stdcall;
Begin
  MTBBS.Puts(s);
End;

Function MTAPI.YesNoInput(Prompt:Pchar):Boolean;stdcall;
Begin
  Result := MTBBS.YesNoInput(Prompt);
End;

Function MTAPI.Input(Prompt:Pchar):Pchar;stdcall;
Begin
  Result := Mtbbs.Input(Prompt);
End;

Function MTAPI.InputCommand(Prompt:Pchar;CharInp:Boolean):Pchar;stdcall;
Begin
  Result := Mtbbs.InputCommand(Prompt,CharInp);
End;

Procedure MTAPI.Who;stdcall;
Begin
   Mtbbs.Who;
End;

Procedure MTAPI.Telegram;stdcall;
Begin
   Mtbbs.Telegram;
End;


end.
