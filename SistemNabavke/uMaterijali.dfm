object fraMaterijali: TfraMaterijali
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
      Width = 88
      Height = 30
      Caption = 'Materijali'
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
      Width = 171
      Height = 15
      Caption = 'Upravljanje materijalima sistema'
    end
  end
  object pnlLista: TPanel
    AlignWithMargins = True
    Left = 12
    Top = 102
    Width = 636
    Height = 586
    Margins.Left = 12
    Margins.Top = 12
    Margins.Right = 0
    Margins.Bottom = 12
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object lblListaNaslov: TLabel
      Left = 20
      Top = 16
      Width = 144
      Height = 19
      Caption = 'Lista materijala'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'JetBrains Mono'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblPretraga: TLabel
      Left = 308
      Top = 18
      Width = 80
      Height = 17
      Caption = 'Pretraga :'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'JetBrains Mono'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object dbgMaterijali: TDBGrid
      AlignWithMargins = True
      Left = 20
      Top = 58
      Width = 596
      Height = 508
      Margins.Left = 20
      Margins.Top = 20
      Margins.Right = 20
      Margins.Bottom = 20
      Align = alBottom
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
    object edtPretraga: TEdit
      Left = 394
      Top = 16
      Width = 222
      Height = 23
      TabOrder = 1
    end
  end
  object pnlDetalji: TPanel
    AlignWithMargins = True
    Left = 660
    Top = 102
    Width = 300
    Height = 586
    Margins.Left = 12
    Margins.Top = 12
    Margins.Right = 20
    Margins.Bottom = 12
    Align = alRight
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object lblDetaljiNaslov: TLabel
      Left = 16
      Top = 18
      Width = 152
      Height = 17
      Caption = 'Podaci o materijalu'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'JetBrains Mono SemiBold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblNazivNaslov: TLabel
      Left = 16
      Top = 64
      Width = 46
      Height = 15
      Caption = 'Materijal'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblTipNaslov: TLabel
      Left = 16
      Top = 120
      Width = 53
      Height = 15
      Caption = 'Kategorija'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblJedinicaNaslov: TLabel
      Left = 16
      Top = 176
      Width = 72
      Height = 15
      Caption = 'Jedinica mere'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblMinimumNaslov: TLabel
      Left = 16
      Top = 232
      Width = 53
      Height = 15
      Caption = 'Minimum'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object edtNaziv: TEdit
      Left = 16
      Top = 85
      Width = 268
      Height = 23
      TabOrder = 0
    end
    object edtMinimum: TEdit
      Left = 16
      Top = 253
      Width = 268
      Height = 23
      PasswordChar = '#'
      TabOrder = 1
    end
    object cmbJedinica: TComboBox
      Left = 16
      Top = 197
      Width = 268
      Height = 23
      Style = csDropDownList
      TabOrder = 2
    end
    object btnNovi: TButton
      Left = 16
      Top = 483
      Width = 265
      Height = 33
      Caption = 'Novi materijal'
      TabOrder = 3
    end
    object Panel1: TPanel
      Left = 15
      Top = 530
      Width = 268
      Height = 31
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 4
      object btnSacuvaj: TButton
        Left = 0
        Top = 0
        Width = 126
        Height = 31
        Align = alLeft
        Caption = 'Sa'#269'uvaj'
        TabOrder = 0
      end
      object btnOdustani: TButton
        Left = 142
        Top = 0
        Width = 126
        Height = 31
        Align = alRight
        Caption = 'Odustani'
        TabOrder = 1
      end
    end
    object cmbTip: TComboBox
      Left = 16
      Top = 141
      Width = 268
      Height = 23
      Style = csDropDownList
      TabOrder = 5
    end
  end
end
