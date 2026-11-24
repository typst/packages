// Additional README examples, also runnable as standalone downloaded files.
// typst compile --root . gallery/additional.typ gallery/additional.pdf
#import "@preview/quick-vertex:0.2.0": feasible-region, analyze
#set page(width: auto, height: auto, margin: 8pt, fill: white)

// Level lines remain visible when the direction arrow is hidden.
#feasible-region(
  ((1, 1, 4, "<="), (1, 3, 6, "<=")),
  objective: (3, 4), gradient: false,
)
#pagebreak()

// An unattained supremum, with Spanish labels.
#feasible-region(
  ((1, 1, 4, "<"),),
  objective: (1, 1), sense: "max", lang: "es",
)

// The corresponding pure analysis is independent of CeTZ drawing.
#let result = analyze(((1, 1, 4, "<"),), objective: (1, 1))
#assert.eq(result.status, "unattained")
#assert(calc.abs(result.value - 4) < 1e-8)
