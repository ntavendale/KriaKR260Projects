{$MODE DELPHIUNICODE}
unit Utilities;

interface 

uses
  SysUtils, Classes, Unix, BaseUnix, Linux;

type 
  TUtilities = class
  public
    class function get_posix_clock_time_usec: UInt64;
  end;

implementation

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