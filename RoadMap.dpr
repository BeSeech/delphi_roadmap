program RoadMap;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fRoadMapMain},
  uBeImage in 'uBeImage.pas',
  UTouchPoint in 'UTouchPoint.pas',
  uBeColumn in 'uBeColumn.pas',
  uSetKey in 'uSetKey.pas' {fSetKey},
  uSettings in 'uSettings.pas' {fSettings},
  NativeXml in 'nativexml\nativexml\NativeXml.pas',
  sdStreams in 'nativexml\nativexml\sdStreams.pas',
  sdDebug in 'nativexml\nativexml\sdDebug.pas',
  sdStringTable in 'nativexml\nativexml\sdStringTable.pas',
  ULogin in 'ULogin.pas' {fLogin},
  uContext in 'uContext.pas',
  uUpdater in 'uUpdater.pas',
  uAppInfo in 'uAppInfo.pas',
  uDialogs in 'uDialogs.pas',
  DirectDraw in 'L:\GDIPlus\DirectDraw.pas',
  GDIPAPI_Evos in 'GDIPlus\GDIPAPI_Evos.pas',
  GDIPOBJ_Evos in 'GDIPlus\GDIPOBJ_Evos.pas',
  GDIPUTIL in 'GDIPlus\GDIPUTIL.pas',
  uPing in 'uPing.pas',
  USendStrToOtherApp in 'USendStrToOtherApp.pas',
  URoadMapIntegrationConst in 'URoadMapIntegrationConst.pas',
  UIssueStatistic in 'UIssueStatistic.pas' {fIssueStatistic};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'RoadMap';
  Application.CreateForm(TfRoadMapMain, fRoadMapMain);
  Application.CreateForm(TfSetKey, fSetKey);
  Application.CreateForm(TfSettings, fSettings);
  Application.CreateForm(TfLogin, fLogin);
  Application.CreateForm(TfIssueStatistic, fIssueStatistic);
  Application.Run;
end.
