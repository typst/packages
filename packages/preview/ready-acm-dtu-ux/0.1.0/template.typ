// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(title: "", subtitle: "Final Report 02809 (or 02266)", abstract: [], authors: (), body) = {
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)
  set page(numbering: "1", number-align: center)
  set text(
    font: "Libertinus Serif",
    size: 10pt,
    lang: "en"
  )

  // Monospaced for code
  show raw: set text(font: "Inconsolata")

  // Headings use Biolinum (sans-serif)
  show heading.where(level: 1): smallcaps
  show heading.where(level: 1): set text(
    font: "Libertinus Sans",
    size: 12pt,
    weight: "bold",
  )

  show heading.where(level: 2): set text(
    font: "Libertinus Sans",
    size: 11pt,
    weight: "bold"
  )

  show heading.where(level: 3): set text(
    font: "Libertinus Sans",
    size: 10pt,
    weight: "bold"
  )

  // Figure captions might use Biolinum too
  show figure.caption: set text(
    font: "Libertinus Sans",
    size: 9pt
  )

  show bibliography: set text(size: 8pt)

  set heading(numbering: "1.1")

  // Title row.
  align(center)[
    #block(text(weight: 700, 1.75em, title), below: 0em) \
    #block(text(weight: 400, 1.25em, subtitle), above: 0em)
  ]

  // Author information.
  pad(
    top: 0.5em,
    bottom: 0.5em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(2, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center)[
        #text([*#author.name*], size: 1.25em) \
        #author.affiliation \
        #author.postal \
        #author.email
      ]),
    ),
  )

  // Main body.
  set par(justify: true)
  show: columns.with(2, gutter: 1.3em)

  if abstract != [] {
    heading(outlined: false, numbering: none, text(0.85em, smallcaps[Abstract]))
    abstract
  }

  body
}

#let appendix(body) = {
  set heading(numbering: "A", supplement: [Appendix])
  counter(heading).update(0)
  body
}
