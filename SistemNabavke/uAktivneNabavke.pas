unit uAktivneNabavke;

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
  TfraAktivneNabavke = class(TFrame)

    pnlHeader: TPanel;
    lblNaslov: TLabel;
    lblOpis: TLabel;

    pnlTabela: TPanel;
    lblListaNaslov: TLabel;
    dbgNabavke: TDBGrid;

    pnlDetalji: TPanel;
    lblDetaljiNaslov: TLabel;

    lblZahtevNaslov: TLabel;
    lblZahtevVrednost: TLabel;

    lblMaterijalNaslov: TLabel;
    lblMaterijalVrednost: TLabel;

    lblKolicinaNaslov: TLabel;
    lblKolicinaVrednost: TLabel;

    lblDobavljacNaslov: TLabel;
    lblDobavljacVrednost: TLabel;

    lblUkupnoNaslov: TLabel;
    lblUkupnoVrednost: TLabel;

    lblDatumNaslov: TLabel;
    lblDatumVrednost: TLabel;

    lblStatusNaslov: TLabel;
    lblStatusVrednost: TLabel;

    Bevel1: TBevel;

  private

    // NOVO
    FQryNabavke: TFDQuery;
    FDsNabavke: TDataSource;

    // NOVO
    FKorisnikID: Integer;
    FUloga: string;

    procedure UcitajNabavke;
    procedure PodesiKolone;

    procedure qryNabavkeAfterScroll(
      DataSet: TDataSet
    );

    procedure PrikaziDetalje;
    procedure OcistiDetalje;

    function BojaStatusa(
      const AStatus: string
    ): TColor;

  public

    constructor Create(
      AOwner: TComponent
    ); override;

    procedure Osvezi;

    // NOVO
    property KorisnikID: Integer
      read FKorisnikID
      write FKorisnikID;

    property Uloga: string
      read FUloga
      write FUloga;

  end;

implementation

uses
  uLogin;

{$R *.dfm}


// ============================================================
// CONSTRUCTOR
// ============================================================

constructor TfraAktivneNabavke.Create(
  AOwner: TComponent
);
begin
  inherited Create(AOwner);


  // ==========================================================
  // QUERY
  // ==========================================================

  FQryNabavke :=
    TFDQuery.Create(Self);

  FQryNabavke.Connection :=
    frmLogin.FDConnection1;


  // ==========================================================
  // DATASOURCE
  // ==========================================================

  FDsNabavke :=
    TDataSource.Create(Self);

  FDsNabavke.DataSet :=
    FQryNabavke;


  // ==========================================================
  // GRID
  // ==========================================================

  dbgNabavke.DataSource :=
    FDsNabavke;

  dbgNabavke.ReadOnly :=
    True;

  dbgNabavke.Options :=
    dbgNabavke.Options + [dgRowSelect];


  // ==========================================================
  // AFTER SCROLL
  // ==========================================================

  FQryNabavke.AfterScroll :=
    qryNabavkeAfterScroll;


  // ==========================================================
  // STATUS LABEL
  // ==========================================================

  lblStatusVrednost.StyleElements :=
    lblStatusVrednost.StyleElements - [seFont];

  lblStatusVrednost.Font.Style :=
    [fsBold];


  // ==========================================================
  // POČETNO STANJE
  // ==========================================================

  FKorisnikID :=
    0;

  FUloga :=
    '';


  OcistiDetalje;

end;


// ============================================================
// OSVEŽAVANJE
// ============================================================

procedure TfraAktivneNabavke.Osvezi;
begin

  UcitajNabavke;

end;


// ============================================================
// UČITAVANJE AKTIVNIH NABAVKI
// ============================================================

procedure TfraAktivneNabavke.UcitajNabavke;
begin

  FQryNabavke.Close;


  FQryNabavke.SQL.Text :=

    'SELECT ' +

    // ID narudžbenice
    'ord.id AS order_id, ' +


    // ========================================================
    // ŠIFRA ZAHTEVA
    // ========================================================

    'CAST(' +

      '''Z-'' || ' +
      'strftime(''%Y'', r.created_at) || ' +
      '''-'' || ' +
      'printf(''%04d'', r.id) ' +

    'AS VARCHAR(30)) ' +
    'AS sifra_zahteva, ' +


    // ========================================================
    // MATERIJAL
    // ========================================================

    'CAST(m.name AS VARCHAR(150)) ' +
    'AS materijal, ' +


    // ========================================================
    // KOLIČINA
    // ========================================================

    'CAST(' +

      'printf(''%g'', r.quantity) || ' +
      ''' '' || m.unit ' +

    'AS VARCHAR(50)) ' +
    'AS kolicina_prikaz, ' +


    // ========================================================
    // DOBAVLJAČ
    // ========================================================

    'CAST(s.name AS VARCHAR(150)) ' +
    'AS dobavljac, ' +


    // ========================================================
    // UKUPNA CENA
    // ========================================================

    'ord.total_price, ' +

    'CAST(' +

      'printf(''%.2f'', ord.total_price) ' +

    'AS VARCHAR(50)) ' +
    'AS ukupno_prikaz, ' +


    // ========================================================
    // STATUS IZ BAZE
    // ========================================================

    'CAST(ord.status AS VARCHAR(30)) ' +
    'AS status, ' +


    // ========================================================
    // STATUS ZA PRIKAZ
    // ========================================================

    'CAST(' +

      'CASE ord.status ' +

        'WHEN ''created'' ' +
        'THEN ''Kreirana'' ' +

        'WHEN ''sent'' ' +
        'THEN ''Poslata'' ' +

        'WHEN ''confirmed'' ' +
        'THEN ''Potvrđena'' ' +

        'WHEN ''in_progress'' ' +
        'THEN ''U toku'' ' +

        'WHEN ''delivered'' ' +
        'THEN ''Isporučena'' ' +

        'WHEN ''completed'' ' +
        'THEN ''Završena'' ' +

        'ELSE ord.status ' +

      'END ' +

    'AS VARCHAR(50)) ' +
    'AS status_prikaz, ' +


    // ========================================================
    // OČEKIVANI DATUM
    // ========================================================

    'CAST(' +

      'CASE ' +

        'WHEN ord.expected_date IS NULL ' +
        'THEN '''' ' +

        'ELSE ' +
        'strftime(''%d.%m.%Y'', ord.expected_date) ' +

      'END ' +

    'AS VARCHAR(30)) ' +
    'AS datum_prikaz ' +


    // ========================================================
    // TABELE
    // ========================================================

    'FROM orders ord ' +

    'INNER JOIN requests r ' +
    'ON r.id = ord.request_id ' +

    'INNER JOIN materials m ' +
    'ON m.id = r.material_id ' +

    'INNER JOIN suppliers s ' +
    'ON s.id = ord.supplier_id ' +


    // ========================================================
    // SAMO AKTIVNE
    // ========================================================

    'WHERE ord.status <> ''completed'' ';


  // ==========================================================
  // PODNOSILAC VIDI SAMO SVOJE
  // ==========================================================

  if SameText(
    FUloga,
    'Podnosilac'
  ) then
  begin

    FQryNabavke.SQL.Add(
      'AND r.user_id = :user_id '
    );

  end


  // ==========================================================
  // MENADŽER VIDI SVE
  // ==========================================================

  else if SameText(
    FUloga,
    'Menadzer'
  ) then
  begin

    // Ne dodajemo nikakav dodatni WHERE uslov.

  end


  // ==========================================================
  // ZAŠTITA
  // ==========================================================

  else
  begin

    // Ako bi se frame greškom otvorio drugoj ulozi,
    // neće videti tuđe nabavke.
    FQryNabavke.SQL.Add(
      'AND 1 = 0 '
    );

  end;


  // ==========================================================
  // SORTIRANJE
  // ==========================================================

  FQryNabavke.SQL.Add(

    'ORDER BY ' +
    'ord.expected_date ASC, ' +
    'ord.id DESC'

  );


  // ==========================================================
  // PARAMETAR ZA PODNOSIOCA
  // ==========================================================

  if SameText(
    FUloga,
    'Podnosilac'
  ) then
  begin

    FQryNabavke.ParamByName(
      'user_id'
    ).AsInteger :=
      FKorisnikID;

  end;


  try

    FQryNabavke.Open;


    PodesiKolone;


    if not FQryNabavke.IsEmpty then
    begin

      FQryNabavke.First;

      PrikaziDetalje;

    end
    else
    begin

      OcistiDetalje;

    end;


  except

    on E: Exception do
    begin

      ShowMessage(
        'Greška prilikom učitavanja aktivnih nabavki:' +
        sLineBreak +
        E.Message
      );


      OcistiDetalje;

    end;

  end;

end;


// ============================================================
// KOLONE TABELE
// ============================================================

procedure TfraAktivneNabavke.PodesiKolone;
begin

  dbgNabavke.Columns.Clear;


  // ==========================================================
  // ZAHTEV
  // ==========================================================

  with dbgNabavke.Columns.Add do
  begin

    FieldName :=
      'sifra_zahteva';

    Title.Caption :=
      'Zahtev';

    Width :=
      110;

  end;


  // ==========================================================
  // MATERIJAL
  // ==========================================================

  with dbgNabavke.Columns.Add do
  begin

    FieldName :=
      'materijal';

    Title.Caption :=
      'Materijal';

    Width :=
      150;

  end;


  // ==========================================================
  // KOLIČINA
  // ==========================================================

  with dbgNabavke.Columns.Add do
  begin

    FieldName :=
      'kolicina_prikaz';

    Title.Caption :=
      'Količina';

    Width :=
      90;

  end;


  // ==========================================================
  // DOBAVLJAČ
  // ==========================================================

  with dbgNabavke.Columns.Add do
  begin

    FieldName :=
      'dobavljac';

    Title.Caption :=
      'Dobavljač';

    Width :=
      150;

  end;


  // ==========================================================
  // STATUS
  // ==========================================================

  with dbgNabavke.Columns.Add do
  begin

    FieldName :=
      'status_prikaz';

    Title.Caption :=
      'Status';

    Width :=
      100;

  end;


  // ==========================================================
  // DATUM
  // ==========================================================

  with dbgNabavke.Columns.Add do
  begin

    FieldName :=
      'datum_prikaz';

    Title.Caption :=
      'Očekivana isporuka';

    Width :=
      125;

  end;

end;


// ============================================================
// PROMENA REDA
// ============================================================

procedure TfraAktivneNabavke.qryNabavkeAfterScroll(
  DataSet: TDataSet
);
begin

  PrikaziDetalje;

end;


// ============================================================
// PRIKAZ DETALJA
// ============================================================

procedure TfraAktivneNabavke.PrikaziDetalje;
var
  StatusDB: string;
begin

  if (not FQryNabavke.Active) or
     FQryNabavke.IsEmpty then
  begin

    OcistiDetalje;

    Exit;

  end;


  // ==========================================================
  // ZAHTEV
  // ==========================================================

  lblZahtevVrednost.Caption :=
    FQryNabavke.FieldByName(
      'sifra_zahteva'
    ).AsString;


  // ==========================================================
  // MATERIJAL
  // ==========================================================

  lblMaterijalVrednost.Caption :=
    FQryNabavke.FieldByName(
      'materijal'
    ).AsString;


  // ==========================================================
  // KOLIČINA
  // ==========================================================

  lblKolicinaVrednost.Caption :=
    FQryNabavke.FieldByName(
      'kolicina_prikaz'
    ).AsString;


  // ==========================================================
  // DOBAVLJAČ
  // ==========================================================

  lblDobavljacVrednost.Caption :=
    FQryNabavke.FieldByName(
      'dobavljac'
    ).AsString;


  // ==========================================================
  // UKUPNA CENA
  // ==========================================================

  lblUkupnoVrednost.Caption :=

    FormatFloat(
      '#,##0.00',
      FQryNabavke.FieldByName(
        'total_price'
      ).AsFloat
    ) +

    ' RSD';


  // ==========================================================
  // DATUM
  // ==========================================================

  lblDatumVrednost.Caption :=
    FQryNabavke.FieldByName(
      'datum_prikaz'
    ).AsString;


  // ==========================================================
  // STATUS
  // ==========================================================

  lblStatusVrednost.Caption :=
    FQryNabavke.FieldByName(
      'status_prikaz'
    ).AsString;


  StatusDB :=
    FQryNabavke.FieldByName(
      'status'
    ).AsString;


  lblStatusVrednost.Font.Color :=
    BojaStatusa(
      StatusDB
    );

end;


// ============================================================
// ČIŠĆENJE DETALJA
// ============================================================

procedure TfraAktivneNabavke.OcistiDetalje;
begin

  lblZahtevVrednost.Caption :=
    '-';

  lblMaterijalVrednost.Caption :=
    '-';

  lblKolicinaVrednost.Caption :=
    '-';

  lblDobavljacVrednost.Caption :=
    '-';

  lblUkupnoVrednost.Caption :=
    '-';

  lblDatumVrednost.Caption :=
    '-';

  lblStatusVrednost.Caption :=
    '-';


  lblStatusVrednost.Font.Color :=
    clWindowText;

end;


// ============================================================
// BOJA STATUSA
// ============================================================

function TfraAktivneNabavke.BojaStatusa(
  const AStatus: string
): TColor;
begin

  // Kreirana
  if SameText(
    AStatus,
    'created'
  ) then
    Result :=
      RGB(107, 114, 128)


  // Poslata
  else if SameText(
    AStatus,
    'sent'
  ) then
    Result :=
      RGB(37, 99, 235)


  // Potvrđena
  else if SameText(
    AStatus,
    'confirmed'
  ) then
    Result :=
      RGB(5, 150, 105)


  // U toku
  else if SameText(
    AStatus,
    'in_progress'
  ) then
    Result :=
      RGB(245, 158, 11)


  // Isporučena
  else if SameText(
    AStatus,
    'delivered'
  ) then
    Result :=
      RGB(22, 163, 74)


  else
    Result :=
      clWindowText;

end;


// ============================================================
// PRAZAN EVENT IZ DESIGNER-A
// ============================================================

end.
