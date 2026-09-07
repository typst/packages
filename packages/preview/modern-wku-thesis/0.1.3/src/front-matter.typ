// Front matter: abstract, acknowledgments, table of contents,
// lists of figures/tables and the acronyms table.

#let front-matter(abstract: none, keywords: none, acknowledgments: none, acronyms: none) = {
  // Abstract section (if provided)
  if abstract != none {
    [= Abstract]

    [#abstract]

    v(1em)

    if keywords != none {
      text(weight: "bold")[Keywords: ] + [#keywords]
    }

    pagebreak()
  }

  // Acknowledgments section (if provided)
  if acknowledgments != none {
    [= Acknowledgments]

    [#acknowledgments]

    pagebreak()
  }

  // TOC entry styles: level-1 entries bold with extra spacing,
  // deeper levels pulled back to the left.
  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    strong(it)
  }
  show outline.entry.where(level: 2): it => pad(left: -4em, it)
  show outline.entry.where(level: 3): it => pad(left: -5em, it)
  show outline.entry.where(level: 4): it => pad(left: -5em, it)

  outline(title: text(size: 25pt, weight: "bold")[Table of Contents])
  pagebreak()

  // Lists of figures/tables as headings so they appear in the TOC
  heading(level: 1, numbering: none)[List of Figures]
  outline(title: none, target: figure.where(kind: image))
  pagebreak()

  heading(level: 1, numbering: none)[List of Tables]
  outline(title: none, target: figure.where(kind: table))
  pagebreak()

  // Acronyms table (if provided)
  if acronyms != none and acronyms.len() > 0 {
    [= Definition of Acronyms]

    figure(
      table(
        columns: (20%, 80%),
        stroke: 0.5pt,
        align: (center, left),
        table.header(
          [*Acronym*], [*Definition*]
        ),
        ..acronyms.pairs().flatten(),
      ),
      caption: [Definition of Acronyms],
      kind: table,
    )

    pagebreak()
  }
}
