#{
  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry: set text(size: 13pt)
  show outline.entry: set block(above: 12pt)
  show outline.entry.where(level: 1): set text(weight: "bold", size: 13pt)
  show outline.entry.where(level: 1): set block(above: 32pt)

  heading(level: 1, "Table of Contents")
  outline(depth: 3, indent: auto, title: none, target: heading)
}

#context {
  if query(figure.where(kind: image)).len() > 0 {
    set outline.entry(
      fill: grid(
          columns: 2,
          gutter: 0pt,
          repeat[~.], h(11pt),
    ))
    
    heading("List of Figures", level: 1)
    outline(
      title: none,
      indent: auto,
      target: figure.where(kind: image),
    )
  }
}

#context {
  if query(figure.where(kind: table)).len() > 0 { 
    set outline.entry(
          fill: grid(
              columns: 2,
              gutter: 0pt,
              repeat[~.], h(11pt),
        ))
    heading(level: 1, "List of Tables")
    outline(target: figure.where(kind: table), title: none, indent: auto)
  }
}

#context {
  if query(figure.where(kind: "definition")).len() > 0 { 
    heading(level: 1, "List of Definitions")
    outline(target: figure.where(kind: "definition"), title: none, indent: auto)
  }
}

#context {
  if query(figure.where(kind: "theorem")).len() > 0 {
    heading(level: 1, "List of Theorems")
    outline(target: figure.where(kind: "theorem"), title: none)
  }
}
