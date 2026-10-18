{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal GPU Acceleration & Tessellator     }
{                                                                          }
{   Provides high-level OOP wrappers for GPU 2D render batches, vector     }
{   curve/polygon tessellation meshes, and hardware renderers.             }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.gpu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ctypes,
  ftpas.api, ftpas.types;

type
  { Point constructor helper }
  TFtPoint2D = ftpas.api.TFtPoint2D;
  PFtPoint2D = ftpas.api.PFtPoint2D;
  TFtBatchStats = ftpas.api.TFtBatchStats;
  PFtBatchStats = ftpas.api.PFtBatchStats;

  { TFtTessMesh — Geometry mesh holding tessellated vertices and indices }
  TFtTessMesh = class
  private
    FHandle: Pointer;
    FOwnsHandle: Boolean;

    function  GetVertexCount: Integer;
    function  GetIndexCount: Integer;
  public
    constructor Create();
    constructor Wrap(AHandle: Pointer; AOwnsHandle: Boolean = False);
    destructor Destroy; override;

    procedure Clear();

    property Handle: Pointer read FHandle;
    property VertexCount: Integer read GetVertexCount;
    property IndexCount: Integer read GetIndexCount;
  end;

  { TFtRenderBatch — 2D quad/mesh batch emitter }
  TFtRenderBatch = class
  private
    FHandle: Pointer;
    FOwnsHandle: Boolean;
  public
    constructor Create();
    constructor Wrap(AHandle: Pointer; AOwnsHandle: Boolean = False);
    destructor Destroy; override;

    procedure Clear();
    function  GetStats(): TFtBatchStats;

    procedure EmitRect(AX, AY, AW, AH: Single; AColor: Cardinal; ABlendMode: Integer = 0);
    procedure EmitTexturedRect(AX, AY, AW, AH, AU0, AV0, AU1, AV1: Single;
                               ATexID: Cardinal; AOpacity: Single = 1.0; ABlendMode: Integer = 0);
    procedure EmitRoundedRect(AX, AY, AW, AH, ARadius: Single;
                              AFillColor, ABorderColor: Cardinal;
                              ABorderWidth: Single = 0.0; ABlendMode: Integer = 0);
    procedure EmitBoxShadow(AX, AY, AW, AH, ARadius, AOffsetX, AOffsetY,
                            ABlurRadius, ASpread: Single;
                            AShadowColor: Cardinal; ABlendMode: Integer = 0);
    procedure EmitLinearGradient(AX, AY, AW, AH: Single;
                                 AColorStart, AColorEnd: Cardinal;
                                 AAngleDeg: Single = 0.0; ABlendMode: Integer = 0);
    procedure EmitPathMesh(AMesh: TFtTessMesh; AColor: Cardinal; ABlendMode: Integer = 0);

    property Handle: Pointer read FHandle;
  end;

  { TFtGPUTessellator — GPU path/curve tessellator }
  TFtGPUTessellator = class
  private
    FHandle: Pointer;
    FOwnsHandle: Boolean;
  public
    constructor Create();
    constructor Wrap(AHandle: Pointer; AOwnsHandle: Boolean = False);
    destructor Destroy; override;

    procedure StrokePolyline(AMesh: TFtTessMesh; const APoints: array of TFtPoint2D;
                             AClosed: Boolean = False; AStrokeWidth: Single = 1.0;
                             AJoinStyle: Integer = 0; ACapStyle: Integer = 0;
                             AMiterLimit: Single = 4.0; AAntiAliasFringe: Boolean = True);
    procedure StrokeBezier(AMesh: TFtTessMesh;
                           AP0, AP1, AP2, AP3: TFtPoint2D;
                           AStrokeWidth: Single = 1.0;
                           AJoinStyle: Integer = 0; ACapStyle: Integer = 0;
                           AMiterLimit: Single = 4.0; AAntiAliasFringe: Boolean = True);
    procedure FillPolygon(AMesh: TFtTessMesh; const APoints: array of TFtPoint2D;
                          AAntiAliasFringe: Boolean = True);

    property Handle: Pointer read FHandle;
  end;

  { TFtGPURenderer — Hardware accelerated GPU renderer }
  TFtGPURenderer = class
  private
    FHandle: Pointer;
    FBatch: TFtRenderBatch;
    FTessellator: TFtGPUTessellator;

    function  GetBatch: TFtRenderBatch;
    function  GetTessellator: TFtGPUTessellator;
  public
    constructor Create();
    destructor Destroy; override;

    procedure BeginFrame(AViewportW, AViewportH: Integer);
    procedure EndFrame();

    property Batch: TFtRenderBatch read GetBatch;
    property Tessellator: TFtGPUTessellator read GetTessellator;
    property Handle: Pointer read FHandle;
  end;

function FtPoint2D(AX, AY: Single): TFtPoint2D; inline;

implementation

function FtPoint2D(AX, AY: Single): TFtPoint2D;
begin
  Result.x := AX;
  Result.y := AY;
end;

{ TFtTessMesh }

constructor TFtTessMesh.Create();
begin
  inherited Create();
  if Assigned(ft_tessmesh_create) then
    FHandle := ft_tessmesh_create();
  FOwnsHandle := True;
end;

constructor TFtTessMesh.Wrap(AHandle: Pointer; AOwnsHandle: Boolean);
begin
  inherited Create();
  FHandle := AHandle;
  FOwnsHandle := AOwnsHandle;
end;

destructor TFtTessMesh.Destroy();
begin
  if FOwnsHandle and (FHandle <> nil) and Assigned(ft_tessmesh_destroy) then
    ft_tessmesh_destroy(FHandle);
  inherited Destroy();
end;

procedure TFtTessMesh.Clear();
begin
  if (FHandle <> nil) and Assigned(ft_tessmesh_clear) then
    ft_tessmesh_clear(FHandle);
end;

function TFtTessMesh.GetVertexCount: Integer;
var
  vCount, iCount: cint32;
begin
  vCount := 0;
  iCount := 0;
  if (FHandle <> nil) and Assigned(ft_tessmesh_get_counts) then
    ft_tessmesh_get_counts(FHandle, vCount, iCount);
  Result := vCount;
end;

function TFtTessMesh.GetIndexCount: Integer;
var
  vCount, iCount: cint32;
begin
  vCount := 0;
  iCount := 0;
  if (FHandle <> nil) and Assigned(ft_tessmesh_get_counts) then
    ft_tessmesh_get_counts(FHandle, vCount, iCount);
  Result := iCount;
end;

{ TFtRenderBatch }

constructor TFtRenderBatch.Create();
begin
  inherited Create();
  if Assigned(ft_batch_create) then
    FHandle := ft_batch_create();
  FOwnsHandle := True;
end;

constructor TFtRenderBatch.Wrap(AHandle: Pointer; AOwnsHandle: Boolean);
begin
  inherited Create();
  FHandle := AHandle;
  FOwnsHandle := AOwnsHandle;
end;

destructor TFtRenderBatch.Destroy();
begin
  if FOwnsHandle and (FHandle <> nil) and Assigned(ft_batch_destroy) then
    ft_batch_destroy(FHandle);
  inherited Destroy();
end;

procedure TFtRenderBatch.Clear();
begin
  if (FHandle <> nil) and Assigned(ft_batch_clear) then
    ft_batch_clear(FHandle);
end;

function TFtRenderBatch.GetStats(): TFtBatchStats;
begin
  FillChar(Result, SizeOf(Result), 0);
  if (FHandle <> nil) and Assigned(ft_batch_get_stats) then
    ft_batch_get_stats(FHandle, @Result);
end;

procedure TFtRenderBatch.EmitRect(AX, AY, AW, AH: Single; AColor: Cardinal; ABlendMode: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_batch_emit_rect) then
    ft_batch_emit_rect(FHandle, AX, AY, AW, AH, AColor, ABlendMode);
end;

procedure TFtRenderBatch.EmitTexturedRect(AX, AY, AW, AH, AU0, AV0, AU1, AV1: Single;
  ATexID: Cardinal; AOpacity: Single; ABlendMode: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_batch_emit_textured_rect) then
    ft_batch_emit_textured_rect(FHandle, AX, AY, AW, AH, AU0, AV0, AU1, AV1, ATexID, AOpacity, ABlendMode);
end;

procedure TFtRenderBatch.EmitRoundedRect(AX, AY, AW, AH, ARadius: Single;
  AFillColor, ABorderColor: Cardinal; ABorderWidth: Single; ABlendMode: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_batch_emit_rounded_rect) then
    ft_batch_emit_rounded_rect(FHandle, AX, AY, AW, AH, ARadius, AFillColor, ABorderColor, ABorderWidth, ABlendMode);
end;

procedure TFtRenderBatch.EmitBoxShadow(AX, AY, AW, AH, ARadius, AOffsetX, AOffsetY,
  ABlurRadius, ASpread: Single; AShadowColor: Cardinal; ABlendMode: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_batch_emit_box_shadow) then
    ft_batch_emit_box_shadow(FHandle, AX, AY, AW, AH, ARadius, AOffsetX, AOffsetY, ABlurRadius, ASpread, AShadowColor, ABlendMode);
end;

procedure TFtRenderBatch.EmitLinearGradient(AX, AY, AW, AH: Single;
  AColorStart, AColorEnd: Cardinal; AAngleDeg: Single; ABlendMode: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_batch_emit_linear_gradient) then
    ft_batch_emit_linear_gradient(FHandle, AX, AY, AW, AH, AColorStart, AColorEnd, AAngleDeg, ABlendMode);
end;

procedure TFtRenderBatch.EmitPathMesh(AMesh: TFtTessMesh; AColor: Cardinal; ABlendMode: Integer);
begin
  if (FHandle <> nil) and (AMesh <> nil) and (AMesh.Handle <> nil) and Assigned(ft_batch_emit_path_mesh) then
    ft_batch_emit_path_mesh(FHandle, AMesh.Handle, AColor, ABlendMode);
end;

{ TFtGPUTessellator }

constructor TFtGPUTessellator.Create();
begin
  inherited Create();
  if Assigned(ft_tessellator_create) then
    FHandle := ft_tessellator_create();
  FOwnsHandle := True;
end;

constructor TFtGPUTessellator.Wrap(AHandle: Pointer; AOwnsHandle: Boolean);
begin
  inherited Create();
  FHandle := AHandle;
  FOwnsHandle := AOwnsHandle;
end;

destructor TFtGPUTessellator.Destroy();
begin
  if FOwnsHandle and (FHandle <> nil) and Assigned(ft_tessellator_destroy) then
    ft_tessellator_destroy(FHandle);
  inherited Destroy();
end;

procedure TFtGPUTessellator.StrokePolyline(AMesh: TFtTessMesh; const APoints: array of TFtPoint2D;
  AClosed: Boolean; AStrokeWidth: Single; AJoinStyle: Integer; ACapStyle: Integer;
  AMiterLimit: Single; AAntiAliasFringe: Boolean);
var
  cClosed, cFringe: cint32;
  pPtr: PFtPoint2D;
  cnt: Integer;
begin
  cnt := Length(APoints);
  if (cnt <= 0) or (FHandle = nil) or (AMesh = nil) or (AMesh.Handle = nil) or
     not Assigned(ft_tessellator_stroke_polyline) then
    Exit;

  if AClosed then cClosed := 1 else cClosed := 0;
  if AAntiAliasFringe then cFringe := 1 else cFringe := 0;
  pPtr := @APoints[0];
  ft_tessellator_stroke_polyline(FHandle, AMesh.Handle, pPtr, cnt, cClosed,
                                 AStrokeWidth, AJoinStyle, ACapStyle, AMiterLimit, cFringe);
end;

procedure TFtGPUTessellator.StrokeBezier(AMesh: TFtTessMesh;
  AP0, AP1, AP2, AP3: TFtPoint2D; AStrokeWidth: Single;
  AJoinStyle: Integer; ACapStyle: Integer; AMiterLimit: Single; AAntiAliasFringe: Boolean);
var
  cFringe: cint32;
begin
  if (FHandle = nil) or (AMesh = nil) or (AMesh.Handle = nil) or
     not Assigned(ft_tessellator_stroke_bezier) then
    Exit;

  if AAntiAliasFringe then cFringe := 1 else cFringe := 0;
  ft_tessellator_stroke_bezier(FHandle, AMesh.Handle,
                               AP0.x, AP0.y, AP1.x, AP1.y, AP2.x, AP2.y, AP3.x, AP3.y,
                               AStrokeWidth, AJoinStyle, ACapStyle, AMiterLimit, cFringe);
end;

procedure TFtGPUTessellator.FillPolygon(AMesh: TFtTessMesh; const APoints: array of TFtPoint2D;
  AAntiAliasFringe: Boolean);
var
  cFringe: cint32;
  pPtr: PFtPoint2D;
  cnt: Integer;
begin
  cnt := Length(APoints);
  if (cnt <= 0) or (FHandle = nil) or (AMesh = nil) or (AMesh.Handle = nil) or
     not Assigned(ft_tessellator_fill_polygon) then
    Exit;

  if AAntiAliasFringe then cFringe := 1 else cFringe := 0;
  pPtr := @APoints[0];
  ft_tessellator_fill_polygon(FHandle, AMesh.Handle, pPtr, cnt, cFringe);
end;

{ TFtGPURenderer }

constructor TFtGPURenderer.Create();
begin
  inherited Create();
  if Assigned(ft_renderer_create) then
    FHandle := ft_renderer_create();
  FBatch := nil;
  FTessellator := nil;
end;

destructor TFtGPURenderer.Destroy();
begin
  if FBatch <> nil then
  begin
    FBatch.Free();
    FBatch := nil;
  end;
  if FTessellator <> nil then
  begin
    FTessellator.Free();
    FTessellator := nil;
  end;
  if (FHandle <> nil) and Assigned(ft_renderer_destroy) then
    ft_renderer_destroy(FHandle);
  inherited Destroy();
end;

procedure TFtGPURenderer.BeginFrame(AViewportW, AViewportH: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_renderer_begin) then
    ft_renderer_begin(FHandle, AViewportW, AViewportH);
end;

procedure TFtGPURenderer.EndFrame();
begin
  if (FHandle <> nil) and Assigned(ft_renderer_end) then
    ft_renderer_end(FHandle);
end;

function TFtGPURenderer.GetBatch: TFtRenderBatch;
var
  bHandle: Pointer;
begin
  if (FBatch = nil) and (FHandle <> nil) and Assigned(ft_renderer_get_batch) then
  begin
    bHandle := ft_renderer_get_batch(FHandle);
    if bHandle <> nil then
      FBatch := TFtRenderBatch.Wrap(bHandle, False);
  end;
  Result := FBatch;
end;

function TFtGPURenderer.GetTessellator: TFtGPUTessellator;
var
  tHandle: Pointer;
begin
  if (FTessellator = nil) and (FHandle <> nil) and Assigned(ft_renderer_get_tessellator) then
  begin
    tHandle := ft_renderer_get_tessellator(FHandle);
    if tHandle <> nil then
      FTessellator := TFtGPUTessellator.Wrap(tHandle, False);
  end;
  Result := FTessellator;
end;

end.
