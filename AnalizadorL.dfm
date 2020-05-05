object LForm: TLForm
  Left = 0
  Top = 0
  Caption = 'LForm'
  ClientHeight = 321
  ClientWidth = 203
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object TokenList: TListView
    Left = 0
    Top = 0
    Width = 217
    Height = 313
    Columns = <
      item
        Caption = 'Token'
        Width = 100
      end
      item
        Caption = 'Cadena'
        Width = 100
      end>
    Groups = <
      item
        GroupID = 0
        State = [lgsNormal]
        HeaderAlign = taLeftJustify
        FooterAlign = taLeftJustify
        TitleImage = -1
      end>
    TabOrder = 0
  end
end
