{$MODE DELPHIUNICODE}
unit Utilities;

interface 

uses
  SysUtils, Classes, Unix, BaseUnix, Linux, DmaTypes;

type 
  TUtilities = class
  private
    class var FDataIn: Cardinal;
  public
    class function get_posix_clock_time_usec: UInt64;
    class property DataIn: Cardinal read FDataIn write FDataIn;
  end;


implementation

class function TUtilities.get_posix_clock_time_usec: UInt64;
var
  ts: timespec;
begin
  if (clock_gettime (CLOCK_MONOTONIC, @ts) = 0) then
    Result:= (ts.tv_sec * 1000000) + (ts.tv_nsec div 1000)
  else
    Result := 0;
end;

begin
end.