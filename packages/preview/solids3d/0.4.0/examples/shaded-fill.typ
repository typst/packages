#import "@preview/solids3d:0.4.0": *

#set page(width: 18cm, height: 12cm, margin: 8mm, fill: vintage-paper)
#set text(font: "DejaVu Serif", size: 9pt, fill: vintage-ink)

#let P = perspective(5.6, 4.2, 2.8)
#let light = (1.0, -0.35, 1.0)
#let hatch-pen = pencil-pen(paint: vintage-ink, thickness: 0.70pt,
  nib-major: 1.05, nib-ratio: 0.30)
#let contour = (paint: vintage-ink, thickness: 0.78pt, plain: true)
#let hatch = vintage-hatch(
  light: light,
  count: 760,
  length: 0.22,
  crosshatch: 0.76,
  seed: 11,
  pen: hatch-pen,
)

#let sphere-scene = vintage-shaded(
  sphere((0, 0, 0), 1),
  hatch: hatch,
  outline: contour,
)
#let cylinder-scene = vintage-shaded(
  cylinder(0.78, 2.1),
  hatch: vintage-hatch(
    light: light,
    count: 620,
    length: 0.25,
    crosshatch: 0.35,
    seed: 23,
    pen: hatch-pen,
  ),
  outline: contour,
)

#align(center)[
  #text(size: 15pt, weight: "bold")[Tracé normal et remplissage gravé]
  #v(3pt)
  #text(fill: gray(0.35))[Contour vectoriel classique sur hachures posées avant projection]
]
#v(5mm)
#grid(columns: (1fr, 1fr), gutter: 10mm, align: center,
  [
    #picture(width: 5.8cm, height: 5.1cm, projection: P, light: light,
      style: "vintage", ..sphere-scene)
    #align(center)[#text(style: "italic")[Sphère · contour normal + hachures croisées]]
  ],
  [
    #picture(width: 5.8cm, height: 5.1cm, projection: P, light: light,
      style: "vintage", ..cylinder-scene)
    #align(center)[#text(style: "italic")[Cylindre · contour normal + shading]]
  ],
)
