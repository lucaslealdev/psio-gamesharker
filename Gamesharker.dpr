program Project1;

{%File 'shark.ico'}

uses
  Forms,
  gamesharker in 'gamesharker.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Gamesharker 1.0';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
