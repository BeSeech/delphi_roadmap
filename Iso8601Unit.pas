unit Iso8601Unit;

interface
       uses dialogs;
type
  TUtc = class(TObject)
  public
    class function FromUtc(const Value: TDateTime): TDateTime; static;
    class function ToUtc(const Value: TDateTime): TDateTime; static;
    class function UtcNow: TDateTime; static;
  end;

  TToTIso8601 = class(TUtc)
  public
    class function DateTimeToIso8601(const Value: TDateTime): string; static;
    class function DateToIso8601(const Value: TDate): string; static;
    class function TimeToIso8601(const Value: TTime): string; static;
    class function UtcTimeToIso8601(const Value: TTime): string; static;
  end;

  TIso8601 = class(TToTIso8601)
  public
    class function DateFromIso8601(const Value: string): TDate; static;
    class function DateTimeFromIso8601(const Value: string): TDateTime; static;
    class function TimeFromIso8601(const Value: string): TTime; static;
    class function UtcDateTimeToIso8601(const Value: TDateTime): string; static;
  end;

implementation

uses
  XSBuiltIns,
  SysUtils,
  IdGlobalProtocols;

class function TIso8601.DateFromIso8601(const Value: string): TDate;
begin
  with TXSDate.Create() do
  try
    XSToNative(value); // convert from WideString
    Result := AsDate; // convert to TDate
  finally
    Free();
  end;
end;

class function TIso8601.DateTimeFromIso8601(const Value: string): TDateTime;
var
s: string;

begin
  try
  s := value;
  if (Copy(s, Length(s)-4, 1) = '-') or (Copy(s, Length(s)-4, 1) = '+') then
  begin
    if Copy(s, Length(s)-2, 1) <> ':' then
      s := Copy(s, 1, Length(s)-2) + ':' + Copy(s, Length(s)-1,2);
  end;
  with TXSDateTime.Create() do
  try
    XSToNative(s); // convert from WideString
    Result := AsDateTime; // convert to TDateTime
  finally
    Free();
  end;
  except
    on E:Exception do
      ShowMessage('Error JiraDate To TDateTime from string ' + s);

  end;
end;

class function TIso8601.TimeFromIso8601(const Value: string): TTime;
begin
  with TXSTime.Create() do
  try
    XSToNative(value); // convert from WideString
    Result := AsTime; // convert to TTime
  finally
    Free();
  end;
end;

class function TIso8601.UtcDateTimeToIso8601(const Value: TDateTime): string;
begin
  with TXSDateTime.Create() do
  try
    AsUTCDateTime := Value;
    Result := NativeToXS; // convert to WideString
  finally
    Free();
  end;
end;

class function TUtc.FromUtc(const Value: TDateTime): TDateTime;
var
  Bias: TDateTime;
begin
  Bias := TimeZoneBias;
  Result := Value - TimeZoneBias;
end;

class function TUtc.ToUtc(const Value: TDateTime): TDateTime;
var
  Bias: TDateTime;
begin
  Bias := TimeZoneBias;
  Result := Value + TimeZoneBias;
end;

class function TUtc.UtcNow: TDateTime;
begin
  Result := ToUtc(Now);
end;

class function TToTIso8601.DateTimeToIso8601(const Value: TDateTime): string;
begin
  with TXSDateTime.Create() do
  try
    AsDateTime := Value; // convert from TDateTime
    Result := NativeToXS; // convert to WideString
  finally
    Free();
  end;
end;

class function TToTIso8601.DateToIso8601(const Value: TDate): string;
begin
  with TXSDate.Create() do
  try
    AsDate := Value; // convert from TDate
    Result := NativeToXS; // convert to WideString
  finally
    Free();
  end;
end;

class function TToTIso8601.TimeToIso8601(const Value: TTime): string;
begin
  with TXSTime.Create() do
  try
    AsTime := Value; // convert from TTime
    Result := NativeToXS; // convert to WideString
  finally
    Free();
  end;
end;

class function TToTIso8601.UtcTimeToIso8601(const Value: TTime): string;
begin
  with TXSTime.Create() do
  try
    AsTime := ToUtc(Value);
    Result := NativeToXS; // convert to WideString
  finally
    Free();
  end;
end;

end.
