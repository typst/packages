#import "@preview/unify:0.8.1": qty, num
#import "@preview/cetz:0.5.3": canvas, draw, decorations
#import "@preview/tudelft-thesis-novanext:0.1.0": *

#show: standalone.with(preamble: it => {
  set page(
    height: auto,
    width: auto,
    margin: 0pt,
  )
  show: set-fonts
  it
})

#canvas({
  import draw: *
  line((-2, 2.5), (2, 2.5));
  for c in range(-18, 18, step: 3) {
    line((c/10, 2.5), (c/10+.3, 2.5+.3))
  }
  for c in (-1, 1) {
    decorations.coil(line((c, 2.5), (c, 1)),
    amplitude: .7, start:15%, stop: 85%, segments: 5, factor: 125%)
    content((c - 0.7, 1.7), [$k$])
  }
  content((-1.6, -0.4), (1.6, 1),
    box(align(center + horizon)[#qty(100, "kg")], fill: yellow, stroke: (paint: orange, thickness: 2pt, join: "round"),width: 100%,height: 100%,inset: 1em))
})


