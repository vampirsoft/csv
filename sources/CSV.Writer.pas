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
  
{ TCSVWriter }

  TCSVWriter = class sealed
  public type
    TRow = class
    strict private type
      TFieldsEnumerator = class(TInterfacedObject, IEnumerator<string>)
      strict private
        FIndex: Integer;
        [Weak] FCSVRow: TRow;

      private
        function GetCurrentGen: string; inline;

      public
        constructor Create(const CSVRow: TRow); reintroduce;

      public
        function IEnumerator<string>.GetCurrent = GetCurrentGen;
        function GetCurrent: TObject; inline;
        function MoveNext: Boolean; inline;
        procedure Reset; inline;
      end;

    strict private
      procedure SetField(Index: Integer; const Value: string); overload;
      procedure SetField(ColumnName: string; const Value: string); overload;

    private
      FFields: TDictionary<string, string>;
      FCSVWriter: TCSVWriter;
      function ToArray: TArray<string>; inline;

    private
      constructor Create(const CSVWriter: TCSVWriter); reintroduce;

    public
      destructor Destroy; override;

    public
      function ToString: string; override;

    public
      property FieldByIndex[Index: Integer]: string write SetField; default;
      property Field[ColumnName: string]: string write SetField;
    end;

  strict private
    FDelimiter: Char;
    function GetCaseSensitive: Boolean; inline;

  private
    FColumns: TStringList;
    FCSVRows: TObjectList<TRow>;

  public
    constructor Create(const Delimiter: Char = ','; const CaseSensitive: Boolean = false); reintroduce;
    destructor Destroy; override;

  public
    function AddRow: TRow; inline;
    procedure AddColumn(const ColumnName: string); inline;

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

function TCSVWriter.AddRow: TRow;
begin
  Result := TRow.Create(Self);
  FCSVRows.Add(Result);
end;

constructor TCSVWriter.Create(const Delimiter: Char; const CaseSensitive: Boolean);
begin
  FDelimiter := Delimiter;
  
  FColumns := TStringList.Create(dupIgnore, False, CaseSensitive);
  FCSVRows := TObjectList<TRow>.Create;
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

function TCSVWriter.ToArray: TArray<TArray<string>>;
begin
  Result := [FColumns.ToStringArray];

  for var CSVRow in FCSVRows do
  begin    
    Result := Result + [CSVRow.ToArray];
  end;
end;

{ TCSVWriter.TRow }

constructor TCSVWriter.TRow.Create(const CSVWriter: TCSVWriter);
begin
  FCSVWriter := CSVWriter;

  FFields := TDictionary<string, string>.Create;
end;

destructor TCSVWriter.TRow.Destroy;
begin
  FreeAndNil(FFields);
end;

procedure TCSVWriter.TRow.SetField(ColumnName: string; const Value: string);
begin
  const Index = FCSVWriter.FColumns.IndexOf(ColumnName);
  if Index < 0 then FCSVWriter.AddColumn(ColumnName);

  FFields.AddOrSetValue(IfThenElse(FCSVWriter.CaseSensitive, ColumnName, ColumnName.ToLower), Value);
end;

procedure TCSVWriter.TRow.SetField(Index: Integer; const Value: string);
begin
  if (Index < 0) or (Index >= FCSVWriter.FColumns.Count) then
  begin
    raise ECSVException.Create('Index=' + Index.ToString + ' out of range=[0, ' + (FCSVWriter.FColumns.Count - 1).ToString + ']');
  end;

  const ColumnName = FCSVWriter.FColumns[Index];
  FFields.AddOrSetValue(IfThenElse(FCSVWriter.CaseSensitive, ColumnName, ColumnName.ToLower), Value);
end;

function TCSVWriter.TRow.ToArray: TArray<string>;
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

function TCSVWriter.TRow.ToString: string;
begin
  const Enumerator = TFieldsEnumerator.Create(Self);
  try
    Result := string.Join(FCSVWriter.Delimiter, Enumerator);
  finally
    FreeAndNil(Enumerator);
  end;
end;

{ TCSVWriter.TRow.TFieldsEnumerator }

constructor TCSVWriter.TRow.TFieldsEnumerator.Create(const CSVRow: TRow);
begin
  FCSVRow := CSVRow;

  FIndex := -1;
end;

function TCSVWriter.TRow.TFieldsEnumerator.GetCurrent: TObject;
begin
  Result := nil;
end;

function TCSVWriter.TRow.TFieldsEnumerator.GetCurrentGen: string;
begin
  var ColumnName := FCSVRow.FCSVWriter.FColumns[FIndex];
  ColumnName := IfThenElse(FCSVRow.FCSVWriter.CaseSensitive, ColumnName, ColumnName.ToLower);

  if not FCSVRow.FFields.TryGetValue(ColumnName, Result) then Result := '';
end;

function TCSVWriter.TRow.TFieldsEnumerator.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FCSVRow.FCSVWriter.FColumns.Count;
end;

procedure TCSVWriter.TRow.TFieldsEnumerator.Reset;
begin
  FIndex := -1;
end;

end.
