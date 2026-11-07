{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal FTML Declarative Integration       }
{                                                                          }
{   Bridges Floria Toolkit Markup Language (FTML) and Floria JS runtime    }
{   with native ftpas widgets (TFtWindow, TFtButton, TFtLabel, etc.).      }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.ftml;

{$mode objfpc}{$H+}
{$interfaces corba}
{$modeswitch advancedrecords}

interface

uses
  Classes, SysUtils, Math,
  floriajs,
  ftpas.types, ftpas.api, ftpas.widget, ftpas.window,
  ftpas.controls, ftpas.layouts, ftpas.creative, ftpas.views, ftpas.menus,
  ftpas.ftml.res;

type
  { Forward Declarations }
  TFtFTMLHost = class;
  TFtFTMLWindow = class;
  TFtFTMLForm = class;

  { Notified for every widget instantiated from markup. Host applications use
    this to attach native behaviour (e.g. a terminal view on a DrawingArea). }
  TFtFTMLWidgetCreatedEvent = procedure(Sender: TFtFTMLHost;
    AItem: TFloriaFTMLItem; AWidget: TFtWidget) of object;

  { Menu item bindings (menus are not widgets, so they are tracked apart). }
  PFtFTMLMenuItemBinding = ^TFtFTMLMenuItemBinding;
  TFtFTMLMenuItemBinding = record
    Item: TFloriaFTMLItem;
    MenuItem: TFtMenuItem;
  end;

  { Mapping item that binds an FTML item with its corresponding native TFtWidget }
  PFtFTMLItemBinding = ^TFtFTMLItemBinding;
  TFtFTMLItemBinding = record
    Item: TFloriaFTMLItem;
    Widget: TFtWidget;
    TypeName: string;
    LastText: string;
    LastRadius: Double;
    LastX, LastY, LastW, LastH: Integer;
    LastVisible: Boolean;
    LastChecked: Boolean;
    LastValue: Double;
    LastColor: string;
  end;

  { Signal/Event bridge helper object }
  TFtFTMLSignalBridge = class
  private
    FHost: TFtFTMLHost;
    FItem: TFloriaFTMLItem;
  public
    constructor Create(AHost: TFtFTMLHost; AItem: TFloriaFTMLItem);
    procedure HandleButtonClick(Sender: TFtButton);
    procedure HandleEntryChange(Sender: TFtWidget; const AText: string);
    procedure HandleSwitchToggle(Sender: TFtSwitch; AToggled: Boolean);
    procedure HandleCheckBoxChange(Sender: TFtCheckBox; AChecked: Boolean);
    procedure HandleSliderChange(Sender: TFtSlider; AValue: Double);
    procedure HandleTextAreaChange(Sender: TFtWidget; const AText: string);
    procedure HandleRadioChange(Sender: TFtRadioButton; AChecked: Boolean);
    procedure HandleMenuItemClick(Sender: TFtMenuItem);
    procedure HandleUrlSubmit(Sender: TFtUrlEntry; const Url: string);
    procedure HandleUrlSecurityClick(Sender: TFtUrlEntry; SecurityState: TFtUrlSecurityState);
    procedure HandleUrlBookmarkClick(Sender: TFtUrlEntry; Bookmarked: Boolean);
    procedure HandleComboBoxChange(Sender: TFtComboBox; SelectedIndex: Integer; const Text: string);
    procedure HandlePathNavigate(Sender: TFtPathBar; const Path: string);
    procedure HandlePathModeChange(Sender: TFtPathBar; Mode: TFtPathBarMode);
    procedure HandleWindowButtonClick(Sender: TFtWindowButton);
    procedure HandleScrubberChange(Sender: TFtNumberScrubber; NewValue: Double);
    procedure HandleRulerCreateGuide(Sender: TFtRuler; WorldPos: Double);
    procedure HandleTreeSelect(Sender: TFtTreeView; Node: TFtTreeNode);
    procedure HandleTableRowSelect(Sender: TFtTable; RowIndex: Integer);
    procedure HandleTableRowDblClick(Sender: TFtTable; RowIndex: Integer);
    procedure HandleIconSelect(Sender: TFtIconView; ItemIndex: Integer);
    procedure HandleIconActivate(Sender: TFtIconView; ItemIndex: Integer);
  end;

  { TFtFTMLHost — Container widget hosting an FTML component hierarchy }
  TFtFTMLHost = class(TFtContainer)
  private
    FEngine: TFloriaFTMLEngine;
    FRootItem: TFloriaFTMLItem;
    FRootWidget: TFtWidget;
    FBindings: array of TFtFTMLItemBinding;
    FBindingCount: Integer;
    FMenuItems: array of TFtFTMLMenuItemBinding;
    FMenuItemCount: Integer;
    FBridges: TFPList;
    FIsSyncing: Boolean;
    FLastError: string;
    FOnWidgetCreated: TFtFTMLWidgetCreatedEvent;
    FAncestorWindow: TFtWindow;

    procedure AddMenuItemBinding(AItem: TFloriaFTMLItem; AMenuItem: TFtMenuItem);
    procedure DoWidgetCreated(AItem: TFloriaFTMLItem; AWidget: TFtWidget);

    procedure ClearBindings();
    procedure RegisterBinding(AItem: TFloriaFTMLItem; AWidget: TFtWidget);
    function  BuildWidgetTree(AItem: TFloriaFTMLItem; AParentWidget: TFtWidget): TFtWidget;
    procedure AttachSignals(AItem: TFloriaFTMLItem; AWidget: TFtWidget);
    function  GetHasErrors(): Boolean;

    procedure HookAncestorWindow();
    procedure UnhookAncestorWindow();
    procedure HandleAncestorControlsInsetChanged(Sender: TObject; const AInset: TFtWindowControlsInset);
    function  JSBeginWindowMove(const AArgs: array of TFloriaJSValue; AThis: TFloriaJSValue): TFloriaJSValue;
    function  JSBeginWindowResize(const AArgs: array of TFloriaJSValue; AThis: TFloriaJSValue): TFloriaJSValue;
    function  JSSetExtendedClientArea(const AArgs: array of TFloriaJSValue; AThis: TFloriaJSValue): TFloriaJSValue;
    function  JSIsExtendedClientArea(const AArgs: array of TFloriaJSValue; AThis: TFloriaJSValue): TFloriaJSValue;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer); reintroduce;
    destructor Destroy(); override;

    function  LoadString(const ASource: string): TFloriaFTMLItem;
    function  LoadFile(const AFileName: string): TFloriaFTMLItem;
    function  Evaluate(const AScript: string): TFloriaJSValue;
    function  FindItem(const AId: string): TFloriaFTMLItem;
    function  FindWidget(const AId: string): TFtWidget;
    function  FindMenuItem(const AId: string): TFtMenuItem;
    procedure RegisterFunction(const AName: string; AProc: TFloriaJSNativeProc);

    procedure SyncProperties();
    procedure EmitItemSignal(AItem: TFloriaFTMLItem; const ASignalName: string);
    procedure NotifyControlsInsetChanged(const AInset: TFtWindowControlsInset);

    property Engine: TFloriaFTMLEngine read FEngine;
    property RootItem: TFloriaFTMLItem read FRootItem;
    property RootWidget: TFtWidget read FRootWidget;
    property LastError: string read FLastError;
    property HasErrors: Boolean read GetHasErrors;
    property OnWidgetCreated: TFtFTMLWidgetCreatedEvent
      read FOnWidgetCreated write FOnWidgetCreated;
  end;

  { TFtFTMLWindow — Window class hosting an FTML component tree }
  TFtFTMLWindow = class(TFtWindow)
  private
    FHost: TFtFTMLHost;
    function  GetEngine(): TFloriaFTMLEngine;
    function  GetRootItem(): TFloriaFTMLItem;
  protected
    procedure DoResize(ANewWidth, ANewHeight: Integer); override;
    procedure DoControlsInsetChanged(const AInset: TFtWindowControlsInset); override;
  public
    constructor Create(AWidth, AHeight: Integer; const ATitle: string = ''); reintroduce;
    destructor Destroy(); override;

    procedure SetBounds(AX, AY, AWidth, AHeight: Integer);
    function  LoadString(const ASource: string): TFloriaFTMLItem;
    function  LoadFile(const AFileName: string): TFloriaFTMLItem;
    function  Evaluate(const AScript: string): TFloriaJSValue;
    function  FindItem(const AId: string): TFloriaFTMLItem;
    function  FindWidget(const AId: string): TFtWidget;
    function  FindMenuItem(const AId: string): TFtMenuItem;
    procedure RegisterFunction(const AName: string; AProc: TFloriaJSNativeProc);
    procedure SyncProperties();

    property Host: TFtFTMLHost read FHost;
    property Engine: TFloriaFTMLEngine read GetEngine;
    property RootItem: TFloriaFTMLItem read GetRootItem;
  end;

  { TFtFTMLForm — FTML design-bound window, the .lfm counterpart.

    The layout is fetched from the embedded resource registry first (see
    tools/ftml_embed.pas and ftpas.ftml.res), so no markup file has to be
    shipped with the executable. During UI development, setting the
    FTML_DESIGN_DIR environment variable or placing <design>.ftml next to
    the executable overrides the embedded copy. }
  TFtFTMLForm = class(TFtFTMLWindow)
  private
    FDesignName: string;
    FDesignFileName: string;
    FExternalDesign: Boolean;
  protected
    function  GetDefaultDesignName(): string; virtual;
    function  FindDesignFile(const AName: string): string;
    function  ResolveDesign(out ASource, AFileName: string): Boolean; virtual;
  public
    constructor Create(AWidth, AHeight: Integer; const ATitle: string = '';
      const ADesignName: string = ''); reintroduce;
    procedure LoadDesign(); virtual;
    function  ReadComponentRes(const AResName: string): Boolean;

    property DesignName: string read FDesignName;
    property DesignFileName: string read FDesignFileName;
    property ExternalDesign: Boolean read FExternalDesign;
  end;

  { Resource loading functions mirroring the Lazarus/Delphi ReadComponentRes model }
  function ReadComponentRes(const AResName: string; AForm: TFtFTMLForm): Boolean; overload;
  function ReadComponentRes(const AResName: string; out ASource: string): Boolean; overload;
  function InitComponentRes(const AResName: string; AForm: TFtFTMLForm): Boolean;

implementation

uses
  ftpas.app;

function FindAncestorWindow(AWidget: TFtWidget): TFtWindow; forward;

{ TFtFTMLSignalBridge }

constructor TFtFTMLSignalBridge.Create(AHost: TFtFTMLHost; AItem: TFloriaFTMLItem);
begin
  inherited Create();
  FHost := AHost;
  FItem := AItem;
end;

procedure TFtFTMLSignalBridge.HandleButtonClick(Sender: TFtButton);
begin
  if FHost <> nil then
    FHost.EmitItemSignal(FItem, 'clicked');
end;

procedure TFtFTMLSignalBridge.HandleEntryChange(Sender: TFtWidget; const AText: string);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('text', JSMakeString(AText));
    FHost.SyncProperties();
  end;
end;

procedure TFtFTMLSignalBridge.HandleSwitchToggle(Sender: TFtSwitch; AToggled: Boolean);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('checked', JSMakeBoolean(AToggled));
    FHost.EmitItemSignal(FItem, 'toggled');
  end;
end;

procedure TFtFTMLSignalBridge.HandleCheckBoxChange(Sender: TFtCheckBox; AChecked: Boolean);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('checked', JSMakeBoolean(AChecked));
    FHost.EmitItemSignal(FItem, 'toggled');
  end;
end;

procedure TFtFTMLSignalBridge.HandleSliderChange(Sender: TFtSlider; AValue: Double);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('value', JSMakeNumber(AValue));
    FHost.SyncProperties();
  end;
end;

procedure TFtFTMLSignalBridge.HandleTextAreaChange(Sender: TFtWidget; const AText: string);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('text', JSMakeString(AText));
    FHost.EmitItemSignal(FItem, 'textChanged');
  end;
end;

procedure TFtFTMLSignalBridge.HandleRadioChange(Sender: TFtRadioButton; AChecked: Boolean);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('checked', JSMakeBoolean(AChecked));
    FHost.EmitItemSignal(FItem, 'toggled');
  end;
end;

procedure TFtFTMLSignalBridge.HandleMenuItemClick(Sender: TFtMenuItem);
begin
  if FHost <> nil then
    FHost.EmitItemSignal(FItem, 'clicked');
end;

procedure TFtFTMLSignalBridge.HandleUrlSubmit(Sender: TFtUrlEntry; const Url: string);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('url', JSMakeString(Url));
    FItem.SetProperty('text', JSMakeString(Url));
    FHost.EmitItemSignal(FItem, 'submitted');
    FHost.SyncProperties();
  end;
end;

procedure TFtFTMLSignalBridge.HandleUrlSecurityClick(Sender: TFtUrlEntry; SecurityState: TFtUrlSecurityState);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FHost.EmitItemSignal(FItem, 'securityClicked');
  end;
end;

procedure TFtFTMLSignalBridge.HandleUrlBookmarkClick(Sender: TFtUrlEntry; Bookmarked: Boolean);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('bookmarked', JSMakeBoolean(Bookmarked));
    FHost.EmitItemSignal(FItem, 'bookmarkClicked');
  end;
end;

procedure TFtFTMLSignalBridge.HandleComboBoxChange(Sender: TFtComboBox; SelectedIndex: Integer; const Text: string);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('selectedIndex', JSMakeNumber(SelectedIndex));
    FItem.SetProperty('text', JSMakeString(Text));
    FHost.EmitItemSignal(FItem, 'change');
    FHost.EmitItemSignal(FItem, 'changed');
    FHost.SyncProperties();
  end;
end;

procedure TFtFTMLSignalBridge.HandlePathNavigate(Sender: TFtPathBar; const Path: string);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('path', JSMakeString(Path));
    FHost.EmitItemSignal(FItem, 'navigate');
    FHost.EmitItemSignal(FItem, 'navigated');
    FHost.SyncProperties();
  end;
end;

procedure TFtFTMLSignalBridge.HandlePathModeChange(Sender: TFtPathBar; Mode: TFtPathBarMode);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('mode', JSMakeNumber(Ord(Mode)));
    FHost.EmitItemSignal(FItem, 'modeChanged');
  end;
end;

procedure TFtFTMLSignalBridge.HandleWindowButtonClick(Sender: TFtWindowButton);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FHost.EmitItemSignal(FItem, 'click');
    FHost.EmitItemSignal(FItem, 'clicked');
  end;
end;

procedure TFtFTMLSignalBridge.HandleScrubberChange(Sender: TFtNumberScrubber; NewValue: Double);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('value', JSMakeNumber(NewValue));
    FHost.EmitItemSignal(FItem, 'change');
    FHost.EmitItemSignal(FItem, 'changed');
    FHost.SyncProperties();
  end;
end;

procedure TFtFTMLSignalBridge.HandleRulerCreateGuide(Sender: TFtRuler; WorldPos: Double);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('guidePosition', JSMakeNumber(WorldPos));
    FHost.EmitItemSignal(FItem, 'createGuide');
  end;
end;

procedure TFtFTMLSignalBridge.HandleTreeSelect(Sender: TFtTreeView; Node: TFtTreeNode);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    if Node <> nil then
      FItem.SetProperty('selectedText', JSMakeString(Node.Text))
    else
      FItem.SetProperty('selectedText', JSMakeString(''));
    FHost.EmitItemSignal(FItem, 'select');
    FHost.EmitItemSignal(FItem, 'selected');
  end;
end;

procedure TFtFTMLSignalBridge.HandleTableRowSelect(Sender: TFtTable; RowIndex: Integer);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('selectedRow', JSMakeNumber(RowIndex));
    FHost.EmitItemSignal(FItem, 'rowSelected');
    FHost.EmitItemSignal(FItem, 'select');
    FHost.SyncProperties();
  end;
end;

procedure TFtFTMLSignalBridge.HandleTableRowDblClick(Sender: TFtTable; RowIndex: Integer);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('selectedRow', JSMakeNumber(RowIndex));
    FHost.EmitItemSignal(FItem, 'rowDoubleClicked');
  end;
end;

procedure TFtFTMLSignalBridge.HandleIconSelect(Sender: TFtIconView; ItemIndex: Integer);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('selectedIndex', JSMakeNumber(ItemIndex));
    FHost.EmitItemSignal(FItem, 'select');
  end;
end;

procedure TFtFTMLSignalBridge.HandleIconActivate(Sender: TFtIconView; ItemIndex: Integer);
begin
  if (FHost <> nil) and (FItem <> nil) and not FHost.FIsSyncing then
  begin
    FItem.SetProperty('selectedIndex', JSMakeNumber(ItemIndex));
    FHost.EmitItemSignal(FItem, 'activate');
  end;
end;

{ TFtFTMLHost }

constructor TFtFTMLHost.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer);
begin
  inherited Create(AParent, AX, AY, AW, AH);
  DrawFrame := False;
  ScrollBarMode := ftsbmNone;
  SetPadding(0.0, 0.0);
  FEngine := TFloriaFTMLEngine.Create();
  FRootItem := nil;
  FRootWidget := nil;
  FBindingCount := 0;
  SetLength(FBindings, 0);
  FMenuItemCount := 0;
  SetLength(FMenuItems, 0);
  FBridges := TFPList.Create();
  FIsSyncing := False;
  FLastError := '';
  FAncestorWindow := nil;
  if FEngine.JSContext <> nil then
  begin
    FEngine.JSContext.RegisterMethod('beginWindowMove', @JSBeginWindowMove);
    FEngine.JSContext.RegisterMethod('beginWindowResize', @JSBeginWindowResize);
    FEngine.JSContext.RegisterMethod('setExtendedClientArea', @JSSetExtendedClientArea);
    FEngine.JSContext.RegisterMethod('isExtendedClientArea', @JSIsExtendedClientArea);
  end;
  HookAncestorWindow();
end;

destructor TFtFTMLHost.Destroy();
begin
  UnhookAncestorWindow();
  ClearBindings();
  FreeAndNil(FBridges);
  FreeAndNil(FEngine);
  inherited Destroy();
end;

procedure TFtFTMLHost.AddMenuItemBinding(AItem: TFloriaFTMLItem; AMenuItem: TFtMenuItem);
begin
  if (AItem = nil) or (AMenuItem = nil) then Exit;
  if FMenuItemCount >= Length(FMenuItems) then
  begin
    if Length(FMenuItems) = 0 then
      SetLength(FMenuItems, 8)
    else
      SetLength(FMenuItems, Length(FMenuItems) * 2);
  end;
  FMenuItems[FMenuItemCount].Item := AItem;
  FMenuItems[FMenuItemCount].MenuItem := AMenuItem;
  Inc(FMenuItemCount);
end;

procedure TFtFTMLHost.DoWidgetCreated(AItem: TFloriaFTMLItem; AWidget: TFtWidget);
begin
  if Assigned(FOnWidgetCreated) and (AItem <> nil) and (AWidget <> nil) then
    FOnWidgetCreated(Self, AItem, AWidget);
end;

function TFtFTMLHost.FindMenuItem(const AId: string): TFtMenuItem;
var
  i: Integer;
begin
  for i := 0 to FMenuItemCount - 1 do
  begin
    if (FMenuItems[i].Item <> nil) and (FMenuItems[i].Item.Id = AId) then
      Exit(FMenuItems[i].MenuItem);
  end;
  Result := nil;
end;

procedure TFtFTMLHost.ClearBindings();
var
  i: Integer;
begin
  if FBridges <> nil then
  begin
    for i := 0 to FBridges.Count - 1 do
      TObject(FBridges[i]).Free();
    FBridges.Clear();
  end;

  FBindingCount := 0;
  SetLength(FBindings, 0);
  FMenuItemCount := 0;
  SetLength(FMenuItems, 0);

  if (FRootWidget <> nil) and (FRootWidget <> Self) then
  begin
    FRootWidget.Free();
    FRootWidget := nil;
  end
  else if FRootWidget = Self then
  begin
    if Assigned(Children) then
    begin
      while Children.Count > 0 do
        TFtWidget(Children[Children.Count - 1]).Free();
    end;
  end;
  FRootWidget := nil;
  FRootItem := nil;
end;

procedure TFtFTMLHost.RegisterBinding(AItem: TFloriaFTMLItem; AWidget: TFtWidget);
begin
  if AItem = nil then Exit;

  if FBindingCount >= Length(FBindings) then
  begin
    if Length(FBindings) = 0 then
      SetLength(FBindings, 16)
    else
      SetLength(FBindings, Length(FBindings) * 2);
  end;

  FBindings[FBindingCount].Item := AItem;
  FBindings[FBindingCount].Widget := AWidget;
  FBindings[FBindingCount].TypeName := AItem.TypeName;
  FBindings[FBindingCount].LastText := AItem.GetPropertyAsString('text', '');
  FBindings[FBindingCount].LastRadius := AItem.GetPropertyAsNumber('radius', 0.0);
  if AWidget <> nil then
  begin
    FBindings[FBindingCount].LastX := AWidget.X;
    FBindings[FBindingCount].LastY := AWidget.Y;
    FBindings[FBindingCount].LastW := AWidget.Width;
    FBindings[FBindingCount].LastH := AWidget.Height;
  end
  else
  begin
    FBindings[FBindingCount].LastX := Round(AItem.X);
    FBindings[FBindingCount].LastY := Round(AItem.Y);
    FBindings[FBindingCount].LastW := Round(AItem.Width);
    FBindings[FBindingCount].LastH := Round(AItem.Height);
  end;
  FBindings[FBindingCount].LastVisible := AItem.Visible;
  FBindings[FBindingCount].LastChecked := AItem.GetPropertyAsBoolean('checked', False);
  FBindings[FBindingCount].LastValue := AItem.GetPropertyAsNumber('value', 0.0);
  FBindings[FBindingCount].LastColor := AItem.GetPropertyAsString('color', '');

  Inc(FBindingCount);
end;

procedure TFtFTMLHost.AttachSignals(AItem: TFloriaFTMLItem; AWidget: TFtWidget);
var
  bridge: TFtFTMLSignalBridge;
begin
  if (AItem = nil) or (AWidget = nil) then Exit;

  bridge := TFtFTMLSignalBridge.Create(Self, AItem);
  FBridges.Add(bridge);

  if AWidget is TFtButton then
  begin
    TFtButton(AWidget).OnClick := @bridge.HandleButtonClick;
  end
  else if AWidget is TFtEntry then
  begin
    TFtEntry(AWidget).OnChange := @bridge.HandleEntryChange;
  end
  else if AWidget is TFtSwitch then
  begin
    TFtSwitch(AWidget).OnToggle := @bridge.HandleSwitchToggle;
  end
  else if AWidget is TFtCheckBox then
  begin
    TFtCheckBox(AWidget).OnChange := @bridge.HandleCheckBoxChange;
  end
  else if AWidget is TFtSlider then
  begin
    TFtSlider(AWidget).OnChange := @bridge.HandleSliderChange;
  end
  else if AWidget is TFtUrlEntry then
  begin
    TFtUrlEntry(AWidget).OnSubmit := @bridge.HandleUrlSubmit;
    TFtUrlEntry(AWidget).OnSecurityClick := @bridge.HandleUrlSecurityClick;
    TFtUrlEntry(AWidget).OnBookmarkClick := @bridge.HandleUrlBookmarkClick;
  end
  else if AWidget is TFtTextArea then
  begin
    TFtTextArea(AWidget).OnChange := @bridge.HandleTextAreaChange;
  end
  else if AWidget is TFtRadioButton then
  begin
    TFtRadioButton(AWidget).OnChange := @bridge.HandleRadioChange;
  end
  else if AWidget is TFtComboBox then
  begin
    TFtComboBox(AWidget).OnChange := @bridge.HandleComboBoxChange;
  end
  else if AWidget is TFtPathBar then
  begin
    TFtPathBar(AWidget).OnNavigate := @bridge.HandlePathNavigate;
    TFtPathBar(AWidget).OnModeChange := @bridge.HandlePathModeChange;
  end
  else if AWidget is TFtWindowButton then
  begin
    TFtWindowButton(AWidget).OnClick := @bridge.HandleWindowButtonClick;
  end
  else if AWidget is TFtNumberScrubber then
  begin
    TFtNumberScrubber(AWidget).OnChange := @bridge.HandleScrubberChange;
  end
  else if AWidget is TFtRuler then
  begin
    TFtRuler(AWidget).OnCreateGuide := @bridge.HandleRulerCreateGuide;
  end
  else if AWidget is TFtTreeView then
  begin
    TFtTreeView(AWidget).OnSelect := @bridge.HandleTreeSelect;
  end
  else if AWidget is TFtTable then
  begin
    TFtTable(AWidget).OnSelectRow := @bridge.HandleTableRowSelect;
    TFtTable(AWidget).OnRowDoubleClick := @bridge.HandleTableRowDblClick;
  end
  else if AWidget is TFtIconView then
  begin
    TFtIconView(AWidget).OnSelect := @bridge.HandleIconSelect;
    TFtIconView(AWidget).OnActivate := @bridge.HandleIconActivate;
  end;
end;

function ParseHexColor(const AColor: string; out R, G, B: Double): Boolean;
var
  s: string;
  v, err: Integer;
begin
  Result := False;
  s := Trim(AColor);
  if (Length(s) > 0) and (s[1] = '#') then
    Delete(s, 1, 1);
  if Length(s) = 6 then
  begin
    Val('$' + Copy(s, 1, 2), v, err);
    if err <> 0 then Exit;
    R := v / 255.0;
    Val('$' + Copy(s, 3, 2), v, err);
    if err <> 0 then Exit;
    G := v / 255.0;
    Val('$' + Copy(s, 5, 2), v, err);
    if err <> 0 then Exit;
    B := v / 255.0;
    Result := True;
  end
  else if Length(s) = 3 then
  begin
    Val('$' + s[1] + s[1], v, err);
    if err <> 0 then Exit;
    R := v / 255.0;
    Val('$' + s[2] + s[2], v, err);
    if err <> 0 then Exit;
    G := v / 255.0;
    Val('$' + s[3] + s[3], v, err);
    if err <> 0 then Exit;
    B := v / 255.0;
    Result := True;
  end;
end;

procedure PopulateTreeNodes(AItem: TFloriaFTMLItem; AParentNode: TFtTreeNode; ATree: TFtTreeView);
var
  k: Integer;
  childItem: TFloriaFTMLItem;
  node: TFtTreeNode;
  nodeText: string;
begin
  for k := 0 to AItem.ChildCount() - 1 do
  begin
    childItem := AItem.GetChild(k);
    if (childItem.TypeName = 'TreeNode') or (childItem.TypeName = 'Node') or (childItem.TypeName = 'Item') then
    begin
      nodeText := childItem.GetPropertyAsString('text', childItem.GetPropertyAsString('caption', 'Node'));
      if AParentNode = nil then
        node := ATree.AddRoot(nodeText)
      else
        node := AParentNode.AddChild(nodeText);
      if childItem.HasProperty('expanded') then
        node.Expanded := childItem.GetPropertyAsBoolean('expanded', True);
      PopulateTreeNodes(childItem, node, ATree);
    end;
  end;
end;

function TFtFTMLHost.BuildWidgetTree(AItem: TFloriaFTMLItem; AParentWidget: TFtWidget): TFtWidget;
var
  W: TFtWidget;
  ix, iy, iw, ih: Integer;
  rad, minVal, maxVal, curVal, frac, sp: Double;
  cr, cg, cb: Double;
  cap, txt, ph, colorStr, borderCol: string;
  dirStr, wrapStr, justStr, alignStr: string;
  colTmpl, rowTmpl: string;
  padVal, colGap, rowGap, flexG, flexS, flexB: Double;
  nCols, nRows, gridC, gridR, colS, rowS: Integer;
  i, j: Integer;
  childrenHandled: Boolean;
  tabItem, subItem: TFloriaFTMLItem;
  page: TFtTabPage;
  pageWidget, w1, w2: TFtWidget;
  mi: TFtMenuItem;
  popup: TFtPopupMenu;
  win: TFtWindow;
  bridge: TFtFTMLSignalBridge;
  fnt, hintStr, clsStr, titleStr: string;
  opa: Double;
  itemsVal: TFloriaJSValue;
  itemsStr, kindStr, styleStr: string;
  arr: TFloriaJSArray;
  btnKind: TFtWindowButtonKind;
  btnStyle: TFtWindowButtonStyle;
  rulerOri: TFtRulerOrientation;
  anchorMode: TFtAnchorMode;
  textAlign: TFtTextAlign;
  rowIdx: Integer;
  zoomStr: string;
begin
  if AItem = nil then Exit(nil);

  ix := Round(AItem.X);
  iy := Round(AItem.Y);
  iw := Round(AItem.Width);
  ih := Round(AItem.Height);

  if (iw <= 0) and (AParentWidget = Self) then
    iw := Self.Width;
  if (ih <= 0) and (AParentWidget = Self) then
    ih := Self.Height;

  W := nil;
  childrenHandled := False;

  if (AItem = FRootItem) and ((AItem.TypeName = 'Rectangle') or (AItem.TypeName = 'Container') or (AItem.TypeName = 'Item') or (AItem.TypeName = 'Window')) then
  begin
    W := Self;
    rad := AItem.GetPropertyAsNumber('radius', 0.0);
    if rad > 0.0 then
      Self.CornerRadius := rad;

    colorStr := AItem.GetPropertyAsString('color');
    borderCol := AItem.GetPropertyAsString('borderColor');
    if (colorStr <> '') or (borderCol <> '') then
    begin
      if borderCol <> '' then
        Self.Style := 'background-color: ' + colorStr + '; border: 1px solid ' + borderCol + ';'
      else
        Self.Style := 'background-color: ' + colorStr + ';';
    end;

    win := FindAncestorWindow(Self);
    if win <> nil then
    begin
      titleStr := AItem.GetPropertyAsString('title', '');
      if titleStr <> '' then
        win.Title := titleStr;

      if AItem.HasProperty('extendedClientArea') or AItem.HasProperty('extended_client_area') then
      begin
        win.ExtendedClientArea := AItem.GetPropertyAsBoolean('extendedClientArea', False) or
                                  AItem.GetPropertyAsBoolean('extended_client_area', False);
        AItem.SetProperty('controlsInsetLeft', JSMakeNumber(win.WindowControlsInset.Left));
        AItem.SetProperty('controlsInsetRight', JSMakeNumber(win.WindowControlsInset.Right));
        AItem.SetProperty('controlsInsetTop', JSMakeNumber(win.WindowControlsInset.Top));
        AItem.SetProperty('controlsInsetBottom', JSMakeNumber(win.WindowControlsInset.Bottom));
        AItem.SetProperty('extendedClientArea', JSMakeBoolean(win.ExtendedClientArea));
      end;
    end;
  end
  else if (AItem = FRootItem) and ((AItem.TypeName = 'Panel') or (AItem.TypeName = 'Card')) then
  begin
    W := Self;
    Self.DrawFrame := True;
    padVal := AItem.GetPropertyAsNumber('padding', 8.0);
    Self.SetPadding(padVal, padVal);
    rad := AItem.GetPropertyAsNumber('radius', 6.0);
    if rad > 0.0 then
      Self.CornerRadius := rad;

    colorStr := AItem.GetPropertyAsString('color');
    borderCol := AItem.GetPropertyAsString('borderColor');
    if (colorStr <> '') or (borderCol <> '') then
    begin
      if borderCol <> '' then
        Self.Style := 'background-color: ' + colorStr + '; border: 1px solid ' + borderCol + ';'
      else
        Self.Style := 'background-color: ' + colorStr + ';';
    end;

    win := FindAncestorWindow(Self);
    if win <> nil then
    begin
      titleStr := AItem.GetPropertyAsString('title', '');
      if titleStr <> '' then
        win.Title := titleStr;

      if AItem.HasProperty('extendedClientArea') or AItem.HasProperty('extended_client_area') then
      begin
        win.ExtendedClientArea := AItem.GetPropertyAsBoolean('extendedClientArea', False) or
                                  AItem.GetPropertyAsBoolean('extended_client_area', False);
        AItem.SetProperty('controlsInsetLeft', JSMakeNumber(win.WindowControlsInset.Left));
        AItem.SetProperty('controlsInsetRight', JSMakeNumber(win.WindowControlsInset.Right));
        AItem.SetProperty('controlsInsetTop', JSMakeNumber(win.WindowControlsInset.Top));
        AItem.SetProperty('controlsInsetBottom', JSMakeNumber(win.WindowControlsInset.Bottom));
        AItem.SetProperty('extendedClientArea', JSMakeBoolean(win.ExtendedClientArea));
      end;
    end;
  end
  else if (AItem.TypeName = 'Container') or (AItem.TypeName = 'Item') then
  begin
    if (iw <= 0) and (AParentWidget <> nil) and (AParentWidget.Width > ix) then
      iw := AParentWidget.Width - ix;
    if (ih <= 0) and (AParentWidget <> nil) and (AParentWidget.Height > iy) then
      ih := AParentWidget.Height - iy;

    W := TFtContainer.Create(AParentWidget, ix, iy, iw, ih);
    TFtContainer(W).ScrollBarMode := ftsbmNone;
    padVal := AItem.GetPropertyAsNumber('padding', 0.0);
    TFtContainer(W).SetPadding(padVal, padVal);
    rad := AItem.GetPropertyAsNumber('radius', 0.0);
    if rad > 0.0 then
      TFtContainer(W).CornerRadius := rad;

    styleStr := AItem.GetPropertyAsString('style', '');
    if styleStr <> '' then
      W.Style := styleStr
    else
    begin
      colorStr := AItem.GetPropertyAsString('color');
      borderCol := AItem.GetPropertyAsString('borderColor');
      if (colorStr <> '') or (borderCol <> '') then
      begin
        if borderCol <> '' then
          W.Style := 'background-color: ' + colorStr + '; border: 1px solid ' + borderCol + ';'
        else
          W.Style := 'background-color: ' + colorStr + ';';
      end;
    end;
    if AItem.HasProperty('drawFrame') then
      TFtContainer(W).DrawFrame := AItem.GetPropertyAsBoolean('drawFrame', False);
  end
  else if (AItem.TypeName = 'Panel') or (AItem.TypeName = 'Card') then
  begin
    if (iw <= 0) and (AParentWidget <> nil) and (AParentWidget.Width > ix) then
      iw := AParentWidget.Width - ix;
    if (ih <= 0) and (AParentWidget <> nil) and (AParentWidget.Height > iy) then
      ih := AParentWidget.Height - iy;

    W := TFtPanel.Create(AParentWidget, ix, iy, iw, ih);
    TFtPanel(W).ScrollBarMode := ftsbmNone;
    padVal := AItem.GetPropertyAsNumber('padding', 8.0);
    TFtPanel(W).SetPadding(padVal, padVal);
    rad := AItem.GetPropertyAsNumber('radius', 6.0);
    if rad > 0.0 then
      TFtPanel(W).CornerRadius := rad;

    colorStr := AItem.GetPropertyAsString('color');
    borderCol := AItem.GetPropertyAsString('borderColor');
    if (colorStr <> '') or (borderCol <> '') then
    begin
      if borderCol <> '' then
        W.Style := 'background-color: ' + colorStr + '; border: 1px solid ' + borderCol + ';'
      else
        W.Style := 'background-color: ' + colorStr + ';';
    end;
  end
  else if AItem.TypeName = 'Rectangle' then
  begin
    if (iw <= 0) and (AParentWidget <> nil) and (AParentWidget.Width > ix) then
      iw := AParentWidget.Width - ix;
    if (ih <= 0) and (AParentWidget <> nil) and (AParentWidget.Height > iy) then
      ih := AParentWidget.Height - iy;

    W := TFtContainer.Create(AParentWidget, ix, iy, iw, ih);
    TFtContainer(W).ScrollBarMode := ftsbmNone;
    padVal := AItem.GetPropertyAsNumber('padding', 0.0);
    TFtContainer(W).SetPadding(padVal, padVal);
    rad := AItem.GetPropertyAsNumber('radius', 0.0);
    if rad > 0.0 then
      TFtContainer(W).CornerRadius := rad;

    styleStr := AItem.GetPropertyAsString('style', '');
    if styleStr <> '' then
      W.Style := styleStr
    else
    begin
      colorStr := AItem.GetPropertyAsString('color');
      borderCol := AItem.GetPropertyAsString('borderColor');
      if (colorStr <> '') or (borderCol <> '') then
      begin
        if borderCol <> '' then
          W.Style := 'background-color: ' + colorStr + '; border: 1px solid ' + borderCol + ';'
        else
          W.Style := 'background-color: ' + colorStr + ';';
      end;
    end;
    if AItem.HasProperty('drawFrame') then
      TFtContainer(W).DrawFrame := AItem.GetPropertyAsBoolean('drawFrame', False);
  end
  else if AItem.TypeName = 'Button' then
  begin
    if iw <= 0 then iw := 120;
    if ih <= 0 then ih := 36;
    cap := AItem.GetPropertyAsString('text', '');
    if not AItem.HasProperty('text') and not AItem.HasProperty('icon') then
      cap := 'Button';
    W := TFtButton.Create(AParentWidget, ix, iy, iw, ih, cap);
    if AItem.HasProperty('icon') then
    begin
      kindStr := AItem.GetPropertyAsString('icon');
      if FtApp().HasIcon(kindStr) then
      begin
        TFtButton(W).SetIconSVG(FtApp().GetIconSvg(kindStr, FtApp().DarkMode));
        if not AItem.HasProperty('text') then
        begin
          TFtButton(W).IconPosition := ftipOnly;
          TFtButton(W).Caption := '';
        end;
      end;
    end;
    if AItem.HasProperty('isToggle') then
      TFtButton(W).IsToggle := AItem.GetPropertyAsBoolean('isToggle', False);
    if AItem.HasProperty('toggled') or AItem.HasProperty('checked') then
      TFtButton(W).Toggled := AItem.GetPropertyAsBoolean('toggled', AItem.GetPropertyAsBoolean('checked', False));
    AttachSignals(AItem, W);
  end
  else if (AItem.TypeName = 'Text') or (AItem.TypeName = 'Label') then
  begin
    txt := AItem.GetPropertyAsString('text', '');
    if iw <= 0 then
    begin
      if (AParentWidget <> nil) and (AParentWidget.Width > ix + 16) then
        iw := AParentWidget.Width - ix - 16
      else
        iw := 400;
    end;
    if ih <= 0 then
      ih := 26;

    W := TFtLabel.Create(AParentWidget, ix, iy, iw, ih, txt);
    if AItem.HasProperty('selectable') then
      TFtLabel(W).Selectable := AItem.GetPropertyAsBoolean('selectable', True);
    colorStr := AItem.GetPropertyAsString('color');
    if colorStr <> '' then
    begin
      W.Style := 'color: ' + colorStr + ';';
      if ParseHexColor(colorStr, cr, cg, cb) then
        TFtLabel(W).SetColor(cr, cg, cb);
    end;
  end
  else if (AItem.TypeName = 'TextInput') or (AItem.TypeName = 'Entry') then
  begin
    if iw <= 0 then
    begin
      if (AParentWidget <> nil) and (AParentWidget.Width > ix + 16) then
        iw := AParentWidget.Width - ix - 16
      else
        iw := 200;
    end;
    if ih <= 0 then
      ih := 36;

    txt := AItem.GetPropertyAsString('text', '');
    W := TFtEntry.Create(AParentWidget, ix, iy, iw, ih, txt);
    ph := AItem.GetPropertyAsString('placeholder', '');
    if ph <> '' then
      TFtEntry(W).Placeholder := ph;
    AttachSignals(AItem, W);
  end
  else if (AItem.TypeName = 'UrlEntry') or (AItem.TypeName = 'OmniBox') then
  begin
    if iw <= 0 then
    begin
      if (AParentWidget <> nil) and (AParentWidget.Width > ix + 16) then
        iw := AParentWidget.Width - ix - 16
      else
        iw := 300;
    end;
    if ih <= 0 then
      ih := 36;

    txt := AItem.GetPropertyAsString('url', AItem.GetPropertyAsString('text', ''));
    W := TFtUrlEntry.Create(AParentWidget, ix, iy, iw, ih, txt);
    rad := AItem.GetPropertyAsNumber('radius', AItem.GetPropertyAsNumber('cornerRadius', 0.0));
    if rad > 0.0 then
      TFtUrlEntry(W).CornerRadius := rad;
    TFtUrlEntry(W).ShowSecurityChip := AItem.GetPropertyAsBoolean('showSecurityChip', True);
    TFtUrlEntry(W).ShowBookmarkButton := AItem.GetPropertyAsBoolean('showBookmarkButton', True);
    TFtUrlEntry(W).ShowSecurityBadgeText := AItem.GetPropertyAsBoolean('showSecurityBadgeText', False);
    curVal := AItem.GetPropertyAsNumber('securityState', -1.0);
    if curVal >= 0.0 then
      TFtUrlEntry(W).SecurityState := TFtUrlSecurityState(Round(curVal));
    TFtUrlEntry(W).Bookmarked := AItem.GetPropertyAsBoolean('bookmarked', False);
    AttachSignals(AItem, W);
  end
  else if AItem.TypeName = 'Switch' then
  begin
    if iw <= 0 then iw := 120;
    if ih <= 0 then ih := 32;
    W := TFtSwitch.Create(AParentWidget, ix, iy, iw, ih, AItem.GetPropertyAsString('text', ''));
    TFtSwitch(W).Checked := AItem.GetPropertyAsBoolean('checked', False);
    AttachSignals(AItem, W);
  end
  else if AItem.TypeName = 'CheckBox' then
  begin
    if iw <= 0 then iw := 160;
    if ih <= 0 then ih := 28;
    W := TFtCheckBox.Create(AParentWidget, ix, iy, iw, ih, AItem.GetPropertyAsString('text', ''));
    TFtCheckBox(W).Checked := AItem.GetPropertyAsBoolean('checked', False);
    AttachSignals(AItem, W);
  end
  else if AItem.TypeName = 'Slider' then
  begin
    if iw <= 0 then iw := 160;
    if ih <= 0 then ih := 24;
    W := TFtSlider.Create(AParentWidget, ix, iy, iw, ih);
    minVal := AItem.GetPropertyAsNumber('min', 0.0);
    maxVal := AItem.GetPropertyAsNumber('max', 100.0);
    curVal := AItem.GetPropertyAsNumber('value', minVal);
    TFtSlider(W).SetRange(minVal, maxVal);
    TFtSlider(W).Value := curVal;
    AttachSignals(AItem, W);
  end
  else if AItem.TypeName = 'ProgressBar' then
  begin
    if iw <= 0 then iw := 200;
    if ih <= 0 then ih := 20;
    frac := AItem.GetPropertyAsNumber('fraction', 0.0);
    W := TFtProgressBar.Create(AParentWidget, ix, iy, iw, ih);
    TFtProgressBar(W).Value := frac;
  end
  else if AItem.TypeName = 'Column' then
  begin
    if (iw <= 0) and (AParentWidget <> nil) and (AParentWidget.Width > ix) then
      iw := AParentWidget.Width - ix;
    if (ih <= 0) and (AParentWidget <> nil) and (AParentWidget.Height > iy) then
      ih := AParentWidget.Height - iy;
    W := TFtVBox.Create(AParentWidget, ix, iy, iw, ih);
    sp := AItem.GetPropertyAsNumber('gap', -1.0);
    if sp < 0.0 then
      sp := AItem.GetPropertyAsNumber('spacing', 0.0);
    if sp > 0.0 then
      TFtVBox(W).Gap := sp;
  end
  else if AItem.TypeName = 'Row' then
  begin
    if (iw <= 0) and (AParentWidget <> nil) and (AParentWidget.Width > ix) then
      iw := AParentWidget.Width - ix;
    if ih <= 0 then
      ih := 44;
    W := TFtHBox.Create(AParentWidget, ix, iy, iw, ih);
    sp := AItem.GetPropertyAsNumber('gap', -1.0);
    if sp < 0.0 then
      sp := AItem.GetPropertyAsNumber('spacing', 0.0);
    if sp > 0.0 then
      TFtHBox(W).Gap := sp;

    alignStr := LowerCase(AItem.GetPropertyAsString('alignItems', 'center'));
    if alignStr = 'center' then
      TFtHBox(W).AlignItems := ftaiCenter
    else if (alignStr = 'flex-start') or (alignStr = 'start') then
      TFtHBox(W).AlignItems := ftaiStart
    else if (alignStr = 'flex-end') or (alignStr = 'end') then
      TFtHBox(W).AlignItems := ftaiEnd
    else if alignStr = 'stretch' then
      TFtHBox(W).AlignItems := ftaiStretch;
  end
  else if AItem.TypeName = 'FlexBox' then
  begin
    if (iw <= 0) and (AParentWidget <> nil) and (AParentWidget.Width > ix) then
      iw := AParentWidget.Width - ix;
    if (ih <= 0) and (AParentWidget <> nil) and (AParentWidget.Height > iy) then
      ih := AParentWidget.Height - iy;
    W := TFtFlexBox.Create(AParentWidget, ix, iy, iw, ih);

    // Direction
    dirStr := LowerCase(AItem.GetPropertyAsString('direction', 'row'));
    if dirStr = 'column' then
      TFtFlexBox(W).Direction := ftfdColumn
    else
      TFtFlexBox(W).Direction := ftfdRow;

    // Wrap
    wrapStr := LowerCase(AItem.GetPropertyAsString('wrap', 'nowrap'));
    if wrapStr = 'wrap' then
      TFtFlexBox(W).Wrap := ftfwWrap
    else if wrapStr = 'wrap-reverse' then
      TFtFlexBox(W).Wrap := ftfwWrapReverse
    else
      TFtFlexBox(W).Wrap := ftfwNoWrap;

    // JustifyContent
    justStr := LowerCase(AItem.GetPropertyAsString('justifyContent', 'flex-start'));
    if (justStr = 'flex-end') or (justStr = 'end') then
      TFtFlexBox(W).JustifyContent := ftjcEnd
    else if justStr = 'center' then
      TFtFlexBox(W).JustifyContent := ftjcCenter
    else if (justStr = 'space-between') or (justStr = 'spacebetween') then
      TFtFlexBox(W).JustifyContent := ftjcSpaceBetween
    else if (justStr = 'space-around') or (justStr = 'spacearound') then
      TFtFlexBox(W).JustifyContent := ftjcSpaceAround
    else if (justStr = 'space-evenly') or (justStr = 'spaceevenly') then
      TFtFlexBox(W).JustifyContent := ftjcSpaceEvenly
    else
      TFtFlexBox(W).JustifyContent := ftjcStart;

    // AlignItems
    alignStr := LowerCase(AItem.GetPropertyAsString('alignItems', 'stretch'));
    if (alignStr = 'flex-start') or (alignStr = 'start') then
      TFtFlexBox(W).AlignItems := ftaiStart
    else if (alignStr = 'flex-end') or (alignStr = 'end') then
      TFtFlexBox(W).AlignItems := ftaiEnd
    else if alignStr = 'center' then
      TFtFlexBox(W).AlignItems := ftaiCenter
    else
      TFtFlexBox(W).AlignItems := ftaiStretch;

    sp := AItem.GetPropertyAsNumber('gap', -1.0);
    if sp < 0.0 then
      sp := AItem.GetPropertyAsNumber('spacing', 0.0);
    if sp > 0.0 then
      TFtFlexBox(W).Gap := sp;

    padVal := AItem.GetPropertyAsNumber('padding', 0.0);
    if padVal > 0.0 then
      TFtFlexBox(W).SetPadding(padVal, padVal);
  end
  else if AItem.TypeName = 'Grid' then
  begin
    if (iw <= 0) and (AParentWidget <> nil) and (AParentWidget.Width > ix) then
      iw := AParentWidget.Width - ix;
    if (ih <= 0) and (AParentWidget <> nil) and (AParentWidget.Height > iy) then
      ih := AParentWidget.Height - iy;
    W := TFtGrid.Create(AParentWidget, ix, iy, iw, ih);

    nCols := Round(AItem.GetPropertyAsNumber('columns', 2.0));
    nRows := Round(AItem.GetPropertyAsNumber('rows', 0.0));

    colTmpl := AItem.GetPropertyAsString('columnTemplate', '');
    if colTmpl <> '' then
      TFtGrid(W).SetColumnTemplate(colTmpl)
    else if nCols > 0 then
      TFtGrid(W).ColumnCount := nCols;

    rowTmpl := AItem.GetPropertyAsString('rowTemplate', '');
    if rowTmpl <> '' then
      TFtGrid(W).SetRowTemplate(rowTmpl)
    else if nRows > 0 then
      TFtGrid(W).RowCount := nRows;

    colGap := AItem.GetPropertyAsNumber('columnGap', -1.0);
    rowGap := AItem.GetPropertyAsNumber('rowGap', -1.0);
    sp := AItem.GetPropertyAsNumber('gap', -1.0);
    if sp < 0.0 then
      sp := AItem.GetPropertyAsNumber('spacing', 0.0);
    if colGap < 0.0 then colGap := sp;
    if rowGap < 0.0 then rowGap := sp;
    if (colGap > 0.0) or (rowGap > 0.0) then
      TFtGrid(W).SetGaps(colGap, rowGap);
  end
  else if (AItem.TypeName = 'DrawingArea') or (AItem.TypeName = 'Canvas') then
  begin
    if iw <= 0 then iw := 200;
    if ih <= 0 then ih := 120;
    W := TFtDrawingArea.Create(AParentWidget, ix, iy, iw, ih);
  end
  else if AItem.TypeName = 'TextArea' then
  begin
    if iw <= 0 then iw := 240;
    if ih <= 0 then ih := 120;
    W := TFtTextArea.Create(AParentWidget, ix, iy, iw, ih,
      AItem.GetPropertyAsString('text', ''));
    ph := AItem.GetPropertyAsString('placeholder', '');
    if ph <> '' then
      TFtTextArea(W).Placeholder := ph;
    if AItem.GetPropertyAsBoolean('readOnly', False) then
      TFtTextArea(W).ReadOnly := True;
    AttachSignals(AItem, W);
  end
  else if (AItem.TypeName = 'Radio') or (AItem.TypeName = 'RadioButton') then
  begin
    if iw <= 0 then iw := 160;
    if ih <= 0 then ih := 28;
    W := TFtRadioButton.Create(AParentWidget, ix, iy, iw, ih,
      AItem.GetPropertyAsString('text', ''));
    TFtRadioButton(W).Checked := AItem.GetPropertyAsBoolean('checked', False);
    AttachSignals(AItem, W);
  end
  else if AItem.TypeName = 'Image' then
  begin
    if iw <= 0 then iw := 64;
    if ih <= 0 then ih := 64;
    W := TFtImage.Create(AParentWidget, ix, iy, iw, ih,
      AItem.GetPropertyAsString('src', AItem.GetPropertyAsString('file', '')));
  end
  else if AItem.TypeName = 'ScrollBar' then
  begin
    if iw <= 0 then iw := 12;
    if ih <= 0 then ih := 160;
    if LowerCase(AItem.GetPropertyAsString('orientation', 'vertical')) = 'horizontal' then
      W := TFtScrollBar.Create(AParentWidget, ix, iy, iw, ih, ftsboHorizontal)
    else
      W := TFtScrollBar.Create(AParentWidget, ix, iy, iw, ih, ftsboVertical);
  end
  else if AItem.TypeName = 'Splitter' then
  begin
    if iw <= 0 then iw := 6;
    if ih <= 0 then ih := 160;
    if LowerCase(AItem.GetPropertyAsString('orientation', 'vertical')) = 'horizontal' then
      W := TFtSplitter.Create(AParentWidget, ix, iy, iw, ih, ftspoHorizontal)
    else
      W := TFtSplitter.Create(AParentWidget, ix, iy, iw, ih, ftspoVertical);
  end
  else if AItem.TypeName = 'Spacer' then
  begin
    W := TFtSpacer.Create(AParentWidget);
    W.SetBounds(ix, iy, iw, ih);
  end
  else if AItem.TypeName = 'Separator' then
  begin
    if ih <= 0 then ih := 1;
    W := TFtContainer.Create(AParentWidget, ix, iy, iw, ih);
    TFtContainer(W).ScrollBarMode := ftsbmNone;
    W.Style := 'background-color: ' + AItem.GetPropertyAsString('color', '#45475a') + ';';
  end
  else if (AItem.TypeName = 'Notebook') or (AItem.TypeName = 'Tabs') then
  begin
    if (iw <= 0) and (AParentWidget <> nil) and (AParentWidget.Width > ix) then
      iw := AParentWidget.Width - ix;
    if (ih <= 0) and (AParentWidget <> nil) and (AParentWidget.Height > iy) then
      ih := AParentWidget.Height - iy;
    W := TFtNotebook.Create(AParentWidget, ix, iy, iw, ih);
    if AItem.HasProperty('tabHeight') then
      TFtNotebook(W).TabHeight := AItem.GetPropertyAsNumber('tabHeight', 32.0);
    if AItem.HasProperty('maxTabWidth') then
      TFtNotebook(W).MaxTabWidth := AItem.GetPropertyAsNumber('maxTabWidth', 200.0);
    if AItem.HasProperty('minTabWidth') then
      TFtNotebook(W).MinTabWidth := AItem.GetPropertyAsNumber('minTabWidth', 70.0);
    childrenHandled := True;
    for i := 0 to AItem.ChildCount() - 1 do
    begin
      tabItem := AItem.GetChild(i);
      if (tabItem.TypeName = 'Tab') or (tabItem.TypeName = 'TabPage') or
         (tabItem.TypeName = 'TabItem') then
      begin
        titleStr := tabItem.GetPropertyAsString('title', '');
        if titleStr = '' then
          titleStr := tabItem.GetPropertyAsString('text', 'Tab');
        page := TFtNotebook(W).AddTab(titleStr,
          tabItem.GetPropertyAsBoolean('closeable', True));
        pageWidget := TFtWidget.Wrap(page.Handle, W, False);
        RegisterBinding(tabItem, pageWidget);
        DoWidgetCreated(tabItem, pageWidget);
        for j := 0 to tabItem.ChildCount() - 1 do
          BuildWidgetTree(tabItem.GetChild(j), pageWidget);
      end
      else
        BuildWidgetTree(tabItem, W);
    end;
  end
  else if (AItem.TypeName = 'MenuBar') or (AItem.TypeName = 'MainMenu') then
  begin
    win := FindAncestorWindow(AParentWidget);
    if win = nil then
      Exit(nil);
    W := TFtMainMenu.Create(win);
    childrenHandled := True;
    for i := 0 to AItem.ChildCount() - 1 do
    begin
      tabItem := AItem.GetChild(i);
      if tabItem.TypeName <> 'Menu' then Continue;
      titleStr := tabItem.GetPropertyAsString('title', '');
      if titleStr = '' then
        titleStr := tabItem.GetPropertyAsString('text', 'Menu');
      popup := TFtMainMenu(W).AddMenu(titleStr);
      for j := 0 to tabItem.ChildCount() - 1 do
      begin
        subItem := tabItem.GetChild(j);
        if subItem.TypeName = 'Separator' then
          TFtPopupMenu(popup).AddSeparator()
        else if (subItem.TypeName = 'MenuItem') or (subItem.TypeName = 'Action') then
        begin
          if subItem.GetPropertyAsBoolean('checkable', False) then
            mi := TFtPopupMenu(popup).AddCheckItem(
              subItem.GetPropertyAsString('text', ''),
              subItem.GetPropertyAsBoolean('checked', False))
          else
            mi := TFtPopupMenu(popup).AddItem(
              subItem.GetPropertyAsString('text', ''));
          if subItem.HasProperty('shortcut') then
            mi.Shortcut := subItem.GetPropertyAsString('shortcut', '');
          bridge := TFtFTMLSignalBridge.Create(Self, subItem);
          FBridges.Add(bridge);
          mi.OnClick := @bridge.HandleMenuItemClick;
          AddMenuItemBinding(subItem, mi);
        end;
      end;
    end;
  end
  else if (AItem.TypeName = 'ComboBox') or (AItem.TypeName = 'DropDown') or (AItem.TypeName = 'Selector') then
  begin
    if iw <= 0 then iw := 160;
    if ih <= 0 then ih := 32;
    W := TFtComboBox.Create(AParentWidget, ix, iy, iw, ih);
    ph := AItem.GetPropertyAsString('placeholder', '');
    if ph <> '' then
      TFtComboBox(W).Placeholder := ph;
    if AItem.GetPropertyAsBoolean('editable', False) then
      TFtComboBox(W).Editable := True;
    rad := AItem.GetPropertyAsNumber('radius', AItem.GetPropertyAsNumber('cornerRadius', 0.0));
    if rad > 0.0 then
      TFtComboBox(W).CornerRadius := rad;

    if AItem.HasProperty('items') then
    begin
      itemsVal := AItem.GetProperty('items');
      if itemsVal.IsString() then
      begin
        itemsStr := itemsVal.ToString();
        while itemsStr <> '' do
        begin
          j := Pos(',', itemsStr);
          if j > 0 then
          begin
            TFtComboBox(W).AddItem(Trim(Copy(itemsStr, 1, j - 1)));
            Delete(itemsStr, 1, j);
          end
          else
          begin
            TFtComboBox(W).AddItem(Trim(itemsStr));
            itemsStr := '';
          end;
        end;
      end
      else if itemsVal.IsArray() then
      begin
        arr := itemsVal.AsArray();
        for i := 0 to arr.Length() - 1 do
          TFtComboBox(W).AddItem(arr.GetElement(i).ToString());
      end;
    end;

    if AItem.ChildCount() > 0 then
    begin
      childrenHandled := True;
      for i := 0 to AItem.ChildCount() - 1 do
      begin
        subItem := AItem.GetChild(i);
        TFtComboBox(W).AddItem(subItem.GetPropertyAsString('text', subItem.GetPropertyAsString('value', '')));
      end;
    end;

    curVal := AItem.GetPropertyAsNumber('selectedIndex', -1.0);
    if curVal >= 0.0 then
      TFtComboBox(W).SelectedIndex := Round(curVal);
    txt := AItem.GetPropertyAsString('text', '');
    if txt <> '' then
      TFtComboBox(W).Text := txt;

    AttachSignals(AItem, W);
  end
  else if (AItem.TypeName = 'PathBar') or (AItem.TypeName = 'BreadcrumbBar') then
  begin
    if iw <= 0 then
    begin
      if (AParentWidget <> nil) and (AParentWidget.Width > ix + 16) then
        iw := AParentWidget.Width - ix - 16
      else
        iw := 300;
    end;
    if ih <= 0 then ih := 32;
    txt := AItem.GetPropertyAsString('path', AItem.GetPropertyAsString('text', ''));
    W := TFtPathBar.Create(AParentWidget, ix, iy, iw, ih, txt);
    rad := AItem.GetPropertyAsNumber('radius', AItem.GetPropertyAsNumber('cornerRadius', 0.0));
    if rad > 0.0 then
      TFtPathBar(W).CornerRadius := rad;
    if AItem.HasProperty('showEditButton') then
      TFtPathBar(W).ShowEditButton := AItem.GetPropertyAsBoolean('showEditButton', True);
    titleStr := AItem.GetPropertyAsString('rootDisplayName', '');
    if titleStr <> '' then
      TFtPathBar(W).RootDisplayName := titleStr;
    kindStr := LowerCase(AItem.GetPropertyAsString('mode', 'breadcrumbs'));
    if (kindStr = 'edit') or (kindStr = '1') then
      TFtPathBar(W).Mode := ftpbmEdit
    else
      TFtPathBar(W).Mode := ftpbmBreadcrumbs;
    AttachSignals(AItem, W);
  end
  else if AItem.TypeName = 'WindowButton' then
  begin
    if iw <= 0 then iw := 28;
    if ih <= 0 then ih := 28;
    kindStr := LowerCase(AItem.GetPropertyAsString('kind', 'close'));
    btnKind := ftwbClose;
    if (kindStr = 'minimize') or (kindStr = 'min') then btnKind := ftwbMinimize
    else if (kindStr = 'maximize') or (kindStr = 'max') then btnKind := ftwbMaximize
    else if kindStr = 'restore' then btnKind := ftwbRestore
    else if kindStr = 'shade' then btnKind := ftwbShade
    else if kindStr = 'pin' then btnKind := ftwbPin
    else if kindStr = 'menu' then btnKind := ftwbMenu
    else if kindStr = 'add' then btnKind := ftwbAdd;

    styleStr := LowerCase(AItem.GetPropertyAsString('buttonStyle', 'squircle'));
    btnStyle := ftwsSquircle;
    if styleStr = 'circle' then btnStyle := ftwsCircle
    else if (styleStr = 'square') or (styleStr = 'flat') then btnStyle := ftwsSquare;

    W := TFtWindowButton.Create(AParentWidget, ix, iy, iw, ih, btnKind, btnStyle);
    if AItem.HasProperty('glyphArm') then
      TFtWindowButton(W).GlyphArm := AItem.GetPropertyAsNumber('glyphArm', 6.0);
    if AItem.HasProperty('transitionDuration') then
      TFtWindowButton(W).TransitionDuration := Round(AItem.GetPropertyAsNumber('transitionDuration', 150.0));
    AttachSignals(AItem, W);
  end
  else if (AItem.TypeName = 'NumberScrubber') or (AItem.TypeName = 'Scrubber') then
  begin
    if iw <= 0 then iw := 140;
    if ih <= 0 then ih := 28;
    txt := AItem.GetPropertyAsString('label', AItem.GetPropertyAsString('text', ''));
    W := TFtNumberScrubber.Create(AParentWidget, ix, iy, iw, ih, txt);
    minVal := AItem.GetPropertyAsNumber('min', AItem.GetPropertyAsNumber('minValue', 0.0));
    maxVal := AItem.GetPropertyAsNumber('max', AItem.GetPropertyAsNumber('maxValue', 100.0));
    TFtNumberScrubber(W).SetRange(minVal, maxVal);
    if AItem.HasProperty('decimals') then
      TFtNumberScrubber(W).Decimals := Round(AItem.GetPropertyAsNumber('decimals', 0.0));
    if AItem.HasProperty('step') then
      TFtNumberScrubber(W).Step := AItem.GetPropertyAsNumber('step', 1.0);
    curVal := AItem.GetPropertyAsNumber('value', minVal);
    TFtNumberScrubber(W).Value := curVal;
    if AItem.HasProperty('prefix') then
      TFtNumberScrubber(W).Prefix := AItem.GetPropertyAsString('prefix', '');
    if AItem.HasProperty('suffix') then
      TFtNumberScrubber(W).Suffix := AItem.GetPropertyAsString('suffix', '');
    AttachSignals(AItem, W);
  end
  else if AItem.TypeName = 'Ruler' then
  begin
    dirStr := LowerCase(AItem.GetPropertyAsString('orientation', 'horizontal'));
    if dirStr = 'vertical' then
    begin
      rulerOri := ftroVertical;
      if iw <= 0 then iw := 24;
      if ih <= 0 then ih := 200;
    end
    else
    begin
      rulerOri := ftroHorizontal;
      if iw <= 0 then iw := 200;
      if ih <= 0 then ih := 24;
    end;
    W := TFtRuler.Create(AParentWidget, rulerOri, ix, iy, iw, ih);
    kindStr := LowerCase(AItem.GetPropertyAsString('unit', 'pixels'));
    if (kindStr = 'points') or (kindStr = 'pt') then
      TFtRuler(W).UnitKind := ftruPoints
    else if (kindStr = 'millimeters') or (kindStr = 'mm') then
      TFtRuler(W).UnitKind := ftruMillimeters
    else if (kindStr = 'centimeters') or (kindStr = 'cm') then
      TFtRuler(W).UnitKind := ftruCentimeters
    else if (kindStr = 'inches') or (kindStr = 'in') then
      TFtRuler(W).UnitKind := ftruInches
    else
      TFtRuler(W).UnitKind := ftruPixels;
    if AItem.HasProperty('thickness') then
      TFtRuler(W).Thickness := Round(AItem.GetPropertyAsNumber('thickness', 24.0));
    if AItem.HasProperty('showPointer') then
      TFtRuler(W).ShowPointer := AItem.GetPropertyAsBoolean('showPointer', True);
    if AItem.HasProperty('origin') or AItem.HasProperty('scale') then
      TFtRuler(W).SetOriginAndScale(
        AItem.GetPropertyAsNumber('origin', 0.0),
        AItem.GetPropertyAsNumber('scale', 1.0));
    if AItem.HasProperty('pointerPosition') then
      TFtRuler(W).PointerPosition := AItem.GetPropertyAsNumber('pointerPosition', 0.0);
    AttachSignals(AItem, W);
  end
  else if AItem.TypeName = 'FloatingBar' then
  begin
    if iw <= 0 then iw := 300;
    if ih <= 0 then ih := 44;
    kindStr := LowerCase(AItem.GetPropertyAsString('anchor', 'topcenter'));
    anchorMode := ftamTopCenter;
    if (kindStr = 'bottomcenter') or (kindStr = 'bottom') then anchorMode := ftamBottomCenter
    else if kindStr = 'topleft' then anchorMode := ftamTopLeft
    else if kindStr = 'topright' then anchorMode := ftamTopRight
    else if kindStr = 'bottomleft' then anchorMode := ftamBottomLeft
    else if kindStr = 'bottomright' then anchorMode := ftamBottomRight
    else if kindStr = 'center' then anchorMode := ftamCenter;

    W := TFtFloatingBar.Create(AParentWidget, anchorMode, iw, ih);
    if AItem.HasProperty('autoAnchor') then
      TFtFloatingBar(W).AutoAnchor := AItem.GetPropertyAsBoolean('autoAnchor', True);
    if AItem.HasProperty('marginX') or AItem.HasProperty('marginY') then
      TFtFloatingBar(W).SetMargins(
        AItem.GetPropertyAsNumber('marginX', 0.0),
        AItem.GetPropertyAsNumber('marginY', 0.0));
    TFtFloatingBar(W).UpdateAnchor();
  end
  else if AItem.TypeName = 'FormGrid' then
  begin
    if (iw <= 0) and (AParentWidget <> nil) and (AParentWidget.Width > ix) then
      iw := AParentWidget.Width - ix;
    if (ih <= 0) and (AParentWidget <> nil) and (AParentWidget.Height > iy) then
      ih := AParentWidget.Height - iy;
    if iw <= 0 then iw := 400;
    if ih <= 0 then ih := 250;
    W := TFtFormGrid.Create(AParentWidget, ix, iy, iw, ih);
    childrenHandled := True;
    for i := 0 to AItem.ChildCount() - 1 do
    begin
      subItem := AItem.GetChild(i);
      if (subItem.TypeName = 'FormRow') or (subItem.TypeName = 'Row') then
      begin
        titleStr := subItem.GetPropertyAsString('label', subItem.GetPropertyAsString('text', ''));
        if subItem.ChildCount() >= 2 then
        begin
          w1 := BuildWidgetTree(subItem.GetChild(0), W);
          w2 := BuildWidgetTree(subItem.GetChild(1), W);
          TFtFormGrid(W).AddRowWidgets(w1, w2);
        end
        else if subItem.ChildCount() = 1 then
        begin
          w1 := BuildWidgetTree(subItem.GetChild(0), W);
          TFtFormGrid(W).AddRow(titleStr, w1);
        end
        else
          TFtFormGrid(W).AddRow(titleStr, nil);
      end
      else if subItem.TypeName = 'FormSection' then
      begin
        TFtFormGrid(W).AddSection(subItem.GetPropertyAsString('title', subItem.GetPropertyAsString('text', 'Section')));
      end
      else if subItem.TypeName = 'FormSpanned' then
      begin
        if subItem.ChildCount() > 0 then
        begin
          w1 := BuildWidgetTree(subItem.GetChild(0), W);
          TFtFormGrid(W).AddSpanned(w1);
        end;
      end
      else
      begin
        titleStr := subItem.GetPropertyAsString('label', '');
        w1 := BuildWidgetTree(subItem, W);
        if titleStr <> '' then
          TFtFormGrid(W).AddRow(titleStr, w1)
        else if subItem.GetPropertyAsBoolean('spanned', False) then
          TFtFormGrid(W).AddSpanned(w1);
      end;
    end;
  end
  else if AItem.TypeName = 'TreeView' then
  begin
    if (iw <= 0) and (AParentWidget <> nil) and (AParentWidget.Width > ix) then
      iw := AParentWidget.Width - ix;
    if (ih <= 0) and (AParentWidget <> nil) and (AParentWidget.Height > iy) then
      ih := AParentWidget.Height - iy;
    if iw <= 0 then iw := 200;
    if ih <= 0 then ih := 200;
    W := TFtTreeView.Create(AParentWidget, ix, iy, iw, ih);
    if AItem.HasProperty('itemHeight') then
      TFtTreeView(W).ItemHeight := AItem.GetPropertyAsNumber('itemHeight', 24.0);
    if AItem.HasProperty('indentWidth') then
      TFtTreeView(W).IndentWidth := AItem.GetPropertyAsNumber('indentWidth', 16.0);
    if AItem.HasProperty('drawFrame') then
      TFtTreeView(W).DrawFrame := AItem.GetPropertyAsBoolean('drawFrame', False);
    childrenHandled := True;
    PopulateTreeNodes(AItem, nil, TFtTreeView(W));
    AttachSignals(AItem, W);
  end
  else if (AItem.TypeName = 'Table') or (AItem.TypeName = 'TableView') then
  begin
    if (iw <= 0) and (AParentWidget <> nil) and (AParentWidget.Width > ix) then
      iw := AParentWidget.Width - ix;
    if (ih <= 0) and (AParentWidget <> nil) and (AParentWidget.Height > iy) then
      ih := AParentWidget.Height - iy;
    if iw <= 0 then iw := 300;
    if ih <= 0 then ih := 200;
    W := TFtTable.Create(AParentWidget, ix, iy, iw, ih);
    if AItem.HasProperty('headerHeight') then
      TFtTable(W).HeaderHeight := AItem.GetPropertyAsNumber('headerHeight', 28.0);
    if AItem.HasProperty('rowHeight') then
      TFtTable(W).RowHeight := AItem.GetPropertyAsNumber('rowHeight', 24.0);
    if AItem.HasProperty('showGridlines') then
      TFtTable(W).ShowGridlines := AItem.GetPropertyAsBoolean('showGridlines', True);
    if AItem.HasProperty('zebraStriping') then
      TFtTable(W).ZebraStriping := AItem.GetPropertyAsBoolean('zebraStriping', True);
    if AItem.HasProperty('multiSelect') then
      TFtTable(W).MultiSelect := AItem.GetPropertyAsBoolean('multiSelect', False);
    if AItem.HasProperty('drawFrame') then
      TFtTable(W).DrawFrame := AItem.GetPropertyAsBoolean('drawFrame', False);

    childrenHandled := True;
    for i := 0 to AItem.ChildCount() - 1 do
    begin
      subItem := AItem.GetChild(i);
      if (subItem.TypeName = 'TableColumn') or (subItem.TypeName = 'Column') then
      begin
        titleStr := subItem.GetPropertyAsString('title', subItem.GetPropertyAsString('text', 'Column'));
        padVal := subItem.GetPropertyAsNumber('width', 100.0);
        alignStr := LowerCase(subItem.GetPropertyAsString('align', 'left'));
        textAlign := ftaLeft;
        if alignStr = 'center' then textAlign := ftaCenter
        else if (alignStr = 'right') or (alignStr = 'end') then textAlign := ftaRight;
        TFtTable(W).AddColumn(titleStr, padVal, textAlign);
      end
      else if (subItem.TypeName = 'TableRow') or (subItem.TypeName = 'Row') then
      begin
        rowIdx := TFtTable(W).AddRow();
        for j := 0 to subItem.ChildCount() - 1 do
        begin
          tabItem := subItem.GetChild(j);
          TFtTable(W).SetCell(rowIdx, j,
            tabItem.GetPropertyAsString('text', tabItem.GetPropertyAsString('value', '')));
        end;
        if (subItem.ChildCount() = 0) and (subItem.HasProperty('cells') or subItem.HasProperty('values')) then
        begin
          itemsVal := subItem.GetProperty('cells');
          if not itemsVal.IsArray() then
            itemsVal := subItem.GetProperty('values');
          if itemsVal.IsArray() then
          begin
            arr := itemsVal.AsArray();
            for j := 0 to arr.Length() - 1 do
              TFtTable(W).SetCell(rowIdx, j, arr.GetElement(j).ToString());
          end;
        end;
      end;
    end;

    curVal := AItem.GetPropertyAsNumber('selectedRow', -1.0);
    if curVal >= 0.0 then
      TFtTable(W).SelectedRow := Round(curVal);

    AttachSignals(AItem, W);
  end
  else if (AItem.TypeName = 'IconView') or (AItem.TypeName = 'FlowGrid') then
  begin
    if (iw <= 0) and (AParentWidget <> nil) and (AParentWidget.Width > ix) then
      iw := AParentWidget.Width - ix;
    if (ih <= 0) and (AParentWidget <> nil) and (AParentWidget.Height > iy) then
      ih := AParentWidget.Height - iy;
    if iw <= 0 then iw := 300;
    if ih <= 0 then ih := 200;
    W := TFtIconView.Create(AParentWidget, ix, iy, iw, ih);
    if AItem.HasProperty('zoomLevel') then
    begin
      zoomStr := LowerCase(AItem.GetPropertyAsString('zoomLevel'));
      if zoomStr = 'small' then TFtIconView(W).ZoomLevel := ftizSmall
      else if zoomStr = 'normal' then TFtIconView(W).ZoomLevel := ftizNormal
      else if zoomStr = 'large' then TFtIconView(W).ZoomLevel := ftizLarge
      else if zoomStr = 'huge' then TFtIconView(W).ZoomLevel := ftizHuge;
    end;
    if AItem.HasProperty('iconSize') then
      TFtIconView(W).IconSize := Round(AItem.GetPropertyAsNumber('iconSize', 48.0));
    if AItem.HasProperty('itemWidth') then
      TFtIconView(W).ItemWidth := AItem.GetPropertyAsNumber('itemWidth', 96.0);
    if AItem.HasProperty('itemHeight') then
      TFtIconView(W).ItemHeight := AItem.GetPropertyAsNumber('itemHeight', 88.0);
    if AItem.HasProperty('spacingX') then
      TFtIconView(W).SpacingX := AItem.GetPropertyAsNumber('spacingX', 12.0);
    if AItem.HasProperty('spacingY') then
      TFtIconView(W).SpacingY := AItem.GetPropertyAsNumber('spacingY', 12.0);
    if AItem.HasProperty('multiSelect') then
      TFtIconView(W).MultiSelect := AItem.GetPropertyAsBoolean('multiSelect', False);
    if AItem.HasProperty('drawFrame') then
      TFtIconView(W).DrawFrame := AItem.GetPropertyAsBoolean('drawFrame', False);

    childrenHandled := True;
    for i := 0 to AItem.ChildCount() - 1 do
    begin
      subItem := AItem.GetChild(i);
      if (subItem.TypeName = 'IconItem') or (subItem.TypeName = 'Item') then
      begin
        titleStr := subItem.GetPropertyAsString('caption', subItem.GetPropertyAsString('text', ''));
        rowIdx := TFtIconView(W).AddItem(titleStr);
        if subItem.HasProperty('subtext') then
          TFtIconView(W).Subtexts[rowIdx] := subItem.GetPropertyAsString('subtext');
      end;
    end;

    curVal := AItem.GetPropertyAsNumber('selectedIndex', -1.0);
    if curVal >= 0.0 then
      TFtIconView(W).SelectedIndex := Round(curVal);

    AttachSignals(AItem, W);
  end
  else if (AItem.TypeName = 'PopupMenu') or (AItem.TypeName = 'ContextMenu') then
  begin
    W := TFtPopupMenu.Create(AParentWidget);
    rad := AItem.GetPropertyAsNumber('radius', AItem.GetPropertyAsNumber('cornerRadius', 0.0));
    if rad > 0.0 then
      TFtPopupMenu(W).CornerRadius := rad;
    if (AParentWidget <> nil) and (AParentWidget <> Self) and (AParentWidget.ContextMenuHandle = nil) then
      AParentWidget.ContextMenuHandle := W.Handle;
    childrenHandled := True;
    for i := 0 to AItem.ChildCount() - 1 do
    begin
      subItem := AItem.GetChild(i);
      if subItem.TypeName = 'Separator' then
        TFtPopupMenu(W).AddSeparator()
      else if (subItem.TypeName = 'Menu') or (subItem.TypeName = 'SubMenu') then
      begin
        titleStr := subItem.GetPropertyAsString('title', subItem.GetPropertyAsString('text', 'SubMenu'));
        popup := TFtPopupMenu.Create(W);
        for j := 0 to subItem.ChildCount() - 1 do
        begin
          tabItem := subItem.GetChild(j);
          if tabItem.TypeName = 'Separator' then
            popup.AddSeparator()
          else if (tabItem.TypeName = 'MenuItem') or (tabItem.TypeName = 'Action') then
          begin
            if tabItem.GetPropertyAsBoolean('checkable', False) then
              mi := popup.AddCheckItem(
                tabItem.GetPropertyAsString('text', ''),
                tabItem.GetPropertyAsBoolean('checked', False))
            else
              mi := popup.AddItem(
                tabItem.GetPropertyAsString('text', ''));
            if tabItem.HasProperty('shortcut') then
              mi.Shortcut := tabItem.GetPropertyAsString('shortcut', '');
            bridge := TFtFTMLSignalBridge.Create(Self, tabItem);
            FBridges.Add(bridge);
            mi.OnClick := @bridge.HandleMenuItemClick;
            AddMenuItemBinding(tabItem, mi);
          end;
        end;
        TFtPopupMenu(W).AddSubMenu(titleStr, popup);
      end
      else if (subItem.TypeName = 'MenuItem') or (subItem.TypeName = 'Action') then
      begin
        if subItem.GetPropertyAsBoolean('checkable', False) then
          mi := TFtPopupMenu(W).AddCheckItem(
            subItem.GetPropertyAsString('text', ''),
            subItem.GetPropertyAsBoolean('checked', False))
        else
          mi := TFtPopupMenu(W).AddItem(
            subItem.GetPropertyAsString('text', ''));
        if subItem.HasProperty('shortcut') then
          mi.Shortcut := subItem.GetPropertyAsString('shortcut', '');
        bridge := TFtFTMLSignalBridge.Create(Self, subItem);
        FBridges.Add(bridge);
        mi.OnClick := @bridge.HandleMenuItemClick;
        AddMenuItemBinding(subItem, mi);
      end;
    end;
  end
  else
  begin
    { Generic fallback container }
    W := TFtContainer.Create(AParentWidget, ix, iy, iw, ih);
    TFtContainer(W).ScrollBarMode := ftsbmNone;
    TFtContainer(W).SetPadding(0.0, 0.0);
  end;

  { Generic, type-independent presentation properties }
  if W <> nil then
  begin
    fnt := AItem.GetPropertyAsString('font', '');
    if fnt <> '' then
      W.Font := fnt;
    opa := AItem.GetPropertyAsNumber('opacity', 1.0);
    if (opa >= 0.0) and (opa < 1.0) then
      W.Opacity := opa;
    if AItem.HasProperty('enabled') then
      W.Enabled := AItem.GetPropertyAsBoolean('enabled', True);
    hintStr := AItem.GetPropertyAsString('hint', '');
    if hintStr = '' then
      hintStr := AItem.GetPropertyAsString('tooltip', '');
    if hintStr <> '' then
      W.Hint := hintStr;
    clsStr := AItem.GetPropertyAsString('styleClass', '');
    if clsStr <> '' then
      W.StyleClass := clsStr;
    if AItem.Id <> '' then
      W.StyleId := AItem.Id;
    styleStr := AItem.GetPropertyAsString('style', '');
    if styleStr <> '' then
      W.Style := styleStr;
    if AItem.HasProperty('drawFrame') and (W is TFtContainer) then
      TFtContainer(W).DrawFrame := AItem.GetPropertyAsBoolean('drawFrame', False);
  end;

  // Apply child layout constraints on native widget
  if (W <> nil) and (W <> Self) then
  begin
    flexG := AItem.GetPropertyAsNumber('flexGrow', 0.0);
    if flexG > 0.0 then
      W.FlexGrow := flexG;

    flexS := AItem.GetPropertyAsNumber('flexShrink', 1.0);
    if flexS <> 1.0 then
      W.FlexShrink := flexS;

    flexB := AItem.GetPropertyAsNumber('flexBasis', 0.0);
    if flexB > 0.0 then
      W.FlexBasis := flexB;

    alignStr := LowerCase(AItem.GetPropertyAsString('alignSelf', 'auto'));
    if (alignStr = 'flex-start') or (alignStr = 'start') then
      W.AlignSelf := ftasStart
    else if (alignStr = 'flex-end') or (alignStr = 'end') then
      W.AlignSelf := ftasEnd
    else if alignStr = 'center' then
      W.AlignSelf := ftasCenter
    else if alignStr = 'stretch' then
      W.AlignSelf := ftasStretch
    else
      W.AlignSelf := ftasAuto;

    if (AParentWidget is TFtGrid) or AItem.HasProperty('gridColumn') or AItem.HasProperty('gridRow') or
       AItem.HasProperty('colSpan') or AItem.HasProperty('rowSpan') then
    begin
      gridC := Round(AItem.GetPropertyAsNumber('gridColumn', 0.0));
      gridR := Round(AItem.GetPropertyAsNumber('gridRow', 0.0));
      colS := Round(AItem.GetPropertyAsNumber('colSpan', 1.0));
      rowS := Round(AItem.GetPropertyAsNumber('rowSpan', 1.0));
      if gridC < 0 then gridC := 0;
      if gridR < 0 then gridR := 0;
      if colS < 1 then colS := 1;
      if rowS < 1 then rowS := 1;
      W.SetGridCell(gridC, gridR, colS, rowS);

      if AParentWidget is TFtGrid then
        TFtGrid(AParentWidget).AddWidget(W, gridC, gridR, colS, rowS);
    end;

    // Conflict detection: position anchors inside layout container
    if AItem.HasAnchors() and ((AParentWidget is TFtFlexBox) or (AParentWidget is TFtGrid)) then
      WriteLn('[FTML Notice] Position anchors ignored on item "', AItem.Id, '" inside layout container "', AParentWidget.ClassName, '"');
  end;

  if (W <> nil) and (W <> Self) then
  begin
    W.Visible := AItem.Visible;
    W.Enabled := AItem.GetPropertyAsBoolean('enabled', True);
  end;

  RegisterBinding(AItem, W);
  DoWidgetCreated(AItem, W);

  { Recursively instantiate child items }
  if not childrenHandled then
    for i := 0 to AItem.ChildCount() - 1 do
      BuildWidgetTree(AItem.GetChild(i), W);

  Result := W;
end;

function FindAncestorWindow(AWidget: TFtWidget): TFtWindow;
var
  w: TFtWidget;
begin
  w := AWidget;
  while (w <> nil) and not (w is TFtWindow) do
    w := w.Parent;
  if w is TFtWindow then
    Result := TFtWindow(w)
  else
    Result := nil;
end;

function TFtFTMLHost.LoadString(const ASource: string): TFloriaFTMLItem;
var
  win: TFtWindow;
begin
  ClearBindings();

  FRootItem := FEngine.LoadString(ASource);
  if FRootItem = nil then
  begin
    FLastError := FEngine.LastError;
    Exit(nil);
  end;

  HookAncestorWindow();
  win := FindAncestorWindow(Self);
  if win <> nil then
  begin
    if FRootItem.HasProperty('extendedClientArea') or FRootItem.HasProperty('extended_client_area') then
    begin
      if FRootItem.GetPropertyAsBoolean('extendedClientArea', False) or
         FRootItem.GetPropertyAsBoolean('extended_client_area', False) then
        win.ExtendedClientArea := True;
    end
    else
      FRootItem.SetProperty('extendedClientArea', JSMakeBoolean(win.ExtendedClientArea));

    if not FRootItem.HasProperty('controlsInsetLeft') then
      FRootItem.SetProperty('controlsInsetLeft', JSMakeNumber(win.WindowControlsInset.Left));
    if not FRootItem.HasProperty('controlsInsetRight') then
      FRootItem.SetProperty('controlsInsetRight', JSMakeNumber(win.WindowControlsInset.Right));
    if not FRootItem.HasProperty('controlsInsetTop') then
      FRootItem.SetProperty('controlsInsetTop', JSMakeNumber(win.WindowControlsInset.Top));
    if not FRootItem.HasProperty('controlsInsetBottom') then
      FRootItem.SetProperty('controlsInsetBottom', JSMakeNumber(win.WindowControlsInset.Bottom));
  end
  else
  begin
    if not FRootItem.HasProperty('extendedClientArea') then
      FRootItem.SetProperty('extendedClientArea', JSMakeBoolean(False));
    if not FRootItem.HasProperty('controlsInsetLeft') then
      FRootItem.SetProperty('controlsInsetLeft', JSMakeNumber(0));
    if not FRootItem.HasProperty('controlsInsetRight') then
      FRootItem.SetProperty('controlsInsetRight', JSMakeNumber(0));
    if not FRootItem.HasProperty('controlsInsetTop') then
      FRootItem.SetProperty('controlsInsetTop', JSMakeNumber(0));
    if not FRootItem.HasProperty('controlsInsetBottom') then
      FRootItem.SetProperty('controlsInsetBottom', JSMakeNumber(0));
  end;

  if (Width > 0) and (Height > 0) then
  begin
    FRootItem.Width := Width;
    FRootItem.Height := Height;
  end;

  FRootWidget := BuildWidgetTree(FRootItem, Self);
  SyncProperties();
  Result := FRootItem;
end;

function TFtFTMLHost.LoadFile(const AFileName: string): TFloriaFTMLItem;
var
  win: TFtWindow;
begin
  ClearBindings();

  FRootItem := FEngine.LoadFile(AFileName);
  if FRootItem = nil then
  begin
    FLastError := FEngine.LastError;
    Exit(nil);
  end;

  HookAncestorWindow();
  win := FindAncestorWindow(Self);
  if win <> nil then
  begin
    if FRootItem.HasProperty('extendedClientArea') or FRootItem.HasProperty('extended_client_area') then
    begin
      if FRootItem.GetPropertyAsBoolean('extendedClientArea', False) or
         FRootItem.GetPropertyAsBoolean('extended_client_area', False) then
        win.ExtendedClientArea := True;
    end
    else
      FRootItem.SetProperty('extendedClientArea', JSMakeBoolean(win.ExtendedClientArea));

    if not FRootItem.HasProperty('controlsInsetLeft') then
      FRootItem.SetProperty('controlsInsetLeft', JSMakeNumber(win.WindowControlsInset.Left));
    if not FRootItem.HasProperty('controlsInsetRight') then
      FRootItem.SetProperty('controlsInsetRight', JSMakeNumber(win.WindowControlsInset.Right));
    if not FRootItem.HasProperty('controlsInsetTop') then
      FRootItem.SetProperty('controlsInsetTop', JSMakeNumber(win.WindowControlsInset.Top));
    if not FRootItem.HasProperty('controlsInsetBottom') then
      FRootItem.SetProperty('controlsInsetBottom', JSMakeNumber(win.WindowControlsInset.Bottom));
  end
  else
  begin
    if not FRootItem.HasProperty('extendedClientArea') then
      FRootItem.SetProperty('extendedClientArea', JSMakeBoolean(False));
    if not FRootItem.HasProperty('controlsInsetLeft') then
      FRootItem.SetProperty('controlsInsetLeft', JSMakeNumber(0));
    if not FRootItem.HasProperty('controlsInsetRight') then
      FRootItem.SetProperty('controlsInsetRight', JSMakeNumber(0));
    if not FRootItem.HasProperty('controlsInsetTop') then
      FRootItem.SetProperty('controlsInsetTop', JSMakeNumber(0));
    if not FRootItem.HasProperty('controlsInsetBottom') then
      FRootItem.SetProperty('controlsInsetBottom', JSMakeNumber(0));
  end;

  if (Width > 0) and (Height > 0) then
  begin
    FRootItem.Width := Width;
    FRootItem.Height := Height;
  end;

  FRootWidget := BuildWidgetTree(FRootItem, Self);
  SyncProperties();
  Result := FRootItem;
end;

function TFtFTMLHost.Evaluate(const AScript: string): TFloriaJSValue;
begin
  Result := FEngine.Evaluate(AScript);
  SyncProperties();
end;

function TFtFTMLHost.FindItem(const AId: string): TFloriaFTMLItem;
begin
  Result := FEngine.FindItemById(AId);
end;

function TFtFTMLHost.FindWidget(const AId: string): TFtWidget;
var
  i: Integer;
begin
  for i := 0 to FBindingCount - 1 do
  begin
    if (FBindings[i].Item <> nil) and (FBindings[i].Item.Id = AId) then
      Exit(FBindings[i].Widget);
  end;
  Result := nil;
end;

procedure TFtFTMLHost.RegisterFunction(const AName: string; AProc: TFloriaJSNativeProc);
begin
  if FEngine <> nil then
    FEngine.JSContext.RegisterFunction(AName, AProc);
end;

procedure TFtFTMLHost.EmitItemSignal(AItem: TFloriaFTMLItem; const ASignalName: string);
begin
  if AItem <> nil then
  begin
    AItem.EmitSignal(ASignalName);
    SyncProperties();
  end;
end;

procedure TFtFTMLHost.SyncProperties();
var
  i: Integer;
  item: TFloriaFTMLItem;
  W: TFtWidget;
  curText, curColor, alignStr, kindStr: string;
  curRad, curVal, cr, cg, cb, curFlexG: Double;
  curCheck, curVis, layoutNeeded: Boolean;
  newAlign: TFtAlignSelf;
  ix, iy, iw, ih, wx, wy: Integer;
  cx, cy, cw, ch: Double;
  btnKind: TFtWindowButtonKind;
  anchorMode: TFtAnchorMode;
begin
  if FIsSyncing then Exit;
  FIsSyncing := True;
  layoutNeeded := False;
  try
    for i := 0 to FBindingCount - 1 do
    begin
      item := FBindings[i].Item;
      W := FBindings[i].Widget;
      if (item = nil) or (W = nil) then Continue;

      // Text property sync (Buttons, Labels, Entries)
      if (W is TFtButton) or (W is TFtLabel) or (W is TFtEntry) then
      begin
        curText := item.GetPropertyAsString('text', '');
        if curText <> FBindings[i].LastText then
        begin
          if W is TFtButton then
            TFtButton(W).Caption := curText
          else if W is TFtLabel then
            TFtLabel(W).Text := curText
          else if W is TFtEntry then
            TFtEntry(W).Text := curText;
          FBindings[i].LastText := curText;
        end;
      end;

      // Color sync (Label)
      if W is TFtLabel then
      begin
        curColor := item.GetPropertyAsString('color', '');
        if curColor <> FBindings[i].LastColor then
        begin
          W.Style := 'color: ' + curColor + ';';
          if ParseHexColor(curColor, cr, cg, cb) then
            TFtLabel(W).SetColor(cr, cg, cb);
          FBindings[i].LastColor := curColor;
        end;
      end;

      // Corner radius sync
      if (W is TFtContainer) and not (W is TFtUrlEntry) then
      begin
        curRad := item.GetPropertyAsNumber('radius', item.GetPropertyAsNumber('cornerRadius', 0.0));
        if curRad <> FBindings[i].LastRadius then
        begin
          TFtContainer(W).CornerRadius := curRad;
          FBindings[i].LastRadius := curRad;
        end;
      end;

      // Boolean checked sync (Switch, CheckBox)
      if (W is TFtSwitch) or (W is TFtCheckBox) then
      begin
        curCheck := item.GetPropertyAsBoolean('checked', False);
        if curCheck <> FBindings[i].LastChecked then
        begin
          if W is TFtSwitch then
            TFtSwitch(W).Checked := curCheck
          else if W is TFtCheckBox then
            TFtCheckBox(W).Checked := curCheck;
          FBindings[i].LastChecked := curCheck;
        end;
      end;

      // Slider / ProgressBar value sync
      if W is TFtSlider then
      begin
        curVal := item.GetPropertyAsNumber('value', 0.0);
        if curVal <> FBindings[i].LastValue then
        begin
          TFtSlider(W).Value := curVal;
          FBindings[i].LastValue := curVal;
        end;
      end
      else if W is TFtProgressBar then
      begin
        curVal := item.GetPropertyAsNumber('fraction', 0.0);
        if curVal <> FBindings[i].LastValue then
        begin
          TFtProgressBar(W).Value := curVal;
          FBindings[i].LastValue := curVal;
        end;
      end
      else if W is TFtUrlEntry then
      begin
        curText := item.GetPropertyAsString('url', item.GetPropertyAsString('text', ''));
        if curText <> FBindings[i].LastText then
        begin
          TFtUrlEntry(W).Url := curText;
          FBindings[i].LastText := curText;
        end;
        curRad := item.GetPropertyAsNumber('cornerRadius', item.GetPropertyAsNumber('radius', -1.0));
        if (curRad >= 0.0) and (curRad <> FBindings[i].LastRadius) then
        begin
          TFtUrlEntry(W).CornerRadius := curRad;
          FBindings[i].LastRadius := curRad;
        end;
        curVal := item.GetPropertyAsNumber('securityState', -1.0);
        if curVal >= 0.0 then
          TFtUrlEntry(W).SecurityState := TFtUrlSecurityState(Round(curVal));
        curCheck := item.GetPropertyAsBoolean('bookmarked', False);
        if curCheck <> TFtUrlEntry(W).Bookmarked then
          TFtUrlEntry(W).Bookmarked := curCheck;
      end
      else if W is TFtComboBox then
      begin
        curVal := item.GetPropertyAsNumber('selectedIndex', -1.0);
        if (curVal >= 0.0) and (Round(curVal) <> TFtComboBox(W).SelectedIndex) then
          TFtComboBox(W).SelectedIndex := Round(curVal);
        curText := item.GetPropertyAsString('text', '');
        if (curText <> '') and (curText <> FBindings[i].LastText) then
        begin
          TFtComboBox(W).Text := curText;
          FBindings[i].LastText := curText;
        end;
      end
      else if W is TFtPathBar then
      begin
        curText := item.GetPropertyAsString('path', '');
        if (curText <> '') and (curText <> FBindings[i].LastText) then
        begin
          TFtPathBar(W).Path := curText;
          FBindings[i].LastText := curText;
        end;
      end
      else if W is TFtNumberScrubber then
      begin
        curVal := item.GetPropertyAsNumber('value', TFtNumberScrubber(W).Value);
        if curVal <> FBindings[i].LastValue then
        begin
          TFtNumberScrubber(W).Value := curVal;
          FBindings[i].LastValue := curVal;
        end;
      end
      else if W is TFtTable then
      begin
        curVal := item.GetPropertyAsNumber('selectedRow', -1.0);
        if (curVal >= 0.0) and (Round(curVal) <> TFtTable(W).SelectedRow) then
          TFtTable(W).SelectedRow := Round(curVal);
      end
      else if W is TFtFloatingBar then
      begin
        kindStr := LowerCase(item.GetPropertyAsString('anchor', ''));
        if kindStr <> '' then
        begin
          anchorMode := ftamTopCenter;
          if (kindStr = 'bottomcenter') or (kindStr = 'bottom') then anchorMode := ftamBottomCenter
          else if kindStr = 'topleft' then anchorMode := ftamTopLeft
          else if kindStr = 'topright' then anchorMode := ftamTopRight
          else if kindStr = 'bottomleft' then anchorMode := ftamBottomLeft
          else if kindStr = 'bottomright' then anchorMode := ftamBottomRight
          else if kindStr = 'center' then anchorMode := ftamCenter;
          if TFtFloatingBar(W).Anchor <> anchorMode then
          begin
            TFtFloatingBar(W).Anchor := anchorMode;
            TFtFloatingBar(W).UpdateAnchor();
          end;
        end;
      end
      else if W is TFtWindowButton then
      begin
        kindStr := LowerCase(item.GetPropertyAsString('kind', ''));
        if kindStr <> '' then
        begin
          btnKind := ftwbClose;
          if (kindStr = 'minimize') or (kindStr = 'min') then btnKind := ftwbMinimize
          else if (kindStr = 'maximize') or (kindStr = 'max') then btnKind := ftwbMaximize
          else if kindStr = 'restore' then btnKind := ftwbRestore
          else if kindStr = 'shade' then btnKind := ftwbShade
          else if kindStr = 'pin' then btnKind := ftwbPin
          else if kindStr = 'menu' then btnKind := ftwbMenu
          else if kindStr = 'add' then btnKind := ftwbAdd;
          if TFtWindowButton(W).Kind <> btnKind then
            TFtWindowButton(W).Kind := btnKind;
        end;
      end;

      // Child flex constraint sync
      if W <> Self then
      begin
        curFlexG := item.GetPropertyAsNumber('flexGrow', 0.0);
        if Abs(curFlexG - W.FlexGrow) > 0.001 then
        begin
          W.FlexGrow := curFlexG;
          layoutNeeded := True;
        end;

        alignStr := LowerCase(item.GetPropertyAsString('alignSelf', 'auto'));
        if (alignStr = 'flex-start') or (alignStr = 'start') then newAlign := ftasStart
        else if (alignStr = 'flex-end') or (alignStr = 'end') then newAlign := ftasEnd
        else if alignStr = 'center' then newAlign := ftasCenter
        else if alignStr = 'stretch' then newAlign := ftasStretch
        else newAlign := ftasAuto;
        if newAlign <> W.AlignSelf then
        begin
          W.AlignSelf := newAlign;
          layoutNeeded := True;
        end;
      end;

      // Layout container refresh
      if W is TFtFlexBox then
        TFtFlexBox(W).UpdateLayout()
      else if W is TFtGrid then
        TFtGrid(W).UpdateLayout()
      else if W is TFtFloatingBar then
        TFtFloatingBar(W).UpdateAnchor();

      // Geometry sync
      ix := Round(item.X);
      iy := Round(item.Y);
      iw := Round(item.Width);
      ih := Round(item.Height);

      if (W <> Self) and not (W is TFtMainMenu) and not (W is TFtPopupMenu) and
         not ((W.Parent is TFtFlexBox) or (W.Parent is TFtGrid)) then
      begin
        wx := ix;
        wy := iy;
        if (W.Parent <> nil) and (W.Parent <> Self) and not (W.Parent is TFtWindow) then
        begin
          if W.Parent is TFtContainer then
          begin
            TFtContainer(W.Parent).GetClientRect(cx, cy, cw, ch);
            Inc(wx, Round(cx - TFtContainer(W.Parent).ScrollX));
            Inc(wy, Round(cy - TFtContainer(W.Parent).ScrollY));
          end
          else
          begin
            Inc(wx, W.Parent.X);
            Inc(wy, W.Parent.Y);
          end;
        end;

        if (wx <> FBindings[i].LastX) or (wy <> FBindings[i].LastY) or
           (iw <> FBindings[i].LastW) or (ih <> FBindings[i].LastH) then
        begin
          if (iw > 0) and (ih > 0) then
          begin
            W.SetBounds(wx, wy, iw, ih);
            FBindings[i].LastX := wx;
            FBindings[i].LastY := wy;
            FBindings[i].LastW := iw;
            FBindings[i].LastH := ih;
            layoutNeeded := True;
          end;
        end;
      end
      else
      begin
        if (ix <> FBindings[i].LastX) or (iy <> FBindings[i].LastY) or
           (iw <> FBindings[i].LastW) or (ih <> FBindings[i].LastH) then
        begin
          FBindings[i].LastX := ix;
          FBindings[i].LastY := iy;
          FBindings[i].LastW := iw;
          FBindings[i].LastH := ih;
        end;
      end;

      // Visibility sync
      curVis := item.Visible;
      if curVis <> FBindings[i].LastVisible then
      begin
        W.Visible := curVis;
        FBindings[i].LastVisible := curVis;
        layoutNeeded := True;
      end;
    end;

    if layoutNeeded then
      Self.Invalidate();
  finally
    FIsSyncing := False;
  end;
end;

function TFtFTMLHost.GetHasErrors(): Boolean;
begin
  Result := (FLastError <> '') or (FEngine.HasErrors());
end;

procedure TFtFTMLHost.HookAncestorWindow();
var
  win: TFtWindow;
begin
  win := FindAncestorWindow(Self);
  if (win <> nil) and (win <> FAncestorWindow) then
  begin
    UnhookAncestorWindow();
    FAncestorWindow := win;
    if not (FAncestorWindow is TFtFTMLWindow) then
    begin
      if not Assigned(FAncestorWindow.OnControlsInsetChanged) then
        FAncestorWindow.OnControlsInsetChanged := @HandleAncestorControlsInsetChanged;
    end;
  end;
end;

procedure TFtFTMLHost.UnhookAncestorWindow();
begin
  if (FAncestorWindow <> nil) and not (FAncestorWindow is TFtFTMLWindow) then
  begin
    if FAncestorWindow.OnControlsInsetChanged = @HandleAncestorControlsInsetChanged then
      FAncestorWindow.OnControlsInsetChanged := nil;
  end;
  FAncestorWindow := nil;
end;

procedure TFtFTMLHost.HandleAncestorControlsInsetChanged(Sender: TObject; const AInset: TFtWindowControlsInset);
begin
  NotifyControlsInsetChanged(AInset);
end;

procedure TFtFTMLHost.NotifyControlsInsetChanged(const AInset: TFtWindowControlsInset);
begin
  if FRootItem <> nil then
  begin
    FRootItem.SetProperty('controlsInsetLeft', JSMakeNumber(AInset.Left));
    FRootItem.SetProperty('controlsInsetRight', JSMakeNumber(AInset.Right));
    FRootItem.SetProperty('controlsInsetTop', JSMakeNumber(AInset.Top));
    FRootItem.SetProperty('controlsInsetBottom', JSMakeNumber(AInset.Bottom));
    FRootItem.SetProperty('extendedClientArea', JSMakeBoolean(True));
    SyncProperties();
  end;
end;

function TFtFTMLHost.JSBeginWindowMove(const AArgs: array of TFloriaJSValue; AThis: TFloriaJSValue): TFloriaJSValue;
var
  win: TFtWindow;
  rx, ry: Integer;
begin
  win := FindAncestorWindow(Self);
  if win <> nil then
  begin
    rx := 0; ry := 0;
    if Length(AArgs) >= 1 then rx := Round(AArgs[0].ToNumber());
    if Length(AArgs) >= 2 then ry := Round(AArgs[1].ToNumber());
    win.BeginWindowMove(rx, ry);
  end;
  Result := JSMakeUndefined();
end;

function TFtFTMLHost.JSBeginWindowResize(const AArgs: array of TFloriaJSValue; AThis: TFloriaJSValue): TFloriaJSValue;
var
  win: TFtWindow;
  rx, ry, dir: Integer;
begin
  win := FindAncestorWindow(Self);
  if win <> nil then
  begin
    rx := 0; ry := 0; dir := 0;
    if Length(AArgs) >= 1 then rx := Round(AArgs[0].ToNumber());
    if Length(AArgs) >= 2 then ry := Round(AArgs[1].ToNumber());
    if Length(AArgs) >= 3 then dir := Round(AArgs[2].ToNumber());
    win.BeginWindowResize(rx, ry, dir);
  end;
  Result := JSMakeUndefined();
end;

function TFtFTMLHost.JSSetExtendedClientArea(const AArgs: array of TFloriaJSValue; AThis: TFloriaJSValue): TFloriaJSValue;
var
  win: TFtWindow;
  enable: Boolean;
begin
  win := FindAncestorWindow(Self);
  if win <> nil then
  begin
    enable := True;
    if Length(AArgs) >= 1 then enable := AArgs[0].ToBoolean();
    win.ExtendedClientArea := enable;
    if FRootItem <> nil then
    begin
      FRootItem.SetProperty('extendedClientArea', JSMakeBoolean(enable));
      FRootItem.SetProperty('controlsInsetLeft', JSMakeNumber(win.WindowControlsInset.Left));
      FRootItem.SetProperty('controlsInsetRight', JSMakeNumber(win.WindowControlsInset.Right));
      FRootItem.SetProperty('controlsInsetTop', JSMakeNumber(win.WindowControlsInset.Top));
      FRootItem.SetProperty('controlsInsetBottom', JSMakeNumber(win.WindowControlsInset.Bottom));
    end;
  end;
  Result := JSMakeUndefined();
end;

function TFtFTMLHost.JSIsExtendedClientArea(const AArgs: array of TFloriaJSValue; AThis: TFloriaJSValue): TFloriaJSValue;
var
  win: TFtWindow;
begin
  win := FindAncestorWindow(Self);
  if win <> nil then
    Result := JSMakeBoolean(win.ExtendedClientArea)
  else
    Result := JSMakeBoolean(False);
end;

{ TFtFTMLWindow }

constructor TFtFTMLWindow.Create(AWidth, AHeight: Integer; const ATitle: string);
begin
  inherited Create(AWidth, AHeight, ATitle);
  FHost := TFtFTMLHost.Create(Self, 0, 0, AWidth, AHeight);
end;

destructor TFtFTMLWindow.Destroy();
begin
  inherited Destroy();
end;

function TFtFTMLWindow.GetEngine(): TFloriaFTMLEngine;
begin
  Result := FHost.Engine;
end;

function TFtFTMLWindow.GetRootItem(): TFloriaFTMLItem;
begin
  Result := FHost.RootItem;
end;

procedure TFtFTMLWindow.DoResize(ANewWidth, ANewHeight: Integer);
begin
  inherited DoResize(ANewWidth, ANewHeight);
  if FHost <> nil then
  begin
    FHost.SetBounds(0, 0, ANewWidth, ANewHeight);
    if FHost.RootItem <> nil then
    begin
      FHost.RootItem.Width := ANewWidth;
      FHost.RootItem.Height := ANewHeight;
    end;
    FHost.SyncProperties();
  end;
end;

procedure TFtFTMLWindow.DoControlsInsetChanged(const AInset: TFtWindowControlsInset);
begin
  inherited DoControlsInsetChanged(AInset);
  if FHost <> nil then
    FHost.NotifyControlsInsetChanged(AInset);
end;

procedure TFtFTMLWindow.SetBounds(AX, AY, AWidth, AHeight: Integer);
begin
  inherited SetBounds(AX, AY, AWidth, AHeight);
  DoResize(AWidth, AHeight);
end;

function TFtFTMLWindow.LoadString(const ASource: string): TFloriaFTMLItem;
begin
  Result := FHost.LoadString(ASource);
  if Result <> nil then
    DoResize(Width, Height);
end;

function TFtFTMLWindow.LoadFile(const AFileName: string): TFloriaFTMLItem;
begin
  Result := FHost.LoadFile(AFileName);
  if Result <> nil then
    DoResize(Width, Height);
end;

function TFtFTMLWindow.Evaluate(const AScript: string): TFloriaJSValue;
begin
  Result := FHost.Evaluate(AScript);
end;

function TFtFTMLWindow.FindItem(const AId: string): TFloriaFTMLItem;
begin
  Result := FHost.FindItem(AId);
end;

function TFtFTMLWindow.FindWidget(const AId: string): TFtWidget;
begin
  Result := FHost.FindWidget(AId);
end;

function TFtFTMLWindow.FindMenuItem(const AId: string): TFtMenuItem;
begin
  Result := FHost.FindMenuItem(AId);
end;

procedure TFtFTMLWindow.RegisterFunction(const AName: string; AProc: TFloriaJSNativeProc);
begin
  FHost.RegisterFunction(AName, AProc);
end;

procedure TFtFTMLWindow.SyncProperties();
begin
  FHost.SyncProperties();
end;

{ TFtFTMLForm }

constructor TFtFTMLForm.Create(AWidth, AHeight: Integer; const ATitle: string;
  const ADesignName: string);
begin
  inherited Create(AWidth, AHeight, ATitle);
  if ADesignName <> '' then
    FDesignName := ADesignName
  else
    FDesignName := GetDefaultDesignName();
  FDesignFileName := '';
  FExternalDesign := False;
  LoadDesign();
end;

function TFtFTMLForm.GetDefaultDesignName(): string;
begin
  Result := ClassName;
  if (Length(Result) > 1) and (Result[1] = 'T') then
    Delete(Result, 1, 1);
end;

function TFtFTMLForm.FindDesignFile(const AName: string): string;
var
  dirs: array[0..4] of string;
  i: Integer;
  candidate: string;
begin
  Result := '';
  if AName = '' then Exit;

  dirs[0] := GetEnvironmentVariable('FTML_DESIGN_DIR');
  dirs[1] := ExtractFilePath(ParamStr(0));
  dirs[2] := IncludeTrailingPathDelimiter(GetCurrentDir());
  dirs[3] := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'design' + PathDelim;
  dirs[4] := IncludeTrailingPathDelimiter(GetCurrentDir()) + 'design' + PathDelim;

  for i := Low(dirs) to High(dirs) do
  begin
    if dirs[i] = '' then Continue;
    candidate := IncludeTrailingPathDelimiter(dirs[i]) + AName + '.ftml';
    if FileExists(candidate) then
      Exit(candidate);
    candidate := IncludeTrailingPathDelimiter(dirs[i]) + AName;
    if FileExists(candidate) then
      Exit(candidate);
  end;
end;

function TFtFTMLForm.ResolveDesign(out ASource, AFileName: string): Boolean;
var
  fn: string;
begin
  Result := False;
  ASource := '';
  AFileName := '';
  FExternalDesign := False;

  { 1. Developer override: an .ftml file on disk wins over the embedded copy. }
  fn := FindDesignFile(FDesignName);
  if fn = '' then
    fn := FindDesignFile(ClassName);
  if fn <> '' then
  begin
    FExternalDesign := True;
    AFileName := fn;
    Exit(True);
  end;

  { 2. Native embedded FPC resource via ReadComponentRes }
  if ftpas.ftml.ReadComponentRes(FDesignName, ASource) then
  begin
    AFileName := FDesignName;
    Exit(True);
  end;
  if ftpas.ftml.ReadComponentRes(ClassName, ASource) then
  begin
    AFileName := ClassName;
    Exit(True);
  end;

  { 3. Fallback: check registered in-memory FTML resource }
  if EmbeddedFTMLSource(FDesignName, ASource, AFileName) then
    Exit(True);
  if EmbeddedFTMLSource(ClassName, ASource, AFileName) then
    Exit(True);

  Result := False;
end;

function ReadComponentRes(const AResName: string; out ASource: string): Boolean;
var
  H: TFPResourceHandle;
  Stream: TResourceStream;
  ActualName: string;
begin
  Result := False;
  ASource := '';
  if AResName = '' then Exit;

  { 1. Check FPC native resource compiled with {$R ...} as RT_RCDATA }
  ActualName := UpperCase(AResName);
  H := system.FindResource(HInstance, ActualName, RT_RCDATA);
  if PtrInt(H) = 0 then
  begin
    ActualName := AResName;
    H := system.FindResource(HInstance, ActualName, RT_RCDATA);
  end;

  if PtrInt(H) <> 0 then
  begin
    Stream := TResourceStream.Create(HInstance, ActualName, RT_RCDATA);
    try
      if Stream.Size > 0 then
      begin
        SetLength(ASource, Stream.Size);
        Stream.ReadBuffer(ASource[1], Stream.Size);
        Result := True;
      end;
    finally
      Stream.Free();
    end;
    Exit;
  end;

  { 2. Fallback: check registered in-memory FTML resource }
  Result := EmbeddedFTMLSource(AResName, ASource, ActualName) or
            EmbeddedFTMLSource(UpperCase(AResName), ASource, ActualName);
end;

function ReadComponentRes(const AResName: string; AForm: TFtFTMLForm): Boolean;
var
  src: string;
begin
  Result := False;
  if (AForm = nil) or (AResName = '') then Exit;
  if not ReadComponentRes(AResName, src) then Exit;
  Result := AForm.LoadString(src) <> nil;
  if Result and (AForm.Width > 0) and (AForm.Height > 0) then
    AForm.DoResize(AForm.Width, AForm.Height);
end;

function InitComponentRes(const AResName: string; AForm: TFtFTMLForm): Boolean;
begin
  Result := ReadComponentRes(AResName, AForm);
end;

function TFtFTMLForm.ReadComponentRes(const AResName: string): Boolean;
begin
  Result := ftpas.ftml.ReadComponentRes(AResName, Self);
end;

procedure TFtFTMLForm.LoadDesign();
var
  src, fn: string;
begin
  if not ResolveDesign(src, fn) then
  begin
    WriteLn(StdErr, '[FTML] No embedded resource or .ftml file for form "',
      ClassName, '" (design name "', FDesignName, '").');
    FDesignFileName := '';
    Exit;
  end;

  FDesignFileName := fn;
  if FExternalDesign then
  begin
    if LoadFile(fn) = nil then
      WriteLn(StdErr, '[FTML] ', Host.LastError);
  end
  else if LoadString(src) = nil then
    WriteLn(StdErr, '[FTML] ', Host.LastError);

  if (Width > 0) and (Height > 0) then
    DoResize(Width, Height);
end;

end.
