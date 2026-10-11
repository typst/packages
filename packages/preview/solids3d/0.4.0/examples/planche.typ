// Planche gravée — solids3d 0.2 : surfaces gravées au burin, nœuds en 3D, accolades calligraphiques et cartouche (nibart).
// Compiler : typst compile examples/planche.typ     (après ./install.sh)
#import "@preview/solids3d:0.4.0": *

#set page(paper: "a4", margin: 1.1cm, fill: rgb("#e9dfc7"))
#set text(lang: "fr")

#let S = 5.3cm
#let L = light((-1, 0.9, 1.1))
#let P = orthographic(4, -3, 2.5)
#let wavy = engraving(wave: (amplitude: 0.45pt, length: 11pt, shift: 0.35), angle: 20, spacing: 2.4pt)
#let fig(n, name, body) = block(breakable: false, {
  block(height: S, width: 100%, align(center + horizon, body))
  v(-2pt)
  align(center, text(size: 9pt, style: "italic")[Fig. #n — #name])
})

#plate(title: "Solides & nœuds", subtitle: [gravés à la plume avec #raw("solids3d") et #raw("nibart")], number: "I",
  caption: [Surfaces hachurées à la manière d’un billet de banque, nœuds tubulaires et cotes calligraphiques.],
  width: 100% - 0pt,
  grid(columns: (1fr, 1fr, 1fr), row-gutter: 10pt,
    fig(1, "La sphère", picture(size: S, projection: P, style: "engraving", engraving: wavy, light: L,
      engraved(sphere((0, 0, 0), 1)),
      brace3((0, 0, -1), (0, 0, 1), offset: (-0.88, -1.17, 0), label: $2 r$))),
    fig(2, "Le tore", picture(size: S, projection: orthographic(5, 4, 3), style: "engraving", engraving: wavy, light: L,
      engraved(torus(1, 0.38)))),
    fig(3, "Le cône", picture(size: S, projection: P, style: "engraving", light: L,
      engraved(cone((0, 0, 0), 1, 1.7, Z, 1), edges: linewidth(0.4)),
      brace3((0, 0, 0), (0, 0, 1.7), offset: (-0.78, -1.04, 0), label: $h$))),
    fig(4, "Le trèfle", picture(size: S, projection: orthographic(3, 2, 4), style: "engraving", light: L,
      knot3(trefoil(), width: 10pt, style: "weave"))),
    fig(5, "Les anneaux de Borromée", picture(size: S, projection: orthographic(1, 1, 1), light: L,
      knot3(..borromean(a: 2, b: 1.25), width: 7pt, samples: 120, style: "weave"))),
    fig(6, [Le nœud $T(2,5)$], picture(size: S, projection: orthographic(1, 1, 5), light: L,
      knot3(torus-knot(2, 5, R: 2, r: 0.8), width: 8pt, samples: 160, style: "weave", colors: (rgb("#2e7d5b"),)))),
    fig(7, "Le cylindre", picture(size: S, projection: P, style: "engraving", engraving: wavy, light: L,
      engraved(cylinder((0, 0, 0), 0.8, 1.6, Z, 1), edges: linewidth(0.4)),
      brace3((0, 0, 0), (0, 0, 1.6), offset: (-0.9, -1.2, 0), label: $h$))),
    fig(8, "Le nœud de huit", picture(size: S, projection: orthographic(2, 1, 3), light: L,
      knot3(figure-eight(), width: 8pt, samples: 140, style: "weave", colors: (rgb("#b03a2e"),)))),
    fig(9, "L’entrelacs de Hopf", picture(size: S, projection: orthographic(2, 1, 3), style: "engraving", light: L,
      knot3(..hopf-link(R: 1.4), width: 10pt, samples: 100, style: "weave"))),
  ))
