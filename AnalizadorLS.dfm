object AForm: TAForm
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Analizador'
  ClientHeight = 336
  ClientWidth = 664
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = Menu
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TBox: TMemo
    Left = 0
    Top = 0
    Width = 506
    Height = 241
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Consolas'
    Font.Style = []
    Lines.Strings = (
      'TBox')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
    WantTabs = True
    OnChange = LexicoMClick
  end
  object Panel1: TPanel
    Left = 504
    Top = -6
    Width = 160
    Height = 343
    Caption = 'Panel1'
    TabOrder = 1
    object TokenList: TListView
      Left = 0
      Top = 6
      Width = 161
      Height = 334
      Columns = <
        item
          Caption = 'Token'
          Width = 60
        end
        item
          Caption = 'Cadena'
          Width = 90
        end>
      TabOrder = 0
    end
  end
  object ErrorBox: TMemo
    Left = 0
    Top = 240
    Width = 506
    Height = 96
    Lines.Strings = (
      'ErrorBox')
    ReadOnly = True
    TabOrder = 2
  end
  object Menu: TMainMenu
    Left = 536
    Top = 272
    object ArchivoM: TMenuItem
      Caption = 'Archivo'
      object AbrirM: TMenuItem
        Caption = 'Abrir'
        OnClick = AbrirMClick
      end
      object GuardarM: TMenuItem
        Caption = 'Guardar'
        OnClick = GuardarMClick
      end
      object SalirM: TMenuItem
        Caption = 'Salir'
      end
    end
  end
end
