#import "@preview/ctz-euclide:0.1.5": *

#set page(width: auto, height: auto, margin: 0.3cm)

#ctz-canvas(length: 0.7cm, clip-canvas: (-4, -4, 6, 10), {
  import cetz.draw: *
  ctz-init()

  // Inversion parameters
  let O = (-4, 0)
  let R = 3
  let n = 6

  // Two vertical lines and their inversions
  ctz-def-line("l1", (-1, 0), (-1, 1))
  ctz-def-line("l2", (1, 0), (1, 1))
  ctz-def-inversion("l1i", "l1", O, R)
  ctz-def-inversion("l2i", "l2", O, R)

  // Draw infinite lines (clipped)
  ctz-draw-line-add((-1, 0), (-1, 1), add: (10, 10), stroke: blue + 0.4pt)
  ctz-draw-line-add((1, 0), (1, 1), add: (10, 10), stroke: green + 0.4pt)
  ctz-draw("l1i", stroke: blue + 0.4pt)
  ctz-draw("l2i", stroke: green + 0.4pt)

  for i in range(0, n + 1) {
    let cname = "C" + str(i)
    let cpname = "Cp" + str(i)
    ctz-def-circle(cname, (0, 2 * i), radius: 1)
    ctz-def-inversion(cpname, cname, O, R)
    ctz-draw(cpname, stroke: red + 0.4pt)

    if calc.abs(i) < 4 {
      ctz-draw(cname, stroke: red + 0.4pt)

      ctz-def-points(P1: (1, 2 * i), P2: (-1, 2 * i))
      ctz-def-inversion("P1i", "P1", O, R)
      ctz-def-inversion("P2i", "P2", O, R)

      ctz-draw(segment: ("P1", "P1i"), stroke: green + 0.4pt)
      ctz-draw(segment: ("P2", "P2i"), stroke: blue + 0.4pt)
    }
  }
})
