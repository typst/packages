// APA heading hierarchy. Levels 4 and 5 are provided explicitly as run-in helpers.
#let with-headings(
  body,
  font-size: 10pt,
  heading-leading: 1em,
  heading-spacing: 1em,
) = {
  set heading(numbering: none)
  show heading: set block(above: heading-spacing, below: heading-spacing)
  show heading: set par(
    first-line-indent: 0pt,
    leading: heading-leading,
    spacing: heading-spacing,
  )

  show heading.where(level: 1): set align(center)
  show heading.where(level: 1): set text(weight: "bold", size: font-size)

  show heading.where(level: 2): set align(left)
  show heading.where(level: 2): set text(weight: "bold", size: font-size)

  show heading.where(level: 3): set align(left)
  show heading.where(level: 3): set text(
    weight: "bold",
    style: "italic",
    size: font-size,
  )

  // Document title is a semantic Typst title element, distinct from headings.
  show title: set align(center)
  show title: set text(weight: "bold", size: font-size)

  // Use apa-run-in-heading(title, paragraph) for exact run-in levels 4 and 5.
  body
}
