{$MODE DELPHIUNICODE}
program dmaProxyTest;

uses
  SysUtils,
  Unix, 
  BaseUnix,
  Linux,
  CTypes, 
  UnixType,
  PThreads,
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
procedure SetupThreads(num_transfers: PInteger);
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


begin
  TUtilities.Stop := FALSE;
  try
    TUtilities.TransferCount := StrToInt(ParamStr(1));
    TUtilities.TestSizeKb := StrToInt(ParamStr(2));
    if (ParamCount >= 4) then
      TUtilities.Verify := 0 <> StrToInt(ParamStr(3));
  except
    ShowUsage;
    Exit;
  end;
  WriteLn('DMA Proxy Test');
  WriteLn(Format('  Transfer Count     : %d', [TUtilities.TransferCount]));
  WriteLn(Format('  Transfer Data Size : %d Kb', [TUtilities.TestSizeKb]));
  if TUtilities.Verify then
    WriteLn('  Verify             : True')
  else  
    WriteLn('  Verify             : False');
  WriteLn(Format('  TChannelBuffer Size Size : %d Bytes', [SizeOf(TChannelBuffer)]));
  WriteLn(Format('  TChannel Size Size       : %d Bytes', [SizeOf(TChannel)]));
end.

