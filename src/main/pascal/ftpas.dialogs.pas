{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal Dialogs (TFtFileDialog, MsgBox)    }
{                                                                          }
{   Provides OOP wrappers and convenient static methods for File Dialogs   }
{   and Message / Alert / Confirmation Dialogs.                            }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.dialogs;

{$mode objfpc}{$H+}

interface

uses
  ctypes, Classes, SysUtils, ftpas.api, ftpas.types;

type
  { Forward Declarations }
  TFtFileDialog = class;
  TFtMessageDialog = class;

  { TFtFileDialog — Open, save, and select folder dialog }
  TFtFileDialog = class
  private
    FHandle: Pointer;
    FDirectory: string;
    FDefaultName: string;
    FFilter: string;
    FShowHidden: Boolean;

    function  GetDirectory: string;
    procedure SetDirectory(const AValue: string);
    procedure SetDefaultName(const AValue: string);
    procedure SetFilter(const AValue: string);
    procedure SetShowHidden(AValue: Boolean);
    function  GetSelectedPath: string;
  public
    constructor Create(ADialogType: TFtFileDialogType = ftfdtOpen);
    destructor Destroy; override;

    function  ShowModal(): Integer;

    { One-shot static convenience methods }
    class function OpenFile(const ATitle: string = ''; const ADefaultDir: string = ''; const AFilter: string = ''): string;
    class function SaveFile(const ATitle: string = ''; const ADefaultDir: string = ''; const ADefaultName: string = ''; const AFilter: string = ''): string;
    class function SelectFolder(const ATitle: string = ''; const ADefaultDir: string = ''): string;

    property Handle: Pointer read FHandle;
    property Directory: string read GetDirectory write SetDirectory;
    property DefaultName: string read FDefaultName write SetDefaultName;
    property Filter: string read FFilter write SetFilter;
    property ShowHidden: Boolean read FShowHidden write SetShowHidden;
    property SelectedPath: string read GetSelectedPath;
  end;

  { TFtMessageDialog — Standard alert, info, warning, question dialogs }
  TFtMessageDialog = class
  private
    FHandle: Pointer;
    function  GetVerificationChecked: Boolean;
    procedure SetVerificationChecked(AValue: Boolean);
    procedure SetDetails(const AValue: string);
    procedure SetVerificationText(const AValue: string);
  public
    constructor Create(const ATitle, AInstruction, AMessage: string;
                       ADialogType: TFtMsgDialogSeverity = ftmdInfo;
                       AButtonsType: TFtMsgDialogButtons = ftmbOk);
    destructor Destroy; override;

    procedure SetCustomIconSVG(const ASVG: string);
    procedure AddButton(const ACaption: string; AModalResult: TFtModalResult;
                        AIsDefault: Boolean = False; AIsDestructive: Boolean = False);
    procedure ClearButtons();
    function  ShowModal(): TFtModalResult;

    { One-shot static convenience methods }
    class function ShowMessage(const AMessage: string; const ATitle: string = 'Message'): Integer;
    class function ShowInfo(const ATitle, AInstruction, AMessage: string): Integer;
    class function ShowWarning(const ATitle, AInstruction, AMessage: string): Integer;
    class function ShowError(const ATitle, AInstruction, AMessage: string; const ADetails: string = ''): Integer;
    class function Confirm(const ATitle, AInstruction, AMessage: string): Boolean;
    class function ConfirmWithVerification(const ATitle, AInstruction, AMessage, AVerificationText: string;
                                           out AVerified: Boolean): Boolean;

    property Handle: Pointer read FHandle;
    property Details: string write SetDetails;
    property VerificationText: string write SetVerificationText;
    property VerificationChecked: Boolean read GetVerificationChecked write SetVerificationChecked;
  end;

implementation

{ TFtFileDialog }

constructor TFtFileDialog.Create(ADialogType: TFtFileDialogType = ftfdtOpen);
begin
  inherited Create;
  if Assigned(ft_file_dialog_create) then
    FHandle := ft_file_dialog_create(Ord(ADialogType))
  else
    FHandle := nil;
end;

destructor TFtFileDialog.Destroy;
begin
  if (FHandle <> nil) and Assigned(ft_file_dialog_destroy) then
  begin
    ft_file_dialog_destroy(FHandle);
    FHandle := nil;
  end;
  inherited Destroy;
end;

function TFtFileDialog.ShowModal(): Integer;
begin
  if (FHandle <> nil) and Assigned(ft_file_dialog_show_modal) then
    Result := ft_file_dialog_show_modal(FHandle)
  else
    Result := 0;
end;

function TFtFileDialog.GetDirectory: string;
begin
  if (FHandle <> nil) and Assigned(ft_file_dialog_get_directory) then
    Result := StrPas(ft_file_dialog_get_directory(FHandle))
  else
    Result := FDirectory;
end;

procedure TFtFileDialog.SetDirectory(const AValue: string);
begin
  FDirectory := AValue;
  if (FHandle <> nil) and Assigned(ft_file_dialog_set_directory) then
    ft_file_dialog_set_directory(FHandle, PChar(AValue));
end;

procedure TFtFileDialog.SetDefaultName(const AValue: string);
begin
  FDefaultName := AValue;
  if (FHandle <> nil) and Assigned(ft_file_dialog_set_default_name) then
    ft_file_dialog_set_default_name(FHandle, PChar(AValue));
end;

procedure TFtFileDialog.SetFilter(const AValue: string);
begin
  FFilter := AValue;
  if (FHandle <> nil) and Assigned(ft_file_dialog_set_filter) then
    ft_file_dialog_set_filter(FHandle, PChar(AValue));
end;

procedure TFtFileDialog.SetShowHidden(AValue: Boolean);
begin
  FShowHidden := AValue;
  if (FHandle <> nil) and Assigned(ft_file_dialog_set_show_hidden) then
    ft_file_dialog_set_show_hidden(FHandle, Ord(AValue));
end;

function TFtFileDialog.GetSelectedPath: string;
begin
  if (FHandle <> nil) and Assigned(ft_file_dialog_get_selected_path) then
    Result := StrPas(ft_file_dialog_get_selected_path(FHandle))
  else
    Result := '';
end;

class function TFtFileDialog.OpenFile(const ATitle: string = ''; const ADefaultDir: string = ''; const AFilter: string = ''): string;
var
  pRes: PChar;
begin
  if Assigned(ft_dialog_open_file) then
  begin
    pRes := ft_dialog_open_file(PChar(ATitle), PChar(ADefaultDir), PChar(AFilter));
    if pRes <> nil then
      Result := StrPas(pRes)
    else
      Result := '';
  end
  else
    Result := '';
end;

class function TFtFileDialog.SaveFile(const ATitle: string = ''; const ADefaultDir: string = ''; const ADefaultName: string = ''; const AFilter: string = ''): string;
var
  pRes: PChar;
begin
  if Assigned(ft_dialog_save_file) then
  begin
    pRes := ft_dialog_save_file(PChar(ATitle), PChar(ADefaultDir), PChar(ADefaultName), PChar(AFilter));
    if pRes <> nil then
      Result := StrPas(pRes)
    else
      Result := '';
  end
  else
    Result := '';
end;

class function TFtFileDialog.SelectFolder(const ATitle: string = ''; const ADefaultDir: string = ''): string;
var
  pRes: PChar;
begin
  if Assigned(ft_dialog_select_folder) then
  begin
    pRes := ft_dialog_select_folder(PChar(ATitle), PChar(ADefaultDir));
    if pRes <> nil then
      Result := StrPas(pRes)
    else
      Result := '';
  end
  else
    Result := '';
end;

{ TFtMessageDialog }

constructor TFtMessageDialog.Create(const ATitle, AInstruction, AMessage: string;
                                    ADialogType: TFtMsgDialogSeverity = ftmdInfo;
                                    AButtonsType: TFtMsgDialogButtons = ftmbOk);
begin
  inherited Create;
  if Assigned(ft_message_dialog_create) then
    FHandle := ft_message_dialog_create(PChar(ATitle), PChar(AInstruction), PChar(AMessage),
                                        Ord(ADialogType), Ord(AButtonsType))
  else
    FHandle := nil;
end;

destructor TFtMessageDialog.Destroy;
begin
  if (FHandle <> nil) and Assigned(ft_message_dialog_destroy) then
  begin
    ft_message_dialog_destroy(FHandle);
    FHandle := nil;
  end;
  inherited Destroy;
end;

procedure TFtMessageDialog.SetDetails(const AValue: string);
begin
  if (FHandle <> nil) and Assigned(ft_message_dialog_set_details) then
    ft_message_dialog_set_details(FHandle, PChar(AValue));
end;

procedure TFtMessageDialog.SetVerificationText(const AValue: string);
begin
  if (FHandle <> nil) and Assigned(ft_message_dialog_set_verification_text) then
    ft_message_dialog_set_verification_text(FHandle, PChar(AValue));
end;

function TFtMessageDialog.GetVerificationChecked: Boolean;
begin
  if (FHandle <> nil) and Assigned(ft_message_dialog_get_verification_checked) then
    Result := (ft_message_dialog_get_verification_checked(FHandle) <> 0)
  else
    Result := False;
end;

procedure TFtMessageDialog.SetVerificationChecked(AValue: Boolean);
begin
  if (FHandle <> nil) and Assigned(ft_message_dialog_set_verification_checked) then
    ft_message_dialog_set_verification_checked(FHandle, Ord(AValue));
end;

procedure TFtMessageDialog.SetCustomIconSVG(const ASVG: string);
begin
  if (FHandle <> nil) and Assigned(ft_message_dialog_set_custom_icon_svg) then
    ft_message_dialog_set_custom_icon_svg(FHandle, PChar(ASVG));
end;

procedure TFtMessageDialog.AddButton(const ACaption: string; AModalResult: TFtModalResult;
                                     AIsDefault: Boolean = False; AIsDestructive: Boolean = False);
begin
  if (FHandle <> nil) and Assigned(ft_message_dialog_add_button) then
    ft_message_dialog_add_button(FHandle, PChar(ACaption), Ord(AModalResult),
                                 Ord(AIsDefault), Ord(AIsDestructive));
end;

procedure TFtMessageDialog.ClearButtons();
begin
  if (FHandle <> nil) and Assigned(ft_message_dialog_clear_buttons) then
    ft_message_dialog_clear_buttons(FHandle);
end;

function TFtMessageDialog.ShowModal(): TFtModalResult;
begin
  if (FHandle <> nil) and Assigned(ft_message_dialog_show_modal) then
    Result := TFtModalResult(ft_message_dialog_show_modal(FHandle))
  else
    Result := ftmrNone;
end;

class function TFtMessageDialog.ShowMessage(const AMessage: string; const ATitle: string = 'Message'): Integer;
begin
  if Assigned(ft_show_message) then
    Result := ft_show_message(PChar(AMessage), PChar(ATitle))
  else
    Result := 0;
end;

class function TFtMessageDialog.ShowInfo(const ATitle, AInstruction, AMessage: string): Integer;
begin
  if Assigned(ft_show_info) then
    Result := ft_show_info(PChar(ATitle), PChar(AInstruction), PChar(AMessage))
  else
    Result := 0;
end;

class function TFtMessageDialog.ShowWarning(const ATitle, AInstruction, AMessage: string): Integer;
begin
  if Assigned(ft_show_warning) then
    Result := ft_show_warning(PChar(ATitle), PChar(AInstruction), PChar(AMessage))
  else
    Result := 0;
end;

class function TFtMessageDialog.ShowError(const ATitle, AInstruction, AMessage: string; const ADetails: string = ''): Integer;
begin
  if Assigned(ft_show_error) then
    Result := ft_show_error(PChar(ATitle), PChar(AInstruction), PChar(AMessage), PChar(ADetails))
  else
    Result := 0;
end;

class function TFtMessageDialog.Confirm(const ATitle, AInstruction, AMessage: string): Boolean;
begin
  if Assigned(ft_confirm) then
    Result := (ft_confirm(PChar(ATitle), PChar(AInstruction), PChar(AMessage)) <> 0)
  else
    Result := False;
end;

class function TFtMessageDialog.ConfirmWithVerification(const ATitle, AInstruction, AMessage,
                                                       AVerificationText: string;
                                                       out AVerified: Boolean): Boolean;
var
  v: cint32;
  ret: Integer;
begin
  v := 0;
  if Assigned(ft_confirm_with_verification) then
  begin
    ret := ft_confirm_with_verification(PChar(ATitle), PChar(AInstruction), PChar(AMessage),
                                        PChar(AVerificationText), @v);
    AVerified := (v <> 0);
    Result := (ret <> 0);
  end
  else
  begin
    AVerified := False;
    Result := False;
  end;
end;

end.
