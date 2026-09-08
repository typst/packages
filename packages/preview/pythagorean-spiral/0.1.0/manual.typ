// pythagorean-spiral — manual
#import "@preview/pythagorean-spiral:0.1.0": *
#set page(width: 21cm, height: 29.7cm, margin: 1.8cm)
#set text(size: 10.5pt)
#set par(justify: true)
#set heading(numbering: "1.")

// display helper: an example is just an inset box with its content
#let example(body) = block(
  width: 100%,
  inset: 8pt,
  radius: 4pt,
  stroke: 0.5pt + rgb("#cccccc"),
  fill: rgb("#fafafa"),
  body,
)

#align(center, text(size: 26pt, weight: "bold")[The Spiral of Theodorus])
#align(center, text(size: 13pt, fill: luma(68))[#emoji.hand.write FERGOUS Abdelhak])
#align(center, text(size: 11pt, fill: rgb("#666666"))[
  pythagorean-spiral — a Typst package · v0.1.0
])

#v(6pt)
#line(length: 100%, stroke: 0.7pt)

= The construction

The *spiral of Theodorus* (also called the *snail of Pythagoras*, "escargot
de Pythagore") is built from right triangles sharing a common vertex $O$:

- triangle 1 is right-angled isosceles with legs of length $a$;
- every following triangle has one leg equal to the previous hypotenuse
  and the *other leg still equal to $a$* (the new leg added at each step
  always has the length $a$ of the starting segment).

Hence, for any starting length $a$, the $n$-th triangle has legs
$a sqrt(n)$ and $a$, and hypotenuse $a sqrt(n + 1)$:

#table(
  columns: (auto, auto, auto),
  stroke: 0.5pt + rgb("#999999"),
  [*Triangle*], [*Legs*], [*Hypotenuse*],
  [1], [$a$, $a$], [$a sqrt(2)$],
  [2], [$a sqrt(2)$, $a$], [$a sqrt(3)$],
  [3], [$a sqrt(3)$, $a$], [$a sqrt(4)$],
  [$dots.v$], [$dots.v$], [$dots.v$],
  [$n$], [$a sqrt(n)$, $a$], [$a sqrt(n + 1)$],
)

The angle added at step $n$ is

$ theta_n = arctan(1 / sqrt(n)) $

so after $N$ triangles the spiral has turned by

$ phi_N = sum_(n=1)^N arctan(1 / sqrt(n)) $

which famously exceeds a full turn already at $N = 17$:
$phi_17 approx 364.78 degree$.

#align(center)[
  #pythagorean-spiral(
    steps: 2,
    size: 1cm,
    length-labels: "formulas",   // lengths in units of a: 1, sqrt(2), sqrt(3)
    label-new-legs: true,        // the new legs: all of length a -> "1"
  )
]
#align(center, text(size: 8.5pt, fill: rgb("#666666"))[
  The length labels are in units of $a$: each new leg has length $a$ (shown
  as 1), the rays have length $a sqrt(1), a sqrt(2), a sqrt(3), ...$.
])

= Basic usage

#example([
  #pythagorean-spiral(steps: 12, size: 1cm)
])

The package works with pure Typst primitives: the result is a normal box
that measures, nests and flows like any other content.

= Parameters

== steps and size

#example([
  #pythagorean-spiral(steps: 5, size: 1cm)
  #pythagorean-spiral(steps: 12, size: 1cm)
  #pythagorean-spiral(steps: 17, size: 1cm)
])

== fill

`fill` accepts a colour, a gradient (sampled along the spiral) or an array
of colours (interpolated along the spiral):

#example([
  #pythagorean-spiral(steps: 20, size: 0.9cm, fill: teal)
  #pythagorean-spiral(steps: 20, size: 0.9cm, fill: gradient.linear(red, blue))
  #pythagorean-spiral(steps: 20, size: 0.9cm, fill: (yellow, orange, red))
])

== stroke

#example([
  #pythagorean-spiral(steps: 12, size: 0.9cm, stroke: none)
  #pythagorean-spiral(steps: 12, size: 0.9cm, stroke: 2pt + navy)
  #pythagorean-spiral(steps: 12, size: 0.9cm, stroke: (paint: green, thickness: 1.5pt, dash: "dashed"))
])

== direction and start-angle

#example([
  #pythagorean-spiral(steps: 12, size: 0.9cm, direction: "cw")
  #pythagorean-spiral(steps: 12, size: 0.9cm, start-angle: 90deg)
])

== mode

- `"triangles"` — full outlines (default);
- `"spiral"` — only the outer staircase $P_0 → P_1 → ... → P_N$;
- `"rays"` — only the segments from the centre.

#example([
  #pythagorean-spiral(steps: 17, size: 0.8cm, mode: "spiral")
  #pythagorean-spiral(steps: 17, size: 0.8cm, mode: "rays")
  #pythagorean-spiral(steps: 17, size: 0.8cm, show-hypotenuses: false)
])

== Length labels

Write the exact length of every ray. The ray closing the $k$-th triangle
($O arrow.r P_(k-1)$) has length $a sqrt(k)$, where $a$ is the length of
the starting leg and $k$ is the step number — the starting leg itself is
step 1 ($a sqrt(1) = a$). Each label is *rotated parallel to its ray* and
stays on it, positioned along the ray by `length-pos` (default 0.72: 0 = at
the centre O, 1 = at the outer endpoint $P_n$) — near the outer end the
rays are further apart, so the labels do not overlap. `length-offset`
(default 0) moves them perpendicularly if needed. With
`label-new-legs: #true` the new perpendicular legs (each of length $a$)
are labelled too — their labels are pushed to the *outside* of the spiral
(`new-leg-offset`, default 2.5 mm) so they never cover the drawing inside.
Three modes:

- `"values"` — decimal approximation of $a sqrt(k)$ ("1 cm", "1.414 cm",
  "1.732 cm", ...);
- `"formulas"` — the *exact* value $sqrt(k)$ in units of $a$, simplified
  for perfect squares: $sqrt(1) arrow.r 1$, $sqrt(4) arrow.r 2$, ...;
- a function `(k, len) => content` for full control, where `k` is the step
  number (1 = starting leg) and `len = sqrt(k)` in units of `size`, so the
  exact length is `size · len = size · sqrt(k)`.

#example([
  #pythagorean-spiral(steps: 6, size: 1.1cm, length-labels: "values")
  #pythagorean-spiral(steps: 6, size: 1.1cm, length-labels: "formulas")
])

By default the labels carry a white background so they stay readable over
the strokes — even when the triangles are not filled. Pass
`length-label-background: #none` to remove it.

For readability on coloured fills, add a background:

#example([
  #pythagorean-spiral(
    steps: 8, size: 1.1cm,
    fill: blue.transparentize(70%),
    length-labels: "values",
  )
  #pythagorean-spiral(
    steps: 8, size: 1.1cm,
    fill: (yellow, orange),
    length-labels: (k, len) => [$k$],
  )
])

== Teaching annotations

Right-angle marks, vertex labels and triangle indices:

#example([
  #pythagorean-spiral(
    steps: 8, size: 1.1cm, fill: blue.transparentize(75%),
    labels: "vertices", right-angle-marks: true,
  )
  #pythagorean-spiral(
    steps: 10, size: 1cm, fill: (yellow, orange),
    labels: "indices", label-size: 7pt,
  )
])

= Geometry helpers

- `#raw("spiral-points(steps, direction: \"ccw\", start-angle: 0deg)")`
  returns the vertices $P_0 … P_N$ in math coordinates (y up), in units of
  the leg length — handy for drawing the spiral inside a CeTZ canvas or for
  further computations.
- `#raw("spiral-angle(steps)")` returns the accumulated angle.

#example([
  #let pts = spiral-points(5)
  #let angle = spiral-angle(17)
  [#pts.len() vertices · angle 17 = #(angle / 1deg)°]
])

= License

MIT. This is an independent package.
