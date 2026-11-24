#import "tpl.typ": *

= Opérations booléennes

#api("boolean(a, b, op: \"difference\", fill-rule-a: auto, fill-rule-b: auto, name: none, ..style)")

Les opérandes sont soit des éléments, soit le *nom* d'un élément déjà dessiné.
Tous les sous-chemins doivent être fermés et coplanaires.

#ex(```typc
let a = circle((0,0), radius: .55)
let b = circle((.6,0), radius: .55)
for (i, op) in ("union", "intersection", "difference", "xor").enumerate() {
  scope({
    translate((i * 1.9, 0))
    boolean(a, b, op: op, fill: blue.lighten(60%), stroke: blue)
    content((.3, -1), text(6pt, raw(op)))
  })
}
```, ratio: 55%)

#ex(```typc
rect((-1,-1), (1,0), name: "r", stroke: (dash: "dotted"))
circle((0,0), radius: .8, name: "c", stroke: (dash: "dotted"))
boolean("r", "c", op: "difference", fill: orange.lighten(50%), stroke: orange)
```, ratio: 62%)

= Décorations

Toutes les décorations prennent un *chemin cible* et acceptent
`amplitude`, `segments` ou `segment-length`, `start`, `stop`, `name`.

== `zigzag`, `coil`, `wave`, `square`

#ex(```typc
let fns = (decorations.zigzag, decorations.coil,
           decorations.wave, decorations.square)
let names = ("zigzag", "coil", "wave", "square")
for (i, f) in fns.enumerate() {
  let y = -i * 1.2
  line((0, y), (4, y), stroke: gray.lighten(50%))
  f(line((0, y), (4, y)), amplitude: .3, stroke: blue)
  content((4.3, y), anchor: "west", text(7pt, raw(names.at(i))))
}
```, ratio: 55%)

#ex(```typc
// start / stop : portion décorée du chemin
line((0,0), (4,0), stroke: gray)
decorations.coil(line((0,0), (4,0)), amplitude: .3,
                 start: 20%, stop: 80%, segments: 8, stroke: red)
```, ratio: 62%)

#ex(```typc
// une décoration marche sur n'importe quel chemin
decorations.wave(circle((0,0), radius: 1), amplitude: .2,
                 segment-length: .4, stroke: purple)
```, ratio: 62%)

== Accolades : `brace` et `flat-brace`

#ex(```typc
decorations.brace((0,0), (4,0))
decorations.brace((0,-1), (4,-1), amplitude: .6, stroke: blue)
decorations.brace((0,-2.4), (4,-2.4), flip: true, stroke: red)
```, ratio: 62%)

#ex(```typc
decorations.flat-brace((0,0), (4,0), name: "b")
content("b.content", anchor: "south")[largeur]
decorations.flat-brace((0,-1.4), (4,-1.4), aspect: 25%, stroke: blue)
decorations.flat-brace((0,-2.4), (4,-2.4), outer-curves: 0, stroke: red)
```, ratio: 62%)

#note(title: "Ancres des accolades")[
  `start`, `end`, `spike`, `content`, `center`. L'ancre `content` est le point
  idéal pour poser l'étiquette, décalée devant la pointe.
]

= Angles

#api("cetz.angle.angle(origin, a, b, direction: \"ccw\", label: none, name: none, ..style)")

`direction` vaut `"ccw"` (défaut), `"cw"`, `"near"` (angle intérieur) ou `"far"`
(angle extérieur). Les ancres produites sont `a`, `b`, `origin`, `label`,
`start`, `end`.

#ex(```typc
line((0,0), (60deg, 2.4), name: "a")
line((0,0), (-20deg, 2.4), name: "b")
angle-lib.angle("a.start", "a.end", "b.end", label: $alpha$,
                fill: blue.lighten(80%), stroke: blue, radius: 1)
```, ratio: 62%)

#ex(```typc
line((0,0), (70deg, 2.4), name: "a")
line((0,0), (0deg, 2.4), name: "b")
// étiquette calculée à partir de la valeur de l'angle
// ccw : de b vers a ; "near" prendrait toujours l'angle intérieur
angle-lib.angle("a.start", "b.end", "a.end", radius: 1.2,
  mark: (end: ">"), stroke: red,
  label: v => text(8pt)[#calc.round(v / 1deg)°])
```, ratio: 62%)

#ex(```typc
line((0,0), (0,2), name: "a")
line((0,0), (2.4,0), name: "b")
angle-lib.right-angle("a.start", "a.end", "b.end", radius: .5, stroke: green)
```, ratio: 62%)

= Arbres

#api("cetz.tree.tree(root, draw-node: auto, draw-edge: auto, direction: \"down\", grow: 1, spread: 1, name: none)")

Un arbre est un tableau imbriqué~: `(racine, enfant1, enfant2, …)`.

#ex(```typc
tree.tree(([A], ([B], [D], [E]), ([C], [F])), spread: 1.4, grow: 1.2)
```, ratio: 62%)

#ex(```typc
tree.tree(
  ([*root*], ([a], [a1], [a2]), ([b], [b1])),
  direction: "right", grow: 2, spread: 1.2,
  // node : dictionnaire avec .content, .depth, .group-name
  draw-node: node => {
    circle((0,0), radius: .35, fill: blue.lighten(80%), stroke: blue)
    content((0,0), text(7pt, node.content))
  },
  // parent / child : nœuds ; .group-name donne le nom de l'élément
  draw-edge: (parent, child) => {
    line(parent.group-name, child.group-name,
         mark: (end: ">"), stroke: gray)
  })
```, ratio: 62%)

= Palettes

#ex(```typc
let p = palette.new(colors: (red, blue, green, orange, purple))
for i in range(0, p("len")) {
  set-style(..p(i))
  circle((i * 1.1, 0), radius: .45)
}
```, ratio: 62%)

#ex(```typc
// palettes prédéfinies + variation par trait
let p = palette.new(colors: palette.tango-colors)
for i in range(0, p("len")) {
  rect((i * .8, 0), (i * .8 + .6, 1), ..p(i))
}
let d = palette.new(colors: (black,),
                    dash: ("solid", "dashed", "dotted", "densely-dotted"))
for i in range(0, d("len")) {
  line((0, -.5 - i * .35), (7, -.5 - i * .35), ..d(i, fill: false, stroke: true))
}
```, ratio: 58%)

#note(title: "Palettes prêtes à l'emploi")[
  `cetz.palette` expose directement `gray`, `red`, `orange`, `light-green`,
  `dark-green`, `turquoise`, `cyan`, `blue`, `indigo`, `purple`, `magenta`,
  `pink`, `rainbow`, `tango`, `tango-light`, `tango-dark`, ainsi que les listes
  de couleurs correspondantes (`tango-colors`, …). Utilisez
  `p(i, fill: false, stroke: true)` pour colorer le trait plutôt que le fond,
  et `p("len")` pour connaître le nombre de variantes.
]

#ex(```typc
for (i, p) in (palette.rainbow, palette.blue, palette.tango-dark).enumerate() {
  for j in range(0, p("len")) {
    rect((j * .55, -i * .8), (j * .55 + .5, -i * .8 + .6), ..p(j))
  }
}
```, ratio: 58%)
