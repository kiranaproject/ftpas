{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal C ABI Low-Level Binding            }
{                                                                          }
{   Provides direct C API definitions and dynamic library loading for      }
{   libft.so, exposing the full functionality of Floria Toolkit.           }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

unit ftpas.api;

{$mode objfpc}{$H+}

interface

uses
  ctypes, SysUtils, dynlibs;

const
  FT_LIB_NAME = 'libft.so';

  { Button States }
  FT_BUTTON_STATE_NORMAL  = 0;
  FT_BUTTON_STATE_HOVERED = 1;
  FT_BUTTON_STATE_PRESSED = 2;

  { Cursor Types }
  FT_CURSOR_DEFAULT   = 0;
  FT_CURSOR_IBEAM     = 1;
  FT_CURSOR_SIZE_H    = 2;
  FT_CURSOR_SIZE_V    = 3;
  FT_CURSOR_HAND      = 4;
  FT_CURSOR_CROSSHAIR = 5;
  FT_CURSOR_MOVE      = 6;

  { Window Types }
  FT_WINDOW_TYPE_NORMAL        = 0;
  FT_WINDOW_TYPE_DIALOG        = 1;
  FT_WINDOW_TYPE_POPUP_MENU    = 2;
  FT_WINDOW_TYPE_DROPDOWN_MENU = 3;
  FT_WINDOW_TYPE_TOOLTIP       = 4;
  FT_WINDOW_TYPE_UTILITY       = 5;
  FT_WINDOW_TYPE_DOCK          = 6;
  FT_WINDOW_TYPE_DESKTOP       = 7;

  { Micro-Flexbox Child Alignments }
  FT_ALIGN_SELF_AUTO    = 0;
  FT_ALIGN_SELF_STRETCH = 1;
  FT_ALIGN_SELF_START   = 2;
  FT_ALIGN_SELF_CENTER  = 3;
  FT_ALIGN_SELF_END     = 4;

  { Button Icon Positions }
  FT_BUTTON_ICON_LEFT  = 0;
  FT_BUTTON_ICON_RIGHT = 1;
  FT_BUTTON_ICON_TOP   = 2;
  FT_BUTTON_ICON_ONLY  = 3;

  { Window Button Kinds }
  FT_WINDOW_BUTTON_CLOSE    = 0;
  FT_WINDOW_BUTTON_MINIMIZE = 1;
  FT_WINDOW_BUTTON_MAXIMIZE = 2;
  FT_WINDOW_BUTTON_RESTORE  = 3;
  FT_WINDOW_BUTTON_SHADE    = 4;
  FT_WINDOW_BUTTON_PIN      = 5;
  FT_WINDOW_BUTTON_MENU     = 6;
  FT_WINDOW_BUTTON_ADD      = 7;

  { Window Button Styles }
  FT_WINDOW_BUTTON_CIRCLE   = 0;
  FT_WINDOW_BUTTON_SQUIRCLE = 1;
  FT_WINDOW_BUTTON_SQUARE   = 2;

  { Text Alignments }
  FT_TEXT_ALIGN_LEFT   = 0;
  FT_TEXT_ALIGN_CENTER = 1;
  FT_TEXT_ALIGN_RIGHT  = 2;

  { PathBar Modes }
  FT_PATH_BAR_MODE_BREADCRUMBS = 0;
  FT_PATH_BAR_MODE_EDIT        = 1;

  { UrlEntry Security States }
  FT_URL_SECURITY_SECURE   = 0;
  FT_URL_SECURITY_INSECURE = 1;
  FT_URL_SECURITY_INTERNAL = 2;
  FT_URL_SECURITY_FILE     = 3;
  FT_URL_SECURITY_CUSTOM   = 4;

  { UrlEntry Action IDs }
  FT_URL_ACTION_BOOKMARK = 1;

  { ScrollBar Orientations }
  FT_SCROLLBAR_HORIZONTAL = 0;
  FT_SCROLLBAR_VERTICAL   = 1;

  { ScrollBar Modes }
  FT_SCROLLBAR_MODE_NONE            = 0;
  FT_SCROLLBAR_MODE_HORIZONTAL_ONLY = 1;
  FT_SCROLLBAR_MODE_VERTICAL_ONLY   = 2;
  FT_SCROLLBAR_MODE_AUTO_BOTH       = 3;

  { Flex Directions }
  FT_FLEX_ROW    = 0;
  FT_FLEX_COLUMN = 1;

  { Flex Justify Content }
  FT_JUSTIFY_START         = 0;
  FT_JUSTIFY_CENTER        = 1;
  FT_JUSTIFY_END           = 2;
  FT_JUSTIFY_SPACE_BETWEEN = 3;
  FT_JUSTIFY_SPACE_AROUND  = 4;
  FT_JUSTIFY_SPACE_EVENLY  = 5;

  { Flex Align Items }
  FT_ALIGN_STRETCH = 0;
  FT_ALIGN_START   = 1;
  FT_ALIGN_CENTER  = 2;
  FT_ALIGN_END     = 3;

  { Flex Wrap }
  FT_FLEX_NOWRAP       = 0;
  FT_FLEX_WRAP         = 1;
  FT_FLEX_WRAP_REVERSE = 2;

  { Anchor Modes }
  FT_ANCHOR_TOP_CENTER    = 0;
  FT_ANCHOR_BOTTOM_CENTER = 1;
  FT_ANCHOR_TOP_LEFT      = 2;
  FT_ANCHOR_TOP_RIGHT     = 3;
  FT_ANCHOR_BOTTOM_LEFT   = 4;
  FT_ANCHOR_BOTTOM_RIGHT  = 5;
  FT_ANCHOR_CENTER        = 6;

  { Grid Track Sizes }
  FT_GRID_AUTO  = 0;
  FT_GRID_FIXED = 1;
  FT_GRID_FLEX  = 2;

  { Slider Orientations }
  FT_SLIDER_HORIZONTAL = 0;
  FT_SLIDER_VERTICAL   = 1;

  { ProgressBar Orientations }
  FT_PROGRESS_HORIZONTAL = 0;
  FT_PROGRESS_VERTICAL   = 1;

  { Image Scale Modes }
  FT_IMAGE_SCALE_FIT     = 0;
  FT_IMAGE_SCALE_STRETCH = 1;
  FT_IMAGE_SCALE_CENTER  = 2;
  FT_IMAGE_SCALE_NONE    = 3;

  { Splitter Orientations }
  FT_SPLITTER_HORIZONTAL = 0;
  FT_SPLITTER_VERTICAL   = 1;

  { File Dialog Types }
  FT_FILE_DIALOG_OPEN          = 0;
  FT_FILE_DIALOG_SAVE          = 1;
  FT_FILE_DIALOG_SELECT_FOLDER = 2;

  { Modal Results }
  FT_MODAL_NONE    = 0;
  FT_MODAL_OK      = 1;
  FT_MODAL_CANCEL  = 2;
  FT_MODAL_YES     = 3;
  FT_MODAL_NO      = 4;
  FT_MODAL_ABORT   = 5;
  FT_MODAL_RETRY   = 6;
  FT_MODAL_IGNORE  = 7;
  FT_MODAL_CLOSE   = 8;

  { Message Dialog Severities }
  FT_MSG_DIALOG_CUSTOM   = 0;
  FT_MSG_DIALOG_INFO     = 1;
  FT_MSG_DIALOG_WARNING  = 2;
  FT_MSG_DIALOG_ERROR    = 3;
  FT_MSG_DIALOG_QUESTION = 4;
  FT_MSG_DIALOG_SUCCESS  = 5;

  { Message Dialog Button Presets }
  FT_MSG_BUTTONS_OK            = 0;
  FT_MSG_BUTTONS_OK_CANCEL     = 1;
  FT_MSG_BUTTONS_YES_NO        = 2;
  FT_MSG_BUTTONS_YES_NO_CANCEL = 3;
  FT_MSG_BUTTONS_RETRY_CANCEL  = 4;
  FT_MSG_BUTTONS_CUSTOM        = 5;

  { Ruler Orientations }
  FT_RULER_HORIZONTAL = 0;
  FT_RULER_VERTICAL   = 1;

  { Ruler Units }
  FT_RULER_UNIT_PIXELS      = 0;
  FT_RULER_UNIT_POINTS      = 1;
  FT_RULER_UNIT_MILLIMETERS = 2;
  FT_RULER_UNIT_CENTIMETERS = 3;
  FT_RULER_UNIT_INCHES      = 4;

  { GPU Blend Modes }
  FT_BLEND_SRCOVER  = 0;
  FT_BLEND_ADDITIVE = 1;
  FT_BLEND_MULTIPLY = 2;
  FT_BLEND_SCREEN   = 3;
  FT_BLEND_SRC      = 4;

  { GPU Join & Cap Styles }
  FT_JOIN_MITER = 0;
  FT_JOIN_BEVEL = 1;
  FT_JOIN_ROUND = 2;

  FT_CAP_BUTT   = 0;
  FT_CAP_SQUARE = 1;
  FT_CAP_ROUND  = 2;

type
  { Handle Types }
  TFtWidget        = Pointer;
  TFtBitmap        = Pointer;
  TFtCanvas        = Pointer;
  TFtNotebook      = Pointer;
  TFtTabPage       = Pointer;
  TFtSplitter      = Pointer;
  TFtTreeView      = Pointer;
  TFtTreeNode      = Pointer;
  TFtTable         = Pointer;
  TFtFileDialog    = Pointer;
  TFtMessageDialog = Pointer;
  TFtCamera2D      = Pointer;
  TFtRenderBatch   = Pointer;
  TFtGPUTessellator= Pointer;
  TFtTessMesh      = Pointer;
  TFtGPURenderer   = Pointer;
  TFtSizeGroup     = Pointer;
  TFtMenuItem      = Pointer;

  { Point & Geometry Records }
  TFtPoint2D = record
    x: Single;
    y: Single;
  end;
  PFtPoint2D = ^TFtPoint2D;

  TFtBatchStats = record
    draw_calls: Cardinal;
    vertex_count: Cardinal;
  end;
  PFtBatchStats = ^TFtBatchStats;

  { C Callback Signatures }
  TFtClickCallback               = procedure(widget: TFtWidget; user_data: Pointer); cdecl;
  TFtHoverCallback               = procedure(widget: TFtWidget; hovered: cint32; user_data: Pointer); cdecl;
  TFtPressCallback               = procedure(widget: TFtWidget; pressed: cint32; user_data: Pointer); cdecl;
  TFtToggleCallback              = procedure(widget: TFtWidget; toggled: cint32; user_data: Pointer); cdecl;
  TFtWindowGLDrawCallback        = procedure(window: TFtWidget; width, height: cint32; user_data: Pointer); cdecl;
  TFtButtonPaintCallback         = procedure(button: TFtWidget; canvas: Pointer; x, y, w, h: Double; state: cint32; user_data: Pointer); cdecl;
  TFtEntryChangeCallback         = procedure(widget: TFtWidget; text: PChar; user_data: Pointer); cdecl;
  TFtEntrySubmitCallback         = procedure(widget: TFtWidget; text: PChar; user_data: Pointer); cdecl;
  TFtTextAreaChangeCallback      = procedure(widget: TFtWidget; text: PChar; user_data: Pointer); cdecl;
  TFtPathBarNavigateCallback     = procedure(pathbar: TFtWidget; path: PChar; user_data: Pointer); cdecl;
  TFtPathBarModeChangeCallback   = procedure(pathbar: TFtWidget; mode: cint32; user_data: Pointer); cdecl;
  TFtUrlEntrySubmitCallback      = procedure(url_entry: TFtWidget; url: PChar; user_data: Pointer); cdecl;
  TFtUrlEntrySecurityClickCallback = procedure(url_entry: TFtWidget; security_state: cint32; user_data: Pointer); cdecl;
  TFtUrlEntryBookmarkClickCallback = procedure(url_entry: TFtWidget; bookmarked: cint32; user_data: Pointer); cdecl;
  TFtUrlEntryActionClickCallback = procedure(url_entry: TFtWidget; action_id: cint32; user_data: Pointer); cdecl;
  TFtScrollCallback              = procedure(widget: TFtWidget; value: Double; user_data: Pointer); cdecl;
  TFtCheckCallback               = procedure(widget: TFtWidget; checked: cint32; user_data: Pointer); cdecl;
  TFtRadioCallback               = procedure(widget: TFtWidget; checked: cint32; user_data: Pointer); cdecl;
  TFtComboChangeCallback         = procedure(widget: TFtWidget; selected_index: cint32; text: PChar; user_data: Pointer); cdecl;
  TFtSliderChangeCallback        = procedure(widget: TFtWidget; value: Double; user_data: Pointer); cdecl;
  TFtMenuCallback                = procedure(item: TFtMenuItem; user_data: Pointer); cdecl;
  TFtTabChangeCallback           = procedure(notebook: TFtNotebook; new_index, old_index: cint32; user_data: Pointer); cdecl;
  TFtSplitterPositionCallback    = procedure(splitter: TFtSplitter; position: Double; user_data: Pointer); cdecl;
  TFtTreeNodeSelectCallback      = procedure(treeview: TFtTreeView; node: TFtTreeNode; user_data: Pointer); cdecl;
  TFtTableRowSelectCallback      = procedure(table: TFtTable; row_index: cint32; user_data: Pointer); cdecl;
  TFtTableRowDoubleClickCallback = procedure(table: TFtTable; row_index: cint32; user_data: Pointer); cdecl;
  TFtTableDrawHeaderCallback     = function(table: TFtTable; canvas: Pointer; col_idx: cint32; x, y, w, h: Double; sort_order: cint32; user_data: Pointer): cint32; cdecl;
  TFtTableDrawCellCallback       = function(table: TFtTable; canvas: Pointer; row_idx, col_idx: cint32; x, y, w, h: Double; is_selected, is_hovered: cint32; user_data: Pointer): cint32; cdecl;
  TFtDrawingPaintCallback        = procedure(widget: TFtWidget; canvas: TFtCanvas; user_data: Pointer); cdecl;
  TFtDrawingMouseEvent           = procedure(widget: TFtWidget; x, y, button: cint32; user_data: Pointer); cdecl;
  TFtDrawingMouseMoveEvent       = procedure(widget: TFtWidget; x, y: cint32; user_data: Pointer); cdecl;
  TFtDrawingWheelEvent           = procedure(widget: TFtWidget; x, y, delta_x, delta_y: cint32; user_data: Pointer); cdecl;
  TFtDrawingKeyEvent             = procedure(widget: TFtWidget; keysym, state: cuint32; user_data: Pointer); cdecl;
  TFtDrawingResizeEvent          = procedure(widget: TFtWidget; new_width, new_height: cint32; user_data: Pointer); cdecl;
  TFtRulerGuideEvent             = procedure(widget: TFtWidget; world_pos: Double; user_data: Pointer); cdecl;
  TFtScrubberChangeEvent         = procedure(widget: TFtWidget; new_value: Double; user_data: Pointer); cdecl;
  TFtWindowMouseCallback         = procedure(window: TFtWidget; x, y, button: cint32; user_data: Pointer); cdecl;
  TFtWindowMouseMoveCallback     = procedure(window: TFtWidget; x, y: cint32; user_data: Pointer); cdecl;
  TFtWindowKeyCallback           = procedure(window: TFtWidget; key: cuint32; is_down: cint32; user_data: Pointer); cdecl;
  TFtWindowResizeCallback        = procedure(window: TFtWidget; new_width, new_height: cint32; user_data: Pointer); cdecl;
  TFtWindowCloseCallback         = function(window: TFtWidget; user_data: Pointer): cint32; cdecl;
  TFtDestroyCallback             = procedure(widget: TFtWidget; user_data: Pointer); cdecl;
  TFtEventFilterFunc             = function(event: Pointer): cint32; cdecl;
  TFtTickCallback                = procedure(user_data: Pointer); cdecl;

{ Function Pointer Declarations for Dynamic Dispatch }
var
  { Core Lifecycle }
  ft_init: procedure(); cdecl;
  ft_main_loop: procedure(); cdecl;
  ft_quit: procedure(); cdecl;

  { Window Management }
  ft_window_create: function(width, height: cint32; title: PChar): TFtWidget; cdecl;
  ft_window_set_title: procedure(window: TFtWidget; title: PChar); cdecl;
  ft_window_set_borderless: procedure(window: TFtWidget; borderless: cint32); cdecl;
  ft_window_get_borderless: function(window: TFtWidget): cint32; cdecl;
  ft_window_set_skip_taskbar: procedure(window: TFtWidget; skip_taskbar: cint32); cdecl;
  ft_window_get_skip_taskbar: function(window: TFtWidget): cint32; cdecl;
  ft_window_set_window_type: procedure(window: TFtWidget; window_type: cint32); cdecl;
  ft_window_get_window_type: function(window: TFtWidget): cint32; cdecl;
  ft_window_set_position: procedure(window: TFtWidget; x, y: cint32); cdecl;
  ft_window_get_position: procedure(window: TFtWidget; out x, y: cint32); cdecl;
  ft_window_set_opacity: procedure(window: TFtWidget; opacity: Double); cdecl;
  ft_window_get_opacity: function(window: TFtWidget): Double; cdecl;
  ft_window_set_background_opacity: procedure(window: TFtWidget; opacity: Double); cdecl;
  ft_window_get_background_opacity: function(window: TFtWidget): Double; cdecl;
  ft_window_set_background_blur: procedure(window: TFtWidget; blur: cint32); cdecl;
  ft_window_get_background_blur: function(window: TFtWidget): cint32; cdecl;
  ft_window_set_strut_partial: procedure(window: TFtWidget; left, right, top, bottom, left_start_y, left_end_y, right_start_y, right_end_y, top_start_x, top_end_x, bottom_start_x, bottom_end_x: cint32); cdecl;
  ft_window_show_modal: function(window: TFtWidget): cint32; cdecl;
  ft_window_bring_to_front: procedure(window: TFtWidget); cdecl;
  ft_window_grab_input: procedure(window: TFtWidget); cdecl;
  ft_window_ungrab_input: procedure(window: TFtWidget); cdecl;
  ft_window_get_native_handle: function(window: TFtWidget): Pointer; cdecl;
  ft_window_set_layout: procedure(window, layout: TFtWidget); cdecl;

  { Hardware Acceleration & EGL }
  ft_egl_is_available: function(): cint32; cdecl;
  ft_backend_enable_egl: function(enable: cint32): cint32; cdecl;
  ft_backend_is_egl_enabled: function(): cint32; cdecl;
  ft_egl_window_create: function(width, height: cint32; title: PChar): TFtWidget; cdecl;
  ft_window_is_hardware_accelerated: function(window: TFtWidget): cint32; cdecl;
  ft_window_set_hardware_accelerated: procedure(window: TFtWidget; accelerated: cint32); cdecl;
  ft_window_set_swap_interval: procedure(window: TFtWidget; interval: cint32); cdecl;
  ft_window_make_current: function(window: TFtWidget): cint32; cdecl;
  ft_window_release_current: procedure(window: TFtWidget); cdecl;
  ft_window_on_gl_draw: procedure(window: TFtWidget; callback: TFtWindowGLDrawCallback; user_data: Pointer); cdecl;

  { Widget General }
  ft_widget_show: procedure(widget: TFtWidget); cdecl;
  ft_widget_hide: procedure(widget: TFtWidget); cdecl;
  ft_widget_get_visible: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_set_visible: procedure(widget: TFtWidget; visible: cint32); cdecl;
  ft_widget_is_showing: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_invalidate: procedure(widget: TFtWidget); cdecl;
  ft_window_repaint: procedure(window: TFtWidget); cdecl;
  ft_widget_set_focus: procedure(widget: TFtWidget); cdecl;
  ft_widget_has_focus: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_set_focusable: procedure(widget: TFtWidget; focusable: cint32); cdecl;
  ft_widget_get_focusable: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_set_accepts_tab: procedure(widget: TFtWidget; accepts: cint32); cdecl;
  ft_widget_get_accepts_tab: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_set_opacity: procedure(widget: TFtWidget; opacity: Double); cdecl;
  ft_widget_get_opacity: function(widget: TFtWidget): Double; cdecl;
  ft_widget_set_enabled: procedure(widget: TFtWidget; enabled: cint32); cdecl;
  ft_widget_get_enabled: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_get_parent_render_area: function(widget: TFtWidget; out x, y, w, h, radius: Double): cint32; cdecl;
  ft_widget_set_bounds: procedure(widget: TFtWidget; x, y, w, h: cint32); cdecl;
  ft_widget_get_bounds: procedure(widget: TFtWidget; out x, y, w, h: cint32); cdecl;
  ft_widget_get_x: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_get_y: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_get_width: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_get_height: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_destroy: procedure(widget: TFtWidget); cdecl;
  ft_widget_is_valid: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_on_destroy: procedure(widget: TFtWidget; callback: TFtDestroyCallback; user_data: Pointer); cdecl;

  { Micro-Flexbox Child Properties }
  ft_widget_set_flex_grow: procedure(widget: TFtWidget; grow: Double); cdecl;
  ft_widget_get_flex_grow: function(widget: TFtWidget): Double; cdecl;
  ft_widget_set_flex_shrink: procedure(widget: TFtWidget; shrink: Double); cdecl;
  ft_widget_get_flex_shrink: function(widget: TFtWidget): Double; cdecl;
  ft_widget_set_flex_basis: procedure(widget: TFtWidget; basis: Double); cdecl;
  ft_widget_get_flex_basis: function(widget: TFtWidget): Double; cdecl;
  ft_widget_set_align_self: procedure(widget: TFtWidget; align_self: cint32); cdecl;
  ft_widget_get_align_self: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_set_margin: procedure(widget: TFtWidget; left, top, right, bottom: cint32); cdecl;
  ft_widget_set_margin_all: procedure(widget: TFtWidget; margin: cint32); cdecl;
  ft_widget_set_grid_cell: procedure(widget: TFtWidget; col, row, col_span, row_span: cint32); cdecl;
  ft_widget_get_grid_col: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_get_grid_row: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_get_grid_col_span: function(widget: TFtWidget): cint32; cdecl;
  ft_widget_get_grid_row_span: function(widget: TFtWidget): cint32; cdecl;

  { Hints & Tooltips }
  ft_widget_set_hint: procedure(widget: TFtWidget; hint: PChar); cdecl;
  ft_widget_get_hint: function(widget: TFtWidget): PChar; cdecl;
  ft_widget_get_effective_hint: function(widget: TFtWidget): PChar; cdecl;
  ft_widget_set_show_hint: procedure(widget: TFtWidget; show_hint: cint32); cdecl;
  ft_widget_get_show_hint: function(widget: TFtWidget): cint32; cdecl;
  ft_set_hint_delay: procedure(delay_ms: cint32); cdecl;
  ft_get_hint_delay: function(): cint32; cdecl;

  { Buttons }
  ft_button_create: function(parent: TFtWidget; x, y, w, h: cint32; caption: PChar): TFtWidget; cdecl;
  ft_toggle_button_create: function(parent: TFtWidget; x, y, w, h: cint32; caption: PChar): TFtWidget; cdecl;
  ft_button_set_toggle: procedure(button: TFtWidget; can_toggle: cint32); cdecl;
  ft_button_get_toggle: function(button: TFtWidget): cint32; cdecl;
  ft_button_set_toggled: procedure(button: TFtWidget; toggled: cint32); cdecl;
  ft_button_get_toggled: function(button: TFtWidget): cint32; cdecl;
  ft_button_get_state: function(button: TFtWidget): cint32; cdecl;
  ft_button_on_click: procedure(button: TFtWidget; callback: TFtClickCallback; user_data: Pointer); cdecl;
  ft_button_on_hover: procedure(button: TFtWidget; callback: TFtHoverCallback; user_data: Pointer); cdecl;
  ft_button_on_press: procedure(button: TFtWidget; callback: TFtPressCallback; user_data: Pointer); cdecl;
  ft_button_on_toggle: procedure(button: TFtWidget; callback: TFtToggleCallback; user_data: Pointer); cdecl;
  ft_button_set_corner_radius: procedure(button: TFtWidget; radius: Double); cdecl;
  ft_button_get_corner_radius: function(button: TFtWidget): Double; cdecl;
  ft_button_set_shadow: procedure(button: TFtWidget; enabled: cint32); cdecl;
  ft_button_get_shadow: function(button: TFtWidget): cint32; cdecl;
  ft_button_set_caption: procedure(button: TFtWidget; caption: PChar); cdecl;
  ft_button_get_caption: function(button: TFtWidget): PChar; cdecl;
  ft_button_set_icon_file: procedure(button: TFtWidget; filepath: PChar); cdecl;
  ft_button_set_icon_svg: procedure(button: TFtWidget; svg_content: PChar); cdecl;
  ft_button_set_icon_bitmap: procedure(button: TFtWidget; bmp: TFtBitmap; owns_bitmap: cint32); cdecl;
  ft_button_get_icon_bitmap: function(button: TFtWidget): TFtBitmap; cdecl;
  ft_button_clear_icon: procedure(button: TFtWidget); cdecl;
  ft_button_set_icon_position: procedure(button: TFtWidget; position: cint32); cdecl;
  ft_button_get_icon_position: function(button: TFtWidget): cint32; cdecl;
  ft_button_set_icon_size: procedure(button: TFtWidget; width, height: cint32); cdecl;
  ft_button_get_icon_size: procedure(button: TFtWidget; out width, height: cint32); cdecl;
  ft_button_set_icon_gap: procedure(button: TFtWidget; gap: cint32); cdecl;
  ft_button_get_icon_gap: function(button: TFtWidget): cint32; cdecl;
  ft_button_on_paint_icon: procedure(button: TFtWidget; callback: TFtButtonPaintCallback; user_data: Pointer); cdecl;
  ft_button_on_paint: procedure(button: TFtWidget; callback: TFtButtonPaintCallback; user_data: Pointer); cdecl;
  ft_button_set_align: procedure(button: TFtWidget; alignment: cint32); cdecl;
  ft_button_get_align: function(button: TFtWidget): cint32; cdecl;
  ft_button_set_padding_x: procedure(button: TFtWidget; padding_x: Double); cdecl;
  ft_button_get_padding_x: function(button: TFtWidget): Double; cdecl;

  { Window Buttons }
  ft_window_button_create: function(parent: TFtWidget; x, y, w, h, kind, style: cint32): TFtWidget; cdecl;
  ft_window_button_set_kind: procedure(button: TFtWidget; kind: cint32); cdecl;
  ft_window_button_get_kind: function(button: TFtWidget): cint32; cdecl;
  ft_window_button_set_style: procedure(button: TFtWidget; style: cint32); cdecl;
  ft_window_button_get_style: function(button: TFtWidget): cint32; cdecl;
  ft_window_button_set_glyph_arm: procedure(button: TFtWidget; arm: Double); cdecl;
  ft_window_button_get_glyph_arm: function(button: TFtWidget): Double; cdecl;
  ft_window_button_on_click: procedure(button: TFtWidget; callback: TFtClickCallback; user_data: Pointer); cdecl;
  ft_window_button_on_hover: procedure(button: TFtWidget; callback: TFtHoverCallback; user_data: Pointer); cdecl;
  ft_window_button_on_press: procedure(button: TFtWidget; callback: TFtPressCallback; user_data: Pointer); cdecl;
  ft_window_button_set_transition_duration: procedure(button: TFtWidget; duration_ms: cint32); cdecl;
  ft_window_button_get_transition_duration: function(button: TFtWidget): cint32; cdecl;
  ft_window_button_get_hover_progress: function(button: TFtWidget): Double; cdecl;

  { Switch }
  ft_switch_create: function(parent: TFtWidget; x, y, w, h: cint32; caption: PChar): TFtWidget; cdecl;
  ft_switch_set_checked: procedure(switch_widget: TFtWidget; checked: cint32); cdecl;
  ft_switch_get_checked: function(switch_widget: TFtWidget): cint32; cdecl;
  ft_switch_toggle: procedure(switch_widget: TFtWidget); cdecl;
  ft_switch_set_toggled: procedure(switch_widget: TFtWidget; toggled: cint32); cdecl;
  ft_switch_get_toggled: function(switch_widget: TFtWidget): cint32; cdecl;
  ft_switch_get_state: function(switch_widget: TFtWidget): cint32; cdecl;
  ft_switch_on_toggle: procedure(switch_widget: TFtWidget; callback: TFtToggleCallback; user_data: Pointer); cdecl;
  ft_switch_on_change: procedure(switch_widget: TFtWidget; callback: TFtToggleCallback; user_data: Pointer); cdecl;
  ft_switch_on_hover: procedure(switch_widget: TFtWidget; callback: TFtHoverCallback; user_data: Pointer); cdecl;
  ft_switch_set_corner_radius: procedure(switch_widget: TFtWidget; radius: Double); cdecl;
  ft_switch_get_corner_radius: function(switch_widget: TFtWidget): Double; cdecl;
  ft_switch_set_shadow: procedure(switch_widget: TFtWidget; enabled: cint32); cdecl;
  ft_switch_get_shadow: function(switch_widget: TFtWidget): cint32; cdecl;
  ft_switch_set_caption: procedure(switch_widget: TFtWidget; caption: PChar); cdecl;
  ft_switch_get_caption: function(switch_widget: TFtWidget): PChar; cdecl;
  ft_switch_set_transition_duration: procedure(switch_widget: TFtWidget; duration_ms: cint32); cdecl;
  ft_switch_get_transition_duration: function(switch_widget: TFtWidget): cint32; cdecl;

  { Text / Label }
  ft_text_create: function(parent: TFtWidget; x, y, w, h: cint32; text: PChar): TFtWidget; cdecl;
  ft_text_set_text: procedure(text_widget: TFtWidget; text: PChar); cdecl;
  ft_text_get_text: function(text_widget: TFtWidget): PChar; cdecl;
  ft_text_set_selectable: procedure(text_widget: TFtWidget; selectable: cint32); cdecl;
  ft_text_get_selectable: function(text_widget: TFtWidget): cint32; cdecl;
  ft_text_get_selected_text: function(text_widget: TFtWidget): PChar; cdecl;
  ft_text_select_all: procedure(text_widget: TFtWidget); cdecl;
  ft_text_clear_selection: procedure(text_widget: TFtWidget); cdecl;
  ft_text_copy: procedure(text_widget: TFtWidget); cdecl;
  ft_text_set_alignment: procedure(text_widget: TFtWidget; alignment: cint32); cdecl;
  ft_text_get_alignment: function(text_widget: TFtWidget): cint32; cdecl;
  ft_text_set_color: procedure(text_widget: TFtWidget; r, g, b: Double); cdecl;
  ft_text_reset_color: procedure(text_widget: TFtWidget); cdecl;
  ft_text_set_word_wrap: procedure(text_widget: TFtWidget; word_wrap: cint32); cdecl;
  ft_text_get_word_wrap: function(text_widget: TFtWidget): cint32; cdecl;
  ft_text_set_wrap: procedure(text_widget: TFtWidget; wrap: cint32); cdecl;
  ft_text_get_wrap: function(text_widget: TFtWidget): cint32; cdecl;

  { Clipboard }
  ft_clipboard_set_text: procedure(text: PChar); cdecl;
  ft_clipboard_get_text: function(): PChar; cdecl;

  { Entry (LineEdit) }
  ft_entry_create: function(parent: TFtWidget; x, y, w, h: cint32; text: PChar): TFtWidget; cdecl;
  ft_entry_set_text: procedure(entry: TFtWidget; text: PChar); cdecl;
  ft_entry_get_text: function(entry: TFtWidget): PChar; cdecl;
  ft_entry_set_placeholder: procedure(entry: TFtWidget; placeholder: PChar); cdecl;
  ft_entry_get_placeholder: function(entry: TFtWidget): PChar; cdecl;
  ft_entry_set_readonly: procedure(entry: TFtWidget; readonly_mode: cint32); cdecl;
  ft_entry_get_readonly: function(entry: TFtWidget): cint32; cdecl;
  ft_entry_on_change: procedure(entry: TFtWidget; callback: TFtEntryChangeCallback; user_data: Pointer); cdecl;
  ft_entry_on_submit: procedure(entry: TFtWidget; callback: TFtEntrySubmitCallback; user_data: Pointer); cdecl;
  ft_entry_set_corner_radius: procedure(entry: TFtWidget; radius: Double); cdecl;

  { PathBar }
  ft_path_bar_create: function(parent: TFtWidget; x, y, w, h: cint32; initial_path: PChar): TFtWidget; cdecl;
  ft_path_bar_set_path: procedure(pathbar: TFtWidget; path: PChar); cdecl;
  ft_path_bar_get_path: function(pathbar: TFtWidget): PChar; cdecl;
  ft_path_bar_set_mode: procedure(pathbar: TFtWidget; mode: cint32); cdecl;
  ft_path_bar_get_mode: function(pathbar: TFtWidget): cint32; cdecl;
  ft_path_bar_on_navigate: procedure(pathbar: TFtWidget; callback: TFtPathBarNavigateCallback; user_data: Pointer); cdecl;
  ft_path_bar_on_mode_change: procedure(pathbar: TFtWidget; callback: TFtPathBarModeChangeCallback; user_data: Pointer); cdecl;
  ft_path_bar_get_entry: function(pathbar: TFtWidget): TFtWidget; cdecl;
  ft_path_bar_set_show_edit_button: procedure(pathbar: TFtWidget; show_button: cint32); cdecl;
  ft_path_bar_get_show_edit_button: function(pathbar: TFtWidget): cint32; cdecl;
  ft_path_bar_set_root_display_name: procedure(pathbar: TFtWidget; display_name: PChar); cdecl;
  ft_path_bar_get_root_display_name: function(pathbar: TFtWidget): PChar; cdecl;
  ft_path_bar_set_corner_radius: procedure(pathbar: TFtWidget; radius: Double); cdecl;
  ft_path_bar_get_corner_radius: function(pathbar: TFtWidget): Double; cdecl;

  { UrlEntry }
  ft_url_entry_create: function(parent: TFtWidget; x, y, w, h: cint32; initial_url: PChar): TFtWidget; cdecl;
  ft_url_entry_set_url: procedure(url_entry: TFtWidget; url: PChar); cdecl;
  ft_url_entry_get_url: function(url_entry: TFtWidget): PChar; cdecl;
  ft_url_entry_set_security_state: procedure(url_entry: TFtWidget; security_state: cint32); cdecl;
  ft_url_entry_get_security_state: function(url_entry: TFtWidget): cint32; cdecl;
  ft_url_entry_set_bookmarked: procedure(url_entry: TFtWidget; bookmarked: cint32); cdecl;
  ft_url_entry_get_bookmarked: function(url_entry: TFtWidget): cint32; cdecl;
  ft_url_entry_set_show_security_chip: procedure(url_entry: TFtWidget; show_chip: cint32); cdecl;
  ft_url_entry_get_show_security_chip: function(url_entry: TFtWidget): cint32; cdecl;
  ft_url_entry_set_show_security_badge_text: procedure(url_entry: TFtWidget; show_badge_text: cint32); cdecl;
  ft_url_entry_get_show_security_badge_text: function(url_entry: TFtWidget): cint32; cdecl;
  ft_url_entry_set_show_bookmark_button: procedure(url_entry: TFtWidget; show_button: cint32); cdecl;
  ft_url_entry_get_show_bookmark_button: function(url_entry: TFtWidget): cint32; cdecl;
  ft_url_entry_set_auto_prefix_https: procedure(url_entry: TFtWidget; auto_prefix: cint32); cdecl;
  ft_url_entry_get_auto_prefix_https: function(url_entry: TFtWidget): cint32; cdecl;
  ft_url_entry_set_corner_radius: procedure(url_entry: TFtWidget; radius: Double); cdecl;
  ft_url_entry_get_corner_radius: function(url_entry: TFtWidget): Double; cdecl;
  ft_url_entry_set_editing: procedure(url_entry: TFtWidget; editing: cint32); cdecl;
  ft_url_entry_get_editing: function(url_entry: TFtWidget): cint32; cdecl;
  ft_url_entry_on_submit: procedure(url_entry: TFtWidget; callback: TFtUrlEntrySubmitCallback; user_data: Pointer); cdecl;
  ft_url_entry_on_security_click: procedure(url_entry: TFtWidget; callback: TFtUrlEntrySecurityClickCallback; user_data: Pointer); cdecl;
  ft_url_entry_on_bookmark_click: procedure(url_entry: TFtWidget; callback: TFtUrlEntryBookmarkClickCallback; user_data: Pointer); cdecl;
  ft_url_entry_on_action_click: procedure(url_entry: TFtWidget; callback: TFtUrlEntryActionClickCallback; user_data: Pointer); cdecl;
  ft_url_entry_get_entry: function(url_entry: TFtWidget): TFtWidget; cdecl;

  { TextArea }
  ft_textarea_create: function(parent: TFtWidget; x, y, w, h: cint32; text: PChar): TFtWidget; cdecl;
  ft_textarea_set_text: procedure(textarea: TFtWidget; text: PChar); cdecl;
  ft_textarea_get_text: function(textarea: TFtWidget): PChar; cdecl;
  ft_textarea_set_placeholder: procedure(textarea: TFtWidget; placeholder: PChar); cdecl;
  ft_textarea_get_placeholder: function(textarea: TFtWidget): PChar; cdecl;
  ft_textarea_set_readonly: procedure(textarea: TFtWidget; readonly_mode: cint32); cdecl;
  ft_textarea_get_readonly: function(textarea: TFtWidget): cint32; cdecl;
  ft_textarea_on_change: procedure(textarea: TFtWidget; callback: TFtTextAreaChangeCallback; user_data: Pointer); cdecl;
  ft_textarea_set_corner_radius: procedure(textarea: TFtWidget; radius: Double); cdecl;
  ft_textarea_set_scrollbar_mode: procedure(textarea: TFtWidget; mode: cint32); cdecl;
  ft_textarea_get_scrollbar_mode: function(textarea: TFtWidget): cint32; cdecl;
  ft_textarea_get_vscrollbar: function(textarea: TFtWidget): TFtWidget; cdecl;
  ft_textarea_get_hscrollbar: function(textarea: TFtWidget): TFtWidget; cdecl;

  { ScrollBar }
  ft_scrollbar_create: function(parent: TFtWidget; x, y, w, h, orientation: cint32): TFtWidget; cdecl;
  ft_scrollbar_set_orientation: procedure(scrollbar: TFtWidget; orientation: cint32); cdecl;
  ft_scrollbar_get_orientation: function(scrollbar: TFtWidget): cint32; cdecl;
  ft_scrollbar_set_range: procedure(scrollbar: TFtWidget; min, max, page_size: Double); cdecl;
  ft_scrollbar_set_value: procedure(scrollbar: TFtWidget; value: Double); cdecl;
  ft_scrollbar_get_value: function(scrollbar: TFtWidget): Double; cdecl;
  ft_scrollbar_get_min: function(scrollbar: TFtWidget): Double; cdecl;
  ft_scrollbar_get_max: function(scrollbar: TFtWidget): Double; cdecl;
  ft_scrollbar_get_page_size: function(scrollbar: TFtWidget): Double; cdecl;
  ft_scrollbar_set_step: procedure(scrollbar: TFtWidget; step: Double); cdecl;
  ft_scrollbar_get_step: function(scrollbar: TFtWidget): Double; cdecl;
  ft_scrollbar_on_scroll: procedure(scrollbar: TFtWidget; callback: TFtScrollCallback; user_data: Pointer); cdecl;
  ft_scrollbar_set_corner_radius: procedure(scrollbar: TFtWidget; radius: Double); cdecl;

  { Container & Panel }
  ft_container_create: function(parent: TFtWidget; x, y, w, h: cint32): TFtWidget; cdecl;
  ft_panel_create: function(parent: TFtWidget; x, y, w, h: cint32): TFtWidget; cdecl;
  ft_container_set_scrollbar_mode: procedure(container: TFtWidget; mode: cint32); cdecl;
  ft_container_get_scrollbar_mode: function(container: TFtWidget): cint32; cdecl;
  ft_container_set_content_size: procedure(container: TFtWidget; width, height: Double); cdecl;
  ft_container_get_content_size: procedure(container: TFtWidget; out width, height: Double); cdecl;
  ft_container_set_scroll_pos: procedure(container: TFtWidget; scroll_x, scroll_y: Double); cdecl;
  ft_container_get_scroll_x: function(container: TFtWidget): Double; cdecl;
  ft_container_get_scroll_y: function(container: TFtWidget): Double; cdecl;
  ft_container_set_corner_radius: procedure(container: TFtWidget; radius: Double); cdecl;
  ft_container_get_corner_radius: function(container: TFtWidget): Double; cdecl;
  ft_container_set_backdrop_blur: procedure(container: TFtWidget; radius: Double); cdecl;
  ft_container_get_backdrop_blur: function(container: TFtWidget): Double; cdecl;
  ft_container_set_padding: procedure(container: TFtWidget; pad_x, pad_y: Double); cdecl;
  ft_container_set_draw_frame: procedure(container: TFtWidget; draw_frame: cint32); cdecl;
  ft_container_get_draw_frame: function(container: TFtWidget): cint32; cdecl;
  ft_container_set_draw_focus_ring: procedure(container: TFtWidget; draw_focus_ring: cint32); cdecl;
  ft_container_get_draw_focus_ring: function(container: TFtWidget): cint32; cdecl;
  ft_container_set_auto_content_size: procedure(container: TFtWidget; auto_size: cint32); cdecl;
  ft_container_get_auto_content_size: function(container: TFtWidget): cint32; cdecl;
  ft_container_get_vscrollbar: function(container: TFtWidget): TFtWidget; cdecl;
  ft_container_get_hscrollbar: function(container: TFtWidget): TFtWidget; cdecl;
  ft_container_on_scroll: procedure(container: TFtWidget; callback: TFtScrollCallback; user_data: Pointer); cdecl;
  ft_container_get_client_rect: procedure(container: TFtWidget; out x, y, w, h: Double); cdecl;
  ft_container_get_render_area: procedure(container: TFtWidget; out x, y, w, h, radius: Double); cdecl;
  ft_container_get_inner_radius: function(container: TFtWidget): Double; cdecl;
  ft_container_get_effective_corner_radius: function(container: TFtWidget): Double; cdecl;
  ft_container_update_scrollbars: procedure(container: TFtWidget); cdecl;

  { Flexbox & Layouts }
  ft_flexbox_create: function(parent: TFtWidget; x, y, w, h, direction: cint32): TFtWidget; cdecl;
  ft_hbox_create: function(parent: TFtWidget; x, y, w, h: cint32): TFtWidget; cdecl;
  ft_vbox_create: function(parent: TFtWidget; x, y, w, h: cint32): TFtWidget; cdecl;
  ft_spacer_create: function(parent: TFtWidget): TFtWidget; cdecl;
  ft_floating_bar_create: function(parent: TFtWidget; anchor_mode, width, height: cint32): TFtWidget; cdecl;
  ft_floating_bar_set_anchor: procedure(bar: TFtWidget; anchor_mode: cint32); cdecl;
  ft_floating_bar_get_anchor: function(bar: TFtWidget): cint32; cdecl;
  ft_floating_bar_set_margins: procedure(bar: TFtWidget; margin_x, margin_y: Double); cdecl;
  ft_floating_bar_get_margins: procedure(bar: TFtWidget; out margin_x, margin_y: Double); cdecl;
  ft_floating_bar_set_auto_anchor: procedure(bar: TFtWidget; auto_anchor: cint32); cdecl;
  ft_floating_bar_get_auto_anchor: function(bar: TFtWidget): cint32; cdecl;
  ft_floating_bar_update_anchor: procedure(bar: TFtWidget); cdecl;
  ft_flexbox_set_direction: procedure(flexbox: TFtWidget; direction: cint32); cdecl;
  ft_flexbox_get_direction: function(flexbox: TFtWidget): cint32; cdecl;
  ft_flexbox_set_wrap: procedure(flexbox: TFtWidget; wrap: cint32); cdecl;
  ft_flexbox_get_wrap: function(flexbox: TFtWidget): cint32; cdecl;
  ft_flexbox_set_justify_content: procedure(flexbox: TFtWidget; justify: cint32); cdecl;
  ft_flexbox_get_justify_content: function(flexbox: TFtWidget): cint32; cdecl;
  ft_flexbox_set_align_items: procedure(flexbox: TFtWidget; align: cint32); cdecl;
  ft_flexbox_get_align_items: function(flexbox: TFtWidget): cint32; cdecl;
  ft_flexbox_set_gap: procedure(flexbox: TFtWidget; gap: Double); cdecl;
  ft_flexbox_get_gap: function(flexbox: TFtWidget): Double; cdecl;
  ft_flexbox_update_layout: procedure(flexbox: TFtWidget); cdecl;
  ft_flexbox_add_splitter: function(flexbox: TFtWidget): TFtWidget; cdecl;
  ft_flex_splitter_create: function(flexbox: TFtWidget; splitter_size: Double): TFtWidget; cdecl;

  { 2D Grid & Form Grid }
  ft_grid_create: function(parent: TFtWidget; x, y, w, h: cint32): TFtWidget; cdecl;
  ft_grid_set_column_count: procedure(grid: TFtWidget; count: cint32); cdecl;
  ft_grid_set_row_count: procedure(grid: TFtWidget; count: cint32); cdecl;
  ft_grid_get_column_count: function(grid: TFtWidget): cint32; cdecl;
  ft_grid_get_row_count: function(grid: TFtWidget): cint32; cdecl;
  ft_grid_set_gaps: procedure(grid: TFtWidget; col_gap, row_gap: Double); cdecl;
  ft_grid_set_column_fixed: procedure(grid: TFtWidget; col: cint32; width: Double); cdecl;
  ft_grid_set_column_flex: procedure(grid: TFtWidget; col: cint32; weight: Double); cdecl;
  ft_grid_set_column_auto: procedure(grid: TFtWidget; col: cint32); cdecl;
  ft_grid_set_row_fixed: procedure(grid: TFtWidget; row: cint32; height: Double); cdecl;
  ft_grid_set_row_flex: procedure(grid: TFtWidget; row: cint32; weight: Double); cdecl;
  ft_grid_set_row_auto: procedure(grid: TFtWidget; row: cint32); cdecl;
  ft_grid_set_column_template: procedure(grid: TFtWidget; tmpl: PChar); cdecl;
  ft_grid_set_row_template: procedure(grid: TFtWidget; tmpl: PChar); cdecl;
  ft_grid_add_widget: procedure(grid, widget: TFtWidget; col, row, col_span, row_span: cint32); cdecl;
  ft_grid_update_layout: procedure(grid: TFtWidget); cdecl;
  ft_form_grid_create: function(parent: TFtWidget; x, y, w, h: cint32): TFtWidget; cdecl;
  ft_form_grid_add_row: function(form_grid: TFtWidget; label_text: PChar; control: TFtWidget): TFtWidget; cdecl;
  ft_form_grid_add_row_widgets: procedure(form_grid, label_widget, control_widget: TFtWidget); cdecl;
  ft_form_grid_add_spanned: procedure(form_grid, control: TFtWidget); cdecl;
  ft_form_grid_add_section: function(form_grid: TFtWidget; title: PChar): TFtWidget; cdecl;

  { Size Group }
  ft_size_group_create: function(mode: cint32): TFtSizeGroup; cdecl;
  ft_size_group_destroy: procedure(group: TFtSizeGroup); cdecl;
  ft_size_group_add_widget: procedure(group: TFtSizeGroup; widget: TFtWidget); cdecl;
  ft_size_group_remove_widget: procedure(group: TFtSizeGroup; widget: TFtWidget); cdecl;
  ft_size_group_synchronize: procedure(group: TFtSizeGroup); cdecl;

  { CheckBox }
  ft_checkbox_create: function(parent: TFtWidget; x, y, w, h: cint32; caption: PChar): TFtWidget; cdecl;
  ft_checkbox_set_checked: procedure(checkbox: TFtWidget; checked: cint32); cdecl;
  ft_checkbox_get_checked: function(checkbox: TFtWidget): cint32; cdecl;
  ft_checkbox_toggle: procedure(checkbox: TFtWidget); cdecl;
  ft_checkbox_set_caption: procedure(checkbox: TFtWidget; caption: PChar); cdecl;
  ft_checkbox_get_caption: function(checkbox: TFtWidget): PChar; cdecl;
  ft_checkbox_set_corner_radius: procedure(checkbox: TFtWidget; radius: Double); cdecl;
  ft_checkbox_get_corner_radius: function(checkbox: TFtWidget): Double; cdecl;
  ft_checkbox_on_toggle: procedure(checkbox: TFtWidget; callback: TFtCheckCallback; user_data: Pointer); cdecl;

  { RadioButton }
  ft_radio_create: function(parent: TFtWidget; x, y, w, h: cint32; caption: PChar): TFtWidget; cdecl;
  ft_radio_set_checked: procedure(radio: TFtWidget; checked: cint32); cdecl;
  ft_radio_get_checked: function(radio: TFtWidget): cint32; cdecl;
  ft_radio_set_group: procedure(radio: TFtWidget; group_id: cint32); cdecl;
  ft_radio_get_group: function(radio: TFtWidget): cint32; cdecl;
  ft_radio_set_caption: procedure(radio: TFtWidget; caption: PChar); cdecl;
  ft_radio_get_caption: function(radio: TFtWidget): PChar; cdecl;
  ft_radio_on_toggle: procedure(radio: TFtWidget; callback: TFtRadioCallback; user_data: Pointer); cdecl;

  { ComboBox }
  ft_combobox_create: function(parent: TFtWidget; x, y, w, h: cint32): TFtWidget; cdecl;
  ft_combobox_add_item: function(combobox: TFtWidget; item: PChar): cint32; cdecl;
  ft_combobox_clear: procedure(combobox: TFtWidget); cdecl;
  ft_combobox_get_item_count: function(combobox: TFtWidget): cint32; cdecl;
  ft_combobox_get_item: function(combobox: TFtWidget; index: cint32): PChar; cdecl;
  ft_combobox_set_selected: procedure(combobox: TFtWidget; index: cint32); cdecl;
  ft_combobox_get_selected: function(combobox: TFtWidget): cint32; cdecl;
  ft_combobox_get_selected_text: function(combobox: TFtWidget): PChar; cdecl;
  ft_combobox_set_text: procedure(combobox: TFtWidget; text: PChar); cdecl;
  ft_combobox_get_text: function(combobox: TFtWidget): PChar; cdecl;
  ft_combobox_set_placeholder: procedure(combobox: TFtWidget; placeholder: PChar); cdecl;
  ft_combobox_get_placeholder: function(combobox: TFtWidget): PChar; cdecl;
  ft_combobox_set_editable: procedure(combobox: TFtWidget; editable: cint32); cdecl;
  ft_combobox_get_editable: function(combobox: TFtWidget): cint32; cdecl;
  ft_combobox_set_corner_radius: procedure(combobox: TFtWidget; radius: Double); cdecl;
  ft_combobox_get_corner_radius: function(combobox: TFtWidget): Double; cdecl;
  ft_combobox_popup: procedure(combobox: TFtWidget); cdecl;
  ft_combobox_on_change: procedure(combobox: TFtWidget; callback: TFtComboChangeCallback; user_data: Pointer); cdecl;

  { Slider }
  ft_slider_create: function(parent: TFtWidget; x, y, w, h, orientation: cint32): TFtWidget; cdecl;
  ft_slider_set_orientation: procedure(slider: TFtWidget; orientation: cint32); cdecl;
  ft_slider_get_orientation: function(slider: TFtWidget): cint32; cdecl;
  ft_slider_set_range: procedure(slider: TFtWidget; min, max: Double); cdecl;
  ft_slider_get_min: function(slider: TFtWidget): Double; cdecl;
  ft_slider_get_max: function(slider: TFtWidget): Double; cdecl;
  ft_slider_set_value: procedure(slider: TFtWidget; value: Double); cdecl;
  ft_slider_get_value: function(slider: TFtWidget): Double; cdecl;
  ft_slider_set_step: procedure(slider: TFtWidget; step: Double); cdecl;
  ft_slider_get_step: function(slider: TFtWidget): Double; cdecl;
  ft_slider_set_thumb_size: procedure(slider: TFtWidget; thumb_size: Double); cdecl;
  ft_slider_get_thumb_size: function(slider: TFtWidget): Double; cdecl;
  ft_slider_on_change: procedure(slider: TFtWidget; callback: TFtSliderChangeCallback; user_data: Pointer); cdecl;

  { ProgressBar }
  ft_progressbar_create: function(parent: TFtWidget; x, y, w, h, orientation: cint32): TFtWidget; cdecl;
  ft_progressbar_set_orientation: procedure(progressbar: TFtWidget; orientation: cint32); cdecl;
  ft_progressbar_get_orientation: function(progressbar: TFtWidget): cint32; cdecl;
  ft_progressbar_set_range: procedure(progressbar: TFtWidget; min, max: Double); cdecl;
  ft_progressbar_get_min: function(progressbar: TFtWidget): Double; cdecl;
  ft_progressbar_get_max: function(progressbar: TFtWidget): Double; cdecl;
  ft_progressbar_set_value: procedure(progressbar: TFtWidget; value: Double); cdecl;
  ft_progressbar_get_value: function(progressbar: TFtWidget): Double; cdecl;
  ft_progressbar_set_indeterminate: procedure(progressbar: TFtWidget; indeterminate: cint32); cdecl;
  ft_progressbar_get_indeterminate: function(progressbar: TFtWidget): cint32; cdecl;
  ft_progressbar_set_show_text: procedure(progressbar: TFtWidget; show_text: cint32); cdecl;
  ft_progressbar_get_show_text: function(progressbar: TFtWidget): cint32; cdecl;
  ft_progressbar_set_text_format: procedure(progressbar: TFtWidget; format: PChar); cdecl;
  ft_progressbar_get_text_format: function(progressbar: TFtWidget): PChar; cdecl;
  ft_progressbar_set_corner_radius: procedure(progressbar: TFtWidget; radius: Double); cdecl;
  ft_progressbar_get_corner_radius: function(progressbar: TFtWidget): Double; cdecl;

  { Menus }
  ft_main_menu_create: function(window: TFtWidget): TFtWidget; cdecl;
  ft_main_menu_add_menu: function(main_menu: TFtWidget; caption: PChar): TFtWidget; cdecl;
  ft_main_menu_add_item: function(main_menu: TFtWidget; caption: PChar; popup_menu: TFtWidget): TFtMenuItem; cdecl;
  ft_main_menu_item_count: function(main_menu: TFtWidget): cint32; cdecl;
  ft_main_menu_get_item: function(main_menu: TFtWidget; index: cint32): TFtMenuItem; cdecl;
  ft_main_menu_close: procedure(main_menu: TFtWidget); cdecl;

  ft_popup_menu_create: function(parent: TFtWidget): TFtWidget; cdecl;
  ft_popup_menu_add_item: function(popup_menu: TFtWidget; caption: PChar; callback: TFtMenuCallback; user_data: Pointer): TFtMenuItem; cdecl;
  ft_popup_menu_add_check_item: function(popup_menu: TFtWidget; caption: PChar; checked: cint32; callback: TFtMenuCallback; user_data: Pointer): TFtMenuItem; cdecl;
  ft_popup_menu_add_separator: function(popup_menu: TFtWidget): TFtMenuItem; cdecl;
  ft_popup_menu_add_submenu: function(popup_menu: TFtWidget; caption: PChar; submenu: TFtWidget): TFtMenuItem; cdecl;
  ft_popup_menu_item_count: function(popup_menu: TFtWidget): cint32; cdecl;
  ft_popup_menu_get_item: function(popup_menu: TFtWidget; index: cint32): TFtMenuItem; cdecl;
  ft_popup_menu_show: procedure(popup_menu: TFtWidget; x, y: cint32); cdecl;
  ft_popup_menu_close: procedure(popup_menu: TFtWidget); cdecl;
  ft_popup_menu_clear: procedure(popup_menu: TFtWidget); cdecl;
  ft_popup_menu_set_corner_radius: procedure(popup_menu: TFtWidget; radius: Double); cdecl;

  ft_menu_item_set_caption: procedure(item: TFtMenuItem; caption: PChar); cdecl;
  ft_menu_item_get_caption: function(item: TFtMenuItem): PChar; cdecl;
  ft_menu_item_set_shortcut: procedure(item: TFtMenuItem; shortcut: PChar); cdecl;
  ft_menu_item_get_shortcut: function(item: TFtMenuItem): PChar; cdecl;
  ft_menu_item_set_enabled: procedure(item: TFtMenuItem; enabled: cint32); cdecl;
  ft_menu_item_get_enabled: function(item: TFtMenuItem): cint32; cdecl;
  ft_menu_item_set_checked: procedure(item: TFtMenuItem; checked: cint32); cdecl;
  ft_menu_item_get_checked: function(item: TFtMenuItem): cint32; cdecl;
  ft_menu_item_set_checkable: procedure(item: TFtMenuItem; checkable: cint32); cdecl;
  ft_menu_item_get_checkable: function(item: TFtMenuItem): cint32; cdecl;
  ft_menu_item_set_submenu: procedure(item: TFtMenuItem; submenu: TFtWidget); cdecl;
  ft_menu_item_get_submenu: function(item: TFtMenuItem): TFtWidget; cdecl;
  ft_menu_item_on_click: procedure(item: TFtMenuItem; callback: TFtMenuCallback; user_data: Pointer); cdecl;
  ft_menu_item_set_tag: procedure(item: TFtMenuItem; tag: Int64); cdecl;
  ft_menu_item_get_tag: function(item: TFtMenuItem): Int64; cdecl;

  ft_widget_set_context_menu: procedure(widget, popup_menu: TFtWidget); cdecl;
  ft_widget_get_context_menu: function(widget: TFtWidget): TFtWidget; cdecl;
  ft_window_set_context_menu: procedure(window, popup_menu: TFtWidget); cdecl;
  ft_window_get_context_menu: function(window: TFtWidget): TFtWidget; cdecl;
  ft_window_set_main_menu: procedure(window, main_menu: TFtWidget); cdecl;
  ft_window_get_main_menu: function(window: TFtWidget): TFtWidget; cdecl;

  { System & Theme }
  ft_system_font_get: function(): PChar; cdecl;
  ft_system_font_set: procedure(font_desc: PChar); cdecl;
  ft_widget_set_font: procedure(widget: TFtWidget; font_desc: PChar); cdecl;
  ft_widget_get_font: function(widget: TFtWidget): PChar; cdecl;
  ft_screen_dpi_get: function(): Double; cdecl;
  ft_screen_dpi_set: procedure(dpi: Double); cdecl;
  ft_screen_get_width: function(): cint32; cdecl;
  ft_screen_get_height: function(): cint32; cdecl;
  ft_register_event_filter: procedure(filter: TFtEventFilterFunc); cdecl;
  ft_set_tick_callback: procedure(callback: TFtTickCallback; user_data: Pointer); cdecl;
  // Optional; absent on older libft builds, so callers must check Assigned().
  ft_set_timer: procedure(interval_ms: cint32; callback: TFtTickCallback; user_data: Pointer); cdecl;
  ft_backend_get_connection: function(): Pointer; cdecl;
  ft_backend_get_screen: function(): Pointer; cdecl;
  ft_backend_get_key_symbols: function(): Pointer; cdecl;
  ft_font_gamma_get: function(): Double; cdecl;
  ft_font_gamma_set: procedure(gamma: Double); cdecl;
  ft_font_create: function(desc: PChar): Pointer; cdecl;
  ft_font_ascii_advance: function(font: Pointer; ch: cint32): Double; cdecl;
  ft_font_text_width: function(font: Pointer; text: PChar): Double; cdecl;
  ft_font_get_metrics: procedure(font: Pointer; out ascent, descent, height, maxAdvance: Double); cdecl;

  ft_theme_set: function(theme_name: PChar): cint32; cdecl;
  ft_theme_get: function(): PChar; cdecl;
  ft_theme_get_available: function(): PChar; cdecl;
  ft_theme_set_corner_radius: procedure(radius: Double); cdecl;
  ft_theme_get_corner_radius: function(): Double; cdecl;
  ft_theme_set_shadow: procedure(enabled: cint32); cdecl;
  ft_theme_get_shadow: function(): cint32; cdecl;
  ft_theme_load_file: function(filepath: PChar): cint32; cdecl;
  ft_theme_load_dir: function(dirpath: PChar): cint32; cdecl;
  ft_theme_set_dark_mode: procedure(enabled: cint32); cdecl;
  ft_theme_get_dark_mode: function(): cint32; cdecl;
  ft_theme_has_dark_mode: function(theme_name: PChar): cint32; cdecl;

  { CSS & Animation }
  ft_widget_set_style_class: procedure(widget: TFtWidget; style_class: PChar); cdecl;
  ft_widget_get_style_class: function(widget: TFtWidget): PChar; cdecl;
  ft_widget_set_style_id: procedure(widget: TFtWidget; style_id: PChar); cdecl;
  ft_widget_get_style_id: function(widget: TFtWidget): PChar; cdecl;
  ft_widget_set_style: procedure(widget: TFtWidget; inline_css: PChar); cdecl;
  ft_widget_get_style: function(widget: TFtWidget): PChar; cdecl;
  ft_style_load_css_file: function(filepath: PChar): cint32; cdecl;
  ft_style_load_css_string: function(css_string: PChar): cint32; cdecl;
  ft_animation_is_running: function(): cint32; cdecl;

  { Bitmap & Images }
  ft_bitmap_create: function(width, height: cint32): TFtBitmap; cdecl;
  ft_bitmap_load_file: function(filepath: PChar): TFtBitmap; cdecl;
  ft_bitmap_load_memory: function(data: Pointer; size: cint32): TFtBitmap; cdecl;
  ft_bitmap_create_from_rgba: function(pixels: Pointer; width, height: cint32): TFtBitmap; cdecl;
  ft_bitmap_create_from_bgra: function(pixels: Pointer; width, height: cint32): TFtBitmap; cdecl;
  ft_bitmap_get_width: function(bmp: TFtBitmap): cint32; cdecl;
  ft_bitmap_get_height: function(bmp: TFtBitmap): cint32; cdecl;
  ft_bitmap_get_stride: function(bmp: TFtBitmap): cint32; cdecl;
  ft_bitmap_get_pixels: function(bmp: TFtBitmap): Pointer; cdecl;
  ft_bitmap_create_scaled: function(bmp: TFtBitmap; new_width, new_height: cint32): TFtBitmap; cdecl;
  ft_bitmap_destroy: procedure(bmp: TFtBitmap); cdecl;
  ft_bitmap_save_to_file: procedure(bmp: TFtBitmap; filepath: PChar); cdecl;

  ft_image_create: function(parent: TFtWidget; x, y, w, h: cint32; filepath: PChar): TFtWidget; cdecl;
  ft_image_load_file: procedure(image: TFtWidget; filepath: PChar); cdecl;
  ft_image_load_memory: procedure(image: TFtWidget; data: Pointer; size: cint32); cdecl;
  ft_image_load_svg_file: procedure(image: TFtWidget; filepath: PChar); cdecl;
  ft_image_load_svg_string: procedure(image: TFtWidget; svg_content: PChar); cdecl;
  ft_image_invalidate_cache: procedure(image: TFtWidget); cdecl;
  ft_image_set_bitmap: procedure(image: TFtWidget; bmp: TFtBitmap; owns_bitmap: cint32); cdecl;
  ft_image_get_bitmap: function(image: TFtWidget): TFtBitmap; cdecl;
  ft_image_set_scale_mode: procedure(image: TFtWidget; mode: cint32); cdecl;
  ft_image_get_scale_mode: function(image: TFtWidget): cint32; cdecl;
  ft_image_set_opacity: procedure(image: TFtWidget; opacity: Double); cdecl;
  ft_image_get_opacity: function(image: TFtWidget): Double; cdecl;
  ft_bitmap_create_from_svg: function(svg_content: PChar; width, height: cint32): TFtBitmap; cdecl;
  ft_bitmap_create_from_svg_file: function(filepath: PChar; width, height: cint32): TFtBitmap; cdecl;

  { Direct Canvas Drawing }
  ft_canvas_draw_image: procedure(canvas: Pointer; x, y: Double; bmp: TFtBitmap; opacity: Double); cdecl;
  ft_canvas_draw_image_scaled: procedure(canvas: Pointer; x, y, w, h: Double; bmp: TFtBitmap; opacity: Double); cdecl;
  ft_canvas_draw_image_part: procedure(canvas: Pointer; x, y, w, h: Double; bmp: TFtBitmap; src_x, src_y, src_w, src_h: cint32; opacity: Double); cdecl;
  ft_canvas_draw_svg: procedure(canvas: Pointer; x, y, w, h: Double; svg_content: PChar); cdecl;
  ft_canvas_draw_svg_file: procedure(canvas: Pointer; x, y, w, h: Double; filepath: PChar); cdecl;
  ft_canvas_push_alpha: procedure(canvas: Pointer; alpha: Double); cdecl;
  ft_canvas_pop_alpha: procedure(canvas: Pointer); cdecl;
  ft_canvas_reset_alpha: procedure(canvas: Pointer); cdecl;
  ft_canvas_get_alpha: function(canvas: Pointer): Double; cdecl;
  ft_canvas_draw_rect: procedure(canvas: Pointer; x, y, w, h: cint32; r, g, b, a: Double); cdecl;
  ft_canvas_draw_rounded_rect: procedure(canvas: Pointer; x, y, w, h, radius, r, g, b, a: Double); cdecl;
  ft_canvas_draw_rounded_rect_outline: procedure(canvas: Pointer; x, y, w, h, radius, border_width, r, g, b, a: Double); cdecl;
  ft_canvas_draw_line: procedure(canvas: Pointer; x1, y1, x2, y2, width, r, g, b, a: Double); cdecl;
  ft_canvas_draw_circle: procedure(canvas: Pointer; cx, cy, radius, r, g, b, a: Double); cdecl;
  ft_canvas_draw_text: procedure(canvas: Pointer; x, y: Double; text: PChar; font: Pointer; r, g, b: Double); cdecl;
  ft_canvas_draw_text_left: procedure(canvas: Pointer; x, y, w, h: Double; text: PChar; font: Pointer; r, g, b: Double); cdecl;
  ft_canvas_draw_text_centered: procedure(canvas: Pointer; x, y, w, h: cint32; text: PChar; font: Pointer; r, g, b: Double); cdecl;
  ft_canvas_push_clip_rect: procedure(canvas: Pointer; x, y, w, h: cint32); cdecl;
  ft_canvas_pop_clip_rect: procedure(canvas: Pointer); cdecl;
  ft_canvas_push_clip_rounded_rect: procedure(canvas: Pointer; x, y, w, h, radius: Double); cdecl;
  ft_canvas_pop_clip_rounded_rect: procedure(canvas: Pointer); cdecl;
  ft_canvas_reset_clipping: procedure(canvas: Pointer); cdecl;

  { Notebook & Tabs }
  ft_notebook_create: function(parent: TFtWidget; x, y, w, h: cint32): TFtNotebook; cdecl;
  ft_notebook_add_tab: function(notebook: TFtNotebook; title: PChar; closeable: cint32): TFtTabPage; cdecl;
  ft_notebook_remove_tab: procedure(notebook: TFtNotebook; index: cint32); cdecl;
  ft_notebook_clear_tabs: procedure(notebook: TFtNotebook); cdecl;
  ft_notebook_get_page_count: function(notebook: TFtNotebook): cint32; cdecl;
  ft_notebook_get_page: function(notebook: TFtNotebook; index: cint32): TFtTabPage; cdecl;
  ft_notebook_set_active_index: procedure(notebook: TFtNotebook; index: cint32); cdecl;
  ft_notebook_get_active_index: function(notebook: TFtNotebook): cint32; cdecl;
  ft_notebook_set_tab_height: procedure(notebook: TFtNotebook; height: Double); cdecl;
  ft_notebook_get_tab_height: function(notebook: TFtNotebook): Double; cdecl;
  ft_notebook_on_tab_change: procedure(notebook: TFtNotebook; callback: TFtTabChangeCallback; user_data: Pointer); cdecl;
  ft_notebook_set_max_tab_width: procedure(notebook: TFtNotebook; width: Double); cdecl;
  ft_notebook_get_max_tab_width: function(notebook: TFtNotebook): Double; cdecl;
  ft_notebook_set_min_tab_width: procedure(notebook: TFtNotebook; width: Double); cdecl;
  ft_notebook_get_min_tab_width: function(notebook: TFtNotebook): Double; cdecl;
  ft_notebook_set_scroll_offset: procedure(notebook: TFtNotebook; offset: Double); cdecl;
  ft_notebook_get_scroll_offset: function(notebook: TFtNotebook): Double; cdecl;
  ft_notebook_ensure_tab_visible: procedure(notebook: TFtNotebook; index: cint32); cdecl;
  ft_tab_page_set_title: procedure(page: TFtTabPage; title: PChar); cdecl;
  ft_tab_page_get_title: function(page: TFtTabPage): PChar; cdecl;
  ft_tab_page_set_closeable: procedure(page: TFtTabPage; closeable: cint32); cdecl;
  ft_tab_page_get_closeable: function(page: TFtTabPage): cint32; cdecl;
  ft_tab_page_set_icon: procedure(page: TFtTabPage; icon: TFtBitmap); cdecl;
  ft_tab_page_get_icon: function(page: TFtTabPage): TFtBitmap; cdecl;

  { Splitter }
  ft_splitter_create: function(parent: TFtWidget; x, y, w, h, orientation: cint32): TFtSplitter; cdecl;
  ft_splitter_set_panes: procedure(splitter: TFtSplitter; pane1, pane2: TFtWidget); cdecl;
  ft_splitter_get_pane1: function(splitter: TFtSplitter): TFtWidget; cdecl;
  ft_splitter_get_pane2: function(splitter: TFtSplitter): TFtWidget; cdecl;
  ft_splitter_set_orientation: procedure(splitter: TFtSplitter; orientation: cint32); cdecl;
  ft_splitter_get_orientation: function(splitter: TFtSplitter): cint32; cdecl;
  ft_splitter_set_pos: procedure(splitter: TFtSplitter; pos: Double); cdecl;
  ft_splitter_get_pos: function(splitter: TFtSplitter): Double; cdecl;
  ft_splitter_set_ratio: procedure(splitter: TFtSplitter; ratio: Double); cdecl;
  ft_splitter_set_splitter_size: procedure(splitter: TFtSplitter; size: Double); cdecl;
  ft_splitter_get_splitter_size: function(splitter: TFtSplitter): Double; cdecl;
  ft_splitter_set_min_sizes: procedure(splitter: TFtSplitter; min_pane1, min_pane2: Double); cdecl;
  ft_splitter_get_min_pane1_size: function(splitter: TFtSplitter): Double; cdecl;
  ft_splitter_get_min_pane2_size: function(splitter: TFtSplitter): Double; cdecl;
  ft_splitter_on_position_change: procedure(splitter: TFtSplitter; callback: TFtSplitterPositionCallback; user_data: Pointer); cdecl;

  { TreeView }
  ft_treeview_create: function(parent: TFtWidget; x, y, w, h: cint32): TFtTreeView; cdecl;
  ft_treeview_add_node: function(treeview: TFtTreeView; text: PChar; parent_node: TFtTreeNode): TFtTreeNode; cdecl;
  ft_treeview_clear: procedure(treeview: TFtTreeView); cdecl;
  ft_treeview_get_root: function(treeview: TFtTreeView): TFtTreeNode; cdecl;
  ft_treeview_get_selected_node: function(treeview: TFtTreeView): TFtTreeNode; cdecl;
  ft_treeview_set_selected_node: procedure(treeview: TFtTreeView; node: TFtTreeNode); cdecl;
  ft_treeview_set_item_height: procedure(treeview: TFtTreeView; height: Double); cdecl;
  ft_treeview_get_item_height: function(treeview: TFtTreeView): Double; cdecl;
  ft_treeview_set_indent_width: procedure(treeview: TFtTreeView; width: Double); cdecl;
  ft_treeview_get_indent_width: function(treeview: TFtTreeView): Double; cdecl;
  ft_treeview_on_select: procedure(treeview: TFtTreeView; callback: TFtTreeNodeSelectCallback; user_data: Pointer); cdecl;
  ft_treenode_add_child: function(node: TFtTreeNode; text: PChar): TFtTreeNode; cdecl;
  ft_treenode_delete_child: procedure(node: TFtTreeNode; index: cint32); cdecl;
  ft_treenode_get_child_count: function(node: TFtTreeNode): cint32; cdecl;
  ft_treenode_get_child: function(node: TFtTreeNode; index: cint32): TFtTreeNode; cdecl;
  ft_treenode_get_parent: function(node: TFtTreeNode): TFtTreeNode; cdecl;
  ft_treenode_set_text: procedure(node: TFtTreeNode; text: PChar); cdecl;
  ft_treenode_get_text: function(node: TFtTreeNode): PChar; cdecl;
  ft_treenode_set_expanded: procedure(node: TFtTreeNode; expanded: cint32); cdecl;
  ft_treenode_get_expanded: function(node: TFtTreeNode): cint32; cdecl;
  ft_treenode_set_icon: procedure(node: TFtTreeNode; icon: TFtBitmap); cdecl;
  ft_treenode_get_icon: function(node: TFtTreeNode): TFtBitmap; cdecl;
  ft_treenode_set_data: procedure(node: TFtTreeNode; data: Pointer); cdecl;
  ft_treenode_get_data: function(node: TFtTreeNode): Pointer; cdecl;
  ft_treenode_set_tag: procedure(node: TFtTreeNode; tag: cint32); cdecl;
  ft_treenode_get_tag: function(node: TFtTreeNode): cint32; cdecl;

  { Table / DataGrid }
  ft_table_create: function(parent: TFtWidget; x, y, w, h: cint32): TFtTable; cdecl;
  ft_table_add_column: function(table: TFtTable; title: PChar; width: Double; alignment: cint32): cint32; cdecl;
  ft_table_get_column_count: function(table: TFtTable): cint32; cdecl;
  ft_table_set_column_title: procedure(table: TFtTable; col_idx: cint32; title: PChar); cdecl;
  ft_table_get_column_title: function(table: TFtTable; col_idx: cint32): PChar; cdecl;
  ft_table_set_column_width: procedure(table: TFtTable; col_idx: cint32; width: Double); cdecl;
  ft_table_get_column_width: function(table: TFtTable; col_idx: cint32): Double; cdecl;
  ft_table_set_column_align: procedure(table: TFtTable; col_idx, alignment: cint32); cdecl;
  ft_table_get_column_align: function(table: TFtTable; col_idx: cint32): cint32; cdecl;
  ft_table_set_column_icon: procedure(table: TFtTable; col_idx: cint32; icon: TFtBitmap); cdecl;
  ft_table_get_column_icon: function(table: TFtTable; col_idx: cint32): TFtBitmap; cdecl;
  ft_table_add_row: function(table: TFtTable): cint32; cdecl;
  ft_table_delete_row: procedure(table: TFtTable; row_idx: cint32); cdecl;
  ft_table_clear_rows: procedure(table: TFtTable); cdecl;
  ft_table_clear_all: procedure(table: TFtTable); cdecl;
  ft_table_get_row_count: function(table: TFtTable): cint32; cdecl;
  ft_table_set_cell: procedure(table: TFtTable; row, col: cint32; value: PChar); cdecl;
  ft_table_get_cell: function(table: TFtTable; row, col: cint32): PChar; cdecl;
  ft_table_set_cell_icon: procedure(table: TFtTable; row, col: cint32; icon: TFtBitmap); cdecl;
  ft_table_get_cell_icon: function(table: TFtTable; row, col: cint32): TFtBitmap; cdecl;
  ft_table_set_selected_row: procedure(table: TFtTable; row: cint32); cdecl;
  ft_table_get_selected_row: function(table: TFtTable): cint32; cdecl;
  ft_table_set_multi_select: procedure(table: TFtTable; enabled: cint32); cdecl;
  ft_table_get_multi_select: function(table: TFtTable): cint32; cdecl;
  ft_table_is_row_selected: function(table: TFtTable; row_idx: cint32): cint32; cdecl;
  ft_table_set_row_selected: procedure(table: TFtTable; row_idx, selected: cint32); cdecl;
  ft_table_select_all: procedure(table: TFtTable); cdecl;
  ft_table_clear_selection: procedure(table: TFtTable); cdecl;
  ft_table_get_selected_row_count: function(table: TFtTable): cint32; cdecl;
  ft_table_get_selected_rows: function(table: TFtTable; out_indices: pcint32; max_count: cint32): cint32; cdecl;
  ft_table_set_header_height: procedure(table: TFtTable; height: Double); cdecl;
  ft_table_get_header_height: function(table: TFtTable): Double; cdecl;
  ft_table_set_row_height: procedure(table: TFtTable; height: Double); cdecl;
  ft_table_get_row_height: function(table: TFtTable): Double; cdecl;
  ft_table_set_show_gridlines: procedure(table: TFtTable; show: cint32); cdecl;
  ft_table_get_show_gridlines: function(table: TFtTable): cint32; cdecl;
  ft_table_set_zebra_striping: procedure(table: TFtTable; enabled: cint32); cdecl;
  ft_table_get_zebra_striping: function(table: TFtTable): cint32; cdecl;
  ft_table_on_select_row: procedure(table: TFtTable; callback: TFtTableRowSelectCallback; user_data: Pointer); cdecl;
  ft_table_on_row_double_click: procedure(table: TFtTable; callback: TFtTableRowDoubleClickCallback; user_data: Pointer); cdecl;
  ft_table_on_draw_header: procedure(table: TFtTable; callback: TFtTableDrawHeaderCallback; user_data: Pointer); cdecl;
  ft_table_on_draw_cell: procedure(table: TFtTable; callback: TFtTableDrawCellCallback; user_data: Pointer); cdecl;

  { File Dialogs }
  ft_file_dialog_create: function(dialog_type: cint32): TFtFileDialog; cdecl;
  ft_file_dialog_set_directory: procedure(dlg: TFtFileDialog; dir: PChar); cdecl;
  ft_file_dialog_get_directory: function(dlg: TFtFileDialog): PChar; cdecl;
  ft_file_dialog_set_default_name: procedure(dlg: TFtFileDialog; name: PChar); cdecl;
  ft_file_dialog_set_filter: procedure(dlg: TFtFileDialog; filter: PChar); cdecl;
  ft_file_dialog_set_show_hidden: procedure(dlg: TFtFileDialog; show_hidden: cint32); cdecl;
  ft_file_dialog_show_modal: function(dlg: TFtFileDialog): cint32; cdecl;
  ft_file_dialog_get_selected_path: function(dlg: TFtFileDialog): PChar; cdecl;
  ft_file_dialog_destroy: procedure(dlg: TFtFileDialog); cdecl;
  ft_dialog_open_file: function(title, default_dir, filter: PChar): PChar; cdecl;
  ft_dialog_save_file: function(title, default_dir, default_name, filter: PChar): PChar; cdecl;
  ft_dialog_select_folder: function(title, default_dir: PChar): PChar; cdecl;

  { Message Dialogs }
  ft_message_dialog_create: function(title, instruction, message: PChar; dialog_type, buttons_type: cint32): TFtMessageDialog; cdecl;
  ft_message_dialog_set_details: procedure(dlg: TFtMessageDialog; details: PChar); cdecl;
  ft_message_dialog_set_verification_text: procedure(dlg: TFtMessageDialog; text: PChar); cdecl;
  ft_message_dialog_set_verification_checked: procedure(dlg: TFtMessageDialog; checked: cint32); cdecl;
  ft_message_dialog_get_verification_checked: function(dlg: TFtMessageDialog): cint32; cdecl;
  ft_message_dialog_set_custom_icon_svg: procedure(dlg: TFtMessageDialog; svg: PChar); cdecl;
  ft_message_dialog_add_button: procedure(dlg: TFtMessageDialog; caption: PChar; modal_result, is_default, is_destructive: cint32); cdecl;
  ft_message_dialog_clear_buttons: procedure(dlg: TFtMessageDialog); cdecl;
  ft_message_dialog_show_modal: function(dlg: TFtMessageDialog): cint32; cdecl;
  ft_message_dialog_destroy: procedure(dlg: TFtMessageDialog); cdecl;
  ft_show_message: function(message, title: PChar): cint32; cdecl;
  ft_show_info: function(title, instruction, message: PChar): cint32; cdecl;
  ft_show_warning: function(title, instruction, message: PChar): cint32; cdecl;
  ft_show_error: function(title, instruction, message, details: PChar): cint32; cdecl;
  ft_confirm: function(title, instruction, message: PChar): cint32; cdecl;
  ft_confirm_with_verification: function(title, instruction, message, verification_text: PChar; out_verified: pcint32): cint32; cdecl;

  { Drawing Area }
  ft_drawingarea_create: function(parent: TFtWidget; x, y, w, h: cint32): TFtWidget; cdecl;
  ft_drawingarea_set_cursor: procedure(area: TFtWidget; cursor_type: cint32); cdecl;
  ft_drawingarea_get_cursor: function(area: TFtWidget): cint32; cdecl;
  ft_drawingarea_set_clip_to_bounds: procedure(area: TFtWidget; clip: cint32); cdecl;
  ft_drawingarea_on_paint: procedure(area: TFtWidget; callback: TFtDrawingPaintCallback; user_data: Pointer); cdecl;
  ft_drawingarea_on_mouse_down: procedure(area: TFtWidget; callback: TFtDrawingMouseEvent; user_data: Pointer); cdecl;
  ft_drawingarea_on_mouse_up: procedure(area: TFtWidget; callback: TFtDrawingMouseEvent; user_data: Pointer); cdecl;
  ft_drawingarea_on_mouse_move: procedure(area: TFtWidget; callback: TFtDrawingMouseMoveEvent; user_data: Pointer); cdecl;
  ft_drawingarea_on_mouse_wheel: procedure(area: TFtWidget; callback: TFtDrawingWheelEvent; user_data: Pointer); cdecl;
  ft_drawingarea_on_mouse_enter: procedure(area: TFtWidget; callback: TFtDrawingMouseMoveEvent; user_data: Pointer); cdecl;
  ft_drawingarea_on_mouse_leave: procedure(area: TFtWidget; callback: TFtDrawingMouseMoveEvent; user_data: Pointer); cdecl;
  ft_drawingarea_on_key_down: procedure(area: TFtWidget; callback: TFtDrawingKeyEvent; user_data: Pointer); cdecl;
  ft_drawingarea_on_key_up: procedure(area: TFtWidget; callback: TFtDrawingKeyEvent; user_data: Pointer); cdecl;
  ft_drawingarea_on_resize: procedure(area: TFtWidget; callback: TFtDrawingResizeEvent; user_data: Pointer); cdecl;

  { Ruler }
  ft_ruler_create: function(parent: TFtWidget; orientation, x, y, w, h: cint32): TFtWidget; cdecl;
  ft_ruler_set_origin_and_scale: procedure(ruler: TFtWidget; origin, scale: Double); cdecl;
  ft_ruler_set_pointer_position: procedure(ruler: TFtWidget; pos: Double); cdecl;
  ft_ruler_set_unit: procedure(ruler: TFtWidget; unit_kind: cint32); cdecl;
  ft_ruler_get_unit: function(ruler: TFtWidget): cint32; cdecl;
  ft_ruler_set_show_pointer: procedure(ruler: TFtWidget; show: cint32); cdecl;
  ft_ruler_set_thickness: procedure(ruler: TFtWidget; thickness: cint32); cdecl;
  ft_ruler_on_create_guide: procedure(ruler: TFtWidget; callback: TFtRulerGuideEvent; user_data: Pointer); cdecl;

  { Number Scrubber }
  ft_numberscrubber_create: function(parent: TFtWidget; x, y, w, h: cint32; label_text: PChar): TFtWidget; cdecl;
  ft_numberscrubber_set_value: procedure(scrubber: TFtWidget; value: Double); cdecl;
  ft_numberscrubber_get_value: function(scrubber: TFtWidget): Double; cdecl;
  ft_numberscrubber_set_range: procedure(scrubber: TFtWidget; min_val, max_val: Double); cdecl;
  ft_numberscrubber_set_step: procedure(scrubber: TFtWidget; step: Double); cdecl;
  ft_numberscrubber_set_decimals: procedure(scrubber: TFtWidget; decimals: cint32); cdecl;
  ft_numberscrubber_set_suffix: procedure(scrubber: TFtWidget; suffix: PChar); cdecl;
  ft_numberscrubber_set_prefix: procedure(scrubber: TFtWidget; prefix: PChar); cdecl;
  ft_numberscrubber_on_change: procedure(scrubber: TFtWidget; callback: TFtScrubberChangeEvent; user_data: Pointer); cdecl;

  { 2D Camera }
  ft_camera2d_create: function(min_zoom, max_zoom: Double): TFtCamera2D; cdecl;
  ft_camera2d_destroy: procedure(camera: TFtCamera2D); cdecl;
  ft_camera2d_reset: procedure(camera: TFtCamera2D); cdecl;
  ft_camera2d_world_to_screen: procedure(camera: TFtCamera2D; wx, wy: Double; out out_sx, out_sy: Double); cdecl;
  ft_camera2d_screen_to_world: procedure(camera: TFtCamera2D; sx, sy: Double; out out_wx, out_wy: Double); cdecl;
  ft_camera2d_zoom_at: procedure(camera: TFtCamera2D; pivot_sx, pivot_sy, delta_factor: Double); cdecl;
  ft_camera2d_set_zoom_at: procedure(camera: TFtCamera2D; pivot_sx, pivot_sy, new_zoom: Double); cdecl;
  ft_camera2d_pan_by: procedure(camera: TFtCamera2D; delta_sx, delta_sy: Double); cdecl;
  ft_camera2d_fit_rect: procedure(camera: TFtCamera2D; wx, wy, ww, wh, view_w, view_h, margin: Double); cdecl;
  ft_camera2d_get_zoom: function(camera: TFtCamera2D): Double; cdecl;
  ft_camera2d_set_zoom: procedure(camera: TFtCamera2D; zoom: Double); cdecl;
  ft_camera2d_get_pan: procedure(camera: TFtCamera2D; out out_pan_x, out_pan_y: Double); cdecl;
  ft_camera2d_set_pan: procedure(camera: TFtCamera2D; pan_x, pan_y: Double); cdecl;
  ft_camera2d_get_rotation: function(camera: TFtCamera2D): Double; cdecl;
  ft_camera2d_set_rotation: procedure(camera: TFtCamera2D; deg: Double); cdecl;

  { Icons }
  ft_icon_get_svg: function(name: PChar; dark_mode: cint32): PChar; cdecl;
  ft_icon_get_bitmap: function(name: PChar; width, height, dark_mode: cint32): TFtBitmap; cdecl;
  ft_icon_register: procedure(name, svg_light, svg_dark: PChar); cdecl;
  ft_icon_has: function(name: PChar): cint32; cdecl;
  ft_icon_set_monochrome_colors: procedure(light_color, dark_color: PChar); cdecl;

  { GPU Core & Batching }
  ft_gpu_is_available: function(): cint32; cdecl;
  ft_window_set_direct_gpu_mode: procedure(window: TFtWidget; direct_gpu: cint32); cdecl;
  ft_window_on_mouse_down: procedure(window: TFtWidget; callback: TFtWindowMouseCallback; user_data: Pointer); cdecl;
  ft_window_on_mouse_up: procedure(window: TFtWidget; callback: TFtWindowMouseCallback; user_data: Pointer); cdecl;
  ft_window_on_mouse_move: procedure(window: TFtWidget; callback: TFtWindowMouseMoveCallback; user_data: Pointer); cdecl;
  ft_window_on_key: procedure(window: TFtWidget; callback: TFtWindowKeyCallback; user_data: Pointer); cdecl;
  ft_window_on_resize: procedure(window: TFtWidget; callback: TFtWindowResizeCallback; user_data: Pointer); cdecl;
  ft_window_on_close: procedure(window: TFtWidget; callback: TFtWindowCloseCallback; user_data: Pointer); cdecl;
  ft_batch_create: function(): TFtRenderBatch; cdecl;
  ft_batch_destroy: procedure(batch: TFtRenderBatch); cdecl;
  ft_batch_clear: procedure(batch: TFtRenderBatch); cdecl;
  ft_batch_get_stats: procedure(batch: TFtRenderBatch; stats: PFtBatchStats); cdecl;
  ft_batch_emit_rect: procedure(batch: TFtRenderBatch; x, y, w, h: Single; color: Cardinal; blend_mode: cint32); cdecl;
  ft_batch_emit_textured_rect: procedure(batch: TFtRenderBatch; x, y, w, h, u0, v0, u1, v1: Single; tex_id: Cardinal; opacity: Single; blend_mode: cint32); cdecl;
  ft_batch_emit_rounded_rect: procedure(batch: TFtRenderBatch; x, y, w, h, radius: Single; fill_color, border_color: Cardinal; border_width: Single; blend_mode: cint32); cdecl;
  ft_batch_emit_box_shadow: procedure(batch: TFtRenderBatch; x, y, w, h, radius, offset_x, offset_y, blur_radius, spread: Single; shadow_color: Cardinal; blend_mode: cint32); cdecl;
  ft_batch_emit_linear_gradient: procedure(batch: TFtRenderBatch; x, y, w, h: Single; color_start, color_end: Cardinal; angle_deg: Single; blend_mode: cint32); cdecl;
  ft_batch_emit_path_mesh: procedure(batch: TFtRenderBatch; mesh: TFtTessMesh; color: Cardinal; blend_mode: cint32); cdecl;
  ft_tessmesh_create: function(): TFtTessMesh; cdecl;
  ft_tessmesh_destroy: procedure(mesh: TFtTessMesh); cdecl;
  ft_tessmesh_clear: procedure(mesh: TFtTessMesh); cdecl;
  ft_tessmesh_get_counts: procedure(mesh: TFtTessMesh; out vertex_count, index_count: cint32); cdecl;
  ft_tessellator_create: function(): TFtGPUTessellator; cdecl;
  ft_tessellator_destroy: procedure(tess: TFtGPUTessellator); cdecl;
  ft_tessellator_stroke_polyline: procedure(tess: TFtGPUTessellator; mesh: TFtTessMesh; points: PFtPoint2D; count, closed: cint32; stroke_width: Single; join_style, cap_style: cint32; miter_limit: Single; aa_fringe: cint32); cdecl;
  ft_tessellator_stroke_bezier: procedure(tess: TFtGPUTessellator; mesh: TFtTessMesh; p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y: Single; stroke_width: Single; join_style, cap_style: cint32; miter_limit: Single; aa_fringe: cint32); cdecl;
  ft_tessellator_fill_polygon: procedure(tess: TFtGPUTessellator; mesh: TFtTessMesh; points: PFtPoint2D; count: cint32; aa_fringe: cint32); cdecl;
  ft_renderer_create: function(): TFtGPURenderer; cdecl;
  ft_renderer_destroy: procedure(renderer: TFtGPURenderer); cdecl;
  ft_renderer_begin: procedure(renderer: TFtGPURenderer; viewport_w, viewport_h: cint32); cdecl;
  ft_renderer_end: procedure(renderer: TFtGPURenderer); cdecl;
  ft_renderer_get_batch: function(renderer: TFtGPURenderer): TFtRenderBatch; cdecl;
  ft_renderer_get_tessellator: function(renderer: TFtGPURenderer): TFtGPUTessellator; cdecl;

{ Dynamic Library Loader Utilities }
function  FtLoadLib(const ALibPath: string = ''): Boolean;
procedure FtUnloadLib();
function  FtIsLibLoaded(): Boolean;

implementation

var
  gLibHandle: TLibHandle = NilHandle;

function FtIsLibLoaded(): Boolean;
begin
  Result := (gLibHandle <> NilHandle);
end;

procedure FtUnloadLib();
begin
  if gLibHandle <> NilHandle then
  begin
    UnloadLibrary(gLibHandle);
    gLibHandle := NilHandle;
  end;
end;

function BindFunc(const AName: string): Pointer;
begin
  Result := GetProcedureAddress(gLibHandle, AName);
  if Result = nil then
    Result := GetProcedureAddress(gLibHandle, PChar(AName));
end;

function FtLoadLib(const ALibPath: string = ''): Boolean;
var
  candidates: array of string;
  candidate: string;
  envPath: string;
  appDir: string;
begin
  if FtIsLibLoaded() then
    Exit(True);

  appDir := ExtractFilePath(ParamStr(0));
  envPath := GetEnvironmentVariable('LIBFT_PATH');

  SetLength(candidates, 0);

  if ALibPath <> '' then
  begin
    SetLength(candidates, Length(candidates) + 1);
    candidates[High(candidates)] := ALibPath;
  end;

  if envPath <> '' then
  begin
    SetLength(candidates, Length(candidates) + 1);
    candidates[High(candidates)] := envPath;
  end;

  SetLength(candidates, Length(candidates) + 8);
  candidates[Length(candidates) - 8] := './target/' + FT_LIB_NAME;
  candidates[Length(candidates) - 7] := './' + FT_LIB_NAME;
  candidates[Length(candidates) - 6] := appDir + 'target/' + FT_LIB_NAME;
  candidates[Length(candidates) - 5] := appDir + FT_LIB_NAME;
  candidates[Length(candidates) - 4] := '../floria-toolkit/target/' + FT_LIB_NAME;
  candidates[Length(candidates) - 3] := '../../floria-toolkit/target/' + FT_LIB_NAME;
  candidates[Length(candidates) - 2] := '/usr/local/lib/' + FT_LIB_NAME;
  candidates[Length(candidates) - 1] := FT_LIB_NAME;

  for candidate in candidates do
  begin
    if (candidate = FT_LIB_NAME) or FileExists(candidate) then
    begin
      gLibHandle := LoadLibrary(candidate);
      if gLibHandle <> NilHandle then
        Break;
    end;
  end;

  if gLibHandle = NilHandle then
    Exit(False);

  { Bind Core Lifecycle }
  Pointer(ft_init) := BindFunc('ft_init');
  Pointer(ft_main_loop) := BindFunc('ft_main_loop');
  Pointer(ft_quit) := BindFunc('ft_quit');

  { Bind Window Management }
  Pointer(ft_window_create) := BindFunc('ft_window_create');
  Pointer(ft_window_set_title) := BindFunc('ft_window_set_title');
  Pointer(ft_window_set_borderless) := BindFunc('ft_window_set_borderless');
  Pointer(ft_window_get_borderless) := BindFunc('ft_window_get_borderless');
  Pointer(ft_window_set_skip_taskbar) := BindFunc('ft_window_set_skip_taskbar');
  Pointer(ft_window_get_skip_taskbar) := BindFunc('ft_window_get_skip_taskbar');
  Pointer(ft_window_set_window_type) := BindFunc('ft_window_set_window_type');
  Pointer(ft_window_get_window_type) := BindFunc('ft_window_get_window_type');
  Pointer(ft_window_set_position) := BindFunc('ft_window_set_position');
  Pointer(ft_window_get_position) := BindFunc('ft_window_get_position');
  Pointer(ft_window_set_opacity) := BindFunc('ft_window_set_opacity');
  Pointer(ft_window_get_opacity) := BindFunc('ft_window_get_opacity');
  Pointer(ft_window_set_background_opacity) := BindFunc('ft_window_set_background_opacity');
  Pointer(ft_window_get_background_opacity) := BindFunc('ft_window_get_background_opacity');
  Pointer(ft_window_set_background_blur) := BindFunc('ft_window_set_background_blur');
  Pointer(ft_window_get_background_blur) := BindFunc('ft_window_get_background_blur');
  Pointer(ft_window_set_strut_partial) := BindFunc('ft_window_set_strut_partial');
  Pointer(ft_window_show_modal) := BindFunc('ft_window_show_modal');
  Pointer(ft_window_bring_to_front) := BindFunc('ft_window_bring_to_front');
  Pointer(ft_window_grab_input) := BindFunc('ft_window_grab_input');
  Pointer(ft_window_ungrab_input) := BindFunc('ft_window_ungrab_input');
  Pointer(ft_window_get_native_handle) := BindFunc('ft_window_get_native_handle');
  Pointer(ft_window_set_layout) := BindFunc('ft_window_set_layout');

  { Bind Hardware Acceleration & EGL }
  Pointer(ft_egl_is_available) := BindFunc('ft_egl_is_available');
  Pointer(ft_backend_enable_egl) := BindFunc('ft_backend_enable_egl');
  Pointer(ft_backend_is_egl_enabled) := BindFunc('ft_backend_is_egl_enabled');
  Pointer(ft_egl_window_create) := BindFunc('ft_egl_window_create');
  Pointer(ft_window_is_hardware_accelerated) := BindFunc('ft_window_is_hardware_accelerated');
  Pointer(ft_window_set_hardware_accelerated) := BindFunc('ft_window_set_hardware_accelerated');
  Pointer(ft_window_set_swap_interval) := BindFunc('ft_window_set_swap_interval');
  Pointer(ft_window_make_current) := BindFunc('ft_window_make_current');
  Pointer(ft_window_release_current) := BindFunc('ft_window_release_current');
  Pointer(ft_window_on_gl_draw) := BindFunc('ft_window_on_gl_draw');

  { Bind Widget General }
  Pointer(ft_widget_show) := BindFunc('ft_widget_show');
  Pointer(ft_widget_hide) := BindFunc('ft_widget_hide');
  Pointer(ft_widget_get_visible) := BindFunc('ft_widget_get_visible');
  Pointer(ft_widget_set_visible) := BindFunc('ft_widget_set_visible');
  Pointer(ft_widget_is_showing) := BindFunc('ft_widget_is_showing');
  Pointer(ft_widget_invalidate) := BindFunc('ft_widget_invalidate');
  Pointer(ft_window_repaint) := BindFunc('ft_window_repaint');
  Pointer(ft_widget_set_focus) := BindFunc('ft_widget_set_focus');
  Pointer(ft_widget_has_focus) := BindFunc('ft_widget_has_focus');
  Pointer(ft_widget_set_focusable) := BindFunc('ft_widget_set_focusable');
  Pointer(ft_widget_get_focusable) := BindFunc('ft_widget_get_focusable');
  Pointer(ft_widget_set_accepts_tab) := BindFunc('ft_widget_set_accepts_tab');
  Pointer(ft_widget_get_accepts_tab) := BindFunc('ft_widget_get_accepts_tab');
  Pointer(ft_widget_set_opacity) := BindFunc('ft_widget_set_opacity');
  Pointer(ft_widget_get_opacity) := BindFunc('ft_widget_get_opacity');
  Pointer(ft_widget_set_enabled) := BindFunc('ft_widget_set_enabled');
  Pointer(ft_widget_get_enabled) := BindFunc('ft_widget_get_enabled');
  Pointer(ft_widget_get_parent_render_area) := BindFunc('ft_widget_get_parent_render_area');
  Pointer(ft_widget_set_bounds) := BindFunc('ft_widget_set_bounds');
  Pointer(ft_widget_get_bounds) := BindFunc('ft_widget_get_bounds');
  Pointer(ft_widget_get_x) := BindFunc('ft_widget_get_x');
  Pointer(ft_widget_get_y) := BindFunc('ft_widget_get_y');
  Pointer(ft_widget_get_width) := BindFunc('ft_widget_get_width');
  Pointer(ft_widget_get_height) := BindFunc('ft_widget_get_height');
  Pointer(ft_widget_destroy) := BindFunc('ft_widget_destroy');
  Pointer(ft_widget_is_valid) := BindFunc('ft_widget_is_valid');
  Pointer(ft_widget_on_destroy) := BindFunc('ft_widget_on_destroy');

  { Bind Micro-Flexbox Child Properties }
  Pointer(ft_widget_set_flex_grow) := BindFunc('ft_widget_set_flex_grow');
  Pointer(ft_widget_get_flex_grow) := BindFunc('ft_widget_get_flex_grow');
  Pointer(ft_widget_set_flex_shrink) := BindFunc('ft_widget_set_flex_shrink');
  Pointer(ft_widget_get_flex_shrink) := BindFunc('ft_widget_get_flex_shrink');
  Pointer(ft_widget_set_flex_basis) := BindFunc('ft_widget_set_flex_basis');
  Pointer(ft_widget_get_flex_basis) := BindFunc('ft_widget_get_flex_basis');
  Pointer(ft_widget_set_align_self) := BindFunc('ft_widget_set_align_self');
  Pointer(ft_widget_get_align_self) := BindFunc('ft_widget_get_align_self');
  Pointer(ft_widget_set_margin) := BindFunc('ft_widget_set_margin');
  Pointer(ft_widget_set_margin_all) := BindFunc('ft_widget_set_margin_all');
  Pointer(ft_widget_set_grid_cell) := BindFunc('ft_widget_set_grid_cell');
  Pointer(ft_widget_get_grid_col) := BindFunc('ft_widget_get_grid_col');
  Pointer(ft_widget_get_grid_row) := BindFunc('ft_widget_get_grid_row');
  Pointer(ft_widget_get_grid_col_span) := BindFunc('ft_widget_get_grid_col_span');
  Pointer(ft_widget_get_grid_row_span) := BindFunc('ft_widget_get_grid_row_span');

  { Bind Hints }
  Pointer(ft_widget_set_hint) := BindFunc('ft_widget_set_hint');
  Pointer(ft_widget_get_hint) := BindFunc('ft_widget_get_hint');
  Pointer(ft_widget_get_effective_hint) := BindFunc('ft_widget_get_effective_hint');
  Pointer(ft_widget_set_show_hint) := BindFunc('ft_widget_set_show_hint');
  Pointer(ft_widget_get_show_hint) := BindFunc('ft_widget_get_show_hint');
  Pointer(ft_set_hint_delay) := BindFunc('ft_set_hint_delay');
  Pointer(ft_get_hint_delay) := BindFunc('ft_get_hint_delay');

  { Bind Buttons }
  Pointer(ft_button_create) := BindFunc('ft_button_create');
  Pointer(ft_toggle_button_create) := BindFunc('ft_toggle_button_create');
  Pointer(ft_button_set_toggle) := BindFunc('ft_button_set_toggle');
  Pointer(ft_button_get_toggle) := BindFunc('ft_button_get_toggle');
  Pointer(ft_button_set_toggled) := BindFunc('ft_button_set_toggled');
  Pointer(ft_button_get_toggled) := BindFunc('ft_button_get_toggled');
  Pointer(ft_button_get_state) := BindFunc('ft_button_get_state');
  Pointer(ft_button_on_click) := BindFunc('ft_button_on_click');
  Pointer(ft_button_on_hover) := BindFunc('ft_button_on_hover');
  Pointer(ft_button_on_press) := BindFunc('ft_button_on_press');
  Pointer(ft_button_on_toggle) := BindFunc('ft_button_on_toggle');
  Pointer(ft_button_set_corner_radius) := BindFunc('ft_button_set_corner_radius');
  Pointer(ft_button_get_corner_radius) := BindFunc('ft_button_get_corner_radius');
  Pointer(ft_button_set_shadow) := BindFunc('ft_button_set_shadow');
  Pointer(ft_button_get_shadow) := BindFunc('ft_button_get_shadow');
  Pointer(ft_button_set_caption) := BindFunc('ft_button_set_caption');
  Pointer(ft_button_get_caption) := BindFunc('ft_button_get_caption');
  Pointer(ft_button_set_icon_file) := BindFunc('ft_button_set_icon_file');
  Pointer(ft_button_set_icon_svg) := BindFunc('ft_button_set_icon_svg');
  Pointer(ft_button_set_icon_bitmap) := BindFunc('ft_button_set_icon_bitmap');
  Pointer(ft_button_get_icon_bitmap) := BindFunc('ft_button_get_icon_bitmap');
  Pointer(ft_button_clear_icon) := BindFunc('ft_button_clear_icon');
  Pointer(ft_button_set_icon_position) := BindFunc('ft_button_set_icon_position');
  Pointer(ft_button_get_icon_position) := BindFunc('ft_button_get_icon_position');
  Pointer(ft_button_set_icon_size) := BindFunc('ft_button_set_icon_size');
  Pointer(ft_button_get_icon_size) := BindFunc('ft_button_get_icon_size');
  Pointer(ft_button_set_icon_gap) := BindFunc('ft_button_set_icon_gap');
  Pointer(ft_button_get_icon_gap) := BindFunc('ft_button_get_icon_gap');
  Pointer(ft_button_on_paint_icon) := BindFunc('ft_button_on_paint_icon');
  Pointer(ft_button_on_paint) := BindFunc('ft_button_on_paint');
  Pointer(ft_button_set_align) := BindFunc('ft_button_set_align');
  Pointer(ft_button_get_align) := BindFunc('ft_button_get_align');
  Pointer(ft_button_set_padding_x) := BindFunc('ft_button_set_padding_x');
  Pointer(ft_button_get_padding_x) := BindFunc('ft_button_get_padding_x');

  { Bind Window Buttons }
  Pointer(ft_window_button_create) := BindFunc('ft_window_button_create');
  Pointer(ft_window_button_set_kind) := BindFunc('ft_window_button_set_kind');
  Pointer(ft_window_button_get_kind) := BindFunc('ft_window_button_get_kind');
  Pointer(ft_window_button_set_style) := BindFunc('ft_window_button_set_style');
  Pointer(ft_window_button_get_style) := BindFunc('ft_window_button_get_style');
  Pointer(ft_window_button_set_glyph_arm) := BindFunc('ft_window_button_set_glyph_arm');
  Pointer(ft_window_button_get_glyph_arm) := BindFunc('ft_window_button_get_glyph_arm');
  Pointer(ft_window_button_on_click) := BindFunc('ft_window_button_on_click');
  Pointer(ft_window_button_on_hover) := BindFunc('ft_window_button_on_hover');
  Pointer(ft_window_button_on_press) := BindFunc('ft_window_button_on_press');
  Pointer(ft_window_button_set_transition_duration) := BindFunc('ft_window_button_set_transition_duration');
  Pointer(ft_window_button_get_transition_duration) := BindFunc('ft_window_button_get_transition_duration');
  Pointer(ft_window_button_get_hover_progress) := BindFunc('ft_window_button_get_hover_progress');

  { Bind Switch }
  Pointer(ft_switch_create) := BindFunc('ft_switch_create');
  Pointer(ft_switch_set_checked) := BindFunc('ft_switch_set_checked');
  Pointer(ft_switch_get_checked) := BindFunc('ft_switch_get_checked');
  Pointer(ft_switch_toggle) := BindFunc('ft_switch_toggle');
  Pointer(ft_switch_set_toggled) := BindFunc('ft_switch_set_toggled');
  Pointer(ft_switch_get_toggled) := BindFunc('ft_switch_get_toggled');
  Pointer(ft_switch_get_state) := BindFunc('ft_switch_get_state');
  Pointer(ft_switch_on_toggle) := BindFunc('ft_switch_on_toggle');
  Pointer(ft_switch_on_change) := BindFunc('ft_switch_on_change');
  Pointer(ft_switch_on_hover) := BindFunc('ft_switch_on_hover');
  Pointer(ft_switch_set_corner_radius) := BindFunc('ft_switch_set_corner_radius');
  Pointer(ft_switch_get_corner_radius) := BindFunc('ft_switch_get_corner_radius');
  Pointer(ft_switch_set_shadow) := BindFunc('ft_switch_set_shadow');
  Pointer(ft_switch_get_shadow) := BindFunc('ft_switch_get_shadow');
  Pointer(ft_switch_set_caption) := BindFunc('ft_switch_set_caption');
  Pointer(ft_switch_get_caption) := BindFunc('ft_switch_get_caption');
  Pointer(ft_switch_set_transition_duration) := BindFunc('ft_switch_set_transition_duration');
  Pointer(ft_switch_get_transition_duration) := BindFunc('ft_switch_get_transition_duration');

  { Bind Text / Label }
  Pointer(ft_text_create) := BindFunc('ft_text_create');
  Pointer(ft_text_set_text) := BindFunc('ft_text_set_text');
  Pointer(ft_text_get_text) := BindFunc('ft_text_get_text');
  Pointer(ft_text_set_selectable) := BindFunc('ft_text_set_selectable');
  Pointer(ft_text_get_selectable) := BindFunc('ft_text_get_selectable');
  Pointer(ft_text_get_selected_text) := BindFunc('ft_text_get_selected_text');
  Pointer(ft_text_select_all) := BindFunc('ft_text_select_all');
  Pointer(ft_text_clear_selection) := BindFunc('ft_text_clear_selection');
  Pointer(ft_text_copy) := BindFunc('ft_text_copy');
  Pointer(ft_text_set_alignment) := BindFunc('ft_text_set_alignment');
  Pointer(ft_text_get_alignment) := BindFunc('ft_text_get_alignment');
  Pointer(ft_text_set_color) := BindFunc('ft_text_set_color');
  Pointer(ft_text_reset_color) := BindFunc('ft_text_reset_color');
  Pointer(ft_text_set_word_wrap) := BindFunc('ft_text_set_word_wrap');
  Pointer(ft_text_get_word_wrap) := BindFunc('ft_text_get_word_wrap');
  Pointer(ft_text_set_wrap) := BindFunc('ft_text_set_wrap');
  Pointer(ft_text_get_wrap) := BindFunc('ft_text_get_wrap');

  { Bind Clipboard }
  Pointer(ft_clipboard_set_text) := BindFunc('ft_clipboard_set_text');
  Pointer(ft_clipboard_get_text) := BindFunc('ft_clipboard_get_text');

  { Bind Entry }
  Pointer(ft_entry_create) := BindFunc('ft_entry_create');
  Pointer(ft_entry_set_text) := BindFunc('ft_entry_set_text');
  Pointer(ft_entry_get_text) := BindFunc('ft_entry_get_text');
  Pointer(ft_entry_set_placeholder) := BindFunc('ft_entry_set_placeholder');
  Pointer(ft_entry_get_placeholder) := BindFunc('ft_entry_get_placeholder');
  Pointer(ft_entry_set_readonly) := BindFunc('ft_entry_set_readonly');
  Pointer(ft_entry_get_readonly) := BindFunc('ft_entry_get_readonly');
  Pointer(ft_entry_on_change) := BindFunc('ft_entry_on_change');
  Pointer(ft_entry_on_submit) := BindFunc('ft_entry_on_submit');
  Pointer(ft_entry_set_corner_radius) := BindFunc('ft_entry_set_corner_radius');

  { Bind PathBar }
  Pointer(ft_path_bar_create) := BindFunc('ft_path_bar_create');
  Pointer(ft_path_bar_set_path) := BindFunc('ft_path_bar_set_path');
  Pointer(ft_path_bar_get_path) := BindFunc('ft_path_bar_get_path');
  Pointer(ft_path_bar_set_mode) := BindFunc('ft_path_bar_set_mode');
  Pointer(ft_path_bar_get_mode) := BindFunc('ft_path_bar_get_mode');
  Pointer(ft_path_bar_on_navigate) := BindFunc('ft_path_bar_on_navigate');
  Pointer(ft_path_bar_on_mode_change) := BindFunc('ft_path_bar_on_mode_change');
  Pointer(ft_path_bar_get_entry) := BindFunc('ft_path_bar_get_entry');
  Pointer(ft_path_bar_set_show_edit_button) := BindFunc('ft_path_bar_set_show_edit_button');
  Pointer(ft_path_bar_get_show_edit_button) := BindFunc('ft_path_bar_get_show_edit_button');
  Pointer(ft_path_bar_set_root_display_name) := BindFunc('ft_path_bar_set_root_display_name');
  Pointer(ft_path_bar_get_root_display_name) := BindFunc('ft_path_bar_get_root_display_name');
  Pointer(ft_path_bar_set_corner_radius) := BindFunc('ft_path_bar_set_corner_radius');
  Pointer(ft_path_bar_get_corner_radius) := BindFunc('ft_path_bar_get_corner_radius');

  { Bind UrlEntry }
  Pointer(ft_url_entry_create) := BindFunc('ft_url_entry_create');
  Pointer(ft_url_entry_set_url) := BindFunc('ft_url_entry_set_url');
  Pointer(ft_url_entry_get_url) := BindFunc('ft_url_entry_get_url');
  Pointer(ft_url_entry_set_security_state) := BindFunc('ft_url_entry_set_security_state');
  Pointer(ft_url_entry_get_security_state) := BindFunc('ft_url_entry_get_security_state');
  Pointer(ft_url_entry_set_bookmarked) := BindFunc('ft_url_entry_set_bookmarked');
  Pointer(ft_url_entry_get_bookmarked) := BindFunc('ft_url_entry_get_bookmarked');
  Pointer(ft_url_entry_set_show_security_chip) := BindFunc('ft_url_entry_set_show_security_chip');
  Pointer(ft_url_entry_get_show_security_chip) := BindFunc('ft_url_entry_get_show_security_chip');
  Pointer(ft_url_entry_set_show_security_badge_text) := BindFunc('ft_url_entry_set_show_security_badge_text');
  Pointer(ft_url_entry_get_show_security_badge_text) := BindFunc('ft_url_entry_get_show_security_badge_text');
  Pointer(ft_url_entry_set_show_bookmark_button) := BindFunc('ft_url_entry_set_show_bookmark_button');
  Pointer(ft_url_entry_get_show_bookmark_button) := BindFunc('ft_url_entry_get_show_bookmark_button');
  Pointer(ft_url_entry_set_auto_prefix_https) := BindFunc('ft_url_entry_set_auto_prefix_https');
  Pointer(ft_url_entry_get_auto_prefix_https) := BindFunc('ft_url_entry_get_auto_prefix_https');
  Pointer(ft_url_entry_set_corner_radius) := BindFunc('ft_url_entry_set_corner_radius');
  Pointer(ft_url_entry_get_corner_radius) := BindFunc('ft_url_entry_get_corner_radius');
  Pointer(ft_url_entry_set_editing) := BindFunc('ft_url_entry_set_editing');
  Pointer(ft_url_entry_get_editing) := BindFunc('ft_url_entry_get_editing');
  Pointer(ft_url_entry_on_submit) := BindFunc('ft_url_entry_on_submit');
  Pointer(ft_url_entry_on_security_click) := BindFunc('ft_url_entry_on_security_click');
  Pointer(ft_url_entry_on_bookmark_click) := BindFunc('ft_url_entry_on_bookmark_click');
  Pointer(ft_url_entry_on_action_click) := BindFunc('ft_url_entry_on_action_click');
  Pointer(ft_url_entry_get_entry) := BindFunc('ft_url_entry_get_entry');

  { Bind TextArea }
  Pointer(ft_textarea_create) := BindFunc('ft_textarea_create');
  Pointer(ft_textarea_set_text) := BindFunc('ft_textarea_set_text');
  Pointer(ft_textarea_get_text) := BindFunc('ft_textarea_get_text');
  Pointer(ft_textarea_set_placeholder) := BindFunc('ft_textarea_set_placeholder');
  Pointer(ft_textarea_get_placeholder) := BindFunc('ft_textarea_get_placeholder');
  Pointer(ft_textarea_set_readonly) := BindFunc('ft_textarea_set_readonly');
  Pointer(ft_textarea_get_readonly) := BindFunc('ft_textarea_get_readonly');
  Pointer(ft_textarea_on_change) := BindFunc('ft_textarea_on_change');
  Pointer(ft_textarea_set_corner_radius) := BindFunc('ft_textarea_set_corner_radius');
  Pointer(ft_textarea_set_scrollbar_mode) := BindFunc('ft_textarea_set_scrollbar_mode');
  Pointer(ft_textarea_get_scrollbar_mode) := BindFunc('ft_textarea_get_scrollbar_mode');
  Pointer(ft_textarea_get_vscrollbar) := BindFunc('ft_textarea_get_vscrollbar');
  Pointer(ft_textarea_get_hscrollbar) := BindFunc('ft_textarea_get_hscrollbar');

  { Bind ScrollBar }
  Pointer(ft_scrollbar_create) := BindFunc('ft_scrollbar_create');
  Pointer(ft_scrollbar_set_orientation) := BindFunc('ft_scrollbar_set_orientation');
  Pointer(ft_scrollbar_get_orientation) := BindFunc('ft_scrollbar_get_orientation');
  Pointer(ft_scrollbar_set_range) := BindFunc('ft_scrollbar_set_range');
  Pointer(ft_scrollbar_set_value) := BindFunc('ft_scrollbar_set_value');
  Pointer(ft_scrollbar_get_value) := BindFunc('ft_scrollbar_get_value');
  Pointer(ft_scrollbar_get_min) := BindFunc('ft_scrollbar_get_min');
  Pointer(ft_scrollbar_get_max) := BindFunc('ft_scrollbar_get_max');
  Pointer(ft_scrollbar_get_page_size) := BindFunc('ft_scrollbar_get_page_size');
  Pointer(ft_scrollbar_set_step) := BindFunc('ft_scrollbar_set_step');
  Pointer(ft_scrollbar_get_step) := BindFunc('ft_scrollbar_get_step');
  Pointer(ft_scrollbar_on_scroll) := BindFunc('ft_scrollbar_on_scroll');
  Pointer(ft_scrollbar_set_corner_radius) := BindFunc('ft_scrollbar_set_corner_radius');

  { Bind Container & Panel }
  Pointer(ft_container_create) := BindFunc('ft_container_create');
  Pointer(ft_panel_create) := BindFunc('ft_panel_create');
  Pointer(ft_container_set_scrollbar_mode) := BindFunc('ft_container_set_scrollbar_mode');
  Pointer(ft_container_get_scrollbar_mode) := BindFunc('ft_container_get_scrollbar_mode');
  Pointer(ft_container_set_content_size) := BindFunc('ft_container_set_content_size');
  Pointer(ft_container_get_content_size) := BindFunc('ft_container_get_content_size');
  Pointer(ft_container_set_scroll_pos) := BindFunc('ft_container_set_scroll_pos');
  Pointer(ft_container_get_scroll_x) := BindFunc('ft_container_get_scroll_x');
  Pointer(ft_container_get_scroll_y) := BindFunc('ft_container_get_scroll_y');
  Pointer(ft_container_set_corner_radius) := BindFunc('ft_container_set_corner_radius');
  Pointer(ft_container_get_corner_radius) := BindFunc('ft_container_get_corner_radius');
  Pointer(ft_container_set_backdrop_blur) := BindFunc('ft_container_set_backdrop_blur');
  Pointer(ft_container_get_backdrop_blur) := BindFunc('ft_container_get_backdrop_blur');
  Pointer(ft_container_set_padding) := BindFunc('ft_container_set_padding');
  Pointer(ft_container_set_draw_frame) := BindFunc('ft_container_set_draw_frame');
  Pointer(ft_container_get_draw_frame) := BindFunc('ft_container_get_draw_frame');
  Pointer(ft_container_set_draw_focus_ring) := BindFunc('ft_container_set_draw_focus_ring');
  Pointer(ft_container_get_draw_focus_ring) := BindFunc('ft_container_get_draw_focus_ring');
  Pointer(ft_container_set_auto_content_size) := BindFunc('ft_container_set_auto_content_size');
  Pointer(ft_container_get_auto_content_size) := BindFunc('ft_container_get_auto_content_size');
  Pointer(ft_container_get_vscrollbar) := BindFunc('ft_container_get_vscrollbar');
  Pointer(ft_container_get_hscrollbar) := BindFunc('ft_container_get_hscrollbar');
  Pointer(ft_container_on_scroll) := BindFunc('ft_container_on_scroll');
  Pointer(ft_container_get_client_rect) := BindFunc('ft_container_get_client_rect');
  Pointer(ft_container_get_render_area) := BindFunc('ft_container_get_render_area');
  Pointer(ft_container_get_inner_radius) := BindFunc('ft_container_get_inner_radius');
  Pointer(ft_container_get_effective_corner_radius) := BindFunc('ft_container_get_effective_corner_radius');
  Pointer(ft_container_update_scrollbars) := BindFunc('ft_container_update_scrollbars');

  { Bind Flexbox & Layouts }
  Pointer(ft_flexbox_create) := BindFunc('ft_flexbox_create');
  Pointer(ft_hbox_create) := BindFunc('ft_hbox_create');
  Pointer(ft_vbox_create) := BindFunc('ft_vbox_create');
  Pointer(ft_spacer_create) := BindFunc('ft_spacer_create');
  Pointer(ft_floating_bar_create) := BindFunc('ft_floating_bar_create');
  Pointer(ft_floating_bar_set_anchor) := BindFunc('ft_floating_bar_set_anchor');
  Pointer(ft_floating_bar_get_anchor) := BindFunc('ft_floating_bar_get_anchor');
  Pointer(ft_floating_bar_set_margins) := BindFunc('ft_floating_bar_set_margins');
  Pointer(ft_floating_bar_get_margins) := BindFunc('ft_floating_bar_get_margins');
  Pointer(ft_floating_bar_set_auto_anchor) := BindFunc('ft_floating_bar_set_auto_anchor');
  Pointer(ft_floating_bar_get_auto_anchor) := BindFunc('ft_floating_bar_get_auto_anchor');
  Pointer(ft_floating_bar_update_anchor) := BindFunc('ft_floating_bar_update_anchor');
  Pointer(ft_flexbox_set_direction) := BindFunc('ft_flexbox_set_direction');
  Pointer(ft_flexbox_get_direction) := BindFunc('ft_flexbox_get_direction');
  Pointer(ft_flexbox_set_wrap) := BindFunc('ft_flexbox_set_wrap');
  Pointer(ft_flexbox_get_wrap) := BindFunc('ft_flexbox_get_wrap');
  Pointer(ft_flexbox_set_justify_content) := BindFunc('ft_flexbox_set_justify_content');
  Pointer(ft_flexbox_get_justify_content) := BindFunc('ft_flexbox_get_justify_content');
  Pointer(ft_flexbox_set_align_items) := BindFunc('ft_flexbox_set_align_items');
  Pointer(ft_flexbox_get_align_items) := BindFunc('ft_flexbox_get_align_items');
  Pointer(ft_flexbox_set_gap) := BindFunc('ft_flexbox_set_gap');
  Pointer(ft_flexbox_get_gap) := BindFunc('ft_flexbox_get_gap');
  Pointer(ft_flexbox_update_layout) := BindFunc('ft_flexbox_update_layout');
  Pointer(ft_flexbox_add_splitter) := BindFunc('ft_flexbox_add_splitter');
  Pointer(ft_flex_splitter_create) := BindFunc('ft_flex_splitter_create');

  { Bind Grid & Form Grid }
  Pointer(ft_grid_create) := BindFunc('ft_grid_create');
  Pointer(ft_grid_set_column_count) := BindFunc('ft_grid_set_column_count');
  Pointer(ft_grid_set_row_count) := BindFunc('ft_grid_set_row_count');
  Pointer(ft_grid_get_column_count) := BindFunc('ft_grid_get_column_count');
  Pointer(ft_grid_get_row_count) := BindFunc('ft_grid_get_row_count');
  Pointer(ft_grid_set_gaps) := BindFunc('ft_grid_set_gaps');
  Pointer(ft_grid_set_column_fixed) := BindFunc('ft_grid_set_column_fixed');
  Pointer(ft_grid_set_column_flex) := BindFunc('ft_grid_set_column_flex');
  Pointer(ft_grid_set_column_auto) := BindFunc('ft_grid_set_column_auto');
  Pointer(ft_grid_set_row_fixed) := BindFunc('ft_grid_set_row_fixed');
  Pointer(ft_grid_set_row_flex) := BindFunc('ft_grid_set_row_flex');
  Pointer(ft_grid_set_row_auto) := BindFunc('ft_grid_set_row_auto');
  Pointer(ft_grid_set_column_template) := BindFunc('ft_grid_set_column_template');
  Pointer(ft_grid_set_row_template) := BindFunc('ft_grid_set_row_template');
  Pointer(ft_grid_add_widget) := BindFunc('ft_grid_add_widget');
  Pointer(ft_grid_update_layout) := BindFunc('ft_grid_update_layout');
  Pointer(ft_form_grid_create) := BindFunc('ft_form_grid_create');
  Pointer(ft_form_grid_add_row) := BindFunc('ft_form_grid_add_row');
  Pointer(ft_form_grid_add_row_widgets) := BindFunc('ft_form_grid_add_row_widgets');
  Pointer(ft_form_grid_add_spanned) := BindFunc('ft_form_grid_add_spanned');
  Pointer(ft_form_grid_add_section) := BindFunc('ft_form_grid_add_section');

  { Bind Size Group }
  Pointer(ft_size_group_create) := BindFunc('ft_size_group_create');
  Pointer(ft_size_group_destroy) := BindFunc('ft_size_group_destroy');
  Pointer(ft_size_group_add_widget) := BindFunc('ft_size_group_add_widget');
  Pointer(ft_size_group_remove_widget) := BindFunc('ft_size_group_remove_widget');
  Pointer(ft_size_group_synchronize) := BindFunc('ft_size_group_synchronize');

  { Bind CheckBox }
  Pointer(ft_checkbox_create) := BindFunc('ft_checkbox_create');
  Pointer(ft_checkbox_set_checked) := BindFunc('ft_checkbox_set_checked');
  Pointer(ft_checkbox_get_checked) := BindFunc('ft_checkbox_get_checked');
  Pointer(ft_checkbox_toggle) := BindFunc('ft_checkbox_toggle');
  Pointer(ft_checkbox_set_caption) := BindFunc('ft_checkbox_set_caption');
  Pointer(ft_checkbox_get_caption) := BindFunc('ft_checkbox_get_caption');
  Pointer(ft_checkbox_set_corner_radius) := BindFunc('ft_checkbox_set_corner_radius');
  Pointer(ft_checkbox_get_corner_radius) := BindFunc('ft_checkbox_get_corner_radius');
  Pointer(ft_checkbox_on_toggle) := BindFunc('ft_checkbox_on_toggle');

  { Bind RadioButton }
  Pointer(ft_radio_create) := BindFunc('ft_radio_create');
  Pointer(ft_radio_set_checked) := BindFunc('ft_radio_set_checked');
  Pointer(ft_radio_get_checked) := BindFunc('ft_radio_get_checked');
  Pointer(ft_radio_set_group) := BindFunc('ft_radio_set_group');
  Pointer(ft_radio_get_group) := BindFunc('ft_radio_get_group');
  Pointer(ft_radio_set_caption) := BindFunc('ft_radio_set_caption');
  Pointer(ft_radio_get_caption) := BindFunc('ft_radio_get_caption');
  Pointer(ft_radio_on_toggle) := BindFunc('ft_radio_on_toggle');

  { Bind ComboBox }
  Pointer(ft_combobox_create) := BindFunc('ft_combobox_create');
  Pointer(ft_combobox_add_item) := BindFunc('ft_combobox_add_item');
  Pointer(ft_combobox_clear) := BindFunc('ft_combobox_clear');
  Pointer(ft_combobox_get_item_count) := BindFunc('ft_combobox_get_item_count');
  Pointer(ft_combobox_get_item) := BindFunc('ft_combobox_get_item');
  Pointer(ft_combobox_set_selected) := BindFunc('ft_combobox_set_selected');
  Pointer(ft_combobox_get_selected) := BindFunc('ft_combobox_get_selected');
  Pointer(ft_combobox_get_selected_text) := BindFunc('ft_combobox_get_selected_text');
  Pointer(ft_combobox_set_text) := BindFunc('ft_combobox_set_text');
  Pointer(ft_combobox_get_text) := BindFunc('ft_combobox_get_text');
  Pointer(ft_combobox_set_placeholder) := BindFunc('ft_combobox_set_placeholder');
  Pointer(ft_combobox_get_placeholder) := BindFunc('ft_combobox_get_placeholder');
  Pointer(ft_combobox_set_editable) := BindFunc('ft_combobox_set_editable');
  Pointer(ft_combobox_get_editable) := BindFunc('ft_combobox_get_editable');
  Pointer(ft_combobox_set_corner_radius) := BindFunc('ft_combobox_set_corner_radius');
  Pointer(ft_combobox_get_corner_radius) := BindFunc('ft_combobox_get_corner_radius');
  Pointer(ft_combobox_popup) := BindFunc('ft_combobox_popup');
  Pointer(ft_combobox_on_change) := BindFunc('ft_combobox_on_change');

  { Bind Slider }
  Pointer(ft_slider_create) := BindFunc('ft_slider_create');
  Pointer(ft_slider_set_orientation) := BindFunc('ft_slider_set_orientation');
  Pointer(ft_slider_get_orientation) := BindFunc('ft_slider_get_orientation');
  Pointer(ft_slider_set_range) := BindFunc('ft_slider_set_range');
  Pointer(ft_slider_get_min) := BindFunc('ft_slider_get_min');
  Pointer(ft_slider_get_max) := BindFunc('ft_slider_get_max');
  Pointer(ft_slider_set_value) := BindFunc('ft_slider_set_value');
  Pointer(ft_slider_get_value) := BindFunc('ft_slider_get_value');
  Pointer(ft_slider_set_step) := BindFunc('ft_slider_set_step');
  Pointer(ft_slider_get_step) := BindFunc('ft_slider_get_step');
  Pointer(ft_slider_set_thumb_size) := BindFunc('ft_slider_set_thumb_size');
  Pointer(ft_slider_get_thumb_size) := BindFunc('ft_slider_get_thumb_size');
  Pointer(ft_slider_on_change) := BindFunc('ft_slider_on_change');

  { Bind ProgressBar }
  Pointer(ft_progressbar_create) := BindFunc('ft_progressbar_create');
  Pointer(ft_progressbar_set_orientation) := BindFunc('ft_progressbar_set_orientation');
  Pointer(ft_progressbar_get_orientation) := BindFunc('ft_progressbar_get_orientation');
  Pointer(ft_progressbar_set_range) := BindFunc('ft_progressbar_set_range');
  Pointer(ft_progressbar_get_min) := BindFunc('ft_progressbar_get_min');
  Pointer(ft_progressbar_get_max) := BindFunc('ft_progressbar_get_max');
  Pointer(ft_progressbar_set_value) := BindFunc('ft_progressbar_set_value');
  Pointer(ft_progressbar_get_value) := BindFunc('ft_progressbar_get_value');
  Pointer(ft_progressbar_set_indeterminate) := BindFunc('ft_progressbar_set_indeterminate');
  Pointer(ft_progressbar_get_indeterminate) := BindFunc('ft_progressbar_get_indeterminate');
  Pointer(ft_progressbar_set_show_text) := BindFunc('ft_progressbar_set_show_text');
  Pointer(ft_progressbar_get_show_text) := BindFunc('ft_progressbar_get_show_text');
  Pointer(ft_progressbar_set_text_format) := BindFunc('ft_progressbar_set_text_format');
  Pointer(ft_progressbar_get_text_format) := BindFunc('ft_progressbar_get_text_format');
  Pointer(ft_progressbar_set_corner_radius) := BindFunc('ft_progressbar_set_corner_radius');
  Pointer(ft_progressbar_get_corner_radius) := BindFunc('ft_progressbar_get_corner_radius');

  { Bind Menus }
  Pointer(ft_main_menu_create) := BindFunc('ft_main_menu_create');
  Pointer(ft_main_menu_add_menu) := BindFunc('ft_main_menu_add_menu');
  Pointer(ft_main_menu_add_item) := BindFunc('ft_main_menu_add_item');
  Pointer(ft_main_menu_item_count) := BindFunc('ft_main_menu_item_count');
  Pointer(ft_main_menu_get_item) := BindFunc('ft_main_menu_get_item');
  Pointer(ft_main_menu_close) := BindFunc('ft_main_menu_close');
  Pointer(ft_popup_menu_create) := BindFunc('ft_popup_menu_create');
  Pointer(ft_popup_menu_add_item) := BindFunc('ft_popup_menu_add_item');
  Pointer(ft_popup_menu_add_check_item) := BindFunc('ft_popup_menu_add_check_item');
  Pointer(ft_popup_menu_add_separator) := BindFunc('ft_popup_menu_add_separator');
  Pointer(ft_popup_menu_add_submenu) := BindFunc('ft_popup_menu_add_submenu');
  Pointer(ft_popup_menu_item_count) := BindFunc('ft_popup_menu_item_count');
  Pointer(ft_popup_menu_get_item) := BindFunc('ft_popup_menu_get_item');
  Pointer(ft_popup_menu_show) := BindFunc('ft_popup_menu_show');
  Pointer(ft_popup_menu_close) := BindFunc('ft_popup_menu_close');
  Pointer(ft_popup_menu_clear) := BindFunc('ft_popup_menu_clear');
  Pointer(ft_popup_menu_set_corner_radius) := BindFunc('ft_popup_menu_set_corner_radius');
  Pointer(ft_menu_item_set_caption) := BindFunc('ft_menu_item_set_caption');
  Pointer(ft_menu_item_get_caption) := BindFunc('ft_menu_item_get_caption');
  Pointer(ft_menu_item_set_shortcut) := BindFunc('ft_menu_item_set_shortcut');
  Pointer(ft_menu_item_get_shortcut) := BindFunc('ft_menu_item_get_shortcut');
  Pointer(ft_menu_item_set_enabled) := BindFunc('ft_menu_item_set_enabled');
  Pointer(ft_menu_item_get_enabled) := BindFunc('ft_menu_item_get_enabled');
  Pointer(ft_menu_item_set_checked) := BindFunc('ft_menu_item_set_checked');
  Pointer(ft_menu_item_get_checked) := BindFunc('ft_menu_item_get_checked');
  Pointer(ft_menu_item_set_checkable) := BindFunc('ft_menu_item_set_checkable');
  Pointer(ft_menu_item_get_checkable) := BindFunc('ft_menu_item_get_checkable');
  Pointer(ft_menu_item_set_submenu) := BindFunc('ft_menu_item_set_submenu');
  Pointer(ft_menu_item_get_submenu) := BindFunc('ft_menu_item_get_submenu');
  Pointer(ft_menu_item_on_click) := BindFunc('ft_menu_item_on_click');
  Pointer(ft_menu_item_set_tag) := BindFunc('ft_menu_item_set_tag');
  Pointer(ft_menu_item_get_tag) := BindFunc('ft_menu_item_get_tag');
  Pointer(ft_widget_set_context_menu) := BindFunc('ft_widget_set_context_menu');
  Pointer(ft_widget_get_context_menu) := BindFunc('ft_widget_get_context_menu');
  Pointer(ft_window_set_context_menu) := BindFunc('ft_window_set_context_menu');
  Pointer(ft_window_get_context_menu) := BindFunc('ft_window_get_context_menu');
  Pointer(ft_window_set_main_menu) := BindFunc('ft_window_set_main_menu');
  Pointer(ft_window_get_main_menu) := BindFunc('ft_window_get_main_menu');

  { Bind System & Theme }
  Pointer(ft_system_font_get) := BindFunc('ft_system_font_get');
  Pointer(ft_system_font_set) := BindFunc('ft_system_font_set');
  Pointer(ft_widget_set_font) := BindFunc('ft_widget_set_font');
  Pointer(ft_widget_get_font) := BindFunc('ft_widget_get_font');
  Pointer(ft_screen_dpi_get) := BindFunc('ft_screen_dpi_get');
  Pointer(ft_screen_dpi_set) := BindFunc('ft_screen_dpi_set');
  Pointer(ft_screen_get_width) := BindFunc('ft_screen_get_width');
  Pointer(ft_screen_get_height) := BindFunc('ft_screen_get_height');
  Pointer(ft_register_event_filter) := BindFunc('ft_register_event_filter');
  Pointer(ft_set_tick_callback) := BindFunc('ft_set_tick_callback');
  Pointer(ft_set_timer) := BindFunc('ft_set_timer');
  Pointer(ft_backend_get_connection) := BindFunc('ft_backend_get_connection');
  Pointer(ft_backend_get_screen) := BindFunc('ft_backend_get_screen');
  Pointer(ft_backend_get_key_symbols) := BindFunc('ft_backend_get_key_symbols');
  Pointer(ft_font_gamma_get) := BindFunc('ft_font_gamma_get');
  Pointer(ft_font_gamma_set) := BindFunc('ft_font_gamma_set');
  Pointer(ft_font_create) := BindFunc('ft_font_create');
  Pointer(ft_font_ascii_advance) := BindFunc('ft_font_ascii_advance');
  Pointer(ft_font_text_width) := BindFunc('ft_font_text_width');
  Pointer(ft_font_get_metrics) := BindFunc('ft_font_get_metrics');
  Pointer(ft_theme_set) := BindFunc('ft_theme_set');
  Pointer(ft_theme_get) := BindFunc('ft_theme_get');
  Pointer(ft_theme_get_available) := BindFunc('ft_theme_get_available');
  Pointer(ft_theme_set_corner_radius) := BindFunc('ft_theme_set_corner_radius');
  Pointer(ft_theme_get_corner_radius) := BindFunc('ft_theme_get_corner_radius');
  Pointer(ft_theme_set_shadow) := BindFunc('ft_theme_set_shadow');
  Pointer(ft_theme_get_shadow) := BindFunc('ft_theme_get_shadow');
  Pointer(ft_theme_load_file) := BindFunc('ft_theme_load_file');
  Pointer(ft_theme_load_dir) := BindFunc('ft_theme_load_dir');
  Pointer(ft_theme_set_dark_mode) := BindFunc('ft_theme_set_dark_mode');
  Pointer(ft_theme_get_dark_mode) := BindFunc('ft_theme_get_dark_mode');
  Pointer(ft_theme_has_dark_mode) := BindFunc('ft_theme_has_dark_mode');

  { Bind CSS & Animation }
  Pointer(ft_widget_set_style_class) := BindFunc('ft_widget_set_style_class');
  Pointer(ft_widget_get_style_class) := BindFunc('ft_widget_get_style_class');
  Pointer(ft_widget_set_style_id) := BindFunc('ft_widget_set_style_id');
  Pointer(ft_widget_get_style_id) := BindFunc('ft_widget_get_style_id');
  Pointer(ft_widget_set_style) := BindFunc('ft_widget_set_style');
  Pointer(ft_widget_get_style) := BindFunc('ft_widget_get_style');
  Pointer(ft_style_load_css_file) := BindFunc('ft_style_load_css_file');
  Pointer(ft_style_load_css_string) := BindFunc('ft_style_load_css_string');
  Pointer(ft_animation_is_running) := BindFunc('ft_animation_is_running');

  { Bind Bitmaps & Images }
  Pointer(ft_bitmap_create) := BindFunc('ft_bitmap_create');
  Pointer(ft_bitmap_load_file) := BindFunc('ft_bitmap_load_file');
  Pointer(ft_bitmap_load_memory) := BindFunc('ft_bitmap_load_memory');
  Pointer(ft_bitmap_create_from_rgba) := BindFunc('ft_bitmap_create_from_rgba');
  Pointer(ft_bitmap_create_from_bgra) := BindFunc('ft_bitmap_create_from_bgra');
  Pointer(ft_bitmap_get_width) := BindFunc('ft_bitmap_get_width');
  Pointer(ft_bitmap_get_height) := BindFunc('ft_bitmap_get_height');
  Pointer(ft_bitmap_get_stride) := BindFunc('ft_bitmap_get_stride');
  Pointer(ft_bitmap_get_pixels) := BindFunc('ft_bitmap_get_pixels');
  Pointer(ft_bitmap_create_scaled) := BindFunc('ft_bitmap_create_scaled');
  Pointer(ft_bitmap_destroy) := BindFunc('ft_bitmap_destroy');
  Pointer(ft_bitmap_save_to_file) := BindFunc('ft_bitmap_save_to_file');
  Pointer(ft_image_create) := BindFunc('ft_image_create');
  Pointer(ft_image_load_file) := BindFunc('ft_image_load_file');
  Pointer(ft_image_load_memory) := BindFunc('ft_image_load_memory');
  Pointer(ft_image_load_svg_file) := BindFunc('ft_image_load_svg_file');
  Pointer(ft_image_load_svg_string) := BindFunc('ft_image_load_svg_string');
  Pointer(ft_image_invalidate_cache) := BindFunc('ft_image_invalidate_cache');
  Pointer(ft_image_set_bitmap) := BindFunc('ft_image_set_bitmap');
  Pointer(ft_image_get_bitmap) := BindFunc('ft_image_get_bitmap');
  Pointer(ft_image_set_scale_mode) := BindFunc('ft_image_set_scale_mode');
  Pointer(ft_image_get_scale_mode) := BindFunc('ft_image_get_scale_mode');
  Pointer(ft_image_set_opacity) := BindFunc('ft_image_set_opacity');
  Pointer(ft_image_get_opacity) := BindFunc('ft_image_get_opacity');
  Pointer(ft_bitmap_create_from_svg) := BindFunc('ft_bitmap_create_from_svg');
  Pointer(ft_bitmap_create_from_svg_file) := BindFunc('ft_bitmap_create_from_svg_file');

  { Bind Canvas Drawing }
  Pointer(ft_canvas_draw_image) := BindFunc('ft_canvas_draw_image');
  Pointer(ft_canvas_draw_image_scaled) := BindFunc('ft_canvas_draw_image_scaled');
  Pointer(ft_canvas_draw_image_part) := BindFunc('ft_canvas_draw_image_part');
  Pointer(ft_canvas_draw_svg) := BindFunc('ft_canvas_draw_svg');
  Pointer(ft_canvas_draw_svg_file) := BindFunc('ft_canvas_draw_svg_file');
  Pointer(ft_canvas_push_alpha) := BindFunc('ft_canvas_push_alpha');
  Pointer(ft_canvas_pop_alpha) := BindFunc('ft_canvas_pop_alpha');
  Pointer(ft_canvas_reset_alpha) := BindFunc('ft_canvas_reset_alpha');
  Pointer(ft_canvas_get_alpha) := BindFunc('ft_canvas_get_alpha');
  Pointer(ft_canvas_draw_rect) := BindFunc('ft_canvas_draw_rect');
  Pointer(ft_canvas_draw_rounded_rect) := BindFunc('ft_canvas_draw_rounded_rect');
  Pointer(ft_canvas_draw_rounded_rect_outline) := BindFunc('ft_canvas_draw_rounded_rect_outline');
  Pointer(ft_canvas_draw_line) := BindFunc('ft_canvas_draw_line');
  Pointer(ft_canvas_draw_circle) := BindFunc('ft_canvas_draw_circle');
  Pointer(ft_canvas_draw_text) := BindFunc('ft_canvas_draw_text');
  Pointer(ft_canvas_draw_text_left) := BindFunc('ft_canvas_draw_text_left');
  Pointer(ft_canvas_draw_text_centered) := BindFunc('ft_canvas_draw_text_centered');
  Pointer(ft_canvas_push_clip_rect) := BindFunc('ft_canvas_push_clip_rect');
  Pointer(ft_canvas_pop_clip_rect) := BindFunc('ft_canvas_pop_clip_rect');
  Pointer(ft_canvas_push_clip_rounded_rect) := BindFunc('ft_canvas_push_clip_rounded_rect');
  Pointer(ft_canvas_pop_clip_rounded_rect) := BindFunc('ft_canvas_pop_clip_rounded_rect');
  Pointer(ft_canvas_reset_clipping) := BindFunc('ft_canvas_reset_clipping');

  { Bind Notebook }
  Pointer(ft_notebook_create) := BindFunc('ft_notebook_create');
  Pointer(ft_notebook_add_tab) := BindFunc('ft_notebook_add_tab');
  Pointer(ft_notebook_remove_tab) := BindFunc('ft_notebook_remove_tab');
  Pointer(ft_notebook_clear_tabs) := BindFunc('ft_notebook_clear_tabs');
  Pointer(ft_notebook_get_page_count) := BindFunc('ft_notebook_get_page_count');
  Pointer(ft_notebook_get_page) := BindFunc('ft_notebook_get_page');
  Pointer(ft_notebook_set_active_index) := BindFunc('ft_notebook_set_active_index');
  Pointer(ft_notebook_get_active_index) := BindFunc('ft_notebook_get_active_index');
  Pointer(ft_notebook_set_tab_height) := BindFunc('ft_notebook_set_tab_height');
  Pointer(ft_notebook_get_tab_height) := BindFunc('ft_notebook_get_tab_height');
  Pointer(ft_notebook_on_tab_change) := BindFunc('ft_notebook_on_tab_change');
  Pointer(ft_notebook_set_max_tab_width) := BindFunc('ft_notebook_set_max_tab_width');
  Pointer(ft_notebook_get_max_tab_width) := BindFunc('ft_notebook_get_max_tab_width');
  Pointer(ft_notebook_set_min_tab_width) := BindFunc('ft_notebook_set_min_tab_width');
  Pointer(ft_notebook_get_min_tab_width) := BindFunc('ft_notebook_get_min_tab_width');
  Pointer(ft_notebook_set_scroll_offset) := BindFunc('ft_notebook_set_scroll_offset');
  Pointer(ft_notebook_get_scroll_offset) := BindFunc('ft_notebook_get_scroll_offset');
  Pointer(ft_notebook_ensure_tab_visible) := BindFunc('ft_notebook_ensure_tab_visible');
  Pointer(ft_tab_page_set_title) := BindFunc('ft_tab_page_set_title');
  Pointer(ft_tab_page_get_title) := BindFunc('ft_tab_page_get_title');
  Pointer(ft_tab_page_set_closeable) := BindFunc('ft_tab_page_set_closeable');
  Pointer(ft_tab_page_get_closeable) := BindFunc('ft_tab_page_get_closeable');
  Pointer(ft_tab_page_set_icon) := BindFunc('ft_tab_page_set_icon');
  Pointer(ft_tab_page_get_icon) := BindFunc('ft_tab_page_get_icon');

  { Bind Splitter }
  Pointer(ft_splitter_create) := BindFunc('ft_splitter_create');
  Pointer(ft_splitter_set_panes) := BindFunc('ft_splitter_set_panes');
  Pointer(ft_splitter_get_pane1) := BindFunc('ft_splitter_get_pane1');
  Pointer(ft_splitter_get_pane2) := BindFunc('ft_splitter_get_pane2');
  Pointer(ft_splitter_set_orientation) := BindFunc('ft_splitter_set_orientation');
  Pointer(ft_splitter_get_orientation) := BindFunc('ft_splitter_get_orientation');
  Pointer(ft_splitter_set_pos) := BindFunc('ft_splitter_set_pos');
  Pointer(ft_splitter_get_pos) := BindFunc('ft_splitter_get_pos');
  Pointer(ft_splitter_set_ratio) := BindFunc('ft_splitter_set_ratio');
  Pointer(ft_splitter_set_splitter_size) := BindFunc('ft_splitter_set_splitter_size');
  Pointer(ft_splitter_get_splitter_size) := BindFunc('ft_splitter_get_splitter_size');
  Pointer(ft_splitter_set_min_sizes) := BindFunc('ft_splitter_set_min_sizes');
  Pointer(ft_splitter_get_min_pane1_size) := BindFunc('ft_splitter_get_min_pane1_size');
  Pointer(ft_splitter_get_min_pane2_size) := BindFunc('ft_splitter_get_min_pane2_size');
  Pointer(ft_splitter_on_position_change) := BindFunc('ft_splitter_on_position_change');

  { Bind TreeView }
  Pointer(ft_treeview_create) := BindFunc('ft_treeview_create');
  Pointer(ft_treeview_add_node) := BindFunc('ft_treeview_add_node');
  Pointer(ft_treeview_clear) := BindFunc('ft_treeview_clear');
  Pointer(ft_treeview_get_root) := BindFunc('ft_treeview_get_root');
  Pointer(ft_treeview_get_selected_node) := BindFunc('ft_treeview_get_selected_node');
  Pointer(ft_treeview_set_selected_node) := BindFunc('ft_treeview_set_selected_node');
  Pointer(ft_treeview_set_item_height) := BindFunc('ft_treeview_set_item_height');
  Pointer(ft_treeview_get_item_height) := BindFunc('ft_treeview_get_item_height');
  Pointer(ft_treeview_set_indent_width) := BindFunc('ft_treeview_set_indent_width');
  Pointer(ft_treeview_get_indent_width) := BindFunc('ft_treeview_get_indent_width');
  Pointer(ft_treeview_on_select) := BindFunc('ft_treeview_on_select');
  Pointer(ft_treenode_add_child) := BindFunc('ft_treenode_add_child');
  Pointer(ft_treenode_delete_child) := BindFunc('ft_treenode_delete_child');
  Pointer(ft_treenode_get_child_count) := BindFunc('ft_treenode_get_child_count');
  Pointer(ft_treenode_get_child) := BindFunc('ft_treenode_get_child');
  Pointer(ft_treenode_get_parent) := BindFunc('ft_treenode_get_parent');
  Pointer(ft_treenode_set_text) := BindFunc('ft_treenode_set_text');
  Pointer(ft_treenode_get_text) := BindFunc('ft_treenode_get_text');
  Pointer(ft_treenode_set_expanded) := BindFunc('ft_treenode_set_expanded');
  Pointer(ft_treenode_get_expanded) := BindFunc('ft_treenode_get_expanded');
  Pointer(ft_treenode_set_icon) := BindFunc('ft_treenode_set_icon');
  Pointer(ft_treenode_get_icon) := BindFunc('ft_treenode_get_icon');
  Pointer(ft_treenode_set_data) := BindFunc('ft_treenode_set_data');
  Pointer(ft_treenode_get_data) := BindFunc('ft_treenode_get_data');
  Pointer(ft_treenode_set_tag) := BindFunc('ft_treenode_set_tag');
  Pointer(ft_treenode_get_tag) := BindFunc('ft_treenode_get_tag');

  { Bind Table }
  Pointer(ft_table_create) := BindFunc('ft_table_create');
  Pointer(ft_table_add_column) := BindFunc('ft_table_add_column');
  Pointer(ft_table_get_column_count) := BindFunc('ft_table_get_column_count');
  Pointer(ft_table_set_column_title) := BindFunc('ft_table_set_column_title');
  Pointer(ft_table_get_column_title) := BindFunc('ft_table_get_column_title');
  Pointer(ft_table_set_column_width) := BindFunc('ft_table_set_column_width');
  Pointer(ft_table_get_column_width) := BindFunc('ft_table_get_column_width');
  Pointer(ft_table_set_column_align) := BindFunc('ft_table_set_column_align');
  Pointer(ft_table_get_column_align) := BindFunc('ft_table_get_column_align');
  Pointer(ft_table_set_column_icon) := BindFunc('ft_table_set_column_icon');
  Pointer(ft_table_get_column_icon) := BindFunc('ft_table_get_column_icon');
  Pointer(ft_table_add_row) := BindFunc('ft_table_add_row');
  Pointer(ft_table_delete_row) := BindFunc('ft_table_delete_row');
  Pointer(ft_table_clear_rows) := BindFunc('ft_table_clear_rows');
  Pointer(ft_table_clear_all) := BindFunc('ft_table_clear_all');
  Pointer(ft_table_get_row_count) := BindFunc('ft_table_get_row_count');
  Pointer(ft_table_set_cell) := BindFunc('ft_table_set_cell');
  Pointer(ft_table_get_cell) := BindFunc('ft_table_get_cell');
  Pointer(ft_table_set_cell_icon) := BindFunc('ft_table_set_cell_icon');
  Pointer(ft_table_get_cell_icon) := BindFunc('ft_table_get_cell_icon');
  Pointer(ft_table_set_selected_row) := BindFunc('ft_table_set_selected_row');
  Pointer(ft_table_get_selected_row) := BindFunc('ft_table_get_selected_row');
  Pointer(ft_table_set_multi_select) := BindFunc('ft_table_set_multi_select');
  Pointer(ft_table_get_multi_select) := BindFunc('ft_table_get_multi_select');
  Pointer(ft_table_is_row_selected) := BindFunc('ft_table_is_row_selected');
  Pointer(ft_table_set_row_selected) := BindFunc('ft_table_set_row_selected');
  Pointer(ft_table_select_all) := BindFunc('ft_table_select_all');
  Pointer(ft_table_clear_selection) := BindFunc('ft_table_clear_selection');
  Pointer(ft_table_get_selected_row_count) := BindFunc('ft_table_get_selected_row_count');
  Pointer(ft_table_get_selected_rows) := BindFunc('ft_table_get_selected_rows');
  Pointer(ft_table_set_header_height) := BindFunc('ft_table_set_header_height');
  Pointer(ft_table_get_header_height) := BindFunc('ft_table_get_header_height');
  Pointer(ft_table_set_row_height) := BindFunc('ft_table_set_row_height');
  Pointer(ft_table_get_row_height) := BindFunc('ft_table_get_row_height');
  Pointer(ft_table_set_show_gridlines) := BindFunc('ft_table_set_show_gridlines');
  Pointer(ft_table_get_show_gridlines) := BindFunc('ft_table_get_show_gridlines');
  Pointer(ft_table_set_zebra_striping) := BindFunc('ft_table_set_zebra_striping');
  Pointer(ft_table_get_zebra_striping) := BindFunc('ft_table_get_zebra_striping');
  Pointer(ft_table_on_select_row) := BindFunc('ft_table_on_select_row');
  Pointer(ft_table_on_row_double_click) := BindFunc('ft_table_on_row_double_click');
  Pointer(ft_table_on_draw_header) := BindFunc('ft_table_on_draw_header');
  Pointer(ft_table_on_draw_cell) := BindFunc('ft_table_on_draw_cell');

  { Bind File Dialogs }
  Pointer(ft_file_dialog_create) := BindFunc('ft_file_dialog_create');
  Pointer(ft_file_dialog_set_directory) := BindFunc('ft_file_dialog_set_directory');
  Pointer(ft_file_dialog_get_directory) := BindFunc('ft_file_dialog_get_directory');
  Pointer(ft_file_dialog_set_default_name) := BindFunc('ft_file_dialog_set_default_name');
  Pointer(ft_file_dialog_set_filter) := BindFunc('ft_file_dialog_set_filter');
  Pointer(ft_file_dialog_set_show_hidden) := BindFunc('ft_file_dialog_set_show_hidden');
  Pointer(ft_file_dialog_show_modal) := BindFunc('ft_file_dialog_show_modal');
  Pointer(ft_file_dialog_get_selected_path) := BindFunc('ft_file_dialog_get_selected_path');
  Pointer(ft_file_dialog_destroy) := BindFunc('ft_file_dialog_destroy');
  Pointer(ft_dialog_open_file) := BindFunc('ft_dialog_open_file');
  Pointer(ft_dialog_save_file) := BindFunc('ft_dialog_save_file');
  Pointer(ft_dialog_select_folder) := BindFunc('ft_dialog_select_folder');

  { Bind Message Dialogs }
  Pointer(ft_message_dialog_create) := BindFunc('ft_message_dialog_create');
  Pointer(ft_message_dialog_set_details) := BindFunc('ft_message_dialog_set_details');
  Pointer(ft_message_dialog_set_verification_text) := BindFunc('ft_message_dialog_set_verification_text');
  Pointer(ft_message_dialog_set_verification_checked) := BindFunc('ft_message_dialog_set_verification_checked');
  Pointer(ft_message_dialog_get_verification_checked) := BindFunc('ft_message_dialog_get_verification_checked');
  Pointer(ft_message_dialog_set_custom_icon_svg) := BindFunc('ft_message_dialog_set_custom_icon_svg');
  Pointer(ft_message_dialog_add_button) := BindFunc('ft_message_dialog_add_button');
  Pointer(ft_message_dialog_clear_buttons) := BindFunc('ft_message_dialog_clear_buttons');
  Pointer(ft_message_dialog_show_modal) := BindFunc('ft_message_dialog_show_modal');
  Pointer(ft_message_dialog_destroy) := BindFunc('ft_message_dialog_destroy');
  Pointer(ft_show_message) := BindFunc('ft_show_message');
  Pointer(ft_show_info) := BindFunc('ft_show_info');
  Pointer(ft_show_warning) := BindFunc('ft_show_warning');
  Pointer(ft_show_error) := BindFunc('ft_show_error');
  Pointer(ft_confirm) := BindFunc('ft_confirm');
  Pointer(ft_confirm_with_verification) := BindFunc('ft_confirm_with_verification');

  { Bind Drawing Area }
  Pointer(ft_drawingarea_create) := BindFunc('ft_drawingarea_create');
  Pointer(ft_drawingarea_set_cursor) := BindFunc('ft_drawingarea_set_cursor');
  Pointer(ft_drawingarea_get_cursor) := BindFunc('ft_drawingarea_get_cursor');
  Pointer(ft_drawingarea_set_clip_to_bounds) := BindFunc('ft_drawingarea_set_clip_to_bounds');
  Pointer(ft_drawingarea_on_paint) := BindFunc('ft_drawingarea_on_paint');
  Pointer(ft_drawingarea_on_mouse_down) := BindFunc('ft_drawingarea_on_mouse_down');
  Pointer(ft_drawingarea_on_mouse_up) := BindFunc('ft_drawingarea_on_mouse_up');
  Pointer(ft_drawingarea_on_mouse_move) := BindFunc('ft_drawingarea_on_mouse_move');
  Pointer(ft_drawingarea_on_mouse_wheel) := BindFunc('ft_drawingarea_on_mouse_wheel');
  Pointer(ft_drawingarea_on_mouse_enter) := BindFunc('ft_drawingarea_on_mouse_enter');
  Pointer(ft_drawingarea_on_mouse_leave) := BindFunc('ft_drawingarea_on_mouse_leave');
  Pointer(ft_drawingarea_on_key_down) := BindFunc('ft_drawingarea_on_key_down');
  Pointer(ft_drawingarea_on_key_up) := BindFunc('ft_drawingarea_on_key_up');
  Pointer(ft_drawingarea_on_resize) := BindFunc('ft_drawingarea_on_resize');

  { Bind Ruler }
  Pointer(ft_ruler_create) := BindFunc('ft_ruler_create');
  Pointer(ft_ruler_set_origin_and_scale) := BindFunc('ft_ruler_set_origin_and_scale');
  Pointer(ft_ruler_set_pointer_position) := BindFunc('ft_ruler_set_pointer_position');
  Pointer(ft_ruler_set_unit) := BindFunc('ft_ruler_set_unit');
  Pointer(ft_ruler_get_unit) := BindFunc('ft_ruler_get_unit');
  Pointer(ft_ruler_set_show_pointer) := BindFunc('ft_ruler_set_show_pointer');
  Pointer(ft_ruler_set_thickness) := BindFunc('ft_ruler_set_thickness');
  Pointer(ft_ruler_on_create_guide) := BindFunc('ft_ruler_on_create_guide');

  { Bind Number Scrubber }
  Pointer(ft_numberscrubber_create) := BindFunc('ft_numberscrubber_create');
  Pointer(ft_numberscrubber_set_value) := BindFunc('ft_numberscrubber_set_value');
  Pointer(ft_numberscrubber_get_value) := BindFunc('ft_numberscrubber_get_value');
  Pointer(ft_numberscrubber_set_range) := BindFunc('ft_numberscrubber_set_range');
  Pointer(ft_numberscrubber_set_step) := BindFunc('ft_numberscrubber_set_step');
  Pointer(ft_numberscrubber_set_decimals) := BindFunc('ft_numberscrubber_set_decimals');
  Pointer(ft_numberscrubber_set_suffix) := BindFunc('ft_numberscrubber_set_suffix');
  Pointer(ft_numberscrubber_set_prefix) := BindFunc('ft_numberscrubber_set_prefix');
  Pointer(ft_numberscrubber_on_change) := BindFunc('ft_numberscrubber_on_change');

  { Bind 2D Camera }
  Pointer(ft_camera2d_create) := BindFunc('ft_camera2d_create');
  Pointer(ft_camera2d_destroy) := BindFunc('ft_camera2d_destroy');
  Pointer(ft_camera2d_reset) := BindFunc('ft_camera2d_reset');
  Pointer(ft_camera2d_world_to_screen) := BindFunc('ft_camera2d_world_to_screen');
  Pointer(ft_camera2d_screen_to_world) := BindFunc('ft_camera2d_screen_to_world');
  Pointer(ft_camera2d_zoom_at) := BindFunc('ft_camera2d_zoom_at');
  Pointer(ft_camera2d_set_zoom_at) := BindFunc('ft_camera2d_set_zoom_at');
  Pointer(ft_camera2d_pan_by) := BindFunc('ft_camera2d_pan_by');
  Pointer(ft_camera2d_fit_rect) := BindFunc('ft_camera2d_fit_rect');
  Pointer(ft_camera2d_get_zoom) := BindFunc('ft_camera2d_get_zoom');
  Pointer(ft_camera2d_set_zoom) := BindFunc('ft_camera2d_set_zoom');
  Pointer(ft_camera2d_get_pan) := BindFunc('ft_camera2d_get_pan');
  Pointer(ft_camera2d_set_pan) := BindFunc('ft_camera2d_set_pan');
  Pointer(ft_camera2d_get_rotation) := BindFunc('ft_camera2d_get_rotation');
  Pointer(ft_camera2d_set_rotation) := BindFunc('ft_camera2d_set_rotation');

  { Bind Icons }
  Pointer(ft_icon_get_svg) := BindFunc('ft_icon_get_svg');
  Pointer(ft_icon_get_bitmap) := BindFunc('ft_icon_get_bitmap');
  Pointer(ft_icon_register) := BindFunc('ft_icon_register');
  Pointer(ft_icon_has) := BindFunc('ft_icon_has');
  Pointer(ft_icon_set_monochrome_colors) := BindFunc('ft_icon_set_monochrome_colors');

  { Bind GPU Batching & Rendering }
  Pointer(ft_gpu_is_available) := BindFunc('ft_gpu_is_available');
  Pointer(ft_window_set_direct_gpu_mode) := BindFunc('ft_window_set_direct_gpu_mode');
  Pointer(ft_window_on_mouse_down) := BindFunc('ft_window_on_mouse_down');
  Pointer(ft_window_on_mouse_up) := BindFunc('ft_window_on_mouse_up');
  Pointer(ft_window_on_mouse_move) := BindFunc('ft_window_on_mouse_move');
  Pointer(ft_window_on_key) := BindFunc('ft_window_on_key');
  Pointer(ft_window_on_resize) := BindFunc('ft_window_on_resize');
  Pointer(ft_window_on_close) := BindFunc('ft_window_on_close');
  Pointer(ft_batch_create) := BindFunc('ft_batch_create');
  Pointer(ft_batch_destroy) := BindFunc('ft_batch_destroy');
  Pointer(ft_batch_clear) := BindFunc('ft_batch_clear');
  Pointer(ft_batch_get_stats) := BindFunc('ft_batch_get_stats');
  Pointer(ft_batch_emit_rect) := BindFunc('ft_batch_emit_rect');
  Pointer(ft_batch_emit_textured_rect) := BindFunc('ft_batch_emit_textured_rect');
  Pointer(ft_batch_emit_rounded_rect) := BindFunc('ft_batch_emit_rounded_rect');
  Pointer(ft_batch_emit_box_shadow) := BindFunc('ft_batch_emit_box_shadow');
  Pointer(ft_batch_emit_linear_gradient) := BindFunc('ft_batch_emit_linear_gradient');
  Pointer(ft_batch_emit_path_mesh) := BindFunc('ft_batch_emit_path_mesh');
  Pointer(ft_tessmesh_create) := BindFunc('ft_tessmesh_create');
  Pointer(ft_tessmesh_destroy) := BindFunc('ft_tessmesh_destroy');
  Pointer(ft_tessmesh_clear) := BindFunc('ft_tessmesh_clear');
  Pointer(ft_tessmesh_get_counts) := BindFunc('ft_tessmesh_get_counts');
  Pointer(ft_tessellator_create) := BindFunc('ft_tessellator_create');
  Pointer(ft_tessellator_destroy) := BindFunc('ft_tessellator_destroy');
  Pointer(ft_tessellator_stroke_polyline) := BindFunc('ft_tessellator_stroke_polyline');
  Pointer(ft_tessellator_stroke_bezier) := BindFunc('ft_tessellator_stroke_bezier');
  Pointer(ft_tessellator_fill_polygon) := BindFunc('ft_tessellator_fill_polygon');
  Pointer(ft_renderer_create) := BindFunc('ft_renderer_create');
  Pointer(ft_renderer_destroy) := BindFunc('ft_renderer_destroy');
  Pointer(ft_renderer_begin) := BindFunc('ft_renderer_begin');
  Pointer(ft_renderer_end) := BindFunc('ft_renderer_end');
  Pointer(ft_renderer_get_batch) := BindFunc('ft_renderer_get_batch');
  Pointer(ft_renderer_get_tessellator) := BindFunc('ft_renderer_get_tessellator');

  Result := True;
end;

initialization
  FtLoadLib();

finalization
  FtUnloadLib();

end.
