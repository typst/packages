// Recettes prêtes à copier pour les figures de solides au collège.
// Les annotations sont des commandes 3D : elles suivent la même projection que
// les arêtes et peuvent être combinées avec draw(), surface() et silhouette().
#import "@preview/solids3d:0.4.0": *

#set page(width: 19cm, height: auto, margin: 8mm)
#set text(font: "DejaVu Sans", size: 8.5pt, fill: rgb("#17233b"))

#let edge-ink = pen(rgb("#17233b"), 0.65pt)
#let hidden-ink = pen(gray(0.45), 0.45pt, dashed)
#let code-ink = pen(rgb("#c4422f"), 0.7pt)
#let measure-ink = pen(rgb("#1f62a5"), 0.65pt)
#let guide-ink = pen(gray(0.35), 0.5pt, dashed)
#let P = orthographic(7, 6, 5)

#let card(title, body) = block(
  width: 100%,
  inset: 5pt,
  radius: 3pt,
  fill: rgb("#f8fafc"),
  stroke: (paint: rgb("#cbd5e1"), thickness: 0.5pt),
  {
    align(center, text(weight: "bold", size: 9.5pt, title))
    v(2pt)
    body
  },
)

= Figures de solides — recettes collège

Cette planche montre les commandes directement réutilisables pour une
représentation en perspective cavalière : points nommés en mode mathématique,
arêtes cachées en pointillés, codage des longueurs égales, angles droits,
hauteurs et annotations de longueurs. Les textes de `dimension3` suivent
automatiquement l’inclinaison projetée de leur ligne et sont centrés sur la
cote ; `dx`/`dy` permettent de les ajuster finement, comme les noms de points
(avec `rotate: false` ou un angle explicite pour un cas particulier). Les
lignes d’attache peuvent être supprimées avec `extensions: false` ; `pen`
accepte notamment `dashed` et `dotted` pour la cote et ses flèches, tandis que
`extension-pen` règle séparément les lignes d’attache conservées.

#grid(columns: 2, gutter: 7pt,
  card([Pavé droit — sommets, codages et cotes], {
    let v = cuboid-vertices(length: 5, width: 3, height: 2.5)
    picture(width: 8.1cm, projection: P,
      draw(cuboid(length: 5, width: 3, height: 2.5), withopacity(lightblue, 0.45)),
      cuboid-edges(v, visible: edge-ink, hidden: hidden-ink),
      edge-code3(v.A, v.B, count: 1, pen: code-ink),
      edge-code3(v.E, v.F, count: 1, pen: code-ink),
      edge-code3(v.B, v.C, count: 2, pen: code-ink),
      right-angle3(v.B, v.A, v.E, size: 0.24, pen: code-ink),
      point3($A$, v.A, align: SW, pen: edge-ink),
      point3($B$, v.B, align: S, pen: edge-ink),
      // Fine placement examples: numeric dx/dy follow the projected figure.
      point3($C$, v.C, align: SE, pen: edge-ink, dx: 0.08, dy: 0.04),
      point3($E$, v.E, align: NW, pen: edge-ink),
      point3($F$, v.F, align: N, pen: edge-ink),
      point3($G$, v.G, align: NE, pen: edge-ink),
      dimension3([AB = 5 cm], v.A, v.B, offset: (0, -0.72, 0), align: S,
        pen: pen(measure-ink, dashed), extension-pen: pen(measure-ink, dotted), dx: 0.10, dy: 0.03),
      dimension3([BC = 3 cm], v.B, v.C, offset: (0, 0, -0.55), align: SE, pen: measure-ink),
      dimension3([AE = 2.5 cm], v.A, v.E, offset: (-0.7, 0, 0), align: W, pen: measure-ink),
    )
  }),
  card([Prisme droit triangulaire — base rectangle], {
    let A = O
    let B = (2.6, 0, 0)
    let C = (0, 1.6, 0)
    let A1 = (0, 0, 2.8)
    let B1 = (2.6, 0, 2.8)
    let C1 = (0, 1.6, 2.8)
    let pr = right-prism3(base: 2.6, width: 1.6, height: 2.8)
    picture(width: 8.1cm, projection: P,
      draw(pr, withopacity(palegreen, 0.52)),
      draw((
        line3(A, B, C, cyclic: true),
        line3(A1, B1, C1, cyclic: true),
        line3(A, A1), line3(B, B1), line3(C, C1),
      ), edge-ink),
      equal-edges3(((A, A1), (B, B1), (C, C1)), count: 1, pen: code-ink),
      right-angle3(B, A, C, size: 0.22, pen: code-ink),
      point3($A$, A, align: SW, pen: edge-ink),
      point3($B$, B, align: S, pen: edge-ink),
      point3($C$, C, align: W, pen: edge-ink),
      point3($A'$, A1, align: NW, pen: edge-ink),
      point3($B'$, B1, align: N, pen: edge-ink),
      point3($C'$, C1, align: E, pen: edge-ink),
      dimension3([AA' = 2.8 cm], A, A1, offset: (-0.65, 0, 0), align: W, pen: measure-ink),
      dimension3([AB = 2.6 cm], A, B, offset: (0, -0.58, 0), align: S, pen: measure-ink),
      angle-code3(B, A, C, right: true, size: 0.22, pen: code-ink),
    )
  }),
  card([Pyramide — base carrée, hauteur et angle droit], {
    let base = regular-polygon3(center: O, radius: 1.55, n: 4, angle: 45)
    let A = base.nodes.at(0)
    let B = base.nodes.at(1)
    let C = base.nodes.at(2)
    let D = base.nodes.at(3)
    let O0 = (0, 0, 0)
    let S = (0, 0, 3.1)
    let py = surface(cone-over(base, S), surface(base))
    picture(width: 8.1cm, projection: P,
      draw(py, withopacity(lightred, 0.5)),
      draw((
        line3(A, B, C, D, cyclic: true),
        line3(S, A), line3(S, B), line3(S, C), line3(S, D),
      ), edge-ink),
      height3(S, O0, pen: guide-ink),
      equal-edges3(((A, B), (B, C), (C, D), (D, A)), count: 1, pen: code-ink),
      right-angle3(S, O0, A, size: 0.22, pen: code-ink),
      // At B, BA and BC are consecutive sides of the square base: use the
      // square marker, not an arc labelled 90°, to keep the right angle
      // unambiguous in the projection.
      angle-code3(A, B, C, right: true, size: 0.22, pen: code-ink),
      point3($A$, A, align: S, pen: edge-ink),
      point3($B$, B, align: E, pen: edge-ink),
      point3($C$, C, align: N, pen: edge-ink),
      point3($D$, D, align: W, pen: edge-ink),
      point3($O$, O0, align: SW, pen: edge-ink),
      point3($S$, S, align: N, pen: edge-ink),
      // These two cotes are already clear without projecting attachment lines.
      dimension3([SO = 3.1 cm], O0, S, offset: (-0.65, 0, 0), align: W,
        pen: pen(measure-ink, dashed), extensions: false),
      dimension3([AB], A, B, offset: (0, -0.48, -0.05), align: S,
        pen: pen(measure-ink, dotted), extensions: false),
    )
  }),
  card([Cylindre — rayon, axe et hauteur], {
    let O = (0, 0, 0)
    let O1 = (0, 0, 3.4)
    let A = (1.55, 0, 0)
    let A1 = (1.55, 0, 3.4)
    let cy = cylinder(O, 1.55, 3.4, Z)
    let disk = apply(scale3(1.55), unitdisk)
    let top = apply(shift(O1), disk)
    picture(width: 8.1cm, projection: P,
      draw(surface(cy, disk, top), withopacity(paleblue, 0.55)),
      draw(cy, edge-ink),
      draw(circle3(O, 1.55), guide-ink),
      draw(circle3(O1, 1.55), edge-ink),
      draw(line3(O, O1), guide-ink),
      draw(line3(A, A1), edge-ink),
      point3($O$, O, align: SW, pen: edge-ink),
      point3($O'$, O1, align: N, pen: edge-ink, dx: -0.05, dy: 0.02),
      point3($A$, A, align: S, pen: edge-ink),
      point3($A'$, A1, align: E, pen: edge-ink),
      dimension3([r = 1.55 cm], O, A, offset: (0, -0.55, 0), align: S, pen: measure-ink),
      dimension3([h = 3.4 cm], O, O1, offset: (-0.68, 0, 0), align: W, pen: measure-ink),
      angle-code3(A, O, O1, right: true, size: 0.2, pen: code-ink),
    )
  }),
  card([Sphère — centre, rayon et grand cercle], {
    let O = (0, 0, 0)
    let A = (1.7, 0, 0)
    let s = apply(scale3(1.7), sphere(O, 1))
    picture(width: 8.1cm, projection: orthographic(6, 5, 4),
      draw(surface(s), withopacity(paleyellow, 0.65)),
      draw(silhouette(s), edge-ink),
      draw(circle3(O, 1.7, normal: Z), pen(rgb("#1f62a5"), 0.65pt)),
      draw(circle3(O, 1.7, normal: Y), pen(gray(0.4), 0.5pt, dashed)),
      draw(line3(O, A), edge-ink),
      point3($O$, O, align: SW, pen: edge-ink),
      point3($A$, A, align: E, pen: edge-ink),
      dimension3([OA = 1.7 cm], O, A, offset: (0, -0.5, 0), align: S, pen: measure-ink),
      callout3([grand cercle], interp(O, A, 0.7), (2.6, -1.1, 0.2), align: W, pen: code-ink, dx: 0.06, dy: 0.05),
    )
  }),
  card([Repère — coordonnées dans un pavé droit], {
    let v = cuboid-vertices(length: 4, width: 2.5, height: 2.2)
    picture(width: 8.1cm, projection: orthographic(7, 6, 5),
      draw(cuboid(length: 4, width: 2.5, height: 2.2), withopacity(lightblue, 0.42)),
      cuboid-edges(v, visible: edge-ink, hidden: hidden-ink),
      xaxis3($x$, Arrow3, pen: measure-ink, min: 0, max: 4.8),
      yaxis3($y$, Arrow3, pen: measure-ink, min: 0, max: 3.2),
      zaxis3($z$, Arrow3, pen: measure-ink, min: 0, max: 3.0),
      point3($O$, v.A, align: SW, pen: edge-ink),
      point3($G$, v.G, align: NE, pen: edge-ink),
      dimension3([$x = 4$], v.A, v.B, offset: (0, -0.58, 0), align: S, pen: measure-ink),
      dimension3([$y = 2.5$], v.B, v.C, offset: (0, 0, -0.5), align: SE, pen: measure-ink),
      dimension3([$z = 2.2$], v.A, v.E, offset: (-0.65, 0, 0), align: W, pen: measure-ink),
    )
  }),
)

#v(6pt)
#block(
  inset: 6pt,
  fill: rgb("#fff7df"),
  stroke: (paint: rgb("#e7bd5a"), thickness: 0.5pt),
  [
    #text(weight: "bold")[Commandes principales :]
    `point3($A$, A)` pose un sommet nommé ; `dimension3([AB = 5 cm], A, B, offset: ...)`
    cote une longueur ; `edge-code3(A, B, count: 2)` code une arête ;
    `equal-edges3(((A, B), (C, D)), count: 1)` réutilise le même code ;
    `right-angle3(C, A, D)` ou `angle-code3(C, A, D, right: true)` marque un angle droit ;
    `angle-mark3(B, A, C, label: $alpha$)` dessine un arc d'angle.
  ],
)
