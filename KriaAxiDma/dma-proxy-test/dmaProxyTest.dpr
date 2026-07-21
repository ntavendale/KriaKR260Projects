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
	TUtilities.Stop := TRUE;
end;

procedure ShowUsage;
begin
  WriteLn('Usage:');
  WriteLn('  dmaProxyTest <# of DMA transfers to perform> <# of bytes in each transfer in KB (< 1MB)> <optional verify, 0 or 1>');
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
end.

