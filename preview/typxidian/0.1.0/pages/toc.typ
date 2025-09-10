#{
  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry: set text(size: 13pt)
  show outline.entry: set block(above: 12pt)
  show outline.entry.where(level: 1): set text(weight: "bold", size: 14pt)
  show outline.entry.where(level: 1): set block(above: 32pt)

  heading(level: 1, "Table of Contents")
  outline(depth: 3, indent: auto, title: none, target: heading)
}

#context {
  if query(figure.where(kind: image)).len() > 0 {
    heading(level: 1, "List of Figures")
    outline(target: figure.where(kind: image), title: none)
  }
}

#context {
  if query(figure.where(kind: table)).len() > 0 {
    heading(level: 1, "List of Tables")
    outline(target: figure.where(kind: table), title: none)
  }
}

#context {
  if query(figure.where(kind: "definitions")).len() > 0 {
    heading(level: 1, "List of Definitions")
    outline(target: figure.where(kind: "definitions"))
  }
}

#context {
  if query(figure.where(kind: "theorems")).len() > 0 {
    heading(level: 1, "List of Theorems")
    outline(target: figure.where(kind: "theorems"))
  }
}
