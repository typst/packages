// Le style "engraving" : gravure au burin, trame droite, billet de banque (ondulée) et encre bleue.
// Compiler : typst compile examples/engraving.typ     (après ./install.sh)
#import "@preview/solids3d:0.4.0": *

#set page(width: 21cm, height: auto, margin: 1cm, fill: white)
#set text(lang: "fr", size: 9pt)

#let L = light((-1, 0.9, 1.1))
#let P = orthographic(5, 4, 3)
#let scene(spec, ..opts) = picture(size: 6.2cm, projection: P, style: "engraving", engraving: spec, light: L, ..opts,
  engraved(sphere((1.6, 0, 0.6), 0.6)),
  engraved(torus(0.9, 0.3, c: (-0.6, 0.2, 0.3))),
  engraved(cone((0.4, 1.6, 0), 0.6, 1.4, Z, 1), edges: linewidth(0.6)),
  engraved(cylinder((-0.6, -1.4, 0), 0.5, 1.3, Z, 1)))

#grid(columns: 3, column-gutter: 6pt,
  figure(scene(engraving()), caption: [Trame droite (défaut)]),
  figure(scene(engraving(wave: (amplitude: 0.45pt, length: 11pt, shift: 0.35), angle: 20, spacing: 2.4pt)),
    caption: [Billet de banque : `wave`]),
  figure(scene(engraving(paper: white, ink: rgb("#1c3d7a"), angle: 55, spacing: 2.8pt, cross: false)),
    caption: [Encre bleue, sans trame croisée]),
)
