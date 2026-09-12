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
