{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal OOP Wrapper Umbrella Unit          }
{                                                                          }
{   Re-exports all major Ft classes, records, and functions for convenient }
{   single-unit inclusion (`uses ftpas;`).                                 }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas;

{$mode objfpc}{$H+}

interface

uses
  ftpas.api,
  ftpas.types,
  ftpas.font,
  ftpas.canvas,
  ftpas.widget,
  ftpas.window,
  ftpas.controls,
  ftpas.layouts,
  ftpas.views,
  ftpas.creative,
  ftpas.dialogs,
  ftpas.menus,
  ftpas.app,
  ftpas.gpu,
  floriajs,
  ftpas.ftml,
  ftpas.ftml.res;

type
  { Core Records & Enums }
  TFtRect                = ftpas.types.TFtRect;
  TFtColor               = ftpas.types.TFtColor;
  TFtButtonState         = ftpas.types.TFtButtonState;
  TFtCursorType          = ftpas.types.TFtCursorType;
  TFtWindowType          = ftpas.types.TFtWindowType;
  TFtAlignSelf           = ftpas.types.TFtAlignSelf;
  TFtButtonIconPosition  = ftpas.types.TFtButtonIconPosition;
  TFtWindowButtonKind    = ftpas.types.TFtWindowButtonKind;
  TFtWindowButtonStyle   = ftpas.types.TFtWindowButtonStyle;
  TFtTextAlign           = ftpas.types.TFtTextAlign;
  TFtPathBarMode         = ftpas.types.TFtPathBarMode;
  TFtUrlSecurityState    = ftpas.types.TFtUrlSecurityState;
  TFtScrollBarOrientation= ftpas.types.TFtScrollBarOrientation;
  TFtScrollBarMode       = ftpas.types.TFtScrollBarMode;
  TFtFlexDirection       = ftpas.types.TFtFlexDirection;
  TFtJustifyContent      = ftpas.types.TFtJustifyContent;
  TFtAlignItems          = ftpas.types.TFtAlignItems;
  TFtFlexWrap            = ftpas.types.TFtFlexWrap;
  TFtAnchorMode          = ftpas.types.TFtAnchorMode;
  TFtSliderOrientation   = ftpas.types.TFtSliderOrientation;
  TFtProgressOrientation = ftpas.types.TFtProgressOrientation;
  TFtImageScaleMode      = ftpas.types.TFtImageScaleMode;
  TFtSplitterOrientation = ftpas.types.TFtSplitterOrientation;
  TFtSizeGroupMode       = ftpas.types.TFtSizeGroupMode;
  TFtRulerOrientation    = ftpas.types.TFtRulerOrientation;
  TFtRulerUnit           = ftpas.types.TFtRulerUnit;
  TFtFileDialogType      = ftpas.types.TFtFileDialogType;
  TFtModalResult         = ftpas.types.TFtModalResult;

  { Application & Canvas }
  TFtApp                 = ftpas.app.TFtApp;
  TFtFontRef             = ftpas.font.TFtFontRef;
  TFtBitmap              = ftpas.canvas.TFtBitmap;
  TFtCanvas              = ftpas.canvas.TFtCanvas;

  { Widgets & Window }
  TFtWidget              = ftpas.widget.TFtWidget;
  TFtWindow              = ftpas.window.TFtWindow;

  { Standard Controls }
  TFtButton              = ftpas.controls.TFtButton;
  TFtWindowButton        = ftpas.controls.TFtWindowButton;
  TFtSwitch              = ftpas.controls.TFtSwitch;
  TFtCheckBox            = ftpas.controls.TFtCheckBox;
  TFtRadioButton         = ftpas.controls.TFtRadioButton;
  TFtLabel               = ftpas.controls.TFtLabel;
  TFtText                = ftpas.controls.TFtText;
  TFtEntry               = ftpas.controls.TFtEntry;
  TFtTextArea            = ftpas.controls.TFtTextArea;
  TFtComboBox            = ftpas.controls.TFtComboBox;
  TFtSlider              = ftpas.controls.TFtSlider;
  TFtProgressBar         = ftpas.controls.TFtProgressBar;
  TFtImage               = ftpas.controls.TFtImage;
  TFtScrollBar           = ftpas.controls.TFtScrollBar;
  TFtPathBar             = ftpas.controls.TFtPathBar;
  TFtUrlEntry            = ftpas.controls.TFtUrlEntry;

  { Layout Containers }
  TFtContainer           = ftpas.layouts.TFtContainer;
  TFtFlexBox             = ftpas.layouts.TFtFlexBox;
  TFtHBox                = ftpas.layouts.TFtHBox;
  TFtVBox                = ftpas.layouts.TFtVBox;
  TFtSpacer              = ftpas.layouts.TFtSpacer;
  TFtFloatingBar         = ftpas.layouts.TFtFloatingBar;
  TFtGrid                = ftpas.layouts.TFtGrid;
  TFtFormGrid            = ftpas.layouts.TFtFormGrid;
  TFtSplitter            = ftpas.layouts.TFtSplitter;
  TFtNotebook            = ftpas.layouts.TFtNotebook;
  TFtTabPage             = ftpas.layouts.TFtTabPage;
  TFtSizeGroup           = ftpas.layouts.TFtSizeGroup;

  { Complex Views }
  TFtTreeNode            = ftpas.views.TFtTreeNode;
  TFtTreeView            = ftpas.views.TFtTreeView;
  TFtTable               = ftpas.views.TFtTable;

  { Creative Suite }
  TFtDrawingArea         = ftpas.creative.TFtDrawingArea;
  TFtRuler               = ftpas.creative.TFtRuler;
  TFtNumberScrubber      = ftpas.creative.TFtNumberScrubber;
  TFtCamera2D            = ftpas.creative.TFtCamera2D;

  { Dialogs }
  TFtFileDialog          = ftpas.dialogs.TFtFileDialog;
  TFtMessageDialog       = ftpas.dialogs.TFtMessageDialog;

  { Menus }
  TFtMenuItem            = ftpas.menus.TFtMenuItem;
  TFtPopupMenu           = ftpas.menus.TFtPopupMenu;
  TFtMainMenu            = ftpas.menus.TFtMainMenu;

  { GPU Acceleration }
  TFtPoint2D             = ftpas.gpu.TFtPoint2D;
  PFtPoint2D             = ftpas.gpu.PFtPoint2D;
  TFtBatchStats          = ftpas.gpu.TFtBatchStats;
  TFtTessMesh            = ftpas.gpu.TFtTessMesh;
  TFtRenderBatch         = ftpas.gpu.TFtRenderBatch;
  TFtGPUTessellator      = ftpas.gpu.TFtGPUTessellator;
  TFtGPURenderer         = ftpas.gpu.TFtGPURenderer;

  { Declarative FTML (Floria Toolkit Markup Language) & Scripting }
  TFtFTMLHost            = ftpas.ftml.TFtFTMLHost;
  TFtFTMLWindow          = ftpas.ftml.TFtFTMLWindow;
  TFtFTMLForm            = ftpas.ftml.TFtFTMLForm;
  TFtFTMLWidgetCreatedEvent = ftpas.ftml.TFtFTMLWidgetCreatedEvent;
  TFtFTMLResource        = ftpas.ftml.res.TFtFTMLResource;
  TFloriaFTMLEngine      = floriajs.TFloriaFTMLEngine;
  TFloriaFTMLItem        = floriajs.TFloriaFTMLItem;
  TFloriaJSValue         = floriajs.TFloriaJSValue;
  TFloriaJSNativeProc    = floriajs.TFloriaJSNativeProc;

{ Global Helper Functions }
function  FtApp(): TFtApp; inline;
function  FtColor(R, G, B: Double; A: Double = 1.0): TFtColor; inline;
function  FtColorHex(const AHex: string): TFtColor; inline;
function  FtRect(AX, AY, AW, AH: Integer): TFtRect; inline;
function  FtPoint2D(AX, AY: Single): TFtPoint2D; inline;

implementation

function FtApp(): TFtApp;
begin
  Result := ftpas.app.FtApp();
end;

function FtColor(R, G, B: Double; A: Double): TFtColor;
begin
  Result := ftpas.types.FtColor(R, G, B, A);
end;

function FtColorHex(const AHex: string): TFtColor;
begin
  Result := ftpas.types.FtColorHex(AHex);
end;

function FtRect(AX, AY, AW, AH: Integer): TFtRect;
begin
  Result := ftpas.types.FtRect(AX, AY, AW, AH);
end;

function FtPoint2D(AX, AY: Single): TFtPoint2D;
begin
  Result := ftpas.gpu.FtPoint2D(AX, AY);
end;

end.
