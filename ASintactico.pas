unit ASintactico;

interface

uses
System.SysUtils, System.RegularExpressions, System.Generics.Collections, Vcl.StdCtrls;

type
  AnalizadorSintactico = Class(TObject)
    private
      procedure q0(pos, textbox: String);
      procedure q1(pos, textbox: String);
      procedure qx(x: String);
      procedure Aritmetica(cadena: String);
      procedure Sentencias(cadena: String);
      procedure Funciones(cadena: String);
      function SELECT_syntaxis(cadena: String) : Boolean;
      function Es_Valor(cadena: String) : Boolean;
      function Es_Parametro(cadena: String; parametros: Integer) : Boolean;
      function Es_Condicion(cadena: String): Boolean;
      function Es_Asignacion(cadena: String): Boolean;
      function Es_Variable(cadena: String) : Boolean; overload;
      function Es_Variable(arreglo: TArray<String>) : Boolean;  overload;
    public
      function AnalizarSintaxis(TBox, ErrorBox: TMemo; PRV: TArray<String>): TMemo;
      function PDA(textbox: String): Boolean;
    end;

const
  FUNCIONES_ESPACIO : Array[0..15] of String =
    (
      'SELECT', 'FROM', 'WHERE', 'ON',
      'IS', 'NOT', 'ALTER', 'AND',
      'INSERT', 'CREATE', 'DATABASE', 'TABLE',
      'DROP', 'DELETE', 'INTO', 'SET'
    );

  FUNCIONES_PARENTESIS: Array[0..2] of String =
    (
      'HAVING', 'VALUES', 'ALL'
    );

implementation

var
  Match: TMatch;
  Stack: TStack<String>;
  Flag: Boolean;
  Errors: String;
  PR: TArray<String>;

function AnalizadorSintactico.AnalizarSintaxis(TBox, ErrorBox: TMemo; PRV: TArray<String>): TMemo;
begin
  PR := PRV;
  Errors := String.Empty;
  if (PDA(TBox.Text))
  then ErrorBox.Text := ''
  else ErrorBox.Text := 'Error de Sintaxis';
  ErrorBox.Text := ErrorBox.Text + Errors;
  Result := ErrorBox;
end;

function AnalizadorSintactico.PDA(textbox: string): Boolean;
begin
  Flag := True;
  Stack := TStack<String>.Create;
  Match := TRegEx.Match(textbox, '\x28|\x29|\x5B|\x5D|(\bBEGIN\b)|(\bEND\b)');
  q0(Match.Value, textbox);
  Match := TRegEx.Match(textbox, '[\x21-\x7E]+\s*[\x2A\x2B\x2D\x2F]\s*[\x21-\x7E]+');
  if (Match.Success) then Aritmetica(Match.Value);
  //Match := TRegEx.Match(textbox, '([\w\x27]+\s*[\x2A\x2B\x2D\x2F\x3D]\s*)+[\w\x27]*');
  //if (Match.Success) then Asignacion(Match.Value);
  Match := TRegEx.Match(textbox, '[^;]*;');
  if (Match.Success) then Funciones(Match.Value);
  if not textbox.IsEmpty then Sentencias(textbox);
  if (Stack.Count = 0) and Flag then
    Result := True
  else
    Result := False;
end;

procedure AnalizadorSintactico.q0(pos, textbox: String);
var
  x, y: char;
begin
  Match := Match.NextMatch();
  if not(pos.IsEmpty) then x := pos.Chars[0];
  case x of
   '(','[','B': begin
                  Stack.Push(x);
                  if Match.Success then q0(Match.Value, textbox);
                end;
  end;
  case x of
   ')' : y := '(';
   ']' : y := '[';
   'E' : y := 'B';
  end;
  case x of
   ')',']','E': begin
                  if (Stack.Count <> 0) and (Stack.Peek.Equals(y)) then Stack.Extract() else qx(x);
                  if Match.Success then q1(Match.Value, textbox);
                end;
  end;
end;

procedure AnalizadorSintactico.q1(pos, textbox: String);
var
  x, y: char;
begin
  Match := Match.NextMatch();
  if not(pos.IsEmpty) then x := pos.Chars[0];
  case x of
   '(','[','B': begin
                  Stack.Push(x);
                  if Match.Success then q0(Match.Value, textbox);
                end;
  end;
  case x of
   ')' : y := '(';
   ']' : y := '[';
   'E' : y := 'B';
  end;
  case x of
   ')',']','E': begin
                  if (Stack.Count <> 0) and (Stack.Peek.Equals(y)) then Stack.Extract() else qx(x);
                  if Match.Success then q1(Match.Value, textbox);
                end;
  end;
end;

procedure AnalizadorSintactico.qx(x: String);
var
  y: String;
begin
  Flag := False;
  if Stack.Count <> 0 then
  case Stack.Peek.Chars[0] of
   '(' : y := ')';
   '[' : y := ']';
   'B' : y := 'END';
  end;
  if x.Equals('E') then x:= 'END';
  if not y.IsEmpty then Errors := Errors + SLineBreak + 'Error de Sintaxis: Se esperaba '+y+' pero '+x+' fue encontrado.'
  else Errors := Errors + SLineBreak + 'Error de Sintaxis: No se esperaba '+x+' pero fue encontrado.';
end;

function AnalizadorSintactico.Es_Valor(cadena: String) : Boolean;
begin
  if(TRegEx.IsMatch(cadena, '[\x21-\x26\x2A-\x2D\x2F]')) or (cadena = '') then Result := False
  else Result := True;
end;

function AnalizadorSintactico.Es_Variable(cadena: String) : Boolean;
var
  i: Integer;
begin
  if not(TRegEx.IsMatch(cadena, '^[a-zA-Z_]+(\d+[a-zA-Z_]*)*$')) or TArray.BinarySearch<String>(PR, cadena, i) then Result := False
  else Result := True;
end;

function AnalizadorSintactico.Es_Variable(arreglo: TArray<String>) : Boolean;
var
  i: Integer;
  cadena: String;
begin
  Result := True;
  for cadena in arreglo do
  begin
    if not(TRegEx.IsMatch(cadena, '^[a-zA-Z_]+(\d+[a-zA-Z_]*)*$')) or TArray.BinarySearch<String>(PR, cadena, i) then Result := False
  end;
end;

function AnalizadorSintactico.Es_Parametro(cadena: String; parametros: Integer) : Boolean;
begin
  Result := True;
  cadena := cadena.TrimRight;
  if not TRegEx.IsMatch(cadena,'^\x28.+\x29$') then Result := False;
  if parametros = 1 then if not Es_Variable(cadena.Replace('(',String.Empty).Replace(')',String.Empty)) then Result := False;
end;

procedure AnalizadorSintactico.Aritmetica(cadena: String);
begin
  cadena := cadena.Replace(' ',String.Empty);
  if cadena <> '' then
  if not Es_Valor(TRegEx.Replace(cadena, '[\x2A\x2B\x2D\x2F][\x21-\x7E]+', String.Empty)) then Flag := False
  else
  begin
    Aritmetica(TRegEx.Match(cadena, '[\x2A\x2B\x2D\x2F][\x21-\x7E]+').Value.Substring(1));
  end;
  Match := Match.NextMatch();
  if Match.Success then Aritmetica(Match.Value);
end;

function AnalizadorSintactico.Es_Asignacion(cadena: String) : Boolean;
begin
  Result := True;
  cadena := cadena.Replace(' ',String.Empty);
  if cadena <> '' then
  if cadena.CountChar('=') > 1 then Result := False;
  if not Es_Valor(TRegEx.Replace(cadena, '\x3D[\x21-\x7E]+', String.Empty)) then Flag := False
  else if not Es_Variable(TRegEx.Replace(cadena, '\x3D[\x21-\x7E]+', String.Empty)) then
  begin
    Flag := False;
    Errors := Errors + SLineBreak + 'Error de Sintaxis: Se esperaba una variable, pero una constante o funcion fue encontrada.';
  end;
end;

function AnalizadorSintactico.Es_Condicion(cadena: String) : Boolean;
begin
  Result := True;
  if not cadena.EndsWith(';') then cadena := cadena + ';';
  if TRegEx.IsMatch(cadena, '\w+\s+\w+') then Result := False;
  cadena := cadena.Replace(' ',String.Empty);
  if cadena <> '' then
  if not Es_Valor(TRegEx.Replace(cadena, '[\x3D\x3C\x3E][\x21-\x7E]+', String.Empty)) then Result := False
  else if not Es_Variable(TRegEx.Replace(cadena, '[\x3D\x3C\x3E][\x21-\x7E]+', String.Empty)) then
  begin
    Result := False;
    Errors := Errors + SLineBreak + 'Error de Sintaxis: Se esperaba una variable, pero una constante o funcion fue encontrada.';
  end;
end;

procedure AnalizadorSintactico.Sentencias(cadena: String);
begin
  if cadena.Chars[cadena.Length-1] <> ';' then
  begin
    Flag := False;
    Errors := Errors + SLineBreak + 'Error de Sintaxis: Se esperaba ; pero no fue encontrado.';
  end;
end;

procedure AnalizadorSintactico.Funciones(cadena: String);
begin
  cadena := cadena.TrimLeft;
  cadena := cadena.TrimRight;
  if (TRegEx.IsMatch(cadena, '^SELECT\s.*;$')) then
  begin
    SELECT_syntaxis(cadena);
  end;
  Match := Match.NextMatch();
  if Match.Success then Funciones(Match.Value);
end;

function AnalizadorSintactico.SELECT_syntaxis(cadena: String) : Boolean;
var
  separatorArray : Array[0..0] of Char;
begin
  separatorArray[0] := ',';
  cadena := cadena.Substring(6).TrimLeft;
  if TRegEx.IsMatch(cadena,'^((\w+\s*(,\s*\w+\s*)*)|(~))\sFROM\s.*;$') then
  begin
    //Sintaxis FROM
    cadena := cadena.Substring(AnsiPos('FROM',cadena)+3).TrimLeft;
    if not Es_Variable(TRegEx.Replace(cadena, '(WHERE|USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty).Replace(';',String.Empty).TrimRight) 
    and not Es_Variable(TRegEx.Replace(cadena, '(WHERE|USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty).Replace(';',String.Empty).TrimRight.Split(separatorArray))
    then Errors := Errors + SLineBreak + 'Error de Sintaxis: ▼'+TRegEx.Replace(cadena, '(WHERE|USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty);
    if TRegEx.IsMatch(cadena,'^\w+\s*(,\s*\w+\s*)*\s(WHERE|USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET)\s.*;$') then
    begin
      cadena := TRegEx.Create('^\w+\s*(,\s*\w+\s*)*\s\b').Replace(cadena, String.Empty, 1);
      //Sintaxis Opcional
      if TRegEx.IsMatch(cadena,'^(WHERE)\s.*;$') then //Sintaxis WHERE
      begin
        cadena := TRegEx.Create('^(WHERE|USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET)\s*').Replace(cadena, String.Empty, 1);
        if not Es_Condicion(TRegEx.Replace(cadena, '(USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty).TrimRight)
        then Errors := Errors + SLineBreak + 'Error de Sintaxis: ▼'+TRegEx.Replace(cadena, '(USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty);
        cadena := cadena.Substring(TRegEx.Replace(cadena, '(USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty).Length).TrimLeft;
      end;
      if TRegEx.IsMatch(cadena,'^(USING)\s.*;$') then //Sintaxis USING
      begin
        cadena := TRegEx.Create('^(WHERE|USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET)\s*').Replace(cadena, String.Empty, 1);
        if not Es_Parametro(TRegEx.Replace(cadena, '(GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty).Replace(';',String.Empty), 1)
        then Errors := Errors + SLineBreak + 'Error de Sintaxis: ▼'+TRegEx.Replace(cadena, '(USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty);
        cadena := cadena.Substring(TRegEx.Replace(cadena, '(GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty).Length).TrimLeft;
      end;
      if TRegEx.IsMatch(cadena,'^(GROUP BY)\s.*;$') then //Sintaxis GROUP BY
      begin
        cadena := TRegEx.Create('^(WHERE|USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET)\s*').Replace(cadena, String.Empty, 1);
        if not Es_Variable(TRegEx.Replace(cadena, '(HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty).Replace(';',String.Empty).TrimRight)
        and not Es_Variable(TRegEx.Replace(cadena, '(HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty).Replace(';',String.Empty).TrimRight.Split(separatorArray))
        then Errors := Errors + SLineBreak + 'Error de Sintaxis: ▼'+TRegEx.Replace(cadena, '(USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty);
        cadena := cadena.Substring(TRegEx.Replace(cadena, '(HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty).Length).TrimLeft;
      end;
      if TRegEx.IsMatch(cadena,'^(HAVING)\s.*;$') then //Sintaxis HAVING
      begin
        cadena := TRegEx.Create('^(WHERE|USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET)\s*').Replace(cadena, String.Empty, 1);
        if not Es_Condicion(TRegEx.Replace(cadena, '(ORDER BY|LIMIT|OFFSET).*;', String.Empty))
        then Errors := Errors + SLineBreak + 'Error de Sintaxis: ▼'+TRegEx.Replace(cadena, '(USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty);
        cadena := cadena.Substring(TRegEx.Replace(cadena, '(ORDER BY|LIMIT|OFFSET).*;', String.Empty).Length).TrimLeft;
      end;
      if TRegEx.IsMatch(cadena,'^(LIMIT)\s.*;$') then //Sintaxis LIMIT
      begin
        cadena := TRegEx.Create('^(WHERE|USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET)\s*').Replace(cadena, String.Empty, 1);
        if not TRegEx.IsMatch(TRegEx.Replace(cadena, '(OFFSET).*;', String.Empty).Replace(';',String.Empty).TrimRight, '^\w+$')
        then Errors := Errors + SLineBreak + 'Error de Sintaxis: ▼'+TRegEx.Replace(cadena, '(USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty);
        cadena := cadena.Substring(TRegEx.Replace(cadena, '(OFFSET).*;', String.Empty).Length).TrimLeft;
      end;
      if TRegEx.IsMatch(cadena,'^(OFFSET)\s.*;$') then //Sintaxis OFFSET
      begin
        cadena := TRegEx.Create('^(WHERE|USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET)\s*').Replace(cadena, String.Empty, 1);
        if not TRegEx.IsMatch(TRegEx.Replace(cadena, '.*;', String.Empty).Replace(';',String.Empty).TrimRight, '^\w+$')
        then Errors := Errors + SLineBreak + 'Error de Sintaxis: ▼'+TRegEx.Replace(cadena, '(USING|GROUP BY|HAVING|ORDER BY|LIMIT|OFFSET).*;', String.Empty);
        cadena := cadena.Substring(TRegEx.Replace(cadena, '.*;', String.Empty).Length).TrimLeft;
      end;
    end
    else if not TRegEx.IsMatch(cadena, '^\w+\s*(,\s*\w+\s*)*;$')
    then Errors := Errors + SLineBreak + 'Error de Sintaxis: ▼'+cadena;
  end
  else if TRegEx.IsMatch(cadena,'^\w+\s*(,\s*\w+\s*)*\sINTO\s.*;$') then
  begin
    cadena := cadena.Substring(AnsiPos('INTO',cadena)+3).TrimLeft;
    if not TRegEx.IsMatch(cadena,'^\w+\s*;$') then
    begin
      Errors := Errors + SLineBreak + 'Error de Sintaxis: ▼'+cadena;
    end;
  end
  else Errors := Errors + SLineBreak + 'Error de Sintaxis: ▼'+cadena;
  Match := Match.NextMatch();
  if Match.Success then Funciones(Match.Value);
end;

end.
