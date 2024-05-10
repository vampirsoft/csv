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
  System.SysUtils, System.Generics.Defaults, System.Generics.Collections,
  Utils.Arrays.Helper,
  CSV.Reader;

type

{ TCSVReaderHelper }

  TCSVReaderHelper = class helper for TCSVReader
  strict private type
    TSearchPredicate = TArray.TSearchPredicate<TCSVRow>;
    TBinarySearchComparer = TArray.TBinarySearchComparer<TCSVRow>;

  public
    function Search(const Predicate: TSearchPredicate): TCSVRow; overload; inline;
    function Search(const Predicate: TSearchPredicate; const StartIndex, Count: Integer): TCSVRow; overload; inline;

    procedure Sort; overload;
    procedure Sort(const Comparer: IComparer<TCSVRow>); overload; inline;
    procedure Sort(const Comparer: IComparer<TCSVRow>; const StartIndex, Count: Integer); overload; inline;

    function BinarySearch(const Compare: TBinarySearchComparer): TCSVRow; overload; inline;
    function BinarySearch(const Compare: TBinarySearchComparer;
      const StartIndex, Count: Integer): TCSVRow; overload; inline;
  end;

implementation

{ TCSVReaderHelper }

function TCSVReaderHelper.BinarySearch(const Compare: TBinarySearchComparer): TCSVRow;
begin
  Result := BinarySearch(Compare, 0, FCSVRows.Count);
end;

function TCSVReaderHelper.BinarySearch(const Compare: TBinarySearchComparer; const StartIndex, Count: Integer): TCSVRow;
var
  FoundIndex: Integer;

begin
  const CSVRows = FCSVRows.ToArray;
  if TArray.BinarySearch<TCSVRow>(CSVRows, Compare, FoundIndex, StartIndex, Count) then Exit(CSVRows[FoundIndex]);
  Result := nil;
end;

function TCSVReaderHelper.Search(const Predicate: TSearchPredicate): TCSVRow;
begin
  Result := Search(Predicate, 0, FCSVRows.Count);
end;

function TCSVReaderHelper.Search(const Predicate: TSearchPredicate; const StartIndex, Count: Integer): TCSVRow;
var
  FoundIndex: Integer;

begin
  const CSVRows = FCSVRows.ToArray;
  if TArray.Search<TCSVRow>(CSVRows, Predicate, FoundIndex, StartIndex, Count) then Exit(CSVRows[FoundIndex]);
  Result := nil;
end;

procedure TCSVReaderHelper.Sort;
begin
  const Comparer = TComparer<string>.Default;
  FCSVRows.Sort(
    TComparer<TCSVRow>.Construct(
      function(const Left, Right: TCSVRow): Integer
      begin
        Result := Comparer.Compare(Left.ToString, Right.ToString);
      end
    )
  );
end;

procedure TCSVReaderHelper.Sort(const Comparer: IComparer<TCSVRow>);
begin
  FCSVRows.Sort(Comparer);
end;

procedure TCSVReaderHelper.Sort(const Comparer: IComparer<TCSVRow>; const StartIndex, Count: Integer);
begin
  FCSVRows.Sort(Comparer, StartIndex, Count);
end;

end.
