/*
 * ==========================================================
 * Project: Typst Academic Thesis Template (KZN)
 * File: kzn-template.typ
 * Description:
 *   A comprehensive Typst template for academic theses and
 *   dissertations. Provides functions for title pages, headers,
 *   footers, table of contents, list of figures/tables, figure
 *   and table formatting with subfigures, and full document
 *   layout management. Supports multilingual documents (DE/EN/FR)
 *   with customizable fonts, spacing, and numbering schemes.
 *
 * Authors: Christian Prim and Lukas Zuberbühler
 * License: MIT License
 * ==========================================================
 *
 * Copyright (c) 2026 Christian Prim and Lukas Zuberbühler
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
 
#import "@preview/kzn-ma:0.1.0": *
#import "@preview/unify:0.7.1": unit, qty, num
#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/codly-languages:0.1.10": *

#show: codly-init.with()
#codly(languages: codly-languages)
#codly(number-format: none, zebra-fill: none, lang-format: none)

#let KZN = "Kantonsschule Zürich Nord (KZN)"


// ============================================================
// Kapitel 1: Einleitung
// ============================================================

= Einleitung

In diesem Dokument wird die Vorlage (Template) der Kantonsschule Zürich Nord @KZN2026 für Maturitätsarbeiten oder andere schriftliche Arbeiten mit dem Textsatzsystem «Typst» @typst2026 vorgestellt. Um einen realistischen Eindruck zu vermitteln, haben wir versucht, das vorliegende Dokument möglichst so wie eine wissenschaftliche Arbeit zu strukturieren.

== Was ist ein Textsatzsystem wie Typst?

Bekannte Textverarbeitungsprogramme wie Microsoft Word sind sogenannte WYSIWYG-Editoren. Das Akronym bedeutet: _What you see is what you get_. Ein Vorteil dieser Art von Programmen ist, dass das Resultat auf dem Bildschirm weitgehend so aussieht wie nachher im Druck. Allerdings müssen dabei alle Formatierungen manuell angepasst werden – etwa Schriftgröße, Abstände oder Nummerierung von Überschriften.

Einen anderen Weg verfolgen Textsatzsysteme wie z.B. #LaTeX oder Typst. Hier werden einmalig Richtlinien für das Layout in einer Vorlage (_template_) definiert. Anschliessend wird der Textinhalt mit Markierungen dem Textsatzsystem übergeben. Die Markierungen dienen dazu, die Funktion des Texts zu beschreiben (beispielsweise Titel, Untertitel, Abbildung, Zitat, ...). Das Textsatzsystem übernimmt dann automatisch die korrekte Formatierung gemäss den Vorgaben.

== Für welche Arbeiten ist Typst geeignet, für welche eher nicht?

Ein Textsatzsystem bietet viele Vorteile, aber auch gewisse Nachteile.

Das Textsatzsystem ist *nicht* für die Arbeit geeignet, wenn:

- die Abgabe in wenigen Tagen ist und keine Erfahrungen mit Typst vorhanden sind (dann ist das am besten bekannte Textverarbeitungsprogramm die beste Wahl)
- das Layout pixelgenau kontrollierbar sein soll und eine individuelle künstlerische Gestaltung gewünscht wird (dann sind professionelle DTP-Programme wie Adobe InDesign die bessere Wahl)
- eine starke Abneigung gegen Programmieren und allem, was danach aussieht, vorliegt

Das Textsatzsystem ist *sehr gut* für die Arbeit geeignet, wenn:

- die Bereitschaft da ist, ein wenig Zeit für die Einarbeitung zu investieren (dafür fällt der Zeitaufwand für die Formatierung in der Endphase vor der Abgabe weg)
- viele Formeln (Mathematik, Physik, Chemie) in der Arbeit vorkommen
- viele Literatur-Quellen zitiert werden sollen
- der Inhalt im Zentrum stehen soll, nicht die Formatierung

== Inhalt dieses Dokuments

Folgende Punkte werden in diesem Dokument behandelt:
+ Auf welchen Grundkonzepten basiert Typst?
+ Wie funktioniert das Formatieren von Text?
+ Wie können Grafiken und Tabellen eingebunden werden?
+ Welche Funktionen bietet das kzn-ma der Kantonsschule Zürich Nord sonst noch?


// ============================================================
// Kapitel 2: Das Textsatzsystem Typst
// ============================================================

= Das Textsatzsystem Typst

== Textformatierung

Der eigentliche Text wird in Typst als Markdown (vgl. #link("https://www.markdownguide.org")) geschrieben. Markdown ist unformatierter Text mit Textzeichen, die die Formatierung steuern. Die wichtigsten Formatierungen in Markdown sind:

- *Titel*: hier werden Gleichheitszeichen vor den Titel gestellt. Je mehr, desto tiefer ist die Titelebene:

  ```typst
  = Haupttitel
  == Untertitel
  === Untertitel eine Ebene tiefer
  ```

- *Fettdruck* und _kursiv_:

  ```typst
  *fettdruck* und _kursiv_
  ```

- *Listen* werden mit - oder + markiert:

  ```typst
  - Aufzählung 1
  - Aufzählung 2
  - Aufzählung 3

  + Nummerierte Liste 1
  + Nummerierte Liste 2
  + Nummerierte Liste 3
  ```

== Funktionen für die Formatierung

Komplexere Formatierungsanweisungen werden in Typst mit Hilfe von Funktionen umgesetzt. Solche Funktionen werden zum Teil vom System zur Verfügung gestellt, können aber auch selbst definiert werden, wie z.B. im hier verwendeten kzn-ma.

=== Funktionsaufruf aus dem Text

Eine Funktion wird im Text so aufgerufen:

```typst
#funktionsname()
```

Ein Beispiel ist der Seitenumbruch:

```typst
#pagebreak()
```

Funktionen können auch Argumente entgegennehmen, z.B. die Art des Seitenumbruchs. Der folgende Seitenumbruch fügt eine Leerseite ein, bis eine ungerade Seitenzahl folgt ```typst (to: "odd")```, dies aber nur, wenn wirklich notwendig, daher ```typst (weak: true)```:

```typst
#pagebreak(to: "odd", weak: true)
```

=== Spezielle Funktionen

Vom Typst-System werden Funktionen zur Verfügung gestellt. Drei davon sind unverzichtbar:

==== ```typst #let```

Mit der Funktion ```typst #let``` werden eigene Variablen definiert:

```typst
#let meinTitel = "Der Titel"
```

Diese Variable kann dann überall im Text aufgerufen werden mit:

```typst
#meinTitel
```

Ganz ähnlich werden auch eigene Funktionen definiert:

```typst
#let meineFunktion() = {
  pagebreak()
}
```

Diese Funktion kann nun überall, wo sie benötigt wird, aufgerufen werden:

```typst
#meineFunktion()
```

==== ```typst #set```

Die Funktion ```typst #set``` dient dazu, verschiedene Formatierungsparameter zu ändern, z.B.:

```typst
#set text(
  font: "New Computer Modern",
  size: 10pt,
)
```

Hier wird die Schriftart und die Schriftgrösse gesetzt.

==== ```typst #show```

Die Funktion ```typst #show``` ermöglicht es, das Aussehen von Elementen dauerhaft zu ändern. Beispiel:

```typst
#show link: set text(blue)
```

setzt die Farbe für URL-Links auf blau. Es können nicht nur schon vorhandene Elemente mit ```typst #show``` verändert werden, es können auch Textausdrücke formatiert und oder ersetzt werden. Der folgende Aufruf sorgt dafür, dass jedes Auftreten des Textes «Typst» blau eingefärbt wird.

```typst
#show "Typst": set text(blue)
```

==== Gültigkeit der Funktionsaufrufe

Wenn die Definitionen, die mit ```typst #let```, ```typst #set``` oder ```typst #show``` gemacht werden, gelten ab der Stelle, wo die Funktionen aufgerufen werden. Wenn die Anweisungen für das ganze Dokument gelten sollen, müssen die Aufrufe am Anfang des Dokuments stehen oder in einer externen Datei aufgerufen werden, die am Anfang vom Textdokument mit ```typst #import "Dateipfad.typ":*``` eingebunden wird. Dazu mehr im @kap:projekt.

== Verweise und Fussnoten

Verweise auf Kapitel, Abbildungen, Tabellen oder Literaturreferenzen werden in Typst alle gleich erzeugt:

```typst
@Ziel-Bezeichnung
```

Wenn das Ziel eines Verweises ein Element im Text ist (also Abbildungen, Tabellen, Kapitel etc.) muss am entsprechenden Ort ein Anker gesetzt werden:

```typst
<Ziel-Bezeichnung>
```

Konkret kann das so aussehen. Zuerst wird der Kapiteltitel als mögliches Verweisziel markiert:

```typst
= Das erste Kapitel <ersteskapitel>
```

Viele Textzeilen später wird ein Verweis auf diese Kapitelnummer benötigt, der mit ```typst @``` erzeugt wird:

```typst
Wie in @ersteskapitel beschrieben...
```

Bei der Wahl der Zielbezeichnung ist man frei, es dürfen allerdings keine Leerzeichen verwendet werden. Es kann nützlich sein, die Art des Linkziels zu verdeutlichen, z.B. so:

```typst
<sec:ersteskapitel>  // für Kapitel
<fig:abbildung1>     // für Abbildungen
<tab:eineTabelle>    // für Tabellen
```

Der Vorteil ist, dass sofort erkennbar ist, ob eine Literaturreferenz oder ein interner Verweis gesetzt wird. Literaturreferenzen funktionieren nämlich grundsätzlich gleich, die Bezeichnung für das Ziel befindet sich aber in der separaten Literatur-Datenbank, dazu mehr in @kap:literatur.

== Tabellen

Tabellen werden verwendet, um beispielsweise Ergebnisse übersichtlich darzustellen, oder für eine Gegenüberstellung. Meist besteht sie aus einem Kopf, der die einzelnen Spalten bezeichnet und dem Inhalt. Diese können in Typst elegant gesetzt werden:

```typst
#figure(
  // Diese Tabelle wird in eine figure-Umgebung eingebettet,
  // was das Anbringen einer Legende erlaubt
  table(
    columns: 4,
    // Anzahl Spalten; alternativ: (2cm, 3cm, 3cm, 3cm)
    align: (left, center, center, center),
    // Ausrichtung der einzelnen Spalten
    fill: (_, y) => if y == 0 { blue.transparentize(80%) },
    // Hintergrundfarbe: nur die erste Zeile (y=0) wird eingefärbt
    stroke: (_, y) => (
      x: none,
      top: if y == 0 { 1pt } else { if y == 1 { 0.5pt } else { 0pt } },
      bottom: 1pt,
    ),
    // Tabellenlinien werden einzeln gestaltet
    table.header([], [Länge in m], [Breite in m], [Höhe in m]),
    // Titelzeile wird bei Seitenumbruch wiederholt
    [Tisch],   [1.20], [1.20], [0.80],
    [Schrank],  [1.15], [0.65], [2.20],
    [Bett],     [2.10], [0.90], [0.25],
  ),
  caption: [Abmessungen einzelner Möbelstücke],
  kind: table,
)<tab1>
```

Die gesetzte Tabelle:

#figure(
  table(
    columns: 4,
    align: (left, center, center, center),
    fill: (_, y) => if y == 0 { blue.transparentize(80%) },
    stroke: (_, y) => (
      x: none,
      top: if y == 0 { 1pt } else { if y == 1 { 0.5pt } else { 0pt } },
      bottom: 1pt,
    ),
    table.header([], [Länge in m], [Breite in m], [Höhe in m]),
    [Tisch],   [1.20], [1.20], [0.80],
    [Schrank],  [1.15], [0.65], [2.20],
    [Bett],     [2.10], [0.90], [0.25],
  ),
  caption: [Abmessungen einzelner Möbelstücke],
  kind: table,
)<tab1>

== Illustrationen / Bilder

Bilder (Bitmap-Formate und Vektorbilder im SVG-Format) werden über den ```typst #image()```-Befehl eingefügt. Dies erfolgt meist wieder innerhalb von ```typst #figure()```, um auch bei Bildern eine aussagekräftige Legende anzubringen:

```typst
#figure(
  image("img/image.jpeg", width: 80%),
  caption: [Kantonsschule Zürich Nord],
  kind: figure,
)<fig1>
```

Als Argument kann die gewünschte Breite des Bildes (im Beispiel: ```typst width: 80%```) angegeben werden, wobei relative Längen in Prozent der verfügbaren Breite oder absolute (beispielsweise in ```typst cm``` oder ```typst mm```) angegeben werden können.

== Formeln

Bei naturwissenschaftlichen Arbeiten müssen oft Formeln gesetzt werden. Diese können sowohl innerhalb des Lauftextes oder freistehend auftreten. Um eine Formel im Textfluss zu setzen, wird sie von einem Dollarzeichen eingeschlossen: ```typst $a=2g$```. Dies wird meist für eine Wertangabe verwendet. Im Lauftext sollte auf den Einsatz von Brüchen verzichtet werden. Eigentliche Umrechnungen oder Formeln werden freistehend gesetzt. Dies wird erreicht, indem ein Leerschlag nach und vor dem Dollarzeichen getippt wird: ```typst $ arrow(F)_"res"=m arrow(a) $```.

$ arrow(F)_"res"=m arrow(a) $

Da der Formelsatz äusserst mächtig ist, wird hier auf eine Auflistung der Befehle verzichtet und auf die offizielle Dokumentation verwiesen.

== Einheiten

Das Zusatzpaket ```typst unify``` erlaubt es, Einheiten typografisch korrekt zu setzen. Die Einheiten können sowohl innerhalb einer Formel als auch im Lauftext angebracht werden, wie folgendes Beispiel zeigt:

```typst
#import "@preview/unify:0.7.1": unit, qty, num

Ein Fahrzeug der Masse #qty("1230", "kg") wird mit einer resultierenden Kraft
von #qty("15", "kilo Newton") gezogen. Wie gross ist die Beschleunigung, die
das Fahrzeug dadurch erfährt? Lösung in #unit("meter per second squared") angeben.

$ a = F_"res"/m = qty("15.0", "kN")/qty("1230", "kilo gram")
    = qty("15.0e3", "N")/qty("1230", "kilo gram")
    = qty("12.2", "m/s^2") $
```

Wie im Beispiel ersichtlich ist, können die Einheiten entweder mit dem jeweiligen Symbol oder dem ausgeschriebenen Namen notiert werden, jedoch keine Mischformen davon: ```typst #unit("m per second squared")``` klappt beispielsweise nicht. Innerhalb des Formelsatzes ist das Notieren des Gartenhages vor Befehlen fakultativ und wurde im Beispiel weggelassen. Mit ```typst #num()``` kann nur eine Masszahl und mit ```typst #unit()``` nur die Einheit gesetzt werden.


// ============================================================
// Kapitel 3: Das ma-template konkret
// ============================================================

#pagebreak(to: "odd", weak: true)

= Das kzn-ma.typ konkret

Das kzn-ma versucht, wo immer möglich, Standardlösungen zu verwenden. Es werden aber einige Einstellungen vorgenommen, um das Layout an die Anforderungen einer Abschlussarbeit der #KZN anzupassen. Weiter werden Hilfsfunktionen zur Verfügung gestellt, die die Layout-Gestaltung erleichtern sollen. Im folgenden Kapitel werden die Handhabung des Templates und die wichtigsten Funktionen kurz mit Beispielen vorgestellt.

== Ein neues Projekt anlegen <kap:projekt>

Am einfachsten wird das Projekt gestartet, indem auf der Typst-Startseite «Start from template» gewählt wird. Ein Projekt besteht dann aus folgenden Ordnern und Dokumenten:

```
project/
├── img/                  // Ordner mit Bilddateien
├── main.typ              // Hauptdokument mit allen Einstellungen
├── main-matter-de.typ    // Hauptteil der Arbeit
├── appendix-de.typ       // Anhang (oder Anhänge)
└── mendeley.bib          // Literaturdatenbank
```

Alle Einstellungen werden im File ```main.typ``` vorgenommen. Nach dem Anlegen des Projekts sind bereits Standardwerte eingetragen.

== Anpassen von Textvariablen

Im Dokument ```main.typ``` müssen einige Variablen an die eigene Arbeit angepasst werden, z.B. Titel, Autoren und Betreuende.

Andere Variablen werden vom Template in mehrsprachigen Varianten zur Verfügung gestellt. Diese werden mit

```typst
... = localize(Variablenname)
```

abgerufen.

*Alle Variablen können auch bei Bedarf durch eigene Ausdrücke überschrieben werden, z.B.:*

```typst
#let toc-title = "Inhaltsübersicht"
```

Gewisse Variablen können auch deaktiviert werden:

```typst
#let supervisors = none
```

// Zeilennummern im folgenden Codeblock bei Zeile 8 beginnen lassen
// (entspricht der tatsächlichen Position in main.typ)
#codly(number-format: n => [#(n + 7)])

```typst
// Namen der Autorinnen und Autoren
#let school = "Kantonsschule Zürich Nord"
#let title = localize(title)
#let subtitle = localize(subtitle)
#let authors = ("Christian Prim", "Lukas Zuberbühler")
#let supervisors = none
#let date = datetime(day: 23, month: 2, year: 2026).display("[day].[month].[year]")
#let thesis-type = localize(thesis-type-beginners-guide)
#let written-by = localize(written-by)
#let supervised-by = none
#let submitted-on = "Version"

// Quellenangaben
#let biblio-style = "ieee"
#let biblio-file = "mendeley.bib"

// Inhaltsdateien
#let content-file = "main-matter.typ"
#let appendix-file = "appendix.typ"

// Bezeichnungen für Abschnitte und Verzeichnisse
#let abstract-title = localize(abstract-title)
#let preface-title = localize(preface-title)
#let ai-declaration-title = localize(ai-declaration-title)
#let acknowledgments-title = localize(acknowledgments-title)
#let toc-title = localize(toc-title)
#let lof-title = localize(lof-title)
#let lot-title = localize(lot-title)
#let biblio-title = localize(biblio-title)
#let appendix-title = localize(appendix-title)

// Kurzbezeichnungen
#let heading-desc = localize(heading-desc)
#let fig-desc = localize(fig-desc)
#let tab-desc = localize(tab-desc)
#let appendix-desc = localize(appendix-desc)
```

// Zeilennummern zurücksetzen
#codly(number-format: n => [#n])

#pagebreak(weak: true)

== Anpassen des Layouts

Für die Layoutanpassungen werden mehrere _Dictionaries_ verwendet. Ein _Dictionary_ ist ein Datentyp in Typst und erlaubt es, mehrere Variablen und/oder Funktionen «zu verpacken».

=== Grundsätzliche Layoutanpassungen

// Zeilennummern bei Zeile 56 beginnen lassen (Position in main.typ)
#codly(number-format: n => [#(n + 55)])

```typst
#let layout-def = (
  paper: "a4",
  font-size: 11pt,
  margin: (top: 2cm, inside: 3cm, outside: 2cm, bottom: 2.5cm),
  numbering: "1",
  mainFont: "EB Garamond",
  monoFont: "New Computer Modern Mono",
  mathFont: "Libertinus Math",
  copystop: false,
  header: kzn-header(even-text: [#title]),
  footer: kzn-footer(footer-text: [#school]),
  link-color: green,
  heading-desc: heading-desc,
  fig-desc: fig-desc,
  tab-desc: tab-desc,
  language: "de",
  language-region: "CH",
)
```

#codly(number-format: none)

Die Einträge hier müssen nicht unbedingt geändert werden, können aber durch eigene Inhalte überschrieben werden. Einige Einträge haben etwas speziellere Eigenschaften:

- Zeile 85: Hier wird die Sprache gesetzt. Unterstützt werden: de, en, fr, it, es
- Zeile 86: Hier wird die Region gesetzt, was sich z.B. auf die Anführungszeichen auswirkt. Mit ```typst "CH"``` werden Schweizer Anführungszeichen («...») verwendet, mit ```typst "DE"``` deutsche („...“). Zur Verfügung stehen alle ISO 3166-1 alpha-2 Region-Codes @wiki:iso-alpha2
- Zeile 71: Hier kann eine anonymisierte Version der Arbeit ohne Bilder, ohne Titelblatt und ohne persönlich markierte Informationen erstellt werden, indem ```typst copystop = true``` gesetzt wird (vgl. @kap:anonym)
- Zeile 74 und 77: Hier werden Funktionen zur Verfügung gestellt, die Kopf- und Fusszeilen korrekt für ein zweiseitiges Layout erstellen. Standard: Titel der Arbeit auf geraden Seiten aussen, aktueller Kapiteltitel auf ungeraden Seiten aussen, Seitenzahl und Schulname in der Fusszeile

Im nächsten Block werden die Verzeichnisse eingerichtet:
- Inhaltsverzeichnis _(table of contents, *toc*)_
- Abbildungsverzeichnis _(list of figures, *lof*)_
- Tabellenverzeichnis _(list of tables, *lot*)_

Standardmässig sind alle Verzeichnisse aktiviert und werden vor der Arbeit gesetzt. Im folgenden Block:

```typst
#let outline-def = (
  toc: [= #toc-title],
  lof: [= #lof-title],
  lot: [= #lot-title],
  // numbering: "i",
  // toc-depth: 3,
  // toc-position: "before",
  // toc-outlined: false,
  // lof-position: "before",
  // lof-outlined: false,
  // lot-position: "before",
  // lot-outlined: true,
)
```

kann dies geändert werden:

- Ein Verzeichnis wird deaktiviert mit: ```typst lot: none```
- Ein aktives Verzeichnis wird ans Ende der Arbeit gestellt mit: ```typst lot-position: "after"```
- Ein aktives Verzeichnis wird aus dem Inhaltsverzeichnis ausgeschlossen mit: ```typst lot-outlined: false```
- Die Seitennummerierung kann geändert werden: ```typst numbering: "1"``` — wenn das Verzeichnis ans Ende der Arbeit gestellt wird, hat diese Definition keine Wirkung
- Standardmässig werden drei Titelebenen ins Inhaltsverzeichnis aufgenommen; das lässt sich z.B. mit ```typst toc-depth: 2``` ändern. Alle Titelebenen tiefer als die angegebene Zahl werden aus dem Inhaltsverzeichnis ausgeschlossen und *verlieren auch im Text die Nummerierung*

=== Titelseite

Das Template stellt zwei vordefinierte Titelseiten-Funktionen zur Verfügung. Welche verwendet wird, wird in der Variable ```typst titlepage-def``` festgelegt:

```typst
#let titlepage-def = (
  content: kznTitlePage()    // KZN-Gestaltung mit Hintergrundbild
  // content: simpleTitlePage() // Einfache, textbasierte Variante
)
```

==== Einfache Titelseite: ```typst simpleTitlePage()```

Die Funktion ```typst simpleTitlePage()``` erzeugt eine einfache Titelseite mit den wichtigsten Angaben sowie einem optionalen Bild in der Mitte. Sie verwendet die allgemein definierten Variablen ```typst title```, ```typst subtitle```, ```typst authors```, ```typst date``` usw. direkt. Der Code der einfachen Titelseite ist im Dokument ```typst main.typ``` sichtbar und kann als Ausgangspunkt für eigene Titelseiten verwendet werden.

==== KZN-Titelseite: ```typst kznTitlePage()```

Die Funktion ```typst kznTitlePage()``` erzeugt eine Titelseite, die dem kantonalen CI-Design nachempfunden ist. Sie wird über ```typst kzn-titlepage()``` aus dem Template aufgerufen und kann mit folgenden Parametern angepasst werden:

```typst
#let kznTitlePage() = kzn-titlepage(
  authors: authors,
  supervisors: supervisors,
  title: localize(title),
  title-size: 28pt,
  subtitle: subtitle,
  subtitle-size: 18pt,
  date: date,
  nord-image: image("img/image.jpeg", height: 100%),   // Hintergrundbild (Dateipfad)
  nord-image-source: [                 // Quellenangabe zum Bild (optional)
    #localize(cover-image) #link("https://...")
  ],
  nord-color: black,                   // Farbe der grafischen Elemente
  background-color: white,             // Hintergrundfarbe der Seite
  zh-blue: rgb("009EE0"),              // Akzentfarbe (Zürcher Blau)
  heading-font: "Lato",               // Schriftart für die Titelseite
  strings: (
    submitted-on: submitted-on,
    thesis-type: thesis-type,
    written-by: written-by,
    supervised-by: supervised-by,
  ),
)
```

Soll kein Hintergrundbild verwendet werden, wird der Parameter ```typst nord-image``` weggelassen oder auf ```typst none``` gesetzt. Die grafischen Elemente erscheinen dann in der gewählten ```typst nord-color```.

==== Eigene Titelseite

Eine vollständig eigene Titelseite kann als Typst-Funktion definiert und direkt als Inhalt von ```typst titlepage-def``` übergeben werden:

```typst
#let meineTitelseite() = {
  place(top + left, [
    #block(text(weight: "bold", size: 20pt, [Mein Schulname]))
  ])
  v(5cm)
  align(center, [
    #block(text(weight: "bold", size: 28pt, title))
    #block(text(size: 16pt, subtitle))
  ])
}

#let titlepage-def = (
  content: meineTitelseite()
)
```

=== Definition der Blöcke vor der eigentlichen Arbeit

Vor dem Inhaltsverzeichnis können mehrere Blöcke eingefügt werden, z.B. Abstract, Vorwort, Danksagung oder eine Erklärung zur KI-Nutzung. Diese werden in ```typst frontmatter-def``` zusammengestellt:

```typst
#let frontmatter-def = (
  content: (
    myAbstract(),
    myAIDeclaration(), 
    myAcknowledgments(),
    myPreface(),
    myCustomBlock(),
  ),
  // numbering: "i",  // Römische Seitennummerierung (Standard)
)
```

Die Reihenfolge der Blöcke in ```typst content: (...)``` bestimmt die Reihenfolge im Dokument. Nicht benötigte Blöcke werden einfach aus der Liste entfernt. Jeder Block ist eine Funktion, die Typst-Inhalt zurückgibt:

```typst
#let myAbstract() = {
  [= #abstract-title

  Hier steht die kurze Zusammenfassung der Arbeit.
  ]
}
```

Eigene Blöcke können nach demselben Muster definiert und in ```typst content: (...)``` aufgenommen werden:

```typst
#let meinEigenerBlock() = {
  [= Eigenständigkeitserklärung

  Ich erkläre, dass ich diese Arbeit selbstständig verfasst habe.
  ]
}

#let frontmatter-def = (
  content: (myAbstract(), meinEigenerBlock(), myAIDeclaration()),
)
```

Die Seitennummerierung im Frontmatter ist standardmässig mit römischen Kleinbuchstaben (i, ii, iii, ...) eingestellt. Dies kann geändert werden:

```typst
#let frontmatter-def = (
  content: (...),
  numbering: "1",  // Arabische Ziffern statt römischer
)
```

==== Vordefinierte Blöcke

Das Template stellt folgende Blöcke zur Verfügung, die direkt verwendet werden können:

- ```typst myAbstract()```: Kurze Zusammenfassung der Arbeit
- ```typst myAIDeclaration()```: Erklärung zur Nutzung von KI-Tools (mehrsprachig)
- ```typst myAcknowledgments()```: Danksagung
- ```typst myPreface()```: Vorwort

=== Anhänge

Der Anhang wird in der Datei ```typst appendix.typ``` verfasst und am Ende von ```typst main.typ``` eingebunden. Die Struktur in ```typst main.typ``` sieht so aus:

```typst
#set heading(
  numbering: "A",            // Alphabetische Nummerierung der Anhang-Titel
  outlined: true,            // Anhänge erscheinen im Inhaltsverzeichnis
  supplement: appendix-desc,
)
#counter(heading).update(0)        // Neustart der Nummerierung bei A
#pagebreak(weak: true, to: "odd")  // Anhang beginnt auf einer rechten Seite

#include appendix-file
```

Der Aufruf ```typst #counter(heading).update(0)``` sorgt dafür, dass die Nummerierung neu bei A beginnt, unabhängig von der Kapitelanzahl im Hauptteil. Soll der Anhang keine Nummerierung haben, wird ```typst numbering: none``` gesetzt.

Sollen mehrere Anhänge als separate Dateien eingebunden werden, können mehrere ```typst #include```-Aufrufe verwendet werden:

```typst
#include "appendix-a.typ"
#include "appendix-b.typ"
```

#pagebreak(weak: true)

== Literaturreferenzen <kap:literatur>

Literaturreferenzen werden in einer separaten Datei im BibTeX-Format verwaltet. Der Dateiname wird in ```typst main.typ``` festgelegt:

```typst
#let biblio-file = "mendeley.bib"
```

==== Die BibTeX-Datei

Eine BibTeX-Datei enthält Einträge für jede Quelle. Ein typischer Eintrag sieht so aus:

```bib
@article{einstein1905,
  author  = {Einstein, Albert},
  title   = {Zur Elektrodynamik bewegter Körper},
  journal = {Annalen der Physik},
  year    = {1905},
  volume  = {17},
  pages   = {891--921},
}

@book{feynman1964,
  author    = {Feynman, Richard P.},
  title     = {The Feynman Lectures on Physics},
  publisher = {Addison-Wesley},
  year      = {1964},
}

@misc{typst2026,
  author = {{Typst GmbH}},
  title  = {Typst Documentation},
  year   = {2026},
  url    = {https://typst.app/docs},
}
```

Die Bezeichnung in den geschweiften Klammern (z.B. ```typst einstein1905```) ist der Zitierschlüssel, mit dem die Quelle im Text referenziert wird.

==== Zitieren im Text <kap:zitieren>

Eine Quelle wird im Text mit ```typst @``` und dem Zitierschlüssel referenziert:

```typst
Die Lichtgeschwindigkeit ist konstant @einstein1905.

Wie in @feynman1964[S.~42] beschrieben...
```

Typst formatiert die Referenz automatisch gemäss dem gewählten Zitierstil.

==== Zitierstile

Der Zitierstil wird in ```typst main.typ``` festgelegt:

```typst
#let biblio-style = "ieee"
```

Zahlreiche Stile sind verfügbar (vgl. #link("https://typst.app/docs/reference/model/bibliography/")).

Die gebräuchlichsten ohne Fussnoten:
- ```typst "ieee"```
- ```typst "apa"```

Mit Fussnoten unten an der Seite:
- ```typst "chicago-notes"```
- ```typst "chicago-fullnotes"```
- ```typst "chicago-shortened-notes"```
- ```typst "modern-humanities-research-association-notes"```
- ```typst "modern-humanities-research-association"```
- ```typst "turabian-fullnote-8"```

Die Wahl des Stils richtet sich nach den Vorgaben der Schule oder des Fachbereichs.

==== Export aus Literaturverwaltungsprogrammen

Die BibTeX-Datei kann direkt aus Literaturverwaltungsprogrammen exportiert werden:

- *Zotero*: Datei → Bibliothek exportieren → Format: BibTeX
- *Mendeley*: Einträge Auswählen → Export → BibTeX
- *JabRef*: Arbeitet nativ im BibTeX-Format

#pagebreak(weak: true)

== Mehrsprachigkeit und ```typst localize()```

Das Template unterstützt die Sprachen Deutsch (```typst "de"```), Englisch (```typst "en"```), Französisch (```typst "fr"```), Italienisch (```typst "it"```) und Spanisch (```typst "es"```). Die aktive Sprache wird in ```typst layout-def``` festgelegt:

```typst
#let layout-def = (
  ...
  language: "de",
  language-region: "CH",
)
```

==== Die Funktion ```typst localize()```

Alle im Template vordefinierten Bezeichnungen (Inhaltsverzeichnis, Abstract, Anhang usw.) sind als mehrsprachige Dictionaries definiert und werden mit ```typst localize()``` in die aktive Sprache übersetzt:

```typst
#let toc-title = localize(toc-title)
```

Eigene mehrsprachige Texte können nach demselben Muster als Dictionary definiert werden:

```typst
#let meinText = (
  de: [Mein Text auf Deutsch],
  en: [My text in English],
  fr: [Mon texte en français],
)

// Im Dokument:
#localize(meinText)
```

```typst localize()``` wählt automatisch die Sprache, die in ```typst layout-def``` gesetzt ist. Ist die aktive Sprache im Dictionary nicht vorhanden, wird zuerst Deutsch, dann Englisch als Fallback verwendet.

==== Sprachregion

Der Parameter ```typst language-region``` beeinflusst sprachregionale Konventionen, insbesondere Anführungszeichen. Mit ```typst language-region: "CH"``` werden Schweizer Anführungszeichen («...») verwendet, mit ```typst "DE"``` deutsche („...“).

#pagebreak(weak: true)

== Anonymisierung mit ```typst copystop``` <kap:anonym>

Für die Einreichung bei Plagiatsprüfungsdiensten kann eine anonymisierte Version des Dokuments erstellt werden, bei der persönliche Angaben und Bilder ausgeblendet werden. Dies wird mit dem Parameter ```typst copystop``` in ```typst layout-def``` aktiviert:

```typst
#let layout-def = (
  ...
  copystop: true,   // Anonymisierter Modus aktiv
  // copystop: false, // Normaler Modus
)
```

Im anonymisierten Modus werden folgende Elemente ausgeblendet bzw. ersetzt:

- Die Titelseite wird durch eine vereinfachte Version mit Titel und dem Hinweis _«Anonyme Version»_ ersetzt
- Alle Bilder werden durch ein Kreuz-Symbol ersetzt
- Alle mit ```typst #private()``` markierten Inhalte werden ausgeblendet

==== Die Funktion ```typst #private()```

Inhalte, die im anonymisierten Modus nicht erscheinen sollen, werden mit ```typst #private()``` markiert:

```typst
// Persönlicher Name im Fliesstext
Wie #private([Maria Muster]) in ihrer Analyse zeigt...

// Link zur eigenen Website
#private(link("https://meine-seite.ch"))

// Ganzer Absatz
#private([
  Dieser Abschnitt enthält persönliche Informationen,
  die bei der Plagiatsprüfung nicht sichtbar sein sollen.
])
```

Im normalen Modus (```typst copystop: false```) wird der Inhalt von ```typst #private()``` vollständig angezeigt. Im anonymisierten Modus (```typst copystop: true```) wird er durch nichts ersetzt – der umgebende Text fliesst nahtlos zusammen.

*Empfehlung:* Namen, Danksagungsadressen und persönliche URLs konsequent mit ```typst #private()``` markieren, damit die anonymisierte Version mit einem einzigen Parameter-Wechsel erstellt werden kann.

#pagebreak(weak: true)

== Erweiterungen der ```typst #figure```-Umgebung

Das KZN-Template benutzt die vom Typst-Standard vorgesehene Syntax zum Einbinden von Abbildungen. Als Erweiterung können Abbildungen mit mehreren Teilabbildungen erstellt werden, indem ein ```typst #grid()``` angelegt wird. Es sind beliebig viele Spalten und Zeilen definierbar, allerdings ist kein Seitenumbruch möglich, daher sind mehr als zwei Spalten/Zeilen kaum sinnvoll. Ein weiteres Beispiel befindet sich in @app:abbildungen.

```typst
#figure(
  align(center)[
    #grid(
      columns: (0.5fr, 0.5fr),
      gutter: 7mm,
      align: bottom,
      [
        #figure(
          align(center)[#image("Abbildung_a.pdf", width: 100%)],
          caption: [Abbildung (a)],
          kind: "subfigure",
        )<fig1a>
      ],
      [
        #figure(
          align(center)[#image("Abbildung_b.pdf", width: 100%)],
          caption: [Abbildung (b)],
          kind: "subfigure",
        )<fig1b>
      ],
      [
        #figure(
          align(center)[#image("Abbildung_c.pdf", width: 100%)],
          caption: [Abbildung (c)],
          kind: "subfigure",
        )<fig1c>
      ],
      [
        #figure(
          align(center)[#image("Abbildung_d.pdf", width: 100%)],
          caption: [Abbildung (d)],
          kind: "subfigure",
        )<fig1d>
      ],
    )
  ],
  caption: [Abbildung mit mehreren Teilabbildungen.],
  kind: figure,
)<fig:abbildung>
```

#figure(
  align(center)[
    #grid(
      columns: (0.5fr, 0.5fr),
      gutter: 7mm,
      align: bottom,
      [
        #figure(
          align(center)[#text(size: 40pt, baseline: 30pt, [A])],
          caption: [Der Buchstabe A],
          kind: "subfigure",
        )<fig1a>
      ],
      [
        #figure(
          align(center)[#text(size: 40pt, baseline: 30pt, [B])],
          caption: [Der Buchstabe B],
          kind: "subfigure",
        )<fig1b>
      ],
      [
        #figure(
          align(center)[#text(size: 40pt, baseline: 30pt, [C])],
          caption: [Der Buchstabe C],
          kind: "subfigure",
        )<fig1c>
      ],
      [
        #figure(
          align(center)[#text(size: 40pt, baseline: 30pt, [D])],
          caption: [Der Buchstabe D],
          kind: "subfigure",
        )<fig1d>
      ],
    )
  ],
  caption: [Abbildung mit mehreren Teilabbildungen.],
  kind: figure,
)<fig:abbildung>

Die einzelnen Teilabbildungen können referenziert werden; für die vollständige Referenz muss auch die einbettende ```typst #figure``` referenziert werden:

```typst
@fig:abbildung @fig1a
```

ergibt:

@fig:abbildung @fig1a


// ============================================================
// Kapitel 4: Diskussion und Ausblick
// ============================================================

#pagebreak(weak: true)

= Diskussion und Ausblick

Das vorliegende Template deckt die typischen Anforderungen einer Maturitätsarbeit ab: strukturierter Textsatz, Formeln, Abbildungen, Tabellen, Literaturverwaltung und mehrsprachige Unterstützung. Einige Bereiche bieten jedoch Potenzial für Weiterentwicklungen, und für den Einstieg in Typst stehen zahlreiche Ressourcen zur Verfügung.

== Weiterentwicklung des Templates

Das Template wird laufend weiterentwickelt. Geplante Erweiterungen umfassen zusätzliche vordefinierte Titelseiten-Varianten, eine vereinfachte Einbindung von Code-Listings mit Syntaxhervorhebung sowie verbesserte Unterstützung für mathematische Beweise und Definitionen als formatierte Blöcke. Rückmeldungen und Verbesserungsvorschläge können direkt an die Autoren gerichtet werden.

== Ressourcen für den Einstieg

=== Offizielle Dokumentation

Die wichtigste Anlaufstelle ist die offizielle Typst-Dokumentation unter #link("https://typst.app/docs"). Sie ist vollständig und enthält für jede Funktion interaktive Beispiele, die direkt im Browser ausprobiert werden können. Besonders nützlich sind:

- *Referenz*: #link("https://typst.app/docs/reference") – vollständige Auflistung aller Funktionen, Typen und Operatoren
- *Guides*: #link("https://typst.app/docs/guides") – thematische Anleitungen, u.a. zu Formeln, Seitenlayout und Schriften
- *Tutorial*: #link("https://typst.app/docs/tutorial") – schrittweiser Einstieg für Neueinsteiger

=== Pakete und Erweiterungen

Das offizielle Paketverzeichnis unter #link("https://typst.app/universe") listet alle verfügbaren Zusatzpakete. Für naturwissenschaftliche Arbeiten besonders relevant sind:

- *unify* (#link("https://typst.app/universe/package/unify")): Typografisch korrekter Einheitensatz (im Template bereits eingebunden)
- *codly* (#link("https://typst.app/universe/package/codly")): Syntaxhervorhebung für Quellcode (im Template bereits eingebunden)
- *cetz* (#link("https://typst.app/universe/package/cetz")): Zeichnungen und Diagramme direkt in Typst, ähnlich wie TikZ in #LaTeX
- *fletcher* (#link("https://typst.app/universe/package/fletcher")): Flussdiagramme und Graphen
- *plotst* (#link("https://typst.app/universe/package/plotst")): Einfache Diagramme und Plots

=== Community und Hilfe

Bei Fragen hilft die aktive Typst-Community weiter:

- *Typst Forum*: #link("https://forum.typst.app") – offizielle Diskussionsplattform, gut durchsuchbar
- *Discord*: Einladungslink über #link("https://typst.app/community") – für schnelle Fragen geeignet
- *GitHub*: #link("https://github.com/typst/typst") – Quellcode, bekannte Fehler und Entwicklungsstand

=== Vergleich mit #LaTeX

Für Nutzerinnen und Nutzer mit #LaTeX - Vorkenntnissen gibt es eine Gegenüberstellung der wichtigsten Syntaxunterschiede unter #link("https://typst.app/docs/guides/guide-for-latex-users"). Typst ist in vielen Belangen schlanker als #LaTeX, unterstützt aber noch nicht alle Pakete und Eigenheiten, die in der wissenschaftlichen Community etabliert sind – insbesondere im Bereich chemischer Strukturformeln (ChemDraw-Äquivalente) und komplexer bibliografischer Stile.

=== Tutorials und Lernmaterial

Neben der offiziellen Dokumentation gibt es eine wachsende Zahl an Tutorials:

- *Typst in 3 Minutes*: #link("https://github.com/typst/typst#learn") – kompakter Schnelleinstieg im README
- *YouTube-Tutorials*: Eine Suche nach «Typst tutorial» liefert aktuelle Einführungsvideos, die den gesamten Workflow von der Installation bis zum fertigen Dokument zeigen
- *Vorlagen auf Typst Universe*: Unter #link("https://typst.app/universe/search?kind=template") finden sich zahlreiche fertige Templates als Ausgangspunkt oder Inspirationsquelle
