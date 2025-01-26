unit Form.Main;

interface

uses
  Winapi.Messages, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Controller.VLCPlayer,
  Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ActnMenus, System.Actions, Vcl.ActnList,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnColorMaps, Vcl.Grids, Data.DB, Vcl.DBGrids,
  DBClient, Vcl.ComCtrls;

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
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure acSelectFolderExecute(Sender: TObject);
    procedure acAjudaSobreExecute(Sender: TObject);
    procedure pnFolderSelectedClick(Sender: TObject);
    procedure gridFileListDblClick(Sender: TObject);
    procedure edNewFileNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure acToolConfigExecute(Sender: TObject);
    procedure tbVolumeChange(Sender: TObject);
  private
    FVLCPlayer: TVLCPlayer;
    FFolderSelected: string;
    FFileSelected: string;
    FIdFileRenaming: Integer;

    procedure SelectFolder;
    procedure LoadVLCPlayer;
    procedure OpenSelectedFile;
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
  System.SysUtils, Util.FileManager, Winapi.Windows, System.IOUtils, Form.Config;

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

  FVLCPlayer.StopPlayer;

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

procedure TfmMain.LoadVLCPlayer;
begin
  FVLCPlayer := TVLCPlayer.Create;
end;

procedure TfmMain.OpenSelectedFile;
begin
  if not pnVideo.Visible then
  begin
    pnVideo.Visible := True;
    pnVideo.Align := alClient;
  end;

  FIdFileRenaming := FcdsFileList.FieldByName('ID').AsInteger;

  FVLCPlayer.OpenFileInPanel(FcdsFileList.FieldByName('COMPLETEFILEPATH').AsWideString, pnVideoView);
  FileSelected := FcdsFileList.FieldByName('FILENAME').AsWideString;
  tbVolume.Position := FVLCPlayer.GetVolume;
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
