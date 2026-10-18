{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal Standard Controls                  }
{                                                                          }
{   Provides OOP wrappers for buttons, switches, checkboxes, entries,      }
{   labels, textareas, comboboxes, sliders, progress bars, images,         }
{   scrollbars, path bars, and url entries.                                }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.controls;

{$mode objfpc}{$H+}

interface

uses
  ctypes, Classes, SysUtils, ftpas.api, ftpas.types, ftpas.canvas, ftpas.widget;

type
  { Forward Declarations }
  TFtButton = class;
  TFtWindowButton = class;
  TFtSwitch = class;
  TFtCheckBox = class;
  TFtRadioButton = class;
  TFtLabel = class;
  TFtText = TFtLabel;
  TFtEntry = class;
  TFtTextArea = class;
  TFtComboBox = class;
  TFtSlider = class;
  TFtProgressBar = class;
  TFtImage = class;
  TFtScrollBar = class;
  TFtPathBar = class;
  TFtUrlEntry = class;

  { Event Signatures }
  TFtButtonClickEvent     = procedure(Sender: TFtButton) of object;
  TFtButtonHoverEvent     = procedure(Sender: TFtButton; Hovered: Boolean) of object;
  TFtButtonPressEvent     = procedure(Sender: TFtButton; Pressed: Boolean) of object;
  TFtButtonToggleEvent    = procedure(Sender: TFtButton; Toggled: Boolean) of object;

  TFtWindowButtonClickEvent = procedure(Sender: TFtWindowButton) of object;

  TFtSwitchToggleEvent    = procedure(Sender: TFtSwitch; Toggled: Boolean) of object;
  TFtSwitchChangeEvent   = procedure(Sender: TFtSwitch; Checked: Boolean) of object;

  TFtCheckChangeEvent    = procedure(Sender: TFtCheckBox; Checked: Boolean) of object;
  TFtRadioChangeEvent    = procedure(Sender: TFtRadioButton; Checked: Boolean) of object;

  TFtTextChangeEvent     = procedure(Sender: TFtWidget; const Text: string) of object;
  TFtTextSubmitEvent     = procedure(Sender: TFtWidget; const Text: string) of object;

  TFtComboChangeEvent    = procedure(Sender: TFtComboBox; SelectedIndex: Integer; const Text: string) of object;
  TFtSliderChangeEvent   = procedure(Sender: TFtSlider; Value: Double) of object;
  TFtScrollEvent         = procedure(Sender: TFtWidget; Value: Double) of object;

  TFtPathNavigateEvent   = procedure(Sender: TFtPathBar; const Path: string) of object;
  TFtPathModeChangeEvent = procedure(Sender: TFtPathBar; Mode: TFtPathBarMode) of object;

  TFtUrlSubmitEvent      = procedure(Sender: TFtUrlEntry; const Url: string) of object;
  TFtUrlSecurityEvent    = procedure(Sender: TFtUrlEntry; SecurityState: TFtUrlSecurityState) of object;
  TFtUrlBookmarkEvent    = procedure(Sender: TFtUrlEntry; Bookmarked: Boolean) of object;

  { TFtButton — Push button and toggle button }
  TFtButton = class(TFtWidget)
  private
    FCaption: string;
    FOnClick: TFtButtonClickEvent;
    FOnHover: TFtButtonHoverEvent;
    FOnPress: TFtButtonPressEvent;
    FOnToggle: TFtButtonToggleEvent;

    function  GetCaption: string;
    procedure SetCaption(const AValue: string);
    function  GetCornerRadius: Double;
    procedure SetCornerRadius(AValue: Double);
    function  GetShadow: Boolean;
    procedure SetShadow(AValue: Boolean);
    function  GetIsToggle: Boolean;
    procedure SetIsToggle(AValue: Boolean);
    function  GetToggled: Boolean;
    procedure SetToggled(AValue: Boolean);
    function  GetState: TFtButtonState;
    function  GetIconPosition: TFtButtonIconPosition;
    procedure SetIconPosition(AValue: TFtButtonIconPosition);
    function  GetIconGap: Integer;
    procedure SetIconGap(AValue: Integer);

    procedure SetOnClick(AValue: TFtButtonClickEvent);
    procedure SetOnHover(AValue: TFtButtonHoverEvent);
    procedure SetOnPress(AValue: TFtButtonPressEvent);
    procedure SetOnToggle(AValue: TFtButtonToggleEvent);
  protected
    procedure DoClick(); virtual;
    procedure DoHover(AHovered: Boolean); virtual;
    procedure DoPress(APressed: Boolean); virtual;
    procedure DoToggle(AToggled: Boolean); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const ACaption: string = ''); reintroduce;
    constructor CreateToggle(AParent: TFtWidget; AX, AY, AW, AH: Integer; const ACaption: string = '');

    procedure SetIconFile(const APath: string);
    procedure SetIconSVG(const ASVG: string);
    procedure SetIconBitmap(ABitmap: TFtBitmap; AOwnsBitmap: Boolean = False);
    procedure ClearIcon();
    procedure SetIconSize(AWidth, AHeight: Integer);
    procedure GetIconSize(out AWidth, AHeight: Integer);

    property Caption: string read GetCaption write SetCaption;
    property CornerRadius: Double read GetCornerRadius write SetCornerRadius;
    property Shadow: Boolean read GetShadow write SetShadow;
    property IsToggle: Boolean read GetIsToggle write SetIsToggle;
    property Toggled: Boolean read GetToggled write SetToggled;
    property State: TFtButtonState read GetState;
    property IconPosition: TFtButtonIconPosition read GetIconPosition write SetIconPosition;
    property IconGap: Integer read GetIconGap write SetIconGap;

    property OnClick: TFtButtonClickEvent read FOnClick write SetOnClick;
    property OnHover: TFtButtonHoverEvent read FOnHover write SetOnHover;
    property OnPress: TFtButtonPressEvent read FOnPress write SetOnPress;
    property OnToggle: TFtButtonToggleEvent read FOnToggle write SetOnToggle;
  end;

  { TFtWindowButton — Titlebar, tabs, and panel indicator button }
  TFtWindowButton = class(TFtWidget)
  private
    FOnClick: TFtWindowButtonClickEvent;
    function  GetKind: TFtWindowButtonKind;
    procedure SetKind(AValue: TFtWindowButtonKind);
    function  GetStyle: TFtWindowButtonStyle;
    procedure SetStyle(AValue: TFtWindowButtonStyle);
    function  GetGlyphArm: Double;
    procedure SetGlyphArm(AValue: Double);
    function  GetTransitionDuration: Integer;
    procedure SetTransitionDuration(AValue: Integer);
    function  GetHoverProgress: Double;
    procedure SetOnClick(AValue: TFtWindowButtonClickEvent);
  protected
    procedure DoClick(); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer;
                       AKind: TFtWindowButtonKind = ftwbClose;
                       AStyle: TFtWindowButtonStyle = ftwsSquircle); reintroduce;

    property Kind: TFtWindowButtonKind read GetKind write SetKind;
    property Style: TFtWindowButtonStyle read GetStyle write SetStyle;
    property GlyphArm: Double read GetGlyphArm write SetGlyphArm;
    property TransitionDuration: Integer read GetTransitionDuration write SetTransitionDuration;
    property HoverProgress: Double read GetHoverProgress;
    property OnClick: TFtWindowButtonClickEvent read FOnClick write SetOnClick;
  end;

  { TFtSwitch — Modern iOS/macOS styled toggle switch }
  TFtSwitch = class(TFtWidget)
  private
    FOnToggle: TFtSwitchToggleEvent;
    FOnChange: TFtSwitchChangeEvent;

    function  GetCaption: string;
    procedure SetCaption(const AValue: string);
    function  GetChecked: Boolean;
    procedure SetChecked(AValue: Boolean);
    function  GetCornerRadius: Double;
    procedure SetCornerRadius(AValue: Double);
    function  GetShadow: Boolean;
    procedure SetShadow(AValue: Boolean);
    function  GetState: Integer;
    function  GetTransitionDuration: Integer;
    procedure SetTransitionDuration(AValue: Integer);

    procedure SetOnToggle(AValue: TFtSwitchToggleEvent);
    procedure SetOnChange(AValue: TFtSwitchChangeEvent);
  protected
    procedure DoToggle(AToggled: Boolean); virtual;
    procedure DoChange(AChecked: Boolean); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const ACaption: string = ''); reintroduce;
    procedure Toggle();

    property Caption: string read GetCaption write SetCaption;
    property Checked: Boolean read GetChecked write SetChecked;
    property CornerRadius: Double read GetCornerRadius write SetCornerRadius;
    property Shadow: Boolean read GetShadow write SetShadow;
    property State: Integer read GetState;
    property TransitionDuration: Integer read GetTransitionDuration write SetTransitionDuration;

    property OnToggle: TFtSwitchToggleEvent read FOnToggle write SetOnToggle;
    property OnChange: TFtSwitchChangeEvent read FOnChange write SetOnChange;
  end;

  { TFtCheckBox — Standard desktop check box with smooth transitions }
  TFtCheckBox = class(TFtWidget)
  private
    FOnChange: TFtCheckChangeEvent;

    function  GetCaption: string;
    procedure SetCaption(const AValue: string);
    function  GetChecked: Boolean;
    procedure SetChecked(AValue: Boolean);
    function  GetCornerRadius: Double;
    procedure SetCornerRadius(AValue: Double);

    procedure SetOnChange(AValue: TFtCheckChangeEvent);
  protected
    procedure DoChange(AChecked: Boolean); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const ACaption: string = ''); reintroduce;
    procedure Toggle();

    property Caption: string read GetCaption write SetCaption;
    property Checked: Boolean read GetChecked write SetChecked;
    property CornerRadius: Double read GetCornerRadius write SetCornerRadius;
    property OnChange: TFtCheckChangeEvent read FOnChange write SetOnChange;
  end;

  { TFtRadioButton — Mutually exclusive radio option }
  TFtRadioButton = class(TFtWidget)
  private
    FOnChange: TFtRadioChangeEvent;

    function  GetCaption: string;
    procedure SetCaption(const AValue: string);
    function  GetChecked: Boolean;
    procedure SetChecked(AValue: Boolean);
    function  GetGroup: Integer;
    procedure SetGroup(AValue: Integer);

    procedure SetOnChange(AValue: TFtRadioChangeEvent);
  protected
    procedure DoChange(AChecked: Boolean); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const ACaption: string = ''); reintroduce;

    property Caption: string read GetCaption write SetCaption;
    property Checked: Boolean read GetChecked write SetChecked;
    property Group: Integer read GetGroup write SetGroup;
    property OnChange: TFtRadioChangeEvent read FOnChange write SetOnChange;
  end;

  { TFtLabel — Static or selectable text label }
  TFtLabel = class(TFtWidget)
  private
    function  GetText: string;
    procedure SetText(const AValue: string);
    function  GetAlignment: TFtTextAlign;
    procedure SetAlignment(AValue: TFtTextAlign);
    function  GetSelectable: Boolean;
    procedure SetSelectable(AValue: Boolean);
    function  GetSelectedText: string;
    function  GetWordWrap: Boolean;
    procedure SetWordWrap(AValue: Boolean);
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const AText: string = ''); reintroduce;

    procedure SetColor(R, G, B: Double);
    procedure ResetColor();
    procedure SelectAll();
    procedure ClearSelection();
    procedure Copy();

    property Text: string read GetText write SetText;
    property Alignment: TFtTextAlign read GetAlignment write SetAlignment;
    property Selectable: Boolean read GetSelectable write SetSelectable;
    property SelectedText: string read GetSelectedText;
    property WordWrap: Boolean read GetWordWrap write SetWordWrap;
  end;

  { TFtEntry — Single-line text input field }
  TFtEntry = class(TFtWidget)
  private
    FOnChange: TFtTextChangeEvent;
    FOnSubmit: TFtTextSubmitEvent;

    function  GetText: string;
    procedure SetText(const AValue: string);
    function  GetPlaceholder: string;
    procedure SetPlaceholder(const AValue: string);
    function  GetReadOnly: Boolean;
    procedure SetReadOnly(AValue: Boolean);
    procedure SetCornerRadius(AValue: Double);

    procedure SetOnChange(AValue: TFtTextChangeEvent);
    procedure SetOnSubmit(AValue: TFtTextSubmitEvent);
  protected
    procedure DoChange(const AText: string); virtual;
    procedure DoSubmit(const AText: string); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const AText: string = ''); reintroduce;

    property Text: string read GetText write SetText;
    property Placeholder: string read GetPlaceholder write SetPlaceholder;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property CornerRadius: Double write SetCornerRadius;

    property OnChange: TFtTextChangeEvent read FOnChange write SetOnChange;
    property OnSubmit: TFtTextSubmitEvent read FOnSubmit write SetOnSubmit;
  end;

  { TFtTextArea — Multi-line scrollable text editor }
  TFtTextArea = class(TFtWidget)
  private
    FOnChange: TFtTextChangeEvent;

    function  GetText: string;
    procedure SetText(const AValue: string);
    function  GetPlaceholder: string;
    procedure SetPlaceholder(const AValue: string);
    function  GetReadOnly: Boolean;
    procedure SetReadOnly(AValue: Boolean);
    procedure SetCornerRadius(AValue: Double);
    function  GetScrollBarMode: TFtScrollBarMode;
    procedure SetScrollBarMode(AValue: TFtScrollBarMode);

    procedure SetOnChange(AValue: TFtTextChangeEvent);
  protected
    procedure DoChange(const AText: string); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const AText: string = ''); reintroduce;

    property Text: string read GetText write SetText;
    property Placeholder: string read GetPlaceholder write SetPlaceholder;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property CornerRadius: Double write SetCornerRadius;
    property ScrollBarMode: TFtScrollBarMode read GetScrollBarMode write SetScrollBarMode;

    property OnChange: TFtTextChangeEvent read FOnChange write SetOnChange;
  end;

  { TFtComboBox — Dropdown list selector }
  TFtComboBox = class(TFtWidget)
  private
    FOnChange: TFtComboChangeEvent;

    function  GetItemCount: Integer;
    function  GetItem(AIndex: Integer): string;
    function  GetSelectedIndex: Integer;
    procedure SetSelectedIndex(AIndex: Integer);
    function  GetSelectedText: string;
    function  GetText: string;
    procedure SetText(const AValue: string);
    function  GetPlaceholder: string;
    procedure SetPlaceholder(const AValue: string);
    function  GetEditable: Boolean;
    procedure SetEditable(AValue: Boolean);
    function  GetCornerRadius: Double;
    procedure SetCornerRadius(AValue: Double);

    procedure SetOnChange(AValue: TFtComboChangeEvent);
  protected
    procedure DoChange(AIndex: Integer; const AText: string); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer); reintroduce;

    function  AddItem(const AItem: string): Integer;
    procedure Clear();
    procedure Popup();

    property ItemCount: Integer read GetItemCount;
    property Items[AIndex: Integer]: string read GetItem;
    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    property SelectedText: string read GetSelectedText;
    property Text: string read GetText write SetText;
    property Placeholder: string read GetPlaceholder write SetPlaceholder;
    property Editable: Boolean read GetEditable write SetEditable;
    property CornerRadius: Double read GetCornerRadius write SetCornerRadius;

    property OnChange: TFtComboChangeEvent read FOnChange write SetOnChange;
  end;

  { TFtSlider — Horizontal and vertical track slider }
  TFtSlider = class(TFtWidget)
  private
    FOnChange: TFtSliderChangeEvent;

    function  GetOrientation: TFtSliderOrientation;
    procedure SetOrientation(AValue: TFtSliderOrientation);
    function  GetMin: Double;
    function  GetMax: Double;
    function  GetValue: Double;
    procedure SetValue(AValue: Double);
    function  GetStep: Double;
    procedure SetStep(AValue: Double);
    function  GetThumbSize: Double;
    procedure SetThumbSize(AValue: Double);

    procedure SetOnChange(AValue: TFtSliderChangeEvent);
  protected
    procedure DoChange(AValue: Double); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer;
                       AOrientation: TFtSliderOrientation = ftsoHorizontal); reintroduce;

    procedure SetRange(AMin, AMax: Double);

    property Orientation: TFtSliderOrientation read GetOrientation write SetOrientation;
    property Min: Double read GetMin;
    property Max: Double read GetMax;
    property Value: Double read GetValue write SetValue;
    property Step: Double read GetStep write SetStep;
    property ThumbSize: Double read GetThumbSize write SetThumbSize;

    property OnChange: TFtSliderChangeEvent read FOnChange write SetOnChange;
  end;

  { TFtProgressBar — Continuous and indeterminate progress indicator }
  TFtProgressBar = class(TFtWidget)
  private
    function  GetOrientation: TFtProgressOrientation;
    procedure SetOrientation(AValue: TFtProgressOrientation);
    function  GetMin: Double;
    function  GetMax: Double;
    function  GetValue: Double;
    procedure SetValue(AValue: Double);
    function  GetIndeterminate: Boolean;
    procedure SetIndeterminate(AValue: Boolean);
    function  GetShowText: Boolean;
    procedure SetShowText(AValue: Boolean);
    function  GetTextFormat: string;
    procedure SetTextFormat(const AValue: string);
    function  GetCornerRadius: Double;
    procedure SetCornerRadius(AValue: Double);
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer;
                       AOrientation: TFtProgressOrientation = ftpoHorizontal); reintroduce;

    procedure SetRange(AMin, AMax: Double);

    property Orientation: TFtProgressOrientation read GetOrientation write SetOrientation;
    property Min: Double read GetMin;
    property Max: Double read GetMax;
    property Value: Double read GetValue write SetValue;
    property Indeterminate: Boolean read GetIndeterminate write SetIndeterminate;
    property ShowText: Boolean read GetShowText write SetShowText;
    property TextFormat: string read GetTextFormat write SetTextFormat;
    property CornerRadius: Double read GetCornerRadius write SetCornerRadius;
  end;

  { TFtImage — Bitmap, PNG, JPEG, and SVG display widget }
  TFtImage = class(TFtWidget)
  private
    function  GetScaleMode: TFtImageScaleMode;
    procedure SetScaleMode(AValue: TFtImageScaleMode);
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const AFilePath: string = ''); reintroduce;

    procedure LoadFile(const AFilePath: string);
    procedure LoadMemory(AData: Pointer; ASize: Integer);
    procedure LoadSVGFile(const AFilePath: string);
    procedure LoadSVGString(const ASVGContent: string);
    procedure InvalidateCache();
    procedure SetBitmap(ABitmap: TFtBitmap; AOwnsBitmap: Boolean = False);
    function  GetBitmap(): TFtBitmap;

    property ScaleMode: TFtImageScaleMode read GetScaleMode write SetScaleMode;
  end;

  { TFtScrollBar — Standalone scrollbar control }
  TFtScrollBar = class(TFtWidget)
  private
    FOnScroll: TFtScrollEvent;

    function  GetOrientation: TFtScrollBarOrientation;
    procedure SetOrientation(AValue: TFtScrollBarOrientation);
    function  GetValue: Double;
    procedure SetValue(AValue: Double);
    function  GetMin: Double;
    function  GetMax: Double;
    function  GetPageSize: Double;
    function  GetStep: Double;
    procedure SetStep(AValue: Double);
    procedure SetCornerRadius(AValue: Double);

    procedure SetOnScroll(AValue: TFtScrollEvent);
  protected
    procedure DoScroll(AValue: Double); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer;
                       AOrientation: TFtScrollBarOrientation = ftsboHorizontal); reintroduce;

    procedure SetRange(AMin, AMax, APageSize: Double);

    property Orientation: TFtScrollBarOrientation read GetOrientation write SetOrientation;
    property Value: Double read GetValue write SetValue;
    property Min: Double read GetMin;
    property Max: Double read GetMax;
    property PageSize: Double read GetPageSize;
    property Step: Double read GetStep write SetStep;
    property CornerRadius: Double write SetCornerRadius;

    property OnScroll: TFtScrollEvent read FOnScroll write SetOnScroll;
  end;

  { TFtPathBar — Nautilus-style breadcrumb path entry }
  TFtPathBar = class(TFtWidget)
  private
    FOnNavigate: TFtPathNavigateEvent;
    FOnModeChange: TFtPathModeChangeEvent;

    function  GetPath: string;
    procedure SetPath(const AValue: string);
    function  GetMode: TFtPathBarMode;
    procedure SetMode(AValue: TFtPathBarMode);
    function  GetShowEditButton: Boolean;
    procedure SetShowEditButton(AValue: Boolean);
    function  GetRootDisplayName: string;
    procedure SetRootDisplayName(const AValue: string);
    function  GetCornerRadius: Double;
    procedure SetCornerRadius(AValue: Double);

    procedure SetOnNavigate(AValue: TFtPathNavigateEvent);
    procedure SetOnModeChange(AValue: TFtPathModeChangeEvent);
  protected
    procedure DoNavigate(const APath: string); virtual;
    procedure DoModeChange(AMode: TFtPathBarMode); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const AInitialPath: string = ''); reintroduce;

    property Path: string read GetPath write SetPath;
    property Mode: TFtPathBarMode read GetMode write SetMode;
    property ShowEditButton: Boolean read GetShowEditButton write SetShowEditButton;
    property RootDisplayName: string read GetRootDisplayName write SetRootDisplayName;
    property CornerRadius: Double read GetCornerRadius write SetCornerRadius;

    property OnNavigate: TFtPathNavigateEvent read FOnNavigate write SetOnNavigate;
    property OnModeChange: TFtPathModeChangeEvent read FOnModeChange write SetOnModeChange;
  end;

  { TFtUrlEntry — Omnibox browser URL entry with security badges }
  TFtUrlEntry = class(TFtWidget)
  private
    FOnSubmit: TFtUrlSubmitEvent;
    FOnSecurityClick: TFtUrlSecurityEvent;
    FOnBookmarkClick: TFtUrlBookmarkEvent;

    function  GetUrl: string;
    procedure SetUrl(const AValue: string);
    function  GetSecurityState: TFtUrlSecurityState;
    procedure SetSecurityState(AValue: TFtUrlSecurityState);
    function  GetBookmarked: Boolean;
    procedure SetBookmarked(AValue: Boolean);
    function  GetShowSecurityChip: Boolean;
    procedure SetShowSecurityChip(AValue: Boolean);
    function  GetShowSecurityBadgeText: Boolean;
    procedure SetShowSecurityBadgeText(AValue: Boolean);
    function  GetShowBookmarkButton: Boolean;
    procedure SetShowBookmarkButton(AValue: Boolean);
    function  GetAutoPrefixHttps: Boolean;
    procedure SetAutoPrefixHttps(AValue: Boolean);
    function  GetCornerRadius: Double;
    procedure SetCornerRadius(AValue: Double);
    function  GetEditing: Boolean;
    procedure SetEditing(AValue: Boolean);

    procedure SetOnSubmit(AValue: TFtUrlSubmitEvent);
    procedure SetOnSecurityClick(AValue: TFtUrlSecurityEvent);
    procedure SetOnBookmarkClick(AValue: TFtUrlBookmarkEvent);
  protected
    procedure DoSubmit(const AUrl: string); virtual;
    procedure DoSecurityClick(ASecurityState: TFtUrlSecurityState); virtual;
    procedure DoBookmarkClick(ABookmarked: Boolean); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const AInitialUrl: string = ''); reintroduce;

    property Url: string read GetUrl write SetUrl;
    property SecurityState: TFtUrlSecurityState read GetSecurityState write SetSecurityState;
    property Bookmarked: Boolean read GetBookmarked write SetBookmarked;
    property ShowSecurityChip: Boolean read GetShowSecurityChip write SetShowSecurityChip;
    property ShowSecurityBadgeText: Boolean read GetShowSecurityBadgeText write SetShowSecurityBadgeText;
    property ShowBookmarkButton: Boolean read GetShowBookmarkButton write SetShowBookmarkButton;
    property AutoPrefixHttps: Boolean read GetAutoPrefixHttps write SetAutoPrefixHttps;
    property CornerRadius: Double read GetCornerRadius write SetCornerRadius;
    property Editing: Boolean read GetEditing write SetEditing;

    property OnSubmit: TFtUrlSubmitEvent read FOnSubmit write SetOnSubmit;
    property OnSecurityClick: TFtUrlSecurityEvent read FOnSecurityClick write SetOnSecurityClick;
    property OnBookmarkClick: TFtUrlBookmarkEvent read FOnBookmarkClick write SetOnBookmarkClick;
  end;

implementation

{ C Callback Dispatchers }

procedure ButtonClickDispatcher(AWidget: Pointer; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtButton(AUserData).DoClick();
end;

procedure ButtonHoverDispatcher(AWidget: Pointer; AHovered: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtButton(AUserData).DoHover(AHovered <> 0);
end;

procedure ButtonPressDispatcher(AWidget: Pointer; APressed: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtButton(AUserData).DoPress(APressed <> 0);
end;

procedure ButtonToggleDispatcher(AWidget: Pointer; AToggled: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtButton(AUserData).DoToggle(AToggled <> 0);
end;

procedure WindowButtonClickDispatcher(AWidget: Pointer; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtWindowButton(AUserData).DoClick();
end;

procedure SwitchToggleDispatcher(AWidget: Pointer; AToggled: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtSwitch(AUserData).DoToggle(AToggled <> 0);
end;

procedure SwitchChangeDispatcher(AWidget: Pointer; AToggled: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtSwitch(AUserData).DoChange(AToggled <> 0);
end;

procedure CheckChangeDispatcher(AWidget: Pointer; AChecked: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtCheckBox(AUserData).DoChange(AChecked <> 0);
end;

procedure RadioChangeDispatcher(AWidget: Pointer; AChecked: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtRadioButton(AUserData).DoChange(AChecked <> 0);
end;

procedure EntryChangeDispatcher(AWidget: Pointer; AText: PChar; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtEntry(AUserData).DoChange(StrPas(AText));
end;

procedure EntrySubmitDispatcher(AWidget: Pointer; AText: PChar; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtEntry(AUserData).DoSubmit(StrPas(AText));
end;

procedure TextAreaChangeDispatcher(AWidget: Pointer; AText: PChar; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtTextArea(AUserData).DoChange(StrPas(AText));
end;

procedure ComboChangeDispatcher(AWidget: Pointer; AIndex: cint32; AText: PChar; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtComboBox(AUserData).DoChange(AIndex, StrPas(AText));
end;

procedure SliderChangeDispatcher(AWidget: Pointer; AValue: Double; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtSlider(AUserData).DoChange(AValue);
end;

procedure ScrollBarScrollDispatcher(AWidget: Pointer; AValue: Double; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtScrollBar(AUserData).DoScroll(AValue);
end;

procedure PathBarNavigateDispatcher(AWidget: Pointer; APath: PChar; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtPathBar(AUserData).DoNavigate(StrPas(APath));
end;

procedure PathBarModeDispatcher(AWidget: Pointer; AMode: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtPathBar(AUserData).DoModeChange(TFtPathBarMode(AMode));
end;

procedure UrlSubmitDispatcher(AWidget: Pointer; AUrl: PChar; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtUrlEntry(AUserData).DoSubmit(StrPas(AUrl));
end;

procedure UrlSecurityDispatcher(AWidget: Pointer; ASecurity: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtUrlEntry(AUserData).DoSecurityClick(TFtUrlSecurityState(ASecurity));
end;

procedure UrlBookmarkDispatcher(AWidget: Pointer; ABookmarked: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtUrlEntry(AUserData).DoBookmarkClick(ABookmarked <> 0);
end;

{ TFtButton }

constructor TFtButton.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const ACaption: string = '');
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  FCaption := ACaption;
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_button_create) then
    h := ft_button_create(pHandle, AX, AY, AW, AH, PChar(ACaption))
  else
    h := nil;
  SetHandle(h, True);
end;

constructor TFtButton.CreateToggle(AParent: TFtWidget; AX, AY, AW, AH: Integer; const ACaption: string = '');
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  FCaption := ACaption;
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_toggle_button_create) then
    h := ft_toggle_button_create(pHandle, AX, AY, AW, AH, PChar(ACaption))
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtButton.GetCaption: string;
begin
  if (Handle <> nil) and Assigned(ft_button_get_caption) then
    Result := StrPas(ft_button_get_caption(Handle))
  else
    Result := FCaption;
end;

procedure TFtButton.SetCaption(const AValue: string);
begin
  FCaption := AValue;
  if (Handle <> nil) and Assigned(ft_button_set_caption) then
    ft_button_set_caption(Handle, PChar(AValue));
end;

function TFtButton.GetCornerRadius: Double;
begin
  if (Handle <> nil) and Assigned(ft_button_get_corner_radius) then
    Result := ft_button_get_corner_radius(Handle)
  else
    Result := -1.0;
end;

procedure TFtButton.SetCornerRadius(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_button_set_corner_radius) then
    ft_button_set_corner_radius(Handle, AValue);
end;

function TFtButton.GetShadow: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_button_get_shadow) then
    Result := (ft_button_get_shadow(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtButton.SetShadow(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_button_set_shadow) then
    ft_button_set_shadow(Handle, Ord(AValue));
end;

function TFtButton.GetIsToggle: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_button_get_toggle) then
    Result := (ft_button_get_toggle(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtButton.SetIsToggle(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_button_set_toggle) then
    ft_button_set_toggle(Handle, Ord(AValue));
end;

function TFtButton.GetToggled: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_button_get_toggled) then
    Result := (ft_button_get_toggled(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtButton.SetToggled(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_button_set_toggled) then
    ft_button_set_toggled(Handle, Ord(AValue));
end;

function TFtButton.GetState: TFtButtonState;
begin
  if (Handle <> nil) and Assigned(ft_button_get_state) then
    Result := TFtButtonState(ft_button_get_state(Handle))
  else
    Result := ftbsNormal;
end;

function TFtButton.GetIconPosition: TFtButtonIconPosition;
begin
  if (Handle <> nil) and Assigned(ft_button_get_icon_position) then
    Result := TFtButtonIconPosition(ft_button_get_icon_position(Handle))
  else
    Result := ftipLeft;
end;

procedure TFtButton.SetIconPosition(AValue: TFtButtonIconPosition);
begin
  if (Handle <> nil) and Assigned(ft_button_set_icon_position) then
    ft_button_set_icon_position(Handle, Ord(AValue));
end;

function TFtButton.GetIconGap: Integer;
begin
  if (Handle <> nil) and Assigned(ft_button_get_icon_gap) then
    Result := ft_button_get_icon_gap(Handle)
  else
    Result := 6;
end;

procedure TFtButton.SetIconGap(AValue: Integer);
begin
  if (Handle <> nil) and Assigned(ft_button_set_icon_gap) then
    ft_button_set_icon_gap(Handle, AValue);
end;

procedure TFtButton.SetIconFile(const APath: string);
begin
  if (Handle <> nil) and Assigned(ft_button_set_icon_file) then
    ft_button_set_icon_file(Handle, PChar(APath));
end;

procedure TFtButton.SetIconSVG(const ASVG: string);
begin
  if (Handle <> nil) and Assigned(ft_button_set_icon_svg) then
    ft_button_set_icon_svg(Handle, PChar(ASVG));
end;

procedure TFtButton.SetIconBitmap(ABitmap: TFtBitmap; AOwnsBitmap: Boolean = False);
begin
  if (Handle <> nil) and (ABitmap <> nil) and Assigned(ft_button_set_icon_bitmap) then
    ft_button_set_icon_bitmap(Handle, ABitmap.Handle, Ord(AOwnsBitmap));
end;

procedure TFtButton.ClearIcon();
begin
  if (Handle <> nil) and Assigned(ft_button_clear_icon) then
    ft_button_clear_icon(Handle);
end;

procedure TFtButton.SetIconSize(AWidth, AHeight: Integer);
begin
  if (Handle <> nil) and Assigned(ft_button_set_icon_size) then
    ft_button_set_icon_size(Handle, AWidth, AHeight);
end;

procedure TFtButton.GetIconSize(out AWidth, AHeight: Integer);
var
  cw, ch: cint32;
begin
  if (Handle <> nil) and Assigned(ft_button_get_icon_size) then
  begin
    ft_button_get_icon_size(Handle, cw, ch);
    AWidth := cw;
    AHeight := ch;
  end
  else
  begin
    AWidth := 16;
    AHeight := 16;
  end;
end;

procedure TFtButton.SetOnClick(AValue: TFtButtonClickEvent);
begin
  FOnClick := AValue;
  if (Handle <> nil) and Assigned(ft_button_on_click) then
    ft_button_on_click(Handle, @ButtonClickDispatcher, Self);
end;

procedure TFtButton.SetOnHover(AValue: TFtButtonHoverEvent);
begin
  FOnHover := AValue;
  if (Handle <> nil) and Assigned(ft_button_on_hover) then
    ft_button_on_hover(Handle, @ButtonHoverDispatcher, Self);
end;

procedure TFtButton.SetOnPress(AValue: TFtButtonPressEvent);
begin
  FOnPress := AValue;
  if (Handle <> nil) and Assigned(ft_button_on_press) then
    ft_button_on_press(Handle, @ButtonPressDispatcher, Self);
end;

procedure TFtButton.SetOnToggle(AValue: TFtButtonToggleEvent);
begin
  FOnToggle := AValue;
  if (Handle <> nil) and Assigned(ft_button_on_toggle) then
    ft_button_on_toggle(Handle, @ButtonToggleDispatcher, Self);
end;

procedure TFtButton.DoClick();
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

procedure TFtButton.DoHover(AHovered: Boolean);
begin
  if Assigned(FOnHover) then
    FOnHover(Self, AHovered);
end;

procedure TFtButton.DoPress(APressed: Boolean);
begin
  if Assigned(FOnPress) then
    FOnPress(Self, APressed);
end;

procedure TFtButton.DoToggle(AToggled: Boolean);
begin
  if Assigned(FOnToggle) then
    FOnToggle(Self, AToggled);
end;

{ TFtWindowButton }

constructor TFtWindowButton.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer;
                                   AKind: TFtWindowButtonKind = ftwbClose;
                                   AStyle: TFtWindowButtonStyle = ftwsSquircle);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_window_button_create) then
    h := ft_window_button_create(pHandle, AX, AY, AW, AH, Ord(AKind), Ord(AStyle))
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtWindowButton.GetKind: TFtWindowButtonKind;
begin
  if (Handle <> nil) and Assigned(ft_window_button_get_kind) then
    Result := TFtWindowButtonKind(ft_window_button_get_kind(Handle))
  else
    Result := ftwbClose;
end;

procedure TFtWindowButton.SetKind(AValue: TFtWindowButtonKind);
begin
  if (Handle <> nil) and Assigned(ft_window_button_set_kind) then
    ft_window_button_set_kind(Handle, Ord(AValue));
end;

function TFtWindowButton.GetStyle: TFtWindowButtonStyle;
begin
  if (Handle <> nil) and Assigned(ft_window_button_get_style) then
    Result := TFtWindowButtonStyle(ft_window_button_get_style(Handle))
  else
    Result := ftwsSquircle;
end;

procedure TFtWindowButton.SetStyle(AValue: TFtWindowButtonStyle);
begin
  if (Handle <> nil) and Assigned(ft_window_button_set_style) then
    ft_window_button_set_style(Handle, Ord(AValue));
end;

function TFtWindowButton.GetGlyphArm: Double;
begin
  if (Handle <> nil) and Assigned(ft_window_button_get_glyph_arm) then
    Result := ft_window_button_get_glyph_arm(Handle)
  else
    Result := 4.0;
end;

procedure TFtWindowButton.SetGlyphArm(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_window_button_set_glyph_arm) then
    ft_window_button_set_glyph_arm(Handle, AValue);
end;

function TFtWindowButton.GetTransitionDuration: Integer;
begin
  if (Handle <> nil) and Assigned(ft_window_button_get_transition_duration) then
    Result := ft_window_button_get_transition_duration(Handle)
  else
    Result := 160;
end;

procedure TFtWindowButton.SetTransitionDuration(AValue: Integer);
begin
  if (Handle <> nil) and Assigned(ft_window_button_set_transition_duration) then
    ft_window_button_set_transition_duration(Handle, AValue);
end;

function TFtWindowButton.GetHoverProgress: Double;
begin
  if (Handle <> nil) and Assigned(ft_window_button_get_hover_progress) then
    Result := ft_window_button_get_hover_progress(Handle)
  else
    Result := 0.0;
end;

procedure TFtWindowButton.SetOnClick(AValue: TFtWindowButtonClickEvent);
begin
  FOnClick := AValue;
  if (Handle <> nil) and Assigned(ft_window_button_on_click) then
    ft_window_button_on_click(Handle, @WindowButtonClickDispatcher, Self);
end;

procedure TFtWindowButton.DoClick();
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

{ TFtSwitch }

constructor TFtSwitch.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const ACaption: string = '');
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_switch_create) then
    h := ft_switch_create(pHandle, AX, AY, AW, AH, PChar(ACaption))
  else
    h := nil;
  SetHandle(h, True);
end;

procedure TFtSwitch.Toggle();
begin
  if (Handle <> nil) and Assigned(ft_switch_toggle) then
    ft_switch_toggle(Handle);
end;

function TFtSwitch.GetCaption: string;
begin
  if (Handle <> nil) and Assigned(ft_switch_get_caption) then
    Result := StrPas(ft_switch_get_caption(Handle))
  else
    Result := '';
end;

procedure TFtSwitch.SetCaption(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_switch_set_caption) then
    ft_switch_set_caption(Handle, PChar(AValue));
end;

function TFtSwitch.GetChecked: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_switch_get_checked) then
    Result := (ft_switch_get_checked(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtSwitch.SetChecked(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_switch_set_checked) then
    ft_switch_set_checked(Handle, Ord(AValue));
end;

function TFtSwitch.GetCornerRadius: Double;
begin
  if (Handle <> nil) and Assigned(ft_switch_get_corner_radius) then
    Result := ft_switch_get_corner_radius(Handle)
  else
    Result := -1.0;
end;

procedure TFtSwitch.SetCornerRadius(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_switch_set_corner_radius) then
    ft_switch_set_corner_radius(Handle, AValue);
end;

function TFtSwitch.GetShadow: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_switch_get_shadow) then
    Result := (ft_switch_get_shadow(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtSwitch.SetShadow(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_switch_set_shadow) then
    ft_switch_set_shadow(Handle, Ord(AValue));
end;

function TFtSwitch.GetState: Integer;
begin
  if (Handle <> nil) and Assigned(ft_switch_get_state) then
    Result := ft_switch_get_state(Handle)
  else
    Result := 0;
end;

function TFtSwitch.GetTransitionDuration: Integer;
begin
  if (Handle <> nil) and Assigned(ft_switch_get_transition_duration) then
    Result := ft_switch_get_transition_duration(Handle)
  else
    Result := 160;
end;

procedure TFtSwitch.SetTransitionDuration(AValue: Integer);
begin
  if (Handle <> nil) and Assigned(ft_switch_set_transition_duration) then
    ft_switch_set_transition_duration(Handle, AValue);
end;

procedure TFtSwitch.SetOnToggle(AValue: TFtSwitchToggleEvent);
begin
  FOnToggle := AValue;
  if (Handle <> nil) and Assigned(ft_switch_on_toggle) then
    ft_switch_on_toggle(Handle, @SwitchToggleDispatcher, Self);
end;

procedure TFtSwitch.SetOnChange(AValue: TFtSwitchChangeEvent);
begin
  FOnChange := AValue;
  if (Handle <> nil) and Assigned(ft_switch_on_change) then
    ft_switch_on_change(Handle, @SwitchChangeDispatcher, Self);
end;

procedure TFtSwitch.DoToggle(AToggled: Boolean);
begin
  if Assigned(FOnToggle) then
    FOnToggle(Self, AToggled);
end;

procedure TFtSwitch.DoChange(AChecked: Boolean);
begin
  if Assigned(FOnChange) then
    FOnChange(Self, AChecked);
end;

{ TFtCheckBox }

constructor TFtCheckBox.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const ACaption: string = '');
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_checkbox_create) then
    h := ft_checkbox_create(pHandle, AX, AY, AW, AH, PChar(ACaption))
  else
    h := nil;
  SetHandle(h, True);
end;

procedure TFtCheckBox.Toggle();
begin
  if (Handle <> nil) and Assigned(ft_checkbox_toggle) then
    ft_checkbox_toggle(Handle);
end;

function TFtCheckBox.GetCaption: string;
begin
  if (Handle <> nil) and Assigned(ft_checkbox_get_caption) then
    Result := StrPas(ft_checkbox_get_caption(Handle))
  else
    Result := '';
end;

procedure TFtCheckBox.SetCaption(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_checkbox_set_caption) then
    ft_checkbox_set_caption(Handle, PChar(AValue));
end;

function TFtCheckBox.GetChecked: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_checkbox_get_checked) then
    Result := (ft_checkbox_get_checked(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtCheckBox.SetChecked(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_checkbox_set_checked) then
    ft_checkbox_set_checked(Handle, Ord(AValue));
end;

function TFtCheckBox.GetCornerRadius: Double;
begin
  if (Handle <> nil) and Assigned(ft_checkbox_get_corner_radius) then
    Result := ft_checkbox_get_corner_radius(Handle)
  else
    Result := -1.0;
end;

procedure TFtCheckBox.SetCornerRadius(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_checkbox_set_corner_radius) then
    ft_checkbox_set_corner_radius(Handle, AValue);
end;

procedure TFtCheckBox.SetOnChange(AValue: TFtCheckChangeEvent);
begin
  FOnChange := AValue;
  if (Handle <> nil) and Assigned(ft_checkbox_on_toggle) then
    ft_checkbox_on_toggle(Handle, @CheckChangeDispatcher, Self);
end;

procedure TFtCheckBox.DoChange(AChecked: Boolean);
begin
  if Assigned(FOnChange) then
    FOnChange(Self, AChecked);
end;

{ TFtRadioButton }

constructor TFtRadioButton.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const ACaption: string = '');
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_radio_create) then
    h := ft_radio_create(pHandle, AX, AY, AW, AH, PChar(ACaption))
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtRadioButton.GetCaption: string;
begin
  if (Handle <> nil) and Assigned(ft_radio_get_caption) then
    Result := StrPas(ft_radio_get_caption(Handle))
  else
    Result := '';
end;

procedure TFtRadioButton.SetCaption(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_radio_set_caption) then
    ft_radio_set_caption(Handle, PChar(AValue));
end;

function TFtRadioButton.GetChecked: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_radio_get_checked) then
    Result := (ft_radio_get_checked(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtRadioButton.SetChecked(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_radio_set_checked) then
    ft_radio_set_checked(Handle, Ord(AValue));
end;

function TFtRadioButton.GetGroup: Integer;
begin
  if (Handle <> nil) and Assigned(ft_radio_get_group) then
    Result := ft_radio_get_group(Handle)
  else
    Result := 0;
end;

procedure TFtRadioButton.SetGroup(AValue: Integer);
begin
  if (Handle <> nil) and Assigned(ft_radio_set_group) then
    ft_radio_set_group(Handle, AValue);
end;

procedure TFtRadioButton.SetOnChange(AValue: TFtRadioChangeEvent);
begin
  FOnChange := AValue;
  if (Handle <> nil) and Assigned(ft_radio_on_toggle) then
    ft_radio_on_toggle(Handle, @RadioChangeDispatcher, Self);
end;

procedure TFtRadioButton.DoChange(AChecked: Boolean);
begin
  if Assigned(FOnChange) then
    FOnChange(Self, AChecked);
end;

{ TFtLabel }

constructor TFtLabel.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const AText: string = '');
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_text_create) then
    h := ft_text_create(pHandle, AX, AY, AW, AH, PChar(AText))
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtLabel.GetText: string;
begin
  if (Handle <> nil) and Assigned(ft_text_get_text) then
    Result := StrPas(ft_text_get_text(Handle))
  else
    Result := '';
end;

procedure TFtLabel.SetText(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_text_set_text) then
    ft_text_set_text(Handle, PChar(AValue));
end;

function TFtLabel.GetAlignment: TFtTextAlign;
begin
  if (Handle <> nil) and Assigned(ft_text_get_alignment) then
    Result := TFtTextAlign(ft_text_get_alignment(Handle))
  else
    Result := ftaLeft;
end;

procedure TFtLabel.SetAlignment(AValue: TFtTextAlign);
begin
  if (Handle <> nil) and Assigned(ft_text_set_alignment) then
    ft_text_set_alignment(Handle, Ord(AValue));
end;

function TFtLabel.GetSelectable: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_text_get_selectable) then
    Result := (ft_text_get_selectable(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtLabel.SetSelectable(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_text_set_selectable) then
    ft_text_set_selectable(Handle, Ord(AValue));
end;

function TFtLabel.GetSelectedText: string;
begin
  if (Handle <> nil) and Assigned(ft_text_get_selected_text) then
    Result := StrPas(ft_text_get_selected_text(Handle))
  else
    Result := '';
end;

function TFtLabel.GetWordWrap: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_text_get_word_wrap) then
    Result := (ft_text_get_word_wrap(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtLabel.SetWordWrap(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_text_set_word_wrap) then
    ft_text_set_word_wrap(Handle, Ord(AValue));
end;

procedure TFtLabel.SetColor(R, G, B: Double);
begin
  if (Handle <> nil) and Assigned(ft_text_set_color) then
    ft_text_set_color(Handle, R, G, B);
end;

procedure TFtLabel.ResetColor();
begin
  if (Handle <> nil) and Assigned(ft_text_reset_color) then
    ft_text_reset_color(Handle);
end;

procedure TFtLabel.SelectAll();
begin
  if (Handle <> nil) and Assigned(ft_text_select_all) then
    ft_text_select_all(Handle);
end;

procedure TFtLabel.ClearSelection();
begin
  if (Handle <> nil) and Assigned(ft_text_clear_selection) then
    ft_text_clear_selection(Handle);
end;

procedure TFtLabel.Copy();
begin
  if (Handle <> nil) and Assigned(ft_text_copy) then
    ft_text_copy(Handle);
end;

{ TFtEntry }

constructor TFtEntry.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const AText: string = '');
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_entry_create) then
    h := ft_entry_create(pHandle, AX, AY, AW, AH, PChar(AText))
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtEntry.GetText: string;
begin
  if (Handle <> nil) and Assigned(ft_entry_get_text) then
    Result := StrPas(ft_entry_get_text(Handle))
  else
    Result := '';
end;

procedure TFtEntry.SetText(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_entry_set_text) then
    ft_entry_set_text(Handle, PChar(AValue));
end;

function TFtEntry.GetPlaceholder: string;
begin
  if (Handle <> nil) and Assigned(ft_entry_get_placeholder) then
    Result := StrPas(ft_entry_get_placeholder(Handle))
  else
    Result := '';
end;

procedure TFtEntry.SetPlaceholder(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_entry_set_placeholder) then
    ft_entry_set_placeholder(Handle, PChar(AValue));
end;

function TFtEntry.GetReadOnly: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_entry_get_readonly) then
    Result := (ft_entry_get_readonly(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtEntry.SetReadOnly(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_entry_set_readonly) then
    ft_entry_set_readonly(Handle, Ord(AValue));
end;

procedure TFtEntry.SetCornerRadius(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_entry_set_corner_radius) then
    ft_entry_set_corner_radius(Handle, AValue);
end;

procedure TFtEntry.SetOnChange(AValue: TFtTextChangeEvent);
begin
  FOnChange := AValue;
  if (Handle <> nil) and Assigned(ft_entry_on_change) then
    ft_entry_on_change(Handle, @EntryChangeDispatcher, Self);
end;

procedure TFtEntry.SetOnSubmit(AValue: TFtTextSubmitEvent);
begin
  FOnSubmit := AValue;
  if (Handle <> nil) and Assigned(ft_entry_on_submit) then
    ft_entry_on_submit(Handle, @EntrySubmitDispatcher, Self);
end;

procedure TFtEntry.DoChange(const AText: string);
begin
  if Assigned(FOnChange) then
    FOnChange(Self, AText);
end;

procedure TFtEntry.DoSubmit(const AText: string);
begin
  if Assigned(FOnSubmit) then
    FOnSubmit(Self, AText);
end;

{ TFtTextArea }

constructor TFtTextArea.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const AText: string = '');
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_textarea_create) then
    h := ft_textarea_create(pHandle, AX, AY, AW, AH, PChar(AText))
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtTextArea.GetText: string;
begin
  if (Handle <> nil) and Assigned(ft_textarea_get_text) then
    Result := StrPas(ft_textarea_get_text(Handle))
  else
    Result := '';
end;

procedure TFtTextArea.SetText(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_textarea_set_text) then
    ft_textarea_set_text(Handle, PChar(AValue));
end;

function TFtTextArea.GetPlaceholder: string;
begin
  if (Handle <> nil) and Assigned(ft_textarea_get_placeholder) then
    Result := StrPas(ft_textarea_get_placeholder(Handle))
  else
    Result := '';
end;

procedure TFtTextArea.SetPlaceholder(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_textarea_set_placeholder) then
    ft_textarea_set_placeholder(Handle, PChar(AValue));
end;

function TFtTextArea.GetReadOnly: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_textarea_get_readonly) then
    Result := (ft_textarea_get_readonly(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtTextArea.SetReadOnly(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_textarea_set_readonly) then
    ft_textarea_set_readonly(Handle, Ord(AValue));
end;

procedure TFtTextArea.SetCornerRadius(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_textarea_set_corner_radius) then
    ft_textarea_set_corner_radius(Handle, AValue);
end;

function TFtTextArea.GetScrollBarMode: TFtScrollBarMode;
begin
  if (Handle <> nil) and Assigned(ft_textarea_get_scrollbar_mode) then
    Result := TFtScrollBarMode(ft_textarea_get_scrollbar_mode(Handle))
  else
    Result := ftsbmAutoBoth;
end;

procedure TFtTextArea.SetScrollBarMode(AValue: TFtScrollBarMode);
begin
  if (Handle <> nil) and Assigned(ft_textarea_set_scrollbar_mode) then
    ft_textarea_set_scrollbar_mode(Handle, Ord(AValue));
end;

procedure TFtTextArea.SetOnChange(AValue: TFtTextChangeEvent);
begin
  FOnChange := AValue;
  if (Handle <> nil) and Assigned(ft_textarea_on_change) then
    ft_textarea_on_change(Handle, @TextAreaChangeDispatcher, Self);
end;

procedure TFtTextArea.DoChange(const AText: string);
begin
  if Assigned(FOnChange) then
    FOnChange(Self, AText);
end;

{ TFtComboBox }

constructor TFtComboBox.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_combobox_create) then
    h := ft_combobox_create(pHandle, AX, AY, AW, AH)
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtComboBox.AddItem(const AItem: string): Integer;
begin
  if (Handle <> nil) and Assigned(ft_combobox_add_item) then
    Result := ft_combobox_add_item(Handle, PChar(AItem))
  else
    Result := -1;
end;

procedure TFtComboBox.Clear();
begin
  if (Handle <> nil) and Assigned(ft_combobox_clear) then
    ft_combobox_clear(Handle);
end;

procedure TFtComboBox.Popup();
begin
  if (Handle <> nil) and Assigned(ft_combobox_popup) then
    ft_combobox_popup(Handle);
end;

function TFtComboBox.GetItemCount: Integer;
begin
  if (Handle <> nil) and Assigned(ft_combobox_get_item_count) then
    Result := ft_combobox_get_item_count(Handle)
  else
    Result := 0;
end;

function TFtComboBox.GetItem(AIndex: Integer): string;
begin
  if (Handle <> nil) and Assigned(ft_combobox_get_item) then
    Result := StrPas(ft_combobox_get_item(Handle, AIndex))
  else
    Result := '';
end;

function TFtComboBox.GetSelectedIndex: Integer;
begin
  if (Handle <> nil) and Assigned(ft_combobox_get_selected) then
    Result := ft_combobox_get_selected(Handle)
  else
    Result := -1;
end;

procedure TFtComboBox.SetSelectedIndex(AIndex: Integer);
begin
  if (Handle <> nil) and Assigned(ft_combobox_set_selected) then
    ft_combobox_set_selected(Handle, AIndex);
end;

function TFtComboBox.GetSelectedText: string;
begin
  if (Handle <> nil) and Assigned(ft_combobox_get_selected_text) then
    Result := StrPas(ft_combobox_get_selected_text(Handle))
  else
    Result := '';
end;

function TFtComboBox.GetText: string;
begin
  if (Handle <> nil) and Assigned(ft_combobox_get_text) then
    Result := StrPas(ft_combobox_get_text(Handle))
  else
    Result := '';
end;

procedure TFtComboBox.SetText(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_combobox_set_text) then
    ft_combobox_set_text(Handle, PChar(AValue));
end;

function TFtComboBox.GetPlaceholder: string;
begin
  if (Handle <> nil) and Assigned(ft_combobox_get_placeholder) then
    Result := StrPas(ft_combobox_get_placeholder(Handle))
  else
    Result := '';
end;

procedure TFtComboBox.SetPlaceholder(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_combobox_set_placeholder) then
    ft_combobox_set_placeholder(Handle, PChar(AValue));
end;

function TFtComboBox.GetEditable: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_combobox_get_editable) then
    Result := (ft_combobox_get_editable(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtComboBox.SetEditable(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_combobox_set_editable) then
    ft_combobox_set_editable(Handle, Ord(AValue));
end;

function TFtComboBox.GetCornerRadius: Double;
begin
  if (Handle <> nil) and Assigned(ft_combobox_get_corner_radius) then
    Result := ft_combobox_get_corner_radius(Handle)
  else
    Result := -1.0;
end;

procedure TFtComboBox.SetCornerRadius(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_combobox_set_corner_radius) then
    ft_combobox_set_corner_radius(Handle, AValue);
end;

procedure TFtComboBox.SetOnChange(AValue: TFtComboChangeEvent);
begin
  FOnChange := AValue;
  if (Handle <> nil) and Assigned(ft_combobox_on_change) then
    ft_combobox_on_change(Handle, @ComboChangeDispatcher, Self);
end;

procedure TFtComboBox.DoChange(AIndex: Integer; const AText: string);
begin
  if Assigned(FOnChange) then
    FOnChange(Self, AIndex, AText);
end;

{ TFtSlider }

constructor TFtSlider.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer;
                             AOrientation: TFtSliderOrientation = ftsoHorizontal);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_slider_create) then
    h := ft_slider_create(pHandle, AX, AY, AW, AH, Ord(AOrientation))
  else
    h := nil;
  SetHandle(h, True);
end;

procedure TFtSlider.SetRange(AMin, AMax: Double);
begin
  if (Handle <> nil) and Assigned(ft_slider_set_range) then
    ft_slider_set_range(Handle, AMin, AMax);
end;

function TFtSlider.GetOrientation: TFtSliderOrientation;
begin
  if (Handle <> nil) and Assigned(ft_slider_get_orientation) then
    Result := TFtSliderOrientation(ft_slider_get_orientation(Handle))
  else
    Result := ftsoHorizontal;
end;

procedure TFtSlider.SetOrientation(AValue: TFtSliderOrientation);
begin
  if (Handle <> nil) and Assigned(ft_slider_set_orientation) then
    ft_slider_set_orientation(Handle, Ord(AValue));
end;

function TFtSlider.GetMin: Double;
begin
  if (Handle <> nil) and Assigned(ft_slider_get_min) then
    Result := ft_slider_get_min(Handle)
  else
    Result := 0.0;
end;

function TFtSlider.GetMax: Double;
begin
  if (Handle <> nil) and Assigned(ft_slider_get_max) then
    Result := ft_slider_get_max(Handle)
  else
    Result := 100.0;
end;

function TFtSlider.GetValue: Double;
begin
  if (Handle <> nil) and Assigned(ft_slider_get_value) then
    Result := ft_slider_get_value(Handle)
  else
    Result := 0.0;
end;

procedure TFtSlider.SetValue(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_slider_set_value) then
    ft_slider_set_value(Handle, AValue);
end;

function TFtSlider.GetStep: Double;
begin
  if (Handle <> nil) and Assigned(ft_slider_get_step) then
    Result := ft_slider_get_step(Handle)
  else
    Result := 1.0;
end;

procedure TFtSlider.SetStep(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_slider_set_step) then
    ft_slider_set_step(Handle, AValue);
end;

function TFtSlider.GetThumbSize: Double;
begin
  if (Handle <> nil) and Assigned(ft_slider_get_thumb_size) then
    Result := ft_slider_get_thumb_size(Handle)
  else
    Result := 16.0;
end;

procedure TFtSlider.SetThumbSize(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_slider_set_thumb_size) then
    ft_slider_set_thumb_size(Handle, AValue);
end;

procedure TFtSlider.SetOnChange(AValue: TFtSliderChangeEvent);
begin
  FOnChange := AValue;
  if (Handle <> nil) and Assigned(ft_slider_on_change) then
    ft_slider_on_change(Handle, @SliderChangeDispatcher, Self);
end;

procedure TFtSlider.DoChange(AValue: Double);
begin
  if Assigned(FOnChange) then
    FOnChange(Self, AValue);
end;

{ TFtProgressBar }

constructor TFtProgressBar.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer;
                                  AOrientation: TFtProgressOrientation = ftpoHorizontal);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_progressbar_create) then
    h := ft_progressbar_create(pHandle, AX, AY, AW, AH, Ord(AOrientation))
  else
    h := nil;
  SetHandle(h, True);
end;

procedure TFtProgressBar.SetRange(AMin, AMax: Double);
begin
  if (Handle <> nil) and Assigned(ft_progressbar_set_range) then
    ft_progressbar_set_range(Handle, AMin, AMax);
end;

function TFtProgressBar.GetOrientation: TFtProgressOrientation;
begin
  if (Handle <> nil) and Assigned(ft_progressbar_get_orientation) then
    Result := TFtProgressOrientation(ft_progressbar_get_orientation(Handle))
  else
    Result := ftpoHorizontal;
end;

procedure TFtProgressBar.SetOrientation(AValue: TFtProgressOrientation);
begin
  if (Handle <> nil) and Assigned(ft_progressbar_set_orientation) then
    ft_progressbar_set_orientation(Handle, Ord(AValue));
end;

function TFtProgressBar.GetMin: Double;
begin
  if (Handle <> nil) and Assigned(ft_progressbar_get_min) then
    Result := ft_progressbar_get_min(Handle)
  else
    Result := 0.0;
end;

function TFtProgressBar.GetMax: Double;
begin
  if (Handle <> nil) and Assigned(ft_progressbar_get_max) then
    Result := ft_progressbar_get_max(Handle)
  else
    Result := 100.0;
end;

function TFtProgressBar.GetValue: Double;
begin
  if (Handle <> nil) and Assigned(ft_progressbar_get_value) then
    Result := ft_progressbar_get_value(Handle)
  else
    Result := 0.0;
end;

procedure TFtProgressBar.SetValue(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_progressbar_set_value) then
    ft_progressbar_set_value(Handle, AValue);
end;

function TFtProgressBar.GetIndeterminate: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_progressbar_get_indeterminate) then
    Result := (ft_progressbar_get_indeterminate(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtProgressBar.SetIndeterminate(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_progressbar_set_indeterminate) then
    ft_progressbar_set_indeterminate(Handle, Ord(AValue));
end;

function TFtProgressBar.GetShowText: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_progressbar_get_show_text) then
    Result := (ft_progressbar_get_show_text(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtProgressBar.SetShowText(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_progressbar_set_show_text) then
    ft_progressbar_set_show_text(Handle, Ord(AValue));
end;

function TFtProgressBar.GetTextFormat: string;
begin
  if (Handle <> nil) and Assigned(ft_progressbar_get_text_format) then
    Result := StrPas(ft_progressbar_get_text_format(Handle))
  else
    Result := '%.0f%%';
end;

procedure TFtProgressBar.SetTextFormat(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_progressbar_set_text_format) then
    ft_progressbar_set_text_format(Handle, PChar(AValue));
end;

function TFtProgressBar.GetCornerRadius: Double;
begin
  if (Handle <> nil) and Assigned(ft_progressbar_get_corner_radius) then
    Result := ft_progressbar_get_corner_radius(Handle)
  else
    Result := -1.0;
end;

procedure TFtProgressBar.SetCornerRadius(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_progressbar_set_corner_radius) then
    ft_progressbar_set_corner_radius(Handle, AValue);
end;

{ TFtImage }

constructor TFtImage.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const AFilePath: string = '');
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_image_create) then
    h := ft_image_create(pHandle, AX, AY, AW, AH, PChar(AFilePath))
  else
    h := nil;
  SetHandle(h, True);
end;

procedure TFtImage.LoadFile(const AFilePath: string);
begin
  if (Handle <> nil) and Assigned(ft_image_load_file) then
    ft_image_load_file(Handle, PChar(AFilePath));
end;

procedure TFtImage.LoadMemory(AData: Pointer; ASize: Integer);
begin
  if (Handle <> nil) and Assigned(ft_image_load_memory) then
    ft_image_load_memory(Handle, AData, ASize);
end;

procedure TFtImage.LoadSVGFile(const AFilePath: string);
begin
  if (Handle <> nil) and Assigned(ft_image_load_svg_file) then
    ft_image_load_svg_file(Handle, PChar(AFilePath));
end;

procedure TFtImage.LoadSVGString(const ASVGContent: string);
begin
  if (Handle <> nil) and Assigned(ft_image_load_svg_string) then
    ft_image_load_svg_string(Handle, PChar(ASVGContent));
end;

procedure TFtImage.InvalidateCache();
begin
  if (Handle <> nil) and Assigned(ft_image_invalidate_cache) then
    ft_image_invalidate_cache(Handle);
end;

procedure TFtImage.SetBitmap(ABitmap: TFtBitmap; AOwnsBitmap: Boolean = False);
begin
  if (Handle <> nil) and (ABitmap <> nil) and Assigned(ft_image_set_bitmap) then
    ft_image_set_bitmap(Handle, ABitmap.Handle, Ord(AOwnsBitmap));
end;

function TFtImage.GetBitmap(): TFtBitmap;
var
  bmpHandle: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_image_get_bitmap) then
  begin
    bmpHandle := ft_image_get_bitmap(Handle);
    if bmpHandle <> nil then
      Result := TFtBitmap.Wrap(bmpHandle, False)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TFtImage.GetScaleMode: TFtImageScaleMode;
begin
  if (Handle <> nil) and Assigned(ft_image_get_scale_mode) then
    Result := TFtImageScaleMode(ft_image_get_scale_mode(Handle))
  else
    Result := ftismFit;
end;

procedure TFtImage.SetScaleMode(AValue: TFtImageScaleMode);
begin
  if (Handle <> nil) and Assigned(ft_image_set_scale_mode) then
    ft_image_set_scale_mode(Handle, Ord(AValue));
end;

{ TFtScrollBar }

constructor TFtScrollBar.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer;
                                AOrientation: TFtScrollBarOrientation = ftsboHorizontal);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_scrollbar_create) then
    h := ft_scrollbar_create(pHandle, AX, AY, AW, AH, Ord(AOrientation))
  else
    h := nil;
  SetHandle(h, True);
end;

procedure TFtScrollBar.SetRange(AMin, AMax, APageSize: Double);
begin
  if (Handle <> nil) and Assigned(ft_scrollbar_set_range) then
    ft_scrollbar_set_range(Handle, AMin, AMax, APageSize);
end;

function TFtScrollBar.GetOrientation: TFtScrollBarOrientation;
begin
  if (Handle <> nil) and Assigned(ft_scrollbar_get_orientation) then
    Result := TFtScrollBarOrientation(ft_scrollbar_get_orientation(Handle))
  else
    Result := ftsboHorizontal;
end;

procedure TFtScrollBar.SetOrientation(AValue: TFtScrollBarOrientation);
begin
  if (Handle <> nil) and Assigned(ft_scrollbar_set_orientation) then
    ft_scrollbar_set_orientation(Handle, Ord(AValue));
end;

function TFtScrollBar.GetValue: Double;
begin
  if (Handle <> nil) and Assigned(ft_scrollbar_get_value) then
    Result := ft_scrollbar_get_value(Handle)
  else
    Result := 0.0;
end;

procedure TFtScrollBar.SetValue(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_scrollbar_set_value) then
    ft_scrollbar_set_value(Handle, AValue);
end;

function TFtScrollBar.GetMin: Double;
begin
  if (Handle <> nil) and Assigned(ft_scrollbar_get_min) then
    Result := ft_scrollbar_get_min(Handle)
  else
    Result := 0.0;
end;

function TFtScrollBar.GetMax: Double;
begin
  if (Handle <> nil) and Assigned(ft_scrollbar_get_max) then
    Result := ft_scrollbar_get_max(Handle)
  else
    Result := 100.0;
end;

function TFtScrollBar.GetPageSize: Double;
begin
  if (Handle <> nil) and Assigned(ft_scrollbar_get_page_size) then
    Result := ft_scrollbar_get_page_size(Handle)
  else
    Result := 10.0;
end;

function TFtScrollBar.GetStep: Double;
begin
  if (Handle <> nil) and Assigned(ft_scrollbar_get_step) then
    Result := ft_scrollbar_get_step(Handle)
  else
    Result := 1.0;
end;

procedure TFtScrollBar.SetStep(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_scrollbar_set_step) then
    ft_scrollbar_set_step(Handle, AValue);
end;

procedure TFtScrollBar.SetCornerRadius(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_scrollbar_set_corner_radius) then
    ft_scrollbar_set_corner_radius(Handle, AValue);
end;

procedure TFtScrollBar.SetOnScroll(AValue: TFtScrollEvent);
begin
  FOnScroll := AValue;
  if (Handle <> nil) and Assigned(ft_scrollbar_on_scroll) then
    ft_scrollbar_on_scroll(Handle, @ScrollBarScrollDispatcher, Self);
end;

procedure TFtScrollBar.DoScroll(AValue: Double);
begin
  if Assigned(FOnScroll) then
    FOnScroll(Self, AValue);
end;

{ TFtPathBar }

constructor TFtPathBar.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const AInitialPath: string = '');
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_path_bar_create) then
    h := ft_path_bar_create(pHandle, AX, AY, AW, AH, PChar(AInitialPath))
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtPathBar.GetPath: string;
begin
  if (Handle <> nil) and Assigned(ft_path_bar_get_path) then
    Result := StrPas(ft_path_bar_get_path(Handle))
  else
    Result := '';
end;

procedure TFtPathBar.SetPath(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_path_bar_set_path) then
    ft_path_bar_set_path(Handle, PChar(AValue));
end;

function TFtPathBar.GetMode: TFtPathBarMode;
begin
  if (Handle <> nil) and Assigned(ft_path_bar_get_mode) then
    Result := TFtPathBarMode(ft_path_bar_get_mode(Handle))
  else
    Result := ftpbmBreadcrumbs;
end;

procedure TFtPathBar.SetMode(AValue: TFtPathBarMode);
begin
  if (Handle <> nil) and Assigned(ft_path_bar_set_mode) then
    ft_path_bar_set_mode(Handle, Ord(AValue));
end;

function TFtPathBar.GetShowEditButton: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_path_bar_get_show_edit_button) then
    Result := (ft_path_bar_get_show_edit_button(Handle) <> 0)
  else
    Result := True;
end;

procedure TFtPathBar.SetShowEditButton(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_path_bar_set_show_edit_button) then
    ft_path_bar_set_show_edit_button(Handle, Ord(AValue));
end;

function TFtPathBar.GetRootDisplayName: string;
begin
  if (Handle <> nil) and Assigned(ft_path_bar_get_root_display_name) then
    Result := StrPas(ft_path_bar_get_root_display_name(Handle))
  else
    Result := '';
end;

procedure TFtPathBar.SetRootDisplayName(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_path_bar_set_root_display_name) then
    ft_path_bar_set_root_display_name(Handle, PChar(AValue));
end;

function TFtPathBar.GetCornerRadius: Double;
begin
  if (Handle <> nil) and Assigned(ft_path_bar_get_corner_radius) then
    Result := ft_path_bar_get_corner_radius(Handle)
  else
    Result := -1.0;
end;

procedure TFtPathBar.SetCornerRadius(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_path_bar_set_corner_radius) then
    ft_path_bar_set_corner_radius(Handle, AValue);
end;

procedure TFtPathBar.SetOnNavigate(AValue: TFtPathNavigateEvent);
begin
  FOnNavigate := AValue;
  if (Handle <> nil) and Assigned(ft_path_bar_on_navigate) then
    ft_path_bar_on_navigate(Handle, @PathBarNavigateDispatcher, Self);
end;

procedure TFtPathBar.SetOnModeChange(AValue: TFtPathModeChangeEvent);
begin
  FOnModeChange := AValue;
  if (Handle <> nil) and Assigned(ft_path_bar_on_mode_change) then
    ft_path_bar_on_mode_change(Handle, @PathBarModeDispatcher, Self);
end;

procedure TFtPathBar.DoNavigate(const APath: string);
begin
  if Assigned(FOnNavigate) then
    FOnNavigate(Self, APath);
end;

procedure TFtPathBar.DoModeChange(AMode: TFtPathBarMode);
begin
  if Assigned(FOnModeChange) then
    FOnModeChange(Self, AMode);
end;

{ TFtUrlEntry }

constructor TFtUrlEntry.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer; const AInitialUrl: string = '');
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_url_entry_create) then
    h := ft_url_entry_create(pHandle, AX, AY, AW, AH, PChar(AInitialUrl))
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtUrlEntry.GetUrl: string;
begin
  if (Handle <> nil) and Assigned(ft_url_entry_get_url) then
    Result := StrPas(ft_url_entry_get_url(Handle))
  else
    Result := '';
end;

procedure TFtUrlEntry.SetUrl(const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_url_entry_set_url) then
    ft_url_entry_set_url(Handle, PChar(AValue));
end;

function TFtUrlEntry.GetSecurityState: TFtUrlSecurityState;
begin
  if (Handle <> nil) and Assigned(ft_url_entry_get_security_state) then
    Result := TFtUrlSecurityState(ft_url_entry_get_security_state(Handle))
  else
    Result := ftussSecure;
end;

procedure TFtUrlEntry.SetSecurityState(AValue: TFtUrlSecurityState);
begin
  if (Handle <> nil) and Assigned(ft_url_entry_set_security_state) then
    ft_url_entry_set_security_state(Handle, Ord(AValue));
end;

function TFtUrlEntry.GetBookmarked: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_url_entry_get_bookmarked) then
    Result := (ft_url_entry_get_bookmarked(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtUrlEntry.SetBookmarked(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_url_entry_set_bookmarked) then
    ft_url_entry_set_bookmarked(Handle, Ord(AValue));
end;

function TFtUrlEntry.GetShowSecurityChip: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_url_entry_get_show_security_chip) then
    Result := (ft_url_entry_get_show_security_chip(Handle) <> 0)
  else
    Result := True;
end;

procedure TFtUrlEntry.SetShowSecurityChip(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_url_entry_set_show_security_chip) then
    ft_url_entry_set_show_security_chip(Handle, Ord(AValue));
end;

function TFtUrlEntry.GetShowSecurityBadgeText: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_url_entry_get_show_security_badge_text) then
    Result := (ft_url_entry_get_show_security_badge_text(Handle) <> 0)
  else
    Result := True;
end;

procedure TFtUrlEntry.SetShowSecurityBadgeText(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_url_entry_set_show_security_badge_text) then
    ft_url_entry_set_show_security_badge_text(Handle, Ord(AValue));
end;

function TFtUrlEntry.GetShowBookmarkButton: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_url_entry_get_show_bookmark_button) then
    Result := (ft_url_entry_get_show_bookmark_button(Handle) <> 0)
  else
    Result := True;
end;

procedure TFtUrlEntry.SetShowBookmarkButton(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_url_entry_set_show_bookmark_button) then
    ft_url_entry_set_show_bookmark_button(Handle, Ord(AValue));
end;

function TFtUrlEntry.GetAutoPrefixHttps: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_url_entry_get_auto_prefix_https) then
    Result := (ft_url_entry_get_auto_prefix_https(Handle) <> 0)
  else
    Result := True;
end;

procedure TFtUrlEntry.SetAutoPrefixHttps(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_url_entry_set_auto_prefix_https) then
    ft_url_entry_set_auto_prefix_https(Handle, Ord(AValue));
end;

function TFtUrlEntry.GetCornerRadius: Double;
begin
  if (Handle <> nil) and Assigned(ft_url_entry_get_corner_radius) then
    Result := ft_url_entry_get_corner_radius(Handle)
  else
    Result := -1.0;
end;

procedure TFtUrlEntry.SetCornerRadius(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_url_entry_set_corner_radius) then
    ft_url_entry_set_corner_radius(Handle, AValue);
end;

function TFtUrlEntry.GetEditing: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_url_entry_get_editing) then
    Result := (ft_url_entry_get_editing(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtUrlEntry.SetEditing(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_url_entry_set_editing) then
    ft_url_entry_set_editing(Handle, Ord(AValue));
end;

procedure TFtUrlEntry.SetOnSubmit(AValue: TFtUrlSubmitEvent);
begin
  FOnSubmit := AValue;
  if (Handle <> nil) and Assigned(ft_url_entry_on_submit) then
    ft_url_entry_on_submit(Handle, @UrlSubmitDispatcher, Self);
end;

procedure TFtUrlEntry.SetOnSecurityClick(AValue: TFtUrlSecurityEvent);
begin
  FOnSecurityClick := AValue;
  if (Handle <> nil) and Assigned(ft_url_entry_on_security_click) then
    ft_url_entry_on_security_click(Handle, @UrlSecurityDispatcher, Self);
end;

procedure TFtUrlEntry.SetOnBookmarkClick(AValue: TFtUrlBookmarkEvent);
begin
  FOnBookmarkClick := AValue;
  if (Handle <> nil) and Assigned(ft_url_entry_on_bookmark_click) then
    ft_url_entry_on_bookmark_click(Handle, @UrlBookmarkDispatcher, Self);
end;

procedure TFtUrlEntry.DoSubmit(const AUrl: string);
begin
  if Assigned(FOnSubmit) then
    FOnSubmit(Self, AUrl);
end;

procedure TFtUrlEntry.DoSecurityClick(ASecurityState: TFtUrlSecurityState);
begin
  if Assigned(FOnSecurityClick) then
    FOnSecurityClick(Self, ASecurityState);
end;

procedure TFtUrlEntry.DoBookmarkClick(ABookmarked: Boolean);
begin
  if Assigned(FOnBookmarkClick) then
    FOnBookmarkClick(Self, ABookmarked);
end;

end.
