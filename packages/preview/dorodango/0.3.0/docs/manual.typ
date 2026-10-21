#import "@preview/tidy:0.4.3"
#import "../src/lib.typ": clothoid, squircle, superellipse

#let light-gray = oklch(93.5%, 0.005, 265deg)
#let medium-gray = oklch(60%, 0.005, 265deg)

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
  outset: (y: 2.6pt, x: 0.3pt),
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

#let api-squircle = tidy.parse-module(
  read("../src/squircle.typ"),
  name: "squircle",
  label-prefix: "api-squircle-",
  require-all-parameters: true,
  scope: (squircle: squircle),
)

#let api-superellipse = tidy.parse-module(
  read("../src/superellipse.typ"),
  name: "superellipse",
  label-prefix: "api-superellipse-",
  require-all-parameters: true,
  scope: (superellipse: superellipse),
)

#let api-clothoid = tidy.parse-module(
  read("../src/clothoid.typ"),
  name: "clothoid",
  label-prefix: "api-clothoid-",
  require-all-parameters: true,
  scope: (clothoid: clothoid),
)

#show: tidy.render-examples.with(
  scope: (
    squircle: squircle,
    superellipse: superellipse,
    clothoid: clothoid,
  ),
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

`dorodango` provides three functions (`squircle`, `superellipse`, and `clothoid`) that mirror the built-in `rect` element, replacing abrupt circular corners with smooth curve transitions.

#align(center)[
  #grid(
    columns: 4,
    rows: 2,
    align: center,
    row-gutter: 6.5pt,
    column-gutter: 22pt,
    rect(
      width: 80pt,
      height: 55pt,
      radius: (top-left: 50%),
      fill: aqua,
    ),
    squircle(
      width: 80pt,
      height: 55pt,
      radius: (top-left: 50%),
      smoothing: 100%,
      fill: aqua,
    ),
    superellipse(
      width: 80pt,
      height: 55pt,
      radius: (top-left: 50%),
      exponent: 5,
      fill: aqua,
    ),
    clothoid(
      width: 80pt,
      height: 55pt,
      radius: (top-left: 50%),
      smoothing: 100%,
      fill: aqua,
    ),

    text(fill: medium-gray)[Rectangle],
    text(fill: medium-gray)[Squircle],
    text(fill: medium-gray)[Superellipse],
    text(fill: medium-gray)[Clothoid],
  )
]

Note that each family is driven by different parameters (see the #link(<api>)[API reference]), so the comparison above is not like-for-like. While `squircle` and `clothoid` corner blends can extend along adjacent edges as space allows, `superellipse` corners always stay strictly within their radius.

= API reference <api>

// squircle

#tidy.show-module(
  api-squircle,
  style: tidy.styles.default,
  first-heading-level: 1,
  show-module-name: false,
  show-outline: false,
)

// superellipse

#tidy.show-module(
  api-superellipse,
  style: tidy.styles.default,
  first-heading-level: 1,
  show-module-name: false,
  show-outline: false,
)

// clothoid

#tidy.show-module(
  api-clothoid,
  style: tidy.styles.default,
  first-heading-level: 1,
  show-module-name: false,
  show-outline: false,
)

= Concepts and examples

== Squircle

`squircle` draws #link("https://www.figma.com/blog/desperately-seeking-squircles/")[Figma's] squircle corner, a circular arc with a cubic Bézier shoulder at either end. `smoothing` splits the corner's 90° turn between the shoulders and the arc, so at `0%` the corner is a plain quarter circle and at `100%` the arc vanishes and the two shoulders meet. `preserve-smoothing` and `per-edge-smoothing`, both specific to `squircle`, control what happens when the requested corner does not fit.

=== Smoothing

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
    )[smoothing: #repr(s)]
  ]),
)
```

=== Preserve smoothing

Large radii and high smoothing both consume space along a corner's edges. For a corner with radius $r$ and smoothing $s$, the required space along each edge is $p = (1 + s) r$. When $p$ exceeds the available edge budget $b$, `preserve-smoothing` determines how the shape adjusts:

- `preserve-smoothing: false` (default) preserves the radius and reduces smoothing to $b / r - 1$.
- `preserve-smoothing: true` keeps both the requested radius and smoothing, compressing the Bézier transitions to fit the edge.

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

=== Per-edge smoothing

Each half of a corner uses space along one adjacent edge, and those edges may have different lengths. For example, on an elongated rectangle, a short edge might run out of space for smoothing while the long edge still has plenty of room.

- `per-edge-smoothing: false` (default) uses the tighter edge budget for both halves, keeping the corner symmetric.
- `per-edge-smoothing: true` allows each half to adapt to its own edge budget independently.

When `preserve-smoothing` is `false`, smoothing is reduced only on the tighter edge, giving the two halves different transition angles. When `preserve-smoothing` is `true`, both halves retain their transition angles, but the transition on the tighter edge is compressed to fit.

```example
#grid(
  rows: 2,
  gutter: 12pt,
  ..(false, true).map(u => align(center + horizon)[
    #squircle(
      width: 150pt,
      height: 48pt,
      radius: 25pt,
      smoothing: 100%,
      per-edge-smoothing: u,
      fill: aqua,
    )[per-edge-smoothing: #repr(u)]
  ]),
)
```

== Superellipse

`superellipse` draws corners based on Lamé curves ($|x/p|^n + |y/p|^n = 1$), fitted with three cubic Bézier segments inside a square corner footprint of side $p$. For $n > 2$, the curve meets straight edges with zero curvature.

=== Exponent

The `exponent` parameter sets $n$, clamped to $[2, 12]$. At $n = 2$, the corner is an exact circular arc matching `rect`. Higher values make the corner squarer. Near $n = 12$, the cubic fit trades exact curve fidelity to stay strictly within the corner footprint.

```example
#grid(
  rows: 3,
  gutter: 12pt,
  ..(2, 3, 6).map(n => align(center + horizon)[
    #superellipse(
      width: 75pt,
      height: 48pt,
      radius: 35%,
      exponent: n,
      fill: aqua,
    )[exponent: #n]
  ]),
)
```

== Clothoid

`clothoid` draws Euler-spiral corner blends, ramping curvature linearly from zero at the straight edge up to the curvature of a central circular arc. Each spiral transition is approximated by a single cubic Bézier segment.

=== Smoothing

`smoothing` splits the 90° corner turn between the spiral transitions and the central circular arc. At `0%`, the corner is a standard circular arc matching `rect`. At `100%`, the central arc vanishes and the two spirals meet directly.

When a blend requires more space than the adjacent edge allows, `clothoid` uniformly scales down both the spiral lengths and circular radius, keeping the angular smoothing proportions intact.

```example
#grid(
  rows: 3,
  gutter: 12pt,
  ..(0%, 60%, 100%).map(s => align(center + horizon)[
    #clothoid(
      width: 75pt,
      height: 48pt,
      radius: 35%,
      smoothing: s,
      fill: aqua,
    )[smoothing: #repr(s)]
  ]),
)
```

== Common parameters

Although `squircle`, `superellipse`, and `clothoid` take different parameters to shape their corners, they share the common ones described below:

=== Size and body

`width` and `height` set the shape's layout dimensions. When both are `auto`, the shape sizes itself to fit the content passed in the body.

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

=== Fill

`fill` sets the interior color, gradient, or tiling pattern.

```example
#grid(
  rows: 2,
  gutter: 12pt,
  squircle(width: 75pt, height: 48pt, radius: 10pt, fill: aqua),
  squircle(width: 75pt, height: 48pt, radius: 10pt, fill: gradient.linear(..color.map.flare)),
)
```

=== Stroke

`stroke` sets the border outline, either uniformly or per side.

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

=== Radius

`radius` controls corner rounding, either as a single value for all corners or per corner.

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

=== Inset and outset

`inset` adds internal padding around the content, while `outset` extends the background drawing outward without affecting layout dimensions.

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
    outset: 7pt,
    fill: aqua,
  )[Outset expands the drawing],
)
```
