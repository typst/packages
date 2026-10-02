#import "utils/global.typ": *
#import "utils/chapter-opener.typ": chapter-opener

// `typst compile --input edition=print` builds the edition for double-sided printing; the default is the edition for reading on screen.
#let edition = sys.inputs.at("edition", default: "digital")
#assert(
  edition in ("print", "digital"),
  message: "edition must be print or digital, not " + edition,
)

#let epigraph = [
  "The problem with object-oriented languages is they’ve got all this implicit \
  environment that they carry around with them. You wanted a banana but \
  what you got was a gorilla holding the banana and the entire jungle." \
  --- Joe Armstrong
]

#let abstract = [_Replace this text with your abstract: `abstract` in `thesis.typ`._ #lorem(140)]

#let affidavit = [
  _Replace this text with the declaration your university requires: `affidavit` in `thesis.typ`._

  I declare that this thesis is my own work, that I have acknowledged every contribution and source, and that I have not submitted it for any other degree.
]

#let acknowledgements = [_Replace this text with your acknowledgements: `acknowledgements` in `thesis.typ`._ #lorem(40)]

#let appendix = [
  = Supplementary Material
  #include "./chapters/appendix.typ"
]

#let glossary = (
  (
    key: "gc",
    short: "GC",
    long: "Garbage Collection",
  ),
  (
    key: "cpu",
    short: "CPU",
    long: "Central Processing Unit",
  ),
)

#let publications = (
  (
    key: "doe2024first",
    text: [J.~Doe and A.~Smith, "Title of a Journal Article," _Journal Name_, vol.~1, pp.~1--10, 2024.],
    group: "Journal Articles",
  ),
  (
    key: "doe2025second",
    text: [J.~Doe, "Title of a Conference Paper," in _Conference Name_, 2025.],
    group: "Conference Papers",
    status: "Under review",
  ),
)

#show: thesis.with(
  author: "<author>",
  title: "<title>",
  degree: "<degree>",
  degree-subject: "<degree subject>",
  doc-id: "<document ID>",
  faculty: "<faculty>",
  department: "<department>",
  defense-location: "<defense location>",
  supervisors: (
    (
      title: "Prof.",
      name: "<supervisor>",
    ),
  ),
  cosupervisors: (
    (
      title: "Dr.",
      name: "<co-supervisor>",
    ),
  ),
  committee: (
    (
      title: "Prof.",
      name: "<committee member>",
    ),
    (
      title: "Prof.",
      name: "<committee member>",
    ),
  ),
  affidavit: affidavit,
  epigraph: epigraph,
  abstract: abstract,
  appendix: appendix,
  acknowledgements: acknowledgements,
  preface: none,
  physical-copy: edition == "print",
  chapter-opener: chapter-opener,
  figure-index: true,
  table-index: true,
  listing-index: true,
  glossary: glossary,
  publications: publications,
  date: datetime(year: 2025, month: 6, day: 1),
  bibliography: bibliography(
    "bibliography.bib",
    title: "Bibliography",
    style: "ieee",
  ),
)

#codly(languages: (
  rs: (
    name: "Rust",
    color: rgb("#CE412B"),
  ),
))

= Introduction <chp:introduction>
#include "./chapters/introduction.typ"

= Basic Usage <chp:basic_usage>
#include "./chapters/basic-usage.typ"

= Figures <chp:figures>
#include "./chapters/figures.typ"

= Typst Basics <chp:typst_basics>
#include "./chapters/typst-basics.typ"

= Utilities <chp:utilities>
#include "./chapters/utilities.typ"
