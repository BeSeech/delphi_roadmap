unit uAppInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, forms,
  Dialogs, ComCtrls;

type
  TAppInfo = class(TObject)
  private
    FStartTime: Double;
    FClockRate: Double;
    procedure Init;
    function GetVersion: string;
  public
    FileName: string;
    FilePath: string;
    FileVersion: string;
    LAppDataPath: string; // "CurrentUser"\Local Settings\Application Data
    LAppDataFolder: string; // задается в .dpr
    LogLines: TStrings;
    function ReadTimer: Double;
    function ReadTimerStr: string;
    function StartTimer: Boolean;
    procedure AddLog(AText: string; ATimer: Boolean = True);
    function GetSpecialFolderPath(AFolder: integer): string;
    procedure AutoRun(AParamName: string; AAdd: Boolean);
  end;

var
  ai: TAppInfo;

implementation

uses SHFolder, Registry;
{ Options }

procedure TAppInfo.AddLog(AText: string; ATimer: Boolean = True);
begin
  if ATimer then
    AText := Format('T: %s'#13#10'%s [%s]', [FormatDateTime('dd:mm:YY hh:nn:ss zzz', now), AText, ReadTimerStr])
  else
    AText := Format('T: %s'#13#10'%s', [FormatDateTime('dd:mm:YY hh:nn:ss zzz', now), AText]);
  if Assigned(LogLines) then
    LogLines.Add(AText);
  if ATimer then
    StartTimer;
end;

procedure TAppInfo.AutoRun(AParamName: string; AAdd: Boolean);
var
  Reg: TRegistry;
  Val: string;
begin
  Reg := TRegistry.Create(KEY_WRITE or KEY_READ or $0100);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\', false);
    Val := Reg.ReadString(AParamName);
    if AAdd then
    begin
      if (Val <> Application.ExeName) then
        Reg.WriteString(AParamName, Application.ExeName)
    end
    else if (Val <> EmptyStr) then
      Reg.DeleteValue(AParamName);
  finally
    Reg.Free;
  end;
end;

function TAppInfo.GetSpecialFolderPath(AFolder: integer): string;
const
  SHGFP_TYPE_CURRENT = 0;
var
  path: array[0..MAX_PATH] of char;
begin
  if SUCCEEDED(SHGetFolderPath(0, AFolder, 0, SHGFP_TYPE_CURRENT, @path[0])) then
    Result := path
  else
    Result := '';
end;

function TAppInfo.GetVersion: string;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
  with VerValue^ do
  begin
    Result := IntToStr(dwFileVersionMS shr 16);
    Result := Result + '.' + IntToStr(dwFileVersionMS and $FFFF);
    Result := Result + '.' + IntToStr(dwFileVersionLS shr 16);
    Result := Result + '.' + IntToStr(dwFileVersionLS and $FFFF);
  end;
  FreeMem(VerInfo, VerInfoSize);
end;

procedure TAppInfo.Init;
begin
  FileName := ExtractFileName(Application.ExeName);
  FilePath := ExtractFilePath(Application.ExeName);
  LAppDataPath := GetSpecialFolderPath(CSIDL_LOCAL_APPDATA) + '\';
  LAppDataFolder := '';
  FileVersion := GetVersion;
  FClockRate := -1;
end;

function TAppInfo.ReadTimer: Double;
var
  ET: TLargeInteger;
begin
  QueryPerformanceCounter(ET);
  Result := 1000.0 * (ET - FStartTime) / FClockRate;
end;

function TAppInfo.ReadTimerStr: string;
begin
  if FClockRate > 0 then
    result := vartostr(round(ReadTimer * 10) / 10);
end;

function TAppInfo.StartTimer: Boolean;
var
  QW: TLargeInteger;
begin
  if FClockRate <= 0 then
  begin
    QueryPerformanceFrequency(QW);
    FClockRate := QW;
  end;
  Result := QueryPerformanceCounter(QW);
  FStartTime := QW;
end;

initialization
  ai := TAppInfo.Create;
  ai.Init;
finalization
  ai.LogLines := nil;
  FreeAndNil(ai);
end.

