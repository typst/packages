#let impagina(content) = grid(
  columns: 2,
  inset: 12pt,
  content,
  grid.vline(stroke: (thickness: 0.1mm, dash: "dashed")),
  content
)
