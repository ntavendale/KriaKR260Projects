{$MODE DELPHIUNICODE}
program dmaProxyTest;

uses
  // By default, Free Pascal compiles programs as single-threaded applications.
  // To resolve this issue, you must include the cThreads unit as the VERY FIRST
  // unit in the uses clause of your main program file when working on Posix systems.
  // We won't bother with an ifdef since this is a linux only project.
  cThreads, 
  SysUtils,
  Unix, 
  BaseUnix,
  Linux,
  CTypes, 
  UnixType,
  PThreads,
  Math,
  DmaTypes in 'DmaTypes.pas',
  Utilities in 'Utilities.pas',
  TxChannel in 'TxChannel.pas',
  RxChannel in 'RxChannel.pas';

procedure SigInt(AInput: Integer);
begin
  TUtilities.Stop := TRUE;
end;

procedure ShowUsage;
begin
  WriteLn('Usage:');
  WriteLn('  dmaProxyTest <# of DMA transfers to perform> <# of bytes in each transfer in KB (< 1MB)> <optional verify, 0 or 1>');
end;

// Setup the transmit and receive threads so that the transmit thread is low priority to help prevent it from 
// overrunning the receive since most testing is done without any backpressure to the transmit channel.
procedure SetupThreads;
var
  tattr_tx: pthread_attr_t;
  i, newprio: Integer;
  param: sched_param;
begin
  newprio := 20;
  
  // Initialize the thread attributes struct
  pthread_attr_init (@tattr_tx);
  // The transmit thread should be lower priority than the receive
  // Get the default attributes and scheduling param
  pthread_attr_getschedparam(@tattr_tx, @param);
  // Set the transmit priority to the lowest
  param.sched_priority := newprio;
  pthread_attr_setschedparam (@tattr_tx, @param);

  for i := 0 to (RX_CHANNEL_COUNT - 1) do
    pthread_create(@RxChannels[i].ThreadId, nil, TStartRoutine(@RxThread), Pointer(@RxChannels[i]));
  
  for i := 0 to (TX_CHANNEL_COUNT - 1) do
    pthread_create(@TxChannels[i].ThreadId, @tattr_tx, TStartRoutine(@TxThread), Pointer(@TxChannels[i]));
end;

var
  i, max_channel_count: Integer;
  mb_sec: Double;
  channel_name: String;
  start_time, end_time, time_diff: Uint64;
begin
  TUtilities.Stop := FALSE;
  try
    TUtilities.TransferCount := StrToInt(ParamStr(1));
    TUtilities.TestSizeKb := StrToInt(ParamStr(2));
    if (ParamCount >= 3) then
      TUtilities.Verify := 0 <> StrToInt(ParamStr(3));
  except
    ShowUsage;
    Exit;
  end;
  WriteLn('DMA Proxy Test (', ParamCount, ')');
  WriteLn(Format('  Transfer Count     : %d', [TUtilities.TransferCount]));
  WriteLn(Format('  Transfer Data Size : %d Kb', [TUtilities.TestSizeKb]));
  if TUtilities.Verify then
    WriteLn('  Verify             : True')
  else  
    WriteLn('  Verify             : False');
  WriteLn(Format('  TxChannelBuffer Size Size : %d Bytes', [SizeOf(TChannelBuffer)]));
  WriteLn(Format('  TxChannel Size Size       : %d Bytes', [SizeOf(TTxChannel)]));
  WriteLn(Format('  RxChannel Size Size       : %d Bytes', [SizeOf(TRxChannel)]));

  max_channel_count := Max(TX_CHANNEL_COUNT, RX_CHANNEL_COUNT);

  WriteLn('Set up TxWrite channels');
  for i := 0 to (TX_CHANNEL_COUNT-1) do
  begin
    channel_name := '/dev/' + TxChannelNames[i];
    TxChannels[i].FileDescriptor := fpOpen(channel_name, O_RDWR);
    if TxChannels[i].FileDescriptor < 1 then
    begin
      WriteLn(Format('Unable to open DMA proxy device file: %s', [channel_name]));
      ExitCode := 1;
      Exit;
    end;
    
    // Open the file descriptors for each tx channel and map the kernel driver memory into user space
    // DMA cannot use virtual addresses. It needs a PHYSICAL memory address. So instead of allocating
    // memory using getmem, allocmem or whatever we will use fpMMap to map physical to the character device 
    // and use that address as our buffer pointer.
    // Because we defined a TChannelBuffers type TxChannels[i].ChannelBuffers won't be an opaque pointer.
    // We just allocate the size of that. We don't need to do calculate it's size
    TxChannels[i].ChannelBuffers := PTxChannelBuffers(fpMmap(nil, SizeOf(TTxChannelBuffers), PROT_READ or PROT_WRITE, MAP_SHARED, TxChannels[i].FileDescriptor, 0));
    
    if (TxChannels[i].ChannelBuffers = MAP_FAILED) then 
    begin
      WriteLn('Failed to mmap tx channel');
      ExitCode := 1;
      Exit;
    end;
    WriteLn(Format('TX#%d: 0x%p', [i, TxChannels[i].ChannelBuffers]));
  end;

  WriteLn('Set up TxRead channels');
  // Open the file descriptors for each rx channel and map the kernel driver memory into user space 
  // DMA cannot use virtual addresses. It needs a PHYSICAL memory address. So instead of allocating
  // memory using getmem, allocmem or whatever we will use fpMMap to map physical to the character device 
  // and use that address as our buffer pointer.
  // Because we defined a TChannelBuffers type TxChannels[i].ChannelBuffers won't be an opaque pointer.
  // We just allocate the size of that. We don't need to do calculate it's size
  for i := 0 to (RX_CHANNEL_COUNT-1) do
  begin
    channel_name := '/dev/' + RxChannelNames[i];
    RxChannels[i].FileDescriptor := fpOpen(channel_name, O_RDWR);
    if RxChannels[i].FileDescriptor < 1 then
    begin
      WriteLn(Format('Unable to open DMA proxy device file: %s', [channel_name]));
      ExitCode := 1;
      Exit;
    end;

    // Open the file descriptors for each tx channel and map the kernel driver memory into user space
    // DMA cannot use virtual addresses. It needs a PHYSICAL memory address. So instead of allocating
    // memory using getmem, allocmem or whatever we will use fpMMap to map physical to the character device 
    // and use that address as our buffer pointer.
    // Because we defined a TChannelBuffers type TxChannels[i].ChannelBuffers won't be an opaque pointer.
    // We just allocate the size of that. We don't need to do calculate it's size
    RxChannels[i].ChannelBuffers := PRxChannelBuffers(fpMmap(nil, sizeof(TRxChannelBuffers), PROT_READ or PROT_WRITE, MAP_SHARED, RxChannels[i].FileDescriptor, 0));
    if RxChannels[i].ChannelBuffers = MAP_FAILED then
    begin
      WriteLn('Failed to mmap rx channel');
      ExitCode := 1;
      Exit;
    end;
    WriteLn(Format('RX#%d: 0x%p', [i, RxChannels[i].ChannelBuffers]));
  end;

  start_time := TUtilities.get_posix_clock_time_usec;
  SetupThreads;
  
  // Do the minimum to know the transfers are done before getting the time for performance 
  for  i := 0 to (RX_CHANNEL_COUNT-1) do
    pthread_join(RxChannels[i].ThreadId, nil);

  // Grab the end time and calculate the performance
  end_time := TUtilities.get_posix_clock_time_usec;
  time_diff := end_time - start_time;
  mb_sec := (1000000 / time_diff) * (TUtilities.TransferCount * max_channel_count * TUtilities.TestSizeBytes) / 1000000;
  
  WriteLn(Format('Time: %d microseconds', [time_diff]));
  WriteLn(Format('Transfer size: %d KB', [TUtilities.TransferCount * (TUtilities.TestSizeKb) * max_channel_count]));
  WriteLn(Format('Throughput %.3f MB / sec', [mb_sec]));
  //Clean up all the channels before leaving 
  for i := 0 to (TX_CHANNEL_COUNT - 1) do
  begin
    pthread_join(TxChannels[i].ThreadId, nil);
    fpMunmap(TxChannels[i].ChannelBuffers, SizeOf(TTxChannelBuffers));
    fpClose(TxChannels[i].FileDescriptor);
  end;
  
  for i := 0 to (RX_CHANNEL_COUNT - 1) do
  begin
    fpMunmap(RxChannels[i].ChannelBuffers, SizeOf(TRxChannelBuffers));
    fpClose(RxChannels[i].FileDescriptor);
  end;
  WriteLn('');
  WriteLn('So long and thanks for all the fish!');
  WriteLn('DMA proxy test complete');
end.

