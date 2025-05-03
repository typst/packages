#let outline_page() = {
  // TODO Needed, because context creates empty pages with wrong numbering
  set page(
    numbering: "i",
  )

  set outline.entry(fill: grid(
    columns: 2,
    gutter: 0pt,
    repeat[~.],
    h(11pt),
  ))

  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): set text(weight: "bold")
  show outline.entry.where(level: 1): set block(above: 16pt)
  
  outline(
    depth: 3,
    indent: auto,
  )
}
