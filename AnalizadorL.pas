unit AnalizadorL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.RegularExpressions, Vcl.ComCtrls;

type
  TLForm = class(TForm)
    TokenList: TListView;
    procedure SetTableTokens(PRV, OLA, OTROS, ERROR, TVAR: TArray<String>);
  end;

var
  LForm: TLForm;
  ListItem: TListItem;

implementation

{$R *.dfm}

procedure TLForm.SetTableTokens(PRV, OLA, OTROS, ERROR, TVAR: TArray<String>);
var
  i: Integer;
begin
  with TokenList do
  begin
    Parent := Self;
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

end.
