#import "tpl.typ": *

= Transformations

Les transformations sont *cumulatives* et affectent tout ce qui suit dans le
groupe courant. Enfermez-les dans un `scope` pour les limiter.

== `translate`

#ex(```typc
rect((0,0), (1,1), stroke: gray)
scope({ translate((1.5, 0)); rect((0,0), (1,1), stroke: blue) })
scope({ translate(x: 3, y: .5); rect((0,0), (1,1), stroke: red) })
```, ratio: 62%)

== `rotate`

#ex(```typc
for (i, a) in (0deg, 20deg, 40deg, 60deg).enumerate() {
  scope({
    rotate(a)
    rect((0,0), (2,.4), stroke: (blue, red, green, orange).at(i))
  })
}
// rotation autour d'un point donné
scope({ rotate(45deg, origin: (4,0)); rect((3.5,-.5), (4.5,.5), stroke: purple) })
```, ratio: 62%)

== `scale`

#ex(```typc
circle((0,0), radius: .5, stroke: gray)
scope({ scale(1.6); circle((0,0), radius: .5, stroke: blue) })
scope({ scale(x: 2, y: .5); circle((2,0), radius: .5, stroke: red) })
```, ratio: 62%)

== `set-origin` et `move-to`

#ex(```typc
circle((0,0), radius: .1, fill: black)
set-origin((2,1))          // (0,0) est déplacé ici
circle((0,0), radius: .1, fill: red)
rect((-.4,-.4), (.4,.4), stroke: red)
```, ratio: 62%)

#ex(```typc
// move-to déplace seulement le "point précédent"
line((0,0), (1,1))
move-to((2,0))
line((), (rel: (1,1)), stroke: blue)
```, ratio: 62%)

== `set-viewport`

Remappe un rectangle sur un autre — pratique pour tracer dans des unités
« métier ».

#ex(```typc
rect((0,0), (4,2), stroke: gray)
set-viewport((0,0), (4,2), bounds: (100, 50))
// désormais on dessine en coordonnées 0..100 × 0..50
line((0,0), (100,50), stroke: blue)
circle((50,25), radius: 10, stroke: red)
```, ratio: 62%)

== Matrices : `set-transform` / `transform`

#ex(```typc
// cisaillement manuel
transform(((1, .4, 0, 0), (0, 1, 0, 0), (0, 0, 1, 0), (0, 0, 0, 1)))
rect((0,0), (2,1), stroke: blue)
```, ratio: 62%)

= Dessin 3D

== `ortho` — projection isométrique

#ex(```typc
ortho({
  on-xy({ rect((-1,-1), (1,1), fill: red.transparentize(50%)) })
  on-xz({ rect((-1,-1), (1,1), fill: green.transparentize(50%)) })
  on-zy({ rect((-1,-1), (1,1), fill: blue.transparentize(50%)) })
})
```, ratio: 62%)

#ex(```typc
// un cube
ortho(x: 30deg, y: 30deg, {
  for z in (-1, 1) {
    on-xy(z: z, rect((-1,-1), (1,1), fill: blue.transparentize(70%)))
  }
  for (x, y) in ((-1,-1), (1,-1), (1,1), (-1,1)) {
    line((x, y, -1), (x, y, 1))
  }
})
```, ratio: 62%)

== `perspective`

#ex(```typc
perspective(x: 30deg, y: 30deg, {
  for z in (-1, 1) {
    on-xy(z: z, rect((-1,-1), (1,1), fill: orange.transparentize(70%)))
  }
  for (x, y) in ((-1,-1), (1,-1), (1,1), (-1,1)) {
    line((x, y, -1), (x, y, 1))
  }
})
```, ratio: 62%)

#note(title: "Paramètres utiles")[
  `ortho(x:, y:, z:, sorted: true, cull-face: none, flatten: false, …)` et
  `perspective(x:, y:, z:, distance: auto, …)`. `cull-face: "cw"` ou `"ccw"`
  supprime les faces arrière~; `sorted` trie les objets de l'arrière vers l'avant.
]

== Plans de travail `on-xy` / `on-xz` / `on-zy`

#ex(```typc
ortho({
  on-xy(z: 0, { grid((-1,-1), (1,1), stroke: gray + .3pt)
                content((0,0))[xy] })
  on-xz(y: -1, { circle((0,0), radius: .6, stroke: red)
                 content((0,0), text(fill: red)[xz]) })
})
```, ratio: 62%)
