unit Util.Config;

interface

var
  ConfigVCLPath: string;

procedure UpdateVLCPath(AVLCPath: string);
procedure LoadConfigs;
procedure SaveConfigs;

implementation

uses
  System.SysUtils, System.IniFiles;

procedure LoadConfigs;
var
  LIniPath: string;
  LIniConfigs: TIniFile;
begin
  LIniPath := ExtractFilePath(ParamStr(0)) + 'Config.ini';

  if not FileExists(LIniPath) then
    SaveConfigs;

  LIniConfigs := TIniFile.Create(LIniPath);
  try
    ConfigVCLPath := LIniConfigs.ReadString('VCL', 'Path', '');
  finally
    FreeAndNil(LIniConfigs);
  end;
end;

procedure SaveConfigs;
var
  LIniPath: string;
  LIniConfigs: TIniFile;
begin
  LIniPath := ExtractFilePath(ParamStr(0)) + 'Config.ini';

  LIniConfigs := TIniFile.Create(LIniPath);
  try
    LIniConfigs.WriteString('VCL', 'Path', ConfigVCLPath);
  finally
    FreeAndNil(LIniConfigs);
  end;
end;

procedure UpdateVLCPath(AVLCPath: string);
begin
  if AVLCPath = ConfigVCLPath then
    Exit;

  ConfigVCLPath := AVLCPath;
  SaveConfigs;
end;

initialization
  LoadConfigs;

end.
