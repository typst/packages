#{
  // repeat points between page number and header
  set outline.entry(fill: grid(
    columns: 2,
    gutter: 0pt,
    repeat[~.], h(11pt),
  ))

  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): set text(weight: "bold")
  show outline.entry.where(level: 1): set block(above: 16pt)

  // only put headers up to X.X.X in the TOG
  outline(
    depth: 3,
  )
}
