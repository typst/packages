#import "@preview/cetz:0.4.2": draw
#let label(pos, text, color, justify: "center") = {
  import draw: *
  content(
    pos,
    box(
      fill: white,
      inset: 4.5pt,
      stroke: color,
      text,
    ),
    anchor: justify,
  )
}
