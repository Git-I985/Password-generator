unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ClipBrd,  LCLIntf;

type
 StrArray = array of string;
 CustomImageCheckbox = TImage;

 TMainForm = class(TForm)
    { Text }
    PasswordLengthTitle1: TStaticText;
    PasswordLengthTitle2: TStaticText;
    PasswordLengthTitle3: TStaticText;
    PasswordLengthTitle4: TStaticText;
    PasswordResult: TStaticText;
    SecondPanelTitle: TStaticText;
    PasswordLengthTitle: TStaticText;

    { Slider Components }
    ProgressBar: TShape;
    SliderController: TImage;
    SliderBackgroundColor: TImage;
    SliderBackground: TImage;
    SliderFill: TImage;

    { Inputs }
    PassowordLengthEdit: TEdit;
    FirstPanelBackground: TImage;
    CopyPasswordButton: TImage;
    SecondPanelBackground: TImage;
    PasswordLengthForm: TImage;
    SecondPanelSeparator: TShape;

    { Panels }
    PasswordPanel: TPanel;
    SettingsPanel: TPanel;
    CheckboxesPanel: TPanel;

    { checkboxes }
    CheckboxUppercase: CustomImageCheckbox;
    CheckboxLowercase: CustomImageCheckbox;
    CheckboxNumbers: CustomImageCheckbox;
    CheckboxSpecial: CustomImageCheckbox;
    CheckboxIconsList: TImageList;

    { functions }
    function SetPasswordSettingValue(var Setting: boolean; Value: boolean): boolean;
    function UpdatePasswordSettingValue(var Setting: boolean): boolean;

    { procedures }
    procedure CopyPasswordButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetControllerPosition(X: integer);
    procedure CustomCheckboxClick(Sender: TObject); overload;
    procedure SliderBackgroundMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure GeneratePassword();
    procedure UpdatePaswdDifficultyLine();
    procedure UpdatePasswordSetting(Setting: String; SpecifiedValue: boolean = false; Value: boolean = false);
    procedure UpdateCheckbox(Checkbox: TImage; IconIndex: Integer);
end;

var
  MainForm: TMainForm;
  PasswordLength: integer;
  AllowedUppercase: boolean = false;
  AllowedLowercase: boolean = false;
  AllowedNumbers: boolean = false;
  AllowedSpecial: boolean = false;

  { Using colors }
  ColorGreen: TColor;
  ColorOrange: TColor;
  ColorRed: TColor;
  ColorDisabled: TColor;

implementation

{$R *.lfm}

{ Slider functional }
procedure TMainForm.SliderBackgroundMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var ConvertedLength: integer;
begin
       if (X mod 10 = 0) and
          (ssLeft in Shift) and
          (X >= 0) and
          (X <= SliderBackground.Width) then begin

             { convert 200 width to 20 (max password length) }
             ConvertedLength := Round(X/10);

             SetControllerPosition(X);

             PasswordLength := ConvertedLength;
             PassowordLengthEdit.Text := IntToStr(ConvertedLength);

             GeneratePassword;
       end;
end;

procedure TMainForm.SetControllerPosition(X: integer);
begin
     SliderFill.Width := x;
     SliderController.Left := 112 + x - Round(SliderController.Width / 2);
end;

{ password difficulty level line }
procedure TMainForm.UpdatePaswdDifficultyLine();
begin
     { set size }
     if (PasswordLength >= 10) then ProgressBar.Width := 504 { Fullsize }
     else ProgressBar.Width := Round((500/100) * PasswordLength * 10);

     { set color }
     if (PasswordLength >= 10) then ProgressBar.Brush.Color := ColorGreen;
     if PasswordLength < 6 then ProgressBar.Brush.Color := ColorOrange;
     if PasswordLength < 3 then ProgressBar.Brush.Color := ColorRed;

     if not AllowedUppercase and
        not AllowedLowercase then
        ProgressBar.Brush.Color := ColorDisabled;
end;

{ copy password in clipboard  }
procedure TMainForm.CopyPasswordButtonClick(Sender: TObject);
begin
     if not (PasswordResult.Caption = '') then begin
        Clipboard.AsText := PasswordResult.Caption;
        PasswordResult.Font.Color := ColorDisabled;
     end;
end;

function TMainForm.SetPasswordSettingValue(var Setting: boolean; Value: boolean): boolean;
begin
  Setting := Value;
  SetPasswordSettingValue := Setting;
end;

function TMainForm.UpdatePasswordSettingValue(var Setting: boolean): boolean;
begin
  Setting := not Setting;
  UpdatePasswordSettingValue := Setting;
end;

procedure TMainForm.UpdatePasswordSetting(Setting: String; SpecifiedValue: Boolean = false; Value: Boolean = false);
var
  UpdatedCheckboxValue: boolean;
  AnchoredCheckbox: CustomImageCheckbox;
begin
  case Setting of
       'AllowedUppercase': begin
          if SpecifiedValue then
             UpdatedCheckboxValue := SetPasswordSettingValue(AllowedUppercase, Value)
          else
            UpdatedCheckboxValue := UpdatePasswordSettingValue(AllowedUppercase);

          AnchoredCheckbox := CheckboxUppercase;
       end;
       'AllowedLowercase': begin
          if SpecifiedValue then
             UpdatedCheckboxValue := SetPasswordSettingValue(AllowedLowercase, Value)
          else
            UpdatedCheckboxValue := UpdatePasswordSettingValue(AllowedLowercase);

          AnchoredCheckbox := CheckboxLowercase;
       end;
       'AllowedNumbers': begin
          if SpecifiedValue then
             UpdatedCheckboxValue := SetPasswordSettingValue(AllowedNumbers, Value)
          else
            UpdatedCheckboxValue := UpdatePasswordSettingValue(AllowedNumbers);

          AnchoredCheckbox := CheckboxNumbers;
       end;
       'AllowedSpecial': begin
          if SpecifiedValue then
             UpdatedCheckboxValue := SetPasswordSettingValue(AllowedSpecial, Value)
          else
            UpdatedCheckboxValue := UpdatePasswordSettingValue(AllowedSpecial);

          AnchoredCheckbox := CheckboxSpecial;
       end;
  end;

  UpdateCheckbox(AnchoredCheckbox, Ord(UpdatedCheckboxValue));
end;

{ Change passord property checkbox icon }
procedure TMainForm.UpdateCheckbox(Checkbox: TImage; IconIndex: Integer);
begin
     CheckboxIconsList.GetBitmap(IconIndex,Checkbox.picture.Bitmap);
end;

{ Password settings checkboxes click handler }
procedure TMainForm.CustomCheckBoxClick(Sender: TObject);
var
  PressedCheckbox: CustomImageCheckbox;
  CheckboxNumer: Integer;
begin
  PressedCheckbox := (Sender as TImage);
  CheckboxNumer := PressedCheckbox.Tag;
  { Change password property }
  case CheckboxNumer of
       1: UpdatePasswordSetting('AllowedUppercase');
       2: UpdatePasswordSetting('AllowedLowercase');
       3: UpdatePasswordSetting('AllowedNumbers');
       4: UpdatePasswordSetting('AllowedSpecial');
  end;
  { Re'generates password after changing parameters }
  GeneratePassword;
end;

{ Generate password with selected settings and length }
procedure TMainForm.GeneratePassword();
var
  UpperSymbls: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  LowerSymbls: string = 'abcdefghijklmnopqrstuvwxyz';
  NumbsSymbls: string = '01234567890123456789';
  SpeclSymbls: string = '!@#&$^%./';
  AllowSymbls: string = '';
  { result paswd string }
  PaswdOutStr: string = '';
  { cycle var }
  i: integer;
  RandomCharIndex: integer;
begin
     { reset passowrd result color after copy }
     PasswordResult.Font.Color := RGB(10,34,64);
     UpdatePaswdDifficultyLine;

     if AllowedUppercase then AllowSymbls += UpperSymbls;
     if AllowedLowercase then AllowSymbls += LowerSymbls;
     if AllowedNumbers then AllowSymbls += NumbsSymbls;
     if AllowedSpecial then AllowSymbls += SpeclSymbls;

     if not (Length(AllowSymbls) = 0) and
        not (PasswordLength = 0) then begin

        for i := 1 to PasswordLength do begin
           { Takes a random character from allowed string }
           RandomCharIndex := Random(Length(AllowSymbls)) + 1;
           PaswdOutStr += AllowSymbls[RandomCharIndex];
         end;
     end;

     { Print new passowrd }
     PasswordResult.Caption := PaswdOutStr;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  defaultPassowrdLength: integer = 13;
begin
  { Colors init }
  ColorGreen := RGB(95,216,137);
  ColorOrange := RGB(241,155,43);
  ColorRed := RGB(210,45,39);
  ColorDisabled := RGB(215, 215, 215);

  { Main init }

  PasswordLength := defaultPassowrdLength;
  PassowordLengthEdit.Text := IntToStr(PasswordLength);
  UpdatePasswordSetting('AllowedLowercase', true, true);
  UpdatePasswordSetting('AllowedUppercase', true, true);
  UpdatePasswordSetting('AllowedNumbers', true, true);

  SetControllerPosition(130);

  GeneratePassword;
end;























end.
