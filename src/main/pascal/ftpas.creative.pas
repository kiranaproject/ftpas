{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal Creative & Canvas Widgets          }
{                                                                          }
{   Provides TFtDrawingArea (interactive vector canvas), TFtRuler,         }
{   TFtNumberScrubber, and TFtCamera2D pan/zoom viewport camera.           }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.creative;

{$mode objfpc}{$H+}

interface

uses
  ctypes, Classes, SysUtils, ftpas.api, ftpas.types, ftpas.canvas, ftpas.widget;

type
  { Forward Declarations }
  TFtDrawingArea = class;
  TFtRuler = class;
  TFtNumberScrubber = class;
  TFtCamera2D = class;

  { Event Signatures }
  TFtDrawingPaintEvent  = procedure(Sender: TFtDrawingArea; Canvas: TFtCanvas) of object;
  TFtDrawingMouseEvent  = procedure(Sender: TFtDrawingArea; X, Y, Button: Integer) of object;
  TFtDrawingMouseMoveEvent = procedure(Sender: TFtDrawingArea; X, Y: Integer) of object;
  TFtDrawingWheelEvent  = procedure(Sender: TFtDrawingArea; X, Y, DeltaX, DeltaY: Integer) of object;
  TFtDrawingKeyEvent    = procedure(Sender: TFtDrawingArea; KeySym, State: LongWord) of object;
  TFtDrawingResizeEvent = procedure(Sender: TFtDrawingArea; NewWidth, NewHeight: Integer) of object;

  TFtRulerGuideEvent    = procedure(Sender: TFtRuler; WorldPos: Double) of object;
  TFtScrubberChangeEvent= procedure(Sender: TFtNumberScrubber; NewValue: Double) of object;

  { TFtDrawingArea — Interactive vector canvas widget }
  TFtDrawingArea = class(TFtWidget)
  private
    FOnPaint: TFtDrawingPaintEvent;
    FOnMouseDown: TFtDrawingMouseEvent;
    FOnMouseUp: TFtDrawingMouseEvent;
    FOnMouseMove: TFtDrawingMouseMoveEvent;
    FOnMouseWheel: TFtDrawingWheelEvent;
    FOnMouseEnter: TFtDrawingMouseMoveEvent;
    FOnMouseLeave: TFtDrawingMouseMoveEvent;
    FOnKeyDown: TFtDrawingKeyEvent;
    FOnKeyUp: TFtDrawingKeyEvent;
    FOnResize: TFtDrawingResizeEvent;

    function  GetCursor: TFtCursorType;
    procedure SetCursor(AValue: TFtCursorType);
    procedure SetClipToBounds(AValue: Boolean);

    procedure SetOnPaint(AValue: TFtDrawingPaintEvent);
    procedure SetOnMouseDown(AValue: TFtDrawingMouseEvent);
    procedure SetOnMouseUp(AValue: TFtDrawingMouseEvent);
    procedure SetOnMouseMove(AValue: TFtDrawingMouseMoveEvent);
    procedure SetOnMouseWheel(AValue: TFtDrawingWheelEvent);
    procedure SetOnMouseEnter(AValue: TFtDrawingMouseMoveEvent);
    procedure SetOnMouseLeave(AValue: TFtDrawingMouseMoveEvent);
    procedure SetOnKeyDown(AValue: TFtDrawingKeyEvent);
    procedure SetOnKeyUp(AValue: TFtDrawingKeyEvent);
    procedure SetOnResize(AValue: TFtDrawingResizeEvent);
  protected
    procedure DoPaint(ACanvas: TFtCanvas); virtual;
    procedure DoMouseDown(AX, AY, AButton: Integer); virtual;
    procedure DoMouseUp(AX, AY, AButton: Integer); virtual;
    procedure DoMouseMove(AX, AY: Integer); virtual;
    procedure DoMouseWheel(AX, AY, ADeltaX, ADeltaY: Integer); virtual;
    procedure DoMouseEnter(AX, AY: Integer); virtual;
    procedure DoMouseLeave(AX, AY: Integer); virtual;
    procedure DoKeyDown(AKeySym, AState: LongWord); virtual;
    procedure DoKeyUp(AKeySym, AState: LongWord); virtual;
    procedure DoResize(ANewWidth, ANewHeight: Integer); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer); reintroduce;

    property Cursor: TFtCursorType read GetCursor write SetCursor;
    property ClipToBounds: Boolean write SetClipToBounds;

    property OnPaint: TFtDrawingPaintEvent read FOnPaint write SetOnPaint;
    property OnMouseDown: TFtDrawingMouseEvent read FOnMouseDown write SetOnMouseDown;
    property OnMouseUp: TFtDrawingMouseEvent read FOnMouseUp write SetOnMouseUp;
    property OnMouseMove: TFtDrawingMouseMoveEvent read FOnMouseMove write SetOnMouseMove;
    property OnMouseWheel: TFtDrawingWheelEvent read FOnMouseWheel write SetOnMouseWheel;
    property OnMouseEnter: TFtDrawingMouseMoveEvent read FOnMouseEnter write SetOnMouseEnter;
    property OnMouseLeave: TFtDrawingMouseMoveEvent read FOnMouseLeave write SetOnMouseLeave;
    property OnKeyDown: TFtDrawingKeyEvent read FOnKeyDown write SetOnKeyDown;
    property OnKeyUp: TFtDrawingKeyEvent read FOnKeyUp write SetOnKeyUp;
    property OnResize: TFtDrawingResizeEvent read FOnResize write SetOnResize;
  end;

  { TFtRuler — Precision measurement ruler with guide ticks and dragging }
  TFtRuler = class(TFtWidget)
  private
    FOnCreateGuide: TFtRulerGuideEvent;

    function  GetUnitKind: TFtRulerUnit;
    procedure SetUnitKind(AValue: TFtRulerUnit);
    procedure SetPointerPosition(AValue: Double);
    procedure SetShowPointer(AValue: Boolean);
    procedure SetThickness(AValue: Integer);

    procedure SetOnCreateGuide(AValue: TFtRulerGuideEvent);
  protected
    procedure DoCreateGuide(AWorldPos: Double); virtual;
  public
    constructor Create(AParent: TFtWidget; AOrientation: TFtRulerOrientation;
                       AX, AY, AW, AH: Integer); reintroduce;

    procedure SetOriginAndScale(AOrigin, AScale: Double);

    property PointerPosition: Double write SetPointerPosition;
    property UnitKind: TFtRulerUnit read GetUnitKind write SetUnitKind;
    property ShowPointer: Boolean write SetShowPointer;
    property Thickness: Integer write SetThickness;

    property OnCreateGuide: TFtRulerGuideEvent read FOnCreateGuide write SetOnCreateGuide;
  end;

  { TFtNumberScrubber — Numeric drag scrubber control }
  TFtNumberScrubber = class(TFtWidget)
  private
    FOnChange: TFtScrubberChangeEvent;

    function  GetValue: Double;
    procedure SetValue(AValue: Double);
    procedure SetStep(AValue: Double);
    procedure SetDecimals(AValue: Integer);
    procedure SetSuffix(const AValue: string);
    procedure SetPrefix(const AValue: string);

    procedure SetOnChange(AValue: TFtScrubberChangeEvent);
  protected
    procedure DoChange(ANewValue: Double); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const ALabel: string = ''); reintroduce;

    procedure SetRange(AMinVal, AMaxVal: Double);

    property Value: Double read GetValue write SetValue;
    property Step: Double write SetStep;
    property Decimals: Integer write SetDecimals;
    property Suffix: string write SetSuffix;
    property Prefix: string write SetPrefix;

    property OnChange: TFtScrubberChangeEvent read FOnChange write SetOnChange;
  end;

  { TFtCamera2D — Viewport pan, zoom and pivot camera }
  TFtCamera2D = class
  private
    FHandle: Pointer;
    function  GetZoom: Double;
    procedure SetZoom(AValue: Double);
    function  GetRotation: Double;
    procedure SetRotation(AValue: Double);
  public
    constructor Create(AMinZoom: Double = 0.05; AMaxZoom: Double = 32.0);
    destructor Destroy; override;

    procedure Reset();
    procedure WorldToScreen(AWX, AWY: Double; out ASX, ASY: Double);
    procedure ScreenToWorld(ASX, ASY: Double; out AWX, AWY: Double);
    procedure ZoomAt(APivotSX, APivotSY, ADeltaFactor: Double);
    procedure SetZoomAt(APivotSX, APivotSY, ANewZoom: Double);
    procedure PanBy(ADeltaSX, ADeltaSY: Double);
    procedure FitRect(AWX, AWY, AWW, AWH, AViewW, AViewH, AMargin: Double);

    procedure GetPan(out APanX, APanY: Double);
    procedure SetPan(APanX, APanY: Double);

    property Handle: Pointer read FHandle;
    property Zoom: Double read GetZoom write SetZoom;
    property Rotation: Double read GetRotation write SetRotation;
  end;

implementation

{ C Callback Dispatchers }

procedure DrawingPaintDispatcher(AWidget: Pointer; ACanvas: Pointer; AUserData: Pointer); cdecl;
var
  cv: TFtCanvas;
begin
  if (AUserData <> nil) and (ACanvas <> nil) then
  begin
    cv := TFtCanvas.Create(ACanvas);
    try
      TFtDrawingArea(AUserData).DoPaint(cv);
    finally
      cv.Free;
    end;
  end;
end;

procedure DrawingMouseDownDispatcher(AWidget: Pointer; AX, AY, AButton: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtDrawingArea(AUserData).DoMouseDown(AX, AY, AButton);
end;

procedure DrawingMouseUpDispatcher(AWidget: Pointer; AX, AY, AButton: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtDrawingArea(AUserData).DoMouseUp(AX, AY, AButton);
end;

procedure DrawingMouseMoveDispatcher(AWidget: Pointer; AX, AY: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtDrawingArea(AUserData).DoMouseMove(AX, AY);
end;

procedure DrawingWheelDispatcher(AWidget: Pointer; AX, AY, ADeltaX, ADeltaY: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtDrawingArea(AUserData).DoMouseWheel(AX, AY, ADeltaX, ADeltaY);
end;

procedure DrawingMouseEnterDispatcher(AWidget: Pointer; AX, AY: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtDrawingArea(AUserData).DoMouseEnter(AX, AY);
end;

procedure DrawingMouseLeaveDispatcher(AWidget: Pointer; AX, AY: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtDrawingArea(AUserData).DoMouseLeave(AX, AY);
end;

procedure DrawingKeyDownDispatcher(AWidget: Pointer; AKeySym, AState: cuint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtDrawingArea(AUserData).DoKeyDown(AKeySym, AState);
end;

procedure DrawingKeyUpDispatcher(AWidget: Pointer; AKeySym, AState: cuint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtDrawingArea(AUserData).DoKeyUp(AKeySym, AState);
end;

procedure DrawingResizeDispatcher(AWidget: Pointer; ANewW, ANewH: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtDrawingArea(AUserData).DoResize(ANewW, ANewH);
end;

procedure RulerGuideDispatcher(AWidget: Pointer; AWorldPos: Double; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtRuler(AUserData).DoCreateGuide(AWorldPos);
end;

procedure ScrubberChangeDispatcher(AWidget: Pointer; ANewValue: Double; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtNumberScrubber(AUserData).DoChange(ANewValue);
end;

{ TFtDrawingArea }

constructor TFtDrawingArea.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_drawingarea_create) then
    h := ft_drawingarea_create(pHandle, AX, AY, AW, AH)
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtDrawingArea.GetCursor: TFtCursorType;
begin
  if (Handle <> nil) and Assigned(ft_drawingarea_get_cursor) then
    Result := TFtCursorType(ft_drawingarea_get_cursor(Handle))
  else
    Result := ftcDefault;
end;

procedure TFtDrawingArea.SetCursor(AValue: TFtCursorType);
begin
  if (Handle <> nil) and Assigned(ft_drawingarea_set_cursor) then
    ft_drawingarea_set_cursor(Handle, Ord(AValue));
end;

procedure TFtDrawingArea.SetClipToBounds(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_drawingarea_set_clip_to_bounds) then
    ft_drawingarea_set_clip_to_bounds(Handle, Ord(AValue));
end;

procedure TFtDrawingArea.SetOnPaint(AValue: TFtDrawingPaintEvent);
begin
  FOnPaint := AValue;
  if (Handle <> nil) and Assigned(ft_drawingarea_on_paint) then
    ft_drawingarea_on_paint(Handle, @DrawingPaintDispatcher, Self);
end;

procedure TFtDrawingArea.SetOnMouseDown(AValue: TFtDrawingMouseEvent);
begin
  FOnMouseDown := AValue;
  if (Handle <> nil) and Assigned(ft_drawingarea_on_mouse_down) then
    ft_drawingarea_on_mouse_down(Handle, @DrawingMouseDownDispatcher, Self);
end;

procedure TFtDrawingArea.SetOnMouseUp(AValue: TFtDrawingMouseEvent);
begin
  FOnMouseUp := AValue;
  if (Handle <> nil) and Assigned(ft_drawingarea_on_mouse_up) then
    ft_drawingarea_on_mouse_up(Handle, @DrawingMouseUpDispatcher, Self);
end;

procedure TFtDrawingArea.SetOnMouseMove(AValue: TFtDrawingMouseMoveEvent);
begin
  FOnMouseMove := AValue;
  if (Handle <> nil) and Assigned(ft_drawingarea_on_mouse_move) then
    ft_drawingarea_on_mouse_move(Handle, @DrawingMouseMoveDispatcher, Self);
end;

procedure TFtDrawingArea.SetOnMouseWheel(AValue: TFtDrawingWheelEvent);
begin
  FOnMouseWheel := AValue;
  if (Handle <> nil) and Assigned(ft_drawingarea_on_mouse_wheel) then
    ft_drawingarea_on_mouse_wheel(Handle, @DrawingWheelDispatcher, Self);
end;

procedure TFtDrawingArea.SetOnMouseEnter(AValue: TFtDrawingMouseMoveEvent);
begin
  FOnMouseEnter := AValue;
  if (Handle <> nil) and Assigned(ft_drawingarea_on_mouse_enter) then
    ft_drawingarea_on_mouse_enter(Handle, @DrawingMouseEnterDispatcher, Self);
end;

procedure TFtDrawingArea.SetOnMouseLeave(AValue: TFtDrawingMouseMoveEvent);
begin
  FOnMouseLeave := AValue;
  if (Handle <> nil) and Assigned(ft_drawingarea_on_mouse_leave) then
    ft_drawingarea_on_mouse_leave(Handle, @DrawingMouseLeaveDispatcher, Self);
end;

procedure TFtDrawingArea.SetOnKeyDown(AValue: TFtDrawingKeyEvent);
begin
  FOnKeyDown := AValue;
  if (Handle <> nil) and Assigned(ft_drawingarea_on_key_down) then
    ft_drawingarea_on_key_down(Handle, @DrawingKeyDownDispatcher, Self);
end;

procedure TFtDrawingArea.SetOnKeyUp(AValue: TFtDrawingKeyEvent);
begin
  FOnKeyUp := AValue;
  if (Handle <> nil) and Assigned(ft_drawingarea_on_key_up) then
    ft_drawingarea_on_key_up(Handle, @DrawingKeyUpDispatcher, Self);
end;

procedure TFtDrawingArea.SetOnResize(AValue: TFtDrawingResizeEvent);
begin
  FOnResize := AValue;
  if (Handle <> nil) and Assigned(ft_drawingarea_on_resize) then
    ft_drawingarea_on_resize(Handle, @DrawingResizeDispatcher, Self);
end;

procedure TFtDrawingArea.DoPaint(ACanvas: TFtCanvas);
begin
  if Assigned(FOnPaint) then
    FOnPaint(Self, ACanvas);
end;

procedure TFtDrawingArea.DoMouseDown(AX, AY, AButton: Integer);
begin
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, AX, AY, AButton);
end;

procedure TFtDrawingArea.DoMouseUp(AX, AY, AButton: Integer);
begin
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, AX, AY, AButton);
end;

procedure TFtDrawingArea.DoMouseMove(AX, AY: Integer);
begin
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, AX, AY);
end;

procedure TFtDrawingArea.DoMouseWheel(AX, AY, ADeltaX, ADeltaY: Integer);
begin
  if Assigned(FOnMouseWheel) then
    FOnMouseWheel(Self, AX, AY, ADeltaX, ADeltaY);
end;

procedure TFtDrawingArea.DoMouseEnter(AX, AY: Integer);
begin
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self, AX, AY);
end;

procedure TFtDrawingArea.DoMouseLeave(AX, AY: Integer);
begin
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self, AX, AY);
end;

procedure TFtDrawingArea.DoKeyDown(AKeySym, AState: LongWord);
begin
  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, AKeySym, AState);
end;

procedure TFtDrawingArea.DoKeyUp(AKeySym, AState: LongWord);
begin
  if Assigned(FOnKeyUp) then
    FOnKeyUp(Self, AKeySym, AState);
end;

procedure TFtDrawingArea.DoResize(ANewWidth, ANewHeight: Integer);
begin
  if Assigned(FOnResize) then
    FOnResize(Self, ANewWidth, ANewHeight);
end;

{ TFtRuler }

constructor TFtRuler.Create(AParent: TFtWidget; AOrientation: TFtRulerOrientation;
                            AX, AY, AW, AH: Integer);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_ruler_create) then
    h := ft_ruler_create(pHandle, Ord(AOrientation), AX, AY, AW, AH)
  else
    h := nil;
  SetHandle(h, True);
end;

procedure TFtRuler.SetOriginAndScale(AOrigin, AScale: Double);
begin
  if (Handle <> nil) and Assigned(ft_ruler_set_origin_and_scale) then
    ft_ruler_set_origin_and_scale(Handle, AOrigin, AScale);
end;

procedure TFtRuler.SetPointerPosition(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_ruler_set_pointer_position) then
    ft_ruler_set_pointer_position(Handle, AValue);
end;

function TFtRuler.GetUnitKind: TFtRulerUnit;
begin
  if (Handle <> nil) and Assigned(ft_ruler_get_unit) then
    Result := TFtRulerUnit(ft_ruler_get_unit(Handle))
  else
    Result := ftruPixels;
end;

procedure TFtRuler.SetUnitKind(AValue: TFtRulerUnit);
begin
  if (Handle <> nil) and Assigned(ft_ruler_set_unit) then
    ft_ruler_set_unit(Handle, Ord(AValue));
end;

procedure TFtRuler.SetShowPointer(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_ruler_set_show_pointer) then
    ft_ruler_set_show_pointer(Handle, Ord(AValue));
end;

procedure TFtRuler.SetThickness(AValue: Integer);
begin
  if (Handle <> nil) and Assigned(ft_ruler_set_thickness) then
    ft_ruler_set_thickness(Handle, AValue);
end;

procedure TFtRuler.SetOnCreateGuide(AValue: TFtRulerGuideEvent);
begin
  FOnCreateGuide := AValue;
  if (Handle <> nil) and Assigned(ft_ruler_on_create_guide) then
    ft_ruler_on_create_guide(Handle, @RulerGuideDispatcher, Self);
end;

procedure TFtRuler.DoCreateGuide(AWorldPos: Double);
begin
  if Assigned(FOnCreateGuide) then
    FOnCreateGuide(Self, AWorldPos);
end;

{ TFtNumberScrubber }

constructor TFtNumberScrubber.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const ALabel: string = '');
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_numberscrubber_create) then
    h := ft_numberscrubber_create(pHandle, AX, AY, AW, AH, PChar(ALabel))
  else
    h := nil;
  SetHandle(h, True);
end;

procedure TFtNumberScrubber.SetRange(AMinVal, AMaxVal: Double);
begin
  if (Handle <> nil) and Assigned(ft_numberscrubber_set_range) then
    ft_numberscrubber_set_range(Handle, AMinVal, AMaxVal);
end;

function TFtNumberScrubber.GetValue: Double;
begin
  if (Handle <> nil) and Assigned(ft_numberscrubber_get_value) then
    Result := ft_numberscrubber_get_value(Handle)
  else
    Result := 0.0;
end;

procedure TFtNumberScrubber.SetValue(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_numberscrubber_set_value) then
    ft_numberscrubber_set_value(Handle, AValue);
end;

procedure TFtNumberScrubber.SetStep(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_numberscrubber_set_step) then
    ft_numberscrubber_set_step(Handle, AValue);
end;

procedure TFtNumberScrubber.SetDecimals(AValue: Integer);
begin
  if (Handle <> nil) and Assigned(ft_numberscrubber_set_decimals) then
    ft_numberscrubber_set_decimals(Handle, AValue);
end;

procedure TFtNumberScrubber.SetSuffix(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_numberscrubber_set_suffix) then
    ft_numberscrubber_set_suffix(Handle, PChar(AValue));
end;

procedure TFtNumberScrubber.SetPrefix(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_numberscrubber_set_prefix) then
    ft_numberscrubber_set_prefix(Handle, PChar(AValue));
end;

procedure TFtNumberScrubber.SetOnChange(AValue: TFtScrubberChangeEvent);
begin
  FOnChange := AValue;
  if (Handle <> nil) and Assigned(ft_numberscrubber_on_change) then
    ft_numberscrubber_on_change(Handle, @ScrubberChangeDispatcher, Self);
end;

procedure TFtNumberScrubber.DoChange(ANewValue: Double);
begin
  if Assigned(FOnChange) then
    FOnChange(Self, ANewValue);
end;

{ TFtCamera2D }

constructor TFtCamera2D.Create(AMinZoom: Double = 0.05; AMaxZoom: Double = 32.0);
begin
  inherited Create;
  if Assigned(ft_camera2d_create) then
    FHandle := ft_camera2d_create(AMinZoom, AMaxZoom)
  else
    FHandle := nil;
end;

destructor TFtCamera2D.Destroy;
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_destroy) then
  begin
    ft_camera2d_destroy(FHandle);
    FHandle := nil;
  end;
  inherited Destroy;
end;

procedure TFtCamera2D.Reset();
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_reset) then
    ft_camera2d_reset(FHandle);
end;

procedure TFtCamera2D.WorldToScreen(AWX, AWY: Double; out ASX, ASY: Double);
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_world_to_screen) then
    ft_camera2d_world_to_screen(FHandle, AWX, AWY, ASX, ASY)
  else
  begin
    ASX := AWX;
    ASY := AWY;
  end;
end;

procedure TFtCamera2D.ScreenToWorld(ASX, ASY: Double; out AWX, AWY: Double);
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_screen_to_world) then
    ft_camera2d_screen_to_world(FHandle, ASX, ASY, AWX, AWY)
  else
  begin
    AWX := ASX;
    AWY := ASY;
  end;
end;

procedure TFtCamera2D.ZoomAt(APivotSX, APivotSY, ADeltaFactor: Double);
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_zoom_at) then
    ft_camera2d_zoom_at(FHandle, APivotSX, APivotSY, ADeltaFactor);
end;

procedure TFtCamera2D.SetZoomAt(APivotSX, APivotSY, ANewZoom: Double);
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_set_zoom_at) then
    ft_camera2d_set_zoom_at(FHandle, APivotSX, APivotSY, ANewZoom);
end;

procedure TFtCamera2D.PanBy(ADeltaSX, ADeltaSY: Double);
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_pan_by) then
    ft_camera2d_pan_by(FHandle, ADeltaSX, ADeltaSY);
end;

procedure TFtCamera2D.FitRect(AWX, AWY, AWW, AWH, AViewW, AViewH, AMargin: Double);
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_fit_rect) then
    ft_camera2d_fit_rect(FHandle, AWX, AWY, AWW, AWH, AViewW, AViewH, AMargin);
end;

function TFtCamera2D.GetZoom: Double;
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_get_zoom) then
    Result := ft_camera2d_get_zoom(FHandle)
  else
    Result := 1.0;
end;

procedure TFtCamera2D.SetZoom(AValue: Double);
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_set_zoom) then
    ft_camera2d_set_zoom(FHandle, AValue);
end;

procedure TFtCamera2D.GetPan(out APanX, APanY: Double);
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_get_pan) then
    ft_camera2d_get_pan(FHandle, APanX, APanY)
  else
  begin
    APanX := 0.0;
    APanY := 0.0;
  end;
end;

procedure TFtCamera2D.SetPan(APanX, APanY: Double);
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_set_pan) then
    ft_camera2d_set_pan(FHandle, APanX, APanY);
end;

function TFtCamera2D.GetRotation: Double;
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_get_rotation) then
    Result := ft_camera2d_get_rotation(FHandle)
  else
    Result := 0.0;
end;

procedure TFtCamera2D.SetRotation(AValue: Double);
begin
  if (FHandle <> nil) and Assigned(ft_camera2d_set_rotation) then
    ft_camera2d_set_rotation(FHandle, AValue);
end;

end.
