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
  ftpas.controls, ftpas.layouts;

type
  { Forward Declarations }
  TFtFTMLHost = class;
  TFtFTMLWindow = class;

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
  end;

  { TFtFTMLHost — Container widget hosting an FTML component hierarchy }
  TFtFTMLHost = class(TFtContainer)
  private
    FEngine: TFloriaFTMLEngine;
    FRootItem: TFloriaFTMLItem;
    FRootWidget: TFtWidget;
    FBindings: array of TFtFTMLItemBinding;
    FBindingCount: Integer;
    FBridges: TFPList;
    FIsSyncing: Boolean;
    FLastError: string;

    procedure ClearBindings();
    procedure RegisterBinding(AItem: TFloriaFTMLItem; AWidget: TFtWidget);
    function  BuildWidgetTree(AItem: TFloriaFTMLItem; AParentWidget: TFtWidget): TFtWidget;
    procedure AttachSignals(AItem: TFloriaFTMLItem; AWidget: TFtWidget);
    function  GetHasErrors(): Boolean;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer); reintroduce;
    destructor Destroy(); override;

    function  LoadString(const ASource: string): TFloriaFTMLItem;
    function  LoadFile(const AFileName: string): TFloriaFTMLItem;
    function  Evaluate(const AScript: string): TFloriaJSValue;
    function  FindItem(const AId: string): TFloriaFTMLItem;
    function  FindWidget(const AId: string): TFtWidget;
    procedure RegisterFunction(const AName: string; AProc: TFloriaJSNativeProc);

    procedure SyncProperties();
    procedure EmitItemSignal(AItem: TFloriaFTMLItem; const ASignalName: string);

    property Engine: TFloriaFTMLEngine read FEngine;
    property RootItem: TFloriaFTMLItem read FRootItem;
    property RootWidget: TFtWidget read FRootWidget;
    property LastError: string read FLastError;
    property HasErrors: Boolean read GetHasErrors;
  end;

  { TFtFTMLWindow — Window class hosting an FTML component tree }
  TFtFTMLWindow = class(TFtWindow)
  private
    FHost: TFtFTMLHost;
    function  GetEngine(): TFloriaFTMLEngine;
    function  GetRootItem(): TFloriaFTMLItem;
  protected
    procedure DoResize(ANewWidth, ANewHeight: Integer); override;
  public
    constructor Create(AWidth, AHeight: Integer; const ATitle: string = ''); reintroduce;
    destructor Destroy(); override;

    procedure SetBounds(AX, AY, AWidth, AHeight: Integer);
    function  LoadString(const ASource: string): TFloriaFTMLItem;
    function  LoadFile(const AFileName: string): TFloriaFTMLItem;
    function  Evaluate(const AScript: string): TFloriaJSValue;
    function  FindItem(const AId: string): TFloriaFTMLItem;
    function  FindWidget(const AId: string): TFtWidget;
    procedure RegisterFunction(const AName: string; AProc: TFloriaJSNativeProc);
    procedure SyncProperties();

    property Host: TFtFTMLHost read FHost;
    property Engine: TFloriaFTMLEngine read GetEngine;
    property RootItem: TFloriaFTMLItem read GetRootItem;
  end;

implementation

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

{ TFtFTMLHost }

constructor TFtFTMLHost.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer);
begin
  inherited Create(AParent, AX, AY, AW, AH);
  ScrollBarMode := ftsbmNone;
  SetPadding(0.0, 0.0);
  FEngine := TFloriaFTMLEngine.Create();
  FRootItem := nil;
  FRootWidget := nil;
  FBindingCount := 0;
  SetLength(FBindings, 0);
  FBridges := TFPList.Create();
  FIsSyncing := False;
  FLastError := '';
end;

destructor TFtFTMLHost.Destroy();
begin
  ClearBindings();
  FreeAndNil(FBridges);
  FreeAndNil(FEngine);
  inherited Destroy();
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
  FBindings[FBindingCount].LastX := Round(AItem.X);
  FBindings[FBindingCount].LastY := Round(AItem.Y);
  FBindings[FBindingCount].LastW := Round(AItem.Width);
  FBindings[FBindingCount].LastH := Round(AItem.Height);
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
  i: Integer;
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

  if (AItem = FRootItem) and ((AItem.TypeName = 'Rectangle') or (AItem.TypeName = 'Card')) then
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
  end
  else if (AItem.TypeName = 'Rectangle') or (AItem.TypeName = 'Card') then
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
  else if AItem.TypeName = 'Button' then
  begin
    if iw <= 0 then iw := 120;
    if ih <= 0 then ih := 36;
    cap := AItem.GetPropertyAsString('text', 'Button');
    W := TFtButton.Create(AParentWidget, ix, iy, iw, ih, cap);
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
  else
  begin
    { Generic fallback container }
    W := TFtContainer.Create(AParentWidget, ix, iy, iw, ih);
    TFtContainer(W).ScrollBarMode := ftsbmNone;
    TFtContainer(W).SetPadding(0.0, 0.0);
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

  RegisterBinding(AItem, W);

  { Recursively instantiate child items }
  for i := 0 to AItem.ChildCount() - 1 do
    BuildWidgetTree(AItem.GetChild(i), W);

  Result := W;
end;

function TFtFTMLHost.LoadString(const ASource: string): TFloriaFTMLItem;
begin
  ClearBindings();

  FRootItem := FEngine.LoadString(ASource);
  if FRootItem = nil then
  begin
    FLastError := FEngine.LastError;
    Exit(nil);
  end;

  FRootWidget := BuildWidgetTree(FRootItem, Self);
  SyncProperties();
  Result := FRootItem;
end;

function TFtFTMLHost.LoadFile(const AFileName: string): TFloriaFTMLItem;
begin
  ClearBindings();

  FRootItem := FEngine.LoadFile(AFileName);
  if FRootItem = nil then
  begin
    FLastError := FEngine.LastError;
    Exit(nil);
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
  W, curParent: TFtWidget;
  curText, curColor, alignStr: string;
  curRad, curVal, cr, cg, cb, curFlexG: Double;
  curCheck, curVis, layoutNeeded: Boolean;
  newAlign: TFtAlignSelf;
  ix, iy, iw, ih: Integer;
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
      if W is TFtContainer then
      begin
        curRad := item.GetPropertyAsNumber('radius', 0.0);
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
        TFtGrid(W).UpdateLayout();

      // Geometry sync
      ix := Round(item.X);
      iy := Round(item.Y);
      iw := Round(item.Width);
      ih := Round(item.Height);
      if (ix <> FBindings[i].LastX) or (iy <> FBindings[i].LastY) or
         (iw <> FBindings[i].LastW) or (ih <> FBindings[i].LastH) then
      begin
        if (iw > 0) and (ih > 0) then
        begin
          if (W <> Self) and not ((W.Parent is TFtFlexBox) or (W.Parent is TFtGrid)) then
          begin
            curParent := W.Parent;
            while (curParent <> nil) and (curParent <> Self) do
            begin
              Inc(ix, curParent.X);
              Inc(iy, curParent.Y);
              curParent := curParent.Parent;
            end;
            W.SetBounds(ix, iy, iw, ih);
          end;
          FBindings[i].LastX := Round(item.X);
          FBindings[i].LastY := Round(item.Y);
          FBindings[i].LastW := iw;
          FBindings[i].LastH := ih;
          layoutNeeded := True;
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

procedure TFtFTMLWindow.SetBounds(AX, AY, AWidth, AHeight: Integer);
begin
  inherited SetBounds(AX, AY, AWidth, AHeight);
  DoResize(AWidth, AHeight);
end;

function TFtFTMLWindow.LoadString(const ASource: string): TFloriaFTMLItem;
begin
  Result := FHost.LoadString(ASource);
end;

function TFtFTMLWindow.LoadFile(const AFileName: string): TFloriaFTMLItem;
begin
  Result := FHost.LoadFile(AFileName);
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

procedure TFtFTMLWindow.RegisterFunction(const AName: string; AProc: TFloriaJSNativeProc);
begin
  FHost.RegisterFunction(AName, AProc);
end;

procedure TFtFTMLWindow.SyncProperties();
begin
  FHost.SyncProperties();
end;

end.
