// ===========================================================================
//  faboxyst — ornate frames and the flag box, a tour.
//
//    typst compile examples/ornate.typ --root .
// ===========================================================================

#import "@preview/faboxyst:0.2.0": *

#set page(width: 17cm, height: auto, margin: 9mm, fill: white)
#set text(font: ("Libertinus Serif", "DejaVu Serif"), size: 10.5pt)
#set par(leading: 0.62em)

#let sample = [
  Consider the complex numbers $z_1 = 2 + i$ and $z_2 = 1 - 2i$.
  + Write $z_1 + z_2$, $z_1 z_2$ and $z_1 / z_2$ in algebraic form.
  + Compute $overline(z_1)$, $|z_1|$ and $|z_2|$.
]

= The presets

#khatambox(title: [Algebraic computation and conjugate], badge: [1], badge-label: [Exercise], sample)
#v(4mm)
#zellijbox(title: [Exercise 2 — Exponential form and roots], sample)
#v(4mm)
#arabesquebox(title: [Exercise 1 — Algebraic computation], sample)
#v(4mm)
#mihrabbox(title: [Exercise 1 — Algebraic computation], sample)
#v(4mm)
#fleuronbox(title: [Preface])[#lorem(28)]
#v(4mm)
#mosaicbox[
  #align(center)[#text(size: 1.5em, weight: "bold")[Complex numbers] #v(-0.4em) #text(fill: luma(90))[Chapter 4]]
]

= Your own recipe

Every knob of `ornatebox` is open on the presets, and `ornatebox` itself
takes any motif for the edges, the corners and the centres.

#ornatebox(
  title: [Roots of unity],
  colour: rgb("#7A1F2B"), gold: rgb("#D8B15A"),
  rules: ((0.9pt, "ink"), (0.4pt, "gold")),
  edge: "palmette", edge-sides: ("start", "end"),
  corner: (bottom: "scroll"), corner-size: 0.8cm, corner-shift: (-0.1cm, -0.1cm),
  centre: (bottom: "flourish"),
  caps: ("flat", "arch"), badge: [3], badge-label: [Ex.],
  sash-inset: (0cm, 0.9cm),
)[#lorem(30)]

#v(4mm)

// a motif of your own: a plain gold dot
#let dot = (aspect: (1, 1), draw: (s, pal) => box(width: s, height: s,
  circle(radius: s / 2, fill: pal.gold, stroke: 0.5pt + pal.ink)))

#ornatebox(
  title: [Custom motif], title-style: "sash", caps: ("swoosh", "swoosh"),
  edge: dot, edge-size: 0.18cm, edge-gap: 0.22cm, edge-sides: "all",
  corner: tint("wedge", ink: rgb("#1E6B5A")), centre: none,
  rules: ((1.4pt, "ink"),), radius: 0.25cm, colour: rgb("#1E6B5A"),
)[#lorem(24)]

#v(4mm)

// glyphs of an ornament font
#ornatebox(
  title: [From a font],
  edge: glyph-motif("❦"), edge-sides: "all", edge-size: 0.36cm,
  corner: glyph-motif("✤", fill: p => p.gold), corner-size: 0.5cm,
  centre: none, caps: ("notch", "notch"), sash-inset: (1cm, 1cm),
  title-align: center, colour: rgb("#2F2A26"), gold: rgb("#9C7A3C"),
)[#lorem(24)]

= The flag box

#flagbox(title: [First box])[#lorem(30)]
#v(4mm)
#flagbox(title: [Second box: with a longer title], colour: rgb("#a11d1d"),
  tail: "swallow", badge: [2])[#lorem(22)]
#v(4mm)
#flagbox(title: [Centred, pointed foot], colour: rgb("#1E6B5A"), tail: "point",
  flag-align: center, stitch: true, end-motif: "finial")[#lorem(22)]
#v(4mm)
#flagbox(title: [At the end], colour: rgb("#6B3FA0"), flag-align: end, badge: [7],
  end-motif: "rosette")[#lorem(18)]
