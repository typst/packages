#import "tpl.typ": *

= Styles

== Trois niveaux de style

#table(columns: (auto, 1fr), stroke: 0.4pt + bd, inset: 5pt,
  fill: (_, y) => if y == 0 { bg },
  [*Niveau*], [*Exemple*],
  [par élément], [`circle((0,0), fill: red)`],
  [par contexte], [`set-style(fill: red)` — vaut pour la suite du groupe],
  [par racine], [`set-style(circle: (fill: red))` — ne vise que les cercles],
)

#ex(```typc
set-style(stroke: (paint: blue, thickness: 1pt), fill: blue.lighten(85%))
circle((0,0), radius: .6)
rect((1.2,-.6), (2.4,.6))
// surcharge locale
circle((3.6,0), radius: .6, fill: red.lighten(70%), stroke: red)
```, ratio: 62%)

#ex(```typc
// style par racine : seuls les cercles sont touchés
set-style(circle: (fill: orange.lighten(60%), stroke: orange),
          rect: (stroke: (dash: "dashed")))
circle((0,0), radius: .6)
rect((1.2,-.6), (2.4,.6))
```, ratio: 62%)

#note(title: "Héritage")[
  La valeur `auto` d'une clé de style signifie « hérite de l'ancêtre le plus
  proche ». Ainsi `set-style(stroke: red)` colore aussi les traits des `circle`,
  dont `circle.stroke` vaut `auto` par défaut.
]

== Raccourcis `fill` et `stroke`

#ex(```typc
fill(yellow)       // = set-style(fill: yellow)
stroke(2pt + red)  // = set-style(stroke: 2pt + red)
circle((0,0), radius: .6)
rect((1.4,-.6), (2.6,.6))
```, ratio: 62%)

== Clés de style principales

#table(columns: (auto, auto, 1fr), stroke: 0.4pt + bd, inset: 5pt,
  fill: (_, y) => if y == 0 { bg }, align: left,
  [*Clé*], [*Défaut*], [*Effet*],
  [`fill`], [`none`], [couleur, dégradé ou motif de remplissage],
  [`fill-rule`], [`"non-zero"`], [`"non-zero"` ou `"even-odd"`],
  [`stroke`], [`1pt` noir], [trait (type `stroke` Typst ou dictionnaire)],
  [`radius`], [`1`], [rayon par défaut des cercles/polygones],
  [`padding`], [`none`], [marge (nombre, tableau ou dictionnaire)],
  [`mark`], [voir §5], [flèches et symboles de chemin],
  [`shorten`], [`"LINEAR"`], [raccourcissement des béziers pour les marques],
)

== Remplissages avancés

#ex(```typc
circle((0,0), radius: .8,
  fill: gradient.linear(blue, purple, angle: 45deg))
circle((2,0), radius: .8,
  fill: gradient.radial(yellow, red))
rect((3.2,-.8), (4.8,.8),
  fill: gradient.linear(..color.map.viridis), stroke: none)
```, ratio: 62%)

#ex(```typc
// non-zero vs even-odd sur un chemin auto-sécant
compound-path(fill: blue.lighten(60%), fill-rule: "non-zero", {
  n-star((0,0), 5, inner-radius: 45%)
})
compound-path(fill: blue.lighten(60%), fill-rule: "even-odd", {
  n-star((2.6,0), 5, inner-radius: 45%)
})
```, ratio: 62%)

= Marques (flèches)

== Mnémoniques

Chaque mnémonique est un raccourci d'une forme de marque~:

#ex(```typc
let ms = (">", "<", "<>", "[]", "]", "[", "|",
          "o", "+", "x", "*", ")>", ">>", ")")
for (i, m) in ms.enumerate() {
  let y = -i * .42
  line((0, y), (1.6, y), mark: (end: m))
  content((1.9, y), anchor: "west", raw("\"" + m + "\""))
}
```, ratio: 55%)

== Noms de formes

#ex(```typc
let ms = ("triangle", "stealth", "curved-stealth", "bar", "ellipse",
          "circle", "bracket", "diamond", "rect", "hook", "straight",
          "barbed", "plus", "x", "star", "parenthesis")
for (i, m) in ms.enumerate() {
  let (cx, cy) = (int(i / 8) * 4.2, calc.rem(i, 8) * -.45)
  line((cx, cy), (cx + 1.4, cy), mark: (end: m))
  content((cx + 1.7, cy), anchor: "west", text(7pt, raw(m)))
}
```, ratio: 55%)

== Position et combinaisons

#ex(```typc
line((0,3), (3,3), mark: (end: ">"))
line((0,2.4), (3,2.4), mark: (start: ">", end: ">"))
line((0,1.8), (3,1.8), mark: (symbol: ">"))        // aux deux bouts
line((0,1.2), (3,1.2), mark: (end: (">", ">")))    // marques multiples
line((0,.6), (3,.6), mark: (end: ">", pos: 50%))   // au milieu
line((0,0), (3,0), mark: (end: ">", harpoon: true))
```, ratio: 62%)

== Taille, remplissage, inclinaison

#ex(```typc
line((0,2.4), (3,2.4), mark: (end: ">", scale: 2))
line((0,1.8), (3,1.8), mark: (end: ">", length: .5, width: .5))
line((0,1.2), (3,1.2), mark: (end: ">", fill: red), stroke: red)
line((0,.6), (3,.6), mark: (end: ">", slant: 60%))
line((0,0), (3,0), mark: (end: ">", flip: true, harpoon: true))
```, ratio: 62%)

#note(title: "Style de marque global")[
  `set-style(mark: (fill: black, scale: 1.4))` s'applique à toutes les marques
  suivantes. Les clés utiles~: `length` `width` `inset` `sep` `scale`
  `pos` `offset` `slant` `harpoon` `flip` `reverse` `anchor`
  (`"tip"`, `"center"`, `"base"`), `shorten-to`, `transform-shape`.
]

== Marques sur les courbes

#ex(```typc
bezier((0,0), (4,0), (1,2), (3,-2),
  stroke: blue, mark: (start: ">", end: ">", fill: blue))
catmull((0,-1.5), (1.3,-.6), (2.6,-2), (4,-1.2),
  stroke: red, mark: (end: "stealth", fill: red))
```, ratio: 62%)

== `mark` comme élément autonome

#ex(```typc
line((0,0), (3,1), stroke: gray)
mark((0,0), (3,1), symbol: ">", scale: 3)
mark((1.5,.5), (3,1), symbol: "stealth", anchor: "center", scale: 3,
     fill: red, stroke: red)
```, ratio: 62%)
