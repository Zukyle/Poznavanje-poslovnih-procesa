object fraSviZahtevi: TfraSviZahtevi
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
      Width = 101
      Height = 30
      Caption = 'Svi zahtevi'
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
      Width = 223
      Height = 15
      Caption = 'Pregled svih podnetih zahteva za nabavku.'
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
    TabOrder = 1
    object lblDetaljiNaslov: TLabel
      Left = 16
      Top = 17
      Width = 120
      Height = 17
      Caption = 'Izabrani zahtev'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'JetBrains Mono SemiBold'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblIDZahteva: TLabel
      Left = 16
      Top = 55
      Width = 88
      Height = 17
      Caption = 'Z-2005-5555'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = 'JetBrains Mono'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblMaterijalNaslov: TLabel
      Left = 16
      Top = 88
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
      Top = 109
      Width = 5
      Height = 15
      Caption = '-'
    end
    object lblKolicinaNaslov: TLabel
      Left = 16
      Top = 130
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
      Top = 151
      Width = 5
      Height = 15
      Caption = '-'
    end
    object lblPrioritetNaslov: TLabel
      Left = 16
      Top = 172
      Width = 42
      Height = 15
      Caption = 'Prioritet'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblPrioritetVrednost: TLabel
      Left = 16
      Top = 193
      Width = 5
      Height = 15
      Caption = '-'
    end
    object lblDatumNaslov: TLabel
      Left = 16
      Top = 214
      Width = 80
      Height = 15
      Caption = 'Datum potrebe'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblDatumVrednost: TLabel
      Left = 16
      Top = 235
      Width = 5
      Height = 15
      Caption = '-'
    end
    object lblRazlogNaslov: TLabel
      Left = 16
      Top = 256
      Width = 68
      Height = 15
      Caption = 'Obrazlo'#382'enje'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblStatusNaslov: TLabel
      Left = 16
      Top = 356
      Width = 78
      Height = 15
      Caption = 'Trenutni status'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblStatusVrednost: TLabel
      Left = 16
      Top = 377
      Width = 5
      Height = 15
      Caption = '-'
    end
    object lblPodnosilacNaslov: TLabel
      Left = 16
      Top = 398
      Width = 58
      Height = 15
      Caption = 'Podnosilac'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object lblPodnosilacVrednost: TLabel
      Left = 16
      Top = 419
      Width = 5
      Height = 15
      Caption = '-'
    end
    object lblKomentarNaslov: TLabel
      Left = 16
      Top = 440
      Width = 113
      Height = 15
      Caption = 'Komentar menad'#382'era'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object memRazlog: TMemo
      Left = 16
      Top = 277
      Width = 185
      Height = 68
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object memKomentar: TMemo
      Left = 16
      Top = 461
      Width = 185
      Height = 68
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 1
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
    TabOrder = 2
    object lblListaNaslov: TLabel
      Left = 20
      Top = 16
      Width = 162
      Height = 19
      Caption = 'Zahtevi za nabavku'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'JetBrains Mono'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object dbgZahtevi: TDBGrid
      Left = 20
      Top = 55
      Width = 677
      Height = 506
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
end
