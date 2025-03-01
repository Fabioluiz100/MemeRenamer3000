unit Form.Main;

interface

uses
  Winapi.Messages, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Controller.VLCPlayer,
  Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ActnMenus, System.Actions, Vcl.ActnList,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnColorMaps, Vcl.Grids, Data.DB, Vcl.DBGrids,
  DBClient, Vcl.ComCtrls, System.ImageList, Vcl.ImgList, Vcl.Menus;

type
  TfmMain = class(TForm)
    pnMain: TPanel;
    ambMain: TActionMainMenuBar;
    amMain: TActionManager;
    acSelectFolder: TAction;
    acAjudaSobre: TAction;
    pnFolderSelected: TPanel;
    pnRenameOptions: TPanel;
    pnPreview: TPanel;
    pnFileList: TPanel;
    gridFileList: TDBGrid;
    splPreviewListFiles: TSplitter;
    dsFileList: TDataSource;
    fodFolder: TFileOpenDialog;
    edNewFileName: TEdit;
    lbSelectNewFileName: TLabel;
    acToolConfig: TAction;
    pnVideo: TPanel;
    pnVideoControls: TPanel;
    pnVideoView: TPanel;
    tbVolume: TTrackBar;
    btPlay: TButton;
    ilIcons: TImageList;
    btPause: TButton;
    btStop: TButton;
    pnFileCount: TPanel;
    pmFileOptions: TPopupMenu;
    pmmiOpenFile: TMenuItem;
    pmmiOpenFileInExplorer: TMenuItem;
    imgImagem: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure acSelectFolderExecute(Sender: TObject);
    procedure acAjudaSobreExecute(Sender: TObject);
    procedure pnFolderSelectedClick(Sender: TObject);
    procedure gridFileListDblClick(Sender: TObject);
    procedure edNewFileNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure acToolConfigExecute(Sender: TObject);
    procedure tbVolumeChange(Sender: TObject);
    procedure btPlayClick(Sender: TObject);
    procedure btPauseClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure pmmiOpenFileClick(Sender: TObject);
    procedure pmmiOpenFileInExplorerClick(Sender: TObject);
    procedure gridFileListMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
  private
    FVLCPlayer: TVLCPlayer;
    FFolderSelected: string;
    FFileSelected: string;
    FIdFileRenaming: Integer;

    procedure SelectFolder;
    procedure LoadVLCPlayer;
    procedure OpenSelectedFile;
    procedure OpenImageFile;
    procedure OpenVideoFile;
    procedure setFolderSelected(AFolderSelected: string);
    procedure setFileSelected(AFileSelected: string);
    procedure ChangeFileName(ANewName: string);

    property FolderSelected: string read FFolderSelected write setFolderSelected;
    property FileSelected: string read FFileSelected write setFileSelected;
  public
    FcdsFileList: TClientDataSet;
  end;

var
  fmMain: TfmMain;

implementation

uses
  System.SysUtils, Util.FileManager, Winapi.Windows, System.IOUtils, Form.Config, System.Types,
  Enum.FileType, Vcl.Imaging.PNGImage, Vcl.Imaging.jpeg, Vcl.Imaging.GIFImg;

{$R *.dfm}

{ TfmMain }

procedure TfmMain.acAjudaSobreExecute(Sender: TObject);
begin
  ShowMessage('Feito por Fabioluiz100!');
end;

procedure TfmMain.acSelectFolderExecute(Sender: TObject);
begin
  SelectFolder;
end;

procedure TfmMain.acToolConfigExecute(Sender: TObject);
begin
  TfmConfig.OpenConfigs;
end;

procedure TfmMain.btPauseClick(Sender: TObject);
begin
  FVLCPlayer.PauseMedia;
end;

procedure TfmMain.btPlayClick(Sender: TObject);
begin
  OpenSelectedFile;
end;

procedure TfmMain.btStopClick(Sender: TObject);
begin
  FVLCPlayer.StopPlayer;
end;

procedure TfmMain.ChangeFileName(ANewName: string);
var
  LNewFileName: string;
begin
  if FIdFileRenaming <> FcdsFileList.FieldByName('ID').AsInteger then
  begin
    FcdsFileList.First;
    if not FcdsFileList.Locate('ID', FIdFileRenaming, []) then
      raise Exception.Create('Não foi possível localizar registro do arquivo ' +
                             QuotedStr(FileSelected) + '.');
  end;

  FVLCPlayer.StopMedia;

  if ANewName = FcdsFileList.FieldByName('FILENAME').AsWideString then
    Exit;

  LNewFileName := ExtractFilePath(FcdsFileList.FieldByName('COMPLETEFILEPATH').AsWideString) +
    ANewName + FcdsFileList.FieldByName('FILEEXTENSION').AsWideString;

  if not RenameFile(FcdsFileList.FieldByName('COMPLETEFILEPATH').AsString, LNewFileName) then
    raise Exception.Create('Não foi possível renomear o arquivo!');

  FcdsFileList.Edit;
  FcdsFileList.FieldByName('FILENAME').AsWideString := ANewName;
  FcdsFileList.FieldByName('COMPLETEFILEPATH').AsWideString :=
    ExtractFilePath(FcdsFileList.FieldByName('COMPLETEFILEPATH').AsWideString) +
    FcdsFileList.FieldByName('FILENAME').AsWideString +
    FcdsFileList.FieldByName('FILEEXTENSION').AsWideString;
  FcdsFileList.Post;
end;

procedure TfmMain.edNewFileNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key <> VK_RETURN then
    Exit;

  ChangeFileName(edNewFileName.Text);
  FcdsFileList.Next;
  OpenSelectedFile;
end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FVLCPlayer) then
    FreeAndNil(FVLCPlayer);
  if Assigned(FcdsFileList) then
    FreeAndNil(FcdsFileList);
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  LoadVLCPlayer;
end;

procedure TfmMain.gridFileListDblClick(Sender: TObject);
begin
  OpenSelectedFile;
end;

procedure TfmMain.gridFileListMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  LMouseCursorPoint: TPoint;
begin
  if Button <> mbRight then
    Exit;

  if not Assigned(FcdsFileList) or not(FcdsFileList.Active) then
    Exit;

  LMouseCursorPoint := gridFileList.ClientToScreen(Point(X, Y));
  pmFileOptions.Popup(LMouseCursorPoint.X, LMouseCursorPoint.Y);
end;

procedure TfmMain.LoadVLCPlayer;
begin
  FVLCPlayer := TVLCPlayer.Create;
end;

procedure TfmMain.OpenSelectedFile;
var
  LFileType: TFileType;
begin
  LFileType := TUtilFileManager.GetFileTypeByExt(FcdsFileList.FieldByName('FILEEXTENSION').AsString);

  case LFileType of
    ftAudioVideo: OpenVideoFile;
    ftImage: OpenImageFile;
    else
      Application.MessageBox(
        PChar(Format('Arquivo "%s" ainda não é suportado.', [FcdsFileList.FieldByName('FILEEXTENSION').AsString])),
        'Atenção!', MB_ICONWARNING + MB_OK);
  end;
end;

procedure TfmMain.OpenImageFile;
begin
  pnVideo.Visible := False;

  if FVLCPlayer.IsPlaying then
    FVLCPlayer.StopPlayer;

  imgImagem.Visible := True;
  try
    imgImagem.Picture.LoadFromFile(FcdsFileList.FieldByName('COMPLETEFILEPATH').AsWideString);
  except on E: Exception do
    Application.MessageBox(
        PChar(Format('Não foi possível abrir a imagem "%s". Motivo: %s',
        [FcdsFileList.FieldByName('COMPLETEFILEPATH').AsWideString, E.Message])),
        'Falha ao abrir imagem', MB_ICONERROR + MB_OK);
  end;
end;

procedure TfmMain.OpenVideoFile;
begin
  imgImagem.Visible := False;

  if not pnVideo.Visible then
  begin
    pnVideo.Visible := True;
    pnVideo.Align := alClient;
  end;

  FVLCPlayer.OpenFileInPanel(FcdsFileList.FieldByName('COMPLETEFILEPATH').AsWideString, pnVideoView);
  if (FIdFileRenaming = 0) or (FIdFileRenaming <> FcdsFileList.FieldByName('ID').AsInteger) then
  begin
    FIdFileRenaming := FcdsFileList.FieldByName('ID').AsInteger;
    FileSelected := FcdsFileList.FieldByName('FILENAME').AsWideString;
  end;
  tbVolume.Position := FVLCPlayer.GetVolume;
end;

procedure TfmMain.pmmiOpenFileClick(Sender: TObject);
begin
  TUtilFileManager.OpenFile(FcdsFileList.FieldByName('COMPLETEFILEPATH').AsWideString);
end;

procedure TfmMain.pmmiOpenFileInExplorerClick(Sender: TObject);
begin
  TUtilFileManager.OpenFileInExplorer(FcdsFileList.FieldByName('COMPLETEFILEPATH').AsWideString);
end;

procedure TfmMain.pnFolderSelectedClick(Sender: TObject);
begin
  SelectFolder;
end;

procedure TfmMain.SelectFolder;
begin
  if not fodFolder.Execute then
    Exit;

  FolderSelected := fodFolder.FileName;
  if Assigned(FcdsFileList) then
  begin
    FcdsFileList.Close;
    FreeAndNil(FcdsFileList);
  end;

  FcdsFileList := TUtilFileManager.GetDataSetFileListFromFolder(FolderSelected);
  FcdsFileList.First;
  OpenSelectedFile;
  dsFileList.DataSet := FcdsFileList;

  pnFileCount.Caption := 'Total de arquivos: ' + FcdsFileList.RecordCount.ToString;

  edNewFileName.SetFocus;
  edNewFileName.SelectAll;
end;

procedure TfmMain.setFileSelected(AFileSelected: string);
begin
  FFileSelected := AFileSelected;

  edNewFileName.Text := FFileSelected;
  if edNewFileName.Focused then
    edNewFileName.SelectAll;
end;

procedure TfmMain.setFolderSelected(AFolderSelected: string);
begin
  FFolderSelected := AFolderSelected;
  pnFolderSelected.Font.Style := [fsBold];
  pnFolderSelected.Caption := FFolderSelected;
end;

procedure TfmMain.tbVolumeChange(Sender: TObject);
begin
  FVLCPlayer.SetVolume(tbVolume.Position);
end;

end.
