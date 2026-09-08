{$MODE DELPHIUNICODE}
unit HygrometerRestServer;

interface

uses
  mormot.core.base,  mormot.core.data,  mormot.core.os,  mormot.core.log,  mormot.core.text,  mormot.core.json,
  mormot.core.search,  mormot.core.buffers,  mormot.core.unicode,  mormot.crypt.secure,  mormot.orm.base,  mormot.orm.core,
  mormot.rest.core,  mormot.rest.server,  mormot.rest.http.server,  mormot.rest.memserver, 
  Instruction, HygrometerData, Resolution, RxChannel, TxChannel;

type
  THygrometerRestServer = class(TRestServerFullMemory)
  published
    procedure get_data(pmCtxt: TRestServerUriContext);
    procedure set_resolution(pmCtxt: TRestServerUriContext);
    //procedure SetDisplay(pmCtxt: TRestServerUriContext);
    //procedure SetResolution(pmCtxt: TRestServerUriContext);
  end;

implementation

procedure THygrometerRestServer.get_data(pmCtxt: TRestServerUriContext);
var
  LInstruction: TInstruction;
  LHygrometerData: THygrometerData;
  data_read: Cardinal;
begin
  if (pmCtxt.Method <> mGET) then
  begin
     pmCtxt.Error(StringToUtf8('Only http GET allowed'), HTTP_BADREQUEST);
  end;

  LInstruction := TInstruction.Create(itFetch, 0);
  try
    SendData(LInstruction.GetInstruction);
  finally
    LInstruction.Free;
  end;

  data_read := ReadData;
  LHygrometerData := THygrometerData.Create(data_read);
  try
    pmCtxt.Returns(LHygrometerData.ToJson, HTTP_SUCCESS);
  finally
    LHygrometerData.Free;    
  end;
end;

procedure THygrometerRestServer.set_resolution(pmCtxt: TRestServerUriContext);
var
  LInstruction: TInstruction;
  LResolution: TResolution;
  json_data_in: String;
begin
  if (pmCtxt.Method <> mPOST) then
  begin
     pmCtxt.Error(StringToUtf8('Only http GET allowed'), HTTP_BADREQUEST);
     EXIT;
  end;

  json_data_in := pmCtxt.Call.InBody;
  LResolution := TResolution.FromJson(json_data_in);
  if (nil = LResolution) then
  begin
    pmCtxt.Error(StringToUtf8('Invalid Json'), HTTP_BADREQUEST);
    EXIT;
  end;

  try
    LInstruction := TInstruction.Create(itSetResolution, LResolution.GetResolution);
    try
      SendData(LInstruction.GetInstruction)
    finally
      LInstruction.Free;
    end;
    pmCtxt.Success;
  finally
    LResolution.Free;
  end;
end;

end.