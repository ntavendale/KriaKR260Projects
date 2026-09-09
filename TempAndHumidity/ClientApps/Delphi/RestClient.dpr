program RestClient;

uses
  Vcl.Forms,
  Main in 'Main.pas' {fmMain},
  RestClasses in 'RestClasses.pas',
  EndpointClient in 'EndpointClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
