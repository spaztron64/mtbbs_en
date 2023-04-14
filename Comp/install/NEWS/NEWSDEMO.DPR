program newsdemo;

uses
  Forms,
  newsmain in 'newsmain.pas' {mainform};

{$R *.RES}

begin
(*$ifndef ver80 *)
  Application.Initialize;
(*$endif *)
  Application.CreateForm(Tmainform, mainform);
  Application.Run;
end.
(*@\\\0000000D01*)
