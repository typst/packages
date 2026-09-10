#import "tpl.typ": *

= Galerie

Des figures complètes, plus longues, qui combinent plusieurs techniques.
Elles servent de point de départ à copier-coller.

== Le théorème de Pythagore

#ex(```typc
let (a, b) = (2.2, 1.5)
// triangle rectangle
line((0,0), (a,0), (0,b), close: true,
     fill: blue.lighten(85%), stroke: blue)
angle-lib.right-angle((0,0), (a,0), (0,b), radius: .3, stroke: blue)
// carré sur chaque côté
line((0,0), (a,0), (a,-a), (0,-a), close: true,
     fill: red.lighten(80%), stroke: red)
content((a/2, -a/2), text(8pt, fill: red)[$a^2$])
line((0,0), (0,b), (-b,b), (-b,0), close: true,
     fill: green.lighten(80%), stroke: green)
content((-b/2, b/2), text(8pt, fill: green)[$b^2$])
// carré sur l'hypoténuse
let h = vector.sub((0,b,0), (a,0,0))
let n = (h.at(1), -h.at(0), 0)
line((a,0), (0,b), vector.add((0,b,0), n),
     vector.add((a,0,0), n), close: true,
     fill: orange.lighten(80%), stroke: orange)
content(vector.add(vector.lerp((a,0,0), (0,b,0), .5),
        vector.scale(n, .5)), text(8pt, fill: orange)[$c^2$])
```, ratio: 52%)

== Coupe géologique / couches empilées

#ex(```typc
let layers = (
  (0.0, 0.5, rgb("#8d6e63"), "sol"),
  (0.5, 1.1, rgb("#a1887f"), "argile"),
  (1.1, 1.5, rgb("#ffd54f"), "sable"),
  (1.5, 2.4, rgb("#90a4ae"), "roche"),
)
for (y0, y1, c, nom) in layers {
  merge-path(close: true, fill: c, stroke: c.darken(25%), {
    // surface ondulée en haut de couche
    hobby((0, -y0), (2, -y0 + .12), (4, -y0 - .1), (6, -y0 + .05))
    line((6, -y0), (6, -y1))
    hobby((6, -y1 + .05), (4, -y1 - .1), (2, -y1 + .12), (0, -y1))
    line((0, -y1), (0, -y0))
  })
  content((6.3, -(y0 + y1) / 2), anchor: "west", text(7pt, nom))
}
```, ratio: 52%)

== Engrenage paramétrique

#ex(```typc
let gear(pos, teeth: 12, r: 1, h: .18, name: none) = {
  let pts = ()
  let step = 360deg / (teeth * 2)
  for i in range(teeth * 2) {
    let a = step * i
    let rr = if calc.rem(i, 2) == 0 { r + h } else { r - h }
    pts.push((pos.at(0) + calc.cos(a) * rr,
              pos.at(1) + calc.sin(a) * rr))
  }
  line(..pts, close: true, fill: gray.lighten(70%),
       stroke: gray.darken(20%), name: name)
  circle(pos, radius: r * .3, fill: white, stroke: gray.darken(20%))
}
gear((0,0), teeth: 14, r: 1.1)
gear((2.5,0), teeth: 10, r: .8)
```, ratio: 52%)

== Rosace (courbe polaire)

#ex(```typc
// r = cos(k·θ) : rosace à k ou 2k pétales
for (k, c) in ((3, blue), (5, red)) {
  let pts = range(0, 361, step: 3).map(d => {
    let t = d * 1deg
    let r = calc.cos(k * t) * 1.4
    (calc.cos(t) * r + (if k == 3 { 0 } else { 3.4 }),
     calc.sin(t) * r)
  })
  line(..pts, close: true, stroke: c + .8pt)
}
```, ratio: 52%)

== Spirale d'Archimède et suite de Fibonacci

#ex(```typc
// spirale : r croît linéairement avec l'angle
let pts = range(0, 1081, step: 6).map(d => {
  let t = d * 1deg
  let r = d / 1080 * 1.8
  (calc.cos(t) * r, calc.sin(t) * r)
})
line(..pts, stroke: gradient.linear(blue, red) + 1.2pt)

// carrés de Fibonacci
let (x, y) = (2.6, -1.8)
let fib = (1, 1, 2, 3, 5)
let s = .3
for (i, f) in fib.enumerate() {
  rect((x, y), (x + f * s, y + f * s),
       stroke: teal, fill: teal.transparentize(90%))
  x += f * s
}
```, ratio: 52%)

== Diagramme de Voronoï (approché)

#ex(```typc
let sites = ((0.6,0.7), (2.1,1.5), (3.4,0.5), (1.6,2.4), (3.2,2.3))
let cols = (red, blue, green, orange, purple)
// échantillonnage : chaque cellule est coloriée point par point
let n = 26
for i in range(n) {
  for j in range(int(n * 0.6)) {
    let p = (i / n * 4, j / (n * 0.6) * 3)
    let best = 0
    let bd = 1e9
    for (k, s) in sites.enumerate() {
      let d = vector.dist((p.at(0), p.at(1), 0), (s.at(0), s.at(1), 0))
      if d < bd { bd = d; best = k }
    }
    rect(p, (rel: (4 / n, 3 / (n * 0.6))), stroke: none,
         fill: cols.at(best).transparentize(80%))
  }
}
for (k, s) in sites.enumerate() {
  circle(s, radius: .09, fill: cols.at(k), stroke: white + .8pt)
}
```, ratio: 52%)

== Carte mentale (arbre stylisé)

#ex(```typc
let node(pos, body, c, name) = {
  content(pos, padding: .18, frame: "rect", name: name,
          fill: c.lighten(80%), stroke: c, radius: .12,
          text(7pt, body))
}
node((0,0), [CeTZ], blue, "root")
let kids = (([Formes], 1.6), ([Styles], .55),
            ([Ancres], -.55), ([3D], -1.6))
for (i, (label, y)) in kids.enumerate() {
  node((3, y), label, (red, orange, green, purple).at(i),
       "k" + str(i))
  bezier("root.east", "k" + str(i) + ".west",
         (1.6, 0), (1.6, y), stroke: gray)
}
```, ratio: 52%)

== Sphère filaire (méridiens et parallèles)

#ex(```typc
ortho(x: 25deg, y: 30deg, {
  let r = 1.4
  // parallèles
  for k in range(-2, 3) {
    let z = k / 3 * r
    let rr = calc.sqrt(calc.max(r * r - z * z, 0))
    on-xy(z: z, circle((0,0), radius: rr,
                       stroke: blue.lighten(40%) + .5pt))
  }
  // méridiens
  for i in range(6) {
    scope({
      rotate(z: 30deg * i)
      on-xz(y: 0, circle((0,0), radius: r,
                         stroke: gray.lighten(20%) + .5pt))
    })
  }
})
```, ratio: 52%)

== Chemin de fer / diagramme syntaxique

#ex(```typc
let term(pos, body, name) = content(pos, padding: .16,
  frame: "rect", radius: .3, fill: blue.lighten(85%),
  stroke: blue, name: name, text(7pt, body))
let nonterm(pos, body, name) = content(pos, padding: .16,
  frame: "rect", fill: orange.lighten(80%),
  stroke: orange, name: name, text(7pt, body))
line((-.6,0), (0,0), mark: (end: ">"))
term((0.6,0), [let], "a")
nonterm((2.2,0), [ident], "b")
term((3.8,0), [=], "c")
nonterm((5.4,0), [expr], "d")
for (p, q) in (("a","b"), ("b","c"), ("c","d")) {
  line(p + ".east", q + ".west", mark: (end: ">"))
}
line("d.east", (6.4,0), mark: (end: ">"))
// boucle de répétition
bezier("d.south", "b.south", (5.4,-1), (2.2,-1),
       stroke: gray, mark: (end: ">"))
content((3.8,-.95), anchor: "north", text(6pt)[répétition])
```, ratio: 52%)
