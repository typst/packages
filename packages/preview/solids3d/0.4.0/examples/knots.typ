// Nœuds et entrelacs tubulaires : knot3 (nibart). Compiler : typst compile examples/knots.typ
#import "@preview/solids3d:0.4.0": *

#set page(width: 21cm, height: auto, margin: 1cm, fill: rgb("#f4edda"))
#set text(lang: "fr", size: 9pt)

#let L = light((-1, 0.9, 1))
#let S = 4.6cm
#let fig(name, body) = figure(body, caption: name)

#grid(columns: 3, row-gutter: 8pt,
  fig("Trèfle (gap)", picture(size: S, projection: orthographic(3, 2, 4), light: L,
    knot3(trefoil(), width: 10pt))),
  fig("Nœud de huit (weave)", picture(size: S, projection: orthographic(2, 1, 3), light: L,
    knot3(figure-eight(), width: 8pt, samples: 140, style: "weave", colors: (rgb("#b03a2e"),)))),
  fig([Nœud torique $T(3,5)$], picture(size: S, projection: orthographic(1, 1, 5), light: L,
    knot3(torus-knot(3, 5, R: 2, r: 0.8), width: 6pt, samples: 200, style: "weave", colors: (rgb("#3a5ca8"),)))),
  fig("Entrelacs de Hopf", picture(size: S, projection: orthographic(2, 1, 3), light: L,
    knot3(..hopf-link(R: 1.4), width: 9pt, style: "weave"))),
  fig("Anneaux de Borromée", picture(size: S, projection: orthographic(1, 1, 1), light: L,
    knot3(..borromean(a: 2, b: 1.25), width: 7pt, style: "weave"))),
  fig("Trèfle gravé", picture(size: S, projection: orthographic(3, 2, 4), style: "engraving", light: L,
    knot3(trefoil(), width: 10pt, style: "weave"))),
)
