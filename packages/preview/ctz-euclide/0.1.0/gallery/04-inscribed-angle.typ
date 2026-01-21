#import "@preview/ctz-euclide:0.1.0": *
#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.3cm)

#cetz.canvas(length: 1cm, {
  import cetz.draw: *

  let ctz = create-api(cetz)

  (ctz.init)()
  (ctz.style)(point: (shape: "cross", size: 0.11, stroke: black + 1.2pt))

  (ctz.pts)(O: (0, 0), R: (4, 0))
  circle("O", radius: 4, stroke: black + 1.2pt)

  // Place points on circle: A left, C right, B at bottom
  (ctz.rotate)("A", "R", "O", 150)
  (ctz.rotate)("C", "R", "O", 30)
  (ctz.rotate)("B", "R", "O", 250)

  // Inscribed angle at B (looking up at chord AC)
  line("A", "B", stroke: blue + 1.2pt)
  line("B", "C", stroke: blue + 1.2pt)
  (ctz.angle)(
    "B",
    "A",
    "C",
    label: $alpha$,
    radius: 0.8,
    fill: blue.lighten(70%),
    stroke: blue,
  )

  // Central angle at O (same chord AC)
  line("O", "A", stroke: red + 1.2pt)
  line("O", "C", stroke: red + 1.2pt)
  (ctz.angle)(
    "O",
    "A",
    "C",
    label: $2alpha$,
    radius: 1.2,
    fill: red.lighten(70%),
    stroke: red,
  )

  // Arc
  line("A", "C", stroke: gray.lighten(40%) + 0.8pt)

  (ctz.points)("O", "A", "B", "C")
  (ctz.labels)(
    "O",
    "A",
    "B",
    "C",
    O: (pos: "below", offset: (0, -0.15)),
    A: "left",
    B: "below left",
    C: "right",
  )
})
