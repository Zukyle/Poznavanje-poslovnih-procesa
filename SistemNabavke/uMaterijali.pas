unit uMaterijali;

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
  TfraMaterijali = class(TFrame)

    pnlHeader: TPanel;
    lblNaslov: TLabel;
    lblOpis: TLabel;

    pnlLista: TPanel;
    lblListaNaslov: TLabel;
    lblPretraga: TLabel;
    dbgMaterijali: TDBGrid;
    edtPretraga: TEdit;

    pnlDetalji: TPanel;
    lblDetaljiNaslov: TLabel;

    lblNazivNaslov: TLabel;
    lblTipNaslov: TLabel;
    lblJedinicaNaslov: TLabel;
    lblMinimumNaslov: TLabel;

    edtNaziv: TEdit;              // IZMENJENO
    edtMinimum: TEdit;

    cmbJedinica: TComboBox;
    cmbTip: TComboBox;

    btnNovi: TButton;

    Panel1: TPanel;

    btnSacuvaj: TButton;
    btnOdustani: TButton;

  private

    FQryMaterijali: TFDQuery;
    FDsMaterijali: TDataSource;

    FMaterijalID: Integer;
    FNoviMaterijal: Boolean;

    procedure UcitajKategorije;
    procedure UcitajJedinice;
    procedure UcitajMaterijale;
    procedure UcitajSelektovaniMaterijal;

    procedure PodesiKolone;
    procedure OcistiFormu;

    procedure edtPretragaChange(Sender: TObject);

    procedure qryMaterijaliAfterScroll(
      DataSet: TDataSet
    );

    procedure btnNoviClick(Sender: TObject);
    procedure btnSacuvajClick(Sender: TObject);
    procedure btnOdustaniClick(Sender: TObject);

    function ProcitajMinimum(
      out AMinimum: Double
    ): Boolean;

    function NazivPostoji(
      const ANaziv: string;
      AIzuzmiID: Integer
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

constructor TfraMaterijali.Create(
  AOwner: TComponent
);
begin
  inherited Create(AOwner);


  // ==========================================================
  // QUERY
  // ==========================================================

  FQryMaterijali :=
    TFDQuery.Create(Self);

  FQryMaterijali.Connection :=
    frmLogin.FDConnection1;


  // ==========================================================
  // DATASOURCE
  // ==========================================================

  FDsMaterijali :=
    TDataSource.Create(Self);

  FDsMaterijali.DataSet :=
    FQryMaterijali;


  // ==========================================================
  // GRID
  // ==========================================================

  dbgMaterijali.DataSource :=
    FDsMaterijali;

  dbgMaterijali.ReadOnly :=
    True;

  dbgMaterijali.Options :=
    dbgMaterijali.Options + [dgRowSelect];

  FQryMaterijali.AfterScroll :=
    qryMaterijaliAfterScroll;


  // ==========================================================
  // COMBOBOX
  // ==========================================================

  cmbTip.Style :=
    csDropDownList;

  cmbJedinica.Style :=
    csDropDownList;


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


  // ==========================================================
  // POČETNO STANJE
  // ==========================================================

  FMaterijalID :=
    0;

  FNoviMaterijal :=
    False;


  UcitajKategorije;

  UcitajJedinice;

  Osvezi;

end;


// ============================================================
// UČITAVANJE KATEGORIJA
// ============================================================

procedure TfraMaterijali.UcitajKategorije;
var
  Q: TFDQuery;
  KategorijaID: Integer;
begin

  cmbTip.Items.Clear;


  Q :=
    TFDQuery.Create(nil);

  try

    Q.Connection :=
      frmLogin.FDConnection1;


    Q.SQL.Text :=

      'SELECT ' +
        'id, ' +
        'name ' +

      'FROM material_types ' +

      'ORDER BY name';


    Q.Open;


    while not Q.Eof do
    begin

      KategorijaID :=
        Q.FieldByName(
          'id'
        ).AsInteger;


      cmbTip.Items.AddObject(

        Q.FieldByName(
          'name'
        ).AsString,

        TObject(
          NativeInt(
            KategorijaID
          )
        )

      );


      Q.Next;

    end;


  finally

    Q.Free;

  end;


  cmbTip.ItemIndex :=
    -1;

end;


// ============================================================
// JEDINICE MERE
// ============================================================

procedure TfraMaterijali.UcitajJedinice;
begin

  cmbJedinica.Items.Clear;

  cmbJedinica.Items.Add('kg');
  cmbJedinica.Items.Add('kom');
  cmbJedinica.Items.Add('l');
  cmbJedinica.Items.Add('m');
  cmbJedinica.Items.Add('m2');
  cmbJedinica.Items.Add('m3');

  cmbJedinica.ItemIndex :=
    -1;

end;


// ============================================================
// OSVEŽAVANJE
// ============================================================

procedure TfraMaterijali.Osvezi;
begin

  UcitajKategorije;

  UcitajMaterijale;

end;


// ============================================================
// UČITAVANJE MATERIJALA
// ============================================================

procedure TfraMaterijali.UcitajMaterijale;
var
  PrethodniID: Integer;
begin

  PrethodniID :=
    FMaterijalID;


  FQryMaterijali.Close;


  FQryMaterijali.SQL.Text :=

    'SELECT ' +

    'm.id, ' +

    // ========================================================
    // NAZIV
    // ========================================================

    'CAST(m.name AS VARCHAR(150)) ' +
    'AS naziv, ' +


    // ========================================================
    // KATEGORIJA
    // ========================================================

    'm.type_id, ' +

    'CAST(COALESCE(mt.name, ''-'') AS VARCHAR(100)) ' +
    'AS kategorija, ' +


    // ========================================================
    // JEDINICA
    // ========================================================

    'CAST(m.unit AS VARCHAR(30)) ' +
    'AS jedinica, ' +


    // ========================================================
    // TRENUTNO STANJE
    // ========================================================

    'm.current_quantity, ' +

    'CAST(' +
      'printf(''%g'', m.current_quantity) ' +
    'AS VARCHAR(50)) ' +
    'AS trenutno_prikaz, ' +


    // ========================================================
    // MINIMUM
    // ========================================================

    'm.min_quantity, ' +

    'CAST(' +
      'printf(''%g'', m.min_quantity) ' +
    'AS VARCHAR(50)) ' +
    'AS minimum_prikaz ' +


    // ========================================================
    // TABELE
    // ========================================================

    'FROM materials m ' +

    'LEFT JOIN material_types mt ' +
    'ON mt.id = m.type_id ' +


    // ========================================================
    // PRETRAGA
    // ========================================================

    'WHERE (' +

      ':pretraga = '''' ' +

      'OR LOWER(m.name) ' +
      'LIKE LOWER(:pretraga_like) ' +

      'OR LOWER(COALESCE(mt.name, '''')) ' +
      'LIKE LOWER(:pretraga_like) ' +

      'OR LOWER(m.unit) ' +
      'LIKE LOWER(:pretraga_like) ' +

    ') ' +


    'ORDER BY m.name ASC';


  FQryMaterijali.ParamByName(
    'pretraga'
  ).AsString :=
    Trim(
      edtPretraga.Text
    );


  FQryMaterijali.ParamByName(
    'pretraga_like'
  ).AsString :=
    '%' +
    Trim(
      edtPretraga.Text
    ) +
    '%';


  try

    FQryMaterijali.Open;


    PodesiKolone;


    // ========================================================
    // VRATI PRETHODNO IZABRANI MATERIJAL
    // ========================================================

    if PrethodniID <> 0 then
    begin

      if not FQryMaterijali.Locate(
        'id',
        PrethodniID,
        []
      ) then
      begin

        FQryMaterijali.First;

      end;

    end;


    if not FQryMaterijali.IsEmpty then
    begin

      UcitajSelektovaniMaterijal;

    end
    else
    begin

      FMaterijalID :=
        0;

      OcistiFormu;

    end;


  except

    on E: Exception do
    begin

      ShowMessage(
        'Greška prilikom učitavanja materijala:' +
        sLineBreak +
        E.Message
      );

    end;

  end;

end;


// ============================================================
// KOLONE
// ============================================================

procedure TfraMaterijali.PodesiKolone;
begin

  dbgMaterijali.Columns.Clear;


  with dbgMaterijali.Columns.Add do
  begin

    FieldName :=
      'naziv';

    Title.Caption :=
      'Naziv';

    Width :=
      180;

  end;


  with dbgMaterijali.Columns.Add do
  begin

    FieldName :=
      'kategorija';

    Title.Caption :=
      'Kategorija';

    Width :=
      130;

  end;


  with dbgMaterijali.Columns.Add do
  begin

    FieldName :=
      'jedinica';

    Title.Caption :=
      'Jedinica';

    Width :=
      75;

  end;


  with dbgMaterijali.Columns.Add do
  begin

    FieldName :=
      'trenutno_prikaz';

    Title.Caption :=
      'Trenutno';

    Width :=
      90;

  end;


  with dbgMaterijali.Columns.Add do
  begin

    FieldName :=
      'minimum_prikaz';

    Title.Caption :=
      'Minimum';

    Width :=
      90;

  end;

end;


// ============================================================
// PROMENA REDA
// ============================================================

procedure TfraMaterijali.qryMaterijaliAfterScroll(
  DataSet: TDataSet
);
begin

  if FNoviMaterijal then
    Exit;


  if FQryMaterijali.Active and
     (not FQryMaterijali.IsEmpty) then
  begin

    UcitajSelektovaniMaterijal;

  end;

end;


// ============================================================
// UČITAVANJE SELEKTOVANOG MATERIJALA
// ============================================================

procedure TfraMaterijali.UcitajSelektovaniMaterijal;
var
  I: Integer;
  KategorijaID: Integer;
begin

  if (not FQryMaterijali.Active) or
     FQryMaterijali.IsEmpty then
    Exit;


  FNoviMaterijal :=
    False;


  FMaterijalID :=
    FQryMaterijali.FieldByName(
      'id'
    ).AsInteger;


  // ==========================================================
  // NAZIV
  // ==========================================================

  edtNaziv.Text :=
    FQryMaterijali.FieldByName(
      'naziv'
    ).AsString;


  // ==========================================================
  // KATEGORIJA
  // ==========================================================

  KategorijaID :=
    FQryMaterijali.FieldByName(
      'type_id'
    ).AsInteger;


  cmbTip.ItemIndex :=
    -1;


  for I := 0 to cmbTip.Items.Count - 1 do
  begin

    if Integer(
      NativeInt(
        cmbTip.Items.Objects[I]
      )
    ) = KategorijaID then
    begin

      cmbTip.ItemIndex :=
        I;

      Break;

    end;

  end;


  // ==========================================================
  // JEDINICA
  // ==========================================================

  cmbJedinica.ItemIndex :=
    cmbJedinica.Items.IndexOf(

      FQryMaterijali.FieldByName(
        'jedinica'
      ).AsString

    );


  // ==========================================================
  // MINIMUM
  // ==========================================================

  edtMinimum.Text :=
    FormatFloat(
      '0.##',
      FQryMaterijali.FieldByName(
        'min_quantity'
      ).AsFloat
    );


  lblDetaljiNaslov.Caption :=
    'Podaci o materijalu';

end;


// ============================================================
// NOVI MATERIJAL
// ============================================================

procedure TfraMaterijali.btnNoviClick(
  Sender: TObject
);
begin

  FNoviMaterijal :=
    True;

  FMaterijalID :=
    0;


  OcistiFormu;


  lblDetaljiNaslov.Caption :=
    'Novi materijal';


  edtNaziv.SetFocus;

end;


// ============================================================
// ČIŠĆENJE FORME
// ============================================================

procedure TfraMaterijali.OcistiFormu;
begin

  edtNaziv.Clear;

  edtMinimum.Clear;


  cmbTip.ItemIndex :=
    -1;

  cmbJedinica.ItemIndex :=
    -1;


  if FNoviMaterijal then
    lblDetaljiNaslov.Caption :=
      'Novi materijal'
  else
    lblDetaljiNaslov.Caption :=
      'Podaci o materijalu';

end;


// ============================================================
// ČITANJE MINIMALNE KOLIČINE
// ============================================================

function TfraMaterijali.ProcitajMinimum(
  out AMinimum: Double
): Boolean;
var
  S: string;
  FS: TFormatSettings;
begin

  Result :=
    False;


  S :=
    Trim(
      edtMinimum.Text
    );


  if S = '' then
  begin

    ShowMessage(
      'Unesite minimalnu količinu.'
    );

    edtMinimum.SetFocus;

    Exit;

  end;


  FS :=
    TFormatSettings.Create;


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


  if not TryStrToFloat(
    S,
    AMinimum,
    FS
  ) then
  begin

    ShowMessage(
      'Minimalna količina mora biti broj.'
    );

    edtMinimum.SetFocus;

    Exit;

  end;


  if AMinimum < 0 then
  begin

    ShowMessage(
      'Minimalna količina ne može biti negativna.'
    );

    edtMinimum.SetFocus;

    Exit;

  end;


  Result :=
    True;

end;


// ============================================================
// PROVERA DUPLIKATA NAZIVA
// ============================================================

function TfraMaterijali.NazivPostoji(
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

      'FROM materials ' +

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
// SAČUVAJ
// ============================================================

procedure TfraMaterijali.btnSacuvajClick(
  Sender: TObject
);
var
  Q: TFDQuery;

  Naziv: string;
  Jedinica: string;
  KategorijaNaziv: string;

  KategorijaID: Integer;

  Minimum: Double;
begin

  // ==========================================================
  // NAZIV
  // ==========================================================

  Naziv :=
    Trim(
      edtNaziv.Text
    );


  if Naziv = '' then
  begin

    ShowMessage(
      'Unesite naziv materijala.'
    );

    edtNaziv.SetFocus;

    Exit;

  end;


  // ==========================================================
  // KATEGORIJA
  // ==========================================================

  if cmbTip.ItemIndex < 0 then
  begin

    ShowMessage(
      'Izaberite kategoriju materijala.'
    );

    cmbTip.SetFocus;

    Exit;

  end;


  KategorijaID :=
    Integer(
      NativeInt(
        cmbTip.Items.Objects[
          cmbTip.ItemIndex
        ]
      )
    );


  KategorijaNaziv :=
    cmbTip.Text;


  // ==========================================================
  // JEDINICA
  // ==========================================================

  if cmbJedinica.ItemIndex < 0 then
  begin

    ShowMessage(
      'Izaberite jedinicu mere.'
    );

    cmbJedinica.SetFocus;

    Exit;

  end;


  Jedinica :=
    cmbJedinica.Text;


  // ==========================================================
  // MINIMUM
  // ==========================================================

  if not ProcitajMinimum(
    Minimum
  ) then
    Exit;


  // ==========================================================
  // DUPLIKAT NAZIVA
  // ==========================================================

  if NazivPostoji(
    Naziv,
    FMaterijalID
  ) then
  begin

    ShowMessage(
      'Materijal sa ovim nazivom već postoji.'
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
    // NOVI MATERIJAL
    // ========================================================

    if FNoviMaterijal then
    begin

      Q.SQL.Text :=

        'INSERT INTO materials ' +

        '(' +
          'name, ' +
          'type, ' +       // privremeno čuvamo i staru kolonu
          'type_id, ' +
          'unit, ' +
          'current_quantity, ' +
          'min_quantity' +
        ') ' +

        'VALUES ' +

        '(' +
          ':name, ' +
          ':type, ' +
          ':type_id, ' +
          ':unit, ' +
          '0, ' +
          ':min_quantity' +
        ')';


      Q.ParamByName(
        'name'
      ).AsString :=
        Naziv;


      Q.ParamByName(
        'type'
      ).AsString :=
        KategorijaNaziv;


      Q.ParamByName(
        'type_id'
      ).AsInteger :=
        KategorijaID;


      Q.ParamByName(
        'unit'
      ).AsString :=
        Jedinica;


      Q.ParamByName(
        'min_quantity'
      ).AsFloat :=
        Minimum;


      try

        Q.ExecSQL;


        // Dohvat ID-a novog materijala
        Q.Close;


        Q.SQL.Text :=
          'SELECT last_insert_rowid() AS id';


        Q.Open;


        FMaterijalID :=
          Q.FieldByName(
            'id'
          ).AsInteger;


        FNoviMaterijal :=
          False;


        ShowMessage(
          'Materijal je uspešno dodat.'
        );


      except

        on E: Exception do
        begin

          ShowMessage(
            'Greška prilikom dodavanja materijala:' +
            sLineBreak +
            E.Message
          );

          Exit;

        end;

      end;

    end


    // ========================================================
    // IZMENA POSTOJEĆEG
    // ========================================================

    else
    begin

      if FMaterijalID = 0 then
      begin

        ShowMessage(
          'Izaberite materijal koji želite da izmenite.'
        );

        Exit;

      end;


      Q.SQL.Text :=

        'UPDATE materials ' +

        'SET ' +
          'name = :name, ' +
          'type = :type, ' +
          'type_id = :type_id, ' +
          'unit = :unit, ' +
          'min_quantity = :min_quantity ' +

        'WHERE id = :id';


      Q.ParamByName(
        'name'
      ).AsString :=
        Naziv;


      Q.ParamByName(
        'type'
      ).AsString :=
        KategorijaNaziv;


      Q.ParamByName(
        'type_id'
      ).AsInteger :=
        KategorijaID;


      Q.ParamByName(
        'unit'
      ).AsString :=
        Jedinica;


      Q.ParamByName(
        'min_quantity'
      ).AsFloat :=
        Minimum;


      Q.ParamByName(
        'id'
      ).AsInteger :=
        FMaterijalID;


      try

        Q.ExecSQL;


        ShowMessage(
          'Podaci materijala su uspešno sačuvani.'
        );


      except

        on E: Exception do
        begin

          ShowMessage(
            'Greška prilikom izmene materijala:' +
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


  UcitajMaterijale;

end;


// ============================================================
// ODUSTANI
// ============================================================

procedure TfraMaterijali.btnOdustaniClick(
  Sender: TObject
);
begin

  FNoviMaterijal :=
    False;


  if FQryMaterijali.Active and
     (not FQryMaterijali.IsEmpty) then
  begin

    UcitajSelektovaniMaterijal;

  end
  else
  begin

    FMaterijalID :=
      0;

    OcistiFormu;

  end;

end;


// ============================================================
// PRETRAGA
// ============================================================

procedure TfraMaterijali.edtPretragaChange(
  Sender: TObject
);
begin

  FNoviMaterijal :=
    False;

  UcitajMaterijale;

end;

end.
