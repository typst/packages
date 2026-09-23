
#let var = (
  // Layout
  abstract-width: 5.56in,
  title-descent: 0.3in,
  first-header-dy: -0.07in,
  rule-dy: 0.08in,
  first-rule-dy: 0in,
  // Colors
  text-color: rgb("#202020"),
  link-color: rgb("#2E3092"),
  // Font sizes
  abstract-font-size: 9.5pt,
  doi-font-size: 8.5pt,
  first-header-font-size: 12pt,
  header-font-size: 10.5pt,
  footer-font-size: 10.5pt,
  footnote-font-size: 9.3pt,
  // Spacings
  title-spacing: 16.5pt,
  affiliation-spacing: 6.5pt,
  date-spacing: 8pt,
  abstract-spacing: 7pt,
  abstract-leading: 5.8pt,
  frontmatter-spacing: 13pt,
)

#let layout(
  var: var,
  content,
) = {
  // Page layout
  // ***********

  set page(
    paper: "us-letter",
    margin: (
      x: 0.72in,
      top: 0.7in,
      bottom: 1.07in,
    ),
    header-ascent: 0.25in,
    footer-descent: 0.5in,
    columns: 2,
  )

  set columns(gutter: 0.25in)


  // Typography
  // **********

  set text(
    font: "TeX Gyre Termes",
    size: 10.5pt,
    fill: var.text-color,
    //tracking: 0.1pt, // LaTeX look
    overhang: false,
  )

  set par(
    spacing: 0.6em,
    leading: 0.5em,
    linebreaks: "optimized",
    justification-limits: (
      spacing: (min: 67%, max: 130%),
      tracking: (min: -0.015em, max: 0.02em),
    ),
    first-line-indent: (amount: 1em, all: false),
    justify: true,
  )

  // force indent on first paragraph of section
  show heading: it => { it + h(0pt) }


  // Headings
  // ********

  show title: set text(size: 12.5pt, weight: "bold", tracking: 0.1pt, spacing: 100% + 0.1pt)
  show title: set par(leading: 0.4em)

  show heading: set text(
    size: 10.5pt,
    weight: "bold",
    style: "normal",
    hyphenate: false,
  )
  show heading: set align(center)
  show heading.where(level: 1): upper
  show heading.where(level: 1): set heading(numbering: "I.")
  show heading.where(level: 2): set heading(numbering: (..n, i) => numbering("A.", i))
  show heading.where(level: 3): set heading(numbering: (..n, i) => numbering("1.", i))


  // Figures, tables and equations
  // *****************************

  show figure: set figure(supplement: "FIG.")
  set figure.caption(separator: ". ")
  show figure.caption: set text(size: 9.5pt)

  show figure.where(kind: table): set figure(supplement: "TABLE", numbering: "I")
  show figure.where(kind: table): set figure.caption(position: top)

  set math.equation(numbering: "(1)")


  // References
  // **********

  set ref(supplement: it => {
    if it.func() == figure and it.kind == image {
      "Fig."
    } else if it.func() == figure and it.kind == table {
      "Table"
    } else if it.func() == math.equation {
      "Eq."
    } else if it.func() == heading {
      "Sec."
    } else {
      it.supplement
    }
  })
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      show regex("\d+"): it => text(fill: var.link-color, "(" + it + ")")
      it
    } else {
      it
    }
  }
  show ref: it => {
    show regex(`\b(\d+|[IVXL]+|[A-Z])\b`.text): set text(fill: var.link-color)
    it
  }
  show link: set text(fill: var.link-color)
  show cite: set text(fill: var.link-color)


  // Bibliography
  // ************

  show bibliography: set text(size: 9.5pt)
  show bibliography: set par(leading: 0.5em, spacing: 0.5em)


  content
}
