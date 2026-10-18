{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal Base Widget (TFtWidget)            }
{                                                                          }
{   Provides the foundational TFtWidget OOP class wrapping native FtWidget }
{   handles, geometry, focus, styling, hints, flexbox, and grid traits.    }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.widget;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ftpas.api, ftpas.types;

type
  { Forward Declarations }
  TFtWidget = class;

  { TFtWidget — Base class for all Floria Toolkit widgets }
  TFtWidget = class
  private
    FHandle: Pointer;
    FParent: TFtWidget;
    FChildren: TFPList;
    FOwnsHandle: Boolean;
    FVisible: Boolean;
    FTag: PtrInt;

    function  GetX: Integer;
    procedure SetX(AValue: Integer);
    function  GetY: Integer;
    procedure SetY(AValue: Integer);
    function  GetWidth: Integer;
    procedure SetWidth(AValue: Integer);
    function  GetHeight: Integer;
    procedure SetHeight(AValue: Integer);

    function  GetVisible: Boolean;
    procedure SetVisible(AValue: Boolean);
    function  GetEnabled: Boolean;
    procedure SetEnabled(AValue: Boolean);
    function  GetFocused: Boolean;
    procedure SetFocused(AValue: Boolean);
    function  GetFocusable: Boolean;
    procedure SetFocusable(AValue: Boolean);
    function  GetOpacity: Double;
    procedure SetOpacity(AValue: Double);

    function  GetStyleClass: string;
    procedure SetStyleClass(const AValue: string);
    function  GetStyleId: string;
    procedure SetStyleId(const AValue: string);
    function  GetStyle: string;
    procedure SetStyle(const AValue: string);
    function  GetFont: string;
    procedure SetFont(const AValue: string);

    function  GetHint: string;
    procedure SetHint(const AValue: string);
    function  GetEffectiveHint: string;
    function  GetShowHint: Boolean;
    procedure SetShowHint(AValue: Boolean);

    function  GetFlexGrow: Double;
    procedure SetFlexGrow(AValue: Double);
    function  GetFlexShrink: Double;
    procedure SetFlexShrink(AValue: Double);
    function  GetFlexBasis: Double;
    procedure SetFlexBasis(AValue: Double);
    function  GetAlignSelf: TFtAlignSelf;
    procedure SetAlignSelf(AValue: TFtAlignSelf);

    function  GetGridCol: Integer;
    function  GetGridRow: Integer;
    function  GetGridColSpan: Integer;
    function  GetGridRowSpan: Integer;

    function  GetContextMenuHandle: Pointer;
    procedure SetContextMenuHandle(AValue: Pointer);
  protected
    procedure SetHandle(AHandle: Pointer; AOwns: Boolean = True);
    procedure HandleNativeDestroyed();
  public
    constructor Create(AParent: TFtWidget); virtual;
    constructor Wrap(AHandle: Pointer; AParent: TFtWidget = nil; AOwnsHandle: Boolean = False);
    destructor Destroy; override;

    { Global Widget Registry }
    class procedure RegisterWidget(AWidget: TFtWidget);
    class procedure UnregisterWidget(AWidget: TFtWidget);
    class function  FindWidget(AHandle: Pointer): TFtWidget;

    { Visibility & Rendering }
    procedure Show(); virtual;
    procedure Hide(); virtual;
    procedure Invalidate(); virtual;
    procedure SetFocus(); virtual;

    { Geometry & Bounds }
    procedure SetBounds(AX, AY, AWidth, AHeight: Integer); virtual;
    procedure GetBounds(out AX, AY, AWidth, AHeight: Integer); virtual;
    function  GetParentRenderArea(out X, Y, W, H, Radius: Double): Boolean;

    { Micro-Flexbox Traits }
    procedure SetMargin(ALeft, ATop, ARight, ABottom: Integer);
    procedure SetMarginAll(AMargin: Integer);

    { 2D Grid Traits }
    procedure SetGridCell(ACol, ARow, AColSpan, ARowSpan: Integer);

    { Properties }
    property Handle: Pointer read FHandle;
    property Parent: TFtWidget read FParent;
    property Children: TFPList read FChildren;
    property OwnsHandle: Boolean read FOwnsHandle write FOwnsHandle;

    property X: Integer read GetX write SetX;
    property Y: Integer read GetY write SetY;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;

    property Visible: Boolean read GetVisible write SetVisible;
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property Focused: Boolean read GetFocused write SetFocused;
    property Focusable: Boolean read GetFocusable write SetFocusable;
    property Opacity: Double read GetOpacity write SetOpacity;

    property StyleClass: string read GetStyleClass write SetStyleClass;
    property StyleId: string read GetStyleId write SetStyleId;
    property Style: string read GetStyle write SetStyle;
    property Font: string read GetFont write SetFont;

    property Hint: string read GetHint write SetHint;
    property EffectiveHint: string read GetEffectiveHint;
    property ShowHint: Boolean read GetShowHint write SetShowHint;

    property FlexGrow: Double read GetFlexGrow write SetFlexGrow;
    property Tag: PtrInt read FTag write FTag;
    property FlexShrink: Double read GetFlexShrink write SetFlexShrink;
    property FlexBasis: Double read GetFlexBasis write SetFlexBasis;
    property AlignSelf: TFtAlignSelf read GetAlignSelf write SetAlignSelf;

    property GridCol: Integer read GetGridCol;
    property GridRow: Integer read GetGridRow;
    property GridColSpan: Integer read GetGridColSpan;
    property GridRowSpan: Integer read GetGridRowSpan;

    property ContextMenuHandle: Pointer read GetContextMenuHandle write SetContextMenuHandle;
  end;

implementation

{ Global Widget Registry Implementation }

type
  PWidgetEntry = ^TWidgetEntry;
  TWidgetEntry = record
    Handle: Pointer;
    Widget: TFtWidget;
  end;

var
  gRegistry: array of TWidgetEntry;
  gRegistryCount: Integer = 0;

class procedure TFtWidget.RegisterWidget(AWidget: TFtWidget);
var
  i: Integer;
begin
  if (AWidget = nil) or (AWidget.Handle = nil) then
    Exit;

  for i := 0 to gRegistryCount - 1 do
  begin
    if gRegistry[i].Handle = AWidget.Handle then
    begin
      gRegistry[i].Widget := AWidget;
      Exit;
    end;
  end;

  if gRegistryCount >= Length(gRegistry) then
    SetLength(gRegistry, (gRegistryCount + 1) * 2);

  gRegistry[gRegistryCount].Handle := AWidget.Handle;
  gRegistry[gRegistryCount].Widget := AWidget;
  Inc(gRegistryCount);
end;

class procedure TFtWidget.UnregisterWidget(AWidget: TFtWidget);
var
  i, j: Integer;
begin
  if (AWidget = nil) or (AWidget.Handle = nil) then
    Exit;

  for i := 0 to gRegistryCount - 1 do
  begin
    if gRegistry[i].Handle = AWidget.Handle then
    begin
      for j := i to gRegistryCount - 2 do
        gRegistry[j] := gRegistry[j + 1];
      Dec(gRegistryCount);
      Break;
    end;
  end;
end;

class function TFtWidget.FindWidget(AHandle: Pointer): TFtWidget;
var
  i: Integer;
begin
  if AHandle = nil then
    Exit(nil);

  for i := 0 to gRegistryCount - 1 do
  begin
    if gRegistry[i].Handle = AHandle then
      Exit(gRegistry[i].Widget);
  end;
  Result := nil;
end;

procedure NativeDestroyDispatcher(AWidget: Pointer; AUserData: Pointer); cdecl;
var
  w: TFtWidget;
begin
  w := TFtWidget.FindWidget(AWidget);
  if w <> nil then
    w.HandleNativeDestroyed();
end;

{ TFtWidget Implementation }

constructor TFtWidget.Create(AParent: TFtWidget);
begin
  inherited Create;
  FParent := AParent;
  FHandle := nil;
  FOwnsHandle := True;
  FVisible := True;
  FChildren := TFPList.Create;
  if FParent <> nil then
    FParent.FChildren.Add(Self);
end;

constructor TFtWidget.Wrap(AHandle: Pointer; AParent: TFtWidget = nil; AOwnsHandle: Boolean = False);
begin
  inherited Create;
  FParent := AParent;
  FHandle := AHandle;
  FOwnsHandle := AOwnsHandle;
  FVisible := True;
  FChildren := TFPList.Create;
  if FParent <> nil then
    FParent.FChildren.Add(Self);
  if FHandle <> nil then
  begin
    RegisterWidget(Self);
    if Assigned(ft_widget_on_destroy) then
      ft_widget_on_destroy(FHandle, @NativeDestroyDispatcher, Pointer(Self));
  end;
end;

destructor TFtWidget.Destroy;
var
  child: TFtWidget;
begin
  if FChildren <> nil then
  begin
    while FChildren.Count > 0 do
    begin
      child := TFtWidget(FChildren[FChildren.Count - 1]);
      FChildren.Delete(FChildren.Count - 1);
      child.FParent := nil;
      child.Free;
    end;
    FreeAndNil(FChildren);
  end;

  if FParent <> nil then
  begin
    if FParent.FChildren <> nil then
      FParent.FChildren.Remove(Self);
    FParent := nil;
  end;

  if FHandle <> nil then
  begin
    UnregisterWidget(Self);
    if Assigned(ft_widget_on_destroy) then
      ft_widget_on_destroy(FHandle, nil, nil);
    if FOwnsHandle and Assigned(ft_widget_is_valid) and (ft_widget_is_valid(FHandle) <> 0) then
    begin
      if Assigned(ft_widget_destroy) then
        ft_widget_destroy(FHandle);
    end;
    FHandle := nil;
  end;
  inherited Destroy;
end;

procedure TFtWidget.SetHandle(AHandle: Pointer; AOwns: Boolean = True);
begin
  if FHandle <> nil then
    UnregisterWidget(Self);

  FHandle := AHandle;
  FOwnsHandle := AOwns;

  if FHandle <> nil then
  begin
    RegisterWidget(Self);
    if Assigned(ft_widget_on_destroy) then
      ft_widget_on_destroy(FHandle, @NativeDestroyDispatcher, Pointer(Self));
  end;
end;

procedure TFtWidget.HandleNativeDestroyed();
begin
  UnregisterWidget(Self);
  FHandle := nil;
end;

procedure TFtWidget.Show();
begin
  if (FHandle <> nil) and Assigned(ft_widget_show) then
  begin
    ft_widget_show(FHandle);
    FVisible := True;
  end;
end;

procedure TFtWidget.Hide();
begin
  if (FHandle <> nil) and Assigned(ft_widget_hide) then
  begin
    ft_widget_hide(FHandle);
    FVisible := False;
  end;
end;

procedure TFtWidget.Invalidate();
begin
  if (FHandle <> nil) and Assigned(ft_widget_invalidate) then
    ft_widget_invalidate(FHandle);
end;

procedure TFtWidget.SetFocus();
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_focus) then
    ft_widget_set_focus(FHandle);
end;

procedure TFtWidget.SetBounds(AX, AY, AWidth, AHeight: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_bounds) then
    ft_widget_set_bounds(FHandle, AX, AY, AWidth, AHeight);
end;

procedure TFtWidget.GetBounds(out AX, AY, AWidth, AHeight: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_bounds) then
    ft_widget_get_bounds(FHandle, AX, AY, AWidth, AHeight)
  else
  begin
    AX := 0;
    AY := 0;
    AWidth := 0;
    AHeight := 0;
  end;
end;

function TFtWidget.GetParentRenderArea(out X, Y, W, H, Radius: Double): Boolean;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_parent_render_area) then
    Result := (ft_widget_get_parent_render_area(FHandle, X, Y, W, H, Radius) <> 0)
  else
    Result := False;
end;

procedure TFtWidget.SetMargin(ALeft, ATop, ARight, ABottom: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_margin) then
    ft_widget_set_margin(FHandle, ALeft, ATop, ARight, ABottom);
end;

procedure TFtWidget.SetMarginAll(AMargin: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_margin_all) then
    ft_widget_set_margin_all(FHandle, AMargin);
end;

procedure TFtWidget.SetGridCell(ACol, ARow, AColSpan, ARowSpan: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_grid_cell) then
    ft_widget_set_grid_cell(FHandle, ACol, ARow, AColSpan, ARowSpan);
end;

function TFtWidget.GetX: Integer;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_x) then
    Result := ft_widget_get_x(FHandle)
  else
    Result := 0;
end;

procedure TFtWidget.SetX(AValue: Integer);
begin
  SetBounds(AValue, Y, Width, Height);
end;

function TFtWidget.GetY: Integer;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_y) then
    Result := ft_widget_get_y(FHandle)
  else
    Result := 0;
end;

procedure TFtWidget.SetY(AValue: Integer);
begin
  SetBounds(X, AValue, Width, Height);
end;

function TFtWidget.GetWidth: Integer;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_width) then
    Result := ft_widget_get_width(FHandle)
  else
    Result := 0;
end;

procedure TFtWidget.SetWidth(AValue: Integer);
begin
  SetBounds(X, Y, AValue, Height);
end;

function TFtWidget.GetHeight: Integer;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_height) then
    Result := ft_widget_get_height(FHandle)
  else
    Result := 0;
end;

procedure TFtWidget.SetHeight(AValue: Integer);
begin
  SetBounds(X, Y, Width, AValue);
end;

function TFtWidget.GetVisible: Boolean;
begin
  Result := FVisible;
end;

procedure TFtWidget.SetVisible(AValue: Boolean);
begin
  if AValue then
    Show()
  else
    Hide();
end;

function TFtWidget.GetEnabled: Boolean;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_enabled) then
    Result := (ft_widget_get_enabled(FHandle) <> 0)
  else
    Result := True;
end;

procedure TFtWidget.SetEnabled(AValue: Boolean);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_enabled) then
    ft_widget_set_enabled(FHandle, Ord(AValue));
end;

function TFtWidget.GetFocused: Boolean;
begin
  if (FHandle <> nil) and Assigned(ft_widget_has_focus) then
    Result := (ft_widget_has_focus(FHandle) <> 0)
  else
    Result := False;
end;

procedure TFtWidget.SetFocused(AValue: Boolean);
begin
  if AValue then
    SetFocus();
end;

function TFtWidget.GetFocusable: Boolean;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_focusable) then
    Result := (ft_widget_get_focusable(FHandle) <> 0)
  else
    Result := True;
end;

procedure TFtWidget.SetFocusable(AValue: Boolean);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_focusable) then
    ft_widget_set_focusable(FHandle, Ord(AValue));
end;

function TFtWidget.GetOpacity: Double;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_opacity) then
    Result := ft_widget_get_opacity(FHandle)
  else
    Result := 1.0;
end;

procedure TFtWidget.SetOpacity(AValue: Double);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_opacity) then
    ft_widget_set_opacity(FHandle, AValue);
end;

function TFtWidget.GetStyleClass: string;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_style_class) then
    Result := StrPas(ft_widget_get_style_class(FHandle))
  else
    Result := '';
end;

procedure TFtWidget.SetStyleClass(const AValue: string);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_style_class) then
    ft_widget_set_style_class(FHandle, PChar(AValue));
end;

function TFtWidget.GetStyleId: string;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_style_id) then
    Result := StrPas(ft_widget_get_style_id(FHandle))
  else
    Result := '';
end;

procedure TFtWidget.SetStyleId(const AValue: string);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_style_id) then
    ft_widget_set_style_id(FHandle, PChar(AValue));
end;

function TFtWidget.GetStyle: string;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_style) then
    Result := StrPas(ft_widget_get_style(FHandle))
  else
    Result := '';
end;

procedure TFtWidget.SetStyle(const AValue: string);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_style) then
    ft_widget_set_style(FHandle, PChar(AValue));
end;

function TFtWidget.GetFont: string;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_font) then
    Result := StrPas(ft_widget_get_font(FHandle))
  else
    Result := '';
end;

procedure TFtWidget.SetFont(const AValue: string);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_font) then
    ft_widget_set_font(FHandle, PChar(AValue));
end;

function TFtWidget.GetHint: string;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_hint) then
    Result := StrPas(ft_widget_get_hint(FHandle))
  else
    Result := '';
end;

procedure TFtWidget.SetHint(const AValue: string);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_hint) then
    ft_widget_set_hint(FHandle, PChar(AValue));
end;

function TFtWidget.GetEffectiveHint: string;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_effective_hint) then
    Result := StrPas(ft_widget_get_effective_hint(FHandle))
  else
    Result := '';
end;

function TFtWidget.GetShowHint: Boolean;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_show_hint) then
    Result := (ft_widget_get_show_hint(FHandle) <> 0)
  else
    Result := True;
end;

procedure TFtWidget.SetShowHint(AValue: Boolean);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_show_hint) then
    ft_widget_set_show_hint(FHandle, Ord(AValue));
end;

function TFtWidget.GetFlexGrow: Double;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_flex_grow) then
    Result := ft_widget_get_flex_grow(FHandle)
  else
    Result := 0.0;
end;

procedure TFtWidget.SetFlexGrow(AValue: Double);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_flex_grow) then
    ft_widget_set_flex_grow(FHandle, AValue);
end;

function TFtWidget.GetFlexShrink: Double;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_flex_shrink) then
    Result := ft_widget_get_flex_shrink(FHandle)
  else
    Result := 1.0;
end;

procedure TFtWidget.SetFlexShrink(AValue: Double);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_flex_shrink) then
    ft_widget_set_flex_shrink(FHandle, AValue);
end;

function TFtWidget.GetFlexBasis: Double;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_flex_basis) then
    Result := ft_widget_get_flex_basis(FHandle)
  else
    Result := -1.0;
end;

procedure TFtWidget.SetFlexBasis(AValue: Double);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_flex_basis) then
    ft_widget_set_flex_basis(FHandle, AValue);
end;

function TFtWidget.GetAlignSelf: TFtAlignSelf;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_align_self) then
    Result := TFtAlignSelf(ft_widget_get_align_self(FHandle))
  else
    Result := ftasAuto;
end;

procedure TFtWidget.SetAlignSelf(AValue: TFtAlignSelf);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_align_self) then
    ft_widget_set_align_self(FHandle, Ord(AValue));
end;

function TFtWidget.GetGridCol: Integer;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_grid_col) then
    Result := ft_widget_get_grid_col(FHandle)
  else
    Result := 0;
end;

function TFtWidget.GetGridRow: Integer;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_grid_row) then
    Result := ft_widget_get_grid_row(FHandle)
  else
    Result := 0;
end;

function TFtWidget.GetGridColSpan: Integer;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_grid_col_span) then
    Result := ft_widget_get_grid_col_span(FHandle)
  else
    Result := 1;
end;

function TFtWidget.GetGridRowSpan: Integer;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_grid_row_span) then
    Result := ft_widget_get_grid_row_span(FHandle)
  else
    Result := 1;
end;

function TFtWidget.GetContextMenuHandle: Pointer;
begin
  if (FHandle <> nil) and Assigned(ft_widget_get_context_menu) then
    Result := ft_widget_get_context_menu(FHandle)
  else
    Result := nil;
end;

procedure TFtWidget.SetContextMenuHandle(AValue: Pointer);
begin
  if (FHandle <> nil) and Assigned(ft_widget_set_context_menu) then
    ft_widget_set_context_menu(FHandle, AValue);
end;

initialization
  SetLength(gRegistry, 32);

finalization
  SetLength(gRegistry, 0);

end.
