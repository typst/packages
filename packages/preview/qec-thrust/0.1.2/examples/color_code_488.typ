#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: *
  color-code-2d(
    (0, 0),
    tiling: "4.8.8",
    shape: "rect",
    size: (rows: 4, cols: 4),
    scale: 0.8,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-488",
    show-qubits: true,
    qubit-radius: 0.1,
  )
})
