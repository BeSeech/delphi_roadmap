unit uBeColumn;

interface

uses
  GDIPAPI_Evos,
  GDIPOBJ_EVOS,
  Math,
  uContext,
  Generics.Collections,
  UTouchPoint,
  UBeUtils,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TBeIssue = class;
  TBeIssueLinkList = class;
  TBeIssueColumn = class;
  TBeIssueButtons = class;

  TBeIssueButton = class
  private
    FIssueButtons: TBeIssueButtons;
    FBorder: TRect;
    function GetDrawContext: TDrawContext;
    function GetIssue: TBeIssue;
  public
    function HavePoint(const AGlobalX, AGlobalY: Integer): Boolean;
    procedure Draw; virtual; abstract;
    procedure DrawXY(AGlobalX, AGlobalY: Integer; GPPen: TGPPen);
    property Border: TRect read FBorder write FBorder;
    property Issue: TBeIssue read GetIssue;
    property DrawContext: TDrawContext read GetDrawContext;
    property OwnerButtons: TBeIssueButtons read FIssueButtons;
    constructor Create(AIssueButtons: TBeIssueButtons);
    destructor Destroy;
  end;

  TBeIssueButtonEdit = class(TBeIssueButton)
  public
    procedure Draw; override;
  end;

  TBeIssueButtonDel = class(TBeIssueButton)
  public
    procedure Draw; override;
  end;

  TBeIssueButtonInfo = class(TBeIssueButton)
  public
    procedure Draw; override;
  end;

  TBeIssueButtonMove = class(TBeIssueButton)
  public
    procedure Draw; override;
  end;

  TBeIssueButtons = class
  private
    FIssue: TBeIssue;
    FButtonEdit: TBeIssueButtonEdit;
    FButtonDel: TBeIssueButtonDel;
    FButtonInfo: TBeIssueButtonInfo;
    FButtonMove: TBeIssueButtonMove;
    function GetDrawContext: TDrawContext;
  public
    property ButtonEdit: TBeIssueButtonEdit read FButtonEdit;
    property ButtonDel: TBeIssueButtonDel read FButtonDel;
    property ButtonInfo: TBeIssueButtonInfo read FButtonInfo;
    property ButtonMove: TBeIssueButtonMove read FButtonMove;
    property Issue: TBeIssue read FIssue;
    procedure Draw;
    property DrawContext: TDrawContext read GetDrawContext;
    constructor Create(const AIssue: TBeIssue);
    destructor Destroy; override;
  end;

  TBeIssueLink = class
  private
    FBorder: TRect;
    FToIssue: TBeIssue;
    FOwnerList: TBeIssueLinkList;
    procedure SetBorder(const Value: TRect);
    procedure SetToIssue(const Value: TBeIssue);
    procedure SetOwnerList(const Value: TBeIssueLinkList);
    function GetDrawCotext: TDrawContext;
  public
    function HavePoint(const AGlobalX, AGlobalY: Integer): Boolean;
    constructor Create(const AToIssue: TBeIssue);
    procedure Draw;
    property DrawContext: TDrawContext read GetDrawCotext;
    property OwnerList: TBeIssueLinkList read FOwnerList write SetOwnerList;
    property Border: TRect read FBorder write SetBorder;
    property ToIssue: TBeIssue read FToIssue write SetToIssue;
  end;

  TBeIssueLinkList = class(TObjectList<TBeIssueLink>)
  private
    FOwnerIssueColumn: TBeIssueColumn;
    function GetDrawContext: TDrawContext;
  public
    function GetIssueLinkByPoint(const AGlobalX, AGlobalY: Integer)
      : TBeIssueLink;
    property OwnerIssueColumn: TBeIssueColumn read FOwnerIssueColumn
      write FOwnerIssueColumn;
    property DrawContext: TDrawContext read GetDrawContext;
    function Add(const Value: TBeIssueLink): Integer;
    procedure Insert(Index: Integer; const Value: TBeIssueLink);
    function Remove(const Value: TBeIssueLink): Integer;
    procedure Delete(Index: Integer);

  end;




  TBeIssueColumnList = class(TObjectList<TBeIssueColumn>)
  private
    FSelectedElement: TObject;
    FBorder: TRect;
    FDrawContext: TDrawContext;
    FButtons: TBeIssueButtons;
    procedure SetDrawContext(const Value: TDrawContext);
    procedure SetSelectedElement(const Value: TObject);
  public
    property SelectedElement: TObject read FSelectedElement
      write SetSelectedElement;
    procedure FillFromStrings(const AList: TStrings);
    procedure Draw;
    property Border: TRect read FBorder;
    function HavePoint(const AGlobalX, AGlobalY: Integer): Boolean;
    function GetElemntByGlobalXY(const AGlobalX, AGlobalY: Integer): TObject;
    property DrawContext: TDrawContext read FDrawContext write SetDrawContext;
    function Add(const Value: TBeIssueColumn): Integer;
    procedure Insert(Index: Integer; const Value: TBeIssueColumn);
    function Remove(const Value: TBeIssueColumn): Integer;
    procedure Delete(Index: Integer);
    constructor Create(AOwnsObjects: Boolean = True);
    destructor Destroy;
  end;

  TBeIssueColumn = class(TObjectList<TBeIssue>)
  private
    FIssueLinkList: TBeIssueLinkList;
    FX: Integer;
    FY: Integer;
    FBorder: TRect;
    FOwnerList: TBeIssueColumnList;
    FName: string;
    FPenColor: TColor;
    procedure SetX(const Value: Integer);
    procedure SetY(const Value: Integer);
    function GetCanvas: TCanvas;
    function GetGlobalX: Integer;
    function GetGlobalY: Integer;
    procedure SetOwnerList(const Value: TBeIssueColumnList);
    function GetDrawContext: TDrawContext;
    procedure SetName(const Value: string);
    procedure SetPenColor(const Value: TColor);
  public
    property IssueLinkList: TBeIssueLinkList read FIssueLinkList;
    property PenColor: TColor read FPenColor write SetPenColor;
    property Name: string read FName write SetName;
    function HavePoint(const AGlobalX, AGlobalY: Integer): Boolean;
    function IssueIndexByPoint(const AGlobalX, AGlobalY: Integer): Integer;
    property OwnerList: TBeIssueColumnList read FOwnerList write SetOwnerList;
    property Border: TRect read FBorder;
    property GlobalX: Integer read GetGlobalX;
    property GlobalY: Integer read GetGlobalY;
    procedure Draw;
    property DrawContext: TDrawContext read GetDrawContext;
    property X: Integer read FX write SetX;
    property Y: Integer read FY write SetY;
    function AddIssue(const ABeforeIssue: TBeIssue): Integer;
    function Add(const Value: TBeIssue): Integer;
    procedure Insert(Index: Integer; const Value: TBeIssue);
    function Remove(const Value: TBeIssue): Integer;
    procedure Delete(Index: Integer);
    constructor Create(AOwnsObjects: Boolean = True);
    destructor Destroy;
  end;

  TBeIssue = class
  private
    FBorder: TRect;
    FWidth: Integer;
    FOwnerList: TBeIssueColumn;
    FBrushColor: TColor;
    FPenColor: TColor;
    FFontColor: TColor;
    FX: Integer;
    FY: Integer;
    FHeight: Integer;
    FKey: string;
    FIsOnScreen: Boolean;
    FSummary: string;
    FStatus: string;
    function ScaleInteger(const AValue: Integer): Integer;
    procedure SetWidth(const Value: Integer);
    procedure SetOwnerList(const Value: TBeIssueColumn);
    function GetCanvas: TCanvas;
    procedure SetBrushColor(const Value: TColor);
    procedure SetFontColor(const Value: TColor);
    procedure SetPenColor(const Value: TColor);
    procedure SetX(const Value: Integer);
    procedure SetY(const Value: Integer);
    procedure SetHeight(const Value: Integer);
    procedure SetKey(const Value: string);
    function GetGlobalX: Integer;
    function GetGlobalY: Integer;
    function GetScaledHeight: Integer;
    function GetScaledWidth: Integer;
    function GetBorder: TRect;
    procedure SetIsOnScreen(const Value: Boolean);
    function GetSelected: Boolean;
    procedure SetSummary(const Value: string);
    procedure SetStatus(const Value: string);
  public
    procedure SetDefault;
    function GetBrushGPColorByStatus(const AStatus: string): TGPColor;
    function GetFontColorByStatus(const AStatus: string): TColor;
    function GetBrushGPColorByFilter(const ABaseBrushColor: TGPColor): TGPColor;
    property Status: string read FStatus write SetStatus;
    property Summary: string read FSummary write SetSummary;
    property Selected: Boolean read GetSelected;
    constructor Create; overload;
    constructor Create(const AName: string); overload;
    function HavePoint(const AGlobalX, AGlobalY: Integer): Boolean;
    property IsOnScreen: Boolean read FIsOnScreen write SetIsOnScreen;
    procedure Draw;
    property Border: TRect read GetBorder;
    property Key: string read FKey write SetKey;
    property X: Integer read FX write SetX;
    property Y: Integer read FY write SetY;
    property GlobalX: Integer read GetGlobalX;
    property GlobalY: Integer read GetGlobalY;
    property ScaledHeight: Integer read GetScaledHeight;
    property ScaledWidth: Integer read GetScaledWidth;
    property BrushColor: TColor read FBrushColor write SetBrushColor;
    property PenColor: TColor read FPenColor write SetPenColor;
    property FontColor: TColor read FFontColor write SetFontColor;
    property Canvas: TCanvas read GetCanvas;
    property OwnerList: TBeIssueColumn read FOwnerList write SetOwnerList;
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
  end;

implementation

{ TBeColumn }
function CreateRoundRect(rectangle: TRect; radius: Integer): TGPGraphicsPath;
var
  path: TGPGraphicsPath;
  l, t, w, h, d: Integer;
begin
  path := TGPGraphicsPath.Create;
  l := rectangle.Left;
  t := rectangle.Top;
  w := rectangle.Width;
  h := rectangle.Height;
  d := radius div 2;

  path.AddArc(l, t, d, d, 180, 90); // topleft
  path.AddArc(l + w - d, t, d, d, 270, 90); // topright
  path.AddArc(l + w - d, t + h - d, d, d, 0, 90); // bottomright
  path.AddArc(l, t + h - d, d, d, 90, 90); // bottomleft
  path.CloseFigure();
  result := path;
end;

constructor TBeIssue.Create;
begin
  inherited Create;
  Width := 300;
  Height := IfThen(IsTouchScrean, 100, 80);
  BrushColor := clBtnFace;
  PenColor := clBlack;
  FontColor := clBlack;
  FSummary := 'Загрузка...';
  FStatus := 'Неизвестен';
end;

constructor TBeIssue.Create(const AName: string);
begin
  Create;
  Key := AName;
end;

procedure TBeIssue.Draw;
var
  SummaryTextBorder: TRect;
  SummaryTextBorderA: TRect;

  StatusTextWidth: Integer;
  StatusTextHeight: Integer;
  StatusTextBorder: TRect;

  KeyTextWidth: Integer;
  KeyTextHeight: Integer;
  KeyTextBorder: TRect;

  GPBrush: TGPSolidBrush;
  GPPen: TGPPen;
  path: TGPGraphicsPath;
  GPGraphics: TGPGraphics;
begin
  IsOnScreen := False;
  if not Assigned(Canvas) then
    Exit;
  FBorder := Rect(GlobalX, GlobalY, GlobalX + ScaledWidth,
    GlobalY + ScaledHeight);
  if not Assigned(OwnerList.DrawContext.RectOnScreen) then
    Exit;
  IsOnScreen := OwnerList.DrawContext.RectOnScreen(FBorder);
  if not IsOnScreen then
    Exit;
  GPGraphics := OwnerList.DrawContext.GPGraphics;
  GPBrush := TGPSolidBrush.Create(GetBrushGPColorByFilter(GetBrushGPColorByStatus(Status)));
  path := CreateRoundRect(Border, ScaleInteger(40));

  try
    Canvas.Font.Size := ScaleInteger(8);
    StatusTextWidth := Canvas.TextWidth(Status);
    StatusTextHeight := Canvas.TextHeight(Status);
    KeyTextWidth := Canvas.TextWidth(Key);
    KeyTextHeight := Canvas.TextHeight(Key);

    Canvas.Font.Size := ScaleInteger(10);
    SummaryTextBorder := FBorder;
    SummaryTextBorder.Top := ScaleInteger(5) + SummaryTextBorder.Top +
      KeyTextHeight;
    SummaryTextBorder.Bottom := SummaryTextBorder.Bottom - ScaleInteger(5) -
      StatusTextHeight;
    SummaryTextBorder.Left := ScaleInteger(3) + SummaryTextBorder.Left;
    SummaryTextBorder.Right := SummaryTextBorder.Right - ScaleInteger(3);
    SummaryTextBorderA := SummaryTextBorder;
    Canvas.TextRect(SummaryTextBorder, FSummary, [tfWordBreak, tfEndEllipsis,
      tfCenter, tfCalcRect, tfNoPrefix]);

    GPGraphics.FillPath(GPBrush, path);

    SummaryTextBorder.Left :=
      Round(SummaryTextBorder.Left + ((Point(SummaryTextBorderA.Left,
      0).Distance(Point(SummaryTextBorderA.Right, 0)) / 2) -
      (Point(SummaryTextBorder.Left, 0).Distance(Point(SummaryTextBorder.Right,
      0)) / 2)) / 2);
    SummaryTextBorder.Right := Border.Right - ScaleInteger(3);

    SummaryTextBorder.Top := Max(Border.Top + KeyTextHeight + ScaleInteger(10),
      Round(SummaryTextBorder.Top + ((Point(0, SummaryTextBorderA.Top)
      .Distance(Point(0, SummaryTextBorderA.Bottom)) / 2) - (Point(0,
      SummaryTextBorder.Top).Distance(Point(0, SummaryTextBorder.Bottom)) /
      2)) / 2));
    SummaryTextBorder.Bottom := Border.Bottom - StatusTextHeight -
      ScaleInteger(10) - ScaleInteger(2);

    Canvas.Font.Color := FontColor;
    Canvas.Brush.Style := bsClear;
    Canvas.TextRect(SummaryTextBorder, FSummary, [tfWordBreak, tfEndEllipsis,
      tfCenter, tfNoPrefix]);

    Canvas.Font.Size := ScaleInteger(8);
    StatusTextBorder := FBorder;
    StatusTextBorder.Left := Border.Right - StatusTextWidth - ScaleInteger(5);
    StatusTextBorder.Top := Border.Bottom - StatusTextHeight - ScaleInteger(5);
    StatusTextBorder.Right := Border.Right - ScaleInteger(5);
    StatusTextBorder.Bottom := Border.Bottom - ScaleInteger(5);
    Canvas.Font.Color := GetFontColorByStatus(Status);
    Canvas.TextRect(StatusTextBorder, FStatus, [tfSingleLine, tfEndEllipsis,
      tfRight]);

    KeyTextBorder := FBorder;
    KeyTextBorder.Left := Border.Right - KeyTextWidth - ScaleInteger(5);
    KeyTextBorder.Top := Border.Top + ScaleInteger(5);
    KeyTextBorder.Right := Border.Right - ScaleInteger(5);
    KeyTextBorder.Bottom := Border.Bottom - ScaleInteger(5);
    Canvas.Font.Color := clNavy;
    Canvas.TextRect(KeyTextBorder, FKey, [tfSingleLine, tfEndEllipsis,
      tfRight, tfTop]);

    if Selected then
    begin
      GPPen := TGPPen.Create(MakeColor(255,0,0),ScaleInteger(2));
      GPGraphics.DrawPath(GPPen,Path);
      FreeAndNil(GPPen);
    end;
  finally
    FreeAndNil(path);
    FreeAndNil(GPBrush);
  end;
end;

function TBeIssue.GetBorder: TRect;
begin
  result := FBorder;
end;

function TBeIssue.GetBrushGPColorByStatus(const AStatus: string): TGPColor;
begin
//  result := MakeColor(255, $F0, $F0, $F0);
  result := MakeColor(255, $E0, $E0, $E0);
  if (Pos('In Progress', Status) > 0) or (Pos('Code Review', Status) > 0) or
    (Pos('In Test', Status) > 0) or
    (Pos('Возвращено при тестировании', Status) > 0) then
  begin
    result := MakeColor(255, $A6, $CA, $F0);
    Exit;
  end;
  if (Pos('тклонено', Status) > 0) or
    (Pos('Возвращено при обсуждении', Status) > 0) or
    (Pos('Возвращено при выполнении', Status) > 0) then
  begin
    result := MakeColor(255, $FC, $8F, $8F);
    Exit;
  end;
  if (Pos('Done', Status) > 0) or (Pos('In Release', Status) > 0) then
  begin
    result := MakeColor(255, $C0, $DC, $C0);
    Exit;
  end;
end;

function TBeIssue.GetCanvas: TCanvas;
begin
  result := nil;
  if Assigned(OwnerList) and Assigned(OwnerList.DrawContext) and
    Assigned(OwnerList.DrawContext.Canvas) then
    result := OwnerList.DrawContext.Canvas;
end;

function TBeIssue.GetFontColorByStatus(const AStatus: string): TColor;
begin
  result := clBlack;
  if (Pos('Тестируется', AStatus) > 0) or (Pos('Выполняется', AStatus) > 0) or
    (Pos('Ожидает тестирования', AStatus) > 0) or
    (Pos('Возвращено при тестировании', AStatus) > 0) then
  begin
    result := clBlue;
    Exit;
  end;
  if (Pos('тклонено', AStatus) > 0) or
    (Pos('Возвращено при обсуждении', AStatus) > 0) or
    (Pos('Возвращено при выполнении', AStatus) > 0) then
  begin
    result := clRed;
    Exit;
  end;
  if Pos('Выполнено', AStatus) > 0 then
  begin
    result := clGreen;
    Exit;
  end;
end;

function TBeIssue.GetGlobalX: Integer;
begin
  result := OwnerList.GlobalX + X;
end;

function TBeIssue.GetGlobalY: Integer;
begin
  result := OwnerList.GlobalY + Y;
end;

function TBeIssue.GetBrushGPColorByFilter(
  const ABaseBrushColor: TGPColor): TGPColor;
var
  Alpha: Byte;
  R, G, B: Byte;
begin
  result := ABaseBrushColor;
  if OwnerList.DrawContext.Filter = EmptyStr then
    Exit;
  if Pos(OwnerList.DrawContext.Filter, Key) > 0 then
    Exit;
  if Pos(OwnerList.DrawContext.Filter, Summary) > 0 then
    Exit;
  if OwnerList.DrawContext.Filter = Status then
    Exit;
  Alpha := GetAlpha(Result);
  R := GetRed(Result);
  G := GetGreen(Result);
  B := GetBlue(Result);
  result := MakeColor(Alpha div 4, R, G, B);
end;

function TBeIssue.GetScaledHeight: Integer;
begin
  result := Round(Height * OwnerList.DrawContext.Scale);
  if result < 1 then
    result := 1;
end;

function TBeIssue.GetScaledWidth: Integer;
begin
  result := Round(Width * OwnerList.DrawContext.Scale);
  if result < 1 then
    result := 1;
end;

function TBeIssue.GetSelected: Boolean;
begin
  result := Assigned(OwnerList) and Assigned(OwnerList.OwnerList) and
    (OwnerList.OwnerList.SelectedElement = Self);
end;

function TBeIssue.HavePoint(const AGlobalX, AGlobalY: Integer): Boolean;
begin
  result := Border.Contains(Point(AGlobalX, AGlobalY));
end;

function TBeIssue.ScaleInteger(const AValue: Integer): Integer;
begin
  result := Max(1, Trunc(AValue * OwnerList.DrawContext.Scale));
end;

procedure TBeIssue.SetBrushColor(const Value: TColor);
begin
  FBrushColor := Value;
end;

procedure TBeIssue.SetDefault;
begin
  Summary := 'Загрузка...';
  Status := 'Неизвестен';
end;

procedure TBeIssue.SetFontColor(const Value: TColor);
begin
  FFontColor := Value;
end;

procedure TBeIssue.SetHeight(const Value: Integer);
begin
  FHeight := Value;
end;

procedure TBeIssue.SetIsOnScreen(const Value: Boolean);
begin
  FIsOnScreen := Value;
end;

procedure TBeIssue.SetKey(const Value: string);
begin
  FKey := Value;
end;

procedure TBeIssue.SetOwnerList(const Value: TBeIssueColumn);
begin
  FOwnerList := Value;
end;

procedure TBeIssue.SetPenColor(const Value: TColor);
begin
  FPenColor := Value;
end;

procedure TBeIssue.SetStatus(const Value: string);
begin
  FStatus := Value;
end;

procedure TBeIssue.SetSummary(const Value: string);
begin
  FSummary := Value;
end;

procedure TBeIssue.SetWidth(const Value: Integer);
begin
  FWidth := Value;
end;

procedure TBeIssue.SetX(const Value: Integer);
begin
  FX := Value;
end;

procedure TBeIssue.SetY(const Value: Integer);
begin
  FY := Value;
end;

{ TBeColumnList }

function TBeIssueColumn.Add(const Value: TBeIssue): Integer;
begin
  result := inherited Add(Value);
  Value.OwnerList := Self;
end;

function TBeIssueColumn.AddIssue(const ABeforeIssue: TBeIssue): Integer;
begin
  if Assigned(ABeforeIssue) then
    result := Self.IndexOf(ABeforeIssue)
  else
    result := Self.Count;
  Self.Insert(result, TBeIssue.Create('TN-Random'));
  DrawContext.NeedRepaint := True;
end;

constructor TBeIssueColumn.Create(AOwnsObjects: Boolean = True);
begin
  inherited;
  Name := 'IssueColumn';
  FIssueLinkList := TBeIssueLinkList.Create(True);
  FIssueLinkList.OwnerIssueColumn := Self;
end;

procedure TBeIssueColumn.Delete(Index: Integer);
begin
  Self[Index].OwnerList := nil;
  inherited Delete(Index);
end;

destructor TBeIssueColumn.Destroy;
begin
  Clear;
  FreeAndNil(FIssueLinkList);
  inherited;
end;

procedure TBeIssueColumn.Draw;
var
  i: Integer;
  PrevY: Integer;
  tw, th, ts: Integer;
  HSpace: Extended;
  GPPen: TGPPen;

begin
  while FIssueLinkList.Count > 0 do
    FIssueLinkList.Delete(0);

  PrevY := 0;
  ts := Round(18 * DrawContext.Scale);
  DrawContext.Canvas.Font.Size := ts;
  th := DrawContext.Canvas.TextHeight(Self.Name);
  tw := DrawContext.Canvas.TextWidth(Self.Name) + DrawContext.ScaleInteger(10) ;

  FBorder.Top := GlobalY;
  FBorder.Left := GlobalX;
  FBorder.Right := GlobalX + Max(tw+DrawContext.ScaleInteger(10), DrawContext.ScaleInteger(200));
  FBorder.Bottom := GlobalY + DrawContext.ScaleInteger(10);
  HSpace := DrawContext.GetVerticalSpace * DrawContext.Scale;

  for i := 0 to Pred(Count) do
  begin
    Self[i].X := Round(10 * DrawContext.Scale);
    if i = 0 then
      Self[i].Y := Round(10 * DrawContext.Scale) + th
    else
      Self[i].Y := PrevY + Round(Self[i].ScaledHeight + HSpace);
    PrevY := Self[i].Y;
    Self[i].Draw;
    if DrawContext.EditMode then
    begin
      if (Self[i].IsOnScreen) or
        ((i > 1) and (Self[i - 1].IsOnScreen and (not Self[i].IsOnScreen))) then
        FIssueLinkList.Add(TBeIssueLink.Create(Self[i]));
    end;
    FBorder.Right := Max(FBorder.Right, Self[i].Border.Right +
      DrawContext.ScaleInteger(10));
    FBorder.Left := Min(FBorder.Left, Self[i].Border.Left -
      DrawContext.ScaleInteger(10));
  end;
  if Count > 0 then
    FBorder.Bottom := Self[Pred(Count)].Border.Bottom +
      Round(10 * DrawContext.Scale);
  if DrawContext.EditMode then
  begin
    FIssueLinkList.Add(TBeIssueLink.Create(nil));
    FBorder.Top := Self.Border.Top - Round(HSpace);
  end;
  FBorder.Bottom := Self.Border.Bottom + Round(HSpace);
  DrawContext.Canvas.Brush.Style := bsClear;
  DrawContext.Canvas.Font.Size := ts;
  DrawContext.Canvas.Font.Color := PenColor;


  GPPen:= TGPPen.Create(ColorRefToARGB(PenColor),Round(2 * DrawContext.Scale));
  DrawContext.GPGraphics.DrawLine(GPPen, Border.Right - tw, Border.Top + th + 1, Border.Right, Border.Top + th + 1);
  FreeAndNil(GPPen);


  DrawContext.Canvas.TextRect(Border, Border.Right - tw -
    Round(2 * DrawContext.Scale), Border.Top, Name);


  for i := 0 to Pred(FIssueLinkList.Count) do
    FIssueLinkList[i].Draw;
end;

function TBeIssueColumn.GetCanvas: TCanvas;
begin
  result := nil;
  if Assigned(DrawContext) and Assigned(DrawContext.Canvas) then
    result := DrawContext.Canvas;
end;

function TBeIssueColumn.GetDrawContext: TDrawContext;
begin
  result := nil;
  if Assigned(OwnerList) then
    result := OwnerList.DrawContext;
end;

function TBeIssueColumn.GetGlobalX: Integer;
begin
  result := Round(X * DrawContext.Scale + DrawContext.OffsetX);
end;

function TBeIssueColumn.GetGlobalY: Integer;
begin
  result := Round(Y * DrawContext.Scale + DrawContext.OffsetY);
end;

function TBeIssueColumn.HavePoint(const AGlobalX, AGlobalY: Integer): Boolean;
begin
  result := Border.Contains(Point(AGlobalX, AGlobalY));
end;

procedure TBeIssueColumn.Insert(Index: Integer; const Value: TBeIssue);
begin
  inherited Insert(Index, Value);
  Value.OwnerList := Self;
end;

function TBeIssueColumn.IssueIndexByPoint(const AGlobalX,
  AGlobalY: Integer): Integer;
var
  i: Integer;
begin
  result := -1;
  for i := 0 to Pred(Count) do
    if Self[i].HavePoint(AGlobalX, AGlobalY) then
    begin
      result := i;
      Exit;
    end;
end;

function TBeIssueColumn.Remove(const Value: TBeIssue): Integer;
begin
  Value.OwnerList := Self;
  result := inherited Remove(Value);
end;

procedure TBeIssueColumn.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TBeIssueColumn.SetOwnerList(const Value: TBeIssueColumnList);
begin
  FOwnerList := Value;
end;

procedure TBeIssueColumn.SetPenColor(const Value: TColor);
begin
  FPenColor := Value;
end;

procedure TBeIssueColumn.SetX(const Value: Integer);
begin
  FX := Value;
end;

procedure TBeIssueColumn.SetY(const Value: Integer);
begin
  FY := Value;
end;

{ TBeIssueColumnList }

function TBeIssueColumnList.Add(const Value: TBeIssueColumn): Integer;
begin
  result := inherited Add(Value);
  Value.OwnerList := Self;
end;

constructor TBeIssueColumnList.Create(AOwnsObjects: Boolean);
begin
  inherited Create(AOwnsObjects);
  FButtons := nil;
end;

procedure TBeIssueColumnList.Delete(Index: Integer);
begin
  Self[Index].OwnerList := nil;
  if Assigned(FButtons) then
    FreeAndNil(FButtons);
  inherited Delete(Index);
end;

destructor TBeIssueColumnList.Destroy;
begin
  inherited;
end;

procedure TBeIssueColumnList.Draw;
var
  i: Integer;
  PriorX: Integer;
  MaxBottom: Integer;
  GPPen: TGPPen;
begin
  FBorder.Top := MaxInt;
  FBorder.Left := MaxInt;
  FBorder.Bottom := 0;
  FBorder.Right := 0;
  MaxBottom := 0;
  PriorX := 10;
  for i := 0 to Pred(Count) do
  begin
    Self[i].Y := 10;
    Self[i].X := PriorX;
    Self[i].Draw;
    FBorder.Top := Min(FBorder.Top, Self[i].FBorder.Top);
    FBorder.Left := Min(FBorder.Left, Self[i].FBorder.Left);
    FBorder.Right := Max(FBorder.Right, Self[i].FBorder.Right);
    FBorder.Bottom := Max(FBorder.Bottom, Self[i].FBorder.Bottom);
    PriorX := DrawContext.GlobalToLocal(Self[i].Border.Right,
      Self[i].Border.Bottom).X + 50;
    MaxBottom := Max(MaxBottom, Self[i].Border.Bottom);
  end;

  for i := 0 to Pred(Count) do
  begin
    GPPen:= TGPPen.Create(ColorRefToARGB(Self[i].PenColor),Round(2 * DrawContext.Scale));
    DrawContext.GPGraphics.DrawLine(GPPen, Self[i].Border.Right, Self[i].Border.Top,Self[i].Border.Right, MaxBottom);
    FreeAndNil(GPPen);
  end;

  if Assigned(FButtons) then
    FButtons.Draw;
end;

procedure TBeIssueColumnList.FillFromStrings(const AList: TStrings);
var
  i: Integer;
  Column: TBeIssueColumn;
  List: TStringList;
  lName: String;
  lColor: TColor;
begin
  List := TStringList.Create;
  try
    for i := 0 to Pred(AList.Count) do
    begin
      if Pos(':', AList[i]) = 0 then
        Continue;
      List.Add(AList[i]);
    end;

    for i := 0 to Pred(List.Count) do
    begin
      lName := Trim(Copy(List[i], 1, Pos(':', List[i]) - 1));
      lColor := StringToColor(Trim(Copy(List[i], Pos(':', List[i]) + 1,
        Length(List[i]))));
      if Self.Count <= i then
      begin
        Column := TBeIssueColumn.Create(True);
        Self.Add(Column);
      end
      else
        Column := Self[i];
      Column.Name := lName;
      Column.PenColor := lColor;
    end;

    Self.Count := List.Count;
  finally
    FreeAndNil(List);
  end;
  DrawContext.NeedRepaint := True;
end;

function TBeIssueColumnList.GetElemntByGlobalXY(const AGlobalX,
  AGlobalY: Integer): TObject;
var
  iColumn, iIssue, iLink: Integer;
begin
  result := nil;
  if HavePoint(AGlobalX, AGlobalY) then
  begin
    result := Self;
    if Assigned(FButtons) then
    begin
      if FButtons.ButtonEdit.HavePoint(AGlobalX, AGlobalY) then
      begin
        result := FButtons.ButtonEdit;
        Exit;
      end;
      if FButtons.ButtonMove.HavePoint(AGlobalX, AGlobalY) then
      begin
        result := FButtons.ButtonMove;
        Exit;
      end;
      if FButtons.ButtonInfo.HavePoint(AGlobalX, AGlobalY) then
      begin
        result := FButtons.ButtonInfo;
        Exit;
      end;
      if FButtons.ButtonDel.HavePoint(AGlobalX, AGlobalY) then
      begin
        result := FButtons.ButtonDel;
        Exit;
      end;
    end;
    for iColumn := 0 to Pred(Count) do
    begin
      if Self[iColumn].HavePoint(AGlobalX, AGlobalY) then
      begin
        result := Self[iColumn];
        for iLink := 0 to Pred(Self[iColumn].IssueLinkList.Count) do
        begin
          if Self[iColumn].IssueLinkList[iLink].HavePoint(AGlobalX, AGlobalY)
          then
          begin
            result := Self[iColumn].IssueLinkList[iLink];
            Exit;
          end;
        end;
        for iIssue := 0 to Pred(Self[iColumn].Count) do
        begin
          if Self[iColumn][iIssue].HavePoint(AGlobalX, AGlobalY) then
          begin
            result := Self[iColumn][iIssue];
            Exit;
          end;
        end;
      end;
    end;
  end;
end;

function TBeIssueColumnList.HavePoint(const AGlobalX,
  AGlobalY: Integer): Boolean;
begin
  result := Border.Contains(Point(AGlobalX, AGlobalY));
end;

procedure TBeIssueColumnList.Insert(Index: Integer;
  const Value: TBeIssueColumn);
begin
  inherited Insert(Index, Value);
  Value.OwnerList := Self;
end;

function TBeIssueColumnList.Remove(const Value: TBeIssueColumn): Integer;
begin
  Value.OwnerList := Self;
  result := inherited Remove(Value);
end;

procedure TBeIssueColumnList.SetDrawContext(const Value: TDrawContext);
begin
  FDrawContext := Value;
end;

procedure TBeIssueColumnList.SetSelectedElement(const Value: TObject);
begin
  if FSelectedElement <> Value then
  begin
    DrawContext.NeedRepaint := True;
    FSelectedElement := Value;
    if Assigned(FSelectedElement) and (FSelectedElement is TBeIssue) then
    begin
      FButtons := TBeIssueButtons.Create(FSelectedElement as TBeIssue);
    end
    else
    begin
      if Assigned(FButtons) then
        FreeAndNil(FButtons);
    end;
  end;
end;

{ TBeIssueLink }
constructor TBeIssueLink.Create(const AToIssue: TBeIssue);
begin
  inherited Create;
  ToIssue := AToIssue;
end;

procedure TBeIssueLink.Draw;
var
  X, Y: Integer;
  r: Extended;
  cTBorder: TRect;
  s: string;
  Space: Integer;
  HSpace: Extended;
  clr: TColor;
  GPBrush: TGPSolidBrush;
  GPPen:  TGPPen;
begin
  clr := IfThen(DrawContext.IsMoveMode, clBlue, clSkyBlue);
  GPPen := TGPPen.Create(ColorRefToARGB(clr),1);
  GPBrush := TGPSolidBrush.Create(ColorRefToARGB(clr));
  HSpace := DrawContext.GetVerticalSpace * DrawContext.Scale;
  if Assigned(ToIssue) then
  begin
    X := Round(ToIssue.Border.Left + ToIssue.Border.Width / 2);
    Y := Round(ToIssue.Border.Top - HSpace / 2);
  end
  else
  begin
    X := Round(OwnerList.OwnerIssueColumn.Border.Left +
      OwnerList.OwnerIssueColumn.Border.Width / 2);
    Y := Round(OwnerList.OwnerIssueColumn.Border.Bottom - HSpace / 2);
  end;
  r := (HSpace - 10) / 2;
  Space := DrawContext.ScaleInteger(DrawContext.GetSpace);

  Border := Rect(Round(X - r), Round(Y - r), Round(X + r), Round(Y + r));
  DrawContext.GPGraphics.DrawEllipse(GPPen, MakeRect(Border));

  cTBorder := Rect(Round(Border.Left + Border.Width / 2 -
    DrawContext.ScaleInteger(2)), Border.Top + Space,
    Round(Border.Left + Border.Width / 2 + DrawContext.ScaleInteger(2)),
    Border.Bottom - Space);

  DrawContext.GPGraphics.FillRectangle(GPBrush, MakeRect(cTBorder));

  cTBorder := Rect(Border.Left + Space,
    Round(Border.Top + Border.Height / 2 - DrawContext.ScaleInteger(2)),
    Border.Right - Space, Round(Border.Top + Border.Height / 2 +
    DrawContext.ScaleInteger(2)));

  DrawContext.GPGraphics.FillRectangle(GPBrush, MakeRect(cTBorder));

  FreeAndNil(GPBrush);
  FreeAndNil(GPPen);
end;

function TBeIssueLink.GetDrawCotext: TDrawContext;
begin
  result := OwnerList.DrawContext;
end;

function TBeIssueLink.HavePoint(const AGlobalX, AGlobalY: Integer): Boolean;
begin
  result := Border.Contains(Point(AGlobalX, AGlobalY));
end;

procedure TBeIssueLink.SetBorder(const Value: TRect);
begin
  FBorder := Value;
end;

procedure TBeIssueLink.SetOwnerList(const Value: TBeIssueLinkList);
begin
  FOwnerList := Value;
end;

procedure TBeIssueLink.SetToIssue(const Value: TBeIssue);
begin
  FToIssue := Value;
end;

{ TBeIssueLinkList }

function TBeIssueLinkList.Add(const Value: TBeIssueLink): Integer;
begin
  result := inherited Add(Value);
  Value.OwnerList := Self;
end;

procedure TBeIssueLinkList.Delete(Index: Integer);
begin
  Self[Index].OwnerList := nil;
  inherited Delete(Index);
end;

function TBeIssueLinkList.GetDrawContext: TDrawContext;
begin
  result := OwnerIssueColumn.DrawContext;
end;

function TBeIssueLinkList.GetIssueLinkByPoint(const AGlobalX, AGlobalY: Integer)
  : TBeIssueLink;
var
  i: Integer;
begin
  result := nil;
  for i := 0 to Pred(Count) do
    if Self[i].HavePoint(AGlobalX, AGlobalY) then
    begin
      result := Self[i];
      Exit;
    end;
end;

procedure TBeIssueLinkList.Insert(Index: Integer; const Value: TBeIssueLink);
begin
  inherited Insert(Index, Value);
  Value.OwnerList := Self;
end;

function TBeIssueLinkList.Remove(const Value: TBeIssueLink): Integer;
begin
  Value.OwnerList := Self;
  result := inherited Remove(Value);
end;

{ TBeIssueButtons }

constructor TBeIssueButtons.Create(const AIssue: TBeIssue);
begin
  FIssue := AIssue;
  FButtonEdit := TBeIssueButtonEdit.Create(Self);
  FButtonDel := TBeIssueButtonDel.Create(Self);
  FButtonInfo := TBeIssueButtonInfo.Create(Self);
  FButtonMove := TBeIssueButtonMove.Create(Self);

end;

destructor TBeIssueButtons.Destroy;
begin
  FreeAndNil(FButtonEdit);
  FreeAndNil(FButtonDel);
  FreeAndNil(FButtonInfo);
  FreeAndNil(FButtonMove);
  inherited;
end;

procedure TBeIssueButtons.Draw;
begin
  if not Assigned(FIssue) then
    Exit;
  if not DrawContext.IsMoveMode then
  begin
    if DrawContext.EditMode then
      FButtonEdit.Draw;
    //if DrawContext.EditMode then
    FButtonDel.Draw;
    FButtonInfo.Draw;
  end;
  if (DrawContext.EditMode) then
    FButtonMove.Draw;
end;

function TBeIssueButtons.GetDrawContext: TDrawContext;
begin
  result := FIssue.OwnerList.DrawContext;
end;

{ TBeIssueButton }

constructor TBeIssueButton.Create(AIssueButtons: TBeIssueButtons);
begin
  FIssueButtons := AIssueButtons;
end;

destructor TBeIssueButton.Destroy;
begin
  inherited;
end;

procedure TBeIssueButton.DrawXY(AGlobalX, AGlobalY: Integer; GPPen: TGPPen);
var
  X, Y: Integer;
  r: Extended;
  cTBorder: TRect;
  s: string;
  Space: Integer;
  HSpace: Extended;
  GPBrush : TGPSolidBrush;
  Color: TGPColor;
  A, Red, G, B: Byte;
begin
  GPPen.GetColor(Color);
  A := GetAlpha(Color);
  Red := GetRed(Color);
  G := GetGreen(Color);
  B := GetBlue(Color);
  GPBrush := TGPSolidBrush.Create(MakeColor(A div 4, Red, G, B));

  HSpace := DrawContext.GetVerticalSpace * DrawContext.Scale;
  X := AGlobalX;
  Y := AGlobalY;
  r := (HSpace - 12) / 2;
  Space := DrawContext.ScaleInteger(10);
  Border := Rect(Round(X - r), Round(Y - r), Round(X + r), Round(Y + r));
  DrawContext.GPGraphics.FillEllipse(GPBrush, MakeRect(Border));
  DrawContext.GPGraphics.DrawEllipse(GPPen, MakeRect(Border));
  FreeAndNil(GPBrush);
end;

function TBeIssueButton.GetDrawContext: TDrawContext;
begin
  result := OwnerButtons.DrawContext;
end;

function TBeIssueButton.GetIssue: TBeIssue;
begin
  result := OwnerButtons.Issue;
end;

function TBeIssueButton.HavePoint(const AGlobalX, AGlobalY: Integer): Boolean;
begin
  result := Border.Contains(Point(AGlobalX, AGlobalY));
end;

procedure TBeIssueButtonEdit.Draw;
var
  X, Y: Integer;
  HSpace: Extended;
  GPPen: TGPPen;
begin
  GPPen := TGPPen.Create(ColorRefToARGB(clGray),1);

  HSpace := DrawContext.GetVerticalSpace * DrawContext.Scale;
  X := Round(Issue.Border.Left + HSpace / 2);
  Y := Round(Issue.Border.Top - HSpace / 2);
  DrawXY(X, Y, GPPen);
  FreeAndNil(GPPen);
end;

procedure TBeIssueButtonDel.Draw;
var
  X, Y: Integer;
  HSpace: Extended;
  GPPen: TGPPen;
begin
  if OwnerButtons.DrawContext.EditMode then
    GPPen := TGPPen.Create(ColorRefToARGB(clRed),1)
  else
    GPPen := TGPPen.Create(MakeColor(200, 0, 180, 0),1);
  HSpace := DrawContext.GetVerticalSpace * DrawContext.Scale;
  X := Round(Issue.Border.Left + HSpace / 2);
  Y := Round(Issue.Border.Bottom + HSpace / 2);
  DrawXY(X, Y, GPPen);
  FreeAndNil(GPPen);
end;

procedure TBeIssueButtonInfo.Draw;
var
  X, Y: Integer;
  HSpace: Extended;
  GPPen: TGPPen;
begin
  GPPen := TGPPen.Create(ColorRefToARGB(clSkyBlue),1);
  HSpace := DrawContext.GetVerticalSpace * DrawContext.Scale;
  X := Round(Issue.Border.Right - HSpace / 2);
  Y := Round(Issue.Border.Bottom + HSpace / 2);
  DrawXY(X, Y, GPPen);
  FreeAndNil(GPPen);
end;

procedure TBeIssueButtonMove.Draw;
var
  X, Y: Integer;
  HSpace: Extended;
  GPPen: TGPPen;
begin
  GPPen := TGPPen.Create(MakeColor(200, 0, 0, 255),1);
  HSpace := DrawContext.GetVerticalSpace * DrawContext.Scale;
  X := Round(Issue.Border.Right - HSpace / 2);
  Y := Round(Issue.Border.Top - HSpace / 2);
  DrawXY(X, Y, GPPen);
  FreeAndNil(GPPen);
end;

end.
