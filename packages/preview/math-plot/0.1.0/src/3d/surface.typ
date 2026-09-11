/// Creates a 3D surface plot for a function `z = f(x, y)`. The surface is
/// sampled on a regular grid over the plot's x/y bounds, tessellated into
/// quads, depth-sorted, and rendered with per-face color mapped from the
/// z-value.
#let surface(

  /// A function `(x, y) => z` returning the height at each grid point.
  /// -> function
  fn,

  /// Number of samples along each axis of the grid.
  /// -> int
  samples: 25,

  /// Color map used to shade faces by z-value. When `auto`, a default
  /// blue-to-red ramp is used.
  /// -> auto | gradient | array
  colormap: auto,

  /// Stroke style for the wireframe edges of each quad.
  /// -> stroke
  stroke: 0.3pt + luma(80),

  /// Opacity applied to each face fill.
  /// -> ratio
  opacity: 80%,

) = {
  (
    surface: fn,
    samples: samples,
    colormap: colormap,
    stroke: stroke,
    opacity: opacity,
  )
}
