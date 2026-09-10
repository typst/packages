/// Creates a contour line plot for a scalar field `z = f(x, y)`. Iso-lines are
/// computed at the specified levels using marching squares (via Komet) and
/// rendered as curves in the 2D plot. Optionally, the regions between levels
/// can be filled with colors from a color map.
#let contour(

  /// A function `(x, y) => z` returning the scalar value at each point.
  /// -> function
  fn,

  /// The z-values at which to draw contour lines. A single number is
  /// wrapped into a one-element array.
  /// -> array | int | float
  levels: (-2, -1, 0, 1, 2),

  /// Number of samples along each axis for evaluating the field.
  /// -> int
  samples: 80,

  /// Whether to fill the regions between contour levels with color.
  /// -> bool
  fill: false,

  /// Stroke style for unfilled contour lines.
  /// -> stroke
  stroke: 1pt,

  /// Colors for the contour levels. When `auto`, a default color map is used.
  /// -> auto | array
  colors: auto,

) = {
  (
    contour: fn,
    levels: if type(levels) in (int, float) { (levels,) } else { levels },
    samples: samples,
    contour-fill: fill,
    stroke: stroke,
    colors: colors,
  )
}
