#import "@preview/tgm-hit-protocol:0.1.0": *

#set text(lang: "de")
#show: template(
  title: [Protokolle in Typst],
  course: [5xHIT 20yy/yy],
  subtitle: [Laborprotokoll],
  subject: [Systemtechnik Labor],
  author: "Arthur Dent",
  teacher: [Michael Borko],
  version: [1.0],
  begin: parse-date("2024-10-07"),
  finish: parse-date("2024-10-07"),
  date: parse-date("2024-10-09"),
  bibliography: bibliography("bibliography.bib"),
)

#import "assets/mod.typ" as assets
#include "glossaries.typ"

= Einführung
Diese Protokollvorlage soll helfen den Laborübungsteil entsprechend
dokumentieren zu können. Diese Vorlage ist in Typst verfasst.

== Ziele
Hier werden die zu erwerbenden Kompetenzen und deren Deskriptoren beschrieben.
Diese werden von den unterweisenden Lehrkräften vorgestellt.

Dies kann natürlich auch durch eine Aufzählung erfolgen:
- Dokumentiere wichtige Funktionen
- Gib eine Einführung zur Verwendung von Typst

== Voraussetzungen
Welche Informationen sind notwendig um die Laborübung reibungslos durchführen zu
können? Hier werden alle Anforderungen der Lehrkraft detailliert beschrieben und
mit Quellen untermauert.

== Aufgabenstellung
Hier wird dann die konkrete Aufgabenstellung der Laborübung definiert.

== Bewertung
Hier wird die Bewertung für das Beispiel auf die jeweiligen Kompetenzen
aufgeteilt. Diese soll zur leichteren Abnahme auch nicht entfernt werden.

Nun kommt ein Seitenumbruch, um eine klare Trennung der Schülerarbeit zu
bestimmen.

#pagebreak()

= Anwendung

Hier sollen die Schritte der Laborübung erläutert werden. Hier sind alle
Fragestellungen der Lehrkraft zu beantworten. Etwaige Probleme bzw.
Schwierigkeiten sollten ebenfalls hier angeführt werden.

In diesem Fall werden einige Typst-Elemente dokumentiert, welche bei der
Kreation von Protokollen behilflich sein könnten.

== Figures

Wenn man etwas in ein figure packt, dann kann es in einem Abbildungsverzeichnis
(oder ähnliches) später aufgelistet werden.

#figure(
  "Auch Text ist möglich!",
  caption: [Figure mit Text],
) <text-figure>

Man kann ihnen Labels (\<text-figure>) geben, und referenzieren (@text-figure).

Die folgenden Features können auch ohne figures verwendet werden.

== Abbildungen

#figure(
  assets.just-do-it-logo(width: 50%),
  caption: [Mit Beschreibung und Label],
)

== Mathe :)

=== Inline
Die coole Formel: $e^(i*pi)+1=0$

=== Zentriert
$ e^(i*pi)+1=0 $

=== Figure
#figure(
  $ e^(i*pi)+1=0 $,
  caption: [Eulersche Identität],
)

== Tabellen

#figure(
  table(
    columns: (1fr, 9fr),
    table.header([*Header*], [*Kopf*]),
    [#lorem(2)], [#lorem(10)],
    [#lorem(2)], [uwu],
  ),
  caption: [Tabellen],
)

== Aufzählung

- Element einer Aufzählung
  - Erstes eingerücktes Element einer Aufzählung
  - Zweites eingerücktes Element einer Aufzählung

+ Element einer Aufzählung
  + Erstes eingerücktes Element einer Aufzählung
  + Zweites eingerücktes Element einer Aufzählung

== Glossar

Das Glossar enthält Erklärungen von Begriffen und Abkürzen, die im Fließtext keinen Platz haben. In der Datei `glossaries.typ` werden Begriffe -- oder in diesem Fall eine Abkürzung -- in der folgenden Form definiert:

#figure(
  ```typ
  #glossary-entry(
    "ac:tgm",
    short: "TGM",
    long: "Technologisches Gewerbemuseum",
  )
  ```,
  caption: [Eintrag einer Abkürzung in `glossaries.typ`],
)

Verwendet werden kann dieser Glossareintrag ähnlich einer Quellenangabe durch ```typ @ac:tgm```. Bei der ersten Verwendung wird die Langform automatisch auch dargestellt: @ac:tgm. Bei weiteren Verwendungen wird dagegen nur die Kurzform angezeigt: @ac:tgm.

Mit der Funktion ```typc gls()``` kann auch die Langform erzwungen werden: #gls("syt") ist beim ersten mal auch ausgeschrieben, aber hier wird es manuell erwirkt: #gls("syt", long: true).

== Quelltext

#figure(
  ```cpp
  #include <iostream>
  int main() {
      // Ich bin ein Kommentar!
      std::cout << "Hello World! :3\n";
  }
  ```,
  caption: [C++ Code],
)
