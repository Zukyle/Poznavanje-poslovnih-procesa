object fraNoviZahtev: TfraNoviZahtev
  Left = 0
  Top = 0
  Width = 980
  Height = 700
  Align = alClient
  Color = 16513270
  ParentBackground = False
  ParentColor = False
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
      Width = 228
      Height = 30
      Caption = 'Novi zahtev za nabavku'
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
      Width = 421
      Height = 15
      Caption = 
        'Popunite informacije o materijalu i potrebi kako biste pokrenuli' +
        ' proces nabavke.'
    end
  end
  object pnlSadrzaj: TPanel
    Left = 0
    Top = 90
    Width = 980
    Height = 610
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object pnlSaveti: TPanel
      AlignWithMargins = True
      Left = 740
      Top = 12
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
      TabOrder = 0
      ExplicitTop = 44
      object Image1: TImage
        Left = 16
        Top = 16
        Width = 24
        Height = 24
        Picture.Data = {
          0954506E67496D61676589504E470D0A1A0A0000000D49484452000000180000
          00180806000000E0773DF8000000097048597300000B1300000B1301009A9C18
          000002E04944415478DAAD565D4B1451183EEFCC2AAEAE5DB58A3325EA5ADD44
          5150571169625D2411F807A4E8AA20D29D853E104B21670D82EEBAE83E2F2AAA
          0B41142ABA8920830812DD356B674BBBC9CF70DD797BCEAE537ECC8EA3746099
          9973CEFB3CCFFB71DEB324B630EAE216CB6722AA915F1BDF1BFF1BC1AEBB93C1
          6FEDD58BDB2170B35DB3B1C6B43A1421CE2F07028D93572BD25BF1AEBEC70ADB
          453C2488FA21A07B0381642FCAAA6F89683F337F5433D438765D9BF60B9E2DE2
          61C736A3668F3A9EACF1A02E9EAE60B68730FD23A32EB7C84D2B7397617C4630
          EF91FB58D0A8207EA12ED17D29222F2EF01C2B9544CAC944B46AAA600EF6F6A5
          762E50765E82D7C6AD56183D2441E56ECAA17606C46D08C9634952CA6AD96887
          FED333C9CE90E0C4DC8F98E2219EE2776F51A177722D24C4115BF015189F050D
          5E456BC2D09FB8E1B812E4C222ECB1BC7232E072DC7D5F2A86F53B20F9152051
          BF5E7D41825A33751BC26F48E549433BE795E03AD37A06941684EB56D2D03BFD
          79605A23583968DBE2C4444C7BE94510E94D37B0C2C310F31E620E6F20700E8F
          1CCE018207B3F020541254CB3F5DAA9CF322D8D73B5D9E5132332C783619D577
          E443F70FD395001E2CC083608038EC16D7D52377C08AC5144A6A1E890E6D2070
          4F9EF5018F034CDC9CECD007BD086AFA52A714A601BC8E40E0217F3988A7A3A8
          0C13E5379830B4662F028891029A0A559B2B818CEB92B2348E320DA33ABA511D
          375DC14DAB0708D710FFE962BB38F239169EF5459033EE4B1D134C525D094886
          99A86B22AABDCA85256E1DC7E9EB442134E2F337E2DF84F8BF71C3F16C1539A0
          7CAB88C8B5BF45B09244281F17B6684BC6F4D7BE5A855BB3ABEA4C95064334EF
          46B038C765E92E7DC157B3F36AD7EB2F9AF5DFBEDB351A5C3BB1B890156AC317
          A3F2FBAA4AF1247048E4858356FE0827BAA7600EDCAEBD5AD39A2412BB57CFA1
          357C0550F566B6BE2EEF88699DB68578E09048705CAD17C70D6D6033DB2DFDAB
          D8CEF8030F54A24C10DE94300000000049454E44AE426082}
      end
      object lblDetaljiNaslov: TLabel
        Left = 54
        Top = 23
        Width = 112
        Height = 17
        Caption = 'Korisni saveti'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'JetBrains Mono SemiBold'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblDetaljiNaslovClick
      end
      object Bevel2: TBevel
        Left = 16
        Top = 46
        Width = 185
        Height = 2
        Shape = bsBottomLine
      end
      object Label1: TLabel
        Left = 16
        Top = 64
        Width = 185
        Height = 63
        AutoSize = False
        Caption = 
          'Budite '#353'to precizniji u opisu materijala kako bismo br'#382'e prona'#353'l' +
          'i dobavlja'#269'a.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object Label2: TLabel
        Left = 16
        Top = 128
        Width = 185
        Height = 63
        AutoSize = False
        Caption = 
          'Navediti '#353'to precizniji datom potrebe da bismo planirali isporuk' +
          'u.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object Label3: TLabel
        Left = 16
        Top = 197
        Width = 185
        Height = 63
        AutoSize = False
        Caption = 'Za hitne potrebe izaberite prioritet ,,Visok'#8217#8217
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
    end
    object pnlForma: TPanel
      AlignWithMargins = True
      Left = 12
      Top = 12
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
      ExplicitLeft = 164
      ExplicitTop = 41
      object lblDetaljiZahteva: TLabel
        Left = 20
        Top = 16
        Width = 135
        Height = 19
        Caption = 'Detalji zahteva'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'JetBrains Mono'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblKategorija: TLabel
        Left = 20
        Top = 56
        Width = 53
        Height = 15
        Caption = 'Kategorija'
      end
      object lblMaterijal: TLabel
        Left = 352
        Top = 56
        Width = 46
        Height = 15
        Caption = 'Materijal'
      end
      object lblKolicina: TLabel
        Left = 24
        Top = 112
        Width = 42
        Height = 15
        Caption = 'Koli'#269'ina'
      end
      object lblJedinicaMere: TLabel
        Left = 352
        Top = 112
        Width = 72
        Height = 15
        Caption = 'Jedinica mere'
      end
      object lblPrioritet: TLabel
        Left = 24
        Top = 176
        Width = 42
        Height = 15
        Caption = 'Prioritet'
      end
      object lblDatumPotrebe: TLabel
        Left = 352
        Top = 176
        Width = 80
        Height = 15
        Caption = 'Datum potrebe'
      end
      object lblRazlog: TLabel
        Left = 24
        Top = 235
        Width = 111
        Height = 15
        Caption = 'Obrazlo'#382'enje zahteva'
      end
      object cmbKategorija: TComboBox
        Left = 20
        Top = 77
        Width = 280
        Height = 23
        Style = csDropDownList
        TabOrder = 0
      end
      object cmbMaterijal: TComboBox
        Left = 352
        Top = 77
        Width = 280
        Height = 23
        Style = csDropDownList
        Enabled = False
        TabOrder = 1
      end
      object edtKolicina: TEdit
        Left = 24
        Top = 133
        Width = 280
        Height = 23
        TabOrder = 2
      end
      object edtJedinicaMere: TEdit
        Left = 352
        Top = 133
        Width = 280
        Height = 23
        ReadOnly = True
        TabOrder = 3
      end
      object cmbPrioritet: TComboBox
        Left = 24
        Top = 197
        Width = 280
        Height = 23
        Style = csDropDownList
        TabOrder = 4
      end
      object dtpDatumPotrebe: TDateTimePicker
        Left = 352
        Top = 197
        Width = 280
        Height = 23
        Date = 46251.000000000000000000
        Time = 0.000381458332412876
        TabOrder = 5
      end
      object memRazlog: TMemo
        Left = 24
        Top = 256
        Width = 608
        Height = 121
        Lines.Strings = (
          '')
        TabOrder = 6
      end
      object btnPosaljiZahtev: TButton
        Left = 472
        Top = 392
        Width = 160
        Height = 33
        Caption = 'Po'#353'alji zahtev'
        TabOrder = 7
      end
    end
  end
  object qryMaterijali: TFDQuery
    Left = 736
    Top = 32
  end
end
