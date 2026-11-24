#import "tpl.typ": *

= L'écosystème : `cetz-plot`

`cetz-plot` 0.1.4 est le module de tracé officiel, compatible CeTZ 0.5.x.

```typ
#import "@preview/cetz-plot:0.1.4": plot, chart, smartart
```

Dans les exemples ci-dessous, `plot`, `chart` et `smartart` désignent ces
modules, et le tout vit dans un `cetz.canvas`.

== Courbes de fonctions

#api("plot.plot(body, size: (1,1), axis-style: \"scientific\", x-tick-step: auto, ..)")

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
plot.plot(size: (7, 4), x-tick-step: 2, y-tick-step: .5,
          x-label: $x$, y-label: $y$, {
  plot.add(domain: (-6, 6), x => calc.sin(x), label: $sin x$)
  plot.add(domain: (-6, 6), x => calc.cos(x), label: $cos x$,
           style: (stroke: (dash: "dashed")))
})
```, ratio: 52%)

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
// données brutes + marques
plot.plot(size: (6, 3.5), x-tick-step: 1, y-tick-step: 2, {
  plot.add(((0,1), (1,3), (2,2.4), (3,5), (4,4.2)),
           mark: "o", mark-size: .15, label: "mesures")
  plot.add(((0,0.5), (4,4.5)), style: (stroke: red),
           label: "tendance")
})
```, ratio: 52%)

== Styles d'axes

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
plot.plot(size: (4, 2.6), axis-style: "school-book",
          x-tick-step: 2, y-tick-step: 2, {
  plot.add(domain: (-3, 3), x => x * x / 2)
})
```, ratio: 52%)

Valeurs possibles : `"scientific"` (cadre complet, défaut),
`"school-book"` (axes en croix fléchés), `"left"`, `"right"`, `none`.

== Remplissages et zones

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
plot.plot(size: (6, 3), x-tick-step: 2, y-tick-step: 1, {
  plot.add(domain: (-4, 4), x => calc.sin(x), fill: true,
           style: (fill: blue.transparentize(75%), stroke: blue))
  plot.add-hline(0, style: (stroke: gray))
  plot.add-vline(0, style: (stroke: gray))
})
```, ratio: 52%)

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
plot.plot(size: (6, 3), x-tick-step: 1, y-tick-step: 1, {
  let f = x => calc.sin(x)
  let g = x => calc.cos(x)
  // les deux opérandes sont des données ou des fonctions, pas des plot.add
  plot.add-fill-between(f, g, domain: (0, 6),
    style: (fill: green.transparentize(70%), stroke: none))
  plot.add(domain: (0, 6), f, style: (stroke: blue))
  plot.add(domain: (0, 6), g, style: (stroke: red))
})
```, ratio: 52%)

== Échelles et formats de graduation

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
plot.plot(size: (6, 3), x-tick-step: calc.pi, y-tick-step: 1,
  x-format: plot.formats.multiple-of, {
  plot.add(domain: (0, 2 * calc.pi), calc.sin)
})
```, ratio: 52%)

Les formateurs disponibles : `plot.formats.decimal`, `sci` (notation
scientifique), `fraction`, `multiple-of` (multiples de $pi$ par défaut).

== Barres d'erreur, aires, contours

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": plot
plot.plot(size: (5.5, 3), x-tick-step: 1, y-tick-step: 1, {
  let d = ((0,1), (1,2.2), (2,1.6), (3,2.8))
  plot.add(d, mark: "o", mark-size: .12)
  for (x, y) in d {
    plot.add-errorbar((x, y), y-error: .3, style: (stroke: red))
  }
})
```, ratio: 52%)

= Diagrammes : `chart`

== Barres et colonnes

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": chart
let data = (("Lun", 5), ("Mar", 8), ("Mer", 3), ("Jeu", 7), ("Ven", 6))
chart.columnchart(data, size: (6, 3.5), y-tick-step: 2)
```, ratio: 52%)

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": chart
let data = (("A", 12), ("B", 8), ("C", 15), ("D", 5))
chart.barchart(data, size: (6, 3), x-tick-step: 5,
               bar-style: cetz.palette.blue)
```, ratio: 52%)

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": chart
// barres groupées : mode "clustered"
let data = (("T1", 5, 3), ("T2", 7, 6), ("T3", 4, 8))
chart.columnchart(data, mode: "clustered", value-key: (1, 2),
                  size: (6, 3), y-tick-step: 2,
                  labels: ([produit A], [produit B]),
                  legend: "inner-north-east")
```, ratio: 52%)

== Camembert

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": chart
chart.piechart((25, 30, 20, 25), radius: 2,
               slice-style: cetz.palette.rainbow,
               inner-radius: .4,
               label-key: none)
```, ratio: 52%)

== Radar

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": chart
// radarchart(labels, data) : étiquettes en premier
chart.radarchart(
  ([vitesse], [force], [magie], [chance], [défense]),
  ((5, 4, 3, 5, 2).map(v => v / 5),
   (2, 5, 4, 1, 4).map(v => v / 5)),
  data-style: cetz.palette.blue)
```, ratio: 52%)

#note(title: "Normalisez entre 0 et 1")[
  Malgré une assertion qui autorise `0 <= valeur <= radius`, les valeurs sont
  interprétées comme une *fraction du rayon* en 0.1.4 : au-delà de 1, la toile de
  fond et les étiquettes disparaissent et le tracé déborde. Divisez donc toujours
  vos données par leur maximum. Styles utiles : `web-style`, `web-ticks`,
  `web-label-offset`, `radius`, `center-pos`.
]

== Boîte à moustaches

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": chart
chart.boxwhisker((
  (label: [A], min: 1, q1: 3, q2: 4, q3: 6, max: 9),
  (label: [B], min: 2, q1: 3.5, q2: 5, q3: 7, max: 8,
   outliers: (11, .5)),
), size: (4, 4), label-key: "label", y-tick-step: 2)
```, ratio: 52%)

= Diagrammes de Venn : `cetz-venn`

```typ
#import "@preview/cetz-venn:0.2.0" as venn
```

#ex(```typc
// #import "@preview/cetz-venn:0.2.0" as venn
venn.venn2(name: "v", a-fill: red.transparentize(60%),
           b-fill: blue.transparentize(60%))
content("v.a", [A])
content("v.b", [B])
content("v.ab", [A∩B])
```, ratio: 55%)

#ex(```typc
// #import "@preview/cetz-venn:0.2.0" as venn
venn.venn3(name: "v",
  a-fill: red.transparentize(70%),
  b-fill: green.transparentize(70%),
  c-fill: blue.transparentize(70%))
for k in ("a", "b", "c", "ab", "bc", "ac", "abc") {
  content("v." + k, text(7pt, raw(k)))
}
```, ratio: 55%)

#note(title: "Attributs de set")[
  Chaque ensemble accepte `*-fill`, `*-stroke`, `*-layer`, `*-radius`,
  `*-distance`, `*-anchor-outset`, préfixés par son nom : `a-fill`, `b-radius`, …
  Les noms d'ensembles sont aussi des *ancres* : `a`, `b`, `ab`, `not-ab`
  (et `c`, `bc`, `ac`, `abc`, `not-abc` pour `venn3`).
]

= SmartArt : processus et cycles

== Processus linéaire

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": smartart
smartart.process.basic(
  ([Analyse], [Conception], [Réalisation], [Test]),
  equal-width: true, equal-height: true)
```, ratio: 52%)

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": smartart
smartart.process.chevron(
  ([Idée], [Prototype], [Produit]),
  equal-width: true)
```, ratio: 52%)

== Cycle

#ex(```typc
// #import "@preview/cetz-plot:0.1.4": smartart
smartart.cycle.basic(
  ([Planifier], [Faire], [Vérifier], [Agir]),
  radius: 2.2)
```, ratio: 52%)
