#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: *
  let qubit-radius = 0.1
  color-code-2d(
    (0, 0),
    tiling: "6.6.6",
    shape: "rect",
    size: (rows: 4, cols: 4),
    hex-orientation: "flat",
    scale: 1.2,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-rect",
    show-qubits: true,
    qubit-radius: qubit-radius,
  )
  color-code-2d(
    (0, -9),
    tiling: "6.6.6",
    shape: "tri",
    size: (n: 4),
    hex-orientation: "pointy",
    scale: 1.2,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-tri",
    show-qubits: true,
    qubit-radius: qubit-radius,
  )
  color-code-2d(
    (9, 0),
    tiling: "6.6.6",
    shape: "para",
    size: (rows: 4, cols: 4),
    hex-orientation: "pointy",
    scale: 1.2,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-para",
    show-qubits: true,
    qubit-radius: qubit-radius,
  )
  color-code-2d(
    (9, -10),
    tiling: "6.6.6",
    shape: "tri-cut",
    size: (n: 3),
    hex-orientation: "flat",
    scale: 1.0,
    color1: yellow,
    color2: aqua,
    color3: olive,
    name: "color-tri-cut",
    show-qubits: true,
    qubit-radius: qubit-radius,
  )
})
