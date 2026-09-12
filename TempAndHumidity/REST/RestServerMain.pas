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
unit RestServerMain;

interface

uses
  mormot.core.base,  mormot.core.data,  mormot.core.os,  mormot.core.log,  mormot.core.text,  mormot.core.json,
  mormot.core.search,  mormot.core.buffers,  mormot.core.unicode,  mormot.crypt.secure,  mormot.orm.base,  mormot.orm.core,
  mormot.rest.core,  mormot.rest.server,  mormot.rest.http.server,  mormot.rest.memserver, 
  Instruction, HygrometerData, HygrometerRestServer;

type
  TRestServerMain = class(TSynPersistent)
   private
    FHttpServer: TRestHttpServer;
    FRestServer: THygrometerRestServer;
  public
    constructor Create; override;
    destructor Destroy; override;
    function RunServer(const pmcPort: RawUtf8): Boolean;
  end;

implementation

constructor TRestServerMain.Create;
begin
  inherited Create;
  FHttpServer := nil;
  FRestServer := THygrometerRestServer.Create(TOrmModel.Create([], 'api'));
end;

destructor TRestServerMain.Destroy;
begin
  if (nil <> FHttpServer) then
  begin
    FHttpServer.Free;
    FHttpServer := nil;
  end;  
  FRestServer.Free;
  inherited Destroy;
end;

function TRestServerMain.RunServer(const pmcPort: RawUtf8): Boolean;
begin
  Result := False;
  if (FHttpServer = nil) then
  begin
    WriteLn('Create Rest server');
    FHttpServer := TRestHttpServer.Create(pmcPort, [FRestServer], '+' {DomainName}, useHttpSocket {or useHttpAsync});
    WriteLn('Set Origin');
    FHttpServer.AccessControlAllowOrigin := '*';
    Result := True;
  end else WriteLn('Not nil');
end;

end.