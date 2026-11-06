#import "tpl.typ": *

= Couverture complémentaire

Les derniers recoins de l'API : options du `canvas`, styles complets des
décorations, champs des nœuds d'arbre, et les fonctions de `plot` non encore
montrées.

== `canvas` : `x`, `y`, `z`, `background`, `stroke`

#ex(```typc
// x/y/z redéfinissent les vecteurs de base du repère
circle((0,0), radius: .5, fill: blue.lighten(70%))
line((0,0), (2,0), mark: (end: ">"))
line((0,0), (0,2), mark: (end: ">"))
```, ratio: 58%)

#exr(```typ
// y: -1 inverse l'axe vertical (repère écran)
#cetz.canvas(y: -1, background: luma(96%), padding: .2, {
  import cetz.draw: *
  line((0,0), (2,0), mark: (end: ">"))
  line((0,0), (0,2), mark: (end: ">"))
  content((1.2,1.2))[y vers le bas]
})
```, ratio: 58%)

#exr(```typ
// vecteurs de base obliques -> repère « isométrique » 2D
#cetz.canvas(x: (1, 0), y: (.5, .8), {
  import cetz.draw: *
  grid((0,0), (3,2), stroke: gray + .4pt)
  rect((0,0), (2,1), fill: orange.transparentize(60%))
})
```, ratio: 58%)

== Décorations : le style au complet

#ex(```typc
// amplitude peut être une fonction : elle reçoit un RATIO
// (0%..100%) et doit renvoyer un nombre
decorations.wave(line((0,1.6), (6,1.6)),
  amplitude: r => r / 100% * .5, segments: 30, stroke: blue)
// … ou un tableau, utilisé cycliquement
decorations.zigzag(line((0,.8), (6,.8)),
  amplitude: (.15, .4, .25), segments: 12, stroke: red)
// segment-length fixe la taille au lieu du nombre
decorations.coil(line((0,0), (6,0)),
  amplitude: .3, segment-length: .5, stroke: green)
```, ratio: 55%)

#ex(```typc
// factor : forme du zigzag et du créneau
for (i, f) in (0%, 50%, 100%).enumerate() {
  decorations.zigzag(line((0, -i * .9), (4, -i * .9)),
    amplitude: .3, segments: 6, factor: f, stroke: blue)
  content((4.3, -i * .9), anchor: "west", text(6pt)[factor: #f])
}
```, ratio: 55%)

#ex(```typc
// coil : factor = dépassement (bouclage) ; wave : tension
decorations.coil(line((0,1), (4,1)), amplitude: .3,
  segments: 8, factor: 250%, stroke: purple)
decorations.wave(line((0,0), (4,0)), amplitude: .3,
  segments: 8, tension: 1.2, stroke: teal)
```, ratio: 55%)

== `brace` : accolade effilée

#ex(```typc
// taper + fill : accolade calligraphique
decorations.brace((0,0), (4,0), amplitude: .5,
  thickness: .08, pointiness: 40%,
  fill: black, stroke: none)
decorations.brace((0,-1.4), (4,-1.4), amplitude: .5,
  pointiness: 100%, stroke: blue)
```, ratio: 55%)

== Arbres : champs du nœud et alignement

#ex(```typc
tree.tree(
  ([R], ([A], [A1], [A2]), ([B], [B1])),
  spread: 1.3, grow: 1.4,
  // le nœud expose .content .depth .n .children .name
  draw-node: node => {
    let c = (blue, teal, orange).at(calc.min(node.depth, 2))
    content((0,0), padding: .12, frame: "rect", radius: .1,
      fill: c.lighten(80%), stroke: c,
      text(7pt)[#node.content #text(5pt, fill: gray)[d#node.depth]])
  })
```, ratio: 55%)

#ex(```typc
// direction et anchor : aligner l'arbre sur sa racine
for (i, d) in ("down", "right").enumerate() {
  scope({
    translate((i * 4.2, 0))
    tree.tree(([o], ([a], [b]), [c]), direction: d,
              grow: 1.2, spread: 1.1, anchor: "0")
  })
}
```, ratio: 55%)

== `plot` : types de ligne

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
let d = ((0,1), (1,2.4), (2,1.6), (3,3), (4,2.2))
plot.plot(size: (6, 3.5), x-tick-step: 1, y-tick-step: 1,
          legend: "inner-north-west", {
  plot.add(d, line: "raw", label: "raw")
  plot.add(d, line: "hv", label: "hv",
           style: (stroke: red))
  plot.add(d, line: "spline", label: "spline",
           style: (stroke: green))
})
```, ratio: 52%)

Types disponibles : `"raw"` (défaut), `"linear"`, `"spline"`
(avec `tension`, `samples`), `"vh"`, `"hv"`, `"hvh"` (avec `mid`).

== `plot` : hypographe, épigraphe, remplissage

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
plot.plot(size: (6, 3), x-tick-step: 2, y-tick-step: 1, {
  plot.add(domain: (-4, 4), x => calc.sin(x),
    hypograph: true, style: (stroke: blue))
  plot.add(domain: (-4, 4), x => calc.cos(x),
    epigraph: true, style: (stroke: red))
})
```, ratio: 52%)

== `plot.annotate` : dessiner dans les coordonnées du tracé

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
plot.plot(size: (6, 3), x-tick-step: 2, y-tick-step: 1, {
  plot.add(domain: (0, 2 * calc.pi), calc.sin)
  plot.annotate(background: true, {
    rect((0, -1), (calc.pi, 1), fill: blue.transparentize(85%),
         stroke: none)
  })
  plot.annotate({
    content((calc.pi / 2, 1), anchor: "south",
            text(7pt, fill: blue)[maximum])
    line((calc.pi, -1), (calc.pi, 1),
         stroke: (paint: red, dash: "dashed"))
  })
})
```, ratio: 52%)

== `plot.add-bar` : barres dans un tracé

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
plot.plot(size: (6, 3), x-tick-step: 1, y-tick-step: 2, {
  plot.add-bar(((0, 3), (1, 5), (2, 2), (3, 6)),
               bar-width: .6, style: (fill: teal.lighten(50%),
                                      stroke: teal))
})
```, ratio: 52%)

== `plot.add-contour` : lignes de niveau

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
plot.plot(size: (4.5, 4.5), x-tick-step: 1, y-tick-step: 1, {
  plot.add-contour(
    (x, y) => x * x + y * y,
    x-domain: (-2, 2), y-domain: (-2, 2),
    x-samples: 30, y-samples: 30,
    z: (.5, 1.5, 3), fill: true,
    style: (stroke: blue, fill: blue.transparentize(85%)))
})
```, ratio: 52%)

== `plot.add-violin` : distribution

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
// chaque entrée est (x, <tableau de valeurs>) et les bornes
// des axes doivent être fixées à la main
plot.plot(size: (5, 3.5), x-tick-step: 1, y-tick-step: 2,
  x-min: 0, x-max: 3, y-min: 0, y-max: 9, {
  plot.add-violin((
    (1, (3, 4, 4.5, 5, 6, 6.5, 5.5, 4.2)),
    (2, (2, 3, 3.5, 4, 7, 3.2, 3.8)),
  ), side: "both", bandwidth: .8,
     style: (fill: purple.transparentize(70%), stroke: purple))
})
```, ratio: 52%)

#note(title: "add-violin en 0.1.4")[
  Deux contraintes non documentées : les données sont des couples
  `(x, (v1, v2, …))` — pas une liste de points — et `x-min`/`x-max`/`y-min`/`y-max`
  sont *obligatoires*, sinon l'axe échoue avec `Axis min and max must be set`.
  `side` vaut `"left"`, `"right"` (défaut) ou `"both"`.
]

== `plot` : légende et ancres personnalisées

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
plot.plot(size: (6, 3), x-tick-step: 2, y-tick-step: 1,
  legend: "inner-south-east",
  legend-style: (fill: white, stroke: gray, padding: .2), {
  plot.add(domain: (-4, 4), calc.sin, label: $sin$)
  // une ancre nommée, utilisable après le plot
  plot.add-anchor("sommet", (calc.pi / 2, 1))
}, name: "p")
circle("p.sommet", radius: .1, fill: red)
```, ratio: 52%)

== `plot.formats` : formats de graduation

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
plot.plot(size: (5.5, 2.4), x-tick-step: 1, y-tick-step: 5e5,
  y-format: plot.formats.sci,
  x-format: plot.formats.decimal.with(digits: 1), {
  plot.add(domain: (0, 4), x => x * 3e5)
})
```, ratio: 52%)

== `chart.piechart` : étiquettes et éclatement

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": chart
chart.piechart(
  ((30, [Web]), (25, [Mobile]), (20, [Desktop]), (25, [Autre])),
  value-key: 0, label-key: 1,
  radius: 2, outset: (0,), outset-offset: .3,
  slice-style: cetz.palette.tango,
  inner-radius: .5)
```, ratio: 52%)

== `chart.columnchart` : mode empilé

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": chart
let data = (("Q1", 4, 3, 2), ("Q2", 6, 2, 4), ("Q3", 3, 5, 3))
chart.columnchart(data, mode: "stacked", value-key: (1, 2, 3),
  size: (6, 3.5), y-tick-step: 4,
  labels: ([A], [B], [C]), legend: "inner-north-west")
```, ratio: 52%)

== `smartart` : options de mise en forme

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": smartart
smartart.process.basic(([Un], [Deux], [Trois]),
  equal-width: true, dir: rtl,
  step-style: cetz.palette.blue)
```, ratio: 52%)

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": smartart
smartart.cycle.basic(([A], [B], [C], [D], [E]),
  radius: 2, ccw: true, step-style: cetz.palette.rainbow)
```, ratio: 52%)
