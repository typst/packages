#import "@preview/ctz-euclide:0.1.5": *

#set page(width: auto, height: auto, margin: 0.3cm, fill: rgb(95%, 95%, 80%))

#ctz-canvas(length: 8cm, {
  import cetz.draw: *
  ctz-init()

  let n = 24

  // Inversion circle setup
  ctz-def-points(O: (-4.5, 0))
  ctz-def-line("l1", (-1, 0), (-1, 1))
  ctz-def-line("l2", (1, 0), (1, 1))

  ctz-def-inversion("l1i", "l1", "O", 1)
  ctz-def-inversion("l2i", "l2", "O", 1)

  // Draw inverted lines (outer boundary)
    ctz-draw("l1i", stroke: black + 0.5pt)
    ctz-draw("l2i", stroke: black + 0.5pt)

  // Invert a stack of circles to create the packing
  for i in range(-n, n + 1) {
    let name = "c" + str(i)
    let invname = "ci" + str(i)
    ctz-def-circle(name, (0, 2 * i), radius: 1)
    ctz-def-inversion(invname, name, "O", 1)

    ctz-draw(invname, fill: yellow, stroke: red + 0.4pt)
  }
})
