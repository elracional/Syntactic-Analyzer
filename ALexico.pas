unit ALexico;

interface

uses
System.SysUtils, System.RegularExpressions, System.Generics.Collections;

type
  AnalizadorLexico = Class(TObject)
    private
      function RestarArreglos(A1, A2: TArray<String>): TArray<String>;
    public
      function AnalizarPRV(textbox: String): TArray<String>;
      function AnalizarOLA(textbox: String): TArray<String>;
      function AnalizarOTROS(textbox: String): TArray<String>;
      function AnalizarERROR(textbox: String): TArray<String>;
      function AnalizarVAR(textbox: String; PRV, OLA, OTROS, ERROR: TArray<String>): TArray<String>;
    end;

const
  PALABRAS_RESERVADAS : Array[0..67] of String =
    (
      'SELECT', 'FROM', 'WHERE', 'ON',
      'IS', 'NOT', 'USING', 'ALL',
      'ALTER', 'AND', 'ANY', 'CASCADE',
      'INSERT', 'CONTAINS', 'CREATE', 'CROSS',
      'MAX', 'BY', 'CHECK', 'CURRENT_USER',
      'DATABASE', 'DEFAULT', 'DISTINCT', 'DROP',
      'DUMP', 'ELSE', 'EXISTS', 'FOREIGN',
      'GROUP', 'HAVING', 'IF', 'INTO',
      'TRANSACTION', 'JOIN', 'LEFT', 'RIGHT',
      'NULL', 'PRIMARY', 'SET', 'TABLE',
      'THEN', 'UPDATE', 'VALUES', 'WITH',
      'MIN', 'DELETE', 'OR', 'AS',
      'CURRENT', 'IN', 'ORDER', 'NULLIF',
      'REPLACE', 'VIEW', 'CHECK', 'INNER',
      'FUNCTION', 'BEGIN', 'END', 'WHILE',
      'RECURSIVE', 'UNION', 'DECLARE', 'LIMIT',
      'integer', 'varchar', 'char', 'boolean'
    );
  OPERADORES : Array[0..10] of String =
    (
      '\x25', '\x26', '\x2A', '\x2B',
      '\x2D', '\x2F', '\x3C', '\x3D',
      '\x3E', '\x5E', '\x7C'
    );
  OTROS : Array[0..6] of String =
    (
      '\x3B', '\x28', '\x29', '\x5B', '\x5D', '\x2C', '\x27'
    );


implementation

function AnalizadorLexico.AnalizarPRV(textbox: String): TArray<String>;
var
  regex: TRegEx;
  match: TMatchCollection;
  i, j, k: Integer;
begin
  k := 1;
  for i := 0 to Length(PALABRAS_RESERVADAS)-1 do
  begin
    regex.Create('\b'+PALABRAS_RESERVADAS[i]+'\b');
    match := regex.Matches(textbox);
    for j := 0 to match.Count-1 do
    begin
      SetLength(Result, k);
      Result[k-1] := match.Item[j].Value;
      k := k + 1;
    end;
  end;
end;

function AnalizadorLexico.AnalizarOLA(textbox: String): TArray<String>;
var
  regex: TRegEx;
  match: TMatchCollection;
  i, j, k: Integer;
begin
  k := 1;
  for i := 0 to Length(OPERADORES)-1 do
  begin
    regex.Create(OPERADORES[i]);
    match := regex.Matches(textbox);
    for j := 0 to match.Count-1 do
    begin
      SetLength(Result, k);
      Result[k-1] := match.Item[j].Value;
      k := k + 1;
    end;
  end;
end;

function AnalizadorLexico.AnalizarOTROS(textbox: String): TArray<String>;
var
  regex: TRegEx;
  match: TMatchCollection;
  i, j, k: Integer;
begin
  k := 1;
  for i := 0 to Length(OTROS)-1 do
  begin
    regex.Create(OTROS[i]);
    match := regex.Matches(textbox);
    for j := 0 to match.Count-1 do
    begin
      SetLength(Result, k);
      Result[k-1] := match.Item[j].Value;
      k := k + 1;
    end;
  end;
end;

function AnalizadorLexico.AnalizarERROR(textbox: String): TArray<String>;
var
  regex: TRegEx;
  match: TMatchCollection;
  j, k: Integer;
begin
  k := 1;
  regex.Create('\b\d+[a-zA-Z_]+\b');
  match := regex.Matches(textbox);
  for j := 0 to match.Count-1 do
  begin
    SetLength(Result, k);
    Result[k-1] := match.Item[j].Value;
    k := k + 1;
  end;
end;

function AnalizadorLexico.AnalizarVAR(textbox: String; PRV, OLA, OTROS, ERROR: TArray<String>): TArray<String>;
var
  regex: TRegEx;
  match: TMatchCollection;
  j, k: Integer;
begin
  k := 1;
  regex.Create('\w+');
  match := regex.Matches(textbox);
  for j := 0 to match.Count-1 do
  begin
    SetLength(Result, k);
    Result[k-1] := match.Item[j].Value;
    k := k + 1;
  end;
  Result := RestarArreglos(Result, PRV);
  Result := RestarArreglos(Result, OLA);
  Result := RestarArreglos(Result, OTROS);
  Result := RestarArreglos(Result, ERROR);
end;

function AnalizadorLexico.RestarArreglos(A1, A2: TArray<String>): TArray<String>;
var
  j, k: Integer;
begin
  for j := 0 to Length(A1)-1 do
  begin
    for k := 0 to Length(A2)-1 do
    begin
      if (A1[j] = A2[k])
      then A1[j] := '';
    end;
  end;
  Result := A1;
end;


end.
