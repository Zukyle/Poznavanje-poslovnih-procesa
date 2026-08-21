program SistemNabavke;

uses
  Vcl.Forms,
  uLogin in 'uLogin.pas' {frmLogin},
  uGlavna in 'uGlavna.pas' {frmGlavna},
  uNoviZahtev in 'uNoviZahtev.pas' {fraNoviZahtev: TFrame},
  uMojiZahtevi in 'uMojiZahtevi.pas' {fraMojiZahtevi: TFrame},
  uZahteviOdobrenje in 'uZahteviOdobrenje.pas' {fraZahteviOdobrenje: TFrame},
  uSviZahtevi in 'uSviZahtevi.pas' {fraSviZahtevi: TFrame},
  uOdobreniZahtevi in 'uOdobreniZahtevi.pas' {fraOdobreniZahtevi: TFrame},
  uDobavljaci in 'uDobavljaci.pas' {fraDobavljaci: TFrame},
  uPonude in 'uPonude.pas' {fraPonude: TFrame},
  uNarudzbenice in 'uNarudzbenice.pas' {fraNarudzbenice: TFrame},
  uAktivneNabavke in 'uAktivneNabavke.pas' {fraAktivneNabavke: TFrame},
  uOcekivaneIsporuke in 'uOcekivaneIsporuke.pas' {fraOcekivaneIsporuke: TFrame},
  uPrijemRobe in 'uPrijemRobe.pas' {fraPrijemRobe: TFrame},
  uMagacin in 'uMagacin.pas' {fraMagacin: TFrame},
  uKorisnici in 'uKorisnici.pas' {fraKorisnici: TFrame},
  uMaterijali in 'uMaterijali.pas' {fraMaterijali: TFrame},
  uOsnovniPodaci in 'uOsnovniPodaci.pas' {fraOsnovniPodaci: TFrame},
  uDashboard in 'uDashboard.pas' {fraDashboard: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmGlavna, frmGlavna);
  Application.Run;
end.
