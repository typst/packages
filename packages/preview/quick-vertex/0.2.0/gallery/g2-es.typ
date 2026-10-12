// Spanish preview: level lines and direction toward a finite minimum.
// typst compile --root . --format png --ppi 150 gallery/g2-es.typ gallery/g2-es.png
#import "../lib.typ": feasible-region
#set page(width: auto, height: auto, margin: 8pt, fill: white)
#feasible-region(
  ((1, 1, 4, ">="), (1, 0, 1, ">=")),
  objective: (2, 3), sense: "min", lang: "es",
)
