{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (ftpas) — Extended Client Area (ECA) Browser Demo       }
{                                                                          }
{   Demonstrates building an Extended Client Area desktop window with      }
{   declarative FTML markup, reactive controls insets binding, tab strip   }
{   integration, and SSD/ECA dynamic toggling.                             }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

program eca_browser_demo;

{$mode objfpc}{$H+}
{$interfaces corba}

uses
  Classes, SysUtils, ftpas;

const
  BROWSER_FTML =
    'Window {' + LineEnding +
    '  id: mainWindow;' + LineEnding +
    '  width: 960; height: 600;' + LineEnding +
    '  title: "Floria Toolkit (ftpas) — ECA Browser Demo";' + LineEnding +
    '  extendedClientArea: true;' + LineEnding +
    '  color: "#1e1e2e";' + LineEnding +
    '  property int activeTabIndex: 0;' + LineEnding +
    '  property int counterClicks: 0;' + LineEnding +
    '  property string currentUrl: "https://floria.dev/docs/eca-protocol";' + LineEnding +
    LineEnding +
    '  /* Top Bar: Aligned horizontally alongside window controls */' + LineEnding +
    '  Rectangle {' + LineEnding +
    '    id: topBar;' + LineEnding +
    '    anchors.top: parent.top;' + LineEnding +
    '    anchors.left: parent.left;' + LineEnding +
    '    anchors.right: parent.right;' + LineEnding +
    '    height: 42;' + LineEnding +
    '    color: "#181825";' + LineEnding +
    LineEnding +
    '    /* Tabs Strip: Offset by controlsInsetLeft to avoid overlapping server buttons */' + LineEnding +
    '    Row {' + LineEnding +
    '      id: tabStrip;' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.leftMargin: mainWindow.controlsInsetLeft + 8;' + LineEnding +
    '      anchors.verticalCenter: parent.verticalCenter;' + LineEnding +
    '      height: 32;' + LineEnding +
    '      spacing: 6;' + LineEnding +
    LineEnding +
    '      Button {' + LineEnding +
    '        id: tab1;' + LineEnding +
    '        width: 130; height: 32;' + LineEnding +
    '        text: "ECA Protocol Spec";' + LineEnding +
    '        onClicked: {' + LineEnding +
    '          mainWindow.activeTabIndex = 0;' + LineEnding +
    '          mainWindow.currentUrl = "https://floria.dev/docs/eca-protocol";' + LineEnding +
    '        }' + LineEnding +
    '      }' + LineEnding +
    LineEnding +
    '      Button {' + LineEnding +
    '        id: tab2;' + LineEnding +
    '        width: 130; height: 32;' + LineEnding +
    '        text: "ftpas Framework";' + LineEnding +
    '        onClicked: {' + LineEnding +
    '          mainWindow.activeTabIndex = 1;' + LineEnding +
    '          mainWindow.currentUrl = "https://floria.dev/ftpas/overview";' + LineEnding +
    '        }' + LineEnding +
    '      }' + LineEnding +
    LineEnding +
    '      Button {' + LineEnding +
    '        id: tab3;' + LineEnding +
    '        width: 130; height: 32;' + LineEnding +
    '        text: "Window Manager";' + LineEnding +
    '        onClicked: {' + LineEnding +
    '          mainWindow.activeTabIndex = 2;' + LineEnding +
    '          mainWindow.currentUrl = "https://floria.dev/wmsama/architecture";' + LineEnding +
    '        }' + LineEnding +
    '      }' + LineEnding +
    '    }' + LineEnding +
    '  }' + LineEnding +
    LineEnding +
    '  /* Navigation & Omnibox Bar */' + LineEnding +
    '  Rectangle {' + LineEnding +
    '    id: navBar;' + LineEnding +
    '    anchors.top: topBar.bottom;' + LineEnding +
    '    anchors.left: parent.left;' + LineEnding +
    '    anchors.right: parent.right;' + LineEnding +
    '    height: 48;' + LineEnding +
    '    color: "#252538";' + LineEnding +
    LineEnding +
    '    Row {' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.leftMargin: 12;' + LineEnding +
    '      anchors.verticalCenter: parent.verticalCenter;' + LineEnding +
    '      spacing: 8;' + LineEnding +
    LineEnding +
    '      Button {' + LineEnding +
    '        id: btnBack;' + LineEnding +
    '        width: 36; height: 32;' + LineEnding +
    '        text: "<";' + LineEnding +
    '      }' + LineEnding +
    LineEnding +
    '      Button {' + LineEnding +
    '        id: btnForward;' + LineEnding +
    '        width: 36; height: 32;' + LineEnding +
    '        text: ">";' + LineEnding +
    '      }' + LineEnding +
    LineEnding +
    '      Button {' + LineEnding +
    '        id: btnReload;' + LineEnding +
    '        width: 36; height: 32;' + LineEnding +
    '        text: "O";' + LineEnding +
    '      }' + LineEnding +
    '    }' + LineEnding +
    LineEnding +
    '    TextInput {' + LineEnding +
    '      id: omniBox;' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.leftMargin: 148;' + LineEnding +
    '      anchors.right: parent.right;' + LineEnding +
    '      anchors.rightMargin: 180;' + LineEnding +
    '      anchors.verticalCenter: parent.verticalCenter;' + LineEnding +
    '      height: 34;' + LineEnding +
    '      text: mainWindow.currentUrl;' + LineEnding +
    '    }' + LineEnding +
    LineEnding +
    '    Button {' + LineEnding +
    '      id: btnToggleECA;' + LineEnding +
    '      anchors.right: parent.right;' + LineEnding +
    '      anchors.rightMargin: 12;' + LineEnding +
    '      anchors.verticalCenter: parent.verticalCenter;' + LineEnding +
    '      width: 156; height: 32;' + LineEnding +
    '      text: mainWindow.extendedClientArea ? "Switch to SSD" : "Switch to ECA";' + LineEnding +
    '      onClicked: {' + LineEnding +
    '        setExtendedClientArea(!mainWindow.extendedClientArea);' + LineEnding +
    '      }' + LineEnding +
    '      }' + LineEnding +
    '  }' + LineEnding +
    LineEnding +
    '  /* Web Page Content Area */' + LineEnding +
    '  Rectangle {' + LineEnding +
    '    id: pageContent;' + LineEnding +
    '    anchors.top: navBar.bottom;' + LineEnding +
    '    anchors.left: parent.left;' + LineEnding +
    '    anchors.right: parent.right;' + LineEnding +
    '    anchors.bottom: statusBar.top;' + LineEnding +
    '    anchors.margins: 16;' + LineEnding +
    '    color: "#313244";' + LineEnding +
    '    radius: 8;' + LineEnding +
    LineEnding +
    '    Text {' + LineEnding +
    '      id: pageHeader;' + LineEnding +
    '      anchors.top: parent.top;' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.margins: 24;' + LineEnding +
    '      text: "Page Content: Tab " + (mainWindow.activeTabIndex + 1) + " Active";' + LineEnding +
    '      color: "#89b4fa";' + LineEnding +
    '    }' + LineEnding +
    LineEnding +
    '    Text {' + LineEnding +
    '      id: urlStatus;' + LineEnding +
    '      anchors.top: pageHeader.bottom;' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.leftMargin: 24;' + LineEnding +
    '      anchors.topMargin: 12;' + LineEnding +
    '      text: "Viewing: " + mainWindow.currentUrl;' + LineEnding +
    '      color: "#cdd6f4";' + LineEnding +
    '    }' + LineEnding +
    LineEnding +
    '    Row {' + LineEnding +
    '      anchors.top: urlStatus.bottom;' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.leftMargin: 24;' + LineEnding +
    '      anchors.topMargin: 20;' + LineEnding +
    '      spacing: 12;' + LineEnding +
    LineEnding +
    '      Button {' + LineEnding +
    '        id: btnAction;' + LineEnding +
    '        width: 180; height: 38;' + LineEnding +
    '        text: "Interactive Click (+1)";' + LineEnding +
    '        onClicked: {' + LineEnding +
    '          mainWindow.counterClicks = mainWindow.counterClicks + 1;' + LineEnding +
    '        }' + LineEnding +
    '      }' + LineEnding +
    LineEnding +
    '      Text {' + LineEnding +
    '        anchors.verticalCenter: parent.verticalCenter;' + LineEnding +
    '        text: "Total Action Clicks: " + mainWindow.counterClicks;' + LineEnding +
    '        color: "#a6e3a1";' + LineEnding +
    '      }' + LineEnding +
    '    }' + LineEnding +
    '  }' + LineEnding +
    LineEnding +
    '  /* Status Bar */' + LineEnding +
    '  Rectangle {' + LineEnding +
    '    id: statusBar;' + LineEnding +
    '    anchors.left: parent.left;' + LineEnding +
    '    anchors.right: parent.right;' + LineEnding +
    '    anchors.bottom: parent.bottom;' + LineEnding +
    '    height: 28;' + LineEnding +
    '    color: "#181825";' + LineEnding +
    LineEnding +
    '    Text {' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.leftMargin: 12;' + LineEnding +
    '      anchors.verticalCenter: parent.verticalCenter;' + LineEnding +
    '      text: "Mode: " + (mainWindow.extendedClientArea ? "ECA Active" : "SSD Fallback") + " | Controls Inset: [L: " + mainWindow.controlsInsetLeft + ", R: " + mainWindow.controlsInsetRight + ", T: " + mainWindow.controlsInsetTop + ", B: " + mainWindow.controlsInsetBottom + "]";' + LineEnding +
    '      color: "#a6adc8";' + LineEnding +
    '    }' + LineEnding +
    '  }' + LineEnding +
    '}';

var
  MainWindow: TFtFTMLWindow;

begin
  MainWindow := TFtFTMLWindow.Create(960, 600, 'Floria Toolkit (ftpas) — ECA Browser Demo');
  try
    if MainWindow.LoadString(BROWSER_FTML) = nil then
    begin
      WriteLn('Failed to load FTML: ', MainWindow.Host.LastError);
      Halt(1);
    end;

    MainWindow.Show();
    FtApp.Run();
  finally
    MainWindow.Free();
  end;
end.
