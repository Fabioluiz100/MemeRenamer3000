unit Util.FileManager;

interface

uses
  DBClient, Enum.FileType;

type
  TUtilFileManager = class
  public
    class function GetDataSetFileListFromFolder(AFolderPath: string): TClientDataSet;
    class procedure OpenFile(const ACompleteFilePath: string);
    class procedure OpenFileInExplorer(const ACompleteFilePath: string);
    class procedure ValidateVLCPath(AFolderPath: string);
    class function GetFileTypeByExt(AFileExt: string): TFileType;
    class procedure ChangeFileName(ANewName: string; var AcdsFileList: TClientDataSet);
  end;

const
  AUDIO_VIDEO_EXTS: array[0..14] of String = (
    'mp3', 'wav', 'ogg', 'flac', 'aac', 'wma', 'm4a',
    'mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm', 'mpeg'
  );

  IMAGE_EXTS: array[0..9] of String = (
    'jpg', 'jpeg', 'png', 'bmp', 'gif', 'tiff', 'tif', 'ico', 'webp', 'svg'
  );

implementation

uses
  System.IOUtils, Data.DB, System.Types, System.SysUtils, System.Classes, Winapi.ShellAPI, Winapi.Windows,
  System.StrUtils;

{ TUtilFileManager }

class procedure TUtilFileManager.ChangeFileName(ANewName: string; var AcdsFileList: TClientDataSet);
var
  LNewFileName: string;
begin
  if ANewName = AcdsFileList.FieldByName('FILENAME').AsWideString then
    Exit;

  LNewFileName := ExtractFilePath(AcdsFileList.FieldByName('COMPLETEFILEPATH').AsWideString) +
    ANewName + AcdsFileList.FieldByName('FILEEXTENSION').AsWideString;

  if FileExists(LNewFileName) then
    raise Exception.Create('Esse arquivo já existe!');

  if not RenameFile(AcdsFileList.FieldByName('COMPLETEFILEPATH').AsString, LNewFileName) then
    raise Exception.Create('Não foi possível renomear o arquivo!');

  AcdsFileList.Edit;
  AcdsFileList.FieldByName('FILENAME').AsWideString := ANewName;
  AcdsFileList.FieldByName('COMPLETEFILEPATH').AsWideString :=
    ExtractFilePath(AcdsFileList.FieldByName('COMPLETEFILEPATH').AsWideString) +
    AcdsFileList.FieldByName('FILENAME').AsWideString +
    AcdsFileList.FieldByName('FILEEXTENSION').AsWideString;
  AcdsFileList.Post;
end;

class function TUtilFileManager.GetDataSetFileListFromFolder(AFolderPath: string): TClientDataSet;
var
  LFileList: TStringDynArray;
  LStringListFiles: TStringList;
  LFileName: string;
begin
  LFileList := TDirectory.GetFiles(AFolderPath);

  if Length(LFileList) = 0 then
    raise Exception.Create('Nenhum arquivo encontrado nesta pasta.');

  Result := TClientDataSet.Create(nil);
  Result.FieldDefs.Add('ID', ftInteger);
  Result.FieldDefs.Add('FILENAME', ftWideString, 256);
  Result.FieldDefs.Add('ORIGINALFILENAME', ftWideString, 256);
  Result.FieldDefs.Add('FILEEXTENSION', ftWideString, 20);
  Result.FieldDefs.Add('COMPLETEFILEPATH', ftWideString, 3000);
  Result.CreateDataSet;

  LStringListFiles := TStringList.Create;
  LStringListFiles.AddStrings(LFileList);
  try
    for var i := 0 to LStringListFiles.Count - 1 do
    begin
      LFileName := ChangeFileExt(ExtractFileName(LStringListFiles.Strings[i]), '');

      Result.Append;
      Result.FieldByName('ID').AsInteger := i;
      Result.FieldByName('FILENAME').AsWideString := LFileName;
      Result.FieldByName('ORIGINALFILENAME').AsWideString := LFileName;
      Result.FieldByName('FILEEXTENSION').AsWideString := ExtractFileExt(LStringListFiles.Strings[i]);
      Result.FieldByName('COMPLETEFILEPATH').AsWideString := LStringListFiles.Strings[i];
      Result.Post;
    end;
  finally
    FreeAndNil(LStringListFiles);
  end;
end;

class procedure TUtilFileManager.OpenFile(const ACompleteFilePath: string);
begin
  if FileExists(ACompleteFilePath) then
    ShellExecute(0, 'open', PChar(ACompleteFilePath), nil, nil, SW_SHOWNORMAL);
end;

class procedure TUtilFileManager.OpenFileInExplorer(const ACompleteFilePath: string);
begin
  if FileExists(ACompleteFilePath) then
    ShellExecute(0, 'open', 'explorer.exe', PChar('/select,' + ACompleteFilePath), nil, SW_SHOWNORMAL)
end;

class procedure TUtilFileManager.ValidateVLCPath(AFolderPath: string);
begin
  if not FileExists(AFolderPath+'\libvlccore.dll') or not FileExists(AFolderPath+'\libvlc.dll') then
    raise Exception.CreateFmt('Instalação do VLC Player inválida.' + sLineBreak +
      'Não foram detectadas bibliotecas necessárias em "%s".', [AFolderPath]);
end;

class function TUtilFileManager.GetFileTypeByExt(AFileExt: string): TFileType;
var
  LFileExt: String;
begin
  LFileExt := StringReplace(AFileExt, '.', '', [rfReplaceAll]);
  LFileExt := LowerCase(LFileExt);

  if MatchStr(LFileExt, AUDIO_VIDEO_EXTS) then
    Result := TFileType.ftAudioVideo
  else if MatchStr(LFileExt, IMAGE_EXTS) then
    Result := TFileType.ftImage
  else
    Result := TFileType.ftUnknown;
end;

end.
