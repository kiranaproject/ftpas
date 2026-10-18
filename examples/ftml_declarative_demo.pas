{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (ftpas) — Declarative FTML UI Example                   }
{                                                                          }
{   Demonstrates building modern desktop UIs declaratively using FTML       }
{   (Floria Toolkit Markup Language) with reactive property bindings,      }
{   signal handlers, and Pascal-JavaScript host function interop.          }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

program ftml_declarative_demo;

{$mode objfpc}{$H+}
{$interfaces corba}

uses
  Classes, SysUtils, Math, floriajs, ftpas;

const
  APP_FTML =
    'Rectangle {' + LineEnding +
    '  id: rootWindow;' + LineEnding +
    '  width: 680; height: 580;' + LineEnding +
    '  color: "#181825";' + LineEnding +
    '  property int clickCount: 0;' + LineEnding +
    '  property string userName: "Floria Developer";' + LineEnding +
    LineEnding +
    '  Rectangle {' + LineEnding +
    '    id: headerCard;' + LineEnding +
    '    anchors.top: parent.top;' + LineEnding +
    '    anchors.left: parent.left;' + LineEnding +
    '    anchors.right: parent.right;' + LineEnding +
    '    anchors.margins: 24;' + LineEnding +
    '    height: 64;' + LineEnding +
    '    color: "#1e1e2e";' + LineEnding +
    '    radius: 10;' + LineEnding +
    '    Text {' + LineEnding +
    '      id: appTitle;' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.leftMargin: 20;' + LineEnding +
    '      anchors.verticalCenter: parent.verticalCenter;' + LineEnding +
    '      text: "Floria Toolkit — Declarative FTML UI Demo";' + LineEnding +
    '      color: "#89b4fa";' + LineEnding +
    '    }' + LineEnding +
    '  }' + LineEnding +
    LineEnding +
    '  Rectangle {' + LineEnding +
    '    id: contentCard;' + LineEnding +
    '    anchors.top: headerCard.bottom;' + LineEnding +
    '    anchors.left: parent.left;' + LineEnding +
    '    anchors.right: parent.right;' + LineEnding +
    '    anchors.bottom: parent.bottom;' + LineEnding +
    '    anchors.margins: 24;' + LineEnding +
    '    anchors.topMargin: 16;' + LineEnding +
    '    color: "#313244";' + LineEnding +
    '    radius: 12;' + LineEnding +
    LineEnding +
    '    Text {' + LineEnding +
    '      id: welcomeLabel;' + LineEnding +
    '      anchors.top: parent.top;' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.margins: 24;' + LineEnding +
    '      text: "Hello, " + rootWindow.userName + "! Welcome to FTML.";' + LineEnding +
    '      color: "#cdd6f4";' + LineEnding +
    '    }' + LineEnding +
    LineEnding +
    '    Text {' + LineEnding +
    '      id: counterDisplay;' + LineEnding +
    '      anchors.top: welcomeLabel.bottom;' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.leftMargin: 24;' + LineEnding +
    '      anchors.topMargin: 10;' + LineEnding +
    '      text: "Reactive Clicks: " + rootWindow.clickCount;' + LineEnding +
    '      color: "#a6e3a1";' + LineEnding +
    '    }' + LineEnding +
    LineEnding +
    '    Row {' + LineEnding +
    '      id: buttonBar;' + LineEnding +
    '      anchors.top: counterDisplay.bottom;' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.leftMargin: 24;' + LineEnding +
    '      anchors.topMargin: 14;' + LineEnding +
    '      height: 44;' + LineEnding +
    '      spacing: 12;' + LineEnding +
    '      Button {' + LineEnding +
    '        id: incButton;' + LineEnding +
    '        width: 140; height: 38;' + LineEnding +
    '        text: "Click Me (+1)";' + LineEnding +
    '        onClicked: {' + LineEnding +
    '          rootWindow.clickCount = rootWindow.clickCount + 1;' + LineEnding +
    '        }' + LineEnding +
    '      }' + LineEnding +
    '      Button {' + LineEnding +
    '        id: resetButton;' + LineEnding +
    '        width: 120; height: 38;' + LineEnding +
    '        text: "Reset Counter";' + LineEnding +
    '        onClicked: {' + LineEnding +
    '          rootWindow.clickCount = 0;' + LineEnding +
    '        }' + LineEnding +
    '      }' + LineEnding +
    '    }' + LineEnding +
    LineEnding +
    '    Text {' + LineEnding +
    '      id: inputPrompt;' + LineEnding +
    '      anchors.top: buttonBar.bottom;' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.leftMargin: 24;' + LineEnding +
    '      anchors.topMargin: 18;' + LineEnding +
    '      text: "Enter your name to test bidirectional input binding:";' + LineEnding +
    '      color: "#bac2de";' + LineEnding +
    '    }' + LineEnding +
    LineEnding +
    '    TextInput {' + LineEnding +
    '      id: nameInput;' + LineEnding +
    '      anchors.top: inputPrompt.bottom;' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.leftMargin: 24;' + LineEnding +
    '      anchors.topMargin: 8;' + LineEnding +
    '      width: 320; height: 36;' + LineEnding +
    '      text: "Floria Developer";' + LineEnding +
    '      placeholder: "Type your name...";' + LineEnding +
    '      onTextChanged: {' + LineEnding +
    '        rootWindow.userName = nameInput.text;' + LineEnding +
    '      }' + LineEnding +
    '    }' + LineEnding +
    LineEnding +
    '    Text {' + LineEnding +
    '      id: calcLabel;' + LineEnding +
    '      anchors.top: nameInput.bottom;' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.leftMargin: 24;' + LineEnding +
    '      anchors.topMargin: 14;' + LineEnding +
    '      text: "Pascal Host Interop: 2^" + rootWindow.clickCount + " = " + computePower(2, rootWindow.clickCount);' + LineEnding +
    '      color: "#fab387";' + LineEnding +
    '    }' + LineEnding +
    LineEnding +
    '    Grid {' + LineEnding +
    '      id: statsGrid;' + LineEnding +
    '      anchors.top: calcLabel.bottom;' + LineEnding +
    '      anchors.left: parent.left;' + LineEnding +
    '      anchors.right: parent.right;' + LineEnding +
    '      anchors.bottom: parent.bottom;' + LineEnding +
    '      anchors.margins: 24;' + LineEnding +
    '      anchors.topMargin: 16;' + LineEnding +
    '      columns: 3;' + LineEnding +
    '      columnGap: 12; rowGap: 12;' + LineEnding +
    '      columnTemplate: "1fr 1fr 1fr";' + LineEnding +
    '      Rectangle {' + LineEnding +
    '        id: statCard1;' + LineEnding +
    '        color: "#1e1e2e";' + LineEnding +
    '        radius: 8;' + LineEnding +
    '        gridColumn: 0; gridRow: 0;' + LineEnding +
    '        Text {' + LineEnding +
    '          x: 16; y: 14;' + LineEnding +
    '          text: "Computation";' + LineEnding +
    '          color: "#89dceb";' + LineEnding +
    '        }' + LineEnding +
    '        Text {' + LineEnding +
    '          x: 16; y: 40;' + LineEnding +
    '          text: "2^" + rootWindow.clickCount + " = " + computePower(2, rootWindow.clickCount);' + LineEnding +
    '          color: "#f9e2af";' + LineEnding +
    '        }' + LineEnding +
    '      }' + LineEnding +
    '      Rectangle {' + LineEnding +
    '        id: statCard2;' + LineEnding +
    '        color: "#1e1e2e";' + LineEnding +
    '        radius: 8;' + LineEnding +
    '        gridColumn: 1; gridRow: 0;' + LineEnding +
    '        Text {' + LineEnding +
    '          x: 16; y: 14;' + LineEnding +
    '          text: "Active User";' + LineEnding +
    '          color: "#cba6f7";' + LineEnding +
    '        }' + LineEnding +
    '        Text {' + LineEnding +
    '          x: 16; y: 40;' + LineEnding +
    '          text: rootWindow.userName;' + LineEnding +
    '          color: "#a6e3a1";' + LineEnding +
    '        }' + LineEnding +
    '      }' + LineEnding +
    '      Rectangle {' + LineEnding +
    '        id: statCard3;' + LineEnding +
    '        color: "#1e1e2e";' + LineEnding +
    '        radius: 8;' + LineEnding +
    '        gridColumn: 2; gridRow: 0;' + LineEnding +
    '        Text {' + LineEnding +
    '          x: 16; y: 14;' + LineEnding +
    '          text: "Layout Mode";' + LineEnding +
    '          color: "#f38ba8";' + LineEnding +
    '        }' + LineEnding +
    '        Text {' + LineEnding +
    '          x: 16; y: 40;' + LineEnding +
    '          text: "Responsive Anchors";' + LineEnding +
    '          color: "#cdd6f4";' + LineEnding +
    '        }' + LineEnding +
    '      }' + LineEnding +
    '    }' + LineEnding +
    '  }' + LineEnding +
    '}';

{ Native Pascal function exposed to FTML / JavaScript }
function PascalComputePower(const AArgs: array of TFloriaJSValue; AThis: TFloriaJSValue): TFloriaJSValue;
var
  baseVal, expVal: Double;
begin
  if Length(AArgs) >= 2 then
  begin
    baseVal := AArgs[0].ToNumber();
    expVal := AArgs[1].ToNumber();
    Result := JSMakeNumber(Power(baseVal, expVal));
  end
  else
    Result := JSMakeNumber(1.0);
end;

var
  MainWindow: TFtFTMLWindow;

begin
  MainWindow := TFtFTMLWindow.Create(680, 580, 'Floria Toolkit — FTML Declarative UI Demo');
  try
    { Register native Pascal functions into the FTML JavaScript engine }
    MainWindow.RegisterFunction('computePower', @PascalComputePower);

    { Load the FTML component tree }
    if MainWindow.LoadString(APP_FTML) = nil then
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
