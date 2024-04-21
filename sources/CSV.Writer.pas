/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : csv                                                        *//
//* Latest Source: https://github.com/vampirsoft/csv                          *//
//* Unit Name    : CSV.Writer.pas                                             *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

unit CSV.Writer;

{$INCLUDE CSV.inc}

interface

uses
  System.Classes, System.Generics.Collections,
  CSV.Common;
  
type
  ECSVException = CSV.Common.ECSVException;
  
{ TCSVWriter }

  TCSVWriter = class sealed
  strict private type
    TCSVRow = class
    strict private type
      TFieldsEnumerator = class(TInterfacedObject, IEnumerator<string>)
      strict private
        FIndex: Integer;
        [Weak] FCSVRow: TCSVRow;
      public
        constructor Create(const CSVRow: TCSVRow); reintroduce;
      public
        function GetCurrentGen: string;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
        function IEnumerator<string>.GetCurrent = GetCurrentGen;
        function GetCurrent: TObject;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
        function MoveNext: Boolean;
        procedure Reset;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
      end;

    strict private
      procedure SetField(Index: Integer; const Value: string); overload;
      procedure SetField(ColumnName: string; const Value: string); overload;
    private
      FFields: TDictionary<string, string>;
      FCSVWriter: TCSVWriter;
      function ToArray: TArray<string>;
    public
      constructor Create(const CSVWriter: TCSVWriter); reintroduce;
      destructor Destroy; override;
    public
      function ToString: string; override;
    public
      property FieldByIndex[Index: Integer]: string write SetField; default;
      property Field[ColumnName: string]: string write SetField;
    end;

  strict private
    FDelimiter: Char;
    function GetCaseSensitive: Boolean;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
  private
    FColumns: TStringList;
    FCSVRows: TObjectList<TCSVRow>;
    class function IfThenElse<T>(const Condition: Boolean; const ThenValue, ElseValue: T): T; static;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
  public
    constructor Create(const Delimiter: Char = ','; const CaseSensitive: Boolean = false); reintroduce;
    destructor Destroy; override;
  public
    function AddRow: TCSVRow;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
    procedure AddColumn(const ColumnName: string);{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
  public
    function ToArray: TArray<TArray<string>>;
  public
    property Delimiter: Char read FDelimiter;
    property CaseSensitive: Boolean read GetCaseSensitive;
  end;
  
implementation

uses
  System.SysUtils;
  
{ TCSVWriter }

procedure TCSVWriter.AddColumn(const ColumnName: string);
begin
  FColumns.Add(ColumnName);
end;

function TCSVWriter.AddRow: TCSVRow;
begin
  Result := TCSVRow.Create(Self);
  FCSVRows.Add(Result);
end;

constructor TCSVWriter.Create(const Delimiter: Char; const CaseSensitive: Boolean);
begin
  FDelimiter := Delimiter;
  
  FColumns := TStringList.Create(dupIgnore, False, CaseSensitive);
  FCSVRows := TObjectList<TCSVRow>.Create;
end;

destructor TCSVWriter.Destroy;
begin
  FreeAndNil(FCSVRows);
  FreeAndNil(FColumns);
end;

function TCSVWriter.GetCaseSensitive: Boolean;
begin
  Result := FColumns.CaseSensitive;
end;

class function TCSVWriter.IfThenElse<T>(const Condition: Boolean; const ThenValue, ElseValue: T): T;
begin
  if Condition then Exit(ThenValue);
  Result := ElseValue;
end;

function TCSVWriter.ToArray: TArray<TArray<string>>;
begin
  Result := [FColumns.ToStringArray];

  for var CSVRow in FCSVRows do
  begin    
    Result := Result + [CSVRow.ToArray];
  end;
end;

{ TCSVWriter.TCSVRow }

constructor TCSVWriter.TCSVRow.Create(const CSVWriter: TCSVWriter);
begin
  FCSVWriter := CSVWriter;

  FFields := TDictionary<string, string>.Create;
end;

destructor TCSVWriter.TCSVRow.Destroy;
begin
  FreeAndNil(FFields);
end;

procedure TCSVWriter.TCSVRow.SetField(ColumnName: string; const Value: string);
begin
  const Index = FCSVWriter.FColumns.IndexOf(ColumnName);
  if Index < 0 then FCSVWriter.AddColumn(ColumnName);

  FFields.Add(TCSVWriter.IfThenElse(FCSVWriter.CaseSensitive, ColumnName, ColumnName.ToLower), Value);
end;

procedure TCSVWriter.TCSVRow.SetField(Index: Integer; const Value: string);
begin
  if (Index < 0) or (Index >= FCSVWriter.FColumns.Count) then
  begin
    raise ECSVException.Create('Index=' + Index.ToString + ' out of range=[0, ' + (FCSVWriter.FColumns.Count - 1).ToString + ']');
  end;

  const ColumnName = FCSVWriter.FColumns[Index];
  FFields.Add(TCSVWriter.IfThenElse(FCSVWriter.CaseSensitive, ColumnName, ColumnName.ToLower), Value);
end;

function TCSVWriter.TCSVRow.ToArray: TArray<string>;
begin
  Result := [];

  const Enumerator = TFieldsEnumerator.Create(Self);
  try
    while Enumerator.MoveNext do
    begin  
      Result := Result + [Enumerator.GetCurrentGen];
    end;
  finally
    FreeAndNil(Enumerator);
  end;
end;

function TCSVWriter.TCSVRow.ToString: string;
begin
  const Enumerator = TFieldsEnumerator.Create(Self);
  try
    Result := string.Join(FCSVWriter.Delimiter, Enumerator);
  finally
    FreeAndNil(Enumerator);
  end;
end;

{ TCSVWriter.TCSVRow.TFieldsEnumerator }

constructor TCSVWriter.TCSVRow.TFieldsEnumerator.Create(const CSVRow: TCSVRow);
begin
  FCSVRow := CSVRow;

  FIndex := -1;
end;

function TCSVWriter.TCSVRow.TFieldsEnumerator.GetCurrent: TObject;
begin
  Result := nil;
end;

function TCSVWriter.TCSVRow.TFieldsEnumerator.GetCurrentGen: string;
begin
  var ColumnName := FCSVRow.FCSVWriter.FColumns[FIndex];
  ColumnName := TCSVWriter.IfThenElse(FCSVRow.FCSVWriter.CaseSensitive, ColumnName, ColumnName.ToLower);

  if not FCSVRow.FFields.TryGetValue(ColumnName, Result) then Result := '';
end;

function TCSVWriter.TCSVRow.TFieldsEnumerator.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FCSVRow.FCSVWriter.FColumns.Count;
end;

procedure TCSVWriter.TCSVRow.TFieldsEnumerator.Reset;
begin
  FIndex := -1;
end;

end.
