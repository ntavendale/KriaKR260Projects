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
unit DisplaySetting;

interface

uses
  SysUtils,
  mormot.core.base,
  mormot.core.text,
  mormot.core.json;

type
  TDisplayResolution = (drTemperature, drHumidity);
  TDisplaySetting = class(TSynPersistent)
  private
    FDisplayResolution: TDisplayResolution;
  published
    property DisplayResolution: TDisplayResolution read FDisplayResolution write FDisplayResolution;
  public
    constructor Create(ADisplayResolution: TDisplayResolution); reintroduce;
    function GetDisplaySetting: Cardinal;
    function ToJson: String;
    class function FromJson(const AJson: String): TDisplaySetting;
  end;

implementation

constructor TDisplaySetting.Create(ADisplayResolution: TDisplayResolution);
begin
  inherited Create;
  FDisplayResolution := ADisplayResolution;
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
  Result := ObjectToJson(self);
end;

class function TDisplaySetting.FromJson(const AJson: String): TDisplaySetting;
begin
  Result := TDisplaySetting.Create(drTemperature);
  if not ObjectLoadJson(result, RawUtf8(AJson)) then
  begin
    Result.Free;
    Result := nil;
  end;
end;

end.
