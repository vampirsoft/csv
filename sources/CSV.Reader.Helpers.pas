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
  System.Generics.Defaults,
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

    procedure Sort; overload;
    procedure Sort(const Comparer: IComparer<TCSVRow>); overload;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
    procedure Sort(const Comparer: IComparer<TCSVRow>; const Index, Count: Integer); overload;{$IF DEFINED(USE_INLINE)}inline;{$ENDIF}
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

procedure TCSVReaderHelper.Sort;
begin
  FCSVRows.Sort(
    TComparer<TCSVRow>.Construct(
      function (const Left, Right: TCSVRow): Integer
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

procedure TCSVReaderHelper.Sort(const Comparer: IComparer<TCSVRow>; const Index, Count: Integer);
begin
  FCSVRows.Sort(Comparer, Index, Count);
end;

end.
