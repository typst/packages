#import "@preview/solids3d:0.4.0": *

#set page(width: 12cm, height: 8cm, margin: 8mm)

// A dependency-free tube constructor for helixes, wires and rods. `width` is
// the diameter; `n` controls the polygonal section and `caps` closes the ends.
#let P = perspective(camera: (4.5, 5.2, 3.4), up: Z, target: O, zoom: 1.1)
#let tau = 2 * calc.pi
#let helix = graph3(
  t => (1.05 * calc.cos(t * 1rad), 1.05 * calc.sin(t * 1rad), -1.15 + 0.055 * t),
  0, 6 * tau, n: 72, join: "--",
)
#let rod = tube3(line3((0, 0, -1.35), (0, 0, 1.35)), width: 0.62, n: 16, caps: true)
#let helix-tube = tube3(helix, width: 0.105, n: 8)

#align(center)[
  #text(size: 13pt, weight: "bold")[A polygonal tube around a helix]
  #v(4pt)
  #picture(size: 10.5cm, projection: P,
    draw(surface(rod), withopacity(palecyan, 0.72)),
    draw(surface(helix-tube), withopacity(paleyellow, 0.95)),
    draw(helix, pen(red, 0.35pt)),
  )
  #v(2pt)
  #text(size: 8pt, style: "italic")[The tube is built from a transported frame; no Asymptote runtime is required.]
]
