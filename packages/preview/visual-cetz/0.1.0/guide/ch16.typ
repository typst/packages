#import "tpl.typ": *

= Géométrie euclidienne

Ce chapitre montre que les constructions classiques — celles de
#link("https://ctan.org/pkg/tkz-euclide")[tkz-euclide] — s'obtiennent avec les
*seules primitives de CeTZ*, sans une ligne de bibliothèque externe. Tout
repose sur cinq mécanismes déjà vus :

#table(columns: (auto, 1fr), stroke: 0.4pt + bd, inset: 5pt,
  fill: (_, y) => if y == 0 { bg }, align: left,
  [*Outil CeTZ*], [*Ce qu'il donne en géométrie*],
  [`circle-through(A, B, C)`], [le cercle circonscrit, et son centre par
   l'ancre `.center`],
  [`(bary: (A: 1, B: 1, C: 1))`], [tout point défini par un barycentre :
   centre de gravité, centre inscrit, exinscrits],
  [`(P, "_|_", A, B)`], [le projeté orthogonal de P sur (AB) : pied de hauteur,
   point de contact],
  [`intersections(..)`], [l'intersection de deux droites ou courbes :
   orthocentre, points d'un cercle],
  [`(A, 50%, B)`], [milieu et, plus généralement, tout point d'un segment],
)

#note(title: "Nommer avant d'utiliser")[
  Les coordonnées `bary`, `"_|_"` et les ancres exigent des éléments *nommés*.
  On pose donc d'abord les points avec `circle(.., name: "A")`, puis on y fait
  référence par la chaîne `"A"`. Une variable Typst ne suffit pas.
]

== Les points de base

#ex(```typc
// on matérialise les sommets, ce qui les nomme
circle((0,0),     radius: .06, fill: black, name: "A")
circle((5,0),     radius: .06, fill: black, name: "B")
circle((1.4,3.2), radius: .06, fill: black, name: "C")
line("A", "B", "C", close: true)

// milieu : interpolation à 50 %
circle(("A", 50%, "B"), radius: .09, fill: red, stroke: none)
// centre de gravité : barycentre équipondéré
circle((bary: (A: 1, B: 1, C: 1)), radius: .09, fill: purple, stroke: none)
// pied de la hauteur issue de A : projection
circle(("A", "_|_", "B", "C"), radius: .09, fill: green, stroke: none)

for (p, n) in (("A", $A$), ("B", $B$), ("C", $C$)) {
  content(p, anchor: "north-east", padding: .12, text(7pt, n))
}
```, ratio: 52%)

== Cercle circonscrit et médiatrices

`circle-through` fait tout le travail ; son ancre `.center` donne O.

#ex(```typc
circle((0,0),     radius: .06, fill: black, name: "A")
circle((4.6,-.4), radius: .06, fill: black, name: "B")
circle((1.8,3),   radius: .06, fill: black, name: "C")
line("A", "B", "C", close: true)
circle-through("A", "B", "C", name: "cc", stroke: blue + 1pt)

// une médiatrice = la droite joignant le milieu au centre
for (p, q) in (("A","B"), ("B","C"), ("C","A")) {
  let m = (p, 50%, q)
  circle(m, radius: .05, fill: gray, stroke: none)
  line(m, "cc.center", stroke: (paint: gray, dash: "dashed"))
}
circle("cc.center", radius: .09, fill: blue, stroke: none)
content("cc.center", anchor: "south-west", padding: .1,
        text(7pt, fill: blue, $O$))
```, ratio: 52%)

== Orthocentre par intersection des hauteurs

#ex(```typc
circle((0,0),   radius: .06, fill: black, name: "A")
circle((5,0),   radius: .06, fill: black, name: "B")
circle((1.4,3), radius: .06, fill: black, name: "C")
line("A", "B", "C", close: true)

// `intersections` dessine les hauteurs et nomme leur point commun
intersections(name: "x", "H", {
  line("A", ("A", "_|_", "B", "C"), stroke: (dash: "dotted"))
  line("B", ("B", "_|_", "C", "A"), stroke: (dash: "dotted"))
  line("C", ("C", "_|_", "A", "B"), stroke: (dash: "dotted"))
})
circle("H.0", radius: .1, fill: orange, stroke: none)
content("H.0", anchor: "west", padding: .14, text(7pt, fill: orange, $H$))

// les pieds des hauteurs
for (s, p, q) in (("A","B","C"), ("B","C","A"), ("C","A","B")) {
  circle((s, "_|_", p, q), radius: .06, fill: green, stroke: none)
}
```, ratio: 52%)

== Cercle inscrit : un barycentre bien choisi

Le centre du cercle inscrit est le barycentre des sommets pondérés par les
longueurs des côtés opposés. `get-ctx` donne accès aux coordonnées résolues
pour les mesurer.

#ex(```typc
let (A, B, C) = ((0,0), (5,0), (1.2,3))
circle(A, radius: .06, fill: black, name: "A")
circle(B, radius: .06, fill: black, name: "B")
circle(C, radius: .06, fill: black, name: "C")
line("A", "B", "C", close: true)

// longueurs des côtés, avec les utilitaires vectoriels de CeTZ
let a = cetz.vector.dist(B, C)
let b = cetz.vector.dist(C, A)
let c = cetz.vector.dist(A, B)
let I = (bary: (A: a, B: b, C: c))

// le rayon est la distance de I à un côté : |I - projeté|
circle(I, radius: .06, fill: green, stroke: none, name: "I")
intersections(name: "t", "T", {
  circle(I, radius: 3, stroke: none)   // cercle auxiliaire, invisible
  line("A", "B", stroke: none)
})
// plus simple : le point de contact est le projeté de I sur (AB)
line("I", ("I", "_|_", "A", "B"), stroke: green)
circle(("I", "_|_", "A", "B"), radius: .06, fill: green, stroke: none)
content("I", anchor: "north", padding: .16, text(7pt, fill: green, $I$))
```, ratio: 52%)

Pour tracer le cercle lui-même, on mesure le rayon dans `get-ctx`, où les
coordonnées sont déjà résolues en vecteurs :

#ex(```typc
let (A, B, C) = ((0,0), (5,0), (1.2,3))
circle(A, radius: .06, fill: black, name: "A")
circle(B, radius: .06, fill: black, name: "B")
circle(C, radius: .06, fill: black, name: "C")
line("A", "B", "C", close: true)

let (a, b, c) = (cetz.vector.dist(B, C),
                 cetz.vector.dist(C, A),
                 cetz.vector.dist(A, B))
let s = (a + b + c) / 2
// aire par la formule de Héron, puis r = aire / demi-périmètre
let aire = calc.sqrt(s * (s - a) * (s - b) * (s - c))
circle((bary: (A: a, B: b, C: c)), radius: aire / s,
       stroke: green + 1pt)

// les bissectrices concourent au centre
for s in ("A", "B", "C") {
  line(s, (bary: (A: a, B: b, C: c)),
       stroke: (paint: gray, dash: "dashed", thickness: .5pt))
}
```, ratio: 52%)

== La droite d'Euler

O, G et H sont alignés. On les obtient par trois mécanismes différents.

#ex(```typc
circle((0,0),     radius: .06, fill: black, name: "A")
circle((5,0),     radius: .06, fill: black, name: "B")
circle((1.4,3.4), radius: .06, fill: black, name: "C")
line("A", "B", "C", close: true)

circle-through("A", "B", "C", name: "cc", stroke: blue)
intersections(name: "x", "H", {
  line("A", ("A", "_|_", "B", "C"), stroke: none)
  line("B", ("B", "_|_", "C", "A"), stroke: none)
})

// la droite passe par O et H ; on la prolonge par interpolation
// au-delà des extrémités : un ratio < 0 % ou > 100 % extrapole
line(("cc.center", -60%, "H.0"), ("cc.center", 160%, "H.0"),
     stroke: (paint: red, dash: "dashed"))

for (p, c, n) in (("cc.center", blue, $O$), ("H.0", orange, $H$),
                  ((bary: (A: 1, B: 1, C: 1)), purple, $G$)) {
  circle(p, radius: .09, fill: c, stroke: none)
  content(p, anchor: "south", padding: .12, text(7pt, fill: c, n))
}
```, ratio: 52%)

#note(title: "Extrapoler une droite")[
  L'interpolation `(A, t, B)` accepte des ratios hors de $[0%, 100%]$ : `-60%`
  recule avant A, `160%` dépasse B. C'est le moyen le plus court de prolonger
  une droite définie par deux points, sans calcul de vecteur.
]

== Le cercle des neuf points

Son centre est le milieu de [OH] et son rayon la moitié de celui du cercle
circonscrit — deux valeurs qu'on lit sur les objets déjà construits.

#ex(```typc
circle((0,0),     radius: .06, fill: black, name: "A")
circle((5,0),     radius: .06, fill: black, name: "B")
circle((1.6,3.2), radius: .06, fill: black, name: "C")
line("A", "B", "C", close: true)
circle-through("A", "B", "C", name: "cc", stroke: gray + .5pt)
intersections(name: "x", "H", {
  line("A", ("A", "_|_", "B", "C"), stroke: none)
  line("B", ("B", "_|_", "C", "A"), stroke: none)
})

// rayon = distance centre → sommet, mesurée dans get-ctx
get-ctx(ctx => {
  let (_, o, a) = cetz.coordinate.resolve(ctx, "cc.center", "A")
  circle(("cc.center", 50%, "H.0"),
         radius: cetz.vector.dist(o, a) / 2, stroke: red + 1pt)
})

// les neuf points : 3 milieux, 3 pieds, 3 milieux des [HS]
for (p, q) in (("A","B"), ("B","C"), ("C","A")) {
  circle((p, 50%, q), radius: .07, fill: blue, stroke: none)
}
for (s, p, q) in (("A","B","C"), ("B","C","A"), ("C","A","B")) {
  circle((s, "_|_", p, q), radius: .07, fill: green, stroke: none)
}
for s in ("A", "B", "C") {
  circle(("H.0", 50%, s), radius: .07, fill: orange, stroke: none)
}
```, ratio: 52%)

#note(title: "Mesurer une longueur")[
  `cetz.coordinate.resolve(ctx, ..)` transforme des coordonnées de tout système
  en vecteurs, dans un `get-ctx`. C'est la porte d'entrée pour tout calcul
  métrique — longueur, angle — à partir d'éléments nommés.
]

== Théorème de Thalès

Tout point du cercle de diamètre [AB] voit ce diamètre sous un angle droit.

#ex(```typc
circle((0,0),   radius: .06, fill: black, name: "A")
circle((4.4,0), radius: .06, fill: black, name: "B")
// le cercle de diamètre [AB] : centre au milieu, passant par A
circle(("A", 50%, "B"), radius: 2.2, stroke: blue, name: "c")
line("A", "B", stroke: (paint: gray, dash: "dashed"))

// des points du cercle par ancre angulaire
for a in (35deg, 75deg, 130deg) {
  let M = "c." + repr(a)
  line("A", M, "B", stroke: .7pt)
  angle-lib.right-angle(M, "A", "B", radius: .32, stroke: red)
  circle(M, radius: .06, fill: red, stroke: none)
}
```, ratio: 52%)

== Théorème de l'angle inscrit

L'angle au centre vaut le double de l'angle inscrit sur le même arc. Les
ancres angulaires d'un cercle donnent les points sans aucun calcul.

#ex(```typc
circle((0,0), radius: 1.9, stroke: gray, name: "c")
line("c.200deg", "c.center", "c.340deg", stroke: blue + 1pt)
line("c.200deg", "c.80deg", "c.340deg", stroke: red + 1pt)

angle-lib.angle("c.center", "c.200deg", "c.340deg", radius: .5,
  label: $2 alpha$, stroke: blue, fill: blue.lighten(85%))
angle-lib.angle("c.80deg", "c.200deg", "c.340deg", radius: .6,
  label: $alpha$, stroke: red, fill: red.lighten(85%))

for (p, n, an) in (("c.200deg", $A$, "east"), ("c.340deg", $B$, "west"),
                   ("c.80deg", $M$, "south"), ("c.center", $O$, "north")) {
  circle(p, radius: .06, fill: black, stroke: none)
  content(p, anchor: an, padding: .12, text(7pt, n))
}
```, ratio: 52%)

== Tangentes à un cercle

La coordonnée `tangent` est native : elle donne le point de contact.

#ex(```typc
circle((0,0), radius: 1.4, stroke: blue, name: "c")
circle((3.4,1.5), radius: .07, fill: black, name: "P")

for s in (1, 2) {
  let T = (element: "c", point: "P", solution: s)
  line("P", T, stroke: red)
  line("c.center", T, stroke: (paint: gray, dash: "dotted"))
  circle(T, radius: .06, fill: red, stroke: none)
  // le rayon est perpendiculaire à la tangente au point de contact
  angle-lib.right-angle(T, "c.center", "P", radius: .25, stroke: gray)
}
content("P", anchor: "west", padding: .12, text(7pt, $P$))
```, ratio: 52%)

== Deux cercles : points communs et axe radical

#ex(```typc
intersections(name: "i", "X", {
  circle((0,0),   radius: 1.7, stroke: blue,  name: "c1")
  circle((2.6,.6), radius: 1.5, stroke: green, name: "c2")
})
// l'axe radical est la droite passant par les deux intersections
line(("X.0", -80%, "X.1"), ("X.0", 180%, "X.1"),
     stroke: (paint: red, dash: "dashed"))
for n in ("X.0", "X.1") {
  circle(n, radius: .08, fill: red, stroke: none)
}
```, ratio: 52%)

== Puissance d'un point

#ex(```typc
circle((0,0), radius: 1.5, stroke: blue, name: "c")
circle((3.6,0), radius: .06, fill: black, name: "P")
// une sécante issue de P coupe le cercle en deux points
intersections(name: "i", "S", {
  circle((0,0), radius: 1.5, stroke: none)
  line("P", (-3.6, 1.2), stroke: orange)
})
for n in ("S.0", "S.1") { circle(n, radius: .07, fill: orange, stroke: none) }
// la tangente donne PT² = PA · PB
let T = (element: "c", point: "P", solution: 1)
line("P", T, stroke: red)
circle(T, radius: .07, fill: red, stroke: none)
content("P", anchor: "west", padding: .12, text(7pt, $P$))
content(T, anchor: "south", padding: .1, text(7pt, fill: red, $T$))
```, ratio: 52%)

== Triangle médian et triangle orthique

#ex(```typc
circle((0,0),     radius: .05, fill: black, name: "A")
circle((4.8,0),   radius: .05, fill: black, name: "B")
circle((1.4,3.2), radius: .05, fill: black, name: "C")
line("A", "B", "C", close: true, stroke: 1pt)

// médian : les trois milieux
line(("A", 50%, "B"), ("B", 50%, "C"), ("C", 50%, "A"), close: true,
     fill: blue.transparentize(85%), stroke: blue)
// orthique : les trois pieds des hauteurs
line(("A", "_|_", "B", "C"), ("B", "_|_", "C", "A"),
     ("C", "_|_", "A", "B"), close: true,
     fill: red.transparentize(85%), stroke: red)
```, ratio: 52%)

== Droite de Simson

Les projetés d'un point du cercle circonscrit sur les trois côtés sont
alignés. Pour tracer la droite entière il faut relier les deux projetés
*extrêmes* : selon la position de M, le projeté « du milieu » n'est pas
forcément celui qu'on croit — ici c'est celui sur (AB).

#ex(```typc
circle((0,0),   radius: .05, fill: black, name: "A")
circle((4.4,0), radius: .05, fill: black, name: "B")
circle((1,2.8), radius: .05, fill: black, name: "C")
line("A", "B", "C", close: true)
circle-through("A", "B", "C", name: "cc", stroke: gray)

// un point du cercle, par son ancre angulaire
circle("cc.250deg", radius: .07, fill: red, stroke: none, name: "M")
content("M", anchor: "north", padding: .12, text(7pt, fill: red, $M$))

// les trois projetés
for (p, q) in (("A","B"), ("B","C"), ("C","A")) {
  let f = ("M", "_|_", p, q)
  circle(f, radius: .06, fill: blue, stroke: none)
  line("M", f, stroke: (paint: gray, dash: "dotted", thickness: .4pt))
}
// on relie les deux projetés EXTRÊMES — ceux sur (BC) et (CA) —
// en débordant un peu : le projeté sur (AB) tombe entre les deux
line((("M", "_|_", "B", "C"), -12%, ("M", "_|_", "C", "A")),
     (("M", "_|_", "B", "C"), 112%, ("M", "_|_", "C", "A")),
     stroke: blue + 1pt)
```, ratio: 52%)

== Théorème de Ptolémée

Pour un quadrilatère inscriptible, $A C dot B D = A B dot C D + B C dot A D$.

#ex(```typc
circle((0,0), radius: 1.8, stroke: gray, name: "c")
let (A, B, C, D) = ("c.160deg", "c.45deg", "c.-40deg", "c.230deg")
line(A, B, C, D, close: true, stroke: blue + 1pt)
line(A, C, stroke: (paint: red, dash: "dashed"))
line(B, D, stroke: (paint: red, dash: "dashed"))

// vérification numérique dans get-ctx
get-ctx(ctx => {
  let (_, a, b, c, d) = cetz.coordinate.resolve(ctx, A, B, C, D)
  let dist = cetz.vector.dist
  let g = dist(a, c) * dist(b, d)
  let h = dist(a, b) * dist(c, d) + dist(b, c) * dist(a, d)
  content((0, -2.4), text(6pt)[
    #calc.round(g, digits: 3) = #calc.round(h, digits: 3)])
})
for (p, n, an) in ((A, $A$, "east"), (B, $B$, "west"),
                   (C, $C$, "west"), (D, $D$, "east")) {
  circle(p, radius: .06, fill: black, stroke: none)
  content(p, anchor: an, padding: .12, text(7pt, n))
}
```, ratio: 52%)

== Polygones réguliers et pentagramme

`polygon` et `n-star` couvrent l'essentiel ; les ancres du polygone donnent
ses sommets.

#ex(```typc
polygon((0,0), 6, radius: 1.5, stroke: blue + 1pt,
        fill: blue.transparentize(90%), name: "hex")
// report du rayon : les six cercles de la construction au compas
for-each-anchor("hex", exclude: ("center", "default"), n => {
  circle((), radius: 1.5, stroke: (paint: gray.lighten(50%),
                                   thickness: .4pt, dash: "dotted"))
  circle((), radius: .06, fill: black, stroke: none)
})
```, ratio: 52%)

#ex(```typc
polygon((0,0), 5, radius: 1.7, stroke: blue + 1pt, name: "p")
// les diagonales d'un pentagone forment le pentagramme
n-star((0,0), 5, radius: 1.7, inner-radius: 38.2%,
       stroke: orange, show-inner: true)
```, ratio: 52%)

== Théorème de Napoléon

Les centres des triangles équilatéraux construits sur les côtés forment un
triangle équilatéral. Le sommet extérieur s'obtient par la coordonnée
d'interpolation *avec angle* : `(p, 100%, -60deg, q)` place un point à la
distance $p q$ de `p`, dans la direction tournée de $-60°$.

#ex(```typc
circle((0,0),     radius: .05, fill: black, name: "A")
circle((4,-.6),   radius: .05, fill: black, name: "B")
circle((1.4,2.6), radius: .05, fill: black, name: "C")
line("A", "B", "C", close: true, stroke: 1pt)

for (i, (p, q)) in (("A","B"), ("B","C"), ("C","A")).enumerate() {
  let S = (p, 100%, -60deg, q)
  line(p, q, S, close: true, stroke: gray + .6pt,
       fill: gray.transparentize(90%))
  circle(S, radius: .04, stroke: none, name: "S" + str(i))
}
// les centres, par barycentre des trois sommets
line((bary: (A: 1, B: 1, S0: 1)),
     (bary: (B: 1, C: 1, S1: 1)),
     (bary: (C: 1, A: 1, S2: 1)),
     close: true, stroke: red + 1.2pt, fill: red.transparentize(88%))

get-ctx(ctx => {
  let (_, ..c) = cetz.coordinate.resolve(ctx,
    (bary: (A: 1, B: 1, S0: 1)),
    (bary: (B: 1, C: 1, S1: 1)),
    (bary: (C: 1, A: 1, S2: 1)))
  content((1.6, -2.6), text(6pt)[côtés : #range(3).map(i =>
    str(calc.round(cetz.vector.dist(c.at(i), c.at(calc.rem(i + 1, 3))),
                   digits: 3))).join(" · ")])
})
```, ratio: 52%)

== Spirale de Théodore

Chaque triangle rectangle ajoute une unité au carré de l'hypoténuse : les
rayons successifs valent $sqrt(1), sqrt(2), sqrt(3), …$ Ici tout se fait par
transformations, sans une seule coordonnée calculée à la main.

#ex(```typc
// à chaque étape on tourne du bon angle, puis on rallonge
let r = 1.0
for i in range(1, 17) {
  let nr = calc.sqrt(i + 1)
  line((0,0), (r, 0), stroke: gray + .4pt)
  line((r, 0), (r, 1), stroke: blue + .8pt)
  line((0,0), (r, 1), stroke: gray + .4pt)
  angle-lib.right-angle((r, 0), (0,0), (r, 1), radius: .12,
                        stroke: gray + .3pt)
  if i <= 3 {
    content((r / 2, 0), anchor: "north", padding: .06,
            text(5pt)[$sqrt(#str(i))$])
  }
  // on pivote pour que la nouvelle hypoténuse devienne l'axe
  rotate(calc.atan2(r, 1.0))
  r = nr
}
```, ratio: 52%)

== Coniques : ellipse, parabole, hyperbole

#ex(```typc
// ellipse : circle à rayon (rx, ry) ; les foyers par calcul
let (a, b) = (2, 1.2)
circle((0,0), radius: (a, b), stroke: blue + 1pt)
let c = calc.sqrt(a * a - b * b)
for x in (-c, c) {
  circle((x, 0), radius: .07, fill: red, stroke: none)
}
// un point et ses rayons vecteurs
let M = (calc.cos(65deg) * a, calc.sin(65deg) * b)
line((-c, 0), M, (c, 0), stroke: green)
circle(M, radius: .06, fill: green, stroke: none)
```, ratio: 52%)

#ex(```typc
// parabole y = x²/4 : foyer (0,1), directrice y = -1
let pts = range(-45, 46).map(i => (i / 10, calc.pow(i / 10, 2) / 4))
line(..pts, stroke: blue + 1pt)
line((-4.5, -1), (4.5, -1), stroke: (paint: gray, dash: "dashed"))
circle((0, 1), radius: .08, fill: red, stroke: none)
// la distance au foyer égale la distance à la directrice
let P = (3, 9 / 4)
line((0,1), P, stroke: green)
line(P, (3, -1), stroke: green)
circle(P, radius: .06, fill: green, stroke: none)
```, ratio: 52%)

#ex(```typc
// hyperbole x²/a² - y²/b² = 1, tracée par branches
let (a, b) = (1, .8)
for s in (-1, 1) {
  let pts = range(0, 41).map(i => {
    let t = i / 20 - 1
    (s * a * calc.cosh(t * 1.6), b * calc.sinh(t * 1.6))
  })
  line(..pts, stroke: blue + 1pt)
}
// les asymptotes
for s in (-1, 1) {
  line((-3, s * 3 * b / a), (3, -s * 3 * b / a),
       stroke: (paint: gray, dash: "dashed"))
}
```, ratio: 52%)
