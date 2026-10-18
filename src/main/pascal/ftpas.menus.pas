{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal Menus (Main Menu & Popup Menu)     }
{                                                                          }
{   Provides TFtMenuItem, TFtPopupMenu, and TFtMainMenu OOP wrappers.      }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.menus;

{$mode objfpc}{$H+}

interface

uses
  ctypes, Classes, SysUtils, ftpas.api, ftpas.types, ftpas.widget, ftpas.window;

type
  { Forward Declarations }
  TFtMenuItem = class;
  TFtPopupMenu = class;
  TFtMainMenu = class;

  { Event Signatures }
  TFtMenuClickEvent = procedure(Sender: TFtMenuItem) of object;

  { TFtMenuItem — Item inside popup menu or main menu }
  TFtMenuItem = class
  private
    FHandle: Pointer;
    FOnClick: TFtMenuClickEvent;

    function  GetCaption: string;
    procedure SetCaption(const AValue: string);
    function  GetShortcut: string;
    procedure SetShortcut(const AValue: string);
    function  GetEnabled: Boolean;
    procedure SetEnabled(AValue: Boolean);
    function  GetChecked: Boolean;
    procedure SetChecked(AValue: Boolean);
    function  GetCheckable: Boolean;
    procedure SetCheckable(AValue: Boolean);
    function  GetTag: Int64;
    procedure SetTag(AValue: Int64);

    procedure SetOnClick(AValue: TFtMenuClickEvent);
  protected
    procedure DoClick(); virtual;
  public
    constructor Wrap(AHandle: Pointer);

    procedure SetSubMenu(ASubMenu: TFtPopupMenu);

    property Handle: Pointer read FHandle;
    property Caption: string read GetCaption write SetCaption;
    property Shortcut: string read GetShortcut write SetShortcut;
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property Checked: Boolean read GetChecked write SetChecked;
    property Checkable: Boolean read GetCheckable write SetCheckable;
    property Tag: Int64 read GetTag write SetTag;

    property OnClick: TFtMenuClickEvent read FOnClick write SetOnClick;
  end;

  { TFtPopupMenu — Context / popup dropdown menu }
  TFtPopupMenu = class(TFtWidget)
  private
    function  GetItemCount: Integer;
    function  GetItem(AIndex: Integer): TFtMenuItem;
    procedure SetCornerRadius(AValue: Double);
  public
    constructor Create(AParent: TFtWidget); reintroduce;

    function  AddItem(const ACaption: string; AOnClick: TFtMenuClickEvent = nil): TFtMenuItem;
    function  AddCheckItem(const ACaption: string; AChecked: Boolean = False;
                           AOnClick: TFtMenuClickEvent = nil): TFtMenuItem;
    function  AddSeparator(): TFtMenuItem;
    function  AddSubMenu(const ACaption: string; ASubMenu: TFtPopupMenu): TFtMenuItem;

    procedure Show(AX, AY: Integer); reintroduce;
    procedure Close();
    procedure Clear();

    property ItemCount: Integer read GetItemCount;
    property Items[AIndex: Integer]: TFtMenuItem read GetItem;
    property CornerRadius: Double write SetCornerRadius;
  end;

  { TFtMainMenu — Window main menu bar }
  TFtMainMenu = class(TFtWidget)
  private
    function  GetItemCount: Integer;
    function  GetItem(AIndex: Integer): TFtMenuItem;
  public
    constructor Create(AWindow: TFtWindow); reintroduce;

    function  AddMenu(const ACaption: string): TFtPopupMenu;
    function  AddItem(const ACaption: string; APopupMenu: TFtPopupMenu): TFtMenuItem;
    procedure Close();

    property ItemCount: Integer read GetItemCount;
    property Items[AIndex: Integer]: TFtMenuItem read GetItem;
  end;

implementation

{ C Callback Dispatchers }

procedure MenuItemClickDispatcher(AItem: Pointer; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtMenuItem(AUserData).DoClick();
end;

{ TFtMenuItem }

constructor TFtMenuItem.Wrap(AHandle: Pointer);
begin
  inherited Create;
  FHandle := AHandle;
end;

procedure TFtMenuItem.DoClick();
begin
  if Assigned(FOnClick) then
    FOnClick(Self);
end;

function TFtMenuItem.GetCaption: string;
begin
  if (FHandle <> nil) and Assigned(ft_menu_item_get_caption) then
    Result := StrPas(ft_menu_item_get_caption(FHandle))
  else
    Result := '';
end;

procedure TFtMenuItem.SetCaption(const AValue: string);
begin
  if (FHandle <> nil) and Assigned(ft_menu_item_set_caption) then
    ft_menu_item_set_caption(FHandle, PChar(AValue));
end;

function TFtMenuItem.GetShortcut: string;
begin
  if (FHandle <> nil) and Assigned(ft_menu_item_get_shortcut) then
    Result := StrPas(ft_menu_item_get_shortcut(FHandle))
  else
    Result := '';
end;

procedure TFtMenuItem.SetShortcut(const AValue: string);
begin
  if (FHandle <> nil) and Assigned(ft_menu_item_set_shortcut) then
    ft_menu_item_set_shortcut(FHandle, PChar(AValue));
end;

function TFtMenuItem.GetEnabled: Boolean;
begin
  if (FHandle <> nil) and Assigned(ft_menu_item_get_enabled) then
    Result := (ft_menu_item_get_enabled(FHandle) <> 0)
  else
    Result := True;
end;

procedure TFtMenuItem.SetEnabled(AValue: Boolean);
begin
  if (FHandle <> nil) and Assigned(ft_menu_item_set_enabled) then
    ft_menu_item_set_enabled(FHandle, Ord(AValue));
end;

function TFtMenuItem.GetChecked: Boolean;
begin
  if (FHandle <> nil) and Assigned(ft_menu_item_get_checked) then
    Result := (ft_menu_item_get_checked(FHandle) <> 0)
  else
    Result := False;
end;

procedure TFtMenuItem.SetChecked(AValue: Boolean);
begin
  if (FHandle <> nil) and Assigned(ft_menu_item_set_checked) then
    ft_menu_item_set_checked(FHandle, Ord(AValue));
end;

function TFtMenuItem.GetCheckable: Boolean;
begin
  if (FHandle <> nil) and Assigned(ft_menu_item_get_checkable) then
    Result := (ft_menu_item_get_checkable(FHandle) <> 0)
  else
    Result := False;
end;

procedure TFtMenuItem.SetCheckable(AValue: Boolean);
begin
  if (FHandle <> nil) and Assigned(ft_menu_item_set_checkable) then
    ft_menu_item_set_checkable(FHandle, Ord(AValue));
end;

function TFtMenuItem.GetTag: Int64;
begin
  if (FHandle <> nil) and Assigned(ft_menu_item_get_tag) then
    Result := ft_menu_item_get_tag(FHandle)
  else
    Result := 0;
end;

procedure TFtMenuItem.SetTag(AValue: Int64);
begin
  if (FHandle <> nil) and Assigned(ft_menu_item_set_tag) then
    ft_menu_item_set_tag(FHandle, AValue);
end;

procedure TFtMenuItem.SetSubMenu(ASubMenu: TFtPopupMenu);
var
  sh: Pointer;
begin
  if ASubMenu <> nil then sh := ASubMenu.Handle else sh := nil;
  if (FHandle <> nil) and Assigned(ft_menu_item_set_submenu) then
    ft_menu_item_set_submenu(FHandle, sh);
end;

procedure TFtMenuItem.SetOnClick(AValue: TFtMenuClickEvent);
begin
  FOnClick := AValue;
  if (FHandle <> nil) and Assigned(ft_menu_item_on_click) then
    ft_menu_item_on_click(FHandle, @MenuItemClickDispatcher, Self);
end;

{ TFtPopupMenu }

constructor TFtPopupMenu.Create(AParent: TFtWidget);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_popup_menu_create) then
    h := ft_popup_menu_create(pHandle)
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtPopupMenu.AddItem(const ACaption: string; AOnClick: TFtMenuClickEvent = nil): TFtMenuItem;
var
  ih: Pointer;
  item: TFtMenuItem;
begin
  if (Handle <> nil) and Assigned(ft_popup_menu_add_item) then
  begin
    ih := ft_popup_menu_add_item(Handle, PChar(ACaption), nil, nil);
    if ih <> nil then
    begin
      item := TFtMenuItem.Wrap(ih);
      if Assigned(AOnClick) then
        item.OnClick := AOnClick;
      Result := item;
    end
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TFtPopupMenu.AddCheckItem(const ACaption: string; AChecked: Boolean = False;
                                   AOnClick: TFtMenuClickEvent = nil): TFtMenuItem;
var
  ih: Pointer;
  item: TFtMenuItem;
begin
  if (Handle <> nil) and Assigned(ft_popup_menu_add_check_item) then
  begin
    ih := ft_popup_menu_add_check_item(Handle, PChar(ACaption), Ord(AChecked), nil, nil);
    if ih <> nil then
    begin
      item := TFtMenuItem.Wrap(ih);
      if Assigned(AOnClick) then
        item.OnClick := AOnClick;
      Result := item;
    end
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TFtPopupMenu.AddSeparator(): TFtMenuItem;
var
  ih: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_popup_menu_add_separator) then
  begin
    ih := ft_popup_menu_add_separator(Handle);
    if ih <> nil then
      Result := TFtMenuItem.Wrap(ih)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TFtPopupMenu.AddSubMenu(const ACaption: string; ASubMenu: TFtPopupMenu): TFtMenuItem;
var
  sh, ih: Pointer;
begin
  if ASubMenu <> nil then sh := ASubMenu.Handle else sh := nil;
  if (Handle <> nil) and Assigned(ft_popup_menu_add_submenu) then
  begin
    ih := ft_popup_menu_add_submenu(Handle, PChar(ACaption), sh);
    if ih <> nil then
      Result := TFtMenuItem.Wrap(ih)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

procedure TFtPopupMenu.Show(AX, AY: Integer);
begin
  if (Handle <> nil) and Assigned(ft_popup_menu_show) then
    ft_popup_menu_show(Handle, AX, AY);
end;

procedure TFtPopupMenu.Close();
begin
  if (Handle <> nil) and Assigned(ft_popup_menu_close) then
    ft_popup_menu_close(Handle);
end;

procedure TFtPopupMenu.Clear();
begin
  if (Handle <> nil) and Assigned(ft_popup_menu_clear) then
    ft_popup_menu_clear(Handle);
end;

function TFtPopupMenu.GetItemCount: Integer;
begin
  if (Handle <> nil) and Assigned(ft_popup_menu_item_count) then
    Result := ft_popup_menu_item_count(Handle)
  else
    Result := 0;
end;

function TFtPopupMenu.GetItem(AIndex: Integer): TFtMenuItem;
var
  ih: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_popup_menu_get_item) then
  begin
    ih := ft_popup_menu_get_item(Handle, AIndex);
    if ih <> nil then
      Result := TFtMenuItem.Wrap(ih)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

procedure TFtPopupMenu.SetCornerRadius(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_popup_menu_set_corner_radius) then
    ft_popup_menu_set_corner_radius(Handle, AValue);
end;

{ TFtMainMenu }

constructor TFtMainMenu.Create(AWindow: TFtWindow);
var
  wHandle, h: Pointer;
begin
  inherited Create(AWindow);
  if AWindow <> nil then wHandle := AWindow.Handle else wHandle := nil;
  if Assigned(ft_main_menu_create) then
    h := ft_main_menu_create(wHandle)
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtMainMenu.AddMenu(const ACaption: string): TFtPopupMenu;
var
  mh: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_main_menu_add_menu) then
  begin
    mh := ft_main_menu_add_menu(Handle, PChar(ACaption));
    if mh <> nil then
      Result := TFtPopupMenu.Wrap(mh, Self, False)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TFtMainMenu.AddItem(const ACaption: string; APopupMenu: TFtPopupMenu): TFtMenuItem;
var
  ph, ih: Pointer;
begin
  if APopupMenu <> nil then ph := APopupMenu.Handle else ph := nil;
  if (Handle <> nil) and Assigned(ft_main_menu_add_item) then
  begin
    ih := ft_main_menu_add_item(Handle, PChar(ACaption), ph);
    if ih <> nil then
      Result := TFtMenuItem.Wrap(ih)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

procedure TFtMainMenu.Close();
begin
  if (Handle <> nil) and Assigned(ft_main_menu_close) then
    ft_main_menu_close(Handle);
end;

function TFtMainMenu.GetItemCount: Integer;
begin
  if (Handle <> nil) and Assigned(ft_main_menu_item_count) then
    Result := ft_main_menu_item_count(Handle)
  else
    Result := 0;
end;

function TFtMainMenu.GetItem(AIndex: Integer): TFtMenuItem;
var
  ih: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_main_menu_get_item) then
  begin
    ih := ft_main_menu_get_item(Handle, AIndex);
    if ih <> nil then
      Result := TFtMenuItem.Wrap(ih)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

end.
