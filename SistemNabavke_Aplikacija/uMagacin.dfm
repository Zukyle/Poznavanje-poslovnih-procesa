object fraMagacin: TfraMagacin
  Left = 0
  Top = 0
  Width = 980
  Height = 700
  TabOrder = 0
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 980
    Height = 90
    Align = alTop
    BevelOuter = bvNone
    Color = 16513270
    ParentBackground = False
    TabOrder = 0
    object lblNaslov: TLabel
      Left = 24
      Top = 18
      Width = 81
      Height = 30
      Caption = 'Magacin'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblOpis: TLabel
      Left = 24
      Top = 52
      Width = 191
      Height = 15
      Caption = ' Pregled trenutnog stanja materijala '
    end
  end
  object pnlSadrzaj: TPanel
    AlignWithMargins = True
    Left = 12
    Top = 102
    Width = 956
    Height = 586
    Margins.Left = 12
    Margins.Top = 12
    Margins.Right = 12
    Margins.Bottom = 12
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object lblPretraga: TLabel
      Left = 20
      Top = 25
      Width = 100
      Height = 21
      Caption = 'Pretraga :'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'JetBrains Mono'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object dbgMagacin: TDBGrid
      Left = 24
      Top = 72
      Width = 905
      Height = 489
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
    object cmbStanje: TComboBox
      Left = 684
      Top = 26
      Width = 245
      Height = 23
      Style = csDropDownList
      TabOrder = 1
    end
    object edtPretraga: TEdit
      Left = 136
      Top = 26
      Width = 529
      Height = 23
      TabOrder = 2
    end
  end
end
