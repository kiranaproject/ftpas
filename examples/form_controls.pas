{ ************************************************************************** }
{                                                                          }
{   Floria Toolkit (ftpas) — Form & Controls OOP Example                   }
{                                                                          }
{   Demonstrates text entries, checkboxes, switches, sliders, progress     }
{   bars, and combo boxes using idiomatic Object Pascal OOP methods.       }
{                                                                          }
{   Copyright (c) 2026 Dio Affriza                                         }
{   SPDX-License-Identifier: MPL-2.0                                       }
{                                                                          }
{ ************************************************************************** }

program form_controls;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, ftpas, ftpas.types;

type
  { TFormControlsWindow — Main form window (like TForm in LCL) }
  TFormControlsWindow = class(TFtWindow)
  private
    FTitleLabel: TFtLabel;
    FNameEntry: TFtEntry;
    FDeptCombo: TFtComboBox;
    FNotifyCheck: TFtCheckBox;
    FDarkModeSwitch: TFtSwitch;
    FVolumeSlider: TFtSlider;
    FProgressBar: TFtProgressBar;
    FStatusLabel: TFtLabel;
    FSubmitBtn: TFtButton;
    FResetBtn: TFtButton;

    procedure HandleSliderChange(Sender: TFtSlider; NewValue: Double);
    procedure HandleSwitchToggle(Sender: TFtSwitch; Toggled: Boolean);
    procedure HandleSubmitClick(Sender: TFtButton);
    procedure HandleResetClick(Sender: TFtButton);
  public
    constructor Create(); reintroduce;
  end;

constructor TFormControlsWindow.Create();
var
  lbl: TFtLabel;
begin
  inherited Create(600, 520, 'Floria Toolkit — Form Controls');

  { Title }
  FTitleLabel := TFtLabel.Create(Self, 30, 24, 540, 32, 'Employee Profile & Preferences');

  { Name Field }
  lbl := TFtLabel.Create(Self, 30, 70, 100, 24, 'Full Name:');
  FNameEntry := TFtEntry.Create(Self, 150, 68, 410, 32);
  FNameEntry.Placeholder := 'Enter your full name';
  FNameEntry.Text := 'Jane Doe';

  { Department Combo }
  lbl := TFtLabel.Create(Self, 30, 116, 100, 24, 'Department:');
  FDeptCombo := TFtComboBox.Create(Self, 150, 114, 410, 32);
  FDeptCombo.AddItem('Engineering');
  FDeptCombo.AddItem('Product Design');
  FDeptCombo.AddItem('Quality Assurance');
  FDeptCombo.AddItem('DevOps & Cloud');
  FDeptCombo.SelectedIndex := 0;

  { CheckBox }
  lbl := TFtLabel.Create(Self, 30, 162, 100, 24, 'Alerts:');
  FNotifyCheck := TFtCheckBox.Create(Self, 150, 162, 250, 24, 'Receive email notifications');
  FNotifyCheck.Checked := True;

  { Switch: Dark Mode }
  lbl := TFtLabel.Create(Self, 30, 204, 100, 24, 'Dark Theme:');
  FDarkModeSwitch := TFtSwitch.Create(Self, 150, 202, 54, 28);
  FDarkModeSwitch.Checked := FtApp.DarkMode;
  FDarkModeSwitch.OnToggle := @HandleSwitchToggle;

  { Slider }
  lbl := TFtLabel.Create(Self, 30, 250, 100, 24, 'Volume Level:');
  FVolumeSlider := TFtSlider.Create(Self, 150, 248, 410, 28);
  FVolumeSlider.SetRange(0.0, 100.0);
  FVolumeSlider.Value := 65.0;
  FVolumeSlider.OnChange := @HandleSliderChange;

  { Progress Bar }
  lbl := TFtLabel.Create(Self, 30, 296, 100, 24, 'Progress:');
  FProgressBar := TFtProgressBar.Create(Self, 150, 298, 410, 20);
  FProgressBar.SetRange(0.0, 100.0);
  FProgressBar.Value := 65.0;

  { Status Display }
  FStatusLabel := TFtLabel.Create(Self, 30, 340, 530, 24, 'Ready.');

  { Action Buttons }
  FSubmitBtn := TFtButton.Create(Self, 330, 420, 110, 38, 'Save Profile');
  FSubmitBtn.OnClick := @HandleSubmitClick;

  FResetBtn := TFtButton.Create(Self, 450, 420, 110, 38, 'Reset');
  FResetBtn.OnClick := @HandleResetClick;
end;

procedure TFormControlsWindow.HandleSliderChange(Sender: TFtSlider; NewValue: Double);
begin
  FProgressBar.Value := NewValue;
  FStatusLabel.Text := Format('Volume set to %0.0f%%', [NewValue]);
end;

procedure TFormControlsWindow.HandleSwitchToggle(Sender: TFtSwitch; Toggled: Boolean);
begin
  FtApp.DarkMode := Toggled;
  if Toggled then
    FStatusLabel.Text := 'Dark mode activated'
  else
    FStatusLabel.Text := 'Light mode activated';
end;

procedure TFormControlsWindow.HandleSubmitClick(Sender: TFtButton);
var
  msg: string;
begin
  msg := Format('Saved profile for "%s" (%s).' + LineEnding +
                'Notifications: %s, Volume: %0.0f%%',
                [FNameEntry.Text, FDeptCombo.SelectedText,
                 BoolToStr(FNotifyCheck.Checked, 'Enabled', 'Disabled'),
                 FVolumeSlider.Value]);
  FStatusLabel.Text := 'Profile saved successfully.';
  TFtMessageDialog.ShowInfo('Profile Saved', 'Successfully Recorded', msg);
end;

procedure TFormControlsWindow.HandleResetClick(Sender: TFtButton);
begin
  FNameEntry.Text := '';
  FDeptCombo.SelectedIndex := 0;
  FNotifyCheck.Checked := False;
  FVolumeSlider.Value := 50.0;
  FProgressBar.Value := 50.0;
  FStatusLabel.Text := 'Form reset to defaults.';
end;

var
  MainWindow: TFormControlsWindow;

begin
  MainWindow := TFormControlsWindow.Create();
  try
    MainWindow.Show();
    FtApp.Run();
  finally
    MainWindow.Free();
  end;
end.
