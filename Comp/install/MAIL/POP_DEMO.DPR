program pop_demo;

uses
  Forms,
  pop_main in 'pop_main.pas' {mainform};

{$R *.RES}

begin
(*$ifndef ver80 *)
  Application.Initialize;
(*$endif *)
  Application.CreateForm(Tmainform, mainform);
  Application.Run;
end.
(*@\\\0000000D01*)
