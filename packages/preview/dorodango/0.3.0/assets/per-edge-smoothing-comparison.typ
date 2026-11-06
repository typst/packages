#import "../src/lib.typ": squircle

#set page(width: 170mm, height: auto, margin: 8mm, fill: none)

#let theme = sys.inputs.at("theme", default: "light")
#set text(
  font: "Source Sans 3",
  size: 12.5pt,
  fill: if theme == "dark" {
    rgb("#f0f6fc")
  } else { rgb("#000000") },
)

#align(center + horizon)[
  #grid(
    columns: (1fr, 1fr),
    rows: 2,
    align: center + top,
    row-gutter: 12pt,
    column-gutter: 14pt,
    squircle(
      width: 160pt,
      height: 50pt,
      radius: 25pt,
      smoothing: 100%,
      fill: aqua,
    ),
    squircle(
      width: 160pt,
      height: 50pt,
      radius: 25pt,
      smoothing: 100%,
      per-edge-smoothing: true,
      fill: aqua,
    ),

    [per-edge-smoothing: false], [per-edge-smoothing: true],
  )
]
