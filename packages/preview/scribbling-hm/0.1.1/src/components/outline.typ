#let outline-page() = {
  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): set text(weight: "bold")
  show outline.entry.where(level: 1): set block(above: 16pt)

  outline(
    depth: 3,
    indent: auto
  )

  pagebreak()
}