{$MODE DELPHIUNICODE}
unit RxChannel;

interface 

uses
  SysUtils, Classes, Unix, BaseUnix, Linux, DmaTypes, Utilities;

const 
  RX_CHANNEL_COUNT = 1;
  RxChannelNames: array [0..0] of PChar = ('dma_proxy_rx'); //add unique channel names here 

var
  RxChannels: array[0 .. (RX_CHANNEL_COUNT -1)] of TChannel;

// The following function is the transmit thread to allow the transmit and the receive channels to be
// operating simultaneously. Some of the ioctl calls are blocking so that multiple threads are required.
function RxThread(AChannel: PChannel): Pointer;  

implementation

function RxThread(AChannel: PChannel): Pointer;
var
  in_progress_count, buffer_id,rx_counter: Integer;
begin
  in_progress_count := 0;
  buffer_id := 0;
  rx_counter := 0;

  // Start all buffers being received
  while (buffer_id < RX_BUFFER_COUNT) do
  begin
    // Don't worry about initializing the receive buffers as the pattern used in the
    // transmit buffers is unique across every transfer so it should catch errors.
    
    AChannel^.ChannelBuffers[buffer_id]^.Length := TUtilities.TestSizeBytes;
    
    fpIoctl(AChannel^.FileDescriptor, START_XFER, @buffer_id);
    // Handle the case of a specified number of transfers that is less than the number
    // of buffers
    Inc(in_progress_count);
    if in_progress_count >= TUtilities.TransferCount then
      BREAK;
      
    Inc(buffer_id, BUFFER_INCREMENT);
  end;
  Result := nil;
end;

begin
end.