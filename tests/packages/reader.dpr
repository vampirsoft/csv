/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : csv                                                        *//
//* Latest Source: https://github.com/vampirsoft/csv                          *//
//* Unit Name    : reader.dpr                                                 *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

program reader;

{$INCLUDE CSV.Tests.inc}

uses
  CSV.Tests.Runner in '..\sources\CSV.Tests.Runner.pas',
  CSV.Common in '..\..\sources\CSV.Common.pas',
  CSV.Reader in '..\..\sources\CSV.Reader.pas',
  CSV.Reader.Helpers in '..\..\sources\CSV.Reader.Helpers.pas',
  CSV.Reader.Tests in '..\sources\CSV.Reader.Tests.pas';

{$R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;
  RunRegisteredTests;
end.
