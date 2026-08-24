#import "tpl.typ": *

= Coordonnées

CeTZ résout automatiquement le *système de coordonnées* d'après la forme de la valeur
que vous écrivez. Il n'y a rien à déclarer~: `(1, 2)` est cartésien,
`(30deg, 2)` est polaire, `"a.north"` est une ancre, etc.

== Tableau récapitulatif

#table(columns: (auto, auto, 1fr), stroke: 0.4pt + bd, inset: 5pt,
  fill: (_, y) => if y == 0 { bg }, align: (left, left, left),
  [*Système*], [*Écriture*], [*Sens*],
  [XYZ], [`(x, y)` / `(x, y, z)` \ `(x: 1, y: 2)`], [cartésien; unités du canvas ou longueurs (`(1cm, 2cm)`)],
  [Polaire], [`(30deg, 2)` \ `(angle: 30deg, radius: 2)`], [angle + rayon (rayon scalaire ou `(rx, ry)`)],
  [Ancre], [`"nom.ancre"` / `"nom"` \ `(name: "n", anchor: "north")`], [point d'un élément nommé],
  [Barycentrique], [`(bary: (a: 1, b: 1, c: 2))`], [moyenne pondérée de points nommés],
  [Relatif], [`(rel: (1, 0))` \ `(rel: (1,0), to: "a.east")`], [décalage depuis le point précédent (ou `to`)],
  [Interpolation], [`(a, 50%, b)` / `(a, .5, b)` \ `(a, 50%, 20deg, b)`], [le long du segment `a`–`b`, avec rotation optionnelle],
  [Perpendiculaire], [`(a, "-|", b)` / `(a, "|-", b)`], [intersection des perpendiculaires],
  [Projection], [`(p, "_|_", a, b)`], [projeté orthogonal de `p` sur la droite `ab`],
  [Tangente], [`(element: "c", point: p, solution: 1)`], [tangente à une forme depuis un point],
  [Fonction], [`(v => …, a, b)`], [calcul libre sur les vecteurs résolus],
  [Précédente], [`()`], [le dernier point utilisé],
)

== Cartésien et polaire

#ex(```typc
grid((0,0), (3,2), stroke: gray.lighten(50%) + .3pt)
line((0,0), (3,2), stroke: blue, mark: (end: ">"))
line((0,0), (1cm, 1cm), stroke: red)        // longueurs absolues
circle((x: 2, y: 1), radius: .15, fill: green)
```)

#ex(```typc
line((0,0), (3,0), stroke: gray)
for a in range(0, 91, step: 15) {
  line((0,0), (a * 1deg, 2.4), stroke: blue.lighten(30%))
  content((a * 1deg, 2.7), text(7pt)[#a°])
}
// rayon elliptique : (angle, (rx, ry))
line((0,0), (45deg, (2.8, 1.2)), stroke: red + 1pt)
```, ratio: 55%)

== Relatif et point précédent

#ex(```typc
// (rel:) : décalage depuis le point précédent
line((0,0), (rel: (1,0)), (rel: (0,1)),
     (rel: (1,0)), (rel: (0,1)), stroke: blue + 1pt)
// (rel:, to:) : décalage depuis une ancre donnée
circle((0,0), radius: .1, fill: red, name: "o")
circle((rel: (0,-1), to: "o"), radius: .1, fill: orange)
```, ratio: 60%)

#note(title: "update")[
  `(rel: (1,0), update: false)` calcule le point relatif *sans* déplacer le
  « point précédent ». Pratique pour poser des étiquettes en marge d'un chemin.
]

== Interpolation le long d'un segment

#ex(```typc
line((0,0), (4,1), name: "l", stroke: gray)
// ratio -> fraction du segment
circle(((0,0), 25%, (4,1)), radius: .12, fill: blue)
// nombre -> distance absolue en unités
circle(((0,0), 2, (4,1)), radius: .12, fill: red)
// avec angle -> tourne autour du premier point
line((0,0), ((0,0), 2, 60deg, (4,1)), stroke: green, mark: (end: ">"))
```, ratio: 60%)

== Perpendiculaires et projection

#ex(```typc
circle((0,2), radius: .08, fill: blue, name: "a")
circle((3,0), radius: .08, fill: red,  name: "b")
line("a", ("a", "|-", "b"), stroke: (dash: "dashed"))
line("b", ("a", "|-", "b"), stroke: (dash: "dashed"))
circle(("a", "|-", "b"), radius: .1, stroke: green)
content(("a", "|-", "b"), anchor: "north-west",
        padding: .1, text(7pt)[point "|-"])
```, ratio: 60%)

#ex(```typc
line((0,0), (4,1.2), name: "L", stroke: gray + 1pt)
circle((1.2, 2), radius: .08, fill: red, name: "P")
// projeté orthogonal de P sur (0,0)-(4,1.2)
line("P", ("P", "_|_", (0,0), (4,1.2)),
     stroke: (paint: blue, dash: "dotted"))
circle(("P", "_|_", (0,0), (4,1.2)), radius: .1, stroke: blue)
```, ratio: 60%)

== Barycentrique

#ex(```typc
circle((0,0),   radius: .05, name: "A", fill: black)
circle((4,0),   radius: .05, name: "B", fill: black)
circle((2,2.4), radius: .05, name: "C", fill: black)
line("A", "B", "C", close: true, stroke: gray)
circle((bary: (A: 1, B: 1, C: 1)), radius: .1, fill: red)
circle((bary: (A: 3, B: 1, C: 1)), radius: .1, fill: blue)
```, ratio: 60%)

== Tangente

#ex(```typc
circle((0,0), radius: 1, name: "c")
circle((3,1), radius: .06, fill: red, name: "p")
line("p", (element: "c", point: "p", solution: 1), stroke: blue)
line("p", (element: "c", point: "p", solution: 2), stroke: green)
```, ratio: 60%)

== Coordonnée fonctionnelle

#ex(```typc
let mid = (a, b) => vector.scale(vector.add(a, b), .5)
line((0,0), (3,2), stroke: gray)
circle((mid, (0,0), (3,2)), radius: .15, fill: orange)
```, ratio: 60%)
