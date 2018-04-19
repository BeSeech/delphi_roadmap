unit UBeUtils;

interface
  Uses
    Winapi.Windows;

function IsTouchScrean: Boolean;

implementation

function IsTouchScrean: Boolean;
var
  tData: integer;
begin
  Result := False;
  tData := GetSystemMetrics(SM_DIGITIZER);
  if tData and NID_READY <> 0 then
    if tData and NID_MULTI_INPUT <> 0 then
      Result := True
    else
      Result := False;
end;

end.
