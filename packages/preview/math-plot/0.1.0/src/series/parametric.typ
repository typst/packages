// Parametric curve series constructor.

/// Plots a 2D parametric curve $(x(t), y(t))$ by sampling two coordinate
/// functions over a parameter domain.
#let parametric(

  /// Function $x(t)$ returning the x-coordinate for parameter $t$.
  /// -> function
  fn-x,

  /// Function $y(t)$ returning the y-coordinate for parameter $t$.
  /// -> function
  fn-y,

  /// Parameter range as `(t-min, t-max)`.
  /// -> array
  domain: (0.0, 1.0),

  /// Stroke style for the curve.
  /// -> stroke
  stroke: blue + 1.2pt,

  /// Number of sample points used to draw the curve.
  /// -> int
  samples: 100,
) = (parametric: (fn-x, fn-y), domain: domain, stroke: stroke, samples: samples)
