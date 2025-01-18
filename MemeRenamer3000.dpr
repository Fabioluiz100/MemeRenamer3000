program MemeRenamer3000;

uses
  Vcl.Forms,
  Controller.VLCPlayer in 'controllers\Controller.VLCPlayer.pas',
  uPrincipal in 'views\uPrincipal.pas' {fmPrincipal},
  Vcl.Themes,
  Vcl.Styles,
  Util.FileManager in 'utils\Util.FileManager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Carbon');
  Application.CreateForm(TfmPrincipal, fmPrincipal);
  Application.Run;
end.
