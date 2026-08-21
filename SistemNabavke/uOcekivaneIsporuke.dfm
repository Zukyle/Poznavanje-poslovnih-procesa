object fraOcekivaneIsporuke: TfraOcekivaneIsporuke
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
      Width = 186
      Height = 30
      Caption = 'O'#269'ekivane isporuke'
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
      Width = 252
      Height = 15
      Caption = 'Pregled narud'#382'benica koje se o'#269'ekuju za prijem.'
    end
  end
  object pnlTabela: TPanel
    AlignWithMargins = True
    Left = 12
    Top = 102
    Width = 716
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
      Width = 162
      Height = 19
      Caption = 'O'#269'ekivane isporuke'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'JetBrains Mono'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object dbgIsporuke: TDBGrid
      AlignWithMargins = True
      Left = 20
      Top = 58
      Width = 676
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
  end
  object pnlDetalji: TPanel
    AlignWithMargins = True
    Left = 740
    Top = 102
    Width = 220
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
      Width = 128
      Height = 17
      Caption = 'Detalji isporuke'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'JetBrains Mono SemiBold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblNarudzbenicaNaslov: TLabel
      Left = 16
      Top = 64
      Width = 73
      Height = 15
      Caption = 'Narud'#382'benica'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblNarudzbenicaVrednost: TLabel
      Left = 16
      Top = 85
      Width = 5
      Height = 15
      Caption = '-'
    end
    object lblMaterijalNaslov: TLabel
      Left = 16
      Top = 106
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
    object lblMaterijalVrednost: TLabel
      Left = 16
      Top = 127
      Width = 5
      Height = 15
      Caption = '-'
    end
    object lblKolicinaNaslov: TLabel
      Left = 16
      Top = 148
      Width = 42
      Height = 15
      Caption = 'Koli'#269'ina'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblKolicinaVrednost: TLabel
      Left = 16
      Top = 169
      Width = 5
      Height = 15
      Caption = '-'
    end
    object lblDobavljacNaslov: TLabel
      Left = 16
      Top = 190
      Width = 52
      Height = 15
      Caption = 'Dobavlja'#269
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblDobavljacVrednost: TLabel
      Left = 16
      Top = 211
      Width = 5
      Height = 15
      Caption = '-'
    end
    object lblUkupnoNaslov: TLabel
      Left = 16
      Top = 232
      Width = 69
      Height = 15
      Caption = 'Ukupna cena'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblUkupnoVrednost: TLabel
      Left = 16
      Top = 253
      Width = 5
      Height = 15
      Caption = '-'
    end
    object lblDatumVrednost: TLabel
      Left = 16
      Top = 295
      Width = 5
      Height = 15
      Caption = '-'
    end
    object lblDatumNaslov: TLabel
      Left = 16
      Top = 274
      Width = 103
      Height = 15
      Caption = 'O'#269'ekivana isporuka'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblStatusVrednost: TLabel
      Left = 16
      Top = 337
      Width = 5
      Height = 15
      Caption = '-'
    end
    object lblStatusNaslov: TLabel
      Left = 16
      Top = 316
      Width = 32
      Height = 15
      Caption = 'Status'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object Bevel1: TBevel
      Left = 16
      Top = 41
      Width = 185
      Height = 2
      Shape = bsBottomLine
    end
    object Bevel2: TBevel
      Left = 16
      Top = 358
      Width = 185
      Height = 2
      Shape = bsBottomLine
    end
    object btnPrimiRobu: TButton
      Left = 16
      Top = 376
      Width = 187
      Height = 33
      Caption = 'Primi robu'
      TabOrder = 0
    end
  end
end
