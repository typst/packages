#import "tpl.typ": *

= Vecteurs et matrices

CeTZ expose ses utilitaires mathématiques : indispensables dès que l'on calcule
des positions plutôt que de les écrire à la main.

== `cetz.vector`

#table(columns: (auto, 1fr), stroke: 0.4pt + bd, inset: 5pt,
  fill: (_, y) => if y == 0 { bg }, align: left,
  [*Fonction*], [*Effet*],
  [`add(a, b)` `sub(a, b)`], [somme / différence],
  [`scale(v, x)` `div(v, x)`], [produit / division par un scalaire],
  [`neg(v)`], [opposé],
  [`len(v)` `dist(a, b)`], [norme / distance],
  [`norm(v)`], [vecteur unitaire],
  [`dot(a, b)` `cross(a, b)`], [produit scalaire / vectoriel],
  [`angle2(a, b)`], [angle du vecteur `b - a` (2D)],
  [`angle(a, c, b)`], [angle en `c` entre `a` et `b`],
  [`lerp(a, b, t)`], [interpolation linéaire],
  [`element-product(a, b)`], [produit terme à terme],
  [`as-vec(v)`], [complète en vecteur 3D],
)

#ex(```typc
let a = (3, 1, 0)
let b = (1, 2.5, 0)
line((0,0), a, mark: (end: ">"), stroke: blue)
line((0,0), b, mark: (end: ">"), stroke: red)
// somme : règle du parallélogramme
line((0,0), vector.add(a, b), mark: (end: ">"), stroke: green + 1.2pt)
line(a, vector.add(a, b), stroke: (dash: "dotted"))
line(b, vector.add(a, b), stroke: (dash: "dotted"))
content(vector.add(a, b), anchor: "west", padding: .12, text(7pt)[a + b])
```, ratio: 60%)

#ex(```typc
let a = (3, 1)
// normale unitaire : tourner de 90° puis normaliser
let n = vector.norm((-a.at(1), a.at(0), 0))
line((0,0), a, mark: (end: ">"))
line((0,0), n, mark: (end: ">"), stroke: red)
content(n, anchor: "east", padding: .1, text(7pt)[normale])
get-ctx(_ => none)
content((3.4, 1), anchor: "west",
        text(7pt)[|a| = #calc.round(vector.len(a), digits: 3)])
```, ratio: 60%)

#ex(```typc
// une flèche décalée parallèlement à un segment
let (a, b) = ((0,0), (4,1.5))
let d = vector.norm(vector.sub(b, a))
let n = vector.scale((-d.at(1), d.at(0), 0), .35)
line(a, b, stroke: gray)
line(vector.add(a, n), vector.add(b, n),
     mark: (end: ">"), stroke: blue)
```, ratio: 60%)

== `cetz.matrix`

#table(columns: (auto, 1fr), stroke: 0.4pt + bd, inset: 5pt,
  fill: (_, y) => if y == 0 { bg }, align: left,
  [*Fonction*], [*Effet*],
  [`ident(4)` `diag(..)`], [identité / diagonale],
  [`mul-mat(a, b, ..)`], [produit matriciel],
  [`mul-vec(m, v)`], [applique la matrice à un vecteur],
  [`inverse(m)`], [inverse],
  [`transform-translate(x, y, z)`], [translation],
  [`transform-scale(f)`], [homothétie],
  [`transform-rotate-x/y/z(a)`], [rotation autour d'un axe],
  [`transform-rotate-xyz(x, y, z)`], [rotation composée],
  [`transform-rotate-aer(az, el, roll)`], [azimut / élévation / roulis],
  [`transform-shear-x(f)` `-z(f)`], [cisaillement],
)

#ex(```typc
// composer soi-même une transformation
let m = matrix.mul-mat(
  matrix.transform-translate(2, 0, 0),
  matrix.transform-rotate-z(30deg),
  matrix.transform-scale(1.4),
)
rect((0,0), (1.5,1), stroke: gray)
transform(m)
rect((0,0), (1.5,1), stroke: blue + 1pt)
```, ratio: 60%)

#note(title: "Ordre des produits")[
  `mul-mat(A, B)` applique *B d'abord*, puis A — comme en algèbre linéaire.
  Un `transform(m)` s'ajoute à la transformation courante ; `set-transform(m)`
  la remplace.
]

= Étendre CeTZ

== Marques personnalisées : `register-mark`

#api("register-mark(symbol, body, mnemonic: none, tip: none, base: none, ..)")

`body` est une fonction `style => éléments`. Les ancres `tip` et `base` disent à
CeTZ où la pointe se situe et où le chemin doit s'arrêter.

#ex(```typc
register-mark("flag", style => {
  anchor("tip", (0, 0))
  anchor("base", (style.length, 0))
  line((0,0), (style.length, 0),
       (style.length, style.width / 2), close: true,
       fill: style.fill, stroke: style.stroke)
}, mnemonic: "F")

line((0,1), (3,1), mark: (end: "flag", fill: red))
line((0,.4), (3,.4), mark: (end: "F", fill: blue, scale: 2))
```, ratio: 60%)

#note(title: "Piège vérifié en 0.5.2")[
  Déclarez les ancres `tip`/`base` *à l'intérieur* de `body`, avec `anchor(..)`.
  Les paramètres homonymes `tip:` et `base:` de `register-mark` construisent bien
  les ancres, mais la fonction insère `body` au lieu de la version augmentée :
  ils restent sans effet et la marque échoue avec
  `dictionary does not contain key "tip"`.
]

== Systèmes de coordonnées personnalisés

#api("register-coordinate-resolver(resolver)")

Le résolveur est une fonction `(ctx, coord) => coord`. Il est *scopé* au groupe
courant.

#ex(```typc
// un système de coordonnées logarithmique
register-coordinate-resolver((ctx, c) => {
  if type(c) == dictionary and "log" in c {
    c = c.log.map(n => calc.log(n, base: 10))
  }
  return c
})
line((0,0), (4,0), mark: (end: ">"))
for v in (1, 10, 100, 1000, 10000) {
  circle((log: (v, 1)), radius: .1, fill: blue)
  content((log: (v, 1)), anchor: "north", padding: .2, text(6pt)[#v])
}
```, ratio: 58%)

== Éléments réutilisables

Un « élément » CeTZ n'est rien d'autre qu'une fonction qui renvoie des éléments.
Enveloppez-la dans un `group` nommé pour lui donner des ancres.

#ex(```typc
let resistor(a, b, name: none) = group(name: name, {
  decorations.zigzag(line(a, b), amplitude: .2, segments: 6)
  anchor("west", a)
  anchor("east", b)
})
let source(pos, name: none) = group(name: name, {
  circle(pos, radius: .35)
  content(pos, text(8pt)[$~$])
})
source((0,0), name: "s")
resistor((1.2,0), (3.2,0), name: "r1")
line("s.east", "r1.west")
line("r1.east", (4.4,0), (4.4,-1.2), (0,-1.2), "s.south")
```, ratio: 58%)

== Interroger le contexte

#ex(```typc
get-ctx(ctx => {
  // ctx.length, ctx.style, ctx.transform, ctx.nodes …
  content((0,.4), text(7pt)[unité : #ctx.length])
  content((0,0), text(7pt)[éléments connus : #ctx.nodes.keys().len()])
})
circle((0,0), radius: .01, name: "invisible")
```, ratio: 60%)

#note(title: "set-ctx")[
  `set-ctx(ctx => { ctx.foo = 1; ctx })` permet de stocker ses propres données
  dans le contexte, lisibles plus loin via `get-ctx`. Utile pour écrire des
  bibliothèques d'éléments qui se coordonnent entre eux.
]
