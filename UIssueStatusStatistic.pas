unit UIssueStatusStatistic;

interface

uses
  UIssueHistory,
  System.DateUtils,
  Vcl.ExtCtrls,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

const
  cWorkHours = 7;

type
  TIssueStatus = class;

  TIssueStatusList = class(TObjectList<TIssueStatus>)
  private
    FText: TStringList;
  public
    function Text: TStringList;
    procedure FillFromHistoryList(const AHistory: TIssueHistoryList);
    function GetStatusByName(const AName: string): TIssueStatus;
    function HaveStatusWithName(const AName: string): Boolean;
    function Add(const Value: TIssueStatus): Integer;
    procedure Insert(Index: Integer; const Value: TIssueStatus);
    function Remove(const Value: TIssueStatus): Integer;
    procedure Delete(Index: Integer);
    constructor Create(AOwnsObjects: Boolean = True);
    destructor Destroy;

  end;

  TIssueStatus = class
  private
    FOwnerList: TIssueStatusList;
    FName: string;
    FHours: Integer;
    FDays: Integer;
  public
    constructor Create(const AName: string); overload;
    property OwnerList: TIssueStatusList read FOwnerList write FOwnerList;
    property Name: string read FName write FName;
    property Hours: Integer read FHours write FHours;
    property Days: Integer read FDays write FDays;
  end;

  TIssueStatusStatistic = class
  private
    FItems: TIssueStatusList;
    FError: string;
    FKey: string;
    FStatus: string;
    FSummary: string;
    function GetItem(AIndex: Integer): TIssueStatus;
    procedure SetItem(AIndex: Integer; const Value: TIssueStatus);
  public
    property Key: string read FKey write FKey;
    property Summary: string read FSummary write FSummary;
    property Status: string read FStatus write FStatus;
    property Error: string read FError write FError;
    property Item[AIndex: Integer]: TIssueStatus read GetItem
      write SetItem; default;
    property Statuses: TIssueStatusList read FItems;
    constructor Create; overload;
    destructor Destroy; override;
  end;

implementation

{ TIssueStatusList }

function TIssueStatusList.Add(const Value: TIssueStatus): Integer;
begin
  result := inherited Add(Value);
  Value.OwnerList := Self;
end;

constructor TIssueStatusList.Create(AOwnsObjects: Boolean);
begin
  inherited Create(AOwnsObjects);
  FText := TStringList.Create;
end;

procedure TIssueStatusList.Delete(Index: Integer);
begin
  Self[Index].OwnerList := nil;
  inherited Delete(Index);
end;

destructor TIssueStatusList.Destroy;
begin
  FreeAndNil(FText);
  inherited;
end;

procedure TIssueStatusList.FillFromHistoryList(const AHistory
  : TIssueHistoryList);
var
  i: Integer;
  Status: TIssueStatus;
  PriorDateTime: TDateTime;
  dbtw, hbtw, id, holidaysdbtw: Integer;
begin
  Self.Clear;
  PriorDateTime := 0;
  for i := 0 to Pred(AHistory.Count) do
  begin
    dbtw := 0;
    hbtw := 0;
    if PriorDateTime > 0 then
    begin
      dbtw := DaysBetween(PriorDateTime, AHistory[i].DateTime);
      holidaysdbtw := 0;
      for id := 0 to Pred(dbtw) do
      begin
        if DayOfWeek(PriorDateTime + id) in [1, 7] then
          holidaysdbtw := holidaysdbtw + 1;
      end;
      dbtw := dbtw - holidaysdbtw;
      if dbtw < 0 then
        raise Exception.Create('Wtf with holidays?');
      hbtw := HoursBetween(PriorDateTime, AHistory[i].DateTime);
      if dbtw > 0 then
        hbtw := dbtw * cWorkHours;
    end;
    Status := Self.GetStatusByName(AHistory[i].OldValue);
    if not Assigned(Status) then
    begin
      Status := TIssueStatus.Create(AHistory[i].OldValue);
      Self.Add(Status);
    end;
    Status.Hours := Status.Hours + hbtw;
    Status.Days := Status.Days + dbtw;
    PriorDateTime := AHistory[i].DateTime;
  end;

  i := Pred(AHistory.Count);
  dbtw := 0;
  hbtw := 0;
  if PriorDateTime > 0 then
  begin
    dbtw := DaysBetween(AHistory[i].DateTime, now);
    holidaysdbtw := 0;
    for id := 0 to Pred(dbtw) do
    begin
      if DayOfWeek(AHistory[i].DateTime + id) in [1, 7] then
        holidaysdbtw := holidaysdbtw + 1;
    end;
    dbtw := dbtw - holidaysdbtw;
    if dbtw < 0 then
      raise Exception.Create('Wtf with holidays?');
    hbtw := HoursBetween(AHistory[i].DateTime, now);
    if dbtw > 0 then
      hbtw := dbtw * cWorkHours;
  end;
  Status := Self.GetStatusByName(AHistory[i].NewValue);
  if not Assigned(Status) then
  begin
    Status := TIssueStatus.Create(AHistory[i].NewValue);
    Self.Add(Status);
  end;
  Status.Hours := Status.Hours + hbtw;
  Status.Days := Status.Days + dbtw;
  PriorDateTime := AHistory[i].DateTime;
end;

function TIssueStatusList.GetStatusByName(const AName: string): TIssueStatus;
var
  i: Integer;
begin
  result := nil;
  for i := 0 to Pred(Count) do
    if Self[i].Name = AName then
    begin
      result := Self[i];
      Break;
    end;
end;

function TIssueStatusList.HaveStatusWithName(const AName: string): Boolean;
begin
  result := Assigned(GetStatusByName(AName));
end;

procedure TIssueStatusList.Insert(Index: Integer; const Value: TIssueStatus);
begin
  inherited Insert(Index, Value);
  Value.OwnerList := Self;
end;

function TIssueStatusList.Remove(const Value: TIssueStatus): Integer;
begin
  Value.OwnerList := Self;
  result := inherited Remove(Value);
end;

function TIssueStatusList.Text: TStringList;
var
  i: Integer;
begin
  FText.Clear;
  for i := 0 to Pred(Count) do
    FText.Add(Self[i].FName + ' : ' + IntToStr(Self[i].FHours) + ' часов; ' +
      IntToStr(Self[i].FDays) + ' дней;');
  result := FText;
end;

{ TIssueStatusStatistic }

constructor TIssueStatusStatistic.Create;
begin
  inherited;
  FItems := TIssueStatusList.Create(True);
  FError := EmptyStr;
end;

destructor TIssueStatusStatistic.Destroy;
begin
  FreeAndNil(FItems);
  inherited;
end;

function TIssueStatusStatistic.GetItem(AIndex: Integer): TIssueStatus;
begin
  result := FItems[AIndex];
end;

procedure TIssueStatusStatistic.SetItem(AIndex: Integer;
  const Value: TIssueStatus);
begin
  FItems[AIndex] := Value;
end;

{ TIssueStatus }

constructor TIssueStatus.Create(const AName: string);
begin
  inherited Create;
  FName := AName;
  FHours := 0;
  FDays := 0;
end;

end.
