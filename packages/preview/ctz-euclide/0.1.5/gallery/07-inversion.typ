#import "@preview/ctz-euclide:0.1.5": *

#set page(width: auto, height: auto, margin: 0.3cm)

#ctz-canvas(length: 0.7cm, clip-canvas: (-6, -5, 6, 6), {
  import cetz.draw: *
  ctz-init()

  // Inversion setup
  ctz-def-points(
    O: (0, 0),
    A: (-5, -1.5),
    B: (5, -1.5),
    C: (2, 1),
    D: (-2, 0),
  )

  ctz-def-line("l1", "A", "B")
  ctz-def-circle("c1", "C", radius: 1.2)
  ctz-def-circle("c2", "D", radius: 2)

  // Invert line and circles through circle centered at O
  ctz-def-inversion("l1i", "l1", "O", 3)
  ctz-def-inversion("c1i", "c1", "O", 3)
  ctz-def-inversion("c2i", "c2", "O", 3)

  // Inversion circle
  ctz-draw(circle-r: (_pt("O"), 3), stroke: black + 1pt)

  // Original objects (light)
  ctz-draw("l1", stroke: gray + 0.7pt)
  ctz-draw("c1", stroke: gray + 0.7pt)
  ctz-draw("c2", stroke: gray + 0.7pt)

  // Inverted objects (bold)
  ctz-draw("l1i", stroke: blue + 1.1pt)
  ctz-draw("c1i", stroke: red + 1.1pt)
  ctz-draw("c2i", stroke: green.darken(20%) + 1.1pt)

  ctz-draw(points: ("O"), labels: (O: "below left"))
})
