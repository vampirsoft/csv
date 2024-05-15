/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : csv                                                        *//
//* Latest Source: https://github.com/vampirsoft/csv                          *//
//* Unit Name    : writer.dpr                                                 *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

program writer;

{$INCLUDE CSV.Tests.inc}

uses
  CSV.Tests.Runner in '..\sources\CSV.Tests.Runner.pas',
  CSV.Common in '..\..\sources\CSV.Common.pas',
  CSV.Writer in '..\..\sources\CSV.Writer.pas',
  CSV.Writer.Tests in '..\sources\CSV.Writer.Tests.pas';

{$R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;
  RunRegisteredTests;
end.
