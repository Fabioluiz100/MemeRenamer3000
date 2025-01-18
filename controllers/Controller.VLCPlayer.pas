unit Controller.VLCPlayer;

interface

uses
  System.Classes, Winapi.Windows, Vcl.ExtCtrls;

type
  TVLCPlayer = class
  private
    function GetVLCLibPath: string;
    function LoadVLCLibrary(APath: string): Integer;
    function GetAProcAddress(AHandle: Integer; var AAddr: Pointer; AProcName: string;
      AFailedList: TStringList): Integer;
    function LoadVLCFunctions(AVlcHandle: Integer; AFailedList: TStringList): Boolean;
  public
    constructor Create;
    destructor Destroy;override;

    procedure OpenFileInPanel(AFileName: string; var APanel: TPanel);
    procedure StopPlayer;
  end;

  plibvlc_instance_t = type Pointer;
  plibvlc_media_player_t = type Pointer;
  plibvlc_media_t = type Pointer;

implementation

uses
  Winapi.Messages, System.SysUtils, System.Variants, Vcl.Controls, Vcl.Forms;

{ TVLCPlayer }

var
  libvlc_media_new_path: function(p_instance: Plibvlc_instance_t; path : PAnsiChar) : Plibvlc_media_t; cdecl;
  libvlc_media_new_location: function(p_instance: plibvlc_instance_t; psz_mrl : PAnsiChar) : Plibvlc_media_t; cdecl;
  libvlc_media_player_new_from_media: function(p_media: Plibvlc_media_t) : Plibvlc_media_player_t; cdecl;
  libvlc_media_player_set_hwnd: procedure(p_media_player: Plibvlc_media_player_t; drawable : Pointer); cdecl;
  libvlc_media_player_play: procedure(p_media_player: Plibvlc_media_player_t); cdecl;
  libvlc_media_player_stop: procedure(p_media_player: Plibvlc_media_player_t); cdecl;
  libvlc_media_player_release: procedure(p_media_player: Plibvlc_media_player_t); cdecl;
  libvlc_media_player_is_playing: function(p_media_player: Plibvlc_media_player_t) : Integer; cdecl;
  libvlc_media_release: procedure(p_media: Plibvlc_media_t); cdecl;
  libvlc_new: function(argc: Integer; argv: PAnsiChar) : Plibvlc_instance_t; cdecl;
  libvlc_release : procedure(p_instance: Plibvlc_instance_t); cdecl;

  vlcLib: integer;
  vlcInstance: plibvlc_instance_t;
  vlcMedia: plibvlc_media_t;
  vlcMediaPlayer: plibvlc_media_player_t;

constructor TVLCPlayer.Create;
var
  slError: TStringList;
begin
  try
    vlclib := LoadVLCLibrary(GetVLCLibPath());
  except on E: Exception do
    raise Exception.Create('Erro ao iniciar VLC Player:' + sLineBreak + E.Message);
  end;

  try
    slError := TStringList.Create;
    try
      if not LoadVLCFunctions(vlclib, slError) then
        raise Exception.Create('Algumas funções não puderam ser carregadas à biblioteca:' +
                               sLineBreak + slError.Text);
    finally
      FreeAndNil(slError);
    end;
  except on E: Exception do
    begin
      FreeLibrary(vlclib);
      raise Exception.Create('Erro ao iniciar VLC Player:' + sLineBreak + E.Message);
    end;
  end;

end;

destructor TVLCPlayer.Destroy;
begin
  FreeLibrary(vlclib);
  inherited;
end;

function TVLCPlayer.GetAProcAddress(AHandle: integer; var AAddr: Pointer; AProcName: string;
  AFailedList: TStringList): Integer;
begin
  AAddr := GetProcAddress(AHandle, PWideChar(AProcName));

  if Assigned(AAddr) then
    Exit(0);

  if Assigned(AFailedList) then
    AFailedList.Add(AProcName);

  Result := -1;
end;

function TVLCPlayer.GetVLCLibPath: string;
var
  LHandle: HKEY;
  LRegType: Integer;
  LDataSize: Cardinal;
  LKey: PWideChar;
  LRegResult: Integer;
begin
  Result := '';
  LKey := 'SOFTWARE\VideoLAN\VLC';
  LRegResult := RegOpenKeyEx(HKEY_LOCAL_MACHINE, LKey, 0, KEY_READ, LHandle);

  if LRegResult <> ERROR_SUCCESS then
    raise Exception.Create('Não foi possível verificar a instalação VLC Player no registro do Windows. ' +
                           'Código do erro: ' + IntToStr(LRegResult));

  try
    LRegResult := RegQueryValueEx(LHandle, 'InstallDir', nil, @LRegType, nil, @LDataSize);

    if LRegResult <> ERROR_SUCCESS then
      raise Exception.Create('Erro ao ler registro do Windows com a instalação VLC Player. ' +
                             'Código do erro: ' + IntToStr(LRegResult));

    SetLength(Result, LDataSize);
    RegQueryValueEx(LHandle, 'InstallDir', nil, @LRegType, PByte(@Result[1]), @LDataSize);
    Result[LDataSize] := '\';
  finally
    RegCloseKey(LHandle);
  end;

  Result := String(PChar(Result));
end;

function TVLCPlayer.LoadVLCFunctions(AVlcHandle: integer; AFailedList: TStringList): Boolean;
begin
  GetAProcAddress(AVlcHandle, @libvlc_new, 'libvlc_new', AFailedList);
  GetAProcAddress(AVlcHandle, @libvlc_media_new_location, 'libvlc_media_new_location', AFailedList);
  GetAProcAddress(AVlcHandle, @libvlc_media_player_new_from_media, 'libvlc_media_player_new_from_media', AFailedList);
  GetAProcAddress(AVlcHandle, @libvlc_media_release, 'libvlc_media_release', AFailedList);
  GetAProcAddress(AVlcHandle, @libvlc_media_player_set_hwnd, 'libvlc_media_player_set_hwnd', AFailedList);
  GetAProcAddress(AVlcHandle, @libvlc_media_player_play, 'libvlc_media_player_play', AFailedList);
  GetAProcAddress(AVlcHandle, @libvlc_media_player_stop, 'libvlc_media_player_stop', AFailedList);
  GetAProcAddress(AVlcHandle, @libvlc_media_player_release, 'libvlc_media_player_release', AFailedList);
  GetAProcAddress(AVlcHandle, @libvlc_release, 'libvlc_release', AFailedList);
  GetAProcAddress(AVlcHandle, @libvlc_media_player_is_playing, 'libvlc_media_player_is_playing', AFailedList);
  GetAProcAddress(AVlcHandle, @libvlc_media_new_path, 'libvlc_media_new_path', AFailedList);

  Result := AFailedList.Count = 0;
end;

function TVLCPlayer.LoadVLCLibrary(APath: string): Integer;
begin
  Result := LoadLibrary(PWideChar(APath + '\libvlccore.dll'));
  Result := LoadLibrary(PWideChar(APath + '\libvlc.dll'));
end;

procedure TVLCPlayer.OpenFileInPanel(AFileName: string; var APanel: TPanel);
var
  LUtf8Path: UTF8String;
begin
  StopPlayer;

  LUtf8Path := UTF8Encode(AFileName);

  vlcInstance := libvlc_new(0, nil);
  //vlcMedia := libvlc_media_new_path(vlcInstance, PAnsiChar(@Utf8Path[0]));
  vlcMedia := libvlc_media_new_path(vlcInstance, PAnsiChar(AnsiString(LUtf8Path)));
  vlcMediaPlayer := libvlc_media_player_new_from_media(vlcMedia);
  libvlc_media_release(vlcMedia);
  libvlc_media_player_set_hwnd(vlcMediaPlayer, Pointer(APanel.Handle));
  libvlc_media_player_play(vlcMediaPlayer);
end;

procedure TVLCPlayer.StopPlayer;
begin
  if not Assigned(vlcMediaPlayer) then
    Exit;

  libvlc_media_player_stop(vlcMediaPlayer);
  while libvlc_media_player_is_playing(vlcMediaPlayer) = 1 do
    Sleep(100);

  libvlc_media_player_release(vlcMediaPlayer);
  vlcMediaPlayer := nil;
  libvlc_release(vlcInstance);
end;

end.
