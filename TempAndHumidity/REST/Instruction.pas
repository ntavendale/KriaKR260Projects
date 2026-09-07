{$MODE DELPHIUNICODE}

unit Instruction;

interface

uses
  SysUtils,
  mormot.core.base,
  mormot.core.text,
  mormot.core.json;

type
  TInstructionType = (itFetch, itSetResolution, itSetDisplay);
  TInstruction = class(TSynPersistent)
  private
    FInstructionType: TInstructionType;
    FInstructionData: Cardinal;
  published
    property InstructionType: TInstructionType read FInstructionType write FInstructionType;
    property InstructionData: Cardinal read FInstructionData write FInstructionData;
  public
    constructor Create(AType: TInstructionType; AData: Cardinal); reintroduce;
    function GetInstruction: Cardinal;
    function ToJson: String;
    class function FromJson(const AJson: String): TInstruction;
  end;

implementation

constructor TInstruction.Create(AType: TInstructionType; AData: Cardinal);
begin
  inherited Create;
  FInstructionType := AType;
  FInstructionData := AData;
end;

function TInstruction.GetInstruction: Cardinal;
begin
  case FInstructionType of
    itFetch: Result := (FInstructionData and $00FFFFFF);
    itSetResolution: Result := (FInstructionData and $00FFFFFF) or $01000000;
    itSetDisplay: Result := (FInstructionData and $00FFFFFF) or $02000000;
  else
    raise Exception.Create(Format('Invalid instruction type %d', [Ord(FInstructionType)]));
  end;
end;

function TInstruction.ToJson: String;
begin
  Result := ObjectToJson(self);
end;

class function TInstruction.FromJson(const AJson: String): TInstruction;
begin
  Result := TInstruction.Create(itFetch, 0);
  if not ObjectLoadJson(result, RawUtf8(AJson)) then
  begin
    Result.Free;
    Result := nil;
  end;
end;

end.
