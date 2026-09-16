#import "@preview/cetz:0.4.0": canvas
#import "../lib.typ": *

#set page(width: auto, height: auto, margin: 5pt)

#let patch-666(shape, size, name, orientation: "flat", scale: 0.8) = canvas({
  let code = color-code-2d(
    (0, 0),
    tiling: "6.6.6",
    shape: shape,
    size: size,
    orientation: orientation,
    scale: scale,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: name,
    show-qubits: false,
  )
  (code.draw-background)()
})

#let cell(body) = box(width: 200pt, height: 200pt, inset: 4pt)[
  #align(center + horizon)[#body]
]

#grid(
  columns: 3,
  gutter: 10pt,
  [#cell[#patch-666("rect", (rows: 4, cols: 4), "color-666-rect-flat")]],
  [#cell[#patch-666("rect", (rows: 4, cols: 4), "color-666-rect-pointy", orientation: "pointy")]],
  [#cell[#patch-666("para", (rows: 4, cols: 4), "color-666-para", scale: 0.74)]],
  [#cell[#patch-666("tri", (n: 4), "color-666-tri", scale: 0.72)]],
  [#cell[#patch-666("tri-cut", (n: 3), "color-666-tri-cut")]],
  [#cell[#patch-666("hex", (lx: 3, ly: 3, lz: 3), "color-666-hex", scale: 0.6)]],
)
