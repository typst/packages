#import "@preview/marius-dhbw-thesis:0.1.0": (
  dhbw-template,
  vglcite,
  vglcites,
)

// ============================================================
// Metadaten der Arbeit
// ============================================================

#let meta = (
  art-der-arbeit: "Bachelorarbeit",
  titel-der-arbeit: "Titel der wissenschaftlichen Arbeit",

  titel-zeile1: [
    Titel der wissenschaftlichen Arbeit
  ],

  titel-zeile2: [],

  autor-der-arbeit: "Vorname Nachname",
  anschrift-zeile1: "Straße Hausnummer",
  anschrift-zeile2: "PLZ Ort",

  abteilung: "Abteilung",
  firma: "Unternehmen, Ort",
  kurs: "Kurs",
  studienrichtung: "Digital Business Management",
  matrikelnummer: "1234567",

  studiengangsleiter: "Name",
  wiss-betreuer: "Name",
  firmen-betreuer: "Name",

  abgabedatum: "TT.MM.JJJJ",
)

// ============================================================
// Abkürzungsverzeichnis
// ============================================================

#let acronyms = ()

// ============================================================
// Optionale Bestandteile
// ============================================================

#let nondisclosure = none
#let gender-notice = none
#let appendix = none

// ============================================================
// Literaturverzeichnis
// ============================================================

#let references = bibliography(
  "bibliography.bib",
  title: none,
  style: "harvard-cite-them-right",
)

// ============================================================
// Dokumentvorlage
// ============================================================

#show: body => dhbw-template(
  meta: meta,

  acronyms: acronyms,
  nondisclosure: nondisclosure,
  gender-notice: gender-notice,
  appendix: appendix,

  bibliography-content: references,

  body,
)

// ============================================================
// Inhalt der Arbeit
// ============================================================

= Beispielkapitel