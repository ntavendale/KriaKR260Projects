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
procedure TxThread(AChannel: PChannel; TestSize: Integer; AVerify: Boolean; TransferCount: Integer);

implementation

procedure TxThread(AChannel: PChannel; TestSize: Integer; AVerify: Boolean; TransferCount: Integer);
var
  i, counter, buffer_id, in_progress_count, stop_in_progress: Integer;
begin
  counter := 0;
  stop_in_progress := 0;

  buffer_id := 0;
  while (buffer_id < TX_BUFFER_COUNT) do
  begin
    AChannel^.ChannelBuffers[buffer_id]^.Length := TestSize;
    if AVerify then
    begin
			for i := 0 to (1-1) do// test_size / sizeof(unsigned int); i++)
				AChannel^.ChannelBuffers[buffer_id]^.Buffer[i] := i + in_progress_count;
    end;

    // Start the DMA transfer and this call is non-blocking
    fpIoctl(AChannel^.FileDescriptor, START_XFER, @buffer_id);

    //Keep track of the number of transfers that are in progress and if the number is less
		// than the number of channel buffers then stop before all channel buffers are used
    Inc(in_progress_count);
		if in_progress_count >= TransferCount then
			BREAK;

    Inc(buffer_id, BUFFER_INCREMENT);
  end;
end;

begin
end.