# ftpas — Floria Toolkit Object Pascal (FPC) OOP Binding

**ftpas** provides an idiomatic, strongly-typed, Object-Oriented (OOP) Free Pascal binding and wrapper around **Floria Toolkit** (`libft.so`), targeting premier native Linux **X11/XCB** desktop experiences.

---

## Architecture & Unit Hierarchy

`ftpas` is organized into a modular unit hierarchy. You can import individual units or simply `uses ftpas;` for single-unit convenience:

| Unit | Purpose | Key Classes & Types |
| :--- | :--- | :--- |
| **[`ftpas.api`](src/main/pascal/ftpas.api.pas)** | C ABI function pointers, dynamic library loader (`dynlibs`) | `FtLoadLib`, `FtUnloadLib`, `FtIsLibLoaded` |
| **[`ftpas.types`](src/main/pascal/ftpas.types.pas)** | Typed enums, geometry records, colors | `TFtRect`, `TFtColor`, `TFtButtonState`, `TFtAnchorMode` |
| **[`ftpas.app`](src/main/pascal/ftpas.app.pas)** | Application lifecycle, display, theme, clipboard | `TFtApp`, `FtApp` |
| **[`ftpas.canvas`](src/main/pascal/ftpas.canvas.pas)** | 2D vector graphics & raster images | `TFtCanvas`, `TFtBitmap` |
| **[`ftpas.widget`](src/main/pascal/ftpas.widget.pas)** | Base widget class & global registry | `TFtWidget`, `TFtWidgetRegistry` |
| **[`ftpas.window`](src/main/pascal/ftpas.window.pas)** | Top-level windows, EGL hardware mode | `TFtWindow` |
| **[`ftpas.controls`](src/main/pascal/ftpas.controls.pas)** | Standard desktop interactive controls | `TFtButton`, `TFtSwitch`, `TFtCheckBox`, `TFtEntry`, `TFtSlider` |
| **[`ftpas.layouts`](src/main/pascal/ftpas.layouts.pas)** | Flexbox, grid, floating bars, notebooks | `TFtHBox`, `TFtVBox`, `TFtFloatingBar`, `TFtGrid`, `TFtNotebook`, `TFtSizeGroup` |
| **[`ftpas.views`](src/main/pascal/ftpas.views.pas)** | DataGrid table & hierarchical TreeView | `TFtTable`, `TFtTreeView`, `TFtTreeNode` |
| **[`ftpas.creative`](src/main/pascal/ftpas.creative.pas)** | Creative suite & canvas manipulation | `TFtDrawingArea`, `TFtRuler`, `TFtNumberScrubber`, `TFtCamera2D` |
| **[`ftpas.dialogs`](src/main/pascal/ftpas.dialogs.pas)** | Native dialogs (File & Message alerts) | `TFtFileDialog`, `TFtMessageDialog` |
| **[`ftpas.menus`](src/main/pascal/ftpas.menus.pas)** | Main menu bar & context popup menus | `TFtMainMenu`, `TFtPopupMenu`, `TFtMenuItem` |
| **[`ftpas.gpu`](src/main/pascal/ftpas.gpu.pas)** | GPU render batches & path tessellation | `TFtRenderBatch`, `TFtGPUTessellator`, `TFtTessMesh`, `TFtGPURenderer` |
| **[`ftpas`](src/main/pascal/ftpas.pas)** | Umbrella unit re-exporting all core symbols | Single-unit inclusion (`uses ftpas;`) |

---

## Quickstart

`ftpas` follows standard Object Pascal / Lazarus LCL principles: windows subclass `TFtWindow` (like `TForm` in LCL), and child widgets are declared as fields of the window with `Self` passed as their parent.

```pascal
program hello_world;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, ftpas, ftpas.types;

type
  { THelloWindow — Main application window (like TForm in LCL) }
  THelloWindow = class(TFtWindow)
  private
    FLabel: TFtLabel;
    FButton: TFtButton;
    procedure HandleButtonClick(Sender: TFtButton);
  public
    constructor Create(); reintroduce;
  end;

constructor THelloWindow.Create();
begin
  inherited Create(480, 320, 'Floria Toolkit — Hello World');
  
  { Child widgets declare Self (Window) as their parent container }
  FLabel := TFtLabel.Create(Self, 40, 60, 400, 36, 'Welcome to ftpas!');
  FLabel.Alignment := ftaCenter;

  FButton := TFtButton.Create(Self, 160, 140, 160, 42, 'Click Me!');
  FButton.OnClick := @HandleButtonClick;
end;

procedure THelloWindow.HandleButtonClick(Sender: TFtButton);
begin
  TFtMessageDialog.ShowInfo('Greeting', 'Success!', 'Hello from Floria Toolkit (ftpas)!');
end;

var
  MainWindow: THelloWindow;

begin
  MainWindow := THelloWindow.Create();
  try
    MainWindow.Show();
    FtApp.Run();
  finally
    MainWindow.Free();
  end;
end.
```

---

## Building & Testing

`ftpas` is built with **[PasBuild](https://github.com/graemeg/pasbuild)** using `project.xml`.

### 1. Compile Library
```bash
pasbuild compile
# or
./build.sh compile
```

### 2. Run Test Suite
```bash
pasbuild test
# or
./build.sh test
```

### 3. Build & Run Examples
```bash
./build.sh examples
# Run any example:
./examples/hello_world
./examples/form_controls
./examples/floating_navbar
```

---

## License

MPL-2.0. Copyright (c) 2026 Dio Affriza.
