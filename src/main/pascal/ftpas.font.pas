{ ************************************************************************** }
{   Floria Toolkit (ftpas) — Font object wrapper                           }
{   Copyright (c) 2026 Dio Affriza — SPDX-License-Identifier: MPL-2.0      }
{                                                                          }
{   TFtFontRef wraps a Floria font object created through ft_font_create.   }
{   It gives Pascal code a font handle for TFtCanvas.DrawText plus exact    }
{   advance/metric measurements, which terminal and text views need.        }
{ ************************************************************************** }

unit ftpas.font;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, ftpas.api;

type
  TFtFontRef = class
  private
    FHandle: Pointer;
    FOwnsHandle: Boolean;
    function GetValid: Boolean;
  public
    { Empty description selects the current system font. }
    constructor Create(const ADesc: string = '');
    destructor Destroy(); override;

    function  AsciiAdvance(AChar: AnsiChar): Double;
    function  TextWidth(const AText: string): Double;
    procedure GetMetrics(out AAscent, ADescent, AHeight, AMaxAdvance: Double);

    property Handle: Pointer read FHandle;
    property Valid: Boolean read GetValid;
  end;

implementation

constructor TFtFontRef.Create(const ADesc: string);
begin
  inherited Create();
  if Assigned(ft_font_create) then
    FHandle := ft_font_create(PChar(ADesc))
  else
    FHandle := nil;
  { The font manager owns and caches font objects, so we never destroy them. }
  FOwnsHandle := False;
end;

destructor TFtFontRef.Destroy();
begin
  inherited Destroy();
end;

function TFtFontRef.GetValid: Boolean;
begin
  Result := FHandle <> nil;
end;

function TFtFontRef.AsciiAdvance(AChar: AnsiChar): Double;
begin
  if Assigned(ft_font_ascii_advance) and (FHandle <> nil) then
    Result := ft_font_ascii_advance(FHandle, Ord(AChar))
  else
    Result := 0.0;
end;

function TFtFontRef.TextWidth(const AText: string): Double;
begin
  if Assigned(ft_font_text_width) and (FHandle <> nil) then
    Result := ft_font_text_width(FHandle, PChar(AText))
  else
    Result := 0.0;
end;

procedure TFtFontRef.GetMetrics(out AAscent, ADescent, AHeight, AMaxAdvance: Double);
begin
  AAscent := 0.0;
  ADescent := 0.0;
  AHeight := 0.0;
  AMaxAdvance := 0.0;
  if Assigned(ft_font_get_metrics) and (FHandle <> nil) then
    ft_font_get_metrics(FHandle, AAscent, ADescent, AHeight, AMaxAdvance);
end;

end.
