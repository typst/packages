// Fill-area series constructors.

#import "../helpers.typ": _resolve-fn

/// Fills the area between a function curve and a horizontal baseline. Useful
/// for shading regions under (or above) a curve.
#let fill-area(
  ..args,

  /// The function $y = f(x)$ whose curve bounds the filled region. Can be
  /// passed as the first positional argument or via this parameter.
  /// -> function | none
  fn: none,

  /// Restricts the fill domain to `(xmin, xmax)`. When `auto`, the plot's
  /// own x-axis range is used.
  /// -> auto | array
  domain: auto,

  /// The y-value of the horizontal baseline that closes the filled region.
  /// -> float
  baseline: 0.0,

  /// Fill color for the shaded region.
  /// -> color
  color: luma(220),

  /// Hatch pattern angle in degrees. `none` disables hatching.
  /// -> none | angle
  hatch: none,

  /// Spacing between hatch lines.
  /// -> length
  hatch-spacing: 5pt,

  /// Stroke style for hatch lines.
  /// -> stroke
  hatch-stroke: luma(80) + 0.5pt,

  /// Number of sample points used to approximate the function curve.
  /// -> int
  samples: 80,
) = {
  let fn = _resolve-fn("fill-area", args, fn)
  let spec = (
    fill: fn, baseline: baseline, color: color,
    hatch: hatch, hatch-spacing: hatch-spacing, hatch-stroke: hatch-stroke,
    samples: samples,
  )
  if domain != auto { spec.insert("domain", domain) }
  spec
}

/// Fills the area between two function curves. The region is bounded by the
/// two curves and optionally restricted to a domain.
#let area-between(
  ..args,

  /// First bounding function $y = f_1(x)$. Can be passed positionally.
  /// -> function | none
  fn1: none,

  /// Second bounding function $y = f_2(x)$. Can be passed positionally.
  /// -> function | none
  fn2: none,

  /// Restricts the fill domain to `(xmin, xmax)`. When `auto`, the plot's
  /// own x-axis range is used.
  /// -> auto | array
  domain: auto,

  /// Fill color for the shaded region.
  /// -> color
  color: luma(220),

  /// Hatch pattern angle in degrees. `none` disables hatching.
  /// -> none | angle
  hatch: none,

  /// Spacing between hatch lines.
  /// -> length
  hatch-spacing: 5pt,

  /// Stroke style for hatch lines.
  /// -> stroke
  hatch-stroke: luma(80) + 0.5pt,

  /// Number of sample points used to approximate the bounding curves.
  /// -> int
  samples: 80,
) = {
  assert(args.named().len() == 0,
    message: "area-between: unknown named arguments: " + args.named().keys().join(", "))
  let pos = args.pos()
  assert((fn1 == none) == (fn2 == none) and pos.len() == if fn1 == none { 2 } else { 0 },
    message: "area-between: expected two functions, positionally or as fn1:/fn2:")
  let (fn1, fn2) = if fn1 != none { (fn1, fn2) } else { (pos.at(0), pos.at(1)) }
  let spec = (
    fill-between: (fn1, fn2), color: color,
    hatch: hatch, hatch-spacing: hatch-spacing, hatch-stroke: hatch-stroke,
    samples: samples,
  )
  if domain != auto { spec.insert("domain", domain) }
  spec
}

/// Fills a closed region defined by a parametric boundary curve
/// $(x(t), y(t))$. The curve is automatically closed.
#let fill-closed(

  /// Function $x(t)$ returning the x-coordinate of the boundary.
  /// -> function
  fn-x,

  /// Function $y(t)$ returning the y-coordinate of the boundary.
  /// -> function
  fn-y,

  /// Parameter range as `(t-min, t-max)`.
  /// -> array
  domain: (0.0, 1.0),

  /// Fill color for the enclosed region.
  /// -> color
  color: luma(220),

  /// Hatch pattern angle in degrees. `none` disables hatching.
  /// -> none | angle
  hatch: none,

  /// Spacing between hatch lines.
  /// -> length
  hatch-spacing: 5pt,

  /// Stroke style for hatch lines.
  /// -> stroke
  hatch-stroke: luma(80) + 0.5pt,

  /// Number of sample points used to approximate the boundary curve.
  /// -> int
  samples: 80,
) = (
  fill-closed: (fn-x, fn-y), domain: domain, color: color,
  hatch: hatch, hatch-spacing: hatch-spacing, hatch-stroke: hatch-stroke,
  samples: samples,
)
