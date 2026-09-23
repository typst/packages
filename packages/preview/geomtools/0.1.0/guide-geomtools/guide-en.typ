#import "@preview/geomtools:0.1.0": *
#import "helpers.typ": *

#set page(
  paper: "a4",
  margin: (x: 1.7cm, y: 1.85cm),
  numbering: "1",
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 8pt, fill: luma(110), font: "DejaVu Serif")
      grid(columns: (1fr, 1fr),
        [geomtools — user guide],
        align(right)[Drawing instruments],
      )
      v(-0.35em)
      line(length: 100%, stroke: 0.4pt + luma(200))
    }
  },
)
#set text(size: 10.2pt, font: "DejaVu Serif", lang: "en", fill: ink)
#set par(justify: true, leading: 0.72em)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  block(above: 0.4em, below: 0.75em, {
    text(size: 16pt, weight: "bold", fill: blue, it)
    v(-0.5em)
    line(length: 100%, stroke: 0.9pt + blue)
  })
}
#show heading.where(level: 2): it => block(above: 1.15em, below: 0.5em,
  text(size: 12pt, weight: "bold", fill: rgb("#1C3D5A"), it))
#show heading.where(level: 3): it => block(above: 0.9em, below: 0.4em,
  text(size: 10.6pt, weight: "bold", style: "italic", it))
#show raw: set text(font: "DejaVu Sans Mono", size: 7.7pt)
#show raw.where(block: true): it => block(
  width: 100%, fill: luma(248), stroke: 0.4pt + luma(220),
  inset: 7pt, radius: 3pt, above: 0.45em, below: 0.55em, it,
)
#show strong: set text(fill: rgb("#16324F"))

#let cap(t) = align(center, text(size: 8pt, fill: luma(90), style: "italic", t))
#let note(title, body) = block(
  width: 100%, fill: rgb("#E7F5FF"), stroke: 0.7pt + blue,
  inset: 9pt, radius: 4pt, above: 0.6em, below: 0.6em,
  {
    text(weight: "bold", fill: blue, size: 9pt, title)
    v(0.2em)
    body
  },
)
#let warn(title, body) = block(
  width: 100%, fill: rgb("#FFF4E6"), stroke: 0.7pt + orange,
  inset: 9pt, radius: 4pt, above: 0.55em, below: 0.55em,
  {
    text(weight: "bold", fill: orange, size: 9pt, title)
    v(0.2em)
    body
  },
)

#let A = A0
#let B = B0
#let C = C0
#let O = circumcenter(A, B, C)
#let I = incenter(A, B, C)
#let G = centroid(A, B, C)
#let H = orthocenter(A, B, C)
#let R = dist(O, A)
#let r-in = I.at(1)
#let Ma = midp(B, C)
#let Mb = midp(A, C)
#let Mc = midp(A, B)
#let Ha = foot(A, B, C)
#let Hb = foot(B, A, C)
#let Hc = foot(C, A, B)
#let Ta = foot(I, B, C)
#let Tb = foot(I, A, C)
#let Tc = foot(I, A, B)

#let rAB = 4.5
#let (Pab, Qab) = circ-inter(A, rAB, B, rAB)
#let P-ab = if Pab.at(1) > Qab.at(1) { Pab } else { Qab }
#let Q-ab = if Pab.at(1) > Qab.at(1) { Qab } else { Pab }

#let rAC = 4.2
#let (Pac, Qac) = circ-inter(A, rAC, C, rAC)
#let toward-b = vsub(B, midp(A, C))
#let P-ac = if dotp(vsub(Pac, midp(A, C)), toward-b) > 0 { Pac } else { Qac }
#let Q-ac = if dotp(vsub(Pac, midp(A, C)), toward-b) > 0 { Qac } else { Pac }

#let r-bis = 2.05
#let P-angA = lerp(A, B, r-bis / dist(A, B))
#let Q-angA = lerp(A, C, r-bis / dist(A, C))
#let r-bis2 = 1.85
#let (Ra1, Ra2) = circ-inter(P-angA, r-bis2, Q-angA, r-bis2)
#let R-A = farther(A, Ra1, Ra2)

#let P-angB = lerp(B, A, r-bis / dist(B, A))
#let Q-angB = lerp(B, C, r-bis / dist(B, C))
#let (Rb1, Rb2) = circ-inter(P-angB, r-bis2, Q-angB, r-bis2)
#let R-B = farther(B, Rb1, Rb2)

#align(center)[
  #v(0.4em)
  #text(size: 11pt, fill: blue, tracking: 1.4pt)[USER GUIDE]
  #v(0.15em)
  #text(size: 28pt, weight: "bold")[geomtools]


  #v(1em) 

  #text(size: 13pt, fill: luma(68))[#emoji.hand.write FERGOUS Abdelhak]

  #v(1em)
  
  #text(size: 12.5pt, fill: luma(70))[
    Drawing instruments for a geometry figure
  ]
  #v(0.15em)
  #text(size: 10pt, fill: luma(100))[
    ruler · pencil · set square · protractor · compass
  ]
]

#v(0.55em)

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += line-ext(P-ab, Q-ab, beyond: 0.3, stroke: blue.lighten(45%), weight: 0.55)
  fig += line-ext(P-ac, Q-ac, beyond: 0.3, stroke: blue.lighten(45%), weight: 0.55)
  fig += p-line(A, Ma, stroke: orange.lighten(25%), weight: 0.7, role: "edge")
  fig += p-line(B, Mb, stroke: orange.lighten(25%), weight: 0.7, role: "edge")
  fig += p-line(C, Mc, stroke: orange.lighten(25%), weight: 0.7, role: "edge")
  fig += p-line(A, Ha, stroke: purple.lighten(30%), weight: 0.7, role: "edge")
  fig += p-line(B, Hb, stroke: purple.lighten(30%), weight: 0.7, role: "edge")
  fig += p-line(C, Hc, stroke: purple.lighten(30%), weight: 0.7, role: "edge")
  fig += p-line(A, Ta, stroke: green.lighten(25%), weight: 0.65, role: "edge")
  fig += p-line(B, Tb, stroke: green.lighten(25%), weight: 0.65, role: "edge")
  fig += p-line(C, Tc, stroke: green.lighten(25%), weight: 0.65, role: "edge")
  fig += p-circle(O, R, stroke: blue, weight: 1.35)
  fig += p-circle(I, r-in, stroke: green, weight: 1.25)
  fig += line-ext(O, H, beyond: 0.55, stroke: red, weight: 1.05, dash: none)
  fig += pt(O, fill: blue, r: 0.09)
  fig += pt(I, fill: green, r: 0.09)
  fig += pt(G, fill: orange, r: 0.09)
  fig += pt(H, fill: purple, r: 0.09)
  fig += lab(O, text(fill: blue)[$O$], dx: 0.28, dy: -0.28, fill: blue)
  fig += lab(I, text(fill: green)[$I$], dx: -0.30, dy: 0.22, fill: green)
  fig += lab(G, text(fill: orange)[$G$], dx: 0.28, dy: 0.22, fill: orange)
  fig += lab(H, text(fill: purple)[$H$], dx: -0.28, dy: 0.26, fill: purple)
  fig
}, padding: 0.55))
#cap[Triangle $A B C$ used throughout, its four centres, and Euler's line $(O G H)$.]

#v(0.4em)

#grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 8pt,
  align(center)[
    #text(fill: blue, weight: "bold")[$O$ circumcentre]\
    #text(size: 8.5pt, fill: luma(80))[perp. bisectors, compass]
  ],
  align(center)[
    #text(fill: green, weight: "bold")[$I$ incentre]\
    #text(size: 8.5pt, fill: luma(80))[angle bisectors, compass]
  ],
  align(center)[
    #text(fill: orange, weight: "bold")[$G$ centroid]\
    #text(size: 8.5pt, fill: luma(80))[medians, ruler]
  ],
  align(center)[
    #text(fill: purple, weight: "bold")[$H$ orthocentre]\
    #text(size: 8.5pt, fill: luma(80))[altitudes, set square]
  ],
)

#v(0.7em)

The Typst package `geomtools` lays the *geometer's instruments* on a
figure: ruler, pencil, set square, protractor, compass — crisp like the
LaTeX original, or “hand-drawn”. This guide introduces them, then uses
them to *construct* the four centres of a triangle, with their markings
(equal-length ticks, right angles, bisector arcs).

It is a port of Cédric Pierquet's `OutilsGeomTikZ`. No CeTZ: the tools
are plain lists of polygons, arcs and labels.

#outline(indent: 1em, depth: 2)

= The package in two minutes

== Local install

The package is not (yet) on Universe. Import it by path:

```typ
#import "path/to/geomtools/lib.typ": *
```

Everything the package exports lives in `geom`: you pass it a *list of
primitives* — what each instrument *returns*, not Typst content.

```typ
#geom({
  ruler(length: 10)
  pencil(at: (3, 2), rotate: -20deg)
})
```

Inside a `{ ... }` block, Typst *joins* arrays. You can also write
`ruler(...) + pencil(...)` with `+`, which is more explicit, and that is
what every listing in this guide does.

== Two modes, one geometry

#grid(columns: (1fr, 1fr), column-gutter: 12pt,
  [
    #align(center, geom(ruler(length: 7, width: 1.5), padding: 0.3))
    #cap[`mode: "clean"` — the default]
  ],
  [
    #align(center, geom(ruler(length: 7, width: 1.5), mode: "rough", padding: 0.3))
    #cap[`mode: "rough"`]
  ],
)

```typ
#geom(ruler(length: 7))
#geom(ruler(length: 7), mode: "rough", roughness: 2, seed: 4)
#geom-rough(ruler(length: 7))
```

The wobble is *deterministic*: same `seed`, same figure on every compile.
Numerals are never wobbled — a hand-drawn “3” would be a different
typeface, not a shakier 3.

== What you compose

| Function | Role on a construction |
|---|---|
| `compass(from, to)` | needle at `from`, lead at `to` — the opening is exact |
| `set-square` | 30-60-90 set square, right angle at the origin |
| `ruler` | zero at the origin, running right |
| `right-angle` | right-angle *mark* (open square, not the tool) |
| `pencil` | pencil, tip at the origin pointing up |
| `p-line` `p-arc` `p-circle` `p-label` | the figure itself |

Common arguments: `at`, `rotate`, `scale`, `colour`, `fill`. The French
keys of the original (`Longueur`, `Origine`…) map to English (`length`,
`at`…).

#note[Textbook convention][
  *The solid stroke is the figure; the dash is the trace of the instrument*
  — the one you rub out afterwards. Every primitive takes `dash: "dashed"`.
  A construction arc is therefore:

  ```typ
  p-arc(A, 4.5, 20deg, 160deg, stroke: luma(120), dash: "dashed")
  ```
]

= The canvas and the toolbox

Coordinates are in *centimetres*, $y$ pointing *up* (mathematical
orientation). The renderer flips the axis once.

== Helpers already exported

`vadd` `vsub` `vmul` `vnorm` `dist` `vangle` `arc-pts` `circle-pts`
`rect-pts` — plus the constructors `p-poly` `p-line` `p-circle` `p-arc`
`p-label`.

`vangle((x, y))` is the bearing of the vector, $0 degree$ on $+x$,
$90 degree$ on $+y$. That is the angle you pass to `rotate`.

== Helpers in this guide

`helpers.typ` adds what a construction needs:

- `midp(A, B)`, `unit(v)`, `lerp(A, B, t)`, `foot(P, A, B)`
- `circ-inter(P, r1, Q, r2)` — the two intersections of two circles
- `line-inter(P1, P2, Q1, Q2)` — intersection of two lines
- `circumcenter` `incenter` `centroid` `orthocenter`
- `ticks(P, Q, n: 1)` — equal-length marks at the midpoint of $[P Q]$
- `right-angle` (from the package) and `ang-mark` — angle markings
- `square-on(at, along, toward)` — seats the set square on a line, right
  angle turned toward a point

The working triangle, used everywhere:

$ A = (0, 0), quad B = (7.2, 0), quad C = (2.2, 4.8) $

It is *scalene* and *acute*: the four centres are distinct and
*interior*, and the feet of the altitudes fall on the sides (not on their
extensions). $A B$ lies on the $x$-axis, which makes the reading easier
without making the figure special.

```typ
#let A = (0.0, 0.0)
#let B = (7.2, 0.0)
#let C = (2.2, 4.8)
```

= Protractor, and a pencil at the end of the stroke

To *measure* $angle B A C$, centre the protractor at $A$ and align its
base with $(A B)$. Side $[A C]$ meets the scale at the size of the angle
(here $approx 65 degree$).

When you *draw a line*, it often helps to put a pencil at its end: the
lead sits on the tip, the barrel follows the stroke.
`pencil-tip(from, to)` does that — `pencil`'s tip is at the origin and
points up, hence `rotate: vangle(to − from) - 90deg`.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += protractor(at: A, rotate: 0deg, scale: 0.58, radians: false,
    colour: luma(45), value-size: 0.65)
  fig += pencil-tip(A, C, colour: rgb("#2B6CB0"), lead: rgb("#2B6CB0"),
    length: 3.6, scale: 0.78)
  fig
}, padding: 0.4))
#cap[Protractor at $A$, base on $(A B)$. The pencil sits at the end of $[A C]$.]

```typ
#protractor(at: A, rotate: 0deg, scale: 0.58, radians: false)
#pencil-tip(A, C, colour: rgb("#2B6CB0"), lead: rgb("#2B6CB0"))
```

`scale` shrinks the protractor (original radius $3.75$ cm) without moving
the centre. `radians: false` hides the $pi/6$, $pi/4$… band if you only
want degrees. For a $0 degree$–$360 degree$ disc: `full: true`.

= Circumcircle — with the compass

The *circumcircle* is the unique circle through $A$, $B$ and $C$. Its
centre $O$ is the intersection of the *perpendicular bisectors*. A
perpendicular bisector is built with the compass: two arcs of *equal
radius*, larger than half the side.

#note[What you mark][
  - equal-length ticks $A M = M B$ (the midpoint);
  - *right angles* at the midpoint: the bisector is perpendicular to the side;
  - at the end, $O A = O B = O C$ (the radius), optionally with three small
    arcs, though the circle itself is usually enough.
]

== Step 1 — The triangle

#align(center, geom(
  abc-figure(A, B, C)
  + ruler(at: (0, -0.62), length: 7.2, width: 0.55, clamp: false,
      values: true, value-size: 0.7, colour: luma(70))
  + pencil-tip(A, B, colour: rgb("#C92A2A"), length: 3.5, scale: 0.75),
  padding: 0.4,
))
#cap[Draw $A B$ with the ruler; the pencil sits at the end, at $B$.]

```typ
#geom(
  p-line(A, B, stroke: black, weight: 1.35, role: "edge")
  + p-line(B, C, stroke: black, weight: 1.35, role: "edge")
  + p-line(C, A, stroke: black, weight: 1.35, role: "edge")
  + ruler(at: (0, -0.62), length: 7.2, width: 0.55, clamp: false)
)
```

`clamp: false` is essential: by default a ruler's width is silently
floored at $1.5$ cm, and a ruler you thought was thin sits 8 mm off.

== Step 2 — Compass at $A$, opening larger than half the side

$A B = 7.2$, so $A B slash 2 = 3.6$. Take $4.5$ cm. The arc must be long
enough to meet its twin from $B$, *on both sides* of $(A B)$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, rAB, -55deg, 95deg, stroke: muted, dash: "dashed", weight: 0.9)
  fig += compass(A, P-ab, scale: 0.58, leg: 5.2, flip: false,
    pencil-colour: rgb("#C92A2A"))
  fig
}, padding: 0.45))
#cap[`compass(A, P)` — needle at $A$, lead through a point of the arc.]

```typ
#let rAB = 4.5
#p-arc(A, rAB, -55deg, 95deg, stroke: luma(120), dash: "dashed")
#compass(A, (4.5 * calc.cos(40deg), 4.5 * calc.sin(40deg)), scale: 0.58)
```

The compass *really opens* on the two points:

$ "half-angle" = arcsin( (|italic("to") - italic("from")|) slash (2 "leg" "scale") ) $

`scale` shrinks the instrument *without* moving the feet — essential if
it is to fit the figure. `flip: true` swings it to the other side of the
segment when it would cover the triangle.

== Step 3 — Same opening, needle at $B$

The two arcs meet at $P$ and $Q$. *Do not change the opening*: that is
the whole marking $A P = B P = A Q = B Q$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, rAB, -58deg, 100deg, stroke: muted, dash: "dashed", weight: 0.85)
  fig += p-arc(B, rAB, 80deg, 238deg, stroke: muted, dash: "dashed", weight: 0.85)
  fig += pt(P-ab, fill: blue) + pt(Q-ab, fill: blue)
  fig += lab(P-ab, [$P$], dx: 0.28, dy: 0.18, fill: blue)
  fig += lab(Q-ab, [$Q$], dx: 0.28, dy: -0.28, fill: blue)
  fig += compass(B, P-ab, scale: 0.58, leg: 5.2, flip: true,
    pencil-colour: rgb("#C92A2A"))
  fig
}, padding: 0.45))
#cap[Second arc, *same radius*. $P$ and $Q$ are equidistant from $A$ and from $B$.]

Intersections are computed, not guessed:

```typ
#let (P, Q) = circ-inter(A, rAB, B, rAB)
#compass(B, P, scale: 0.58, flip: true)
```

`circ-inter` (in `helpers.typ`) is the classical intersection of two
circles: project onto the line of centres, then step off
$h = sqrt(r_1^2 - a^2)$.

== Step 4 — The perpendicular bisector of $[A B]$

The line $(P Q)$ is the perpendicular bisector: it cuts $[A B]$ at its
midpoint $M$ and is perpendicular to it. Mark both facts.

#align(center, geom({
  let M = Mc
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, rAB, -50deg, 95deg, stroke: muted, dash: "dashed", weight: 0.7)
  fig += p-arc(B, rAB, 85deg, 230deg, stroke: muted, dash: "dashed", weight: 0.7)
  fig += line-ext(P-ab, Q-ab, beyond: 0.35, stroke: blue, weight: 1.05, dash: none)
  fig += pt(P-ab, fill: blue) + pt(Q-ab, fill: blue) + pt(M, fill: blue)
  fig += lab(P-ab, [$P$], dx: 0.26, dy: 0.16, fill: blue)
  fig += lab(Q-ab, [$Q$], dx: 0.26, dy: -0.28, fill: blue)
  fig += lab(M, [$M$], dx: 0.22, dy: 0.22, fill: blue)
  fig += ticks(A, M, n: 1) + ticks(M, B, n: 1)
  fig += right-angle(at: M, rotate: 0deg, size: 0.32, colour: blue)
  fig
}, padding: 0.4))
#cap[Marking: $A M = M B$ (one tick) and $angle P M B = 90 degree$ (open square).]

```typ
#let M = midp(A, B)
#line-ext(P, Q, stroke: blue, dash: none)
#ticks(A, M, n: 1) + ticks(M, B, n: 1)
#right-angle(at: M, rotate: 0deg, size: 0.32, colour: blue)
```

#warn[`right-angle` is not `mini-square`][
  `mini-square` is a *small set square*: it has a hypotenuse. Dropped into
  an angle, that hypotenuse cuts the corner with a diagonal. A right-angle
  mark is an *open square* — two sides, vertex held back from the corner.
  That is `right-angle`.
]

`rotate` on `right-angle` is the direction of the *first* side. Here
$(A B)$ is horizontal, so `rotate: 0deg` and the square rises into the
triangle. On a side of angle $theta$, pass `rotate: theta`, then add
$90 degree$ or turn it over depending on which side you want the square.

== Step 5 — Perpendicular bisector of $[A C]$

Same gesture: *two arcs of equal radius* meeting at *two* points $P'$ and
$Q'$. Radius $4.2$ cm exceeds $A C slash 2 approx 2.64$. The intersection
of the two perpendicular bisectors is $O$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += arc-through(A, P-ab, Q-ab, extra: 22deg, stroke: muted, weight: 0.6)
  fig += arc-through(B, P-ab, Q-ab, extra: 22deg, stroke: muted, weight: 0.6)
  fig += arc-through(A, P-ac, Q-ac, extra: 28deg, stroke: green, weight: 0.85)
  fig += arc-through(C, P-ac, Q-ac, extra: 28deg, stroke: green, weight: 0.85)
  fig += line-ext(P-ab, Q-ab, beyond: 0.2, stroke: blue, weight: 1.0, dash: none)
  fig += line-ext(P-ac, Q-ac, beyond: 0.45, stroke: green, weight: 1.05, dash: none)
  fig += ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
  fig += ticks(A, Mb, n: 2) + ticks(Mb, C, n: 2)
  fig += right-angle(at: Mc, rotate: 0deg, size: 0.28, colour: blue)
  fig += ra-in(Mb, vsub(C, A), vsub(B, Mb), size: 0.28, colour: green)
  fig += pt(P-ab, fill: blue) + pt(Q-ab, fill: blue)
  fig += pt(P-ac, fill: green) + pt(Q-ac, fill: green)
  fig += lab(P-ac, [$P'$], dx: 0.36, dy: -0.22, fill: green, size: 9pt)
  fig += lab(Q-ac, [$Q'$], dx: -0.42, dy: 0.18, fill: green, size: 9pt)
  fig += pt(O, fill: red, r: 0.09)
  fig += lab(O, text(fill: red)[$O$], dx: 0.28, dy: -0.26, fill: red)
  fig += pt(Mc, fill: blue) + pt(Mb, fill: green)
  fig
}, padding: 0.4))
#cap[Each perpendicular bisector: *two* arcs, *two* intersection points. $(P' Q')$ meets $(P Q)$ at $O$.]

```typ
#let rAC = 4.2
#let (P2, Q2) = circ-inter(A, rAC, C, rAC)
#arc-through(A, P2, Q2) + arc-through(C, P2, Q2)
#let O = line-inter(P, Q, P2, Q2)   // or circumcenter(A, B, C)
```

Mark $[A C]$ with *two* ticks, so it is not confused with $[A B]$ (one
tick). The right angle at $M_(A C)$ is turned inward by `ra-in`.

== Step 6 — Compass at $O$, opening $O A$

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += line-ext(P-ab, Q-ab, beyond: 0.15, stroke: blue.lighten(35%), weight: 0.7, dash: none)
  fig += line-ext(P-ac, Q-ac, beyond: 0.4, stroke: blue.lighten(35%), weight: 0.7, dash: none)
  fig += p-circle(O, R, stroke: blue, weight: 1.4)
  fig += p-line(O, A, stroke: blue.lighten(20%), weight: 0.7, role: "edge")
  fig += p-line(O, B, stroke: blue.lighten(20%), weight: 0.7, role: "edge")
  fig += p-line(O, C, stroke: blue.lighten(20%), weight: 0.7, role: "edge")
  fig += waves(O, A, n: 2, stroke: blue)
  fig += waves(O, B, n: 2, stroke: blue)
  fig += waves(O, C, n: 2, stroke: blue)
  fig += pt(O, fill: blue, r: 0.09)
  fig += lab(O, text(fill: blue)[$O$], dx: 0.32, dy: 0.08, fill: blue)
  fig += compass(O, lerp(O, C, 1.0), scale: 0.52, leg: 5.4, flip: false,
    pencil-colour: rgb("#1864AB"), pencil-lead: rgb("#1864AB"))
  fig
}, padding: 0.5))
#cap[The same two tildes on $[O A]$, $[O B]$ and $[O C]$: $O A = O B = O C$.]

```typ
#let O = circumcenter(A, B, C)
#let R = dist(O, A)
#p-circle(O, R, stroke: rgb("#1864AB"), weight: 1.4)
#waves(O, A, n: 2) + waves(O, B, n: 2) + waves(O, C, n: 2)
#compass(O, C, scale: 0.52, pencil-colour: rgb("#1864AB"),
         pencil-lead: rgb("#1864AB"))
```

Without `pencil-lead`, the compass pencil would keep a *black* graphite
tip — an ordinary pencil glued onto a blue barrel. On a coloured pencil,
the lead matches the barrel.

#note[Why $O$ lies on all three perpendicular bisectors][
  By construction $P$ and $Q$ are equidistant from $A$ and $B$, so every
  point of $(P Q)$ is as well — in particular $O$. Likewise $O A = O C$.
  Hence $O A = O B = O C$: the circle centred at $O$ through $A$ passes
  through $B$ and $C$.
]

= Incircle — with the compass

The *incircle* is tangent to the three sides. Its centre $I$ is the
intersection of the *angle bisectors*. An angle bisector is built with
the compass in two moves: an arc centred at the vertex, then two equal
arcs centred at the cut points.

#note[What you mark][
  - *equal arcs* in the two half-angles (the bisector);
  - at the points of tangency, a *right angle* between the radius and the
    side (the radius is perpendicular to the tangent);
  - $I T_a = I T_b = I T_c$ (the inradius), carried by the circle itself.
]

== Step 1 — Arc centred at $A$, cutting $[A B]$ and $[A C]$

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, r-bis, -8deg, 80deg, stroke: muted, dash: "dashed", weight: 0.9)
  fig += pt(P-angA, fill: green) + pt(Q-angA, fill: green)
  fig += lab(P-angA, [$P$], dx: 0.08, dy: -0.32, fill: green)
  fig += lab(Q-angA, [$Q$], dx: -0.34, dy: 0.10, fill: green)
  fig += compass(A, P-angA, scale: 0.55, leg: 5.0, flip: false,
    pencil-colour: rgb("#2F9E44"))
  fig
}, padding: 0.45))
#cap[Needle at $A$. The arc cuts the two sides of the angle — *not* the third.]

```typ
#let r = 2.05
#let P = lerp(A, B, r / dist(A, B))   // on [AB], distance r from A
#let Q = lerp(A, C, r / dist(A, C))   // on [AC], distance r from A
#p-arc(A, r, -8deg, 80deg, stroke: luma(120), dash: "dashed")
#compass(A, P, scale: 0.55)
```

== Step 2 — Compass at $P$ and at $Q$, same opening

The two arcs meet at $R$ *inside* the angle, toward the right. The last
arc is the one centred at $Q$: plant the needle at $Q$ and stop the lead
at $R$, not toward $A$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, r-bis, -6deg, 78deg, stroke: muted, dash: "dashed", weight: 0.65)
  fig += arc-to(P-angA, R-A, back: 48deg, extra: 16deg, stroke: muted, weight: 0.8)
  fig += arc-to(Q-angA, R-A, back: 72deg, extra: 0deg, stroke: green, weight: 0.95)
  fig += pt(P-angA, fill: green) + pt(Q-angA, fill: green) + pt(R-A, fill: green)
  fig += lab(P-angA, [$P$], dx: 0.10, dy: -0.32, fill: green)
  fig += lab(Q-angA, [$Q$], dx: -0.34, dy: 0.14, fill: green)
  fig += lab(R-A, [$R$], dx: 0.28, dy: 0.18, fill: green)
  fig += ray(A, R-A, extra: 2.2, stroke: green, weight: 1.1, dash: none)
  fig += ang-mark(A, B, R-A, r: 0.72, stroke: green)
  fig += ang-mark(A, R-A, C, r: 0.72, stroke: green)
  fig += compass(Q-angA, R-A, scale: 0.48, leg: 4.6, flip: false,
    pencil-colour: rgb("#2F9E44"))
  fig
}, padding: 0.4))
#cap[Needle at $Q$, lead at $R$: the pencil sits at the *end* of the arc, to the right.]

```typ
#let R = farther(A, R1, R2)     // the intersection farther from A
#arc-to(Q, R, back: 72deg, extra: 0deg)
#compass(Q, R, scale: 0.48)     // lead at the end of the arc, to the right
```

Why it works: $A P = A Q$ (same arc), $P R = Q R$ (same opening), $A R$
common, so $triangle A P R = triangle A Q R$ (SSS) and the angles at $A$
are equal.

== Step 3 — Bisector of $angle A B C$, then $I$

A second bisector is enough: the third goes through $I$. For *each*
angle leave the *three* construction arcs: the arc at the vertex, then
the two equal arcs that meet at $R$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += bisector-three-arcs(A, P-angA, Q-angA, R-A, r-bis, r-bis2, stroke: muted)
  fig += bisector-three-arcs(B, P-angB, Q-angB, R-B, r-bis, r-bis2, stroke: muted)
  fig += ray(A, R-A, extra: 2.6, stroke: green, weight: 1.05, dash: none)
  fig += ray(B, R-B, extra: 2.2, stroke: green, weight: 1.05, dash: none)
  fig += ang-mark(A, B, R-A, r: 0.62, stroke: green)
  fig += ang-mark(A, R-A, C, r: 0.62, stroke: green)
  fig += ang-mark(B, A, R-B, r: 0.62, stroke: green)
  fig += ang-mark(B, R-B, C, r: 0.62, stroke: green)
  fig += pt(R-A, fill: green) + pt(R-B, fill: green)
  fig += pt(I, fill: green, r: 0.09)
  fig += lab(I, text(fill: green)[$I$], dx: 0.28, dy: 0.20, fill: green)
  fig
}, padding: 0.4))
#cap[Three arcs at $A$, three arcs at $B$. $I$ is their intersection.]

```typ
#let I = line-inter(A, R-A, B, R-B)   // or incenter(A, B, C)
```

== Step 4 — Drop a perpendicular from $I$ to a side, with the set square

*Keep* the six bisector arcs. For the radius, do not draw an extra arc
at $C$: drop the perpendicular from $I$ to a side *with the set square*.
The foot $T$ is the point of tangency; $I T$ will be the compass opening.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += bisector-three-arcs(A, P-angA, Q-angA, R-A, r-bis, r-bis2, stroke: luma(170))
  fig += bisector-three-arcs(B, P-angB, Q-angB, R-B, r-bis, r-bis2, stroke: luma(170))
  fig += ray(A, R-A, extra: 2.4, stroke: green.lighten(20%), weight: 0.8, dash: none)
  fig += ray(B, R-B, extra: 2.0, stroke: green.lighten(20%), weight: 0.8, dash: none)
  fig += p-line(I, Tc, stroke: green, weight: 1.15, role: "edge")
  fig += ra-in(Tc, vsub(B, A), vsub(I, Tc), size: 0.30, colour: green)
  fig += pt(I, fill: green, r: 0.09)
  fig += pt(Tc, fill: green)
  fig += lab(I, text(fill: green)[$I$], dx: 0.28, dy: 0.22, fill: green)
  fig += lab(Tc, [$T$], dx: 0.22, dy: -0.32, fill: green)
  fig += square-on(Tc, vsub(B, A), vsub(I, Tc),
    length: dist(I, Tc) + 1.15, colour: luma(65))
  fig
}, padding: 0.4))
#cap[The 3+3 arcs stay. The set square on $(A B)$ projects $I$ to $T$: $(I T) perp (A B)$.]

```typ
#let T = foot(I, A, B)
#square-on(T, vsub(B, A), vsub(I, T), length: dist(I, T) + 1.15)
#ra-in(T, vsub(B, A), vsub(I, T), colour: rgb("#2F9E44"))
```

== Step 5 — The circle, and the three tangencies

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-circle(I, r-in, stroke: green, weight: 1.4)
  fig += p-line(I, Ta, stroke: green, weight: 0.85, role: "edge")
  fig += p-line(I, Tb, stroke: green, weight: 0.85, role: "edge")
  fig += p-line(I, Tc, stroke: green, weight: 0.85, role: "edge")
  fig += ra-in(Ta, vsub(C, B), vsub(I, Ta), size: 0.26, colour: green)
  fig += ra-in(Tb, vsub(C, A), vsub(I, Tb), size: 0.26, colour: green)
  fig += ra-in(Tc, vsub(B, A), vsub(I, Tc), size: 0.26, colour: green)
  fig += pt(I, fill: green, r: 0.09)
  fig += pt(Ta, fill: green) + pt(Tb, fill: green) + pt(Tc, fill: green)
  fig += lab(I, text(fill: green)[$I$], dx: 0.28, dy: 0.22, fill: green)
  fig += lab(Ta, [$T_a$], dx: 0.34, dy: 0.10, fill: green, size: 9pt)
  fig += lab(Tb, [$T_b$], dx: -0.36, dy: 0.10, fill: green, size: 9pt)
  fig += lab(Tc, [$T_c$], dx: 0.10, dy: -0.32, fill: green, size: 9pt)
  fig += compass(I, Tc, scale: 0.5, leg: 4.8, flip: false,
    pencil-colour: rgb("#2F9E44"), pencil-lead: rgb("#2F9E44"))
  fig
}, padding: 0.45))
#cap[Three radii, three right angles: the circle is tangent to all three sides.]

```typ
#let I = incenter(A, B, C)
#let T = foot(I, A, B)                 // point of tangency on [AB]
#let r = dist(I, T)
#p-circle(I, r, stroke: rgb("#2F9E44"), weight: 1.4)
#ra-in(T, vsub(B, A), vsub(I, T), colour: rgb("#2F9E44"))
#compass(I, T, scale: 0.5, pencil-lead: rgb("#2F9E44"))
```

`ra-in(T, along, toward)` turns the square *inward*: `along` is the side,
`toward` points to $I$. On $[A C]$, without that test, the square sat
outside the triangle.

= Centroid — medians, with the ruler

The *centroid* $G$ (barycentre of the three vertices) is the intersection
of the *medians*. A median joins a vertex to the *midpoint* of the
opposite side. Find the midpoints with the ruler, then draw the three
medians. The set square has no role here: a median is not a
perpendicular.

#note[What you mark][
  - on each side, *the same number of ticks* on both halves of the
    midpoint: one tick on $[A B]$, two on $[A C]$, three on $[B C]$;
  - do *not* mark $A G = 2 thin G M$ as a construction step (the $2:1$
    split is a theorem). You may write it beside the figure once $G$ is
    found.
]

== Step 1 — Midpoint of $[A B]$ with the ruler

$A B = 7.2$ cm, the midpoint $M_c$ is at $3.6$ cm. Lay the ruler along
the side, zero at $A$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += ruler(at: (0, -0.58), length: 7.2, width: 0.62, clamp: false,
    values: true, value-size: 0.72, colour: luma(60))
  fig += pt(Mc, fill: orange, r: 0.085)
  fig += lab(Mc, [$M_c$], dx: 0.12, dy: 0.32, fill: orange)
  fig += ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
  fig += p-line(Mc, (Mc.at(0), Mc.at(1) + 0.22), stroke: orange, weight: 1.0)
  fig
}, padding: 0.35))
#cap[The $3.6$ on the ruler falls on the midpoint. One tick on each half marks $A M_c = M_c B$.]

```typ
#let Mc = midp(A, B)
#ruler(at: A, rotate: 0deg, length: dist(A, B),
       width: 0.62, clamp: false)
#ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
```

On an arbitrary side, *align* the ruler:

```typ
#ruler(
  at: A,
  rotate: vangle(vsub(C, A)),          // along [AC]
  length: dist(A, C),
  width: 0.62, clamp: false,
)
```

#warn[The `ruler` floor][
  `width` is floored at $1.5$ cm by default, `length` at $3$. A ruler
  laid *under* a 7 cm side, if it is 1.5 cm wide, covers half the
  triangle. `clamp: false` lifts both floors (minimum width then $0.05$).
]

== Step 2 — The three midpoints

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
  fig += ticks(A, Mb, n: 2) + ticks(Mb, C, n: 2)
  fig += ticks(B, Ma, n: 3) + ticks(Ma, C, n: 3)
  fig += pt(Ma, fill: orange) + pt(Mb, fill: orange) + pt(Mc, fill: orange)
  fig += lab(Ma, [$M_a$], dx: 0.34, dy: 0.12, fill: orange)
  fig += lab(Mb, [$M_b$], dx: -0.36, dy: 0.10, fill: orange)
  fig += lab(Mc, [$M_c$], dx: 0.12, dy: 0.30, fill: orange)
  fig += ruler(
    at: A, rotate: vangle(vsub(C, A)),
    length: dist(A, C), width: 0.55, clamp: false,
    values: false, colour: luma(70),
  )
  fig
}, padding: 0.4))
#cap[Three midpoints, three distinct markings. The ruler lies on $[A C]$.]

== Step 3 — Draw the three medians

Join each vertex to the midpoint of the opposite side. Two medians
suffice; the third is a check: if it misses $G$, a midpoint is wrong.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-line(A, Ma, stroke: orange, weight: 1.15, role: "edge")
  fig += p-line(B, Mb, stroke: orange, weight: 1.05, role: "edge")
  fig += p-line(C, Mc, stroke: orange, weight: 1.05, role: "edge")
  fig += ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
  fig += ticks(A, Mb, n: 2) + ticks(Mb, C, n: 2)
  fig += ticks(B, Ma, n: 3) + ticks(Ma, C, n: 3)
  fig += pt(Ma, fill: orange) + pt(Mb, fill: orange) + pt(Mc, fill: orange)
  fig += pt(G, fill: orange, r: 0.1)
  fig += lab(G, text(fill: orange)[$G$], dx: 0.30, dy: 0.22, fill: orange)
  fig += lab(Ma, [$M_a$], dx: 0.34, dy: 0.10, fill: orange)
  fig += lab(Mb, [$M_b$], dx: -0.36, dy: 0.10, fill: orange)
  fig += lab(Mc, [$M_c$], dx: 0.12, dy: 0.30, fill: orange)
  fig
}, padding: 0.4))
#cap[The three medians meet at $G$. No set square: this is not a right angle.]

```typ
#p-line(A, Ma, stroke: rgb("#E8590C"), weight: 1.15, role: "edge")
#p-line(B, Mb, stroke: rgb("#E8590C"), weight: 1.15, role: "edge")
#p-line(C, Mc, stroke: rgb("#E8590C"), weight: 1.15, role: "edge")
```

Two medians are enough. The third is a check: if it misses $G$, a
midpoint is wrong.

#note[$G$ divides each median in the ratio $2:1$][
  $arrow(A G) = 2 thin arrow(G M_a)$.
  In code, $G$ is simply the average of the vertices — the same fact:

  ```typ
  #let G = (
    (A.at(0) + B.at(0) + C.at(0)) / 3,
    (A.at(1) + B.at(1) + C.at(1)) / 3,
  )
  ```
]

= Orthocentre — altitudes, with the set square

The *orthocentre* $H$ is the intersection of the *altitudes*. An altitude
is the perpendicular from a vertex to the opposite side. That is *the*
set-square gesture: one edge on the side, the other edge through the
vertex.

#note[What you mark][
  A *right-angle square* at each foot $H_a$, $H_b$, $H_c$. Nothing else:
  altitudes do not carry equal-length ticks.
]

== Seating the set square on a side

`set-square` has the right angle at the origin, the *base* (short leg) on
$+x$, the *long leg* on $+y$. To seat it on a line:

1. `at`: the point where you want the right angle — in practice the
   *foot* of the altitude, or any point of the side while you still hunt
   for the foot;
2. `rotate`: the bearing of the side, `vangle(vsub(C, B))` for $(B C)$;
3. `flip`: if the long leg points away from the vertex, turn the square
   over.

The helper `square-on(at, along, toward)` does that test: `along` is a
direction vector of the side, `toward` a vector toward the vertex. If
local $+90 degree$ is the wrong side, `flip` turns on.

== Step 1 — Altitude from $C$, set square on $(A B)$

$(A B)$ is horizontal, the perpendicular is vertical. The set square
sits on $A B$, right angle at the foot $H_c = (2.2, 0)$. The long leg
must *pass beyond* $C$: take `length: dist(C, Hc) + 0.55`.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-line(C, Hc, stroke: purple, weight: 1.15, role: "edge")
  fig += pt(Hc, fill: purple)
  fig += lab(Hc, [$H_c$], dx: -0.40, dy: -0.28, fill: purple)
  fig += ra-in(Hc, vsub(B, A), vsub(C, Hc), size: 0.32, colour: purple)
  fig += square-on(Hc, vsub(B, A), vsub(C, Hc),
    length: dist(C, Hc) + 0.55, colour: luma(65))
  fig
}, padding: 0.4))
#cap[One edge on $(A B)$, the other through $C$. The foot $H_c$ is read at the contact.]

```typ
#let Hc = foot(C, A, B)
#square-on(Hc, vsub(B, A), vsub(C, Hc), length: dist(C, Hc) + 0.55)
#ra-in(Hc, vsub(B, A), vsub(C, Hc), colour: rgb("#7048E8"))
#p-line(C, Hc, stroke: rgb("#7048E8"), weight: 1.15, role: "edge")
```

On paper, the pupil *slides* the set square along $(A B)$ until the other
edge meets $C$, *then* draws. On the figure we seat it already in place —
the foot is computed by `foot(C, A, B)`, the orthogonal projection.

== Step 2 — Altitude from $A$, set square on $(B C)$

The side is no longer horizontal. `rotate` follows $(B C)$, `flip` tucks
the square into the triangle.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-line(C, Hc, stroke: purple.lighten(25%), weight: 0.8, role: "edge")
  fig += p-line(A, Ha, stroke: purple, weight: 1.15, role: "edge")
  fig += pt(Hc, fill: purple) + pt(Ha, fill: purple)
  fig += lab(Ha, [$H_a$], dx: 0.32, dy: 0.16, fill: purple)
  fig += ra-in(Hc, vsub(B, A), vsub(C, Hc), size: 0.28, colour: purple)
  fig += ra-in(Ha, vsub(C, B), vsub(A, Ha), size: 0.28, colour: purple)
  fig += square-on(Ha, vsub(C, B), vsub(A, Ha),
    length: dist(A, Ha) + 0.55, colour: luma(65))
  fig
}, padding: 0.4))
#cap[Set square on $(B C)$, long leg toward $A$. Two altitudes already give $H$.]

```typ
#let Ha = foot(A, B, C)
#square-on(Ha, vsub(C, B), vsub(A, Ha), length: dist(A, Ha) + 0.55)
#ra-in(Ha, vsub(C, B), vsub(A, Ha), colour: rgb("#7048E8"))
```

If the small marking square *leaves* the triangle, `rotate` points into
the wrong half-plane. Add $180 degree$, or take `vangle(vsub(B, C))`
instead of `vangle(vsub(C, B))`.

== Step 3 — The third altitude, and $H$

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-line(A, Ha, stroke: purple, weight: 1.05, role: "edge")
  fig += p-line(B, Hb, stroke: purple, weight: 1.05, role: "edge")
  fig += p-line(C, Hc, stroke: purple, weight: 1.05, role: "edge")
  fig += ra-in(Ha, vsub(C, B), vsub(A, Ha), size: 0.26, colour: purple)
  fig += ra-in(Hb, vsub(C, A), vsub(B, Hb), size: 0.26, colour: purple)
  fig += ra-in(Hc, vsub(B, A), vsub(C, Hc), size: 0.26, colour: purple)
  fig += pt(Ha, fill: purple) + pt(Hb, fill: purple) + pt(Hc, fill: purple)
  fig += pt(H, fill: purple, r: 0.1)
  fig += lab(H, text(fill: purple)[$H$], dx: -0.32, dy: 0.24, fill: purple)
  fig += lab(Ha, [$H_a$], dx: 0.32, dy: 0.14, fill: purple, size: 9pt)
  fig += lab(Hb, [$H_b$], dx: -0.36, dy: 0.12, fill: purple, size: 9pt)
  fig += lab(Hc, [$H_c$], dx: -0.40, dy: -0.28, fill: purple, size: 9pt)
  fig += square-on(Hb, vsub(C, A), vsub(B, Hb),
    length: dist(B, Hb) + 0.55, colour: luma(65))
  fig
}, padding: 0.4))
#cap[The three altitudes and their three right angles. $H$ is interior: the triangle is acute.]

```typ
#let H = line-inter(A, Ha, B, Hb)   // or orthocenter(A, B, C)
```

#note[Obtuse triangle][
  If an angle is obtuse, the orthocentre leaves the triangle and two feet
  fall on the *extensions*. `foot` still computes them (the projection
  parameter $t$ is no longer in $[0, 1]$). Extend the side with dashed
  `line-ext`, and seat the set square on that extension.
]

= The four centres together

On *every* triangle, $O$, $G$ and $H$ are collinear: that is *Euler's
line*, and $G$ lies one third of the way along $[O H]$ from $O$:

$ arrow(O G) = 1/3 thin arrow(O H) $

$I$ lies on that line only in isosceles triangles.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-circle(O, R, stroke: blue, weight: 1.15)
  fig += p-circle(I, r-in, stroke: green, weight: 1.1)
  fig += p-line(A, Ma, stroke: orange.lighten(20%), weight: 0.6, role: "edge")
  fig += p-line(B, Mb, stroke: orange.lighten(20%), weight: 0.6, role: "edge")
  fig += p-line(C, Mc, stroke: orange.lighten(20%), weight: 0.6, role: "edge")
  fig += p-line(A, Ha, stroke: purple.lighten(25%), weight: 0.6, role: "edge")
  fig += p-line(B, Hb, stroke: purple.lighten(25%), weight: 0.6, role: "edge")
  fig += p-line(C, Hc, stroke: purple.lighten(25%), weight: 0.6, role: "edge")
  fig += line-ext(O, H, beyond: 0.7, stroke: red, weight: 1.2, dash: none)
  fig += pt(O, fill: blue, r: 0.09)
  fig += pt(I, fill: green, r: 0.09)
  fig += pt(G, fill: orange, r: 0.09)
  fig += pt(H, fill: purple, r: 0.09)
  fig += lab(O, [$O$], dx: 0.30, dy: -0.26, fill: blue)
  fig += lab(I, [$I$], dx: -0.30, dy: 0.22, fill: green)
  fig += lab(G, [$G$], dx: 0.30, dy: 0.20, fill: orange)
  fig += lab(H, [$H$], dx: -0.30, dy: 0.26, fill: purple)
  fig
}, padding: 0.5))
#cap[$O$, $G$, $H$ collinear (red). $I$ sits off the line: $A B C$ is not isosceles.]

== Recap of the gestures

#table(
  columns: (auto, auto, 1fr, auto),
  inset: 7pt,
  stroke: 0.4pt + luma(210),
  fill: (_, y) => if y == 0 { blue.lighten(82%) } else if calc.odd(y) { luma(248) },
  [*Centre*], [*Lines*], [*Instrument*], [*Marking*],
  text(fill: blue, weight: "bold")[$O$], [perp. bisectors], [compass, two equal arcs],
    [$A M = M B$, right angle],
  text(fill: green, weight: "bold")[$I$], [angle bisectors], [compass, arc then two arcs],
    [angle arcs, radii $perp$],
  text(fill: orange, weight: "bold")[$G$], [medians], [ruler (midpoints and medians)],
    [equal-length ticks at midpoints],
  text(fill: purple, weight: "bold")[$H$], [altitudes], [set square on the side],
    [right angle at each foot],
)

= Quick reference

== `geom`

```typ
#geom(body, mode: "clean", roughness: 1.0, seed: 1,
      colour: black, frame: none, padding: 0.25)
```

`body` is an array of primitives. `frame: (x0, x1, y0, y1)` freezes the
extent instead of fitting the content — useful for stacking steps *at
the same scale*.

== `compass(from, to)`

| Argument | Default | |
|---|---|---|
| `leg` | `6.0` | length of a leg, cm |
| `scale` | `1.0` | shrinks the instrument, *keeps* the feet |
| `flip` | `false` | swings to the other side of `[from to]` |
| `pencil-colour` | red | pencil barrel |
| `pencil-lead` | `auto` (black) | lead; pass the same colour as the barrel |
| `show-pencil` | `true` | |

If the span exceeds $2 times "leg" times "scale"$, the legs saturate and
the feet no longer meet. Increase `leg` or bring the points closer.

== `set-square`

| Argument | Default | |
|---|---|---|
| `at` | `(0,0)` | *the right angle* |
| `rotate` | `0deg` | direction of the base (local $+x$) |
| `length` | `10` | long leg; floor $4.5$ if `clamp: true` |
| `flip` | `false` | turn-over on the table |
| `values` | `true` | numerals; `false` keeps the ticks |
| `clamp` | `true` | |

`square-on(at, along, toward)` (this guide) chooses `rotate` and `flip`.

== `ruler`

Zero at `at`, toward `rotate`. `corner: 0.12` softens the ends (not a
capsule). `corner: 0`: sharp corners. `value-pos: "m"` (middle), `"h"`
(top), `"b"` (bottom, upside-down), combinable (`"hb"`).

== `right-angle`

```typ
#right-angle(at: vertex, rotate: 0deg, size: 0.32, colour: black)
```

*Open* square, vertex held back. `rotate` = direction of the first side.

== Construction primitives

```typ
p-line(A, B, stroke: luma(120), weight: 1.0, dash: "dashed", role: "edge")
p-arc(centre, r, a0, a1, stroke: blue, dash: "dashed")
p-circle(centre, r, stroke: blue, weight: 1.3)
p-label(pos, [A], size: 10pt, fill: black)
```

`role: "edge"` (the tools' default) or `"tick"` / `"detail"`: in `rough`
mode, ticks wobble three times less, otherwise a 2 mm mark dissolves at
the amplitude that clothes a 12 cm ruler.

== Formulae used

- $O$ is the intersection of the perpendicular bisectors.
- $I = (a A + b B + c C) / (a + b + c)$ with $a = B C$, $b = A C$, $c = A B$.
- $G = (A + B + C) / 3$.
- $H$ is the intersection of two altitudes; $H_a$ is the projection of $A$ onto side $B C$.

#v(0.8em)
#line(length: 100%, stroke: 0.4pt + luma(180))
#v(0.25em)
#text(size: 8pt, fill: luma(110))[
  `geomtools` 0.1.0 — a port of Cédric Pierquet's `OutilsGeomTikZ`
  (LPPL 1.3c). He neither maintains nor endorses this port. Guide written
  for the triangle $A(0,0)$, $B(7.2,0)$, $C(2.2, 4.8)$; the listings
  copy as-is once `helpers.typ` is imported.
]
