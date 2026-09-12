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
unit HygrometerRestServer;

interface

uses
  mormot.core.base,  mormot.core.data,  mormot.core.os,  mormot.core.log,  mormot.core.text,  mormot.core.json,
  mormot.core.search,  mormot.core.buffers,  mormot.core.unicode,  mormot.crypt.secure,  mormot.orm.base,  mormot.orm.core,
  mormot.rest.core,  mormot.rest.server,  mormot.rest.http.server,  mormot.rest.memserver, 
  Instruction, HygrometerData, Resolution, DisplaySetting, RxChannel, TxChannel;

type
  THygrometerRestServer = class(TRestServerFullMemory)
  published
    procedure get_data(pmCtxt: TRestServerUriContext);
    procedure set_resolution(pmCtxt: TRestServerUriContext);
    procedure set_display(pmCtxt: TRestServerUriContext);
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
  
  case LResolution.TemperatureResolution of
  tr11Bit: WriteLn('TemperatureResolution: 11 Bit');
  tr14Bit: WriteLn('TemperatureResolution: 14 Bit');
  else
    WriteLn('TemperatureResolution: Invalid');
  end;

  try
    case LResolution.HumidityResolution of
    hr8Bit: WriteLn('HumidityResolution:  8 Bit');
    hr11Bit: WriteLn('HumidityResolution: 11 Bit');
    hr14Bit: WriteLn('HumidityResolution: 14 Bit');
    else
      WriteLn('HumidityResolution: Invalid');
    end;
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

procedure THygrometerRestServer.set_display(pmCtxt: TRestServerUriContext);
var
  LInstruction: TInstruction;
  LDisplaySetting: TDisplaySetting;
  json_data_in: String;
begin
  if (pmCtxt.Method <> mPOST) then
  begin
     pmCtxt.Error(StringToUtf8('Only http GET allowed'), HTTP_BADREQUEST);
     EXIT;
  end;

  json_data_in := pmCtxt.Call.InBody;
  LDisplaySetting := TDisplaySetting.FromJson(json_data_in);
  if (nil = LDisplaySetting) then
  begin
    pmCtxt.Error(StringToUtf8('Invalid Json'), HTTP_BADREQUEST);
    EXIT;
  end;

  try
    case LDisplaySetting.DisplayResolution of
    drTemperature: WriteLn('DisplaySetting:  Temperature Resolution');
    drHumidity: WriteLn('DisplaySetting:  Humidity Resolution');
    else
      WriteLn('DisplaySetting: Invalid');
    end;

    LInstruction := TInstruction.Create(itSetDisplay, LDisplaySetting.GetDisplaySetting);
    try
      SendData(LInstruction.GetInstruction)
    finally
      LInstruction.Free;
    end;
    pmCtxt.Success;
  finally
    LDisplaySetting.Free;
  end;
end;

end.