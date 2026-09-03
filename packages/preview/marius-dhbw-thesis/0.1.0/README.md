# Marius DHBW Thesis

Eine konfigurierbare Typst-Vorlage für wissenschaftliche Arbeiten an der Dualen Hochschule Baden-Württemberg.

Die Vorlage stellt unter anderem folgende Bestandteile bereit:

- Titelseite
- konfigurierbares Seiten- und Textlayout
- römische und arabische Seitennummerierung
- Inhaltsverzeichnis
- Abbildungsverzeichnis
- Abkürzungsverzeichnis
- optionaler Sperrvermerk
- optionaler Gender-Hinweis
- optionaler Anhang
- Literaturverzeichnis
- ehrenwörtliche Erklärung
- Funktionen für Einzel- und Mehrfachzitate

> Diese Vorlage ist ein unabhängiges Projekt und keine offizielle Vorlage der Dualen Hochschule Baden-Württemberg.

## Verwendung als Vorlage

In Typst Web kann über **Start from template** ein neues Projekt auf Basis der Vorlage erstellt werden.

Bei lokaler Verwendung kann ein neues Projekt über die Typst-CLI angelegt werden:

```bash
typst init @preview/marius-dhbw-thesis:0.1.0
```

## Verwendung als Package

Das Package kann in einem bestehenden Typst-Projekt importiert werden:

```typst
#import "@preview/marius-dhbw-thesis:0.1.0": (
  dhbw-template,
  vglcite,
  vglcites,
)
```

## Grundprinzip

Die Standardeinstellungen befinden sich im Package und müssen nicht verändert werden.

Individuelle Anpassungen erfolgen ausschließlich in der eigenen `main.typ`:

```typst
#show: body => dhbw-template(
  meta: meta,
  acronyms: acronyms,
  bibliography-content: references,
  body,
)
```

Wenn keine zusätzlichen Parameter angegeben werden, verwendet die Vorlage ihre Standardwerte.

Abweichungen werden als zusätzliche Parameter übergeben:

```typst
#show: body => dhbw-template(
  meta: meta,

  font: "Arial",
  font-size: 11pt,

  acronyms: acronyms,
  bibliography-content: references,

  body,
)
```

Es müssen nur die Parameter angegeben werden, die vom Standard abweichen sollen.

## Minimales Beispiel

```typst
#import "@preview/marius-dhbw-thesis:0.1.0": (
  dhbw-template,
  vglcite,
  vglcites,
)

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

#let acronyms = ()

#let references = bibliography(
  "bibliography.bib",
  title: none,
  style: "harvard-cite-them-right",
)

#show: body => dhbw-template(
  meta: meta,
  acronyms: acronyms,
  bibliography-content: references,
  body,
)

= Einleitung

Hier beginnt die wissenschaftliche Arbeit.
```

## Metadaten

Die Angaben zur Arbeit werden als Dictionary definiert:

```typst
#let meta = (
  art-der-arbeit: "Bachelorarbeit",
  titel-der-arbeit: "Titel der Bachelorarbeit",

  titel-zeile1: [
    Titel der Bachelorarbeit
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
```

Bei langen Titeln kann die Darstellung auf der Titelseite auf zwei Zeilen verteilt werden:

```typst
titel-zeile1: [
  Entwicklung einer Anwendung zur automatisierten
],

titel-zeile2: [
  Unterstützung betrieblicher Prozesse
],
```

`titel-der-arbeit` enthält unabhängig davon den vollständigen Titel, unter anderem für die ehrenwörtliche Erklärung.

## Kapitel erstellen

Der Inhalt beginnt unterhalb des Template-Aufrufs:

```typst
#show: body => dhbw-template(
  meta: meta,
  acronyms: acronyms,
  bibliography-content: references,
  body,
)

= Einleitung

== Problemstellung

Hier beginnt der Text.

== Zielsetzung

Hier beginnt der nächste Abschnitt.

= Theoretische Grundlagen
```

Für Überschriften gilt:

```typst
= Kapitel
== Unterkapitel
=== Unterunterkapitel
```

Die Vorlage gibt keine feste Kapitelstruktur vor.

### Kapitel in eigene Dateien auslagern

Kapitel können frei in eigenen Dateien organisiert werden:

```text
chapters/
├── einleitung.typ
├── grundlagen.typ
├── methodik.typ
└── fazit.typ
```

Einbindung in `main.typ`:

```typst
#include "chapters/einleitung.typ"
#include "chapters/grundlagen.typ"
#include "chapters/methodik.typ"
#include "chapters/fazit.typ"
```

Die Includes werden unterhalb des Aufrufs von `dhbw-template` eingefügt.

## Format überschreiben

### Schriftart ändern

```typst
#show: body => dhbw-template(
  meta: meta,
  font: "Arial",
  bibliography-content: references,
  body,
)
```

### Schriftgröße ändern

```typst
#show: body => dhbw-template(
  meta: meta,
  font-size: 11pt,
  bibliography-content: references,
  body,
)
```

### Absatzformatierung ändern

```typst
#show: body => dhbw-template(
  meta: meta,

  paragraph-justify: true,
  paragraph-leading: 0.9em,
  paragraph-spacing: 1em,

  bibliography-content: references,
  body,
)
```

### Seitenränder ändern

```typst
#show: body => dhbw-template(
  meta: meta,

  page-margin: (
    left: 3cm,
    right: 2.5cm,
    top: 2.5cm,
    bottom: 2.5cm,
  ),

  bibliography-content: references,
  body,
)
```

### Überschriften ändern

```typst
#show: body => dhbw-template(
  meta: meta,

  heading-numbering: "1.1.1",
  heading-align: left,
  heading-below: 1.2em,

  bibliography-content: references,
  body,
)
```

### Mehrere Einstellungen überschreiben

```typst
#show: body => dhbw-template(
  meta: meta,

  font: "Arial",
  font-size: 11pt,

  paragraph-leading: 0.9em,

  page-margin: (
    left: 3cm,
    right: 2.5cm,
    top: 2.5cm,
    bottom: 2.5cm,
  ),

  acronyms: acronyms,
  bibliography-content: references,

  body,
)
```

Alle nicht angegebenen Parameter behalten ihre Standardwerte.

## Logos verwenden

Logos werden nicht durch das Package bereitgestellt. Sie werden im eigenen Projekt gespeichert und als fertiger Bildinhalt an die Vorlage übergeben.

Beispielhafte Projektstruktur:

```text
project/
├── main.typ
├── bibliography.bib
└── img/
    ├── firmenlogo.png
    └── hochschullogo.png
```

Übergabe an die Vorlage:

```typst
#show: body => dhbw-template(
  meta: meta,

  company-logo: image(
    "img/firmenlogo.png",
    height: 2cm,
    fit: "contain",
  ),

  university-logo: image(
    "img/hochschullogo.png",
    height: 2cm,
    fit: "contain",
  ),

  bibliography-content: references,
  body,
)
```

Falls kein Logo verwendet werden soll:

```typst
company-logo: none,
university-logo: none,
```

Nutzende sind selbst dafür verantwortlich, dass die erforderlichen Nutzungsrechte für verwendete Logos und Bilder vorliegen.

## Abkürzungsverzeichnis

Abkürzungen werden in `main.typ` definiert:

```typst
#let acronyms = (
  ("API", "Application Programming Interface"),
  ("BESS", "Battery Energy Storage System"),
  ("IT", "Informationstechnologie"),
  ("PDF", "Portable Document Format"),
)
```

Die Abkürzungen werden an die Vorlage übergeben:

```typst
#show: body => dhbw-template(
  meta: meta,
  acronyms: acronyms,
  bibliography-content: references,
  body,
)
```

Wenn kein Abkürzungsverzeichnis benötigt wird:

```typst
#let acronyms = ()
```

## Sperrvermerk

Ein Sperrvermerk wird als Inhalt definiert:

```typst
#let nondisclosure = [
  Der Inhalt dieser Arbeit darf weder als Ganzes noch in
  Auszügen Personen außerhalb des Prüfungs- und
  Evaluationsverfahrens zugänglich gemacht werden, sofern
  keine anders lautende Genehmigung des Unternehmens vorliegt.
]
```

Übergabe an die Vorlage:

```typst
#show: body => dhbw-template(
  meta: meta,
  nondisclosure: nondisclosure,
  bibliography-content: references,
  body,
)
```

Wenn kein Sperrvermerk benötigt wird:

```typst
#let nondisclosure = none
```

## Gender-Hinweis

```typst
#let gender-notice = [
  In dieser Arbeit wird aus Gründen der besseren Lesbarkeit
  das generische Maskulinum verwendet. Weibliche und andere
  Geschlechteridentitäten werden ausdrücklich mitgemeint,
  soweit die Aussagen dies erfordern.
]
```

Übergabe an die Vorlage:

```typst
#show: body => dhbw-template(
  meta: meta,
  gender-notice: gender-notice,
  bibliography-content: references,
  body,
)
```

Wenn kein Gender-Hinweis benötigt wird:

```typst
#let gender-notice = none
```

## Anhang

Der Anhang kann direkt in `main.typ` definiert werden:

```typst
#let appendix = [
  = Ergänzende Auswertungen

  Hier stehen die ergänzenden Inhalte.
]
```

Übergabe an die Vorlage:

```typst
#show: body => dhbw-template(
  meta: meta,
  appendix: appendix,
  bibliography-content: references,
  body,
)
```

Der Anhang kann alternativ aus einer eigenen Datei geladen werden:

```typst
#let appendix = [
  #include "appendix/anhang.typ"
]
```

Wenn kein Anhang benötigt wird:

```typst
#let appendix = none
```

## Literaturverzeichnis

Alle Quellen werden im eigenen Projekt in einer BibLaTeX-Datei verwaltet:

```text
bibliography.bib
```

Beispiel:

```bibtex
@book{mustermann2025,
  author    = {Mustermann, Max},
  title     = {Grundlagen der Digitalisierung},
  year      = {2025},
  publisher = {Beispielverlag}
}
```

Die Bibliografie wird in `main.typ` erstellt:

```typst
#let references = bibliography(
  "bibliography.bib",
  title: none,
  style: "harvard-cite-them-right",
)
```

Anschließend wird sie an die Vorlage übergeben:

```typst
#show: body => dhbw-template(
  meta: meta,
  bibliography-content: references,
  body,
)
```

Ein anderer Zitierstil kann direkt in `main.typ` angegeben werden:

```typst
#let references = bibliography(
  "bibliography.bib",
  title: none,
  style: "apa",
)
```

Wenn kein Literaturverzeichnis ausgegeben werden soll:

```typst
bibliography-content: none,
```

## Quellen zitieren

Das Package stellt die Funktionen `vglcite` und `vglcites` bereit.

### Einzelzitat mit Fundstelle

```typst
#vglcite(
  <mustermann2025>,
  loc: [S. 10],
)
```

Erwartete Ausgabe:

```text
(vgl. Mustermann, 2025, S. 10)
```

### Einzelzitat ohne Fundstelle

```typst
#vglcite(<mustermann2025>)
```

### Jahr überschreiben

Für Quellen ohne angegebenes Jahr:

```typst
#vglcite(
  <webseite>,
  year-override: [o. J.],
)
```

### Jahreszusatz manuell angeben

```typst
#vglcite(
  <mustermann2025>,
  year-suffix: [a],
  loc: [S. 10],
)
```

Erwartete Ausgabe:

```text
(vgl. Mustermann, 2025a, S. 10)
```

### Mehrfachzitat

```typst
#vglcites(
  (<mustermann2025>, [S. 10]),
  (<beispiel2024>, [S. 25–27]),
)
```

Die Tupelform ist wie folgt aufgebaut:

```typst
(
  <quellenschluessel>,
  [Fundstelle],
  [überschriebenes Jahr],
  [Jahreszusatz],
)
```

Alle Angaben nach dem Quellenschlüssel sind optional.

Beispiel:

```typst
#vglcites(
  (<quelle1>, [S. 10]),
  (<quelle2>, none, [o. J.]),
  (<quelle3>, [S. 20], none, [a]),
)
```

## Automatische Jahreszusätze

Jahreszusätze können im eigenen Projekt über einen Resolver definiert werden:

```typst
#let my-year-suffix(key) = {
  if key == <mustermann2025a> {
    [a]
  } else if key == <mustermann2025b> {
    [b]
  } else {
    none
  }
}
```

Verwendung beim Einzelzitat:

```typst
#vglcite(
  <mustermann2025a>,
  loc: [S. 10],
  year-suffix-resolver: my-year-suffix,
)
```

Verwendung beim Mehrfachzitat:

```typst
#vglcites(
  (<mustermann2025a>, [S. 10]),
  (<mustermann2025b>, [S. 20]),
  year-suffix-resolver: my-year-suffix,
)
```

## Automatische Kurztitel

Kurztitel können ebenfalls im eigenen Projekt definiert werden:

```typst
#let my-short-title(key) = {
  if key == <unternehmenUeberUns> {
    [Über uns]
  } else if key == <unternehmenKennzahlen> {
    [Kennzahlen]
  } else {
    none
  }
}
```

Verwendung:

```typst
#vglcite(
  <unternehmenKennzahlen>,
  year-override: [o. J.],
  short-title-resolver: my-short-title,
)
```

Erwartete Ausgabe:

```text
(vgl. Unternehmen, o. J., „Kennzahlen“)
```

Jahreszusätze und Kurztitel können kombiniert werden:

```typst
#vglcite(
  <unternehmenKennzahlen>,
  year-override: [o. J.],
  year-suffix-resolver: my-year-suffix,
  short-title-resolver: my-short-title,
)
```

## Bilder einfügen

Bilder können im eigenen Projekt gespeichert und mit `figure` eingefügt werden:

```typst
#figure(
  image(
    "img/prozessdarstellung.png",
    width: 80%,
  ),
  caption: [Darstellung des untersuchten Prozesses],
)
```

Beschriftete Abbildungen werden automatisch in das Abbildungsverzeichnis aufgenommen.

## Eigene Funktionen ergänzen

Zusätzliche Funktionen werden im eigenen Projekt definiert. Der Package-Code muss dafür nicht verändert werden.

Beispiel:

```typst
#let hinweis(body) = block(
  fill: luma(240),
  stroke: 0.5pt + gray,
  inset: 8pt,
  body,
)
```

Verwendung:

```typst
#hinweis[
  Dies ist ein zusätzlicher Hinweis.
]
```

Weitere Importe, Variablen und Inhalte können ebenfalls frei ergänzt werden.

## Optionen deaktivieren

Einzelne Bestandteile können über die entsprechenden Parameter deaktiviert werden:

```typst
#show: body => dhbw-template(
  meta: meta,

  show-table-of-contents: false,
  show-figure-outline: false,
  show-declaration: false,

  nondisclosure: none,
  gender-notice: none,
  appendix: none,
  bibliography-content: none,

  body,
)
```

## Kompilieren

Das Dokument kann über die Typst-Web-App oder lokal über die Typst-CLI kompiliert werden:

```bash
typst compile main.typ
```

Standardmäßig wird eine `main.pdf` erzeugt.

Für die kontinuierliche Vorschau bei lokaler Bearbeitung:

```bash
typst watch main.typ
```

## Öffentliche Funktionen

Das Package exportiert folgende Funktionen:

### `dhbw-template`

Erzeugt das vollständige Dokumentlayout und nimmt den Inhalt der Arbeit als letztes positionsbezogenes Argument entgegen.

Grundlegender Aufruf:

```typst
#show: body => dhbw-template(
  meta: meta,
  body,
)
```

### `vglcite`

Erzeugt ein einzelnes indirektes Zitat:

```typst
#vglcite(
  <quellenschluessel>,
  loc: [S. 10],
)
```

### `vglcites`

Erzeugt ein indirektes Mehrfachzitat:

```typst
#vglcites(
  (<quelle1>, [S. 10]),
  (<quelle2>, [S. 20]),
)
```

## Hinweise

- Die Einhaltung der jeweils gültigen Hochschul- und Prüfungsvorgaben muss vor der Abgabe eigenständig geprüft werden.
- Die Vorlage erhebt keinen Anspruch auf formale Vollständigkeit für alle Studiengänge oder Standorte.
- Verwendete Logos und Bilder müssen durch die Nutzenden selbst bereitgestellt werden.
- Für Logos, Bilder, Literatur und sonstige Inhalte müssen die jeweiligen Nutzungsrechte beachtet werden.
- Verfügbarkeit und Darstellung einer Schriftart können von der verwendeten Typst-Umgebung abhängen.

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Weitere Informationen befinden sich in der Datei `LICENSE`.