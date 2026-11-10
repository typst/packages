#import "tpl.typ": *

= Recettes

== Diagramme de boîtes et flèches

#ex(```typc
let box(pos, name, body) = {
  rect((rel: (-.9, -.45), to: pos), (rel: (.9, .45), to: pos),
       name: name, radius: .1, fill: blue.lighten(85%), stroke: blue)
  content(name, body)
}
box((0,0),   "a", [Entrée])
box((3.5,0), "b", [Calcul])
box((7,0),   "c", [Sortie])
line("a.east", "b.west", mark: (end: ">"))
line("b.east", "c.west", mark: (end: ">"))
line("b.south", (rel: (0,-1)), (rel: (-3.5,0)), "a.south",
     mark: (end: ">"), stroke: (dash: "dashed"))
```, ratio: 58%)

== Étiqueter une flèche

#ex(```typc
line((0,0), (4,1.5), name: "l", mark: (end: ">"))
content("l.50%", anchor: "south", padding: .1, text(8pt)[$f$])
content("l.start", anchor: "north-east", padding: .1)[A]
content("l.end", anchor: "south-west", padding: .1)[B]
```, ratio: 62%)

== Repère et courbe de fonction

#ex(```typc
let f = x => calc.sin(x) * 1.2
line((-.3,0), (6.6,0), mark: (end: ">"))
line((0,-1.6), (0,1.8), mark: (end: ">"))
content((6.6,0), anchor: "west", padding: .15, $x$)
content((0,1.8), anchor: "south", padding: .15, $y$)
let pts = range(0, 65).map(i => {
  let x = i / 10
  (x, f(x))
})
line(..pts, stroke: blue + 1.2pt)
for x in (0, 2, 4, 6) {
  line((x, -.1), (x, .1))
  content((x, -.1), anchor: "north", text(7pt)[#x])
}
```, ratio: 58%)

== Cotation

#ex(```typc
rect((0,0), (4,1.6), stroke: gray)
set-style(mark: (start: "|", end: "|"), stroke: .6pt)
line((0,-.4), (4,-.4), name: "w")
content("w.50%", anchor: "north", padding: .1, text(8pt)[4 unités])
line((-.4,0), (-.4,1.6), name: "h")
content("h.50%", anchor: "east", padding: .1, text(8pt)[1,6])
```, ratio: 62%)

== Hachures d'une zone (via `boolean`)

#ex(```typc
let region = merge-path(close: true, {
  line((0,0), (3,0))
  bezier((3,0), (0,2), (2.5,2))
})
let hatch = compound-path({
  for i in range(-3, 14) {
    let x = i * .3
    rect((x, 0), (x + .06, 2.2))
  }
})
region
boolean(region, hatch, op: "intersection", fill: blue.lighten(40%),
        stroke: none)
```, ratio: 62%)

== Graphe avec nœuds circulaires

#ex(```typc
let nodes = (("A", (0,0)), ("B", (2.4,1.2)), ("C", (2.4,-1.2)), ("D", (4.8,0)))
let edges = (("A","B"), ("A","C"), ("B","D"), ("C","D"), ("B","C"))
for (n, p) in nodes {
  circle(p, radius: .4, name: n, fill: white, stroke: 1pt)
  content(p, n)
}
for (a, b) in edges { line(a, b, stroke: gray + .8pt) }
```, ratio: 58%)

#note(title: "Astuce")[
  Une ligne entre deux éléments *nommés* est automatiquement raccourcie jusqu'à
  leur bordure : `line("A", "B")` ne traverse pas les cercles.
]

== Placer un dessin dans le texte

#exr(```typ
Un symbole en ligne #cetz.canvas(length: .35cm, baseline: (0, .2), {
  import cetz.draw: *
  circle((0,0), radius: 1, fill: red.lighten(60%), stroke: red)
}) au milieu d'un paragraphe.
```, ratio: 62%)

#note(title: "baseline")[
  `canvas(baseline: <coordonnée>)` aligne la ligne de base du dessin sur cette
  coordonnée du repère, ce qui permet de l'insérer proprement dans une ligne de
  texte. Donnez un couple `(0, .2)`~: en 0.5.2, la forme scalaire déclenche une
  erreur « variables from outside the context expression are read-only ».
]

== Réutiliser un motif

#ex(```typc
// une fonction qui renvoie des éléments = un "motif" paramétrable
let star-at(pos, c) = n-star(pos, 5, radius: .5, inner-radius: 45%,
                             fill: c.lighten(50%), stroke: c)
star-at((0,0), red)
star-at((1.4,.6), blue)
star-at((2.8,0), green)
```, ratio: 62%)
