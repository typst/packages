// ===========================================================================
//  showcase.typ — every instrument, in both modes.
//
//  typst compile examples/showcase.typ --root .
// ===========================================================================

#import "@preview/geomtools:0.1.0": *

#set page(paper: "a4", margin: (x: 1.8cm, y: 2cm), numbering: "1")
#set text(size: 10pt, font: ("Libertinus Serif", "DejaVu Serif"))
#set par(justify: true)
#show heading.where(level: 1): it => block(above: 1.5em, below: 0.7em, {
  text(size: 15pt, weight: "bold", it.body)
  v(-0.55em)
  line(length: 100%, stroke: 0.7pt + rgb("#1864AB"))
})
#show heading.where(level: 2): it => block(above: 1.1em, below: 0.5em,
  text(size: 10.5pt, weight: "bold", style: "italic", it.body))
#show raw: set text(font: "DejaVu Sans Mono", size: 8.2pt)

#let cap(t) = align(center, text(size: 8pt, fill: luma(100), style: "italic", t))
#let src(c) = block(width: 100%, fill: luma(248), inset: 6pt, radius: 3pt,
  above: 0.5em, below: 0.6em, raw(c, lang: "typ"))

#v(-1em)
#align(center)[
  #text(size: 26pt, weight: "bold")[geomtools]
  #v(-1em)
  #text(size: 13pt, fill: luma(68))[#emoji.hand.write FERGOUS Abdelhak]
  #v(-0.45em)
  #text(size: 11pt, fill: luma(80))[
    drawing instruments for Typst — clean or hand-drawn
  ]
  #v(0.4em)
  #text(size: 9pt, fill: luma(105))[
    a port of #raw("OutilsGeomTikZ") by Cédric Pierquet
  ]
]

#v(0.8em)

Every instrument is described *once*, as geometry. The renderer then draws it
either crisp — as the LaTeX original does — or with a hand-drawn wobble.
Writing each tool twice, once per mode, would guarantee the two drift apart.

#src("#import \"@preview/geomtools:0.1.0\": *

#geom(mode: \"rough\", {
  ruler(length: 10)
  pencil(at: (3, 2), rotate: -20deg)
})")

= The two modes

#grid(columns: (1fr, 1fr), column-gutter: 10pt,
  [
    #align(center, geom(ruler(length: 7), padding: 0.35))
    #cap[`mode: "clean"` — the default]
  ],
  [
    #align(center, geom(ruler(length: 7), mode: "rough", padding: 0.35))
    #cap[`mode: "rough"`]
  ],
)

`roughness` scales the wobble; the seed makes it reproducible, so a figure
looks the same on every compile.

#align(center, grid(columns: 4, column-gutter: 6pt,
  ..(0.5, 1, 2, 3.5).map(r => [
    #geom(set-square(length: 5), mode: "rough", roughness: r, padding: 0.3)
    #cap(raw("roughness: " + str(r)))
  ])))

#v(-0.39em)

= The instruments

== Pencil — `pencil`

#grid(columns: (auto, 1fr), column-gutter: 12pt, align: horizon,
  geom({
    pencil(length: 4)
    pencil(at: (1.6, 0), length: 4, colour: rgb("#1864AB"))
    pencil(at: (3.2, 0), length: 4, colour: rgb("#2F9E44"))
  }, padding: 0.3),
  [
    Tip at the origin, pointing up. `length` is the whole pencil; the original
    clamps it to a 2.5 cm minimum, and so does this.

    #src("#pencil(at: (0, 0), rotate: 0deg, length: 5,
        colour: rgb(\"#D62828\"))")
  ],
)

== Ruler — `ruler`

Zero at the origin, running right. Three graduation depths at 1 mm, 5 mm and
1 cm, exactly as the original draws them.

#align(center, geom(ruler(length: 11, width: 1.8), padding: 0.3))
#cap[`ruler(length: 11, width: 1.8)`]

`values` places the numerals: `"h"` above the scale, `"m"` down the middle,
`"b"` upside-down along the far edge — a real ruler reads both ways up.

#align(center, geom(ruler(length: 9, width: 2.4, value-pos: "hb"),
  padding: 0.3))
#cap[`value-pos: "hb"`]

#pagebreak()

== Set square — `set-square`

A 30-60-90 square. The original derives the base from the height
($"width" = "length" times tan 30 degree$), so the angles are always right.

#grid(columns: (1fr, 1fr), column-gutter: 10pt,
  [
    #align(center, geom(set-square(length: 7), padding: 0.3))
    #cap[clean]
  ],
  [
    #align(center, geom(set-square(length: 7), mode: "rough", padding: 0.3))
    #cap[rough]
  ],
)

== Protractor — `protractor`

Radii follow the original exactly: outer 3.75, inner 2.5, degree ticks
stepping in to 3.55 / 3.45 / 3.35, and the radian band between 2.5 and 3.1.

#grid(columns: (1fr, 1fr), column-gutter: 8pt,
  [
    #align(center, geom(protractor(), padding: 0.25))
    #cap[`protractor()`]
  ],
  [
    #align(center, geom(protractor(full: true, scale: 0.62), padding: 0.25))
    #cap[`full: true`]
  ],
)

== Percent dial and protractor-square

#grid(columns: (1fr, 1fr), column-gutter: 8pt,
  [
    #align(center, geom(percent-dial(scale: 0.62), padding: 0.25))
    #cap[`percent-dial()` — the disc graduated 0–100]
  ],
  [
    #align(center, geom(protractor-square(width: 7), padding: 0.25))
    #cap[`protractor-square(width: 7)`]
  ],
)

== Ruler-square and the small tools

#grid(columns: (1fr, auto), column-gutter: 10pt, align: horizon,
  align(center, geom(ruler-square(length: 8, width: 2.6), padding: 0.3)),
  align(center, geom({
    mini-square()
    mini-ruler(at: (1.6, 0.2))
  }, padding: 0.3)),
)
#cap[`ruler-square`, then `mini-square` and `mini-ruler`]

#pagebreak()

== Compasses — `compass`

Given two points, the legs open so the instrument really does span them:

$ "half-angle" = arcsin( (|"from" - "to"|) / (2 times "leg") ) $

The needle lands on `from` and the pencil tip on `to`, at any bearing.

#align(center, geom({
  compass((0, 0), (4.5, 0))
  compass((7, 0), (9.5, 2.2), pencil-colour: rgb("#1864AB"))
}, padding: 0.4))
#cap[`compass(from, to)` — the span is exact, whatever the direction]

#align(center, geom(compass((0, 0), (5, 0)), mode: "rough", padding: 0.4))
#cap[the same, `mode: "rough"`]

= A worked figure

The instruments are meant to sit on a construction, showing how it was made.

#align(center, geom({
  // the construction: a segment and the arc being struck from A
  p-line((0, 0), (8, 0), stroke: luma(120), weight: 1.0)
  p-arc((0, 0), 4.5, 12deg, 78deg, stroke: rgb("#1864AB"), weight: 1.2)
  p-circle((0, 0), 0.07, fill: black, stroke: none)
  p-circle((8, 0), 0.07, fill: black, stroke: none)
  p-label((0, -0.4), [$A$], size: 9pt)
  p-label((8, -0.4), [$B$], size: 9pt)
  // the compasses striking that arc
  compass((0, 0), (4.5 * calc.cos(45deg), 4.5 * calc.sin(45deg)))
  // and the ruler that drew the segment
  ruler(at: (0, -0.55), length: 8, width: 1.5, values: false)
}, padding: 0.4))
#cap[a construction with the instruments that made it]

#v(0.6em)
#line(length: 100%, stroke: 0.4pt + luma(180))
#v(0.3em)
#text(size: 8pt, fill: luma(110))[
  Ported from `OutilsGeomTikZ` by Cédric Pierquet (LPPL 1.3c). The
  proportions, graduation patterns and the compass opening formula follow the
  original source; the rendering and the rough mode are native Typst.
]
