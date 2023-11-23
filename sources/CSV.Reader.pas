/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : csv                                                        *//
//* Latest Source: https://github.com/vampirsoft/csv                          *//
//* Unit Name    : CSV.Reader.pas                                             *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2023 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

unit CSV.Reader;

{$INCLUDE CSV.inc}

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections;

type
  ECSVException = class(Exception);
  
  TCSVReader = class;

{ TCSVRow }

  TCSVRow = class
  strict private
    FFields: TArray<string>;
    FReader: TCSVReader;
    function GetField(Index: Integer): string; overload;
    function GetField(ColumnName: string): string; overload;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
  private
    constructor Create(const Reader: TCSVReader; const Fields: TArray<string>);
  public
    property FieldByIndex[Index: Integer]: string read GetField;
    property Field[ColumnName: string]: string read GetField;
  end;

{ TCSVReader }

  TCSVReader = class(TEnumerable<TCSVRow>)
  strict private
    FDelimiter: Char;
    FCaseSensitive: Boolean;
  private
    FColumns: TList<string>;
    FRows: TObjectList<TCSVRow>;
    class function IfThenElse<T>(const Condition: Boolean; const ThenValue, ElseValue: T): T;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}static;
  strict private type
    TCSVRowEnumerator = class(TEnumerator<TCSVRow>)
    strict private
      FIndex: Integer;
      FReader: TCSVReader;
    strict protected
      function DoGetCurrent: TCSVRow; override;
      function DoMoveNext: Boolean; override;
    public
      constructor Create(const Reader: TCSVReader);
    end;
  strict protected
    function DoGetEnumerator: TEnumerator<TCSVRow>; override;
  public
    constructor Create(const Strings: TStrings; const Delimiter: Char = ','; const CaseSensitive: Boolean = false);
      reintroduce; overload;
    constructor Create(const Strings: TArray<string>; const Delimiter: Char = ',';
      const CaseSensitive: Boolean = false); reintroduce; overload;
    destructor Destroy; override;
    property Delimiter: Char read FDelimiter;
    property CaseSensitive: Boolean read FCaseSensitive;
  end;

implementation

{ TCSVRow }

constructor TCSVRow.Create(const Reader: TCSVReader; const Fields: TArray<string>);
begin
  FReader := Reader;
  FFields := Fields;
end;

function TCSVRow.GetField(Index: Integer): string;
begin
  if (Index < 0) or (Index >= Length(FFields)) then
  begin
    raise ECSVException.Create('Index=' + Index.ToString + ' out of range=[0, ' + (Length(FFields) - 1).ToString + ']');
  end;
  
  Result := FFields[Index];
end;

function TCSVRow.GetField(ColumnName: string): string;
begin
  ColumnName := TCSVReader.IfThenElse(FReader.CaseSensitive, ColumnName, ColumnName.ToLower);
  const ColumnIndex = FReader.FColumns.IndexOf(ColumnName);
  Result := GetField(ColumnIndex);
end;

{ TCSVReader }

constructor TCSVReader.Create(const Strings: TStrings; const Delimiter: Char; const CaseSensitive: Boolean);
begin
  Create(Strings.ToStringArray, Delimiter, CaseSensitive);
end;

constructor TCSVReader.Create(const Strings: TArray<string>; const Delimiter: Char; const CaseSensitive: Boolean);
begin
  FDelimiter := Delimiter;
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
  
  FRows := TObjectList<TCSVRow>.Create;
  for var Index := 1 to Length(Strings) - 1 do
  begin
    const Row = Strings[Index];
    FRows.Add(TCSVRow.Create(Self, Row.Split(Delimiter)));
  end;
end;

destructor TCSVReader.Destroy;
begin
  FreeAndNil(FRows);
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

constructor TCSVReader.TCSVRowEnumerator.Create(const Reader: TCSVReader);
begin
  FReader := Reader;
  FIndex := -1;
end;

function TCSVReader.TCSVRowEnumerator.DoGetCurrent: TCSVRow;
begin
  Result := FReader.FRows[FIndex];
end;

function TCSVReader.TCSVRowEnumerator.DoMoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FReader.FRows.Count;
end;

end.

