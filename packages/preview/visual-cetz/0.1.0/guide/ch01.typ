#import "tpl.typ": *

= Prise en main

== Installation & squelette minimal

#exr(```typ
#import "@preview/cetz:0.5.2"
#cetz.canvas({
  import cetz.draw: *
  circle((0, 0), radius: 1)
  line((-1, 0), (1, 0), mark: (end: ">"))
})
```, ratio: 62%)

#note(title: "Règle d'or")[
  Un `canvas` prend un *bloc de code* (`{...}`), pas du contenu markup.
  Les fonctions de dessin s'importent depuis `cetz.draw`. Le tout est évalué
  paresseusement~: chaque fonction renvoie une liste d'éléments, elle ne dessine rien
  immédiatement.
]

== Le conteneur `canvas`

#api("canvas(body, length: 1cm, debug: false, background: none, padding: none)")

- `length` — longueur d'une unité du repère (1 unité = 1~cm par défaut).
- `debug` — affiche le repère, les bornes et l'origine.
- `background` — couleur/pattern de fond.
- `padding` — marge autour du dessin (nombre, tableau ou dictionnaire).

#ex(```typc
grid((0,0), (2,2), stroke: gray + .3pt)
circle((1,1), radius: .8, fill: blue.lighten(70%))
```, dbg: true)

#ex(```typc
// length: 0.5cm -> même dessin, deux fois plus petit
circle((1,1), radius: .8, fill: blue.lighten(70%))
```, len: 0.5cm)

== Anatomie d'un appel

#ex(```typc
//     coordonnées      nom        style
line((0,0), (3,1), name: "l", stroke: 2pt + orange)
// le nom permet de réutiliser les ancres
circle("l.end", radius: .2, fill: red)
content("l.start", anchor: "east", padding: .1)[A]
```, ratio: 62%)

Trois familles d'arguments reviennent partout~:

#table(columns: (auto, 1fr), stroke: 0.4pt + bd, inset: 5pt,
  fill: (_, y) => if y == 0 { bg },
  [*Argument*], [*Rôle*],
  [positionnels], [coordonnées ou contenu de la forme],
  [`name:`], [nom de l'élément, pour interroger ses ancres plus tard],
  [`anchor:`], [ancre de l'élément qui sera placée sur la coordonnée donnée],
  [`..style`], [paires clé-valeur de style (`fill`, `stroke`, `radius`, `mark`, …)],
)

== Convention de ce guide pour les imports

Les exemples supposent toujours l'import de base, sous-entendu~:

```typ
#import "@preview/cetz:0.5.2"
#cetz.canvas({
  import cetz.draw: *
  ...
})
```

Dès qu'un exemple utilise un *autre* paquet, sa ligne d'import figure en
commentaire sur la première ligne du code~:

```typc
// #import "@preview/cetz-plot:0.1.4": plot
plot.plot(size: (4, 2), { plot.add(domain: (-2, 2), x => x * x) })
```

== Panorama des fonctions

#table(columns: (auto, 1fr), stroke: 0.4pt + bd, inset: 5pt, align: (left, left),
  fill: (_, y) => if y == 0 { bg },
  [*Catégorie*], [*Fonctions*],
  [Formes],
  [`line` `rect` `circle` `circle-through` `arc` `arc-through` `polygon` `n-star`
   `grid` `content` `bezier` `bezier-through` `catmull` `hobby` `merge-path`
   `compound-path` `svg-path` `rect-around` `mark`],
  [Style], [`set-style` `fill` `stroke` `register-mark`],
  [Groupes], [`group` `scope` `anchor` `copy-anchors` `for-each-anchor` `hide`
   `floating` `on-layer` `intersections` `get-ctx` `set-ctx`],
  [Transformations], [`translate` `rotate` `scale` `set-origin` `move-to`
   `set-transform` `transform` `set-viewport`],
  [Booléens], [`boolean` (`union`, `intersection`, `difference`, `xor`)],
  [3D], [`ortho` `perspective` `on-xy` `on-xz` `on-zy`],
  [Bibliothèques], [`cetz.tree` `cetz.angle` `cetz.decorations` `cetz.palette`],
)
