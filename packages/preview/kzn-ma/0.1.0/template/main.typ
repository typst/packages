/*
 * ==========================================================
 * Project: Typst Academic Thesis Template (KZN)
 * File: main.typ
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

// ============================================================
// Allgemeine Angaben
// ============================================================
// Diese Angaben müssen an die eigene Arbeit angepasst werden.

// Titel und Untertitel der Arbeit.
// Für mehrsprachige Vorlagen: localize(title) bzw. localize(subtitle)
// Für eigene Bezeichnung: #let title = "Mein Titel"
#let title = localize(title)
#let subtitle = localize(subtitle)

// Namen der Autorinnen und Autoren
#let authors = ("Christian Prim", "Lukas Zuberbühler")

// Namen der Betreuungspersonen (none = keine Betreuung)
#let supervisors = none // ("Vorname Nachname",)

// Abgabedatum
#let date = datetime(day: 23, month: 3, year: 2026).display("[day].[month].[year]")

// Art der Arbeit.
// Vordefinierte Optionen: localize(thesis-type-ma), localize(thesis-type-sa),
//   localize(thesis-type-fmp), localize(thesis-type-beginners-guide)
// Eigene Bezeichnung: #let thesis-type = "Laborbericht"
// Kein Eintrag: #let thesis-type = none
#let thesis-type = localize(thesis-type-beginners-guide) 

// Bezeichnungen für Autorenschaft, Betreuung und Datum auf der Titelseite.
// Für eigene Bezeichnung direkt einen Text eingeben, z.B. "geschrieben von"
#let written-by = localize(written-by)
#let supervised-by = none // localize(supervised-by) oder eigene Bezeichnung
#let submitted-on = "Version" // localize(submitted-on) oder eigene Bezeichnung

// Name der Schule — wird in der Fusszeile angezeigt (bei kzn-footer)
#let school = "Kantonsschule Zürich Nord"


// ============================================================
// Quellenangaben
// ============================================================

// Zitierstil für das Literaturverzeichnis.
// Häufige Optionen: "ieee", "apa", "chicago-author-date", "vancouver"
// Für Fussnoten: "chicago-notes", "chicago-fullnotes", "turabian-fullnote-8"
// Vollständige Liste: https://typst.app/docs/reference/model/bibliography/
#let biblio-style = "ieee"

// Dateiname der Literaturdatenbank (BibTeX-Format)
#let biblio-file = "mendeley.bib"


// ============================================================
// Inhaltsdateien
// ============================================================

// Datei mit dem eigentlichen Arbeitsinhalt
#let content-file = "main-matter.typ"

// Datei mit den Anhängen
#let appendix-file = "appendix.typ"


// ============================================================
// Bezeichnungen für Abschnitte und Verzeichnisse
// ============================================================
// Diese Angaben müssen normalerweise nicht verändert werden.
// Für eigene Bezeichnungen direkt einen Text eingeben,
// z.B. #let abstract-title = "Zusammenfassung"

#let abstract-title = localize(abstract-title)               // Abstract
#let preface-title = localize(preface-title)                 // Vorwort
#let ai-declaration-title = localize(ai-declaration-title)   // Erklärung zur Nutzung von KI
#let acknowledgments-title = localize(acknowledgments-title) // Danksagung
#let toc-title = localize(toc-title)                         // Inhaltsverzeichnis
#let lof-title = localize(lof-title)                         // Abbildungsverzeichnis
#let lot-title = localize(lot-title)                         // Tabellenverzeichnis
#let biblio-title = localize(biblio-title)                   // Literatur
#let appendix-title = localize(appendix-title)               // Anhang

// Kurzbezeichnungen für Kapitel, Abbildungen, Tabellen und Anhang
#let heading-desc = localize(heading-desc)                    // Kap.
#let fig-desc = localize(fig-desc)                            // Abb.
#let tab-desc = localize(tab-desc)                            // Tab.
#let appendix-desc = localize(appendix-desc)                  // Anh.



// ============================================================
// Layout-Definitionen
// ============================================================
// Diese Angaben können bei Bedarf angepasst werden.

#let layout-def = (
  // Papierformat
  paper: "a4",

  // Schriftgrösse
  font-size: 11pt,

  // Seitenränder
  margin: (top: 2cm, inside: 3cm, outside: 2cm, bottom: 2.5cm),

  // Format der Seitenzahlen
  numbering: "1",

  // Schriftarten
  mainFont: "EB Garamond",             // Hauptschrift
  monoFont: "New Computer Modern Mono", // Monospace-Schrift
  mathFont: "Libertinus Math",          // Mathematikschrift

  // Anonymisierung: false = normale Version, true = anonymisierte Version
  // Im Text können private Inhalte mit #private([...]) geschützt werden
  copystop: false,

  // Kopfzeile: kzn-header zeigt die aktuelle Kapitelbezeichnung an.
  // Eigene Definition möglich, z.B. header: (odd: [Mein Text], even: [])
  header: kzn-header(even-text: [#title]),

  // Fusszeile: kzn-footer zeigt die Seitenzahl und den Schulnamen an.
  // Eigene Definition möglich, z.B. footer: (odd: [Rechts], even: [Links])
  footer: kzn-footer(footer-text: [#school]),

  // Farbe für Hyperlinks
  link-color: green,

  // Kurzbezeichnungen (werden aus den Variablen oben übernommen)
  heading-desc: heading-desc,
  fig-desc: fig-desc,
  tab-desc: tab-desc,

  // Sprache und Region für Silbentrennung und Sprachregeln
  language: "de",
  language-region: "CH",
)


// ============================================================
// Verzeichnisse
// ============================================================
// toc: Inhaltsverzeichnis
// lof: Abbildungsverzeichnis
// lot: Tabellenverzeichnis
//
// *-position: "before" = vor der Arbeit (nach Abstract, Vorwort etc.)
//             "after"  = zwischen Arbeit und Anhang
//
// *-outlined: true  = Verzeichnis erscheint im Inhaltsverzeichnis
//             false = Verzeichnis erscheint nicht im Inhaltsverzeichnis

#let outline-def = (
  toc: [= #toc-title],
  lof: [= #lof-title],
  lot: [= #lot-title],
  // numbering: "i",       // Römische Seitenzahlen im Vorspann
  // toc-depth: 3,         // Tiefe des Inhaltsverzeichnisses (Standard: 3)
  // toc-position: "before",
  // toc-outlined: false,
  // lof-position: "before",
  // lof-outlined: false,
  // lot-position: "before",
  // lot-outlined: true,
)


// ============================================================
// Titelseite
// ============================================================
// Es stehen zwei vordefinierte Titelseiten zur Auswahl:
//   kznTitlePage()    — Titelseite mit KZN-Gestaltung und Hintergrundbild
//   simpleTitlePage() — Einfache Titelseite ohne Grafikelemente
// Eine eigene Titelseite kann als Funktion definiert und hier eingesetzt werden.

// Einfache Titelseite ohne Grafikelemente
#let simpleTitlePage() = context {
  if show-private-content.get() {
    place(
      top + left,
      [
        #block(text(weight: "bold", size: 16pt, [Kantonsschule Zürich Nord]))
        #block(text(weight: "bold", size: 12pt, [Lang- und Kurzgymnasium]))
        #block(text(weight: "bold", size: 12pt, [Fachmittelschule]))
      ],
    )

    v(7cm)

    place(
      center,
      [
        #block(text(weight: "bold", size: 24pt, title))
        #block(text(weight: "bold", size: 16pt, subtitle))

        #v(1cm)

        #block(text(size: 14pt, [#thesis-type]))
      ],
    )

    v(5cm)
    place(center, [#image("img/image.jpeg", width: 10cm)])

    place(
      bottom + left,
      [
        #block(text(weight: "bold", size: 14pt, [#written-by]))
        #block(text(weight: "bold", size: 16pt, [#join-with-und(authors)]))
        // #block(text(weight: "bold", size: 12pt, [#supervised-by]))
        // #block(text(weight: "bold", size: 14pt, [#join-with-und(supervisors)]))
        #block(text(weight: "bold", size: 11pt, [#submitted-on #date]))
        #v(1cm)
      ],
    )
  } else {
    place(
      horizon + center,
      [
        #block(text(weight: "bold", size: 22pt, title))
        #block(text(weight: "bold", size: 16pt, subtitle))
        #v(2cm)
        #block(text(size: 20pt, localize(anonymous-version)))
      ],
    )
  }
}

// Titelseite mit KZN-Gestaltung und Hintergrundbild
#let kznTitlePage() = kzn-titlepage(
  authors: authors,
  supervisors: supervisors,
  title: localize(title),
  title-size: 28pt,
  subtitle: subtitle,
  subtitle-size: 18pt,
  date: date,
  // Hintergrundbild unten auf der Titelseite
  nord-image: image("img/image.jpeg", height: 100%),
  // Quellenangabe zum Hintergrundbild (beliebiger Textblock)
  nord-image-source: [#localize(cover-image) #link("https://de.wikipedia.org/wiki/Kantonsschule_Zürich_Nord")],
  nord-color: black,
  background-color: white,
  zh-blue: rgb("009EE0"),
  heading-font: "Lato",
  strings: (
    submitted-on: submitted-on,
    thesis-type: thesis-type,
    written-by: written-by,
    supervised-by: supervised-by,
  ),
)

// Hier wird die gewünschte Titelseite ausgewählt
#let titlepage-def = (
  content: kznTitlePage()
  // content: simpleTitlePage()
)


// ============================================================
// Vorspann (Frontmatter)
// ============================================================
// Hier werden die Blöcke vor dem Inhaltsverzeichnis definiert.
// Nicht benötigte Blöcke können auskommentiert oder gelöscht werden.
// Eigene Blöcke können als Funktion definiert und in content: () eingefügt werden.

#let myAbstract() = {
  [= #abstract-title

Dieses Dokument beschreibt das Typst-Template der Kantonsschule Zürich Nord (KZN) für Maturitätsarbeiten und andere schriftliche Arbeiten. Es richtet sich an Schülerinnen und Schüler, die ihre Arbeit mit dem modernen Textsatzsystem Typst verfassen möchten, sowie an Lehrpersonen, die das Template für eigene Dokumente einsetzen.

Im ersten Teil werden die Grundkonzepte von Typst erläutert: Textformatierung mit Markdown, die zentralen Funktionen, sowie das Einbinden von Tabellen, Abbildungen und Formeln.

Der zweite Teil dokumentiert das KZN-Template konkret: Projekterstellung, Anpassung von Layout und Titelseite, Verwaltung der Frontmatter-Blöcke, Literaturreferenzen im BibTeX-Format, Mehrsprachigkeit sowie die Anonymisierungsfunktion für Plagiatsprüfungen.

Im Anhang finden sich vollständige Beispiele für den mathematischen Formelsatz, den Umgang mit diakritischen Zeichen und nicht-lateinischen Schriften, sowie Vorlagen für Einzel- und Mehrfachabbildungen und -tabellen.
  ]
}

#let myAIDeclaration() = {
  [= #ai-declaration-title
  #localize((
    de: [
KI-Tools wurden bei der Erstellung dieser Arbeit in folgenden Bereichen eingesetzt:
- Übersetzungen und Sprachbeispiele (Claude Sonnet 4.6)
- Grammatik- und Stilprüfung (Claude Sonnet 4.6)
- Code-Generierung für Beispiele (Claude Sonnet 4.6)

Alle KI-generierten Inhalte wurden sorgfältig überprüft, verifiziert und bei Bedarf angepasst.],
    en: [
AI tools were used in the following areas during the preparation of this work:
- Translations and language examples (Claude Sonnet 4.6)
- Grammar and style checking (Claude Sonnet 4.6)
- Code generation for examples (Claude Sonnet 4.6)

All AI-generated content was carefully reviewed, verified, and adapted as needed.],
    fr: [
Des outils d'IA ont été utilisés dans les domaines suivants lors de la préparation de ce travail :
- Traductions et exemples linguistiques (Claude Sonnet 4.6)
- Vérification grammaticale et stylistique (Claude Sonnet 4.6)
- Génération de code pour les exemples (Claude Sonnet 4.6)

Tous les contenus générés par IA ont été soigneusement vérifiés, validés et adaptés si nécessaire.],
    it: [
Strumenti di IA sono stati utilizzati nelle seguenti aree durante la preparazione di questo lavoro:
- Traduzioni ed esempi linguistici (Claude Sonnet 4.6)
- Controllo grammaticale e stilistico (Claude Sonnet 4.6)
- Generazione di codice per gli esempi (Claude Sonnet 4.6)

Tutti i contenuti generati dall'IA sono stati attentamente verificati, validati e adattati secondo necessità.],
    es: [
Se utilizaron herramientas de IA en las siguientes áreas durante la preparación de este trabajo:
- Traducciones y ejemplos lingüísticos (Claude Sonnet 4.6)
- Revisión gramatical y estilística (Claude Sonnet 4.6)
- Generación de código para ejemplos (Claude Sonnet 4.6)

Todo el contenido generado por IA fue cuidadosamente revisado, verificado y adaptado según fuera necesario.],
  ))
  ]
}

#let myAcknowledgments() = {
  [= #acknowledgments-title

  Wir danken dem Typst-Entwicklerteam für die Bereitstellung eines modernen, leistungsfähigen und frei zugänglichen Textsatzsystems.
  ]
}

#let myPreface() = {
  [= #preface-title

  Wer eine Maturarbeit schreibt, soll sich auf den Inhalt konzentrieren können –
  nicht auf Seitenränder, Schriftgrössen und Titelseiten. 

  Mit Typst steht ein modernes Textsatzsystem zur Verfügung, das eine klare Trennung von Inhalt und Layout erlaubt. Die Formatierung geschieht automatisch, ist aber dennoch überall anpassbar.
   Literaturreferenzen können mit
  Online-Datenbanken wie Mendeley oder Zotero verwaltet und mit minimalem Aufwand
  in die Arbeit integriert werden. Der Formelsatz für Mathematik, Physik und Chemie ist intuitiv, ebenso Codeblöcke für Informatikarbeiten.
 
 Dieses Template soll Zeit und Nerven sparen, damit beides für das wirklich Wichtige zur Verfügung steht: das Denken, Recherchieren und Schreiben.
  ]
}

// Vorlage für einen eigenen Abschnitt im Vorspann
#let myCustomBlock() = {
  [= Quickstart

  Um die eigene Arbeit zu starten, sind mindestens diese Schritt nötig:

  - Im Dokument ```typst main.typ``` nach dem Kommentar "Allgemeine Angaben" die Informationen wie Titel, Namen etc. anpassen.
  - Ein eigenes Bild für die Titelseite in den Ordner ```typst img``` hochladen und in der ```typst kznTitlePage()```-Funktion im Dokument ```typst main.typ``` anpassen:
    ```typst // Titelseite mit KZN-Gestaltung und Hintergrundbild
  #let kznTitlePage() = kzn-titlepage(
  ...
  nord-image: image("img/neuesBild.jpeg", height: 100%),
  // Quellenangabe zum Hintergrundbild (beliebiger Textblock)
  nord-image-source: [#localize(cover-image) #link("https://www.meineBildquelle.ch")],
  ...
  ```
  - Die Vorspann-Blöcke im Dokument ```typst main.typ``` anpassen und nicht gewünschte löschen. So würde z.B. nur der Abstract-Block gesetzt: ```typst #let frontmatter-def = (
  content: (
    myAbstract(),
  ),
  // numbering: "i",               // Römische Seitenzahlen im Vorspann
  // footer: kzn-footer(footer-text: []), // Eigene Fusszeile im Vorspann
)
```
  - Inhalt in ```typst main-matter.typ``` und ```typst appendix.typ``` löschen bis auf folgende Zeilen:
    ```typst #import "@​preview/kzn-ma:0.1.0": * // Diese Zeile ist immer nötig
#import "@preview/unify:0.7.1": unit, qty, num // Diese Zeile nötig, wenn Formeln gesetzt werden
#import "@preview/codly:1.3.0": codly, codly-init 
#import "@preview/codly-languages:0.1.10": * // Diese beiden Zeilen sind nötig, wenn Codeblöcke gesetzt werden
```
- Arbeit in ```typst main-matter.typ``` und ```typst appendix.typ``` schreiben.
  ]
}

// Alle Blöcke des Vorspanns in der gewünschten Reihenfolge.
// Nicht benötigte Blöcke auskommentieren oder löschen.
#let frontmatter-def = (
  content: (
    myAbstract(),
    myAIDeclaration(), 
    myAcknowledgments(),
    myPreface(),
    myCustomBlock(),
  ),
  // numbering: "i",               // Römische Seitenzahlen im Vorspann
  // footer: kzn-footer(footer-text: []), // Eigene Fusszeile im Vorspann
)


// ============================================================
// Layout einrichten — diese Zeile nicht verändern
// ============================================================

#show: ma.with(
  layout-def: layout-def,
  frontmatter-def: frontmatter-def,
  titlepage-def: titlepage-def,
  outline-def: outline-def,
)


// ============================================================
// Hauptteil
// ============================================================

#include content-file


// ============================================================
// Literaturverzeichnis
// ============================================================

#pagebreak(weak: true)
#bibliography(biblio-file, title: biblio-title, style: biblio-style)


// ============================================================
// Verzeichnisse nach dem Hauptteil
// ============================================================
// Dieser Aufruf ist nur wirksam, wenn in outline-def eine
// *-position: "after" gesetzt wurde. Sonst hat er keine Funktion.

#outlines-after(outline-def, layout-def)


// ============================================================
// Anhang
// ============================================================

#set heading(
  numbering: "A",   // Alphabetische Nummerierung der Anhang-Titel
  outlined: true,   // Anhänge erscheinen im Inhaltsverzeichnis
  supplement: appendix-desc,
)
#counter(heading).update(0)          // Neustart der Nummerierung
#pagebreak(weak: true, to: "odd")    // Beginn auf einer rechten Seite

#include appendix-file
