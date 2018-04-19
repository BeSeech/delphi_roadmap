unit uPing;

interface

uses
  Windows, SysUtils, Classes, WinSock;

type
  ip_option_information = packed record
    Ttl: byte;
    Tos: byte;
    Flags: byte;
    OptionsSize: byte;
    OptionsData: Pointer;
  end;

  icmp_echo_reply = packed record
    Address: u_long;
    Status: u_long;
    RTTime: u_long;
    DataSize: u_short;
    Reserved: u_short;
    Data: Pointer;
    Options: ip_option_information;
  end;

  PIPINFO = ^ip_option_information;
  PVOID = Pointer;

function IcmpCreateFile(): THandle; stdcall;
  external 'ICMP.DLL' name 'IcmpCreateFile';
function IcmpCloseHandle(IcmpHandle: THandle): BOOL; stdcall;
  external 'ICMP.DLL' name 'IcmpCloseHandle';
function IcmpSendEcho(IcmpHandle: THandle;
  DestAddress: u_long;
  RequestData: PVOID;
  RequestSize: Word;
  RequestOptns: PIPINFO;
  ReplyBuffer: PVOID;
  ReplySize: DWORD;
  Timeout: DWORD): DWORD; stdcall; external 'ICMP.DLL' name 'IcmpSendEcho';

function Ping(const AHost: AnsiString): Boolean;

implementation

function Ping(const AHost: AnsiString): Boolean;
var
  hIP: THandle;
  pingBuffer: array [0 .. 31] of Char;
  pIpe: ^icmp_echo_reply;
  pHostEn: PHostEnt;
  wVersionRequested: Word;
  lwsaData: WSAData;
  error: DWORD;
  DestAddress: In_Addr;
begin
  try
  Result := False;
  hIP := IcmpCreateFile();
  GetMem(pIpe, sizeof(icmp_echo_reply) + sizeof(pingBuffer));
  pIpe.Data := @pingBuffer;
  pIpe.DataSize := sizeof(pingBuffer);
  wVersionRequested := MakeWord(1, 1);
  error := WSAStartup(wVersionRequested, lwsaData);
  if (error <> 0) then
    Exit;
  pHostEn := gethostbyname(PAnsiChar(AHost));
  error := GetLastError();
  if (error <> 0) then
    Exit;
  DestAddress := PInAddr(pHostEn^.h_addr_list^)^;
  IcmpSendEcho(hIP, DestAddress.S_addr, @pingBuffer, sizeof(pingBuffer), Nil,
    pIpe, sizeof(icmp_echo_reply) + sizeof(pingBuffer), 100);
  error := GetLastError();
  if (error <> 0) then
    Exit;
  IcmpCloseHandle(hIP);
  WSACleanup();
  FreeMem(pIpe);
  Result := True;
  except
    on E:Exception do
    begin
      Result := False;
    end;
  end;
end;

end.
