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
  FTemperature := (((ATemperatureHumidityData and $0000FFFF) / 65536.0) * 165.0) - 40.0;
  // Humidity is upper word
  FHumidity := ((ATemperatureHumidityData shr 16) / 65536.0) * 100.0
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