unit Form.Config;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls;

type
  TfmConfig = class(TForm)
    pnMain: TPanel;
    pnButtons: TPanel;
    pcConfig: TPageControl;
    tsConfig: TTabSheet;
    lbVCLPath: TLabel;
    edVCLPath: TEdit;
    fodFolder: TFileOpenDialog;
    btCancel: TButton;
    btSave: TButton;
    lbGetVLCPlayer: TLabel;
    procedure edVCLPathClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbGetVLCPlayerClick(Sender: TObject);
  private
    { Private declarations }
    procedure ValidateFields;
    procedure LoadConfigFields;
    procedure SaveConfigFields;
  public
    { Public declarations }
    class procedure OpenConfigs;
  end;

var
  fmConfig: TfmConfig;

implementation

uses
  Util.FileManager, Util.Config, ShellAPI;

{$R *.dfm}

procedure TfmConfig.btCancelClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfmConfig.btSaveClick(Sender: TObject);
begin
  ValidateFields;
  SaveConfigFields;

  Self.Close;
end;

procedure TfmConfig.edVCLPathClick(Sender: TObject);
begin
  if not fodFolder.Execute then
    Exit;

  edVCLPath.Text := fodFolder.FileName;
end;

procedure TfmConfig.FormShow(Sender: TObject);
begin
  LoadConfigFields;
end;

procedure TfmConfig.lbGetVLCPlayerClick(Sender: TObject);
begin
  ShellExecute(HInstance, 'open', PChar('https://www.videolan.org/vlc/download-windows.html'), nil, nil, SW_NORMAL);
end;

procedure TfmConfig.LoadConfigFields;
begin
  edVCLPath.Text := ConfigVCLPath;
end;

procedure TfmConfig.SaveConfigFields;
begin
  ConfigVCLPath := edVCLPath.Text;
  SaveConfigs;
end;

procedure TfmConfig.ValidateFields;
begin
  TUtilFileManager.ValidateVLCPath(edVCLPath.Text);
end;

class procedure TfmConfig.OpenConfigs;
var
  LfmConfig: TfmConfig;
begin
  LfmConfig := TfmConfig.Create(nil);
  try
    LfmConfig.ShowModal;
  finally
    FreeAndNil(LfmConfig);
  end;
end;

end.
