unit uDialogs;

interface

function ConfirmDlg(AMes: string; ACaption: string = '�������������'): boolean; overload;
function ConfirmDlg(AMes: string; Args: array of const; ACaption: string = '�������������'): boolean; overload;
function ConfirmInfoDlg(AMes: string; ACaption: string = '�������������'): boolean; overload;
function ConfirmInfoDlg(AMes: string; Args: array of const; ACaption: string = '�������������'): boolean; overload;
function WarningDlg(AMes: string; ACaption: string = '��������������'): boolean; overload;
function WarningDlg(AMes: string; Args: array of const; ACaption: string = '��������������'): boolean; overload;
procedure ShowErrorMessage(AMes: string; ACaption: string = '������'); overload;
procedure ShowErrorMessage(AMes: string; Args: array of const; ACaption: string = '������'); overload;
procedure ShowInfoMessage(AMes: string; ACaption: string = '����������'); overload;
procedure ShowInfoMessage(AMes: string; Args: array of const; ACaption: string = '����������'); overload;
procedure ShowWarningMessage(AMes: string; ACaption: string = '��������'); overload;
procedure ShowWarningMessage(AMes: string; Args: array of const; ACaption: string = '��������'); overload;
procedure ConfirmAbortDlg(AMes: string; ACaption: string = '�������������'); overload;
procedure ConfirmAbortDlg(AMes: string; Args: array of const; ACaption: string = '�������������'); overload;

implementation

uses Forms, Controls, SysUtils, Windows;

function ConfirmDlg(AMes: string; ACaption: string): boolean;
begin
  Result := Application.MessageBox(pChar(AMes), pChar(ACaption), MB_ICONQUESTION or MB_YESNO) = IDYES;
end;

function ConfirmDlg(AMes: string; Args: array of const; ACaption: string): boolean;
begin
  result := ConfirmDlg(Format(AMes, Args), ACaption);
end;

function ConfirmInfoDlg(AMes: string; ACaption: string): boolean;
begin
  Result := Application.MessageBox(pChar(AMes), pChar(ACaption), MB_ICONINFORMATION or MB_YESNO) = IDYES;
end;

function ConfirmInfoDlg(AMes: string; Args: array of const; ACaption: string): boolean;
begin
  result := ConfirmDlg(Format(AMes, Args), ACaption);
end;

function WarningDlg(AMes: string; ACaption: string): boolean;
begin
  result := Application.MessageBox(pChar(AMes), pChar(ACaption), MB_ICONWARNING or MB_YESNO) = IDYES;
end;

function WarningDlg(AMes: string; Args: array of const; ACaption: string):
  boolean;
begin
  result := WarningDlg(Format(AMes, Args), ACaption);
end;

procedure ShowErrorMessage(AMes: string; ACaption: string);
begin
  Application.MessageBox(pChar(AMes), pChar(ACaption), MB_ICONERROR or MB_OK);
end;

procedure ShowErrorMessage(AMes: string; Args: array of const; ACaption: string);
begin
  ShowErrorMessage(Format(AMes, Args), ACaption);
end;

procedure ShowInfoMessage(AMes: string; ACaption: string);
begin
  Application.MessageBox(pChar(AMes), pChar(ACaption), MB_ICONINFORMATION or MB_OK);
end;

procedure ShowInfoMessage(AMes: string; Args: array of const; ACaption: string);
begin
  ShowInfoMessage(Format(AMes, Args), ACaption);
end;

procedure ShowWarningMessage(AMes: string; ACaption: string);
begin
  Application.MessageBox(pChar(AMes), pChar(ACaption), MB_ICONWARNING or MB_OK);
end;

procedure ShowWarningMessage(AMes: string; Args: array of const; ACaption: string);
begin
  ShowWarningMessage(Format(AMes, Args), ACaption);
end;

procedure ConfirmAbortDlg(AMes: string; ACaption: string); overload;
begin
  if not ConfirmDlg(AMes, ACaption) then
    Abort;
end;

procedure ConfirmAbortDlg(AMes: string; Args: array of const; ACaption: string); overload;
begin
  if not ConfirmDlg(Format(AMes, Args), ACaption) then
    Abort;
end;

end.

