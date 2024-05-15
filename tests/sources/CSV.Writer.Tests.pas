/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : CryptoHash                                                 *//
//* Latest Source: https://github.com/vampirsoft/csv                          *//
//* Unit Name    : CSV.Writer.Tests                                           *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

unit CSV.Writer.Tests;

{$INCLUDE CSV.Tests.inc}

interface

uses
  DUnitX.TestFramework,
  CSV.Writer;

type
  
{ TCSVWriterTests }

  [TestFixture]
  TCSVWriterTests = class
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
    FCSVWriter: TCSVWriter;
    
  public
    [Setup]
    procedure SetUp;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure write_values_should_be_correct;
  end;

implementation

uses
  System.SysUtils, System.Generics.Collections;
  
{ TCSVWriterTests }

procedure TCSVWriterTests.SetUp;
begin
  FCSVWriter := TCSVWriter.Create(FDelimiter);
end;

procedure TCSVWriterTests.TearDown;
begin
  FreeAndNil(FCSVWriter);
end;

procedure TCSVWriterTests.write_values_should_be_correct;
begin
  const Data: TArray<TArray<string>> = [
    [FRowOneCellOne,   FRowOneCellTwo,   FRowOneCellTree],
    [FRowTwoCellOne,   FRowTwoCellTwo,   FRowTwoCellTree],
    [FRowTreeCellOne,  FRowTreeCellTwo,  FRowTreeCellTree]
  ];

  for var Line in Data do
  begin
    const CSVRow = FCSVWriter.AddRow;

    CSVRow.Field[FColumnOne]  := Line[0];
    CSVRow.Field[FColumnTwo]  := Line[1];
    CSVRow.Field[FColumnFree] := Line[2];
  end;

  const Expected = [[FColumnOne, FColumnTwo, FColumnFree]] + Data;
  const Actual = FCSVWriter.ToArray;

  for var I := Low(Actual) to High(Actual) do
  begin
    const A = Actual[I];
    const E = Expected[I];

    for var J := Low(A) to High(A) do
    begin      
       Assert.AreEqual(E[J], A[J]);
    end;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TCSVWriterTests);
  
end.
