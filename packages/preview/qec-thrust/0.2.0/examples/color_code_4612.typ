#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  let code = color-code-2d(
    (0, 0),
    tiling: "4.6.12",
    shape: "rect",
    size: (rows: 6, cols: 6),
    scale: 0.6,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-4612",
    show-qubits: true,
    qubit-radius: 0.2,
  )
  (code.draw-background)()
  (code.highlight-face)("dod-2-2", stroke: (paint: red, thickness: 1pt))
})
