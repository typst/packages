#import "@preview/cetz:0.4.0": canvas
#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 5pt)

#let patch-488(name, orientation: "flat") = canvas({
  let code = color-code-2d(
    (0, 0),
    tiling: "4.8.8",
    shape: "rect",
    size: (rows: 3, cols: 5),
    orientation: orientation,
    scale: 0.72,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: name,
    show-qubits: false,
  )
  (code.draw-background)()
})

#grid(
  columns: 2,
  gutter: 10pt,
  [#patch-488("color-488-flat", orientation: "flat")],
  [#patch-488("color-488-pointy", orientation: "pointy")],
)
