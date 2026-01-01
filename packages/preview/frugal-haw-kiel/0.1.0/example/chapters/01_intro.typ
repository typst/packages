= Grundlegendes
== Zitieren, Glossar und Abkürzungen
Schaut doch mal ins Glossar, was @typst überhaupt ist. Außerdem könnt ihr in @typst_paper noch näher nachlesen, worum es geht.
Hier einige Beispiele für fetten und kursiven Text:

== Normal
#lorem(25)

== Fett
*#lorem(25)*

(Die Überschrift ist bereits extra bold.)

== _Kursiv_
_#lorem(25)_

== *_Fett & Kursiv_*
*_#lorem(25)_*

== Tabellen und Bilder nennen
@example_table zeigt wie schön Mathe sein kann und @example_image zeigt ein Beispielbild.

== Tabellen
// https://typst.app/docs/reference/model/table/
#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    inset: 10pt,
    align: (center+horizon),
    table.header(
      [], [*Volume*], [*Parameters*],
    ),

    image("../assets/cylinder.svg", fit: "contain", width: 30pt),
    $ pi h (D^2 - d^2) / 4 $,
    [
      $h$: height \
      $D$: outer radius \
      $d$: inner radius
    ],

    image("../assets/tetrahedron.svg", fit: "contain", width: 30pt),
    $ sqrt(2) / 12 a^3 $,
    [$a$: edge length]
  ),
  caption: "Mathe ist schön.",
) <example_table>


== Bilder
#figure(
  image("../assets/logo.svg"),
  caption: "Das Logo muss wie in der Readme beschrieben ersetzt werden.",
) <example_image>


