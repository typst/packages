/// Creates a 2D vector field (quiver) plot. Arrows are drawn at grid points
/// across the plot bounds, with direction and magnitude given by the field
/// function. Arrow lengths are auto-scaled relative to average magnitude and
/// grid density unless a manual scale is provided.
#let quiver(

  /// A function `(x, y) => (u, v)` returning the vector components at each grid point.
  /// -> function
  field,

  /// Horizontal spacing between sample grid points.
  /// -> int | float
  x-step: 1,

  /// Vertical spacing between sample grid points.
  /// -> int | float
  y-step: 1,

  /// Scaling factor for arrow lengths. When `auto`, arrows are auto-scaled
  /// based on average magnitude and grid density.
  /// -> auto | int | float
  scale: auto,

  /// Anchor point of each arrow relative to the grid point: `"start"`, `"center"`, or `"end"`.
  /// -> str
  pivot: "center",

  /// Stroke style for the arrow shafts.
  /// -> stroke
  stroke: 1pt + black,

  /// Fill color for the arrowheads.
  /// -> color
  color: black,

  /// Arrow tip mark style. When `auto`, a default arrowhead is used.
  /// -> auto | str
  tip: auto,

) = {
  (
    quiver: field,
    x-step: x-step,
    y-step: y-step,
    scale: scale,
    pivot: pivot,
    stroke: stroke,
    color: color,
    tip: tip,
  )
}
