/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : csv                                                        *//
//* Latest Source: https://github.com/vampirsoft/csv                          *//
//* Unit Name    : CSV.Common.pas                                             *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

unit CSV.Common;

{$INCLUDE CSV.inc}

interface

uses
  System.SysUtils;

type

{ ECSVException }

  ECSVException = class(Exception);

{ TObejectHelper }

  TObejectHelper = class helper for TObject
  public
    class function IfThenElse<T>(const Condition: Boolean; const ThenValue, ElseValue: T): T; static; inline;
  end;
  
implementation

{ TObejectHelper }

class function TObejectHelper.IfThenElse<T>(const Condition: Boolean; const ThenValue, ElseValue: T): T;
begin
  if Condition then Exit(ThenValue);
  Result := ElseValue;
end;

end.
