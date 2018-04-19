unit ULogin;

interface

uses
  NativeXml,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfLogin = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    eLogin: TEdit;
    ePassword: TEdit;
    Shape1: TShape;
    Shape2: TShape;
    Button1: TButton;
    Button2: TButton;
    sClient: TShape;
    Shape4: TShape;
    eUrl: TEdit;
    lUrl: TLabel;
    Shape3: TShape;
  private
    function GetLogin: string;
    function GetPassword: string;
    procedure SetLogin(const Value: string);
    procedure SetPassword(const Value: string);
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);
    { Private declarations }
  public
    { Public declarations }
    procedure SaveToXml;
    procedure LoadFromXml;
    property BaseUrl: string read GetBaseUrl write SetBaseUrl;
    property Login: string read GetLogin write SetLogin;
    property Password: string read GetPassword write SetPassword;
  end;

var
  fLogin: TfLogin;

implementation

const
  cAuthFileName = 'Authorization.cfg';

{$R *.dfm}

  { TForm1 }
function CodeString_v2(mes: string): string;
var
  i: integer;
  s: string;
  CodeText: string;
  iElement: integer;
begin
  s := EmptyStr;
  for i := 1 to length(mes) do
  begin
    s := s + IntToStr(ord(mes[i]) xor i);
    if i <> length(mes) then
      s := s + '_';
  end;
  Result := s;
end;

function DeCodeString_v2(mes: string): string;
var
  i: integer;
  s: string;
  CodeText: string;
  iElement: integer;
  sElement: string;
begin
  s := mes;
  Result := EmptyStr;
  if Trim(mes) = EmptyStr then
    Exit;
  i := 1;
  while Pos('_', s) > 0 do
  begin
    sElement := Copy(s, 1, Pos('_', s) - 1);
    s := Copy(s, Pos('_', s) + 1, length(s));
    iElement := StrToInt(sElement);

    Result := Result + Chr(iElement xor i);
    i := i + 1;
  end;
  iElement := StrToInt(s);
  Result := Result + Chr(iElement xor i);
end;

function TfLogin.GetBaseUrl: string;
begin
  Result := Trim(eUrl.Text);
end;

function TfLogin.GetLogin: string;
begin
  Result := Trim(eLogin.Text);
end;

function TfLogin.GetPassword: string;
begin
  Result := Trim(ePassword.Text);
end;

procedure TfLogin.LoadFromXml;
var
  NativeXml: TNativeXml;
  Node: TXMLNode;
  i: integer;
begin
  if not FileExists(ExtractFilePath(Application.ExeName) + cAuthFileName) then
  begin
    Login := 'beseech';
    Password := EmptyStr;
    BaseUrl := 'http://estream.atlassian.net';
    Exit;
  end;
  NativeXml := TNativeXml.Create(nil);
  try
    NativeXml.LoadFromFile(ExtractFilePath(Application.ExeName) +
      cAuthFileName);
    Node := NativeXml.Root.NodeByName('Authorization').NodeByName('Login');
    if Assigned(Node) then
      Login := DeCodeString_v2
        (Node.Attributes[Node.AttributeIndexByName('Value')].Value);

    Node := NativeXml.Root.NodeByName('Authorization').NodeByName('Password');
    if Assigned(Node) then
      Password := DeCodeString_v2
        (Node.Attributes[Node.AttributeIndexByName('Value')].Value);

    Node := NativeXml.Root.NodeByName('Authorization').NodeByName('BaseUrl');
    if Assigned(Node) then
      BaseUrl := DeCodeString_v2
        (Node.Attributes[Node.AttributeIndexByName('Value')].Value);

  finally
    FreeAndNil(NativeXml);
  end;
end;

procedure TfLogin.SaveToXml;
var
  NativeXml: TNativeXml;
  NodeB: TXMLNode;
  Node: TXMLNode;
  i: integer;
begin
  NativeXml := TNativeXml.Create(nil);
  NativeXml.Clear;
  NativeXml.ExternalEncoding := seUTF8;
  NativeXml.WriteOnDefault := False;
  NativeXml.Canonicalize;
  NativeXml.XmlFormat := xfReadable;
  NativeXml.VersionString := '1.0';
  NativeXml.Declaration.Version := '1.0';
  NativeXml.Declaration.Encoding := 'utf-8';
  NativeXml.Charset := 'utf-8';
  NodeB := NativeXml.Root.NodeNew('Authorization');
  try
    Node := NodeB.NodeNew('Login');
    Node.AttributeAdd('Value', CodeString_v2(Login));

    Node := NodeB.NodeNew('Password');
    Node.AttributeAdd('Value', CodeString_v2(Password));

    Node := NodeB.NodeNew('BaseUrl');
    Node.AttributeAdd('Value', CodeString_v2(BaseUrl));
  finally
    NativeXml.Root.Name := 'Authorization';
    NativeXml.SaveToFile(ExtractFilePath(Application.ExeName) + cAuthFileName);
    FreeAndNil(NativeXml);
  end;
end;

procedure TfLogin.SetBaseUrl(const Value: string);
begin
  eUrl.Text := Trim(Value);
end;

procedure TfLogin.SetLogin(const Value: string);
begin
  eLogin.Text := Trim(Value);
end;

procedure TfLogin.SetPassword(const Value: string);
begin
  ePassword.Text := Trim(Value);
end;

end.
