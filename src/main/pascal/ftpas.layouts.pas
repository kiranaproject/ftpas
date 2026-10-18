{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal Layouts & Containers               }
{                                                                          }
{   Provides OOP wrappers for containers, flexboxes (HBox, VBox, Spacer),  }
{   floating action bars, 2D grids, form grids, splitters, and notebooks.  }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.layouts;

{$mode objfpc}{$H+}

interface

uses
  ctypes, Classes, SysUtils, ftpas.api, ftpas.types, ftpas.canvas, ftpas.widget;

type
  { Forward Declarations }
  TFtContainer = class;
  TFtFlexBox = class;
  TFtHBox = class;
  TFtVBox = class;
  TFtSpacer = class;
  TFtFloatingBar = class;
  TFtGrid = class;
  TFtFormGrid = class;
  TFtSplitter = class;
  TFtTabPage = class;
  TFtNotebook = class;

  { Event Signatures }
  TFtContainerScrollEvent    = procedure(Sender: TFtContainer; Value: Double) of object;
  TFtSplitterPositionEvent   = procedure(Sender: TFtSplitter; Position: Double) of object;
  TFtNotebookTabChangeEvent  = procedure(Sender: TFtNotebook; NewIndex, OldIndex: Integer) of object;

  { TFtContainer — Scrollable viewport / frame }
  TFtContainer = class(TFtWidget)
  private
    FOnScroll: TFtContainerScrollEvent;

    function  GetScrollBarMode: TFtScrollBarMode;
    procedure SetScrollBarMode(AValue: TFtScrollBarMode);
    function  GetScrollX: Double;
    function  GetScrollY: Double;
    function  GetCornerRadius: Double;
    procedure SetCornerRadius(AValue: Double);
    function  GetBackdropBlur: Double;
    procedure SetBackdropBlur(AValue: Double);
    function  GetDrawFrame: Boolean;
    procedure SetDrawFrame(AValue: Boolean);
    function  GetDrawFocusRing: Boolean;
    procedure SetDrawFocusRing(AValue: Boolean);
    function  GetAutoContentSize: Boolean;
    procedure SetAutoContentSize(AValue: Boolean);
    function  GetInnerRadius: Double;
    function  GetEffectiveCornerRadius: Double;

    procedure SetOnScroll(AValue: TFtContainerScrollEvent);
  protected
    procedure DoScroll(AValue: Double); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer); reintroduce;

    procedure SetContentSize(AWidth, AHeight: Double);
    procedure GetContentSize(out AWidth, AHeight: Double);
    procedure SetScrollPos(AScrollX, AScrollY: Double);
    procedure SetPadding(APadX, APadY: Double);
    procedure GetClientRect(out AX, AY, AW, AH: Double);
    procedure GetRenderArea(out AX, AY, AW, AH, ARadius: Double);
    procedure UpdateScrollbars();

    property ScrollBarMode: TFtScrollBarMode read GetScrollBarMode write SetScrollBarMode;
    property ScrollX: Double read GetScrollX;
    property ScrollY: Double read GetScrollY;
    property CornerRadius: Double read GetCornerRadius write SetCornerRadius;
    property BackdropBlur: Double read GetBackdropBlur write SetBackdropBlur;
    property DrawFrame: Boolean read GetDrawFrame write SetDrawFrame;
    property DrawFocusRing: Boolean read GetDrawFocusRing write SetDrawFocusRing;
    property AutoContentSize: Boolean read GetAutoContentSize write SetAutoContentSize;
    property InnerRadius: Double read GetInnerRadius;
    property EffectiveCornerRadius: Double read GetEffectiveCornerRadius;

    property OnScroll: TFtContainerScrollEvent read FOnScroll write SetOnScroll;
  end;

  { TFtFlexBox — Micro-Flexbox layout container }
  TFtFlexBox = class(TFtWidget)
  private
    function  GetDirection: TFtFlexDirection;
    procedure SetDirection(AValue: TFtFlexDirection);
    function  GetWrap: TFtFlexWrap;
    procedure SetWrap(AValue: TFtFlexWrap);
    function  GetJustifyContent: TFtJustifyContent;
    procedure SetJustifyContent(AValue: TFtJustifyContent);
    function  GetAlignItems: TFtAlignItems;
    procedure SetAlignItems(AValue: TFtAlignItems);
    function  GetGap: Double;
    procedure SetGap(AValue: Double);
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer;
                       ADirection: TFtFlexDirection = ftfdRow); reintroduce;

    procedure UpdateLayout();
    function  AddSplitter(): TFtWidget;
    procedure SetPadding(APadX, APadY: Double);

    property Direction: TFtFlexDirection read GetDirection write SetDirection;
    property Wrap: TFtFlexWrap read GetWrap write SetWrap;
    property JustifyContent: TFtJustifyContent read GetJustifyContent write SetJustifyContent;
    property AlignItems: TFtAlignItems read GetAlignItems write SetAlignItems;
    property Gap: Double read GetGap write SetGap;
  end;

  { TFtHBox — Horizontal flexbox }
  TFtHBox = class(TFtFlexBox)
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer); reintroduce;
  end;

  { TFtVBox — Vertical flexbox }
  TFtVBox = class(TFtFlexBox)
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer); reintroduce;
  end;

  { TFtSpacer — Flex expander }
  TFtSpacer = class(TFtWidget)
  public
    constructor Create(AParent: TFtWidget); reintroduce;
  end;

  { TFtFloatingBar — Floating capsule / HUD overlay bar }
  TFtFloatingBar = class(TFtWidget)
  private
    function  GetAnchor: TFtAnchorMode;
    procedure SetAnchor(AValue: TFtAnchorMode);
    function  GetAutoAnchor: Boolean;
    procedure SetAutoAnchor(AValue: Boolean);
  public
    constructor Create(AParent: TFtWidget; AAnchorMode: TFtAnchorMode; AWidth, AHeight: Integer); reintroduce;

    procedure SetMargins(AMarginX, AMarginY: Double);
    procedure GetMargins(out AMarginX, AMarginY: Double);
    procedure UpdateAnchor();

    property Anchor: TFtAnchorMode read GetAnchor write SetAnchor;
    property AutoAnchor: Boolean read GetAutoAnchor write SetAutoAnchor;
  end;

  { TFtGrid — 2D CSS-style grid layout }
  TFtGrid = class(TFtWidget)
  private
    function  GetColumnCount: Integer;
    procedure SetColumnCount(AValue: Integer);
    function  GetRowCount: Integer;
    procedure SetRowCount(AValue: Integer);
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer); reintroduce;

    procedure SetGaps(AColGap, ARowGap: Double);
    procedure SetColumnFixed(ACol: Integer; AWidth: Double);
    procedure SetColumnFlex(ACol: Integer; AWeight: Double);
    procedure SetColumnAuto(ACol: Integer);
    procedure SetRowFixed(ARow: Integer; AHeight: Double);
    procedure SetRowFlex(ARow: Integer; AWeight: Double);
    procedure SetRowAuto(ARow: Integer);
    procedure SetColumnTemplate(const ATemplate: string);
    procedure SetRowTemplate(const ATemplate: string);
    procedure AddWidget(AWidget: TFtWidget; ACol, ARow, AColSpan, ARowSpan: Integer);
    procedure UpdateLayout();

    property ColumnCount: Integer read GetColumnCount write SetColumnCount;
    property RowCount: Integer read GetRowCount write SetRowCount;
  end;

  { TFtFormGrid — Form layout with label-control pairs }
  TFtFormGrid = class(TFtWidget)
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer); reintroduce;

    function  AddRow(const ALabel: string; AControl: TFtWidget): TFtWidget;
    procedure AddRowWidgets(ALabelWidget, AControlWidget: TFtWidget);
    procedure AddSpanned(AControl: TFtWidget);
    function  AddSection(const ATitle: string): TFtWidget;
  end;

  { TFtSplitter — Adjustable dual-pane container }
  TFtSplitter = class(TFtWidget)
  private
    FOnPositionChange: TFtSplitterPositionEvent;

    function  GetOrientation: TFtSplitterOrientation;
    procedure SetOrientation(AValue: TFtSplitterOrientation);
    function  GetPos: Double;
    procedure SetPos(AValue: Double);
    procedure SetRatio(AValue: Double);
    function  GetSplitterSize: Double;
    procedure SetSplitterSize(AValue: Double);
    function  GetMinPane1Size: Double;
    function  GetMinPane2Size: Double;

    procedure SetOnPositionChange(AValue: TFtSplitterPositionEvent);
  protected
    procedure DoPositionChange(APosition: Double); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer;
                       AOrientation: TFtSplitterOrientation = ftspoHorizontal); reintroduce;

    procedure SetPanes(APane1, APane2: TFtWidget);
    procedure SetMinSizes(AMinPane1, AMinPane2: Double);

    property Orientation: TFtSplitterOrientation read GetOrientation write SetOrientation;
    property Pos: Double read GetPos write SetPos;
    property Ratio: Double write SetRatio;
    property SplitterSize: Double read GetSplitterSize write SetSplitterSize;
    property MinPane1Size: Double read GetMinPane1Size;
    property MinPane2Size: Double read GetMinPane2Size;

    property OnPositionChange: TFtSplitterPositionEvent read FOnPositionChange write SetOnPositionChange;
  end;

  { TFtTabPage — Individual tab inside TFtNotebook }
  TFtTabPage = class
  private
    FHandle: Pointer;
    function  GetTitle: string;
    procedure SetTitle(const AValue: string);
    function  GetCloseable: Boolean;
    procedure SetCloseable(AValue: Boolean);
  public
    constructor Wrap(AHandle: Pointer);

    procedure SetIcon(ABitmap: TFtBitmap);
    function  GetIcon(): TFtBitmap;

    property Handle: Pointer read FHandle;
    property Title: string read GetTitle write SetTitle;
    property Closeable: Boolean read GetCloseable write SetCloseable;
  end;

  { TFtNotebook — Multi-tab notebook container }
  TFtNotebook = class(TFtWidget)
  private
    FOnTabChange: TFtNotebookTabChangeEvent;

    function  GetPageCount: Integer;
    function  GetActiveIndex: Integer;
    procedure SetActiveIndex(AValue: Integer);
    function  GetTabHeight: Double;
    procedure SetTabHeight(AValue: Double);

    procedure SetOnTabChange(AValue: TFtNotebookTabChangeEvent);
  protected
    procedure DoTabChange(ANewIndex, AOldIndex: Integer); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer); reintroduce;

    function  AddTab(const ATitle: string; ACloseable: Boolean = False): TFtTabPage;
    procedure RemoveTab(AIndex: Integer);
    procedure ClearTabs();
    function  GetPage(AIndex: Integer): TFtTabPage;

    property PageCount: Integer read GetPageCount;
    property ActiveIndex: Integer read GetActiveIndex write SetActiveIndex;
    property TabHeight: Double read GetTabHeight write SetTabHeight;

    property OnTabChange: TFtNotebookTabChangeEvent read FOnTabChange write SetOnTabChange;
  end;

  { TFtSizeGroup — Size grouping to enforce uniform widget dimensions }
  TFtSizeGroup = class
  private
    FHandle: Pointer;
    FMode: TFtSizeGroupMode;
  public
    constructor Create(AMode: TFtSizeGroupMode = ftsgHorizontal);
    destructor Destroy; override;

    procedure Add(AWidget: TFtWidget);
    procedure Remove(AWidget: TFtWidget);
    procedure Synchronize();

    property Handle: Pointer read FHandle;
    property Mode: TFtSizeGroupMode read FMode;
  end;

implementation

{ C Callback Dispatchers }

procedure ContainerScrollDispatcher(AWidget: Pointer; AValue: Double; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtContainer(AUserData).DoScroll(AValue);
end;

procedure SplitterPosDispatcher(ASplitter: Pointer; APosition: Double; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtSplitter(AUserData).DoPositionChange(APosition);
end;

procedure TabChangeDispatcher(ANotebook: Pointer; ANewIndex, AOldIndex: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtNotebook(AUserData).DoTabChange(ANewIndex, AOldIndex);
end;

{ TFtContainer }

constructor TFtContainer.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_container_create) then
    h := ft_container_create(pHandle, AX, AY, AW, AH)
  else
    h := nil;
  SetHandle(h, True);
end;

procedure TFtContainer.SetContentSize(AWidth, AHeight: Double);
begin
  if (Handle <> nil) and Assigned(ft_container_set_content_size) then
    ft_container_set_content_size(Handle, AWidth, AHeight);
end;

procedure TFtContainer.GetContentSize(out AWidth, AHeight: Double);
begin
  if (Handle <> nil) and Assigned(ft_container_get_content_size) then
    ft_container_get_content_size(Handle, AWidth, AHeight)
  else
  begin
    AWidth := 0;
    AHeight := 0;
  end;
end;

procedure TFtContainer.SetScrollPos(AScrollX, AScrollY: Double);
begin
  if (Handle <> nil) and Assigned(ft_container_set_scroll_pos) then
    ft_container_set_scroll_pos(Handle, AScrollX, AScrollY);
end;

procedure TFtContainer.SetPadding(APadX, APadY: Double);
begin
  if (Handle <> nil) and Assigned(ft_container_set_padding) then
    ft_container_set_padding(Handle, APadX, APadY);
end;

procedure TFtContainer.GetClientRect(out AX, AY, AW, AH: Double);
begin
  if (Handle <> nil) and Assigned(ft_container_get_client_rect) then
    ft_container_get_client_rect(Handle, AX, AY, AW, AH)
  else
  begin
    AX := 0;
    AY := 0;
    AW := 0;
    AH := 0;
  end;
end;

procedure TFtContainer.GetRenderArea(out AX, AY, AW, AH, ARadius: Double);
begin
  if (Handle <> nil) and Assigned(ft_container_get_render_area) then
    ft_container_get_render_area(Handle, AX, AY, AW, AH, ARadius)
  else
  begin
    AX := 0;
    AY := 0;
    AW := 0;
    AH := 0;
    ARadius := 0;
  end;
end;

procedure TFtContainer.UpdateScrollbars();
begin
  if (Handle <> nil) and Assigned(ft_container_update_scrollbars) then
    ft_container_update_scrollbars(Handle);
end;

function TFtContainer.GetScrollBarMode: TFtScrollBarMode;
begin
  if (Handle <> nil) and Assigned(ft_container_get_scrollbar_mode) then
    Result := TFtScrollBarMode(ft_container_get_scrollbar_mode(Handle))
  else
    Result := ftsbmNone;
end;

procedure TFtContainer.SetScrollBarMode(AValue: TFtScrollBarMode);
begin
  if (Handle <> nil) and Assigned(ft_container_set_scrollbar_mode) then
    ft_container_set_scrollbar_mode(Handle, Ord(AValue));
end;

function TFtContainer.GetScrollX: Double;
begin
  if (Handle <> nil) and Assigned(ft_container_get_scroll_x) then
    Result := ft_container_get_scroll_x(Handle)
  else
    Result := 0.0;
end;

function TFtContainer.GetScrollY: Double;
begin
  if (Handle <> nil) and Assigned(ft_container_get_scroll_y) then
    Result := ft_container_get_scroll_y(Handle)
  else
    Result := 0.0;
end;

function TFtContainer.GetCornerRadius: Double;
begin
  if (Handle <> nil) and Assigned(ft_container_get_corner_radius) then
    Result := ft_container_get_corner_radius(Handle)
  else
    Result := -1.0;
end;

procedure TFtContainer.SetCornerRadius(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_container_set_corner_radius) then
    ft_container_set_corner_radius(Handle, AValue);
end;

function TFtContainer.GetBackdropBlur: Double;
begin
  if (Handle <> nil) and Assigned(ft_container_get_backdrop_blur) then
    Result := ft_container_get_backdrop_blur(Handle)
  else
    Result := 0.0;
end;

procedure TFtContainer.SetBackdropBlur(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_container_set_backdrop_blur) then
    ft_container_set_backdrop_blur(Handle, AValue);
end;

function TFtContainer.GetDrawFrame: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_container_get_draw_frame) then
    Result := (ft_container_get_draw_frame(Handle) <> 0)
  else
    Result := True;
end;

procedure TFtContainer.SetDrawFrame(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_container_set_draw_frame) then
    ft_container_set_draw_frame(Handle, Ord(AValue));
end;

function TFtContainer.GetDrawFocusRing: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_container_get_draw_focus_ring) then
    Result := (ft_container_get_draw_focus_ring(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtContainer.SetDrawFocusRing(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_container_set_draw_focus_ring) then
    ft_container_set_draw_focus_ring(Handle, Ord(AValue));
end;

function TFtContainer.GetAutoContentSize: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_container_get_auto_content_size) then
    Result := (ft_container_get_auto_content_size(Handle) <> 0)
  else
    Result := True;
end;

procedure TFtContainer.SetAutoContentSize(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_container_set_auto_content_size) then
    ft_container_set_auto_content_size(Handle, Ord(AValue));
end;

function TFtContainer.GetInnerRadius: Double;
begin
  if (Handle <> nil) and Assigned(ft_container_get_inner_radius) then
    Result := ft_container_get_inner_radius(Handle)
  else
    Result := 0.0;
end;

function TFtContainer.GetEffectiveCornerRadius: Double;
begin
  if (Handle <> nil) and Assigned(ft_container_get_effective_corner_radius) then
    Result := ft_container_get_effective_corner_radius(Handle)
  else
    Result := 0.0;
end;

procedure TFtContainer.SetOnScroll(AValue: TFtContainerScrollEvent);
begin
  FOnScroll := AValue;
  if (Handle <> nil) and Assigned(ft_container_on_scroll) then
    ft_container_on_scroll(Handle, @ContainerScrollDispatcher, Self);
end;

procedure TFtContainer.DoScroll(AValue: Double);
begin
  if Assigned(FOnScroll) then
    FOnScroll(Self, AValue);
end;

{ TFtFlexBox }

constructor TFtFlexBox.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer;
                              ADirection: TFtFlexDirection = ftfdRow);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_flexbox_create) then
    h := ft_flexbox_create(pHandle, AX, AY, AW, AH, Ord(ADirection))
  else
    h := nil;
  SetHandle(h, True);
end;

procedure TFtFlexBox.UpdateLayout();
begin
  if (Handle <> nil) and Assigned(ft_flexbox_update_layout) then
    ft_flexbox_update_layout(Handle);
end;

function TFtFlexBox.AddSplitter(): TFtWidget;
var
  sHandle: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_flexbox_add_splitter) then
  begin
    sHandle := ft_flexbox_add_splitter(Handle);
    Result := TFtWidget.Wrap(sHandle, Self, False);
  end
  else
    Result := nil;
end;

procedure TFtFlexBox.SetPadding(APadX, APadY: Double);
begin
  if (Handle <> nil) and Assigned(ft_container_set_padding) then
    ft_container_set_padding(Handle, APadX, APadY);
end;

function TFtFlexBox.GetDirection: TFtFlexDirection;
begin
  if (Handle <> nil) and Assigned(ft_flexbox_get_direction) then
    Result := TFtFlexDirection(ft_flexbox_get_direction(Handle))
  else
    Result := ftfdRow;
end;

procedure TFtFlexBox.SetDirection(AValue: TFtFlexDirection);
begin
  if (Handle <> nil) and Assigned(ft_flexbox_set_direction) then
    ft_flexbox_set_direction(Handle, Ord(AValue));
end;

function TFtFlexBox.GetWrap: TFtFlexWrap;
begin
  if (Handle <> nil) and Assigned(ft_flexbox_get_wrap) then
    Result := TFtFlexWrap(ft_flexbox_get_wrap(Handle))
  else
    Result := ftfwNoWrap;
end;

procedure TFtFlexBox.SetWrap(AValue: TFtFlexWrap);
begin
  if (Handle <> nil) and Assigned(ft_flexbox_set_wrap) then
    ft_flexbox_set_wrap(Handle, Ord(AValue));
end;

function TFtFlexBox.GetJustifyContent: TFtJustifyContent;
begin
  if (Handle <> nil) and Assigned(ft_flexbox_get_justify_content) then
    Result := TFtJustifyContent(ft_flexbox_get_justify_content(Handle))
  else
    Result := ftjcStart;
end;

procedure TFtFlexBox.SetJustifyContent(AValue: TFtJustifyContent);
begin
  if (Handle <> nil) and Assigned(ft_flexbox_set_justify_content) then
    ft_flexbox_set_justify_content(Handle, Ord(AValue));
end;

function TFtFlexBox.GetAlignItems: TFtAlignItems;
begin
  if (Handle <> nil) and Assigned(ft_flexbox_get_align_items) then
    Result := TFtAlignItems(ft_flexbox_get_align_items(Handle))
  else
    Result := ftaiStretch;
end;

procedure TFtFlexBox.SetAlignItems(AValue: TFtAlignItems);
begin
  if (Handle <> nil) and Assigned(ft_flexbox_set_align_items) then
    ft_flexbox_set_align_items(Handle, Ord(AValue));
end;

function TFtFlexBox.GetGap: Double;
begin
  if (Handle <> nil) and Assigned(ft_flexbox_get_gap) then
    Result := ft_flexbox_get_gap(Handle)
  else
    Result := 0.0;
end;

procedure TFtFlexBox.SetGap(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_flexbox_set_gap) then
    ft_flexbox_set_gap(Handle, AValue);
end;

{ TFtHBox }

constructor TFtHBox.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer);
begin
  inherited Create(AParent, AX, AY, AW, AH, ftfdRow);
end;

{ TFtVBox }

constructor TFtVBox.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer);
begin
  inherited Create(AParent, AX, AY, AW, AH, ftfdColumn);
end;

{ TFtSpacer }

constructor TFtSpacer.Create(AParent: TFtWidget);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_spacer_create) then
    h := ft_spacer_create(pHandle)
  else
    h := nil;
  SetHandle(h, True);
end;

{ TFtFloatingBar }

constructor TFtFloatingBar.Create(AParent: TFtWidget; AAnchorMode: TFtAnchorMode; AWidth, AHeight: Integer);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_floating_bar_create) then
    h := ft_floating_bar_create(pHandle, Ord(AAnchorMode), AWidth, AHeight)
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtFloatingBar.GetAnchor: TFtAnchorMode;
begin
  if (Handle <> nil) and Assigned(ft_floating_bar_get_anchor) then
    Result := TFtAnchorMode(ft_floating_bar_get_anchor(Handle))
  else
    Result := ftamBottomCenter;
end;

procedure TFtFloatingBar.SetAnchor(AValue: TFtAnchorMode);
begin
  if (Handle <> nil) and Assigned(ft_floating_bar_set_anchor) then
    ft_floating_bar_set_anchor(Handle, Ord(AValue));
end;

procedure TFtFloatingBar.SetMargins(AMarginX, AMarginY: Double);
begin
  if (Handle <> nil) and Assigned(ft_floating_bar_set_margins) then
    ft_floating_bar_set_margins(Handle, AMarginX, AMarginY);
end;

procedure TFtFloatingBar.GetMargins(out AMarginX, AMarginY: Double);
begin
  if (Handle <> nil) and Assigned(ft_floating_bar_get_margins) then
    ft_floating_bar_get_margins(Handle, AMarginX, AMarginY)
  else
  begin
    AMarginX := 24.0;
    AMarginY := 24.0;
  end;
end;

function TFtFloatingBar.GetAutoAnchor: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_floating_bar_get_auto_anchor) then
    Result := (ft_floating_bar_get_auto_anchor(Handle) <> 0)
  else
    Result := True;
end;

procedure TFtFloatingBar.SetAutoAnchor(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_floating_bar_set_auto_anchor) then
    ft_floating_bar_set_auto_anchor(Handle, Ord(AValue));
end;

procedure TFtFloatingBar.UpdateAnchor();
begin
  if (Handle <> nil) and Assigned(ft_floating_bar_update_anchor) then
    ft_floating_bar_update_anchor(Handle);
end;

{ TFtGrid }

constructor TFtGrid.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_grid_create) then
    h := ft_grid_create(pHandle, AX, AY, AW, AH)
  else
    h := nil;
  SetHandle(h, True);
end;

procedure TFtGrid.SetGaps(AColGap, ARowGap: Double);
begin
  if (Handle <> nil) and Assigned(ft_grid_set_gaps) then
    ft_grid_set_gaps(Handle, AColGap, ARowGap);
end;

procedure TFtGrid.SetColumnFixed(ACol: Integer; AWidth: Double);
begin
  if (Handle <> nil) and Assigned(ft_grid_set_column_fixed) then
    ft_grid_set_column_fixed(Handle, ACol, AWidth);
end;

procedure TFtGrid.SetColumnFlex(ACol: Integer; AWeight: Double);
begin
  if (Handle <> nil) and Assigned(ft_grid_set_column_flex) then
    ft_grid_set_column_flex(Handle, ACol, AWeight);
end;

procedure TFtGrid.SetColumnAuto(ACol: Integer);
begin
  if (Handle <> nil) and Assigned(ft_grid_set_column_auto) then
    ft_grid_set_column_auto(Handle, ACol);
end;

procedure TFtGrid.SetRowFixed(ARow: Integer; AHeight: Double);
begin
  if (Handle <> nil) and Assigned(ft_grid_set_row_fixed) then
    ft_grid_set_row_fixed(Handle, ARow, AHeight);
end;

procedure TFtGrid.SetRowFlex(ARow: Integer; AWeight: Double);
begin
  if (Handle <> nil) and Assigned(ft_grid_set_row_flex) then
    ft_grid_set_row_flex(Handle, ARow, AWeight);
end;

procedure TFtGrid.SetRowAuto(ARow: Integer);
begin
  if (Handle <> nil) and Assigned(ft_grid_set_row_auto) then
    ft_grid_set_row_auto(Handle, ARow);
end;

procedure TFtGrid.SetColumnTemplate(const ATemplate: string);
begin
  if (Handle <> nil) and Assigned(ft_grid_set_column_template) then
    ft_grid_set_column_template(Handle, PChar(ATemplate));
end;

procedure TFtGrid.SetRowTemplate(const ATemplate: string);
begin
  if (Handle <> nil) and Assigned(ft_grid_set_row_template) then
    ft_grid_set_row_template(Handle, PChar(ATemplate));
end;

procedure TFtGrid.AddWidget(AWidget: TFtWidget; ACol, ARow, AColSpan, ARowSpan: Integer);
begin
  if (Handle <> nil) and (AWidget <> nil) and (AWidget.Handle <> nil) and Assigned(ft_grid_add_widget) then
    ft_grid_add_widget(Handle, AWidget.Handle, ACol, ARow, AColSpan, ARowSpan);
end;

procedure TFtGrid.UpdateLayout();
begin
  if (Handle <> nil) and Assigned(ft_grid_update_layout) then
    ft_grid_update_layout(Handle);
end;

function TFtGrid.GetColumnCount: Integer;
begin
  if (Handle <> nil) and Assigned(ft_grid_get_column_count) then
    Result := ft_grid_get_column_count(Handle)
  else
    Result := 1;
end;

procedure TFtGrid.SetColumnCount(AValue: Integer);
begin
  if (Handle <> nil) and Assigned(ft_grid_set_column_count) then
    ft_grid_set_column_count(Handle, AValue);
end;

function TFtGrid.GetRowCount: Integer;
begin
  if (Handle <> nil) and Assigned(ft_grid_get_row_count) then
    Result := ft_grid_get_row_count(Handle)
  else
    Result := 1;
end;

procedure TFtGrid.SetRowCount(AValue: Integer);
begin
  if (Handle <> nil) and Assigned(ft_grid_set_row_count) then
    ft_grid_set_row_count(Handle, AValue);
end;

{ TFtFormGrid }

constructor TFtFormGrid.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_form_grid_create) then
    h := ft_form_grid_create(pHandle, AX, AY, AW, AH)
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtFormGrid.AddRow(const ALabel: string; AControl: TFtWidget): TFtWidget;
var
  cHandle, rHandle: Pointer;
begin
  if AControl <> nil then cHandle := AControl.Handle else cHandle := nil;
  if (Handle <> nil) and Assigned(ft_form_grid_add_row) then
  begin
    rHandle := ft_form_grid_add_row(Handle, PChar(ALabel), cHandle);
    Result := TFtWidget.Wrap(rHandle, Self, False);
  end
  else
    Result := nil;
end;

procedure TFtFormGrid.AddRowWidgets(ALabelWidget, AControlWidget: TFtWidget);
var
  lh, ch: Pointer;
begin
  if ALabelWidget <> nil then lh := ALabelWidget.Handle else lh := nil;
  if AControlWidget <> nil then ch := AControlWidget.Handle else ch := nil;
  if (Handle <> nil) and Assigned(ft_form_grid_add_row_widgets) then
    ft_form_grid_add_row_widgets(Handle, lh, ch);
end;

procedure TFtFormGrid.AddSpanned(AControl: TFtWidget);
var
  ch: Pointer;
begin
  if AControl <> nil then ch := AControl.Handle else ch := nil;
  if (Handle <> nil) and Assigned(ft_form_grid_add_spanned) then
    ft_form_grid_add_spanned(Handle, ch);
end;

function TFtFormGrid.AddSection(const ATitle: string): TFtWidget;
var
  sHandle: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_form_grid_add_section) then
  begin
    sHandle := ft_form_grid_add_section(Handle, PChar(ATitle));
    Result := TFtWidget.Wrap(sHandle, Self, False);
  end
  else
    Result := nil;
end;

{ TFtSplitter }

constructor TFtSplitter.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer;
                               AOrientation: TFtSplitterOrientation = ftspoHorizontal);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_splitter_create) then
    h := ft_splitter_create(pHandle, AX, AY, AW, AH, Ord(AOrientation))
  else
    h := nil;
  SetHandle(h, True);
end;

procedure TFtSplitter.SetPanes(APane1, APane2: TFtWidget);
var
  h1, h2: Pointer;
begin
  if APane1 <> nil then h1 := APane1.Handle else h1 := nil;
  if APane2 <> nil then h2 := APane2.Handle else h2 := nil;
  if (Handle <> nil) and Assigned(ft_splitter_set_panes) then
    ft_splitter_set_panes(Handle, h1, h2);
end;

procedure TFtSplitter.SetMinSizes(AMinPane1, AMinPane2: Double);
begin
  if (Handle <> nil) and Assigned(ft_splitter_set_min_sizes) then
    ft_splitter_set_min_sizes(Handle, AMinPane1, AMinPane2);
end;

function TFtSplitter.GetOrientation: TFtSplitterOrientation;
begin
  if (Handle <> nil) and Assigned(ft_splitter_get_orientation) then
    Result := TFtSplitterOrientation(ft_splitter_get_orientation(Handle))
  else
    Result := ftspoHorizontal;
end;

procedure TFtSplitter.SetOrientation(AValue: TFtSplitterOrientation);
begin
  if (Handle <> nil) and Assigned(ft_splitter_set_orientation) then
    ft_splitter_set_orientation(Handle, Ord(AValue));
end;

function TFtSplitter.GetPos: Double;
begin
  if (Handle <> nil) and Assigned(ft_splitter_get_pos) then
    Result := ft_splitter_get_pos(Handle)
  else
    Result := 0.0;
end;

procedure TFtSplitter.SetPos(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_splitter_set_pos) then
    ft_splitter_set_pos(Handle, AValue);
end;

procedure TFtSplitter.SetRatio(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_splitter_set_ratio) then
    ft_splitter_set_ratio(Handle, AValue);
end;

function TFtSplitter.GetSplitterSize: Double;
begin
  if (Handle <> nil) and Assigned(ft_splitter_get_splitter_size) then
    Result := ft_splitter_get_splitter_size(Handle)
  else
    Result := 6.0;
end;

procedure TFtSplitter.SetSplitterSize(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_splitter_set_splitter_size) then
    ft_splitter_set_splitter_size(Handle, AValue);
end;

function TFtSplitter.GetMinPane1Size: Double;
begin
  if (Handle <> nil) and Assigned(ft_splitter_get_min_pane1_size) then
    Result := ft_splitter_get_min_pane1_size(Handle)
  else
    Result := 50.0;
end;

function TFtSplitter.GetMinPane2Size: Double;
begin
  if (Handle <> nil) and Assigned(ft_splitter_get_min_pane2_size) then
    Result := ft_splitter_get_min_pane2_size(Handle)
  else
    Result := 50.0;
end;

procedure TFtSplitter.SetOnPositionChange(AValue: TFtSplitterPositionEvent);
begin
  FOnPositionChange := AValue;
  if (Handle <> nil) and Assigned(ft_splitter_on_position_change) then
    ft_splitter_on_position_change(Handle, @SplitterPosDispatcher, Self);
end;

procedure TFtSplitter.DoPositionChange(APosition: Double);
begin
  if Assigned(FOnPositionChange) then
    FOnPositionChange(Self, APosition);
end;

{ TFtTabPage }

constructor TFtTabPage.Wrap(AHandle: Pointer);
begin
  inherited Create;
  FHandle := AHandle;
end;

function TFtTabPage.GetTitle: string;
begin
  if (FHandle <> nil) and Assigned(ft_tab_page_get_title) then
    Result := StrPas(ft_tab_page_get_title(FHandle))
  else
    Result := '';
end;

procedure TFtTabPage.SetTitle(const AValue: string);
begin
  if (FHandle <> nil) and Assigned(ft_tab_page_set_title) then
    ft_tab_page_set_title(FHandle, PChar(AValue));
end;

function TFtTabPage.GetCloseable: Boolean;
begin
  if (FHandle <> nil) and Assigned(ft_tab_page_get_closeable) then
    Result := (ft_tab_page_get_closeable(FHandle) <> 0)
  else
    Result := False;
end;

procedure TFtTabPage.SetCloseable(AValue: Boolean);
begin
  if (FHandle <> nil) and Assigned(ft_tab_page_set_closeable) then
    ft_tab_page_set_closeable(FHandle, Ord(AValue));
end;

procedure TFtTabPage.SetIcon(ABitmap: TFtBitmap);
var
  bHandle: Pointer;
begin
  if ABitmap <> nil then bHandle := ABitmap.Handle else bHandle := nil;
  if (FHandle <> nil) and Assigned(ft_tab_page_set_icon) then
    ft_tab_page_set_icon(FHandle, bHandle);
end;

function TFtTabPage.GetIcon(): TFtBitmap;
var
  bHandle: Pointer;
begin
  if (FHandle <> nil) and Assigned(ft_tab_page_get_icon) then
  begin
    bHandle := ft_tab_page_get_icon(FHandle);
    if bHandle <> nil then
      Result := TFtBitmap.Wrap(bHandle, False)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

{ TFtNotebook }

constructor TFtNotebook.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_notebook_create) then
    h := ft_notebook_create(pHandle, AX, AY, AW, AH)
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtNotebook.AddTab(const ATitle: string; ACloseable: Boolean = False): TFtTabPage;
var
  pHandle: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_notebook_add_tab) then
  begin
    pHandle := ft_notebook_add_tab(Handle, PChar(ATitle), Ord(ACloseable));
    if pHandle <> nil then
      Result := TFtTabPage.Wrap(pHandle)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

procedure TFtNotebook.RemoveTab(AIndex: Integer);
begin
  if (Handle <> nil) and Assigned(ft_notebook_remove_tab) then
    ft_notebook_remove_tab(Handle, AIndex);
end;

procedure TFtNotebook.ClearTabs();
begin
  if (Handle <> nil) and Assigned(ft_notebook_clear_tabs) then
    ft_notebook_clear_tabs(Handle);
end;

function TFtNotebook.GetPage(AIndex: Integer): TFtTabPage;
var
  pHandle: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_notebook_get_page) then
  begin
    pHandle := ft_notebook_get_page(Handle, AIndex);
    if pHandle <> nil then
      Result := TFtTabPage.Wrap(pHandle)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TFtNotebook.GetPageCount: Integer;
begin
  if (Handle <> nil) and Assigned(ft_notebook_get_page_count) then
    Result := ft_notebook_get_page_count(Handle)
  else
    Result := 0;
end;

function TFtNotebook.GetActiveIndex: Integer;
begin
  if (Handle <> nil) and Assigned(ft_notebook_get_active_index) then
    Result := ft_notebook_get_active_index(Handle)
  else
    Result := -1;
end;

procedure TFtNotebook.SetActiveIndex(AValue: Integer);
begin
  if (Handle <> nil) and Assigned(ft_notebook_set_active_index) then
    ft_notebook_set_active_index(Handle, AValue);
end;

function TFtNotebook.GetTabHeight: Double;
begin
  if (Handle <> nil) and Assigned(ft_notebook_get_tab_height) then
    Result := ft_notebook_get_tab_height(Handle)
  else
    Result := 32.0;
end;

procedure TFtNotebook.SetTabHeight(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_notebook_set_tab_height) then
    ft_notebook_set_tab_height(Handle, AValue);
end;

procedure TFtNotebook.SetOnTabChange(AValue: TFtNotebookTabChangeEvent);
begin
  FOnTabChange := AValue;
  if (Handle <> nil) and Assigned(ft_notebook_on_tab_change) then
    ft_notebook_on_tab_change(Handle, @TabChangeDispatcher, Self);
end;

procedure TFtNotebook.DoTabChange(ANewIndex, AOldIndex: Integer);
begin
  if Assigned(FOnTabChange) then
    FOnTabChange(Self, ANewIndex, AOldIndex);
end;

{ TFtSizeGroup }

constructor TFtSizeGroup.Create(AMode: TFtSizeGroupMode);
begin
  inherited Create;
  FMode := AMode;
  if Assigned(ft_size_group_create) then
    FHandle := ft_size_group_create(Ord(AMode));
end;

destructor TFtSizeGroup.Destroy;
begin
  if (FHandle <> nil) and Assigned(ft_size_group_destroy) then
    ft_size_group_destroy(FHandle);
  inherited Destroy;
end;

procedure TFtSizeGroup.Add(AWidget: TFtWidget);
begin
  if (FHandle <> nil) and (AWidget <> nil) and (AWidget.Handle <> nil) and Assigned(ft_size_group_add_widget) then
    ft_size_group_add_widget(FHandle, AWidget.Handle);
end;

procedure TFtSizeGroup.Remove(AWidget: TFtWidget);
begin
  if (FHandle <> nil) and (AWidget <> nil) and (AWidget.Handle <> nil) and Assigned(ft_size_group_remove_widget) then
    ft_size_group_remove_widget(FHandle, AWidget.Handle);
end;

procedure TFtSizeGroup.Synchronize();
begin
  if (FHandle <> nil) and Assigned(ft_size_group_synchronize) then
    ft_size_group_synchronize(FHandle);
end;

end.
