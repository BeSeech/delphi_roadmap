unit uSettings;

interface

uses
  Registry,
  ShlObj,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sScrollBox, sFrameBar,
  sGroupBox, sLabel, Vcl.ExtCtrls;

type
  TfSettings = class(TForm)
    bOK: TButton;
    bCancel: TButton;
    mPrefixes: TMemo;
    mColumns: TMemo;
    sClient: TShape;
    Label1: TLabel;
    Shape1: TShape;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fSettings: TfSettings;

implementation

uses
  UMain;

procedure Associate;
var
  s: string;
  Reg: TRegistry;
begin
  Reg := TRegistry.Create; // создаем
  Reg.RootKey := HKEY_CLASSES_ROOT; // указываем корневую ветку

  Reg.OpenKey('.erm\OpenWithProgids\', true);
  Reg.WriteString('RoadMap.erm', '');

  Reg.OpenKey('\RoadMap.erm\DefaultIcon\', true);
  s := Application.ExeName + ',0';
  Reg.WriteString('', s);

  Reg.OpenKey('\RoadMap.erm\Shell\Open\', true);
  Reg.WriteString('', 'Открыть в RoadMap');

  Reg.OpenKey('command\', true);
  s := '"' + Application.ExeName + '" "%1"';
  Reg.WriteString('', s);

  Reg.Free;

  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
end;

procedure DeleteAssociate;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CLASSES_ROOT;

  Reg.DeleteKey('.erm');
  Reg.DeleteKey('RoadMap.erm');

  Reg.Free;

  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
end;

{$R *.dfm}

procedure TfSettings.Button1Click(Sender: TObject);
begin
  Associate;
end;

procedure TfSettings.Button2Click(Sender: TObject);
begin
  DeleteAssociate;
end;

procedure TfSettings.Button3Click(Sender: TObject);
var
  FileName: string;
begin
  FileName := ExtractFilePath(Application.ExeName) + 'Default.erm';
  fRoadMapMain.SaveToXml(FileName, True);
end;

end.
