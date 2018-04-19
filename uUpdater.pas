unit uUpdater;

interface

uses
  Windows, Messages, SysUtils, Variants, Forms, Classes, Graphics, Controls,
  Dialogs, ShellApi;

type
  TProgUpdater = class
    class function SetProgUpdate(MemoryStream: TMemoryStream): boolean;
    class function RunAsAdmin(hWnd: HWND; AFileName, AParams: string): Boolean;
    class function isReStartWithAdminRigthForUpdate: Boolean;
  end;

implementation

uses ConvUtils, uAppInfo, uDialogs;

{ TProgUpdater }

const
  cReStartWithAdminRigth = 'ARU';

class function TProgUpdater.SetProgUpdate(MemoryStream: TMemoryStream): boolean;
var
  OldFileName: string;
  Rename: Boolean;
  function GetOldFileName: string;
  var
    i: integer;
  label
    TryNewName;
  begin
    Result := 'old_' + ai.FileName;
    i := 0;
    TryNewName:
    if FileExists(ai.FilePath + Result) then
      if not DeleteFile(ai.FilePath + Result) then
      begin
        inc(i);
        Result := 'old' + inttostr(i) + '_' + ai.FileName;
        goto TryNewName;
      end;
  end;
  procedure CloseApp;
  begin
    PostMessage(Application.MainForm.Handle, WM_CLOSE, 0, 0);
  end;
begin
  Result := False;
  Rename := False;
  try
    OldFileName := GetOldFileName;
    if RenameFile(ai.FilePath + ai.FileName, ai.FilePath + OldFileName) then
    begin
      Rename := True;
      MemoryStream.SaveToFile(ai.FilePath + ai.FileName);
      Result := FileExists(ai.FilePath + ai.FileName);
    end
    else if (GetLastError = ERROR_ACCESS_DENIED) and (Win32MajorVersion >= 6) and not isReStartWithAdminRigthForUpdate then
      if WarningDlg('У Вас недостаточно прав на выполнение обновления приложения. ' + #13 +
        'Перезапустить приложение от имени администратора?', 'Ошибка при обновлении') then
      begin
        CloseApp;
        RunAsAdmin(Application.MainForm.Handle, Application.ExeName, cReStartWithAdminRigth);
      end;
  finally
    if Result then
    begin
      CloseApp;
      ShellExecute(Application.Handle, nil, pChar(ai.FileName), nil, pChar(ai.FilePath), SW_SHOWNORMAL);
    end
    else if Rename then //Rollback
      RenameFile(ai.FilePath + OldFileName, ai.FilePath + ai.FileName);
  end;
end;

class function TProgUpdater.isReStartWithAdminRigthForUpdate: Boolean;
var
  i: integer;
begin
  Result := False;
  for i := 1 to ParamCount do
    if (ParamStr(i) = cReStartWithAdminRigth) then
    begin
      Result := True;
      Break;
    end;
end;

class function TProgUpdater.RunAsAdmin(hWnd: HWND; AFileName, AParams: string): Boolean;
var
  sei: TShellExecuteInfo;
begin
  ZeroMemory(@sei, SizeOf(sei));
  sei.cbSize := SizeOf(TShellExecuteInfo);
  sei.Wnd := hwnd;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := PChar('runas');
  sei.lpFile := PChar(AFileName);
  if AParams <> '' then
    sei.lpParameters := PChar(AParams);
  sei.nShow := SW_SHOWNORMAL;
  Result := ShellExecuteEx(@sei);
end;

end.

