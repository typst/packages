#import "tpl.typ": *

= Recettes avancées

== Automate à états finis

#ex(```typc
let state(pos, name, label, accept: false) = {
  circle(pos, radius: .45, name: name, fill: white)
  if accept { circle(pos, radius: .38) }
  content(pos, text(8pt, label))
}
let trans(a, b, label, bend: 25deg) = {
  let m = (a, 50%, b)
  bezier(a, b, (m, .6, bend, a), mark: (end: "stealth", fill: black),
         name: "t")
  content("t.50%", anchor: "south", padding: .08, text(6pt, label))
}
state((0,0), "q0", $q_0$)
state((3,0), "q1", $q_1$)
state((6,0), "q2", $q_2$, accept: true)
line((-1.1,0), "q0.west", mark: (end: "stealth"))
trans("q0.north-east", "q1.north-west", "a")
trans("q1.north-east", "q2.north-west", "b")
trans("q1.south-west", "q0.south-east", "b")
```, ratio: 55%)

== Réseau de neurones

#ex(```typc
let layers = (3, 4, 2)
for (l, n) in layers.enumerate() {
  for i in range(n) {
    let y = (n - 1) / 2 - i
    circle((l * 2.2, y * 1.1), radius: .28,
      fill: (blue, teal, orange).at(l).lighten(70%),
      stroke: (blue, teal, orange).at(l),
      name: "n" + str(l) + "-" + str(i))
  }
}
for l in range(layers.len() - 1) {
  for i in range(layers.at(l)) {
    for j in range(layers.at(l + 1)) {
      line("n" + str(l) + "-" + str(i),
           "n" + str(l + 1) + "-" + str(j),
           stroke: gray.lighten(30%) + .4pt)
    }
  }
}
```, ratio: 55%)

== Diagramme de Gantt

#ex(```typc
let tasks = (
  ("Analyse",    0, 3, blue),
  ("Conception", 2, 5, teal),
  ("Dev",        4, 9, green),
  ("Test",       8, 11, orange),
)
// grille et échelle
for x in range(0, 12) {
  line((x, .4), (x, -tasks.len() * .7), stroke: gray.lighten(60%) + .3pt)
  if calc.rem(x, 2) == 0 {
    content((x, .5), text(6pt)[S#x], anchor: "south")
  }
}
for (i, (nom, a, b, c)) in tasks.enumerate() {
  let y = -i * .7
  rect((a, y - .22), (b, y + .22), radius: .08,
       fill: c.lighten(60%), stroke: c)
  content((a - .2, y), anchor: "east", text(7pt, nom))
}
```, ratio: 52%, len: .72cm)

== Cercle trigonométrique

#ex(```typc
let a = 50deg
circle((0,0), radius: 2, stroke: gray)
line((-2.4,0), (2.4,0), mark: (end: ">"), stroke: .6pt)
line((0,-2.4), (0,2.4), mark: (end: ">"), stroke: .6pt)
line((0,0), (a, 2), stroke: blue + 1pt, name: "r")
// projections
line("r.end", (calc.cos(a) * 2, 0),
     stroke: (paint: red, dash: "dashed"))
line("r.end", (0, calc.sin(a) * 2),
     stroke: (paint: green, dash: "dashed"))
content((calc.cos(a), -.25), text(7pt, fill: red)[cos])
content((-.35, calc.sin(a)), text(7pt, fill: green)[sin])
angle-lib.angle((0,0), (1,0), "r.end", radius: .6,
                label: $alpha$, stroke: blue)
```, ratio: 55%)

== Empilement 3D avec tri de profondeur

#ex(```typc
ortho(x: 30deg, y: 30deg, {
  for (i, c) in (red, orange, yellow, green).enumerate() {
    let z = i * .45
    on-xy(z: z, {
      rect((-1.2 + i * .12, -1.2 + i * .12),
           (1.2 - i * .12, 1.2 - i * .12),
           fill: c.lighten(50%), stroke: c.darken(20%))
    })
  }
})
```, ratio: 55%)

== Carte de chaleur

#ex(```typc
let data = ((1, 5, 3, 8), (7, 2, 9, 4), (3, 6, 1, 7))
let mx = 9
for (i, row) in data.enumerate() {
  for (j, v) in row.enumerate() {
    rect((j * .8, -i * .8), (j * .8 + .8, -i * .8 - .8),
         fill: blue.transparentize(100% - v / mx * 100%),
         stroke: white + 1pt)
    content((j * .8 + .4, -i * .8 - .4),
            text(7pt, fill: if v > 5 { white } else { black })[#v])
  }
}
```, ratio: 55%)

== Chronogramme (signaux logiques)

#ex(```typc
let signal(y, bits, label) = {
  content((-.3, y + .2), anchor: "east", text(7pt, label))
  let pts = ()
  for (i, b) in bits.enumerate() {
    pts.push((i * .7, y + b * .4))
    pts.push((i * .7 + .7, y + b * .4))
  }
  line(..pts, stroke: blue + 1pt)
  for i in range(1, bits.len()) {
    if bits.at(i) != bits.at(i - 1) {
      line((i * .7, y), (i * .7, y + .4), stroke: blue + 1pt)
    }
  }
}
signal(0,    (0,1,1,0,1,0,0,1), "CLK")
signal(-1,   (1,1,0,0,1,1,0,0), "D")
signal(-2,   (0,0,1,1,0,0,1,1), "Q")
```, ratio: 55%)

== Molécule / graphe chimique

#ex(```typc
// la 2e liaison est décalée vers l'intérieur du cycle :
// on raccourcit aussi ses extrémités pour l'esthétique
let bond(a, b, double: false) = {
  line(a, b, stroke: 1pt)
  if double {
    let d = vector.norm(vector.sub(b, a))
    let n = vector.scale((-d.at(1), d.at(0), 0), -.16)
    line(vector.add(vector.lerp(a, b, .12), n),
         vector.add(vector.lerp(a, b, .88), n), stroke: 1pt)
  }
}
// hexagone du benzène — vector.* exige des points cartésiens,
// on convertit donc les coordonnées polaires nous-mêmes
let r = 1.2
let pts = range(6).map(i => {
  let a = 60deg * i
  (calc.cos(a) * r, calc.sin(a) * r, 0)
})
for i in range(6) {
  bond(pts.at(i), pts.at(calc.rem(i + 1, 6)),
       double: calc.rem(i, 2) == 0)
}
```, ratio: 55%)

== Papier millimétré / motif répété

#ex(```typc
// motif de fond réutilisable via un groupe et des transformations
let tile = {
  circle((0,0), radius: .08, fill: blue.lighten(50%), stroke: none)
}
for i in range(0, 8) {
  for j in range(0, 4) {
    scope({
      translate((i * .55, j * .55))
      tile
    })
  }
}
rect((-.3,-.3), (4.15,2.0), stroke: blue.lighten(40%))
```, ratio: 55%)
