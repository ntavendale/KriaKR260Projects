{$MODE DELPHIUNICODE}
unit Utilities;

interface 

uses
  SysUtils, Classes, Unix, BaseUnix, Linux, DmaTypes;

type 
  TUtilities = class
  private
    class var FStop: Boolean;
    class var FVerify: Boolean;
    class var FTransferCount: Cardinal;
    class var FDataCountKilobytes: Cardinal;
    class function GetTestSizeBytes: Cardinal; static;
  public
    class function get_posix_clock_time_usec: UInt64;
    class property Stop: Boolean read FStop write FStop;
    class property Verify: Boolean read FVerify write FVerify;
    class property TransferCount: Cardinal read FTransferCount write FTransferCount;
    class property TestSizeKb: Cardinal read FDataCountKilobytes write FDataCountKilobytes;
    class property TestSizeBytes: Cardinal read GetTestSizeBytes;
  end;


implementation

class function TUtilities.GetTestSizeBytes: Cardinal;
begin
  Result := FDataCountKilobytes * 1024;
  if (Result > BUFFER_SIZE) then
    Result := BUFFER_SIZE;
end;

class function TUtilities.get_posix_clock_time_usec: UInt64;
var
  ts: timespec;
begin
  if (clock_gettime (CLOCK_MONOTONIC, @ts) = 0) then
    Result:= UInt64((ts.tv_sec * 1000000) + (ts.tv_nsec / 1000))
  else
    Result := 0;
end;

begin
end.