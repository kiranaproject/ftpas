{ ************************************************************************** }
{                                                                          }
{   ftml_embed — compile .ftml documents into .res resources or units      }
{                                                                          }
{   Command-line tool belonging to Floria Toolkit (ftpas) that bundles     }
{   declarative FTML documents into standard Free Pascal binary resource   }
{   files (.res) or standalone Pascal units.                               }
{                                                                          }
{   Usage:                                                                 }
{     ftml_embed --res <file.res> <file.ftml> [...]                        }
{     ftml_embed --out <file.pas> [--unit <UnitName>] <file.ftml> [...]    }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

program ftml_embed;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, ftpas.ftml.embed;

procedure ShowUsage(AExitCode: Integer = 0);
begin
  WriteLn('ftml_embed — Floria Toolkit FTML resource compiler');
  WriteLn('Usage:');
  WriteLn('  ftml_embed --res <output.res> [--form Name=file.ftml] file.ftml [...]');
  WriteLn('  ftml_embed --out <output.pas> [--unit <UnitName>] file.ftml [...]');
  WriteLn;
  WriteLn('Options:');
  WriteLn('  -r, --res <file.res>   Emit Free Pascal binary resource file (.res)');
  WriteLn('  -o, --out <file>       Output file (.res or .pas)');
  WriteLn('  -u, --unit <name>      Pascal unit name (when outputting .pas)');
  WriteLn('  --form Name=path       Explicitly name the form class for the document');
  WriteLn('  -h, --help             Show this help screen');
  Halt(AExitCode);
end;

var
  embedder: TFtFTMLEmbedder;
  i, eqAt: Integer;
  arg, outArg, unitArg, formArg, fileArg: string;
  isRes: Boolean;
begin
  if ParamCount() = 0 then
    ShowUsage();

  embedder := TFtFTMLEmbedder.Create();
  try
    outArg := '';
    unitArg := '';
    isRes := False;

    i := 1;
    while i <= ParamCount() do
    begin
      arg := ParamStr(i);
      if (arg = '--res') or (arg = '-r') then
      begin
        Inc(i);
        if i > ParamCount() then ShowUsage();
        outArg := ParamStr(i);
        isRes := True;
      end
      else if (arg = '--out') or (arg = '-o') then
      begin
        Inc(i);
        if i > ParamCount() then ShowUsage();
        outArg := ParamStr(i);
      end
      else if (arg = '--unit') or (arg = '-u') then
      begin
        Inc(i);
        if i > ParamCount() then ShowUsage();
        unitArg := ParamStr(i);
      end
      else if arg = '--form' then
      begin
        Inc(i);
        if i > ParamCount() then ShowUsage();
        formArg := ParamStr(i);
        eqAt := Pos('=', formArg);
        if eqAt > 0 then
          embedder.AddFile(Copy(formArg, eqAt + 1, MaxInt), Copy(formArg, 1, eqAt - 1))
        else
          embedder.AddFile(formArg, '');
      end
      else if (arg = '--help') or (arg = '-h') then
      begin
        ShowUsage();
      end
      else if (Length(arg) > 0) and (arg[1] = '-') then
      begin
        WriteLn(StdErr, 'ftml_embed: unknown option ', arg);
        Halt(2);
      end
      else
      begin
        fileArg := arg;
        eqAt := Pos('=', fileArg);
        if (eqAt > 0) and (not FileExists(fileArg)) then
          embedder.AddFile(Copy(fileArg, eqAt + 1, MaxInt), Copy(fileArg, 1, eqAt - 1))
        else
          embedder.AddFile(fileArg, '');
      end;
      Inc(i);
    end;

    if embedder.ItemCount = 0 then
    begin
      WriteLn(StdErr, 'ftml_embed: no input FTML documents specified.');
      Halt(2);
    end;

    if (outArg <> '') and (LowerCase(ExtractFileExt(outArg)) = '.res') then
      isRes := True;

    if isRes then
    begin
      if outArg = '' then
        outArg := 'ftml_resources.res';
      embedder.EmitRes(outArg);
      WriteLn('ftml_embed: wrote resource file ', outArg, ' (', embedder.ItemCount, ' document(s))');
    end
    else
    begin
      if outArg = '' then
        outArg := 'ftml_resources.pas';
      if unitArg = '' then
        unitArg := ChangeFileExt(ExtractFileName(outArg), '');
      embedder.EmitUnit(outArg, unitArg);
      WriteLn('ftml_embed: wrote Pascal unit ', outArg, ' (', embedder.ItemCount, ' document(s))');
    end;
  finally
    embedder.Free();
  end;
end.
