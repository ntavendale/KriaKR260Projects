// Copyright 2026 Nigel Tavendale
// Permission is hereby granted, free of charge, to any person obtaining a copy of this code
// associated documentation files (the "Code"), to deal in the Code without restriction, including
// without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Code, and to permit persons to whom the Code is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial
// portions of the Code.
//
// THE CODE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
// SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE CODE OR THE USE OR
// OTHER DEALINGS IN THE CODE.
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
  RestServerMain,
  mormot.core.base,
  mormot.core.os,
  mormot.core.log,
  mormot.orm.core,
  mormot.rest.http.server,
  DmaTypes in 'DmaTypes.pas',
  Utilities in 'Utilities.pas',
  TxChannel in 'TxChannel.pas',
  RxChannel in 'RxChannel.pas';

var
  KeepRunning: Boolean = TRUE;

procedure HandleSignal(Sig: LongInt); cdecl;
begin
  case Sig of
    SIGTERM, SIGINT: 
      begin
        // Set the flag to break the main loop
        KeepRunning := False;
      end;
  end;
end;  

var 
  LRestServerMain : TRestServerMain;
  NewAct, OldAct: SigActionRec;
begin
  
  FillChar(NewAct, SizeOf(NewAct), 0);
  NewAct.sa_Handler := @HandleSignal;
  fpSigEmptySet(NewAct.sa_Mask);
  NewAct.sa_Flags := 0;

  // Register handlers for termination signals
  fpSigAction(SIGTERM, @NewAct, @OldAct);
  fpSigAction(SIGINT,  @NewAct, @OldAct);

  writeln('Daemon started. Press Ctrl+C or use "kill" to stop.');

  KeepRunning := TRUE;
  LRestServerMain := TRestServerMain.Create;
  try
    try
      if LRestServerMain.RunServer('8080') then
      begin
        while KeepRunning do Sleep(1000);
      end else
        WriteLn('Something went wrong...');
    except
      on E: Exception do
      begin
        WriteLn(E.Message);
        ExitCode := 1;
      end;
    end;
    ConsoleWaitForEnterKey;
  finally
    LRestServerMain.Free;    
  end;
end.