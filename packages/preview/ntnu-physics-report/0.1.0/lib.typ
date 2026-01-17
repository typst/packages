// NTNU Physics Lab Report Template for Typst
// Based on the LaTeX elsarticle template

#let ntnu-rapport(
  title: none,
  authors: (),
  affiliations: (),
  supervisor: none,
  abstract: none,
  bibliography-file: none,
  two-column: true,
  body,
) = {
  // ===================
  // CONFIGURABLE VALUES
  // ===================

  // Page
  let page-margin-top = 30mm
  let page-margin-bottom = 20mm
  let page-margin-side = 13mm
  let column-gutter = 6mm

  // Fonts
  let font-family = "New Computer Modern"
  let font-size-body = 10pt
  let font-size-title = 13pt
  let font-size-heading = 10pt
  let font-size-authors = 10pt
  let font-size-affiliation = 8pt
  let font-size-abstract = 10pt
  let font-size-caption = 9pt

  // Spacing
  let line-height = 0.5em
  let paragraph-indent = 1em
  let figure-gap = 1em

  // ================
  // PAGE & TEXT SETUP
  // ================

  set page(
    paper: "a4",
    margin: (top: page-margin-top, bottom: page-margin-bottom, left: page-margin-side, right: page-margin-side),
    numbering: "1",
    number-align: center,
  )

  set text(lang: "nb", font: font-family, size: font-size-body)
  set par(justify: true, leading: line-height, first-line-indent: paragraph-indent, spacing: 0.6em)

  // ========
  // HEADINGS
  // ========

  set heading(numbering: "1.")
  show heading.where(level: 1): it => {
    block(above: 1.5em, below: 0.1em)[
      #text(size: font-size-heading, weight: "bold")[#it]
    ]
    h(paragraph-indent)
  }

  // =========
  // EQUATIONS
  // =========

  set math.equation(numbering: "(1)")

  // =================
  // FIGURES & TABLES
  // =================

  show figure.where(kind: image): set figure.caption(position: bottom)
  show figure.where(kind: table): set figure.caption(position: top)
  set figure(gap: figure-gap)
  show figure.caption: it => {
    text(size: font-size-caption)[*#it.supplement #it.counter.display():* #it.body]
  }

  // ============
  // FRONT MATTER
  // ============

  // Title
  v(0.5em)
  align(center, text(size: font-size-title)[#title])
  v(1.5em)

  // Authors & Affiliations
  {
    set par(first-line-indent: 0pt)

    // Build author list with superscript affiliations
    let author-strings = authors.map(author => {
      let affil-marks = author.affiliations.map(i => super(str(i))).join(",")
      [#author.name#affil-marks]
    })
    align(center, text(size: font-size-authors)[#author-strings.join(", ")])
    v(0.6em)

    // Affiliations
    for (i, affil) in affiliations.enumerate() {
      align(center, text(style: "italic", size: font-size-affiliation)[#super(str(i + 1))#affil])
    }

    // Supervisor
    if supervisor != none {
      v(0.3em)
      align(center, text(size: font-size-affiliation)[Veileder: #supervisor])
    }
  }
  v(2.5em)

  // Abstract
  line(length: 100%, stroke: 0.4pt)
  block(width: 100%, inset: (y: 0.4em))[
    #set par(first-line-indent: 0pt)
    *Sammendrag*
    #v(0.2em)
    #text(size: font-size-abstract)[#abstract]
  ]
  line(length: 100%, stroke: 0.4pt)
  v(0.6em)

  // ====
  // BODY
  // ====

  if two-column {
    columns(2, gutter: column-gutter, body)
  } else {
    body
  }

  // ===========
  // BIBLIOGRAPHY
  // ===========

  if bibliography-file != none {
    set par(first-line-indent: 0pt)
    bibliography(bibliography-file, style: "ieee")
  }
}

// =============
// TABLE HELPERS
// =============

#let toprule = table.hline(stroke: 0.8pt)
#let midrule = table.hline(stroke: 0.4pt)
#let bottomrule = table.hline(stroke: 0.8pt)
