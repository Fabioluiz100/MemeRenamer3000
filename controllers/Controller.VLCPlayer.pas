unit Controller.VLCPlayer;

interface

uses
  System.Classes, Winapi.Windows, Vcl.ExtCtrls;

type
  TVLCPlayer = class
  private
    FVLCPath: string;

    procedure LoadVLCLibrary;
    function GetVLCLibPath: string;
    function GetAProcAddress(AHandle: Integer; var AAddr: Pointer; AProcName: string;
      AFailedList: TStringList): Integer;
    function LoadVLCFunctions(AVlcHandle: Integer; AFailedList: TStringList): Boolean;
    function getLibaryLoaded: Boolean;
  public
    constructor Create;
    destructor Destroy;override;

    procedure OpenFileInPanel(AFileName: string; var APanel: TPanel);
    procedure StopPlayer;
    procedure PlayMedia;
    procedure StopMedia;
    procedure PauseMedia;
    procedure SetVolume(ALevel: Integer);
    function GetVolume: Integer;
    function IsPlaying: Boolean;

    property LibaryLoaded: Boolean read getLibaryLoaded;
  end;

  plibvlc_instance_t = type Pointer;
  plibvlc_media_player_t = type Pointer;
  plibvlc_media_t = type Pointer;

implementation

uses
  Winapi.Messages, System.SysUtils, System.Variants, Vcl.Controls, Vcl.Forms,
  Util.Config;

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
  libvlc_audio_get_volume : function(p_media_player : Plibvlc_media_player_t): Integer; cdecl;
  libvlc_audio_set_volume : function(p_media_player : Plibvlc_media_player_t; volume : Integer) : Integer; cdecl;
  libvlc_media_player_pause : procedure(p_media_player : Plibvlc_media_player_t); cdecl;

  vlcLib: integer;
  vlcInstance: plibvlc_instance_t;
  vlcMedia: plibvlc_media_t;
  vlcMediaPlayer: plibvlc_media_player_t;

constructor TVLCPlayer.Create;
begin
  LoadVLCLibrary;
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

function TVLCPlayer.getLibaryLoaded: Boolean;
begin
  Result := vlclib > 0;
end;

function TVLCPlayer.GetVLCLibPath: string;
var
  LHandle: HKEY;
  LRegType: Integer;
  LDataSize: Cardinal;
  LKey: PWideChar;
  LRegResult: Integer;
begin
  if ConfigVCLPath <> '' then
    Exit(ConfigVCLPath);

  Result := '';
  LKey := 'SOFTWARE\VideoLAN\VLC';
  LRegResult := RegOpenKeyEx(HKEY_LOCAL_MACHINE, LKey, 0, KEY_READ, LHandle);

  if LRegResult <> ERROR_SUCCESS then
    raise Exception.CreateFmt('Não foi possível verificar a instalação VLC Player no registro do Windows. ' +
      'Código do erro: %d', [LRegResult]);

  try
    LRegResult := RegQueryValueEx(LHandle, 'InstallDir', nil, @LRegType, nil, @LDataSize);

    if LRegResult <> ERROR_SUCCESS then
      raise Exception.CreateFmt('Erro ao ler registro do Windows com a instalação VLC Player. ' +
        'Código do erro: %d', [LRegResult]);

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
  GetAProcAddress(AVlcHandle, @libvlc_audio_get_volume, 'libvlc_audio_get_volume', AFailedList);
  GetAProcAddress(AVlcHandle, @libvlc_audio_set_volume, 'libvlc_audio_set_volume', AFailedList);
  GetAProcAddress(AVlcHandle, @libvlc_media_player_pause , 'libvlc_media_player_pause', AFailedList);

  Result := AFailedList.Count = 0;
end;

procedure TVLCPlayer.LoadVLCLibrary;
var
  LErrorList: TStringList;
begin
  try
    FVLCPath := GetVLCLibPath();
    vlclib := LoadLibrary(PWideChar(FVLCPath + '\libvlccore.dll'));
    vlclib := LoadLibrary(PWideChar(FVLCPath + '\libvlc.dll'));
  except on E: Exception do
    raise Exception.Create('Erro ao iniciar VLC Player:' + sLineBreak + E.Message);
  end;

  try
    UpdateVLCPath(FVLCPath);
  except on E: Exception do
    Application.MessageBox(PChar('Falha salvar a configuração do VCL Player automaticamente:' +
      sLineBreak + E.Message), PChar(Application.Name), MB_OK + MB_ICONERROR);
  end;

  try
    LErrorList := TStringList.Create;
    try
      if not LoadVLCFunctions(vlclib, LErrorList) then
        raise Exception.Create('Algumas funções não puderam ser carregadas à biblioteca:' +
                               sLineBreak + LErrorList.Text);
    finally
      FreeAndNil(LErrorList);
    end;
  except on E: Exception do
    begin
      FreeLibrary(vlclib);
      raise Exception.Create('Erro ao iniciar VLC Player:' + sLineBreak + E.Message);
    end;
  end;
end;

procedure TVLCPlayer.OpenFileInPanel(AFileName: string; var APanel: TPanel);
var
  LUtf8Path: UTF8String;
  LUTF8StringPath: PAnsiChar;
begin
  StopMedia;

  LUtf8Path := UTF8Encode(AFileName);
  LUTF8StringPath := PAnsiChar(AnsiString(LUtf8Path));

  if not FileExists(String(LUtf8Path)) and
    (Application.MessageBox(PChar('O arquivo não foi encontrado ou possui um nome não suportado. ' +
      'Deseja tentar abri-lo mesmo assim?'), PChar(Application.Name), MB_YESNO + MB_ICONQUESTION) = mrNo) then
      Exit;

  vlcInstance := libvlc_new(0, nil);
  vlcMedia := libvlc_media_new_path(vlcInstance, LUTF8StringPath);
  vlcMediaPlayer := libvlc_media_player_new_from_media(vlcMedia);
  libvlc_media_release(vlcMedia);
  libvlc_media_player_set_hwnd(vlcMediaPlayer, Pointer(APanel.Handle));
  libvlc_media_player_play(vlcMediaPlayer);
end;

procedure TVLCPlayer.SetVolume(ALevel: Integer);
begin
  if not Assigned(vlcMediaPlayer) then
    Exit;

  libvlc_audio_set_volume(vlcMediaPlayer, ALevel);
end;

function TVLCPlayer.GetVolume: Integer;
begin
  if not Assigned(vlcMediaPlayer) then
    Exit(0);

  Result := libvlc_audio_get_volume(vlcMediaPlayer);
end;

function TVLCPlayer.IsPlaying: Boolean;
begin
  if not Assigned(vlcMediaPlayer) then
    Exit(False);

  Result := libvlc_media_player_is_playing(vlcMediaPlayer) = 1;
end;

procedure TVLCPlayer.StopMedia;
begin
  if not Assigned(vlcMediaPlayer) then
    Exit;

  libvlc_media_player_stop(vlcMediaPlayer);
  while libvlc_media_player_is_playing(vlcMediaPlayer) = 1 do
    Sleep(100);
end;

procedure TVLCPlayer.StopPlayer;
begin
  if not Assigned(vlcMediaPlayer) then
    Exit;

  StopMedia;
  libvlc_media_player_release(vlcMediaPlayer);
  vlcMediaPlayer := nil;
  libvlc_release(vlcInstance);
end;

procedure TVLCPlayer.PauseMedia;
begin
  if not Assigned(vlcMediaPlayer) then
    Exit;

  libvlc_media_player_pause(vlcMediaPlayer);
end;

procedure TVLCPlayer.PlayMedia;
begin
  if not Assigned(vlcMediaPlayer) then
    Exit;

  libvlc_media_player_play(vlcMediaPlayer);
end;

end.
