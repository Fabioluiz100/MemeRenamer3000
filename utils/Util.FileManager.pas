unit Util.FileManager;

interface

uses
  DBClient;

type
  TUtilFileManager = class
  public
    class function GetDataSetFileListFromFolder(AFolderPath: string): TClientDataSet;
  end;

implementation

uses
  System.IOUtils, System.Types, Data.DB, System.SysUtils, System.Classes;

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
  Result.FieldDefs.Add('FILENAME', ftString, 256);
  Result.FieldDefs.Add('ORIGINALFILENAME', ftString, 256);
  Result.FieldDefs.Add('FILEEXTENSION', ftString, 20);
  Result.FieldDefs.Add('COMPLETEFILEPATH', ftString, 3000);
  Result.CreateDataSet;

  LStringListFiles := TStringList.Create;
  LStringListFiles.AddStrings(LFileList);
  try
    for var i := 0 to LStringListFiles.Count - 1 do
    begin
      LFileName := ChangeFileExt(ExtractFileName(LStringListFiles.Strings[i]), '');

      Result.Append;
      Result.FieldByName('ID').AsInteger := i;
      Result.FieldByName('FILENAME').AsString := LFileName;
      Result.FieldByName('ORIGINALFILENAME').AsString := LFileName;
      Result.FieldByName('FILEEXTENSION').AsString := ExtractFileExt(LStringListFiles.Strings[i]);
      Result.FieldByName('COMPLETEFILEPATH').AsString := LStringListFiles.Strings[i];
      Result.Post;
    end;
  finally
    FreeAndNil(LStringListFiles);
  end;
end;

end.
