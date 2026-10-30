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
  lists: (image, table),
  // own pages of the front matter after the lists, e.g. a list of symbols
  frontmatter: [
    #heading(numbering: none, outlined: true)[Symbolverzeichnis]

    #let symbols(unit: true, ..rows) = table(
      columns: if unit { (auto, 1fr, auto) } else { (auto, 1fr) },
      stroke: none,
      align: (center, left, left),
      table.header([*Symbol*], [*Bedeutung*], ..if unit { ([*Einheit*],) }),
      table.hline(stroke: 0.5pt),
      ..rows,
    )

    *Physikalische Parameter*
    #symbols(
      $m$, [Masse des Wagens], [$"kg"$],
      $l$, [Länge des Pendels], [$"m"$],
      $g$, [Erdbeschleunigung], [$"m"\/"s"^2$],
      $J$, [Massenträgheitsmoment], [$"kg" "m"^2$],
    )

    *Formelzeichen*
    #symbols(
      $bold(x)$, [Zustand], [–],
      $u$, [Stellgröße], [$"N"$],
      $y$, [Ausgangsgröße], [$"m"$],
      $G(s)$, [Übertragungsfunktion], [–],
    )

    *Diakritische Zeichen*
    #symbols(unit: false,
      $dot(x)$, [Zeitableitung von $x$],
      $hat(x)$, [Schätzwert von $x$],
      $tilde(x)$, [Schätzfehler $x - hat(x)$],
      $x^star$, [Referenzverlauf von $x$],
    )
  ],
)

#set math.equation(supplement: none, numbering: (..nums) => numbering("(1a)", ..nums))

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

Lists:
- Element 1
- Element 1
- Element 1
- Element 1
and some text around.

#lorem(500)

#bibliography("sources.bib")
