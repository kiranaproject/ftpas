{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (Ft) — Object Pascal (ftpas) Test Suite                 }
{                                                                          }
{   Runs unit tests verifying OOP classes and libft.so interoperability.   }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

program TestRunner;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Math,
  fpcunit, testregistry, consoletestrunner,
  ftpas.api, ftpas.types, ftpas.canvas, ftpas.widget, ftpas.window,
  ftpas.controls, ftpas.layouts, ftpas.views, ftpas.creative,
  ftpas.dialogs, ftpas.menus, ftpas.app, ftpas.gpu,
  floriajs, ftpas.ftml, ftpas;

type
  { Test 1: Dynamic Library Loading & Function Binding }
  TLibraryLoadingTest = class(TTestCase)
  published
    procedure TestLibraryLoaded();
    procedure TestCoreBindingsAssigned();
  end;

  { Test 2: Application Controller & Theming }
  TAppAndThemeTest = class(TTestCase)
  published
    procedure TestAppSingleton();
    procedure TestScreenMetrics();
    procedure TestThemeProperties();
    procedure TestCornerRadius();
    procedure TestDarkModeToggle();
  end;

  { Test 3: Bitmap & Canvas Vector Graphics }
  TBitmapAndCanvasTest = class(TTestCase)
  published
    procedure TestBitmapCreation();
    procedure TestBitmapScaling();
    procedure TestCanvasWrapper();
  end;

  { Test 4: Widgets & Core Window Controls }
  TWidgetAndControlsTest = class(TTestCase)
  published
    procedure TestWindowCreation();
    procedure TestButtonProperties();
    procedure TestLabelAndEntry();
    procedure TestSwitchAndCheckBox();
    procedure TestWidgetHierarchy();
  end;

  { Test 5: Layout Containers & Size Group }
  TLayoutsTest = class(TTestCase)
  published
    procedure TestHBoxAndVBox();
    procedure TestFloatingBarProperties();
    procedure TestSizeGroup();
  end;

  { Test 6: Data Views (Table & TreeView) }
  TViewsTest = class(TTestCase)
  published
    procedure TestTableColumnsAndRows();
    procedure TestTreeViewNodes();
  end;

  { Test 7: Creative Tools Suite }
  TCreativeToolsTest = class(TTestCase)
  published
    procedure TestCamera2DTransform();
    procedure TestRulerProperties();
    procedure TestScrubberProperties();
  end;

  { Test 8: GPU Render Batch & Tessellator }
  TGPUTest = class(TTestCase)
  published
    procedure TestTessMesh();
    procedure TestRenderBatch();
  end;

  { Test 9: Declarative FTML Host, Bindings & Signals }
  TFTMLIntegrationTest = class(TTestCase)
  published
    procedure TestFTMLHostCreation();
    procedure TestFTMLLoadStringAndHierarchy();
    procedure TestFTMLReactivePropertyPropagation();
    procedure TestFTMLButtonClickSignalExecution();
    procedure TestFTMLHostFunctionInterop();
    procedure TestFTMLWindowLifecycle();
    procedure TestFTMLAnchorsAndGeometry();
    procedure TestFTMLFlexBoxAndGridContainers();
    procedure TestFTMLContainerAndPanel();
    procedure TestFTMLReadComponentRes();
  end;

{ TLibraryLoadingTest }

procedure TLibraryLoadingTest.TestLibraryLoaded();
begin
  if not FtIsLibLoaded() then
    AssertTrue('ftpas library should load', FtLoadLib());
  AssertTrue('Library must be loaded', FtIsLibLoaded());
end;

procedure TLibraryLoadingTest.TestCoreBindingsAssigned();
begin
  AssertTrue('ft_init must be assigned', Assigned(ft_init));
  AssertTrue('ft_quit must be assigned', Assigned(ft_quit));
  AssertTrue('ft_window_create must be assigned', Assigned(ft_window_create));
  AssertTrue('ft_button_create must be assigned', Assigned(ft_button_create));
  AssertTrue('ft_bitmap_create must be assigned', Assigned(ft_bitmap_create));
end;

{ TAppAndThemeTest }

procedure TAppAndThemeTest.TestAppSingleton();
var
  app1, app2: TFtApp;
begin
  app1 := FtApp();
  app2 := FtApp();
  AssertNotNull('FtApp must not be nil', app1);
  AssertTrue('FtApp must return same singleton instance', app1 = app2);
  AssertTrue('Application must be initialized', app1.Initialized);
end;

procedure TAppAndThemeTest.TestScreenMetrics();
var
  app: TFtApp;
  dpi: Double;
begin
  app := FtApp();
  AssertNotNull('FtApp must not be nil', app);
  dpi := app.ScreenDPI;
  AssertTrue('Screen DPI should be positive', dpi > 0.0);

  app.ScreenDPI := 120.0;
  AssertEquals('Screen DPI should update to 120', 120.0, app.ScreenDPI);
  app.ScreenDPI := dpi; { restore }
end;

procedure TAppAndThemeTest.TestThemeProperties();
var
  app: TFtApp;
  avail: string;
begin
  app := FtApp();
  avail := app.AvailableThemes;
  AssertTrue('Available themes string should exist', Length(avail) >= 0);
end;

procedure TAppAndThemeTest.TestCornerRadius();
var
  app: TFtApp;
  orig: Double;
begin
  app := FtApp();
  orig := app.CornerRadius;
  app.CornerRadius := 8.5;
  AssertEquals('Theme CornerRadius should be 8.5', 8.5, app.CornerRadius);
  app.CornerRadius := orig; { restore }
end;

procedure TAppAndThemeTest.TestDarkModeToggle();
var
  app: TFtApp;
  orig: Boolean;
begin
  app := FtApp();
  orig := app.DarkMode;
  app.DarkMode := True;
  AssertTrue('Dark mode should be enabled', app.DarkMode);
  app.DarkMode := False;
  AssertFalse('Dark mode should be disabled', app.DarkMode);
  app.DarkMode := orig; { restore }
end;

{ TBitmapAndCanvasTest }

procedure TBitmapAndCanvasTest.TestBitmapCreation();
var
  bmp: TFtBitmap;
begin
  bmp := TFtBitmap.Create(80, 60);
  try
    AssertNotNull('Bitmap instance must not be nil', bmp);
    AssertNotNull('Bitmap handle must not be nil', bmp.Handle);
    AssertEquals('Bitmap width must be 80', 80, bmp.Width);
    AssertEquals('Bitmap height must be 60', 60, bmp.Height);
    AssertTrue('Bitmap stride must be >= 320', bmp.Stride >= 320);
    AssertNotNull('Bitmap pixels must not be nil', bmp.Pixels);
  finally
    bmp.Free();
  end;
end;

procedure TBitmapAndCanvasTest.TestBitmapScaling();
var
  bmp, scaled: TFtBitmap;
begin
  bmp := TFtBitmap.Create(100, 100);
  try
    scaled := bmp.CreateScaled(50, 50);
    try
      AssertNotNull('Scaled bitmap should exist', scaled);
      AssertEquals('Scaled width must be 50', 50, scaled.Width);
      AssertEquals('Scaled height must be 50', 50, scaled.Height);
    finally
      scaled.Free();
    end;
  finally
    bmp.Free();
  end;
end;

procedure TBitmapAndCanvasTest.TestCanvasWrapper();
var
  c: TFtCanvas;
begin
  { Test canvas OOP wrapper resilience and method bindings }
  c := TFtCanvas.Create(nil);
  try
    AssertNotNull('Canvas instance should exist', c);
    c.DrawRect(0, 0, 100, 100, 1.0, 0.0, 0.0, 1.0);
    c.DrawRoundedRect(10, 10, 80, 80, 4.0, 0.0, 1.0, 0.0, 1.0);
    c.DrawLine(0, 0, 50, 50, 2.0, 0.0, 0.0, 1.0, 1.0);
    c.DrawCircle(25, 25, 10, 1.0, 1.0, 0.0, 1.0);
    c.PushClipRect(5, 5, 40, 40);
    c.PopClipRect();
    c.PushAlpha(0.7);
    c.PopAlpha();
  finally
    c.Free();
  end;
end;

{ TWidgetAndControlsTest }

procedure TWidgetAndControlsTest.TestWindowCreation();
var
  win: TFtWindow;
begin
  win := TFtWindow.Create(320, 240, 'Test Window');
  try
    AssertNotNull('Window handle should exist', win.Handle);
    AssertEquals('Window title should match', 'Test Window', win.Title);
    AssertEquals('Window width should be 320', 320, win.Width);
    AssertEquals('Window height should be 240', 240, win.Height);
    win.Title := 'Updated Title';
    AssertEquals('Window title should update', 'Updated Title', win.Title);
  finally
    win.Free();
  end;
end;

procedure TWidgetAndControlsTest.TestButtonProperties();
var
  win: TFtWindow;
  btn: TFtButton;
begin
  win := TFtWindow.Create(300, 200, 'BtnTest');
  try
    btn := TFtButton.Create(win, 10, 10, 120, 32, 'Submit');
    AssertNotNull('Button handle should exist', btn.Handle);
    AssertEquals('Button caption should match', 'Submit', btn.Caption);
    btn.Caption := 'Cancel';
    AssertEquals('Button caption should update', 'Cancel', btn.Caption);
    AssertTrue('Button should be enabled by default', btn.Enabled);
    btn.Enabled := False;
    AssertFalse('Button enabled should be false', btn.Enabled);
    btn.Enabled := True;
    AssertEquals('Button default alignment should be center', Ord(ftaCenter), Ord(btn.Alignment));
    btn.Alignment := ftaLeft;
    AssertEquals('Button alignment should update to left', Ord(ftaLeft), Ord(btn.Alignment));
    btn.Alignment := ftaRight;
    AssertEquals('Button alignment should update to right', Ord(ftaRight), Ord(btn.Alignment));
    AssertEquals('Button default padding_x should be 8.0', 8.0, btn.PaddingX);
    btn.PaddingX := 12.0;
    AssertEquals('Button padding_x should update to 12.0', 12.0, btn.PaddingX);
  finally
    win.Free();
  end;
end;

procedure TWidgetAndControlsTest.TestLabelAndEntry();
var
  win: TFtWindow;
  lbl: TFtLabel;
  entry: TFtEntry;
begin
  win := TFtWindow.Create(300, 200, 'CtrlTest');
  try
    lbl := TFtLabel.Create(win, 10, 10, 100, 24, 'Username:');
    AssertEquals('Label text should match', 'Username:', lbl.Text);
    lbl.Text := 'Email:';
    AssertEquals('Label text should update', 'Email:', lbl.Text);

    entry := TFtEntry.Create(win, 10, 40, 200, 30);
    AssertNotNull('Entry handle should exist', entry.Handle);
    entry.Text := 'alice@example.com';
    AssertEquals('Entry text should match', 'alice@example.com', entry.Text);
    entry.Placeholder := 'Enter email';
    AssertEquals('Entry placeholder should match', 'Enter email', entry.Placeholder);
  finally
    win.Free();
  end;
end;

procedure TWidgetAndControlsTest.TestSwitchAndCheckBox();
var
  win: TFtWindow;
  sw: TFtSwitch;
  cb: TFtCheckBox;
begin
  win := TFtWindow.Create(300, 200, 'ToggleTest');
  try
    sw := TFtSwitch.Create(win, 10, 10, 50, 24);
    AssertNotNull('Switch handle should exist', sw.Handle);
    sw.Checked := True;
    AssertTrue('Switch checked should be true', sw.Checked);
    sw.Checked := False;
    AssertFalse('Switch checked should be false', sw.Checked);

    cb := TFtCheckBox.Create(win, 10, 50, 120, 24, 'Accept Terms');
    AssertNotNull('CheckBox handle should exist', cb.Handle);
    AssertEquals('CheckBox caption should match', 'Accept Terms', cb.Caption);
    cb.Checked := True;
    AssertTrue('CheckBox checked should be true', cb.Checked);
    cb.Checked := False;
    AssertFalse('CheckBox checked should be false', cb.Checked);
  finally
    win.Free();
  end;
end;

procedure TWidgetAndControlsTest.TestWidgetHierarchy();
var
  win: TFtWindow;
  btn: TFtButton;
begin
  win := TFtWindow.Create(300, 200, 'HierarchyTest');
  try
    btn := TFtButton.Create(win, 10, 10, 80, 30, 'Child');
    AssertTrue('Button parent should be window', btn.Parent = win);
    btn.Tag := 12345;
    AssertEquals('Widget tag should match', 12345, btn.Tag);
  finally
    win.Free();
  end;
end;

{ TLayoutsTest }

procedure TLayoutsTest.TestHBoxAndVBox();
var
  win: TFtWindow;
  hbox: TFtHBox;
  vbox: TFtVBox;
  sp: TFtSpacer;
begin
  win := TFtWindow.Create(400, 300, 'LayoutTest');
  try
    hbox := TFtHBox.Create(win, 0, 0, 400, 50);
    hbox.Gap := 12.0;
    AssertEquals('HBox gap should be 12', 12.0, hbox.Gap);
    hbox.JustifyContent := ftjcSpaceBetween;
    AssertTrue('JustifyContent should be ftjcSpaceBetween', hbox.JustifyContent = ftjcSpaceBetween);

    sp := TFtSpacer.Create(hbox);
    AssertNotNull('Spacer handle should exist', sp.Handle);

    vbox := TFtVBox.Create(win, 0, 60, 200, 200);
    vbox.Gap := 6.0;
    AssertEquals('VBox gap should be 6', 6.0, vbox.Gap);
  finally
    win.Free();
  end;
end;

procedure TLayoutsTest.TestFloatingBarProperties();
var
  win: TFtWindow;
  bar: TFtFloatingBar;
  mx, my: Double;
begin
  win := TFtWindow.Create(500, 400, 'FloatingTest');
  try
    bar := TFtFloatingBar.Create(win, ftamBottomCenter, 240, 48);
    AssertNotNull('Floating bar handle should exist', bar.Handle);
    AssertTrue('Anchor should be ftamBottomCenter', bar.Anchor = ftamBottomCenter);
    bar.SetMargins(16.0, 20.0);
    bar.GetMargins(mx, my);
    AssertEquals('Margin X should be 16', 16.0, mx);
    AssertEquals('Margin Y should be 20', 20.0, my);
    bar.AutoAnchor := True;
    AssertTrue('AutoAnchor should be true', bar.AutoAnchor);
    bar.UpdateAnchor();
  finally
    win.Free();
  end;
end;

procedure TLayoutsTest.TestSizeGroup();
var
  win: TFtWindow;
  btn1, btn2: TFtButton;
  sg: TFtSizeGroup;
begin
  win := TFtWindow.Create(400, 300, 'SizeGroupTest');
  try
    btn1 := TFtButton.Create(win, 10, 10, 60, 30, 'Short');
    btn2 := TFtButton.Create(win, 10, 50, 140, 30, 'Much Longer Caption');

    sg := TFtSizeGroup.Create(ftsgHorizontal);
    try
      sg.Add(btn1);
      sg.Add(btn2);
      sg.Synchronize();
      sg.Remove(btn1);
    finally
      sg.Free();
    end;
  finally
    win.Free();
  end;
end;

{ TViewsTest }

procedure TViewsTest.TestTableColumnsAndRows();
var
  win: TFtWindow;
  tbl: TFtTable;
  rIdx: Integer;
begin
  win := TFtWindow.Create(400, 300, 'TableTest');
  try
    tbl := TFtTable.Create(win, 10, 10, 380, 260);
    tbl.AddColumn('ID', 50.0);
    tbl.AddColumn('Name', 150.0);
    tbl.AddColumn('Role', 120.0);
    AssertEquals('Table column count should be 3', 3, tbl.ColumnCount);

    rIdx := tbl.AddRow();
    tbl.SetCell(rIdx, 0, '1');
    tbl.SetCell(rIdx, 1, 'Alice');
    tbl.SetCell(rIdx, 2, 'Admin');
    AssertEquals('Table row count should be 1', 1, tbl.RowCount);
    AssertEquals('Cell text should match', 'Alice', tbl.GetCell(rIdx, 1));
  finally
    win.Free();
  end;
end;

procedure TViewsTest.TestTreeViewNodes();
var
  win: TFtWindow;
  tree: TFtTreeView;
  rootNode, childNode: TFtTreeNode;
begin
  win := TFtWindow.Create(300, 400, 'TreeTest');
  try
    tree := TFtTreeView.Create(win, 10, 10, 280, 360);
    rootNode := tree.AddRoot('Documents');
    AssertNotNull('Root node should exist', rootNode);
    AssertEquals('Node text should match', 'Documents', rootNode.Text);

    childNode := rootNode.AddChild('Projects');
    AssertNotNull('Child node should exist', childNode);
    AssertEquals('Child node text should match', 'Projects', childNode.Text);

    rootNode.Expanded := True;
    AssertTrue('Root node should be expanded', rootNode.Expanded);
    rootNode.Expanded := False;
    AssertFalse('Root node should be collapsed', rootNode.Expanded);
  finally
    win.Free();
  end;
end;

{ TCreativeToolsTest }

procedure TCreativeToolsTest.TestCamera2DTransform();
var
  cam: TFtCamera2D;
  sx, sy, wx, wy: Double;
begin
  cam := TFtCamera2D.Create();
  try
    cam.SetPan(100.0, 50.0);
    cam.Zoom := 2.0;

    cam.WorldToScreen(0.0, 0.0, sx, sy);
    cam.ScreenToWorld(sx, sy, wx, wy);
    AssertTrue('Roundtrip X should match within epsilon', Abs(wx - 0.0) < 0.01);
    AssertTrue('Roundtrip Y should match within epsilon', Abs(wy - 0.0) < 0.01);
  finally
    cam.Free();
  end;
end;

procedure TCreativeToolsTest.TestRulerProperties();
var
  win: TFtWindow;
  ruler: TFtRuler;
begin
  win := TFtWindow.Create(400, 300, 'RulerTest');
  try
    ruler := TFtRuler.Create(win, ftroHorizontal, 0, 0, 400, 24);
    AssertNotNull('Ruler handle should exist', ruler.Handle);
    ruler.SetOriginAndScale(50.0, 1.5);
    ruler.Thickness := 28;
    ruler.ShowPointer := True;
    ruler.UnitKind := ftruPixels;
    AssertTrue('Ruler UnitKind should be ftruPixels', ruler.UnitKind = ftruPixels);
  finally
    win.Free();
  end;
end;

procedure TCreativeToolsTest.TestScrubberProperties();
var
  win: TFtWindow;
  scrub: TFtNumberScrubber;
begin
  win := TFtWindow.Create(300, 200, 'ScrubTest');
  try
    scrub := TFtNumberScrubber.Create(win, 10, 10, 120, 28, 'Radius');
    AssertNotNull('Scrubber handle should exist', scrub.Handle);
    scrub.SetRange(0.0, 100.0);
    scrub.Decimals := 1;
    scrub.Value := 42.0;
    AssertEquals('Scrubber initial value should be 42', 42.0, scrub.Value);
    scrub.Value := 75.5;
    AssertEquals('Scrubber value should update', 75.5, scrub.Value);
    scrub.Suffix := ' px';
  finally
    win.Free();
  end;
end;

{ TGPUTest }

procedure TGPUTest.TestTessMesh();
var
  mesh: TFtTessMesh;
begin
  mesh := TFtTessMesh.Create();
  try
    AssertNotNull('Mesh handle should exist', mesh.Handle);
    AssertEquals('Initial vertex count should be 0', 0, mesh.VertexCount);
    AssertEquals('Initial index count should be 0', 0, mesh.IndexCount);
  finally
    mesh.Free();
  end;
end;

procedure TGPUTest.TestRenderBatch();
var
  batch: TFtRenderBatch;
  stats: TFtBatchStats;
begin
  batch := TFtRenderBatch.Create();
  try
    AssertNotNull('Batch handle should exist', batch.Handle);
    batch.Clear();
    batch.EmitRect(10, 10, 100, 50, $FF0000FF, 0);
    stats := batch.GetStats();
    AssertTrue('Draw calls or vertices should be updated', (stats.draw_calls > 0) or (stats.vertex_count > 0));
  finally
    batch.Free();
  end;
end;

{ TFTMLIntegrationTest }

function HostNativeAdd(const AArgs: array of TFloriaJSValue; AThis: TFloriaJSValue): TFloriaJSValue;
begin
  if Length(AArgs) >= 2 then
    Result := JSMakeNumber(AArgs[0].ToNumber() + AArgs[1].ToNumber())
  else
    Result := JSMakeNumber(0.0);
end;

procedure TFTMLIntegrationTest.TestFTMLHostCreation();
var
  win: TFtWindow;
  host: TFtFTMLHost;
begin
  win := TFtWindow.Create(400, 300, 'Test Win');
  try
    host := TFtFTMLHost.Create(win, 0, 0, 400, 300);
    AssertNotNull('Host engine should be initialized', host.Engine);
    AssertNull('Initial RootItem is nil', host.RootItem);
    AssertNull('Initial RootWidget is nil', host.RootWidget);
    AssertFalse('Should have no errors', host.HasErrors);
  finally
    win.Free();
  end;
end;

procedure TFTMLIntegrationTest.TestFTMLLoadStringAndHierarchy();
var
  win: TFtWindow;
  host: TFtFTMLHost;
  root: TFloriaFTMLItem;
  cardW, titleW, btnW: TFtWidget;
const
  SRC =
    'Rectangle {' + LineEnding +
    '  id: mainCard;' + LineEnding +
    '  width: 300; height: 200;' + LineEnding +
    '  radius: 8;' + LineEnding +
    '  color: "#222233";' + LineEnding +
    '  Text {' + LineEnding +
    '    id: titleLabel;' + LineEnding +
    '    text: "Welcome to FTML";' + LineEnding +
    '  }' + LineEnding +
    '  Button {' + LineEnding +
    '    id: actionBtn;' + LineEnding +
    '    text: "Click Here";' + LineEnding +
    '  }' + LineEnding +
    '}';
begin
  win := TFtWindow.Create(400, 300, 'Test Win');
  try
    host := TFtFTMLHost.Create(win, 0, 0, 400, 300);
    root := host.LoadString(SRC);
    AssertNotNull('Root item returned', root);
    AssertEquals('Root item type', 'Rectangle', root.TypeName);
    AssertEquals('Root item ID', 'mainCard', root.Id);

    cardW := host.FindWidget('mainCard');
    AssertNotNull('Found mainCard widget', cardW);
    AssertTrue('mainCard is TFtContainer', cardW is TFtContainer);
    AssertEquals('Container radius', 8.0, TFtContainer(cardW).CornerRadius, 0.001);

    titleW := host.FindWidget('titleLabel');
    AssertNotNull('Found titleLabel widget', titleW);
    AssertTrue('titleLabel is TFtLabel', titleW is TFtLabel);
    AssertEquals('titleLabel text', 'Welcome to FTML', TFtLabel(titleW).Text);

    btnW := host.FindWidget('actionBtn');
    AssertNotNull('Found actionBtn widget', btnW);
    AssertTrue('actionBtn is TFtButton', btnW is TFtButton);
    AssertEquals('actionBtn caption', 'Click Here', TFtButton(btnW).Caption);
  finally
    win.Free();
  end;
end;

procedure TFTMLIntegrationTest.TestFTMLReactivePropertyPropagation();
var
  win: TFtWindow;
  host: TFtFTMLHost;
  root: TFloriaFTMLItem;
  labelW: TFtWidget;
const
  SRC =
    'Rectangle {' + LineEnding +
    '  id: root;' + LineEnding +
    '  property string statusMsg: "Initializing";' + LineEnding +
    '  Text {' + LineEnding +
    '    id: statusLbl;' + LineEnding +
    '    text: "Status: " + root.statusMsg;' + LineEnding +
    '  }' + LineEnding +
    '}';
begin
  win := TFtWindow.Create(400, 300, 'Test Win');
  try
    host := TFtFTMLHost.Create(win, 0, 0, 400, 300);
    root := host.LoadString(SRC);
    AssertNotNull('Root item', root);

    labelW := host.FindWidget('statusLbl');
    AssertNotNull('Found statusLbl', labelW);
    AssertEquals('Initial label text', 'Status: Initializing', TFtLabel(labelW).Text);

    // Update statusMsg on root
    root.SetProperty('statusMsg', JSMakeString('Ready'));
    host.SyncProperties();
    AssertEquals('Updated label text', 'Status: Ready', TFtLabel(labelW).Text);
  finally
    win.Free();
  end;
end;

procedure TFTMLIntegrationTest.TestFTMLButtonClickSignalExecution();
var
  win: TFtWindow;
  host: TFtFTMLHost;
  root: TFloriaFTMLItem;
  btnW, countW: TFtWidget;
const
  SRC =
    'Rectangle {' + LineEnding +
    '  id: counterRoot;' + LineEnding +
    '  property int count: 0;' + LineEnding +
    '  Button {' + LineEnding +
    '    id: incBtn;' + LineEnding +
    '    text: "Add";' + LineEnding +
    '    onClicked: {' + LineEnding +
    '      counterRoot.count = counterRoot.count + 1;' + LineEnding +
    '    }' + LineEnding +
    '  }' + LineEnding +
    '  Text {' + LineEnding +
    '    id: countLbl;' + LineEnding +
    '    text: "Count: " + counterRoot.count;' + LineEnding +
    '  }' + LineEnding +
    '}';
begin
  win := TFtWindow.Create(400, 300, 'Test Win');
  try
    host := TFtFTMLHost.Create(win, 0, 0, 400, 300);
    root := host.LoadString(SRC);
    AssertNotNull('Loaded root', root);

    btnW := host.FindWidget('incBtn');
    countW := host.FindWidget('countLbl');
    AssertNotNull('btn found', btnW);
    AssertNotNull('countLbl found', countW);
    AssertEquals('Initial count text', 'Count: 0', TFtLabel(countW).Text);

    // Simulate clicking button through FTML emit signal
    host.EmitItemSignal(host.FindItem('incBtn'), 'clicked');
    AssertEquals('Count text after 1st click', 'Count: 1', TFtLabel(countW).Text);
    AssertEquals('Property value', 1.0, root.GetPropertyAsNumber('count'), 0.001);

    host.EmitItemSignal(host.FindItem('incBtn'), 'clicked');
    AssertEquals('Count text after 2nd click', 'Count: 2', TFtLabel(countW).Text);
    AssertEquals('Property value', 2.0, root.GetPropertyAsNumber('count'), 0.001);
  finally
    win.Free();
  end;
end;

procedure TFTMLIntegrationTest.TestFTMLHostFunctionInterop();
var
  win: TFtWindow;
  host: TFtFTMLHost;
  val: TFloriaJSValue;
begin
  win := TFtWindow.Create(400, 300, 'Test Win');
  try
    host := TFtFTMLHost.Create(win, 0, 0, 400, 300);
    host.RegisterFunction('addNumbers', @HostNativeAdd);
    val := host.Evaluate('addNumbers(17, 25);');
    AssertTrue('Result is number', val.IsNumber());
    AssertEquals('17 + 25 = 42', 42.0, val.NumVal, 0.001);
  finally
    win.Free();
  end;
end;

procedure TFTMLIntegrationTest.TestFTMLWindowLifecycle();
var
  ftmlWin: TFtFTMLWindow;
  root: TFloriaFTMLItem;
  bgW: TFtWidget;
begin
  ftmlWin := TFtFTMLWindow.Create(600, 400, 'Declarative FTML Window');
  try
    root := ftmlWin.LoadString('Rectangle { id: bgView; width: parent.width; height: parent.height; }');
    AssertNotNull('Root loaded into window', root);
    bgW := ftmlWin.FindWidget('bgView');
    AssertNotNull('Found bgView widget in window', bgW);

    // Test resize delegation
    ftmlWin.SetBounds(0, 0, 800, 500);
    AssertEquals('Host width updated', 800, ftmlWin.Host.Width);
    AssertEquals('Host height updated', 500, ftmlWin.Host.Height);
  finally
    ftmlWin.Free();
  end;
end;

procedure TFTMLIntegrationTest.TestFTMLAnchorsAndGeometry();
var
  win: TFtWindow;
  host: TFtFTMLHost;
  root: TFloriaFTMLItem;
  headerW, bodyW: TFtWidget;
const
  SRC =
    'Rectangle {' + LineEnding +
    '  id: rootCard;' + LineEnding +
    '  width: 600; height: 400;' + LineEnding +
    '  Rectangle {' + LineEnding +
    '    id: header;' + LineEnding +
    '    anchors.top: parent.top;' + LineEnding +
    '    anchors.left: parent.left;' + LineEnding +
    '    anchors.right: parent.right;' + LineEnding +
    '    anchors.margins: 20;' + LineEnding +
    '    height: 80;' + LineEnding +
    '  }' + LineEnding +
    '  Rectangle {' + LineEnding +
    '    id: body;' + LineEnding +
    '    anchors.top: header.bottom;' + LineEnding +
    '    anchors.left: parent.left;' + LineEnding +
    '    anchors.right: parent.right;' + LineEnding +
    '    anchors.bottom: parent.bottom;' + LineEnding +
    '    anchors.margins: 20;' + LineEnding +
    '    anchors.topMargin: 10;' + LineEnding +
    '  }' + LineEnding +
    '}';
begin
  win := TFtWindow.Create(600, 400, 'Test Anchors');
  try
    host := TFtFTMLHost.Create(win, 0, 0, 600, 400);
    root := host.LoadString(SRC);
    AssertNotNull('Loaded root', root);

    headerW := host.FindWidget('header');
    AssertNotNull('Header widget found', headerW);
    // Header bounds: x = 20, y = 20, width = 600 - 20 - 20 = 560, height = 80
    AssertEquals('Header X', 20, headerW.X);
    AssertEquals('Header Y', 20, headerW.Y);
    AssertEquals('Header Width', 560, headerW.Width);
    AssertEquals('Header Height', 80, headerW.Height);

    bodyW := host.FindWidget('body');
    AssertNotNull('Body widget found', bodyW);
    // Body bounds: x = 20, y = 20 + 80 + 10 = 110, width = 560, height = 400 - 20 - 110 = 270
    AssertEquals('Body X', 20, bodyW.X);
    AssertEquals('Body Y', 110, bodyW.Y);
    AssertEquals('Body Width', 560, bodyW.Width);
    AssertEquals('Body Height', 270, bodyW.Height);
  finally
    win.Free();
  end;
end;

procedure TFTMLIntegrationTest.TestFTMLFlexBoxAndGridContainers();
var
  win: TFtWindow;
  host: TFtFTMLHost;
  root: TFloriaFTMLItem;
  flexW, gridW, btn1W, cellW: TFtWidget;
const
  SRC =
    'Rectangle {' + LineEnding +
    '  id: container;' + LineEnding +
    '  width: 500; height: 500;' + LineEnding +
    '  FlexBox {' + LineEnding +
    '    id: myFlex;' + LineEnding +
    '    direction: "row";' + LineEnding +
    '    wrap: "wrap";' + LineEnding +
    '    justifyContent: "space-between";' + LineEnding +
    '    gap: 12;' + LineEnding +
    '    Button {' + LineEnding +
    '      id: flexBtn1;' + LineEnding +
    '      text: "F1";' + LineEnding +
    '      flexGrow: 2.0;' + LineEnding +
    '      alignSelf: "center";' + LineEnding +
    '    }' + LineEnding +
    '  }' + LineEnding +
    '  Grid {' + LineEnding +
    '    id: myGrid;' + LineEnding +
    '    columns: 3; rows: 2;' + LineEnding +
    '    columnGap: 8; rowGap: 16;' + LineEnding +
    '    Rectangle {' + LineEnding +
    '      id: gridCell1;' + LineEnding +
    '      gridColumn: 1; gridRow: 0; colSpan: 2;' + LineEnding +
    '    }' + LineEnding +
    '  }' + LineEnding +
    '}';
begin
  win := TFtWindow.Create(500, 500, 'Test Layouts');
  try
    host := TFtFTMLHost.Create(win, 0, 0, 500, 500);
    root := host.LoadString(SRC);
    AssertNotNull('Loaded root', root);

    flexW := host.FindWidget('myFlex');
    AssertNotNull('FlexBox found', flexW);
    AssertTrue('flexW is TFtFlexBox', flexW is TFtFlexBox);
    AssertTrue('Direction is ftfdRow', TFtFlexBox(flexW).Direction = ftfdRow);
    AssertTrue('Wrap is ftfwWrap', TFtFlexBox(flexW).Wrap = ftfwWrap);
    AssertTrue('JustifyContent is ftjcSpaceBetween', TFtFlexBox(flexW).JustifyContent = ftjcSpaceBetween);
    AssertEquals('Gap is 12', 12.0, TFtFlexBox(flexW).Gap, 0.001);

    btn1W := host.FindWidget('flexBtn1');
    AssertNotNull('flexBtn1 found', btn1W);
    AssertEquals('Button flexGrow', 2.0, btn1W.FlexGrow, 0.001);
    AssertTrue('Button alignSelf', btn1W.AlignSelf = ftasCenter);

    gridW := host.FindWidget('myGrid');
    AssertNotNull('Grid found', gridW);
    AssertTrue('gridW is TFtGrid', gridW is TFtGrid);
    AssertEquals('Grid columns', 3, TFtGrid(gridW).ColumnCount);
    AssertEquals('Grid rows', 2, TFtGrid(gridW).RowCount);

    cellW := host.FindWidget('gridCell1');
    AssertNotNull('gridCell1 found', cellW);
  finally
    win.Free();
  end;
end;

procedure TFTMLIntegrationTest.TestFTMLContainerAndPanel();
var
  win: TFtWindow;
  host: TFtFTMLHost;
  root: TFloriaFTMLItem;
  contW, panW, rectW: TFtWidget;
const
  SRC =
    'Container {' + LineEnding +
    '  id: rootContainer;' + LineEnding +
    '  width: 500; height: 400;' + LineEnding +
    '  Container {' + LineEnding +
    '    id: childBox;' + LineEnding +
    '    width: 200; height: 100;' + LineEnding +
    '  }' + LineEnding +
    '  Panel {' + LineEnding +
    '    id: childPanel;' + LineEnding +
    '    width: 200; height: 100;' + LineEnding +
    '    radius: 8;' + LineEnding +
    '  }' + LineEnding +
    '  Rectangle {' + LineEnding +
    '    id: childRect;' + LineEnding +
    '    width: 100; height: 50;' + LineEnding +
    '  }' + LineEnding +
    '}';
begin
  win := TFtWindow.Create(500, 400, 'Test Container Panel');
  try
    host := TFtFTMLHost.Create(win, 0, 0, 500, 400);
    // Root container must be transparent (DrawFrame = False)
    AssertFalse('Host DrawFrame is False', host.DrawFrame);

    root := host.LoadString(SRC);
    AssertNotNull('Root item parsed', root);
    AssertEquals('Root item type', 'Container', root.TypeName);

    // Child Container: transparent (DrawFrame = False)
    contW := host.FindWidget('childBox');
    AssertNotNull('childBox widget found', contW);
    AssertTrue('childBox is TFtContainer', contW is TFtContainer);
    AssertFalse('childBox is not TFtPanel', contW is TFtPanel);
    AssertFalse('childBox DrawFrame is False', TFtContainer(contW).DrawFrame);

    // Child Panel: styled (DrawFrame = True, is TFtPanel)
    panW := host.FindWidget('childPanel');
    AssertNotNull('childPanel widget found', panW);
    AssertTrue('childPanel is TFtPanel', panW is TFtPanel);
    AssertTrue('childPanel DrawFrame is True', TFtPanel(panW).DrawFrame);
    AssertEquals('childPanel radius is 8.0', 8.0, TFtPanel(panW).CornerRadius, 0.001);

    // Child Rectangle: flat shape (DrawFrame = False)
    rectW := host.FindWidget('childRect');
    AssertNotNull('childRect widget found', rectW);
    AssertTrue('childRect is TFtContainer', rectW is TFtContainer);
    AssertFalse('childRect is not TFtPanel', rectW is TFtPanel);
    AssertFalse('childRect DrawFrame is False', TFtContainer(rectW).DrawFrame);
  finally
    win.Free();
  end;
end;

procedure TFTMLIntegrationTest.TestFTMLReadComponentRes();
const
  RES_MARKUP =
    'Container {' + LineEnding +
    '  id: testResRoot;' + LineEnding +
    '  width: 450; height: 350;' + LineEnding +
    '  Button {' + LineEnding +
    '    id: testResBtn;' + LineEnding +
    '    text: "Resource Button";' + LineEnding +
    '  }' + LineEnding +
    '}';
var
  src: string;
  form: TFtFTMLForm;
  btn: TFtWidget;
begin
  // Non-existent design returns false
  AssertFalse('Non-existent design returns False', ReadComponentRes('TNonExistentDesign', src));

  // Register in-memory FTML resource
  RegisterFTMLResource('TTestFormRes', 'test_form.ftml', PChar(RES_MARKUP), Length(RES_MARKUP));

  // ReadComponentRes loads raw string
  AssertTrue('ReadComponentRes loads registered design', ReadComponentRes('TTestFormRes', src));
  AssertEquals('Loaded string matches markup', RES_MARKUP, src);

  // TFtFTMLForm creates window and resolves via ReadComponentRes
  form := TFtFTMLForm.Create(450, 350, 'Resource Bound Form', 'TTestFormRes');
  try
    AssertEquals('Form design name', 'TTestFormRes', form.DesignName);
    AssertNotNull('Form root item exists', form.RootItem);
    btn := form.FindWidget('testResBtn');
    AssertNotNull('Widget from resource found', btn);
    AssertTrue('Widget is TFtButton', btn is TFtButton);
    AssertEquals('Button text matches', 'Resource Button', TFtButton(btn).Caption);

    // Explicit ReadComponentRes call on form instance
    AssertTrue('Explicit ReadComponentRes call succeeds', form.ReadComponentRes('TTestFormRes'));
  finally
    form.Free();
  end;
end;

var
  Application: TTestRunner;

begin
  Application := TTestRunner.Create(nil);
  try
    RegisterTest(TLibraryLoadingTest);
    RegisterTest(TAppAndThemeTest);
    RegisterTest(TBitmapAndCanvasTest);
    RegisterTest(TWidgetAndControlsTest);
    RegisterTest(TLayoutsTest);
    RegisterTest(TViewsTest);
    RegisterTest(TCreativeToolsTest);
    RegisterTest(TGPUTest);
    RegisterTest(TFTMLIntegrationTest);
    Application.Initialize;
    Application.Run;
  finally
    Application.Free;
  end;
end.
