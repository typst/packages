#import "../src/lib.typ": clothoid, squircle, superellipse

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
    columns: (1fr, 1fr, 1fr),
    rows: 2,
    align: center + top,
    row-gutter: 12pt,
    column-gutter: 14pt,
    squircle(
      width: 85pt,
      height: 55pt,
      radius: 20pt,
      smoothing: 100%,
      fill: aqua,
    ),
    superellipse(
      width: 85pt,
      height: 55pt,
      radius: 20pt,
      exponent: 5,
      fill: aqua,
    ),
    clothoid(
      width: 85pt,
      height: 55pt,
      radius: 20pt,
      smoothing: 100%,
      fill: aqua,
    ),

    [Squircle \ smoothing: 100%],
    [Superellipse \ exponent: 5],
    [Clothoid \ smoothing: 100%],
  )
]
