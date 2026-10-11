#import "@preview/solids3d:0.4.0": *

#set page(width: 18cm, height: 11cm, margin: 8mm, fill: vintage-paper)
#set text(font: "DejaVu Serif", size: 9pt, fill: vintage-ink)

#let P = perspective(5.6, 4.2, 2.8)
#let light = (1.0, -0.35, 1.0)
#let contour = (paint: vintage-ink, thickness: 0.78pt, plain: true)
#let stipple-pen = pencil-pen(paint: vintage-ink, thickness: 0.70pt,
  nib-major: 0.9, nib-ratio: 0.40)
#let random-stipple = vintage-stipple(
  count: 5600,
  min-size: 0.004,
  max-size: 0.034,
  gamma: 1.05,
  distribution: "random",
  light: light,
  seed: 11,
  pen: stipple-pen,
)
#let fibonacci-stipple = vintage-stipple(
  count: 5600,
  min-size: 0.004,
  max-size: 0.034,
  gamma: 1.05,
  distribution: "fibonacci",
  light: light,
  seed: 11,
  pen: stipple-pen,
)

#align(center)[
  #text(size: 15pt, weight: "bold")[Stippling gradué vectoriel]
  #v(3pt)
  #text(fill: gray(0.35))[Même contour normal, deux distributions de points éclairés]
]
#v(5mm)
#grid(columns: (1fr, 1fr), gutter: 10mm, align: center,
  [
    #picture(width: 6.0cm, height: 5.6cm, projection: P, light: light,
      style: "vintage",
      vintage-shaded(
        sphere(O, 1),
        hatch: none,
        stipple: random-stipple,
        outline: contour,
      ),
    )
    #align(center)[#text(style: "italic")[IV. Random graded stipple]]
  ],
  [
    #picture(width: 6.0cm, height: 5.6cm, projection: P, light: light,
      style: "vintage",
      vintage-shaded(
        sphere(O, 1),
        hatch: none,
        stipple: fibonacci-stipple,
        outline: contour,
      ),
    )
    #align(center)[#text(style: "italic")[V. Fibonacci graded stipple]]
  ],
)
