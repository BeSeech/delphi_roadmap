unit uMain;

interface

uses
  Iso8601Unit,
  UColorRichEdit,
  UIssueHistory,
  UIssueStatusStatistic,
  URoadMapIntegrationConst,
  USendStrToOtherApp,
  uPing,
  uUpdater,
  uAppInfo,
  ULogin,
  uSetKey,
  uSettings,
  UBeUtils,
  uBeColumn,
  uBeImage,
  IdHTTP,
  IdURI,
  NativeXML,
{$IFDEF VER280}
  System.JSON,
{$ENDIF}
{$IFDEF VER260}
  DBXJSON,
{$ENDIF}
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, Vcl.Buttons, sButton, Vcl.ImgList, acAlphaImageList,
  sSpeedButton, IdBaseComponent, IdComponent, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, Vcl.ComCtrls, Vcl.Samples.Gauges,
  Vcl.AppEvnts, acImage, IdRawBase, IdRawClient, IdIcmpClient;

type
  TfRoadMapMain = class(TForm)
    Panel1: TPanel;
    im_64_64: TsAlphaImageList;
    sbEditMode: TsSpeedButton;
    sbSettings: TsSpeedButton;
    sbLogin: TsSpeedButton;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    sbRefresh: TsSpeedButton;
    pbProgress: TGauge;
    pProgress: TPanel;
    sbSave: TsSpeedButton;
    sbLoad: TsSpeedButton;
    sdSave: TSaveDialog;
    odOpen: TOpenDialog;
    Label1: TLabel;
    Shape3: TShape;
    sbResetZoom: TsSpeedButton;
    im_64_48: TsAlphaImageList;
    sSaveToPNG: TsSpeedButton;
    sdPng: TSaveDialog;
    sbFilter: TsSpeedButton;
    eFilter: TEdit;
    reUpdateLog: TRichEdit;
    bLogOff: TButton;
    pTouchKeyboard: TPanel;
    sbTouchKeyboard: TsSpeedButton;
    pDigitPanel: TPanel;
    sSpeedButton1: TsSpeedButton;
    sSpeedButton2: TsSpeedButton;
    sSpeedButton3: TsSpeedButton;
    sSpeedButton6: TsSpeedButton;
    sSpeedButton5: TsSpeedButton;
    sSpeedButton4: TsSpeedButton;
    sSpeedButton7: TsSpeedButton;
    sSpeedButton8: TsSpeedButton;
    sSpeedButton9: TsSpeedButton;
    sSpeedButton10: TsSpeedButton;
    sSpeedButton11: TsSpeedButton;
    sDigits: TShape;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbEditModeClick(Sender: TObject);
    procedure sbSettingsClick(Sender: TObject);
    procedure sbLoginClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbRefreshClick(Sender: TObject);
    procedure SaveToXml(const AFileName: string;
      const ADefault: Boolean = False);
    procedure LoadFromXML(const AFileName: string);
    procedure sbSaveClick(Sender: TObject);
    procedure sbLoadClick(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure sbResetZoomClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure sSaveToPNGClick(Sender: TObject);
    procedure sbFilterClick(Sender: TObject);
    procedure eFilterChange(Sender: TObject);
    procedure bLogOffClick(Sender: TObject);
    procedure sdSaveClose(Sender: TObject);
    procedure odOpenClose(Sender: TObject);
    procedure sdPngClose(Sender: TObject);
    procedure sSpeedButton10Click(Sender: TObject);
    procedure sSpeedButton11Click(Sender: TObject);
    procedure sbTouchKeyboardClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure reUpdateLogKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FImage: TBePanel;
    FWait: Integer;
    FUpdateIssuesCanceled: Boolean;
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
  public
    procedure CheckNewVersAndUpdate;
    function BeClear(const AString: string): string;
    function GetResponse(const URL: string): string;
    function LoadIssueFromJiraByKey(const AKey: string): TIssueR;
    function LoadHistoryFromJiraByKey(const AKey: string)
      : TIssueStatusStatistic;
    procedure ApplySettings;
    procedure ShowWait;
    procedure HideWait;
  end;

var
  fRoadMapMain: TfRoadMapMain;

implementation

{$R *.dfm}

const
  cCancel = 'Прервать';
  cOk = 'Ок';

procedure ConvertToPNG(oBMPSrc: TBitmap; sFilename: String);
var
  oPNGDest: TPNGObject;
begin
  oPNGDest := TPNGObject.Create;
  try
    oPNGDest.Assign(oBMPSrc);
    oPNGDest.SaveToFile(sFilename);
  finally
    oPNGDest.Free;
  end;
end;

procedure TfRoadMapMain.CheckNewVersAndUpdate;
  function GetVersion(AFileName: string): string;
  var
    VerInfoSize: DWORD;
    VerInfo: Pointer;
    VerValueSize: DWORD;
    VerValue: PVSFixedFileInfo;
    Dummy: DWORD;
  begin
    VerInfoSize := GetFileVersionInfoSize(PChar(AFileName), Dummy);
    GetMem(VerInfo, VerInfoSize);
    GetFileVersionInfo(PChar(AFileName), 0, VerInfoSize, VerInfo);
    VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
    with VerValue^ do
    begin
      Result := IntToStr(dwFileVersionMS shr 16);
      Result := Result + '.' + IntToStr(dwFileVersionMS and $FFFF);
      Result := Result + '.' + IntToStr(dwFileVersionLS shr 16);
      Result := Result + '.' + IntToStr(dwFileVersionLS and $FFFF);
    end;
    FreeMem(VerInfo, VerInfoSize);
  end;

const
  cFN = '\\192.168.18.11\releasebuilds\OurApp\ERM\RoadMap.exe';
var
  newVers: string;
  ms: TMemoryStream;
  Host: AnsiString;
begin
  Host := AnsiString('192.168.18.11');
  if not Ping(Host) then
    Exit;

  if FileExists(cFN) then
  begin
    newVers := GetVersion(cFN);
    if (newVers <> '') and (newVers <> ai.FileVersion) then
    begin
      MessageBox(Handle, PChar('Обнаружена новая версия: ' + newVers +
        sLineBreak + 'Обновить сейчас!?'), PChar('Новая версия!'),
        MB_ICONQUESTION or MB_OK);

      ms := TMemoryStream.Create;
      try
        ms.LoadFromFile(cFN);
        ms.Position := 0;
        if (ms.Size = 0) then
          raise Exception.Create('No Size');
        if not(ssCtrl in KeyboardStateToShiftState) then
          TProgUpdater.SetProgUpdate(ms);
      finally
        ms.Destroy;
      end;
    end;
  end;
end;

procedure TfRoadMapMain.ApplySettings;
begin
  fSetKey.cbKeyPrefix.Items.Assign(fSettings.mPrefixes.Lines);
  FImage.ColumnList.FillFromStrings(fSettings.mColumns.Lines);
  FImage.PrepareBuffer;
  FImage.Paint;
end;

function TfRoadMapMain.BeClear(const AString: string): string;
begin
  Result := StringReplace(AString, '"', '', [rfReplaceAll]);
end;

procedure TfRoadMapMain.bLogOffClick(Sender: TObject);
begin
  if bLogOff.Caption = cCancel then
    FUpdateIssuesCanceled := True;
  if bLogOff.Caption = cOk then
    pProgress.Visible := False;
end;

procedure TfRoadMapMain.eFilterChange(Sender: TObject);
begin
  FImage.DrawContext.Filter := Trim(eFilter.Text);
  FImage.DrawContext.NeedRepaint := True;
  FImage.PrepareBuffer;
  FImage.Paint;
end;

procedure TfRoadMapMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  FileName: string;
begin
  FileName := ExtractFilePath(Application.ExeName) + 'AutoSave.erm';
  SaveToXml(FileName);
end;

procedure TfRoadMapMain.FormCreate(Sender: TObject);
begin
  FWait := 0;

  sdSave.InitialDir := ExtractFilePath(Application.ExeName);
  sdPng.InitialDir := ExtractFilePath(Application.ExeName);
  odOpen.InitialDir := ExtractFilePath(Application.ExeName);

  FImage := TBePanel.Create(Self, LoadIssueFromJiraByKey,
    LoadHistoryFromJiraByKey);
  FImage.Parent := fRoadMapMain;
  FImage.Visible := True;
  FImage.Align := alClient;
  FImage.SendToBack;

  Caption := 'ERM v. ' + ai.FileVersion;
end;

procedure TfRoadMapMain.FormDestroy(Sender: TObject);
begin
  if IsTouchScrean then
    UnRegisterTouchWindow(FImage.Handle);
end;

procedure TfRoadMapMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if pProgress.Visible then
    Exit;
  if Shift = [] then
  begin
    case Key of
      38: // up
        begin
          FImage.DrawContext.OffsetY := FImage.DrawContext.OffsetY + 40 *
            FImage.DrawContext.Scale;
          FImage.DrawContext.NeedRepaint := True;
          FImage.PrepareBuffer;
          FImage.Paint;
        end;
      40: // down
        begin
          FImage.DrawContext.OffsetY := FImage.DrawContext.OffsetY - 40 *
            FImage.DrawContext.Scale;
          FImage.DrawContext.NeedRepaint := True;
          FImage.PrepareBuffer;
          FImage.Paint;
        end;
      37: // left
        begin
          FImage.DrawContext.OffsetX := FImage.DrawContext.OffsetX + 40 *
            FImage.DrawContext.Scale;
          FImage.DrawContext.NeedRepaint := True;
          FImage.PrepareBuffer;
          FImage.Paint;
        end;
      39: // right
        begin
          FImage.DrawContext.OffsetX := FImage.DrawContext.OffsetX - 40 *
            FImage.DrawContext.Scale;
          FImage.DrawContext.NeedRepaint := True;
          FImage.PrepareBuffer;
          FImage.Paint;
        end;
    end;
  end;
  if ssCtrl in Shift then
  begin
    case Key of
      69: // e
        begin
          sbEditMode.Down := not sbEditMode.Down;
          sbEditMode.Click;
        end;
      70: // f
        begin
          sbFilter.Down := not sbFilter.Down;
          sbFilter.Click;
        end;
      79: // o
        begin
          sbLoad.Click;
        end;
      83: // s
        begin
          sbSave.Click;
        end;
    end;
  end;

end;

procedure TfRoadMapMain.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  Border: TRect;
begin
  Border.TopLeft := FImage.ClientToScreen(Point(0, 0));
  Border.BottomRight := FImage.ClientToScreen
    (Point(FImage.Width, FImage.Height));
  if Border.Contains(MousePos) and (not pProgress.Visible) then
    FImage.DoMouseWheel(Shift, WheelDelta, MousePos);
end;

procedure TfRoadMapMain.FormShow(Sender: TObject);
var
  FileName: string;
begin
{$IFNDEF DEBUG}
  CheckNewVersAndUpdate;
{$ENDIF}
  fLogin.LoadFromXML;
  FileName := ExtractFilePath(Application.ExeName) + 'Default.erm';
  if ParamCount <> 0 then
    LoadFromXML(ParamStr(1))
  else if FileExists(FileName) then
    LoadFromXML(FileName)
  else
    ApplySettings;
end;

function TfRoadMapMain.GetResponse(const URL: string): string;
var
  HTTP: TIdHttp;
  s: TStringStream;
begin
  Result := EmptyStr;
  HTTP := TIdHttp.Create(nil);
  s := TStringStream.Create(Result);
  ShowWait;
  try
    HTTP.Request.ContentType := 'application/json';
    HTTP.Request.Accept := 'application/json';
    HTTP.Request.ContentEncoding := 'utf-8';
    HTTP.IOHandler := IdSSLIOHandlerSocketOpenSSL1;
    HTTP.HandleRedirects := True;
    HTTP.AllowCookies := True;
    HTTP.Request.BasicAuthentication := True;
    HTTP.Request.Username := fLogin.Login;
    HTTP.Request.Password := fLogin.Password;
    HTTP.Request.UserAgent :=
      'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET C9LR 1.0.3705;)';
    HTTP.Get(URL, s);
    s.Position := 0;
    Result := s.ReadString(s.Size);
  finally
    HideWait;
    FreeAndNil(s);
    FreeAndNil(HTTP);
  end;
end;

procedure TfRoadMapMain.HideWait;
begin
  Dec(FWait);
  if FWait = 0 then
  begin
    Screen.Cursor := crDefault;
  end;
end;

procedure TfRoadMapMain.LoadFromXML(const AFileName: string);
var
  NativeXML: TNativeXML;
  NodeH, NodeI, NodeC, NodeP, Node: TXMLNode;
  i, j: Integer;
  s: string;
  nList, nList2: TList;
  Column: TBeIssueColumn;
  Issue: TBeIssue;
begin
  FImage.ColumnList.Clear;
  FImage.ColumnList.SelectedElement := nil;
  nList := TList.Create;
  nList2 := TList.Create;
  NativeXML := TNativeXML.Create(Nil);
  try
    NativeXML.LoadFromFile(AFileName);
    NodeH := NativeXML.Root.NodeByName('Header');
    if not Assigned(NodeH) then
      Exit;
    NodeP := NodeH.NodeByName('Prefixes');
    if not Assigned(NodeP) then
      Exit;
    NodeP.NodesByName('Prefix', nList);
    fSettings.mPrefixes.Lines.Clear;
    for i := 0 to Pred(nList.Count) do
    begin
      Node := TXMLNode(nList[i]);
      fSettings.mPrefixes.Lines.Add
        (Node.Attributes[Node.AttributeIndexByName('Value')].Value);
    end;

    NodeC := NodeH.NodeByName('Columns');
    if not Assigned(NodeC) then
      Exit;
    NodeC.NodesByName('Column', nList);
    fSettings.mColumns.Lines.Clear;
    for i := 0 to Pred(nList.Count) do
    begin
      Node := TXMLNode(nList[i]);
      fSettings.mColumns.Lines.Add
        (Node.Attributes[Node.AttributeIndexByName('Value')].Value);
    end;

    NodeI := NativeXML.Root.NodeByName('Issues');
    if not Assigned(NodeI) then
    begin
      ApplySettings;
      Exit;
    end;
    FImage.ColumnList.Clear;

    NodeI.NodesByName('Column', nList);
    for i := 0 to Pred(nList.Count) do
    begin
      NodeC := TXMLNode(nList[i]);
      Column := TBeIssueColumn.Create(True);
      Column.Name := NodeC.Attributes[NodeC.AttributeIndexByName('Name')].Value;
      Column.PenColor :=
        StringToColor(NodeC.Attributes
        [NodeC.AttributeIndexByName('Color')].Value);

      NodeC.NodesByName('Issue', nList2);
      for j := 0 to Pred(nList2.Count) do
      begin
        Node := TXMLNode(nList2[j]);
        Issue := TBeIssue.Create;
        Issue.Key := Node.Attributes[Node.AttributeIndexByName('Key')].Value;
        Issue.Summary := Node.Attributes
          [Node.AttributeIndexByName('Summary')].Value;
        Issue.Status := Node.Attributes
          [Node.AttributeIndexByName('Status')].Value;
        Column.Add(Issue);
      end;
      FImage.ColumnList.Add(Column);
    end;
  finally
    FreeAndNil(NativeXML);
    FreeAndNil(nList);
    FreeAndNil(nList2);
  end;
  FImage.DrawContext.NeedRepaint := True;
  FImage.PrepareBuffer;
  FImage.Paint;
end;

function TfRoadMapMain.LoadHistoryFromJiraByKey(const AKey: string)
  : TIssueStatusStatistic;
var
  i: Integer;
  s: string;
  j, jh: TJSONObject;
  jarr: TJSONArray;
  Request: string;
  hList: TIssueHistoryList;
begin
  ShowWait;
  hList := TIssueHistoryList.Create(True);
  Result := TIssueStatusStatistic.Create;
  try
    if fLogin.Login = EmptyStr then
      Exit;

    try
      // https://estream.atlassian.net/rest/api/2/issue/TN-1000?fields=id,key,summary,status&expand=changelog
      Request := fLogin.BaseUrl + '/rest/api/2/issue/' + AKey +
        '?fields=id,key,summary,status';
      Request := 'https://estream.atlassian.net/rest/api/2/issue/' + AKey +
        '?fields=id,key,summary,status&expand=changelog';
      Request := IdURI.TIdURI.URLEncode(Request);
      s := UTF8ToString(GetResponse(Request));
      j := TJSONObject.ParseJSONValue(s) as TJSONObject;
      jh := j.GetValue('changelog') as TJSONObject;

      Result.Key := BeClear(j.GetValue('key').ToString);
      j := j.GetValue('fields') as TJSONObject;
      Result.Summary := BeClear(j.GetValue('summary').ToString);
      j := j.GetValue('status') as TJSONObject;
      Result.Status := BeClear(j.GetValue('name').ToString);

      hList.LoadFromTJSonArray(jh.GetValue('histories') as TJSONArray);
      Result.Statuses.FillFromHistoryList(hList);
    except
      On E: Exception do
      begin
        Result.Error := E.Message;
      end;
    end;
  finally
    FreeAndNil(hList);
    HideWait;
  end;
end;

function TfRoadMapMain.LoadIssueFromJiraByKey(const AKey: string): TIssueR;
var
  i: Integer;
  s: string;
  j: TJSONObject;
  jarr: TJSONArray;
  Request: string;
begin
  ShowWait;
  try
    if fLogin.Login = EmptyStr then
      Exit;

    Result.Key := 'nil';
    Result.Error := EmptyStr;
    try
      // https://estream.atlassian.net/rest/api/2/issue/TN-1000?fields=id,key,summary,status&expand=changelog
      Request := fLogin.BaseUrl + '/rest/api/2/issue/' + AKey +
        '?fields=id,key,summary,status';
      Request := IdURI.TIdURI.URLEncode(Request);
      s := UTF8ToString(GetResponse(Request));
      j := TJSONObject.ParseJSONValue(s) as TJSONObject;

      Result.Key := BeClear(j.GetValue('key').ToString);

      j := j.GetValue('fields') as TJSONObject;

      Result.Summary := BeClear(j.GetValue('summary').ToString);

      j := j.GetValue('status') as TJSONObject;
      Result.Status := BeClear(j.GetValue('name').ToString);
    except
      On E: Exception do
      begin
        Result.Error := E.Message;
        Result.Key := 'nil';
      end;
    end;
  finally
    HideWait;
  end;
end;

procedure TfRoadMapMain.odOpenClose(Sender: TObject);
begin
  odOpen.InitialDir := ExtractFilePath(odOpen.FileName);
end;

procedure TfRoadMapMain.reUpdateLogKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    if bLogOff.Caption = cOk then
      bLogOff.Click;
  end;
  if Key = VK_ESCAPE then
  begin
    bLogOff.Click;
  end;
end;

procedure TfRoadMapMain.SaveToXml(const AFileName: string;
  const ADefault: Boolean = False);
var
  NativeXML: TNativeXML;
  NodeH, NodeI, NodeC, NodeP, Node: TXMLNode;
  i, j: Integer;
  s: string;
begin
  NativeXML := TNativeXML.Create(nil);
  try
    NativeXML.Clear;
    NativeXML.ExternalEncoding := seUTF8;
    NativeXML.WriteOnDefault := False;
    NativeXML.XmlFormat := xfReadable;
    NativeXML.VersionString := '1.0';
    NativeXML.Declaration.Version := '1.0';
    NativeXML.Declaration.Encoding := 'utf-8';
    NativeXML.Charset := 'utf-8';
    NodeH := NativeXML.Root.NodeNew('Header');
    NodeP := NodeH.NodeNew('Prefixes');
    for i := 0 to Pred(fSettings.mPrefixes.Lines.Count) do
    begin
      s := Trim(fSettings.mPrefixes.Lines[i]);
      if s <> EmptyStr then
      begin
        Node := NodeP.NodeNew('Prefix');
        Node.AttributeAdd('Value', s);
      end;
    end;
    NodeC := NodeH.NodeNew('Columns');
    for i := 0 to Pred(fSettings.mColumns.Lines.Count) do
    begin
      s := Trim(fSettings.mColumns.Lines[i]);
      if s <> EmptyStr then
      begin
        Node := NodeC.NodeNew('Column');
        Node.AttributeAdd('Value', s);
      end;
    end;
    if not ADefault then
    begin
      NodeI := NativeXML.Root.NodeNew('Issues');
      for i := 0 to Pred(FImage.ColumnList.Count) do
      begin
        s := Trim(FImage.ColumnList[i].Name);
        if s <> EmptyStr then
        begin
          NodeC := NodeI.NodeNew('Column');
          NodeC.AttributeAdd('Name', s);
          NodeC.AttributeAdd('Color',
            ColorToString(FImage.ColumnList[i].PenColor));
          for j := 0 to Pred(FImage.ColumnList[i].Count) do
          begin
            Node := NodeC.NodeNew('Issue');
            Node.AttributeAdd('Key', FImage.ColumnList[i][j].Key);
            Node.AttributeAdd('Summary', FImage.ColumnList[i][j].Summary);
            Node.AttributeAdd('Status', FImage.ColumnList[i][j].Status);
          end;
        end;
      end;
    end;
  finally
    NativeXML.Root.Name := 'RoadMap';
    NativeXML.SaveToFile(AFileName);
    FreeAndNil(NativeXML);
  end;
end;

procedure TfRoadMapMain.sbEditModeClick(Sender: TObject);
begin
  FImage.DrawContext.EditMode := sbEditMode.Down;
  if (FImage.DrawContext.IsMoveMode) and (not FImage.DrawContext.EditMode) then
    FImage.DrawContext.IsMoveMode := False;
  sbSettings.Enabled := sbEditMode.Down;
  FImage.DrawContext.NeedRepaint := True;
  FImage.PrepareBuffer;
  FImage.Paint;
end;

procedure TfRoadMapMain.sbFilterClick(Sender: TObject);
begin
  pTouchKeyboard.Width := 70;
  pTouchKeyboard.Height := eFilter.Height;
  pTouchKeyboard.Left := FImage.Left;
  pTouchKeyboard.Top := FImage.Top;
  eFilter.Left := pTouchKeyboard.Left + pTouchKeyboard.Width;
  eFilter.Top := FImage.Top;
  eFilter.Width := FImage.Width - eFilter.Left + FImage.Left - 5;
  eFilter.Visible := sbFilter.Down;
  eFilter.Text := EmptyStr;
  pTouchKeyboard.Visible := sbFilter.Down;
  if eFilter.Visible then
  begin
    sbTouchKeyboard.Down := IsTouchScrean;
    sbTouchKeyboard.Click;
    eFilter.SetFocus;
  end
  else
    pDigitPanel.Visible := False;
end;

procedure TfRoadMapMain.sbLoadClick(Sender: TObject);
begin
  if odOpen.Execute then
    LoadFromXML(odOpen.FileName);
end;

procedure TfRoadMapMain.sbLoginClick(Sender: TObject);
begin
  if fLogin.ShowModal = mrOk then
    fLogin.SaveToXml
  else
    fLogin.LoadFromXML;
end;

procedure TfRoadMapMain.sbRefreshClick(Sender: TObject);
const
  cError = 'ошибка получения данных';
  cNoChanges = 'нет изменений';
  cHaveChanges = 'обновлено';
  cSummary = 'summary';
  cStastus = 'status';
  cSpace = '    ';
  cBreak = 'Прервано пользователем!';

var
  cnt: Integer;
  i: Integer;
  issPair: TIssueRPair;
  s: string;
  ColorRichEdit: TColorRichEdit;

  function GetColorString(const AString: string; const AColor: TColor): String;
  begin
    Result := ColorRichEdit.GetColorString(AString, AColor);
  end;

  procedure Process;
  begin
    ColorRichEdit.Process;
  end;

begin
  reUpdateLog.Lines.Clear;
  bLogOff.Caption := cCancel;
  FUpdateIssuesCanceled := False;
  pProgress.Left := FImage.Left + 50;
  pProgress.Width := FImage.Width - 100;
  pProgress.Top := FImage.Top + FImage.Height div 2 - pProgress.Height div 2;
  cnt := 0;
  for i := 0 to Pred(FImage.ColumnList.Count) do
    cnt := cnt + FImage.ColumnList[i].Count;
  pbProgress.MinValue := 0;
  pbProgress.MaxValue := cnt;
  pbProgress.Progress := 0;
  pProgress.Visible := True;
  ColorRichEdit := TColorRichEdit.Create(reUpdateLog);
  if reUpdateLog.CanFocus then
    reUpdateLog.SetFocus;
  pProgress.BringToFront;
  ShowWait;
  try
    for i := 0 to Pred(FImage.ColumnList.Count) do
    begin
      for cnt := 0 to Pred(FImage.ColumnList[i].Count) do
      begin
        issPair := FImage.ReloadIssueFromJira(FImage.ColumnList[i][cnt]);
        reUpdateLog.Lines.BeginUpdate;
        if issPair.Error then
        begin
          reUpdateLog.Lines.Add(GetColorString(issPair.OldIssue.Key, clNavy) +
            issPair.OldIssue.Key + ' - ' + GetColorString(cError, clRed)
            + cError);
          Process;
          PostMessage(reUpdateLog.Handle, EM_SCROLL, SB_LINEDOWN, 0);
          s := cSpace + cSummary + ':  ' +
            GetColorString(issPair.OldIssue.Summary, clGray) +
            issPair.OldIssue.Summary;
          reUpdateLog.Lines.Add(s);
          Process;
          PostMessage(reUpdateLog.Handle, EM_SCROLL, SB_LINEDOWN, 0);
        end
        else
        begin
          if issPair.HaveChanges then
          begin
            reUpdateLog.Lines.Add(GetColorString(issPair.OldIssue.Key, clNavy) +
              issPair.OldIssue.Key + ' - ' + GetColorString(cHaveChanges,
              clGreen) + cHaveChanges);
            Process;
            PostMessage(reUpdateLog.Handle, EM_SCROLL, SB_LINEDOWN, 0);
            if issPair.OldIssue.Summary <> issPair.NewIssue.Summary then
            begin
              s := cSpace + cSummary + ':  ' +
                GetColorString(issPair.OldIssue.Summary, clGray) +
                issPair.OldIssue.Summary + '  =>  ' +
                GetColorString(issPair.NewIssue.Summary, clGray) +
                issPair.NewIssue.Summary;
              reUpdateLog.Lines.Add(s);
              Process;
              PostMessage(reUpdateLog.Handle, EM_SCROLL, SB_LINEDOWN, 0);
            end
            else
            begin
              s := cSpace + cSummary + ':  ' +
                GetColorString(issPair.OldIssue.Summary, clGray) +
                issPair.OldIssue.Summary;
              reUpdateLog.Lines.Add(s);
              Process;
              PostMessage(reUpdateLog.Handle, EM_SCROLL, SB_LINEDOWN, 0);
            end;
            if issPair.OldIssue.Status <> issPair.NewIssue.Status then
            begin
              s := cSpace + cStastus + ':  ' +
                GetColorString(issPair.OldIssue.Status,
                FImage.ColumnList[i][cnt].GetFontColorByStatus
                (issPair.OldIssue.Status)) + issPair.OldIssue.Status + '  =>  '
                + GetColorString(issPair.NewIssue.Status,
                FImage.ColumnList[i][cnt].GetFontColorByStatus
                (issPair.NewIssue.Status)) + issPair.NewIssue.Status;
              reUpdateLog.Lines.Add(s);
              Process;
              PostMessage(reUpdateLog.Handle, EM_SCROLL, SB_LINEDOWN, 0);
            end;
          end
          else
          begin
            reUpdateLog.Lines.Add(GetColorString(issPair.OldIssue.Key, clNavy) +
              issPair.OldIssue.Key + ' - ' + GetColorString(cNoChanges, clGray)
              + cNoChanges);
            Process;
            PostMessage(reUpdateLog.Handle, EM_SCROLL, SB_LINEDOWN, 0);
          end;
        end;
        reUpdateLog.Lines.EndUpdate;
        reUpdateLog.SelStart := Length(reUpdateLog.Text);
        reUpdateLog.SelLength := 0;
        PostMessage(reUpdateLog.Handle, EM_SCROLL, SB_LINEDOWN, 0);
        reUpdateLog.Repaint;
        pbProgress.Progress := pbProgress.Progress + 1;
        Application.ProcessMessages;
        if FUpdateIssuesCanceled then
          Break;
      end;
      if FUpdateIssuesCanceled then
        Break;
    end;
  finally
    HideWait;
    FImage.DrawContext.NeedRepaint := True;
    FImage.PrepareBuffer;
    FImage.Paint;
    if FUpdateIssuesCanceled then
    begin
      reUpdateLog.Lines.Add(GetColorString(cBreak, clRed) + cBreak);
      Process;
      PostMessage(reUpdateLog.Handle, EM_SCROLL, SB_LINEDOWN, 0);
    end;
    FreeAndNil(ColorRichEdit);
    bLogOff.Caption := cOk;
  end;
end;

procedure TfRoadMapMain.sbResetZoomClick(Sender: TObject);
begin
  FImage.DrawContext.OffsetX := 0;
  FImage.DrawContext.OffsetY := 50;
  FImage.DrawContext.Scale := 1;

  FImage.DrawContext.NeedRepaint := True;
  FImage.PrepareBuffer;
  FImage.Paint;
end;

procedure TfRoadMapMain.sbSaveClick(Sender: TObject);
begin
  if sdSave.Execute then
  begin
    if Pos('.erm', sdSave.FileName) = 0 then
      sdSave.FileName := sdSave.FileName + '.erm';
    SaveToXml(sdSave.FileName);
  end;
end;

procedure TfRoadMapMain.sbSettingsClick(Sender: TObject);
begin
  if fSettings.ShowModal = mrOk then
    ApplySettings;
end;

procedure TfRoadMapMain.sbTouchKeyboardClick(Sender: TObject);
begin
  pDigitPanel.Top := pTouchKeyboard.Top + pTouchKeyboard.Height + 10;
  pDigitPanel.Left := pTouchKeyboard.Left + 10;
  pDigitPanel.Visible := sbTouchKeyboard.Down;
end;

procedure TfRoadMapMain.sdPngClose(Sender: TObject);
begin
  sdPng.InitialDir := ExtractFilePath(sdPng.FileName);
end;

procedure TfRoadMapMain.sdSaveClose(Sender: TObject);
begin
  sdSave.InitialDir := ExtractFilePath(sdSave.FileName);
end;

procedure TfRoadMapMain.ShowWait;
begin
  if FWait < 0 then
    FWait := 0;
  Inc(FWait);
  if FWait > 0 then
  begin
    Screen.Cursor := crHourGlass;
  end;
end;

procedure TfRoadMapMain.sSaveToPNGClick(Sender: TObject);
var
  el: TObject;
  b: Boolean;
  BufferForPNGSave: TBitmap;
begin
  if not sdPng.Execute then
    Exit;
  if Pos('.png', sdPng.FileName) = 0 then
    sdPng.FileName := sdPng.FileName + '.png';
  FImage.DrawContext.IsPngDrawing := True;
  b := sbEditMode.Down;
  if sbEditMode.Down then
  begin
    sbEditMode.Down := False;
    sbEditMode.Click;
  end;
  el := FImage.ColumnList.SelectedElement;
  FImage.ColumnList.SelectedElement := nil;
  BufferForPNGSave := TBitmap.Create;
  BufferForPNGSave.PixelFormat := pf24bit;
  FImage.DrawForPNGSave := True;
  FImage.DrawContext.Canvas := BufferForPNGSave.Canvas;
  FImage.DrawContext.NeedRepaint := True;
  FImage.PrepareBuffer;
  BufferForPNGSave.SetSize(FImage.ColumnList.Border.Width + 100,
    FImage.ColumnList.Border.Height + 100);
  BufferForPNGSave.Canvas.Brush.Style := bsSolid;
  BufferForPNGSave.Canvas.Brush.Color := clWhite;
  BufferForPNGSave.Canvas.FillRect(Rect(0, 0, BufferForPNGSave.Width,
    BufferForPNGSave.Height));
  FImage.DrawContext.NeedRepaint := True;
  FImage.PrepareBuffer;
  BufferForPNGSave.SetSize(FImage.ColumnList.Border.Width + 100,
    FImage.ColumnList.Border.Height + 100);
  try
    FImage.DrawContext.NeedRepaint := True;
    FImage.PrepareBuffer;
    ConvertToPNG(BufferForPNGSave, sdPng.FileName);
  finally
    FImage.DrawContext.IsPngDrawing := False;
    FImage.DrawContext.Canvas := FImage.Buffer.Canvas;
    FImage.DrawForPNGSave := False;
    FImage.ColumnList.SelectedElement := el;
    sbEditMode.Down := b;
    sbEditMode.Click;
    FreeAndNil(BufferForPNGSave);
  end;
  FImage.DrawContext.NeedRepaint := True;
  FImage.PrepareBuffer;
  FImage.Paint;
end;

procedure TfRoadMapMain.sSpeedButton10Click(Sender: TObject);
begin
  if Sender is TsSpeedButton then
  begin
    if eFilter.SelLength > 0 then
    begin
      eFilter.SelText := EmptyStr;
      eFilter.SelLength := 0;
    end;
    eFilter.Text := eFilter.Text + Trim((Sender as TsSpeedButton).Caption);
  end;
  eFilter.SelStart := Length(eFilter.Text);
  eFilter.SelLength := 0;
end;

procedure TfRoadMapMain.sSpeedButton11Click(Sender: TObject);
begin
  eFilter.Text := EmptyStr;
end;

procedure TfRoadMapMain.WMCopyData(var Msg: TWMCopyData);
var
  RecS: AnsiString;
  RecI: Integer;

begin
  RecS := PAnsiChar(Msg.CopyDataStruct.lpData);
  RecI := Msg.CopyDataStruct.dwData;
  Msg.Result := mrOk;
  case RecI of
    cKeySendType:
      begin
        fSetKey.SetKeyReceivedKey := Trim(RecS);
      end;
    cFilterSendType:
      begin
        sbFilter.Down := Trim(RecS) <> EmptyStr;
        sbFilter.Click;
        eFilter.Text := Trim(RecS);
      end;
    cSetLeft:
      begin
        Application.Restore;
        Self.WindowState := wsNormal;
        Self.Left := StrToIntDef(RecS, Self.Left);
        Self.Top := Screen.WorkAreaTop;
        Self.Height := Screen.WorkAreaHeight;
        Self.Width := Screen.WorkAreaWidth - Self.Left;
      end;
  end;
end;

end.
