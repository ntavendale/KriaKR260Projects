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
  i, in_progress_count, buffer_id,rx_counter: Integer;
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
  
  buffer_id := 0;
  // Finish each queued up receive buffer and keep starting the buffer over again
  // until all the transfers are done
  while (TRUE) do
  begin
    fpIoctl(AChannel^.FileDescriptor, FINISH_XFER, @buffer_id);
    if AChannel^.ChannelBuffers[buffer_id]^.Status <> psNoError then
    begin
      WriteLn(Format('Proxy rx transfer error, # transfers %d, # completed %d, # in progress %d, Status %s', [TUtilities.TransferCount, rx_counter, in_progress_count, ProxyStatusToString(AChannel^.ChannelBuffers[buffer_id]^.Status)]));
			Exit;
    end;
    
    // Verify the data received matches what was sent (tx is looped back to tx)
    // A unique value in the buffers is used across all transfers
    if TUtilities.Verify then
    begin
      for i := 0 to (1-1) do // test_size / sizeof(unsigned int); i++) this is slow
      begin
        if AChannel^.ChannelBuffers[buffer_id]^.Buffer[i] <> i + rx_counter then
        begin
          WriteLn(Format('buffer not equal, index = %d, data = %d expected data = %d', [i, AChannel^.ChannelBuffers[buffer_id]^.Buffer[i], i + rx_counter]));
          BREAK;
        end;
      end;
    end;

    // Keep track how many transfers are in progress so that only the specified number
    // of transfers are attempted
    Dec(in_progress_count, 1);

    // If all the transfers are done then exit 
    Inc(rx_counter, 1);
    if (rx_counter >= TUtilities.TransferCount) then
      BREAK;

    // If the ones in progress will complete the number of transfers then don't start more
    // but finish the ones that are already started
    if ((rx_counter + in_progress_count) >= TUtilities.TransferCount) then
    begin
      // Flip to next buffer treating them as a circular list, and possibly skipping some
      // to show the results when prefetching is not happening
      Inc(buffer_id, BUFFER_INCREMENT);
      buffer_id := buffer_id mod RX_BUFFER_COUNT;
      CONTINUE;
    end;
    // Start the next buffer again with another transfer keeping track of
    // the number in progress but not finished
    fpIoctl(AChannel^.FileDescriptor, START_XFER, @buffer_id);
    
    Inc(in_progress_count, 1);
  end;

  Result := nil;
end;

begin
end.