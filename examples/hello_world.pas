{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (ftpas) — Hello World OOP Example                       }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

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
    FClickCount: Integer;

    procedure HandleButtonClick(Sender: TFtButton);
  public
    constructor Create(); reintroduce;
  end;

constructor THelloWindow.Create();
begin
  inherited Create(480, 320, 'Floria Toolkit — Hello World');
  FClickCount := 0;

  { Title / Greeting Label — Self passed as parent window }
  FLabel := TFtLabel.Create(Self, 40, 60, 400, 36, 'Welcome to Floria Toolkit (ftpas)!');
  FLabel.Alignment := ftaCenter;

  { Action Button — Self passed as parent window }
  FButton := TFtButton.Create(Self, 160, 140, 160, 42, 'Click Me!');
  FButton.OnClick := @HandleButtonClick;
end;

procedure THelloWindow.HandleButtonClick(Sender: TFtButton);
begin
  Inc(FClickCount);
  FLabel.Text := Format('Button clicked %d time(s)!', [FClickCount]);
  if FClickCount = 5 then
    TFtMessageDialog.ShowInfo('Milestone', 'Congratulations!', 'You clicked the button 5 times!');
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
