object fraOsnovniPodaci: TfraOsnovniPodaci
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
      Width = 149
      Height = 30
      Caption = 'Osnovni podaci'
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
      Width = 214
      Height = 15
      Caption = 'Upravljanje osnovnim podacima sistema'
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
      Width = 189
      Height = 19
      Caption = 'Kategorije materijala'
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
    object dbgKategorije: TDBGrid
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
      Caption = 'Podaci o kategoriji'
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
      Width = 84
      Height = 15
      Caption = 'Naziv kategorije'
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
    object Panel1: TPanel
      Left = 15
      Top = 210
      Width = 268
      Height = 31
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
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
    object Panel2: TPanel
      Left = 15
      Top = 162
      Width = 268
      Height = 31
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      object btnNovi: TButton
        Left = 0
        Top = 0
        Width = 126
        Height = 31
        Align = alLeft
        Caption = 'Nova kategorija'
        TabOrder = 0
        ExplicitLeft = -32
        ExplicitTop = -16
      end
      object btnObrisi: TButton
        Left = 142
        Top = 0
        Width = 126
        Height = 31
        Align = alRight
        Caption = 'Obri'#353'i'
        TabOrder = 1
      end
    end
  end
end
