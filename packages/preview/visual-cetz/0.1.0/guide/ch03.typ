#import "tpl.typ": *

= Les formes de base

== `line` — segments et lignes brisées

#api("line(..pts, close: false, name: none, ..style)")

#ex(```typc
line((0,0), (2,1))
line((0,-1), (1,-.2), (2,-1), (3,-.3), stroke: blue)
line((0,-2), (1.4,-1.4), (2.8,-2), close: true,
     fill: orange.lighten(60%), stroke: orange)
```, ratio: 60%)

#ex(```typc
// tous les styles de trait Typst sont acceptés
line((0,2), (4,2), stroke: 2pt + blue)
line((0,1.5), (4,1.5), stroke: (paint: red, dash: "dashed"))
line((0,1), (4,1), stroke: (paint: green, dash: "dotted", thickness: 1.5pt))
line((0,.5), (4,.5), stroke: (paint: black, cap: "round", thickness: 4pt))
```, ratio: 62%)

== `rect` — rectangles

#api("rect(a, b, name: none, anchor: none, ..style)")

#ex(```typc
rect((0,0), (2,1.2))
rect((2.5,0), (4.5,1.2), fill: blue.lighten(70%), stroke: blue)
rect((5,0), (7,1.2), radius: .3, fill: orange.lighten(60%))
rect((0,-1.7), (2,-.5), radius: (north: 50%, rest: 0), fill: teal.lighten(60%))
rect((2.5,-1.7), (4.5,-.5), radius: (north-west: .5, south-east: .5),
     stroke: teal + 1pt)
```, ratio: 60%)

#note(title: "rayon des coins")[
  `radius` accepte un nombre, un ratio, un couple `(rx, ry)`, ou un dictionnaire
  avec les clés `north` `south` `east` `west` `north-west` `north-east`
  `south-west` `south-east` `rest`.
]

== `circle` et `circle-through`

#api("circle(center, radius: 1, name: none, anchor: none, ..style)")

#ex(```typc
circle((0,0))
circle((2.5,0), radius: .7, fill: red.lighten(70%), stroke: red)
// rayon (rx, ry) -> ellipse
circle((5,0), radius: (1.2, .6), fill: blue.lighten(80%))
```, ratio: 60%)

#ex(```typc
// cercle passant par trois points
circle-through((0,0), (2,.5), (1,2), stroke: blue, name: "c")
for p in ((0,0), (2,.5), (1,2)) { circle(p, radius: .06, fill: red) }
circle("c.center", radius: .05, fill: black)
```, ratio: 60%)

== `arc` et `arc-through`

#api("arc(position, start: auto, stop: auto, delta: auto, mode: \"OPEN\", anchor: none, ..style)")

Exactement *deux* des trois paramètres `start`, `stop`, `delta` doivent être donnés.

#ex(```typc
arc((0,0), start: 0deg, stop: 120deg)
arc((2.5,0), start: 45deg, delta: 180deg, stroke: blue)
arc((5,0), stop: 90deg, delta: 90deg, stroke: red)
```, ratio: 62%)

#ex(```typc
// mode : OPEN (défaut), CLOSE, PIE
arc((0,0), start: 30deg, stop: 150deg, mode: "OPEN", stroke: black)
arc((3,0), start: 30deg, stop: 150deg, mode: "CLOSE",
    fill: blue.lighten(70%), stroke: blue)
arc((6,0), start: 30deg, stop: 150deg, mode: "PIE",
    fill: orange.lighten(60%), stroke: orange)
```, ratio: 62%)

#ex(```typc
// arc passant par trois points
arc-through((0,0), (1,1), (2,0), stroke: 1pt + purple)
```, ratio: 60%)

== `polygon` et `n-star`

#ex(```typc
polygon((0,0), 3, fill: red.lighten(70%), stroke: red)
polygon((2.5,0), 5, fill: blue.lighten(70%), stroke: blue)
polygon((5,0), 8, angle: 22.5deg, fill: green.lighten(70%), stroke: green)
```, ratio: 58%)

#ex(```typc
n-star((0,0), 5, fill: yellow, stroke: orange)
n-star((2.5,0), 8, inner-radius: 70%, fill: blue.lighten(70%), stroke: blue)
n-star((5,0), 6, inner-radius: 30%, show-inner: true, stroke: red)
```, ratio: 58%)

== `grid`

#api("grid(from, to, step: 1, help-lines: false, name: none, ..style)")

#ex(```typc
grid((0,0), (3,2), stroke: gray + .4pt)
grid((4,0), (7,2), step: .5, stroke: blue.lighten(50%) + .3pt)
grid((8,0), (11,2), step: (x: 1, y: .5), stroke: red.lighten(40%))
```, ratio: 58%)

== `content` — insérer du contenu Typst

#api("content(position, [body], angle: 0deg, anchor: none, name: none, ..style)")
#api("content(a, b, [body], ..)", "Le contenu est mis à l'échelle dans le rectangle a–b.")

#ex(```typc
content((0,0))[Texte simple]
content((0,-1), text(fill: red)[Coloré])
content((0,-2), angle: 30deg)[Tourné]
content((3,-1), padding: .2, frame: "rect",
        fill: yellow.lighten(60%), stroke: orange)[Encadré]
content((3,-2.2), padding: .2, frame: "circle",
        fill: blue.lighten(70%))[Bulle]
```, ratio: 60%)

#ex(```typc
// deux coordonnées -> contenu ajusté à la boîte
rect((0,0), (4,1.5), stroke: gray)
content((0,0), (4,1.5))[Contenu redimensionné dans la boîte]
```, ratio: 60%)

== Courbes : `bezier`, `bezier-through`, `catmull`, `hobby`

#ex(```typc
// bezier(depart, arrivee, ctrl1, [ctrl2])
bezier((0,0), (3,0), (1.5,2))                        // quadratique
bezier((0,-1.5), (3,-1.5), (1,.2), (2,-3), stroke: blue)  // cubique
```, ratio: 60%)

#ex(```typc
let pts = ((0,0), (1,1.2), (2,-.4), (3,.8))
for p in pts { circle(p, radius: .06, fill: black) }
catmull(..pts, stroke: blue, tension: .5)
hobby(..pts, stroke: red)
bezier-through(pts.at(0), pts.at(1), pts.at(3), stroke: green)
```, ratio: 60%)

#note(title: "catmull vs hobby")[
  `catmull` (spline de Catmull–Rom, style `tension`) et `hobby`
  (algorithme de John Hobby, style `omega`) passent tous deux par les points
  donnés~; `hobby` produit des courbes plus « esthétiques », plus proches de
  `plot[smooth]`/METAFONT.
]

== `merge-path` et `compound-path`

#ex(```typc
// merge-path : recolle plusieurs chemins en un seul chemin
merge-path(fill: blue.lighten(70%), stroke: blue, close: true, {
  line((0,0), (2,0))
  bezier((2,0), (2,2), (3,.5), (3,1.5))
  line((2,2), (0,2))
})
```, ratio: 60%)

#ex(```typc
// compound-path : plusieurs sous-chemins, une seule règle de remplissage
compound-path(fill: teal.lighten(60%), stroke: teal,
              fill-rule: "even-odd", {
  circle((0,0), radius: 1)
  circle((0,0), radius: .5)
})
compound-path(fill: teal.lighten(60%), stroke: teal,
              fill-rule: "non-zero", {
  circle((3,0), radius: 1)
  circle((3,0), radius: .5)
})
```, ratio: 62%)

== `svg-path`

#ex(```typc
svg-path(("m", (0,0)), ("l", (2,0)), ("c", (0,1), (0,0), (-1,1)),
         ("v", -.5), ("h", -1), ("z",),
         fill: orange.lighten(60%), stroke: orange, name: "s")
```, ratio: 62%)

== `rect-around`

Boîte englobante de coordonnées et/ou d'éléments nommés~:

#ex(```typc
circle((0,0), radius: .5, name: "a")
circle((2,1), radius: .8, fill: blue.lighten(80%), name: "b")
rect-around("a", "b", padding: .15,
            stroke: (paint: red, dash: "dashed"))
```, ratio: 62%)
