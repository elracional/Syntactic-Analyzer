program Analizador;

uses
  Vcl.Forms,
  AnalizadorLS in 'AnalizadorLS.pas' {AForm},
  ALexico in 'ALexico.pas',
  ASintactico in 'ASintactico.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TAForm, AForm);
  Application.Run;
end.
