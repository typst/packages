#import "tpl.typ": *

= Ancres

Tout élément nommé (`name: "x"`) expose des *ancres* que l'on cite
`"x.nom-de-l-ancre"`. Trois familles~:

#table(columns: (auto, 1fr), stroke: 0.4pt + bd, inset: 5pt,
  fill: (_, y) => if y == 0 { bg }, align: left,
  [*Famille*], [*Valeurs*],
  [Boussole], [`north` `north-east` `east` `south-east` `south` `south-west`
   `west` `north-west` `center`, ou un *angle* quelconque],
  [Chemin], [`start` `mid` `end`, ou un *ratio* / une *longueur* le long du chemin],
  [Spécifiques], [`circle`: `center` — `arc`: `arc-start` `arc-end` `origin` `chord-center` —
   `line`: sommets numérotés `"0"`, `"1"`, … — `content`: boîte de texte],
)

== Ancres de boussole

#ex(```typc
rect((0,0), (3,2), name: "r", stroke: gray)
for a in ("north", "north-east", "east", "south-east", "south",
          "south-west", "west", "north-west", "center") {
  circle("r." + a, radius: .07, fill: red)
}
content("r.north", anchor: "south", padding: .15, text(7pt)[north])
content("r.east", anchor: "west", padding: .15, text(7pt)[east])
```, ratio: 62%)

#ex(```typc
circle((0,0), radius: 1.2, name: "c", stroke: gray)
// une ancre peut être un angle arbitraire
for a in (0deg, 40deg, 130deg, 250deg) {
  circle("c." + repr(a), radius: .08, fill: blue)
  line("c.center", "c." + repr(a), stroke: (dash: "dotted"))
}
```, ratio: 62%)

== Ancres de chemin

#ex(```typc
bezier((0,0), (4,0), (1,2), (3,-1), name: "b", stroke: gray)
for (r, c) in ((0%, red), (25%, orange), (50%, green),
               (75%, blue), (100%, purple)) {
  circle("b." + repr(r), radius: .09, fill: c)
}
circle("b.start", radius: .15, stroke: red)
circle("b.end", radius: .15, stroke: purple)
```, ratio: 62%)

== L'argument `anchor:` — placer l'élément par son ancre

#ex(```typc
circle((0,0), radius: .06, fill: red)
// l'ancre "north-west" du rect est posée sur (0,0)
rect((0,0), (2,1), anchor: "north-west", stroke: blue)
circle((3,0), radius: .06, fill: red)
circle((3,0), radius: .7, anchor: "south", stroke: green)
```, ratio: 62%)

== Créer ses propres ancres

#ex(```typc
group(name: "g", {
  circle((0,0), radius: .8)
  anchor("bec", (.8, .8))
  anchor("pied", (0, -.8))
})
circle("g.bec", radius: .08, fill: red)
circle("g.pied", radius: .08, fill: blue)
content("g.bec", anchor: "west", padding: .12, text(7pt)[bec])
```, ratio: 62%)

== Parcourir les ancres : `for-each-anchor`

#ex(```typc
rect((0,0), (4,2), name: "r")
for-each-anchor("r", exclude: ("center", "default"), n => {
  circle((), radius: .06, fill: red)
  content((), text(6pt, n), anchor: "center",
          padding: .1, frame: "rect", fill: white, stroke: none)
})
```, ratio: 62%)

== `copy-anchors`

#ex(```typc
group(name: "outer", {
  circle((0,0), radius: .7, name: "inner")
  copy-anchors("inner")   // outer hérite des ancres de inner
})
circle("outer.east", radius: .07, fill: red)
```, ratio: 62%)

= Groupes, calques et intersections

== `group`

Un groupe isole le contexte (styles, transformations) et devient un élément
nommable avec ses propres ancres.

#ex(```typc
group(name: "g", {
  set-style(fill: blue.lighten(70%), stroke: blue)
  circle((0,0), radius: .5)
  circle((1.2,0), radius: .5)
  rect((-.6,-.6), (1.8,.6), stroke: (dash: "dashed"), fill: none)
})
// le groupe a des ancres de boîte
circle("g.north-east", radius: .08, fill: red)
content("g.south", anchor: "north", padding: .15)[groupe]
```, ratio: 62%)

#ex(```typc
// padding et fond du groupe
group(padding: .3, fill: yellow.lighten(70%), stroke: orange, {
  circle((0,0), radius: .5)
  circle((1.4,.3), radius: .3)
})
```, ratio: 62%)

== `scope` — isoler sans créer d'élément

#ex(```typc
scope({
  scale(1.6)
  stroke(red)
  circle((0,0), radius: .5)
})
circle((2,0), radius: .5)   // ni mis à l'échelle, ni rouge
```, ratio: 62%)

== `hide` et `floating`

#ex(```typc
// hide : calculé (donc ancrable) mais non dessiné
hide(circle((0,0), radius: 1, name: "h"))
line((-1,0), (1,0), stroke: (dash: "dotted"))
circle((1,0), radius: .08, fill: red)
// floating : ne contribue pas aux bornes du canvas
floating(content((2.5,1.5))[hors bornes])
rect((-1,-1), (1,1), stroke: gray)
```, ratio: 62%)

== `on-layer`

#ex(```typc
// numéro de calque plus grand = dessiné au-dessus
rect((0,0), (2,1.2), fill: blue.lighten(60%))
on-layer(-1, circle((1,.6), radius: .8, fill: red))   // dessous
on-layer(1, circle((2,1.2), radius: .5, fill: green)) // dessus
```, ratio: 62%)

== `intersections`

#ex(```typc
intersections(name: "i", "x", {
  circle((0,0), radius: 1)
  line((-1.4,-1), (1.4,1))
})
for-each-anchor("x", n => {
  circle((), radius: .1, fill: red)
})
```, ratio: 62%)

#note(title: "Note")[
  `intersections("nom", { ... })` dessine son contenu et nomme chaque point
  d'intersection `"nom.0"`, `"nom.1"`, … Utilisez `samples:` pour affiner la
  détection sur les courbes, et `sort:` pour ordonner les résultats.
]

== `get-ctx` / `set-ctx`

#ex(```typc
get-ctx(ctx => {
  content((0,0), text(8pt)[unité = #ctx.length])
})
```, ratio: 62%)
