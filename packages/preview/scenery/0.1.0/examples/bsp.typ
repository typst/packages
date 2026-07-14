#import "/lib.typ": *

#set page(width: auto, height: auto, margin: 0.6cm)
#set text(font: "New Computer Modern", size: 10pt)

// Two interpenetrating translucent panes. The plain painter's sort (left) must
// pick ONE pane to paint entirely on top — wrong on one side of the crossing.
// The engine's BSP split (right) layers each half correctly.
#let panes = build-scene(
  face(((-1.5, -1, 0), (1.5, -1, 0), (1.5, 1, 0), (-1.5, 1, 0)),
    color: rgb("#4c72b0"), fill-opacity: 45%),
  face(((-1.5, 0, -1), (1.5, 0, -1), (1.5, 0, 1), (-1.5, 0, 1)),
    color: rgb("#dd8452"), fill-opacity: 45%),
)
#let v = camera(azimuth: 35deg, elevation: 20deg)
#grid(
  columns: 2, column-gutter: 1cm,
  align(center)[
    #render-scene(panes, v, width: 6cm)
    Painter's sort (`engine: "typst"`): mis-ordered
  ],
  align(center)[
    #render-scene(panes, v, engine: "wasm", width: 6cm)
    BSP split (`engine: "wasm"`): correct layering
  ],
)
