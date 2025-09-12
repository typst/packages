#import "@preview/pretty-hdm-thesis:0.1.1": pretty-hdm-thesis
#import "@preview/glossarium:0.5.9": gls, glspl

#import "abstract.typ": abstract-de, abstract-en
#import "acronyms.typ": acronyms
#import "glossary.typ": glossary

#let metadata = yaml("metadata.yaml")

#let acknowledgements = [
    I'd like to thank caffeine for getting me through many many MANY nights writing all of this
]

#show: pretty-hdm-thesis.with(
    metadata, // see metadata.yaml
    datetime.today(), // or `datetime(year: 2025, month: 8, day: 4),` if you have a specific submission date already
    bib: bibliography("sources.bib"),
    // optional citation style (default is "chicago-notes"): `bib-style: "turabian-fullnote-8",`

    // the following features are all optional or can be disabled
    glossary: glossary, acronyms: acronyms,
    abstract-de: abstract-de, abstract-en: abstract-en, acknowledgements: acknowledgements,
    declaration-of-authorship: true, table-outline: true, figure-outline: true

    // you can get the HdM Logo or another visual on various pages using the `logo` parameter
    // see the readme for more information
    )


= Introduction

== Topic A

#lorem(75);

#lorem(50);

== Topic B

#lorem(150)

#pagebreak(weak: true)
= Another Heading

#lorem(300)

== Sub Heading

#lorem(150)

= Functions

== Citations

Citing a thing here @iso18004

== Referencing Glossary Items

// only available if you provide a glossary/acronyms to pretty-hdm-thesis that contains this key
Like this: #gls("kuleuven")

== Figures

#figure(
    caption: [
        Image Example (#link("https://www.freepik.com/author/freepik/icons/kawaii-lineal_46#from_element=resource_detail")[Icon by Freepik])
    ],
    image(width: 4cm, "assets/example.png"))

== Tables

#figure(
    caption: "Table Example",
    table(
    columns: (1fr, 50%, auto),
    inset: 10pt,
    align: horizon,
    table.header(
      [],
      [*Area*],
      [*Parameters*],
    ),

    text("cylinder.svg"),
    $ pi h (D^2 - d^2) / 4 $,
    [
      $h$: height \
      $D$: outer radius \
      $d$: inner radius
    ],

    text("tetrahedron.svg"), $ sqrt(2) / 12 a^3 $, [$a$: edge length],
  )
)