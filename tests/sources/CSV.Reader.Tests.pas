/////////////////////////////////////////////////////////////////////////////////
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
  TestFramework, System.Classes,
  CSV.Reader;

type

{ TCSVReaderTests }

  TCSVReaderTests = class(TTestCase)
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
    FStrings: TStrings;
    FCSVReader: TCSVReader;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure get_all_rows_test;

    procedure raise_exceptionon_on_get_field_if_column_not_found_test;
    procedure raise_exceptionon_on_get_field_if_index_not_found_test;

    procedure search_should_return_nil_if_not_found_row_test;
    procedure search_should_return_row_if_row_exists_test;
  end;

implementation

uses
  System.SysUtils, System.Generics.Collections,
  CSV.Reader.Helpers;

{ TCSVReaderTests }

procedure TCSVReaderTests.get_all_rows_test;
begin
  const ExpectColumnOne: TArray<string> = [FRowOneCellOne, FRowTwoCellOne, FRowTreeCellOne];
  const ExpectColumnTwo: TArray<string> = [FRowOneCellTwo, FRowTwoCellTwo, FRowTreeCellTwo];
  const ExpectColumnTree: TArray<string> = [FRowOneCellTree, FRowTwoCellTree, FRowTreeCellTree];

  
  var Index := 0;
  for var CSVRow in FCSVReader do
  begin
    var ActualField := CSVRow.Field[FColumnTwo.ToUpper];
    CheckEquals(ExpectColumnTwo[Index], ActualField);

    ActualField := CSVRow.Field[FColumnFree];
    CheckEquals(ExpectColumnTree[Index], ActualField);
    
    ActualField := CSVRow.Field[FColumnOne.ToLower];
    CheckEquals(ExpectColumnOne[Index], ActualField);
    
    Inc(Index);
  end;
end;

procedure TCSVReaderTests.raise_exceptionon_on_get_field_if_column_not_found_test;
begin
  ExpectedException := ECSVException;

  for var CSVRow in FCSVReader do
  begin
    const ActualField = CSVRow.Field['Invalid column'];
  end;
end;

procedure TCSVReaderTests.raise_exceptionon_on_get_field_if_index_not_found_test;
begin
  ExpectedException := ECSVException;

  for var CSVRow in FCSVReader do
  begin
    const ActualField = CSVRow[3];
  end;
end;

procedure TCSVReaderTests.search_should_return_nil_if_not_found_row_test;
var
  FoundIndex: Integer;

begin
  const ActualCSVRow = FCSVReader.Search(
    function (const CSVRow: TCSVRow): Boolean
    begin
      Result := CSVRow.Field[FColumnTwo] = FRowTreeCellTree;
    end,
    FoundIndex
  );

  CheckEquals(FoundIndex, -1);
  CheckNull(ActualCSVRow);
end;

procedure TCSVReaderTests.search_should_return_row_if_row_exists_test;
var
  FoundIndex: Integer;

begin
  const ActualCSVRow = FCSVReader.Search(
    function (const CSVRow: TCSVRow): Boolean
    begin
      Result := CSVRow.Field[FColumnTwo] = FRowTwoCellTwo;
    end,
    FoundIndex
  );

  CheckEquals(FoundIndex, 1);
  CheckEquals(ActualCSVRow.Field[FColumnTwo], FRowTwoCellTwo);
end;

procedure TCSVReaderTests.SetUp;
begin
  FStrings := TStringList.Create;
  FStrings.Add(FColumnOne + FDelimiter + FColumnTwo + FDelimiter + FColumnFree);
  FStrings.Add(FRowOneCellOne + FDelimiter + FRowOneCellTwo + FDelimiter + FRowOneCellTree);
  FStrings.Add(FRowTwoCellOne + FDelimiter + FRowTwoCellTwo + FDelimiter + FRowTwoCellTree);
  FStrings.Add(FRowTreeCellOne + FDelimiter + FRowTreeCellTwo + FDelimiter + FRowTreeCellTree);

  FCSVReader := TCSVReader.Create(FStrings, FDelimiter);
end;

procedure TCSVReaderTests.TearDown;
begin
  FreeAndNil(FCSVReader);
  
  FreeAndNil(FStrings);
end;

initialization
  RegisterTest(TCSVReaderTests.Suite);
  
end.
