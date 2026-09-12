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
unit HygrometerData;

interface

uses
  SysUtils, Classes, mormot.core.base,  mormot.core.text,  mormot.core.json;

type
  THygrometerData = class(TSynPersistent)
  private
    FTemperature: Single;
    FHumidity: Single;
  published  
    property Temperature: Single read FTemperature write FTemperature;
    property Humidity: Single read FHumidity write FHumidity;
  public
    constructor Create(ATemperatureHumidityData: Cardinal); reintroduce;
    constructor Create(ATemperatureData: Word; AHumidityData: Word); reintroduce;
    function ToJson: String;
    class function FromJson(const AJson: String): THygrometerData;
  end;

implementation

constructor THygrometerData.Create(ATemperatureHumidityData: Cardinal);
begin
  inherited Create;
  // Temperature is lower word
  FTemperature := (((ATemperatureHumidityData  shr 16) / 65536.0) * 165.0) - 40.0;
  // Humidity is upper word
  FHumidity := ((ATemperatureHumidityData and $0000FFFF) / 65536.0) * 100.0
end;

constructor THygrometerData.Create(ATemperatureData: Word; AHumidityData: Word);
begin
  inherited Create;
  FTemperature := ((ATemperatureData / 65536.0) * 165.0) - 40.0;
  FHumidity := (AHumidityData / 65536.0) * 100.0
end;

function THygrometerData.ToJson: String;
begin
  Result := ObjectToJson(self);
end;

class function THygrometerData.FromJson(const AJson: String): THygrometerData;
begin
  Result := THygrometerData.Create(0);
  if not ObjectLoadJson(result, RawUtf8(AJson)) then
  begin
    Result.Free;
    Result := nil;
  end;
end;

end.