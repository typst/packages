/// Creates a 3D vector field (quiver) plot. Arrows are drawn at grid points
/// throughout the 3D plot bounds, with direction and magnitude given by the
/// field function. Arrow lengths are auto-scaled unless a manual scale is
/// provided.
#let quiver3d(

  /// A function `(x, y, z) => (i, j, k)` returning the vector components at each grid point.
  /// -> function
  field,

  /// Spacing between sample grid points along the x axis.
  /// -> int | float
  x-step: 1,

  /// Spacing between sample grid points along the y axis.
  /// -> int | float
  y-step: 1,

  /// Spacing between sample grid points along the z axis.
  /// -> int | float
  z-step: 1,

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

) = {
  (
    quiver3d: field,
    x-step: x-step,
    y-step: y-step,
    z-step: z-step,
    scale: scale,
    pivot: pivot,
    stroke: stroke,
    color: color,
  )
}
