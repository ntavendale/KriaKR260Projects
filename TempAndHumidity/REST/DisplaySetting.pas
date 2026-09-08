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
