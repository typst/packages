// na-courbe v0.1.0 documentation (English) — build with: typst compile doc-en.typ
#import "@preview/na-courbe:0.1.0": courbe, integrale, papier-milli

#set page(paper: "a4", margin: 2cm, fill: white, numbering: "1")
#set text(font: "Libertinus Serif", lang: "en", dir: ltr, size: 11pt)
#set par(justify: true, leading: 0.7em, first-line-indent: 0pt)

#let blue1 = rgb("#08a9ea")
#let blue2 = rgb("#00CCFF")
#let dark = rgb("#350758")
#let sans = "Arial"

// ── Heading styles (left-to-right version of the Arabic documentation) ──
#let unit-heading(number, title) = block(width: 100%, inset: 0pt, breakable: false)[
  #grid(columns: (16mm, 1fr), column-gutter: 4mm, align: horizon,
    circle(radius: 8mm, fill: white, stroke: 1.2pt + blue1)[
      #align(center + horizon)[#text(font: sans, size: 20pt, weight: "bold", fill: blue1)[#number]]
    ],
    text(font: sans, size: 21pt, weight: "bold")[#title],
  )
]

#let sub-style(it) = {
  v(0.5cm, weak: true)
  block(width: 100%, height: 1.6cm, breakable: false, sticky: true)[
    #place(horizon + right)[
      #block(width: 100% - 0.8cm, height: 1.3cm, fill: blue2,
        radius: (right: 0.5cm, left: 0cm), inset: (left: 1.1cm, right: 0.4cm))[
        #align(horizon + left)[#text(size: 16pt, weight: "bold", fill: white, font: sans)[#it.body]]
      ]
    ]
    #place(horizon + left)[
      #block(fill: white, width: 1.6cm, height: 1.6cm, radius: 50%, stroke: blue2 + 2pt)[
        #align(center + horizon)[
          #text(size: 13pt, weight: "bold", fill: dark, font: sans)[#context counter(heading).display("1.1")]
        ]
      ]
    ]
  ]
  v(0.35cm, weak: true)
}

#set heading(numbering: "1.1")
#show heading.where(level: 1): it => {
  v(0.5cm, weak: true)
  unit-heading(counter(heading).display("1"), it.body)
  v(0.35cm)
}
#show heading.where(level: 2): it => sub-style(it)
#show heading.where(level: 3): set text(size: 12.5pt, fill: blue1)

// ── Code boxes, notes, demos, tables ──
#show raw: set text(font: ("DejaVu Sans Mono", "Consolas"), size: 9pt)
#show raw.where(block: true): set block(
  fill: rgb("#ddf3f3"), inset: 12pt, radius: 2pt, width: 100%,
  stroke: 0.3pt + gray, breakable: true,
)

#let note(title, body, color: rgb("#e8a317")) = block(
  width: 100%, inset: 10pt, radius: 4pt, breakable: false,
  fill: color.lighten(88%), stroke: (left: 3pt + color),
)[*#title* \ #body]

// shows the code, then its really computed result
#let demo(code) = {
  let src = code.text
  block(width: 100%, breakable: false, stroke: 0.6pt + luma(190), radius: 4pt, clip: true)[
    #{
      show raw.where(block: true): set block(fill: none, stroke: none, inset: 0pt, radius: 0pt)
      block(width: 100%, fill: rgb("#ddf3f3"), inset: 12pt, code)
    }
    #block(width: 100%, inset: 10pt, align(center)[
      #eval(src, mode: "markup", scope: (courbe: courbe, integrale: integrale, papier-milli: papier-milli))
    ])
  ]
}

#let tbl(..rows) = table(
  columns: (auto, 1fr, auto), inset: 6pt, stroke: 0.5pt + luma(180),
  fill: (_, y) => if y == 0 { rgb("#dbe8f7") },
  align: (left, left, left),
  table.header([*Parameter*], [*Meaning*], [*Default*]),
  ..rows,
)

// ── Cover ──
#align(center)[
  #v(1.5cm)
  #block(width: 100%, inset: (y: 1cm), radius: (top-left: 1cm, bottom-right: 1cm),
    fill: rgb("#ddf3f3"), stroke: 1pt + blue2)[
    #text(size: 32pt, weight: "bold", fill: dark)[The #text(fill: blue1)[`na-courbe`] package]
    #v(0.2cm)
    #text(size: 16pt)[Complete function plotting for Typst]
  ]
  #v(0.6cm)
  #courbe(x => x * x - 2, x: (-3, 3), y: (-3, 5), size: (9, 5), nom: $C_f$,
    autres: ((f: x => 4 - x * x, nom: $C_g$, trait: "tirets"),),
    aire: (-calc.sqrt(3), calc.sqrt(3)), aire-avec: x => 4 - x * x,
    grille: "millimetre", grille-couleur: blue,
    xlabel: $x$, ylabel: $y$, origine: $O$)
  #v(0.6cm)
  #text(size: 11pt, fill: luma(90))[Version 0.1.0 · Prof. Nassim · #link("doc.typ")[الوثائق بالعربية]]
]

#pagebreak()
#block(width: 100%, height: 1.3cm, fill: blue2, radius: (right: 0.5cm, left: 0cm),
  inset: (left: 0.8cm), breakable: false)[
  #align(horizon + left)[#text(size: 20pt, weight: "bold", fill: white, font: sans)[Contents]]
]
#v(0.4cm)
#show outline.entry.where(level: 1): set text(weight: "bold", fill: dark)
#outline(title: none, depth: 2)
#pagebreak()

= Introduction

The `courbe` function draws, in a single coordinate frame, everything needed for a lesson on functions:

- curves with several line styles: solid, dashed, dotted, dash-dotted, *dots only*, or line with markers;
- *piecewise functions* with open and closed end points;
- *labels placed wherever you want* on every element (curve, line, asymptote, point, tangent, area), free text, and fine offsets;
- *grid types*: major, minor, both, *millimetre graph paper*, or none, with control over line style, colour and thickness;
- *tick length* on each axis separately, and the size of the tick labels;
- *normal or trigonometric* ($pi$ multiples) tick labels;
- points (on the curve or free, open or closed) with projections onto the axes;
- lines, segments, asymptotes and tangents;
- areas between a curve and the axis, between two curves, or between a curve and a line, with the area computed numerically;
- overall appearance: background, frame, title, axis colour and thickness.

= Installation

Copy the folder to `~/.local/share/typst/packages/local/na-courbe/0.1.0/` (Linux) or the equivalent on macOS and Windows, then:
```typ
#import "@local/na-courbe:0.1.0": courbe, integrale, papier-milli
```
or, once published, from Typst Universe:
```typ
#import "@preview/na-courbe:0.1.0": courbe, integrale, papier-milli
```
The package needs Typst 0.13 or newer and depends on CeTZ 0.3.4 and cetz-plot 0.1.1 (downloaded automatically).

#note("Right-to-left documents")[Inside an Arabic or Hebrew document, put `#set text(dir: ltr)` before the plot so the coordinate frame stays left to right.]

= Parameters

== Main curve
#tbl(
  [`f`], [The function `x => ...`, or `none` if you only use `morceaux` (required)], [—],
  [`domain`], [Plot domain `(a, b)`], [`(-4, 4)`],
  [`branches`], [Separate domains, used around a vertical asymptote], [`none`],
  [`morceaux`], [Piecewise function: `(f:, domain:, gauche:, droite:, nom:, couleur:, trait:)`; an end is `"ouvert"` or `"ferme"`], [`()`],
  [`couleur`], [Curve colour], [`blue`],
  [`trait`], [Line style: `"continu"`, `"tirets"`, `"pointille"`, `"mixte"`, `"points"`, `"lie"`], [`"continu"`],
  [`epaisseur`], [Line thickness], [`1.6pt`],
  [`marque`, `npts`], [Marker shape (`"o"`, `"x"`, `"+"`, `"*"`, `"square"`, `"triangle"`) and number of points for `"points"` and `"lie"`], [`"o"`, `25`],
  [`autres`], [Other curves: same keys as the main curve (`f`, `nom`, `couleur`, `trait`, `domain`, `branches`, `morceaux`...)], [`()`],
)

== Labels (free placement)
Every element (curve, line, asymptote, segment, tangent, point) accepts the keys below; they work inside `autres`, `droites`, `segments`, `va`, `ha`, `tangente` and `points` too.
#tbl(
  [`nom`], [Label of the element, e.g. `$C_f$`], [`none`],
  [`nom-pos`], [Free position `(x, y)` of the label in plot coordinates; otherwise it is put near the end of the element], [`none`],
  [`nom-t`], [Position along the element itself as a ratio from `0` (start) to `1` (end), when `nom-pos` is not used], [`auto`],
  [`nom-x`], [x-coordinate of the label on the curve or line (alternative to `nom-t`)], [`auto`],
  [`nom-dx`, `nom-dy`], [Extra offset of the label in plot units, added on top of any other position], [`0`, `0`],
  [`nom-ancre`], [Which side of the text sticks to the point: `"center"`, `"north"`, `"south-east"`...], [`auto`],
  [`textes`], [Free texts: `((pos: (1, 2), t: [text], couleur:, ancre:),)`], [`()`],
  [`origine`], [Label of the origin, e.g. `$O$`], [`none`],
  [`fond-noms`], [White background behind labels to make them readable], [`false`],
)

== Lines and points
#tbl(
  [`droites`], [`(a:, b:)` for the line $y = a x + b$ or `(x: c)` for a vertical one; with `nom`, `nom-pos`, `nom-t`, `couleur`, `trait`], [`()`],
  [`segments`], [`(de: (x1, y1), a: (x2, y2), nom:, trait:, couleur:)`; `nom-t` is a ratio between the ends], [`()`],
  [`va`, `ha`], [Asymptotes: numbers or `(v: 2, nom: $x=2$, nom-pos: (..))`], [`()`],
  [`tangente`], [Abscissa of tangency or `(a: 1.5, nom: $T$, nom-pos: (..))`], [`none`],
  [`points`], [A number (point on the curve), or `(v:, nom:, proj:, ouvert:, marque:, couleur:, nom-pos:)`, or a free point `(p: (x, y), ...)`], [`()`],
)

== Area
#tbl(
  [`aire`], [Area domain `(a, b)`], [`none`],
  [`aire-avec`], [Second function bounding the area instead of the axis], [`none`],
  [`aire-couleur`], [Fill colour], [`auto`],
  [`aire-nom`, `aire-nom-pos`], [Label of the area and its free position], [`none`],
)

== Frame and scale
#tbl(
  [`x`, `y`], [Axis bounds `(min, max)`, with min < max], [`(-5, 5)`],
  [`xstep`, `ystep`], [Major tick step; with trigonometric labels it becomes $pi$/denominator automatically], [`auto` ⇒ `1`],
  [`xminor`, `yminor`], [Minor tick step], [`none`],
  [`xunite`, `yunite`], [Length of one unit in centimetres on each axis separately, e.g. `xunite: 2` or `yunite: 0.5cm`; with trigonometric labels it is the length of a whole $pi$. They take priority over `echelle` and `size`], [`auto`],
  [`echelle`], [`(cm per unit horizontally, cm per unit vertically)` in one parameter], [`none`],
  [`size`], [Dimensions in centimetres when `echelle` is not given], [`(8, 6)`],
  [`xlabel`, `ylabel`], [Axis labels], [`none`],
  [`samples`], [Plot resolution], [`150`],
)

== Grid
#tbl(
  [`grille`], [Grid type: `true` or `"principale"` (at major ticks) · `"secondaire"` (at minor ticks) · `"toutes"` (both) · `"millimetre"` (millimetre graph paper; aliases `"milli"`, `"mm"`, `"papier"`) · `false` or `"aucune"` (no grid)], [`true`],
  [`grille-x`, `grille-y`], [Grid type of each axis separately (same values); `auto` follows `grille`], [`auto`],
  [`grille-trait`], [Line style: `"continu"`, `"tirets"`, `"pointille"`, `"mixte"`], [`auto`],
  [`grille-couleur`], [Colour of the grid lines (minor lines are lighter). With millimetre paper the three line shades are derived from it; default is a reddish orange], [`auto`],
  [`grille-epaisseur`], [Thickness of the major grid line (minor lines are 60% of it). With millimetre paper it is the 1 cm line; the 5 mm line is 60% and the 1 mm line 30% of it], [`auto`],
  [`milli-fin`], [Millimetre paper: show the 1 mm lines; with `false` only the 5 mm and 1 cm lines remain], [`true`],
  [`milli-ancre`], [Millimetre paper: `"origine"` makes the centimetre lines pass through the origin (so they coincide with the ticks); `"coin"` counts from the lower-left corner], [`"origine"`],
)
#note("Minor grid", color: rgb("#27ae60"))[With `"secondaire"` or `"toutes"` and no `xminor`/`yminor`, the minor step is computed automatically (one fifth of the major step, one half with trigonometric labels).]
#note("Millimetre paper", color: rgb("#27ae60"))[The graph paper is drawn in real millimetres on the page and spans the axes exactly, from the first to the last tick (plot width × height), closed by a border. For the centimetre lines to coincide with the ticks, make `xunite` and `yunite` whole numbers of centimetres (or choose `size` so that its width equals the number of `x` units).]

== Appearance
#tbl(
  [`fond`], [Background colour of the plot, e.g. `rgb("#fffbe6")`], [`none`],
  [`cadre`], [`true` for a black frame, or a colour for the frame], [`none`],
  [`titre`], [Title placed above the plot, e.g. `[Graph of f]`], [`none`],
  [`axes-couleur`], [Axis colour], [`auto`],
  [`axes-epaisseur`], [Axis thickness, e.g. `1.2pt`], [`auto`],
)

The function `papier-milli(..)` is a shortcut for an empty millimetre sheet: it accepts the same parameters as `courbe` (except `f`) and sets `grille: "millimetre"`.

== Ticks and number format
#tbl(
  [`xtick`, `ytick`], [Major tick length in centimetres on each axis (e.g. `0.25` or `3mm`)], [`auto`],
  [`tick-minor`], [Ratio of minor tick length to major tick length], [`0.6`],
  [`tick-taille`], [Font size of the tick labels, e.g. `9pt`], [`auto`],
  [`xnum`, `ynum`], [Tick label type: `"normal"` or `"pi"` ($pi$ multiples such as $pi/2$, $3pi/2$, $-pi$)], [`"normal"`],
  [`xpi`, `ypi`], [Denominator of $pi$ for trigonometric labels: `2` ⇒ a tick every $pi/2$, `3` ⇒ every $pi/3$, `6` ⇒ every $pi/6$...], [`2`, `2`],
)

= Examples

== Millimetre graph paper
`grille: "millimetre"` draws graph paper: a thin line every 1 mm, a medium line every 5 mm and a thick line every 1 cm. The grid has exactly the length of the axes.

#demo(```typ
#courbe(
  x => x * x / 4 - 1,
  domain: (-4, 4), x: (-4, 4), y: (-2, 4),
  grille: "millimetre",
  nom: $C_f$, nom-t: 0.9, nom-dy: 0.3,
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

=== Changing the grid colour
`grille-couleur` changes the colour of the graph paper (and of every other grid type); `grille-epaisseur` changes its thickness.

#demo(```typ
#courbe(
  x => calc.sin(x) * 2,
  domain: (-4, 4), x: (-4, 4), y: (-3, 3),
  grille: "millimetre", grille-couleur: blue,
  nom: $C_f$, nom-t: 0.8, nom-dy: 0.3, origine: $O$,
)
```)

#demo(```typ
#courbe(
  x => x * x / 2,
  domain: (-3, 3), x: (-3, 3), y: (-1, 5),
  grille: "millimetre", grille-couleur: green.darken(10%),
  grille-epaisseur: 1pt, milli-fin: false,
  nom: $C_f$, nom-t: 0.9, nom-dy: 0.3,
)
```)

=== Different units on the two axes
With `xunite` and `yunite` the grid automatically follows the new length of the axes.

#demo(```typ
#courbe(
  x => calc.sqrt(x),
  domain: (0, 8), x: (-1, 8), y: (-1, 4),
  grille: "millimetre", xunite: 1, yunite: 1.5,
  cadre: true, titre: [$y = sqrt(x)$],
  nom: $C_f$, origine: $O$,
)
```)

=== An empty graph-paper sheet
#demo(```typ
#papier-milli(
  x: (0, 10), y: (0, 6),
  grille-couleur: rgb("#2a9d8f"),
)
```)

=== With trigonometric labels
#demo(```typ
#courbe(
  x => calc.sin(x),
  domain: (-calc.pi, calc.pi), x: (-calc.pi, calc.pi), y: (-1.5, 1.5),
  grille: "millimetre", grille-couleur: purple,
  xnum: "pi", xpi: 2, xunite: 6, yunite: 2,
  nom: $sin x$, nom-t: 0.6, nom-dy: 0.3, origine: $O$,
)
```)

== Appearance: background, frame, title
#demo(```typ
#courbe(
  x => x * x / 4,
  domain: (-4, 4), x: (-4, 4), y: (-1, 4), size: (8, 5),
  fond: rgb("#fffbe6"), cadre: true,
  titre: [The parabola],
  axes-couleur: maroon, axes-epaisseur: 1.2pt,
  nom: $C_f$, origine: $O$,
)
```)

== Placing labels where you want
Each `nom-pos` sets the label position in plot coordinates, and `textes` puts any text anywhere.

#demo(```typ
#courbe(
  x => x * x / 2,
  domain: (-3, 3), x: (-3, 3), y: (-1, 5),
  nom: $C_f$, nom-pos: (-2.4, 3.4),
  droites: ((a: 1, b: 0.5, nom: $d$, nom-pos: (2.5, 1.4)),),
  textes: ((pos: (0, 4.4), t: [parabola], couleur: blue),),
  points: ((v: 2, nom: $M$, nom-pos: (2.35, 1.6)),),
  fond-noms: true, origine: $O$,
  xlabel: $x$, ylabel: $y$,
)
```)

== A label on the curve itself, with ratio and offset
`nom-t` puts the label at a ratio of the domain length (`0` start, `1` end), and `nom-dx` and `nom-dy` shift it slightly.

#demo(```typ
#courbe(
  x => x * x / 2 - 1,
  domain: (-3, 3), x: (-3, 3), y: (-2, 5),
  nom: $C_f$, nom-t: 0.15, nom-dx: -0.2, nom-dy: 0.3,
  droites: ((a: -1, b: 2, nom: $d$, nom-t: 0.2, nom-dy: 0.3, nom-ancre: "south"),),
  segments: ((de: (-2, 1), a: (2, 1), nom: $[A B]$, nom-t: 0.8, nom-dy: 0.25, trait: "tirets", couleur: red),),
)
```)

== Grid types
`grille: "toutes"` draws both major and minor grids, `grille: "secondaire"` only the minor one, and `grille: false` removes the grid.

#demo(```typ
#courbe(
  x => x * x / 2,
  domain: (-3, 3), x: (-3, 3), y: (-1, 5), size: (8, 5),
  grille: "toutes", xminor: 0.5, yminor: 0.5,
  grille-trait: "pointille", grille-couleur: gray,
  nom: $C_f$,
)
```)

The same function with horizontal grid lines only (`grille-x` set to `false`) and no minor ticks:

#demo(```typ
#courbe(
  x => x * x / 2,
  domain: (-3, 3), x: (-3, 3), y: (-1, 5), size: (8, 5),
  grille-x: false, grille-y: true, grille-trait: "tirets",
  nom: $C_f$,
)
```)

== Tick length
`xtick` and `ytick` control the tick length on both axes in centimetres, and `tick-taille` the size of the numbers.

#demo(```typ
#courbe(
  x => x * x / 4,
  domain: (-4, 4), x: (-4, 4), y: (-1, 4), size: (8, 5),
  xtick: 0.3, ytick: 0.12, tick-taille: 9pt,
  xlabel: $x$, ylabel: $y$, origine: $O$, nom: $C_f$,
)
```)

== Trigonometric labels
With `xnum: "pi"` the step becomes $pi/"xpi"$ automatically and the numbers are written as multiples of $pi$.

#demo(```typ
#courbe(
  x => calc.sin(x),
  domain: (-2 * calc.pi, 2 * calc.pi),
  x: (-2 * calc.pi, 2 * calc.pi), y: (-1.5, 1.5),
  echelle: (0.9, 2.2),
  xnum: "pi", xpi: 2,
  nom: $sin x$, nom-t: 0.62, nom-dy: 0.3,
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

With a tick every $pi/6$:

#demo(```typ
#courbe(
  x => calc.cos(x),
  domain: (-calc.pi, calc.pi),
  x: (-calc.pi, calc.pi), y: (-1.5, 1.5),
  echelle: (2.4, 2.2),
  xnum: "pi", xpi: 6, tick-taille: 8pt,
  grille: "principale", couleur: red,
  nom: $cos x$, nom-t: 0.55, nom-dy: 0.3,
)
```)

== Line styles
The same function in six styles: `continu`, `tirets`, `pointille`, `mixte`, `points`, `lie`.

#demo(```typ
#courbe(
  x => 0.3 * x + 3.0,
  domain: (-3, 3), x: (-3, 3), y: (-3, 4.5),
  nom: [continu], nom-pos: (-2.2, 3.8),
  autres: (
    (f: x => 0.3 * x + 2.0, trait: "tirets", nom: [tirets], nom-pos: (-2.2, 2.8), couleur: red),
    (f: x => 0.3 * x + 1.0, trait: "pointille", nom: [pointille], nom-pos: (-2.2, 1.8), couleur: green),
    (f: x => 0.3 * x + 0.0, trait: "mixte", nom: [mixte], nom-pos: (-2.2, 0.8), couleur: purple),
    (f: x => 0.3 * x - 1.0, trait: "points", npts: 18, nom: [points], nom-pos: (-2.2, -0.2), couleur: orange),
    (f: x => 0.3 * x - 2.0, trait: "lie", marque: "x", npts: 10, nom: [lie], nom-pos: (-2.2, -1.2), couleur: teal),
  ),
  grille: false,
)
```)

== Piecewise function
Pass `none` as the main function and describe each piece with its domain. The end `"ouvert"` is an empty circle and `"ferme"` a filled one.

#demo(```typ
#courbe(
  none, x: (-3, 4), y: (-2, 5),
  morceaux: (
    (f: x => x + 2, domain: (-3, 0), droite: "ouvert", nom: $f_1$),
    (f: x => 0.5 * x * x + 1, domain: (0, 2), gauche: "ouvert", nom: $f_2$),
    (f: x => -x + 5, domain: (2, 4), nom: $f_3$),
  ),
  points: ((p: (0, 0.5), nom: $A$),),
  xlabel: $x$, ylabel: $y$,
)
```)

== Scaling the units as you like
`xunite` and `yunite` set the length of one unit in centimetres on each axis independently, so the plot grows or shrinks without changing the bounds.

#demo(```typ
#courbe(
  x => x * x / 4,
  domain: (-4, 4), x: (-4, 4), y: (-1, 4),
  xunite: 0.8, yunite: 1.5,
  nom: $C_f$, origine: $O$,
)
```)

With trigonometric labels, `xunite` is the length of $pi$ in centimetres:

#demo(```typ
#courbe(
  x => calc.sin(x),
  domain: (-calc.pi, calc.pi), x: (-calc.pi, calc.pi), y: (-1.5, 1.5),
  xnum: "pi", xpi: 2, xunite: 3, yunite: 2,
  nom: $sin x$, nom-t: 0.6, nom-dy: 0.3, origine: $O$,
)
```)

== Scale and axis labels
#demo(```typ
#courbe(
  x => x * x / 4,
  domain: (-4, 4), x: (-4, 4), y: (-1, 4),
  xstep: 2, ystep: 0.5, echelle: (0.8, 1),
  xlabel: $x$, ylabel: $y$, origine: $O$, nom: $C_f$,
)
```)

== Asymptotes, tangent and projected points
#demo(```typ
#courbe(
  x => 1 / (x - 1) + 2,
  branches: ((-4, 0.7), (1.3, 5)),
  x: (-4, 5), y: (-3, 7),
  va: ((v: 1, nom: $x = 1$, nom-pos: (1.6, 6.4)),),
  ha: ((v: 2, nom: $y = 2$, nom-pos: (-3, 1.6)),),
  tangente: (a: 3, nom: $T$),
  points: ((v: 3, nom: $A$, proj: true),),
  nom: $C_f$,
)
```)

#note("Why `branches`?", color: rgb("#c0392b"))[
  Around a vertical asymptote a fake line would join the two branches if we plotted on one domain, so we split the plot into two domains on each side of the asymptote.
]

== Segment and free points
#demo(```typ
#courbe(
  x => 0.2 * x * x,
  domain: (-4, 4), x: (-4, 4), y: (-1, 5),
  segments: ((de: (-2, 0.8), a: (3, 1.8), nom: $[A B]$, trait: "tirets", couleur: red),),
  points: ((p: (-2, 0.8), nom: $A$), (p: (3, 1.8), nom: $B$, ouvert: true)),
)
```)

== Area between a curve and the x-axis
#demo(```typ
#courbe(
  x => 4 - x * x,
  domain: (-3, 3), x: (-3, 3), y: (-3, 5),
  aire: (-2, 2), aire-nom: $cal(A)$, aire-nom-pos: (0, 1.5),
  couleur: purple, nom: $C_f$,
)
Area = #calc.round(integrale(x => 4 - x * x, -2, 2), digits: 3)
```)

== Area between two curves
Pass the second curve in `autres` so it is drawn, and in `aire-avec` so it bounds the area.

#demo(```typ
#let f = x => x * x - 2
#let g = x => 4 - x * x
#let r = calc.sqrt(3)
#courbe(
  f, x: (-3, 3), y: (-3, 5), nom: $C_f$,
  autres: ((f: g, nom: $C_g$, couleur: orange),),
  aire: (-r, r), aire-avec: g, aire-nom: $cal(A)$,
)
Area = #calc.round(integrale(f, -r, r, g: g), digits: 3)
```)

== Area between a curve and a line
#demo(```typ
#let f = x => x * x
#let d = x => x + 2
#courbe(
  f, x: (-2, 3), y: (-1, 6), nom: $C_f$,
  droites: ((a: 1, b: 2, nom: $d$),),
  aire: (-1, 2), aire-avec: d, aire-nom: $cal(A)$, couleur: teal,
)
Area = #calc.round(integrale(f, -1, 2, g: d), digits: 3)
```)

= More examples

== Exponential and logarithm
The two curves are symmetric about the dashed line $y = x$.

#demo(```typ
#courbe(
  x => calc.exp(x),
  domain: (-3, 1.7), x: (-3, 5), y: (-3, 5), size: (7, 7),
  nom: $e^x$, couleur: blue,
  autres: ((f: x => calc.ln(x), domain: (0.05, 5), nom: $ln x$, couleur: red),),
  droites: ((a: 1, b: 0, trait: "tirets", nom: $y = x$, nom-t: 0.15, nom-dy: 0.3),),
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

== Cubic function: extrema and tangent
#demo(```typ
#courbe(
  x => x * x * x / 3 - x,
  domain: (-2.5, 2.5), x: (-3, 3), y: (-3, 3), size: (7, 7),
  nom: $C_f$, nom-pos: (-2.2, -2.2),
  points: ((v: 1, nom: $A$, proj: true), (v: -1, nom: $B$, proj: true)),
  tangente: (a: 2, nom: $T$, trait: "tirets"),
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

== Absolute value
#demo(```typ
#courbe(
  x => calc.abs(x - 1) - 2,
  domain: (-3, 5), x: (-3, 5), y: (-3, 4), size: (8, 5),
  nom: $C_f$, nom-t: 0.9, nom-dy: 0.3,
  points: ((v: 1, nom: $S$, nom-ancre: "north"), (v: -1), (v: 3)),
  grille: "toutes", xminor: 0.5, yminor: 0.5, grille-trait: "pointille",
)
```)

== Square root with a closed point
#demo(```typ
#courbe(
  x => calc.sqrt(x),
  domain: (0, 8), x: (-1, 8), y: (-1, 4), size: (8, 5),
  nom: $C_f$, nom-t: 0.7, nom-dy: -0.35,
  points: ((p: (0, 0), nom: $O$, nom-ancre: "north-east"), (v: 4, nom: $A$, proj: true)),
  xlabel: $x$, ylabel: $y$,
)
```)

== Rational function with two asymptotes
#demo(```typ
#courbe(
  x => 2 + 3 / (x - 1),
  branches: ((-4, 0.4), (1.5, 5)),
  x: (-4, 5), y: (-3, 9), size: (8, 6),
  va: ((v: 1, nom: $x = 1$, nom-dx: 0.1),),
  ha: ((v: 2, nom: $y = 2$, nom-t: 0.05, nom-dy: -0.4),),
  nom: $C_f$, nom-t: 0.95, nom-dy: -0.4,
  origine: $O$,
)
```)

== Step function with open and closed ends
#demo(```typ
#courbe(
  none, x: (-3, 3), y: (-1, 3), size: (8, 4),
  morceaux: (
    (f: x => 1.0, domain: (-3, -1), droite: "ouvert", nom: $f_1$, nom-t: 0.5, nom-dy: 0.3),
    (f: x => 2.0, domain: (-1, 1), gauche: "ferme", droite: "ouvert", nom: $f_2$, nom-t: 0.5, nom-dy: 0.3),
    (f: x => 0.5, domain: (1, 3), gauche: "ferme", nom: $f_3$, nom-t: 0.5, nom-dy: 0.3),
  ),
  xlabel: $x$, ylabel: $y$,
)
```)

== Intersection of a curve and a line
#demo(```typ
#courbe(
  x => x * x, domain: (-2.5, 3), x: (-3, 3.5), y: (-1, 7), size: (8, 6),
  nom: $C_f$, nom-t: 0.1, nom-dy: 0.3,
  droites: ((a: 1, b: 2, nom: $d$, nom-t: 0.1, nom-dy: -0.3),),
  points: ((p: (-1, 1), nom: $A$, proj: true), (p: (2, 4), nom: $B$, proj: true)),
  origine: $O$,
)
```)

== A family of curves
We vary the coefficient $a$ in $y = a x^2$ and write its value next to each curve.

#demo(```typ
#courbe(
  x => 0.5 * x * x, domain: (-3, 3), x: (-3, 3), y: (-1, 6), size: (8, 5),
  nom: $a = 1 / 2$, nom-pos: (2.4, 1.0), couleur: blue,
  autres: (
    (f: x => x * x, domain: (-2.4, 2.4), nom: $a = 1$, nom-pos: (1.8, 4.2), couleur: red),
    (f: x => 2 * x * x, domain: (-1.7, 1.7), nom: $a = 2$, nom-pos: (1.2, 5.4), couleur: green),
  ),
  grille: false, origine: $O$,
)
```)

== Sine and cosine together
#demo(```typ
#courbe(
  x => calc.sin(x),
  domain: (-calc.pi, 2 * calc.pi), x: (-calc.pi, 2 * calc.pi), y: (-1.5, 1.5),
  echelle: (0.9, 2.2), xnum: "pi", xpi: 2,
  grille: "toutes", grille-trait: "pointille", grille-couleur: gray,
  nom: $sin x$, nom-t: 0.62, nom-dy: 0.3,
  autres: ((f: x => calc.cos(x), domain: (-calc.pi, 2 * calc.pi), trait: "tirets",
    nom: $cos x$, couleur: red, nom-t: 0.45, nom-dy: 0.3),),
  origine: $O$,
)
```)

== Tangent function and its vertical asymptotes
#demo(```typ
#courbe(
  x => calc.tan(x),
  branches: ((-calc.pi, -calc.pi / 2 - 0.3), (-calc.pi / 2 + 0.3, calc.pi / 2 - 0.3), (calc.pi / 2 + 0.3, calc.pi)),
  x: (-calc.pi, calc.pi), y: (-4, 4), echelle: (1.2, 0.7),
  xnum: "pi", xpi: 2, tick-taille: 9pt,
  va: (calc.pi / 2, -calc.pi / 2),
  nom: $tan x$, nom-pos: (0.9, 3.2), origine: $O$,
)
```)

== Area under the sine curve
#demo(```typ
#courbe(
  x => calc.sin(x),
  domain: (0, calc.pi), x: (-0.5, 3.8), y: (-0.5, 1.5), size: (8, 4),
  xnum: "pi", xpi: 2,
  aire: (0, calc.pi), aire-nom: $cal(A)$, aire-nom-pos: (calc.pi / 2, 0.4),
  couleur: purple, nom: $sin x$, nom-t: 0.2, nom-dy: 0.3,
)
Area = #calc.round(integrale(x => calc.sin(x), 0, calc.pi), digits: 3)
```)

= Reference guide to common functions

This chapter is a quick reference for the five families used most in function lessons: rational, exponential, logarithmic, absolute value and square root. Each family has a table summarising its domain, asymptotes and how to plot it, followed by ready-made examples covering its usual cases. Every example is really computed when this file is compiled, so copy the one closest to your problem and change the function and the bounds.

#let guide-table(..rows) = table(
  columns: (auto, 1fr), inset: 6pt, stroke: 0.5pt + luma(180),
  fill: (x, _) => if x == 0 { rgb("#dbe8f7") },
  ..rows,
)

#guide-table(
  [*Family*], [*Parameters you need*],
  [Rational], [`branches`, `va`, `ha` and an oblique line in `droites`],
  [Exponential], [a single `domain` and `ha`],
  [Logarithmic], [a `domain` starting at a small positive value, and `va`],
  [Absolute value], [`calc.abs` or `morceaux`],
  [Square root], [a `domain` starting at the domain boundary, `calc.max(0, ...)` and a closed point at the start],
)

== Rational functions

#guide-table(
  [*Form*], [$f(x) = P(x) / Q(x)$],
  [*Domain*], [all reals except the roots of the denominator],
  [*Vertical asymptote*], [at every root of the denominator not cancelled by the numerator: `va`],
  [*Horizontal asymptote*], [if the degree of the numerator ≤ the degree of the denominator: `ha`],
  [*Oblique asymptote*], [if the numerator degree = denominator degree + 1: a dashed line in `droites`],
  [*How to plot*], [`branches`: adjacent domains that stay slightly away from each vertical asymptote; `y` clips the long tails],
)

=== The reciprocal function $1/x$
#demo(```typ
#courbe(
  x => 1 / x,
  branches: ((-4, -0.25), (0.25, 4)),
  x: (-4, 4), y: (-4, 4), size: (7, 7),
  va: (0,), ha: (0,),
  nom: $C_f$, nom-t: 0.9, nom-dy: 0.4,
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

=== Homographic function (two asymptotes and a centre of symmetry)
#demo(```typ
#courbe(
  x => (2 * x + 1) / (x - 1),
  branches: ((-4, 0.6), (1.4, 6)),
  x: (-4, 6), y: (-4, 8), size: (8, 6),
  va: ((v: 1, nom: $x = 1$, nom-dx: 0.1),),
  ha: ((v: 2, nom: $y = 2$, nom-t: 0.05, nom-dy: -0.4),),
  points: ((p: (1, 2), nom: $Omega$),),
  nom: $C_f$, nom-t: 0.5, nom-dy: -0.4, origine: $O$,
)
```)

=== Function with an oblique asymptote
#demo(```typ
#courbe(
  x => (x * x - 1) / (x - 2),
  branches: ((-4, 1.6), (2.4, 6)),
  x: (-4, 6), y: (-8, 12), size: (7, 8),
  va: ((v: 2, nom: $x = 2$, nom-dx: 0.1),),
  droites: ((a: 1, b: 2, trait: "tirets", couleur: red,
    nom: $y = x + 2$, nom-t: 0.1, nom-dy: 0.4),),
  nom: $C_f$, nom-t: 0.8, nom-dy: -0.5, origine: $O$,
)
```)

=== Function with two vertical asymptotes
#demo(```typ
#courbe(
  x => 1 / (x * x - 1),
  branches: ((-3, -1.15), (-0.85, 0.85), (1.15, 3)),
  x: (-3, 3), y: (-4, 4), size: (7, 6),
  va: (1, -1), ha: (0,),
  nom: $C_f$, nom-pos: (2.4, 0.7), origine: $O$,
)
```)

== Exponential functions

#guide-table(
  [*Form*], [$f(x) = a^x$ with $a > 0$ and $a != 1$, or $e^x$],
  [*Domain and range*], [domain $RR$, range $]0, +oo[$],
  [*Asymptote*], [the line $y = 0$ (at $-oo$ if $a > 1$, at $+oo$ if $0 < a < 1$): `ha`],
  [*Fixed point*], [every curve goes through $(0, 1)$],
  [*How to plot*], [one domain, no `branches` needed. Use `calc.exp(x)` or `calc.pow(a, x)` with a float base],
)

=== The function $e^x$ with its asymptote and tangent
#demo(```typ
#courbe(
  x => calc.exp(x),
  domain: (-3, 2), x: (-3, 3), y: (-1, 8), size: (7, 6),
  ha: ((v: 0, nom: $y = 0$, nom-t: 0.8, nom-dy: -0.4),),
  tangente: (a: 0, nom: $T$, nom-t: 0.75),
  points: ((v: 0, nom: $A$, proj: true),),
  nom: $e^x$, nom-t: 0.9, nom-dx: -0.5,
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

=== The base decides the direction: $a > 1$ and $0 < a < 1$
#demo(```typ
#courbe(
  x => calc.pow(2.0, x),
  domain: (-3, 3), x: (-3, 3), y: (-1, 6), size: (7, 6),
  ha: (0,),
  nom: $2^x$, nom-pos: (2, 5.3), couleur: blue,
  autres: ((f: x => calc.pow(0.5, x), nom: $(1/2)^x$, nom-pos: (-2, 5.3), couleur: red),),
  points: ((p: (0, 1), nom: $A$, nom-ancre: "south-west"),),
  origine: $O$,
)
```)

=== Translation: $e^(x-1) + 1$
#demo(```typ
#courbe(
  x => calc.exp(x - 1) + 1,
  domain: (-3, 2.5), x: (-3, 3), y: (-1, 6), size: (7, 6),
  ha: ((v: 1, nom: $y = 1$, nom-t: 0.1, nom-dy: 0.35),),
  points: ((v: 1, nom: $A$, proj: true),),
  autres: ((f: x => calc.exp(x), domain: (-3, 1.8), trait: "tirets",
    couleur: gray, nom: $e^x$, nom-t: 0.85, nom-dx: -0.4),),
  nom: $C_f$, nom-t: 0.9, nom-dx: 0.3, nom-dy: -0.3,
)
```)

== Logarithmic functions

#guide-table(
  [*Form*], [$f(x) = ln x$ or $log_a x = (ln x) / (ln a)$],
  [*Domain*], [$]0, +oo[$, so start the domain at a small positive value such as `0.04`],
  [*Asymptote*], [the line $x = 0$: `va`],
  [*Fixed point*], [every curve goes through $(1, 0)$],
  [*In Typst*], [`calc.ln(x)` for the natural log, `calc.log(x)` for base 10, `calc.log(x, base: 2)` for any base],
  [*Link with exp*], [$ln$ and $exp$ are symmetric about $y = x$],
)

=== The function $ln x$ with its asymptote and tangent
#demo(```typ
#courbe(
  x => calc.ln(x),
  domain: (0.04, 8), x: (-1, 8), y: (-3, 3), size: (8, 6),
  va: ((v: 0, nom: $x = 0$, nom-t: 0.9, nom-dx: 0.1),),
  tangente: (a: 1, nom: $T$, nom-t: 0.35),
  points: ((v: 1, nom: $A$, nom-ancre: "north"),),
  nom: $ln x$, nom-t: 0.9, nom-dy: -0.4,
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

=== Different bases: $log_2$, $ln$ and $log_(10)$
#demo(```typ
#courbe(
  x => calc.log(x, base: 2),
  domain: (0.05, 8), x: (-1, 8), y: (-3, 3), size: (8, 6),
  va: (0,),
  nom: $log_2 x$, nom-t: 0.75, nom-dy: 0.3, couleur: blue,
  autres: (
    (f: x => calc.ln(x), domain: (0.05, 8), couleur: red,
      nom: $ln x$, nom-t: 0.75, nom-dy: 0.3),
    (f: x => calc.log(x), domain: (0.05, 8), couleur: green,
      nom: $log x$, nom-t: 0.75, nom-dy: 0.3),
  ),
  points: ((p: (1, 0), nom: $A$, nom-ancre: "north-west"),),
)
```)

=== Translation: $ln(x - 1) + 2$
#demo(```typ
#courbe(
  x => calc.ln(x - 1) + 2,
  domain: (1.05, 8), x: (-1, 8), y: (-2, 5), size: (8, 6),
  va: ((v: 1, nom: $x = 1$, nom-dx: 0.1),),
  points: ((p: (2, 2), nom: $A$, proj: true),),
  nom: $C_f$, nom-t: 0.8, nom-dy: -0.4, origine: $O$,
)
```)

=== Two branches: $ln |x|$
#demo(```typ
#courbe(
  x => calc.ln(calc.abs(x)),
  branches: ((-6, -0.04), (0.04, 6)),
  x: (-6, 6), y: (-3, 3), size: (8, 5),
  va: (0,),
  nom: $ln |x|$, nom-t: 0.8, nom-dy: -0.4, origine: $O$,
)
```)

== Absolute value functions

#guide-table(
  [*Form*], [$f(x) = |u(x)|$, equal to $u(x)$ where $u >= 0$ and $-u(x)$ where $u < 0$],
  [*Domain*], [the same as the domain of $u$],
  [*How to plot*], [`calc.abs(...)` directly; corners appear at the zeros of $u$],
  [*Pieces*], [can be written with `morceaux` to name each piece],
  [*Vertex*], [a free point `(p: (a, b), nom: $S$, proj: true)`],
)

=== The function $|x|$
#demo(```typ
#courbe(
  x => calc.abs(x),
  domain: (-4, 4), x: (-4, 4), y: (-1, 5), size: (7, 5),
  nom: $|x|$, nom-t: 0.9, nom-dy: -0.4,
  points: ((p: (0, 0), nom: $O$, nom-ancre: "north-east"),),
  xlabel: $x$, ylabel: $y$,
)
```)

=== The form $|a x + b| + c$ and its vertex
#demo(```typ
#courbe(
  x => calc.abs(2 * x - 3) - 1,
  domain: (-1, 4), x: (-1, 4), y: (-2, 6), size: (7, 6),
  points: ((p: (1.5, -1), nom: $S$, nom-ancre: "north", proj: true),),
  nom: $C_f$, nom-t: 0.9, nom-dy: -0.4, origine: $O$,
)
```)

=== The curve $|f|$ against $f$
#demo(```typ
#courbe(
  x => calc.abs(x * x - 1),
  domain: (-3, 3), x: (-3, 3), y: (-2, 5), size: (7, 6),
  nom: $|f|$, nom-t: 0.9, nom-dx: -0.6,
  autres: ((f: x => x * x - 1, trait: "tirets", couleur: gray,
    nom: $C_f$, nom-pos: (0.5, -1.4)),),
  origine: $O$,
)
```)

=== A sum of two absolute values: $|x| + |x - 2|$
#demo(```typ
#courbe(
  x => calc.abs(x) + calc.abs(x - 2),
  domain: (-3, 5), x: (-3, 5), y: (-1, 9), size: (7, 6),
  nom: $C_f$, nom-t: 0.9, nom-dy: -0.5, origine: $O$,
)
```)

=== Written piece by piece: $|x - 1|$
#demo(```typ
#courbe(
  none, x: (-3, 4), y: (-1, 4), size: (7, 5),
  morceaux: (
    (f: x => 1 - x, domain: (-3, 1), nom: $1 - x$, nom-t: 0.3, nom-dy: 0.3),
    (f: x => x - 1, domain: (1, 4), nom: $x - 1$, nom-t: 0.7, nom-dy: -0.4),
  ),
  points: ((p: (1, 0), nom: $S$, nom-ancre: "north"),),
)
```)

== Square root functions

#guide-table(
  [*Form*], [$f(x) = sqrt(u(x))$],
  [*Domain*], [only where $u(x) >= 0$: start `domain` exactly at the boundary],
  [*Avoiding errors*], [write `calc.sqrt(calc.max(0, u))` so tiny rounding errors never take the root of a negative number at the ends],
  [*Starting point*], [a closed free point at the start of the domain `(p: (a, 0))`],
  [*Branches*], [if the domain has two parts (such as $x^2 - 1 >= 0$) use `branches`],
)

=== Translations of the root: $sqrt(x)$, $sqrt(x + 2)$ and $sqrt(x - 1)$
#demo(```typ
#courbe(
  x => calc.sqrt(x),
  domain: (0, 8), x: (-3, 8), y: (-1, 4), size: (8, 5),
  nom: $sqrt(x)$, nom-t: 0.1, nom-dy: -0.4, couleur: blue,
  autres: (
    (f: x => calc.sqrt(calc.max(0, x + 2)), domain: (-2, 8), couleur: red,
      nom: $sqrt(x + 2)$, nom-t: 0.35, nom-dy: 0.35),
    (f: x => calc.sqrt(calc.max(0, x - 1)), domain: (1, 8), couleur: green,
      nom: $sqrt(x - 1)$, nom-t: 0.7, nom-dy: -0.4),
  ),
  points: ((p: (0, 0)), (p: (-2, 0)), (p: (1, 0))),
)
```)

=== The root and its reflection: $sqrt(x)$ and $-sqrt(x)$
#demo(```typ
#courbe(
  x => calc.sqrt(x),
  domain: (0, 6), x: (-1, 6), y: (-3, 3), size: (7, 6),
  nom: $sqrt(x)$, nom-t: 0.8, nom-dy: 0.35,
  autres: ((f: x => -calc.sqrt(x), domain: (0, 6),
    nom: $-sqrt(x)$, nom-t: 0.8, nom-dy: -0.4),),
  origine: $O$,
)
```)

=== A half circle: $sqrt(4 - x^2)$
#demo(```typ
#courbe(
  x => calc.sqrt(calc.max(0, 4 - x * x)),
  domain: (-2, 2), x: (-3, 3), y: (-1, 3), size: (6, 4),
  points: ((p: (-2, 0), nom: $A$, nom-ancre: "north"), (p: (2, 0), nom: $B$, nom-ancre: "north")),
  nom: $sqrt(4 - x^2)$, nom-pos: (0, 1), origine: $O$,
)
```)

=== Two branches: $sqrt(x^2 - 1)$ with its oblique asymptotes
#demo(```typ
#courbe(
  x => calc.sqrt(calc.max(0, x * x - 1)),
  branches: ((-4, -1), (1, 4)),
  x: (-4, 4), y: (-1, 5), size: (8, 5),
  droites: (
    (a: 1, b: 0, trait: "tirets", couleur: gray),
    (a: -1, b: 0, trait: "tirets", couleur: gray),
  ),
  points: ((p: (-1, 0), nom: $A$, nom-ancre: "north"), (p: (1, 0), nom: $B$, nom-ancre: "north")),
  nom: $sqrt(x^2 - 1)$, nom-t: 0.7, nom-dy: -0.45,
)
```)

= The `integrale` function
```typ
integrale(f, a, b, g: none, n: 2000, absolu: true)
```
It computes $display(integral_a^b |f(t) - g(t)| dif t)$ with Simpson's rule. Without `g`, the area is between the curve and the x-axis. With `absolu: false` we get the signed integral.

#note("Note", color: rgb("#27ae60"))[
  The area between two curves is the integral of $|f - g|$, so choose the area bounds at the intersection abscissas, or where the order of the curves does not change.
]

= Common problems

#table(columns: (1fr, 1.4fr), inset: 7pt, stroke: 0.5pt + luma(180),
  fill: (_, y) => if y == 0 { rgb("#fbe3e0") },
  table.header([*Problem*], [*Solution*]),
  [A label does not appear], [Its position is outside the `x` and `y` frame; change `nom-pos`.],
  [A label covers the curve], [Change `nom-pos`, `nom-t` or `nom-dy`, or set `fond-noms: true`.],
  [A fake line between two branches], [Use `branches` and stay away from the asymptote.],
  [`trait: "points"` has too few points], [Increase `npts`.],
  [A constant function such as `x => 2` gives an error], [Write it `x => 2.0`.],
  [Numbers appear reversed], [Add `#set text(dir: ltr)`.],
  [Unexpected area], [Make sure the `aire` bounds lie between the intersection abscissas.],
  [The minor grid does not show], [Use `grille: "secondaire"` or `"toutes"`, and make sure `xminor` or `yminor` is smaller than the major step.],
  [The centimetre lines do not match the ticks], [Make `xunite` and `yunite` whole numbers (centimetres per unit), or keep `milli-ancre: "origine"` (the default).],
  [Millimetre paper is too dense when printed], [Use `milli-fin: false` to drop the 1 mm lines, or a thinner `grille-epaisseur`.],
  [Error `x must be (min, max)`], [The bounds of `x` and `y` must be `(smaller, larger)`.],
  [Trigonometric labels are off], [Make the `x` bounds multiples of the step $pi/"xpi"$, e.g. `(-2 * calc.pi, 2 * calc.pi)`.],
)
