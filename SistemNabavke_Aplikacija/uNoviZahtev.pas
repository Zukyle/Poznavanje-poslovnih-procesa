unit uNoviZahtev;

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

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Imaging.pngimage;

type
  TfraNoviZahtev = class(TFrame)

    pnlHeader: TPanel;
    lblNaslov: TLabel;
    lblOpis: TLabel;

    pnlSadrzaj: TPanel;
    pnlSaveti: TPanel;
    pnlForma: TPanel;

    lblDetaljiZahteva: TLabel;

    lblKategorija: TLabel;
    lblMaterijal: TLabel;

    cmbKategorija: TComboBox;
    cmbMaterijal: TComboBox;

    qryMaterijali: TFDQuery;

    lblKolicina: TLabel;
    edtKolicina: TEdit;

    lblJedinicaMere: TLabel;
    edtJedinicaMere: TEdit;

    lblPrioritet: TLabel;
    cmbPrioritet: TComboBox;

    dtpDatumPotrebe: TDateTimePicker;
    lblDatumPotrebe: TLabel;

    lblRazlog: TLabel;
    memRazlog: TMemo;

    btnPosaljiZahtev: TButton;
    Image1: TImage;
    lblDetaljiNaslov: TLabel;
    Bevel2: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure lblDetaljiNaslovClick(Sender: TObject);

  private

    // ID trenutno prijavljenog korisnika
    FKorisnikID: Integer;

    procedure UcitajKategorije;
    procedure UcitajMaterijale;
    procedure UcitajJedinicuMere;

    procedure ResetujFormu;

    procedure cmbKategorijaChange(Sender: TObject);
    procedure cmbMaterijalChange(Sender: TObject);

    procedure btnPosaljiZahtevClick(Sender: TObject);

  public

    constructor Create(AOwner: TComponent); override;

    property KorisnikID: Integer
      read FKorisnikID
      write FKorisnikID;

  end;

implementation

uses
  uLogin;

{$R *.dfm}


// ============================================================
// KREIRANJE FRAME-A
// ============================================================

constructor TfraNoviZahtev.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FKorisnikID := 0;


  // ==========================================================
  // KONEKCIJA
  // ==========================================================

  qryMaterijali.Connection :=
    frmLogin.FDConnection1;


  // ==========================================================
  // COMBOBOX
  // ==========================================================

  cmbKategorija.Style :=
    csDropDownList;

  cmbMaterijal.Style :=
    csDropDownList;

  cmbPrioritet.Style :=
    csDropDownList;


  // Materijal nije dostupan dok se ne izabere kategorija
  cmbMaterijal.Enabled :=
    False;


  // Jedinica mere se ne unosi ručno
  edtJedinicaMere.ReadOnly :=
    True;

  edtJedinicaMere.Clear;


  // ==========================================================
  // PRIORITET
  // ==========================================================

  cmbPrioritet.Items.Clear;

  cmbPrioritet.Items.Add(
    'Nizak'
  );

  cmbPrioritet.Items.Add(
    'Srednji'
  );

  cmbPrioritet.Items.Add(
    'Visok'
  );

  // Podrazumevani prioritet
  cmbPrioritet.ItemIndex :=
    1;


  // ==========================================================
  // DATUM
  // ==========================================================

  dtpDatumPotrebe.Date :=
    Date;


  // ==========================================================
  // DOGAĐAJI
  // ==========================================================

  cmbKategorija.OnChange :=
    cmbKategorijaChange;

  cmbMaterijal.OnChange :=
    cmbMaterijalChange;

  btnPosaljiZahtev.OnClick :=
    btnPosaljiZahtevClick;


  // ==========================================================
  // UČITAVANJE KATEGORIJA
  // ==========================================================

  UcitajKategorije;

end;


procedure TfraNoviZahtev.lblDetaljiNaslovClick(Sender: TObject);
begin

end;

// ============================================================
// UČITAVANJE KATEGORIJA
// ============================================================

procedure TfraNoviZahtev.UcitajKategorije;
var
  KategorijaID: Integer;
begin

  cmbKategorija.Clear;


  qryMaterijali.Close;


  // ==========================================================
  // NOVO
  //
  // Više NE čitamo:
  //
  // materials.type
  //
  // nego posebnu tabelu:
  //
  // material_types
  // ==========================================================

  qryMaterijali.SQL.Text :=

    'SELECT ' +
      'id, ' +
      'name ' +

    'FROM material_types ' +

    'ORDER BY name';


  qryMaterijali.Open;


  while not qryMaterijali.Eof do
  begin

    KategorijaID :=
      qryMaterijali.FieldByName(
        'id'
      ).AsInteger;


    // Korisnik vidi naziv kategorije,
    // a u Objects čuvamo njen ID.
    cmbKategorija.Items.AddObject(

      qryMaterijali.FieldByName(
        'name'
      ).AsString,

      TObject(
        NativeInt(
          KategorijaID
        )
      )

    );


    qryMaterijali.Next;

  end;


  qryMaterijali.Close;


  cmbKategorija.ItemIndex :=
    -1;

end;


// ============================================================
// PROMENA KATEGORIJE
// ============================================================

procedure TfraNoviZahtev.cmbKategorijaChange(
  Sender: TObject
);
begin

  // Brišemo staru jedinicu mere
  edtJedinicaMere.Clear;


  // Učitavamo materijale iz izabrane kategorije
  UcitajMaterijale;

end;


// ============================================================
// UČITAVANJE MATERIJALA
// ============================================================

procedure TfraNoviZahtev.UcitajMaterijale;
var
  MaterijalID: Integer;

  // NOVO
  KategorijaID: Integer;
begin

  cmbMaterijal.Clear;

  cmbMaterijal.Enabled :=
    False;


  if cmbKategorija.ItemIndex = -1 then
    Exit;


  // ==========================================================
  // NOVO
  // Uzimamo ID kategorije iz Objects.
  // ==========================================================

  KategorijaID :=
    Integer(
      NativeInt(
        cmbKategorija.Items.Objects[
          cmbKategorija.ItemIndex
        ]
      )
    );


  qryMaterijali.Close;


  // ==========================================================
  // NOVO
  //
  // Ranije:
  //
  // WHERE type = :type
  //
  // Sada:
  //
  // WHERE type_id = :type_id
  // ==========================================================

  qryMaterijali.SQL.Text :=

    'SELECT ' +
      'id, ' +
      'name ' +

    'FROM materials ' +

    'WHERE type_id = :type_id ' +

    'ORDER BY name';


  qryMaterijali.ParamByName(
    'type_id'
  ).AsInteger :=
    KategorijaID;


  qryMaterijali.Open;


  while not qryMaterijali.Eof do
  begin

    MaterijalID :=
      qryMaterijali.FieldByName(
        'id'
      ).AsInteger;


    // Korisnik vidi naziv,
    // a čuvamo ID materijala.
    cmbMaterijal.Items.AddObject(

      qryMaterijali.FieldByName(
        'name'
      ).AsString,

      TObject(
        NativeInt(
          MaterijalID
        )
      )

    );


    qryMaterijali.Next;

  end;


  qryMaterijali.Close;


  if cmbMaterijal.Items.Count > 0 then
    cmbMaterijal.Enabled :=
      True;


  cmbMaterijal.ItemIndex :=
    -1;

end;


// ============================================================
// PROMENA MATERIJALA
// ============================================================

procedure TfraNoviZahtev.cmbMaterijalChange(
  Sender: TObject
);
begin

  UcitajJedinicuMere;

end;


// ============================================================
// UČITAVANJE JEDINICE MERE
// ============================================================

procedure TfraNoviZahtev.UcitajJedinicuMere;
var
  MaterijalID: Integer;
begin

  edtJedinicaMere.Clear;


  if cmbMaterijal.ItemIndex = -1 then
    Exit;


  MaterijalID :=
    Integer(
      NativeInt(
        cmbMaterijal.Items.Objects[
          cmbMaterijal.ItemIndex
        ]
      )
    );


  qryMaterijali.Close;


  qryMaterijali.SQL.Text :=

    'SELECT unit ' +

    'FROM materials ' +

    'WHERE id = :id';


  qryMaterijali.ParamByName(
    'id'
  ).AsInteger :=
    MaterijalID;


  qryMaterijali.Open;


  if not qryMaterijali.IsEmpty then
  begin

    edtJedinicaMere.Text :=
      qryMaterijali.FieldByName(
        'unit'
      ).AsString;

  end;


  qryMaterijali.Close;

end;


// ============================================================
// SLANJE ZAHTEVA
// ============================================================

procedure TfraNoviZahtev.btnPosaljiZahtevClick(
  Sender: TObject
);
var
  MaterijalID: Integer;
  Kolicina: Double;
  TekstKolicine: string;
  FS: TFormatSettings;
begin

  // ==========================================================
  // PROVERA PRIJAVLJENOG KORISNIKA
  // ==========================================================

  if FKorisnikID <= 0 then
  begin

    ShowMessage(
      'Greška: nije pronađen prijavljeni korisnik.'
    );

    Exit;

  end;


  // ==========================================================
  // KATEGORIJA
  // ==========================================================

  if cmbKategorija.ItemIndex = -1 then
  begin

    ShowMessage(
      'Izaberite kategoriju.'
    );

    cmbKategorija.SetFocus;

    Exit;

  end;


  // ==========================================================
  // MATERIJAL
  // ==========================================================

  if cmbMaterijal.ItemIndex = -1 then
  begin

    ShowMessage(
      'Izaberite materijal.'
    );

    cmbMaterijal.SetFocus;

    Exit;

  end;


  // ==========================================================
  // KOLIČINA
  // ==========================================================

  if Trim(
    edtKolicina.Text
  ) = '' then
  begin

    ShowMessage(
      'Unesite količinu.'
    );

    edtKolicina.SetFocus;

    Exit;

  end;


  FS :=
    TFormatSettings.Create;


  TekstKolicine :=
    Trim(
      edtKolicina.Text
    );


  // Dozvoljavamo korisniku i:
  //
  // 10,5
  // 10.5

  TekstKolicine :=
    StringReplace(
      TekstKolicine,
      '.',
      FS.DecimalSeparator,
      [rfReplaceAll]
    );


  TekstKolicine :=
    StringReplace(
      TekstKolicine,
      ',',
      FS.DecimalSeparator,
      [rfReplaceAll]
    );


  if not TryStrToFloat(
    TekstKolicine,
    Kolicina,
    FS
  ) then
  begin

    ShowMessage(
      'Količina mora biti broj.'
    );

    edtKolicina.SetFocus;

    Exit;

  end;


  if Kolicina <= 0 then
  begin

    ShowMessage(
      'Količina mora biti veća od 0.'
    );

    edtKolicina.SetFocus;

    Exit;

  end;


  // ==========================================================
  // PRIORITET
  // ==========================================================

  if cmbPrioritet.ItemIndex = -1 then
  begin

    ShowMessage(
      'Izaberite prioritet.'
    );

    cmbPrioritet.SetFocus;

    Exit;

  end;


  // ==========================================================
  // DATUM
  // ==========================================================

  if Trunc(
    dtpDatumPotrebe.Date
  ) < Trunc(
    Date
  ) then
  begin

    ShowMessage(
      'Datum potrebe ne može biti u prošlosti.'
    );

    dtpDatumPotrebe.SetFocus;

    Exit;

  end;


  // ==========================================================
  // OBRAZLOŽENJE
  // ==========================================================

  if Trim(
    memRazlog.Text
  ) = '' then
  begin

    ShowMessage(
      'Unesite obrazloženje zahteva.'
    );

    memRazlog.SetFocus;

    Exit;

  end;


  // ==========================================================
  // ID MATERIJALA
  // ==========================================================

  MaterijalID :=
    Integer(
      NativeInt(
        cmbMaterijal.Items.Objects[
          cmbMaterijal.ItemIndex
        ]
      )
    );


  // ==========================================================
  // INSERT U REQUESTS
  //
  // OVDE SE NIŠTA NE MENJA.
  // Requests i dalje čuva material_id.
  // ==========================================================

  qryMaterijali.Close;


  qryMaterijali.SQL.Text :=

    'INSERT INTO requests ' +

    '(' +
      'user_id, ' +
      'material_id, ' +
      'quantity, ' +
      'priority, ' +
      'reason, ' +
      'needed_by, ' +
      'status' +
    ') ' +

    'VALUES ' +

    '(' +
      ':user_id, ' +
      ':material_id, ' +
      ':quantity, ' +
      ':priority, ' +
      ':reason, ' +
      ':needed_by, ' +
      '''pending''' +
    ')';


  qryMaterijali.ParamByName(
    'user_id'
  ).AsInteger :=
    FKorisnikID;


  qryMaterijali.ParamByName(
    'material_id'
  ).AsInteger :=
    MaterijalID;


  qryMaterijali.ParamByName(
    'quantity'
  ).AsFloat :=
    Kolicina;


  qryMaterijali.ParamByName(
    'priority'
  ).AsString :=
    cmbPrioritet.Text;


  qryMaterijali.ParamByName(
    'reason'
  ).AsString :=
    Trim(
      memRazlog.Text
    );


  // SQLite datum: YYYY-MM-DD
  qryMaterijali.ParamByName(
    'needed_by'
  ).AsString :=
    FormatDateTime(
      'yyyy-mm-dd',
      dtpDatumPotrebe.Date
    );


  try

    qryMaterijali.ExecSQL;


    ShowMessage(
      'Zahtev za nabavku je uspešno poslat.'
    );


    ResetujFormu;


  except

    on E: Exception do
    begin

      ShowMessage(
        'Greška prilikom slanja zahteva:' +
        sLineBreak +
        E.Message
      );

    end;

  end;

end;


// ============================================================
// RESETOVANJE FORME
// ============================================================

procedure TfraNoviZahtev.ResetujFormu;
begin

  cmbKategorija.ItemIndex :=
    -1;


  cmbMaterijal.Clear;

  cmbMaterijal.ItemIndex :=
    -1;

  cmbMaterijal.Enabled :=
    False;


  edtJedinicaMere.Clear;

  edtKolicina.Clear;


  cmbPrioritet.ItemIndex :=
    1;


  dtpDatumPotrebe.Date :=
    Date;


  memRazlog.Clear;


  cmbKategorija.SetFocus;

end;

end.
