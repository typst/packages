# Marius DHBW Thesis

A configurable template for academic theses at Baden-Wuerttemberg Cooperative State University (DHBW). It provides a customizable title page, front matter, page numbering, bibliography formatting, optional sections, and citation helpers.

> This package is an independent project and is not an official template of Baden-Wuerttemberg Cooperative State University.

Eine konfigurierbare Typst-Vorlage für wissenschaftliche Arbeiten an der Dualen Hochschule Baden-Württemberg.

Die Vorlage stellt unter anderem folgende Bestandteile bereit:

- Titelseite
- konfigurierbares Seiten- und Textlayout
- römische und arabische Seitennummerierung
- Inhaltsverzeichnis
- Abbildungsverzeichnis
- Abkürzungsverzeichnis
- optionaler Sperrvermerk
- optionaler Abstract mit Metadaten
- optionaler Gender-Hinweis
- optionaler Anhang
- Literaturverzeichnis
- ehrenwörtliche Erklärung
- Funktionen für Einzel- und Mehrfachzitate

> Diese Vorlage ist ein unabhängiges Projekt und keine offizielle Vorlage der Dualen Hochschule Baden-Württemberg.

## Verwendung als Vorlage

In Typst Web kann über **Start from template** ein neues Projekt auf Basis der Vorlage erstellt werden.

Nach Veröffentlichung von Version 0.2.0 kann ein neues Projekt über die Typst-CLI angelegt werden:

```bash
typst init @preview/marius-dhbw-thesis:0.2.0
```

## Verwendung als Package

Nach Veröffentlichung kann das Package in einem bestehenden Typst-Projekt importiert werden:

```typst
#import "@preview/marius-dhbw-thesis:0.2.0": (
  dhbw-template,
  vglcite,
  vglcites,
)
```

## Lokale Entwicklung

Die finale `template/main.typ` verwendet den Package-Import für Version 0.2.0.
Für lokale Entwicklungs- und Kompilierungstests kann dieser Import vorübergehend
durch den relativen Import ersetzt werden, insbesondere solange Version 0.2.0
noch nicht veröffentlicht ist:

```typst
#import "../lib.typ": (
  dhbw-template,
  vglcite,
  vglcites,
)
```

Vom Repository-Hauptverzeichnis aus mit Typst 0.15.0 oder neuer kompilieren:

```bash
typst compile --root . template/main.typ thesis.pdf
```

`--root .` erlaubt den Zugriff auf `lib.typ` und `src/` außerhalb von
`template/`. So werden tatsächlich die lokalen Änderungen getestet und nicht
eine bereits veröffentlichte Package-Version.

Nach dem lokalen Test den Import wieder auf
`@preview/marius-dhbw-thesis:0.2.0` zurücksetzen. Der relative Entwicklungsimport
darf nicht veröffentlicht werden: `typst init` kopiert nur das
Vorlagenverzeichnis; `../lib.typ` würde im daraus erzeugten Projekt nicht
existieren. Der Package-Import löst die Bibliothek unabhängig vom
Vorlagenverzeichnis auf.

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

## Sprache umschalten

Mit `english: true` wird die Vorlage auf Englisch umgestellt. Standard ist
`english: false` (Deutsch):

```typst
#show: body => dhbw-template(
  english: true,
  meta: meta,
  bibliography-content: references,
  body,
)
```

Der Schalter steuert die Typst-Textsprache (einschließlich Silbentrennung und
automatischer Bezeichnungen), alle Standard-Verzeichnisüberschriften, die
ehrenwörtliche Erklärung samt Datumsbeschriftung sowie das Titelblatt:
sämtliche Datenlabels. Hochschulname, „Fakultät Wirtschaft“ und der Studienpräfix
„Studienrichtung BWL –“ bleiben auch in der englischen Vorlage auf Deutsch; alle sind weiterhin
individuell überschreibbar. Für
`meta.art-der-arbeit: auto` wechselt der Standard-Arbeitstyp von `Bachelorarbeit`
zu `Bachelor's Thesis`.
Die Zitathelfer verwenden in englischem Text `cf.` statt
`vgl.` und sprachabhängige Anführungszeichen für Kurztitel.

Eigene Inhalte werden nicht übersetzt: Metadaten (einschließlich
`meta.art-der-arbeit` und `meta.studienrichtung`), Kapitel, Sperrvermerk,
Gender-Hinweis und ein eigener `declaration-content` müssen in der gewünschten
Sprache angegeben werden. Im Beispielprojekt wird `english` einmal vor den
Metadaten definiert. `art-der-arbeit: auto` wird ausschließlich im Template
aufgelöst; ein expliziter Arbeitstyp wie `"Master's Thesis"` bleibt unverändert.

Individuelle Vorgaben wie `table-of-contents-title`, `institution-name`,
`faculty-name` oder `study-prefix` haben weiterhin Vorrang. Der Wert `auto`
verwendet jeweils den sprachabhängigen Standard. Das gilt auch für `language`:
Eine explizite Angabe wie `language: "en"` überschreibt die Textsprache, ändert
aber nicht die durch `english` gewählten Vorlagentexte.

### Überschriften individuell überschreiben

```typst
#show: body => dhbw-template(
  english: true,
  meta: meta,
  table-of-contents-title: [Contents],
  bibliography-title: [Bibliography],
  institution-name: [My University],
  bibliography-content: references,
  body,
)
```

Alle bisherigen Parameter bleiben überschreibbar. Ein expliziter Wert hat
Vorrang vor der automatischen Sprachauflösung; `auto` aktiviert wieder den
sprachabhängigen Standard. `declaration-content` ersetzt den Standardtext der
Erklärung unabhängig von der Sprache.

### Textsprache individuell überschreiben

| `english` | `language` | Feste Vorlagentexte | Typst-Textsprache | Zitatpräfix |
| --- | --- | --- | --- | --- |
| `false` | `auto` | Deutsch | `de` | `vgl.` |
| `true` | `auto` | Englisch | `en` | `cf.` |
| `true` | `"de"` | Englisch | `de` | `vgl.` |
| `false` | `"en"` | Deutsch | `en` | `cf.` |

Beispiel für englische Beschriftungen mit deutscher Textsprache:

```typst
#show: body => dhbw-template(
  english: true,
  language: "de",
  meta: meta,
  bibliography-content: references,
  body,
)
```

`language` steuert unter anderem Silbentrennung, automatische Typst-Bezeichnungen
und Anführungszeichen. Die Zitathelfer lesen die aktive Textsprache über
`text.lang` in `context`: Bei `"en"` verwenden sie `cf.`, ansonsten `vgl.`.
Auch eine lokale Änderung der Textsprache wird berücksichtigt. Die festen
Vorlagentexte und der Standardtext der Erklärung richten sich dagegen nach
`english`.

## Deutsches Beispiel

Das Beispiel setzt eine `bibliography.bib` wie im Abschnitt Literaturverzeichnis
voraus. Für lokale Tests im Repository den oben beschriebenen lokalen Import
verwenden; der Package-Import gilt nach Veröffentlichung.

```typst
#import "@preview/marius-dhbw-thesis:0.2.0": (
  dhbw-template,
  vglcite,
  vglcites,
)

#let english = false

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

#let acronyms = ()

#let abstract = [
  Diese Arbeit untersucht eine betriebliche Problemstellung.
  Hier werden Fragestellung, Vorgehensweise und zentrale Ergebnisse zusammengefasst.
]

#let references = bibliography(
  "bibliography.bib",
  title: none,
  style: "harvard-cite-them-right",
)

#show: body => dhbw-template(
  english: english,
  meta: meta,
  acronyms: acronyms,
  abstract: abstract,
  bibliography-content: references,
  body,
)

= Einleitung

Hier beginnt die wissenschaftliche Arbeit.
```

## English Example

This complete example uses the `mustermann2025` entry from the bibliography
example below. User-provided metadata and content must be supplied in English;
the template does not translate them. For local development, replace the
package import with `../lib.typ` and compile with the repository as root.

```typst
#import "@preview/marius-dhbw-thesis:0.2.0": (
  dhbw-template,
  vglcite,
  vglcites,
)

#let english = true

#let meta = (
  art-der-arbeit: auto,
  titel-der-arbeit: "Digital Transformation in Business",
  titel-zeile1: [Digital Transformation in Business],
  titel-zeile2: [],
  autor-der-arbeit: "Alex Smith",
  anschrift-zeile1: "10 Example Street",
  anschrift-zeile2: "68163 Mannheim, Germany",
  abteilung: "Digital Strategy",
  firma: "Example Company, Mannheim",
  studienjahrgang: "2023",
  kurs: "WDBM23A",
  studienrichtung: "Digital Business Management",
  matrikelnummer: "1234567",
  studiengangsleiter: "Prof. Taylor",
  wiss-betreuer: "Dr. Morgan",
  firmen-betreuer: "Robin Jones",
  abgabedatum: "24 October 2026",
)

#let acronyms = (("API", "Application Programming Interface"),)
#let nondisclosure = none
#let abstract = [
  This thesis examines digital transformation in business.
  Replace this example with a summary of the research question,
  methodology, and principal findings.
]
#let gender-notice = none
#let appendix = none

#let references = bibliography(
  "bibliography.bib",
  title: none,
  style: "harvard-cite-them-right",
)

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

= Introduction

This thesis examines digital transformation in business
#vglcite(<mustermann2025>, loc: [p. 10]).
```

The default declaration is a starting point, not an approved legal statement.
Check its wording against your faculty's current requirements before submission.

## Metadaten

Die Angaben zur Arbeit werden als Dictionary definiert:

```typst
#let meta = (
  art-der-arbeit: auto,
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
  studienjahrgang: "Studienjahrgang",
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

`studienjahrgang` enthält den Studienjahrgang (zum Beispiel `"2023"`) und wird
zusammen mit `kurs` auf dem Titelblatt ausgegeben. Bei bestehenden Metadaten
ohne dieses Feld bleibt die bisherige Kurszeile erhalten. Laut Leitfaden sind
beide Angaben erforderlich; alternativ können beide bereits im Kurswert stehen.

## Abstract

Der Leitfaden vom 14.01.2020 verlangt für Bachelorarbeiten eine einseitige
Zusammenfassung mit Problemstellung, Vorgehensweise und Ergebnissen. Sie steht
nach dem optionalen Sperrvermerk und vor dem Inhaltsverzeichnis:

```typst
#let abstract = [
  Hier steht die Zusammenfassung der konkreten Arbeit.
]

#show: body => dhbw-template(
  english: english,
  meta: meta,
  abstract: abstract,
  bibliography-content: references,
  body,
)
```

Titel, Name, Matrikelnummer, Studienjahrgang und Kurs werden aus `meta`
übernommen. `abstract-title` überschreibt die Überschrift. Ohne Abstract
(`abstract: none`, der Standard) entsteht keine zusätzliche Seite. Das hält
Projekt- und Seminararbeiten sowie bestehende Aufrufe kompatibel; bei einer
Bachelorarbeit muss der Inhalt ausdrücklich ergänzt werden. Der Text wird
nicht automatisch erzeugt oder übersetzt. Die Länge auf eine Seite begrenzen
und den Abstract zusätzlich wie im Leitfaden verlangt auf Moodle hochladen.

## Seitenzählung und Erklärung

Das Titelblatt zählt als I, ohne sichtbare Nummer. Ein Sperrvermerk wird weder
nummeriert noch in die Zählung einbezogen. Er erscheint nicht im
Inhaltsverzeichnis, bleibt aber als PDF-Lesezeichen erreichbar.
Der übrige Vorspann beginnt bei II,
der Hauptteil bei 1. Der Nachlauf setzt die römische Folge ohne Zahlensprung
fort. Diese Fehlerkorrektur verändert gegenüber früheren Versionen die
Seitenzahlen; Verzeichnisse und Querverweise werden automatisch aktualisiert.

Die deutsche Standarderklärung verwendet den Wortlaut aus Abschnitt 4.9.12
(„mit dem Thema:“). Ort, Datum und die eigenhändige Unterschrift sind bei allen
gedruckten Exemplaren erforderlich; die Vorlage ersetzt die Unterschrift nicht.
Ein eigener `declaration-content` bleibt vorrangig. Für die englische Übersetzung
enthält der Leitfaden keinen verbindlichen Wortlaut.

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

Im Haupttext bedeuten `paragraph-leading: auto` und `paragraph-spacing: auto`
einen Grundlinienabstand von 1,5 Schriftgrößen und eine zusätzliche Leerzeile
zwischen Absätzen (bei 12 pt: 18 pt innerhalb eines Absatzes, 36 pt zwischen
den angrenzenden Textzeilen zweier Absätze). Die Berechnung berücksichtigt die
Schriftmetriken. Das ist die hier verwendete Umsetzung des 1,5-fachen Abstands;
Typst-`leading` allein bezeichnet nur den Zwischenraum zwischen den Textzeilen.
Titelblatt, Verzeichnisse und Fußnoten behalten ihre eigenen Abstände.
Die geänderten Standardabstände können den Seitenumbruch des Haupttexts ändern.
Explizite Werte wie im folgenden Beispiel haben weiterhin Vorrang.

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
  keine anders lautende Genehmigung des Dualen Partners vorliegt.
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

Die Fundstelle `loc` wird unverändert ausgegeben und nicht übersetzt.
In deutschen Dokumenten zum Beispiel `[S. 10]`, in englischen `[p. 10]`
beziehungsweise `[pp. 10–12]` verwenden. Auch manuelle Jahresangaben wie
`[o. J.]` oder `[n.d.]` werden nicht automatisch übersetzt.

### Englische Fundstellen

Bei aktiver Textsprache `"en"`:

```typst
#vglcite(<mustermann2025>, loc: [p. 10])

#vglcites(
  (<mustermann2025>, [p. 10]),
  (<mustermann2025>, [pp. 20–22]),
)
```

Mit dem verwendeten Harvard-Stil:

```text
(cf. Mustermann, 2025, p. 10)
(cf. Mustermann, 2025, p. 10; Mustermann, 2025, pp. 20–22)
```

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