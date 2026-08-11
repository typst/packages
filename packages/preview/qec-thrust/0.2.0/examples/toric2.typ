#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 5pt)

#canvas({
  import draw: *
  let code = toric-code((0, 0), 7, 7, size: 1)
  (code.draw-background)()
  (code.highlight-plaquette)(
    (1, 4),
    selected-qubits: (
      ("vertical", 1, 4),
      ("vertical", 1, 5),
      ("horizontal", 2, 4),
      ("horizontal", 1, 4),
      ("vertical", 4, 5),
      ("vertical", 5, 5),
      ("horizontal", 1, 0),
      ("horizontal", 1, 1),
    ),
  )
  (code.highlight-vertex)(
    (6, 1),
    selected-qubits: (
      ("vertical", 5, 1),
      ("vertical", 6, 1),
      ("horizontal", 6, 1),
      ("horizontal", 6, 0),
      ("vertical", 6, 5),
      ("vertical", 6, 4),
      ("horizontal", 2, 0),
      ("horizontal", 3, 0),
    ),
  )
  stabilizer-label((10, -3))
})
