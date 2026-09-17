#import "tpl.typ": *

= Showcase : détails souvent ignorés

Cette section rassemble les options fines que l'on découvre tard, une fois qu'on
a lu le code source. Chaque exemple isole *une* subtilité.

== `grid` : `shift`, `help-lines`, pas asymétrique

#ex(```typc
grid((0,0), (3,2), step: .5, help-lines: true)
grid((0,0), (3,2), step: 1, stroke: black + .6pt)
// shift décale les lignes sans bouger les bornes
grid((4,0), (7,2), step: 1, shift: .5,
     stroke: red.lighten(30%))
grid((4,0), (7,2), step: (x: 1, y: .5),
     stroke: blue.lighten(60%) + .3pt)
```, ratio: 58%)

== `hobby` : `omega` et tensions par segment

#ex(```typc
let p = ((0,0), (1,1), (2,-1), (3,0))
hobby(..p, omega: 0, stroke: blue)     // proche de la droite
hobby(..p, omega: 1, stroke: red)      // proche de l'arc de cercle
for q in p { circle(q, radius: .05, fill: black) }
```, ratio: 58%)

#ex(```typc
let p = ((0,0), (1.5,1.5), (3,0), (4.5,1.5))
// tension entrante / sortante, une valeur par segment
hobby(..p, ta: (1, 1, 1), tb: (1, 1, 1), stroke: gray)
hobby(..p, ta: (2, .5, 2), tb: (.5, 2, .5), stroke: red + 1pt)
```, ratio: 58%)

== `catmull` : tension et fermeture

#ex(```typc
let p = ((0,0), (1,1), (2,-.5), (3,.8))
for (t, c) in ((0, blue), (.5, green), (1, red)) {
  catmull(..p, tension: t, stroke: c)
}
content((3.4, .8), anchor: "west", text(6pt)[t = 0 / .5 / 1])
```, ratio: 58%)

#ex(```typc
let p = ((0,0), (1.4,.9), (2.2,-.4), (.6,-1.1))
catmull(..p, close: true, fill: orange.lighten(70%), stroke: orange)
```, ratio: 58%)

== `content` : texte le long d'une ligne, `wrap`, `auto-scale`

#ex(```typc
line((0,0), (4,1.5), name: "l", stroke: gray)
// angle: <coordonnée> aligne le texte sur la direction
content(("l.start", 50%, "l.end"), angle: "l.end",
        anchor: "south", padding: .12)[texte sur la ligne]
```, ratio: 58%)

#ex(```typc
// wrap : applique une fonction au contenu
content((0,0), padding: .15, frame: "rect",
        wrap: text.with(fill: white, weight: "bold"),
        fill: blue)[Wrap]
// auto-scale : le contenu suit l'échelle du canvas
scope({
  scale(1.8)
  content((1.6,0), auto-scale: true)[Scalé]
})
```, ratio: 58%)

== `arc` : `update-position` et ancres

#ex(```typc
arc((0,0), start: 0deg, stop: 120deg, radius: 1, name: "a")
for (n, c) in (("arc-start", red), ("arc-end", blue),
               ("origin", green), ("chord-center", orange)) {
  circle("a." + n, radius: .07, fill: c)
}
content((2.6,.6), anchor: "west", text(6pt)[
  #text(fill: red)[arc-start] / #text(fill: blue)[arc-end] \
  #text(fill: green)[origin] / #text(fill: orange)[chord-center]])
```, ratio: 55%)

== `line` : ancres numérotées des sommets

#ex(```typc
line((0,0), (1,1.2), (2.2,.3), (3.4,1),
     name: "p", stroke: blue)
// chaque sommet est une ancre "0", "1", "2", …
for i in range(4) {
  circle("p." + str(i), radius: .08, fill: red)
  content("p." + str(i), anchor: "south",
          padding: .12, text(6pt)[#i])
}
```, ratio: 58%)

== `mark` : `offset`, `sep`, `shorten-to`, `transform-shape`

#ex(```typc
// plusieurs marques, espacement contrôlé par sep
line((0,2), (4,2), mark: (end: (">", ">", ">"), sep: .1))
line((0,1.5), (4,1.5), mark: (end: (">", ">", ">"), sep: .35))
// offset décale la marque le long du chemin
line((0,1), (4,1), mark: (end: ">", offset: -.6))
// anchor : la marque est posée par sa base / son centre
line((0,.5), (4,.5), mark: (end: ">", anchor: "base", scale: 2))
line((0,0), (4,0), mark: (end: ">", anchor: "center", scale: 2))
```, ratio: 58%)

#ex(```typc
// shorten-to : jusqu'à quelle marque le trait est raccourci
line((0,1), (3,1), stroke: 3pt + blue,
     mark: (end: (">", ">"), shorten-to: 0, fill: blue))
line((0,0), (3,0), stroke: 3pt + red,
     mark: (end: (">", ">"), shorten-to: auto, fill: red))
```, ratio: 58%)

== `intersections` : tri des points

#ex(```typc
intersections(name: "i", "x", {
  circle((0,0), radius: 1.2)
  hobby((-2,-1.2), (0,1.9), (2,-1.2), stroke: blue)
  line((-2,.4), (2,.4), stroke: green)
}, samples: 25, sort: cetz.sorting.points-by-angle)
// les points sont numérotés dans l'ordre de tri
for-each-anchor("x", n => {
  circle((), radius: .1, fill: red)
  content((), anchor: "south-west", padding: .1, text(6pt, n))
})
```, ratio: 58%)

== `floating` : ignorer un élément dans les bornes

#ex(```typc
group(name: "g", {
  content((1,0), [Normal])
  content((0,1), [Normal])
  floating(content((.5,1.6), text(fill: red)[Floating]))
})
// le rect ne tient pas compte de l'élément flottant
rect("g.north-west", "g.south-east", stroke: red)
```, ratio: 58%)

== `hide` : calculé mais non dessiné

#ex(```typc
// l'élément caché reste nommable et ancrable
hide(circle((0,0), radius: 1, name: "h"))
circle("h.east", radius: .1, fill: red)
circle("h.north", radius: .1, fill: blue)
line("h.west", "h.south", stroke: (dash: "dotted"))
```, ratio: 58%)

#ex(```typc
// bounds: true -> l'élément caché compte dans les bornes du canvas
// (comparez la taille des deux cadres pointillés)
hide(circle((0,0), radius: .8))
hide(circle((2.6,0), radius: .8), bounds: true)
rect-around((0,0), (2.6,0), padding: .1,
            stroke: (paint: red, dash: "dashed"))
```, ratio: 58%, dbg: true)

== `set-origin` vs `translate`

#ex(```typc
grid((0,0), (5,2), stroke: gray.lighten(60%) + .3pt)
circle((0,0), radius: .12, fill: black)
// translate : cumulatif, déplace le repère
scope({ translate((1,1)); circle((0,0), radius: .2, fill: blue) })
// set-origin : place l'origine sur une coordonnée résolue
scope({ set-origin((3,1)); circle((0,0), radius: .2, fill: red) })
```, ratio: 58%)

== `on-layer` : ordre de peinture indépendant du code

#ex(```typc
// le disque rouge est écrit en premier mais peint au-dessus
on-layer(2, circle((.8,0), radius: .7, fill: red.lighten(30%)))
rect((0,-.7), (1.6,.7), fill: blue.lighten(60%))
circle((0,0), radius: .5, fill: green.lighten(40%))
```, ratio: 58%)

== Ancres par distance ou par ratio

#ex(```typc
bezier((0,0), (5,0), (1,2.5), (4,-1.5), name: "b", stroke: gray)
// ratio : proportion de la longueur
circle("b.30%", radius: .1, fill: blue)
// longueur : distance absolue depuis le départ.
// La forme "b.2cm" n'est pas parsée : il faut le dictionnaire.
circle((name: "b", anchor: 2cm), radius: .1, fill: red)
content((0,-1), anchor: "west", text(6pt)[
  #text(fill: blue)[b.30%] · #text(fill: red)[b.2cm]])
```, ratio: 58%)

== `set-viewport` : inverser un axe

#ex(```typc
rect((0,0), (4,2.4), stroke: gray)
// bounds inversés -> l'axe y pointe vers le bas (repère écran)
set-viewport((0,0), (4,2.4), bounds: (100, -100))
line((0,0), (100,-100), stroke: blue, mark: (end: ">"))
content((50,-50), anchor: "north-west", text(6pt)[y vers le bas])
```, ratio: 58%)

== Dégradés suivant la forme

#ex(```typc
circle((0,0), radius: 1,
  fill: gradient.radial(white, blue, focal-center: (35%, 35%)))
rect((2,-1), (4,1),
  fill: gradient.linear(..color.map.rainbow, angle: 45deg),
  stroke: none)
n-star((5.6,0), 5, radius: 1, inner-radius: 45%,
  fill: gradient.conic(..color.map.plasma))
```, ratio: 55%)

== Motifs (`tiling`)

#ex(```typc
// attention : `line` est ici celui de cetz.draw,
// il faut donc qualifier celui de Typst avec `std.`
let hatch = tiling(size: (6pt, 6pt), {
  place(std.line(start: (0pt, 6pt), end: (6pt, 0pt),
                 stroke: .6pt + blue))
})
rect((0,0), (2.5,1.6), fill: hatch, stroke: blue)
circle((4,.8), radius: .8, fill: hatch, stroke: blue)
```, ratio: 58%)

== Styles imbriqués et `..` d'un dictionnaire

#ex(```typc
let theme = (stroke: (paint: purple, thickness: 1.2pt),
             fill: purple.lighten(80%))
// on peut étaler un dictionnaire de style
circle((0,0), radius: .6, ..theme)
rect((1.4,-.6), (2.6,.6), ..theme)
// … ou l'installer dans le contexte
set-style(..theme)
polygon((4,0), 6)
```, ratio: 58%)
