unit MVCL;

(****************************************************

     汎用 ＶＣＬスレッド対応化 ユニット 「ＭＶＣＬ」

      Copyright (C) 1998.3.28 By Yoshihiro Myokan

 ****************************************************)

{

  １．同期オブジェクト「ＴＭｕｔｅｘ」

      Mutex.Wait ....
      　複数スレッドからの同時アクセスの可能性がある部分の
      　最初に実行します。
        < 他のスレッドが実行中なら、待機する。>
      Mutex.Relese ....
        処理が終了したら、必ず呼び出す

       例)
  　　  Mutex.Wait
  　　　 　// 単一スレッドで走らせたい部分
  　　  Mutex.Release

  ２．スレッド対応ＶＣＬ

　　 MVCLをimplementation部のuses節に追加することにより、
　　以下のＶＣＬがスレッド対応化(同時アクセス保護)されます。　

    System unit
     function Copy(S: string; Index, Count: Integer): string;
     function Pos(Substr: string; S: string): Integer;
     Function Format(const Format: string; const Args: array of const): string;
    SysUtils unit
     Function IntToStr(Value: Integer): string;
     Function StrToIntDef(const S: string; Default: Integer): Integer;
     function Trim(const S: string): string;
     function UpperCase(const S: string): string;
      *** 以下の関数は実際のＶＣＬと互換性がありません ***
     Function TimeToStr(Time : TDateTime):String;
     Function DateToStr(Date : TDateTime):String;
     Function StrToDateTimeDef(S : String;Def : TDateTime) : TdateTime;

}

interface
uses
    SysUtils,Windows;

Type

   TMutex = Class(TObject)
   private
      FMutexHandle : Thandle;
   protected
   public
       Procedure Wait;
       Procedure Release;
       constructor Create;
       destructor  Destroy;override;
   end;

Var
    Mutex : TMutex;

 Function Format(const Format: string; const Args: array of const): string;
 Function IntToStr(Value: Integer): string;
 Function StrToIntDef(const S: string; Default: Integer): Integer;
 function Copy(S: string; Index, Count: Integer): string;
 function Pos(Substr: string; S: string): Integer;
 Function TimeToStr(Time : TDateTime):String;
 Function DateToStr(Date : TDateTime):String;
 Function StrToDateTimeDef(S : String;Def : TDateTime) : TdateTime;
 function UpperCase(const S: string): string;

implementation

constructor TMutex.Create;
Begin

      inherited Create;
      FMutexHandle := CreateMutex(nil, False, nil);

end;

destructor  TMutex.Destroy;
Begin

      CloseHandle(FMutexHandle);
      inherited Destroy;

end;

Procedure TMutex.Wait;
Begin

      WaitForSingleObject(FMutexHandle,5000);

End;

Procedure TMutex.Release;
Begin

      ReleaseMutex(FMutexHandle);

End;

//         主要ＶＣＬ関数のスレッド対応化

function Copy(S: string; Index, Count: Integer): string;
Begin

  Mutex.Wait;
   Result := System.Copy(S,Index,Count);
  Mutex.Release;

End;

function Pos(Substr: string; S: string): Integer;
Begin

  Mutex.Wait;
   Result := system.Pos(Substr,S);
  Mutex.Release;

End;

Function Format(const Format: string; const Args: array of const): string;
Begin

  Mutex.Wait;
   Result := SysUtils.Format(Format,Args);
  Mutex.Release;

End;

Function IntToStr(Value: Integer): string;
Begin

  Mutex.Wait;
   Result := SysUtils.IntToStr(Value);
  Mutex.Release;

End;

function UpperCase(const S: string): string;
Begin

  Mutex.Wait;
   Result := SysUtils.UpperCase(S);
  Mutex.Release;

End;

Function StrToIntDef(const S: string; Default: Integer): Integer;
Begin

  Mutex.Wait;
   Result := SysUtils.StrToIntDef(S,Default);
  Mutex.Release;

End;


(*-------*)

Function DateToStr(Date : TDateTime):String;
var
  Year, Month, Day : Word;
begin

  Mutex.Wait;
   DecodeDate(Date,Year,Month, Day);
   Year := Year - 1900;
   If Year > 99 then Year := Year - 100;
   Result := Format('%.2d/%.2d/%.2d',[Year,Month,Day]);
  Mutex.Release;

End;

Function TimeToStr(Time : TDateTime):String;
var
  Hour, Min, Sec, MSec: Word;
begin

  Mutex.Wait;
   DecodeTime(Time,Hour,Min, Sec, MSec);
   Result := Format('%.2d:%.2d:%.2d',[Hour,Min,Sec]);
  Mutex.Release;

End;

Function DateTimeToStr(DateTime : TDateTime):String;
Begin

  Mutex.Wait;
   Result := DateToStr(DateTime)+' '+TimeToStr(DateTime);
  Mutex.Release;

End;

Function StrToDateTimeDef(S : String;Def : TDateTime) : TdateTime;
Var
  Year, Month, Day, Hour, Min, Sec : Word;
  i,m,n : Integer;
  a : String;
Begin

  Mutex.Wait;

  a  := S;
  Result := Def;

  Try

   For i := 0 to 2 Do
    Begin
      if i = 2 then n := Pos(' ',a+' ')
               else n := Pos('/',a);
      If n = 0  then Exit;
       m := StrToIntDef(Copy(a,1,n - 1),-1);
      If m = -1 then Exit;
      a := Copy(a,n + 1,99);
      Case i of
        0 : Year  := m;
        1 : Month := m;
        2 : Day   := m;
      End;
    End;

    If Year < 1900 then
     Begin
        If Year < 80 then Year := Year + 2000
                     else Year := Year + 1900;
     End;

    Result := EncodeDate(Year, Month, Day);

   Hour := 0;
   Min  := 0;
   Sec  := 0;

   For i:=0 to 2 Do
    Begin
      if i = 2 then n := 99
               else n := Pos(':',a);
      If n = 0 then Break;
       m := StrToIntDef(Copy(a,1,n - 1),-1);
      If m = -1 then Exit;
      a := Copy(a,n + 1,99);
      Case i of
        0 : Hour := m;
        1 : Min  := m;
        2 : Sec  := m;
      End;
    End;

    Result := Result + EncodeTime(Hour,Min, Sec,0);

  Finally
   Mutex.Release;
  End;

End;




initialization

     Mutex := TMutex.Create;

Finalization

     Mutex.Free;

end.
