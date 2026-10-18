{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal Window Class (TFtWindow)           }
{                                                                          }
{   Provides the TFtWindow OOP class wrapping native FtWindow handles,     }
{   events (resize, mouse, keyboard, GL draw), modal execution, EGL,       }
{   and strut partial positioning.                                         }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.window;

{$mode objfpc}{$H+}

interface

uses
  ctypes, Classes, SysUtils, ftpas.api, ftpas.types, ftpas.widget;

type
  { Forward Declarations }
  TFtWindow = class;

  { Window Event Procedural Signatures }
  TFtWindowResizeEvent    = procedure(Sender: TFtWindow; ANewWidth, ANewHeight: Integer) of object;
  TFtWindowMouseEvent     = procedure(Sender: TFtWindow; AX, AY, AButton: Integer) of object;
  TFtWindowMouseMoveEvent = procedure(Sender: TFtWindow; AX, AY: Integer) of object;
  TFtWindowKeyEvent       = procedure(Sender: TFtWindow; AKey: LongWord; AIsDown: Boolean) of object;
  TFtWindowGLDrawEvent    = procedure(Sender: TFtWindow; AWidth, AHeight: Integer) of object;
  TFtWindowCloseEvent     = function(Sender: TFtWindow): Boolean of object;

  { TFtWindow — High-level Window class }
  TFtWindow = class(TFtWidget)
  private
    FTitle: string;
    FOnResize: TFtWindowResizeEvent;
    FOnMouseDown: TFtWindowMouseEvent;
    FOnMouseUp: TFtWindowMouseEvent;
    FOnMouseMove: TFtWindowMouseMoveEvent;
    FOnKey: TFtWindowKeyEvent;
    FOnGLDraw: TFtWindowGLDrawEvent;
    FOnClose: TFtWindowCloseEvent;

    function  GetTitle: string;
    procedure SetTitle(const AValue: string);
    function  GetBorderless: Boolean;
    procedure SetBorderless(AValue: Boolean);
    function  GetSkipTaskbar: Boolean;
    procedure SetSkipTaskbar(AValue: Boolean);
    function  GetWindowType: TFtWindowType;
    procedure SetWindowType(AValue: TFtWindowType);
    function  GetBackgroundOpacity: Double;
    procedure SetBackgroundOpacity(AValue: Double);
    function  GetBackgroundBlur: Integer;
    procedure SetBackgroundBlur(AValue: Integer);
    function  GetHardwareAccelerated: Boolean;
    procedure SetHardwareAccelerated(AValue: Boolean);
    procedure SetSwapInterval(AValue: Integer);
    function  GetNativeHandle: Pointer;

    procedure SetOnResize(AValue: TFtWindowResizeEvent);
    procedure SetOnMouseDown(AValue: TFtWindowMouseEvent);
    procedure SetOnMouseUp(AValue: TFtWindowMouseEvent);
    procedure SetOnMouseMove(AValue: TFtWindowMouseMoveEvent);
    procedure SetOnKey(AValue: TFtWindowKeyEvent);
    procedure SetOnGLDraw(AValue: TFtWindowGLDrawEvent);
    procedure SetOnClose(AValue: TFtWindowCloseEvent);
  protected
    procedure DoResize(ANewWidth, ANewHeight: Integer); virtual;
    procedure DoMouseDown(AX, AY, AButton: Integer); virtual;
    procedure DoMouseUp(AX, AY, AButton: Integer); virtual;
    procedure DoMouseMove(AX, AY: Integer); virtual;
    procedure DoKey(AKey: LongWord; AIsDown: Boolean); virtual;
    procedure DoGLDraw(AWidth, AHeight: Integer); virtual;
    function  DoClose(): Boolean; virtual;
  public
    constructor Create(); reintroduce; overload;
    constructor Create(AWidth, AHeight: Integer; const ATitle: string = ''); reintroduce; overload;
    constructor CreateEGL(AWidth, AHeight: Integer; const ATitle: string = '');

    procedure Close();

    function  ShowModal(): Integer;
    procedure BringToFront();
    procedure GrabInput();
    procedure UngrabInput();
    procedure Repaint();

    procedure SetPosition(AX, AY: Integer);
    procedure GetPosition(out AX, AY: Integer);
    procedure SetLayout(ALayout: TFtWidget);
    procedure SetDirectGPUMode(AEnable: Boolean);
    function  MakeCurrent(): Boolean;
    procedure ReleaseCurrent();

    procedure SetStrutPartial(ALeft, ARight, ATop, ABottom,
                             ALeftStartY, ALeftEndY, ARightStartY, ARightEndY,
                             ATopStartX, ATopEndX, ABottomStartX, ABottomEndX: Integer);

    { Properties }
    property Title: string read GetTitle write SetTitle;
    property Borderless: Boolean read GetBorderless write SetBorderless;
    property SkipTaskbar: Boolean read GetSkipTaskbar write SetSkipTaskbar;
    property WindowType: TFtWindowType read GetWindowType write SetWindowType;
    property BackgroundOpacity: Double read GetBackgroundOpacity write SetBackgroundOpacity;
    property BackgroundBlur: Integer read GetBackgroundBlur write SetBackgroundBlur;
    property HardwareAccelerated: Boolean read GetHardwareAccelerated write SetHardwareAccelerated;
    property SwapInterval: Integer write SetSwapInterval;
    property NativeHandle: Pointer read GetNativeHandle;

    { Events }
    property OnResize: TFtWindowResizeEvent read FOnResize write SetOnResize;
    property OnMouseDown: TFtWindowMouseEvent read FOnMouseDown write SetOnMouseDown;
    property OnMouseUp: TFtWindowMouseEvent read FOnMouseUp write SetOnMouseUp;
    property OnMouseMove: TFtWindowMouseMoveEvent read FOnMouseMove write SetOnMouseMove;
    property OnKey: TFtWindowKeyEvent read FOnKey write SetOnKey;
    property OnGLDraw: TFtWindowGLDrawEvent read FOnGLDraw write SetOnGLDraw;
    property OnClose: TFtWindowCloseEvent read FOnClose write SetOnClose;
  end;

implementation

{ C Callbacks Dispatchers }

function WindowCloseDispatcher(AWindow: Pointer; AUserData: Pointer): cint32; cdecl;
var
  win: TFtWindow;
begin
  if AUserData <> nil then
  begin
    win := TFtWindow(AUserData);
    if not win.DoClose() then
      Exit(0);
  end;
  Result := 1;
end;

procedure WindowResizeDispatcher(AWindow: Pointer; ANewWidth, ANewHeight: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtWindow(AUserData).DoResize(ANewWidth, ANewHeight);
end;

procedure WindowMouseDownDispatcher(AWindow: Pointer; AX, AY, AButton: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtWindow(AUserData).DoMouseDown(AX, AY, AButton);
end;

procedure WindowMouseUpDispatcher(AWindow: Pointer; AX, AY, AButton: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtWindow(AUserData).DoMouseUp(AX, AY, AButton);
end;

procedure WindowMouseMoveDispatcher(AWindow: Pointer; AX, AY: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtWindow(AUserData).DoMouseMove(AX, AY);
end;

procedure WindowKeyDispatcher(AWindow: Pointer; AKey: cuint32; AIsDown: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtWindow(AUserData).DoKey(AKey, AIsDown <> 0);
end;

procedure WindowGLDrawDispatcher(AWindow: Pointer; AWidth, AHeight: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtWindow(AUserData).DoGLDraw(AWidth, AHeight);
end;

{ TFtWindow Implementation }

constructor TFtWindow.Create();
begin
  Create(800, 600, 'Floria Toolkit Window');
end;

constructor TFtWindow.Create(AWidth, AHeight: Integer; const ATitle: string = '');
var
  wHandle: Pointer;
begin
  inherited Create(nil);
  FTitle := ATitle;
  if Assigned(ft_window_create) then
    wHandle := ft_window_create(AWidth, AHeight, PChar(ATitle))
  else
    wHandle := nil;

  SetHandle(wHandle, True);
  if (wHandle <> nil) and Assigned(ft_window_on_close) then
    ft_window_on_close(wHandle, @WindowCloseDispatcher, Pointer(Self));
  if (wHandle <> nil) and Assigned(ft_window_on_resize) then
    ft_window_on_resize(wHandle, @WindowResizeDispatcher, Pointer(Self));
end;

constructor TFtWindow.CreateEGL(AWidth, AHeight: Integer; const ATitle: string = '');
var
  wHandle: Pointer;
begin
  inherited Create(nil);
  FTitle := ATitle;
  if Assigned(ft_egl_window_create) then
    wHandle := ft_egl_window_create(AWidth, AHeight, PChar(ATitle))
  else
    wHandle := nil;

  SetHandle(wHandle, True);
  if (wHandle <> nil) and Assigned(ft_window_on_close) then
    ft_window_on_close(wHandle, @WindowCloseDispatcher, Pointer(Self));
  if (wHandle <> nil) and Assigned(ft_window_on_resize) then
    ft_window_on_resize(wHandle, @WindowResizeDispatcher, Pointer(Self));
end;

procedure TFtWindow.Close();
begin
  if Handle <> nil then
    Hide();
end;

function TFtWindow.ShowModal(): Integer;
begin
  if (Handle <> nil) and Assigned(ft_window_show_modal) then
    Result := ft_window_show_modal(Handle)
  else
    Result := FT_MODAL_NONE;
end;

procedure TFtWindow.BringToFront();
begin
  if (Handle <> nil) and Assigned(ft_window_bring_to_front) then
    ft_window_bring_to_front(Handle);
end;

procedure TFtWindow.GrabInput();
begin
  if (Handle <> nil) and Assigned(ft_window_grab_input) then
    ft_window_grab_input(Handle);
end;

procedure TFtWindow.UngrabInput();
begin
  if (Handle <> nil) and Assigned(ft_window_ungrab_input) then
    ft_window_ungrab_input(Handle);
end;

procedure TFtWindow.Repaint();
begin
  if (Handle <> nil) and Assigned(ft_window_repaint) then
    ft_window_repaint(Handle);
end;

procedure TFtWindow.SetPosition(AX, AY: Integer);
begin
  if (Handle <> nil) and Assigned(ft_window_set_position) then
    ft_window_set_position(Handle, AX, AY);
end;

procedure TFtWindow.GetPosition(out AX, AY: Integer);
var
  cx, cy: cint32;
begin
  if (Handle <> nil) and Assigned(ft_window_get_position) then
  begin
    ft_window_get_position(Handle, cx, cy);
    AX := cx;
    AY := cy;
  end
  else
  begin
    AX := 0;
    AY := 0;
  end;
end;

procedure TFtWindow.SetLayout(ALayout: TFtWidget);
begin
  if (Handle <> nil) and Assigned(ft_window_set_layout) then
  begin
    if ALayout <> nil then
      ft_window_set_layout(Handle, ALayout.Handle)
    else
      ft_window_set_layout(Handle, nil);
  end;
end;

procedure TFtWindow.SetDirectGPUMode(AEnable: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_window_set_direct_gpu_mode) then
    ft_window_set_direct_gpu_mode(Handle, Ord(AEnable));
end;

function TFtWindow.MakeCurrent(): Boolean;
begin
  if (Handle <> nil) and Assigned(ft_window_make_current) then
    Result := (ft_window_make_current(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtWindow.ReleaseCurrent();
begin
  if (Handle <> nil) and Assigned(ft_window_release_current) then
    ft_window_release_current(Handle);
end;

procedure TFtWindow.SetStrutPartial(ALeft, ARight, ATop, ABottom,
                                   ALeftStartY, ALeftEndY, ARightStartY, ARightEndY,
                                   ATopStartX, ATopEndX, ABottomStartX, ABottomEndX: Integer);
begin
  if (Handle <> nil) and Assigned(ft_window_set_strut_partial) then
    ft_window_set_strut_partial(Handle, ALeft, ARight, ATop, ABottom,
                                ALeftStartY, ALeftEndY, ARightStartY, ARightEndY,
                                ATopStartX, ATopEndX, ABottomStartX, ABottomEndX);
end;

function TFtWindow.GetTitle: string;
begin
  Result := FTitle;
end;

procedure TFtWindow.SetTitle(const AValue: string);
begin
  FTitle := AValue;
  if (Handle <> nil) and Assigned(ft_window_set_title) then
    ft_window_set_title(Handle, PChar(AValue));
end;

function TFtWindow.GetBorderless: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_window_get_borderless) then
    Result := (ft_window_get_borderless(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtWindow.SetBorderless(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_window_set_borderless) then
    ft_window_set_borderless(Handle, Ord(AValue));
end;

function TFtWindow.GetSkipTaskbar: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_window_get_skip_taskbar) then
    Result := (ft_window_get_skip_taskbar(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtWindow.SetSkipTaskbar(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_window_set_skip_taskbar) then
    ft_window_set_skip_taskbar(Handle, Ord(AValue));
end;

function TFtWindow.GetWindowType: TFtWindowType;
begin
  if (Handle <> nil) and Assigned(ft_window_get_window_type) then
    Result := TFtWindowType(ft_window_get_window_type(Handle))
  else
    Result := ftwtNormal;
end;

procedure TFtWindow.SetWindowType(AValue: TFtWindowType);
begin
  if (Handle <> nil) and Assigned(ft_window_set_window_type) then
    ft_window_set_window_type(Handle, Ord(AValue));
end;

function TFtWindow.GetBackgroundOpacity: Double;
begin
  if (Handle <> nil) and Assigned(ft_window_get_background_opacity) then
    Result := ft_window_get_background_opacity(Handle)
  else
    Result := 1.0;
end;

procedure TFtWindow.SetBackgroundOpacity(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_window_set_background_opacity) then
    ft_window_set_background_opacity(Handle, AValue);
end;

function TFtWindow.GetBackgroundBlur: Integer;
begin
  if (Handle <> nil) and Assigned(ft_window_get_background_blur) then
    Result := ft_window_get_background_blur(Handle)
  else
    Result := 0;
end;

procedure TFtWindow.SetBackgroundBlur(AValue: Integer);
begin
  if (Handle <> nil) and Assigned(ft_window_set_background_blur) then
    ft_window_set_background_blur(Handle, AValue);
end;

function TFtWindow.GetHardwareAccelerated: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_window_is_hardware_accelerated) then
    Result := (ft_window_is_hardware_accelerated(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtWindow.SetHardwareAccelerated(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_window_set_hardware_accelerated) then
    ft_window_set_hardware_accelerated(Handle, Ord(AValue));
end;

procedure TFtWindow.SetSwapInterval(AValue: Integer);
begin
  if (Handle <> nil) and Assigned(ft_window_set_swap_interval) then
    ft_window_set_swap_interval(Handle, AValue);
end;

function TFtWindow.GetNativeHandle: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_window_get_native_handle) then
    Result := ft_window_get_native_handle(Handle)
  else
    Result := nil;
end;

procedure TFtWindow.SetOnResize(AValue: TFtWindowResizeEvent);
begin
  FOnResize := AValue;
  if (Handle <> nil) and Assigned(ft_window_on_resize) then
    ft_window_on_resize(Handle, @WindowResizeDispatcher, Self);
end;

procedure TFtWindow.SetOnMouseDown(AValue: TFtWindowMouseEvent);
begin
  FOnMouseDown := AValue;
  if (Handle <> nil) and Assigned(ft_window_on_mouse_down) then
    ft_window_on_mouse_down(Handle, @WindowMouseDownDispatcher, Self);
end;

procedure TFtWindow.SetOnMouseUp(AValue: TFtWindowMouseEvent);
begin
  FOnMouseUp := AValue;
  if (Handle <> nil) and Assigned(ft_window_on_mouse_up) then
    ft_window_on_mouse_up(Handle, @WindowMouseUpDispatcher, Self);
end;

procedure TFtWindow.SetOnMouseMove(AValue: TFtWindowMouseMoveEvent);
begin
  FOnMouseMove := AValue;
  if (Handle <> nil) and Assigned(ft_window_on_mouse_move) then
    ft_window_on_mouse_move(Handle, @WindowMouseMoveDispatcher, Self);
end;

procedure TFtWindow.SetOnKey(AValue: TFtWindowKeyEvent);
begin
  FOnKey := AValue;
  if (Handle <> nil) and Assigned(ft_window_on_key) then
    ft_window_on_key(Handle, @WindowKeyDispatcher, Self);
end;

procedure TFtWindow.SetOnGLDraw(AValue: TFtWindowGLDrawEvent);
begin
  FOnGLDraw := AValue;
  if (Handle <> nil) and Assigned(ft_window_on_gl_draw) then
    ft_window_on_gl_draw(Handle, @WindowGLDrawDispatcher, Self);
end;

procedure TFtWindow.DoResize(ANewWidth, ANewHeight: Integer);
begin
  Width := ANewWidth;
  Height := ANewHeight;
  if Assigned(FOnResize) then
    FOnResize(Self, ANewWidth, ANewHeight);
end;

procedure TFtWindow.DoMouseDown(AX, AY, AButton: Integer);
begin
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, AX, AY, AButton);
end;

procedure TFtWindow.DoMouseUp(AX, AY, AButton: Integer);
begin
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, AX, AY, AButton);
end;

procedure TFtWindow.DoMouseMove(AX, AY: Integer);
begin
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, AX, AY);
end;

procedure TFtWindow.DoKey(AKey: LongWord; AIsDown: Boolean);
begin
  if Assigned(FOnKey) then
    FOnKey(Self, AKey, AIsDown);
end;

procedure TFtWindow.DoGLDraw(AWidth, AHeight: Integer);
begin
  if Assigned(FOnGLDraw) then
    FOnGLDraw(Self, AWidth, AHeight);
end;

procedure TFtWindow.SetOnClose(AValue: TFtWindowCloseEvent);
begin
  FOnClose := AValue;
  if (Handle <> nil) and Assigned(ft_window_on_close) then
    ft_window_on_close(Handle, @WindowCloseDispatcher, Pointer(Self));
end;

function TFtWindow.DoClose(): Boolean;
begin
  if Assigned(FOnClose) then
    Result := FOnClose(Self)
  else
    Result := True;
end;

end.
