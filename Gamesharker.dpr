program Gamesharker;

{%File 'shark.ico'}

uses
  Forms,
  gamesharker1 in 'gamesharker1.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Gamesharker 1.0.1';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
