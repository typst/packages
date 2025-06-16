#import "../lib.typ": *
#import "@preview/cetz:0.2.1"

#set page(width: auto, height: auto, margin: 0.5cm)

#cetz.canvas(length: 6pt, {
  import cetz.draw: *

  let n = 2000
  let (cx, cy) = (0, 0)
  let (cx-new, cy-new) = (0, 0)
  let rng = gen-rng(42)
  let v = 0
  let col = blue
  for i in range(n) {
    (rng, v) = uniform(rng, low: -1.0, high: 1.0)
    cx-new = cx + v
    (rng, v) = uniform(rng, low: -1.0, high: 1.0)
    cy-new = cy + v
    col = color.mix((blue.transparentize(20%), 1-i/n), (green.transparentize(20%), i/n))
    line(stroke: (paint: col, cap: "round", thickness: 1.5pt),
      (cx, cy), (cx-new, cy-new)
    )
    (cx, cy) = (cx-new, cy-new)
  }
})
