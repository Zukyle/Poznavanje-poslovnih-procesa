unit uMojiZahtevi;

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
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
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
  TfraMojiZahtevi = class(TFrame)

    pnlHeader: TPanel;
    lblNaslov: TLabel;
    lblOpis: TLabel;

    pnlTabela: TPanel;
    lblListaNaslov: TLabel;

    pnlDetalji: TPanel;
    lblDetaljiNaslov: TLabel;
    lblIDZahteva: TLabel;

    dbgZahtevi: TDBGrid;

    qryZahtevi: TFDQuery;
    dsZahtevi: TDataSource;

    lblMaterijalNaslov: TLabel;
    lblMaterijalVrednost: TLabel;

    lblKolicinaNaslov: TLabel;
    lblKolicinaVrednost: TLabel;

    lblPrioritetNaslov: TLabel;
    lblPrioritetVrednost: TLabel;

    lblDatumNaslov: TLabel;
    lblDatumVrednost: TLabel;

    lblRazlogNaslov: TLabel;
    memRazlog: TMemo;

    lblStatusNaslov: TLabel;
    lblStatusVrednost: TLabel;

    btnOpozoviZahtev: TButton;

  private

    // ID trenutno prijavljenog korisnika
    FKorisnikID: Integer;

    procedure SetKorisnikID(const Value: Integer);

    procedure UcitajZahteve;
    procedure PodesiKolone;

    procedure qryZahteviAfterScroll(DataSet: TDataSet);

    procedure PrikaziIzabraniZahtev;
    procedure OcistiDetalje;

    // NOVO
    procedure btnOpozoviZahtevClick(Sender: TObject);

  public

    constructor Create(AOwner: TComponent); override;

    property KorisnikID: Integer
      read FKorisnikID
      write SetKorisnikID;

  end;

implementation

uses
  uLogin;

{$R *.dfm}


// ============================================================
// KREIRANJE FRAME-A
// ============================================================

constructor TfraMojiZahtevi.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FKorisnikID := 0;

  // ==========================================================
  // BAZA
  // ==========================================================

  qryZahtevi.Connection := frmLogin.FDConnection1;

  dsZahtevi.DataSet := qryZahtevi;
  dbgZahtevi.DataSource := dsZahtevi;

  // Tabela samo za pregled
  dbgZahtevi.ReadOnly := True;

  // Kada promenimo red u tabeli
  qryZahtevi.AfterScroll :=
    qryZahteviAfterScroll;

  // Klik na opozivanje
  btnOpozoviZahtev.OnClick :=
    btnOpozoviZahtevClick;

  // Memo samo za čitanje
  memRazlog.ReadOnly := True;

  OcistiDetalje;
end;


// ============================================================
// POSTAVLJANJE KORISNIKA
// ============================================================

procedure TfraMojiZahtevi.SetKorisnikID(const Value: Integer);
begin
  FKorisnikID := Value;

  if FKorisnikID > 0 then
    UcitajZahteve;
end;


// ============================================================
// UČITAVANJE ZAHTEVA
// ============================================================

procedure TfraMojiZahtevi.UcitajZahteve;
begin
  qryZahtevi.Close;

  qryZahtevi.SQL.Text :=

    'SELECT ' +

    // Interni ID
    'r.id, ' +

    // Šifra zahteva
    '''Z-'' || ' +
    'strftime(''%Y'', r.created_at) || ' +
    '''-'' || ' +
    'printf(''%04d'', r.id) AS sifra, ' +

    // Materijal
    'CAST(m.name AS VARCHAR(100)) AS materijal, ' +

    // Količina + jedinica mere
    'CAST(r.quantity AS TEXT) || '' '' || ' +
    'CAST(m.unit AS VARCHAR(20)) AS kolicina, ' +

    // Prioritet
    'CAST(r.priority AS VARCHAR(20)) AS prioritet, ' +

    // Status za prikaz
    'CAST(CASE r.status ' +
    '  WHEN ''pending'' THEN ''Na čekanju'' ' +
    '  WHEN ''approved'' THEN ''Odobren'' ' +
    '  WHEN ''rejected'' THEN ''Odbijen'' ' +
    '  ELSE r.status ' +
    'END AS VARCHAR(30)) AS status_prikaz, ' +

    // Datum kreiranja
    'strftime(''%d.%m.%Y'', r.created_at) AS datum, ' +

    // Sirovi status
    'CAST(r.status AS VARCHAR(20)) AS status_raw, ' +

    // Obrazloženje
    'CAST(r.reason AS VARCHAR(1000)) AS reason, ' +

    // Datum potrebe
    'r.needed_by, ' +

    // Komentar menadžera
    'CAST(r.manager_comment AS VARCHAR(1000)) ' +
    'AS manager_comment ' +

    'FROM requests r ' +

    'INNER JOIN materials m ' +
    'ON m.id = r.material_id ' +

    'WHERE r.user_id = :user_id ' +

    'ORDER BY r.created_at DESC, r.id DESC';


  qryZahtevi.ParamByName('user_id').AsInteger :=
    FKorisnikID;

  try

    qryZahtevi.Open;

    PodesiKolone;

    PrikaziIzabraniZahtev;

  except

    on E: Exception do
    begin
      ShowMessage(
        'Greška prilikom učitavanja zahteva:' +
        sLineBreak +
        E.Message
      );
    end;

  end;
end;


// ============================================================
// PODEŠAVANJE KOLONA
// ============================================================

procedure TfraMojiZahtevi.PodesiKolone;
begin

  dbgZahtevi.Columns.Clear;


  // ==========================================================
  // ID
  // ==========================================================

  with dbgZahtevi.Columns.Add do
  begin
    FieldName := 'sifra';
    Title.Caption := 'ID';
    Width := 105;
  end;


  // ==========================================================
  // MATERIJAL
  // ==========================================================

  with dbgZahtevi.Columns.Add do
  begin
    FieldName := 'materijal';
    Title.Caption := 'Materijal';
    Width := 160;
  end;


  // ==========================================================
  // KOLIČINA
  // ==========================================================

  with dbgZahtevi.Columns.Add do
  begin
    FieldName := 'kolicina';
    Title.Caption := 'Količina';
    Width := 90;
  end;


  // ==========================================================
  // PRIORITET
  // ==========================================================

  with dbgZahtevi.Columns.Add do
  begin
    FieldName := 'prioritet';
    Title.Caption := 'Prioritet';
    Width := 90;
  end;


  // ==========================================================
  // STATUS
  // ==========================================================

  with dbgZahtevi.Columns.Add do
  begin
    FieldName := 'status_prikaz';
    Title.Caption := 'Status';
    Width := 105;
  end;


  // ==========================================================
  // DATUM
  // ==========================================================

  with dbgZahtevi.Columns.Add do
  begin
    FieldName := 'datum';
    Title.Caption := 'Datum';
    Width := 90;
  end;

end;


// ============================================================
// PROMENA REDA
// ============================================================

procedure TfraMojiZahtevi.qryZahteviAfterScroll(
  DataSet: TDataSet
);
begin
  PrikaziIzabraniZahtev;
end;


// ============================================================
// PRIKAZ DETALJA IZABRANOG ZAHTEVA
// ============================================================

procedure TfraMojiZahtevi.PrikaziIzabraniZahtev;
var
  StatusRaw: string;
begin

  // Ako nema zahteva
  if (not qryZahtevi.Active) or
     qryZahtevi.IsEmpty then
  begin
    OcistiDetalje;
    Exit;
  end;


  // ==========================================================
  // ID
  // ==========================================================

  lblIDZahteva.Caption :=
    qryZahtevi.FieldByName('sifra').AsString;


  // ==========================================================
  // MATERIJAL
  // ==========================================================

  lblMaterijalVrednost.Caption :=
    qryZahtevi.FieldByName('materijal').AsString;


  // ==========================================================
  // KOLIČINA
  // ==========================================================

  lblKolicinaVrednost.Caption :=
    qryZahtevi.FieldByName('kolicina').AsString;


  // ==========================================================
  // PRIORITET
  // ==========================================================

  lblPrioritetVrednost.Caption :=
    qryZahtevi.FieldByName('prioritet').AsString;


  // ==========================================================
  // DATUM
  // ==========================================================

  lblDatumVrednost.Caption :=
    qryZahtevi.FieldByName('datum').AsString;


  // ==========================================================
  // OBRAZLOŽENJE
  // ==========================================================

  memRazlog.Lines.Text :=
    qryZahtevi.FieldByName('reason').AsString;


  // ==========================================================
  // STATUS
  // ==========================================================

  lblStatusVrednost.Caption :=
    qryZahtevi.FieldByName('status_prikaz').AsString;


  // ==========================================================
  // OPOZIVANJE
  // ==========================================================

  StatusRaw :=
    qryZahtevi.FieldByName('status_raw').AsString;

  // Zahtev se može opozvati samo dok je pending
  btnOpozoviZahtev.Enabled :=
    SameText(StatusRaw, 'pending');

end;


// ============================================================
// ČIŠĆENJE DESNOG PANELA
// ============================================================

procedure TfraMojiZahtevi.OcistiDetalje;
begin

  lblIDZahteva.Caption := '-';

  lblMaterijalVrednost.Caption := '-';

  lblKolicinaVrednost.Caption := '-';

  lblPrioritetVrednost.Caption := '-';

  lblDatumVrednost.Caption := '-';

  lblStatusVrednost.Caption := '-';

  memRazlog.Clear;

  btnOpozoviZahtev.Enabled := False;

end;


// ============================================================
// OPOZOVI ZAHTEV
// ============================================================

procedure TfraMojiZahtevi.btnOpozoviZahtevClick(Sender: TObject);
var
  ZahtevID: Integer;
  SifraZahteva: string;
begin

  // Ako nema izabranog zahteva
  if (not qryZahtevi.Active) or qryZahtevi.IsEmpty then
    Exit;


  // ==========================================================
  // PROVERA STATUSA
  // ==========================================================

  // Zahtev može da se opozove samo ako je još pending
  if not SameText(
    qryZahtevi.FieldByName('status_raw').AsString,
    'pending'
  ) then
  begin
    ShowMessage(
      'Možete opozvati samo zahtev koji čeka odobrenje.'
    );
    Exit;
  end;


  // ==========================================================
  // PAMTIMO PODATKE PRE ZATVARANJA QUERY-JA
  // ==========================================================

  ZahtevID :=
    qryZahtevi.FieldByName('id').AsInteger;

  SifraZahteva :=
    qryZahtevi.FieldByName('sifra').AsString;


  // ==========================================================
  // POTVRDA
  // ==========================================================

  if MessageDlg(
    'Da li ste sigurni da želite da opozovete zahtev ' +
    SifraZahteva + '?' +
    sLineBreak + sLineBreak +
    'Zahtev će biti obrisan.',
    mtConfirmation,
    [mbYes, mbNo],
    0
  ) <> mrYes then
    Exit;


  // ==========================================================
  // BRISANJE IZ BAZE
  // ==========================================================

  qryZahtevi.Close;

  qryZahtevi.SQL.Text :=
    'DELETE FROM requests ' +
    'WHERE id = :id ' +
    'AND user_id = :user_id ' +
    'AND status = ''pending''';


  qryZahtevi.ParamByName('id').AsInteger :=
    ZahtevID;

  qryZahtevi.ParamByName('user_id').AsInteger :=
    FKorisnikID;


  try

    qryZahtevi.ExecSQL;

    if qryZahtevi.RowsAffected > 0 then
    begin
      ShowMessage(
        'Zahtev je uspešno opozvan.'
      );
    end
    else
    begin
      ShowMessage(
        'Zahtev nije moguće opozvati.'
      );
    end;

    // Ponovo učitavamo tabelu
    UcitajZahteve;

  except

    on E: Exception do
    begin
      ShowMessage(
        'Greška prilikom opozivanja zahteva:' +
        sLineBreak +
        E.Message
      );

      // Ponovo učitaj tabelu i u slučaju greške
      UcitajZahteve;
    end;

  end;

end;

end.
