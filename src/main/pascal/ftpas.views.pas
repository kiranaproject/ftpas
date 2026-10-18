{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal Views & Data Controls              }
{                                                                          }
{   Provides OOP wrappers for advanced desktop data presentation widgets:  }
{   TFtTreeView (hierarchical tree) and TFtTable (multi-column DataGrid).  }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.views;

{$mode objfpc}{$H+}

interface

uses
  ctypes, Classes, SysUtils, ftpas.api, ftpas.types, ftpas.canvas, ftpas.widget;

type
  { Forward Declarations }
  TFtTreeNode = class;
  TFtTreeView = class;
  TFtTable = class;

  { Event Signatures }
  TFtTreeNodeSelectEvent = procedure(Sender: TFtTreeView; Node: TFtTreeNode) of object;
  TFtTableRowSelectEvent = procedure(Sender: TFtTable; RowIndex: Integer) of object;
  TFtTableRowDblClickEvent = procedure(Sender: TFtTable; RowIndex: Integer) of object;

  { TFtTreeNode — Node inside TFtTreeView }
  TFtTreeNode = class
  private
    FHandle: Pointer;
    FOwnsHandle: Boolean;

    function  GetText: string;
    procedure SetText(const AValue: string);
    function  GetExpanded: Boolean;
    procedure SetExpanded(AValue: Boolean);
    function  GetChildCount: Integer;
    function  GetChild(AIndex: Integer): TFtTreeNode;
    function  GetParent: TFtTreeNode;
    function  GetTag: Integer;
    procedure SetTag(AValue: Integer);
    function  GetData: Pointer;
    procedure SetData(AValue: Pointer);
  public
    constructor Wrap(AHandle: Pointer; AOwnsHandle: Boolean = False);
    destructor Destroy; override;

    function  AddChild(const AText: string): TFtTreeNode;
    procedure DeleteChild(AIndex: Integer);
    procedure SetIcon(ABitmap: TFtBitmap);
    function  GetIcon(): TFtBitmap;

    property Handle: Pointer read FHandle;
    property Text: string read GetText write SetText;
    property Expanded: Boolean read GetExpanded write SetExpanded;
    property ChildCount: Integer read GetChildCount;
    property Children[AIndex: Integer]: TFtTreeNode read GetChild;
    property Parent: TFtTreeNode read GetParent;
    property Tag: Integer read GetTag write SetTag;
    property Data: Pointer read GetData write SetData;
  end;

  { TFtTreeView — Hierarchical TreeView widget }
  TFtTreeView = class(TFtWidget)
  private
    FOnSelect: TFtTreeNodeSelectEvent;

    function  GetRoot: TFtTreeNode;
    function  GetSelectedNode: TFtTreeNode;
    procedure SetSelectedNode(AValue: TFtTreeNode);
    function  GetItemHeight: Double;
    procedure SetItemHeight(AValue: Double);
    function  GetIndentWidth: Double;
    procedure SetIndentWidth(AValue: Double);

    procedure SetOnSelect(AValue: TFtTreeNodeSelectEvent);
  protected
    procedure DoSelect(ANode: TFtTreeNode); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer); reintroduce;

    function  AddRoot(const AText: string): TFtTreeNode;
    function  AddNode(const AText: string; AParentNode: TFtTreeNode = nil): TFtTreeNode;
    procedure Clear();

    property Root: TFtTreeNode read GetRoot;
    property SelectedNode: TFtTreeNode read GetSelectedNode write SetSelectedNode;
    property ItemHeight: Double read GetItemHeight write SetItemHeight;
    property IndentWidth: Double read GetIndentWidth write SetIndentWidth;

    property OnSelect: TFtTreeNodeSelectEvent read FOnSelect write SetOnSelect;
  end;

  { TFtTable — Multi-column DataGrid table widget }
  TFtTable = class(TFtWidget)
  private
    FOnSelectRow: TFtTableRowSelectEvent;
    FOnRowDoubleClick: TFtTableRowDblClickEvent;

    function  GetColumnCount: Integer;
    function  GetColumnTitle(AColIdx: Integer): string;
    procedure SetColumnTitle(AColIdx: Integer; const AValue: string);
    function  GetColumnWidth(AColIdx: Integer): Double;
    procedure SetColumnWidth(AColIdx: Integer; AValue: Double);
    function  GetColumnAlign(AColIdx: Integer): TFtTextAlign;
    procedure SetColumnAlign(AColIdx: Integer; AValue: TFtTextAlign);

    function  GetRowCount: Integer;

    function  GetSelectedRow: Integer;
    procedure SetSelectedRow(AValue: Integer);
    function  GetMultiSelect: Boolean;
    procedure SetMultiSelect(AValue: Boolean);
    function  GetSelectedRowCount: Integer;

    function  GetHeaderHeight: Double;
    procedure SetHeaderHeight(AValue: Double);
    function  GetRowHeight: Double;
    procedure SetRowHeight(AValue: Double);
    function  GetShowGridlines: Boolean;
    procedure SetShowGridlines(AValue: Boolean);
    function  GetZebraStriping: Boolean;
    procedure SetZebraStriping(AValue: Boolean);

    procedure SetOnSelectRow(AValue: TFtTableRowSelectEvent);
    procedure SetOnRowDoubleClick(AValue: TFtTableRowDblClickEvent);
  protected
    procedure DoSelectRow(ARowIndex: Integer); virtual;
    procedure DoRowDoubleClick(ARowIndex: Integer); virtual;
  public
    constructor Create(AParent: TFtWidget; AX, AY, AW, AH: Integer); reintroduce;

    { Column Management }
    function  AddColumn(const ATitle: string; AWidth: Double; AAlignment: TFtTextAlign = ftaLeft): Integer;
    procedure SetColumnIcon(AColIdx: Integer; AIcon: TFtBitmap);
    function  GetColumnIcon(AColIdx: Integer): TFtBitmap;

    { Row Management }
    function  AddRow(): Integer;
    procedure DeleteRow(ARowIdx: Integer);
    procedure ClearRows();
    procedure ClearAll();

    { Cell Management }
    function  GetCell(ARow, ACol: Integer): string;
    procedure SetCell(ARow, ACol: Integer; const AValue: string);
    procedure SetCellIcon(ARow, ACol: Integer; AIcon: TFtBitmap);
    function  GetCellIcon(ARow, ACol: Integer): TFtBitmap;

    { Selection Management }
    function  IsRowSelected(ARowIdx: Integer): Boolean;
    procedure SetRowSelected(ARowIdx: Integer; ASelected: Boolean);
    procedure SelectAll();
    procedure ClearSelection();
    function  GetSelectedRows(var AOutIndices: array of Integer): Integer;

    { Properties }
    property ColumnCount: Integer read GetColumnCount;
    property ColumnTitles[AColIdx: Integer]: string read GetColumnTitle write SetColumnTitle;
    property ColumnWidths[AColIdx: Integer]: Double read GetColumnWidth write SetColumnWidth;
    property ColumnAlignments[AColIdx: Integer]: TFtTextAlign read GetColumnAlign write SetColumnAlign;

    property RowCount: Integer read GetRowCount;
    property Cells[ARow, ACol: Integer]: string read GetCell write SetCell; default;

    property SelectedRow: Integer read GetSelectedRow write SetSelectedRow;
    property MultiSelect: Boolean read GetMultiSelect write SetMultiSelect;
    property SelectedRowCount: Integer read GetSelectedRowCount;

    property HeaderHeight: Double read GetHeaderHeight write SetHeaderHeight;
    property RowHeight: Double read GetRowHeight write SetRowHeight;
    property ShowGridlines: Boolean read GetShowGridlines write SetShowGridlines;
    property ZebraStriping: Boolean read GetZebraStriping write SetZebraStriping;

    property OnSelectRow: TFtTableRowSelectEvent read FOnSelectRow write SetOnSelectRow;
    property OnRowDoubleClick: TFtTableRowDblClickEvent read FOnRowDoubleClick write SetOnRowDoubleClick;
  end;

implementation

{ C Callback Dispatchers }

procedure TreeNodeSelectDispatcher(ATreeView: Pointer; ANode: Pointer; AUserData: Pointer); cdecl;
var
  nodeObj: TFtTreeNode;
begin
  if (AUserData <> nil) and (ANode <> nil) then
  begin
    nodeObj := TFtTreeNode.Wrap(ANode, False);
    try
      TFtTreeView(AUserData).DoSelect(nodeObj);
    finally
      nodeObj.Free;
    end;
  end;
end;

procedure TableRowSelectDispatcher(ATable: Pointer; ARowIndex: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtTable(AUserData).DoSelectRow(ARowIndex);
end;

procedure TableRowDblClickDispatcher(ATable: Pointer; ARowIndex: cint32; AUserData: Pointer); cdecl;
begin
  if AUserData <> nil then
    TFtTable(AUserData).DoRowDoubleClick(ARowIndex);
end;

{ TFtTreeNode }

constructor TFtTreeNode.Wrap(AHandle: Pointer; AOwnsHandle: Boolean = False);
begin
  inherited Create;
  FHandle := AHandle;
  FOwnsHandle := AOwnsHandle;
end;

destructor TFtTreeNode.Destroy;
begin
  inherited Destroy;
end;

function TFtTreeNode.GetText: string;
begin
  if (FHandle <> nil) and Assigned(ft_treenode_get_text) then
    Result := StrPas(ft_treenode_get_text(FHandle))
  else
    Result := '';
end;

procedure TFtTreeNode.SetText(const AValue: string);
begin
  if (FHandle <> nil) and Assigned(ft_treenode_set_text) then
    ft_treenode_set_text(FHandle, PChar(AValue));
end;

function TFtTreeNode.GetExpanded: Boolean;
begin
  if (FHandle <> nil) and Assigned(ft_treenode_get_expanded) then
    Result := (ft_treenode_get_expanded(FHandle) <> 0)
  else
    Result := False;
end;

procedure TFtTreeNode.SetExpanded(AValue: Boolean);
begin
  if (FHandle <> nil) and Assigned(ft_treenode_set_expanded) then
    ft_treenode_set_expanded(FHandle, Ord(AValue));
end;

function TFtTreeNode.GetChildCount: Integer;
begin
  if (FHandle <> nil) and Assigned(ft_treenode_get_child_count) then
    Result := ft_treenode_get_child_count(FHandle)
  else
    Result := 0;
end;

function TFtTreeNode.GetChild(AIndex: Integer): TFtTreeNode;
var
  ch: Pointer;
begin
  if (FHandle <> nil) and Assigned(ft_treenode_get_child) then
  begin
    ch := ft_treenode_get_child(FHandle, AIndex);
    if ch <> nil then
      Result := TFtTreeNode.Wrap(ch, False)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TFtTreeNode.GetParent: TFtTreeNode;
var
  ph: Pointer;
begin
  if (FHandle <> nil) and Assigned(ft_treenode_get_parent) then
  begin
    ph := ft_treenode_get_parent(FHandle);
    if ph <> nil then
      Result := TFtTreeNode.Wrap(ph, False)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TFtTreeNode.GetTag: Integer;
begin
  if (FHandle <> nil) and Assigned(ft_treenode_get_tag) then
    Result := ft_treenode_get_tag(FHandle)
  else
    Result := 0;
end;

procedure TFtTreeNode.SetTag(AValue: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_treenode_set_tag) then
    ft_treenode_set_tag(FHandle, AValue);
end;

function TFtTreeNode.GetData: Pointer;
begin
  if (FHandle <> nil) and Assigned(ft_treenode_get_data) then
    Result := ft_treenode_get_data(FHandle)
  else
    Result := nil;
end;

procedure TFtTreeNode.SetData(AValue: Pointer);
begin
  if (FHandle <> nil) and Assigned(ft_treenode_set_data) then
    ft_treenode_set_data(FHandle, AValue);
end;

function TFtTreeNode.AddChild(const AText: string): TFtTreeNode;
var
  ch: Pointer;
begin
  if (FHandle <> nil) and Assigned(ft_treenode_add_child) then
  begin
    ch := ft_treenode_add_child(FHandle, PChar(AText));
    if ch <> nil then
      Result := TFtTreeNode.Wrap(ch, False)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

procedure TFtTreeNode.DeleteChild(AIndex: Integer);
begin
  if (FHandle <> nil) and Assigned(ft_treenode_delete_child) then
    ft_treenode_delete_child(FHandle, AIndex);
end;

procedure TFtTreeNode.SetIcon(ABitmap: TFtBitmap);
var
  bh: Pointer;
begin
  if ABitmap <> nil then bh := ABitmap.Handle else bh := nil;
  if (FHandle <> nil) and Assigned(ft_treenode_set_icon) then
    ft_treenode_set_icon(FHandle, bh);
end;

function TFtTreeNode.GetIcon(): TFtBitmap;
var
  bh: Pointer;
begin
  if (FHandle <> nil) and Assigned(ft_treenode_get_icon) then
  begin
    bh := ft_treenode_get_icon(FHandle);
    if bh <> nil then
      Result := TFtBitmap.Wrap(bh, False)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

{ TFtTreeView }

constructor TFtTreeView.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_treeview_create) then
    h := ft_treeview_create(pHandle, AX, AY, AW, AH)
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtTreeView.AddRoot(const AText: string): TFtTreeNode;
begin
  Result := AddNode(AText, nil);
end;

function TFtTreeView.AddNode(const AText: string; AParentNode: TFtTreeNode = nil): TFtTreeNode;
var
  ph, nh: Pointer;
begin
  if AParentNode <> nil then ph := AParentNode.Handle else ph := nil;
  if (Handle <> nil) and Assigned(ft_treeview_add_node) then
  begin
    nh := ft_treeview_add_node(Handle, PChar(AText), ph);
    if nh <> nil then
      Result := TFtTreeNode.Wrap(nh, False)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

procedure TFtTreeView.Clear();
begin
  if (Handle <> nil) and Assigned(ft_treeview_clear) then
    ft_treeview_clear(Handle);
end;

function TFtTreeView.GetRoot: TFtTreeNode;
var
  rh: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_treeview_get_root) then
  begin
    rh := ft_treeview_get_root(Handle);
    if rh <> nil then
      Result := TFtTreeNode.Wrap(rh, False)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TFtTreeView.GetSelectedNode: TFtTreeNode;
var
  sh: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_treeview_get_selected_node) then
  begin
    sh := ft_treeview_get_selected_node(Handle);
    if sh <> nil then
      Result := TFtTreeNode.Wrap(sh, False)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

procedure TFtTreeView.SetSelectedNode(AValue: TFtTreeNode);
var
  sh: Pointer;
begin
  if AValue <> nil then sh := AValue.Handle else sh := nil;
  if (Handle <> nil) and Assigned(ft_treeview_set_selected_node) then
    ft_treeview_set_selected_node(Handle, sh);
end;

function TFtTreeView.GetItemHeight: Double;
begin
  if (Handle <> nil) and Assigned(ft_treeview_get_item_height) then
    Result := ft_treeview_get_item_height(Handle)
  else
    Result := 24.0;
end;

procedure TFtTreeView.SetItemHeight(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_treeview_set_item_height) then
    ft_treeview_set_item_height(Handle, AValue);
end;

function TFtTreeView.GetIndentWidth: Double;
begin
  if (Handle <> nil) and Assigned(ft_treeview_get_indent_width) then
    Result := ft_treeview_get_indent_width(Handle)
  else
    Result := 16.0;
end;

procedure TFtTreeView.SetIndentWidth(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_treeview_set_indent_width) then
    ft_treeview_set_indent_width(Handle, AValue);
end;

procedure TFtTreeView.SetOnSelect(AValue: TFtTreeNodeSelectEvent);
begin
  FOnSelect := AValue;
  if (Handle <> nil) and Assigned(ft_treeview_on_select) then
    ft_treeview_on_select(Handle, @TreeNodeSelectDispatcher, Self);
end;

procedure TFtTreeView.DoSelect(ANode: TFtTreeNode);
begin
  if Assigned(FOnSelect) then
    FOnSelect(Self, ANode);
end;

{ TFtTable }

constructor TFtTable.Create(AParent: TFtWidget; AX, AY, AW, AH: Integer);
var
  pHandle, h: Pointer;
begin
  inherited Create(AParent);
  if AParent <> nil then pHandle := AParent.Handle else pHandle := nil;
  if Assigned(ft_table_create) then
    h := ft_table_create(pHandle, AX, AY, AW, AH)
  else
    h := nil;
  SetHandle(h, True);
end;

function TFtTable.AddColumn(const ATitle: string; AWidth: Double; AAlignment: TFtTextAlign = ftaLeft): Integer;
begin
  if (Handle <> nil) and Assigned(ft_table_add_column) then
    Result := ft_table_add_column(Handle, PChar(ATitle), AWidth, Ord(AAlignment))
  else
    Result := -1;
end;

function TFtTable.GetColumnCount: Integer;
begin
  if (Handle <> nil) and Assigned(ft_table_get_column_count) then
    Result := ft_table_get_column_count(Handle)
  else
    Result := 0;
end;

function TFtTable.GetColumnTitle(AColIdx: Integer): string;
begin
  if (Handle <> nil) and Assigned(ft_table_get_column_title) then
    Result := StrPas(ft_table_get_column_title(Handle, AColIdx))
  else
    Result := '';
end;

procedure TFtTable.SetColumnTitle(AColIdx: Integer; const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_table_set_column_title) then
    ft_table_set_column_title(Handle, AColIdx, PChar(AValue));
end;

function TFtTable.GetColumnWidth(AColIdx: Integer): Double;
begin
  if (Handle <> nil) and Assigned(ft_table_get_column_width) then
    Result := ft_table_get_column_width(Handle, AColIdx)
  else
    Result := 100.0;
end;

procedure TFtTable.SetColumnWidth(AColIdx: Integer; AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_table_set_column_width) then
    ft_table_set_column_width(Handle, AColIdx, AValue);
end;

function TFtTable.GetColumnAlign(AColIdx: Integer): TFtTextAlign;
begin
  if (Handle <> nil) and Assigned(ft_table_get_column_align) then
    Result := TFtTextAlign(ft_table_get_column_align(Handle, AColIdx))
  else
    Result := ftaLeft;
end;

procedure TFtTable.SetColumnAlign(AColIdx: Integer; AValue: TFtTextAlign);
begin
  if (Handle <> nil) and Assigned(ft_table_set_column_align) then
    ft_table_set_column_align(Handle, AColIdx, Ord(AValue));
end;

procedure TFtTable.SetColumnIcon(AColIdx: Integer; AIcon: TFtBitmap);
var
  bh: Pointer;
begin
  if AIcon <> nil then bh := AIcon.Handle else bh := nil;
  if (Handle <> nil) and Assigned(ft_table_set_column_icon) then
    ft_table_set_column_icon(Handle, AColIdx, bh);
end;

function TFtTable.GetColumnIcon(AColIdx: Integer): TFtBitmap;
var
  bh: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_table_get_column_icon) then
  begin
    bh := ft_table_get_column_icon(Handle, AColIdx);
    if bh <> nil then
      Result := TFtBitmap.Wrap(bh, False)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TFtTable.AddRow(): Integer;
begin
  if (Handle <> nil) and Assigned(ft_table_add_row) then
    Result := ft_table_add_row(Handle)
  else
    Result := -1;
end;

procedure TFtTable.DeleteRow(ARowIdx: Integer);
begin
  if (Handle <> nil) and Assigned(ft_table_delete_row) then
    ft_table_delete_row(Handle, ARowIdx);
end;

procedure TFtTable.ClearRows();
begin
  if (Handle <> nil) and Assigned(ft_table_clear_rows) then
    ft_table_clear_rows(Handle);
end;

procedure TFtTable.ClearAll();
begin
  if (Handle <> nil) and Assigned(ft_table_clear_all) then
    ft_table_clear_all(Handle);
end;

function TFtTable.GetRowCount: Integer;
begin
  if (Handle <> nil) and Assigned(ft_table_get_row_count) then
    Result := ft_table_get_row_count(Handle)
  else
    Result := 0;
end;

function TFtTable.GetCell(ARow, ACol: Integer): string;
begin
  if (Handle <> nil) and Assigned(ft_table_get_cell) then
    Result := StrPas(ft_table_get_cell(Handle, ARow, ACol))
  else
    Result := '';
end;

procedure TFtTable.SetCell(ARow, ACol: Integer; const AValue: string);
begin
  if (Handle <> nil) and Assigned(ft_table_set_cell) then
    ft_table_set_cell(Handle, ARow, ACol, PChar(AValue));
end;

procedure TFtTable.SetCellIcon(ARow, ACol: Integer; AIcon: TFtBitmap);
var
  bh: Pointer;
begin
  if AIcon <> nil then bh := AIcon.Handle else bh := nil;
  if (Handle <> nil) and Assigned(ft_table_set_cell_icon) then
    ft_table_set_cell_icon(Handle, ARow, ACol, bh);
end;

function TFtTable.GetCellIcon(ARow, ACol: Integer): TFtBitmap;
var
  bh: Pointer;
begin
  if (Handle <> nil) and Assigned(ft_table_get_cell_icon) then
  begin
    bh := ft_table_get_cell_icon(Handle, ARow, ACol);
    if bh <> nil then
      Result := TFtBitmap.Wrap(bh, False)
    else
      Result := nil;
  end
  else
    Result := nil;
end;

function TFtTable.GetSelectedRow: Integer;
begin
  if (Handle <> nil) and Assigned(ft_table_get_selected_row) then
    Result := ft_table_get_selected_row(Handle)
  else
    Result := -1;
end;

procedure TFtTable.SetSelectedRow(AValue: Integer);
begin
  if (Handle <> nil) and Assigned(ft_table_set_selected_row) then
    ft_table_set_selected_row(Handle, AValue);
end;

function TFtTable.GetMultiSelect: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_table_get_multi_select) then
    Result := (ft_table_get_multi_select(Handle) <> 0)
  else
    Result := False;
end;

procedure TFtTable.SetMultiSelect(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_table_set_multi_select) then
    ft_table_set_multi_select(Handle, Ord(AValue));
end;

function TFtTable.IsRowSelected(ARowIdx: Integer): Boolean;
begin
  if (Handle <> nil) and Assigned(ft_table_is_row_selected) then
    Result := (ft_table_is_row_selected(Handle, ARowIdx) <> 0)
  else
    Result := False;
end;

procedure TFtTable.SetRowSelected(ARowIdx: Integer; ASelected: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_table_set_row_selected) then
    ft_table_set_row_selected(Handle, ARowIdx, Ord(ASelected));
end;

procedure TFtTable.SelectAll();
begin
  if (Handle <> nil) and Assigned(ft_table_select_all) then
    ft_table_select_all(Handle);
end;

procedure TFtTable.ClearSelection();
begin
  if (Handle <> nil) and Assigned(ft_table_clear_selection) then
    ft_table_clear_selection(Handle);
end;

function TFtTable.GetSelectedRowCount: Integer;
begin
  if (Handle <> nil) and Assigned(ft_table_get_selected_row_count) then
    Result := ft_table_get_selected_row_count(Handle)
  else
    Result := 0;
end;

function TFtTable.GetSelectedRows(var AOutIndices: array of Integer): Integer;
var
  buf: array of cint32;
  count, i: Integer;
begin
  if (Handle <> nil) and Assigned(ft_table_get_selected_rows) and (Length(AOutIndices) > 0) then
  begin
    SetLength(buf, Length(AOutIndices));
    count := ft_table_get_selected_rows(Handle, @buf[0], Length(buf));
    for i := 0 to count - 1 do
      AOutIndices[i] := buf[i];
    Result := count;
  end
  else
    Result := 0;
end;

function TFtTable.GetHeaderHeight: Double;
begin
  if (Handle <> nil) and Assigned(ft_table_get_header_height) then
    Result := ft_table_get_header_height(Handle)
  else
    Result := 28.0;
end;

procedure TFtTable.SetHeaderHeight(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_table_set_header_height) then
    ft_table_set_header_height(Handle, AValue);
end;

function TFtTable.GetRowHeight: Double;
begin
  if (Handle <> nil) and Assigned(ft_table_get_row_height) then
    Result := ft_table_get_row_height(Handle)
  else
    Result := 24.0;
end;

procedure TFtTable.SetRowHeight(AValue: Double);
begin
  if (Handle <> nil) and Assigned(ft_table_set_row_height) then
    ft_table_set_row_height(Handle, AValue);
end;

function TFtTable.GetShowGridlines: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_table_get_show_gridlines) then
    Result := (ft_table_get_show_gridlines(Handle) <> 0)
  else
    Result := True;
end;

procedure TFtTable.SetShowGridlines(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_table_set_show_gridlines) then
    ft_table_set_show_gridlines(Handle, Ord(AValue));
end;

function TFtTable.GetZebraStriping: Boolean;
begin
  if (Handle <> nil) and Assigned(ft_table_get_zebra_striping) then
    Result := (ft_table_get_zebra_striping(Handle) <> 0)
  else
    Result := True;
end;

procedure TFtTable.SetZebraStriping(AValue: Boolean);
begin
  if (Handle <> nil) and Assigned(ft_table_set_zebra_striping) then
    ft_table_set_zebra_striping(Handle, Ord(AValue));
end;

procedure TFtTable.SetOnSelectRow(AValue: TFtTableRowSelectEvent);
begin
  FOnSelectRow := AValue;
  if (Handle <> nil) and Assigned(ft_table_on_select_row) then
    ft_table_on_select_row(Handle, @TableRowSelectDispatcher, Self);
end;

procedure TFtTable.SetOnRowDoubleClick(AValue: TFtTableRowDblClickEvent);
begin
  FOnRowDoubleClick := AValue;
  if (Handle <> nil) and Assigned(ft_table_on_row_double_click) then
    ft_table_on_row_double_click(Handle, @TableRowDblClickDispatcher, Self);
end;

procedure TFtTable.DoSelectRow(ARowIndex: Integer);
begin
  if Assigned(FOnSelectRow) then
    FOnSelectRow(Self, ARowIndex);
end;

procedure TFtTable.DoRowDoubleClick(ARowIndex: Integer);
begin
  if Assigned(FOnRowDoubleClick) then
    FOnRowDoubleClick(Self, ARowIndex);
end;

end.
