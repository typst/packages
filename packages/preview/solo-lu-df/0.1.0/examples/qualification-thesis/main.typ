#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import fletcher.shapes: cylinder, ellipse
#import "@preview/solo-lu-df:0.1.0": *
#import "utils/tables.typ": function-table
#import "utils/diagrams.typ": data-store, dpd-database, dpd-edge, process

#show: ludf.with(
  title: "Darba Nosaukums",
  thesis-type: "Kvalifikācijas Darbs",
  authors: (
    (
      name: "Jānis Bērziņš",
      code: "jb12345",
      location: [Riga, Latvia],
      email: "jb12345@edu.lu.lv",
    ),
    (
      name: "Zane Kalniņa",
      code: "zk67890",
      location: [Riga, Latvia],
      email: "zk67890@edu.lu.lv",
    ),
  ),
  advisors: (
    (
      title: "Mg. dat.",
      name: "Ivars Ozoliņš",
    ),
  ),
  reviewer: (
    name: "Jānis Ozols",
  ),
  date: datetime(
    year: 2025,
    month: 1,
    day: 1,
  ),
  place: "Rīga",
  bibliography: bibliography("bibliography.yml"),
  abstract: (
    primary: (
      text: [
        #lorem(50)

        #lorem(30)

        #lorem(20)
      ],
      keywords: (
        "Foo",
        "Bar",
        "Baz",
      ),
    ),
    secondary: (
      text: [
        #lorem(20)

        #lorem(30)

        #lorem(50)
      ],
      keywords: (
        "foo",
        "bar",
        "baz",
      ),
    ),
  ),
  attachments: (
    attachment(
      caption: "Attachment table",
      label: <table-1>,
      table(
        columns: (1fr, 1fr),
        [foo], [bar],
      ),
    ),
    attachment(
      caption: "Another table",
      table(
        columns: (1fr, 1fr),
        [Column 1], [Column 2],
      ),
    ),
  ),
)


#set heading(numbering: none)
= Apzīmējumu saraksts
/ Docs: Typst dokumentācija.#footnote[https://typst.com/docs/]
/ Universe: Typst kopienas paketes un šabloni.#footnote[https://typst.app/universe/]

= Ievads
== Nolūks
#lorem(100)

== Darbības sfēra

== Saistība ar citiem dokumentiem
PPS ir izstrādāta, ievērojot LVS 68:1996 "Programmatūras prasību specifikācijas
ceļvedis" @lvs_68 un LVS 72:1996 "Ieteicamā prakse programmatūras projektējuma
aprakstīšanai" standarta prasības @lvs_72.

== Pārskats

#set heading(numbering: "1.1.")

= Vispārējais apraksts
== Esošā stāvokļa apraksts
== Pasūtītājs
== Produkta perspektīva
== Darījumprasības
== Sistēmas lietotāji

Skatīt @dpd-0

#figure(
  caption: [\0. līmeņa DPD],
  diagram(
    data-store((0, 0), [Lietotājs]),
    dpd-edge("rr,ddd,ll", align(center)[Ievades ierīces\ dati]),
    process((0, 3), [Sistēma], inset: 20pt),
    dpd-edge(
      "lll,uuu,rrr",
      align(center)[Vizuālās\ izvades dati],
    ),
    dpd-edge(
      "l,uuu,r",
      align(center)[Audio\ izvades dati],
    ),
  ),
) <dpd-0>

/// Or use an image
//
// #figure(
//   caption: "0. līmeņa DPD",
//   image("path/to/image"),
// ) <dpd-0>

== Vispārējie ierobežojumi

= Programmatūras prasību specifikācija
== Konceptuālais datu bāzes apraksts
== Funkcionālās prasības

#figure(
  caption: [\1. līmeņa DPD],
  diagram({
    dpd-database((0, 0), [Datubāze], snap: -1)
    dpd-edge("ldd", align(center)[Neapstrādāti\ ārējie dati])
    dpd-edge("rrr,d", align(center)[Neapstrādāti\ dati])

    process(
      (-1, 2),
      [Ārējs apstrādātājs],
      inset: 20pt,
      stroke: (thickness: 1pt, dash: "dashed"),
    )
    dpd-edge("r,uu", align(center)[Apstrādāti\ ārējie dati])

    data-store((0, -2), [Lietotājs])
    dpd-edge("dd", align(center)[Neapstrādāti\ lietotāja dati])

    process((3, 1), [A modulis], inset: 20pt)
    dpd-edge("lllu", align(center)[Apstrādāti dati], shift: 20pt)
  }),
) <dpd-1>

=== Funkciju sadalījums moduļos
Funkciju sadalījums moduļos ir aprakstīts tabulā (@function-modules[tab.]).

#figure(
  caption: "Funkciju sadalījums pa moduļiem",
  table(
    columns: (auto, 1fr, auto),
    align: left,
    table.header([Modulis], [Funkcija], [Identifikators]),

    table.cell(rowspan: 1)[A modulis],
    [A saskarne], [#link(<AF01>)[AF01]],

    table.cell(rowspan: 2)[B modulis],
    [B saskarne], [#link(<BF01>)[BF01]],
    [B apstrāde], [#link(<BF02>)[BF02]],
  ),
) <function-modules>

=== A Modulis
#function-table(
  "A Saskarne",
  "AF01",
  [#lorem(15)],
  [
    + #lorem(4)
    + #lorem(5)
    + #lorem(6)
  ],
  [
    + #lorem(4)
    + #lorem(5)
    + #lorem(6)
      + #lorem(7)
      + #lorem(8)
        - #lorem(2)
        - #lorem(1)
        - #lorem(3)
        - #lorem(1)
  ],
  [
    + #lorem(10)
    + #lorem(10)
  ],
) <AF01>

=== B Modulis

#function-table(
  "B Saskarne",
  "BF01",
  [#lorem(15)],
  [
    + #lorem(4)
    + #lorem(5)
    + #lorem(6)
  ],
  [
    + #lorem(4)
    + #lorem(5)
    + #lorem(6)
      + #lorem(7)
      + #lorem(8)
        - #lorem(2)
        - #lorem(1)
        - #lorem(3)
        - #lorem(1)
  ],
  [
    + #lorem(10)
    + #lorem(10)
  ],
  [
    + #lorem(10)
    + #lorem(10)
  ],
) <BF01>


#function-table(
  "B Apstrāde",
  "BF02",
  [#lorem(15)],
  [
    + #lorem(4)
    + #lorem(5)
    + #lorem(6)
  ],
  [
    + #lorem(4)
    + #lorem(5)
    + #lorem(6)
      + #lorem(7)
      + #lorem(8)
        - #lorem(2)
        - #lorem(1)
        - #lorem(3)
        - #lorem(1)
  ],
  [
    + #lorem(10)
    + #lorem(10)
  ],
) <BF02>

== Nefunkcionālās prasības
=== Veiktspējas prasības

= Programmatūras projektējuma apraksts
== Datu bāzes projektējums
=== Datu bāzes loģiskais ER modelis
Skatīt @logical-erd

#figure(
  caption: "Datu bāzes loģiskais ER modelis",
  [\<image>],
  // image("path/to/image")
) <logical-erd>

=== Datu bāzes fiziskais ER modelis
Skatīt @physical-erd[]

#figure(
  caption: "Datu bāzes loģiskais ER modelis",
  [\<image>],
  // image("path/to/image")
) <physical-erd>

=== Datu bāzes tabulu apraksts

== Daļējs funkciju projektējums

== Daļējs lietotāju saskarņu projektējums
=== Navigācija
sk. @view-flow-diagram

#figure(
  caption: "Ekrānskatu plūsmas diagramma",
  [\<image>],
  // image("path/to/image")
) <view-flow-diagram>

=== Ekrānskati
