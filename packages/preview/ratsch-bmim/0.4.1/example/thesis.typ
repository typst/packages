#import "./preamble.typ": *

#show: bmim.thesis(
  program: "Master",
  lang: "de",
  university: "UMIT",
  title: [
    Steuerung und Regelung \
    von \
    verteilt-parametrischen Systemen
  ],
  author: [John Doe, Bsc],
  date: [Oktober 2025],
  advisor: (
    (
      name: [ Dr. Max Mustermann ],
      university: [
        UMIT TIROL – Privatuniversität für Gesundheitswissenschaften und -technologie
      ],
      department: [
        Department für Biomedizinische Informatik und Mechatronik
      ],
      unit: [ Institut für Automatisierungs- und Regelungstechnik ],
    ),
    (
      name: [ Univ.-Prof. Max Doe ],
      university: [
        UMIT TIROL – Privatuniversität für Gesundheitswissenschaften und -technologie
      ],
      department:[
        Department für Biomedizinische Informatik und Mechatronik
      ],
      unit: [ Institut für Automatisierungs- und Regelungstechnik ],
    ),
  ),
  abstract: (
    english: [#lorem(150)],
    german: [#lorem(150)],
  ),
  thanks: [Vielen Dank an ...],
  oneside: false,
)

#set math.equation(numbering: "(1.1)")

#outline(
  title: [Abbildungsverzeichnis],
  target: std.figure.where(kind: image, outlined: true),
)

#show: mainmatter

= Ein Kapitel

== Ein 1. Abschnitt

#lorem(150)

== Abschnitt 2

Eine Abbildung sieht so aus wie @abb.

#figure(
  rect(width: 80%, height: 10%, fill: green)[],
  caption: [Grünes Rechteck.],
)<abb>

#lorem(150)

=== Unterabschnitt 1

#lorem(150)

This is a numbered equation

$
  1 + 1 & = 0
$<eqn>


= Kapitel 2

== Abschnitt 1

Die Gleichung @eqn wird hier referenziert.

#lorem(100)

== Abschnitt 2

Eine Tabelle sieht so aus wie @tab.

#figure(
  caption: [Ergebnisse.],
  table(
    columns: 4,
    [t], [1], [2], [3],
    [y], [0.3s], [0.4s], [0.8s],
  ),
)<tab>

#lorem(200)

=== Unterabschnitt 1

#lorem(300)
@netwok2020

==== Unterunterabschnitt 1

#lorem(400)

== Abschnitt 3

#lorem(500)

= Kapitel 3

#lorem(1500)

#show: backmatter

= Details

#lorem(100)


== Mehr Details

Wir haben den Beweis:
#proof[
  #lorem(150)
]

#lorem(300)

== Andere Details

#lorem(500)

#outline(
  title:[Tabellenverzeichnis],
  target: std.figure.where(kind: table, outlined: true),
)

#bibliography("sources.bib")
