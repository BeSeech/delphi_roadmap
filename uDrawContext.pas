unit uDrawContext;

interface

uses
  System.Types,
  Generics.Collections,
  UTouchPoint,
  UBeUtils,
  Vcl.ExtCtrls, // TImage
  Vcl.StdCtrls, // TMemo
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TIssueR = record
    Summary: string;
    Status: string;
    Key: string;
    Components: string;
    Link: string;
  end;

  TRectOnScreen = function(const ARect: TRect): Boolean of object;
  TGetIssueFromJiraByKey = function(const AKey: string): TIssueR of object;

  TDrawContext = class
  private
    FCanvas: TCanvas;
    FScale: Extended;
    FOffsetX: Extended;
    FOffsetY: Extended;
    FRectOnScreen: TRectOnScreen;
    FGetIssueFromJiraByKey: TGetIssueFromJiraByKey;
    FNeedRepaint: Boolean;
    FIsMoveMode: Boolean;
    FEditMode: Boolean;
    FVerticalSpace: Integer;
    FSpace: Integer;
    FIsPngDrawing: Boolean;
    procedure SetScale(const Value: Extended);
    procedure SetRectOnScreen(const Value: TRectOnScreen);
    procedure SetNeedRepaint(const Value: Boolean);
    procedure SetOffsetX(const Value: Extended);
    procedure SetOffsetY(const Value: Extended);
    procedure SetEditMode(const Value: Boolean);
    procedure SetIsMoveMode(const Value: Boolean);
    function GetOffsetX: Extended;
    function GetOffsetY: Extended;
    function GetScale: Extended;
  public
    function GetVerticalSpace: Integer;
    function GetSpace: Integer;
    property IsPngDrawing: Boolean read FIsPngDrawing write FIsPngDrawing;
    property IsMoveMode: Boolean read FIsMoveMode write SetIsMoveMode;
    property EditMode: Boolean read FEditMode write SetEditMode;
    property NeedRepaint: Boolean read FNeedRepaint write SetNeedRepaint;
    function GlobalToLocal(const AX, AY: Integer): TPoint;
    function LocalToGlobal(const AX, AY: Integer): TPoint;
    function ScaleInteger(const AValue: Integer): Integer;
    function GetDistanse(const AX1, AY1, AX2, AY2: Integer): Extended;
    property RectOnScreen: TRectOnScreen read FRectOnScreen
      write SetRectOnScreen;
    property GetIssueFromJiraByKey: TGetIssueFromJiraByKey
      read FGetIssueFromJiraByKey write FGetIssueFromJiraByKey;
    constructor Create(const ACanvas: TCanvas);
    property OffsetX: Extended read GetOffsetX write SetOffsetX;
    property OffsetY: Extended read GetOffsetY write SetOffsetY;
    property Scale: Extended read GetScale write SetScale;
    property Canvas: TCanvas read FCanvas write FCanvas;
  end;

implementation

{ TDrawContext }

constructor TDrawContext.Create(const ACanvas: TCanvas);
begin
  if IsTouchScrean then
  begin
    FVerticalSpace := 60;
    FSpace := 10;
  end
  else
  begin
    FVerticalSpace := 40;
    FSpace := 5;
  end;
  FScale := 1;
  FNeedRepaint := True;
  FCanvas := ACanvas;
  FOffsetX := 0;
  FOffsetY := 50;
end;

function TDrawContext.GetDistanse(const AX1, AY1, AX2, AY2: Integer): Extended;
begin
  Result := Round(sqrt(sqr(AX2 - AX1) + sqr(AY2 - AY1)));
end;

function TDrawContext.GetOffsetX: Extended;
begin
  if FIsPngDrawing then
    Result := 0
  else
    Result := FOffsetX;
end;

function TDrawContext.GetOffsetY: Extended;
begin
  if FIsPngDrawing then
    Result := 50
  else
    Result := FOffsetY;
end;

function TDrawContext.GetScale: Extended;
begin
  if FIsPngDrawing then
    Result := 1
  else
    Result := FScale;
end;

function TDrawContext.GetSpace: Integer;
begin
  Result := FSpace;
end;

function TDrawContext.GetVerticalSpace: Integer;
begin
  if IsPngDrawing then
    Result := 10
  else
    Result := FVerticalSpace;
end;

function TDrawContext.GlobalToLocal(const AX, AY: Integer): TPoint;
begin
  Result.X := Round((AX - OffsetX) / Scale);
  Result.Y := Round((AY - OffsetY) / Scale);
end;

function TDrawContext.LocalToGlobal(const AX, AY: Integer): TPoint;
begin
  Result.X := Round(AX * Scale + OffsetX);
  Result.Y := Round(AY * Scale + OffsetY);
end;

function TDrawContext.ScaleInteger(const AValue: Integer): Integer;
begin
  Result := Round(AValue * Scale);
end;

procedure TDrawContext.SetEditMode(const Value: Boolean);
begin
  FEditMode := Value;
end;

procedure TDrawContext.SetIsMoveMode(const Value: Boolean);
begin
  FIsMoveMode := Value;
end;

procedure TDrawContext.SetNeedRepaint(const Value: Boolean);
begin
  FNeedRepaint := Value;
end;

procedure TDrawContext.SetOffsetX(const Value: Extended);
begin
  if FIsPngDrawing then
    Exit;
  if FOffsetX <> Value then
    FNeedRepaint := True;
  FOffsetX := Value;
end;

procedure TDrawContext.SetOffsetY(const Value: Extended);
begin
  if FIsPngDrawing then
    Exit;
  if FOffsetY <> Value then
    FNeedRepaint := True;
  FOffsetY := Value;
end;

procedure TDrawContext.SetRectOnScreen(const Value: TRectOnScreen);
begin
  FRectOnScreen := Value;
end;

procedure TDrawContext.SetScale(const Value: Extended);
begin
  if FIsPngDrawing then
    Exit;
  if FScale <> Value then
    FNeedRepaint := True;
  FScale := Value;
end;

end.
