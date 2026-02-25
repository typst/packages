#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: *
  color-code-2d(
    (0, 0),
    tiling: "4.6.12",
    shape: "rect",
    size: (rows: 6, cols: 6),
    scale: 0.6,
    color1: yellow,
    color2: aqua,
    color3: olive,
    show-qubits: true,
    qubit-radius: 0.2,
  )
})
