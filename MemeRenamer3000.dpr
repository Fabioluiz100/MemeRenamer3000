program MemeRenamer3000;

uses
  Vcl.Forms,
  Controller.VLCPlayer in 'controllers\Controller.VLCPlayer.pas',
  Form.Main in 'forms\Form.Main.pas' {fmMain},
  Vcl.Themes,
  Vcl.Styles,
  Util.FileManager in 'utils\Util.FileManager.pas',
  Form.Config in 'forms\Form.Config.pas' {fmConfig},
  Util.Config in 'utils\Util.Config.pas',
  Enum.FileType in 'enums\Enum.FileType.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Carbon');
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmConfig, fmConfig);
  Application.Run;
end.
