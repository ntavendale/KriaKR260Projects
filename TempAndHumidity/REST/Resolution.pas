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
unit Resolution;

interface

uses
  SysUtils,
  mormot.core.base,
  mormot.core.text,
  mormot.core.json;

type
  TTemperatureResolution = (tr14Bit, tr11Bit);
  THumidityResolution = (hr14Bit, hr11Bit, hr8Bit);
  TResolution = class(TSynPersistent)
  private
    FTemperatureResolution: TTemperatureResolution;
    FHumidityResolution: THumidityResolution;
  published
    property TemperatureResolution: TTemperatureResolution read FTemperatureResolution write FTemperatureResolution;
    property HumidityResolution: THumidityResolution read FHumidityResolution write FHumidityResolution;
  public
    constructor Create(ATemperatureResolution: TTemperatureResolution; AHumidityResolution: THumidityResolution); reintroduce;
    function GetResolution: Cardinal;
    function ToJson: String;
    class function FromJson(const AJson: String): TResolution;
  end;

implementation

constructor TResolution.Create(ATemperatureResolution: TTemperatureResolution; AHumidityResolution: THumidityResolution);
begin
  inherited Create;
  FTemperatureResolution := ATemperatureResolution;
  FHumidityResolution := AHumidityResolution;
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
  Result := ObjectToJson(self);
end;

class function TResolution.FromJson(const AJson: String): TResolution;
begin
  Result := TResolution.Create(tr14Bit, hr14Bit);
  if not ObjectLoadJson(result, RawUtf8(AJson)) then
  begin
    Result.Free;
    Result := nil;
  end;
end;

end.
