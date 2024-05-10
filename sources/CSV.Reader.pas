/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : csv                                                        *//
//* Latest Source: https://github.com/vampirsoft/csv                          *//
//* Unit Name    : CSV.Reader.pas                                             *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

unit CSV.Reader;

{$INCLUDE CSV.inc}

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  {$IFDEF USE_QUICK_LIB}Quick.Arrays{$ELSE}Utils.ExtArray{$ENDIF},
  CSV.Common;

type
  TCSVReader = class;

{ TCSVRow }

  TCSVRow = class sealed
  public type
    TField = record
    strict private
      FHasValue: Boolean;
      FValue: string;

    private
      constructor Create(const Value: string; const HasValue: Boolean); reintroduce;

    public
      function AsString: string; overload; inline;
      function AsInteger: Integer; overload; inline;
      function AsInteger(const Default: Integer): Integer; overload; inline;
      function AsInt64: Int64; overload; inline;
      function AsInt64(const Default: Int64): Int64; overload; inline;
      function AsFloat: Double; overload; inline;
      function AsFloat(const Default: Double): Double; overload; inline;
      function AsFloat(const Default: Double; const FormatSettings: TFormatSettings): Double; overload; inline;
      function AsDateTime: TDateTime; overload; inline;
      function AsDateTime(const Default: TDateTime): TDateTime; overload; inline;
      function AsDateTime(const Default: TDateTime; const FormatSettings: TFormatSettings): TDateTime; overload; inline;
      function AsBoolean: Boolean; overload; inline;
      function AsBoolean(const Default: Boolean): Boolean; overload; inline;

    public
      property HasValue: Boolean read FHasValue;
    end;

  strict private
    FFields: TArray<string>;
    FCSVReader: TCSVReader;
    function GetField(Index: Integer): TField; overload;
    function GetField(ColumnName: string): TField; overload; inline;

  private
    constructor Create(const CSVReader: TCSVReader; const Fields: TArray<string>); reintroduce;

  public
    function ToString: string; override;

  public
    property FieldByIndex[Index: Integer]: TField read GetField; default;
    property Field[ColumnName: string]: TField read GetField;
  end;

{ TCSVReader }

  TCSVReader = class sealed(TEnumerable<TCSVRow>)
  strict private
    FDelimiter: Char;
    FCaseSensitive: Boolean;

  private
    FColumns: TXArray<string>;

  strict private type
    TCSVRowEnumerator = class(TEnumerator<TCSVRow>)
    strict private
      FIndex: Integer;
      FCSVReader: TCSVReader;

    strict protected
      function DoGetCurrent: TCSVRow; override;
      function DoMoveNext: Boolean; override;

    public
      constructor Create(const CSVReader: TCSVReader);
    end;

  strict protected
    FCSVRows: TObjectList<TCSVRow>;
    function DoGetEnumerator: TEnumerator<TCSVRow>; override;

  public
    constructor Create(const Strings: TStrings; const Delimiter: Char = ','; const CaseSensitive: Boolean = false);
      reintroduce; overload;
    constructor Create(const Strings: TArray<string>; const Delimiter: Char = ',';
      const CaseSensitive: Boolean = false); reintroduce; overload;
    destructor Destroy; override;

  public
    property Delimiter: Char read FDelimiter;
    property CaseSensitive: Boolean read FCaseSensitive;
  end;

implementation

{ TCSVRow }

constructor TCSVRow.Create(const CSVReader: TCSVReader; const Fields: TArray<string>);
begin
  FCSVReader := CSVReader;
  FFields := Fields;
end;

function TCSVRow.GetField(Index: Integer): TField;
begin
  if (Index < 0) or (Index >= FCSVReader.FColumns.Count) then
  begin
    raise ECSVException.Create('Index=' + Index.ToString + ' out of range=[0, ' + (FCSVReader.FColumns.Count - 1).ToString + ']');
  end;

  if Index > High(FFields) then Exit(TField.Create('', False));
  Result := TField.Create(FFields[Index], True);
end;

function TCSVRow.GetField(ColumnName: string): TField;
begin
  ColumnName := IfThenElse(FCSVReader.CaseSensitive, ColumnName, ColumnName.ToLower);
  const ColumnIndex = FCSVReader.FColumns.IndexOf(ColumnName);
  Result := GetField(ColumnIndex);
end;

function TCSVRow.ToString: string;
begin
  Result := string.Join(FCSVReader.Delimiter, FFields);
end;

{ TCSVRow.TField }

constructor TCSVRow.TField.Create(const Value: string; const HasValue: Boolean);
begin
  FValue    := Value;
  FHasValue := HasValue;
end;

function TCSVRow.TField.AsBoolean(const Default: Boolean): Boolean;
begin
  if not Boolean.TryToParse(FValue, Result) then Result := Default;
end;

function TCSVRow.TField.AsBoolean: Boolean;
begin
  Result := Boolean.Parse(FValue);
end;

function TCSVRow.TField.AsDateTime: TDateTime;
begin
  Result := StrToDateTime(FValue);
end;

function TCSVRow.TField.AsDateTime(const Default: TDateTime; const FormatSettings: TFormatSettings): TDateTime;
begin
  if not TryStrToDateTime(FValue, Result, FormatSettings) then Result := Default;
end;

function TCSVRow.TField.AsDateTime(const Default: TDateTime): TDateTime;
begin
  if not TryStrToDateTime(FValue, Result) then Result := Default;
end;

function TCSVRow.TField.AsFloat(const Default: Double): Double;
begin
  if not Double.TryParse(FValue, Result) then Result := Default;
end;

function TCSVRow.TField.AsFloat: Double;
begin
  Result := FValue.ToDouble;
end;

function TCSVRow.TField.AsFloat(const Default: Double; const FormatSettings: TFormatSettings): Double;
begin
  if not Double.TryParse(FValue, Result, FormatSettings) then Result := Default;
end;

function TCSVRow.TField.AsInt64(const Default: Int64): Int64;
begin
  if not Int64.TryParse(FValue, Result) then Result := Default;
end;

function TCSVRow.TField.AsInt64: Int64;
begin
  Result := FValue.ToInt64;
end;

function TCSVRow.TField.AsInteger(const Default: Integer): Integer;
begin
  if not Integer.TryParse(FValue, Result) then Result := Default;
end;

function TCSVRow.TField.AsInteger: Integer;
begin
  Result := FValue.ToInteger;
end;

function TCSVRow.TField.AsString: string;
begin
  Result := FValue;
end;

{ TCSVReader }

constructor TCSVReader.Create(const Strings: TStrings; const Delimiter: Char; const CaseSensitive: Boolean);
begin
  Create(Strings.ToStringArray, Delimiter, CaseSensitive);
end;

constructor TCSVReader.Create(const Strings: TArray<string>; const Delimiter: Char; const CaseSensitive: Boolean);
begin
  FDelimiter     := Delimiter;
  FCaseSensitive := CaseSensitive;
  
  if Length(Strings) > 0 then
  begin
    var Columns := Strings[0];
    Columns := IfThenElse(CaseSensitive, Columns, Columns.ToLower);
    FColumns := Columns.Split(Delimiter);
  end;
  
  FCSVRows := TObjectList<TCSVRow>.Create;
  for var Index := 1 to Length(Strings) - 1 do
  begin
    const Row = Strings[Index];
    FCSVRows.Add(TCSVRow.Create(Self, Row.Split(Delimiter)));
  end;
end;

destructor TCSVReader.Destroy;
begin
  FreeAndNil(FCSVRows);
end;

function TCSVReader.DoGetEnumerator: TEnumerator<TCSVRow>;
begin
  Result := TCSVRowEnumerator.Create(Self);
end;

{ TCSVReader.TCSVRowEnumerator }

constructor TCSVReader.TCSVRowEnumerator.Create(const CSVReader: TCSVReader);
begin
  FCSVReader := CSVReader;
  FIndex := -1;
end;

function TCSVReader.TCSVRowEnumerator.DoGetCurrent: TCSVRow;
begin
  Result := FCSVReader.FCSVRows[FIndex];
end;

function TCSVReader.TCSVRowEnumerator.DoMoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FCSVReader.FCSVRows.Count;
end;

end.
