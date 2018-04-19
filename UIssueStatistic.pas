unit UIssueStatistic;

interface

uses
  UColorRichEdit, UIssueStatusStatistic,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls;

type
  TfIssueStatistic = class(TForm)
    lCaption: TLabel;
    reIssueStatistic: TRichEdit;
    bOK: TButton;
    Shape2: TShape;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FColorHelper: TColorRichEdit;
  public
    procedure FillFromIssueStatistic(const AIssueStatusStatistic
      : TIssueStatusStatistic);
  end;

var
  fIssueStatistic: TfIssueStatistic;

implementation

{$R *.dfm}
{ TfIssueStatistic }

procedure TfIssueStatistic.FillFromIssueStatistic(const AIssueStatusStatistic
  : TIssueStatusStatistic);
const
  cSpace = '    ';
  cPre = 'Подготовка';
  cRun = 'Выполнение';
  cTest = 'Тестирование';
var
  i: Integer;
  s: string;

  function GetS(AISS: TIssueStatus): string;
  begin
    if AISS.Days > 0 then
      Result := IntToStr(AISS.Days) + ' дней'
    else
      Result := IntToStr(AISS.Hours) + ' часов';
  end;

  function GetColorString(const AString: string; const AColor: TColor): String;
  begin
    Result := FColorHelper.GetColorString(AString, AColor);
  end;

  procedure Process;
  begin
    FColorHelper.Process;
  end;

begin
  reIssueStatistic.Lines.BeginUpdate;
  try
    reIssueStatistic.Lines.Clear;
    reIssueStatistic.Lines.Add(GetColorString(AIssueStatusStatistic.Key, clNavy) + AIssueStatusStatistic.Key);
    Process;
    reIssueStatistic.Lines.Add(cSpace + GetColorString(AIssueStatusStatistic.Summary, clGrayText) + AIssueStatusStatistic.Summary);
    Process;
    reIssueStatistic.Lines.Add(cSpace + GetColorString(AIssueStatusStatistic.Status, clGrayText) + AIssueStatusStatistic.Status);
    Process;
    reIssueStatistic.Lines.Add(cSpace);

    reIssueStatistic.Lines.Add(GetColorString(cPre, clBlack) + cPre);
    Process;
    for i := 0 to Pred(AIssueStatusStatistic.Statuses.Count) do
    begin
      if (AIssueStatusStatistic[i].Name <> 'Создано') and
       (AIssueStatusStatistic[i].Name <> 'Ожидает обсуждения') and
       (AIssueStatusStatistic[i].Name <> 'Одобрено на обсуждении') and
       (AIssueStatusStatistic[i].Name <> 'Подтверждено') and
       (AIssueStatusStatistic[i].Name <> 'Ожидает выполнения') then
          Continue;
      s := GetS(AIssueStatusStatistic[i]);
      reIssueStatistic.Lines.Add(cSpace + GetColorString(AIssueStatusStatistic[i].Name, clGrayText) + AIssueStatusStatistic[i].Name +
        ' - ' + GetColorString(s, clGrayText) + s);
      Process;
    end;

    reIssueStatistic.Lines.Add(cSpace);
    reIssueStatistic.Lines.Add(GetColorString(cRun, clBlue) + cRun);
    Process;
    for i := 0 to Pred(AIssueStatusStatistic.Statuses.Count) do
    begin
      if (AIssueStatusStatistic[i].Name <> 'Выполняется') and
       (AIssueStatusStatistic[i].Name <> 'Возвращено при тестировании') then
          Continue;
      s := GetS(AIssueStatusStatistic[i]);
      reIssueStatistic.Lines.Add(cSpace + GetColorString(AIssueStatusStatistic[i].Name, clGrayText) + AIssueStatusStatistic[i].Name +
        ' - ' + GetColorString(s, clGrayText) + s);
      Process;
    end;

    reIssueStatistic.Lines.Add(cSpace);
    reIssueStatistic.Lines.Add(GetColorString(cTest, clGreen) + cTest);
    Process;
    for i := 0 to Pred(AIssueStatusStatistic.Statuses.Count) do
    begin
      if (AIssueStatusStatistic[i].Name <> 'Ожидает тестирования') and
       (AIssueStatusStatistic[i].Name <> 'Тестируется') then
          Continue;
      s := GetS(AIssueStatusStatistic[i]);
      reIssueStatistic.Lines.Add(cSpace + GetColorString(AIssueStatusStatistic[i].Name, clGrayText) + AIssueStatusStatistic[i].Name +
        ' - ' + GetColorString(s, clGrayText) + s);
      Process;
    end;

  finally
    reIssueStatistic.Lines.EndUpdate;
  end;
  //
end;

procedure TfIssueStatistic.FormCreate(Sender: TObject);
begin
  FColorHelper := TColorRichEdit.Create(reIssueStatistic);
end;

procedure TfIssueStatistic.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FColorHelper);
end;

end.
