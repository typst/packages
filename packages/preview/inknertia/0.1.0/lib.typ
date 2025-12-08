#import "@preview/cetz:0.4.2"

// Export submodules
#import "feynman.typ"
#import "newtonian.typ"
#import "spacetime.typ"

// Vector math helpers
#let vec_sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let vec_add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let vec_scale(v, s) = (v.at(0) * s, v.at(1) * s)
#let vec_norm(v) = calc.sqrt(calc.pow(v.at(0), 2) + calc.pow(v.at(1), 2))
#let vec_rotate_90(v) = (-v.at(1), v.at(0)) // 90 degrees counter-clockwise

// Function to create a hatching pattern (used by feynman blobs)
#let hatch(angle: 45deg, spacing: 5pt, stroke: 0.5pt + black) = {
  let S = spacing * calc.sqrt(2)
  tiling(size: (S, S))[
    #place(line(start: (0%, 100%), end: (100%, 0%), stroke: stroke))
  ]
}
