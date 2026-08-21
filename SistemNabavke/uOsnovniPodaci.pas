unit uOsnovniPodaci;

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
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.ExtCtrls,

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
  TfraOsnovniPodaci = class(TFrame)

    pnlHeader: TPanel;
    lblNaslov: TLabel;
    lblOpis: TLabel;

    pnlLista: TPanel;
    lblListaNaslov: TLabel;
    lblPretraga: TLabel;
    dbgKategorije: TDBGrid;
    edtPretraga: TEdit;

    pnlDetalji: TPanel;
    lblDetaljiNaslov: TLabel;
    lblNazivNaslov: TLabel;
    edtNaziv: TEdit;

    Panel1: TPanel;
    btnSacuvaj: TButton;
    btnOdustani: TButton;

    Panel2: TPanel;
    btnNovi: TButton;
    btnObrisi: TButton;

  private

    // ========================================================
    // BAZA
    // ========================================================

    FQryKategorije: TFDQuery;
    FDsKategorije: TDataSource;


    // ========================================================
    // TRENUTNA KATEGORIJA
    // ========================================================

    FKategorijaID: Integer;
    FNovaKategorija: Boolean;


    // ========================================================
    // UČITAVANJE
    // ========================================================

    procedure UcitajKategorije;
    procedure UcitajSelektovanuKategoriju;
    procedure PodesiKolone;
    procedure OcistiFormu;


    // ========================================================
    // DOGAĐAJI
    // ========================================================

    procedure edtPretragaChange(Sender: TObject);

    procedure qryKategorijeAfterScroll(
      DataSet: TDataSet
    );

    procedure btnNoviClick(Sender: TObject);
    procedure btnSacuvajClick(Sender: TObject);
    procedure btnOdustaniClick(Sender: TObject);
    procedure btnObrisiClick(Sender: TObject);


    // ========================================================
    // PROVERE
    // ========================================================

    function KategorijaPostoji(
      const ANaziv: string;
      AIzuzmiID: Integer
    ): Boolean;

    function KategorijaSeKoristi(
      AKategorijaID: Integer
    ): Boolean;

  public

    constructor Create(
      AOwner: TComponent
    ); override;

    procedure Osvezi;

  end;

implementation

uses
  uLogin;

{$R *.dfm}


// ============================================================
// CONSTRUCTOR
// ============================================================

constructor TfraOsnovniPodaci.Create(
  AOwner: TComponent
);
begin
  inherited Create(AOwner);


  // ==========================================================
  // QUERY
  // ==========================================================

  FQryKategorije :=
    TFDQuery.Create(Self);

  FQryKategorije.Connection :=
    frmLogin.FDConnection1;


  // ==========================================================
  // DATASOURCE
  // ==========================================================

  FDsKategorije :=
    TDataSource.Create(Self);

  FDsKategorije.DataSet :=
    FQryKategorije;


  // ==========================================================
  // GRID
  // ==========================================================

  dbgKategorije.DataSource :=
    FDsKategorije;

  dbgKategorije.ReadOnly :=
    True;

  dbgKategorije.Options :=
    dbgKategorije.Options + [dgRowSelect];


  FQryKategorije.AfterScroll :=
    qryKategorijeAfterScroll;


  // ==========================================================
  // DOGAĐAJI
  // ==========================================================

  edtPretraga.OnChange :=
    edtPretragaChange;

  btnNovi.OnClick :=
    btnNoviClick;

  btnSacuvaj.OnClick :=
    btnSacuvajClick;

  btnOdustani.OnClick :=
    btnOdustaniClick;

  btnObrisi.OnClick :=
    btnObrisiClick;


  // ==========================================================
  // POČETNO STANJE
  // ==========================================================

  FKategorijaID :=
    0;

  FNovaKategorija :=
    False;


  Osvezi;

end;


// ============================================================
// OSVEŽAVANJE
// ============================================================

procedure TfraOsnovniPodaci.Osvezi;
begin

  UcitajKategorije;

end;


// ============================================================
// UČITAVANJE KATEGORIJA
// ============================================================

procedure TfraOsnovniPodaci.UcitajKategorije;
var
  PrethodniID: Integer;
begin

  PrethodniID :=
    FKategorijaID;


  FQryKategorije.Close;


  FQryKategorije.SQL.Text :=

    'SELECT ' +

      'mt.id, ' +

      'CAST(mt.name AS VARCHAR(150)) ' +
      'AS naziv, ' +

      // Broj materijala koji koriste kategoriju
      '(SELECT COUNT(*) ' +
       ' FROM materials m ' +
       ' WHERE m.type_id = mt.id) ' +
      'AS broj_materijala ' +

    'FROM material_types mt ' +

    'WHERE (' +

      ':pretraga = '''' ' +

      'OR LOWER(mt.name) ' +
      'LIKE LOWER(:pretraga_like) ' +

    ') ' +

    'ORDER BY mt.name ASC';


  FQryKategorije.ParamByName(
    'pretraga'
  ).AsString :=
    Trim(
      edtPretraga.Text
    );


  FQryKategorije.ParamByName(
    'pretraga_like'
  ).AsString :=
    '%' +
    Trim(
      edtPretraga.Text
    ) +
    '%';


  try

    FQryKategorije.Open;


    PodesiKolone;


    // ========================================================
    // VRAĆAMO PRETHODNO IZABRANU KATEGORIJU
    // ========================================================

    if PrethodniID <> 0 then
    begin

      if not FQryKategorije.Locate(
        'id',
        PrethodniID,
        []
      ) then
      begin

        FQryKategorije.First;

      end;

    end;


    if not FQryKategorije.IsEmpty then
    begin

      UcitajSelektovanuKategoriju;

    end
    else
    begin

      FKategorijaID :=
        0;

      OcistiFormu;

    end;


  except

    on E: Exception do
    begin

      ShowMessage(
        'Greška prilikom učitavanja kategorija:' +
        sLineBreak +
        E.Message
      );

    end;

  end;

end;


// ============================================================
// KOLONE
// ============================================================

procedure TfraOsnovniPodaci.PodesiKolone;
begin

  dbgKategorije.Columns.Clear;


  // ==========================================================
  // ID
  // ==========================================================

  with dbgKategorije.Columns.Add do
  begin

    FieldName :=
      'id';

    Title.Caption :=
      'ID';

    Width :=
      60;

  end;


  // ==========================================================
  // NAZIV
  // ==========================================================

  with dbgKategorije.Columns.Add do
  begin

    FieldName :=
      'naziv';

    Title.Caption :=
      'Naziv kategorije';

    Width :=
      190;

  end;


  // ==========================================================
  // BROJ MATERIJALA
  // ==========================================================

  with dbgKategorije.Columns.Add do
  begin

    FieldName :=
      'broj_materijala';

    Title.Caption :=
      'Broj materijala';

    Width :=
      110;

  end;

end;


// ============================================================
// PROMENA REDA U TABELI
// ============================================================

procedure TfraOsnovniPodaci.qryKategorijeAfterScroll(
  DataSet: TDataSet
);
begin

  if FNovaKategorija then
    Exit;


  if FQryKategorije.Active and
     (not FQryKategorije.IsEmpty) then
  begin

    UcitajSelektovanuKategoriju;

  end;

end;


// ============================================================
// UČITAVANJE SELEKTOVANE KATEGORIJE
// ============================================================

procedure TfraOsnovniPodaci.UcitajSelektovanuKategoriju;
begin

  if (not FQryKategorije.Active) or
     FQryKategorije.IsEmpty then
    Exit;


  FNovaKategorija :=
    False;


  FKategorijaID :=
    FQryKategorije.FieldByName(
      'id'
    ).AsInteger;


  edtNaziv.Text :=
    FQryKategorije.FieldByName(
      'naziv'
    ).AsString;


  lblDetaljiNaslov.Caption :=
    'Podaci o kategoriji';


  btnObrisi.Enabled :=
    True;

end;


// ============================================================
// NOVA KATEGORIJA
// ============================================================

procedure TfraOsnovniPodaci.btnNoviClick(
  Sender: TObject
);
begin

  FNovaKategorija :=
    True;

  FKategorijaID :=
    0;


  OcistiFormu;


  lblDetaljiNaslov.Caption :=
    'Nova kategorija';


  btnObrisi.Enabled :=
    False;


  edtNaziv.SetFocus;

end;


// ============================================================
// ČIŠĆENJE FORME
// ============================================================

procedure TfraOsnovniPodaci.OcistiFormu;
begin

  edtNaziv.Clear;


  if FNovaKategorija then
  begin

    lblDetaljiNaslov.Caption :=
      'Nova kategorija';

    btnObrisi.Enabled :=
      False;

  end
  else
  begin

    lblDetaljiNaslov.Caption :=
      'Podaci o kategoriji';

    btnObrisi.Enabled :=
      FKategorijaID <> 0;

  end;

end;


// ============================================================
// PROVERA DA LI NAZIV VEĆ POSTOJI
// ============================================================

function TfraOsnovniPodaci.KategorijaPostoji(
  const ANaziv: string;
  AIzuzmiID: Integer
): Boolean;
var
  Q: TFDQuery;
begin

  Result :=
    False;


  Q :=
    TFDQuery.Create(nil);

  try

    Q.Connection :=
      frmLogin.FDConnection1;


    Q.SQL.Text :=

      'SELECT COUNT(*) AS broj ' +

      'FROM material_types ' +

      'WHERE LOWER(name) = LOWER(:name) ' +

      'AND id <> :id';


    Q.ParamByName(
      'name'
    ).AsString :=
      Trim(
        ANaziv
      );


    Q.ParamByName(
      'id'
    ).AsInteger :=
      AIzuzmiID;


    Q.Open;


    Result :=
      Q.FieldByName(
        'broj'
      ).AsInteger > 0;


  finally

    Q.Free;

  end;

end;


// ============================================================
// PROVERA DA LI KATEGORIJU KORISTE MATERIJALI
// ============================================================

function TfraOsnovniPodaci.KategorijaSeKoristi(
  AKategorijaID: Integer
): Boolean;
var
  Q: TFDQuery;
begin

  Result :=
    False;


  Q :=
    TFDQuery.Create(nil);

  try

    Q.Connection :=
      frmLogin.FDConnection1;


    Q.SQL.Text :=

      'SELECT COUNT(*) AS broj ' +

      'FROM materials ' +

      'WHERE type_id = :type_id';


    Q.ParamByName(
      'type_id'
    ).AsInteger :=
      AKategorijaID;


    Q.Open;


    Result :=
      Q.FieldByName(
        'broj'
      ).AsInteger > 0;


  finally

    Q.Free;

  end;

end;


// ============================================================
// SAČUVAJ
// ============================================================

procedure TfraOsnovniPodaci.btnSacuvajClick(
  Sender: TObject
);
var
  Q: TFDQuery;

  Naziv: string;
begin

  Naziv :=
    Trim(
      edtNaziv.Text
    );


  // ==========================================================
  // VALIDACIJA
  // ==========================================================

  if Naziv = '' then
  begin

    ShowMessage(
      'Unesite naziv kategorije.'
    );

    edtNaziv.SetFocus;

    Exit;

  end;


  if KategorijaPostoji(
    Naziv,
    FKategorijaID
  ) then
  begin

    ShowMessage(
      'Kategorija sa ovim nazivom već postoji.'
    );

    edtNaziv.SetFocus;

    Exit;

  end;


  Q :=
    TFDQuery.Create(nil);

  try

    Q.Connection :=
      frmLogin.FDConnection1;


    // ========================================================
    // NOVA KATEGORIJA
    // ========================================================

    if FNovaKategorija then
    begin

      Q.SQL.Text :=

        'INSERT INTO material_types ' +
        '(name) ' +

        'VALUES (:name)';


      Q.ParamByName(
        'name'
      ).AsString :=
        Naziv;


      try

        Q.ExecSQL;


        // ID nove kategorije
        Q.Close;

        Q.SQL.Text :=
          'SELECT last_insert_rowid() AS id';

        Q.Open;


        FKategorijaID :=
          Q.FieldByName(
            'id'
          ).AsInteger;


        FNovaKategorija :=
          False;


        ShowMessage(
          'Kategorija je uspešno dodata.'
        );


      except

        on E: Exception do
        begin

          ShowMessage(
            'Greška prilikom dodavanja kategorije:' +
            sLineBreak +
            E.Message
          );

          Exit;

        end;

      end;

    end


    // ========================================================
    // IZMENA POSTOJEĆE KATEGORIJE
    // ========================================================

    else
    begin

      if FKategorijaID = 0 then
      begin

        ShowMessage(
          'Izaberite kategoriju koju želite da izmenite.'
        );

        Exit;

      end;


      try

        frmLogin.FDConnection1.StartTransaction;


        // ====================================================
        // 1. MENJAMO NAZIV KATEGORIJE
        // ====================================================

        Q.SQL.Text :=

          'UPDATE material_types ' +

          'SET name = :name ' +

          'WHERE id = :id';


        Q.ParamByName(
          'name'
        ).AsString :=
          Naziv;


        Q.ParamByName(
          'id'
        ).AsInteger :=
          FKategorijaID;


        Q.ExecSQL;


        // ====================================================
        // 2. PRIVREMENO SINHRONIZUJEMO STARU materials.type
        //
        // Dok potpuno ne uklonimo staru kolonu type.
        // ====================================================

        Q.Close;


        Q.SQL.Text :=

          'UPDATE materials ' +

          'SET type = :name ' +

          'WHERE type_id = :type_id';


        Q.ParamByName(
          'name'
        ).AsString :=
          Naziv;


        Q.ParamByName(
          'type_id'
        ).AsInteger :=
          FKategorijaID;


        Q.ExecSQL;


        frmLogin.FDConnection1.Commit;


        ShowMessage(
          'Kategorija je uspešno izmenjena.'
        );


      except

        on E: Exception do
        begin

          if frmLogin.FDConnection1.InTransaction then
            frmLogin.FDConnection1.Rollback;


          ShowMessage(
            'Greška prilikom izmene kategorije:' +
            sLineBreak +
            E.Message
          );

          Exit;

        end;

      end;

    end;


  finally

    Q.Free;

  end;


  UcitajKategorije;

end;


// ============================================================
// OBRIŠI
// ============================================================

procedure TfraOsnovniPodaci.btnObrisiClick(
  Sender: TObject
);
var
  Q: TFDQuery;
  Naziv: string;
begin

  if FKategorijaID = 0 then
  begin

    ShowMessage(
      'Izaberite kategoriju koju želite da obrišete.'
    );

    Exit;

  end;


  // ==========================================================
  // PROVERA DA LI POSTOJE MATERIJALI
  // ==========================================================

  if KategorijaSeKoristi(
    FKategorijaID
  ) then
  begin

    ShowMessage(
      'Kategoriju nije moguće obrisati jer postoje ' +
      'materijali koji je koriste.'
    );

    Exit;

  end;


  Naziv :=
    edtNaziv.Text;


  if MessageDlg(

    'Da li ste sigurni da želite da obrišete kategoriju "' +
    Naziv +
    '"?',

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


    Q.SQL.Text :=

      'DELETE FROM material_types ' +

      'WHERE id = :id';


    Q.ParamByName(
      'id'
    ).AsInteger :=
      FKategorijaID;


    try

      Q.ExecSQL;


      ShowMessage(
        'Kategorija je obrisana.'
      );


      FKategorijaID :=
        0;

      FNovaKategorija :=
        False;


      UcitajKategorije;


    except

      on E: Exception do
      begin

        ShowMessage(
          'Greška prilikom brisanja kategorije:' +
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
// ODUSTANI
// ============================================================

procedure TfraOsnovniPodaci.btnOdustaniClick(
  Sender: TObject
);
begin

  FNovaKategorija :=
    False;


  if FQryKategorije.Active and
     (not FQryKategorije.IsEmpty) then
  begin

    UcitajSelektovanuKategoriju;

  end
  else
  begin

    FKategorijaID :=
      0;

    OcistiFormu;

  end;

end;


// ============================================================
// PRETRAGA
// ============================================================

procedure TfraOsnovniPodaci.edtPretragaChange(
  Sender: TObject
);
begin

  FNovaKategorija :=
    False;

  UcitajKategorije;

end;

end.
