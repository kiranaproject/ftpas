{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal Canvas & Bitmap OOP Wrappers       }
{                                                                          }
{   Provides TFtBitmap and TFtCanvas classes for 2D software and GPU       }
{   rasterization, vector geometry, SVG rendering, and clipping stacks.    }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.canvas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ftpas.api, ftpas.types;

type
  { Forward Declarations }
  TFtBitmap = class;
  TFtCanvas = class;

  { TFtBitmap — In-memory BGRA pixel buffer & SVG rasterizer wrapper }
  TFtBitmap = class
  private
    FHandle: Pointer;
    FOwnsHandle: Boolean;
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetStride: Integer;
    function GetPixels: Pointer;
  public
    constructor Create(AWidth, AHeight: Integer);
    constructor CreateFromFile(const AFilePath: string);
    constructor CreateFromMemory(AData: Pointer; ASize: Integer);
    constructor CreateFromRGBA(APixels: Pointer; AWidth, AHeight: Integer);
    constructor CreateFromBGRA(APixels: Pointer; AWidth, AHeight: Integer);
    constructor CreateFromSVG(const ASVGContent: string; AWidth, AHeight: Integer);
    constructor CreateFromSVGFile(const AFilePath: string; AWidth, AHeight: Integer);
    constructor Wrap(AHandle: Pointer; AOwnsHandle: Boolean = False);
    destructor Destroy; override;

    function CreateScaled(ANewWidth, ANewHeight: Integer): TFtBitmap;
    procedure SaveToFile(const AFilePath: string);

    property Handle: Pointer read FHandle;
    property OwnsHandle: Boolean read FOwnsHandle write FOwnsHandle;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property Stride: Integer read GetStride;
    property Pixels: Pointer read GetPixels;
  end;

  { TFtCanvas — Direct 2D vector and image drawing context }
  TFtCanvas = class
  private
    FHandle: Pointer;
    function GetAlpha: Double;
  public
    constructor Create(ACanvasHandle: Pointer);

    { Shapes & Vector Geometry }
    procedure DrawRect(X, Y, W, H: Integer; R, G, B: Double; A: Double = 1.0); overload;
    procedure DrawRect(const ARect: TFtRect; const AColor: TFtColor); overload;
    procedure DrawRoundedRect(X, Y, W, H, Radius: Double; R, G, B: Double; A: Double = 1.0); overload;
    procedure DrawRoundedRect(const ARect: TFtRect; Radius: Double; const AColor: TFtColor); overload;
    procedure DrawRoundedRectOutline(X, Y, W, H, Radius, BorderWidth: Double; R, G, B: Double; A: Double = 1.0); overload;
    procedure DrawLine(X1, Y1, X2, Y2, Width: Double; R, G, B: Double; A: Double = 1.0);
    procedure DrawCircle(CX, CY, Radius: Double; R, G, B: Double; A: Double = 1.0);

    { Text Rendering }
    procedure DrawText(X, Y: Double; const AText: string; R, G, B: Double; AFont: Pointer = nil);
    procedure DrawTextLeft(X, Y, W, H: Double; const AText: string; R, G, B: Double; AFont: Pointer = nil);
    procedure DrawTextCentered(X, Y, W, H: Integer; const AText: string; R, G, B: Double; AFont: Pointer = nil);

    { Image & SVG Rendering }
    procedure DrawImage(X, Y: Double; ABitmap: TFtBitmap; Opacity: Double = 1.0);
    procedure DrawImageScaled(X, Y, W, H: Double; ABitmap: TFtBitmap; Opacity: Double = 1.0);
    procedure DrawImagePart(X, Y, W, H: Double; ABitmap: TFtBitmap; SrcX, SrcY, SrcW, SrcH: Integer; Opacity: Double = 1.0);
    procedure DrawSVG(X, Y, W, H: Double; const ASVGContent: string);
    procedure DrawSVGFile(X, Y, W, H: Double; const AFilePath: string);

    { Clipping Stack }
    procedure PushClipRect(X, Y, W, H: Integer);
    procedure PopClipRect();
    procedure PushClipRoundedRect(X, Y, W, H, Radius: Double);
    procedure PopClipRoundedRect();
    procedure ResetClipping();

    { Alpha Stack }
    procedure PushAlpha(AAlpha: Double);
    procedure PopAlpha();
    procedure ResetAlpha();

    property Handle: Pointer read FHandle;
    property Alpha: Double read GetAlpha;
  end;

implementation

{ TFtBitmap }

constructor TFtBitmap.Create(AWidth, AHeight: Integer);
begin
  inherited Create;
  FHandle := ft_bitmap_create(AWidth, AHeight);
  FOwnsHandle := True;
end;

constructor TFtBitmap.CreateFromFile(const AFilePath: string);
begin
  inherited Create;
  FHandle := ft_bitmap_load_file(PChar(AFilePath));
  FOwnsHandle := True;
end;

constructor TFtBitmap.CreateFromMemory(AData: Pointer; ASize: Integer);
begin
  inherited Create;
  FHandle := ft_bitmap_load_memory(AData, ASize);
  FOwnsHandle := True;
end;

constructor TFtBitmap.CreateFromRGBA(APixels: Pointer; AWidth, AHeight: Integer);
begin
  inherited Create;
  FHandle := ft_bitmap_create_from_rgba(APixels, AWidth, AHeight);
  FOwnsHandle := True;
end;

constructor TFtBitmap.CreateFromBGRA(APixels: Pointer; AWidth, AHeight: Integer);
begin
  inherited Create;
  FHandle := ft_bitmap_create_from_bgra(APixels, AWidth, AHeight);
  FOwnsHandle := True;
end;

constructor TFtBitmap.CreateFromSVG(const ASVGContent: string; AWidth, AHeight: Integer);
begin
  inherited Create;
  FHandle := ft_bitmap_create_from_svg(PChar(ASVGContent), AWidth, AHeight);
  FOwnsHandle := True;
end;

constructor TFtBitmap.CreateFromSVGFile(const AFilePath: string; AWidth, AHeight: Integer);
begin
  inherited Create;
  FHandle := ft_bitmap_create_from_svg_file(PChar(AFilePath), AWidth, AHeight);
  FOwnsHandle := True;
end;

constructor TFtBitmap.Wrap(AHandle: Pointer; AOwnsHandle: Boolean = False);
begin
  inherited Create;
  FHandle := AHandle;
  FOwnsHandle := AOwnsHandle;
end;

destructor TFtBitmap.Destroy;
begin
  if FOwnsHandle and (FHandle <> nil) and Assigned(ft_bitmap_destroy) then
  begin
    ft_bitmap_destroy(FHandle);
    FHandle := nil;
  end;
  inherited Destroy;
end;

function TFtBitmap.GetWidth: Integer;
begin
  if (FHandle <> nil) and Assigned(ft_bitmap_get_width) then
    Result := ft_bitmap_get_width(FHandle)
  else
    Result := 0;
end;

function TFtBitmap.GetHeight: Integer;
begin
  if (FHandle <> nil) and Assigned(ft_bitmap_get_height) then
    Result := ft_bitmap_get_height(FHandle)
  else
    Result := 0;
end;

function TFtBitmap.GetStride: Integer;
begin
  if (FHandle <> nil) and Assigned(ft_bitmap_get_stride) then
    Result := ft_bitmap_get_stride(FHandle)
  else
    Result := 0;
end;

function TFtBitmap.GetPixels: Pointer;
begin
  if (FHandle <> nil) and Assigned(ft_bitmap_get_pixels) then
    Result := ft_bitmap_get_pixels(FHandle)
  else
    Result := nil;
end;

function TFtBitmap.CreateScaled(ANewWidth, ANewHeight: Integer): TFtBitmap;
var
  newHandle: Pointer;
begin
  if (FHandle <> nil) and Assigned(ft_bitmap_create_scaled) then
  begin
    newHandle := ft_bitmap_create_scaled(FHandle, ANewWidth, ANewHeight);
    Result := TFtBitmap.Wrap(newHandle, True);
  end
  else
    Result := nil;
end;

procedure TFtBitmap.SaveToFile(const AFilePath: string);
begin
  if (FHandle <> nil) and Assigned(ft_bitmap_save_to_file) then
    ft_bitmap_save_to_file(FHandle, PChar(AFilePath));
end;

{ TFtCanvas }

constructor TFtCanvas.Create(ACanvasHandle: Pointer);
begin
  inherited Create;
  FHandle := ACanvasHandle;
end;

function TFtCanvas.GetAlpha: Double;
begin
  if (FHandle <> nil) and Assigned(ft_canvas_get_alpha) then
    Result := ft_canvas_get_alpha(FHandle)
  else
    Result := 1.0;
end;

procedure TFtCanvas.DrawRect(X, Y, W, H: Integer; R, G, B: Double; A: Double = 1.0);
begin
  if (FHandle <> nil) and Assigned(ft_canvas_draw_rect) then
    ft_canvas_draw_rect(FHandle, X, Y, W, H, R, G, B, A);
end;

procedure TFtCanvas.DrawRect(const ARect: TFtRect; const AColor: TFtColor);
begin
  DrawRect(ARect.Left, ARect.Top, ARect.Width, ARect.Height, AColor.R, AColor.G, AColor.B, AColor.A);
end;

procedure TFtCanvas.DrawRoundedRect(X, Y, W, H, Radius: Double; R, G, B: Double; A: Double = 1.0);
begin
  if (FHandle <> nil) and Assigned(ft_canvas_draw_rounded_rect) then
    ft_canvas_draw_rounded_rect(FHandle, X, Y, W, H, Radius, R, G, B, A);
end;

procedure TFtCanvas.DrawRoundedRect(const ARect: TFtRect; Radius: Double; const AColor: TFtColor);
begin
  DrawRoundedRect(ARect.Left, ARect.Top, ARect.Width, ARect.Height, Radius, AColor.R, AColor.G, AColor.B, AColor.A);
end;

procedure TFtCanvas.DrawRoundedRectOutline(X, Y, W, H, Radius, BorderWidth: Double; R, G, B: Double; A: Double = 1.0);
begin
  if (FHandle <> nil) and Assigned(ft_canvas_draw_rounded_rect_outline) then
    ft_canvas_draw_rounded_rect_outline(FHandle, X, Y, W, H, Radius, BorderWidth, R, G, B, A);
end;

procedure TFtCanvas.DrawLine(X1, Y1, X2, Y2, Width: Double; R, G, B: Double; A: Double = 1.0);
begin
  if (FHandle <> nil) and Assigned(ft_canvas_draw_line) then
    ft_canvas_draw_line(FHandle, X1, Y1, X2, Y2, Width, R, G, B, A);
end;

procedure TFtCanvas.DrawCircle(CX, CY, Radius: Double; R, G, B: Double; A: Double = 1.0);
begin
  if (FHandle <> nil) and Assigned(ft_canvas_draw_circle) then
    ft_canvas_draw_circle(FHandle, CX, CY, Radius, R, G, B, A);
end;

procedure TFtCanvas.DrawText(X, Y: Double; const AText: string; R, G, B: Double; AFont: Pointer = nil);
begin
  if (FHandle <> nil) and Assigned(ft_canvas_draw_text) then
    ft_canvas_draw_text(FHandle, X, Y, PChar(AText), AFont, R, G, B);
end;

procedure TFtCanvas.DrawTextLeft(X, Y, W, H: Double; const AText: string; R, G, B: Double; AFont: Pointer = nil);
begin
  if (FHandle <> nil) and Assigned(ft_canvas_draw_text_left) then
    ft_canvas_draw_text_left(FHandle, X, Y, W, H, PChar(AText), AFont, R, G, B);
end;

procedure TFtCanvas.DrawTextCentered(X, Y, W, H: Integer; const AText: string; R, G, B: Double; AFont: Pointer = nil);
begin
  if (FHandle <> nil) and Assigned(ft_canvas_draw_text_centered) then
    ft_canvas_draw_text_centered(FHandle, X, Y, W, H, PChar(AText), AFont, R, G, B);
end;

procedure TFtCanvas.DrawImage(X, Y: Double; ABitmap: TFtBitmap; Opacity: Double = 1.0);
begin
  if (FHandle <> nil) and (ABitmap <> nil) and (ABitmap.Handle <> nil) and Assigned(ft_canvas_draw_image) then
    ft_canvas_draw_image(FHandle, X, Y, ABitmap.Handle, Opacity);
end;

procedure TFtCanvas.DrawImageScaled(X, Y, W, H: Double; ABitmap: TFtBitmap; Opacity: Double = 1.0);
begin
  if (FHandle <> nil) and (ABitmap <> nil) and (ABitmap.Handle <> nil) and Assigned(ft_canvas_draw_image_scaled) then
    ft_canvas_draw_image_scaled(FHandle, X, Y, W, H, ABitmap.Handle, Opacity);
end;

procedure TFtCanvas.DrawImagePart(X, Y, W, H: Double; ABitmap: TFtBitmap; SrcX, SrcY, SrcW, SrcH: Integer; Opacity: Double = 1.0);
begin
  if (FHandle <> nil) and (ABitmap <> nil) and (ABitmap.Handle <> nil) and Assigned(ft_canvas_draw_image_part) then
    ft_canvas_draw_image_part(FHandle, X, Y, W, H, ABitmap.Handle, SrcX, SrcY, SrcW, SrcH, Opacity);
end;

procedure TFtCanvas.DrawSVG(X, Y, W, H: Double; const ASVGContent: string);
begin
  if (FHandle <> nil) and Assigned(ft_canvas_draw_svg) then
    ft_canvas_draw_svg(FHandle, X, Y, W, H, PChar(ASVGContent));
end;

procedure TFtCanvas.DrawSVGFile(X, Y, W, H: Double; const AFilePath: string);
begin
  if (FHandle <> nil) and Assigned(ft_canvas_draw_svg_file) then
    ft_canvas_draw_svg_file(FHandle, X, Y, W, H, PChar(AFilePath));
end;

procedure TFtCanvas.PushClipRect(X, Y, W, H: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_canvas_push_clip_rect) then
    ft_canvas_push_clip_rect(FHandle, X, Y, W, H);
end;

procedure TFtCanvas.PopClipRect();
begin
  if (FHandle <> nil) and Assigned(ft_canvas_pop_clip_rect) then
    ft_canvas_pop_clip_rect(FHandle);
end;

procedure TFtCanvas.PushClipRoundedRect(X, Y, W, H, Radius: Double);
begin
  if (FHandle <> nil) and Assigned(ft_canvas_push_clip_rounded_rect) then
    ft_canvas_push_clip_rounded_rect(FHandle, X, Y, W, H, Radius);
end;

procedure TFtCanvas.PopClipRoundedRect();
begin
  if (FHandle <> nil) and Assigned(ft_canvas_pop_clip_rounded_rect) then
    ft_canvas_pop_clip_rounded_rect(FHandle);
end;

procedure TFtCanvas.ResetClipping();
begin
  if (FHandle <> nil) and Assigned(ft_canvas_reset_clipping) then
    ft_canvas_reset_clipping(FHandle);
end;

procedure TFtCanvas.PushAlpha(AAlpha: Double);
begin
  if (FHandle <> nil) and Assigned(ft_canvas_push_alpha) then
    ft_canvas_push_alpha(FHandle, AAlpha);
end;

procedure TFtCanvas.PopAlpha();
begin
  if (FHandle <> nil) and Assigned(ft_canvas_pop_alpha) then
    ft_canvas_pop_alpha(FHandle);
end;

procedure TFtCanvas.ResetAlpha();
begin
  if (FHandle <> nil) and Assigned(ft_canvas_reset_alpha) then
    ft_canvas_reset_alpha(FHandle);
end;

end.
