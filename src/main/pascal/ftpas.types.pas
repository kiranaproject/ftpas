{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal High-Level Types & Enums           }
{                                                                          }
{   Provides typed enumerations, records, and event procedural types       }
{   for the OOP wrapper layer.                                             }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ftpas.api;

type
  { High-Level Enums }
  TFtButtonState = (
    ftbsNormal  = FT_BUTTON_STATE_NORMAL,
    ftbsHovered = FT_BUTTON_STATE_HOVERED,
    ftbsPressed = FT_BUTTON_STATE_PRESSED
  );

  TFtCursorType = (
    ftcDefault   = FT_CURSOR_DEFAULT,
    ftcIBeam     = FT_CURSOR_IBEAM,
    ftcSizeH     = FT_CURSOR_SIZE_H,
    ftcSizeV     = FT_CURSOR_SIZE_V,
    ftcHand      = FT_CURSOR_HAND,
    ftcCrosshair = FT_CURSOR_CROSSHAIR,
    ftcMove      = FT_CURSOR_MOVE
  );

  TFtWindowType = (
    ftwtNormal       = FT_WINDOW_TYPE_NORMAL,
    ftwtDialog       = FT_WINDOW_TYPE_DIALOG,
    ftwtPopupMenu    = FT_WINDOW_TYPE_POPUP_MENU,
    ftwtDropdownMenu = FT_WINDOW_TYPE_DROPDOWN_MENU,
    ftwtTooltip      = FT_WINDOW_TYPE_TOOLTIP,
    ftwtUtility      = FT_WINDOW_TYPE_UTILITY,
    ftwtDock         = FT_WINDOW_TYPE_DOCK,
    ftwtDesktop      = FT_WINDOW_TYPE_DESKTOP
  );

  TFtAlignSelf = (
    ftasAuto    = FT_ALIGN_SELF_AUTO,
    ftasStretch = FT_ALIGN_SELF_STRETCH,
    ftasStart   = FT_ALIGN_SELF_START,
    ftasCenter  = FT_ALIGN_SELF_CENTER,
    ftasEnd     = FT_ALIGN_SELF_END
  );

  TFtButtonIconPosition = (
    ftipLeft  = FT_BUTTON_ICON_LEFT,
    ftipRight = FT_BUTTON_ICON_RIGHT,
    ftipTop   = FT_BUTTON_ICON_TOP,
    ftipOnly  = FT_BUTTON_ICON_ONLY
  );

  TFtWindowButtonKind = (
    ftwbClose    = FT_WINDOW_BUTTON_CLOSE,
    ftwbMinimize = FT_WINDOW_BUTTON_MINIMIZE,
    ftwbMaximize = FT_WINDOW_BUTTON_MAXIMIZE,
    ftwbRestore  = FT_WINDOW_BUTTON_RESTORE,
    ftwbShade    = FT_WINDOW_BUTTON_SHADE,
    ftwbPin      = FT_WINDOW_BUTTON_PIN,
    ftwbMenu     = FT_WINDOW_BUTTON_MENU,
    ftwbAdd      = FT_WINDOW_BUTTON_ADD
  );

  TFtWindowButtonStyle = (
    ftwsCircle   = FT_WINDOW_BUTTON_CIRCLE,
    ftwsSquircle = FT_WINDOW_BUTTON_SQUIRCLE,
    ftwsSquare   = FT_WINDOW_BUTTON_SQUARE
  );

  TFtTextAlign = (
    ftaLeft   = FT_TEXT_ALIGN_LEFT,
    ftaCenter = FT_TEXT_ALIGN_CENTER,
    ftaRight  = FT_TEXT_ALIGN_RIGHT
  );

  TFtPathBarMode = (
    ftpbmBreadcrumbs = FT_PATH_BAR_MODE_BREADCRUMBS,
    ftpbmEdit        = FT_PATH_BAR_MODE_EDIT
  );

  TFtUrlSecurityState = (
    ftussSecure   = FT_URL_SECURITY_SECURE,
    ftussInsecure = FT_URL_SECURITY_INSECURE,
    ftussInternal = FT_URL_SECURITY_INTERNAL,
    ftussFile     = FT_URL_SECURITY_FILE,
    ftussCustom   = FT_URL_SECURITY_CUSTOM
  );

  TFtScrollBarOrientation = (
    ftsboHorizontal = FT_SCROLLBAR_HORIZONTAL,
    ftsboVertical   = FT_SCROLLBAR_VERTICAL
  );

  TFtScrollBarMode = (
    ftsbmNone            = FT_SCROLLBAR_MODE_NONE,
    ftsbmHorizontalOnly  = FT_SCROLLBAR_MODE_HORIZONTAL_ONLY,
    ftsbmVerticalOnly    = FT_SCROLLBAR_MODE_VERTICAL_ONLY,
    ftsbmAutoBoth        = FT_SCROLLBAR_MODE_AUTO_BOTH
  );

  TFtFlexDirection = (
    ftfdRow    = FT_FLEX_ROW,
    ftfdColumn = FT_FLEX_COLUMN
  );

  TFtJustifyContent = (
    ftjcStart        = FT_JUSTIFY_START,
    ftjcCenter       = FT_JUSTIFY_CENTER,
    ftjcEnd          = FT_JUSTIFY_END,
    ftjcSpaceBetween = FT_JUSTIFY_SPACE_BETWEEN,
    ftjcSpaceAround  = FT_JUSTIFY_SPACE_AROUND,
    ftjcSpaceEvenly  = FT_JUSTIFY_SPACE_EVENLY
  );

  TFtAlignItems = (
    ftaiStretch = FT_ALIGN_STRETCH,
    ftaiStart   = FT_ALIGN_START,
    ftaiCenter  = FT_ALIGN_CENTER,
    ftaiEnd     = FT_ALIGN_END
  );

  TFtFlexWrap = (
    ftfwNoWrap      = FT_FLEX_NOWRAP,
    ftfwWrap        = FT_FLEX_WRAP,
    ftfwWrapReverse = FT_FLEX_WRAP_REVERSE
  );

  TFtAnchorMode = (
    ftamTopCenter    = FT_ANCHOR_TOP_CENTER,
    ftamBottomCenter = FT_ANCHOR_BOTTOM_CENTER,
    ftamTopLeft      = FT_ANCHOR_TOP_LEFT,
    ftamTopRight     = FT_ANCHOR_TOP_RIGHT,
    ftamBottomLeft   = FT_ANCHOR_BOTTOM_LEFT,
    ftamBottomRight  = FT_ANCHOR_BOTTOM_RIGHT,
    ftamCenter       = FT_ANCHOR_CENTER
  );

  TFtSliderOrientation = (
    ftsoHorizontal = FT_SLIDER_HORIZONTAL,
    ftsoVertical   = FT_SLIDER_VERTICAL
  );

  TFtProgressOrientation = (
    ftpoHorizontal = FT_PROGRESS_HORIZONTAL,
    ftpoVertical   = FT_PROGRESS_VERTICAL
  );

  TFtImageScaleMode = (
    ftismFit     = FT_IMAGE_SCALE_FIT,
    ftismStretch = FT_IMAGE_SCALE_STRETCH,
    ftismCenter  = FT_IMAGE_SCALE_CENTER,
    ftismNone    = FT_IMAGE_SCALE_NONE
  );

  TFtSplitterOrientation = (
    ftspoHorizontal = FT_SPLITTER_HORIZONTAL,
    ftspoVertical   = FT_SPLITTER_VERTICAL
  );

  TFtSizeGroupMode = (
    ftsgHorizontal = 0,
    ftsgVertical   = 1,
    ftsgBoth       = 2
  );

  TFtFileDialogType = (
    ftfdtOpen         = FT_FILE_DIALOG_OPEN,
    ftfdtSave         = FT_FILE_DIALOG_SAVE,
    ftfdtSelectFolder = FT_FILE_DIALOG_SELECT_FOLDER
  );

  TFtModalResult = (
    ftmrNone   = FT_MODAL_NONE,
    ftmrOk     = FT_MODAL_OK,
    ftmrCancel = FT_MODAL_CANCEL,
    ftmrYes    = FT_MODAL_YES,
    ftmrNo     = FT_MODAL_NO,
    ftmrAbort  = FT_MODAL_ABORT,
    ftmrRetry  = FT_MODAL_RETRY,
    ftmrIgnore = FT_MODAL_IGNORE,
    ftmrClose  = FT_MODAL_CLOSE
  );

  TFtMsgDialogSeverity = (
    ftmdCustom   = FT_MSG_DIALOG_CUSTOM,
    ftmdInfo     = FT_MSG_DIALOG_INFO,
    ftmdWarning  = FT_MSG_DIALOG_WARNING,
    ftmdError    = FT_MSG_DIALOG_ERROR,
    ftmdQuestion = FT_MSG_DIALOG_QUESTION,
    ftmdSuccess  = FT_MSG_DIALOG_SUCCESS
  );

  TFtMsgDialogButtons = (
    ftmbOk           = FT_MSG_BUTTONS_OK,
    ftmbOkCancel     = FT_MSG_BUTTONS_OK_CANCEL,
    ftmbYesNo        = FT_MSG_BUTTONS_YES_NO,
    ftmbYesNoCancel  = FT_MSG_BUTTONS_YES_NO_CANCEL,
    ftmbRetryCancel  = FT_MSG_BUTTONS_RETRY_CANCEL,
    ftmbCustom       = FT_MSG_BUTTONS_CUSTOM
  );

  TFtRulerOrientation = (
    ftroHorizontal = FT_RULER_HORIZONTAL,
    ftroVertical   = FT_RULER_VERTICAL
  );

  TFtRulerUnit = (
    ftruPixels      = FT_RULER_UNIT_PIXELS,
    ftruPoints      = FT_RULER_UNIT_POINTS,
    ftruMillimeters = FT_RULER_UNIT_MILLIMETERS,
    ftruCentimeters = FT_RULER_UNIT_CENTIMETERS,
    ftruInches      = FT_RULER_UNIT_INCHES
  );

  TFtBlendMode = (
    ftbmSrcOver  = FT_BLEND_SRCOVER,
    ftbmAdditive = FT_BLEND_ADDITIVE,
    ftbmMultiply = FT_BLEND_MULTIPLY,
    ftbmScreen   = FT_BLEND_SCREEN,
    ftbmSrc      = FT_BLEND_SRC
  );

  { Geometry and Color Records }
  TFtRect = record
    Left, Top, Width, Height: Integer;
  end;

  TFtColor = record
    R, G, B, A: Double;
  end;

{ Color Factory Helper Functions }
function FtColor(R, G, B: Double; A: Double = 1.0): TFtColor;
function FtColorHex(const AHex: string): TFtColor;
function FtRect(ALeft, ATop, AWidth, AHeight: Integer): TFtRect;

implementation

function FtColor(R, G, B: Double; A: Double = 1.0): TFtColor;
begin
  Result.R := R;
  Result.G := G;
  Result.B := B;
  Result.A := A;
end;

function FtColorHex(const AHex: string): TFtColor;
var
  clean: string;
  val: Cardinal;
begin
  clean := Trim(AHex);
  if (Length(clean) > 0) and (clean[1] = '#') then
    clean := Copy(clean, 2, Length(clean) - 1);

  if Length(clean) = 6 then
  begin
    val := StrToIntDef('$' + clean, 0);
    Result.R := ((val shr 16) and $FF) / 255.0;
    Result.G := ((val shr 8) and $FF) / 255.0;
    Result.B := (val and $FF) / 255.0;
    Result.A := 1.0;
  end
  else if Length(clean) = 8 then
  begin
    val := StrToIntDef('$' + clean, 0);
    Result.R := ((val shr 24) and $FF) / 255.0;
    Result.G := ((val shr 16) and $FF) / 255.0;
    Result.B := ((val shr 8) and $FF) / 255.0;
    Result.A := (val and $FF) / 255.0;
  end
  else
  begin
    Result.R := 0.0;
    Result.G := 0.0;
    Result.B := 0.0;
    Result.A := 1.0;
  end;
end;

function FtRect(ALeft, ATop, AWidth, AHeight: Integer): TFtRect;
begin
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Width := AWidth;
  Result.Height := AHeight;
end;

end.
