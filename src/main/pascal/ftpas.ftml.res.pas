{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (ftpas) — FTML Resource Registry                        }
{                                                                          }
{   Stores FTML documents embedded into the executable as raw bytes,       }
{   mirroring the Lazarus .lfm embedding model. Generated resource units   }
{   (produced by tools/ftml_embed.pas) call RegisterFTMLResource() during  }
{   their initialization; TFtFTMLForm then loads the document by class.    }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.ftml.res;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  { A single embedded FTML document. Data points at the static byte array
    emitted by the resource unit; it is never owned by the registry. }
  TFtFTMLResource = record
    Name: string;      // logical form name, e.g. 'TConsoleWindow'
    FileName: string;  // original file name, e.g. 'consolesama.ftml'
    Data: PChar;       // UTF-8 bytes (not NUL-terminated by contract)
    Size: Integer;
  end;
  PFtFTMLResource = ^TFtFTMLResource;

  { Register an embedded document. AName is matched case-insensitively. }
procedure RegisterFTMLResource(const AName, AFileName: string;
  AData: PChar; ASize: Integer);

{ Look up an embedded document by form name. Returns False when missing. }
function FindFTMLResource(const AName: string; out AResource: TFtFTMLResource): Boolean;

{ Copy the source of an embedded document into ASource. Returns False when
  the name is unknown. }
function EmbeddedFTMLSource(const AName: string; out ASource, AFileName: string): Boolean;

{ List every registered form name (sorted, one per line). }
function EmbeddedFTMLNames: string;

{ Remove all registrations (used by tests). }
procedure ClearFTMLResources();

implementation

var
  GResources: TStringList = nil;

procedure EnsureRegistry();
begin
  if GResources = nil then
  begin
    GResources := TStringList.Create();
    GResources.Sorted := True;
    GResources.CaseSensitive := False;
    GResources.Duplicates := dupIgnore;
  end;
end;

procedure RegisterFTMLResource(const AName, AFileName: string;
  AData: PChar; ASize: Integer);
var
  res: PFtFTMLResource;
  idx: Integer;
begin
  if (AName = '') or (AData = nil) or (ASize <= 0) then Exit;
  EnsureRegistry();

  if GResources.Find(AName, idx) then
  begin
    { Re-registration replaces the previous entry (useful for hot reload). }
    res := PFtFTMLResource(GResources.Objects[idx]);
    res^.FileName := AFileName;
    res^.Data := AData;
    res^.Size := ASize;
    Exit;
  end;

  New(res);
  res^.Name := AName;
  res^.FileName := AFileName;
  res^.Data := AData;
  res^.Size := ASize;
  GResources.AddObject(AName, TObject(res));
end;

function FindFTMLResource(const AName: string; out AResource: TFtFTMLResource): Boolean;
var
  idx: Integer;
begin
  FillChar(AResource, SizeOf(AResource), 0);
  Result := False;
  if (GResources = nil) or (AName = '') then Exit;
  if not GResources.Find(AName, idx) then Exit;
  AResource := PFtFTMLResource(GResources.Objects[idx])^;
  Result := True;
end;

function EmbeddedFTMLSource(const AName: string; out ASource, AFileName: string): Boolean;
var
  res: TFtFTMLResource;
begin
  ASource := '';
  AFileName := '';
  Result := FindFTMLResource(AName, res);
  if not Result then Exit;
  SetLength(ASource, res.Size);
  if res.Size > 0 then
    Move(res.Data^, ASource[1], res.Size);
  AFileName := res.FileName;
end;

function EmbeddedFTMLNames: string;
var
  i: Integer;
begin
  Result := '';
  if GResources = nil then Exit;
  for i := 0 to GResources.Count - 1 do
  begin
    if i > 0 then Result := Result + LineEnding;
    Result := Result + GResources[i];
  end;
end;

procedure ClearFTMLResources();
var
  i: Integer;
begin
  if GResources = nil then Exit;
  for i := 0 to GResources.Count - 1 do
    Dispose(PFtFTMLResource(GResources.Objects[i]));
  GResources.Clear();
end;

finalization
  if GResources <> nil then
  begin
    ClearFTMLResources();
    FreeAndNil(GResources);
  end;

end.
