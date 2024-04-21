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
  CSV.Common;

type
  ECSVException = CSV.Common.ECSVException;
  
  TCSVReader = class;

{ TCSVRow }

  TCSVRow = class sealed
  strict private
    FFields: TArray<string>;
    FCSVReader: TCSVReader;
    function GetField(Index: Integer): string; overload;
    function GetField(ColumnName: string): string; overload;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
  private
    constructor Create(const CSVReader: TCSVReader; const Fields: TArray<string>);
  public
    function ToString: string; override;
  public
    property FieldByIndex[Index: Integer]: string read GetField; default;
    property Field[ColumnName: string]: string read GetField;
  end;

{ TCSVReader }

  TCSVReader = class sealed(TEnumerable<TCSVRow>)
  strict private
    FDelimiter: Char;
    FCaseSensitive: Boolean;
  private
    FColumns: TList<string>;
    class function IfThenElse<T>(const Condition: Boolean; const ThenValue, ElseValue: T): T; static;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
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

function TCSVRow.GetField(Index: Integer): string;
begin
  if (Index < Low(FFields)) or (Index > High(FFields)) then
  begin
    raise ECSVException.Create('Index=' + Index.ToString + ' out of range=[' + Low(FFields).ToString + ', ' + High(FFields).ToString + ']');
  end;
  
  Result := FFields[Index];
end;

function TCSVRow.GetField(ColumnName: string): string;
begin
  ColumnName := TCSVReader.IfThenElse(FCSVReader.CaseSensitive, ColumnName, ColumnName.ToLower);
  const ColumnIndex = FCSVReader.FColumns.IndexOf(ColumnName);
  Result := GetField(ColumnIndex);
end;

function TCSVRow.ToString: string;
begin
  Result := string.Join(FCSVReader.Delimiter, FFields);
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
  
  if Length(Strings) = 0 then
  begin
    FColumns := TList<string>.Create;
  end else
  begin
    var Columns := Strings[0];
    Columns := TCSVReader.IfThenElse(CaseSensitive, Columns, Columns.ToLower);
    FColumns := TList<string>.Create(Columns.Split(Delimiter));
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
  FreeAndNil(FColumns);
end;

function TCSVReader.DoGetEnumerator: TEnumerator<TCSVRow>;
begin
  Result := TCSVRowEnumerator.Create(Self);
end;

class function TCSVReader.IfThenElse<T>(const Condition: Boolean; const ThenValue, ElseValue: T): T;
begin
  if Condition then Exit(ThenValue);
  Result := ElseValue;
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
