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
  System.SysUtils, System.Generics.Defaults,
  CSV.Reader;

type

{ TCSVReaderHelper }

  TCSVReaderHelper = class helper for TCSVReader
  strict private type
    TSearchPredicate = reference to function(const CSVRow: TCSVRow): Boolean;
    TBinarySearchComparer = reference to function(const CSVRow: TCSVRow): Integer;
  strict private
    procedure CheckIndexAndCount(const StartIndex, Count: Integer);{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
  public
    function Search(const Predicate: TSearchPredicate): TCSVRow; overload;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
    function Search(const Predicate: TSearchPredicate; out FoundIndex: Integer): TCSVRow; overload;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
    function Search(const Predicate: TSearchPredicate; out FoundIndex: Integer;
      const StartIndex, Count: Integer): TCSVRow; overload;

    procedure Sort; overload;
    procedure Sort(const Comparer: IComparer<TCSVRow>); overload;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
    procedure Sort(const Comparer: IComparer<TCSVRow>; const StartIndex, Count: Integer); overload;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}

    function BinarySearch(const Compare: TBinarySearchComparer): TCSVRow; overload;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
    function BinarySearch(const Compare: TBinarySearchComparer; out FoundIndex: Integer): TCSVRow; overload;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
    function BinarySearch(const Compare: TBinarySearchComparer; out FoundIndex: Integer;
      const StartIndex, Count: Integer): TCSVRow; overload;
  end;

implementation

{ TCSVReaderHelper }

function TCSVReaderHelper.BinarySearch(const Compare: TBinarySearchComparer): TCSVRow;
var
  FoundIndex: Integer;

begin
  Result := BinarySearch(Compare, FoundIndex);
end;

function TCSVReaderHelper.BinarySearch(const Compare: TBinarySearchComparer; out FoundIndex: Integer): TCSVRow;
begin
  Result := BinarySearch(Compare, FoundIndex, 0, FCSVRows.Count);
end;

function TCSVReaderHelper.BinarySearch(const Compare: TBinarySearchComparer; out FoundIndex: Integer;
  const StartIndex, Count: Integer): TCSVRow;
begin
  CheckIndexAndCount(StartIndex, Count);

  if Count = 0 then
  begin
    FoundIndex := -1;
    Exit(nil);
  end;

  var L := StartIndex;
  var H := StartIndex + Count - 1;
  while L <= H do
  begin
    var Mid := L + (H - L) shr 1;
    const Cmp = Compare(FCSVRows[Mid]);
    if Cmp < 0 then
      L := Mid + 1
    else if Cmp > 0 then
      H := Mid - 1
    else
    begin
      repeat
        Dec(Mid);
      until (Mid < StartIndex) or (Compare(FCSVRows[Mid]) <> 0);

      Inc(Mid);
      FoundIndex := Mid;
      Exit(FCSVRows[Mid]);
    end;
  end;

  FoundIndex := -1;
  Exit(nil);
end;

procedure TCSVReaderHelper.CheckIndexAndCount(const StartIndex, Count: Integer);
begin
  if
    (StartIndex < 0) or
    ((StartIndex >= FCSVRows.Count) and (Count > 0)) or
    (StartIndex + Count - 1 >= FCSVRows.Count) or
    (Count < 0) or
    (StartIndex + Count < 0)
  then
  begin
    const H = (FCSVRows.Count - 1).ToString;
    raise ECSVException.Create(
      'Index=' + StartIndex.ToString + ' out of range=[0, ' + H + '] or Count=' + Count.ToString + ' out of range=[0, ' + H + ']'
    );
  end;
end;

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

function TCSVReaderHelper.Search(const Predicate: TSearchPredicate; out FoundIndex: Integer; const StartIndex,
  Count: Integer): TCSVRow;
begin
  CheckIndexAndCount(StartIndex, Count);

  for var Index := StartIndex to Count - 1 do
  begin
    const CSVRow = FCSVRows[Index];
    FoundIndex := Index;
    if Predicate(CSVRow) then Exit(CSVRow);
  end;

  FoundIndex := -1;
  Result := nil;
end;

procedure TCSVReaderHelper.Sort;
begin
  FCSVRows.Sort(
    TComparer<TCSVRow>.Construct(
      function(const Left, Right: TCSVRow): Integer
      begin
        Result := TComparer<string>.Default.Compare(Left.ToString, Right.ToString);
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
