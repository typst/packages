#import "@preview/solids3d:0.4.0": *

#set page(width: 18cm, height: 12cm, margin: 8mm, fill: vintage-paper)
#set text(font: "DejaVu Serif", size: 9pt, fill: vintage-ink)

#let P = perspective(5.2, 4.3, 2.8)

// p5-like static sketch: deterministic random and value noise, emitted as SVG
// paths so the result remains a sharp printable vector.
#let noisy-dots = ctx => {
  let commands = ()
  commands.push((ctx.rect)((0, 0), (100, 100), fill: vintage-paper, stroke: none))
  for i in range(420) {
    let x = (ctx.random)(index: i * 2, a: 5, b: 95)
    let y = (ctx.random)(index: i * 2 + 1, a: 5, b: 95)
    let n = (ctx.noise)(x / 24, y: y / 24, octaves: 4)
    let radius = 0.18 + 0.85 * n
    let shade = 0.12 + 0.55 * n
    commands.push((ctx.circle)((x, y), radius,
      fill: gray(shade), stroke: none))
  }
  commands
}

// A 3-D helix becomes a 2-D projected path through the same projection API
// as picture(), showing how 3-D solids/curves can be composed with sketch marks.
#let projected-helix = ctx => {
  let commands = ()
  commands.push((ctx.rect)((0, 0), (100, 100), fill: vintage-paper, stroke: none))
  let points = ()
  for i in range(280) {
    let t = 2 * calc.pi * i / 279
    let p = (0.72 * calc.cos(3 * t), 0.72 * calc.sin(3 * t), -0.95 + 1.9 * t / (2 * calc.pi))
    points.push((ctx.project3)(p, P: P, center: (50, 50), scale: 24))
  }
  commands.push((ctx.polyline)(points, stroke: vintage-ink, width: 0.72, fill: none))
  commands
}

#align(center)[
  #text(size: 15pt, weight: "bold")[Static sketch et projection 3D]
  #v(3pt)
  #text(fill: gray(0.35))[API inspirée de p5.js, sortie vectorielle et déterministe]
]
#v(5mm)
#grid(columns: (1fr, 1fr), gutter: 10mm, align: center,
  [
    #sketch(width: 6.2cm, height: 6.2cm, seed: 17, draw: noisy-dots)
    #align(center)[#text(style: "italic")[random + noise]]
  ],
  [
    #sketch(width: 6.2cm, height: 6.2cm, seed: 17, draw: projected-helix)
    #align(center)[#text(style: "italic")[courbe 3D projetée en tracé 2D]]
  ],
)
