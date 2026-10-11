// Figures pédagogiques de géométrie dans l'espace — collège.
// Les familles de figures suivent l'esprit des exemples de pas-cours
// (https://ctan.org/pkg/pas-cours), mais toutes les constructions sont
// réalisées nativement par solids en Typst.
#import "@preview/solids3d:0.4.0": *
#set page(width: 18cm, height: auto, margin: 8mm)
#set text(size: 8.5pt)

#let ink = rgbf(0.08, 0.12, 0.25)
#let measure-pen = pen(royalblue, 0.65pt)
#let guide-pen = pen(gray(0.35), 0.45pt, dashed)
#let edge-pen = pen(ink, 0.55pt)
#let hint-pen = pen(orange, 0.65pt)

#let card(title, body) = block(
  width: 100%,
  inset: 5pt,
  radius: 3pt,
  fill: rgbf(0.98, 0.985, 1),
  stroke: (paint: rgbf(0.82, 0.85, 0.92), thickness: 0.5pt),
  {
    align(center, text(weight: "bold", size: 10pt, title))
    v(3pt)
    body
  },
)

= Solides usuels — figures annotées

Ces figures présentent les solides fréquemment rencontrés au collège :
sommets, centres, arêtes, rayons, hauteurs, génératrices et faces sont
indiqués par des points, des flèches et des lignes de cote. Les longueurs sont
illustratives et peuvent être remplacées directement dans le code.

#grid(columns: 2, gutter: 7pt,
  card([Pavé droit — sommets et dimensions], {
    let (A, B, C, D) = ((0, 0, 0), (6, 0, 0), (6, 3, 0), (0, 3, 0))
    let (E, F, G, H) = ((0, 0, 2.5), (6, 0, 2.5), (6, 3, 2.5), (0, 3, 2.5))
    picture(width: 7.6cm, projection: orthographic(8, 6, 5),
      draw(cuboid(length: 6, width: 3, height: 2.5), withopacity(lightblue, 0.52)),
      draw(box3(A, G), edge-pen),
      draw(line3(A, G), guide-pen),
      point3([A], A, align: SW, pen: ink), point3([B], B, align: S, pen: ink),
      point3([C], C, align: SE, pen: ink), point3([D], D, align: W, pen: ink),
      point3([E], E, align: NW, pen: ink), point3([F], F, align: N, pen: ink),
      point3([G], G, align: NE, pen: ink), point3([H], H, align: W, pen: ink),
      dimension3([AB = 6 cm], A, B, offset: (0, -0.85, 0), align: S, pen: measure-pen),
      dimension3([BC = 3 cm], B, C, offset: (0, 0, -0.7), align: SE, pen: measure-pen),
      dimension3([AE = 2.5 cm], A, E, offset: (-0.8, 0, 0), align: W, pen: measure-pen),
      callout3([diagonale AG], interp(A, G, 0.5), (-1.8, 1.4, 2.8), align: W, pen: hint-pen),
    )
  }),
  card([Cône de révolution — rayon, hauteur, génératrice], {
    let (O, S, A) = ((0, 0, 0), (0, 0, 4), (2, 0, 0))
    let co = cone(O, 2, 4, Z, 1)
    let base = apply(scale3(2), unitdisk)
    picture(width: 7.6cm, projection: orthographic(7, 6, 5),
      draw(surface(co, base), withopacity(lightred, 0.62)),
      draw(co, edge-pen), draw(circle3(O, 2), guide-pen),
      draw(line3(S, O), guide-pen),
      point3([O], O, align: SW, pen: ink), point3([S], S, align: N, pen: ink),
      point3([A], A, align: S, pen: ink),
      dimension3([r = 2 cm], O, A, offset: (0, -0.65, 0), align: S, pen: measure-pen),
      dimension3([h = 4 cm], O, S, offset: (-0.85, 0, 0), align: W, pen: measure-pen),
      callout3([génératrice], interp(S, A, 0.5), (2.9, -0.2, 2.4), align: W, pen: hint-pen),
      callout3([base circulaire], interp(O, A, 0.65), (-2.4, -1.2, 0), align: E, pen: hint-pen),
    )
  }),
  card([Cylindre — bases et génératrice], {
    let (O, O1, A, B) = ((0, 0, 0), (0, 0, 3.5), (2, 0, 0), (2, 0, 3.5))
    let cy = cylinder(O, 2, 3.5, Z)
    let top = apply(shift(O1), apply(scale3(2), unitdisk))
    picture(width: 7.6cm, projection: orthographic(7, 6, 5),
      draw(surface(cy, apply(scale3(2), unitdisk), top), withopacity(paleblue, 0.62)),
      draw(circle3(O, 2), guide-pen), draw(circle3(O1, 2), edge-pen),
      draw(line3(A, B), edge-pen), draw(line3(O, O1), guide-pen),
      point3([O], O, align: SW, pen: ink), point3([$O'$], O1, align: N, pen: ink),
      point3([A], A, align: S, pen: ink), point3([B], B, align: E, pen: ink),
      dimension3([r = 2 cm], O, A, offset: (0, -0.6, 0), align: S, pen: measure-pen),
      dimension3([h = 3.5 cm], O, O1, offset: (-0.85, 0, 0), align: W, pen: measure-pen),
      callout3([génératrice], interp(A, B, 0.5), (3, -0.4, 1.8), align: W, pen: hint-pen),
      callout3([face latérale], interp(A, B, 0.7), (3.2, 1.7, 2.8), align: W, pen: hint-pen),
    )
  }),
  card([Boule — centre, rayon et grand cercle], {
    let O = (0, 0, 0)
    let A = (2, 0, 0)
    let b = apply(scale3(2), sphere(O, 1))
    picture(width: 7.6cm, projection: orthographic(6, 5, 4),
      draw(surface(b), withopacity(paleyellow, 0.72)),
      draw(silhouette(b), edge-pen),
      draw(circle3(O, 2, normal: Z), pen(royalblue, 0.65pt)),
      draw(circle3(O, 2, normal: Y), pen(royalblue, 0.55pt, dashed)),
      point3([O], O, align: SW, pen: ink), point3([A], A, align: E, pen: ink),
      dimension3([OA = 2 cm], O, A, offset: (0, -0.55, 0), align: S, pen: measure-pen),
      callout3([grand cercle], interp(O, A, 0.75), (2.8, -1.3, 0.2), align: W, pen: hint-pen),
      callout3([centre], O, (-2.2, -1.2, 1.1), align: E, pen: hint-pen),
    )
  }),
  card([Pyramide régulière — hauteur et faces], {
    let base = regular-polygon3(center: O, radius: 1.6, n: 4, angle: 45)
    let (A, B, C, D) = (base.nodes.at(0), base.nodes.at(1), base.nodes.at(2), base.nodes.at(3))
    let O0 = O
    let S0 = (0, 0, 3.2)
    let py = surface(cone-over(base, S0), surface(base))
    picture(width: 7.6cm, projection: orthographic(6, 5, 4),
      draw(py, withopacity(palegreen, 0.68)),
      draw((line3(A, B, C, D, cyclic: true), line3(S0, A), line3(S0, B), line3(S0, C), line3(S0, D)), edge-pen),
      draw(line3(S0, O0), guide-pen),
      point3([A], A, align: S, pen: ink), point3([B], B, align: E, pen: ink),
      point3([C], C, align: N, pen: ink), point3([D], D, align: W, pen: ink),
      point3([O], O0, align: SW, pen: ink), point3([S], S0, align: N, pen: ink),
      dimension3([SO = 3.2 cm], O0, S0, offset: (-0.7, 0, 0), align: W, pen: measure-pen),
      dimension3([AB], A, B, offset: (0, -0.45, -0.1), align: S, pen: measure-pen),
      callout3([face triangulaire], interp(S0, A, 0.55), (2.8, 0.2, 2.4), align: W, pen: hint-pen),
      right-angle3(S0, O0, A, size: 0.22, pen: measure-pen),
    )
  }),
  card([Prisme droit triangulaire — bases et hauteur], {
    let base = regular-polygon3(center: O, radius: 1.55, n: 3, angle: 90)
    let top = apply(shift((0, 0, 2.8)), base)
    let P0 = base.nodes.at(0)
    let P1 = base.nodes.at(1)
    let P2 = base.nodes.at(2)
    let Q0 = top.nodes.at(0)
    let Q1 = top.nodes.at(1)
    let Q2 = top.nodes.at(2)
    let pr = surface(extrude(base, (0, 0, 2.8)), surface(base), surface(top))
    picture(width: 7.6cm, projection: orthographic(6, 5, 4),
      draw(pr, withopacity(lightblue, 0.67)),
      draw((line3(P0, P1, P2, cyclic: true), line3(Q0, Q1, Q2, cyclic: true), line3(P0, Q0), line3(P1, Q1), line3(P2, Q2)), edge-pen),
      point3([$A$], P0, align: S, pen: ink), point3([$B$], P1, align: W, pen: ink),
      point3([$C$], P2, align: E, pen: ink), point3([$A'$], Q0, align: N, pen: ink),
      point3([$B'$], Q1, align: W, pen: ink), point3([$C'$], Q2, align: E, pen: ink),
      dimension3([hauteur = 2.8 cm], P0, Q0, offset: (-0.75, 0, 0), align: W, pen: measure-pen),
      dimension3([AB], P0, P1, offset: (0, -0.45, -0.1), align: S, pen: measure-pen),
      callout3([base], interp(P0, P1, 0.5), (-2.5, -1.1, 0), align: E, pen: hint-pen),
      callout3([face latérale], interp(P0, Q0, 0.5), (2.8, 0.5, 1.5), align: W, pen: hint-pen),
    )
  }),
)

#v(8pt)
#block(
  inset: 6pt,
  fill: rgbf(1, 0.97, 0.88),
  stroke: (paint: rgbf(0.9, 0.7, 0.25), thickness: 0.5pt),
  [Les fonctions `point3`, `callout3`, `dimension3`, `right-angle3`,
  `cuboid`, `regular-pyramid` et `regular-prism` sont exportées par le package.
  Elles renvoient des commandes compatibles avec `picture`, et peuvent donc être
  combinées librement avec `draw`, `surface`, `skeleton` et `silhouette`.],
)
