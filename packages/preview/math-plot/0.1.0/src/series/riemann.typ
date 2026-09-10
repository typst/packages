// Riemann sum series constructor.

#import "../helpers.typ": _resolve-fn

/// Draws a Riemann sum approximation for a function, rendering the
/// approximating rectangles with optional sample-point markers and
/// $Delta x$ / $x_i$ annotations for teaching illustrations.
#let riemann-sum(
  ..args,

  /// The function $y = f(x)$ to approximate. Can be passed as the first
  /// positional argument or via this parameter.
  /// -> function | none
  fn: none,

  /// Restricts the sum domain to `(xmin, xmax)`. When `auto`, the plot's
  /// own x-axis range is used.
  /// -> auto | array
  domain: auto,

  /// Number of rectangles (sub-intervals).
  /// -> int
  n: 4,

  /// Sample-point method: `"left"`, `"right"`, or `"midpoint"`.
  /// -> str
  method: "right",

  /// The y-value of the horizontal baseline for the rectangles.
  /// -> float
  baseline: 0.0,

  /// Fill color for the rectangles.
  /// -> color
  color: luma(220),

  /// Stroke style for the rectangle outlines.
  /// -> stroke
  stroke: luma(80) + 0.6pt,

  /// Hatch pattern angle in degrees. `none` disables hatching.
  /// -> none | angle
  hatch: none,

  /// Spacing between hatch lines.
  /// -> length
  hatch-spacing: 5pt,

  /// Stroke style for hatch lines.
  /// -> stroke
  hatch-stroke: luma(80) + 0.5pt,

  /// Number of sample points per rectangle edge for curved tops.
  /// -> int
  samples: 20,

  /// Whether to draw markers at the sample points on the curve.
  /// -> bool
  show-points: false,

  /// Color of the sample-point markers.
  /// -> color
  point-color: rgb("#c94a00"),

  /// Size of the sample-point markers in canvas units.
  /// -> float
  point-size: 0.07,

  /// Content label placed next to a sample point. `none` disables.
  /// -> content | none
  point-label: none,

  /// Position of the point label. When `auto`, placed above or below
  /// depending on the function value.
  /// -> auto | str
  point-label-pos: auto,

  /// Whether to annotate $Delta x$ on one of the rectangles.
  /// -> bool
  show-dx: false,

  /// Which rectangle (0-based index) receives the $Delta x$ annotation.
  /// When `auto`, the last rectangle is used.
  /// -> auto | int
  dx-rect: auto,

  /// Content used for the $Delta x$ label.
  /// -> content
  dx-label: $Delta x$,

  /// Whether to annotate $x_i$ tick marks beneath the sample points.
  /// -> bool
  show-xi: false,

  /// Custom labels for each $x_i$ tick. When `auto`, generated
  /// automatically.
  /// -> auto | array
  xi-labels: auto,

  /// Whether to display numeric values alongside the $x_i$ labels.
  /// -> bool
  xi-show-values: false,
) = {
  let fn = _resolve-fn("riemann-sum", args, fn)
  let spec = (
    riemann: fn, n: n, method: method, baseline: baseline,
    color: color, stroke: stroke,
    hatch: hatch, hatch-spacing: hatch-spacing, hatch-stroke: hatch-stroke,
    samples: samples,
    show-points: show-points, point-color: point-color, point-size: point-size,
    point-label: point-label, point-label-pos: point-label-pos,
    show-dx: show-dx, dx-rect: dx-rect, dx-label: dx-label,
    show-xi: show-xi, xi-labels: xi-labels, xi-show-values: xi-show-values,
  )
  if domain != auto { spec.insert("domain", domain) }
  spec
}

// volume-of-revolution is defined in plot.typ since it creates its own canvas.
