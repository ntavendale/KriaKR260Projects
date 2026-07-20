{$MODE DELPHIUNICODE}
program dmaProxyTest;

uses
  SysUtils,
  Unix, 
  BaseUnix,
  DmaTypes in 'DmaTypes.pas',
  Utilities in 'Utilities.pas',
  TxChannel in 'TxChannel.pas';

procedure SigInt(AInput: Integer);
begin
	FStop := 1;
end;

begin
  FStop := 0;
  WriteLn('DMA Register consts for MM2S & S2MM');
end.

