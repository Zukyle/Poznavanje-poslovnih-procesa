unit uKorisnici;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Hash,

  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.CheckLst,
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
  TfraKorisnici = class(TFrame)

    pnlHeader: TPanel;
    lblNaslov: TLabel;
    lblOpis: TLabel;

    pnlDetalji: TPanel;
    lblDetaljiNaslov: TLabel;

    lblUsernameNaslov: TLabel;
    lblImeNaslov: TLabel;
    lblUlogaNaslov: TLabel;
    lblLozinkaNaslov: TLabel;
    edtUsername: TEdit;
    edtIme: TEdit;
    edtLozinka: TEdit;

    cmbUloga: TComboBox;
    chkAktivan: TCheckBox;

    btnNovi: TButton;

    Panel1: TPanel;
    btnSacuvaj: TButton;
    btnOdustani: TButton;

    pnlLista: TPanel;
    lblListaNaslov: TLabel;
    dbgKorisnici: TDBGrid;

    edtPretraga: TEdit;
    lblPretraga: TLabel;

  private

    // ========================================================
    // BAZA
    // ========================================================

    FQryKorisnici: TFDQuery;
    FDsKorisnici: TDataSource;


    // ========================================================
    // TRENUTNO IZABRANI KORISNIK
    // ========================================================

    FKorisnikID: Integer;

    // True = unos novog korisnika
    // False = izmena postojećeg
    FNoviKorisnik: Boolean;


    // ========================================================
    // UČITAVANJE
    // ========================================================

    procedure UcitajKorisnike;
    procedure UcitajUloge;
    procedure PodesiKolone;

    procedure UcitajSelektovanogKorisnika;

    procedure OcistiFormu;


    // ========================================================
    // DOGAĐAJI
    // ========================================================

    procedure edtPretragaChange(Sender: TObject);

    procedure qryKorisniciAfterScroll(
      DataSet: TDataSet
    );

    procedure btnNoviClick(Sender: TObject);

    procedure btnSacuvajClick(Sender: TObject);

    procedure btnOdustaniClick(Sender: TObject);


    // ========================================================
    // POMOĆNE FUNKCIJE
    // ========================================================

    function HashLozinke(
      const ALozinka: string
    ): string;

    function UsernamePostoji(
      const AUsername: string;
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

constructor TfraKorisnici.Create(
  AOwner: TComponent
);
begin
  inherited Create(AOwner);


  // ==========================================================
  // QUERY
  // ==========================================================

  FQryKorisnici :=
    TFDQuery.Create(Self);

  FQryKorisnici.Connection :=
    frmLogin.FDConnection1;


  // ==========================================================
  // DATASOURCE
  // ==========================================================

  FDsKorisnici :=
    TDataSource.Create(Self);

  FDsKorisnici.DataSet :=
    FQryKorisnici;


  // ==========================================================
  // GRID
  // ==========================================================

  dbgKorisnici.DataSource :=
    FDsKorisnici;

  dbgKorisnici.ReadOnly :=
    True;

  dbgKorisnici.Options :=
    dbgKorisnici.Options + [dgRowSelect];


  FQryKorisnici.AfterScroll :=
    qryKorisniciAfterScroll;


  // ==========================================================
  // COMBOBOX
  // ==========================================================

  cmbUloga.Style :=
    csDropDownList;


  // ==========================================================
  // LOZINKA
  // ==========================================================

  edtLozinka.PasswordChar :=
    '*';


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

  FKorisnikID :=
    0;

  FNoviKorisnik :=
    False;


  UcitajUloge;

  Osvezi;

end;


// ============================================================
// ULOGE
// ============================================================

procedure TfraKorisnici.UcitajUloge;
begin

  cmbUloga.Items.Clear;

  // Vrednosti moraju da odgovaraju CHECK ograničenju u bazi

  cmbUloga.Items.Add(
    'Podnosilac'
  );

  cmbUloga.Items.Add(
    'Menadzer'
  );

  cmbUloga.Items.Add(
    'Nabavka'
  );

  cmbUloga.Items.Add(
    'Magacioner'
  );

  cmbUloga.Items.Add(
    'Administrator'
  );


  cmbUloga.ItemIndex :=
    0;

end;


// ============================================================
// OSVEŽAVANJE
// ============================================================

procedure TfraKorisnici.Osvezi;
begin

  UcitajKorisnike;

end;


// ============================================================
// UČITAVANJE KORISNIKA
// ============================================================

procedure TfraKorisnici.UcitajKorisnike;
var
  PrethodniID: Integer;
begin

  PrethodniID :=
    FKorisnikID;


  FQryKorisnici.Close;


  FQryKorisnici.SQL.Text :=

    'SELECT ' +

    'u.id, ' +

    // ========================================================
    // USERNAME
    // ========================================================

    'CAST(u.username AS VARCHAR(100)) ' +
    'AS username, ' +


    // ========================================================
    // IME
    // ========================================================

    'CAST(u.name AS VARCHAR(150)) ' +
    'AS ime, ' +


    // ========================================================
    // ULOGA
    // ========================================================

    'CAST(u.role AS VARCHAR(50)) ' +
    'AS uloga, ' +


    // ========================================================
    // ACTIVE RAW
    // ========================================================

    'u.active, ' +


    // ========================================================
    // STATUS ZA PRIKAZ
    // ========================================================

    'CAST(' +

      'CASE ' +

        'WHEN u.active = 1 ' +
        'THEN ''Aktivan'' ' +

        'ELSE ''Neaktivan'' ' +

      'END ' +

    'AS VARCHAR(30)) ' +
    'AS status_prikaz ' +


    // ========================================================
    // TABELA
    // ========================================================

    'FROM users u ' +


    // ========================================================
    // PRETRAGA
    // ========================================================

    'WHERE (' +

      ':pretraga = '''' ' +

      'OR LOWER(u.username) ' +
      'LIKE LOWER(:pretraga_like) ' +

      'OR LOWER(u.name) ' +
      'LIKE LOWER(:pretraga_like) ' +

      'OR LOWER(u.role) ' +
      'LIKE LOWER(:pretraga_like) ' +

    ') ' +


    // ========================================================
    // SORTIRANJE
    // ========================================================

    'ORDER BY ' +
    'u.active DESC, ' +
    'u.name ASC';


  FQryKorisnici.ParamByName(
    'pretraga'
  ).AsString :=
    Trim(
      edtPretraga.Text
    );


  FQryKorisnici.ParamByName(
    'pretraga_like'
  ).AsString :=
    '%' +
    Trim(
      edtPretraga.Text
    ) +
    '%';


  try

    FQryKorisnici.Open;


    PodesiKolone;


    // ========================================================
    // VRAĆAMO PRETHODNO IZABRANOG KORISNIKA
    // ========================================================

    if PrethodniID <> 0 then
    begin

      if not FQryKorisnici.Locate(
        'id',
        PrethodniID,
        []
      ) then
      begin

        FQryKorisnici.First;

      end;

    end;


    if not FQryKorisnici.IsEmpty then
    begin

      UcitajSelektovanogKorisnika;

    end
    else
    begin

      FKorisnikID :=
        0;

      OcistiFormu;

    end;


  except

    on E: Exception do
    begin

      ShowMessage(
        'Greška prilikom učitavanja korisnika:' +
        sLineBreak +
        E.Message
      );

    end;

  end;

end;


// ============================================================
// PODEŠAVANJE KOLONA
// ============================================================

procedure TfraKorisnici.PodesiKolone;
begin

  dbgKorisnici.Columns.Clear;


  // ==========================================================
  // USERNAME
  // ==========================================================

  with dbgKorisnici.Columns.Add do
  begin

    FieldName :=
      'username';

    Title.Caption :=
      'Korisničko ime';

    Width :=
      130;

  end;


  // ==========================================================
  // IME
  // ==========================================================

  with dbgKorisnici.Columns.Add do
  begin

    FieldName :=
      'ime';

    Title.Caption :=
      'Ime i prezime';

    Width :=
      180;

  end;


  // ==========================================================
  // ULOGA
  // ==========================================================

  with dbgKorisnici.Columns.Add do
  begin

    FieldName :=
      'uloga';

    Title.Caption :=
      'Uloga';

    Width :=
      120;

  end;


  // ==========================================================
  // STATUS
  // ==========================================================

  with dbgKorisnici.Columns.Add do
  begin

    FieldName :=
      'status_prikaz';

    Title.Caption :=
      'Status';

    Width :=
      90;

  end;

end;


// ============================================================
// PROMENA REDA U TABELI
// ============================================================

procedure TfraKorisnici.qryKorisniciAfterScroll(
  DataSet: TDataSet
);
begin

  if FNoviKorisnik then
    Exit;


  if FQryKorisnici.Active and
     (not FQryKorisnici.IsEmpty) then
  begin

    UcitajSelektovanogKorisnika;

  end;

end;


// ============================================================
// UČITAVANJE IZABRANOG KORISNIKA
// ============================================================

procedure TfraKorisnici.UcitajSelektovanogKorisnika;
var
  UlogaIndex: Integer;
begin

  if (not FQryKorisnici.Active) or
     FQryKorisnici.IsEmpty then
  begin

    FKorisnikID :=
      0;

    OcistiFormu;

    Exit;

  end;


  FNoviKorisnik :=
    False;


  FKorisnikID :=
    FQryKorisnici.FieldByName(
      'id'
    ).AsInteger;


  // ==========================================================
  // USERNAME
  // ==========================================================

  edtUsername.Text :=
    FQryKorisnici.FieldByName(
      'username'
    ).AsString;


  // ==========================================================
  // IME
  // ==========================================================

  edtIme.Text :=
    FQryKorisnici.FieldByName(
      'ime'
    ).AsString;


  // ==========================================================
  // ULOGA
  // ==========================================================

  UlogaIndex :=
    cmbUloga.Items.IndexOf(
      FQryKorisnici.FieldByName(
        'uloga'
      ).AsString
    );


  if UlogaIndex >= 0 then
    cmbUloga.ItemIndex :=
      UlogaIndex
  else
    cmbUloga.ItemIndex :=
      -1;


  // ==========================================================
  // ACTIVE
  // ==========================================================

  chkAktivan.Checked :=
    FQryKorisnici.FieldByName(
      'active'
    ).AsInteger = 1;


  // ==========================================================
  // LOZINKU NE PRIKAZUJEMO
  // ==========================================================

  edtLozinka.Clear;


  lblLozinkaNaslov.Caption :=
    'Nova lozinka (ostavite prazno ako se ne menja)';

end;


// ============================================================
// NOVI KORISNIK
// ============================================================

procedure TfraKorisnici.btnNoviClick(
  Sender: TObject
);
begin

  FNoviKorisnik :=
    True;

  FKorisnikID :=
    0;


  OcistiFormu;


  chkAktivan.Checked :=
    True;


  if cmbUloga.Items.Count > 0 then
    cmbUloga.ItemIndex :=
      0;


  lblLozinkaNaslov.Caption :=
    'Lozinka';


  edtUsername.SetFocus;

end;


// ============================================================
// ČIŠĆENJE FORME
// ============================================================

procedure TfraKorisnici.OcistiFormu;
begin

  edtUsername.Clear;

  edtIme.Clear;

  edtLozinka.Clear;


  if cmbUloga.Items.Count > 0 then
    cmbUloga.ItemIndex :=
      0
  else
    cmbUloga.ItemIndex :=
      -1;


  chkAktivan.Checked :=
    True;


  if FNoviKorisnik then
  begin

    lblDetaljiNaslov.Caption :=
      'Novi korisnik';

    lblLozinkaNaslov.Caption :=
      'Lozinka';

  end
  else
  begin

    lblDetaljiNaslov.Caption :=
      'Podaci o korisniku';

    lblLozinkaNaslov.Caption :=
      'Nova lozinka';

  end;

end;


// ============================================================
// HASH LOZINKE
// ============================================================

function TfraKorisnici.HashLozinke(
  const ALozinka: string
): string;
begin

  Result :=
    THashSHA2.GetHashString(
      ALozinka
    );

end;


// ============================================================
// PROVERA USERNAME-A
// ============================================================

function TfraKorisnici.UsernamePostoji(
  const AUsername: string;
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

      'FROM users ' +

      'WHERE LOWER(username) = LOWER(:username) ' +

      'AND id <> :id';


    Q.ParamByName(
      'username'
    ).AsString :=
      Trim(
        AUsername
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

procedure TfraKorisnici.btnSacuvajClick(
  Sender: TObject
);
var
  Q: TFDQuery;

  Username: string;
  Ime: string;
  Lozinka: string;
  Uloga: string;

  Active: Integer;
begin

  Username :=
    Trim(
      edtUsername.Text
    );


  Ime :=
    Trim(
      edtIme.Text
    );


  Lozinka :=
    edtLozinka.Text;


  // ==========================================================
  // USERNAME
  // ==========================================================

  if Username = '' then
  begin

    ShowMessage(
      'Unesite korisničko ime.'
    );

    edtUsername.SetFocus;

    Exit;

  end;


  // ==========================================================
  // IME
  // ==========================================================

  if Ime = '' then
  begin

    ShowMessage(
      'Unesite ime i prezime korisnika.'
    );

    edtIme.SetFocus;

    Exit;

  end;


  // ==========================================================
  // ULOGA
  // ==========================================================

  if cmbUloga.ItemIndex < 0 then
  begin

    ShowMessage(
      'Izaberite ulogu korisnika.'
    );

    cmbUloga.SetFocus;

    Exit;

  end;


  Uloga :=
    cmbUloga.Text;


  // ==========================================================
  // LOZINKA ZA NOVOG KORISNIKA
  // ==========================================================

  if FNoviKorisnik and
     (Trim(Lozinka) = '') then
  begin

    ShowMessage(
      'Unesite lozinku za novog korisnika.'
    );

    edtLozinka.SetFocus;

    Exit;

  end;


  // ==========================================================
  // DUPLIKAT USERNAME-A
  // ==========================================================

  if UsernamePostoji(
    Username,
    FKorisnikID
  ) then
  begin

    ShowMessage(
      'Korisničko ime već postoji.' +
      sLineBreak +
      'Unesite drugo korisničko ime.'
    );

    edtUsername.SetFocus;

    Exit;

  end;


  if chkAktivan.Checked then
    Active := 1
  else
    Active := 0;


  Q :=
    TFDQuery.Create(nil);

  try

    Q.Connection :=
      frmLogin.FDConnection1;


    // ========================================================
    // NOVI KORISNIK
    // ========================================================

    if FNoviKorisnik then
    begin

      Q.SQL.Text :=

        'INSERT INTO users ' +

        '(' +
          'username, ' +
          'password_hash, ' +
          'name, ' +
          'role, ' +
          'active' +
        ') ' +

        'VALUES ' +

        '(' +
          ':username, ' +
          ':password_hash, ' +
          ':name, ' +
          ':role, ' +
          ':active' +
        ')';


      Q.ParamByName(
        'username'
      ).AsString :=
        Username;


      Q.ParamByName(
        'password_hash'
      ).AsString :=
        HashLozinke(
          Lozinka
        );


      Q.ParamByName(
        'name'
      ).AsString :=
        Ime;


      Q.ParamByName(
        'role'
      ).AsString :=
        Uloga;


      Q.ParamByName(
        'active'
      ).AsInteger :=
        Active;


      try

        Q.ExecSQL;


        // Dohvatamo ID upravo dodatog korisnika

        Q.Close;


        Q.SQL.Text :=
          'SELECT last_insert_rowid() AS id';


        Q.Open;


        FKorisnikID :=
          Q.FieldByName(
            'id'
          ).AsInteger;


        FNoviKorisnik :=
          False;


        ShowMessage(
          'Korisnik je uspešno dodat.'
        );


      except

        on E: Exception do
        begin

          ShowMessage(
            'Greška prilikom dodavanja korisnika:' +
            sLineBreak +
            E.Message
          );

          Exit;

        end;

      end;

    end


    // ========================================================
    // IZMENA POSTOJEĆEG KORISNIKA
    // ========================================================

    else
    begin

      if FKorisnikID = 0 then
      begin

        ShowMessage(
          'Izaberite korisnika kojeg želite da izmenite.'
        );

        Exit;

      end;


      // ======================================================
      // AKO JE UNETA NOVA LOZINKA
      // ======================================================

      if Trim(Lozinka) <> '' then
      begin

        Q.SQL.Text :=

          'UPDATE users ' +

          'SET ' +
            'username = :username, ' +
            'name = :name, ' +
            'role = :role, ' +
            'active = :active, ' +
            'password_hash = :password_hash ' +

          'WHERE id = :id';


        Q.ParamByName(
          'password_hash'
        ).AsString :=
          HashLozinke(
            Lozinka
          );

      end


      // ======================================================
      // LOZINKA SE NE MENJA
      // ======================================================

      else
      begin

        Q.SQL.Text :=

          'UPDATE users ' +

          'SET ' +
            'username = :username, ' +
            'name = :name, ' +
            'role = :role, ' +
            'active = :active ' +

          'WHERE id = :id';

      end;


      Q.ParamByName(
        'username'
      ).AsString :=
        Username;


      Q.ParamByName(
        'name'
      ).AsString :=
        Ime;


      Q.ParamByName(
        'role'
      ).AsString :=
        Uloga;


      Q.ParamByName(
        'active'
      ).AsInteger :=
        Active;


      Q.ParamByName(
        'id'
      ).AsInteger :=
        FKorisnikID;


      try

        Q.ExecSQL;


        ShowMessage(
          'Podaci korisnika su uspešno sačuvani.'
        );


      except

        on E: Exception do
        begin

          ShowMessage(
            'Greška prilikom izmene korisnika:' +
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


  // ==========================================================
  // OSVEŽAVANJE
  // ==========================================================

  UcitajKorisnike;

end;


// ============================================================
// ODUSTANI
// ============================================================

procedure TfraKorisnici.btnOdustaniClick(
  Sender: TObject
);
begin

  FNoviKorisnik :=
    False;


  if FQryKorisnici.Active and
     (not FQryKorisnici.IsEmpty) then
  begin

    UcitajSelektovanogKorisnika;

  end
  else
  begin

    FKorisnikID :=
      0;

    OcistiFormu;

  end;

end;


// ============================================================
// PRETRAGA
// ============================================================

procedure TfraKorisnici.edtPretragaChange(
  Sender: TObject
);
begin

  FNoviKorisnik :=
    False;

  UcitajKorisnike;

end;

end.
