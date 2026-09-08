{$MODE DELPHIUNICODE}
unit HygrometerRestServer;

interface

uses
  mormot.core.base,  mormot.core.data,  mormot.core.os,  mormot.core.log,  mormot.core.text,  mormot.core.json,
  mormot.core.search,  mormot.core.buffers,  mormot.core.unicode,  mormot.crypt.secure,  mormot.orm.base,  mormot.orm.core,
  mormot.rest.core,  mormot.rest.server,  mormot.rest.http.server,  mormot.rest.memserver, 
  Instruction, HygrometerData, RxChannel;

type
  THygrometerRestServer = class(TRestServerFullMemory)
  published
    procedure get_data(pmCtxt: TRestServerUriContext);
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
    WriteLn('Instruction Type: ', LInstruction.InstructionType);
    WriteLn('Instruction Data: ', LInstruction.InstructionData);
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

end.