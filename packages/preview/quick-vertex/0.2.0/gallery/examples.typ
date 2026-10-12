// Source for the README gallery images. Render with:
//   typst compile --root . --format png --ppi 150 gallery/examples.typ gallery/g{p}.png
#import "../lib.typ": feasible-region
#set page(width: auto, height: auto, margin: 8pt, fill: white)

// g1 — bounded region, unique optimum; level lines and the max Z arrow
#feasible-region(
  ((1, 1, 4, "<="), (1, 3, 6, "<=")),
  objective: (3, 4), sense: "max",
  labels: ($x + y = 4$, $x + 3y = 6$),
)
#pagebreak()

// g2 — unbounded region, finite minimum; level lines and the min Z arrow
#feasible-region(
  ((1, 1, 4, ">="), (1, 0, 1, ">=")),
  objective: (2, 3), sense: "min",
)
#pagebreak()

// g3 — multiple optima (whole segment)
#feasible-region(
  ((1, 1, 4, "<="), (1, 0, 3, "<=")),
  objective: (1, 1), sense: "max",
)
#pagebreak()

// g4 — any quadrant (first-quadrant: false)
#feasible-region(
  ((1, 0, 3, "<="), (1, 0, -2, ">="), (0, 1, 2, "<="), (0, 1, -1, ">="), (1, 1, 3, "<=")),
  objective: (1, 2), sense: "max", first-quadrant: false,
)
