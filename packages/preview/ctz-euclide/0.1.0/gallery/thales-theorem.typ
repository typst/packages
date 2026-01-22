#import "@preview/ctz-euclide:0.1.0": *

#set page(width: auto, height: auto, margin: 0.3cm)

#ctz-canvas({
  import cetz.draw: *

  ctz-init()
  ctz-style(point: (shape: "cross", size: 0.1, stroke: black + 1.5pt))

  // Circle with diameter
  ctz-def-points("O", (0, 0), "A", (-3, 0), "B", (3, 0))
  ctz-def-circle("C1", "O", radius: 3)
  ctz-def-line("L1", "A", "B")

  // Point on circle
  ctz-def-point-on-circle("C", "O", 3, 110)

  // Draw circle
  ctz-draw-circle("C1", stroke: gray + 0.8pt)

  // Draw diameter
  ctz-draw-line("L1", stroke: blue + 1.2pt)

  // Draw triangle (angle at C is right angle by Thales' theorem)
  ctz-draw-line("A", "C", "B", "A", stroke: black + 1.2pt)

  // Mark the right angle at C
  ctz-draw-mark-right-angle("A", "C", "B", size: 0.4)

  // Draw altitude from C to AB
  ctz-def-project("H", "C", "A", "B")
  ctz-draw-line("C", "H", stroke: (paint: green, thickness: 0.8pt, dash: "dashed"))

  // Mark points
  ctz-draw-points("A", "B", "C", "O", "H")

  // Labels
  ctz-draw-labels("A", "B", "C", "O", "H",
    A: "left", B: "right", C: "above", O: "below", H: "below")
})
