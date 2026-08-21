unit uPrijemRobe;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.ValEdit,

  Data.DB,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfraPrijemRobe = class(TFrame)

    // ========================================================
    // HEADER
    // ========================================================

    pnlHeader: TPanel;
    lblNaslov: TLabel;
    lblOpis: TLabel;


    // ========================================================
    // PRIJEM
    // ========================================================

    pnlPrijem: TPanel;

    lblNarudzbenicaNaslov: TLabel;
    cmbNarudzbenica: TComboBox;

    vleNarudzbenica: TValueListEditor;

    lblPrimljenaKolicinaNaslov: TLabel;

    // NOVO
    edtPrimljenaKolicina: TEdit;
    cmbJedinicaMere: TComboBox;

    lblStatusPrijemaNaslov: TLabel;
    cmbStatusPrijema: TComboBox;

    lblNapomenaNaslov: TLabel;
    memNapomena: TMemo;

    btnEvidentirajPrijem: TButton;


    // ========================================================
    // TABELA
    // ========================================================

    pnlTabela: TPanel;
    lblListaNaslov: TLabel;
    dbgPrijemi: TDBGrid;

  private

    // ========================================================
    // QUERY + DATASOURCE
    // ========================================================

    FQryPrijemi: TFDQuery;
    FDsPrijemi: TDataSource;


    // ========================================================
    // MAGACIONER
    // ========================================================

    FKorisnikID: Integer;


    // ========================================================
    // TRENUTNA NARUDŽBENICA
    // ========================================================

    FNarudzbenicaID: Integer;
    FMaterijalID: Integer;

    FNarucenaKolicina: Double;
    FVecPrimljeno: Double;
    FPreostalo: Double;

    FJedinica: string;


    // ========================================================
    // NARUDŽBENICE
    // ========================================================

    procedure UcitajNarudzbenice;

    procedure cmbNarudzbenicaChange(
      Sender: TObject
    );

    procedure UcitajDetaljeNarudzbenice;

    procedure OcistiDetaljeNarudzbenice;


    // ========================================================
    // STATUS
    // ========================================================

    procedure UcitajStatusePrijema;

    function StatusPrikazUDB(
      const AStatus: string
    ): string;


    // ========================================================
    // PRIJEM
    // ========================================================

    procedure btnEvidentirajPrijemClick(
      Sender: TObject
    );

    function ProcitajKolicinu(
      out AKolicina: Double
    ): Boolean;


    // ========================================================
    // ISTORIJA PRIJEMA
    // ========================================================

    procedure UcitajPrijeme;

    procedure PodesiKolone;

  public

    constructor Create(
      AOwner: TComponent
    ); override;


    procedure Osvezi;


    procedure OtvoriZaNarudzbenicu(
      ANarudzbenicaID: Integer
    );


    property KorisnikID: Integer
      read FKorisnikID
      write FKorisnikID;

  end;

implementation

uses
  uLogin;

{$R *.dfm}


// ============================================================
// CONSTRUCTOR
// ============================================================

constructor TfraPrijemRobe.Create(
  AOwner: TComponent
);
begin
  inherited Create(AOwner);


  // ==========================================================
  // QUERY
  // ==========================================================

  FQryPrijemi :=
    TFDQuery.Create(Self);

  FQryPrijemi.Connection :=
    frmLogin.FDConnection1;


  // ==========================================================
  // DATASOURCE
  // ==========================================================

  FDsPrijemi :=
    TDataSource.Create(Self);

  FDsPrijemi.DataSet :=
    FQryPrijemi;


  // ==========================================================
  // DBGRID
  // ==========================================================

  dbgPrijemi.DataSource :=
    FDsPrijemi;

  dbgPrijemi.ReadOnly :=
    True;

  dbgPrijemi.Options :=
    dbgPrijemi.Options + [dgRowSelect];


  // ==========================================================
  // NARUDŽBENICA
  // ==========================================================

  cmbNarudzbenica.Style :=
    csDropDownList;

  cmbNarudzbenica.OnChange :=
    cmbNarudzbenicaChange;


  // ==========================================================
  // NOVO - JEDINICA MERE
  // ==========================================================

  cmbJedinicaMere.Style :=
    csDropDownList;

  // Jedinicu ne bira korisnik proizvoljno.
  // Program je automatski učitava iz materijala.
  cmbJedinicaMere.Enabled :=
    False;


  // ==========================================================
  // STATUS
  // ==========================================================

  cmbStatusPrijema.Style :=
    csDropDownList;


  // ==========================================================
  // DUGME
  // ==========================================================

  btnEvidentirajPrijem.OnClick :=
    btnEvidentirajPrijemClick;


  // ==========================================================
  // VALUE LIST EDITOR
  // ==========================================================

  vleNarudzbenica.DisplayOptions :=
    vleNarudzbenica.DisplayOptions +
    [doColumnTitles];


  vleNarudzbenica.TitleCaptions.Clear;

  vleNarudzbenica.TitleCaptions.Add(
    'Podatak'
  );

  vleNarudzbenica.TitleCaptions.Add(
    'Vrednost'
  );


  // Ne dozvoljavamo menjanje podataka
  vleNarudzbenica.Options :=
    vleNarudzbenica.Options -
    [goEditing];


  // ==========================================================
  // POČETNO STANJE
  // ==========================================================

  FKorisnikID :=
    0;


  FNarudzbenicaID :=
    0;

  FMaterijalID :=
    0;


  FNarucenaKolicina :=
    0;

  FVecPrimljeno :=
    0;

  FPreostalo :=
    0;


  FJedinica :=
    '';


  UcitajStatusePrijema;

  OcistiDetaljeNarudzbenice;

  Osvezi;

end;


// ============================================================
// OSVEŽAVANJE
// ============================================================

procedure TfraPrijemRobe.Osvezi;
begin

  UcitajNarudzbenice;

  UcitajPrijeme;

end;


// ============================================================
// STATUSI PRIJEMA
// ============================================================

procedure TfraPrijemRobe.UcitajStatusePrijema;
begin

  cmbStatusPrijema.Items.Clear;


  cmbStatusPrijema.Items.Add(
    'U redu'
  );


  cmbStatusPrijema.Items.Add(
    'Delimično'
  );


  cmbStatusPrijema.Items.Add(
    'Oštećeno'
  );


  cmbStatusPrijema.ItemIndex :=
    0;

end;


// ============================================================
// PRETVARANJE STATUSA ZA BAZU
// ============================================================

function TfraPrijemRobe.StatusPrikazUDB(
  const AStatus: string
): string;
begin

  if SameText(
    AStatus,
    'U redu'
  ) then
    Result :=
      'ok'


  else if SameText(
    AStatus,
    'Delimično'
  ) then
    Result :=
      'partial'


  else if SameText(
    AStatus,
    'Oštećeno'
  ) then
    Result :=
      'damaged'


  else
    Result :=
      '';

end;


// ============================================================
// UČITAVANJE NARUDŽBENICA
// ============================================================

procedure TfraPrijemRobe.UcitajNarudzbenice;
var
  Q: TFDQuery;

  PrethodniID: Integer;
  I: Integer;
begin

  PrethodniID :=
    FNarudzbenicaID;


  cmbNarudzbenica.Items.Clear;

  cmbNarudzbenica.ItemIndex :=
    -1;


  Q :=
    TFDQuery.Create(nil);

  try

    Q.Connection :=
      frmLogin.FDConnection1;


    Q.SQL.Text :=

      'SELECT ' +

      'ord.id, ' +


      // ======================================================
      // ŠIFRA NARUDŽBENICE
      // ======================================================

      'CAST(' +

        '''N-'' || ' +
        'printf(''%04d'', ord.id) ' +

      'AS VARCHAR(30)) ' +
      'AS sifra, ' +


      // ======================================================
      // MATERIJAL
      // ======================================================

      'CAST(m.name AS VARCHAR(150)) ' +
      'AS materijal, ' +


      // ======================================================
      // DOBAVLJAČ
      // ======================================================

      'CAST(s.name AS VARCHAR(150)) ' +
      'AS dobavljac ' +


      // ======================================================
      // TABELE
      // ======================================================

      'FROM orders ord ' +

      'INNER JOIN requests r ' +
      'ON r.id = ord.request_id ' +

      'INNER JOIN materials m ' +
      'ON m.id = r.material_id ' +

      'INNER JOIN suppliers s ' +
      'ON s.id = ord.supplier_id ' +


      // ======================================================
      // NARUDŽBENICE KOJE MOGU DA SE PRIMAJU
      // ======================================================

      'WHERE ord.status IN (' +

        '''sent'', ' +
        '''confirmed'', ' +
        '''in_progress'', ' +
        '''delivered''' +

      ') ' +


      'ORDER BY ' +
      'ord.expected_date ASC, ' +
      'ord.id ASC';


    Q.Open;


    // ========================================================
    // COMBOBOX
    // ========================================================

    while not Q.Eof do
    begin

      cmbNarudzbenica.Items.AddObject(

        Q.FieldByName(
          'sifra'
        ).AsString +

        ' - ' +

        Q.FieldByName(
          'materijal'
        ).AsString +

        ' - ' +

        Q.FieldByName(
          'dobavljac'
        ).AsString,

        TObject(
          NativeInt(
            Q.FieldByName(
              'id'
            ).AsInteger
          )
        )

      );


      Q.Next;

    end;


  finally

    Q.Free;

  end;


  // ==========================================================
  // ZADRŽAVAMO PRETHODNU NARUDŽBENICU AKO POSTOJI
  // ==========================================================

  if PrethodniID <> 0 then
  begin

    for I := 0 to cmbNarudzbenica.Items.Count - 1 do
    begin

      if Integer(
        NativeInt(
          cmbNarudzbenica.Items.Objects[I]
        )
      ) = PrethodniID then
      begin

        cmbNarudzbenica.ItemIndex :=
          I;

        Break;

      end;

    end;

  end;


  // ==========================================================
  // AKO NEMA PRETHODNE, BIRAMO PRVU
  // ==========================================================

  if (cmbNarudzbenica.ItemIndex = -1) and
     (cmbNarudzbenica.Items.Count > 0) then
  begin

    cmbNarudzbenica.ItemIndex :=
      0;

  end;


  // ==========================================================
  // DETALJI
  // ==========================================================

  if cmbNarudzbenica.ItemIndex >= 0 then
  begin

    cmbNarudzbenicaChange(
      cmbNarudzbenica
    );

  end
  else
  begin

    OcistiDetaljeNarudzbenice;

  end;

end;


// ============================================================
// PROMENA IZABRANE NARUDŽBENICE
// ============================================================

procedure TfraPrijemRobe.cmbNarudzbenicaChange(
  Sender: TObject
);
begin

  if cmbNarudzbenica.ItemIndex < 0 then
  begin

    OcistiDetaljeNarudzbenice;

    Exit;

  end;


  FNarudzbenicaID :=
    Integer(
      NativeInt(
        cmbNarudzbenica.Items.Objects[
          cmbNarudzbenica.ItemIndex
        ]
      )
    );


  UcitajDetaljeNarudzbenice;

end;


// ============================================================
// UČITAVANJE DETALJA NARUDŽBENICE
// ============================================================

procedure TfraPrijemRobe.UcitajDetaljeNarudzbenice;
var
  Q: TFDQuery;

  Materijal: string;
  Dobavljac: string;
  Datum: string;
begin

  if FNarudzbenicaID = 0 then
  begin

    OcistiDetaljeNarudzbenice;

    Exit;

  end;


  Q :=
    TFDQuery.Create(nil);

  try

    Q.Connection :=
      frmLogin.FDConnection1;


    Q.SQL.Text :=

      'SELECT ' +

      // ======================================================
      // MATERIJAL ID
      // ======================================================

      'r.material_id, ' +


      // ======================================================
      // MATERIJAL
      // ======================================================

      'CAST(m.name AS VARCHAR(150)) ' +
      'AS materijal, ' +


      // ======================================================
      // JEDINICA MERE
      // ======================================================

      'CAST(m.unit AS VARCHAR(50)) ' +
      'AS jedinica, ' +


      // ======================================================
      // DOBAVLJAČ
      // ======================================================

      'CAST(s.name AS VARCHAR(150)) ' +
      'AS dobavljac, ' +


      // ======================================================
      // NARUČENA KOLIČINA
      // ======================================================

      'r.quantity AS narucena_kolicina, ' +


      // ======================================================
      // VEĆ PRIMLJENO
      //
      // Oštećena roba se ne računa kao prihvaćena.
      // ======================================================

      'COALESCE((' +

        'SELECT SUM(d.received_quantity) ' +

        'FROM deliveries d ' +

        'WHERE d.order_id = ord.id ' +

        'AND d.status IN (' +
          '''ok'', ' +
          '''partial''' +
        ')' +

      '), 0) ' +
      'AS vec_primljeno, ' +


      // ======================================================
      // OČEKIVANI DATUM
      // ======================================================

      'CAST(' +

        'CASE ' +

          'WHEN ord.expected_date IS NULL ' +
          'THEN '''' ' +

          'ELSE ' +
          'strftime(''%d.%m.%Y'', ord.expected_date) ' +

        'END ' +

      'AS VARCHAR(30)) ' +
      'AS datum_prikaz ' +


      // ======================================================
      // TABELE
      // ======================================================

      'FROM orders ord ' +

      'INNER JOIN requests r ' +
      'ON r.id = ord.request_id ' +

      'INNER JOIN materials m ' +
      'ON m.id = r.material_id ' +

      'INNER JOIN suppliers s ' +
      'ON s.id = ord.supplier_id ' +

      'WHERE ord.id = :order_id';


    Q.ParamByName(
      'order_id'
    ).AsInteger :=
      FNarudzbenicaID;


    Q.Open;


    if Q.IsEmpty then
    begin

      OcistiDetaljeNarudzbenice;

      Exit;

    end;


    // ========================================================
    // PODACI
    // ========================================================

    FMaterijalID :=
      Q.FieldByName(
        'material_id'
      ).AsInteger;


    Materijal :=
      Q.FieldByName(
        'materijal'
      ).AsString;


    // ========================================================
    // JEDINICA MERE
    // ========================================================

    FJedinica :=
      Q.FieldByName(
        'jedinica'
      ).AsString;


    // NOVO
    // Automatski prikazujemo jedinicu odgovarajućeg materijala.

    cmbJedinicaMere.Items.Clear;

    cmbJedinicaMere.Items.Add(
      FJedinica
    );

    cmbJedinicaMere.ItemIndex :=
      0;

    cmbJedinicaMere.Enabled :=
      True;


    // ========================================================
    // OSTALI PODACI
    // ========================================================

    Dobavljac :=
      Q.FieldByName(
        'dobavljac'
      ).AsString;


    FNarucenaKolicina :=
      Q.FieldByName(
        'narucena_kolicina'
      ).AsFloat;


    FVecPrimljeno :=
      Q.FieldByName(
        'vec_primljeno'
      ).AsFloat;


    // ========================================================
    // PREOSTALO
    // ========================================================

    FPreostalo :=
      FNarucenaKolicina -
      FVecPrimljeno;


    if FPreostalo < 0 then
      FPreostalo :=
        0;


    Datum :=
      Q.FieldByName(
        'datum_prikaz'
      ).AsString;


    // ========================================================
    // VALUE LIST EDITOR
    // ========================================================

    vleNarudzbenica.Strings.Clear;


    vleNarudzbenica.InsertRow(
      'Materijal',
      Materijal,
      True
    );


    vleNarudzbenica.InsertRow(
      'Dobavljač',
      Dobavljac,
      True
    );


    vleNarudzbenica.InsertRow(

      'Naručena količina',

      FormatFloat(
        '0.##',
        FNarucenaKolicina
      ) +

      ' ' +
      FJedinica,

      True

    );


    vleNarudzbenica.InsertRow(

      'Već primljeno',

      FormatFloat(
        '0.##',
        FVecPrimljeno
      ) +

      ' ' +
      FJedinica,

      True

    );


    vleNarudzbenica.InsertRow(

      'Preostalo',

      FormatFloat(
        '0.##',
        FPreostalo
      ) +

      ' ' +
      FJedinica,

      True

    );


    vleNarudzbenica.InsertRow(
      'Očekivani datum',
      Datum,
      True
    );


    // ========================================================
    // DUGME
    // ========================================================

    btnEvidentirajPrijem.Enabled :=
      FPreostalo > 0;


  finally

    Q.Free;

  end;

end;


// ============================================================
// ČIŠĆENJE DETALJA
// ============================================================

procedure TfraPrijemRobe.OcistiDetaljeNarudzbenice;
begin

  FNarudzbenicaID :=
    0;

  FMaterijalID :=
    0;


  FNarucenaKolicina :=
    0;

  FVecPrimljeno :=
    0;

  FPreostalo :=
    0;


  FJedinica :=
    '';


  // ==========================================================
  // NOVO - JEDINICA MERE
  // ==========================================================

  cmbJedinicaMere.Items.Clear;

  cmbJedinicaMere.ItemIndex :=
    -1;

  cmbJedinicaMere.Enabled :=
    False;


  // ==========================================================
  // VALUE LIST
  // ==========================================================

  vleNarudzbenica.Strings.Clear;


  vleNarudzbenica.InsertRow(
    'Materijal',
    '-',
    True
  );


  vleNarudzbenica.InsertRow(
    'Dobavljač',
    '-',
    True
  );


  vleNarudzbenica.InsertRow(
    'Naručena količina',
    '-',
    True
  );


  vleNarudzbenica.InsertRow(
    'Već primljeno',
    '-',
    True
  );


  vleNarudzbenica.InsertRow(
    'Preostalo',
    '-',
    True
  );


  vleNarudzbenica.InsertRow(
    'Očekivani datum',
    '-',
    True
  );


  btnEvidentirajPrijem.Enabled :=
    False;

end;


// ============================================================
// ČITANJE PRIMLJENE KOLIČINE
// ============================================================

function TfraPrijemRobe.ProcitajKolicinu(
  out AKolicina: Double
): Boolean;
var
  S: string;
  FS: TFormatSettings;
begin

  Result :=
    False;


  // NOVO
  S :=
    Trim(
      edtPrimljenaKolicina.Text
    );


  // ==========================================================
  // PRAZNO
  // ==========================================================

  if S = '' then
  begin

    ShowMessage(
      'Unesite primljenu količinu.'
    );


    edtPrimljenaKolicina.SetFocus;

    Exit;

  end;


  FS :=
    TFormatSettings.Create;


  // ==========================================================
  // PODRŽAVAMO I:
  //
  // 125,5
  // 125.5
  // ==========================================================

  if FS.DecimalSeparator = ',' then
  begin

    S :=
      StringReplace(
        S,
        '.',
        ',',
        [rfReplaceAll]
      );

  end
  else
  begin

    S :=
      StringReplace(
        S,
        ',',
        '.',
        [rfReplaceAll]
      );

  end;


  // ==========================================================
  // KONVERZIJA
  // ==========================================================

  if not TryStrToFloat(
    S,
    AKolicina,
    FS
  ) then
  begin

    ShowMessage(
      'Primljena količina nije pravilno uneta.'
    );


    edtPrimljenaKolicina.SetFocus;

    Exit;

  end;


  // ==========================================================
  // KOLIČINA > 0
  // ==========================================================

  if AKolicina <= 0 then
  begin

    ShowMessage(
      'Primljena količina mora biti veća od 0.'
    );


    edtPrimljenaKolicina.SetFocus;

    Exit;

  end;


  // ==========================================================
  // NE SME PREKO PREOSTALE KOLIČINE
  // ==========================================================

  if AKolicina > FPreostalo then
  begin

    ShowMessage(

      'Primljena količina ne može biti veća od preostale količine.' +

      sLineBreak +
      sLineBreak +

      'Preostalo: ' +

      FormatFloat(
        '0.##',
        FPreostalo
      ) +

      ' ' +
      FJedinica

    );


    edtPrimljenaKolicina.SetFocus;

    Exit;

  end;


  Result :=
    True;

end;


// ============================================================
// EVIDENTIRAJ PRIJEM
// ============================================================

procedure TfraPrijemRobe.btnEvidentirajPrijemClick(
  Sender: TObject
);
var
  Q: TFDQuery;

  Kolicina: Double;
  StatusDB: string;

  NovoPrimljeno: Double;
begin

  // ==========================================================
  // NARUDŽBENICA
  // ==========================================================

  if FNarudzbenicaID = 0 then
  begin

    ShowMessage(
      'Izaberite narudžbenicu.'
    );

    Exit;

  end;


  // ==========================================================
  // MAGACIONER
  // ==========================================================

  if FKorisnikID = 0 then
  begin

    ShowMessage(
      'Korisnik nije pravilno prijavljen.'
    );

    Exit;

  end;


  // ==========================================================
  // JEDINICA MERE
  // ==========================================================

  if cmbJedinicaMere.ItemIndex < 0 then
  begin

    ShowMessage(
      'Jedinica mere nije određena.'
    );

    Exit;

  end;


  // ==========================================================
  // KOLIČINA
  // ==========================================================

  if not ProcitajKolicinu(
    Kolicina
  ) then
    Exit;


  // ==========================================================
  // STATUS
  // ==========================================================

  if cmbStatusPrijema.ItemIndex < 0 then
  begin

    ShowMessage(
      'Izaberite status prijema.'
    );

    Exit;

  end;


  StatusDB :=
    StatusPrikazUDB(
      cmbStatusPrijema.Text
    );


  if StatusDB = '' then
  begin

    ShowMessage(
      'Status prijema nije validan.'
    );

    Exit;

  end;


  // ==========================================================
  // POTVRDA
  // ==========================================================

  if MessageDlg(

    'Da li želite da evidentirate prijem?' +

    sLineBreak +
    sLineBreak +

    'Primljena količina: ' +

    FormatFloat(
      '0.##',
      Kolicina
    ) +

    ' ' +
    FJedinica +

    sLineBreak +

    'Status: ' +
    cmbStatusPrijema.Text,

    mtConfirmation,
    [mbYes, mbNo],
    0

  ) <> mrYes then
    Exit;


  Q :=
    TFDQuery.Create(nil);

  try

    Q.Connection :=
      frmLogin.FDConnection1;


    try

      // ======================================================
      // TRANSAKCIJA
      // ======================================================

      frmLogin.FDConnection1.StartTransaction;


      // ======================================================
      // 1. DELIVERIES
      // ======================================================

      Q.SQL.Text :=

        'INSERT INTO deliveries ' +

        '(' +
          'order_id, ' +
          'received_quantity, ' +
          'status, ' +
          'note, ' +
          'received_by' +
        ') ' +

        'VALUES ' +

        '(' +
          ':order_id, ' +
          ':received_quantity, ' +
          ':status, ' +
          ':note, ' +
          ':received_by' +
        ')';


      Q.ParamByName(
        'order_id'
      ).AsInteger :=
        FNarudzbenicaID;


      Q.ParamByName(
        'received_quantity'
      ).AsFloat :=
        Kolicina;


      Q.ParamByName(
        'status'
      ).AsString :=
        StatusDB;


      Q.ParamByName(
        'note'
      ).AsString :=
        Trim(
          memNapomena.Text
        );


      Q.ParamByName(
        'received_by'
      ).AsInteger :=
        FKorisnikID;


      Q.ExecSQL;


      // ======================================================
      // 2. MAGACIN
      //
      // OŠTEĆENA ROBA NE POVEĆAVA STANJE.
      // ======================================================

      if not SameText(
        StatusDB,
        'damaged'
      ) then
      begin

        Q.Close;


        Q.SQL.Text :=

          'UPDATE materials ' +

          'SET current_quantity = ' +
          'current_quantity + :quantity ' +

          'WHERE id = :material_id';


        Q.ParamByName(
          'quantity'
        ).AsFloat :=
          Kolicina;


        Q.ParamByName(
          'material_id'
        ).AsInteger :=
          FMaterijalID;


        Q.ExecSQL;

      end;


      // ======================================================
      // 3. NOVA UKUPNO PRIMLJENA KOLIČINA
      // ======================================================

      NovoPrimljeno :=
        FVecPrimljeno;


      // Oštećena roba se ne računa kao prihvaćena.
      if not SameText(
        StatusDB,
        'damaged'
      ) then
      begin

        NovoPrimljeno :=
          NovoPrimljeno +
          Kolicina;

      end;


      // ======================================================
      // 4. STATUS NARUDŽBENICE
      // ======================================================

      Q.Close;


      if NovoPrimljeno >=
         FNarucenaKolicina then
      begin

        // Kompletno primljena
        Q.SQL.Text :=

          'UPDATE orders ' +

          'SET status = ''completed'' ' +

          'WHERE id = :id';

      end
      else
      begin

        // Još čekamo ostatak
        Q.SQL.Text :=

          'UPDATE orders ' +

          'SET status = ''in_progress'' ' +

          'WHERE id = :id';

      end;


      Q.ParamByName(
        'id'
      ).AsInteger :=
        FNarudzbenicaID;


      Q.ExecSQL;


      // ======================================================
      // COMMIT
      // ======================================================

      frmLogin.FDConnection1.Commit;


      // ======================================================
      // PORUKA
      // ======================================================

      if NovoPrimljeno >=
         FNarucenaKolicina then
      begin

        ShowMessage(

          'Prijem je uspešno evidentiran.' +

          sLineBreak +
          sLineBreak +

          'Kompletna naručena količina je primljena.' +

          sLineBreak +

          'Narudžbenica je završena.'

        );

      end
      else
      begin

        ShowMessage(

          'Prijem je uspešno evidentiran.' +

          sLineBreak +
          sLineBreak +

          'Preostalo za prijem: ' +

          FormatFloat(
            '0.##',
            FNarucenaKolicina - NovoPrimljeno
          ) +

          ' ' +
          FJedinica

        );

      end;


      // ======================================================
      // ČIŠĆENJE UNOSA
      // ======================================================

      edtPrimljenaKolicina.Clear;


      memNapomena.Clear;


      cmbStatusPrijema.ItemIndex :=
        0;


      // ======================================================
      // OSVEŽAVANJE
      // ======================================================

      UcitajNarudzbenice;

      UcitajPrijeme;


    except

      on E: Exception do
      begin

        if frmLogin.FDConnection1.InTransaction then
        begin

          frmLogin.FDConnection1.Rollback;

        end;


        ShowMessage(

          'Greška prilikom evidentiranja prijema:' +

          sLineBreak +

          E.Message

        );

      end;

    end;


  finally

    Q.Free;

  end;

end;


// ============================================================
// UČITAVANJE ISTORIJE PRIJEMA
// ============================================================

procedure TfraPrijemRobe.UcitajPrijeme;
begin

  FQryPrijemi.Close;


  FQryPrijemi.SQL.Text :=

    'SELECT ' +

    'd.id, ' +


    // ========================================================
    // NARUDŽBENICA
    // ========================================================

    'CAST(' +

      '''N-'' || ' +
      'printf(''%04d'', ord.id) ' +

    'AS VARCHAR(30)) ' +
    'AS narudzbenica, ' +


    // ========================================================
    // MATERIJAL
    // ========================================================

    'CAST(m.name AS VARCHAR(150)) ' +
    'AS materijal, ' +


    // ========================================================
    // PRIMLJENO
    // ========================================================

    'CAST(' +

      'printf(''%g'', d.received_quantity) || ' +
      ''' '' || m.unit ' +

    'AS VARCHAR(50)) ' +
    'AS primljeno, ' +


    // ========================================================
    // STATUS
    // ========================================================

    'CAST(' +

      'CASE d.status ' +

        'WHEN ''ok'' ' +
        'THEN ''U redu'' ' +

        'WHEN ''partial'' ' +
        'THEN ''Delimično'' ' +

        'WHEN ''damaged'' ' +
        'THEN ''Oštećeno'' ' +

        'ELSE d.status ' +

      'END ' +

    'AS VARCHAR(50)) ' +
    'AS status_prikaz, ' +


    // ========================================================
    // DATUM
    // ========================================================

    'CAST(' +

      'strftime(' +
        '''%d.%m.%Y %H:%M'', ' +
        'd.received_at' +
      ') ' +

    'AS VARCHAR(50)) ' +
    'AS datum_prikaz, ' +


    // ========================================================
    // MAGACIONER
    // ========================================================

    'CAST(u.name AS VARCHAR(150)) ' +
    'AS magacioner ' +


    // ========================================================
    // TABELE
    // ========================================================

    'FROM deliveries d ' +

    'INNER JOIN orders ord ' +
    'ON ord.id = d.order_id ' +

    'INNER JOIN requests r ' +
    'ON r.id = ord.request_id ' +

    'INNER JOIN materials m ' +
    'ON m.id = r.material_id ' +

    'INNER JOIN users u ' +
    'ON u.id = d.received_by ' +


    // ========================================================
    // SORTIRANJE
    // ========================================================

    'ORDER BY ' +
    'd.received_at DESC, ' +
    'd.id DESC';


  try

    FQryPrijemi.Open;


    PodesiKolone;


  except

    on E: Exception do
    begin

      ShowMessage(

        'Greška prilikom učitavanja prijema:' +

        sLineBreak +

        E.Message

      );

    end;

  end;

end;


// ============================================================
// KOLONE TABELE
// ============================================================

procedure TfraPrijemRobe.PodesiKolone;
begin

  dbgPrijemi.Columns.Clear;


  // ==========================================================
  // NARUDŽBENICA
  // ==========================================================

  with dbgPrijemi.Columns.Add do
  begin

    FieldName :=
      'narudzbenica';

    Title.Caption :=
      'Narudžbenica';

    Width :=
      100;

  end;


  // ==========================================================
  // MATERIJAL
  // ==========================================================

  with dbgPrijemi.Columns.Add do
  begin

    FieldName :=
      'materijal';

    Title.Caption :=
      'Materijal';

    Width :=
      150;

  end;


  // ==========================================================
  // PRIMLJENO
  // ==========================================================

  with dbgPrijemi.Columns.Add do
  begin

    FieldName :=
      'primljeno';

    Title.Caption :=
      'Primljeno';

    Width :=
      90;

  end;


  // ==========================================================
  // STATUS
  // ==========================================================

  with dbgPrijemi.Columns.Add do
  begin

    FieldName :=
      'status_prikaz';

    Title.Caption :=
      'Status';

    Width :=
      90;

  end;


  // ==========================================================
  // DATUM
  // ==========================================================

  with dbgPrijemi.Columns.Add do
  begin

    FieldName :=
      'datum_prikaz';

    Title.Caption :=
      'Datum';

    Width :=
      130;

  end;


  // ==========================================================
  // MAGACIONER
  // ==========================================================

  with dbgPrijemi.Columns.Add do
  begin

    FieldName :=
      'magacioner';

    Title.Caption :=
      'Magacioner';

    Width :=
      140;

  end;

end;


// ============================================================
// OTVORI ZA KONKRETNU NARUDŽBENICU
// ============================================================

procedure TfraPrijemRobe.OtvoriZaNarudzbenicu(
  ANarudzbenicaID: Integer
);
var
  I: Integer;
begin

  UcitajNarudzbenice;


  for I := 0 to cmbNarudzbenica.Items.Count - 1 do
  begin

    if Integer(
      NativeInt(
        cmbNarudzbenica.Items.Objects[I]
      )
    ) = ANarudzbenicaID then
    begin

      cmbNarudzbenica.ItemIndex :=
        I;


      cmbNarudzbenicaChange(
        cmbNarudzbenica
      );


      Exit;

    end;

  end;


  ShowMessage(
    'Izabrana narudžbenica trenutno nije dostupna za prijem.'
  );

end;

end.
