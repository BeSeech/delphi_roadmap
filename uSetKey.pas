unit uSetKey;

interface

uses
  ClipBrd,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  sSpeedButton;

type
  TfSetKey = class(TForm)
    cbKeyPrefix: TComboBox;
    eKey: TEdit;
    bCancel: TButton;
    bOK: TButton;
    sClient: TShape;
    Shape1: TShape;
    sSpeedButton1: TsSpeedButton;
    sSpeedButton2: TsSpeedButton;
    sSpeedButton3: TsSpeedButton;
    sSpeedButton4: TsSpeedButton;
    sSpeedButton5: TsSpeedButton;
    sSpeedButton6: TsSpeedButton;
    sSpeedButton7: TsSpeedButton;
    sSpeedButton8: TsSpeedButton;
    sSpeedButton9: TsSpeedButton;
    sSpeedButton10: TsSpeedButton;
    sSpeedButton11: TsSpeedButton;
    Shape2: TShape;
    Label1: TLabel;
    sbPasteKey: TsSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure sSpeedButton11Click(Sender: TObject);
    procedure sSpeedButton10Click(Sender: TObject);
    procedure sbPasteKeyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FSetKeyReceivedKey: string;
    procedure SetSetKeyReceivedKey(const Value: string);
  public
    property SetKeyReceivedKey: string read FSetKeyReceivedKey write SetSetKeyReceivedKey;
  end;

var
  fSetKey: TfSetKey;
  //{<KeyFromJira>}TN-1384

implementation

{$R *.dfm}

procedure TfSetKey.FormCreate(Sender: TObject);
begin
  FSetKeyReceivedKey := EmptyStr;
end;

procedure TfSetKey.FormShow(Sender: TObject);
var
  s: string;
  l: Integer;
begin
  if SetKeyReceivedKey <> EmptyStr then
  begin
    sbPasteKey.Caption := SetKeyReceivedKey;
    sbPasteKey.Visible := True;
  end
  else
    sbPasteKey.Visible := False;
  eKey.SetFocus;
end;

procedure TfSetKey.sbPasteKeyClick(Sender: TObject);
var
  s: string;
  KeyPrefix: string;
begin
  s := sbPasteKey.Caption;
  eKey.Text := Copy(s, Pos('-', s) + 1, Length(s));
  KeyPrefix := Copy(s, 1, Pos('-', s) - 1);
  cbKeyPrefix.ItemIndex := cbKeyPrefix.Items.IndexOf(Trim(KeyPrefix));
end;

procedure TfSetKey.SetSetKeyReceivedKey(const Value: string);
begin
  FSetKeyReceivedKey := Value;

  if SetKeyReceivedKey <> EmptyStr then
  begin
    sbPasteKey.Caption := SetKeyReceivedKey;
    sbPasteKey.Visible := True;
  end
  else
    sbPasteKey.Visible := False;
end;

procedure TfSetKey.sSpeedButton10Click(Sender: TObject);
begin
  if Sender is TsSpeedButton then
  begin
    if eKey.SelLength > 0 then
    begin
      eKey.SelText := EmptyStr;
      eKey.SelLength := 0;
    end;
    eKey.Text :=   eKey.Text + Trim((Sender as TsSpeedButton).Caption);
  end;
  eKey.SelStart := Length(eKey.Text);
  eKey.SelLength := 0;
end;

procedure TfSetKey.sSpeedButton11Click(Sender: TObject);
begin
  eKey.Text := EmptyStr;
end;

end.
