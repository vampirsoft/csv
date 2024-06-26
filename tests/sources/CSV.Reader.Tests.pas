﻿/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : CryptoHash                                                 *//
//* Latest Source: https://github.com/vampirsoft/csv                          *//
//* Unit Name    : CSV.Reader.Tests                                           *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

unit CSV.Reader.Tests;

{$INCLUDE CSV.Tests.inc}

interface

uses
  DUnitX.TestFramework, System.Classes,
  CSV.Common, CSV.Reader;

type

{ TCSVReaderTests }

  [TestFixture]
  TCSVReaderTests = class
  strict private const
    FDelimiter = #9;
    
    FColumnOne = 'One column';
    FColumnTwo = 'Two column';
    FColumnFree = 'Tree column';

    FRowOneCellOne = 'Row one - cell one';
    FRowOneCellTwo = '';
    FRowOneCellTree = 'Row one - cell tree';

    FRowTwoCellOne = 'Row two - cell one';
    FRowTwoCellTwo = 'Row two - cell two';
    FRowTwoCellTree = '';

    FRowTreeCellOne = '';
    FRowTreeCellTwo = 'Row tree - cell two';
    FRowTreeCellTree = 'Row tree - cell tree';

  strict private
    FCSVReader: TCSVReader;

  public
    [Setup]
    procedure SetUp;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure get_all_rows_test;

    [Test]
    procedure raise_exceptionon_on_get_field_if_column_not_found_test;
    [Test]
    procedure raise_exceptionon_on_get_field_if_index_not_found_test;

    [Test]
    procedure search_should_return_nil_if_not_found_row_test;
    [Test]
    procedure search_should_return_row_if_row_exists_test;

    [Test]
    procedure binary_search_should_return_nil_if_not_found_row_test;
    [Test]
    procedure binary_search_should_return_nil_if_row_exists_test;
  end;

implementation

uses
  System.SysUtils, System.Generics.Defaults, System.Generics.Collections,
  CSV.Reader.Helpers;

{ TCSVReaderTests }

procedure TCSVReaderTests.binary_search_should_return_nil_if_not_found_row_test;
begin
  const Comparer = TComparer<string>.Default;

  FCSVReader.Sort(
    TComparer<TCSVRow>.Construct(
      function(const Left, Right: TCSVRow): Integer
      begin
        Result := Comparer.Compare(Left.Field[FColumnOne].AsString, Right.Field[FColumnOne].AsString);
      end
    )
  );

  const ActualCSVRow = FCSVReader.BinarySearch(
    function(const CSVRow: TCSVRow): Integer
    begin
      Result := Comparer.Compare(CSVRow.Field[FColumnOne].AsString, FRowTreeCellTree);
    end
  );

  Assert.IsNull(ActualCSVRow);
end;

procedure TCSVReaderTests.binary_search_should_return_nil_if_row_exists_test;
begin
  const Comparer = TComparer<string>.Default;

  FCSVReader.Sort(
    TComparer<TCSVRow>.Construct(
      function(const Left, Right: TCSVRow): Integer
      begin
        Result := Comparer.Compare(Left.Field[FColumnOne].AsString, Right.Field[FColumnOne].AsString);
      end
    )
  );

  const ActualCSVRow = FCSVReader.BinarySearch(
    function(const CSVRow: TCSVRow): Integer
    begin
      Result := Comparer.Compare(CSVRow.Field[FColumnOne].AsString, FRowTwoCellOne);
    end
  );

   Assert.AreEqual(ActualCSVRow.Field[FColumnOne].AsString, FRowTwoCellOne);
end;

procedure TCSVReaderTests.get_all_rows_test;
begin
  const ExpectColumnOne: TArray<string> = [FRowOneCellOne, FRowTwoCellOne, FRowTreeCellOne];
  const ExpectColumnTwo: TArray<string> = [FRowOneCellTwo, FRowTwoCellTwo, FRowTreeCellTwo];
  const ExpectColumnTree: TArray<string> = [FRowOneCellTree, FRowTwoCellTree, FRowTreeCellTree];
  
  var Index := 0;
  for var CSVRow in FCSVReader do
  begin
    var ActualField := CSVRow.Field[FColumnTwo.ToUpper].AsString;
     Assert.AreEqual(ExpectColumnTwo[Index], ActualField);

    ActualField := CSVRow.Field[FColumnFree].AsString;
     Assert.AreEqual(ExpectColumnTree[Index], ActualField);
    
    ActualField := CSVRow.Field[FColumnOne.ToLower].AsString;
     Assert.AreEqual(ExpectColumnOne[Index], ActualField);
    
    Inc(Index);
  end;
end;

procedure TCSVReaderTests.raise_exceptionon_on_get_field_if_column_not_found_test;
begin
  Assert.WillRaise(
    procedure
    begin
      for var CSVRow in FCSVReader do
      begin
        const ActualField = CSVRow.Field['Invalid column'];
      end;
    end,
    ECSVException
  );
end;

procedure TCSVReaderTests.raise_exceptionon_on_get_field_if_index_not_found_test;
begin
  Assert.WillRaise(
    procedure
    begin
      for var CSVRow in FCSVReader do
      begin
        const ActualField = CSVRow[3];
      end;
    end,
    ECSVException
  );
end;

procedure TCSVReaderTests.search_should_return_nil_if_not_found_row_test;
begin
  const ActualCSVRow = FCSVReader.Search(
    function(const CSVRow: TCSVRow): Boolean
    begin
      Result := CSVRow.Field[FColumnTwo].AsString = FRowTreeCellTree;
    end
  );

  Assert.IsNull(ActualCSVRow);
end;

procedure TCSVReaderTests.search_should_return_row_if_row_exists_test;
begin
  const ActualCSVRow = FCSVReader.Search(
    function(const CSVRow: TCSVRow): Boolean
    begin
      Result := CSVRow.Field[FColumnTwo].AsString = FRowTwoCellTwo;
    end
  );

   Assert.AreEqual(ActualCSVRow.Field[FColumnTwo].AsString, FRowTwoCellTwo);
end;

procedure TCSVReaderTests.SetUp;
begin
  const Strings = TStringList.Create;
  Strings.Add(string.Join(FDelimiter, [FColumnOne,      FColumnTwo,      FColumnFree]));
  Strings.Add(string.Join(FDelimiter, [FRowOneCellOne,  FRowOneCellTwo,  FRowOneCellTree]));
  Strings.Add(string.Join(FDelimiter, [FRowTwoCellOne,  FRowTwoCellTwo,  FRowTwoCellTree]));
  Strings.Add(string.Join(FDelimiter, [FRowTreeCellOne, FRowTreeCellTwo, FRowTreeCellTree]));

  FCSVReader := TCSVReader.Create(Strings, FDelimiter);

  FreeAndNil(Strings);
end;

procedure TCSVReaderTests.TearDown;
begin
  FreeAndNil(FCSVReader);
end;

initialization
  TDUnitX.RegisterTestFixture(TCSVReaderTests);
  
end.
