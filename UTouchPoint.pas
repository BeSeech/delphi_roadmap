unit UTouchPoint;

interface

uses
  System.SysUtils,
  WinApi.Windows,
  System.Generics.Collections;

const
  cDefInteger = -1000;

Type
  TTouchSessionType = (tstNone, tstClick, tstMove, tstZoom, tstFinished);
  TTouchPoint = class;
  TTouchSession = class;

  TTouchSessionList = class(TObjectList<TTouchSession>)
    Function GetSessionById(const AId: Integer): TTouchSession;
  end;

  TTouchPoints = class(TObjectList<TTouchPoint>)
  public
    Function GetPointById(const AId: Integer): TTouchPoint;
  end;

  TTouchSession = class
  private
    FId: Integer;
    FTouchSessionType: TTouchSessionType;
    FDownPoint: TTouchPoint;
    FMovePointList: TTouchPoints;
    FUpPoint: TTouchPoint;
    function GetMovePoint: TTouchPoint;
  public
    constructor Create(const AId: Integer);
    destructor Destroy;
    function Distance(const ASession: TTouchSession): Extended;
    property Id: Integer read FId;
    property SessionType: TTouchSessionType read FTouchSessionType
      write FTouchSessionType;
    property DownPoint: TTouchPoint read FDownPoint;
    property UpPoint: TTouchPoint read FUpPoint;
    property MovePoint: TTouchPoint read GetMovePoint;
    property MovePointList: TTouchPoints read FMovePointList;
  end;

  TTouchPoint = class
  private
    FX: Integer;
    FId: Integer;
    FY: Integer;
    FDeltaX: Integer;
    FDeltaY: Integer;
    procedure SetX(const Value: Integer);
    procedure SetY(const Value: Integer);
    function GetPoint: TPoint;
    procedure SetPoint(const Value: TPoint);
  public
    property X: Integer read FX write SetX;
    property Y: Integer read FY write SetY;
    property Id: Integer read FId write FId;
    property DeltaX: Integer read FDeltaX;
    property DeltaY: Integer read FDeltaY;
    property AsPoint: TPoint read GetPoint write SetPoint;
    constructor Create; overload;
    constructor Create(ATouchIput: TTouchInput); overload;
    procedure Fill(ATouchIput: TTouchInput);
  end;

implementation

{ TTouchPoints }

function TTouchPoints.GetPointById(const AId: Integer): TTouchPoint;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Pred(Count) do
    if Self[i].Id = AId then
      Result := Self[i];
end;

{ TTouchPoint }

constructor TTouchPoint.Create;
begin
  inherited;
  FX := cDefInteger;
  FY := cDefInteger;
  FId := -1;
  FDeltaX := 0;
  FDeltaY := 0;
end;

constructor TTouchPoint.Create(ATouchIput: TTouchInput);
begin
  inherited Create;
  FX := ATouchIput.X;
  FY := ATouchIput.Y;
  FId := ATouchIput.dwID;
end;

procedure TTouchPoint.Fill(ATouchIput: TTouchInput);
begin
  FX := ATouchIput.X;
  FY := ATouchIput.Y;
  FId := ATouchIput.dwID;
end;

function TTouchPoint.GetPoint: TPoint;
begin
  Result.X := FX;
  Result.Y := FY;
end;

procedure TTouchPoint.SetPoint(const Value: TPoint);
begin
  FX := Value.X;
  FY := Value.Y;
end;

procedure TTouchPoint.SetX(const Value: Integer);
begin
  FDeltaX := Value - FX;
  FX := Value;
end;

procedure TTouchPoint.SetY(const Value: Integer);
begin
  FDeltaY := Value - FY;
  FY := Value;
end;

constructor TTouchSession.Create(const AId: Integer);
begin
  inherited Create;
  FTouchSessionType := tstNone;
  FId := AId;
  FDownPoint := TTouchPoint.Create;
  FMovePointList := TTouchPoints.Create(True);
  FUpPoint := TTouchPoint.Create;
end;

destructor TTouchSession.Destroy;
begin
  inherited;
  FreeAndNil(FDownPoint);
  FreeAndNil(FMovePointList);
  FreeAndNil(FUpPoint);
end;

function TTouchSession.Distance(const ASession: TTouchSession): Extended;
var
  p1, p2: TPoint;
begin
  if Assigned(Self.MovePoint) then
    p1 := Self.MovePoint.AsPoint
  else
    p1 := Self.DownPoint.AsPoint;

  if Assigned(ASession.MovePoint) then
    p2 := ASession.MovePoint.AsPoint
  else
    p2 := ASession.DownPoint.AsPoint;

  Result := p1.Distance(p2);
end;

function TTouchSession.GetMovePoint: TTouchPoint;
begin
  Result := nil;
  if FMovePointList.Count > 0 then
    Result := FMovePointList.Last;
end;

function TTouchSessionList.GetSessionById(const AId: Integer): TTouchSession;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Pred(Count) do
    if Self[i].Id = AId then
      Result := Self[i];
end;

end.
