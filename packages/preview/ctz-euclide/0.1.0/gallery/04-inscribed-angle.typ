#import "@preview/ctz-euclide:0.1.0": *

#set page(width: auto, height: auto, margin: 0.3cm)

#ctz-canvas(length: 1cm, {
  import cetz.draw: *

  ctz-init()
  ctz-style(point: (shape: "cross", size: 0.11, stroke: black + 1.2pt))

  ctz-def-points(O: (0, 0), R: (4, 0))
  ctz-def-circle("C1", "O", through: "R")
  ctz-draw("C1", stroke: black + 1.2pt)
  ctz-label-circle("C1", $C_1$, pos: "above right", dist: 0.2)

  // Place points on circle: A left, C right, B at bottom
  ctz-def-rotation("A", "R", "O", 150)
  ctz-def-rotation("C", "R", "O", 30)
  ctz-def-rotation("B", "R", "O", 250)

  // Inscribed angle at B (looking up at chord AC)
  ctz-draw(segment: ("A", "B"), stroke: blue + 1.2pt)
  ctz-draw(segment: ("B", "C"), stroke: blue + 1.2pt)
  ctz-draw-angle(
    "B",
    "A",
    "C",
    label: $alpha$,
    radius: 0.8,
    fill: blue.lighten(70%),
    stroke: blue,
  )

  // Central angle at O (same chord AC)
  ctz-draw(segment: ("O", "A"), stroke: red + 1.2pt)
  ctz-draw(segment: ("O", "C"), stroke: red + 1.2pt)
  ctz-draw-angle(
    "O",
    "A",
    "C",
    label: $2alpha$,
    radius: 1.2,
    fill: red.lighten(70%),
    stroke: red,
  )

  // Arc
  ctz-draw(segment: ("A", "C"), stroke: gray.lighten(40%) + 0.8pt)

  ctz-draw(points: ("O", "A", "B", "C"), labels: (
    
    O: (pos: "below", offset: (0, -0.15)),
    A: "left",
    B: "below left",
    C: "right",
  ))
})
