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
  #block(width: 100% * 2 / 3)[
    #grid(
      columns: (1fr, 1fr),
      rows: 2,
      align: center + top,
      row-gutter: 12pt,
      column-gutter: 14pt,
      rect(
        width: 90pt,
        height: 60pt,
        radius: (top-left: 50%),
        fill: aqua,
      ),
      squircle(
        width: 90pt,
        height: 60pt,
        radius: (top-left: 50%),
        smoothing: 100%,
        fill: aqua,
      ),

      text[Rounded rectangle], text[Squircle],
    )
  ]
]
