#import "@preview/tidy:0.4.3"
#import "../src/lib.typ": squircle

#let light-gray = oklch(92%, 0.004, 265deg)
#let medium-gray = oklch(60%, 0.004, 265deg)

#set document(title: "dorodango manual")

#set page(
  paper: "a4",
  numbering: "1",
  number-align: center + bottom,
)

#set text(font: "Source Sans 3", size: 10.8pt)

#set raw(lang: "manual-inline")

#show raw.where(block: false, lang: "manual-inline"): set text(size: 9.2pt)

#show raw.where(block: false, lang: "manual-inline"): box.with(
  outset: (y: 2.7pt, x: 0.3pt),
  inset: (x: 2.5pt),
  fill: light-gray,
  radius: 2.2pt,
)

#set par(justify: true, leading: 0.72em, justification-limits: (
  tracking: (min: -0.012em, max: 0.012em),
  spacing: (min: 70%, max: 130%),
))

#set heading(numbering: none)

#show heading.where(level: 1): it => {
  set text(size: 16pt)
  set block(below: 0.8em)
  block(it)
}

#show heading.where(level: 2): it => {
  set block(below: 0.8em)
  block(it)
}

#show link: set text(fill: rgb("4B69BE"))

#show footnote: set text(fill: rgb("4B69BE"))

#let api = tidy.parse-module(
  read("../src/squircle.typ"),
  name: "squircle",
  label-prefix: "api-",
  require-all-parameters: true,
  scope: (squircle: squircle),
)

#show: tidy.render-examples.with(
  scope: (squircle: squircle),
  layout: (code, preview) => grid(
    columns: (1fr, 0.5fr),
    gutter: 10pt,
    block(breakable: false, inset: 10pt, fill: rgb("ddd3"), width: 100%)[#code],
    block(breakable: false, inset: 10pt, width: 100%)[
      #set text(font: "Source Sans 3", size: 10.8pt)
      #preview
    ],
  ),
)

#grid(
  columns: (1fr,),
  rows: 2,
  align: center,
  gutter: 0.525cm,
  text(size: 27pt, weight: "bold")[dorodango],
  text(
    fill: medium-gray,
  )[Draw squircles in Typst with tunable corner smoothing],
)

#v(1cm)

#outline(title: [Contents], depth: 2)

#pagebreak()

= Introduction

A squircle is a rounded rectangle whose corners blend smoothly into its straight edges. Unlike a standard rounded rectangle, which transitions abruptly from a straight edge to a circular arc, a squircle has a gradual change in curvature around each corner. As a result, a squircle reads as one unified shape, rather than a square that has simply had its corners clipped or rounded off.

#align(center)[
  #grid(
    columns: 2,
    rows: 2,
    align: center,
    row-gutter: 7pt,
    column-gutter: 25pt,
    rect(
      width: 90pt,
      height: 60pt,
      radius: (top-left: 50%),
      fill: aqua,
    ),
    squircle(
      width: 90pt,
      height: 60pt,
      radius: (top-left: 50%),
      smoothing: 100%,
      fill: aqua,
    ),

    text(fill: medium-gray)[Rectangle], text(fill: medium-gray)[Squircle],
  )
]

`dorodango` draws squircles by placing two cubic Bézier transitions between the circular portion of each corner and its adjoining straight edges#footnote[#link("https://www.figma.com/blog/desperately-seeking-squircles/")[Daniel Furse, "Desperately seeking squircles"]]. The Bézier control points determine the extent and curvature profile of these transitions and, therefore, the smoothness of the corners. When the adjoining straight edges do not provide enough room for the full transitions, the transitions are normally shortened to fit. Alternatively, the Bézier handles can be shortened, compressing the corner while preserving the intended smoothness#footnote[#link("https://github.com/JaceThings/Lisse")[JaceThings/Lisse implementation]].

= API reference

#tidy.show-module(
  api,
  style: tidy.styles.default,
  first-heading-level: 1,
  show-module-name: false,
  show-outline: false,
)

= Examples

== Size and body

`width` and `height` set the squircle's layout size. When both are `auto`, the squircle takes its size from the positional body passed in square brackets, as the first shape below illustrates, while the second uses fixed dimensions.

```example
#grid(
  rows: 2,
  gutter: 12pt,
  squircle(radius: 10pt, fill: aqua)[Auto-sized body],
  squircle(
    width: 150pt,
    height: 55pt,
    radius: 10pt,
    fill: aqua,
  )[Fixed width and height],
)
```

== Fill

`fill` sets the squircle's interior paint. In the example below, the first shape uses a solid color and the second uses a linear gradient.

```example
#grid(
  rows: 2,
  gutter: 12pt,
  squircle(width: 75pt, height: 48pt, radius: 10pt, fill: aqua),
  squircle(width: 75pt, height: 48pt, radius: 10pt, fill: gradient.linear(..color.map.flare)),
)
```

== Stroke

`stroke` draws the outline. In the example below, the first shape uses one stroke on every edge, while the second assigns each edge its own stroke.

```example
#grid(
  rows: 2,
  gutter: 12pt,
  squircle(
    width: 75pt,
    height: 48pt,
    radius: 10pt,
    stroke: 3pt + fuchsia,
  ),
  squircle(
    width: 75pt,
    height: 48pt,
    radius: 10pt,
    stroke: (top: 3pt + red, bottom: none, right: blue, left: 5pt + orange),
  ),
)
```

== Radius

`radius` controls corner rounding. In the example below, the shapes show square corners, one shared radius, and a smaller top-left radius with a shared value for the remaining corners.

```example
#grid(
  rows: 3,
  gutter: 12pt,
  squircle(
    width: 75pt,
    height: 48pt,
    radius: 0pt,
    fill: aqua,
  ),
  squircle(
    width: 75pt,
    height: 48pt,
    radius: 35%,
    fill: aqua,
  ),
  squircle(
    width: 75pt,
    height: 48pt,
    radius: (top-left: 4pt, rest: 20pt),
    fill: aqua,
  ),
)
```

== Inset and outset

`inset` pads the body, while `outset` expands the drawing without changing layout. In the example below, the first shape has neither, the second uses an inset, and the third uses an outset.

```example
#grid(
  rows: 3,
  gutter: 12pt,
  squircle(
    width: 90pt,
    height: 48pt,
    radius: 10pt,
    fill: aqua,
  )[No inset or outset],
  squircle(
    width: 90pt,
    height: 48pt,
    inset: (x: 20pt, y: 10pt),
    radius: 10pt,
    fill: aqua,
  )[Inset adds padding],
  squircle(
    width: 90pt,
    height: 48pt,
    radius: 10pt,
    outset: 8pt,
    fill: aqua,
  )[Outset expands the drawing],
)
```

== Smoothing

`smoothing` controls the gradual transition between edges and corners. In the example below, the shapes use `0%`, `60%`, and `100%` smoothing.

```example
#grid(
  rows: 3,
  gutter: 12pt,
  ..(0%, 60%, 100%).map(s => align(center + horizon)[
    #squircle(
      width: 75pt,
      height: 48pt,
      radius: 35%,
      smoothing: s,
      fill: aqua,
    )[#repr(s)]
  ]),
)
```

== Preserve smoothing

Large radii and high smoothing each need room along the edges beside a corner and small elements may not have enough room for both. `preserve-smoothing` controls whether radius or smoothing takes priority.

- `preserve-smoothing: false` keeps the requested radius, within the limits of the shape, and lowers the smoothing value until the corner fits.
- `preserve-smoothing: true` keeps the requested smoothing and the circular arc derived from the radius. To make the corner fit, it shortens the Bézier transitions between the straight edges and that arc.

To prevent adjacent corners from overlapping, `dorodango` first determines how much of each adjoining edge a corner can use. This available space depends on the edge length and the radii of the corners at its ends. With radius $r$ and smoothing $s$, a corner initially needs $p = (1 + s) r$ along each adjoining edge. If this exceeds the available space $b$, `preserve-smoothing: false` reduces smoothing to $b / r - 1$ while keeping the radius. With `preserve-smoothing: true`, `dorodango` keeps the radius, smoothing, and circular portion of the corner, then shortens the Bézier transitions so it fits within the available space.

```example
#grid(
  rows: 2,
  gutter: 12pt,
  ..(false, true).map(keep => align(center + horizon)[
    #squircle(
      width: 75pt,
      height: 48pt,
      radius: 18pt,
      smoothing: 100%,
      preserve-smoothing: keep,
      fill: aqua,
    )[preserve-smoothing: #repr(keep)]
  ]),
)
```
