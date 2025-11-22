#import "@preview/tatras-ieee:0.1.0": ieee
// #import "../lib.typ": ieee

#show: ieee.with(
  title: [Názov článku na konferenciu vo formáte IEEE],
  abstract: [
    Link na #link("https://typst.app/")[Typst.app].
    #lorem(60)
  ],
  authors: (
    (
      name: "Janko Mkrvička",
      department: [Fakulta],
      organization: [Univerzita],
      location: [Bratislava, Slovensko],
      email: "janko@mrkvicka.sk"
    ),
    (
      name: "Peter Milan",
      department: [Fakulta],
      organization: [Univerzita],
      location: [Bratislava, Slovensko],
      email: "peter@milan.sk"
    ),
  ),
  index-terms: ("Kľúčové", "slová", "článku"),
  bibliography: bibliography("refs.bib"),
  figure-reference-supplement: [Obr.],  // default
  table-reference-supplement: [Tabuľka],  // default
  section-reference-supplement: [Sekcia],  // default
  underline-links: 2,  // default
)

= Nadpis 1 úrovne
#lorem(60)
== Link na webstránku
Link na #link("https://typst.app/")[Typst.app] je alebo nie je podčiarknutý.
== Citovanie
Citácia zdroja @example.

== Nadpis 2 úrovne <sec:heading2>
#lorem(60)

=== Referencia na obrázok
@fig:circle zobrazuje kružnicu.

#figure(
  placement: none,
  circle(radius: 15pt),
  caption: [Kružnica]
) <fig:circle>

#lorem(60)

== Referencia na sekciu
@sec:heading2 nam hovorí o nadpise druhej úrovne.

== Referencia na rovnicu
Nižšie vidíme rovnicu @eq:com, ktorá nám hovorí o komutatívnosti.

$ a #sym.times b = b #sym.times a $ <eq:com>

=== Nadpis 3 úrovne
#lorem(30)

=== Druhý Nadpis 3 úrovne
#lorem(30)


#figure(
  caption: [Mená a vek ľudí],
  placement: top,
  table(
    // Table styling is not mandated by the IEEE. Feel free to adjust these
    // settings and potentially move them into a set rule.
    columns: (6em, auto),
    align: (left, right),
    inset: (x: 8pt, y: 4pt),
    // stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

    table.header[*Meno*][*Vek*],
   [Ján], [25],
    [Eva], [30],
    [Peter], [45],
    [Mária], [35],
    [Tomáš], [50],
    [Anna], [40],
    [Michal], [55],
    [Zuzana], [60],
  )
) <tab:name_ages>

#lorem(60)

@tab:name_ages zobrazuje mená a vek ľudí.

= Záver
#lorem(60)

= Poďakovanie
#lorem(30)
  