unit uBeImage;

interface

uses
  UIssueStatistic,
  UIssueStatusStatistic,
  Winapi.PsAPI,
  uLogin,
  uSetKey,
  uQuestion,
  Math,
  uBeColumn,
  UContext,
  UTouchPoint,
  UBeUtils,
  Winapi.Shellapi,
  Vcl.ExtCtrls,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

const
  WM_DELISSUE = WM_USER + 1;
  WM_INFOISSUE = WM_USER + 2;
  WM_EDITISSUE = WM_USER + 3;
  WM_MOVEISSUE = WM_USER + 4;
  WM_ADDISSUE = WM_USER + 5;
  WM_STATISSUE = WM_USER + 6;
  cMinScale = 0.4;
  cMaxScale = 4;

Type
  TIssueR = record
    Summary: string;
    Status: string;
    Key: string;
    Error: string;
    procedure FillFromIssue(const AIssue: TBeIssue);
  end;

  TIssueRPair = record
    OldIssue: TIssueR;
    NewIssue: TIssueR;
    Error: Boolean;
    function HaveChanges: Boolean;
  end;

  TGetIssueFromJiraByKey = function(const AKey: string): TIssueR of object;
  TGetIssueStatFromJiraByKey = function(const AKey: string)
    : TIssueStatusStatistic of object;

  TBePanel = class(TPanel)
  private
    FMouseDownPos: TPoint;
    FIsMoveNow: Boolean;
    FLog: TStringList;
    FShowLog: Boolean;
    FGetIssueFromJiraByKey: TGetIssueFromJiraByKey;
    FGetIssueStatFromJiraByKey: TGetIssueStatFromJiraByKey;
    FColumnList: TBeIssueColumnList;
    FDistBetweenTwoPoints: Integer;
    FBeOwner: TForm;
    FBuffer: TBitmap;
    FDrawForPNGSave: Boolean;
    FRect: TRect;
    FTouchSessionList: TTouchSessionList;
    FDrawContext: TDrawContext;
    procedure SetDrawContext(const Value: TDrawContext);
    procedure WMPaint(var message: TWMPaint); message WM_PAINT;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

  public
    property DrawForPNGSave: Boolean read FDrawForPNGSave write FDrawForPNGSave;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure CenterImage(const ALocalX, ALocalY: Integer);
    property ColumnList: TBeIssueColumnList read FColumnList;
    procedure DelIssue(var message: TMessage); message WM_DELISSUE;
    procedure EditIssue(var message: TMessage); message WM_EDITISSUE;
    procedure MoveIssue(var message: TMessage); message WM_MOVEISSUE;
    procedure AddIssue(var message: TMessage); message WM_ADDISSUE;
    procedure InfoIssue(var message: TMessage); message WM_INFOISSUE;
    procedure StatIssue(var message: TMessage); message WM_STATISSUE;
    procedure Log(const ALogMessage: string);
    function ReloadIssueFromJira(const AIssue: TBeIssue): TIssueRPair;
    function RectOnScreen(const ARect: TRect): Boolean;
    property DrawContext: TDrawContext read FDrawContext write SetDrawContext;
    property Buffer: TBitmap read FBuffer;
    procedure Paint; override;
    procedure DrawLog;
    procedure PrepareBuffer;
    procedure CalcAfterTouch;
    procedure OffsetBy(ADx, ADy: Integer);
    procedure OnTouch(var Msg: TMessage); message WM_TOUCH;
    procedure OnResize(var m: TMessage); message WM_SIZE;
    constructor Create(AOwner: TComponent;
      AGetIssueFromJiraByKey: TGetIssueFromJiraByKey;
      AGetIssueStatFromJiraByKey: TGetIssueStatFromJiraByKey); overload;
    destructor Destroy; override;

  end;

implementation

function FindRunApplPathByName(FExeName: string): string;
var
  procesess: array [0 .. $FFF] of DWORD;
  ProcessName: string;
  i, count, pml: cardinal;
  ph: THandle;
  Buffer: array [0 .. MAX_PATH - 1] of char;
begin
  Result := '';
  if not EnumProcesses(@procesess, SizeOf(procesess), count) then
    Exit;
  count := count div SizeOf(DWORD);

  for i := 0 to count - 1 do
  begin
    ph := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false,
      procesess[i]);
    if ph > 0 then
    begin
      try
        pml := GetModuleFileNameEx(ph, 0, PChar(@Buffer), SizeOf(Buffer));
        if (pml = 0) then
          continue
        else
          SetString(ProcessName, PChar(@Buffer), pml);
      finally
        CloseHandle(ph);
      end;
      if (UpperCase(ExtractFileName(ProcessName)) = UpperCase(FExeName)) then
      begin
        Result := ProcessName;
        Break;
      end;
    end;
  end;
end;

procedure TBePanel.AddIssue(var message: TMessage);
var
  KeyPrefix: string;
  Issue: TBeIssue;
  iIssue: Integer;
  issR: TIssueR;
begin
  Application.ProcessMessages;
  Issue := FColumnList.SelectedElement as TBeIssue;
  Issue.Key := 'TN-';
  fSetKey.eKey.Text := Copy(Issue.Key, Pos('-', Issue.Key) + 1,
    Length(Issue.Key));
  KeyPrefix := Copy(Issue.Key, 1, Pos('-', Issue.Key) - 1);
  fSetKey.cbKeyPrefix.ItemIndex := fSetKey.cbKeyPrefix.Items.IndexOf
    (Trim(KeyPrefix));
  if fSetKey.ShowModal = mrOk then
  begin
    Issue.Key := fSetKey.cbKeyPrefix.Text + '-' + Trim(fSetKey.eKey.Text);
    Issue.SetDefault;
    DrawContext.NeedRepaint := True;
    PrepareBuffer;
    Paint;
    issR := FGetIssueFromJiraByKey(fSetKey.cbKeyPrefix.Text + '-' +
      Trim(fSetKey.eKey.Text));
    if issR.Key = 'nil' then
    begin
      Application.MessageBox(PChar(issR.Error),
        PChar('Не удалось получить данные по задаче ' + Issue.Key),
        MB_ICONERROR or MB_OK);
      Issue.OwnerList.Remove(Issue);
      FColumnList.SelectedElement := nil;
    end
    else
    begin
      Issue.Key := issR.Key;
      Issue.Summary := issR.Summary;
      Issue.Status := issR.Status;
    end;
  end
  else
  begin
    Issue.OwnerList.Remove(Issue);
    FColumnList.SelectedElement := nil;
  end;
  DrawContext.NeedRepaint := True;
  PrepareBuffer;
  Paint;
end;

procedure TBePanel.CalcAfterTouch;
const
  cDeltaScale = 2;
var
  p1, p2: TPoint;
  CurrentDist: Integer;
  GMP, LMPA, MP: TPoint;
  Element: TObject;
  Session, Session1, Session2: TTouchSession;
  Dx, Dy: Integer;
  i, iIssue: Integer;
  NewIssue, OldIssue: TBeIssue;
  DelOnIterration: Boolean;
begin
  repeat
    DelOnIterration := false;
    for i := 0 to Pred(FTouchSessionList.count) do
    begin
      Session := FTouchSessionList[i];
      if (Session.UpPoint.Id >= 0) and (Session.SessionType = tstClick) then
      begin
        FTouchSessionList.Remove(Session);
        DelOnIterration := True;
        Break;
      end;
      if (Session.UpPoint.Id >= 0) and (Session.SessionType = tstMove) then
      begin
        FTouchSessionList.Remove(Session);
        DelOnIterration := True;
        Break;
      end;
      if (Session.UpPoint.Id >= 0) and (Session.SessionType = tstZoom) then
      begin
        FDistBetweenTwoPoints := cDefInteger;
        FTouchSessionList.Remove(Session);
        DelOnIterration := True;
        Break;
      end;
      if (Session.UpPoint.Id >= 0) and (Session.SessionType = tstFinished) then
      begin
        FTouchSessionList.Remove(Session);
        DelOnIterration := True;
        Break;
      end;
    end;
  until not DelOnIterration;

  if FTouchSessionList.count > 2 then
  begin
    for i := 0 to Pred(FTouchSessionList.count) do
      FTouchSessionList[i].SessionType := tstFinished;
    Exit;
  end;

  case FTouchSessionList.count of
    1:
      begin
        Session := FTouchSessionList[0];
        if Session.SessionType = tstNone then
        begin
          p1 := Session.DownPoint.AsPoint;
          if Assigned(Session.MovePoint) then
            p2 := Session.MovePoint.AsPoint
          else
            p2 := p1;
          if p1.Distance(p2) > 50 then
            Session.SessionType := tstMove
          else if Session.UpPoint.Id >= 0 then
            Session.SessionType := tstClick;
        end;

        { DoClick }
        if (Session.SessionType = tstClick) then
        begin
          Session.SessionType := tstFinished;
          Element := FColumnList.GetElemntByGlobalXY(Session.DownPoint.X,
            Session.DownPoint.Y);
          if Assigned(Element) and (Element is TBeIssueButtonInfo) and
            (FColumnList.SelectedElement is TBeIssue) then
          begin
            PostMessage(Handle, WM_INFOISSUE, 0,
              Integer(Addr(FColumnList.SelectedElement)));
          end
          else if Assigned(Element) and (Element is TBeIssueButtonMove) and
            (FColumnList.SelectedElement is TBeIssue) then
          begin
            PostMessage(Handle, WM_MOVEISSUE, 0,
              Integer(Addr(FColumnList.SelectedElement)));
          end
          else if Assigned(Element) and (Element is TBeIssueButtonDel) and
            (FColumnList.SelectedElement is TBeIssue) and DrawContext.EditMode
          then
          begin
            PostMessage(Handle, WM_DELISSUE, 0,
              Integer(Addr(FColumnList.SelectedElement)));
          end
          else if Assigned(Element) and (Element is TBeIssueButtonDel) and
            (FColumnList.SelectedElement is TBeIssue) and
            (not DrawContext.EditMode) then
          begin
            PostMessage(Handle, WM_STATISSUE, 0,
              Integer(Addr(FColumnList.SelectedElement)));
          end
          else if Assigned(Element) and (Element is TBeIssueButtonEdit) and
            (FColumnList.SelectedElement is TBeIssue) then
          begin
            PostMessage(Handle, WM_EDITISSUE, 0,
              Integer(Addr(FColumnList.SelectedElement)));
          end
          else if Assigned(Element) and (Element is TBeIssueLink) then
          begin
            if DrawContext.IsMoveMode then
            begin
              iIssue := TBeIssueLink(Element)
                .OwnerList.OwnerIssueColumn.AddIssue
                (TBeIssueLink(Element).ToIssue);
              NewIssue := TBeIssueLink(Element)
                .OwnerList.OwnerIssueColumn[iIssue];
              OldIssue := FColumnList.SelectedElement as TBeIssue;
              NewIssue.Summary := OldIssue.Summary;
              NewIssue.Key := OldIssue.Key;
              NewIssue.Status := OldIssue.Status;
              OldIssue.OwnerList.Remove(OldIssue);
              FColumnList.SelectedElement := NewIssue;
              DrawContext.IsMoveMode := false;
            end
            else
            begin
              iIssue := TBeIssueLink(Element)
                .OwnerList.OwnerIssueColumn.AddIssue
                (TBeIssueLink(Element).ToIssue);
              NewIssue := TBeIssueLink(Element)
                .OwnerList.OwnerIssueColumn[iIssue];
              FColumnList.SelectedElement := NewIssue;
              PostMessage(Handle, WM_ADDISSUE, 0, Integer(Addr((NewIssue))));
            end;
          end
          else if Assigned(Element) and (Element is TBeIssue) and
            (Element <> FColumnList.SelectedElement) then
          begin
            if not DrawContext.IsMoveMode then
              FColumnList.SelectedElement := Element;
          end;
        end;

        { DoMove }
        if (Session.SessionType = tstMove) and (Session.MovePointList.count > 1)
        then
        begin
          Dx := Session.MovePointList[Session.MovePointList.count - 1].X -
            Session.MovePointList[Session.MovePointList.count - 2].X;
          Dy := Session.MovePointList[Session.MovePointList.count - 1].Y -
            Session.MovePointList[Session.MovePointList.count - 2].Y;
          OffsetBy(Dx, Dy);
        end;
      end;
    2:
      begin
        Session1 := FTouchSessionList[0];
        Session2 := FTouchSessionList[1];

        if FDistBetweenTwoPoints = cDefInteger then
          FDistBetweenTwoPoints := Round(Session1.Distance(Session2));
        if Assigned(Session1.MovePoint) and Assigned(Session2.MovePoint) then
          CurrentDist := Round(Session1.Distance(Session2))
        else
          CurrentDist := FDistBetweenTwoPoints;

        if Abs(CurrentDist - FDistBetweenTwoPoints) > 40 then
        begin
          Session1.SessionType := tstZoom;
          Session2.SessionType := tstZoom;
          MP.X := Round((Session1.MovePoint.X + Session2.MovePoint.X) / 2);
          MP.Y := Round((Session1.MovePoint.Y + Session2.MovePoint.Y) / 2);
          GMP := MP;
          MP := DrawContext.GlobalToLocal(MP.X, MP.Y);

          if (FDistBetweenTwoPoints <> cDefInteger) and
            (FDistBetweenTwoPoints > CurrentDist) then
          begin
            DrawContext.Scale := DrawContext.Scale / cDeltaScale;
            if DrawContext.Scale < cMinScale then
              DrawContext.Scale := DrawContext.Scale * cDeltaScale;
          end
          else
          begin
            DrawContext.Scale := DrawContext.Scale * cDeltaScale;
            if DrawContext.Scale > cMaxScale then
              DrawContext.Scale := DrawContext.Scale / cDeltaScale;
          end;
          LMPA := DrawContext.GlobalToLocal(GMP.X, GMP.Y);

          DrawContext.OffsetX := DrawContext.OffsetX - (MP.X - LMPA.X) *
            DrawContext.Scale;
          DrawContext.OffsetY := DrawContext.OffsetY - (MP.Y - LMPA.Y) *
            DrawContext.Scale;
          FDistBetweenTwoPoints := CurrentDist;
        end;
      end;
  end;
end;

procedure TBePanel.CenterImage(const ALocalX, ALocalY: Integer);
var
  MP: TPoint;
begin
  MP := Self.ClientToScreen(Point(Width div 2, Height div 2));
  MP := DrawContext.GlobalToLocal(MP.X, MP.Y);
  DrawContext.OffsetX := DrawContext.OffsetX -
    (ALocalX * DrawContext.Scale - MP.X) * DrawContext.Scale;
  DrawContext.OffsetY := DrawContext.OffsetY -
    (ALocalX * DrawContext.Scale - MP.Y) * DrawContext.Scale;
  DrawContext.NeedRepaint := True;
  PrepareBuffer;
  Paint;
end;

constructor TBePanel.Create(AOwner: TComponent;
  AGetIssueFromJiraByKey: TGetIssueFromJiraByKey;
  AGetIssueStatFromJiraByKey: TGetIssueStatFromJiraByKey);
var
  Column: TBeIssue;
  i, cnt: Integer;
  BeIssC: TBeIssueColumn;
begin
  inherited Create(AOwner);
  FShowLog := True;
  FLog := TStringList.Create;

  FDrawForPNGSave := false;

  FMouseDownPos := Point(-1, -1);
  FIsMoveNow := false;
  FGetIssueFromJiraByKey := AGetIssueFromJiraByKey;
  FGetIssueStatFromJiraByKey := AGetIssueStatFromJiraByKey;
  FDistBetweenTwoPoints := cDefInteger;

  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf24bit;

  FDrawContext := TDrawContext.Create(Buffer.Canvas);
  FDrawContext.RectOnScreen := Self.RectOnScreen;
  FDrawContext.EditMode := false;

  FColumnList := TBeIssueColumnList.Create(True);
  FColumnList.DrawContext := DrawContext;

  FTouchSessionList := TTouchSessionList.Create(True);

  FBeOwner := nil;
  Self.DoubleBuffered := false;
  if AOwner is TForm then
    FBeOwner := AOwner as TForm
  else
    raise Exception.Create('AOwner должен быть формой');

  Parent := FBeOwner;
  Align := alClient;
  DrawContext.NeedRepaint := True;
  PrepareBuffer;
  if IsTouchScrean then
    RegisterTouchWindow(Handle, 0);
end;

procedure TBePanel.DelIssue(var message: TMessage);
var
  Issue: TBeIssue;
begin
  Issue := FColumnList.SelectedElement as TBeIssue;
  if Application.MessageBox(PChar('Удалить "' + Issue.Key + '"?'),
    'Подтвердите удаление', MB_YESNO or MB_ICONQUESTION) = ID_YES then
  begin
    Issue.OwnerList.Remove(Issue);
    FColumnList.SelectedElement := nil;
    PrepareBuffer;
    Paint;
  end;
end;

destructor TBePanel.Destroy;
begin
  FreeAndNil(FColumnList);
  FreeAndNil(FDrawContext);
  FreeAndNil(FBuffer);
  FreeAndNil(FTouchSessionList);
  FreeAndNil(FLog);
  inherited;
end;

function TBePanel.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
const
  cDeltaScale = 1.1;
var
  MP, GMP, LMPA: TPoint;
begin
  inherited;
  if Shift <> [] then
    Exit;
  MP := ScreenToClient(MousePos);
  GMP := MP;
  MP := DrawContext.GlobalToLocal(MP.X, MP.Y);
  if WheelDelta < 0 then
  begin
    DrawContext.Scale := DrawContext.Scale / cDeltaScale;
    if DrawContext.Scale < cMinScale then
      DrawContext.Scale := DrawContext.Scale * cDeltaScale;
  end
  else
  begin
    DrawContext.Scale := DrawContext.Scale * cDeltaScale;
    if DrawContext.Scale > cMaxScale then
      DrawContext.Scale := DrawContext.Scale / cDeltaScale;
  end;
  LMPA := DrawContext.GlobalToLocal(GMP.X, GMP.Y);
  DrawContext.OffsetX := DrawContext.OffsetX - (MP.X - LMPA.X) *
    DrawContext.Scale;
  DrawContext.OffsetY := DrawContext.OffsetY - (MP.Y - LMPA.Y) *
    DrawContext.Scale;
  DrawContext.NeedRepaint := True;
  PrepareBuffer;
  Paint;
end;

procedure TBePanel.DrawLog;
var
  i: Integer;
  tw: Integer;
  dtw: Integer;
  s: string;
begin
  if FShowLog then
  begin
    DrawContext.Canvas.Font.Size := 10;
    DrawContext.Canvas.Pen.Color := clSkyBlue;
    DrawContext.Canvas.Pen.Width := 1;
    tw := 0;
    for i := 0 to Pred(FLog.count) do
      tw := Max(tw, DrawContext.Canvas.TextWidth(FLog[i]));
    for i := 0 to Pred(FLog.count) do
    begin
      if FLog[i] = EmptyStr then
      begin
        DrawContext.Canvas.MoveTo(2, 12 + i * 18);
        DrawContext.Canvas.LineTo(tw + 12, 12 + i * 18);
      end
      else
      begin
        s := Copy(FLog[i], 1, Pos('-', FLog[i]));
        dtw := DrawContext.Canvas.TextWidth(s);
        DrawContext.Canvas.Font.Color := clSkyBlue;
        DrawContext.Canvas.TextOut(7, 2 + i * 18, s);
        DrawContext.Canvas.Font.Color := clGray;
        DrawContext.Canvas.TextOut(9 + dtw, 2 + i * 18,
          Copy(FLog[i], Pos('-', FLog[i]) + 1, Length(FLog[i])));
      end;
    end;
  end;
end;

procedure TBePanel.EditIssue(var message: TMessage);
var
  KeyPrefix: string;
  Issue: TBeIssue;
  issR: TIssueR;
begin
  Application.ProcessMessages;
  Issue := FColumnList.SelectedElement as TBeIssue;
  fSetKey.eKey.Text := Copy(Issue.Key, Pos('-', Issue.Key) + 1,
    Length(Issue.Key));
  KeyPrefix := Copy(Issue.Key, 1, Pos('-', Issue.Key) - 1);
  fSetKey.cbKeyPrefix.ItemIndex := fSetKey.cbKeyPrefix.Items.IndexOf
    (Trim(KeyPrefix));
  if fSetKey.ShowModal = mrOk then
  begin
    Issue.Key := fSetKey.cbKeyPrefix.Text + '-' + Trim(fSetKey.eKey.Text);
    Issue.SetDefault;
    DrawContext.NeedRepaint := True;
    PrepareBuffer;
    Paint;
    Application.ProcessMessages;
    issR := FGetIssueFromJiraByKey(fSetKey.cbKeyPrefix.Text + '-' +
      Trim(fSetKey.eKey.Text));
    if issR.Key <> 'nil' then
    begin
      Issue.Key := issR.Key;
      Issue.Summary := issR.Summary;
      Issue.Status := issR.Status;
    end
    else
      Application.MessageBox(PChar(issR.Error),
        PChar('Не удалось получить данные по задаче ' + Issue.Key),
        MB_ICONERROR or MB_OK);
    DrawContext.NeedRepaint := True;
    PrepareBuffer;
    Paint;
  end;
end;

procedure TBePanel.InfoIssue(var message: TMessage);
var
  Issue: TBeIssue;
  brPath: string;
  Link: string;
begin
  Issue := FColumnList.SelectedElement as TBeIssue;
  Link := fLogin.BaseUrl + '/browse/' + Issue.Key;
  brPath := FindRunApplPathByName('GoogleChromePortable.exe');
  if (brPath <> '') then
  begin
    ShellExecute(0, 'OPEN', PChar(brPath), PChar(Link), nil, SW_SHOW);
    Exit;
  end;
  brPath := FindRunApplPathByName('FirefoxPortable.exe');
  if (brPath <> '') then
  begin
    ShellExecute(0, 'OPEN', PChar(brPath), PChar(Link), nil, SW_SHOW);
    Exit;
  end;
  ShellExecute(0, 'OPEN', PChar(Link), '', '', SW_SHOWNORMAL);
end;

procedure TBePanel.Log(const ALogMessage: string);
begin
  if not FShowLog then
    Exit;
  if ALogMessage <> EmptyStr then
    FLog.Add(TimeToStr(now) + ' - ' + ALogMessage)
  else
    FLog.Add(EmptyStr);
  if FLog.count > 40 then
    FLog.Delete(0);
end;

procedure TBePanel.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if ssTouch in Shift then
    Exit;
  FMouseDownPos := Point(X, Y);
end;

procedure TBePanel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if ssTouch in Shift then
    Exit;
  if FMouseDownPos.X < 0 then
    Exit;
  if FIsMoveNow then
  begin
    OffsetBy(X - FMouseDownPos.X, Y - FMouseDownPos.Y);
    FMouseDownPos := Point(X, Y);
  end
  else
  begin
    if FMouseDownPos.Distance(Point(X, Y)) > 10 then
      FIsMoveNow := True;
  end;
end;

procedure TBePanel.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  IsClick: Boolean;
  Element: TObject;
  iIssue: Integer;
  NewIssue, OldIssue: TBeIssue;

begin
  inherited;
  if ssTouch in Shift then
    Exit;
  IsClick := (FMouseDownPos.Distance(Point(X, Y)) < 10) and (not FIsMoveNow);
  FMouseDownPos := Point(-1, -1);
  FIsMoveNow := false;
  if not IsClick then
    Exit;
  Element := FColumnList.GetElemntByGlobalXY(X, Y);
  { if ((Assigned(Element) and ((Element is TBeIssueColumnList) or
    ((Element is TBeIssueColumn)))) or (not Assigned(Element))) and
    (Assigned(FColumnList.SelectedElement)) then
    FColumnList.SelectedElement := nil
    else }
  if Assigned(Element) and (Element is TBeIssueButtonInfo) and
    (FColumnList.SelectedElement is TBeIssue) then
  begin
    PostMessage(Handle, WM_INFOISSUE, 0,
      Integer(Addr(FColumnList.SelectedElement)));
  end
  else if Assigned(Element) and (Element is TBeIssueButtonMove) and
    (FColumnList.SelectedElement is TBeIssue) then
  begin
    PostMessage(Handle, WM_MOVEISSUE, 0,
      Integer(Addr(FColumnList.SelectedElement)));
  end
  else if Assigned(Element) and (Element is TBeIssueButtonDel) and
    (FColumnList.SelectedElement is TBeIssue) and DrawContext.EditMode then
  begin
    PostMessage(Handle, WM_DELISSUE, 0,
      Integer(Addr(FColumnList.SelectedElement)));
  end
  else if Assigned(Element) and (Element is TBeIssueButtonDel) and
    (FColumnList.SelectedElement is TBeIssue) and (not DrawContext.EditMode)
  then
  begin
    PostMessage(Handle, WM_STATISSUE, 0,
      Integer(Addr(FColumnList.SelectedElement)));
  end
  else if Assigned(Element) and (Element is TBeIssueButtonEdit) and
    (FColumnList.SelectedElement is TBeIssue) then
  begin
    PostMessage(Handle, WM_EDITISSUE, 0,
      Integer(Addr(FColumnList.SelectedElement)));
  end
  else if Assigned(Element) and (Element is TBeIssueLink) then
  begin
    if DrawContext.IsMoveMode then
    begin
      iIssue := TBeIssueLink(Element).OwnerList.OwnerIssueColumn.AddIssue
        (TBeIssueLink(Element).ToIssue);
      NewIssue := TBeIssueLink(Element).OwnerList.OwnerIssueColumn[iIssue];
      OldIssue := FColumnList.SelectedElement as TBeIssue;
      NewIssue.Summary := OldIssue.Summary;
      NewIssue.Key := OldIssue.Key;
      NewIssue.Status := OldIssue.Status;
      OldIssue.OwnerList.Remove(OldIssue);
      FColumnList.SelectedElement := NewIssue;
      DrawContext.IsMoveMode := false;
    end
    else
    begin
      iIssue := TBeIssueLink(Element).OwnerList.OwnerIssueColumn.AddIssue
        (TBeIssueLink(Element).ToIssue);
      NewIssue := TBeIssueLink(Element).OwnerList.OwnerIssueColumn[iIssue];
      FColumnList.SelectedElement := NewIssue;
      PostMessage(Handle, WM_ADDISSUE, 0, Integer(Addr((NewIssue))));
    end;
  end
  else if Assigned(Element) and (Element is TBeIssue) and
    (Element <> FColumnList.SelectedElement) then
  begin
    if not DrawContext.IsMoveMode then
      FColumnList.SelectedElement := Element;
  end;

  DrawContext.NeedRepaint := True;
  PrepareBuffer;
  Paint;
end;

procedure TBePanel.MoveIssue(var message: TMessage);
begin
  DrawContext.IsMoveMode := not DrawContext.IsMoveMode;
  DrawContext.NeedRepaint := True;
  PrepareBuffer;
  Paint;
end;

procedure TBePanel.OffsetBy(ADx, ADy: Integer);
begin
  DrawContext.OffsetX := DrawContext.OffsetX + ADx;
  DrawContext.OffsetY := DrawContext.OffsetY + ADy;
  PrepareBuffer;
  Paint;
end;

procedure TBePanel.OnResize(var m: TMessage);
begin
  FRect := Rect(0, 0, Width, Height);
  Buffer.SetSize(Width, Height);
  DrawContext.NeedRepaint := True;
  PrepareBuffer;
  Paint;
end;

procedure TBePanel.OnTouch(var Msg: TMessage);
var
  InputsCount: Integer;
  Inputs: array of TTouchInput;
  i: Integer;
  pnt: TPoint;
  curPoint: TTouchPoint;
  Session: TTouchSession;
begin
  InputsCount := Msg.WParam and $FFFF;
  SetLength(Inputs, InputsCount);
  if GetTouchInputInfo(Msg.LParam, InputsCount, @Inputs[0], SizeOf(TTouchInput))
  then
  begin
    for i := 0 to InputsCount - 1 do
    begin
      pnt := Self.ScreenToClient(Point(Inputs[i].X div 100,
        Inputs[i].Y div 100));
      Inputs[i].X := pnt.X;
      Inputs[i].Y := pnt.Y;
    end;
    for i := 0 to InputsCount - 1 do
    begin
      Session := FTouchSessionList.GetSessionById(Inputs[i].dwID);
      if not Assigned(Session) then
      begin
        Session := TTouchSession.Create(Inputs[i].dwID);
        FTouchSessionList.Add(Session);
      end;
      if Inputs[i].dwFlags and TOUCHEVENTF_DOWN <> 0 then
        Session.DownPoint.Fill(Inputs[i]);
      if Inputs[i].dwFlags and TOUCHEVENTF_MOVE <> 0 then
        Session.MovePointList.Add(TTouchPoint.Create(Inputs[i]));
      if Inputs[i].dwFlags and TOUCHEVENTF_UP <> 0 then
        Session.UpPoint.Fill(Inputs[i]);
    end;
  end;
  CloseTouchInputHandle(Msg.LParam);
  CalcAfterTouch;
  PrepareBuffer;
  Paint;
end;

procedure TBePanel.Paint;
begin
  Self.Canvas.CopyRect(FRect, Buffer.Canvas, FRect);
end;

procedure TBePanel.PrepareBuffer;
const
  cTSize = 80;
var
  i: Integer;
  r: TRect;
begin
  if not DrawContext.NeedRepaint then
    Exit
  else
    DrawContext.NeedRepaint := false;
  with Buffer do
  begin
    DrawContext.Canvas.Brush.Color := clWhite;
    DrawContext.Canvas.Brush.Style := bsSolid;
    DrawContext.Canvas.FillRect(Rect(0, 0, FBeOwner.Width, FBeOwner.Height));
    // Canvas.Brush.Style := bsClear;
    { for i := 0 to FInitTouchPoints.Count - 1 do
      begin
      r.Left := FInitTouchPoints[i].X - cTSize;
      r.Right := FInitTouchPoints[i].X + cTSize;
      r.Top := FInitTouchPoints[i].Y - cTSize;
      r.Bottom := FInitTouchPoints[i].Y + cTSize;
      Canvas.Pen.Color := clRed;
      Canvas.Pen.Width := 1;
      Canvas.Ellipse(r);
      Canvas.Pen.Width := 1;
      Canvas.MoveTo(FInitTouchPoints[i].X + cTSize, FInitTouchPoints[i].Y);
      Canvas.LineTo(FInitTouchPoints[i].X - cTSize, FInitTouchPoints[i].Y);
      Canvas.MoveTo(FInitTouchPoints[i].X, FInitTouchPoints[i].Y + cTSize);
      Canvas.LineTo(FInitTouchPoints[i].X, FInitTouchPoints[i].Y - cTSize);
      Canvas.Pen.Color := clYellow;
      end;

      Canvas.Pen.Color := clYellow;
      Canvas.Pen.Width := 6;
      Canvas.Brush.Style := bsClear;
      for i := 0 to FCurrentTouchPoints.Count - 1 do
      begin
      r.Left := FCurrentTouchPoints[i].X - cTSize;
      r.Right := FCurrentTouchPoints[i].X + cTSize;
      r.Top := FCurrentTouchPoints[i].Y - cTSize;
      r.Bottom := FCurrentTouchPoints[i].Y + cTSize;
      Canvas.Pen.Width := 1;
      Canvas.Ellipse(r);
      Canvas.Pen.Width := 1;
      Canvas.Pen.Color := clYellow;
      Canvas.MoveTo(FCurrentTouchPoints[i].X + cTSize,
      FCurrentTouchPoints[i].Y);
      Canvas.LineTo(FCurrentTouchPoints[i].X - cTSize,
      FCurrentTouchPoints[i].Y);
      Canvas.MoveTo(FCurrentTouchPoints[i].X, FCurrentTouchPoints[i].Y
      + cTSize);
      Canvas.LineTo(FCurrentTouchPoints[i].X, FCurrentTouchPoints[i].Y
      - cTSize);
      Canvas.Pen.Color := clYellow;
      end; }
    FColumnList.Draw;
    DrawLog;
  End;
end;

function TBePanel.RectOnScreen(const ARect: TRect): Boolean;
begin
  if DrawForPNGSave then
  begin
    Result := True;
    Exit;
  end;
  Result := false;
  if (ARect.Right < 0) or (ARect.Bottom < 0) then
    Exit;
  if (ARect.Left > Self.Width) or (ARect.Top > Self.Height) then
    Exit;
  Result := True;
end;

function TBePanel.ReloadIssueFromJira(const AIssue: TBeIssue): TIssueRPair;
var
  issR: TIssueR;
begin
  Result.OldIssue.FillFromIssue(AIssue);
  Result.NewIssue.FillFromIssue(AIssue);
  Application.ProcessMessages;
  issR := FGetIssueFromJiraByKey(AIssue.Key);
  if issR.Key <> 'nil' then
  begin
    AIssue.Summary := issR.Summary;
    AIssue.Status := issR.Status;
    Result.NewIssue.FillFromIssue(AIssue);
  end;
  DrawContext.NeedRepaint := True;
  PrepareBuffer;
  Paint;
  Result.Error := issR.Key = 'nil';
end;

procedure TBePanel.SetDrawContext(const Value: TDrawContext);
begin
  FDrawContext := Value;
end;

procedure TBePanel.StatIssue(var message: TMessage);
var
  Issue: TBeIssue;
  brPath: string;
  Link: string;
  IssueStat: TIssueStatusStatistic;
begin
  Issue := FColumnList.SelectedElement as TBeIssue;
  IssueStat := FGetIssueStatFromJiraByKey(Issue.Key);
  try
    if IssueStat.Error <> EmptyStr then
    begin
      Application.MessageBox(PChar(IssueStat.Error),
        PChar('Не удалось получить данные по задаче ' + Issue.Key),
        MB_ICONERROR or MB_OK);
      Exit;
    end;
    fIssueStatistic.FillFromIssueStatistic(IssueStat);
    fIssueStatistic.ShowModal;
  finally
    FreeAndNil(IssueStat);
  end;
end;

procedure TBePanel.WMPaint(var message: TWMPaint);
var
  PS: TPaintStruct;
begin
  Winapi.Windows.BeginPaint(Handle, PS);
  if (csDesigning in ComponentState) then
    Exit;
  Canvas.Lock;
  try
    Paint;
  finally
    Canvas.Unlock;
    Winapi.Windows.EndPaint(Handle, PS);
  end;
end;

function TIssueRPair.HaveChanges: Boolean;
begin
  Result := not((OldIssue.Status = NewIssue.Status) and
    (OldIssue.Summary = OldIssue.Summary));
end;

{ TIssueR }

procedure TIssueR.FillFromIssue(const AIssue: TBeIssue);
begin
  Self.Summary := AIssue.Summary;
  Self.Key := AIssue.Key;
  Self.Status := AIssue.Status;
end;

end.
