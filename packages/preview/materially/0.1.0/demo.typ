#import "@preview/materially:0.1.0" as materially

#set page(
  width: 109pt,
  height: 38pt,
  margin: 5pt
  // flipped: true, // Landscape
)

#let symbol = materially.init()

#let admonition-type(it) = {
  text(.8em, weight: 700, font:("Roboto", "Helvetica", "Arial"), it)
}
#grid(
  columns: (auto, 1fr),
  column-gutter: 5pt,

  grid.cell(inset: (right: 5pt), stroke: (right:.5pt),
    text(1.5em, symbol("info"))
  ),
  {
    [
      #admonition-type[NOTE]

      You are special!
    ]
  }
)
