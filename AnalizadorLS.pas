unit AnalizadorLS;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ExtCtrls, Vcl.StdCtrls, System.RegularExpressions,
  AnalizadorL, ALexico, ASintactico, Vcl.ComCtrls;

type
  TAForm = class(TForm)
    Menu: TMainMenu;
    ArchivoM: TMenuItem;
    AbrirM: TMenuItem;
    GuardarM: TMenuItem;
    SalirM: TMenuItem;
    TBox: TMemo;
    TokenList: TListView;
    Panel1: TPanel;
    ErrorBox: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure LexicoMClick(Sender: TObject);
    procedure AbrirMClick(Sender: TObject);
    procedure GuardarMClick(Sender: TObject);
  private
    function GetFilePath() : String;
    function SetFilePath() : String;
  public
    procedure SetTableTokens(PRV, OLA, OTROS, ERROR, TVAR: TArray<String>);
  end;

var
  AForm: TAForm;
  openDialog: TOpenDialog;
  saveDialog : TSaveDialog;

implementation

{$R *.dfm}

function TAForm.GetFilePath(): String;
begin
  openDialog := TOpenDialog.Create(self);
  openDialog.InitialDir := 'C:\';
  openDialog.Options := [ofFileMustExist];
  openDialog.Filter := 'Structured Query Language File|*.sql|Text File|*.txt';
  openDialog.FilterIndex := 2;
  if openDialog.Execute
  then Result := openDialog.FileName;
  openDialog.Free;
end;

function TAForm.SetFilePath(): String;
begin
  saveDialog := TSaveDialog.Create(self);
  saveDialog.InitialDir := 'C:\';
  saveDialog.Filter := 'Structured Query Language File|*.sql|Text File|*.txt';
  saveDialog.DefaultExt := 'txt';
  saveDialog.FilterIndex := 2;
  if saveDialog.Execute
  then Result := saveDialog.FileName;
  saveDialog.Free;
end;

function GetFileText(filename: String) : String;
var
  chosenFile: TextFile;
  text: String;
begin
  AssignFile(chosenFile, filename);
  Reset(chosenFile);
  while not Eof(chosenFile) do
  begin
    Readln(chosenFile, text);
    Result := Result + text + SLineBreak;
  end;
  CloseFile(chosenFile);
end;

procedure SetFileText(filename, text: String);
var
  chosenFile: TextFile;
begin
  AssignFile(chosenFile, filename);
  ReWrite(chosenFile);
  Write(chosenFile, text);
  CloseFile(chosenFile);
end;

procedure TAForm.SetTableTokens(PRV, OLA, OTROS, ERROR, TVAR: TArray<String>);
var
  i: Integer;
begin
  with TokenList do
  begin
    Parent := Panel1;
    Align := alClient;
    ViewStyle := vsReport;
    Items.Clear;
    for i := 0 to Length(PRV)-1 do
    begin
      ListItem := Items.Add;
      ListItem.Caption := 'PRV';
      ListItem.SubItems.Add(PRV[i]);
    end;
    for i := 0 to Length(OLA)-1 do
    begin
      ListItem := Items.Add;
      ListItem.Caption := 'OLA';
      ListItem.SubItems.Add(OLA[i]);
    end;
    for i := 0 to Length(OTROS)-1 do
    begin
      ListItem := Items.Add;
      ListItem.Caption := 'OTROS';
      ListItem.SubItems.Add(OTROS[i]);
    end;
    for i := 0 to Length(ERROR)-1 do
    begin
      ListItem := Items.Add;
      ListItem.Caption := 'ERROR';
      ListItem.SubItems.Add(ERROR[i]);
    end;
    for i := 0 to Length(TVAR)-1 do
    begin
      if not(TVAR[i] = '') then
      begin
        ListItem := Items.Add;
        ListItem.Caption := 'VAR';
        ListItem.SubItems.Add(TVAR[i]);
      end;
    end;
  end;
end;

procedure TAForm.GuardarMClick(Sender: TObject);
begin
  SetFileText(SetFilePath(), TBox.Text);
end;

procedure TAForm.AbrirMClick(Sender: TObject);
begin
  TBox.Text := GetFileText(GetFilePath());
end;

procedure TAForm.FormCreate(Sender: TObject);
Const TabInc : LongInt = 10;
begin
  TBox.Text := '';
  ErrorBox.Text := '';
  SendMessage(TBox.Handle,$00CB,1,LongInt(@TabInc));
end;

procedure TAForm.LexicoMClick(Sender: TObject);
var
  Lex: ALexico.AnalizadorLexico;
  Sin: ASintactico.AnalizadorSintactico;
  PRV, OLA, OTROS, ERROR, TVAR: TArray<String>;
begin
  PRV := Lex.AnalizarPRV(TBox.Text);
  OLA := Lex.AnalizarOLA(TBox.Text);
  OTROS := Lex.AnalizarOTROS(TBox.Text);
  ERROR := Lex.AnalizarERROR(TBox.Text);
  TVAR := Lex.AnalizarVAR(TBox.Text, PRV, OLA, OTROS, ERROR);
  SetTableTokens(PRV, OLA, OTROS, ERROR, TVAR);
  Sin.AnalizarSintaxis(TBox, ErrorBox, PRV);
end;

end.
