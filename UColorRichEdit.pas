unit UColorRichEdit;

interface
uses
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.ComCtrls;

type
  TColorRichEdit = class
    private
      FRichEdit: TRichEdit;
    public
      function GetColorString(const AString: string; const AColor: TColor): String;
      procedure Process;
      constructor Create(ARichEdit: TRichEdit); overload;

  end;

implementation

{ TReColor }

constructor TColorRichEdit.Create(ARichEdit: TRichEdit);
begin
  inherited Create;
  FRichEdit := ARichEdit;
end;

function TColorRichEdit.GetColorString(const AString: string;
  const AColor: TColor): String;
begin
    Result := '{<Color>:' + IntToStr(Length(AString)) + ':<' +
      ColorToString(AColor) + '>}';
end;

procedure TColorRichEdit.Process;
  var
    sts, stl: Integer;
    ColorStartS, ColorStartL: Integer;
    stColor: TColor;
    sColor: string;
  begin
    while Pos('{<Color>:', FRichEdit.Text) > 0 do
    begin
      ColorStartS := Pos('{<Color>:', FRichEdit.Text) -
        FRichEdit.Lines.Count;
      ColorStartL := Pos('>}', FRichEdit.Text) - (FRichEdit.Lines.Count - 1)
        - ColorStartS + 1;
      FRichEdit.SelStart := ColorStartS;
      FRichEdit.SelLength := ColorStartL;
      sColor := FRichEdit.SelText;
      stl := StrToInt(Copy(sColor, Pos('>:', sColor) + 2,
        Pos(':<', sColor) - Pos('>:', sColor) - 2));
      sts := ColorStartS;
      sColor := Copy(sColor, Pos(':<', sColor) + 2,
        Pos('>}', sColor) - Pos(':<', sColor) - 2);
      stColor := StringToColor(sColor);
      FRichEdit.SelText := EmptyStr;
      FRichEdit.SelStart := sts;
      FRichEdit.SelLength := stl;
      FRichEdit.SelAttributes.Color := stColor;
      FRichEdit.SelStart := 0;
      FRichEdit.SelLength := 0;
    end;
  end;

end.
