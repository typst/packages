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
    columns: (1fr, 1fr, 1fr),
    rows: 2,
    align: center + top,
    row-gutter: 12pt,
    column-gutter: 14pt,
    squircle(width: 85pt, height: 55pt, radius: 20pt, fill: aqua),
    squircle(
      width: 85pt,
      height: 55pt,
      radius: 20pt,
      smoothing: 100%,
      fill: aqua,
    ),
    squircle(
      width: 85pt,
      height: 55pt,
      radius: 20pt,
      smoothing: 100%,
      preserve-smoothing: true,
      fill: aqua,
    ),

    [smoothing: 60%],
    [smoothing: 100%],
    [
      smoothing: 100% #linebreak()
      preserve-smoothing: true
    ],
  )
]
