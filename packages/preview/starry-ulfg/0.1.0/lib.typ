#let starry-ulfg(
  document-title: "Lab Report",
  title: [Lab Report],
  course: none,
  year: [2025/2026],
  logos: (),
  candidates: (),
  professors: (),
  paper-size: "a4",
  lang: "en",
  preface: [],
  acknowledgment: [],
  show-list-of-figure: true,
  show-list-of-tables: true,
  show-appendix-table-contents: true,
  body,
) = {
  // Document metadata
  set document(title: document-title, author: candidates)
  // Text settings
  set text(font: "New Computer Modern", lang: lang, size: 12pt)
  // paragraph settings
  set par(justify: true, spacing: 1.5em)
  // page settings
  set page(
    paper: paper-size,
    margin: (right: 2.54cm, left: 2.54cm, top: 2.54cm, bottom: 2.54cm),
    number-align: bottom + right,
  )
  // Equations settings
  set math.equation(numbering: "(1)")
  // Headings settings
  set heading(numbering: "1.1", supplement: [Chapter])
  show heading.where(level: 1): it => { pagebreak(weak: true); it }
  show heading: set block(below: 2.5%)
  // Hide empty outlines
  show outline: it => if query(it.target) != () { it }
  // Cover Page
  place(top + right, year)
  align(center + horizon)[

    #place(top + left, image("assets/ulfg-logo.jpg", height: 10%))
    #let offset = 15%
    #for logo in logos {
      place(top + left, dx: offset, logo)
      offset = offset + 15%
    }
    // Title
    #text(22pt, strong(title))

    // Course name
    #if course != none {
      course
    }

    // Prepare By
    #linebreak()
    Prepared By:
    #linebreak()
    #for author in candidates {
      text(14pt, strong(author))
      linebreak()
    }
  ]
  // Presented to
  align(bottom + center)[
    #if professors != () {
      "Presented To:"
      for prof in professors {
        linebreak()
        strong(prof)
      }
      // table(align: center, stroke: none, column-gutter: 1pt, columns: 1, ..professors)
    }
  ]
  pagebreak()

  if preface != [] {
    align(center)[#text(16pt, strong([Preface]))]
    preface
    pagebreak(weak: true)
  }

  if acknowledgment != [] {
    align(center)[#text(16pt, strong([Acknowledgment]))]
    acknowledgment
    pagebreak(weak: true)
  }

  set page(numbering: "I", number-align: bottom + right)
  counter(page).update(1)

  // Table of contents.
  outline(title: [Table of Contents], depth: 3, indent: auto, target: heading.where(supplement: [Chapter]))

  // List of figures.
  if show-list-of-figure {
    outline(title: [List of Figures], target: figure.where(kind: image))
  }

  // list of tables.
  if show-list-of-tables {
    outline(title: [List of Tables], target: figure.where(kind: table))
  }

  if show-appendix-table-contents {
    outline(target: heading.where(supplement: [Appendix]), title: [Appendix])
  }
  // Content page break.
  pagebreak(weak: true)

  // Start Page numbering and reset counter.
  set page(numbering: "1", number-align: bottom + right)
  counter(page).update(1)

  body
}

#let appendix(body) = {
  set heading(numbering: "A", supplement: [Appendix])
  counter(heading).update(0)
  body
}