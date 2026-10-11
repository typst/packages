#import "@preview/solids3d:0.4.0": *

#set page(width: 21cm, height: 10.5cm, margin: 8mm, fill: vintage-paper)
#set text(font: "DejaVu Serif", size: 8.5pt, fill: vintage-ink)

#let P = perspective(5.6, 4.2, 2.8)
#let light = (1.0, -0.35, 1.0)
#let contour = (plain: true, paint: vintage-ink, thickness: 0.72pt)
#let mark-pen = pencil-pen(paint: vintage-ink, thickness: 0.58pt,
  nib-major: 1.02, nib-ratio: 0.30)
#let hatch = vintage-hatch(
  light: light,
  count: 620,
  length: 0.23,
  crosshatch: 0.72,
  seed: 31,
  pen: mark-pen,
)
#let card(shape, label) = [
  #solid-plot(
    shape,
    size: 4.0cm,
    projection: P,
    light: light,
    style: "vintage",
    hatch: hatch,
    meshpen: mark-pen,
    outline: contour,
  )
  #align(center)[#text(style: "italic")[#label]]
]

#align(center)[
  #text(size: 14pt, weight: "bold")[Solides 3D · plot3d et tracés 2D]
  #v(3pt)
  #text(fill: gray(0.35))[Surface, contour et hachures composés dans la même projection]
]
#v(5mm)
#grid(columns: 4, gutter: 6mm, align: center,
  card(sphere(O, 1), [sphère]),
  card(cylinder(0.72, 1.9), [cylindre]),
  card(cone(0.82, 2.1), [cône]),
  card(torus(0.78, 0.30), [tore]),
)
