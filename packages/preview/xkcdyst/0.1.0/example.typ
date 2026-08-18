// ---------------------------------------------------------------------------
//  example.typ — a minimal starting point.
//  Compile:  typst compile example.typ --font-path fonts
// ---------------------------------------------------------------------------

#import "@preview/cetz:0.5.2"
#import cetz.draw: *
#import "xkcd-lib.typ": *

#set page(width: auto, height: auto, margin: 1cm, fill: white)
#set text(font: ("xkcd Script", "xkcd", "DejaVu Sans"), size: 11pt)

#cetz.canvas(length: 1cm, {
  // axes
  xkcd-line(((0, 0), (0, 4)), seed: 1, stroke: 1.2pt)
  xkcd-line(((0, 0), (6, 0)), seed: 2, stroke: 1.2pt)

  // a hand-drawn curve: y = 1.5 + sin(x)
  xkcd-plot(
    x => 1.5 + calc.sin(x * 1rad), 0.2, 5.8,
    samples: 80, seed: 3,
    stroke: (paint: pltblue, thickness: 1.2pt),
  )

  // shapes
  xkcd-rect((0.6, 2.6), (1.9, 3.6), seed: 4, stroke: 1pt, fill: yellow.lighten(50%))
  xkcd-circle((4.6, 2.9), 0.6, seed: 5, stroke: 1pt, fill: red.lighten(60%))
  xkcd-arc((3, 3.2), 0.8, 20, 160, seed: 6, stroke: (paint: green.darken(20%), thickness: 1.2pt))

  // labels
  content((1.25, 3.1), text(size: 0.9em)[box])
  content((4.6, 2.9), text(size: 0.9em)[blob])
  content((3, -0.45), [x])
})
