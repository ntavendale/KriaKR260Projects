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
  published
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