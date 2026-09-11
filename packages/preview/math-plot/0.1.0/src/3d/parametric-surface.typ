/// Creates a 3D parametric surface from a mapping `(u, v) => (x, y, z)`.
/// The parameter domain is sampled on a regular grid, tessellated into quads,
/// depth-sorted, and rendered with per-face color mapped from the z-component.
#let parametric-surface(

  /// A function `(u, v) => (x, y, z)` returning the 3D position for each
  /// parameter pair.
  /// -> function
  fn,

  /// The `(min, max)` range for the u parameter.
  /// -> array
  u-range: (0, 1),

  /// The `(min, max)` range for the v parameter.
  /// -> array
  v-range: (0, 1),

  /// Number of samples along the u axis.
  /// -> int
  u-samples: 25,

  /// Number of samples along the v axis.
  /// -> int
  v-samples: 25,

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
    parametric-surface: fn,
    u-range: u-range,
    v-range: v-range,
    u-samples: u-samples,
    v-samples: v-samples,
    colormap: colormap,
    stroke: stroke,
    opacity: opacity,
  )
}
