unit USendStrToOtherApp;

interface

uses
  Winapi.Windows, Winapi.Messages, Vcl.Controls, Vcl.Forms;

type
  TReceiverRecord = record
    MainFormClassName: string;
    MainFormCaption: string;
  end;
  TCopyDataStruct = packed record
    dwData: DWORD; // до 32 бит, которые нужно передать
    // приложению-получателю
    cbData: DWORD; // размер, в байтах данных, указателя lpData
    lpData: Pointer; // Указатель на данные, которые нужно передать
    // приложению-получателю. Может быть NIL.
  end;

  TStringSender = class
  private
    class function SendData(const copyDataStruct: TCopyDataStruct; const AToApplication: TReceiverRecord): Integer;
  public
    class function SendString(const AString: string; const AInteger: Integer; const AToApplication: TReceiverRecord): Integer;
  end;

implementation

class function TStringSender.SendData(const copyDataStruct: TCopyDataStruct; const AToApplication: TReceiverRecord): Integer;
var
  receiverHandle: THandle;
  res: Integer;
begin
  Result := mrNone;
  if AToApplication.MainFormCaption = '' then
  receiverHandle := FindWindow(PChar(AToApplication.MainFormClassName), nil)
  else
  receiverHandle := FindWindow(PChar(AToApplication.MainFormClassName), PChar(AToApplication.MainFormCaption));
  if receiverHandle = 0 then
  begin
    Result := mrIgnore;
    Exit;
  end;
  Result := SendMessage(receiverHandle, WM_COPYDATA,
    Integer(Application.Handle), Integer(@copyDataStruct));
end;

class function TStringSender.SendString(const AString: string; const AInteger: Integer; const AToApplication: TReceiverRecord): Integer;
var
  copyDataStruct: TCopyDataStruct;
  s: AnsiString;
begin
  s := AString;
  copyDataStruct.dwData := AInteger;
  copyDataStruct.cbData := 1 + Length(s);
  copyDataStruct.lpData := Pointer(s);
  Result := SendData(copyDataStruct, AToApplication);
end;

end.
