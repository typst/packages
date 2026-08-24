# pythagorean-spiral — the Spiral of Theodorus (the Pythagorean snail)

A zero-dependency Typst package that draws the famous spiral of right
triangles. Each triangle adds a leg of length `size` at a right angle to
the previous hypotenuse, so the n-th triangle has legs `√n·size` and
`size`, and hypotenuse `√(n+1)·size`.

```typst
#import "@preview/pythagorean-spiral:0.1.0": *

#pythagorean-spiral(steps: 17, size: 1cm)
```

Everything is drawn with plain Typst primitives (`polygon`, `line`,
`curve`, `circle`, `place`) — no plugin, no CeTZ dependency, fully
measurable, works anywhere a box does.

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `steps` | `12` | Number of triangles (1–5000) |
| `size` | `1cm` | Length of the starting leg |
| `fill` | `none` | Fill of the triangles: `none`, a `color`, a `gradient` (sampled along the spiral) or an `array` of colors (interpolated along the spiral) |
| `stroke` | `black` | Outline: `none`, a `color`, or a full `stroke` |
| `stroke-width` | `1pt` | Outline thickness when `stroke` is a color |
| `direction` | `"ccw"` | `"ccw"` (counter-clockwise) or `"cw"` |
| `start-angle` | `0deg` | Rotation of the whole spiral |
| `mode` | `"triangles"` | `"triangles"`, `"spiral"` (outer staircase only) or `"rays"` (segments from the centre only) |
| `show-hypotenuses` | `true` | Draw the inner rays O → Pₙ |
| `right-angle-marks` | `false` | Draw small square marks at every right angle |
| `right-angle-size` | `3mm` | Side of the right-angle marks |
| `center-dot` | `true` | Dot at the centre O |
| `center-dot-radius` | `1.2mm` | Dot radius |
| `center-dot-fill` | `black` | Dot colour |
| `labels` | `none` | `"vertices"` (P₀…Pₙ), `"indices"` (numbers the triangles) or `"lengths"` (leg/hypotenuse lengths) |
| `label-size` | `8pt` | Label font size |
| `label-offset` | `4mm` | Distance of vertex labels from the vertex |
| `length-labels` | `none` | `"values"` (decimal of `a·√n`, e.g. "1.414 cm"), `"formulas"` (exact `√n` in units of `a`, simplified: `√1`→`1`, `√4`→`2`), or a function `(k, len) => content` — writes the exact length `a·√n` of each ray; labels are rotated parallel to their ray and centred on it |
| `label-new-legs` | `false` | Also label the new perpendicular legs of every triangle (each has the exact length `a` of the starting leg); the labels are placed on the OUTSIDE of the spiral so they never cover the drawing |
| `new-leg-offset` | `2.5mm` | Perpendicular distance of the new-leg labels from their segment (outward) |
| `length-size` | `7pt` | Font size of the length labels |
| `length-pos` | `0.72` | Position of the ray labels ALONG their ray: 0 = at the centre O, 1 = at the outer endpoint Pₙ (near the outer end the rays are further apart, so labels do not overlap) |
| `length-offset` | `0` | Perpendicular distance of the ray labels from their ray (0 = labels sit on the segment) |
| `length-label-background` | `white` | Background colour behind the length labels (white by default so labels stay readable over the strokes, even without triangle fills; pass `none` to remove it) |
| `padding` | `7mm` | Space around the drawing |
| `background` | `none` | Canvas background colour |

## Examples

```typst
// classic classroom spiral
#pythagorean-spiral(steps: 17, size: 1cm)

// gradient fill, clockwise, thicker stroke
#pythagorean-spiral(
  steps: 30,
  size: 1.2cm,
  fill: gradient.linear(rgb("#ff6b6b"), rgb("#4ecdc4")),
  stroke: 1.5pt + rgb("#2d3436"),
  direction: "cw",
)

// hand-coloured triangles + right-angle marks + indices
#pythagorean-spiral(
  steps: 10,
  size: 1cm,
  fill: (yellow, orange, red),
  right-angle-marks: true,
  labels: "indices",
)

// length labels: the exact length a·√n of every ray
// (n = 1 is the starting leg, length a = a·√1)
#pythagorean-spiral(
  steps: 8, size: 1.2cm,
  fill: blue.transparentize(70%),
  length-labels: "values",       // decimal: 1 cm, 1.414 cm, 1.732 cm, ...
  length-label-background: white,
)
#pythagorean-spiral(
  steps: 8, size: 1.2cm,
  length-labels: "formulas",     // exact: √1, √2, √3, ...
  label-new-legs: true,          // the new legs too: each has length a -> "1"
)

// poster with vertex labels
#pythagorean-spiral(
  steps: 8,
  size: 1.4cm,
  labels: "vertices",
  label-size: 9pt,
  fill: blue.transparentize(70%),
)
```

## Geometry helpers

```typst
#spiral-points(steps)        // vertices P_0 … P_N (math coords, units of size)
#spiral-angle(steps)         // accumulated angle (angle)
```

With 17 triangles the accumulated angle already exceeds a full turn:
`#spiral-angle(17)` ≈ 364.78° — the spiral famously overshoots 360°.

## License

MIT. This is an independent package, not affiliated with any LaTeX project.

FERGOUS Abdelhak
