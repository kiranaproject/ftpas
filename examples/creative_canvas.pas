{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (ftpas) — Creative Canvas & Studio Viewport Example     }
{                                                                          }
{   Demonstrates TFtCamera2D (pan & cursor zoom), TFtRuler (hairline       }
{   tracking, unit switching), TFtNumberScrubber, TFtDrawingArea           }
{   infinite pasteboard, adaptive world-space grid, and artboard paper.    }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

program creative_canvas;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Math,
  ftpas, ftpas.types, ftpas.creative, ftpas.canvas, ftpas.controls,
  ftpas.layouts, ftpas.widget, ftpas.window, ftpas.app;

type
  { TCreativeCanvasWindow — Creative Studio Viewport Window (like TForm in LCL) }
  TCreativeCanvasWindow = class(TFtWindow)
  private
    FCamera: TFtCamera2D;
    FRoot: TFtVBox;

    { Top Main Toolbar }
    FTopBar: TFtHBox;
    FBtnZoomIn: TFtButton;
    FBtnZoomOut: TFtButton;
    FBtnZoomReset: TFtButton;
    FBtnFitDoc: TFtButton;
    FBtnUnitPx: TFtButton;
    FBtnUnitIn: TFtButton;
    FBtnUnitMm: TFtButton;
    FBtnVSync: TFtButton;
    FDarkSwitch: TFtSwitch;

    { Secondary Property Bar }
    FPropBar: TFtHBox;
    FScrubX: TFtNumberScrubber;
    FScrubY: TFtNumberScrubber;
    FScrubW: TFtNumberScrubber;
    FScrubH: TFtNumberScrubber;
    FScrubZoom: TFtNumberScrubber;

    { Central Workspace }
    FWorkVBox: TFtVBox;
    FTopRulerRow: TFtHBox;
    FCornerBox: TFtContainer;
    FRulerH: TFtRuler;
    FMainCanvasRow: TFtHBox;
    FRulerV: TFtRuler;
    FDrawingArea: TFtDrawingArea;

    { Bottom Status Bar }
    FStatusBar: TFtHBox;
    FStatusCoords: TFtLabel;
    FStatusZoom: TFtLabel;

    { Application State }
    FVSync: Integer;
    FDocX, FDocY, FDocW, FDocH: Double;
    FShapeX, FShapeY, FShapeW, FShapeH: Double;

    { Mouse Navigation State }
    FIsPanning: Boolean;
    FPanStartX, FPanStartY: Integer;
    FPanOrigX, FPanOrigY: Double;
    FSpaceHeld: Boolean;
    FLastStatusX, FLastStatusY: Integer;

    procedure SyncRulersAndStatus();

    { Drawing Area Callbacks }
    procedure HandlePaint(Sender: TFtDrawingArea; Canvas: TFtCanvas);
    procedure HandleMouseDown(Sender: TFtDrawingArea; AX, AY, Button: Integer);
    procedure HandleMouseMove(Sender: TFtDrawingArea; AX, AY: Integer);
    procedure HandleMouseUp(Sender: TFtDrawingArea; AX, AY, Button: Integer);
    procedure HandleMouseWheel(Sender: TFtDrawingArea; AX, AY, DeltaX, DeltaY: Integer);
    procedure HandleKeyDown(Sender: TFtDrawingArea; KeySym, State: LongWord);
    procedure HandleKeyUp(Sender: TFtDrawingArea; KeySym, State: LongWord);
    procedure HandleResize(Sender: TFtDrawingArea; NewWidth, NewHeight: Integer);

    { Toolbar Action Callbacks }
    procedure HandleBtnZoomIn(Sender: TFtButton);
    procedure HandleBtnZoomOut(Sender: TFtButton);
    procedure HandleBtnZoomReset(Sender: TFtButton);
    procedure HandleBtnFitDoc(Sender: TFtButton);
    procedure HandleUnitPx(Sender: TFtButton);
    procedure HandleUnitIn(Sender: TFtButton);
    procedure HandleUnitMm(Sender: TFtButton);
    procedure HandleToggleVSync(Sender: TFtButton);
    procedure HandleDarkModeToggle(Sender: TFtSwitch; Toggled: Boolean);

    { Scrubber Callbacks }
    procedure HandleScrubX(Sender: TFtNumberScrubber; NewValue: Double);
    procedure HandleScrubY(Sender: TFtNumberScrubber; NewValue: Double);
    procedure HandleScrubW(Sender: TFtNumberScrubber; NewValue: Double);
    procedure HandleScrubH(Sender: TFtNumberScrubber; NewValue: Double);
    procedure HandleScrubZoom(Sender: TFtNumberScrubber; NewValue: Double);
  public
    constructor Create(); reintroduce;
    destructor Destroy; override;
  end;

constructor TCreativeCanvasWindow.Create();
var
  titleLbl, cardLbl, zoomLbl, darkLbl: TFtLabel;
begin
  inherited Create(960, 680, 'Floria Creative Viewport & Ruler Studio');
  SetPosition(60, 60);
  SwapInterval := 0; { Uncapped presentation for fluid interaction }

  { Default document artboard dimensions in world space }
  FDocX := 100.0;
  FDocY := 60.0;
  FDocW := 640.0;
  FDocH := 420.0;

  { Default editable card geometry }
  FShapeX := 220.0;
  FShapeY := 140.0;
  FShapeW := 200.0;
  FShapeH := 130.0;

  FVSync := 0;
  FIsPanning := False;
  FSpaceHeld := False;
  FLastStatusX := -999;
  FLastStatusY := -999;

  { Viewport Camera with min zoom 0.05 and max zoom 32.0 }
  FCamera := TFtCamera2D.Create(0.05, 32.0);

  { Root Vertical Flexbox Layout — Attached to Self (Window) }
  FRoot := TFtVBox.Create(Self, 0, 0, 960, 680);
  SetLayout(FRoot);

  { ─── Top Main Toolbar (Navigation & Global Actions) ─────────────── }
  FTopBar := TFtHBox.Create(FRoot, 0, 0, 960, 42);
  FTopBar.SetBounds(0, 0, 960, 42);
  FTopBar.SetPadding(12.0, 4.0);
  FTopBar.Gap := 8.0;
  FTopBar.Style := 'background-color: rgba(100, 116, 139, 0.08); border-bottom: 1px solid rgba(100, 116, 139, 0.2);';

  titleLbl := TFtLabel.Create(FTopBar, 0, 0, 160, 28, 'Creative Viewport');
  titleLbl.Font := 'sans-serif,12,bold';

  FBtnZoomIn := TFtButton.Create(FTopBar, 0, 0, 34, 28, '+');
  FBtnZoomIn.OnClick := @HandleBtnZoomIn;

  FBtnZoomOut := TFtButton.Create(FTopBar, 0, 0, 34, 28, '-');
  FBtnZoomOut.OnClick := @HandleBtnZoomOut;

  FBtnZoomReset := TFtButton.Create(FTopBar, 0, 0, 52, 28, '100%');
  FBtnZoomReset.OnClick := @HandleBtnZoomReset;

  FBtnFitDoc := TFtButton.Create(FTopBar, 0, 0, 72, 28, 'Fit Page');
  FBtnFitDoc.OnClick := @HandleBtnFitDoc;

  FBtnUnitPx := TFtButton.Create(FTopBar, 0, 0, 36, 28, 'px');
  FBtnUnitPx.OnClick := @HandleUnitPx;

  FBtnUnitIn := TFtButton.Create(FTopBar, 0, 0, 36, 28, 'in');
  FBtnUnitIn.OnClick := @HandleUnitIn;

  FBtnUnitMm := TFtButton.Create(FTopBar, 0, 0, 40, 28, 'mm');
  FBtnUnitMm.OnClick := @HandleUnitMm;

  FBtnVSync := TFtButton.Create(FTopBar, 0, 0, 120, 28, 'VSync: OFF (0ms)');
  FBtnVSync.OnClick := @HandleToggleVSync;

  TFtSpacer.Create(FTopBar);

  darkLbl := TFtLabel.Create(FTopBar, 0, 0, 85, 28, 'Dark Mode');
  darkLbl.Style := 'color: #64748b;';

  FDarkSwitch := TFtSwitch.Create(FTopBar, 0, 0, 48, 24, '');
  FDarkSwitch.Checked := FtApp.DarkMode;
  FDarkSwitch.OnToggle := @HandleDarkModeToggle;

  { ─── Secondary Property Bar (Photoshop-style Scrubbers) ──────────── }
  FPropBar := TFtHBox.Create(FRoot, 0, 0, 960, 38);
  FPropBar.SetBounds(0, 0, 960, 38);
  FPropBar.SetPadding(12.0, 4.0);
  FPropBar.Gap := 10.0;
  FPropBar.Style := 'background-color: rgba(100, 116, 139, 0.04); border-bottom: 1px solid rgba(100, 116, 139, 0.15);';

  cardLbl := TFtLabel.Create(FPropBar, 0, 0, 100, 26, 'Vector Card:');
  cardLbl.Style := 'font-size: 11px; font-weight: bold; color: #64748b;';

  FScrubX := TFtNumberScrubber.Create(FPropBar, 0, 0, 95, 26, 'X');
  FScrubX.Value := FShapeX;
  FScrubX.Suffix := 'px';
  FScrubX.OnChange := @HandleScrubX;

  FScrubY := TFtNumberScrubber.Create(FPropBar, 0, 0, 95, 26, 'Y');
  FScrubY.Value := FShapeY;
  FScrubY.Suffix := 'px';
  FScrubY.OnChange := @HandleScrubY;

  FScrubW := TFtNumberScrubber.Create(FPropBar, 0, 0, 95, 26, 'W');
  FScrubW.Value := FShapeW;
  FScrubW.Suffix := 'px';
  FScrubW.OnChange := @HandleScrubW;

  FScrubH := TFtNumberScrubber.Create(FPropBar, 0, 0, 95, 26, 'H');
  FScrubH.Value := FShapeH;
  FScrubH.Suffix := 'px';
  FScrubH.OnChange := @HandleScrubH;

  TFtSpacer.Create(FPropBar);

  zoomLbl := TFtLabel.Create(FPropBar, 0, 0, 50, 26, 'Zoom:');
  zoomLbl.Style := 'font-size: 11px; color: #64748b;';

  FScrubZoom := TFtNumberScrubber.Create(FPropBar, 0, 0, 85, 26, '');
  FScrubZoom.SetRange(5.0, 3200.0);
  FScrubZoom.Step := 5.0;
  FScrubZoom.Suffix := '%';
  FScrubZoom.Value := 100.0;
  FScrubZoom.OnChange := @HandleScrubZoom;

  { ─── Central Workspace: Rulers + Drawing Area ───────────────────── }
  FWorkVBox := TFtVBox.Create(FRoot, 0, 0, 960, 560);
  FWorkVBox.FlexGrow := 1.0;

  { Row 1: Corner Square + Top Horizontal Ruler }
  FTopRulerRow := TFtHBox.Create(FWorkVBox, 0, 0, 960, 20);
  FTopRulerRow.SetBounds(0, 0, 960, 20);

  FCornerBox := TFtContainer.Create(FTopRulerRow, 0, 0, 20, 20);
  FCornerBox.SetBounds(0, 0, 20, 20);
  FCornerBox.Style := 'background-color: rgba(100, 116, 139, 0.2); border-right: 1px solid rgba(100, 116, 139, 0.3); border-bottom: 1px solid rgba(100, 116, 139, 0.3);';

  FRulerH := TFtRuler.Create(FTopRulerRow, ftroHorizontal, 0, 0, 940, 20);
  FRulerH.FlexGrow := 1.0;

  { Row 2: Left Vertical Ruler + Central Drawing Area }
  FMainCanvasRow := TFtHBox.Create(FWorkVBox, 0, 0, 960, 540);
  FMainCanvasRow.FlexGrow := 1.0;

  FRulerV := TFtRuler.Create(FMainCanvasRow, ftroVertical, 0, 0, 20, 540);
  FRulerV.SetBounds(0, 0, 20, 540);

  FDrawingArea := TFtDrawingArea.Create(FMainCanvasRow, 0, 0, 940, 540);
  FDrawingArea.FlexGrow := 1.0;
  FDrawingArea.OnPaint := @HandlePaint;
  FDrawingArea.OnMouseDown := @HandleMouseDown;
  FDrawingArea.OnMouseMove := @HandleMouseMove;
  FDrawingArea.OnMouseUp := @HandleMouseUp;
  FDrawingArea.OnMouseWheel := @HandleMouseWheel;
  FDrawingArea.OnKeyDown := @HandleKeyDown;
  FDrawingArea.OnKeyUp := @HandleKeyUp;
  FDrawingArea.OnResize := @HandleResize;

  { ─── Bottom Status Bar ─────────────────────────────────────────── }
  FStatusBar := TFtHBox.Create(FRoot, 0, 0, 960, 26);
  FStatusBar.SetBounds(0, 0, 960, 26);
  FStatusBar.SetPadding(12.0, 3.0);
  FStatusBar.Style := 'background-color: rgba(100, 116, 139, 0.08); border-top: 1px solid rgba(100, 116, 139, 0.2);';

  FStatusCoords := TFtLabel.Create(FStatusBar, 0, 0, 360, 20, 'Doc: (0.0, 0.0) px | World: (0.0, 0.0)');
  FStatusCoords.Style := 'font-size: 11px; color: #64748b;';

  TFtSpacer.Create(FStatusBar);

  FStatusZoom := TFtLabel.Create(FStatusBar, 0, 0, 120, 20, 'Zoom: 100%');
  FStatusZoom.Style := 'font-size: 11px; color: #0284c7; text-align: right;';

  { Initial layout pass and document centering }
  FRoot.UpdateLayout();
  HandleBtnFitDoc(nil);
end;

destructor TCreativeCanvasWindow.Destroy();
begin
  FCamera.Free();
  inherited Destroy();
end;

procedure TCreativeCanvasWindow.SyncRulersAndStatus();
var
  zoom, docScreenX, docScreenY: Double;
begin
  if FCamera = nil then Exit;

  zoom := FCamera.Zoom;

  { Sync horizontal & vertical rulers with artboard origin in screen space }
  FCamera.WorldToScreen(FDocX, FDocY, docScreenX, docScreenY);

  if FRulerH <> nil then
    FRulerH.SetOriginAndScale(docScreenX, zoom);
  if FRulerV <> nil then
    FRulerV.SetOriginAndScale(docScreenY, zoom);

  { Update status bar zoom and scrubber }
  if FStatusZoom <> nil then
    FStatusZoom.Text := Format('Zoom: %d%%', [Round(zoom * 100.0)]);
  if FScrubZoom <> nil then
    FScrubZoom.Value := zoom * 100.0;
end;

procedure TCreativeCanvasWindow.HandlePaint(Sender: TFtDrawingArea; Canvas: TFtCanvas);
var
  viewW, viewH, areaX, areaY: Integer;
  isDark: Boolean;
  zoom: Double;
  topLeftWldX, topLeftWldY, botRightWldX, botRightWldY: Double;
  minWldX, maxWldX, minWldY, maxWldY: Double;
  gridStep, gridR, gridG, gridB, gridAlpha: Double;
  startGX, endGX, gx, startGY, endGY, gy, sx, sy: Double;
  docSX, docSY, docSW, docSH: Double;
  headerSX, headerSY, circCX, circCY: Double;
  shpSX, shpSY, shpSW, shpSH, lblSX, lblSY, hRad: Double;
begin
  if (FCamera = nil) or (Canvas = nil) then Exit;

  viewW := Sender.Width;
  viewH := Sender.Height;
  areaX := Sender.X;
  areaY := Sender.Y;
  isDark := FtApp.DarkMode;

  { 1. Infinite Pasteboard Background }
  if isDark then
    Canvas.DrawRect(areaX, areaY, viewW, viewH, 0.11, 0.13, 0.17, 1.0) { slate-900 }
  else
    Canvas.DrawRect(areaX, areaY, viewW, viewH, 0.90, 0.92, 0.94, 1.0); { slate-200 }

  zoom := FCamera.Zoom;

  { 2. Adaptive Grid in World Coordinates }
  FCamera.ScreenToWorld(0.0, 0.0, topLeftWldX, topLeftWldY);
  FCamera.ScreenToWorld(Double(viewW), Double(viewH), botRightWldX, botRightWldY);

  if topLeftWldX < botRightWldX then
  begin
    minWldX := topLeftWldX;
    maxWldX := botRightWldX;
  end
  else
  begin
    minWldX := botRightWldX;
    maxWldX := topLeftWldX;
  end;

  if topLeftWldY < botRightWldY then
  begin
    minWldY := topLeftWldY;
    maxWldY := botRightWldY;
  end
  else
  begin
    minWldY := botRightWldY;
    maxWldY := topLeftWldY;
  end;

  gridStep := 50.0;
  if zoom < 0.4 then
    gridStep := 200.0
  else if zoom < 0.8 then
    gridStep := 100.0
  else if zoom > 2.5 then
    gridStep := 10.0;

  if isDark then
  begin
    gridR := 0.20;
    gridG := 0.24;
    gridB := 0.30;
  end
  else
  begin
    gridR := 0.80;
    gridG := 0.83;
    gridB := 0.86;
  end;
  gridAlpha := 0.4;

  { Vertical grid lines }
  startGX := Floor(minWldX / gridStep) * gridStep - gridStep;
  endGX := Ceil(maxWldX / gridStep) * gridStep + gridStep;
  gx := startGX;
  while gx <= endGX do
  begin
    FCamera.WorldToScreen(gx, 0.0, sx, sy);
    Canvas.DrawLine(areaX + sx, areaY, areaX + sx, areaY + viewH, 1.0, gridR, gridG, gridB, gridAlpha);
    gx := gx + gridStep;
  end;

  { Horizontal grid lines }
  startGY := Floor(minWldY / gridStep) * gridStep - gridStep;
  endGY := Ceil(maxWldY / gridStep) * gridStep + gridStep;
  gy := startGY;
  while gy <= endGY do
  begin
    FCamera.WorldToScreen(0.0, gy, sx, sy);
    Canvas.DrawLine(areaX, areaY + sy, areaX + viewW, areaY + sy, 1.0, gridR, gridG, gridB, gridAlpha);
    gy := gy + gridStep;
  end;

  { 3. Document Sheet (Artboard Page with Drop Shadow) }
  FCamera.WorldToScreen(FDocX, FDocY, docSX, docSY);
  docSW := FDocW * zoom;
  docSH := FDocH * zoom;

  { Soft Drop Shadow }
  if isDark then
  begin
    Canvas.DrawRoundedRect(areaX + docSX + 4.0, areaY + docSY + 4.0, docSW, docSH, 4.0, 0.0, 0.0, 0.0, 0.35);
    Canvas.DrawRoundedRect(areaX + docSX + 2.0, areaY + docSY + 2.0, docSW, docSH, 2.0, 0.0, 0.0, 0.0, 0.20);
    { Dark Artboard Page }
    Canvas.DrawRect(Trunc(areaX + docSX), Trunc(areaY + docSY), Trunc(docSW), Trunc(docSH), 0.18, 0.21, 0.27, 1.0);
    Canvas.DrawRoundedRectOutline(areaX + docSX, areaY + docSY, docSW, docSH, 0.0, 1.0, 0.35, 0.40, 0.48, 1.0);
  end
  else
  begin
    Canvas.DrawRoundedRect(areaX + docSX + 4.0, areaY + docSY + 4.0, docSW, docSH, 4.0, 0.0, 0.0, 0.0, 0.12);
    Canvas.DrawRoundedRect(areaX + docSX + 2.0, areaY + docSY + 2.0, docSW, docSH, 2.0, 0.0, 0.0, 0.0, 0.08);
    { White Paper Page }
    Canvas.DrawRect(Trunc(areaX + docSX), Trunc(areaY + docSY), Trunc(docSW), Trunc(docSH), 1.0, 1.0, 1.0, 1.0);
    Canvas.DrawRoundedRectOutline(areaX + docSX, areaY + docSY, docSW, docSH, 0.0, 1.0, 0.75, 0.78, 0.82, 1.0);
  end;

  { 4. Artboard Content: Header, Decorative Elements, Interactive Card }
  FCamera.WorldToScreen(FDocX + 30.0, FDocY + 35.0, headerSX, headerSY);
  if isDark then
    Canvas.DrawText(areaX + headerSX, areaY + headerSY, 'Floria Vector Document (Artboard 1)', 0.90, 0.92, 0.96)
  else
    Canvas.DrawText(areaX + headerSX, areaY + headerSY, 'Floria Vector Document (Artboard 1)', 0.15, 0.20, 0.25);

  { Static Decorative Circle }
  FCamera.WorldToScreen(FDocX + 100.0, FDocY + 180.0, circCX, circCY);
  Canvas.DrawCircle(areaX + circCX, areaY + circCY, (45.0 + 3.0) * zoom, 1.0, 1.0, 1.0, 0.4);
  Canvas.DrawCircle(areaX + circCX, areaY + circCY, 45.0 * zoom, 0.93, 0.27, 0.36, 0.85); { rose-500 }

  { Interactive Card (Controlled by scrubbers) }
  FCamera.WorldToScreen(FShapeX, FShapeY, shpSX, shpSY);
  shpSW := FShapeW * zoom;
  shpSH := FShapeH * zoom;

  { Blue filled card }
  Canvas.DrawRoundedRect(areaX + shpSX, areaY + shpSY, shpSW, shpSH, 8.0 * zoom, 0.14, 0.45, 0.91, 0.90);
  Canvas.DrawRoundedRectOutline(areaX + shpSX, areaY + shpSY, shpSW, shpSH, 8.0 * zoom, 2.0, 0.38, 0.72, 0.98, 1.0);

  { Card Label }
  FCamera.WorldToScreen(FShapeX + 16.0, FShapeY + 34.0, lblSX, lblSY);
  Canvas.DrawText(areaX + lblSX, areaY + lblSY, 'Interactive Vector Card', 1.0, 1.0, 1.0);

  { 4 Selection Handles }
  hRad := 4.0;
  Canvas.DrawRect(Trunc(areaX + shpSX - hRad), Trunc(areaY + shpSY - hRad), Trunc(hRad * 2), Trunc(hRad * 2), 1.0, 1.0, 1.0, 1.0);
  Canvas.DrawRect(Trunc(areaX + shpSX + shpSW - hRad), Trunc(areaY + shpSY - hRad), Trunc(hRad * 2), Trunc(hRad * 2), 1.0, 1.0, 1.0, 1.0);
  Canvas.DrawRect(Trunc(areaX + shpSX - hRad), Trunc(areaY + shpSY + shpSH - hRad), Trunc(hRad * 2), Trunc(hRad * 2), 1.0, 1.0, 1.0, 1.0);
  Canvas.DrawRect(Trunc(areaX + shpSX + shpSW - hRad), Trunc(areaY + shpSY + shpSH - hRad), Trunc(hRad * 2), Trunc(hRad * 2), 1.0, 1.0, 1.0, 1.0);
end;

procedure TCreativeCanvasWindow.HandleMouseDown(Sender: TFtDrawingArea; AX, AY, Button: Integer);
begin
  { Middle button (2) or Left click (1) with spacebar initiates viewport panning }
  if (Button = 2) or ((Button = 1) and FSpaceHeld) then
  begin
    FIsPanning := True;
    FPanStartX := AX;
    FPanStartY := AY;
    FCamera.GetPan(FPanOrigX, FPanOrigY);
    FDrawingArea.Cursor := ftcMove;
  end;
end;

procedure TCreativeCanvasWindow.HandleMouseMove(Sender: TFtDrawingArea; AX, AY: Integer);
var
  dx, dy: Integer;
  wx, wy, relDocX, relDocY: Double;
begin
  if FIsPanning then
  begin
    dx := AX - FPanStartX;
    dy := AY - FPanStartY;
    FCamera.SetPan(FPanOrigX + dx, FPanOrigY + dy);
    SyncRulersAndStatus();
    Sender.Invalidate();
  end;

  { Update ruler pointer tracking hairlines }
  if FRulerH <> nil then FRulerH.PointerPosition := AX;
  if FRulerV <> nil then FRulerV.PointerPosition := AY;

  { Update World coordinates in status bar (avoid jitter) }
  if (FCamera <> nil) and (FStatusCoords <> nil) and
     ((Abs(AX - FLastStatusX) >= 2) or (Abs(AY - FLastStatusY) >= 2)) then
  begin
    FLastStatusX := AX;
    FLastStatusY := AY;
    FCamera.ScreenToWorld(Double(AX), Double(AY), wx, wy);
    relDocX := wx - FDocX;
    relDocY := wy - FDocY;
    FStatusCoords.Text := Format('Doc: (%.1f, %.1f) px | World: (%.1f, %.1f)', [relDocX, relDocY, wx, wy]);
  end;
end;

procedure TCreativeCanvasWindow.HandleMouseUp(Sender: TFtDrawingArea; AX, AY, Button: Integer);
begin
  if FIsPanning and ((Button = 2) or (Button = 1)) then
  begin
    FIsPanning := False;
    if FSpaceHeld then
      FDrawingArea.Cursor := ftcHand
    else
      FDrawingArea.Cursor := ftcDefault;
  end;
end;

procedure TCreativeCanvasWindow.HandleMouseWheel(Sender: TFtDrawingArea; AX, AY, DeltaX, DeltaY: Integer);
var
  factor: Double;
begin
  if FCamera = nil then Exit;

  { Zoom in/out anchored on cursor position }
  if DeltaY > 0 then
    factor := 1.15
  else
    factor := 1.0 / 1.15;

  FCamera.ZoomAt(Double(AX), Double(AY), factor);
  SyncRulersAndStatus();
  Sender.Invalidate();
end;

procedure TCreativeCanvasWindow.HandleKeyDown(Sender: TFtDrawingArea; KeySym, State: LongWord);
begin
  { Spacebar (XK_space = 32) enables hand panning mode }
  if KeySym = 32 then
  begin
    FSpaceHeld := True;
    FDrawingArea.Cursor := ftcHand;
  end;
end;

procedure TCreativeCanvasWindow.HandleKeyUp(Sender: TFtDrawingArea; KeySym, State: LongWord);
begin
  if KeySym = 32 then
  begin
    FSpaceHeld := False;
    if not FIsPanning then
      FDrawingArea.Cursor := ftcDefault;
  end;
end;

procedure TCreativeCanvasWindow.HandleResize(Sender: TFtDrawingArea; NewWidth, NewHeight: Integer);
begin
  SyncRulersAndStatus();
end;

procedure TCreativeCanvasWindow.HandleBtnZoomIn(Sender: TFtButton);
var
  w, h: Integer;
begin
  if (FCamera = nil) or (FDrawingArea = nil) then Exit;
  w := FDrawingArea.Width;
  h := FDrawingArea.Height;
  FCamera.ZoomAt(w * 0.5, h * 0.5, 1.25);
  SyncRulersAndStatus();
  FDrawingArea.Invalidate();
end;

procedure TCreativeCanvasWindow.HandleBtnZoomOut(Sender: TFtButton);
var
  w, h: Integer;
begin
  if (FCamera = nil) or (FDrawingArea = nil) then Exit;
  w := FDrawingArea.Width;
  h := FDrawingArea.Height;
  FCamera.ZoomAt(w * 0.5, h * 0.5, 0.80);
  SyncRulersAndStatus();
  FDrawingArea.Invalidate();
end;

procedure TCreativeCanvasWindow.HandleBtnZoomReset(Sender: TFtButton);
var
  w, h: Integer;
  centerDocX, centerDocY: Double;
begin
  if (FCamera = nil) or (FDrawingArea = nil) then Exit;
  w := FDrawingArea.Width;
  h := FDrawingArea.Height;
  centerDocX := FDocX + FDocW * 0.5;
  centerDocY := FDocY + FDocH * 0.5;
  FCamera.Zoom := 1.0;
  FCamera.SetPan((w * 0.5) - centerDocX, (h * 0.5) - centerDocY);
  SyncRulersAndStatus();
  FDrawingArea.Invalidate();
end;

procedure TCreativeCanvasWindow.HandleBtnFitDoc(Sender: TFtButton);
var
  w, h: Integer;
begin
  if (FCamera = nil) or (FDrawingArea = nil) then Exit;
  w := FDrawingArea.Width;
  h := FDrawingArea.Height;
  FCamera.FitRect(FDocX, FDocY, FDocW, FDocH, Double(w), Double(h), 40.0);
  SyncRulersAndStatus();
  FDrawingArea.Invalidate();
end;

procedure TCreativeCanvasWindow.HandleUnitPx(Sender: TFtButton);
begin
  if FRulerH <> nil then FRulerH.UnitKind := ftruPixels;
  if FRulerV <> nil then FRulerV.UnitKind := ftruPixels;
end;

procedure TCreativeCanvasWindow.HandleUnitIn(Sender: TFtButton);
begin
  if FRulerH <> nil then FRulerH.UnitKind := ftruInches;
  if FRulerV <> nil then FRulerV.UnitKind := ftruInches;
end;

procedure TCreativeCanvasWindow.HandleUnitMm(Sender: TFtButton);
begin
  if FRulerH <> nil then FRulerH.UnitKind := ftruMillimeters;
  if FRulerV <> nil then FRulerV.UnitKind := ftruMillimeters;
end;

procedure TCreativeCanvasWindow.HandleToggleVSync(Sender: TFtButton);
begin
  FVSync := 1 - FVSync;
  SwapInterval := FVSync;
  if FVSync <> 0 then
    Sender.Caption := 'VSync: 60Hz'
  else
    Sender.Caption := 'VSync: OFF (0ms)';
end;

procedure TCreativeCanvasWindow.HandleDarkModeToggle(Sender: TFtSwitch; Toggled: Boolean);
begin
  FtApp.DarkMode := Toggled;
  if FDrawingArea <> nil then FDrawingArea.Invalidate();
  if FRulerH <> nil then FRulerH.Invalidate();
  if FRulerV <> nil then FRulerV.Invalidate();
end;

procedure TCreativeCanvasWindow.HandleScrubX(Sender: TFtNumberScrubber; NewValue: Double);
begin
  FShapeX := NewValue;
  if FDrawingArea <> nil then FDrawingArea.Invalidate();
end;

procedure TCreativeCanvasWindow.HandleScrubY(Sender: TFtNumberScrubber; NewValue: Double);
begin
  FShapeY := NewValue;
  if FDrawingArea <> nil then FDrawingArea.Invalidate();
end;

procedure TCreativeCanvasWindow.HandleScrubW(Sender: TFtNumberScrubber; NewValue: Double);
begin
  FShapeW := NewValue;
  if FDrawingArea <> nil then FDrawingArea.Invalidate();
end;

procedure TCreativeCanvasWindow.HandleScrubH(Sender: TFtNumberScrubber; NewValue: Double);
begin
  FShapeH := NewValue;
  if FDrawingArea <> nil then FDrawingArea.Invalidate();
end;

procedure TCreativeCanvasWindow.HandleScrubZoom(Sender: TFtNumberScrubber; NewValue: Double);
var
  w, h: Integer;
begin
  if (FCamera = nil) or (FDrawingArea = nil) then Exit;
  w := FDrawingArea.Width;
  h := FDrawingArea.Height;
  FCamera.SetZoomAt(w * 0.5, h * 0.5, NewValue / 100.0);
  SyncRulersAndStatus();
  FDrawingArea.Invalidate();
end;

var
  StudioWindow: TCreativeCanvasWindow;

begin
  StudioWindow := TCreativeCanvasWindow.Create();
  try
    StudioWindow.Show();
    FtApp.Run();
  finally
    StudioWindow.Free();
  end;
end.
