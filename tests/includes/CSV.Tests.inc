/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : csv                                                        *//
//* Latest Source: https://github.com/vampirsoft/csv                          *//
//* Unit Name    : CSV.Tests.inc                                              *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2023 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

{$IF NOT DEFINED(CSV_TESTS_INC)}
{$DEFINE CSV_TESTS_INC}

// Управление исполнителями тестов, включать можно только один одновременно.
// Если ни один не включен, тесты будут исполняться в косольном режиме
//{$DEFINE USE_VCL_TESTRUNNER}
//{$DEFINE USE_MOBILE_TESTRUNNER}

// ВНИМАНИЕ!!!
// =============================================================================
// КОД СЛЕДУЮЩИЙ НИЖЕ НЕ ПРЕДНАЗНАЧЕН ДЛЯ ИЗМЕНЕНИЯ ПРОГРАММИСТОМ И
// СОДЕРЖИТ КРИТИЧЕСКИЕ НАСТРОЙКИ

{$IF NOT DEFINED(MSWINDOWS)}
  {$UNDEF USE_VCL_TESTRUNNER}
{$ENDIF MSWINDOWS}
{$IF NOT (DEFINED(USE_VCL_TESTRUNNER) OR DEFINED(USE_MOBILE_TESTRUNNER))}
  {$DEFINE CONSOLE_TESTRUNNER}
{$ENDIF CONSOLE_TESTRUNNER}

{$INCLUDE CSV.inc}

{$ENDIF ~ CSV_TESTS_INC}

