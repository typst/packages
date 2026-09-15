// ===========================================================================
//  faboxyst — SVG motifs with `image-motif`.
//
//    typst compile examples/image-motif.typ --root .
//
//  The three SVGs in assets/ come from the fancy-frames package
//  (Daniel Ayala, MIT-0 — no attribution required). They only serve to
//  demonstrate `image-motif`: delete assets/ and this file and nothing
//  else in the package breaks.
//
//  `image-motif` reads the SVG markup as text and recolours it to the
//  box's palette: black becomes the ink, white the paper; grey shades
//  stay. The aspect comes from the viewBox.
// ===========================================================================

#import "@preview/faboxyst:0.2.0": *

#set page(width: 17cm, height: auto, margin: 9mm, fill: white)
#set text(font: ("Libertinus Serif", "DejaVu Serif"), size: 10.5pt)
#set par(leading: 0.62em)

#let corner-svg = read("assets/corner5.svg")
#let edge-svg = read("assets/repetition2.svg")
#let centre-svg = read("assets/center12.svg")

= One SVG, three palettes

The same two files, recoloured by `colour` / `gold` alone — no editing,
no second asset.

#grid(columns: 3, column-gutter: 4mm,
  ..((rgb("#1F3A68"), rgb("#C9A24E")),
     (rgb("#7A1F2B"), rgb("#D8B15A")),
     (rgb("#1E5C4A"), rgb("#B8863B"))).map(pair =>
    ornatebox(
      title: none,
      colour: pair.at(0), gold: pair.at(1),
      edge: image-motif(edge-svg), edge-sides: ("start", "end"),
      edge-size: 0.38cm, edge-gap: 0.45cm,
      corner: image-motif(corner-svg, corner: "tr"), corner-size: 0.9cm,
      corner-shift: (-0.08cm, -0.08cm),
      centre: none,
      rules: ((0.8pt, "ink"),),
      inset: (x: 0.55cm, y: 0.4cm),
    )[#lorem(10)]))

#v(5mm)

= A wide centre piece

`center12.svg` is a long horizontal divider (aspect ≈ 4.7 : 1); as a
`centre` motif it masks the bottom rule and hangs over it.

#ornatebox(
  title: [Leçon 1 — Les nombres complexes],
  colour: rgb("#5C3A1E"), gold: rgb("#B08D45"),
  edge: image-motif(edge-svg), edge-sides: ("start", "end"),
  edge-size: 0.38cm, edge-gap: 0.5cm,
  corner: image-motif(corner-svg, corner: "tr"), corner-size: 1.1cm,
  corner-shift: (-0.1cm, -0.1cm),
  centre: (bottom: image-motif(centre-svg)),
  centre-size: 0.45cm,
  caps: ("flat", "flat"), sash-inset: (1.5cm, 1.5cm),
  inset: (x: 0.7cm, y: 0.5cm),
)[#lorem(24)]

#v(5mm)

= Ink and paper, motif by motif

`ink:` and `paper:` take a colour or a function of the palette — here the
corner draws in gold while the rest stays navy.

#ornatebox(
  title: [Recoloured piecewise],
  colour: rgb("#1F3A68"), gold: rgb("#C9A24E"),
  edge: image-motif(edge-svg), edge-sides: ("start", "end"),
  edge-size: 0.38cm, edge-gap: 0.5cm,
  corner: image-motif(corner-svg, corner: "tr", ink: pal => pal.gold),
  corner-size: 0.9cm, corner-shift: (-0.08cm, -0.08cm),
  centre: none,
  inset: (x: 0.6cm, y: 0.42cm),
)[#lorem(14)]
