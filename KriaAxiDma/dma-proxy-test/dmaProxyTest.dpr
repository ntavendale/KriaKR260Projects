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
	Halt;
end;

begin
  WriteLn('DMA Register consts for MM2S & S2MM');
end.

