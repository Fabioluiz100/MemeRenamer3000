unit Util.Config;

interface

var
  ConfigVCLPath: string;
  AppVersion: string;

procedure UpdateVLCPath(AVLCPath: string);
procedure LoadConfigs;
procedure SaveConfigs;

implementation

uses
  System.SysUtils, System.IniFiles, Winapi.Windows;

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

procedure GetAppVersion;
var
  LSize, LHandle: DWORD;
  LBuffer: TBytes;
  LFileInfo: PVSFixedFileInfo;
  LFileInfoSize: UINT;
begin
  LSize := GetFileVersionInfoSize(PChar(ParamStr(0)), LHandle);
  if LSize > 0 then
  begin
    SetLength(LBuffer, LSize);
    if GetFileVersionInfo(PChar(ParamStr(0)), LHandle, LSize, LBuffer) then
      if VerQueryValue(LBuffer, '\', Pointer(LFileInfo), LFileInfoSize) then
        AppVersion := Format('v%d.%d', [HiWord(LFileInfo.dwFileVersionMS), LoWord(LFileInfo.dwFileVersionMS)]);
  end;
end;

initialization
  LoadConfigs;
  GetAppVersion;

end.
