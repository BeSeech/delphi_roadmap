unit UIssueHistory;

interface

uses
  Iso8601Unit,
{$IFDEF VER280}
  System.JSON,
{$ENDIF}
{$IFDEF VER260}
  DBXJSON,
{$ENDIF}
  Vcl.ExtCtrls,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TIssueHistory = class;

  TIssueHistoryList = class(TObjectList<TIssueHistory>)
  private
    FText: TStringList;
  public
    procedure LoadFromTJSonArray(const Ajharr: TJSONArray);
    function Text: TStringList;
    function Add(const Value: TIssueHistory): Integer;
    procedure Insert(Index: Integer; const Value: TIssueHistory);
    function Remove(const Value: TIssueHistory): Integer;
    procedure Delete(Index: Integer);
    constructor Create(AOwnsObjects: Boolean = True);
    destructor Destroy;
  end;

  TIssueHistory = class
  private
    FOwnerList: TIssueHistoryList;
    FDateTime: TDateTime;
    FNewValue: String;
    FOldValue: String;
    procedure SetDateTime(const Value: TDateTime);
    procedure SetNewValue(const Value: String);
    procedure SetOldValue(const Value: String);
  public
    constructor Create; overload;
    destructor Destroy; override;
    property OwnerList: TIssueHistoryList read FOwnerList write FOwnerList;
    property DateTime: TDateTime read FDateTime write SetDateTime;
    property OldValue: String read FOldValue write SetOldValue;
    property NewValue: String read FNewValue write SetNewValue;
  end;

implementation
function BeClear(const AString: string): string;
begin
  Result := StringReplace(AString, '"', '', [rfReplaceAll]);
end;

constructor TIssueHistory.Create;
begin
  inherited Create;
  FOwnerList := nil;
  FDateTime := 0;
  FOldValue := EmptyStr;
  FNewValue := EmptyStr;
end;

destructor TIssueHistory.Destroy;
begin
  FOwnerList := nil;
  inherited;
end;

procedure TIssueHistory.SetDateTime(const Value: TDateTime);
begin
  FDateTime := Value;
end;

procedure TIssueHistory.SetNewValue(const Value: String);
begin
  FNewValue := Value;
end;

procedure TIssueHistory.SetOldValue(const Value: String);
begin
  FOldValue := Value;
end;

{ TIssueHistoryList }

function TIssueHistoryList.Add(const Value: TIssueHistory): Integer;
begin
  result := inherited Add(Value);
  Value.OwnerList := Self;
end;

constructor TIssueHistoryList.Create(AOwnsObjects: Boolean);
begin
  inherited Create(AOwnsObjects);
  FText := TStringList.Create;
end;

procedure TIssueHistoryList.Delete(Index: Integer);
begin
  Self[Index].OwnerList := nil;
  inherited Delete(Index);
end;

destructor TIssueHistoryList.Destroy;
begin
  FreeAndNil(FText);
  inherited;
end;

procedure TIssueHistoryList.Insert(Index: Integer; const Value: TIssueHistory);
begin
  inherited Insert(Index, Value);
  Value.OwnerList := Self;
end;

procedure TIssueHistoryList.LoadFromTJSonArray(const Ajharr: TJSONArray);
var
  hi, hii: Integer;
  jhiarr: TJSONArray;
  isStatus: Boolean;
  field, fromStatus, toStatus: string;
begin
  for hi := 0 to Pred(Ajharr.Size) do
  begin
    jhiarr := (Ajharr.Get(hi) as tJSonObject).GetValue('items') as TJSONArray;
    isStatus := False;
    if not Assigned(jhiarr) then
      Continue;
    for hii := 0 to Pred(jhiarr.Size) do
    begin
      field := BeClear((jhiarr.Get(hii) as tJSonObject).GetValue('field')
        .ToString);
      if (field <> 'status') then
        Continue;
      isStatus := True;
      fromStatus := BeClear((jhiarr.Get(hii) as tJSonObject)
        .GetValue('fromString').ToString);
      toStatus := BeClear((jhiarr.Get(hii) as tJSonObject)
        .GetValue('toString').ToString);
    end;
    if not isStatus then
      Continue;
    Self.Add(TIssueHistory.Create);
    Self[Pred(Self.Count)].OldValue := fromStatus;
    Self[Pred(Self.Count)].NewValue := toStatus;
    Self[Pred(Self.Count)].DateTime := TIso8601.DateTimeFromIso8601
      (BeClear((Ajharr.Get(hi) as tJSonObject).GetValue('created').ToString));
  end;
end;

function TIssueHistoryList.Remove(const Value: TIssueHistory): Integer;
begin
  Value.OwnerList := Self;
  result := inherited Remove(Value);
end;

function TIssueHistoryList.Text: TStringList;
var
  i: Integer;
begin
  FText.Clear;
  for i := 0 to Pred(Count) do
    FText.Add(DateTimeToStr(Self[i].DateTime) + ' - ' + Self[i].OldValue +
      ' -> ' + Self[i].NewValue);
  result := FText;
end;

end.
