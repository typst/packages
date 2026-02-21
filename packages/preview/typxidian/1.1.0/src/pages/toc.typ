#set outline.entry(
  fill: grid(
    columns: 2,
    gutter: 0pt,
    repeat[#h(5pt).], h(11pt),
  ),
)

#show outline.entry: set text(size: 11pt)
#show outline.entry: set block(above: 10pt)

#{
  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): set text(weight: "semibold", size: 11pt)
  show outline.entry.where(level: 1): set block(above: 24pt)
  heading(level: 1, "Table of Contents", numbering: none, supplement: "toc")
  outline(depth: 3, indent: auto, title: none, target: heading)
}

// dynamic LOF, LOT, LOD, displayed only if necessary
#let dynamic-list-off(title, kind) = context {
  if query(figure.where(kind: kind)).len() > 0 {
    heading(title, level: 1, numbering: none)
    outline(title: none, indent: auto, target: figure.where(kind: kind))
  }
}

#dynamic-list-off("List of Figures", image)
#dynamic-list-off("List of Tables", table)
#dynamic-list-off("List of Definitions", "definition")
#dynamic-list-off("List of Theorems", "theorem")
