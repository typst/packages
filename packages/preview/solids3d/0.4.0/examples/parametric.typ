// Surfaces paramétriques et maillages — solids3d 0.4.0
#import "@preview/solids3d:0.4.0": *
#set page(width: 18cm, height: auto, margin: 1cm)
#set text(size: 9pt)

#let P = orthographic(5, 4, 3)
#let wave = surface-grid(
  (u, v) => (u, v, 0.22 * calc.sin(2 * u) * calc.cos(2 * v)),
  -1.5, 1.5, -1.5, 1.5,
  nu: 16, nv: 16,
)
#let wave-colored = surface-grid(
  (u, v) => (u, v, 0.16 * calc.cos(u) * calc.sin(v)),
  -2, 2, -2, 2,
  nu: 18, nv: 18,
  color: (u, v) => if u < 0 { paleblue } else { paleyellow },
)
#let field = heightfield(
  (x, y) => 0.18 * (x * x - y * y),
  -1.2, 1.2, -1.2, 1.2,
  nx: 12, ny: 12,
)
#let vertices = (
  (0, 0, 0), (1, 0, 0), (1, 1, 0), (0, 1, 0),
  (0, 0, 1), (1, 0, 1), (1, 1, 1), (0, 1, 1),
)
#let faces = (
  (0, 1, 2, 3), (4, 7, 6, 5), (0, 4, 5, 1),
  (1, 5, 6, 2), (2, 6, 7, 3), (3, 7, 4, 0),
)
#let cube = surface-mesh(vertices, faces, smooth: false)

#align(center)[
  #text(size: 14pt, weight: "bold")[Surfaces paramétriques et maillages]
  #v(8pt)
]
#grid(columns: 2, gutter: 12pt,
  figure(
    picture(width: 7.5cm, projection: P,
      draw(wave, withopacity(paleblue, 0.9), meshpen: pen(black, 0.25pt)),
    ), caption: [grille paramétrique avec normales moyennées],
  ),
  figure(
    picture(width: 7.5cm, projection: P, shading: "none",
      draw(wave-colored, meshpen: pen(black, 0.2pt)),
    ), caption: [coloration par cellule et `shading: "none"`],
  ),
  figure(
    picture(width: 7.5cm, projection: P,
      draw(field, withopacity(paleyellow, 0.9), meshpen: pen(black, 0.25pt)),
    ), caption: [raccourci `heightfield`],
  ),
  figure(
    picture(width: 7.5cm, projection: P,
      draw(apply(shift(-0.5, -0.5, -0.2), cube), withopacity(palegreen, 0.85), orange),
      draw(apply(shift(-0.5, -0.5, -0.2), mesh-edges(vertices, faces)), pen: black),
    ), caption: [`surface-mesh` avec wireframe `mesh-edges`],
  ),
)
