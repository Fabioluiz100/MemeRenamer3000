unit Form.About;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage, Vcl.StdCtrls;

type
  TfmAbout = class(TForm)
    pnMain: TPanel;
    pnLogo: TPanel;
    imgLogo: TImage;
    pnText: TPanel;
    lbAppName: TLabel;
    pnSpacer: TPanel;
    lbCopyright: TLabel;
    lbGetVLCPlayer: TLabel;
    procedure lbGetVLCPlayerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    class procedure OpenAbout;
  end;

var
  fmAbout: TfmAbout;

implementation

uses
  ShellAPI, System.SysUtils, DateUtils, Util.Config;

{$R *.dfm}

procedure TfmAbout.FormCreate(Sender: TObject);
begin
  Self.Constraints.MinHeight := Self.Height;
  Self.Constraints.MinWidth := Self.Width;
  lbAppName.Caption := lbAppName.Caption + ' ' + AppVersion;
  lbCopyright.Caption := Format(lbCopyright.Caption, [YearOf(Now)]);
end;

procedure TfmAbout.lbGetVLCPlayerClick(Sender: TObject);
begin
  ShellExecute(HInstance, 'open', PChar('https://github.com/Fabioluiz100/MemeRenamer3000/'), nil, nil, SW_NORMAL);
end;

class procedure TfmAbout.OpenAbout;
var
  LfmAbout: TfmAbout;
begin
  LfmAbout := TfmAbout.Create(nil);
  try
    LfmAbout.ShowModal;
  finally
    FreeAndNil(LfmAbout);
  end;
end;

end.
