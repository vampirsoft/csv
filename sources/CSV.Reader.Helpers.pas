/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : csv                                                        *//
//* Latest Source: https://github.com/vampirsoft/csv                          *//
//* Unit Name    : CSV.Reader.Helpers.pas                                     *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

unit CSV.Reader.Helpers;

{$INCLUDE CSV.inc}

interface

uses
  CSV.Reader;

type

{ TCSVReaderHelper }

  TCSVReaderHelper = class helper for TCSVReader
  strict private type
    TSearchPredicate = reference to function(const CSVRow: TCSVRow): Boolean;
  public
    function Search(const Predicate: TSearchPredicate): TCSVRow; overload;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
    function Search(const Predicate: TSearchPredicate; out FoundIndex: Integer): TCSVRow; overload;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
    function Search(const Predicate: TSearchPredicate; out FoundIndex: Integer; const Index, Count: Integer): TCSVRow; overload;
  end;

implementation

uses
  System.SysUtils;

{ TCSVReaderHelper }

function TCSVReaderHelper.Search(const Predicate: TSearchPredicate): TCSVRow;
var
  FoundIndex: Integer;

begin
  Result := Search(Predicate, FoundIndex);
end;

function TCSVReaderHelper.Search(const Predicate: TSearchPredicate; out FoundIndex: Integer): TCSVRow;
begin
  Result := Search(Predicate, FoundIndex, 0, FCSVRows.Count);
end;

function TCSVReaderHelper.Search(const Predicate: TSearchPredicate; out FoundIndex: Integer; const Index,
  Count: Integer): TCSVRow;
begin
  if
    (Index < 0) or
    ((Index >= FCSVRows.Count) and (Count > 0)) or
    (Index + Count - 1 >= FCSVRows.Count) or
    (Count < 0) or
    (Index + Count < 0)
  then
  begin
    const H = (FCSVRows.Count - 1).ToString;
    raise ECSVException.Create('Index=' + Index.ToString + ' out of range=[0, ' + H + '] or Count=' + Count.ToString + ' out of range=[0, ' + H + ']');
  end;

  for var I := Index to Count - 1 do
  begin
    const CSVRow = FCSVRows[I];
    FoundIndex := I;
    if Predicate(CSVRow) then Exit(CSVRow);
  end;
  FoundIndex := -1;
  Result := nil;
end;

end.
