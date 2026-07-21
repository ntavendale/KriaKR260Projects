{$MODE DELPHIUNICODE}
unit TxChannel;

interface 

uses
  SysUtils, Classes, Unix, BaseUnix, Linux, DmaTypes, Utilities;

const 
  TX_CHANNEL_COUNT = 1;  
  TxChannelNames: array [0..0] of PChar = ('dma_proxy_tx'); //add unique channel names here 

var
  TxChannels: array[0 .. (TX_CHANNEL_COUNT -1)] of TChannel;

// The following function is the transmit thread to allow the transmit and the receive channels to be
// operating simultaneously. Some of the ioctl calls are blocking so that multiple threads are required.
function TxThread(AChannel: PChannel): Pointer;

implementation

function TxThread(AChannel: PChannel): Pointer;
var
  i, counter, buffer_id, in_progress_count: Integer;
  stop_in_progress: Boolean;
begin
  
  counter := 0;
  in_progress_count := 0;
  buffer_id := 0;
  stop_in_progress := FALSE;

  while (buffer_id < TX_BUFFER_COUNT) do
  begin
    AChannel^.ChannelBuffers[buffer_id]^.Length := TUtilities.TestSizeBytes;
    if TUtilities.Verify then
    begin
      for i := 0 to (1-1) do// test_size / sizeof(unsigned int); i++)
        AChannel^.ChannelBuffers[buffer_id]^.Buffer[i] := i + in_progress_count;
    end;

    // Start the DMA transfer and this call is non-blocking
    fpIoctl(AChannel^.FileDescriptor, START_XFER, @buffer_id);

    // Keep track of the number of transfers that are in progress and if the number is less
    // than the number of channel buffers then stop before all channel buffers are used
    Inc(in_progress_count);
		if in_progress_count >= TUtilities.TransferCount then
			BREAK;

    Inc(buffer_id, BUFFER_INCREMENT);
  end;

  // Start finishing up the DMA transfers that were started beginning with the 1st channel buffer.
  while (TRUE) do
  begin
    // Perform the DMA transfer and check the status after it completes
    // as the call blocks til the transfer is done.
    fpIoctl(AChannel^.FileDescriptor, FINISH_XFER, @buffer_id);
    if (AChannel^.ChannelBuffers[buffer_id]^.Status <> psNoError) then
      WriteLn(Format('Proxy tx transfer error %s', [ProxyStatusToString(AChannel^.ChannelBuffers[buffer_id]^.Status)]));
    // Keep track of how many transfers are in progress and how many completed
    Dec(in_progress_count);
    Inc(counter);
    
    // If all the transfers are done then exit
    if (counter >= TUtilities.TransferCount) then
      BREAK;
    // If an early stop (control c or kill) has happened then exit gracefully
    // letting all transfers queued up be completed, but it's trickier because
    // the number of transmit vs receive channel buffers can be very different
    // which means another X transfers need to be done gracefully shutdown the
    // receive without leaving transfers in progress which is unrecoverable
    if (TUtilities.Stop and not stop_in_progress)  then
    begin
      stop_in_progress := TRUE;
      TUtilities.TransferCount := counter + RX_BUFFER_COUNT;
    end;
    
    // If the ones in progress will complete the count then don't start more
    if ((counter + in_progress_count) >= TUtilities.TransferCount) then
    begin
      buffer_id := buffer_id + BUFFER_INCREMENT;
      buffer_id := buffer_id mod TX_BUFFER_COUNT;
      CONTINUE;
    end;

    // Initialize the buffer and perform the DMA transfer, check the status after it completes
    // as the call blocks til the transfer is done.
    if (TUtilities.Verify) then
    begin
      for i := 0 to (TUtilities.TestSizeBytes div sizeof(Cardinal)) -1 do
        AChannel^.ChannelBuffers[buffer_id]^.Buffer[i] := i + ((TX_BUFFER_COUNT div BUFFER_INCREMENT) - 1) + counter;
    end;
    
    // Restart the completed channel buffer to start another transfer and keep
    // track of the number of transfers in progress
    fpIoctl(AChannel^.FileDescriptor, START_XFER, @buffer_id);
    Inc(in_progress_count);
  end;
  Result := nil;
end;

begin
end.