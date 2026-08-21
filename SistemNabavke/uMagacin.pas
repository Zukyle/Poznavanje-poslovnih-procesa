unit uMagacin;

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
  TfraMagacin = class(TFrame)

    pnlHeader: TPanel;
    lblNaslov: TLabel;
    lblOpis: TLabel;

    pnlSadrzaj: TPanel;

    dbgMagacin: TDBGrid;

    lblPretraga: TLabel;
    cmbStanje: TComboBox;
    edtPretraga: TEdit;

  private

    // NOVO
    FQryMagacin: TFDQuery;
    FDsMagacin: TDataSource;

    // NOVO
    procedure UcitajStanja;

    // NOVO
    procedure UcitajMaterijale;

    // NOVO
    procedure PodesiKolone;

    // NOVO
    procedure edtPretragaChange(Sender: TObject);

    // NOVO
    procedure cmbStanjeChange(Sender: TObject);

    // NOVO
    procedure dbgMagacinDrawColumnCell(
      Sender: TObject;
      const Rect: TRect;
      DataCol: Integer;
      Column: TColumn;
      State: TGridDrawState
    );

  public

    // NOVO
    constructor Create(AOwner: TComponent); override;

    // NOVO
    procedure Osvezi;

  end;

implementation

uses
  uLogin;

{$R *.dfm}


// ============================================================
// CONSTRUCTOR
// ============================================================

constructor TfraMagacin.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);


  // ==========================================================
  // QUERY
  // ==========================================================

  FQryMagacin :=
    TFDQuery.Create(Self);

  FQryMagacin.Connection :=
    frmLogin.FDConnection1;


  // ==========================================================
  // DATASOURCE
  // ==========================================================

  FDsMagacin :=
    TDataSource.Create(Self);

  FDsMagacin.DataSet :=
    FQryMagacin;


  // ==========================================================
  // GRID
  // ==========================================================

  dbgMagacin.DataSource :=
    FDsMagacin;

  dbgMagacin.ReadOnly :=
    True;

  dbgMagacin.Options :=
    dbgMagacin.Options + [dgRowSelect];

  dbgMagacin.OnDrawColumnCell :=
    dbgMagacinDrawColumnCell;


  // ==========================================================
  // PRETRAGA
  // ==========================================================

  edtPretraga.OnChange :=
    edtPretragaChange;


  // ==========================================================
  // FILTER STANJA
  // ==========================================================

  cmbStanje.Style :=
    csDropDownList;

  cmbStanje.OnChange :=
    cmbStanjeChange;


  // ==========================================================
  // POČETNO UČITAVANJE
  // ==========================================================

  UcitajStanja;

  Osvezi;

end;


// ============================================================
// STANJA
// ============================================================

procedure TfraMagacin.UcitajStanja;
begin

  cmbStanje.Items.Clear;

  cmbStanje.Items.Add(
    'Svi materijali'
  );

  cmbStanje.Items.Add(
    'Dovoljno na stanju'
  );

  cmbStanje.Items.Add(
    'Nisko stanje'
  );

  cmbStanje.ItemIndex :=
    0;

end;


// ============================================================
// OSVEŽAVANJE
// ============================================================

procedure TfraMagacin.Osvezi;
begin

  UcitajMaterijale;

end;


// ============================================================
// UČITAVANJE MATERIJALA
// ============================================================

procedure TfraMagacin.UcitajMaterijale;
var
  SQLFilter: string;
begin

  FQryMagacin.Close;


  // ==========================================================
  // FILTER STANJA
  // ==========================================================

  SQLFilter := '';


  case cmbStanje.ItemIndex of

    // DOVOLJNO NA STANJU
    1:
      SQLFilter :=
        ' AND m.current_quantity > m.min_quantity ';


    // NISKO STANJE
    2:
      SQLFilter :=
        ' AND m.current_quantity <= m.min_quantity ';

  end;


  // ==========================================================
  // SQL
  // ==========================================================

  FQryMagacin.SQL.Text :=

    'SELECT ' +

    // ID MATERIJALA
    'm.id, ' +


    // ========================================================
    // MATERIJAL
    // ========================================================

    'CAST(m.name AS VARCHAR(150)) ' +
    'AS materijal, ' +


    // ========================================================
    // NOVO - KATEGORIJA IZ material_types
    // ========================================================

    'CAST(' +

      'CASE ' +

        'WHEN mt.name IS NULL ' +
        'THEN ''-'' ' +

        'ELSE mt.name ' +

      'END ' +

    'AS VARCHAR(100)) ' +
    'AS tip, ' +


    // ========================================================
    // JEDINICA
    // ========================================================

    'CAST(m.unit AS VARCHAR(30)) ' +
    'AS jedinica, ' +


    // ========================================================
    // TRENUTNA KOLIČINA
    // ========================================================

    'CAST(' +
      'printf(''%g'', m.current_quantity) ' +
    'AS VARCHAR(50)) ' +
    'AS trenutno, ' +


    // ========================================================
    // MINIMALNA KOLIČINA
    // ========================================================

    'CAST(' +
      'printf(''%g'', m.min_quantity) ' +
    'AS VARCHAR(50)) ' +
    'AS minimum, ' +


    // RAW VREDNOSTI
    'm.current_quantity AS trenutno_vrednost, ' +

    'm.min_quantity AS minimum_vrednost, ' +


    // ========================================================
    // STANJE
    // ========================================================

    'CAST(' +

      'CASE ' +

        'WHEN m.current_quantity <= m.min_quantity ' +
        'THEN ''Nisko'' ' +

        'ELSE ''Dovoljno'' ' +

      'END ' +

    'AS VARCHAR(30)) ' +
    'AS stanje ' +


    // ========================================================
    // TABELE
    // ========================================================

    'FROM materials m ' +


    // NOVO
    'LEFT JOIN material_types mt ' +
    'ON mt.id = m.type_id ' +


    // ========================================================
    // PRETRAGA
    // ========================================================

    'WHERE (' +

      ':pretraga = '''' ' +

      'OR LOWER(m.name) ' +
      'LIKE LOWER(:pretraga_like) ' +

      // NOVO - pretraga po nazivu kategorije
      'OR LOWER(COALESCE(mt.name, '''')) ' +
      'LIKE LOWER(:pretraga_like) ' +

    ') ' +


    // ========================================================
    // FILTER STANJA
    // ========================================================

    SQLFilter +


    // ========================================================
    // SORTIRANJE
    // Nisko stanje prikazujemo prvo.
    // ========================================================

    'ORDER BY ' +

      'CASE ' +

        'WHEN m.current_quantity <= m.min_quantity ' +
        'THEN 0 ' +

        'ELSE 1 ' +

      'END, ' +

      'm.name ASC';


  // ==========================================================
  // PARAMETRI PRETRAGE
  // ==========================================================

  FQryMagacin.ParamByName(
    'pretraga'
  ).AsString :=
    Trim(
      edtPretraga.Text
    );


  FQryMagacin.ParamByName(
    'pretraga_like'
  ).AsString :=
    '%' +
    Trim(
      edtPretraga.Text
    ) +
    '%';


  // ==========================================================
  // OTVARANJE
  // ==========================================================

  try

    FQryMagacin.Open;

    PodesiKolone;


  except

    on E: Exception do
    begin

      ShowMessage(
        'Greška prilikom učitavanja magacina:' +
        sLineBreak +
        E.Message
      );

    end;

  end;

end;


// ============================================================
// PRETRAGA
// ============================================================

procedure TfraMagacin.edtPretragaChange(
  Sender: TObject
);
begin

  UcitajMaterijale;

end;


// ============================================================
// PROMENA FILTERA
// ============================================================

procedure TfraMagacin.cmbStanjeChange(
  Sender: TObject
);
begin

  UcitajMaterijale;

end;


// ============================================================
// KOLONE
// ============================================================

procedure TfraMagacin.PodesiKolone;
begin

  dbgMagacin.Columns.Clear;


  // ==========================================================
  // MATERIJAL
  // ==========================================================

  with dbgMagacin.Columns.Add do
  begin

    FieldName :=
      'materijal';

    Title.Caption :=
      'Materijal';

    Width :=
      180;

  end;


  // ==========================================================
  // TIP
  // ==========================================================

  with dbgMagacin.Columns.Add do
  begin

    FieldName :=
      'tip';

    Title.Caption :=
      'Tip';

    Width :=
      130;

  end;


  // ==========================================================
  // JEDINICA
  // ==========================================================

  with dbgMagacin.Columns.Add do
  begin

    FieldName :=
      'jedinica';

    Title.Caption :=
      'Jedinica';

    Width :=
      80;

  end;


  // ==========================================================
  // TRENUTNO
  // ==========================================================

  with dbgMagacin.Columns.Add do
  begin

    FieldName :=
      'trenutno';

    Title.Caption :=
      'Trenutno';

    Width :=
      100;

  end;


  // ==========================================================
  // MINIMUM
  // ==========================================================

  with dbgMagacin.Columns.Add do
  begin

    FieldName :=
      'minimum';

    Title.Caption :=
      'Minimum';

    Width :=
      100;

  end;


  // ==========================================================
  // STANJE
  // ==========================================================

  with dbgMagacin.Columns.Add do
  begin

    FieldName :=
      'stanje';

    Title.Caption :=
      'Stanje';

    Width :=
      110;

  end;

end;


// ============================================================
// BOJENJE STANJA
// ============================================================

procedure TfraMagacin.dbgMagacinDrawColumnCell(
  Sender: TObject;
  const Rect: TRect;
  DataCol: Integer;
  Column: TColumn;
  State: TGridDrawState
);
var
  Stanje: string;
begin

  if FQryMagacin.IsEmpty then
  begin

    dbgMagacin.DefaultDrawColumnCell(
      Rect,
      DataCol,
      Column,
      State
    );

    Exit;

  end;


  Stanje :=
    FQryMagacin.FieldByName(
      'stanje'
    ).AsString;


  // ==========================================================
  // NE DIRAMO PLAVU SELEKCIJU REDA
  // ==========================================================

  if gdSelected in State then
  begin

    dbgMagacin.DefaultDrawColumnCell(
      Rect,
      DataCol,
      Column,
      State
    );

    Exit;

  end;


  // ==========================================================
  // BOJIMO SAMO KOLONU STANJE
  // ==========================================================

  if SameText(
    Column.FieldName,
    'stanje'
  ) then
  begin

    if SameText(
      Stanje,
      'Nisko'
    ) then
    begin

      // Svetlo crvena pozadina
      dbgMagacin.Canvas.Brush.Color :=
        RGB(255, 230, 230);

      // Tamno crveni tekst
      dbgMagacin.Canvas.Font.Color :=
        RGB(180, 30, 30);

      dbgMagacin.Canvas.Font.Style :=
        [fsBold];

    end
    else
    begin

      // Svetlo zelena pozadina
      dbgMagacin.Canvas.Brush.Color :=
        RGB(228, 247, 235);

      // Tamno zeleni tekst
      dbgMagacin.Canvas.Font.Color :=
        RGB(30, 120, 65);

      dbgMagacin.Canvas.Font.Style :=
        [fsBold];

    end;


    dbgMagacin.Canvas.FillRect(
      Rect
    );


    dbgMagacin.Canvas.TextRect(
      Rect,
      Rect.Left + 5,
      Rect.Top + 2,
      Column.Field.DisplayText
    );

  end
  else
  begin

    dbgMagacin.DefaultDrawColumnCell(
      Rect,
      DataCol,
      Column,
      State
    );

  end;

end;

end.
