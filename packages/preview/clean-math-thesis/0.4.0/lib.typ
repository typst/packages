// global
#import "@preview/great-theorems:0.1.2": great-theorems-init
#import "@preview/hydra:0.6.1": hydra
#import "@preview/equate:0.3.2": equate
#import "@preview/i-figured:0.2.4": reset-counters, show-equation

#import "headings.typ": thesis-heading

#let template(
  // personal/subject related stuff
  author: "Stuart Dent",
  title: "My Very Fancy and Good-Looking Thesis About Interesting Stuff",
  supervisor1: "Prof. Dr. Sue Persmart",
  supervisor2: "Prof. Dr. Ian Telligent",
  degree: "Example",
  program: "Example-Studies",
  university: "Example University",
  institute: "Example Institute",
  deadline: datetime.today().display(),
  city: "Example City",


  // file paths for logos etc.
  uni-logo: none,
  institute-logo: none,

  // formatting settings
  body-font: "Libertinus Serif",
  cover-font: "Libertinus Serif",

  // content that needs to be placed differently then normal chapters
  // frontmatter is put BEFORE the cover page
  frontmatter: none,
  // abstract is put AFTER cover, BEFORE outline
  abstract: none,

  // colors
  cover-color: rgb("#800080"),
  heading-color: rgb("#0000ff"),
  link-color: rgb("#000000"),

  // equation settings
  equate-settings: none,
  equation-numbering-pattern: "(1.1)",

  // the content of the thesis
  body
) = {
// ------------------- settings -------------------
set document(author: author, title: title)
set heading(numbering: "1.1")  // Heading numbering
set enum(numbering: "(i)") // Enumerated lists
show link: set text(fill: link-color)
show ref: set text(fill: link-color)
set page(numbering: "i'")

// ------------------- Math equation settings -------------------

// either use equate if equate-settings is set or use i-figured if equate-settings is none
// i-figured settings
show math.equation: it => {
  if equate-settings == none {
    show-equation(prefix: "eq:", only-labeled: true, numbering: equation-numbering-pattern, it)
  } else {
    it
  }
}
set math.equation(supplement: none) if equate-settings == none

// equate settings
show: it => {
  if equate-settings != none {
    equate(..equate-settings, it)
  } else {
    it
  }
}
set math.equation(numbering: equation-numbering-pattern) if equate-settings != none

// Reference equations with parentheses (for equate)
// cf. https://forum.typst.app/t/how-can-i-set-numbering-for-sub-equations/1603/4
show ref: it => {
  let eq = math.equation
  let el = it.element

  let is-normal-equation = el != none and el.func() == eq
  let with-subnumbers = equate-settings != none and equate-settings.keys().contains("sub-numbering") and equate-settings.sub-numbering
  let is-sub-equation = el != none and el.func() == figure and el.kind == eq
  if equate-settings != none and is-normal-equation {
    link(el.location(), numbering(
      el.numbering,
      ..counter(eq).at(el.location())
    ))
  } else if equate-settings != none and not with-subnumbers and is-sub-equation {
    link(el.location(), numbering(
      el.numbering,
      counter(eq).at(el.location()).at(0) - 1
    ))
  } else if equate-settings != none and is-sub-equation {
    link(el.location(), numbering(
      el.numbering,
      ..el.body.value
    ))
  } else {
    it
  }
}

show math.equation: box  // no line breaks in inline math
show: great-theorems-init  // show rules for theorems


// ------------------- other settings -------------------
// Settings for Chapter in the outline
show outline.entry.where(
  level: 1
): it => {
  v(14.75pt, weak: true)
  strong(it)
}

// table label on top and not below the table
show figure.where(
  kind: table
): set figure.caption(position: top)

// --------------- Frontmatter ---------------
// before the cover page, usually a university-given cover page
set text(font: body-font)  // body font
if frontmatter != none {
  frontmatter
  pagebreak(weak: true) // page break before cover
}

// Update numbering
set page(numbering: "i")
counter(page).update(1)

// ------------------- Cover -------------------
set page(footer: none) // disable footer until the end of contents
set text(font: cover-font)  // cover font

v(1fr)
//logos
  if uni-logo != none and institute-logo != none {
    grid(
      columns: (1fr, 1fr),
      rows: (auto),
      column-gutter: 100pt,
      row-gutter: 7pt,
      grid.cell(
        colspan: 1,
        align: center,
        uni-logo,
      ),
      grid.cell(
        colspan: 1,
        align: center,
        institute-logo,
      ),
      grid.cell(
        colspan: 1,
        align: center,
        text(1.5em, weight: 700, university)
      ),
      grid.cell(
        colspan: 1,
        align: center,
        text(1.5em, weight: 700, institute)
      )
    )
  } else if uni-logo != none {
    grid(
      columns: (0.5fr),
      rows: (auto),
      column-gutter: 100pt,
      row-gutter: 7pt,
      grid.cell(
        colspan: 1,
        align: center,
        uni-logo,
      ),
      grid.cell(
        colspan: 1,
        align: center,
        text(1.5em, weight: 700, university)
      )
    )
  } else if institute-logo != none {
    grid(
      columns: (0.5fr),
      rows: (auto),
      column-gutter: 100pt,
      row-gutter: 7pt,
      grid.cell(
        colspan: 1,
        align: center,
        institute-logo,
      ),
      grid.cell(
        colspan: 1,
        align: center,
        text(1.5em, weight: 700, institute)
      )
    )
  }
v(5fr)
//title
line(length: 100%, stroke: cover-color)
align(center, text(3em, weight: 700, title))
line(start: (10%, 0pt), length: 80%, stroke: cover-color)
v(5fr)
//author
align(center, text(1.5em, weight: 500, degree + " Thesis by " + author))
//study program
if program != none {
  align(center, text(1.3em, weight: 100, "Study Programme: " + program))
}
//university
align(center, text(1.3em, weight: 100, university + ", " + institute))
//date
let deadline-text = deadline
if city != none {
  deadline-text = city + ", " + deadline
}
align(center, text(1.3em, weight: 100, deadline-text))
// supervisors
align(center + bottom, text(1.3em, weight: 100, " supervised by" + linebreak() + supervisor1 + linebreak() +  supervisor2))
pagebreak()

// ------------------- Settings for headings -------------------
show: it => thesis-heading(heading-color, it)

// reset counter from i-figured for section-based equation numbering
show heading: it => {
  if equate-settings == none {
    reset-counters(it)
  } else {
    it
  }
}

// ------------------- Abstract -------------------
set text(font: body-font)  // body font
if abstract != none{
  abstract
}


pagebreak()

// ------------------- Tables of ... -------------------

// Table of contents
set outline.entry(fill: line(length: 100%, stroke: (thickness: 1pt, dash: "loosely-dotted")))
outline(depth: 3, indent: 1em)
pagebreak()

context {
  // List of figures
  let figures = figure.where(kind: image)
  if query(figures).len() > 0 {
    outline(
      title: [List of Figures],
      target: figures,
    )
    pagebreak()
  }

  // List of Tables
  let tables = figure.where(kind: table)
  if query(tables).len() > 0 {
    outline(
      title: [List of Tables],
      target: tables
    )
    pagebreak()
  }
}

// Re-enable page numbering before content
set page(
  numbering: "1",
  number-align: center,
  header: context {
    align(center, emph(hydra(1)))
    v(0.2cm)
  },
  footer: auto
)
counter(page).update(1)

// ------------------- Content -------------------
body
}
