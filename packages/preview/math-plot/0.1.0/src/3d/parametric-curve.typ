/// Creates a 3D parametric curve from a mapping `t => (x, y, z)`. The curve
/// is sampled at evenly spaced values of t and drawn as connected line
/// segments through the projected 3D points.
#let parametric-curve(

  /// A function `t => (x, y, z)` returning the 3D position at parameter t.
  /// -> function
  fn,

  /// The `(min, max)` range for the parameter t.
  /// -> array
  t-range: (0, 1),

  /// Number of sample points along the curve.
  /// -> int
  samples: 100,

  /// Stroke style for the curve.
  /// -> stroke
  stroke: 1.2pt + blue,

) = {
  (
    parametric-curve: fn,
    t-range: t-range,
    samples: samples,
    stroke: stroke,
  )
}
