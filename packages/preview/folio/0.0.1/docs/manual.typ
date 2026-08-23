/// folio v0.0.1 — Reference Manual
/// This document provides a rendered overview of the folio library.
/// For full documentation, see docs/SCHEMA.md, docs/BRAND.md, and docs/PIPELINE.md.

#import "@preview/folio:0.0.1": badge, card, folio-init, metric

#set page(paper: "a4", margin: 2cm, numbering: "1")
#set text(font: ("Liberation Sans", "DejaVu Sans"), size: 10pt)

#align(center + horizon)[
  #text(size: 3em, weight: "bold")[folio]
  #v(0.5em)
  #text(
    size: 1.5em,
    style: "italic",
    fill: luma(100),
  )[Reference Manual — v0.0.1]
  #v(2em)
  #text(size: 1em)[A PMBOK-aligned project document generator for Typst.]
]

#pagebreak()
#outline(title: "Contents", indent: auto)

#pagebreak()
= Quick Start

#card(title: "Minimal Document")[
  ```typst
  #import "@preview/folio:0.0.1": project-doc

  #show: project-doc(
    data: (
      project: (name: "My Project", description: "A short description."),
    ),
  )
  ```
  This produces a document with a cover page and any sections where data is present.
]

= Presets

Three brand presets are available out of the box:

#table(
  columns: (auto, 1fr, auto),
  stroke: 0.5pt + luma(200),
  inset: 0.75em,
  fill: (col, row) => if row == 0 { luma(240) } else { none },
  [*Preset*], [*Character*], [*Best For*],
  [`"minimal"`],
  [Serif, no rounded corners, grayscale],
  [Thesis, academic submissions],

  [`"corporate"`], [Sans-serif, blue, rounded cards], [Project plans, RFPs],
  [`"academic"`],
  [New Computer Modern, deep blue, formal spacing],
  [Academic project briefs],
)

= Sections

All 28 PMBOK-aligned sections are listed in `docs/PIPELINE.md`.
Sections are skipped automatically when data is missing (`auto` mode) or can be forced on/off via `config.sections`.

= Documents

Three example documents are provided:

#card(
  title: "examples/full-standards.typ",
)[Full pipeline — all sections, corporate brand, audit dashboard enabled.]
#v(0.5em)
#card(
  title: "examples/thesis.typ",
)[Academic brand, initiation + planning phases only.]
#v(0.5em)
#card(
  title: "examples/hardware.typ",
)[Corporate navy brand, full budget, risks, compliance, custom safety section.]

= Further Reading

- `docs/SCHEMA.md` — Complete field reference (30+ paths, types, examples)
- `docs/BRAND.md` — Token groups, preset descriptions, customization guide
- `docs/PIPELINE.md` — All 28 sections, custom injection, config reference
