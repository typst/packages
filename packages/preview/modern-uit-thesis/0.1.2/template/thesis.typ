// A central place where libraries are imported (or macros are defined)
// which are used within all the chapters:
#import "chapters/global.typ": *

#let epigraph = [
  "The problem with object-oriented languages is they’ve got all this implicit \
  environment that they carry around with them. You wanted a banana but \
  what you got was a gorilla holding the banana and the entire jungle." \
  --- Joe Armstrong
]

#let abstract = [#lorem(150)]

#let acknowledgements = [#lorem(50)]

// Put your abbreviations/acronyms here.
// 'key' is what you will reference in the typst code
// 'short' is the abbreviation (what will be shown in the pdf on all references except the first)
// 'long' is the full acronym expansion (what will be shown in the first reference of the document)
#let abbreviations = (
  (
    key: "gc",
    short: "GC",
    long: "Garbage Collection",
  ),
  (
    key: "uit",
    short: "UiT",
    long: "University of Tromsø – The Arctic University of Norway",
  ),
  (
    key: "cow",
    short: "COW",
    long: "Copy on Write",
  ),
  (
    key: "cpu",
    short: "CPU",
    long: "Central Processing Unit",
  ),
)

#show: thesis.with(
  author: "<author>",
  title: "<title>",
  degree: "<degree>",
  faculty: "<faculty>",
  department: "<department>",
  major: "<major>",
  supervisors: (
    (
      title: "Main Supervisor",
      name: "Navn Navnesen",
      affiliation: [UiT The Arctic University of Norway, \
        Faculty of Science and Technology, \
        Department of Computer Science
      ],
    ),
    (
      title: "External Supervisor",
      name: "Kari Nordmann",
      affiliation: [External Company A/S],
    ),
  ),
  epigraph: epigraph,
  abstract: abstract,
  acknowledgements: acknowledgements,
  preface: none,
  figure-index: true,
  table-index: true,
  listing-index: true,
  abbreviations: abbreviations,
  date: datetime(year: 2024, month: 12, day: 16),
  bibliography: bibliography("refs.bib", title: "Bibliography", style: "ieee"),
)

// Code blocks
#codly(languages: (
  rust: (
    name: "Rust",
    color: rgb("#CE412B"),
  ),
  // NOTE: Hacky, but 'fs' doesn't syntax highlight
  fsi: (
    name: "F#",
    color: rgb("#6a0dad"),
  ),
))

// Include as many chapters as you like.

= Introduction <chp:introduction>
#include "./chapters/introduction.typ"
// NOTE:
// It's important to have explicit pagebreaks between each chapter,
// otherwise header stylings from the template might break
#pagebreak()

= Basic Usage <chp:basic_usage>
#include "./chapters/basic-usage.typ"
#pagebreak()

= Figures <chp:figures>
#include "./chapters/figures.typ"
#pagebreak()

= Typst Basics <chp:typst_basics>
#include "./chapters/typst-basics.typ"
#pagebreak()

= Utilities <chp:utilities>
#include "./chapters/utilities.typ"
