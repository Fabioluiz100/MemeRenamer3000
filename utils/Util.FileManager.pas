unit Util.FileManager;

interface

uses
  DBClient;

type
  TUtilFileManager = class
  public
    class function GetDataSetFileListFromFolder(AFolderPath: string): TClientDataSet;
    class procedure OpenFile(const ACompleteFilePath: string);
    class procedure OpenFileInExplorer(const ACompleteFilePath: string);
    class procedure ValidateVLCPath(AFolderPath: string);
  end;

implementation

uses
  System.IOUtils, System.Types, Data.DB, System.SysUtils, System.Classes, Winapi.ShellAPI, Winapi.Windows;

{ TUtilFileManager }

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

end.
