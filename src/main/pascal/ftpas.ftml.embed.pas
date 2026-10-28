{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (ftpas) — FTML Resource Embedder Module                 }
{                                                                          }
{   Provides programmatic and CLI facilities to bundle declarative FTML    }
{   documents into standard Free Pascal binary resource (.res) files       }
{   or standalone Pascal resource units.                                   }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.ftml.embed;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, resource, reswriter;

type
  { A single document to be embedded }
  TFtFTMLEmbedItem = record
    FormName: string;
    FileName: string;
    Source: RawByteString;
  end;
  PFtFTMLEmbedItem = ^TFtFTMLEmbedItem;

  { Tool/compiler engine that bundles .ftml files into .res resources or .pas units }
  TFtFTMLEmbedder = class
  private
    FItems: array of TFtFTMLEmbedItem;
    FItemCount: Integer;

    function ExtractFormDirective(const ASource: RawByteString): string;
    function MakeArrayName(const AFormName: string): string;
    function SanitizeIdent(const S: string): string;
    function StripExt(const S: string): string;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure AddFile(const AFileName: string; const AFormName: string = '');
    procedure AddSource(const AName, AFileName: string; const ASource: RawByteString);
    procedure Clear();

    procedure EmitRes(const AOutResFile: string);
    procedure EmitUnit(const AOutPasFile, AUnitName: string);

    function  GetItem(AIndex: Integer): TFtFTMLEmbedItem;
    property  ItemCount: Integer read FItemCount;
  end;

{ Convenience functions }
function CompileFTMLToRes(const AInputFiles: array of string; const AOutResFile: string): Boolean;
function CompileFTMLToUnit(const AInputFiles: array of string; const AOutPasFile, AUnitName: string): Boolean;

implementation

{ TFtFTMLEmbedder }

constructor TFtFTMLEmbedder.Create();
begin
  inherited Create();
  FItemCount := 0;
  SetLength(FItems, 0);
end;

destructor TFtFTMLEmbedder.Destroy();
begin
  Clear();
  inherited Destroy();
end;

procedure TFtFTMLEmbedder.Clear();
begin
  SetLength(FItems, 0);
  FItemCount := 0;
end;

function TFtFTMLEmbedder.SanitizeIdent(const S: string): string;
var
  i: Integer;
  c: Char;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    c := S[i];
    if (c in ['a'..'z', 'A'..'Z', '0'..'9']) then
      Result := Result + c
    else
      Result := Result + '_';
  end;
  if (Result = '') or (Result[1] in ['0'..'9']) then
    Result := '_' + Result;
end;

function TFtFTMLEmbedder.StripExt(const S: string): string;
begin
  Result := ChangeFileExt(ExtractFileName(S), '');
end;

function TFtFTMLEmbedder.ExtractFormDirective(const ASource: RawByteString): string;
var
  p, e: Integer;
  line, rest, name: string;
begin
  Result := '';
  p := 1;
  while p <= Length(ASource) do
  begin
    e := p;
    while (e <= Length(ASource)) and (ASource[e] <> #10) do
      Inc(e);
    line := Trim(Copy(string(ASource), p, e - p));
    if Copy(line, 1, 2) = '//' then
    begin
      rest := Trim(Copy(line, 3, MaxInt));
      if (Pos('@form', LowerCase(rest)) = 1) then
      begin
        name := Trim(Copy(rest, 6, MaxInt));
        if name <> '' then
        begin
          Result := name;
          Exit;
        end;
      end;
    end
    else if line <> '' then
      Break;
    p := e + 1;
  end;
end;

function TFtFTMLEmbedder.MakeArrayName(const AFormName: string): string;
begin
  Result := 'FTML_DATA_' + SanitizeIdent(AFormName);
end;

procedure TFtFTMLEmbedder.AddSource(const AName, AFileName: string; const ASource: RawByteString);
var
  item: TFtFTMLEmbedItem;
  directive: string;
begin
  directive := ExtractFormDirective(ASource);
  item.FormName := AName;
  if item.FormName = '' then
    item.FormName := directive;
  if item.FormName = '' then
    item.FormName := StripExt(AFileName);
  item.FileName := ExtractFileName(AFileName);
  item.Source := ASource;

  Inc(FItemCount);
  SetLength(FItems, FItemCount);
  FItems[FItemCount - 1] := item;
end;

procedure TFtFTMLEmbedder.AddFile(const AFileName: string; const AFormName: string);
var
  fs: TFileStream;
  src: RawByteString;
begin
  if not FileExists(AFileName) then
    raise EFOpenError.CreateFmt('FTML file not found: %s', [AFileName]);

  fs := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(src, fs.Size);
    if fs.Size > 0 then
      fs.ReadBuffer(src[1], fs.Size);
  finally
    fs.Free();
  end;

  AddSource(AFormName, AFileName, src);
end;

function TFtFTMLEmbedder.GetItem(AIndex: Integer): TFtFTMLEmbedItem;
begin
  if (AIndex < 0) or (AIndex >= FItemCount) then
    raise ERangeError.CreateFmt('Item index out of bounds: %d', [AIndex]);
  Result := FItems[AIndex];
end;

procedure TFtFTMLEmbedder.EmitRes(const AOutResFile: string);
var
  res: TResources;
  raw: TGenericResource;
  descType, descName: TResourceDesc;
  i: Integer;
  item: TFtFTMLEmbedItem;
  formNameUpper: string;
begin
  if FItemCount = 0 then
    raise Exception.Create('No FTML documents to embed into resource.');

  res := TResources.Create();
  try
    for i := 0 to FItemCount - 1 do
    begin
      item := FItems[i];
      formNameUpper := UpperCase(item.FormName);
      descType := TResourceDesc.Create(10); // RT_RCDATA = 10
      descName := TResourceDesc.Create(formNameUpper);
      raw := TGenericResource.Create(descType, descName);
      descType.Free();
      descName.Free();
      if Length(item.Source) > 0 then
        raw.RawData.WriteBuffer(item.Source[1], Length(item.Source));
      res.Add(raw);
    end;
    ForceDirectories(ExtractFileDir(ExpandFileName(AOutResFile)));
    res.WriteToFile(AOutResFile);
  finally
    res.Free();
  end;
end;

procedure TFtFTMLEmbedder.EmitUnit(const AOutPasFile, AUnitName: string);
var
  sl: TStringList;
  i, j, col: Integer;
  item: TFtFTMLEmbedItem;
  arrName: string;
  b: Byte;
  lineBuf: string;
begin
  if FItemCount = 0 then
    raise Exception.Create('No FTML documents to emit into Pascal unit.');

  sl := TStringList.Create();
  try
    sl.Add('// Generated by ftml_embed. Do not edit by hand.');
    sl.Add('unit ' + AUnitName + ';');
    sl.Add('');
    sl.Add('{$mode objfpc}{$H+}');
    sl.Add('');
    sl.Add('interface');
    sl.Add('');
    sl.Add('procedure RegisterEmbeddedFTMLResources();');
    sl.Add('');
    sl.Add('implementation');
    sl.Add('');
    sl.Add('uses');
    sl.Add('  ftpas.ftml.res;');
    sl.Add('');

    for i := 0 to FItemCount - 1 do
    begin
      item := FItems[i];
      arrName := MakeArrayName(item.FormName);
      sl.Add('const');
      sl.Add('  ' + arrName + ': array[0..' + IntToStr(Length(item.Source) - 1) + '] of Byte = (');

      lineBuf := '    ';
      col := 0;
      for j := 1 to Length(item.Source) do
      begin
        b := Byte(item.Source[j]);
        lineBuf := lineBuf + IntToStr(b);
        Inc(col);
        if j < Length(item.Source) then
          lineBuf := lineBuf + ',';
        if col >= 16 then
        begin
          sl.Add(lineBuf);
          lineBuf := '    ';
          col := 0;
        end
        else if j < Length(item.Source) then
          lineBuf := lineBuf + ' ';
      end;
      if col > 0 then
        sl.Add(lineBuf);
      sl.Add('  );');
      sl.Add('');
    end;

    sl.Add('procedure RegisterEmbeddedFTMLResources();');
    sl.Add('begin');
    for i := 0 to FItemCount - 1 do
    begin
      item := FItems[i];
      arrName := MakeArrayName(item.FormName);
      sl.Add('  RegisterFTMLResource(''' + StringReplace(item.FormName, '''', '''''', [rfReplaceAll]) +
        ''', ''' + StringReplace(item.FileName, '''', '''''', [rfReplaceAll]) +
        ''', PChar(@' + arrName + '[0]), ' + IntToStr(Length(item.Source)) + ');');
    end;
    sl.Add('end;');
    sl.Add('');
    sl.Add('initialization');
    sl.Add('  RegisterEmbeddedFTMLResources();');
    sl.Add('');
    sl.Add('end.');

    ForceDirectories(ExtractFileDir(ExpandFileName(AOutPasFile)));
    sl.SaveToFile(AOutPasFile);
  finally
    sl.Free();
  end;
end;

function CompileFTMLToRes(const AInputFiles: array of string; const AOutResFile: string): Boolean;
var
  embedder: TFtFTMLEmbedder;
  i: Integer;
begin
  Result := False;
  if (Length(AInputFiles) = 0) or (AOutResFile = '') then Exit;

  embedder := TFtFTMLEmbedder.Create();
  try
    for i := Low(AInputFiles) to High(AInputFiles) do
      embedder.AddFile(AInputFiles[i]);
    embedder.EmitRes(AOutResFile);
    Result := True;
  finally
    embedder.Free();
  end;
end;

function CompileFTMLToUnit(const AInputFiles: array of string; const AOutPasFile, AUnitName: string): Boolean;
var
  embedder: TFtFTMLEmbedder;
  i: Integer;
begin
  Result := False;
  if (Length(AInputFiles) = 0) or (AOutPasFile = '') then Exit;

  embedder := TFtFTMLEmbedder.Create();
  try
    for i := Low(AInputFiles) to High(AInputFiles) do
      embedder.AddFile(AInputFiles[i]);
    embedder.EmitUnit(AOutPasFile, AUnitName);
    Result := True;
  finally
    embedder.Free();
  end;
end;

end.
