{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal Application Singleton & Lifecycle  }
{                                                                          }
{   Manages the Ft application lifecycle, main loop, display/screen,       }
{   themes, clipboard, global CSS stylesheets, and icon assets.            }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.app;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ctypes,
  ftpas.api, ftpas.types, ftpas.canvas;

type
  { TFtApp — Main application controller singleton }
  TFtApp = class
  private
    FInitialized: Boolean;

    function  GetScreenWidth: Integer;
    function  GetScreenHeight: Integer;
    function  GetScreenDPI: Double;
    procedure SetScreenDPI(AValue: Double);

    function  GetSystemFont: string;
    procedure SetSystemFont(const AValue: string);
    function  GetFontGamma: Double;
    procedure SetFontGamma(AValue: Double);
    function  GetAnimationRunning: Boolean;

    function  GetTheme: string;
    procedure SetTheme(const AValue: string);
    function  GetAvailableThemes: string;
    function  GetCornerRadius: Double;
    procedure SetCornerRadius(AValue: Double);
    function  GetShadow: Boolean;
    procedure SetShadow(AValue: Boolean);
    function  GetDarkMode: Boolean;
    procedure SetDarkMode(AValue: Boolean);

    function  GetClipboardText: string;
    procedure SetClipboardText(const AValue: string);

    function  GetEglAvailable: Boolean;
    function  GetEglEnabled: Boolean;
    procedure SetEglEnabled(AValue: Boolean);
    function  GetGpuAvailable: Boolean;
  public
    constructor Create();
    destructor Destroy; override;

    { Lifecycle }
    procedure Initialize();
    procedure Run();
    procedure Terminate();

    { Themes & Styling }
    function  HasDarkMode(const AThemeName: string): Boolean;
    function  LoadThemeFile(const AFilePath: string): Boolean;
    function  LoadThemeDir(const ADirPath: string): Boolean;
    function  LoadCssFile(const AFilePath: string): Boolean;
    function  LoadCssString(const ACssString: string): Boolean;

    { Icon Registry }
    function  GetIconSvg(const AName: string; ADarkMode: Boolean = False): string;
    function  GetIconBitmap(const AName: string; AWidth, AHeight: Integer; ADarkMode: Boolean = False): TFtBitmap;
    procedure RegisterIcon(const AName, ASvgLight, ASvgDark: string);
    function  HasIcon(const AName: string): Boolean;
    procedure SetIconMonochromeColors(const ALightColor, ADarkColor: string);

    { Properties }
    property Initialized: Boolean read FInitialized;
    property ScreenWidth: Integer read GetScreenWidth;
    property ScreenHeight: Integer read GetScreenHeight;
    property ScreenDPI: Double read GetScreenDPI write SetScreenDPI;

    property SystemFont: string read GetSystemFont write SetSystemFont;
    property FontGamma: Double read GetFontGamma write SetFontGamma;
    property AnimationRunning: Boolean read GetAnimationRunning;

    property Theme: string read GetTheme write SetTheme;
    property AvailableThemes: string read GetAvailableThemes;
    property CornerRadius: Double read GetCornerRadius write SetCornerRadius;
    property Shadow: Boolean read GetShadow write SetShadow;
    property DarkMode: Boolean read GetDarkMode write SetDarkMode;

    property ClipboardText: string read GetClipboardText write SetClipboardText;

    property EglAvailable: Boolean read GetEglAvailable;
    property EglEnabled: Boolean read GetEglEnabled write SetEglEnabled;
    property GpuAvailable: Boolean read GetGpuAvailable;
  end;

{ Global Application Instance Accessors }
function  FtApp(): TFtApp;

var
  Application: TFtApp = nil;

implementation

var
  gAppInstance: TFtApp = nil;

function FtApp(): TFtApp;
begin
  if gAppInstance = nil then
    gAppInstance := TFtApp.Create();
  Result := gAppInstance;
end;

{ TFtApp }

constructor TFtApp.Create();
begin
  inherited Create();
  if gAppInstance = nil then
    gAppInstance := Self;
  if Application = nil then
    Application := Self;
  Initialize();
end;

destructor TFtApp.Destroy();
begin
  if FInitialized and Assigned(ft_quit) then
  begin
    ft_quit();
    FInitialized := False;
  end;
  if gAppInstance = Self then
    gAppInstance := nil;
  if Application = Self then
    Application := nil;
  inherited Destroy();
end;

procedure TFtApp.Initialize();
begin
  if not FInitialized then
  begin
    if Assigned(ft_init) then
      ft_init();
    FInitialized := True;
  end;
end;

procedure TFtApp.Run();
begin
  if not FInitialized then
    Initialize();
  if Assigned(ft_main_loop) then
    ft_main_loop();
end;

procedure TFtApp.Terminate();
begin
  if Assigned(ft_quit) then
    ft_quit();
end;

function TFtApp.GetScreenWidth: Integer;
begin
  if Assigned(ft_screen_get_width) then
    Result := ft_screen_get_width()
  else
    Result := 0;
end;

function TFtApp.GetScreenHeight: Integer;
begin
  if Assigned(ft_screen_get_height) then
    Result := ft_screen_get_height()
  else
    Result := 0;
end;

function TFtApp.GetScreenDPI: Double;
begin
  if Assigned(ft_screen_dpi_get) then
    Result := ft_screen_dpi_get()
  else
    Result := 96.0;
end;

procedure TFtApp.SetScreenDPI(AValue: Double);
begin
  if Assigned(ft_screen_dpi_set) then
    ft_screen_dpi_set(AValue);
end;

function TFtApp.GetSystemFont: string;
var
  p: PChar;
begin
  if Assigned(ft_system_font_get) then
  begin
    p := ft_system_font_get();
    if p <> nil then
      Result := string(p)
    else
      Result := '';
  end
  else
    Result := '';
end;

procedure TFtApp.SetSystemFont(const AValue: string);
begin
  if Assigned(ft_system_font_set) then
    ft_system_font_set(PChar(AValue));
end;

function TFtApp.GetFontGamma: Double;
begin
  if Assigned(ft_font_gamma_get) then
    Result := ft_font_gamma_get()
  else
    Result := 1.0;
end;

procedure TFtApp.SetFontGamma(AValue: Double);
begin
  if Assigned(ft_font_gamma_set) then
    ft_font_gamma_set(AValue);
end;

function TFtApp.GetAnimationRunning: Boolean;
begin
  if Assigned(ft_animation_is_running) then
    Result := ft_animation_is_running() <> 0
  else
    Result := False;
end;

function TFtApp.GetTheme: string;
var
  p: PChar;
begin
  if Assigned(ft_theme_get) then
  begin
    p := ft_theme_get();
    if p <> nil then
      Result := string(p)
    else
      Result := '';
  end
  else
    Result := '';
end;

procedure TFtApp.SetTheme(const AValue: string);
begin
  if Assigned(ft_theme_set) then
    ft_theme_set(PChar(AValue));
end;

function TFtApp.GetAvailableThemes: string;
var
  p: PChar;
begin
  if Assigned(ft_theme_get_available) then
  begin
    p := ft_theme_get_available();
    if p <> nil then
      Result := string(p)
    else
      Result := '';
  end
  else
    Result := '';
end;

function TFtApp.GetCornerRadius: Double;
begin
  if Assigned(ft_theme_get_corner_radius) then
    Result := ft_theme_get_corner_radius()
  else
    Result := 0.0;
end;

procedure TFtApp.SetCornerRadius(AValue: Double);
begin
  if Assigned(ft_theme_set_corner_radius) then
    ft_theme_set_corner_radius(AValue);
end;

function TFtApp.GetShadow: Boolean;
begin
  if Assigned(ft_theme_get_shadow) then
    Result := ft_theme_get_shadow() <> 0
  else
    Result := False;
end;

procedure TFtApp.SetShadow(AValue: Boolean);
var
  v: cint32;
begin
  if Assigned(ft_theme_set_shadow) then
  begin
    if AValue then v := 1 else v := 0;
    ft_theme_set_shadow(v);
  end;
end;

function TFtApp.GetDarkMode: Boolean;
begin
  if Assigned(ft_theme_get_dark_mode) then
    Result := ft_theme_get_dark_mode() <> 0
  else
    Result := False;
end;

procedure TFtApp.SetDarkMode(AValue: Boolean);
var
  v: cint32;
begin
  if Assigned(ft_theme_set_dark_mode) then
  begin
    if AValue then v := 1 else v := 0;
    ft_theme_set_dark_mode(v);
  end;
end;

function TFtApp.GetClipboardText: string;
var
  p: PChar;
begin
  if Assigned(ft_clipboard_get_text) then
  begin
    p := ft_clipboard_get_text();
    if p <> nil then
      Result := string(p)
    else
      Result := '';
  end
  else
    Result := '';
end;

procedure TFtApp.SetClipboardText(const AValue: string);
begin
  if Assigned(ft_clipboard_set_text) then
    ft_clipboard_set_text(PChar(AValue));
end;

function TFtApp.GetEglAvailable: Boolean;
begin
  if Assigned(ft_egl_is_available) then
    Result := ft_egl_is_available() <> 0
  else
    Result := False;
end;

function TFtApp.GetEglEnabled: Boolean;
begin
  if Assigned(ft_backend_is_egl_enabled) then
    Result := ft_backend_is_egl_enabled() <> 0
  else
    Result := False;
end;

procedure TFtApp.SetEglEnabled(AValue: Boolean);
var
  v: cint32;
begin
  if Assigned(ft_backend_enable_egl) then
  begin
    if AValue then v := 1 else v := 0;
    ft_backend_enable_egl(v);
  end;
end;

function TFtApp.GetGpuAvailable: Boolean;
begin
  if Assigned(ft_gpu_is_available) then
    Result := ft_gpu_is_available() <> 0
  else
    Result := False;
end;

function TFtApp.HasDarkMode(const AThemeName: string): Boolean;
begin
  if Assigned(ft_theme_has_dark_mode) then
    Result := ft_theme_has_dark_mode(PChar(AThemeName)) <> 0
  else
    Result := False;
end;

function TFtApp.LoadThemeFile(const AFilePath: string): Boolean;
begin
  if Assigned(ft_theme_load_file) then
    Result := ft_theme_load_file(PChar(AFilePath)) <> 0
  else
    Result := False;
end;

function TFtApp.LoadThemeDir(const ADirPath: string): Boolean;
begin
  if Assigned(ft_theme_load_dir) then
    Result := ft_theme_load_dir(PChar(ADirPath)) <> 0
  else
    Result := False;
end;

function TFtApp.LoadCssFile(const AFilePath: string): Boolean;
begin
  if Assigned(ft_style_load_css_file) then
    Result := ft_style_load_css_file(PChar(AFilePath)) <> 0
  else
    Result := False;
end;

function TFtApp.LoadCssString(const ACssString: string): Boolean;
begin
  if Assigned(ft_style_load_css_string) then
    Result := ft_style_load_css_string(PChar(ACssString)) <> 0
  else
    Result := False;
end;

function TFtApp.GetIconSvg(const AName: string; ADarkMode: Boolean): string;
var
  dm: cint32;
  p: PChar;
begin
  if Assigned(ft_icon_get_svg) then
  begin
    if ADarkMode then dm := 1 else dm := 0;
    p := ft_icon_get_svg(PChar(AName), dm);
    if p <> nil then
      Result := string(p)
    else
      Result := '';
  end
  else
    Result := '';
end;

function TFtApp.GetIconBitmap(const AName: string; AWidth, AHeight: Integer; ADarkMode: Boolean): TFtBitmap;
var
  dm: cint32;
  h: Pointer;
begin
  Result := nil;
  if Assigned(ft_icon_get_bitmap) then
  begin
    if ADarkMode then dm := 1 else dm := 0;
    h := ft_icon_get_bitmap(PChar(AName), AWidth, AHeight, dm);
    if h <> nil then
      Result := TFtBitmap.Wrap(h);
  end;
end;

procedure TFtApp.RegisterIcon(const AName, ASvgLight, ASvgDark: string);
begin
  if Assigned(ft_icon_register) then
    ft_icon_register(PChar(AName), PChar(ASvgLight), PChar(ASvgDark));
end;

function TFtApp.HasIcon(const AName: string): Boolean;
begin
  if Assigned(ft_icon_has) then
    Result := ft_icon_has(PChar(AName)) <> 0
  else
    Result := False;
end;

procedure TFtApp.SetIconMonochromeColors(const ALightColor, ADarkColor: string);
begin
  if Assigned(ft_icon_set_monochrome_colors) then
    ft_icon_set_monochrome_colors(PChar(ALightColor), PChar(ADarkColor));
end;

initialization
  FtApp.Initialize();

finalization
  if gAppInstance <> nil then
  begin
    gAppInstance.Free();
    gAppInstance := nil;
  end;

end.
