// Function plot series constructors and convenience wrappers.

#import "../helpers.typ": _resolve-fn

/// Plots a function $y = f(x)$ as a continuous curve. The function is sampled
/// over the plot domain and rendered as a stroked path with optional markers.
#let func-plot(
  ..args,

  /// The function to plot, taking a single argument $x$ and returning $y$.
  /// Can be passed as the first positional argument or via this parameter.
  /// -> function | none
  fn: none,

  /// Restricts the plotting domain to `(xmin, xmax)`. When `auto`, the
  /// plot's own x-axis range is used.
  /// -> auto | array
  domain: auto,

  /// Stroke style for the curve.
  /// -> stroke
  stroke: blue + 1.2pt,

  /// Number of sample points used to draw the curve.
  /// -> int
  samples: 100,

  /// Marker shape drawn at sampled points. Use `"none"` to disable.
  /// -> str
  mark: "none",

  /// Size of each marker in canvas units.
  /// -> float
  mark-size: 0.1,

  /// Fill color for markers.
  /// -> color
  mark-fill: blue,

  /// Stroke style for markers.
  /// -> stroke
  mark-stroke: blue + 0.8pt,

  /// Draw a marker every this many sample points.
  /// -> int
  mark-interval: 10,

  /// Legend label for this series. `none` omits it from the legend.
  /// -> content | none
  label: none,

  /// Position along the curve (0 to 1) where the inline label is placed.
  /// -> float
  label-pos: 0.8,

  /// CeTZ anchor for the inline label relative to its point on the curve.
  /// -> str
  label-anchor: "south-west",
) = {
  let fn = _resolve-fn("func-plot", args, fn)
  let spec = (
    fn: fn, stroke: stroke, samples: samples,
    mark: mark, mark-size: mark-size, mark-fill: mark-fill,
    mark-stroke: mark-stroke, mark-interval: mark-interval,
    label: label, label-pos: label-pos, label-anchor: label-anchor,
  )
  if domain != auto { spec.insert("domain", domain) }
  spec
}

// plot-fn and plot-rational call plot() directly, so they are defined in
// plot.typ alongside the main function. We re-export them from lib.typ.
