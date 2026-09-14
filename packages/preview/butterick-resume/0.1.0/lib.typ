#let two-grid(left: none, right: none) = {
  show grid.cell: set text(size: 14pt)
  show heading.where(level: 2): set text(size: 14pt)
  show grid: set block(below: 1em, above: 1.5em)
  grid(
    columns: (1fr, auto),
    heading(level: 2, left), right,
  )
}

#let template(
  body,
) = {
  set page(
    paper: "us-letter",
    margin: 1.5in,
  )

  set text(
    font: "Source Serif 4",
    lang: "en",
    region: "us",
    size: 10pt,
  )

  set par(
    spacing: 2em,
    leading: 1em,
  )

  set list(
    body-indent: 1.5em,
  )

  set enum(
    body-indent: 1em,
  )

  show heading.where(level: 1): set text(font: "Source Sans 3", weight: "bold")
  show heading.where(level: 1): set smallcaps(all: true)
  show heading.where(level: 1): smallcaps
  show heading.where(level: 1): set text(size: 9pt, tracking: 0.05em)
  show heading.where(level: 1): set block(
    below: 1em,
    above: 2.5em,
    width: 100%,
    stroke: (top: 0.5pt),
    inset: (top: 0.5em, rest: 0em),
  )

  show heading.where(level: 2): set text(font: "Source Serif 4", weight: "medium")

  body
}

#let introduction(name: none, details: none) = context {
  set document(
    title: name,
    author: if (type(name) == content) { name.text } else if (type(name) == string) { name } else { () },
    description: details,
  )
  set align(center)
  set par(justify: true, spacing: 1em)
  show text: upper
  set text(font: "Source Sans 3", tracking: 0.2em, hyphenate: false)
  show std.title: set text(font: "Source Sans 3", size: 18pt, weight: "medium", tracking: 0.2em)
  show std.title: set block(below: 0.75em)

  std.title()

  details
}
