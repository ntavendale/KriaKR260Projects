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
unit RestClasses;

interface

uses
  System.SysUtils, System.Classes, System.JSON, REST.Json;

type
  TDisplayResolution = (drTemperature, drHumidity);
  TTemperatureResolution = (tr14Bit, tr11Bit);
  THumidityResolution = (hr14Bit, hr11Bit, hr8Bit);

  THygrometerData = class
  private
    FTemperature: Single;
    FHumidity: Single;
  public
    constructor Create;
    function ToJson: String;
    class function FromJson(const AJson: String): THygrometerData;
    property Temperature: Single read FTemperature write FTemperature;
    property Humidity: Single read FHumidity write FHumidity;
  end;

  TResolution = class
  private
    FTemperatureResolution: TTemperatureResolution;
    FHumidityResolution: THumidityResolution;
  public
    constructor Create;
    function GetResolution: Cardinal;
    function ToJson: String;
    class function FromJson(const AJson: String): TResolution;
    property TemperatureResolution: TTemperatureResolution read FTemperatureResolution write FTemperatureResolution;
    property HumidityResolution: THumidityResolution read FHumidityResolution write FHumidityResolution;
  end;

  TDisplaySetting = class
  private
    FDisplayResolution: TDisplayResolution;
  public
    constructor Create;
    function GetDisplaySetting: Cardinal;
    function ToJson: String;
    class function FromJson(const AJson: String): TDisplaySetting;
    property DisplayResolution: TDisplayResolution read FDisplayResolution write FDisplayResolution;
  end;

implementation

constructor THygrometerData.Create;
begin
  FTemperature := 0.0;
  FHumidity := 0.0;
end;

function THygrometerData.ToJson: String;
begin
  var LJson := TJsonObject.Create;
  try
    LJson.AddPair('Temperature', TJsonNumber.Create(FTemperature));
    LJson.AddPair('Humidity', TJsonNumber.Create(FHumidity));
    Result := LJson.ToJSON;
  finally
    LJson.Free;
  end;
end;

class function THygrometerData.FromJson(const AJson: String): THygrometerData;
begin

  try
    Result := TJson.JsonToObject<THygrometerData>(AJson);
  except
    Result := nil;
  end;

  if nil = Result then
    raise Exception.Create(String.Format('Invalid json %s', [AJson]));
end;

constructor TResolution.Create;
begin
  FTemperatureResolution := tr14Bit;
  FHumidityResolution := hr14Bit;
end;

function TResolution.GetResolution: Cardinal;
var
  LResolutionData: Cardinal;
begin
  case FTemperatureResolution of
    tr11Bit: LResolutionData := 11;
  else
    LResolutionData := 14;
  end;
  case FHumidityResolution of
    hr8Bit: LResolutionData := (LResolutionData shl 8) or $00000008;
    hr11Bit: LResolutionData := (LResolutionData shl 8) or $0000000B;
  else
    LResolutionData := (LResolutionData shl 8) or $0000000E;
  end;
  Result := LResolutionData;
end;

function TResolution.ToJson: String;
begin
  var LJson := TJsonObject.Create;
  try
    LJson.AddPair('TemperatureResolution', TJsonNumber.Create(Ord(FTemperatureResolution)));
    LJson.AddPair('HumidityResolution', TJsonNumber.Create(Ord(FHumidityResolution)));
    Result := LJson.ToJSON;
  finally
    LJson.Free;
  end;
end;

class function TResolution.FromJson(const AJson: String): TResolution;
begin
  try
    Result := TJson.JsonToObject<TResolution>(AJson);
  except
    Result := nil;
  end;

  if nil = Result then
    raise Exception.Create(String.Format('Invalid json %s', [AJson]));
end;

constructor TDisplaySetting.Create;
begin
  FDisplayResolution := drTemperature;
end;

function TDisplaySetting.GetDisplaySetting: Cardinal;
begin
  case FDisplayResolution of
    drHumidity: Result := 1;
  else
    Result := 0;
  end;
end;

function TDisplaySetting.ToJson: String;
begin
  var LJson := TJsonObject.Create;
  try
    LJson.AddPair('DisplayResolution', TJsonNumber.Create(Ord(FDisplayResolution)));
    Result := LJson.ToJSON;
  finally
    LJson.Free;
  end;
end;

class function TDisplaySetting.FromJson(const AJson: String): TDisplaySetting;
begin
  try
    Result := TJson.JsonToObject<TDisplaySetting>(AJson);
  except
    Result := nil;
  end;

  if nil = Result then
    raise Exception.Create(String.Format('Invalid json %s', [AJson]));
end;

end.
