unit uPrincipal;

interface

uses
  Winapi.Messages, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Controller.VLCPlayer,
  Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ActnMenus, System.Actions, Vcl.ActnList,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnColorMaps, Vcl.Grids, Data.DB, Vcl.DBGrids,
  DBClient;

type
  TfmPrincipal = class(TForm)
    pnPrincipal: TPanel;
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
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure acSelectFolderExecute(Sender: TObject);
    procedure acAjudaSobreExecute(Sender: TObject);
    procedure pnFolderSelectedClick(Sender: TObject);
    procedure gridFileListDblClick(Sender: TObject);
    procedure edNewFileNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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
  fmPrincipal: TfmPrincipal;

implementation

uses
  System.SysUtils, Util.FileManager, Winapi.Windows, System.IOUtils;

{$R *.dfm}

{ TfmPrincipal }

procedure TfmPrincipal.acAjudaSobreExecute(Sender: TObject);
begin
  ShowMessage('Feito por Fabioluiz100!');
end;

procedure TfmPrincipal.acSelectFolderExecute(Sender: TObject);
begin
  SelectFolder;
end;

procedure TfmPrincipal.ChangeFileName(ANewName: string);
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

  if ANewName = FcdsFileList.FieldByName('FILENAME').AsString then
    Exit;

  LNewFileName := ExtractFilePath(FcdsFileList.FieldByName('COMPLETEFILEPATH').AsString) +
    ANewName + FcdsFileList.FieldByName('FILEEXTENSION').AsString;

  if not RenameFile(FcdsFileList.FieldByName('COMPLETEFILEPATH').AsString, LNewFileName) then
    raise Exception.Create('Não foi possível renomear o arquivo!');

  FcdsFileList.Edit;
  FcdsFileList.FieldByName('FILENAME').AsString := ANewName;
  FcdsFileList.FieldByName('COMPLETEFILEPATH').AsString :=
    ExtractFilePath(FcdsFileList.FieldByName('COMPLETEFILEPATH').AsString) +
    FcdsFileList.FieldByName('FILENAME').AsString +
    FcdsFileList.FieldByName('FILEEXTENSION').AsString;
  FcdsFileList.Post;
end;

procedure TfmPrincipal.edNewFileNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key <> VK_RETURN then
    Exit;

  ChangeFileName(edNewFileName.Text);
  FcdsFileList.Next;
  OpenSelectedFile;
end;

procedure TfmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FVLCPlayer) then
    FreeAndNil(FVLCPlayer);
  if Assigned(FcdsFileList) then
    FreeAndNil(FcdsFileList);
end;

procedure TfmPrincipal.FormCreate(Sender: TObject);
begin
  LoadVLCPlayer;
end;

procedure TfmPrincipal.gridFileListDblClick(Sender: TObject);
begin
  OpenSelectedFile;
end;

procedure TfmPrincipal.LoadVLCPlayer;
begin
  FVLCPlayer := TVLCPlayer.Create;
end;

procedure TfmPrincipal.OpenSelectedFile;
begin
  FIdFileRenaming := FcdsFileList.FieldByName('ID').AsInteger;

  FVLCPlayer.OpenFileInPanel(FcdsFileList.FieldByName('COMPLETEFILEPATH').AsString, pnPreview);
  FileSelected := FcdsFileList.FieldByName('FILENAME').AsString;
end;

procedure TfmPrincipal.pnFolderSelectedClick(Sender: TObject);
begin
  SelectFolder;
end;

procedure TfmPrincipal.SelectFolder;
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

procedure TfmPrincipal.setFileSelected(AFileSelected: string);
begin
  FFileSelected := AFileSelected;

  edNewFileName.Text := FFileSelected;
  if edNewFileName.Focused then
    edNewFileName.SelectAll;
end;

procedure TfmPrincipal.setFolderSelected(AFolderSelected: string);
begin
  FFolderSelected := AFolderSelected;
  pnFolderSelected.Font.Style := [fsBold];
  pnFolderSelected.Caption := FFolderSelected;
end;

end.
