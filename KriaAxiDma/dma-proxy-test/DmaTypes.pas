//  Conversion of https://github.com/Xilinx-Wiki-Projects/software-prototypes/blob/master/linux-user-space-dma/Software/Common/dma-proxy.h
{$MODE DELPHIUNICODE}
unit DmaTypes;

interface 

uses
  SysUtils, Classes, Unix, BaseUnix;

const
  BUFFER_SIZE             = (128 * 1024); // must match driver exactly 
  BUFFER_COUNT            = 32;           // driver only 
  SIZE_OF_CARDINAL        = 4;
  BUFFER_ARRAY_SIZE_BYTES = (BUFFER_SIZE div SIZE_OF_CARDINAL);

  TX_BUFFER_COUNT =	1;            // app only, must be <= to the number in the driver 
  RX_BUFFER_COUNT = 32;           // app only, must be <= to the number in the driver 
  BUFFER_INCREMENT = 1;           // normally 1, but skipping buffers (2) defeats prefetching in the CPU */

  _IOC_NRBITS    = 8;
  _IOC_TYPEBITS  = 8;
  _IOC_SIZEBITS  = 14;
  _IOC_DIRBITS   = 2;
  _IOC_NRMASK    = ((1 shl _IOC_NRBITS)-1);
  _IOC_TYPEMASK  = ((1 shl _IOC_TYPEBITS)-1);
  _IOC_SIZEMASK  = ((1 shl _IOC_SIZEBITS)-1);
  _IOC_DIRMASK   = ((1 shl _IOC_DIRBITS)-1);

  _IOC_NRSHIFT   = 0;
  _IOC_TYPESHIFT = (_IOC_NRSHIFT + _IOC_NRBITS);
  _IOC_SIZESHIFT = (_IOC_TYPESHIFT + _IOC_TYPEBITS);
  _IOC_DIRSHIFT  = (_IOC_SIZESHIFT + _IOC_SIZEBITS);

  _IOC_NONE  = 0;
  _IOC_WRITE = 1;
  _IOC_READ  = 2;

type
  TProxyStatus = (psNoError = 0, psBusy = 1, psTimeout = 2, psError = 3);
  PChannelBuffer = ^TChannelBuffer;
  TChannelBuffer = record
  	Buffer: array [0..(BUFFER_ARRAY_SIZE_BYTES - 1)] of Cardinal;
	  Status: TProxyStatus;
	  Length: Cardinal;
    Dummy0: Cardinal;
    Dummy1: Cardinal;
  end;

  PChannelBuffers = ^TChannelBuffers;
  TChannelBuffers = array[0..(BUFFER_COUNT - 1)] of TChannelBuffer;

  PChannel = ^TChannel;
  TChannel = record
	  ChannelBuffers: PChannelBuffers;
	  FileDescriptor: Integer;
	  ThreadId: Uint64;
  end;

function ProxyStatusToString(AProxyStatus: TProxyStatus): String;
function IOW(AType, ANumber: Char; ADataSize: Cardinal): Cardinal;
function IOR(AType, ANumber: Char; ADataSize: Cardinal): Cardinal;
function FINISH_XFER: Cardinal;
function START_XFER: Cardinal;
function XFER: Cardinal;
function SHOW_BUFLEN: Cardinal;

implementation

function ProxyStatusToString(AProxyStatus: TProxyStatus): String;
begin
  case AProxyStatus of
  psNoError: Result := 'psNoError';
  psBusy: Result := 'psBusy';
  psTimeout: Result := 'psTimeout';
  psError: Result := 'psError';
  else
    raise Exception.Create(Format('Invalid ProxyStatus: %d', [Integer(AProxyStatus)]));
  end;
end;

// The _IOW macro is typically used as _IOW(type, number, datatype):
// type: An 8-bit magic number, often an ASCII character, used to keep the ioctl 
//       numbers unique to your specific driver or subsystem.
// number: An 8-bit sequential number identifying the specific command.
// datatype: The actual type of the data structure (e.g., int, struct my_config) that is passed into the driver.
//           The macro uses sizeof() on this type to compute the payload size for the ioctl.

function IOW(AType, ANumber: Char; ADataSize: Cardinal): Cardinal;
begin
  Result := (ADataSize shl _IOC_SIZESHIFT) or (Ord(AType) shl _IOC_TYPESHIFT) or (Ord(ANumber) shl _IOC_NRSHIFT) or (_IOC_WRITE shl _IOC_DIRSHIFT) ; // $40000000 represents _IOC_WRITE
end;

function IOR(AType, ANumber: Char; ADataSize: Cardinal): Cardinal;
begin
  Result := (ADataSize shl _IOC_SIZESHIFT) or (Ord(AType) shl _IOC_TYPESHIFT) or (Ord(ANumber) shl _IOC_NRSHIFT) or (_IOC_READ shl _IOC_DIRSHIFT) ; // $40000000 represents _IOC_WRITE
end;

function FINISH_XFER: Cardinal;
begin
  Result := IOW('a','a', SizeOf(Integer));
end;

function START_XFER: Cardinal;
begin
  Result := IOW('a', 'b', SizeOf(Integer));
end;

function XFER: Cardinal;
begin
  Result := IOR('a', 'c', SizeOf(Integer));
end;

function SHOW_BUFLEN: Cardinal;
begin
  Result := IOR('a', 'd', SizeOf(Integer));
end;

begin

end.