#import "@preview/marius-dhbw-thesis:0.2.0": (
  dhbw-template,
  vglcite,
  vglcites,
)

// false = deutsche Vorlage
// true = englische Vorlage
#let english = false

// ============================================================
// Metadaten der Arbeit
// ============================================================

#let meta = (
  art-der-arbeit: auto,
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
  studienjahrgang: "Studienjahrgang",
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
#let abstract = none
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
  english: english,
  meta: meta,

  acronyms: acronyms,
  nondisclosure: nondisclosure,
  abstract: abstract,
  gender-notice: gender-notice,
  appendix: appendix,

  bibliography-content: references,

  body,
)

// ============================================================
// Inhalt der Arbeit
// ============================================================

= Beispielkapitel