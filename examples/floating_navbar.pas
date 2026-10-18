{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (ftpas) — Floating Navbar & Creative Canvas Example     }
{                                                                          }
{   Demonstrates TFtFloatingBar, TFtDrawingArea vector painting,           }
{   TFtRuler, and TFtNumberScrubber in an idiomatic OOP design.            }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

program floating_navbar;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, ftpas, ftpas.types;

type
  { TFloatingNavWindow — Studio window demonstrating floating bar & canvas (like TForm in LCL) }
  TFloatingNavWindow = class(TFtWindow)
  private
    FRulerH: TFtRuler;
    FDrawingArea: TFtDrawingArea;
    FFloatingBar: TFtFloatingBar;
    FScrubber: TFtNumberScrubber;
    FStatusLabel: TFtLabel;

    FBtnHome: TFtButton;
    FBtnGrid: TFtButton;
    FBtnClear: TFtButton;

    FBrushRadius: Double;
    FShowGrid: Boolean;

    procedure HandlePaint(Sender: TFtDrawingArea; Canvas: TFtCanvas);
    procedure HandleScrubberChange(Sender: TFtNumberScrubber; NewValue: Double);
    procedure HandleGridToggle(Sender: TFtButton);
    procedure HandleClearCanvas(Sender: TFtButton);
  public
    constructor Create(); reintroduce;
  end;

constructor TFloatingNavWindow.Create();
begin
  inherited Create(800, 600, 'Floria Toolkit — Floating Bar & Creative Suite');
  FBrushRadius := 24.0;
  FShowGrid := True;

  { Horizontal Top Ruler — Attached to Self (Window) }
  FRulerH := TFtRuler.Create(Self, ftroHorizontal, 0, 0, 800, 24);
  FRulerH.SetOriginAndScale(0.0, 1.0);
  FRulerH.UnitKind := ftruPixels;
  FRulerH.ShowPointer := True;

  { Central Interactive Drawing Area — Attached to Self }
  FDrawingArea := TFtDrawingArea.Create(Self, 0, 24, 800, 576);
  FDrawingArea.ClipToBounds := True;
  FDrawingArea.OnPaint := @HandlePaint;

  { Floating Capsule Bottom Navigation Bar — Attached to Self }
  FFloatingBar := TFtFloatingBar.Create(Self, ftamBottomCenter, 460, 52);
  FFloatingBar.SetMargins(20.0, 24.0);
  FFloatingBar.AutoAnchor := True;

  { Controls inside the Floating Bar }
  FBtnHome := TFtButton.Create(FFloatingBar, 12, 8, 80, 36, 'Reset');
  FBtnHome.OnClick := @HandleClearCanvas;

  FBtnGrid := TFtButton.Create(FFloatingBar, 100, 8, 80, 36, 'Grid');
  FBtnGrid.OnClick := @HandleGridToggle;

  { Draggable Numeric Scrubber for Brush Radius }
  FScrubber := TFtNumberScrubber.Create(FFloatingBar, 190, 8, 140, 36, 'Radius');
  FScrubber.SetRange(4.0, 80.0);
  FScrubber.Decimals := 1;
  FScrubber.Value := FBrushRadius;
  FScrubber.Suffix := ' px';
  FScrubber.OnChange := @HandleScrubberChange;

  FBtnClear := TFtButton.Create(FFloatingBar, 340, 8, 105, 36, 'Clear');
  FBtnClear.OnClick := @HandleClearCanvas;

  { Status Display Overlay — Attached to Self }
  FStatusLabel := TFtLabel.Create(Self, 16, 36, 300, 24, 'Creative Canvas Ready');
end;

procedure TFloatingNavWindow.HandlePaint(Sender: TFtDrawingArea; Canvas: TFtCanvas);
var
  gx, gy: Integer;
begin
  { Background }
  Canvas.DrawRect(0, 0, Sender.Width, Sender.Height, 0.95, 0.96, 0.98, 1.0);

  { Grid lines if enabled }
  if FShowGrid then
  begin
    gx := 0;
    while gx < Sender.Width do
    begin
      Canvas.DrawLine(gx, 0, gx, Sender.Height, 1.0, 0.88, 0.90, 0.92, 0.8);
      Inc(gx, 40);
    end;
    gy := 0;
    while gy < Sender.Height do
    begin
      Canvas.DrawLine(0, gy, Sender.Width, gy, 1.0, 0.88, 0.90, 0.92, 0.8);
      Inc(gy, 40);
    end;
  end;

  { Central vector artwork showcase }
  Canvas.DrawRoundedRect(250, 150, 300, 180, 16.0, 0.25, 0.45, 0.95, 0.9);
  Canvas.DrawRoundedRectOutline(250, 150, 300, 180, 16.0, 2.0, 1.0, 1.0, 1.0, 0.8);
  Canvas.DrawCircle(400, 240, FBrushRadius, 1.0, 0.85, 0.2, 0.95);
  Canvas.DrawTextCentered(250, 260, 300, 30, 'Floria Toolkit ftpas', 1.0, 1.0, 1.0);
end;

procedure TFloatingNavWindow.HandleScrubberChange(Sender: TFtNumberScrubber; NewValue: Double);
begin
  FBrushRadius := NewValue;
  FStatusLabel.Text := Format('Radius: %0.1f px', [NewValue]);
  FDrawingArea.Invalidate();
end;

procedure TFloatingNavWindow.HandleGridToggle(Sender: TFtButton);
begin
  FShowGrid := not FShowGrid;
  FDrawingArea.Invalidate();
  if FShowGrid then
    FStatusLabel.Text := 'Grid enabled'
  else
    FStatusLabel.Text := 'Grid disabled';
end;

procedure TFloatingNavWindow.HandleClearCanvas(Sender: TFtButton);
begin
  FBrushRadius := 24.0;
  FScrubber.Value := 24.0;
  FShowGrid := True;
  FStatusLabel.Text := 'Canvas reset to defaults';
  FDrawingArea.Invalidate();
end;

var
  StudioWindow: TFloatingNavWindow;

begin
  StudioWindow := TFloatingNavWindow.Create();
  try
    StudioWindow.Show();
    FtApp.Run();
  finally
    StudioWindow.Free();
  end;
end.
