{$MODE DELPHIUNICODE}

{$I mormot.defines.inc}
program hygrometer;

uses
  // By default, Free Pascal compiles programs as single-threaded applications.
  // To resolve this issue, you must include the cThreads unit as the VERY FIRST
  // unit in the uses clause of your main program file when working on Posix systems.
  // We won't bother with an ifdef since this is a linux only project.
  {$I mormot.uses.inc}
  //cThreads, 
  SysUtils,
  Unix, 
  BaseUnix,
  Linux,
  CTypes, 
  UnixType,
  PThreads,
  Math,
  mormot.core.base,
  mormot.core.os,
  mormot.core.log,
  mormot.orm.core,
  mormot.db.raw.sqlite3,
  mormot.rest.http.server,
  DmaTypes in 'DmaTypes.pas',
  Utilities in 'Utilities.pas',
  TxChannel in 'TxChannel.pas',
  RxChannel in 'RxChannel.pas';

procedure ShowUsage;
begin
  WriteLn('Usage:');
  WriteLn('  dmaProxyTest <# of DMA transfers to perform> <# of bytes in each transfer in KB (< 1MB)> <optional verify, 0 or 1>');
end;

// Setup the transmit and receive threads so that the transmit thread is low priority to help prevent it from 
// overrunning the receive since most testing is done without any backpressure to the transmit channel.
var
  data_read: Cardinal;
  max_channel_count: Integer;
  mb_sec: Double;
  channel_name: String;
  start_time, end_time, time_diff: Uint64;
begin
  try
    TUtilities.DataIn := StrToInt(ParamStr(1));
  except
    ShowUsage;
    Exit;
  end;
  WriteLn('hygrometer test (', ParamCount, ')');
  WriteLn(Format('  Data In     : %d', [TUtilities.DataIn]));

  WriteLn(Format('  TxChannelBuffer Size Size : %d Bytes', [SizeOf(TChannelBuffer)]));
  WriteLn(Format('  TxChannel Size Size       : %d Bytes', [SizeOf(TTxChannel)]));
  WriteLn(Format('  RxChannel Size Size       : %d Bytes', [SizeOf(TRxChannel)]));

  max_channel_count := Max(TX_CHANNEL_COUNT, RX_CHANNEL_COUNT);

  SendData(TUtilities.DataIn);
  data_read := ReadData;
  WriteLn(Format('Data Read  0x%.8x', [data_read]));

  WriteLn('');
  WriteLn('So long and thanks for all the fish!');
  WriteLn('DMA proxy test complete');
end.