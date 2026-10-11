#import "@preview/solids3d:0.4.0": *

#set page(width: 18cm, height: 12cm, margin: 8pt)
#set text(size: 9pt, font: "DejaVu Sans")

#let P = orthographic(6, 3, 2)
#let b = cylinder(O, 1, 2)
#let s = (
  // no material / hatch / stipple given: the surface is engraved (tonal line work)
  draw(surface(b)),
  draw(b, m: 6, frontpen: pencil-pen(paint: vintage-ink, thickness: 0.62pt),
    backpen: pencil-pen(paint: vintage-pale-ink, thickness: 0.52pt),
    longitudinalpen: pencil-pen(paint: vintage-ink, thickness: 0.38pt)),
  dimension3([h = 2 cm], (0, 0, 0), (0, 0, 2), offset: (1.7, 0, 0), pen: vintage-ink),
)

#let pencil-scene = (
  // Pencil shading: crossed, slightly wavy sketch strokes whose weight follows the light.
  draw(surface(sphere((0, 0, 0.85), 0.85))),
  draw(sphere((0, 0, 0.85), 0.85), m: 7,
    frontpen: pencil-pen(paint: pencil-ink, thickness: 0.7pt,
      roughness: 0.18, pressure: 0.12, passes: 1, seed: 7)),
  point3([O], (0, 0, 0.85), pen: pencil-ink),
  callout3([centre], (0, 0, 0.85), (1.3, 0.3, 1.5), pen: pencil-ink),
)

#align(center)[
  #text(size: 15pt, weight: "bold")[Styles vectoriels optionnels]
  #v(4pt)
  #text(fill: gray(0.35))[inspirés de la planche scientifique ancienne et du trait de crayon]
]
#v(6pt)
#grid(columns: (1fr, 1fr), gutter: 10pt,
  block(fill: vintage-paper, inset: 8pt, radius: 3pt,
    [
      #text(weight: "bold", fill: vintage-ink)[Vintage · hachures gravées]
      #v(4pt)
      #picture(width: 5.5cm, projection: P, style: "vintage", ..s)
    ]
  ),
  block(fill: vintage-paper, inset: 8pt, radius: 3pt,
    [
      #text(weight: "bold", fill: deepblue)[Pencil draw · hachures graphite]
      #v(4pt)
      #picture(width: 5.5cm, projection: P, style: "pencil", ..pencil-scene)
    ]
  ),
)
#v(5pt)
#align(center)[#text(size: 7.5pt, fill: gray(0.35))[Les deux rendus restent des chemins vectoriels ; le style par défaut n'est pas modifié.]]
